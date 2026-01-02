-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 従業員テーブル
-- ==============================

-- ==============================
-- マスタテーブル
-- ==============================

-- 職種マスタ
CREATE TABLE IF NOT EXISTS m_job_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_order INTEGER DEFAULT 0, -- 表示順序
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_job_types (name, display_order) VALUES 
    ('運転手', 1),
    ('運行管理者', 2),
    ('運行管理者補助者', 3),
    ('整備管理者', 4),
    ('整備管理者補助者', 5),
    ('経理担当', 6),
    ('営業担当', 7),
    ('一般事務', 8),
    ('総務担当', 9),
    ('その他', 99);

CREATE INDEX IF NOT EXISTS idx_m_job_types_name ON m_job_types(name);

-- 雇用形態マスタ
CREATE TABLE IF NOT EXISTS m_employment_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_employment_types (name, display_order) VALUES 
    ('正社員', 1),
    ('アルバイト', 2),
    ('業務委託', 3),
    ('派遣', 4),
    ('パート', 5),
    ('嘱託', 6),
    ('その他', 99);

CREATE INDEX IF NOT EXISTS idx_m_employment_types_name ON m_employment_types(name);

-- 部署マスタ
CREATE TABLE IF NOT EXISTS m_departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_departments (name, display_order) VALUES 
    ('運送部', 1),
    ('整備部', 2),
    ('経理部', 3),
    ('営業部', 4),
    ('総務部', 5),
    ('その他', 99);

CREATE INDEX IF NOT EXISTS idx_m_departments_name ON m_departments(name);

-- 役職マスタ
CREATE TABLE IF NOT EXISTS m_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    level INTEGER DEFAULT 0, -- 役職レベル（数値が大きいほど上位）
    display_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_positions (name, level, display_order) VALUES 
    ('社長', 100, 1),
    ('部長', 80, 2),
    ('課長', 60, 3),
    ('係長', 40, 4),
    ('主任', 20, 5),
    ('一般職', 10, 6),
    ('その他', 0, 99);

CREATE INDEX IF NOT EXISTS idx_m_positions_name ON m_positions(name);

-- 国籍マスター
CREATE TABLE IF NOT EXISTS m_nationalities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_nationalities (name, display_order) VALUES 
    ('日本', 1),
    ('ブラジル', 2),
    ('ペルー', 3),
    ('その他', 99);

CREATE INDEX IF NOT EXISTS idx_m_nationalities_name ON m_nationalities(name);

