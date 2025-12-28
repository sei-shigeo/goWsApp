-- name: GetEmployeeCardList :many
SELECT 
    id, 
    employee_code, 
    employee_image_url, 
    last_name, 
    first_name,
    email,
    phone
FROM employees
WHERE deleted_at IS NULL
ORDER BY employee_code
LIMIT $1 OFFSET $2;

-- 基本情報 + 所属事業所 + 制限情報
-- name: GetEmployeeBasicInfo :one
SELECT 
e.*, 
co.office_name, 
co.office_type,
r.name as role_name,
et.name as employment_type_name,
jt.name as job_type_name,
d.name as department_name,
p.name as position_name,
n.name as nationality_name
FROM employees e
LEFT JOIN company_offices co ON e.office_id = co.id AND co.deleted_at IS NULL
LEFT JOIN m_roles r ON e.role_id = r.id
LEFT JOIN m_employment_types et ON e.employment_type_id = et.id
LEFT JOIN m_job_types jt ON e.job_type_id = jt.id
LEFT JOIN m_departments d ON e.department_id = d.id
LEFT JOIN m_positions p ON e.position_id = p.id
LEFT JOIN m_nationalities n ON e.nationality_id = n.id
WHERE e.id = $1 AND e.deleted_at IS NULL;

-- 国籍マスタ
-- name: GetAllMNationalities :many
SELECT * FROM m_nationalities;

-- 職種マスタ
-- name: GetAllMJobTypes :many
SELECT * FROM m_job_types;

-- 雇用形態マスタ
-- name: GetAllMEmploymentTypes :many
SELECT * FROM m_employment_types;

-- 部署マスタ
-- name: GetAllMDepartments :many
SELECT * FROM m_departments;

-- 役職マスタ
-- name: GetAllMPositions :many
SELECT * FROM m_positions;

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