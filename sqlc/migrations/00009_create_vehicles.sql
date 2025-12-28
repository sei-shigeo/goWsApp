-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 車両管理テーブル
-- ==============================

-- 車両テーブル
CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    vehicle_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- 基本情報
    vehicle_number VARCHAR(50) NOT NULL,           -- 車両番号（社内管理番号）
    registration_number VARCHAR(50) UNIQUE,        -- 登録番号（ナンバープレート）
    vehicle_name VARCHAR(255),                     -- 車両名称
    
    -- 車両詳細
    manufacturer VARCHAR(100),                     -- メーカー（いすゞ、日野、三菱ふそうなど）
    model_name VARCHAR(100),                       -- 車種名
    model_year INTEGER,                            -- 年式
    vehicle_type VARCHAR(50) CHECK (vehicle_type IN ('小型トラック', '中型トラック', '大型トラック','トラクタ', 'トレーラー', 'バン', '乗用車', 'その他')),
    body_type VARCHAR(50),                         -- 車体形状（平ボディ、バン、冷凍車など）
    
    -- 性能・仕様
    max_load_capacity DECIMAL(8,2),                -- 最大積載量（kg）
    vehicle_weight DECIMAL(8,2),                   -- 車両重量（kg）
    gross_vehicle_weight DECIMAL(8,2),             -- 車両総重量（kg）
    fuel_type VARCHAR(30) CHECK (fuel_type IN ('ガソリン', '軽油', 'LPG', 'CNG', 'ハイブリッド', '電気', 'その他')),
    transmission_type VARCHAR(30) CHECK (transmission_type IN ('MT', 'AT', 'AMT', 'その他')),
    
    -- 配属情報
    company_id INTEGER REFERENCES companies(id) ON DELETE SET NULL,
    office_id INTEGER REFERENCES company_offices(id) ON DELETE SET NULL,
    primary_driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    
    -- 所有・契約情報
    ownership_type VARCHAR(30) CHECK (ownership_type IN ('自社所有', 'リース', 'レンタル', 'その他')),
    lease_company VARCHAR(255),                    -- リース会社名
    lease_start_date DATE,                         -- リース開始日
    lease_end_date DATE,                           -- リース終了日
    purchase_date DATE,                            -- 購入日
    purchase_price DECIMAL(12,2),                  -- 購入価格
    
    -- 車検情報
    initial_registration_date DATE,                -- 初度登録日
    vehicle_inspection_expiry DATE,                -- 車検有効期限
    vehicle_inspection_certificate_image_url VARCHAR(255),
    
    -- 自賠責保険
    compulsory_insurance_number VARCHAR(50),       -- 自賠責保険証券番号
    compulsory_insurance_expiry DATE,              -- 自賠責保険有効期限
    compulsory_insurance_image_url VARCHAR(255),
    
    -- 任意保険
    voluntary_insurance_company VARCHAR(255),      -- 任意保険会社
    voluntary_insurance_number VARCHAR(50),        -- 任意保険証券番号
    voluntary_insurance_expiry DATE,               -- 任意保険有効期限
    voluntary_insurance_image_url VARCHAR(255),
    
    -- 状態管理
    vehicle_status VARCHAR(30) CHECK (vehicle_status IN ('稼働中', '整備中', '休車', '売却予定', '廃車', 'その他')) DEFAULT '稼働中',
    odometer INTEGER,                              -- 走行距離（km）
    last_maintenance_date DATE,                    -- 最終整備日
    next_maintenance_date DATE,                    -- 次回整備予定日
    
    -- 画像・資料
    vehicle_image_url VARCHAR(255),                -- 車両画像
    
    -- その他
    notes TEXT,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_vehicles_code ON vehicles(vehicle_code);
