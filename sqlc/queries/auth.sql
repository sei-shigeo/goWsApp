-- ==============================
-- 認証・セッション管理クエリ
-- ==============================

-- name: GetEmployeeForLogin :one
-- 従業員コードでログイン情報を取得
SELECT 
    e.id,
    e.employee_code,
    e.last_name,
    e.first_name,
    e.password_hash,
    e.role_id,
    r.name as role_name,
    e.failed_login_attempts,
    e.locked_until,
    e.last_login_at,
    e.is_active
FROM employees e
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.employee_code = $1
AND e.deleted_at IS NULL;

-- name: UpdateLoginSuccess :exec
-- ログイン成功時の更新
UPDATE employees
SET 
    last_login_at = CURRENT_TIMESTAMP,
    failed_login_attempts = 0,
    locked_until = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: IncrementFailedLoginAttempts :exec
-- ログイン失敗回数をインクリメント
UPDATE employees
SET 
    failed_login_attempts = failed_login_attempts + 1,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: LockEmployeeAccount :exec
-- アカウントをロック
UPDATE employees
SET 
    locked_until = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: UpdateEmployeePassword :exec
-- パスワードを更新
UPDATE employees
SET 
    password_hash = $2,
    password_updated_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: CreateSession :one
-- セッションを作成
INSERT INTO sessions (
    employee_id,
    session_token,
    ip_address,
    user_agent,
    expires_at
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetSessionByToken :one
-- セッショントークンでセッションを取得
SELECT 
    s.*,
    e.employee_code,
    e.last_name,
    e.first_name,
    e.role_id,
    r.name as role_name
FROM sessions s
JOIN employees e ON s.employee_id = e.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE s.session_token = $1
AND s.expires_at > CURRENT_TIMESTAMP
AND e.is_active = true
AND e.deleted_at IS NULL;

-- name: UpdateSessionAccess :exec
-- セッションの最終アクセス時刻を更新
UPDATE sessions
SET last_accessed_at = CURRENT_TIMESTAMP
WHERE session_token = $1;

-- name: DeleteSession :exec
-- セッションを削除（ログアウト）
DELETE FROM sessions
WHERE session_token = $1;

-- name: DeleteExpiredSessions :exec
-- 期限切れセッションを削除
DELETE FROM sessions
WHERE expires_at < CURRENT_TIMESTAMP;

-- name: DeleteEmployeeSessions :exec
-- 特定従業員のすべてのセッションを削除
DELETE FROM sessions
WHERE employee_id = $1;

-- name: CreateLoginLog :exec
-- ログイン履歴を記録
INSERT INTO login_logs (
    employee_id,
    employee_code,
    login_success,
    failure_reason,
    ip_address,
    user_agent
) VALUES (
    $1, $2, $3, $4, $5, $6
);

-- name: GetLoginLogs :many
-- ログイン履歴を取得
SELECT *
FROM login_logs
WHERE employee_id = $1
ORDER BY attempted_at DESC
LIMIT $2 OFFSET $3;

-- name: GetRecentLoginLogs :many
-- 最近のログイン履歴を取得（全従業員）
SELECT 
    l.*,
    e.last_name,
    e.first_name
FROM login_logs l
LEFT JOIN employees e ON l.employee_id = e.id
ORDER BY l.attempted_at DESC
LIMIT $1 OFFSET $2;

-- name: CountActiveSessions :one
-- アクティブなセッション数を取得
SELECT COUNT(*) as count
FROM sessions
WHERE expires_at > CURRENT_TIMESTAMP;

-- name: GetActiveSessionsByEmployee :many
-- 従業員のアクティブセッション一覧
SELECT *
FROM sessions
WHERE employee_id = $1
AND expires_at > CURRENT_TIMESTAMP
ORDER BY created_at DESC;