-- 従業員テーブル
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_code TEXT NOT NULL UNIQUE,
    
    -- 基本情報
    employee_image_url TEXT,
    employee_photo_date DATE,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name_kana TEXT,
    first_name_kana TEXT,
    legal_name TEXT,
    gender TEXT NOT NULL DEFAULT 'その他' CHECK (gender IN ('男', '女', 'その他')),
    blood_type TEXT NOT NULL DEFAULT '不明' CHECK (blood_type IN ('A', 'B', 'O', 'AB', '不明')),

    -- 連絡先
    address TEXT,
    phone TEXT,
    email TEXT,

    -- 緊急連絡先
    emergency_contact_name TEXT, -- 緊急連絡先名前
    emergency_contact_relationship TEXT, -- 緊急連絡先関係
    emergency_contact_phone TEXT, -- 緊急連絡先電話番号
    emergency_contact_email TEXT, -- 緊急連絡先メールアドレス
    emergency_contact_address TEXT, -- 緊急連絡先住所

    -- 雇用情報
    birth_date DATE, --生年月日
    hire_date DATE,--雇用日
    appointment_date DATE, --選任日
    office_id INTEGER DEFAULT 1 REFERENCES company_offices(id) ON DELETE SET DEFAULT, -- 所属事業所
    employment_type_id INTEGER DEFAULT 1 REFERENCES m_employment_types(id) ON DELETE SET DEFAULT, -- 雇用形態
    job_type_id INTEGER DEFAULT 1 REFERENCES m_job_types(id) ON DELETE SET DEFAULT, -- 職種
    department_id INTEGER DEFAULT 1 REFERENCES m_departments(id) ON DELETE SET DEFAULT, -- 部署
    position_id INTEGER DEFAULT 1 REFERENCES m_positions(id) ON DELETE SET DEFAULT, -- 役職
    
    -- 退職情報
    retirement_date DATE,
    retirement_reason TEXT,
    death_date DATE,
    death_reason TEXT,
    
    -- 運転免許情報
    driver_license_no TEXT, --運転免許番号
    driver_license_type TEXT, --運転免許種別
    driver_license_issue_date DATE, --運転免許発行日
    driver_license_expiry DATE, --運転免許有効期限
    driver_license_image_url_front TEXT, --運転免許画像（前）
    driver_license_image_url_back TEXT, --運転免許画像（後）
    driving_disabled_date DATE, --運転停止日
    driving_disabled_reason TEXT, --運転停止理由
    
    -- 在留資格
    nationality_id INTEGER DEFAULT 1 REFERENCES m_nationalities(id) ON DELETE SET DEFAULT, --　参照先は削除不可
    visa_type TEXT DEFAULT '永住権', -- 在留資格種別
    visa_expiry DATE, -- 在留資格有効期限
    visa_image_url_front TEXT,
    visa_image_url_back TEXT,

    -- 銀行
    bank_code TEXT, -- 銀行コード    
    bank_name TEXT, -- 銀行名
    bank_branch_code TEXT, -- 銀行支店コード
    bank_branch_name TEXT, -- 銀行支店名
    bank_account_type TEXT, -- 銀行口座種別
    bank_account_number TEXT, -- 銀行口座番号
    bank_account_name TEXT, -- 銀行口座名
    bank_account_kana TEXT, -- 銀行口座名（カナ）
    
    -- 認証情報
    role_id INTEGER REFERENCES m_roles(id) ON DELETE SET NULL, -- 権限（管理者/一般）
    password_hash TEXT, -- ハッシュ化されたパスワード
    password_updated_at DATETIME, -- パスワード最終更新日
    failed_login_attempts INTEGER DEFAULT 0, -- ログイン失敗回数
    locked_until DATETIME, -- アカウントロック期限
    last_login_at DATETIME, -- 最終ログイン日時
    
    -- ステータス
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_employees_code ON employees(employee_code);
CREATE INDEX IF NOT EXISTS idx_employees_office ON employees(office_id);
CREATE INDEX IF NOT EXISTS idx_employees_role ON employees(role_id);
CREATE INDEX IF NOT EXISTS idx_employees_active ON employees(is_active);
CREATE INDEX IF NOT EXISTS idx_employees_employment_type ON employees(employment_type_id);
CREATE INDEX IF NOT EXISTS idx_employees_job_type ON employees(job_type_id);
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_employees_position ON employees(position_id);
CREATE INDEX IF NOT EXISTS idx_employees_nationality ON employees(nationality_id);

