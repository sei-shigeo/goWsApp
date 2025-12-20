-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 配送オーダー・請求管理テーブル
-- ==============================

-- 配送オーダーテーブル（ヘッダー）
CREATE TABLE IF NOT EXISTS delivery_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- 取引先情報
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    
    -- サービス種別（必須）
    service_type VARCHAR(20) CHECK (service_type IN ('スポット便', '定期便', '常用', 'チャーター', 'その他')) NOT NULL,
    
    -- 品名マスター参照（定期便・常用便の場合のみ使用）
    service_type_id INTEGER REFERENCES service_items(id) ON DELETE SET NULL,
    
    -- 運行情報
    order_date DATE NOT NULL DEFAULT CURRENT_DATE, -- 受注日
    operation_date DATE NOT NULL, -- 運行日
    delivery_date DATE, -- 配送日
    
    -- 配車情報（現在の配車：画面表示用）
    driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 現在の運転者
    driver_companion_id INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 現在の同乗者
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE SET NULL, -- 現在の車両
    departure_time TIME, -- 出発予定時間
    arrival_time TIME, -- 到着予定時間
    
    -- 経理に教える情報（配車担当が入力）
    has_highway_fee BOOLEAN DEFAULT false, -- 高速料金が出るかどうか
    has_extra_charge BOOLEAN DEFAULT false, -- 追加料金が出るかどうか
    is_tax_exempt BOOLEAN DEFAULT false, -- 非課税かどうか
    
    -- ステータス管理
    order_status VARCHAR(20) CHECK (order_status IN ('受注', '配車済', '配送中', '完了', 'キャンセル')) DEFAULT '受注',
    
    -- 経理処理状況（経理担当が入力）
    billing_confirmed BOOLEAN DEFAULT false, -- 経理確定かどうか
    billing_confirmed_by INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 経理担当
    billing_confirmed_at TIMESTAMP WITH TIME ZONE, -- 経理確定日
    
    -- 売上管理（経理が設定）
    revenue_date DATE, -- 売上計上日
    revenue_month VARCHAR(7), -- 売上月（YYYY-MM）検索用
    revenue_locked BOOLEAN DEFAULT false, -- 売上確定済み（締め後は修正不可）
    
    -- 金額サマリー（経理確定時に保存）
    subtotal_amount DECIMAL(12,2),
    tax_amount DECIMAL(12,2),
    total_amount DECIMAL(12,2),
    
    -- 請求書発行状況
    invoice_issued BOOLEAN DEFAULT false,
    invoice_number VARCHAR(50),
    invoice_date DATE,
    
    -- その他
    notes TEXT,
    
    -- 作成者・担当者
    created_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    assigned_to INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX idx_delivery_orders_number ON delivery_orders(order_number);
CREATE INDEX idx_delivery_orders_customer ON delivery_orders(customer_id);
CREATE INDEX idx_delivery_orders_service_type ON delivery_orders(service_type);
CREATE INDEX idx_delivery_orders_operation_date ON delivery_orders(operation_date);
CREATE INDEX idx_delivery_orders_driver ON delivery_orders(driver_id);
CREATE INDEX idx_delivery_orders_vehicle ON delivery_orders(vehicle_id);
CREATE INDEX idx_delivery_orders_status ON delivery_orders(order_status);
CREATE INDEX idx_delivery_orders_billing_confirmed ON delivery_orders(billing_confirmed);
CREATE INDEX idx_delivery_orders_revenue_date ON delivery_orders(revenue_date);
CREATE INDEX idx_delivery_orders_revenue_month ON delivery_orders(revenue_month);
CREATE INDEX idx_delivery_orders_revenue_locked ON delivery_orders(revenue_locked);
CREATE INDEX idx_delivery_orders_invoice_issued ON delivery_orders(invoice_issued);

