-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 従業員関連テーブル
-- ==============================

-- 教育訓練履歴テーブル
CREATE TABLE IF NOT EXISTS training_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    training_type VARCHAR(50) NOT NULL CHECK (training_type IN ('initial', 'regular', 'accident', 'special')),
    training_date DATE NOT NULL,
    training_hours DECIMAL(4,1),
    instructor VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_training_records_employee ON training_records(employee_id);
CREATE INDEX idx_training_records_date ON training_records(training_date);

INSERT INTO training_records (employee_id, training_type, training_date, training_hours, instructor, notes) VALUES 
    (1, 'initial', '2025-01-15', 8.0, '山田講師', '初任教育を実施'),
    (2, 'regular', '2025-02-01', 2.0, '佐藤指導員', '定期講習を実施');

-- 健康診断履歴テーブル
CREATE TABLE IF NOT EXISTS health_checkup_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    checkup_date DATE NOT NULL,
    checkup_type VARCHAR(50) CHECK (checkup_type IN ('定期', '雇入れ時', '深夜業従事者')),
    overall_result VARCHAR(20) CHECK (overall_result IN ('異常なし', '要再検査', '要精密検査')),
    medical_institution VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_health_checkup_records_employee ON health_checkup_records(employee_id);
CREATE INDEX idx_health_checkup_records_date ON health_checkup_records(checkup_date);

INSERT INTO health_checkup_records (employee_id, checkup_date, checkup_type, overall_result, medical_institution, notes) VALUES 
    (1, '2025-04-01', '定期', '異常なし', 'さくら健康診断センター', '特記事項なし'),
    (2, '2025-04-01', '定期', '要再検査', '名古屋中央クリニック', '血圧高め、再検査要');

-- 資格取得履歴テーブル
CREATE TABLE IF NOT EXISTS qualification_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    qualification_type VARCHAR(50),
    qualification_date DATE NOT NULL,
    qualification_number VARCHAR(20),
    qualification_image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_qualification_records_employee ON qualification_records(employee_id);

INSERT INTO qualification_records (employee_id, qualification_type, qualification_date, qualification_number) VALUES 
    (1, 'フォークリフト', '2020-03-15', 'FL-2020-123456'),
    (1, '玉掛け', '2020-06-20', 'TK-2020-234567'),
    (2, 'フォークリフト', '2021-04-10', 'FL-2021-345678');

-- 保険履歴テーブル
CREATE TABLE IF NOT EXISTS insurance_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    insurance_type VARCHAR(50) CHECK (insurance_type IN ('健康保険', '厚生年金', '雇用保険', 'マイナンバー')),
    insurance_date DATE NOT NULL,
    insurance_image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_insurance_records_employee ON insurance_records(employee_id);

INSERT INTO insurance_records (employee_id, insurance_type, insurance_date) VALUES 
    (1, '健康保険', '2024-04-01'),
    (1, '厚生年金', '2024-04-01'),
    (1, '雇用保険', '2024-04-01'),
    (2, '健康保険', '2024-05-01'),
    (2, '厚生年金', '2024-05-01'),
    (2, '雇用保険', '2024-05-01');

-- 学歴テーブル
CREATE TABLE IF NOT EXISTS education_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    education_type VARCHAR(50) CHECK (education_type IN ('中学校', '高等学校', '大学', '大学院')),
    education_date DATE NOT NULL,
    education_institution VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_education_records_employee ON education_records(employee_id);

INSERT INTO education_records (employee_id, education_type, education_date, education_institution, notes) VALUES 
    (1, '高等学校', '2015-03-01', '愛知県立名古屋商業高等学校', '卒業'),
    (2, '大学', '2019-03-01', '名古屋大学経済学部', '卒業');

-- 職歴テーブル
CREATE TABLE IF NOT EXISTS career_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    career_type VARCHAR(50) CHECK (career_type IN ('会社', '店舗', 'その他')),
    career_date DATE NOT NULL,
    career_institution VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_career_records_employee ON career_records(employee_id);

INSERT INTO career_records (employee_id, career_type, career_date, career_institution, notes) VALUES 
    (1, '会社', '2015-04-01', '株式会社東海運輸', '運転手として3年勤務'),
    (2, '会社', '2019-04-01', '名古屋物流センター', '事務職として2年勤務');

-- 事故履歴テーブル
CREATE TABLE IF NOT EXISTS accident_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    accident_date DATE NOT NULL,
    accident_type VARCHAR(50) CHECK (accident_type IN ('車両事故', '人身事故', 'その他')),
    accident_location VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_accident_records_employee ON accident_records(employee_id);
CREATE INDEX idx_accident_records_date ON accident_records(accident_date);

-- 違反履歴テーブル
CREATE TABLE IF NOT EXISTS violation_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    violation_date DATE NOT NULL,
    violation_type VARCHAR(50) CHECK (violation_type IN ('違反', 'その他')),
    violation_location VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_violation_records_employee ON violation_records(employee_id);
CREATE INDEX idx_violation_records_date ON violation_records(violation_date);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS violation_records CASCADE;
DROP TABLE IF EXISTS accident_records CASCADE;
DROP TABLE IF EXISTS career_records CASCADE;
DROP TABLE IF EXISTS education_records CASCADE;
DROP TABLE IF EXISTS insurance_records CASCADE;
DROP TABLE IF EXISTS qualification_records CASCADE;
DROP TABLE IF EXISTS health_checkup_records CASCADE;
DROP TABLE IF EXISTS training_records CASCADE;

-- +goose StatementEnd
