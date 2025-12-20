-- ==============================
-- 権限マスタークエリ
-- ==============================

-- name: ListRoles :many
-- 権限一覧を取得
SELECT *
FROM m_roles
ORDER BY id;

-- name: GetRole :one
-- 権限を取得
SELECT *
FROM m_roles
WHERE id = $1;

-- name: GetRoleByName :one
-- 権限名で取得
SELECT *
FROM m_roles
WHERE name = $1;
