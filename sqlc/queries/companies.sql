-- ==============================
-- 会社情報・事業所管理クエリ
-- ==============================

-- name: GetCompany :one
-- 会社情報を取得
SELECT *
FROM companies
WHERE id = $1
AND deleted_at IS NULL;

-- name: UpdateCompany :exec
-- 会社情報を更新
UPDATE companies
SET
    name = COALESCE(sqlc.narg('name'), name),
    company_code = COALESCE(sqlc.narg('company_code'), company_code),
    transport_license_number = COALESCE(sqlc.narg('transport_license_number'), transport_license_number),
    transport_license_type = COALESCE(sqlc.narg('transport_license_type'), transport_license_type),
    transport_license_issue_date = COALESCE(sqlc.narg('transport_license_issue_date'), transport_license_issue_date),
    transport_license_expiry_date = COALESCE(sqlc.narg('transport_license_expiry_date'), transport_license_expiry_date),
    tax_id = COALESCE(sqlc.narg('tax_id'), tax_id),
    invoice_number = COALESCE(sqlc.narg('invoice_number'), invoice_number),
    representative_name = COALESCE(sqlc.narg('representative_name'), representative_name),
    is_active = COALESCE(sqlc.narg('is_active'), is_active),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: CreateCompanyOffice :one
-- 事業所を登録
INSERT INTO company_offices (
    company_id,
    office_code,
    office_name,
    office_type,
    manager_id,
    opening_date,
    postal_code,
    address,
    phone,
    fax,
    email,
    website,
    notes,
    is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- name: GetCompanyOffice :one
-- 事業所を取得
SELECT 
    o.*,
    e.last_name || ' ' || e.first_name as manager_name
FROM company_offices o
LEFT JOIN employees e ON o.manager_id = e.id
WHERE o.id = $1
AND o.deleted_at IS NULL;

-- name: ListCompanyOffices :many
-- 事業所一覧
SELECT 
    o.*,
    e.last_name || ' ' || e.first_name as manager_name
FROM company_offices o
LEFT JOIN employees e ON o.manager_id = e.id
WHERE o.deleted_at IS NULL
ORDER BY o.office_code;

-- name: ListActiveCompanyOffices :many
-- アクティブな事業所一覧
SELECT 
    o.*,
    e.last_name || ' ' || e.first_name as manager_name
FROM company_offices o
LEFT JOIN employees e ON o.manager_id = e.id
WHERE o.is_active = true
AND o.deleted_at IS NULL
ORDER BY o.office_code;

-- name: UpdateCompanyOffice :exec
-- 事業所を更新
UPDATE company_offices
SET
    office_name = COALESCE(sqlc.narg('office_name'), office_name),
    office_type = COALESCE(sqlc.narg('office_type'), office_type),
    manager_id = COALESCE(sqlc.narg('manager_id'), manager_id),
    postal_code = COALESCE(sqlc.narg('postal_code'), postal_code),
    address = COALESCE(sqlc.narg('address'), address),
    phone = COALESCE(sqlc.narg('phone'), phone),
    fax = COALESCE(sqlc.narg('fax'), fax),
    email = COALESCE(sqlc.narg('email'), email),
    website = COALESCE(sqlc.narg('website'), website),
    notes = COALESCE(sqlc.narg('notes'), notes),
    is_active = COALESCE(sqlc.narg('is_active'), is_active),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteCompanyOffice :exec
-- 事業所を論理削除
UPDATE company_offices
SET
    deleted_at = CURRENT_TIMESTAMP,
    is_active = false
WHERE id = $1;
