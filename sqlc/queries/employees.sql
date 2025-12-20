-- name: GetEmployeeCardList :many
SELECT 
    e.id, 
    e.employee_code, 
    e.employee_image_url, 
    e.last_name, 
    e.first_name,
    a.prefecture,
    a.city,
    a.street_address,
    a.building_name,
    m.email,
    p.phone_number
FROM employees e
LEFT JOIN m_emails m ON e.id = m.owner_id AND m.owner_type = 'employee' AND m.is_primary = true
LEFT JOIN m_phones p ON e.id = p.owner_id AND p.owner_type = 'employee' AND p.is_primary = true
LEFT JOIN m_addresses a ON e.id = a.owner_id AND a.owner_type = 'employee' AND a.is_primary = true
WHERE e.deleted_at IS NULL
ORDER BY e.employee_code
LIMIT $1 OFFSET $2;