-- ==============================
-- 取引先管理クエリ
-- ==============================

-- name: CreateCustomer :one
-- 取引先を新規登録
INSERT INTO customers (
    name,
    customer_code,
    credit_limit,
    payment_terms,
    payment_method,
    closing_day,
    payment_due_day,
    invoice_number,
    is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetCustomer :one
-- 取引先をIDで取得
SELECT *
FROM customers
WHERE id = $1
AND deleted_at IS NULL;

-- name: GetCustomerByCode :one
-- 取引先コードで取得
SELECT *
FROM customers
WHERE customer_code = $1
AND deleted_at IS NULL;

-- name: ListCustomers :many
-- 取引先一覧を取得
SELECT *
FROM customers
WHERE deleted_at IS NULL
ORDER BY customer_code
LIMIT $1 OFFSET $2;

-- name: ListActiveCustomers :many
-- アクティブな取引先一覧
SELECT *
FROM customers
WHERE is_active = true
AND deleted_at IS NULL
ORDER BY customer_code;

-- name: SearchCustomers :many
-- 取引先を検索
SELECT *
FROM customers
WHERE deleted_at IS NULL
AND (
    $1::text IS NULL 
    OR customer_code ILIKE '%' || $1 || '%'
    OR name ILIKE '%' || $1 || '%'
)
AND ($2::boolean IS NULL OR is_active = $2)
ORDER BY customer_code
LIMIT $3 OFFSET $4;

-- name: UpdateCustomer :exec
-- 取引先情報を更新
UPDATE customers
SET
    name = COALESCE(sqlc.narg('name'), name),
    credit_limit = COALESCE(sqlc.narg('credit_limit'), credit_limit),
    payment_terms = COALESCE(sqlc.narg('payment_terms'), payment_terms),
    payment_method = COALESCE(sqlc.narg('payment_method'), payment_method),
    closing_day = COALESCE(sqlc.narg('closing_day'), closing_day),
    payment_due_day = COALESCE(sqlc.narg('payment_due_day'), payment_due_day),
    invoice_number = COALESCE(sqlc.narg('invoice_number'), invoice_number),
    is_active = COALESCE(sqlc.narg('is_active'), is_active),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteCustomer :exec
-- 取引先を論理削除
UPDATE customers
SET
    deleted_at = CURRENT_TIMESTAMP,
    is_active = false
WHERE id = $1;

-- name: CountCustomers :one
-- 取引先数をカウント
SELECT COUNT(*) as count
FROM customers
WHERE deleted_at IS NULL
AND ($1::boolean IS NULL OR is_active = $1);

-- name: GetCustomerWithContacts :one
-- 取引先と担当者情報を取得
SELECT 
    c.*,
    json_agg(
        json_build_object(
            'id', cc.id,
            'last_name', cc.last_name,
            'first_name', cc.first_name,
            'department', cc.department,
            'position', cc.position,
            'phone_direct', cc.phone_direct,
            'email', cc.email
        ) ORDER BY cc.is_primary DESC, cc.last_name
    ) FILTER (WHERE cc.id IS NOT NULL) as contacts
FROM customers c
LEFT JOIN customer_contacts cc ON c.id = cc.customer_id
WHERE c.id = $1
GROUP BY c.id;

-- name: CreateCustomerContact :one
-- 取引先担当者を登録
INSERT INTO customer_contacts (
    customer_id,
    last_name,
    first_name,
    last_name_kana,
    first_name_kana,
    department,
    position,
    email,
    phone_direct,
    phone_mobile,
    is_primary,
    notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
) RETURNING *;

-- name: GetCustomerContact :one
-- 取引先担当者を取得
SELECT *
FROM customer_contacts
WHERE id = $1;

-- name: ListCustomerContacts :many
-- 取引先の担当者一覧
SELECT *
FROM customer_contacts
WHERE customer_id = $1
ORDER BY is_primary DESC, last_name;

-- name: UpdateCustomerContact :exec
-- 取引先担当者を更新
UPDATE customer_contacts
SET
    last_name = COALESCE(sqlc.narg('last_name'), last_name),
    first_name = COALESCE(sqlc.narg('first_name'), first_name),
    last_name_kana = COALESCE(sqlc.narg('last_name_kana'), last_name_kana),
    first_name_kana = COALESCE(sqlc.narg('first_name_kana'), first_name_kana),
    department = COALESCE(sqlc.narg('department'), department),
    position = COALESCE(sqlc.narg('position'), position),
    email = COALESCE(sqlc.narg('email'), email),
    phone_direct = COALESCE(sqlc.narg('phone_direct'), phone_direct),
    phone_mobile = COALESCE(sqlc.narg('phone_mobile'), phone_mobile),
    is_primary = COALESCE(sqlc.narg('is_primary'), is_primary),
    notes = COALESCE(sqlc.narg('notes'), notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteCustomerContact :exec
-- 取引先担当者を削除
DELETE FROM customer_contacts
WHERE id = $1;

-- name: SetPrimaryContact :exec
-- メイン担当者を設定（他の担当者のis_primaryをfalseにする）
UPDATE customer_contacts
SET 
    is_primary = CASE WHEN id = $2 THEN true ELSE false END,
    updated_at = CURRENT_TIMESTAMP
WHERE customer_id = $1
AND deleted_at IS NULL;
