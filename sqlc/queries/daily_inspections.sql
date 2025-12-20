-- ==============================
-- 日常点検クエリ
-- ==============================

-- name: CreateDailyInspection :one
-- 日常点検記録を登録
INSERT INTO vehicle_daily_inspections (
    vehicle_id,
    driver_id,
    inspection_date,
    inspection_time,
    odometer_reading,
    engine_oil_level,
    coolant_level,
    brake_fluid_level,
    washer_fluid_level,
    tire_pressure_fl,
    tire_pressure_fr,
    tire_pressure_rl,
    tire_pressure_rr,
    tire_tread_depth,
    headlights,
    tail_lights,
    brake_lights,
    turn_signals,
    hazard_lights,
    windshield_wipers,
    horn,
    mirrors,
    seat_belt,
    body_damage,
    overall_status,
    abnormality_description,
    action_taken,
    notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
    $21, $22, $23, $24, $25, $26, $27, $28
) RETURNING *;

-- name: GetDailyInspection :one
-- 日常点検記録を取得
SELECT 
    di.*,
    v.vehicle_number,
    v.vehicle_name,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
JOIN vehicles v ON di.vehicle_id = v.id
LEFT JOIN employees e ON di.driver_id = e.id
WHERE di.id = $1;

-- name: ListDailyInspections :many
-- 日常点検記録一覧
SELECT 
    di.*,
    v.vehicle_number,
    v.vehicle_name,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
JOIN vehicles v ON di.vehicle_id = v.id
LEFT JOIN employees e ON di.driver_id = e.id
ORDER BY di.inspection_date DESC, di.inspection_time DESC
LIMIT $1 OFFSET $2;

-- name: ListDailyInspectionsByVehicle :many
-- 車両別の日常点検記録
SELECT 
    di.*,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
LEFT JOIN employees e ON di.driver_id = e.id
WHERE di.vehicle_id = $1
ORDER BY di.inspection_date DESC, di.inspection_time DESC
LIMIT $2 OFFSET $3;

-- name: ListDailyInspectionsByDate :many
-- 日付別の日常点検記録
SELECT 
    di.*,
    v.vehicle_number,
    v.vehicle_name,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
JOIN vehicles v ON di.vehicle_id = v.id
LEFT JOIN employees e ON di.driver_id = e.id
WHERE di.inspection_date = $1
ORDER BY di.inspection_time;

-- name: GetLatestInspectionByVehicle :one
-- 車両の最新点検記録を取得
SELECT 
    di.*,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
LEFT JOIN employees e ON di.driver_id = e.id
WHERE di.vehicle_id = $1
ORDER BY di.inspection_date DESC, di.inspection_time DESC
LIMIT 1;

-- name: UpdateDailyInspection :exec
-- 日常点検記録を更新
UPDATE vehicle_daily_inspections
SET
    overall_status = COALESCE(sqlc.narg('overall_status'), overall_status),
    abnormality_description = COALESCE(sqlc.narg('abnormality_description'), abnormality_description),
    action_taken = COALESCE(sqlc.narg('action_taken'), action_taken),
    notes = COALESCE(sqlc.narg('notes'), notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: GetDefectiveInspections :many
-- 不良のある点検記録一覧
SELECT 
    di.*,
    v.vehicle_number,
    v.vehicle_name,
    e.last_name || ' ' || e.first_name as driver_name
FROM vehicle_daily_inspections di
JOIN vehicles v ON di.vehicle_id = v.id
LEFT JOIN employees e ON di.driver_id = e.id
WHERE di.overall_status IN ('要注意', '整備必要', '運行不可')
ORDER BY di.inspection_date DESC;

-- name: CountDailyInspections :one
-- 日常点検記録数をカウント
SELECT COUNT(*) as count
FROM vehicle_daily_inspections
WHERE ($1::date IS NULL OR inspection_date >= $1)
AND ($2::date IS NULL OR inspection_date <= $2)
AND ($3::text IS NULL OR overall_status = $3);