CREATE INDEX IF NOT EXISTS idx_vehicles_registration ON vehicles(registration_number);
CREATE INDEX IF NOT EXISTS idx_vehicles_company ON vehicles(company_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_office ON vehicles(office_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_driver ON vehicles(primary_driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(vehicle_status);
CREATE INDEX IF NOT EXISTS idx_vehicles_active ON vehicles(is_active);
CREATE INDEX IF NOT EXISTS idx_vehicles_inspection_expiry ON vehicles(vehicle_inspection_expiry);

INSERT INTO vehicles (vehicle_code, vehicle_number, registration_number, vehicle_name, manufacturer, model_name, model_year, vehicle_type, fuel_type, transmission_type, company_id, office_id, ownership_type, vehicle_status) VALUES 
    ('V-001', '1号車', '名古屋100あ1234', 'いすゞエルフ', 'いすゞ', 'エルフ', 2020, '小型トラック', '軽油', 'MT', 1, 1, '自社所有', '稼働中'),
    ('V-002', '2号車', '名古屋100あ5678', '三菱ふそうキャンター', '三菱ふそう', 'キャンター', 2021, '小型トラック', '軽油', 'MT', 1, 1, '自社所有', '稼働中');

-- 車両整備記録テーブル
CREATE TABLE IF NOT EXISTS vehicle_maintenance_records (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(50) CHECK (maintenance_type IN ('定期点検', '車検', '修理', '部品交換', 'その他')),
    maintenance_shop VARCHAR(255),                 -- 整備工場名
    mechanic_name VARCHAR(100),                    -- 整備士名
    
    -- 整備内容
    description TEXT,
    parts_replaced TEXT,                           -- 交換部品
    
    -- 費用
    labor_cost DECIMAL(10,2),                      -- 工賃
    parts_cost DECIMAL(10,2),                      -- 部品代
    other_cost DECIMAL(10,2),                      -- その他費用
    total_cost DECIMAL(10,2),                      -- 合計費用
    
    -- 走行距離
    odometer_reading INTEGER,                      -- 整備時の走行距離
    
    -- 次回予定
    next_maintenance_date DATE,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_vehicle ON vehicle_maintenance_records(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_date ON vehicle_maintenance_records(maintenance_date);
CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_type ON vehicle_maintenance_records(maintenance_type);

-- 車両給油記録テーブル
CREATE TABLE IF NOT EXISTS vehicle_fuel_records (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    
    fuel_date DATE NOT NULL,
    fuel_station VARCHAR(255),                     -- 給油所名
    
    -- 給油情報
    fuel_type VARCHAR(30),
    fuel_amount DECIMAL(8,2),                      -- 給油量（L）
    fuel_unit_price DECIMAL(8,2),                  -- 単価（円/L）
    fuel_total_price DECIMAL(10,2),                -- 合計金額
    
    -- 走行距離
    odometer_reading INTEGER,                      -- 給油時の走行距離
    distance_traveled INTEGER,                     -- 前回給油からの走行距離
    fuel_efficiency DECIMAL(6,2),                  -- 燃費（km/L）
    
    -- 支払い情報
    payment_method VARCHAR(30) CHECK (payment_method IN ('現金', 'クレジットカード', '給油カード', '法人カード', 'その他')),
    receipt_image_url VARCHAR(255),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vehicle_fuel_vehicle ON vehicle_fuel_records(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_fuel_driver ON vehicle_fuel_records(driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_fuel_date ON vehicle_fuel_records(fuel_date);

-- 車両事故記録テーブル
CREATE TABLE IF NOT EXISTS vehicle_accident_records (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    
    accident_date DATE NOT NULL,
    accident_time TIME,
    accident_location VARCHAR(500),
    
    -- 事故種別
    accident_type VARCHAR(50) CHECK (accident_type IN ('物損事故', '人身事故', '自損事故', 'その他')),
    accident_severity VARCHAR(30) CHECK (accident_severity IN ('軽微', '中程度', '重大', '全損')),
    
    -- 事故詳細
    description TEXT,
    weather_condition VARCHAR(50),                 -- 天候
    road_condition VARCHAR(50),                    -- 路面状況
    
    -- 相手方情報
    other_party_name VARCHAR(255),                 -- 相手方氏名
    other_party_phone VARCHAR(20),                 -- 相手方連絡先
    other_party_insurance VARCHAR(255),            -- 相手方保険会社
    
    -- 警察・保険対応
    police_reported BOOLEAN DEFAULT false,         -- 警察届出有無
    police_report_number VARCHAR(100),             -- 事故受理番号
    insurance_claim_number VARCHAR(100),           -- 保険請求番号
    
    -- 損害・修理
    vehicle_damage_description TEXT,               -- 車両損害内容
    repair_cost DECIMAL(12,2),                     -- 修理費用
    repair_shop VARCHAR(255),                      -- 修理工場
    repair_start_date DATE,
    repair_end_date DATE,
    
    -- 画像・資料
    accident_image_url VARCHAR(255),
    police_report_image_url VARCHAR(255),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vehicle_accident_vehicle ON vehicle_accident_records(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_accident_driver ON vehicle_accident_records(driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_accident_date ON vehicle_accident_records(accident_date);
CREATE INDEX IF NOT EXISTS idx_vehicle_accident_type ON vehicle_accident_records(accident_type);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS vehicle_accident_records CASCADE;
DROP TABLE IF EXISTS vehicle_fuel_records CASCADE;
DROP TABLE IF EXISTS vehicle_maintenance_records CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;

-- +goose StatementEnd
