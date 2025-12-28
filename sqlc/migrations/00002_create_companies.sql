-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 自社テーブル
-- ==============================

-- 自社テーブル
CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    company_code VARCHAR(50) UNIQUE,
    
    -- 運送業許可証情報
    transport_license_number VARCHAR(50),
    transport_license_type VARCHAR(50),
    transport_license_issue_date DATE,
    transport_license_expiry_date DATE,
    transport_license_image_url VARCHAR(255),
    
    -- 法人情報
    tax_id VARCHAR(50),
    established_date DATE,
    capital_stock BIGINT,
    representative_name VARCHAR(255),
    representative_name_kana VARCHAR(255),
    representative_name_en VARCHAR(255),

    -- インボイス番号
    invoice_number VARCHAR(50),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_companies_code ON companies(company_code);
CREATE INDEX IF NOT EXISTS idx_companies_active ON companies(is_active);

INSERT INTO companies (name, company_code) VALUES ('株式会社和清商事', 'COM-001');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS companies CASCADE;

-- +goose StatementEnd

