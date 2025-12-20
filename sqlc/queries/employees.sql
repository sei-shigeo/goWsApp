-- ==============================
-- 従業員管理クエリ
-- ==============================

-- name: CreateEmployee :one
-- 従業員を新規登録
INSERT INTO employees (
    employee_code,
    last_name,
    first_name,
    last_name_kana,
    first_name_kana,
    legal_name,
    gender,
    birth_date,
    hire_date,
    office_id,
    job_type,
    employment_type,
    department,
    position,
    role_id,
    nationality,
    is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
) RETURNING *;

-- name: GetEmployee :one
-- 従業員をIDで取得
SELECT 
    e.*,
    o.office_name,
    r.name as role_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.id = $1
AND e.deleted_at IS NULL;

-- name: GetEmployeeByCode :one
-- 従業員コードで取得
SELECT 
    e.*,
    o.office_name,
    r.name as role_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.employee_code = $1
AND e.deleted_at IS NULL;

-- name: ListEmployees :many
-- 従業員一覧を取得
SELECT 
    e.*,
    o.office_name,
    r.name as role_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.deleted_at IS NULL
ORDER BY e.employee_code
LIMIT $1 OFFSET $2;

-- name: ListActiveEmployees :many
-- アクティブな従業員一覧
SELECT 
    e.*,
    o.office_name,
    r.name as role_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.is_active = true
AND e.deleted_at IS NULL
ORDER BY e.employee_code;

-- name: ListDrivers :many
-- 運転者一覧を取得（配車用）
SELECT 
    e.*,
    o.office_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
WHERE e.job_type = '運転者'
AND e.is_active = true
AND e.deleted_at IS NULL
AND (e.driving_disabled_date IS NULL OR e.driving_disabled_date > CURRENT_DATE)
AND (e.retirement_date IS NULL OR e.retirement_date > CURRENT_DATE)
ORDER BY e.employee_code;

-- name: SearchEmployees :many
-- 従業員を検索
SELECT 
    e.*,
    o.office_name,
    r.name as role_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.deleted_at IS NULL
AND (
    $1::text IS NULL OR e.employee_code ILIKE '%' || $1 || '%'
    OR e.last_name ILIKE '%' || $1 || '%'
    OR e.first_name ILIKE '%' || $1 || '%'
    OR e.last_name_kana ILIKE '%' || $1 || '%'
    OR e.first_name_kana ILIKE '%' || $1 || '%'
)
AND ($2::integer IS NULL OR e.office_id = $2)
AND ($3::text IS NULL OR e.job_type = $3)
AND ($4::boolean IS NULL OR e.is_active = $4)
ORDER BY e.employee_code
LIMIT $5 OFFSET $6;

-- name: UpdateEmployee :exec
-- 従業員情報を更新
UPDATE employees
SET
    last_name = COALESCE(sqlc.narg('last_name'), last_name),
    first_name = COALESCE(sqlc.narg('first_name'), first_name),
    last_name_kana = COALESCE(sqlc.narg('last_name_kana'), last_name_kana),
    first_name_kana = COALESCE(sqlc.narg('first_name_kana'), first_name_kana),
    legal_name = COALESCE(sqlc.narg('legal_name'), legal_name),
    gender = COALESCE(sqlc.narg('gender'), gender),
    birth_date = COALESCE(sqlc.narg('birth_date'), birth_date),
    office_id = COALESCE(sqlc.narg('office_id'), office_id),
    job_type = COALESCE(sqlc.narg('job_type'), job_type),
    employment_type = COALESCE(sqlc.narg('employment_type'), employment_type),
    department = COALESCE(sqlc.narg('department'), department),
    position = COALESCE(sqlc.narg('position'), position),
    role_id = COALESCE(sqlc.narg('role_id'), role_id),
    is_active = COALESCE(sqlc.narg('is_active'), is_active),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: UpdateEmployeeLicense :exec
-- 運転免許情報を更新
UPDATE employees
SET
    driver_license_no = $2,
    driver_license_type = $3,
    driver_license_issue_date = $4,
    driver_license_expiry = $5,
    driver_license_image_url_front = $6,
    driver_license_image_url_back = $7,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: SetEmployeeRetirement :exec
-- 従業員を退職処理
UPDATE employees
SET
    retirement_date = $2,
    retirement_reason = $3,
    is_active = false,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: DeleteEmployee :exec
-- 従業員を論理削除
UPDATE employees
SET
    deleted_at = CURRENT_TIMESTAMP,
    is_active = false
WHERE id = $1;

-- name: CountEmployees :one
-- 従業員数をカウント
SELECT COUNT(*) as count
FROM employees
WHERE deleted_at IS NULL
AND ($1::boolean IS NULL OR is_active = $1);

-- name: ListEmployeesByOffice :many
-- 事業所別の従業員一覧
SELECT 
    e.*,
    r.name as role_name
FROM employees e
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.office_id = $1
AND e.deleted_at IS NULL
ORDER BY e.employee_code;

-- name: GetLicenseExpiringSoon :many
-- 免許証の有効期限が近い従業員を取得
SELECT 
    e.*,
    o.office_name
FROM employees e
LEFT JOIN company_offices o ON e.office_id = o.id
WHERE e.driver_license_expiry IS NOT NULL
AND e.driver_license_expiry BETWEEN CURRENT_DATE AND CURRENT_DATE + $1::interval
AND e.is_active = true
AND e.deleted_at IS NULL
ORDER BY e.driver_license_expiry;
