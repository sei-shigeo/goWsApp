-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 事業所・拠点テーブル
-- ==============================

-- 事業所テーブル（employeesより先に作成）
CREATE TABLE IF NOT EXISTS company_offices (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    office_code VARCHAR(50) UNIQUE,
    office_name VARCHAR(255) NOT NULL, -- 事業所名
    office_type VARCHAR(20) CHECK (office_type IN ('本社', '支店', '事業所', '車庫', '倉庫', 'その他')), -- 事業所種別
    manager_id INTEGER, -- employeesテーブル作成後に外部キー制約を追加
    
    -- 基本情報
    opening_date DATE,
    closing_date DATE,
    
    -- 連絡先情報
    postal_code VARCHAR(10), -- 郵便番号
    address VARCHAR(500), -- 住所
    phone VARCHAR(20), -- 電話番号
    fax VARCHAR(20), -- ファックス
    email VARCHAR(255), -- メールアドレス
    website VARCHAR(255), -- ウェブサイト
    
    -- その他
    image_url VARCHAR(255),
    notes TEXT,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_company_offices_company ON company_offices(company_id);
CREATE INDEX IF NOT EXISTS idx_company_offices_code ON company_offices(office_code);
CREATE INDEX IF NOT EXISTS idx_company_offices_active ON company_offices(is_active);

-- 事業所データを先に挿入（manager_idはNULL）
INSERT INTO company_offices (company_id, office_code, office_name, office_type, address, phone, email, website) VALUES 
    (1, 'O-001', '株式会社和清商事', '本社', '愛知県名古屋市中区栄3-4-5', '052-1234-5678', 'info@wasei.co.jp', 'https://www.wasei.co.jp'),
    (1, 'O-002', '豊田', '支店', '東京都千代田区永田町1-7-1', '03-1234-5678', 'tokyo@wasei.co.jp', 'https://www.wasei.co.jp');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS company_offices CASCADE;

-- +goose StatementEnd

