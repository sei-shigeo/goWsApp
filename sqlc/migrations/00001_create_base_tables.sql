-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 基本マスターテーブル
-- ==============================

-- 権限マスターテーブル
CREATE TABLE IF NOT EXISTS m_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_roles (name) VALUES ('管理者'), ('一般');

-- ==============================
-- コアエンティティテーブル
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

CREATE INDEX idx_companies_code ON companies(company_code);
CREATE INDEX idx_companies_active ON companies(is_active);

INSERT INTO companies (name, company_code) VALUES ('株式会社和清商事', 'COM-001');

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

CREATE INDEX idx_customers_code ON customers(customer_code);
CREATE INDEX idx_customers_active ON customers(is_active);

INSERT INTO customers (name, customer_code, closing_day, payment_due_day) VALUES 
    ('都築産業', 'C-001', 15, NULL),    -- 15日締め、月末払い
    ('MPS事業部', 'C-002', NULL, 25),  -- 月末締め、25日払い
    ('司企業', 'C-003', 20, 10);       -- 20日締め、翌月10日払い

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

CREATE INDEX idx_company_offices_company ON company_offices(company_id);
CREATE INDEX idx_company_offices_code ON company_offices(office_code);
CREATE INDEX idx_company_offices_active ON company_offices(is_active);

-- 事業所データを先に挿入（manager_idはNULL）
INSERT INTO company_offices (company_id, office_code, office_name, office_type, address, phone, email, website) VALUES 
    (1, 'O-001', '株式会社和清商事', '本社', '愛知県名古屋市中区栄3-4-5', '052-1234-5678', 'info@wasei.co.jp', 'https://www.wasei.co.jp'),
    (1, 'O-002', '豊田', '支店', '東京都千代田区永田町1-7-1', '03-1234-5678', 'tokyo@wasei.co.jp', 'https://www.wasei.co.jp');

-- 従業員テーブル
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    employee_code VARCHAR(50) NOT NULL UNIQUE,
    
    -- 基本情報
    employee_image_url VARCHAR(255),
    employee_photo_date DATE,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name_kana VARCHAR(100),
    first_name_kana VARCHAR(100),
    legal_name VARCHAR(200),
    gender VARCHAR(20) NOT NULL DEFAULT '不明' CHECK (gender IN ('男', '女', 'その他')),
    blood_type VARCHAR(20) NOT NULL DEFAULT '不明' CHECK (blood_type IN ('A', 'B', 'O', 'AB', '不明')),

    -- 連絡先
    address VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(255),
    
    -- 雇用情報
    birth_date DATE, --生年月日
    hire_date DATE,--雇用日
    appointment_date DATE, --選任日
    office_id INTEGER REFERENCES company_offices(id) ON DELETE SET NULL, -- 所属事業所
    job_type VARCHAR(20) CHECK (job_type IN ('運転者', '運行管理者', '整備管理者', '経理', '営業', '事務', 'その他')),
    employment_type VARCHAR(20) CHECK (employment_type IN ('正社員', 'アルバイト', '業務委託', '派遣', 'パート', '嘱託', 'その他')),
    department VARCHAR(50),
    position VARCHAR(50),
    
    -- 退職情報
    retirement_date DATE,
    retirement_reason TEXT,
    death_date DATE,
    death_reason TEXT,
    
    -- 運転免許情報
    driver_license_no VARCHAR(50), --運転免許番号
    driver_license_type VARCHAR(50), --運転免許種別
    driver_license_issue_date DATE, --運転免許発行日
    driver_license_expiry DATE, --運転免許有効期限
    driver_license_image_url_front VARCHAR(255), --運転免許画像（前）
    driver_license_image_url_back VARCHAR(255), --運転免許画像（後）
    driving_disabled_date DATE, --運転停止日
    driving_disabled_reason TEXT, --運転停止理由
    
    -- 在留資格
    nationality VARCHAR(50) NOT NULL DEFAULT '日本',
    visa_type VARCHAR(50) DEFAULT '永住権', -- 在留資格種別
    visa_expiry DATE, -- 在留資格有効期限
    visa_image_url_front VARCHAR(255),
    visa_image_url_back VARCHAR(255),

    -- 銀行
    bank_code VARCHAR(50), -- 銀行コード    
    bank_name VARCHAR(255), -- 銀行名
    bank_branch_code VARCHAR(50), -- 銀行支店コード
    bank_branch_name VARCHAR(255), -- 銀行支店名
    bank_account_type VARCHAR(50), -- 銀行口座種別
    bank_account_number VARCHAR(50), -- 銀行口座番号
    bank_account_name VARCHAR(255), -- 銀行口座名
    bank_account_kana VARCHAR(255), -- 銀行口座名（カナ）
    
    -- 認証情報
    role_id INTEGER REFERENCES m_roles(id) ON DELETE SET NULL, -- 権限（管理者/一般）
    password_hash VARCHAR(255), -- ハッシュ化されたパスワード
    password_updated_at TIMESTAMP WITH TIME ZONE, -- パスワード最終更新日
    failed_login_attempts INTEGER DEFAULT 0, -- ログイン失敗回数
    locked_until TIMESTAMP WITH TIME ZONE, -- アカウントロック期限
    last_login_at TIMESTAMP WITH TIME ZONE, -- 最終ログイン日時
    
    -- ステータス
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX idx_employees_code ON employees(employee_code);
CREATE INDEX idx_employees_office ON employees(office_id);
CREATE INDEX idx_employees_role ON employees(role_id);
CREATE INDEX idx_employees_active ON employees(is_active);

