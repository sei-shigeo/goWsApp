-- name: GetEmployeeCardList :many
SELECT 
    e.id, 
    e.employee_code, 
    e.employee_image_url, 
    e.last_name, 
    e.first_name,
    m.email,
    p.phone_number
FROM employees e
LEFT JOIN m_emails m ON e.id = m.owner_id AND m.owner_type = 'employee' AND m.is_primary = true
LEFT JOIN m_phones p ON e.id = p.owner_id AND p.owner_type = 'employee' AND p.is_primary = true
WHERE e.deleted_at IS NULL
ORDER BY e.employee_code
LIMIT $1 OFFSET $2;

-- 基本情報 + 所属事業所 + 制限情報
-- name: GetEmployeeBasicInfo :one
SELECT 
e.*, 
co.office_name, 
co.office_type,
r.name as role_name
FROM employees e
LEFT JOIN company_offices co ON e.office_id = co.id AND co.deleted_at IS NULL
LEFT JOIN m_roles r ON e.role_id = r.id
WHERE e.id = $1 AND e.deleted_at IS NULL;

-- 住所
-- name: GetEmployeeAddresses :many
SELECT * FROM m_addresses WHERE owner_id = $1 AND owner_type = 'employee';

-- メールアドレス
-- name: GetEmployeeEmails :many
SELECT * FROM m_emails WHERE owner_id = $1 AND owner_type = 'employee';

-- 電話番号
-- name: GetEmployeePhones :many
SELECT * FROM m_phones WHERE owner_id = $1 AND owner_type = 'employee';

-- 銀行
-- name: GetEmployeeBanks :many
SELECT * FROM m_banks WHERE owner_id = $1 AND owner_type = 'employee';

-- 緊急連絡先
-- name: GetEmployeeEmergencyContacts :many
SELECT * FROM emergency_contacts WHERE employee_id = $1;

-- 教育訓練
-- name: GetEmployeeTrainingRecords :many
SELECT * FROM training_records WHERE employee_id = $1;

-- 健康診断
-- name: GetEmployeeHealthCheckupRecords :many
SELECT * FROM health_checkup_records WHERE employee_id = $1;

-- 資格
-- name: GetEmployeeQualificationRecords :many
SELECT * FROM qualification_records WHERE employee_id = $1;

-- 保険
-- name: GetEmployeeInsuranceRecords :many
SELECT * FROM insurance_records WHERE employee_id = $1;

-- 学歴
-- name: GetEmployeeEducationRecords :many
SELECT * FROM education_records WHERE employee_id = $1;

-- 職歴
-- name: GetEmployeeCareerRecords :many
SELECT * FROM career_records WHERE employee_id = $1;

-- 事故履歴
-- name: GetEmployeeAccidentRecords :many 
SELECT * FROM accident_records WHERE employee_id = $1;

-- 違反履歴
-- name: GetEmployeeViolationRecords :many
SELECT * FROM violation_records WHERE employee_id = $1;