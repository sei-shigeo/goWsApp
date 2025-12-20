-- ==============================
-- 車両管理クエリ
-- ==============================

-- name: CreateVehicle :one
-- 車両を新規登録
INSERT INTO vehicles (
    vehicle_code,
    vehicle_number,
    vehicle_name,
    vehicle_type,
    manufacturer,
    model_name,
    model_year,
    initial_registration_date,
    vehicle_inspection_expiry,
    max_load_capacity,
    fuel_type,
    office_id,
    is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
) RETURNING *;

-- name: GetVehicle :one
-- 車両をIDで取得
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.id = $1
AND v.deleted_at IS NULL;

-- name: GetVehicleByNumber :one
-- 車両番号で取得
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.vehicle_number = $1
AND v.deleted_at IS NULL;

-- name: ListVehicles :many
-- 車両一覧を取得
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.deleted_at IS NULL
ORDER BY v.vehicle_number
LIMIT $1 OFFSET $2;

-- name: ListActiveVehicles :many
-- アクティブな車両一覧（配車可能）
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.is_active = true
AND v.deleted_at IS NULL
AND (v.vehicle_inspection_expiry IS NULL OR v.vehicle_inspection_expiry > CURRENT_DATE)
ORDER BY v.vehicle_number;

-- name: ListVehiclesByType :many
-- 車両タイプ別一覧
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.vehicle_type = $1
AND v.is_active = true
AND v.deleted_at IS NULL
ORDER BY v.vehicle_number;

-- name: ListTractors :many
-- トラクタ一覧
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.vehicle_type = 'トラクタ'
AND v.is_active = true
AND v.deleted_at IS NULL
ORDER BY v.vehicle_number;

-- name: ListTrailers :many
-- トレーラー一覧
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.vehicle_type = 'トレーラー'
AND v.is_active = true
AND v.deleted_at IS NULL
ORDER BY v.vehicle_number;

-- name: SearchVehicles :many
-- 車両を検索
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.deleted_at IS NULL
AND (
    $1::text IS NULL 
    OR v.vehicle_number ILIKE '%' || $1 || '%'
    OR v.vehicle_name ILIKE '%' || $1 || '%'
)
AND ($2::text IS NULL OR v.vehicle_type = $2)
AND ($3::integer IS NULL OR v.office_id = $3)
AND ($4::boolean IS NULL OR v.is_active = $4)
ORDER BY v.vehicle_number
LIMIT $5 OFFSET $6;

-- name: UpdateVehicle :exec
-- 車両情報を更新
UPDATE vehicles
SET
    vehicle_name = COALESCE(sqlc.narg('vehicle_name'), vehicle_name),
    vehicle_type = COALESCE(sqlc.narg('vehicle_type'), vehicle_type),
    manufacturer = COALESCE(sqlc.narg('manufacturer'), manufacturer),
    model_name = COALESCE(sqlc.narg('model_name'), model_name),
    model_year = COALESCE(sqlc.narg('model_year'), model_year),
    vehicle_inspection_expiry = COALESCE(sqlc.narg('vehicle_inspection_expiry'), vehicle_inspection_expiry),
    max_load_capacity = COALESCE(sqlc.narg('max_load_capacity'), max_load_capacity),
    fuel_type = COALESCE(sqlc.narg('fuel_type'), fuel_type),
    office_id = COALESCE(sqlc.narg('office_id'), office_id),
    is_active = COALESCE(sqlc.narg('is_active'), is_active),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteVehicle :exec
-- 車両を論理削除
UPDATE vehicles
SET
    deleted_at = CURRENT_TIMESTAMP,
    is_active = false
WHERE id = $1;

-- name: CountVehicles :one
-- 車両数をカウント
SELECT COUNT(*) as count
FROM vehicles
WHERE deleted_at IS NULL
AND ($1::boolean IS NULL OR is_active = $1);

-- name: GetVehicleInspectionExpiringSoon :many
-- 車検の有効期限が近い車両を取得
SELECT 
    v.*,
    o.office_name
FROM vehicles v
LEFT JOIN company_offices o ON v.office_id = o.id
WHERE v.vehicle_inspection_expiry IS NOT NULL
AND v.vehicle_inspection_expiry BETWEEN CURRENT_DATE AND CURRENT_DATE + $1::interval
AND v.is_active = true
AND v.deleted_at IS NULL
ORDER BY v.vehicle_inspection_expiry;

-- name: CreateVehicleMaintenance :one
-- 整備記録を登録
INSERT INTO vehicle_maintenance_records (
    vehicle_id,
    maintenance_type,
    maintenance_date,
    odometer_reading,
    maintenance_shop,
    total_cost,
    next_maintenance_date,
    notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: ListVehicleMaintenanceRecords :many
-- 車両の整備記録一覧
SELECT *
FROM vehicle_maintenance_records
WHERE vehicle_id = $1
AND deleted_at IS NULL
ORDER BY maintenance_date DESC
LIMIT $2 OFFSET $3;

-- name: CreateVehicleFuelRecord :one
-- 燃料記録を登録
INSERT INTO vehicle_fuel_records (
    vehicle_id,
    fuel_date,
    fuel_station,
    fuel_type,
    fuel_amount,
    fuel_unit_price,
    fuel_total_price,
    odometer_reading,
    notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: ListVehicleFuelRecords :many
-- 車両の燃料記録一覧
SELECT *
FROM vehicle_fuel_records
WHERE vehicle_id = $1
ORDER BY fuel_date DESC
LIMIT $2 OFFSET $3;

-- name: GetVehicleFuelSummary :one
-- 車両の燃料消費サマリー（期間指定）
SELECT 
    vehicle_id,
    COUNT(*) as refuel_count,
    SUM(fuel_amount) as total_fuel_amount,
    SUM(fuel_total_price) as total_cost,
    AVG(fuel_unit_price) as avg_unit_price
FROM vehicle_fuel_records
WHERE vehicle_id = $1
AND fuel_date BETWEEN $2 AND $3
GROUP BY vehicle_id;
