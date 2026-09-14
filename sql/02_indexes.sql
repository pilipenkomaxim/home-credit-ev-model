CREATE INDEX IF NOT EXISTS idx_bureau_curr   ON bureau (sk_id_curr);
CREATE INDEX IF NOT EXISTS idx_bureau_bureau ON bureau (sk_id_bureau);
CREATE INDEX IF NOT EXISTS idx_bb_bureau     ON bureau_balance (sk_id_bureau);
CREATE INDEX IF NOT EXISTS idx_prev_curr     ON previous_application (sk_id_curr);
CREATE INDEX IF NOT EXISTS idx_inst_curr     ON installments_payments (sk_id_curr);
CREATE INDEX IF NOT EXISTS idx_cc_curr       ON credit_card_balance (sk_id_curr);
CREATE INDEX IF NOT EXISTS idx_pos_curr      ON pos_cash_balance (sk_id_curr);
ANALYZE;
