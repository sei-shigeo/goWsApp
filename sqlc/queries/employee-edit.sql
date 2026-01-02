-- name: EmployeeBasicInfoUpdate :one
UPDATE employees
SET
    employee_code = ?,
    -- 画像情報
    employee_image_url = ?,
    employee_photo_date = ?,
    -- 基本情報
    last_name = ?,
    first_name = ?,
    last_name_kana = ?,
    first_name_kana = ?,
    legal_name = ?,
    gender = ?,
    blood_type = ?,
    address = ?,
    phone = ?,
    email = ?,
    -- 緊急連絡先
    emergency_contact_name = ?,
    emergency_contact_relationship = ?,
    emergency_contact_phone = ?,
    emergency_contact_email = ?,
    emergency_contact_address = ?,
    -- 在留資格
    nationality_id = ?,
    visa_type = ?,
    visa_expiry = ?,

    updated_at = CURRENT_TIMESTAMP
WHERE id = ?
RETURNING employee_code, employee_image_url, employee_photo_date, last_name, first_name, last_name_kana, first_name_kana, legal_name, gender, blood_type, address, phone, email, emergency_contact_name, emergency_contact_relationship, emergency_contact_phone, emergency_contact_email, emergency_contact_address, nationality_id, visa_type, visa_expiry;


-- name: EmployeeBasicInfoCreate :exec
INSERT INTO employees (
    employee_code, employee_image_url, employee_photo_date, last_name, first_name,
    last_name_kana, first_name_kana, legal_name, gender, blood_type,
    address, phone, email, emergency_contact_name, emergency_contact_relationship,
    emergency_contact_phone, emergency_contact_email, emergency_contact_address, nationality_id, visa_type,
    visa_expiry
) VALUES (
    ?, ?, ?, ?, ?,
    ?, ?, ?, ?, ?,
    ?, ?, ?, ?, ?,
    ?, ?, ?, ?, ?,
    ? 
);