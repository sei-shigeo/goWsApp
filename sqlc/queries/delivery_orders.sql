-- ==============================
-- 配送オーダー管理クエリ
-- ==============================

-- name: CreateDeliveryOrder :one
-- 配送オーダーを新規登録
INSERT INTO delivery_orders (
    order_number,
    customer_id,
    service_type,
    service_type_id,
    order_date,
    operation_date,
    delivery_date,
    driver_id,
    driver_companion_id,
    vehicle_id,
    departure_time,
    arrival_time,
    has_highway_fee,
    has_extra_charge,
    is_tax_exempt,
    order_status,
    notes,
    created_by,
    assigned_to
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
) RETURNING *;

-- name: GetDeliveryOrder :one
-- 配送オーダーをIDで取得
SELECT 
    ord.*,
    c.name as customer_name,
    c.customer_code,
    e1.last_name || ' ' || e1.first_name as driver_name,
    e2.last_name || ' ' || e2.first_name as companion_name,
    v.vehicle_number,
    si.item_name as service_item_name
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
LEFT JOIN employees e1 ON ord.driver_id = e1.id
LEFT JOIN employees e2 ON ord.driver_companion_id = e2.id
LEFT JOIN vehicles v ON ord.vehicle_id = v.id
LEFT JOIN service_items si ON ord.service_type_id = si.id
WHERE ord.id = $1
AND ord.deleted_at IS NULL;

-- name: GetDeliveryOrderByNumber :one
-- オーダー番号で取得
SELECT 
    ord.*,
    c.name as customer_name,
    c.customer_code
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
WHERE ord.order_number = $1
AND ord.deleted_at IS NULL;

-- name: ListDeliveryOrders :many
-- 配送オーダー一覧
SELECT 
    ord.*,
    c.name as customer_name,
    c.customer_code,
    e.last_name || ' ' || e.first_name as driver_name,
    v.vehicle_number
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
LEFT JOIN employees e ON ord.driver_id = e.id
LEFT JOIN vehicles v ON ord.vehicle_id = v.id
WHERE ord.deleted_at IS NULL
ORDER BY ord.operation_date DESC, ord.order_number DESC
LIMIT $1 OFFSET $2;

-- name: ListDeliveryOrdersByDate :many
-- 日付別オーダー一覧
SELECT 
    ord.*,
    c.name as customer_name,
    e.last_name || ' ' || e.first_name as driver_name,
    v.vehicle_number
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
LEFT JOIN employees e ON ord.driver_id = e.id
LEFT JOIN vehicles v ON ord.vehicle_id = v.id
WHERE ord.operation_date = $1
AND ord.deleted_at IS NULL
ORDER BY ord.departure_time, ord.order_number;

-- name: ListDeliveryOrdersByCustomer :many
-- 取引先別オーダー一覧
SELECT 
    ord.*,
    e.last_name || ' ' || e.first_name as driver_name,
    v.vehicle_number
FROM delivery_orders ord
LEFT JOIN employees e ON ord.driver_id = e.id
LEFT JOIN vehicles v ON ord.vehicle_id = v.id
WHERE ord.customer_id = $1
AND ord.deleted_at IS NULL
ORDER BY ord.operation_date DESC
LIMIT $2 OFFSET $3;

-- name: SearchDeliveryOrders :many
-- オーダーを検索
SELECT 
    ord.*,
    c.name as customer_name,
    c.customer_code,
    e.last_name || ' ' || e.first_name as driver_name,
    v.vehicle_number
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
LEFT JOIN employees e ON ord.driver_id = e.id
LEFT JOIN vehicles v ON ord.vehicle_id = v.id
WHERE ord.deleted_at IS NULL
AND ($1::text IS NULL OR ord.order_number ILIKE '%' || $1 || '%')
AND ($2::integer IS NULL OR ord.customer_id = $2)
AND ($3::date IS NULL OR ord.operation_date >= $3)
AND ($4::date IS NULL OR ord.operation_date <= $4)
AND ($5::text IS NULL OR ord.order_status = $5)
AND ($6::text IS NULL OR ord.service_type = $6)
AND ($7::boolean IS NULL OR ord.billing_confirmed = $7)
ORDER BY ord.operation_date DESC, ord.order_number DESC
LIMIT $8 OFFSET $9;

