-- +goose Up
-- +goose StatementBegin

-- ==============================
-- 認証・セッション管理テーブル
-- ==============================

-- セッションテーブル
CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL, -- セッショントークン
    
    -- セッション情報
    ip_address VARCHAR(45), -- IPv6対応
    user_agent TEXT, -- ブラウザ情報
    
    -- 有効期限
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- 作成・更新
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sessions_employee ON sessions(employee_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);

-- ログイン履歴テーブル
CREATE TABLE IF NOT EXISTS login_logs (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    employee_code VARCHAR(50), -- 削除されても履歴を残す
    
    -- ログイン結果
    login_success BOOLEAN NOT NULL,
    failure_reason VARCHAR(100), -- 失敗理由（パスワード違い、アカウントロック等）
    
    -- アクセス情報
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- ログイン日時
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_login_logs_employee ON login_logs(employee_id);
CREATE INDEX IF NOT EXISTS idx_login_logs_code ON login_logs(employee_code);
CREATE INDEX IF NOT EXISTS idx_login_logs_attempted ON login_logs(attempted_at);
CREATE INDEX IF NOT EXISTS idx_login_logs_success ON login_logs(login_success);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS login_logs CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;

-- +goose StatementEnd
