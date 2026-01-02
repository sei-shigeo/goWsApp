-- name: GetEmployeeCardList :many
SELECT 
    id, 
    employee_code, 
    employee_image_url, 
    last_name, 
    first_name,
    email,
    phone,
    address
FROM employees
WHERE deleted_at IS NULL
ORDER BY employee_code
LIMIT ? OFFSET ?;

-- name: GetEmployeeBasicInfo :one
SELECT 
e.id, e.employee_code, e.employee_image_url, e.employee_photo_date,
e.last_name, e.first_name, e.last_name_kana, e.first_name_kana, e.legal_name,
e.gender, e.blood_type, e.address, e.phone, e.email,
e.emergency_contact_name, e.emergency_contact_relationship, e.emergency_contact_phone,
e.emergency_contact_email, e.emergency_contact_address,
e.birth_date, e.hire_date, e.appointment_date,
e.office_id, e.employment_type_id, e.job_type_id, e.department_id, e.position_id,
e.retirement_date, e.retirement_reason, e.death_date, e.death_reason,
e.driver_license_no, e.driver_license_type, e.driver_license_issue_date, e.driver_license_expiry,
e.driver_license_image_url_front, e.driver_license_image_url_back,
e.driving_disabled_date, e.driving_disabled_reason,
e.nationality_id, e.visa_type, e.visa_expiry, e.visa_image_url_front, e.visa_image_url_back,
e.bank_code, e.bank_name, e.bank_branch_code, e.bank_branch_name,
e.bank_account_type, e.bank_account_number, e.bank_account_name, e.bank_account_kana,
e.role_id, e.password_hash, e.password_updated_at, e.failed_login_attempts,
e.locked_until, e.last_login_at, e.is_active, e.created_at, e.updated_at, e.deleted_at,
co.office_name, co.office_type,
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
WHERE e.id = ? AND e.deleted_at IS NULL;

-- name: GetAllMNationalities :many
SELECT * FROM m_nationalities;

-- name: GetAllMJobTypes :many
SELECT * FROM m_job_types;

-- name: GetAllMEmploymentTypes :many
SELECT * FROM m_employment_types;

-- name: GetAllMDepartments :many
SELECT * FROM m_departments;

-- name: GetAllMPositions :many
SELECT * FROM m_positions;

-- name: GetEmployeeTrainingRecords :many
SELECT * FROM training_records WHERE employee_id = ?;

-- name: GetEmployeeHealthCheckupRecords :many
SELECT * FROM health_checkup_records WHERE employee_id = ?;

-- name: GetEmployeeQualificationRecords :many
SELECT * FROM qualification_records WHERE employee_id = ?;

-- name: GetEmployeeInsuranceRecords :many
SELECT * FROM insurance_records WHERE employee_id = ?;

-- name: GetEmployeeEducationRecords :many
SELECT * FROM education_records WHERE employee_id = ?;

-- name: GetEmployeeCareerRecords :many
SELECT * FROM career_records WHERE employee_id = ?;

-- name: GetEmployeeAccidentRecords :many
SELECT * FROM accident_records WHERE employee_id = ?;

-- name: GetEmployeeViolationRecords :many
SELECT * FROM violation_records WHERE employee_id = ?;