-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 請求書管理テーブル
-- ==============================

-- 請求書テーブル
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- 請求書番号
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    
    -- 請求期間
    billing_period_from DATE NOT NULL, -- 期間開始（例：2025-01-01）
    billing_period_to DATE NOT NULL,   -- 期間終了（例：2025-01-31）
    
    -- 締日情報
    closing_date DATE NOT NULL, -- 締日（例：2025-01-31）
    
    -- 金額（オーダーから集計）
    subtotal_amount DECIMAL(12,2) NOT NULL, -- 小計
    tax_amount DECIMAL(12,2) NOT NULL,      -- 消費税
    total_amount DECIMAL(12,2) NOT NULL,    -- 合計
    
    -- 発行状況
    invoice_date DATE, -- 請求書発行日
    issued_at TIMESTAMP WITH TIME ZONE, -- 発行日時
    issued_by INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 発行者
    
    -- 支払い情報
    payment_due_date DATE, -- 支払期限
    payment_status VARCHAR(20) CHECK (payment_status IN ('未発行', '発行済', '入金済', '延滞', 'キャンセル')) DEFAULT '未発行',
    payment_date DATE, -- 入金日
    payment_amount DECIMAL(12,2), -- 入金額
    
    -- その他
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_invoices_number ON invoices(invoice_number);
CREATE INDEX IF NOT EXISTS idx_invoices_customer ON invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_period ON invoices(billing_period_from, billing_period_to);
CREATE INDEX IF NOT EXISTS idx_invoices_closing_date ON invoices(closing_date);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(payment_status);
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_date ON invoices(invoice_date);

-- 請求書とオーダーの紐付けテーブル
CREATE TABLE IF NOT EXISTS invoice_orders (
    invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    order_id INTEGER NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
    
    -- この紐付けの作成日時
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (invoice_id, order_id)
);

CREATE INDEX IF NOT EXISTS idx_invoice_orders_invoice ON invoice_orders(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_orders_order ON invoice_orders(order_id);

-- サンプルデータ

-- 請求書1: 都築産業（1月分）
INSERT INTO invoices (
    invoice_number, customer_id,
    billing_period_from, billing_period_to, closing_date,
    subtotal_amount, tax_amount, total_amount,
    invoice_date, issued_at, payment_due_date, payment_status
) VALUES (
    'INV-2025-001', 1,
    '2025-01-01', '2025-01-15', '2025-01-15',
    84000, 8400, 92400,
    '2025-01-20', '2025-01-20 10:00:00+09', '2025-01-31', '発行済'
);

-- オーダー1を請求書1に紐付け
INSERT INTO invoice_orders (invoice_id, order_id) VALUES
    (1, 1);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS invoice_orders CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;

-- +goose StatementEnd
