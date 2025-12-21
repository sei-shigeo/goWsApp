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
    bank_code VARCHAR(10),
    bank_name VARCHAR(255),
    branch_code VARCHAR(11),
    branch_name VARCHAR(255),
    account_type SMALLINT DEFAULT 1,
    account_number VARCHAR(255),
    account_name VARCHAR(255),
    account_kana VARCHAR(255),
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_bank_per_owner UNIQUE (owner_type, owner_id, bank_code)
);

CREATE INDEX idx_banks_owner ON m_banks(owner_type, owner_id);
CREATE INDEX idx_banks_active ON m_banks(is_active);

INSERT INTO m_banks (
    owner_type, owner_id, 
    bank_code, bank_name, 
    branch_code, branch_name, 
    account_type, account_number, account_name, account_kana,
    is_active
    ) VALUES 
    ('company', 1, '0005', '三菱UFJ銀行', '001', '本店', 1, '1234567', '株式会社和清商事', 'カ)ワセイショウジ', true),
    ('customer', 1, '0001', 'みずほ銀行', '002', '東京支店', 1, '7654321', '都築産業', 'ツヅキサンギョウ', true),
    -- 従業員の銀行口座
    ('employee', 1, '0005', '三菱UFJ銀行', '001', '本店', 1, '1111111', '茂雄清', 'シゲオセイ', true),
    ('employee', 2, '0001', 'みずほ銀行', '002', '東京支店', 1, '2222222', 'アケミ伴', 'アケミバン', true),
    ('employee', 3, '0005', '三菱UFJ銀行', '001', '本店', 1, '3333333', 'マサヒロ藤原', 'マサヒロフジワラ', true),
    ('employee', 4, '0001', 'みずほ銀行', '002', '東京支店', 1, '4444444', 'ヒロシ田中', 'ヒロシタナカ', true),
    ('employee', 5, '0005', '三菱UFJ銀行', '001', '本店', 1, '5555555', 'タカシ渡辺', 'タカシワタナベ', true),
    ('employee', 6, '0001', 'みずほ銀行', '002', '東京支店', 1, '6666666', 'ナオミ山田', 'ナオミヤマダ', true),
    ('employee', 7, '0005', '三菱UFJ銀行', '001', '本店', 1, '7777777', 'マサユキ佐藤', 'マサユキサトウ', true),
    ('employee', 8, '0001', 'みずほ銀行', '002', '東京支店', 1, '8888888', 'ナオト鈴木', 'ナオトスズキ', true),
    ('employee', 9, '0005', '三菱UFJ銀行', '001', '本店', 1, '9999999', 'ヒロミ高橋', 'ヒロミタカハシ', true),
    ('employee', 10, '0001', 'みずほ銀行', '002', '東京支店', 1, '0000000', 'ナオユキ伊藤', 'ナオユキイトウ', true),
    ('employee', 11, '0005', '三菱UFJ銀行', '001', '本店', 1, '1111111', 'マサユキ渡辺', 'マサユキワタナベ', true),
    ('employee', 12, '0001', 'みずほ銀行', '002', '東京支店', 1, '2222222', 'ナオミ山田', 'ナオミヤマダ', true),
    ('employee', 13, '0005', '三菱UFJ銀行', '001', '本店', 1, '3333333', 'マサユキ佐藤', 'マサユキサトウ', true),
    ('employee', 14, '0001', 'みずほ銀行', '002', '東京支店', 1, '4444444', 'ナオト鈴木', 'ナオトスズキ', true),
    ('employee', 15, '0005', '三菱UFJ銀行', '001', '本店', 1, '5555555', 'ヒロミ高橋', 'ヒロミタカハシ', true),
    ('employee', 16, '0001', 'みずほ銀行', '002', '東京支店', 1, '6666666', 'ナオユキ伊藤', 'ナオユキイトウ', true),
    ('employee', 17, '0005', '三菱UFJ銀行', '001', '本店', 1, '7777777', 'マサユキ渡辺', 'マサユキワタナベ', true),
    ('employee', 18, '0001', 'みずほ銀行', '002', '東京支店', 1, '8888888', 'ナオミ山田', 'ナオミヤマダ', true);
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
    -- 会社のメールアドレス
    ('company', 1, 'info@wasei.co.jp', true),
    -- 顧客のメールアドレス
    ('customer', 1, 'contact@tsuzuki.co.jp', true),
    -- 従業員のメールアドレス
    ('employee', 1, 'sei.shigueo@wasei.co.jp', true),
    ('employee', 2, 'akemi.ban@wasei.co.jp', true),
    ('employee', 3, 'masahiro.fujiwara@wasei.co.jp', true),
    ('employee', 4, 'hiroshi.tanaka@wasei.co.jp', true),
    ('employee', 5, 'takashi.watanabe@wasei.co.jp', true),
    ('employee', 6, 'naomi.yamada@wasei.co.jp', true),
    ('employee', 7, 'masayuki.sato@wasei.co.jp', true),
    ('employee', 8, 'naoto.suzuki@wasei.co.jp', true),
    ('employee', 9, 'hiroshi.takahashi@wasei.co.jp', true),
    ('employee', 10, 'naoyuki.ito@wasei.co.jp', true),
    ('employee', 11, 'masayuki.watanabe@wasei.co.jp', true),
    ('employee', 12, 'naomi.yamada@wasei.co.jp', true),
    ('employee', 13, 'masayuki.sato@wasei.co.jp', true),
    ('employee', 14, 'naoto.suzuki@wasei.co.jp', true),
    ('employee', 15, 'hiroshi.takahashi@wasei.co.jp', true),
    ('employee', 16, 'naoyuki.ito@wasei.co.jp', true),
    ('employee', 17, 'masayuki.watanabe@wasei.co.jp', true),
    ('employee', 18, 'naomi.yamada@wasei.co.jp', true),
    ('employee', 19, 'masayuki.sato@wasei.co.jp', true),
    ('employee', 20, 'naoto.suzuki@wasei.co.jp', true),
    ('employee', 21, 'hiroshi.takahashi@wasei.co.jp', true),
    ('employee', 22, 'naoyuki.ito@wasei.co.jp', true);

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
    -- 会社の電話番号
    ('company', 1, '052-123-4567', '固定電話', true),
    -- 顧客の電話番号
    ('customer', 1, '03-1234-5678', '固定電話', true),
    -- 従業員の電話番号
    ('employee', 1, '090-1111-2222', '携帯電話', true),
    ('employee', 2, '090-2222-3333', '携帯電話', true),
    ('employee', 3, '090-3333-4444', '携帯電話', true),
    ('employee', 4, '090-4444-5555', '携帯電話', true),
    ('employee', 5, '090-5555-6666', '携帯電話', true),
    ('employee', 6, '090-6666-7777', '携帯電話', true),
    ('employee', 7, '090-7777-8888', '携帯電話', true),
    ('employee', 8, '090-8888-9999', '携帯電話', true),
    ('employee', 9, '090-9999-0000', '携帯電話', true),
    ('employee', 10, '090-0000-1111', '携帯電話', true),
    ('employee', 11, '090-1111-2222', '携帯電話', true),
    ('employee', 12, '090-2222-3333', '携帯電話', true),
    ('employee', 13, '090-3333-4444', '携帯電話', true),
    ('employee', 14, '090-4444-5555', '携帯電話', true),
    ('employee', 15, '090-5555-6666', '携帯電話', true),
    ('employee', 16, '090-6666-7777', '携帯電話', true),
    ('employee', 17, '090-7777-8888', '携帯電話', true),
    ('employee', 18, '090-8888-9999', '携帯電話', true),
    ('employee', 19, '090-9999-0000', '携帯電話', true),
    ('employee', 20, '090-0000-1111', '携帯電話', true),
    ('employee', 21, '090-1111-2222', '携帯電話', true),
    ('employee', 22, '090-2222-3333', '携帯電話', true);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS m_phones CASCADE;
DROP TABLE IF EXISTS m_emails CASCADE;
DROP TABLE IF EXISTS m_addresses CASCADE;
DROP TABLE IF EXISTS m_banks CASCADE;

-- +goose StatementEnd
