-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 取引先テーブル
-- ==============================

-- 取引先テーブル
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    credit_limit DECIMAL(12,2), -- 信用限度額
    payment_terms VARCHAR(50), -- 支払条件（例：月末締め翌月末払い）
    payment_method VARCHAR(50), -- 支払方法
    
    -- 締日・支払日
    closing_day INTEGER CHECK (closing_day BETWEEN 1 AND 31), -- 締日（1～31、NULL=月末）
    payment_due_day INTEGER CHECK (payment_due_day BETWEEN 1 AND 31), -- 支払日（1～31、NULL=月末）

    -- インボイス番号
    invoice_number VARCHAR(50),

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_customers_code ON customers(customer_code);
CREATE INDEX IF NOT EXISTS idx_customers_active ON customers(is_active);

INSERT INTO customers (name, customer_code, closing_day, payment_due_day) VALUES 
    ('都築産業', 'C-001', 15, NULL),    -- 15日締め、月末払い
    ('MPS事業部', 'C-002', NULL, 25),  -- 月末締め、25日払い
    ('司企業', 'C-003', 20, 10);       -- 20日締め、翌月10日払い

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS customers CASCADE;

-- +goose StatementEnd

