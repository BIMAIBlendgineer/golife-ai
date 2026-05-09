-- GoLife AI SQLite migration v5
-- MindFlow Core + EcoShop Domain

CREATE TABLE IF NOT EXISTS mental_load_items (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  domain TEXT NOT NULL,
  state TEXT NOT NULL,
  urgency_score REAL NOT NULL,
  effort_score REAL NOT NULL,
  confidence REAL NOT NULL,
  privacy_level TEXT NOT NULL,
  created_at_iso TEXT NOT NULL,
  updated_at_iso TEXT NOT NULL,
  json_blob TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_mental_load_user_state
ON mental_load_items(user_id, state);

CREATE INDEX IF NOT EXISTS idx_mental_load_domain
ON mental_load_items(domain);

CREATE INDEX IF NOT EXISTS idx_mental_load_priority
ON mental_load_items(state, urgency_score, effort_score);

CREATE TABLE IF NOT EXISTS decision_cards (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  status TEXT NOT NULL,
  final_score REAL NOT NULL,
  confidence REAL NOT NULL,
  created_at_iso TEXT NOT NULL,
  updated_at_iso TEXT NOT NULL,
  json_blob TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_decision_cards_user_status
ON decision_cards(user_id, status);

CREATE INDEX IF NOT EXISTS idx_decision_cards_score
ON decision_cards(status, final_score);

CREATE TABLE IF NOT EXISTS shopping_needs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  need_type TEXT NOT NULL,
  state TEXT NOT NULL,
  urgency_score REAL NOT NULL,
  currency TEXT,
  created_at_iso TEXT NOT NULL,
  updated_at_iso TEXT NOT NULL,
  json_blob TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_shopping_needs_user_state
ON shopping_needs(user_id, state);

CREATE INDEX IF NOT EXISTS idx_shopping_needs_type
ON shopping_needs(need_type);

CREATE TABLE IF NOT EXISTS product_evidence_cards (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  brand TEXT,
  sustainability_status TEXT NOT NULL,
  checked_at_iso TEXT,
  confidence REAL NOT NULL,
  json_blob TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_product_evidence_user_product
ON product_evidence_cards(user_id, product_name);

CREATE INDEX IF NOT EXISTS idx_product_evidence_status
ON product_evidence_cards(sustainability_status);