-- name: UpdateDeliveryOrder :exec
-- オーダー情報を更新
UPDATE delivery_orders
SET
    customer_id = COALESCE(sqlc.narg('customer_id'), customer_id),
    service_type = COALESCE(sqlc.narg('service_type'), service_type),
    service_type_id = COALESCE(sqlc.narg('service_type_id'), service_type_id),
    operation_date = COALESCE(sqlc.narg('operation_date'), operation_date),
    delivery_date = COALESCE(sqlc.narg('delivery_date'), delivery_date),
    driver_id = COALESCE(sqlc.narg('driver_id'), driver_id),
    driver_companion_id = COALESCE(sqlc.narg('driver_companion_id'), driver_companion_id),
    vehicle_id = COALESCE(sqlc.narg('vehicle_id'), vehicle_id),
    departure_time = COALESCE(sqlc.narg('departure_time'), departure_time),
    arrival_time = COALESCE(sqlc.narg('arrival_time'), arrival_time),
    has_highway_fee = COALESCE(sqlc.narg('has_highway_fee'), has_highway_fee),
    has_extra_charge = COALESCE(sqlc.narg('has_extra_charge'), has_extra_charge),
    is_tax_exempt = COALESCE(sqlc.narg('is_tax_exempt'), is_tax_exempt),
    order_status = COALESCE(sqlc.narg('order_status'), order_status),
    notes = COALESCE(sqlc.narg('notes'), notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: UpdateDeliveryOrderStatus :exec
-- オーダーステータスを更新
UPDATE delivery_orders
SET
    order_status = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: ConfirmBilling :exec
-- 経理確定処理
UPDATE delivery_orders
SET
    billing_confirmed = true,
    billing_confirmed_by = $2,
    billing_confirmed_at = CURRENT_TIMESTAMP,
    subtotal_amount = $3,
    tax_amount = $4,
    total_amount = $5,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: SetRevenueDate :exec
-- 売上計上日を設定
UPDATE delivery_orders
SET
    revenue_date = $2,
    revenue_month = TO_CHAR($2, 'YYYY-MM'),
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: LockRevenue :exec
-- 売上を確定（締め処理）
UPDATE delivery_orders
SET
    revenue_locked = true,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: UnlockRevenue :exec
-- 売上確定を解除
UPDATE delivery_orders
SET
    revenue_locked = false,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: IssueInvoice :exec
-- 請求書発行
UPDATE delivery_orders
SET
    invoice_issued = true,
    invoice_number = $2,
    invoice_date = $3,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: DeleteDeliveryOrder :exec
-- オーダーを論理削除
UPDATE delivery_orders
SET
    deleted_at = CURRENT_TIMESTAMP,
    order_status = 'キャンセル'
WHERE id = $1;

-- name: GetOrdersForBilling :many
-- 経理確定待ちのオーダー一覧
SELECT 
    ord.*,
    c.name as customer_name,
    c.customer_code
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
WHERE ord.billing_confirmed = false
AND ord.order_status = '完了'
AND ord.deleted_at IS NULL
ORDER BY ord.operation_date;

-- name: GetOrdersForInvoice :many
-- 請求書発行対象オーダー一覧（取引先・期間指定）
SELECT 
    ord.*,
    c.closing_day,
    c.payment_due_day
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
WHERE ord.customer_id = $1
AND ord.billing_confirmed = true
AND ord.invoice_issued = false
AND ord.revenue_date BETWEEN $2 AND $3
AND ord.deleted_at IS NULL
ORDER BY ord.revenue_date;

-- name: GetRevenueSummaryByMonth :many
-- 月別売上集計
SELECT 
    revenue_month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    SUM(subtotal_amount) as total_subtotal,
    SUM(tax_amount) as total_tax
FROM delivery_orders
WHERE revenue_month IS NOT NULL
AND billing_confirmed = true
AND deleted_at IS NULL
AND ($1::text IS NULL OR revenue_month >= $1)
AND ($2::text IS NULL OR revenue_month <= $2)
GROUP BY revenue_month
ORDER BY revenue_month DESC;

-- name: GetRevenueSummaryByCustomer :many
-- 取引先別売上集計（期間指定）
SELECT 
    ord.customer_id,
    c.name as customer_name,
    c.customer_code,
    COUNT(*) as order_count,
    SUM(ord.total_amount) as total_revenue,
    SUM(ord.subtotal_amount) as total_subtotal,
    SUM(ord.tax_amount) as total_tax
FROM delivery_orders ord
JOIN customers c ON ord.customer_id = c.id
WHERE ord.billing_confirmed = true
AND ord.deleted_at IS NULL
AND ($1::date IS NULL OR ord.revenue_date >= $1)
AND ($2::date IS NULL OR ord.revenue_date <= $2)
GROUP BY ord.customer_id, c.name, c.customer_code
ORDER BY total_revenue DESC;

-- name: CountDeliveryOrders :one
-- オーダー数をカウント
SELECT COUNT(*) as count
FROM delivery_orders
WHERE deleted_at IS NULL
AND ($1::text IS NULL OR order_status = $1);

-- ==============================
-- 配送明細管理
-- ==============================

-- name: CreateDeliveryDetail :one
-- 配送明細を登録
INSERT INTO delivery_details (
    order_id,
    line_number,
    route_from,
    route_to,
    driver_id,
    driver_companion_id,
    vehicle_id,
    trailer_id,
    departure_time,
    arrival_time,
    service_item_id,
    item_name,
    quantity,
    unit,
    unit_price,
    amount,
    tax_category,
    detail_notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
) RETURNING *;

-- name: GetDeliveryDetail :one
-- 配送明細を取得
SELECT *
FROM delivery_details
WHERE id = $1;

-- name: ListDeliveryDetails :many
-- オーダーの明細一覧
SELECT 
    dd.*,
    e1.last_name || ' ' || e1.first_name as driver_name,
    e2.last_name || ' ' || e2.first_name as companion_name,
    v1.vehicle_number,
    v2.vehicle_number as trailer_number
FROM delivery_details dd
LEFT JOIN employees e1 ON dd.driver_id = e1.id
LEFT JOIN employees e2 ON dd.driver_companion_id = e2.id
LEFT JOIN vehicles v1 ON dd.vehicle_id = v1.id
LEFT JOIN vehicles v2 ON dd.trailer_id = v2.id
WHERE dd.order_id = $1
ORDER BY dd.line_number;

-- name: UpdateDeliveryDetail :exec
-- 配送明細を更新
UPDATE delivery_details
SET
    route_from = COALESCE(sqlc.narg('route_from'), route_from),
    route_to = COALESCE(sqlc.narg('route_to'), route_to),
    driver_id = COALESCE(sqlc.narg('driver_id'), driver_id),
    driver_companion_id = COALESCE(sqlc.narg('driver_companion_id'), driver_companion_id),
    vehicle_id = COALESCE(sqlc.narg('vehicle_id'), vehicle_id),
    trailer_id = COALESCE(sqlc.narg('trailer_id'), trailer_id),
    departure_time = COALESCE(sqlc.narg('departure_time'), departure_time),
    arrival_time = COALESCE(sqlc.narg('arrival_time'), arrival_time),
    item_name = COALESCE(sqlc.narg('item_name'), item_name),
    quantity = COALESCE(sqlc.narg('quantity'), quantity),
    unit = COALESCE(sqlc.narg('unit'), unit),
    unit_price = COALESCE(sqlc.narg('unit_price'), unit_price),
    amount = COALESCE(sqlc.narg('amount'), amount),
    tax_category = COALESCE(sqlc.narg('tax_category'), tax_category),
    detail_notes = COALESCE(sqlc.narg('detail_notes'), detail_notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteDeliveryDetail :exec
-- 配送明細を削除
DELETE FROM delivery_details
WHERE id = $1;

-- name: GetOrderTotalAmount :one
-- オーダーの合計金額を計算
SELECT 
    COALESCE(SUM(dd.amount), 0) + COALESCE(SUM(dc.amount), 0) as total
FROM delivery_details dd
LEFT JOIN delivery_charges dc ON dd.order_id = dc.order_id
WHERE dd.order_id = $1;

-- ==============================
-- 追加料金管理
-- ==============================

-- name: CreateDeliveryCharge :one
-- 追加料金を登録
INSERT INTO delivery_charges (
    order_id,
    detail_id,
    charge_type,
    charge_name,
    amount,
    tax_category,
    notes,
    receipt_image_url
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: ListDeliveryCharges :many
-- オーダーの追加料金一覧
SELECT *
FROM delivery_charges
WHERE order_id = $1
ORDER BY id;

-- name: UpdateDeliveryCharge :exec
-- 追加料金を更新
UPDATE delivery_charges
SET
    charge_type = COALESCE(sqlc.narg('charge_type'), charge_type),
    charge_name = COALESCE(sqlc.narg('charge_name'), charge_name),
    amount = COALESCE(sqlc.narg('amount'), amount),
    tax_category = COALESCE(sqlc.narg('tax_category'), tax_category),
    notes = COALESCE(sqlc.narg('notes'), notes),
    receipt_image_url = COALESCE(sqlc.narg('receipt_image_url'), receipt_image_url),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: DeleteDeliveryCharge :exec
-- 追加料金を削除
DELETE FROM delivery_charges
WHERE id = $1;

-- ==============================
-- 配車履歴管理
-- ==============================

-- name: CreateDeliveryAssignment :one
-- 配車履歴を記録
INSERT INTO delivery_assignments (
    order_id,
    detail_id,
    driver_id,
    driver_companion_id,
    vehicle_id,
    assigned_at,
    started_at,
    completed_at,
    cancelled_at,
    assignment_status,
    cancellation_reason,
    notes,
    assigned_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
) RETURNING *;

-- name: ListDeliveryAssignments :many
-- オーダーの配車履歴一覧
SELECT 
    da.*,
    e1.last_name || ' ' || e1.first_name as driver_name,
    e2.last_name || ' ' || e2.first_name as companion_name,
    v.vehicle_number,
    e3.last_name || ' ' || e3.first_name as assigned_by_name
FROM delivery_assignments da
LEFT JOIN employees e1 ON da.driver_id = e1.id
LEFT JOIN employees e2 ON da.driver_companion_id = e2.id
LEFT JOIN vehicles v ON da.vehicle_id = v.id
LEFT JOIN employees e3 ON da.assigned_by = e3.id
WHERE da.order_id = $1
ORDER BY da.assigned_at DESC;

-- name: UpdateDeliveryAssignmentStatus :exec
-- 配車ステータスを更新
UPDATE delivery_assignments
SET
    assignment_status = sqlc.arg('assignment_status'),
    started_at = COALESCE(sqlc.narg('started_at'), started_at),
    completed_at = COALESCE(sqlc.narg('completed_at'), completed_at),
    cancelled_at = COALESCE(sqlc.narg('cancelled_at'), cancelled_at),
    cancellation_reason = COALESCE(sqlc.narg('cancellation_reason'), cancellation_reason),
    notes = COALESCE(sqlc.narg('notes'), notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');
