-- name: EmployeeBasicInfoUpdate :one
UPDATE employees
SET
    employee_code = $2,
    -- 画像情報
    employee_image_url = $3,
    employee_photo_date = $4,
    -- 基本情報
    last_name = $5,
    first_name = $6,
    last_name_kana = $7,
    first_name_kana = $8,
    legal_name = $9,
    gender = $10,
    blood_type = $11,
    address = $12,
    phone = $13,
    email = $14,
    -- 緊急連絡先
    emergency_contact_name = $15,
    emergency_contact_relationship = $16,
    emergency_contact_phone = $17,
    emergency_contact_email = $18,
    emergency_contact_address = $19,
    -- 在留資格
    nationality_id = $20,
    visa_type = $21,
    visa_expiry = $22,

    updated_at = CURRENT_TIMESTAMP
WHERE id = $1
RETURNING employee_code, employee_image_url, employee_photo_date, last_name, first_name, last_name_kana, first_name_kana, legal_name, gender, blood_type, address, phone, email, emergency_contact_name, emergency_contact_relationship, emergency_contact_phone, emergency_contact_email, emergency_contact_address, nationality_id, visa_type, visa_expiry;
