-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 品名マスターテーブル
-- ==============================

-- 品名（商品・サービス）マスターテーブル
-- 注意：単価は毎回手入力するため、このテーブルでは管理しない
CREATE TABLE IF NOT EXISTS service_items (
    id SERIAL PRIMARY KEY,
    
    -- サービス種別
    service_type VARCHAR(20) CHECK (service_type IN ('スポット便', '定期便', '常用', 'チャーター', 'その他')),
    
    item_name VARCHAR(255) NOT NULL, -- 品名

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX idx_service_items_type ON service_items(service_type);

-- サンプルデータ（定期便・常用便のみ）
INSERT INTO service_items (service_type, item_name) VALUES
    -- 定期便
    ('定期便', 'ミルクラン便'),
    ('定期便', 'インバーター便'),
    ('定期便', '名港海運便'),
    ('定期便', '長草便'),
    ('定期便', 'JETCT花園便'),
    
    -- 常用
    ('常用', '形鋼'),
    ('常用', '鋼管パイプ');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS service_items CASCADE;

-- +goose StatementEnd
