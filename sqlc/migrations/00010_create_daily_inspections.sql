-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 車両日常点検テーブル
-- ==============================

-- 車両日常点検記録テーブル
CREATE TABLE IF NOT EXISTS vehicle_daily_inspections (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    
    -- 点検基本情報
    inspection_date DATE NOT NULL,
    inspection_time TIME,
    inspection_type VARCHAR(20) CHECK (inspection_type IN ('始業前', '終業後')) DEFAULT '始業前',
    odometer_reading INTEGER,
    
    -- ========================================
    -- エンジンルーム
    -- ========================================
    engine_oil_level VARCHAR(10) CHECK (engine_oil_level IN ('良', '注意', '不良', '未実施')),
    coolant_level VARCHAR(10) CHECK (coolant_level IN ('良', '注意', '不良', '未実施')),
    brake_fluid_level VARCHAR(10) CHECK (brake_fluid_level IN ('良', '注意', '不良', '未実施')),
    washer_fluid_level VARCHAR(10) CHECK (washer_fluid_level IN ('良', '注意', '不良', '未実施')),
    battery_condition VARCHAR(10) CHECK (battery_condition IN ('良', '注意', '不良', '未実施')),
    engine_noise VARCHAR(10) CHECK (engine_noise IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- タイヤ
    -- ========================================
    tire_pressure_fl VARCHAR(10) CHECK (tire_pressure_fl IN ('良', '注意', '不良', '未実施')),  -- 前左
    tire_pressure_fr VARCHAR(10) CHECK (tire_pressure_fr IN ('良', '注意', '不良', '未実施')),  -- 前右
    tire_pressure_rl VARCHAR(10) CHECK (tire_pressure_rl IN ('良', '注意', '不良', '未実施')),  -- 後左
    tire_pressure_rr VARCHAR(10) CHECK (tire_pressure_rr IN ('良', '注意', '不良', '未実施')),  -- 後右
    tire_tread_depth VARCHAR(10) CHECK (tire_tread_depth IN ('良', '注意', '不良', '未実施')),
    tire_damage VARCHAR(10) CHECK (tire_damage IN ('良', '注意', '不良', '未実施')),
    wheel_nuts VARCHAR(10) CHECK (wheel_nuts IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- 灯火類・方向指示器
    -- ========================================
    headlights VARCHAR(10) CHECK (headlights IN ('良', '注意', '不良', '未実施')),
    tail_lights VARCHAR(10) CHECK (tail_lights IN ('良', '注意', '不良', '未実施')),
    brake_lights VARCHAR(10) CHECK (brake_lights IN ('良', '注意', '不良', '未実施')),
    turn_signals VARCHAR(10) CHECK (turn_signals IN ('良', '注意', '不良', '未実施')),
    hazard_lights VARCHAR(10) CHECK (hazard_lights IN ('良', '注意', '不良', '未実施')),
    clearance_lights VARCHAR(10) CHECK (clearance_lights IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- ブレーキ系統
    -- ========================================
    foot_brake_operation VARCHAR(10) CHECK (foot_brake_operation IN ('良', '注意', '不良', '未実施')),
    parking_brake_operation VARCHAR(10) CHECK (parking_brake_operation IN ('良', '注意', '不良', '未実施')),
    brake_effectiveness VARCHAR(10) CHECK (brake_effectiveness IN ('良', '注意', '不良', '未実施')),
    air_brake_pressure VARCHAR(10) CHECK (air_brake_pressure IN ('良', '注意', '不良', '未実施', '該当なし')),
    
    -- ========================================
    -- ステアリング・操作系
    -- ========================================
    steering_operation VARCHAR(10) CHECK (steering_operation IN ('良', '注意', '不良', '未実施')),
    steering_play VARCHAR(10) CHECK (steering_play IN ('良', '注意', '不良', '未実施')),
    clutch_operation VARCHAR(10) CHECK (clutch_operation IN ('良', '注意', '不良', '未実施', '該当なし')),
    accelerator_operation VARCHAR(10) CHECK (accelerator_operation IN ('良', '注意', '不良', '未実施')),
    gear_shift_operation VARCHAR(10) CHECK (gear_shift_operation IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- その他装備・安全装置
    -- ========================================
    windshield_wipers VARCHAR(10) CHECK (windshield_wipers IN ('良', '注意', '不良', '未実施')),
    horn VARCHAR(10) CHECK (horn IN ('良', '注意', '不良', '未実施')),
    mirrors VARCHAR(10) CHECK (mirrors IN ('良', '注意', '不良', '未実施')),
    windows_windshield VARCHAR(10) CHECK (windows_windshield IN ('良', '注意', '不良', '未実施')),
    seat_belt VARCHAR(10) CHECK (seat_belt IN ('良', '注意', '不良', '未実施')),
    speedometer VARCHAR(10) CHECK (speedometer IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- 荷台・架装
    -- ========================================
    cargo_bed_condition VARCHAR(10) CHECK (cargo_bed_condition IN ('良', '注意', '不良', '未実施', '該当なし')),
    loading_platform VARCHAR(10) CHECK (loading_platform IN ('良', '注意', '不良', '未実施', '該当なし')),
    tailgate_operation VARCHAR(10) CHECK (tailgate_operation IN ('良', '注意', '不良', '未実施', '該当なし')),
    
    -- ========================================
    -- 車体・外観
    -- ========================================
    body_damage VARCHAR(10) CHECK (body_damage IN ('良', '注意', '不良', '未実施')),
    fuel_leak VARCHAR(10) CHECK (fuel_leak IN ('良', '注意', '不良', '未実施')),
    oil_leak VARCHAR(10) CHECK (oil_leak IN ('良', '注意', '不良', '未実施')),
    water_leak VARCHAR(10) CHECK (water_leak IN ('良', '注意', '不良', '未実施')),
    
    -- ========================================
    -- 総合判定
    -- ========================================
    overall_status VARCHAR(20) CHECK (overall_status IN ('良好', '要注意', '整備必要', '運行不可')) NOT NULL,
    
    -- ========================================
    -- 異常事項
    -- ========================================
    abnormality_found BOOLEAN DEFAULT false,
    abnormality_description TEXT,
    action_taken TEXT,
    repair_required BOOLEAN DEFAULT false,
    repair_scheduled_date DATE,
    
    -- ========================================
    -- その他
    -- ========================================
    weather_condition VARCHAR(50),
    temperature DECIMAL(4,1),
    notes TEXT,
    
    -- ========================================
    -- 承認・確認
    -- ========================================
    confirmed_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_daily_inspections_vehicle ON vehicle_daily_inspections(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_daily_inspections_driver ON vehicle_daily_inspections(driver_id);
CREATE INDEX IF NOT EXISTS idx_daily_inspections_date ON vehicle_daily_inspections(inspection_date);
CREATE INDEX IF NOT EXISTS idx_daily_inspections_vehicle_date ON vehicle_daily_inspections(vehicle_id, inspection_date);
CREATE INDEX IF NOT EXISTS idx_daily_inspections_status ON vehicle_daily_inspections(overall_status);
CREATE INDEX IF NOT EXISTS idx_daily_inspections_abnormality ON vehicle_daily_inspections(abnormality_found) WHERE abnormality_found = true;

-- サンプルデータ
INSERT INTO vehicle_daily_inspections (
    vehicle_id, driver_id, inspection_date, inspection_time, inspection_type,
    engine_oil_level, coolant_level, brake_fluid_level,
    tire_pressure_fl, tire_pressure_fr, tire_pressure_rl, tire_pressure_rr,
    headlights, brake_lights, turn_signals,
    foot_brake_operation, parking_brake_operation,
    steering_operation, windshield_wipers, horn, mirrors,
    overall_status, abnormality_found
) VALUES 
(1, 1, CURRENT_DATE, '08:00:00', '始業前',
    '良', '良', '良',
    '良', '良', '良', '良',
    '良', '良', '良',
    '良', '良',
    '良', '良', '良', '良',
    '良好', false),
(2, 2, CURRENT_DATE, '07:30:00', '始業前',
    '良', '良', '良',
    '良', '良', '良', '良',
    '良', '良', '良',
    '良', '良',
    '良', '良', '良', '良',
    '良好', false);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS vehicle_daily_inspections CASCADE;

-- +goose StatementEnd
