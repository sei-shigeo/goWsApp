-- ==============================
-- サービス品名マスタークエリ
-- ==============================

-- name: CreateServiceItem :one
-- サービス品名を登録
INSERT INTO service_items (
    service_type,
    item_name
) VALUES (
    $1, $2
) RETURNING *;

-- name: GetServiceItem :one
-- サービス品名を取得
SELECT *
FROM service_items
WHERE id = $1
AND deleted_at IS NULL;

-- name: ListServiceItems :many
-- サービス品名一覧
SELECT *
FROM service_items
WHERE deleted_at IS NULL
ORDER BY service_type, item_name;

-- name: ListServiceItemsByType :many
-- サービスタイプ別の品名一覧
SELECT *
FROM service_items
WHERE service_type = $1
AND deleted_at IS NULL
ORDER BY item_name;

-- name: SearchServiceItems :many
-- サービス品名を検索
SELECT *
FROM service_items
WHERE deleted_at IS NULL
AND (
    $1::text IS NULL 
    OR item_name ILIKE '%' || $1 || '%'
)
AND ($2::text IS NULL OR service_type = $2)
ORDER BY service_type, item_name;

-- name: UpdateServiceItem :exec
-- サービス品名を更新
UPDATE service_items
SET
    service_type = COALESCE(sqlc.narg('service_type'), service_type),
    item_name = COALESCE(sqlc.narg('item_name'), item_name),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteServiceItem :exec
-- サービス品名を論理削除
UPDATE service_items
SET deleted_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: CountServiceItems :one
-- サービス品名数をカウント
SELECT COUNT(*) as count
FROM service_items
WHERE deleted_at IS NULL
AND ($1::text IS NULL OR service_type = $1);