INSERT INTO employees (
    employee_code, 
    last_name, first_name, last_name_kana, first_name_kana, legal_name, 
    phone,email,address,
    gender, birth_date, blood_type,
    hire_date, office_id, role_id, password_hash) VALUES 
    ('E-001', '茂雄', '清', 'シゲオ', 'セイ', 'Rafael Shigueo Sei', '090-1111-2222', 'shigeo.sei@wasei.co.jp', '愛知県名古屋市中区栄3-4-5', '男', CURRENT_DATE, 'A', CURRENT_DATE, 2, 1, '$2a$10$dummy_hash_for_admin'),
    ('E-002', 'アケミ', '伴', 'アケミ', 'バン', 'Akemi Ban', '090-2222-3333', 'akemi.ban@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-003', 'マサヒロ', '藤原', 'マサヒロ', 'フジワラ', 'Masahiro Fujiwara', '090-3333-4444', 'masahiro.fujiwara@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-004', 'ヒロシ', '田中', 'ヒロシ', 'タナカ', 'Hiroshi Tanaka', '090-4444-5555', 'hiroshi.tanaka@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-005', 'タカシ', '渡辺', 'タカシ', 'ワタナベ', 'Takashi Watanabe', '090-5555-6666', 'takashi.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-006', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-6666-7777', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-007', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-7777-8888', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-008', 'ナオト', '鈴木', 'ナオト', 'スズキ', 'Naoto Suzuki', '090-8888-9999', 'naoto.suzuki@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-009', 'ヒロミ', '高橋', 'ヒロミ', 'タカハシ', 'Hiroshi Takahashi', '090-9999-0000', 'hiroshi.takahashi@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-010', 'ナオユキ', '伊藤', 'ナオユキ', 'イトウ', 'Naoyuki Ito', '090-0000-1111', 'naoyuki.ito@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-011', 'マサユキ', '渡辺', 'マサユキ', 'ワタナベ', 'Masayuki Watanabe', '090-1111-2222', 'masayuki.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-012', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-2222-3333', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-013', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-3333-4444', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-014', 'ナオト', '鈴木', 'ナオト', 'スズキ', 'Naoto Suzuki', '090-4444-5555', 'naoto.suzuki@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-015', 'ヒロミ', '高橋', 'ヒロミ', 'タカハシ', 'Hiroshi Takahashi', '090-5555-6666', 'hiroshi.takahashi@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-016', 'ナオユキ', '伊藤', 'ナオユキ', 'イトウ', 'Naoyuki Ito', '090-6666-7777', 'naoyuki.ito@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-017', 'マサユキ', '渡辺', 'マサユキ', 'ワタナベ', 'Masayuki Watanabe', '090-7777-8888', 'masayuki.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-018', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-8888-9999', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user'),
    ('E-019', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-9999-0000', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user');

-- company_officesのmanager_idに外部キー制約を追加
ALTER TABLE company_offices 
ADD CONSTRAINT fk_company_offices_manager 
FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL;

CREATE INDEX idx_company_offices_manager ON company_offices(manager_id);

-- 事業所のmanager_idを更新
UPDATE company_offices SET manager_id = 1 WHERE office_code = 'O-001';
UPDATE company_offices SET manager_id = 2 WHERE office_code = 'O-002';

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS company_offices CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS m_roles CASCADE;

-- +goose StatementEnd