INSERT INTO employees (
    employee_code, 
    last_name, first_name, last_name_kana, first_name_kana, legal_name, 
    phone, email, address,
    gender, birth_date, blood_type,
    hire_date, office_id, role_id, password_hash,
    employment_type_id, job_type_id, department_id, position_id, nationality_id
) VALUES 
    ('E-001', '茂雄', '清', 'シゲオ', 'セイ', 'Rafael Shigueo Sei', '090-1111-2222', 'shigeo.sei@wasei.co.jp', '愛知県名古屋市中区栄3-4-5', '男', CURRENT_DATE, 'A', CURRENT_DATE, 2, 1, '$2a$10$dummy_hash_for_admin', 1, 1, 1, 6, 2),
    ('E-002', 'アケミ', '伴', 'アケミ', 'バン', 'Akemi Ban', '090-2222-3333', 'akemi.ban@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 2, 1, 2, 1),
    ('E-003', 'マサヒロ', '藤原', 'マサヒロ', 'フジワラ', 'Masahiro Fujiwara', '090-3333-4444', 'masahiro.fujiwara@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 3, 1, 3, 1),
    ('E-004', 'ヒロシ', '田中', 'ヒロシ', 'タナカ', 'Hiroshi Tanaka', '090-4444-5555', 'hiroshi.tanaka@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 4, 2, 2, 1),
    ('E-005', 'タカシ', '渡辺', 'タカシ', 'ワタナベ', 'Takashi Watanabe', '090-5555-6666', 'takashi.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 5, 2, 3, 1),
    ('E-006', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-6666-7777', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 6, 3, 6, 1),
    ('E-007', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-7777-8888', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 7, 4, 6, 1),
    ('E-008', 'ナオト', '鈴木', 'ナオト', 'スズキ', 'Naoto Suzuki', '090-8888-9999', 'naoto.suzuki@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 8, 5, 6, 1),
    ('E-009', 'ヒロミ', '高橋', 'ヒロミ', 'タカハシ', 'Hiroshi Takahashi', '090-9999-0000', 'hiroshi.takahashi@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 1, 1, 5, 1),
    ('E-010', 'ナオユキ', '伊藤', 'ナオユキ', 'イトウ', 'Naoyuki Ito', '090-0000-1111', 'naoyuki.ito@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 8, 5, 6, 1),
    ('E-011', 'マサユキ', '渡辺', 'マサユキ', 'ワタナベ', 'Masayuki Watanabe', '090-1111-2222', 'masayuki.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 1, 1, 6, 1),
    ('E-012', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-2222-3333', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 2, 8, 5, 6, 2),
    ('E-013', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-3333-4444', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 1, 1, 6, 1),
    ('E-014', 'ナオト', '鈴木', 'ナオト', 'スズキ', 'Naoto Suzuki', '090-4444-5555', 'naoto.suzuki@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'O', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 3, 1, 1, 6, 3),
    ('E-015', 'ヒロミ', '高橋', 'ヒロミ', 'タカハシ', 'Hiroshi Takahashi', '090-5555-6666', 'hiroshi.takahashi@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'AB', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 2, 1, 4, 1),
    ('E-016', 'ナオユキ', '伊藤', 'ナオユキ', 'イトウ', 'Naoyuki Ito', '090-6666-7777', 'naoyuki.ito@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, 'A', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 6, 3, 3, 1),
    ('E-017', 'マサユキ', '渡辺', 'マサユキ', 'ワタナベ', 'Masayuki Watanabe', '090-7777-8888', 'masayuki.watanabe@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, 'B', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 4, 2, 5, 1),
    ('E-018', 'ナオミ', '山田', 'ナオミ', 'ヤマダ', 'Naomi Yamada', '090-8888-9999', 'naomi.yamada@wasei.co.jp', '東京都千代田区永田町1-7-1', '女', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 5, 8, 5, 6, 1),
    ('E-019', 'マサユキ', '佐藤', 'マサユキ', 'サトウ', 'Masayuki Sato', '090-9999-0000', 'masayuki.sato@wasei.co.jp', '東京都千代田区永田町1-7-1', '男', CURRENT_DATE, '不明', CURRENT_DATE, 1, 2, '$2a$10$dummy_hash_for_user', 1, 7, 4, 5, 1);

-- company_officesのmanager_idに外部キー制約を追加
-- SQLite3ではALTER TABLEで外部キー制約を追加できないため、インデックスのみ作成
-- 外部キー制約はテーブル作成時に定義する必要がある（既に00004で定義済み）
CREATE INDEX IF NOT EXISTS idx_company_offices_manager ON company_offices(manager_id);

-- 事業所のmanager_idを更新
UPDATE company_offices SET manager_id = 1 WHERE office_code = 'O-001';
UPDATE company_offices SET manager_id = 2 WHERE office_code = 'O-002';

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS m_nationalities;
DROP TABLE IF EXISTS m_positions;
DROP TABLE IF EXISTS m_departments;
DROP TABLE IF EXISTS m_employment_types;
DROP TABLE IF EXISTS m_job_types;

-- +goose StatementEnd