-- 配送明細テーブル（ルート・請求明細）
CREATE TABLE IF NOT EXISTS delivery_details (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL, -- 行番号
    
    -- ルート情報
    route_from VARCHAR(255), -- 出発地
    route_to VARCHAR(255), -- 目的地
    
    -- 配車情報（便ごと）
    driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 運転者（この便の担当）
    driver_companion_id INTEGER REFERENCES employees(id) ON DELETE SET NULL, -- 同乗者
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE SET NULL, -- 車両（トラクタの場合はメイン車両）
    trailer_id INTEGER REFERENCES vehicles(id) ON DELETE SET NULL, -- トレーラー（トラクタ使用時）
    departure_time TIME, -- 出発時間
    arrival_time TIME, -- 到着時間
    
    -- 品名・数量（配車担当が入力）
    service_item_id INTEGER REFERENCES service_items(id) ON DELETE SET NULL,
    item_name VARCHAR(255), -- 品名（定期便・常用便はservice_itemsから、スポット便は手入力）
    quantity DECIMAL(10,2) DEFAULT 1, -- 数量
    unit VARCHAR(20) CHECK (unit IN ('個', '便', '車', '時間', 't')),
    
    -- 単価・金額（経理担当が入力）
    unit_price DECIMAL(10,2), -- 単価
    amount DECIMAL(12,2), -- 金額（数量×単価）
    
    -- 課税区分
    tax_category VARCHAR(20) CHECK (tax_category IN ('課税', '非課税', '免税')) DEFAULT '課税',
    
    -- 詳細・備考
    detail_notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_details_order ON delivery_details(order_id);
CREATE INDEX idx_delivery_details_driver ON delivery_details(driver_id);
CREATE INDEX idx_delivery_details_vehicle ON delivery_details(vehicle_id);
CREATE INDEX idx_delivery_details_trailer ON delivery_details(trailer_id);
CREATE INDEX idx_delivery_details_service_item ON delivery_details(service_item_id);
CREATE UNIQUE INDEX idx_delivery_details_line ON delivery_details(order_id, line_number);

-- 追加料金テーブル（経理担当が入力）
CREATE TABLE IF NOT EXISTS delivery_charges (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
    detail_id INTEGER REFERENCES delivery_details(id) ON DELETE CASCADE,
    
    -- 料金種別
    charge_type VARCHAR(50) CHECK (charge_type IN ('高速料金', '駐車料金', '時間外割増', '深夜割増', '休日割増', '待機料', '燃料チャージ', 'その他')),
    charge_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    
    -- 課税区分
    tax_category VARCHAR(20) CHECK (tax_category IN ('課税', '非課税', '免税')) DEFAULT '課税',
    
    -- 詳細
    notes TEXT,
    receipt_image_url VARCHAR(255),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_charges_order ON delivery_charges(order_id);
CREATE INDEX idx_delivery_charges_detail ON delivery_charges(detail_id);
CREATE INDEX idx_delivery_charges_type ON delivery_charges(charge_type);

-- 配車履歴テーブル（車両故障・運転手変更などの履歴管理）
CREATE TABLE IF NOT EXISTS delivery_assignments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
    detail_id INTEGER REFERENCES delivery_details(id) ON DELETE CASCADE, -- どの便（明細）の配車か
    
    -- 配車情報
    driver_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    driver_companion_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE SET NULL,
    
    -- この配車の有効期間
    assigned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 配車された日時
    started_at TIMESTAMP WITH TIME ZONE, -- 実際に出発した日時
    completed_at TIMESTAMP WITH TIME ZONE, -- 完了した日時
    cancelled_at TIMESTAMP WITH TIME ZONE, -- キャンセルされた日時
    
    -- ステータス管理
    assignment_status VARCHAR(20) CHECK (assignment_status IN ('配車済', '運行中', '完了', 'キャンセル')) DEFAULT '配車済',
    
    -- 変更理由
    cancellation_reason VARCHAR(50) CHECK (cancellation_reason IN ('車両故障', '車両整備', '運転手体調不良', '運転手欠勤', '顧客都合', 'その他')),
    notes TEXT,
    
    -- 作成者
    assigned_by INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_assignments_order ON delivery_assignments(order_id);
CREATE INDEX idx_delivery_assignments_detail ON delivery_assignments(detail_id);
CREATE INDEX idx_delivery_assignments_driver ON delivery_assignments(driver_id);
CREATE INDEX idx_delivery_assignments_vehicle ON delivery_assignments(vehicle_id);
CREATE INDEX idx_delivery_assignments_status ON delivery_assignments(assignment_status);
CREATE INDEX idx_delivery_assignments_assigned_at ON delivery_assignments(assigned_at);

-- サンプルデータ

-- オーダー1: 定期便（ミルクラン便）
INSERT INTO delivery_orders (
    order_number, customer_id, service_type, service_type_id, 
    operation_date, delivery_date,
    driver_id, vehicle_id, -- 代表運転手・車両（画面表示用）
    order_status, has_highway_fee,
    billing_confirmed, revenue_date, revenue_month, 
    subtotal_amount, tax_amount, total_amount,
    created_by
) VALUES (
    'ORD-20250120-001', 1, '定期便', 1, 
    '2025-01-20', '2025-01-20',
    1, 1, -- 茂雄清さん・車両1号車
    '完了', true,
    true, '2025-01-25', '2025-01', 
    84000, 8400, 92400, -- 3便×28000円
    1
);

-- 1便: 茂雄清さん
INSERT INTO delivery_details (
    order_id, line_number, route_from, route_to,
    driver_id, vehicle_id, departure_time, arrival_time,
    service_item_id, item_name, quantity, unit, unit_price, amount,
    tax_category
) VALUES (
    1, 1, '名古屋', '安城',
    1, 1, '08:00', '10:00',
    1, 'ミルクラン便', 1, '便', 28000, 28000,
    '課税'
);

-- 2便: 茂雄清さん
INSERT INTO delivery_details (
    order_id, line_number, route_from, route_to,
    driver_id, vehicle_id, departure_time, arrival_time,
    service_item_id, item_name, quantity, unit, unit_price, amount,
    tax_category
) VALUES (
    1, 2, '安城', '岡崎',
    1, 1, '10:30', '12:00',
    1, 'ミルクラン便', 1, '便', 28000, 28000,
    '課税'
);

-- 3便: アケミ伴さん（運転手交代の例）
INSERT INTO delivery_details (
    order_id, line_number, route_from, route_to,
    driver_id, vehicle_id, departure_time, arrival_time,
    service_item_id, item_name, quantity, unit, unit_price, amount,
    tax_category
) VALUES (
    1, 3, '岡崎', '名古屋',
    2, 1, '13:00', '15:00',
    1, 'ミルクラン便', 1, '便', 28000, 28000,
    '課税'
);

-- 追加料金: 高速料金（非課税）
INSERT INTO delivery_charges (
    order_id, detail_id, charge_type, charge_name, amount,
    tax_category
) VALUES (
    1, 1, '高速料金', '伊勢湾岸道', 1200,
    '非課税'
);

-- オーダー2: スポット便（パレット配送）
INSERT INTO delivery_orders (
    order_number, customer_id, service_type, 
    operation_date, delivery_date,
    driver_id, driver_companion_id, vehicle_id, departure_time, arrival_time,
    order_status, has_highway_fee, has_extra_charge,
    created_by
) VALUES (
    'ORD-20250120-002', 2, 'スポット便', 
    '2025-01-20', '2025-01-20',
    2, 1, 2, '09:00', '17:00',
    '配車済', false, false,
    1
);

-- 明細1: パレット（スポット便は手入力、経理未確定）
INSERT INTO delivery_details (
    order_id, line_number, route_from, route_to,
    driver_id, vehicle_id, departure_time, arrival_time,
    item_name, quantity, unit,
    tax_category, detail_notes
) VALUES (
    2, 1, '豊田', '岡崎',
    2, 2, '09:00', '17:00',
    'パレット', 10, '個',
    '課税', '経理担当が後ほど単価を入力'
);

-- 配車履歴サンプル

-- オーダー1の1便の配車履歴（問題なく完了）
INSERT INTO delivery_assignments (
    order_id, detail_id, driver_id, vehicle_id,
    assigned_at, started_at, completed_at,
    assignment_status, assigned_by
) VALUES (
    1, 1, 1, 1,
    '2025-01-20 07:00:00+09', '2025-01-20 08:00:00+09', '2025-01-20 10:00:00+09',
    '完了', 1
);

-- オーダー1の3便の配車履歴（運転手交代）
INSERT INTO delivery_assignments (
    order_id, detail_id, driver_id, vehicle_id,
    assigned_at, started_at, completed_at,
    assignment_status, notes, assigned_by
) VALUES (
    1, 3, 2, 1,
    '2025-01-20 12:30:00+09', '2025-01-20 13:00:00+09', '2025-01-20 15:00:00+09',
    '完了', '午後便は伴さんが担当', 1
);

-- オーダー2の配車履歴（車両故障で変更の例）
-- 最初の配車（2号車）→ 車両故障でキャンセル
INSERT INTO delivery_assignments (
    order_id, detail_id, driver_id, vehicle_id,
    assigned_at, started_at, cancelled_at,
    assignment_status, cancellation_reason, notes, assigned_by
) VALUES (
    2, 1, 2, 2,
    '2025-01-20 08:00:00+09', '2025-01-20 09:00:00+09', '2025-01-20 10:30:00+09',
    'キャンセル', '車両故障', '2号車のエンジントラブルのため3号車に変更', 1
);

-- 2回目の配車（同じ2号車で継続）→ 運行中
INSERT INTO delivery_assignments (
    order_id, detail_id, driver_id, vehicle_id,
    assigned_at, started_at,
    assignment_status, notes, assigned_by
) VALUES (
    2, 1, 2, 2,
    '2025-01-20 11:00:00+09', '2025-01-20 11:30:00+09',
    '運行中', '修理後、同じ2号車で運行継続', 1
);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS delivery_assignments CASCADE;
DROP TABLE IF EXISTS delivery_charges CASCADE;
DROP TABLE IF EXISTS delivery_details CASCADE;
DROP TABLE IF EXISTS delivery_orders CASCADE;

-- +goose StatementEnd
