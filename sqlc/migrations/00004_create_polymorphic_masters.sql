-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 共通マスターテーブル（ポリモーフィック）
-- ==============================

-- 銀行口座テーブル
CREATE TABLE IF NOT EXISTS m_banks (
    id SERIAL PRIMARY KEY,
    owner_type VARCHAR(30) NOT NULL CHECK (owner_type IN ('company', 'customer', 'employee', 'company_office')),
    owner_id INTEGER NOT NULL,
    bank_code VARCHAR(10) NOT NULL,
    bank_name VARCHAR(255) NOT NULL,
    branch_code VARCHAR(11),
    branch_name VARCHAR(255),
    account_type SMALLINT NOT NULL DEFAULT 1,
    account_number VARCHAR(255) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_kana VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_bank_per_owner UNIQUE (owner_type, owner_id, bank_code)
);

CREATE INDEX idx_banks_owner ON m_banks(owner_type, owner_id);
CREATE INDEX idx_banks_active ON m_banks(is_active);

INSERT INTO m_banks (owner_type, owner_id, bank_code, bank_name, branch_code, branch_name, account_type, account_number, account_name, account_kana) VALUES 
    ('company', 1, '0005', '三菱UFJ銀行', '001', '本店', 1, '1234567', '株式会社和清商事', 'カ)ワセイショウジ'),
    ('customer', 1, '0001', 'みずほ銀行', '002', '東京支店', 1, '7654321', '都築産業', 'ツヅキサンギョウ'),
    ('employee', 1, '0005', '三菱UFJ銀行', '001', '本店', 1, '1111111', '茂雄清', 'シゲオセイ');

-- 住所テーブル
CREATE TABLE IF NOT EXISTS m_addresses (
    id SERIAL PRIMARY KEY,
    owner_type VARCHAR(30) NOT NULL CHECK (owner_type IN ('company', 'customer', 'employee', 'company_office')),
    owner_id INTEGER NOT NULL,
    postal_code VARCHAR(10),
    prefecture VARCHAR(50),
    city VARCHAR(100),
    street_address VARCHAR(255),
    building_name VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_owner ON m_addresses(owner_type, owner_id);
CREATE UNIQUE INDEX idx_addresses_primary ON m_addresses(owner_type, owner_id) WHERE is_primary = true;

INSERT INTO m_addresses (owner_type, owner_id, postal_code, prefecture, city, street_address, building_name, is_primary) VALUES 
    ('company', 1, '460-0008', '愛知県', '名古屋市中区', '栄3-4-5', 'サンシャインビル10F', true),
    ('customer', 1, '100-0001', '東京都', '千代田区', '永田町1-7-1', '永田町ビル', true),
    ('employee', 1, '460-0002', '愛知県', '名古屋市中区', '丸の内1-1-1', 'マンション名古屋101', true);

-- メールアドレステーブル
CREATE TABLE IF NOT EXISTS m_emails (
    id SERIAL PRIMARY KEY,
    owner_type VARCHAR(30) NOT NULL CHECK (owner_type IN ('company', 'customer', 'employee', 'company_office')),
    owner_id INTEGER NOT NULL,
    email VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emails_owner ON m_emails(owner_type, owner_id);
CREATE UNIQUE INDEX idx_emails_primary ON m_emails(owner_type, owner_id) WHERE is_primary = true;

INSERT INTO m_emails (owner_type, owner_id, email, is_primary) VALUES 
    ('company', 1, 'info@wasei.co.jp', true),
    ('customer', 1, 'contact@tsuzuki.co.jp', true),
    ('employee', 1, 'sei.shigueo@wasei.co.jp', true);

-- 電話番号テーブル
CREATE TABLE IF NOT EXISTS m_phones (
    id SERIAL PRIMARY KEY,
    owner_type VARCHAR(30) NOT NULL CHECK (owner_type IN ('company', 'customer', 'employee', 'company_office')),
    owner_id INTEGER NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    phone_type VARCHAR(20) NOT NULL CHECK (phone_type IN ('固定電話', '携帯電話', '内線')),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_phones_owner ON m_phones(owner_type, owner_id);
CREATE UNIQUE INDEX idx_phones_primary ON m_phones(owner_type, owner_id) WHERE is_primary = true;

INSERT INTO m_phones (owner_type, owner_id, phone_number, phone_type, is_primary) VALUES 
    ('company', 1, '052-123-4567', '固定電話', true),
    ('customer', 1, '03-1234-5678', '固定電話', true),
    ('employee', 1, '090-1111-2222', '携帯電話', true);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS m_phones CASCADE;
DROP TABLE IF EXISTS m_emails CASCADE;
DROP TABLE IF EXISTS m_addresses CASCADE;
DROP TABLE IF EXISTS m_banks CASCADE;

-- +goose StatementEnd
