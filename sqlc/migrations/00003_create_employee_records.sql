-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 従業員関連テーブル
-- ==============================

-- 緊急連絡先
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    contact_name VARCHAR(100),
    contact_relationship VARCHAR(50),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emergency_contacts_employee ON emergency_contacts(employee_id);

INSERT INTO emergency_contacts (employee_id, contact_name, contact_relationship, contact_phone) VALUES 
    (1, '山田太郎', '父', '090-1234-5678'),
    (1, '山田花子', '母', '090-1234-5679'),
    (2, '佐藤一郎', '父', '090-1234-5680');

-- 教育訓練履歴テーブル
CREATE TABLE IF NOT EXISTS training_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    training_type VARCHAR(50) NOT NULL CHECK (training_type IN ('初任教育', '定期講習', '事故教育', '特殊教育')), -- 初任教育、定期講習、事故教育、特殊教育は教育訓練の種類
    training_date DATE NOT NULL, -- 教育訓練日
    training_hours DECIMAL(4,1), -- 教育訓練時間 
    instructor VARCHAR(100), -- 指導員
    notes TEXT, -- 備考
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
); -- 教育訓練履歴テーブル

INSERT INTO training_records (employee_id, training_type, training_date, training_hours, instructor, notes) VALUES 
    (1, '初任教育', '2025-01-15', 8.0, '山田講師', '初任教育を実施'),
    (1, '定期講習', '2026-01-15', 8.0, '山田講師', '安全教育を実施'),
    (1, '事故教育', '2027-01-15', 8.0, '山田講師', '消防教育を実施'),
    (2, '特殊教育', '2025-02-01', 2.0, '佐藤指導員', '特殊教育を実施');

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
    (1, '2026-07-01', '定期', '異常なし', 'さくら健康診断センター', '特記事項なし'),
    (1, '2027-10-01', '定期', '異常なし', 'さくら健康診断センター', '特記事項なし'),
    (2, '2026-04-01', '定期', '要再検査', '名古屋中央クリニック', '血圧高め、再検査要'),
    (2, '2026-07-01', '定期', '要再検査', '名古屋中央クリニック', '血圧高め、再検査要'),
    (2, '2026-10-01', '定期', '要再検査', '名古屋中央クリニック', '血圧高め、再検査要');

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
    insurance_number VARCHAR(20),
    insurance_image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_insurance_records_employee ON insurance_records(employee_id);

INSERT INTO insurance_records (employee_id, insurance_type, insurance_date, insurance_number) VALUES 
    (1, '健康保険', '2024-04-01', '12345678901'),
    (1, '厚生年金', '2024-04-01', '12345678902'),
    (1, '雇用保険', '2024-04-01', '12345678903'),
    (1, 'マイナンバー', '2024-04-01', '12345678904'),
    (2, '健康保険', '2024-05-01', '12345678905'),
    (2, '厚生年金', '2024-05-01', '12345678906'),
    (2, '雇用保険', '2024-05-01', '12345678907'),
    (2, 'マイナンバー', '2024-05-01', '12345678908');

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
    (1, '中学校', '2012-04-01', '愛知県立名古屋商業中学校', '卒業'),
    (1, '高等学校', '2015-04-01', '愛知県立名古屋商業高等学校', '卒業'),
    (1, '大学', '2018-04-01', '愛知県立名古屋商業大学', '卒業'),
    (2, '中学校', '2013-04-01', '愛知県立名古屋商業中学校', '卒業'),
    (2, '高等学校', '2016-04-01', '愛知県立名古屋商業高等学校', '卒業'),
    (2, '大学', '2019-04-01', '名古屋大学経済学部', '卒業');

-- 職歴テーブル
CREATE TABLE IF NOT EXISTS career_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    company_name VARCHAR(50), -- 会社名
    start_date DATE NOT NULL, -- 勤務開始日
    end_date DATE, -- 勤務終了日
    job_type VARCHAR(50), -- 職種
    retirement_reason TEXT, -- 辞めた理由
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_career_records_employee ON career_records(employee_id);

INSERT INTO career_records (employee_id, company_name, start_date, end_date, job_type, retirement_reason) VALUES 
    (1, '株式会社エース物流', '2015-04-01', '2018-04-01', '運転手', '会社が倒産したため'),
    (1, '株式会社太陽商会', '2018-04-01', '2021-04-01', '運転手', '会社が倒産したため'),
    (1, '株式会社サンシャイン物流', '2021-04-01', '2024-04-01', '運転手', '会社が倒産したため'),
    (2, '名古屋物流センター', '2019-04-01', '2021-04-01', '運転手', '会社が倒産したため');

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

DROP TABLE IF EXISTS emergency_contacts CASCADE;
DROP TABLE IF EXISTS violation_records CASCADE;
DROP TABLE IF EXISTS accident_records CASCADE;
DROP TABLE IF EXISTS career_records CASCADE;
DROP TABLE IF EXISTS education_records CASCADE;
DROP TABLE IF EXISTS insurance_records CASCADE;
DROP TABLE IF EXISTS qualification_records CASCADE;
DROP TABLE IF EXISTS health_checkup_records CASCADE;
DROP TABLE IF EXISTS training_records CASCADE;

-- +goose StatementEnd
