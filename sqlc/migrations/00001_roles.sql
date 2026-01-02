-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 基本マスターテーブル
-- ==============================

-- 権限マスターテーブル
CREATE TABLE IF NOT EXISTS m_roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO m_roles (name) VALUES ('管理者'), ('一般');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS m_roles;

-- +goose StatementEnd

