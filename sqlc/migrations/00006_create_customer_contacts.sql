-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 取引先担当者テーブル
-- ==============================

-- 取引先担当者テーブル
CREATE TABLE IF NOT EXISTS customer_contacts (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    contact_code VARCHAR(50) UNIQUE,
    
    -- 基本情報
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name_kana VARCHAR(100),
    first_name_kana VARCHAR(100),
    
    -- 所属情報
    department VARCHAR(100),
    position VARCHAR(100),
    office_location VARCHAR(100),
    
    -- 連絡先
    email VARCHAR(255),
    phone_direct VARCHAR(20),
    phone_mobile VARCHAR(20),
    phone_extension VARCHAR(10),
    
    -- フラグ
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- メモ
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_customer_contacts_customer ON customer_contacts(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_contacts_code ON customer_contacts(contact_code);
CREATE INDEX IF NOT EXISTS idx_customer_contacts_primary ON customer_contacts(is_primary) WHERE is_primary = true;
CREATE INDEX IF NOT EXISTS idx_customer_contacts_active ON customer_contacts(is_active);

INSERT INTO customer_contacts (
    customer_id, contact_code, 
    last_name, first_name, last_name_kana, first_name_kana, 
    department, position, 
    office_location, email, phone_direct, phone_mobile, is_primary) VALUES 
    (1, 'CC-001', '山田', '太郎', 'ヤマダ', 'タロウ', '購買部', '部長', '本社', 'yamada@tsuzuki.co.jp', '03-1234-5678', '090-1234-5678', true),
    (1, 'CC-002', '佐藤', '花子', 'サトウ', 'ハナコ', '購買部', '課長', '本社', 'sato@tsuzuki.co.jp', '03-1234-5679', '090-1234-5679', false),
    (2, 'CC-003', '鈴木', '一郎', 'スズキ', 'イチロウ', '物流部', '部長', '本社', 'suzuki@mps.co.jp', '03-2234-5678', '090-2234-5678', true);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS customer_contacts CASCADE;

-- +goose StatementEnd
