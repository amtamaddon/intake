-- Episodic memory schema. This database is a DERIVED, REBUILDABLE INDEX over the
-- flat files under tasks/ and archive/tasks/ -- it carries no authority of its own.
-- If the DB and the flat files ever disagree, the flat files win, and
-- scripts/index_rebuild.py regenerates the DB from scratch. Never hash-chain this
-- database; it is not part of the audit trail, only a query convenience over it.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS tasks (
  task_id          TEXT PRIMARY KEY,
  title            TEXT NOT NULL,
  impact_class     TEXT NOT NULL CHECK (impact_class IN ('internal','money','client-facing')),
  status           TEXT NOT NULL CHECK (status IN ('active','stopped','done','archived')),
  created_ts       TEXT,
  closed_ts        TEXT,
  iterations       INTEGER NOT NULL DEFAULT 0,
  final_result     TEXT CHECK (final_result IN ('PASS','FAIL','ESCALATE-TO-HUMAN') OR final_result IS NULL),
  approved_by      TEXT,
  goal_text        TEXT,
  tags             TEXT,
  worklog_tip_hash TEXT,
  indexed_ts       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS worklog_entries (
  task_id  TEXT    NOT NULL REFERENCES tasks(task_id) ON DELETE CASCADE,
  seq      INTEGER NOT NULL,
  ts       TEXT    NOT NULL,
  actor    TEXT    NOT NULL,
  prev     TEXT    NOT NULL,
  hash     TEXT    NOT NULL,
  message  TEXT    NOT NULL,
  PRIMARY KEY (task_id, seq)
);

CREATE TABLE IF NOT EXISTS verdicts (
  task_id         TEXT    NOT NULL REFERENCES tasks(task_id) ON DELETE CASCADE,
  n               INTEGER NOT NULL,
  result          TEXT    NOT NULL CHECK (result IN ('PASS','FAIL','ESCALATE-TO-HUMAN')),
  model           TEXT,
  ts              TEXT,
  failed_criteria TEXT,
  path            TEXT    NOT NULL,
  PRIMARY KEY (task_id, n)
);

CREATE TABLE IF NOT EXISTS trace_events (
  task_id            TEXT NOT NULL REFERENCES tasks(task_id) ON DELETE CASCADE,
  ts                 TEXT NOT NULL,
  event              TEXT NOT NULL,
  actor              TEXT,
  model              TEXT,
  iteration          INTEGER,
  latency_s          REAL,
  input_tokens       INTEGER,
  output_tokens      INTEGER,
  cache_read_tokens  INTEGER,
  cache_write_tokens INTEGER,
  cost_usd           REAL,
  outcome            TEXT
);
CREATE INDEX IF NOT EXISTS idx_trace_task_ts ON trace_events(task_id, ts);

CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts USING fts5(
  title, goal_text, tags, task_id UNINDEXED, tokenize='porter unicode61'
);
CREATE VIRTUAL TABLE IF NOT EXISTS worklog_fts USING fts5(
  message, actor, task_id UNINDEXED, seq UNINDEXED, tokenize='porter unicode61'
);
CREATE VIRTUAL TABLE IF NOT EXISTS verdicts_fts USING fts5(
  failed_criteria, task_id UNINDEXED, n UNINDEXED, tokenize='porter unicode61'
);
