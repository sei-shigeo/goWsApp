-- ==============================
-- 請求書管理クエリ
-- ==============================

-- name: CreateInvoice :one
-- 請求書を作成
INSERT INTO invoices (
    invoice_number,
    customer_id,
    billing_period_from,
    billing_period_to,
    closing_date,
    subtotal_amount,
    tax_amount,
    total_amount,
    invoice_date,
    issued_by,
    payment_due_date,
    payment_status,
    notes
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
) RETURNING *;

-- name: GetInvoice :one
-- 請求書を取得
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code,
    e.last_name || ' ' || e.first_name as issued_by_name
FROM invoices i
JOIN customers c ON i.customer_id = c.id
LEFT JOIN employees e ON i.issued_by = e.id
WHERE i.id = $1
AND i.deleted_at IS NULL;

-- name: GetInvoiceByNumber :one
-- 請求書番号で取得
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.invoice_number = $1
AND i.deleted_at IS NULL;

-- name: ListInvoices :many
-- 請求書一覧
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.deleted_at IS NULL
ORDER BY i.invoice_date DESC, i.invoice_number DESC
LIMIT $1 OFFSET $2;

-- name: ListInvoicesByCustomer :many
-- 取引先別の請求書一覧
SELECT *
FROM invoices
WHERE customer_id = $1
AND deleted_at IS NULL
ORDER BY invoice_date DESC
LIMIT $2 OFFSET $3;

-- name: SearchInvoices :many
-- 請求書を検索
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.deleted_at IS NULL
AND ($1::text IS NULL OR i.invoice_number ILIKE '%' || $1 || '%')
AND ($2::integer IS NULL OR i.customer_id = $2)
AND ($3::date IS NULL OR i.invoice_date >= $3)
AND ($4::date IS NULL OR i.invoice_date <= $4)
AND ($5::text IS NULL OR i.payment_status = $5)
ORDER BY i.invoice_date DESC, i.invoice_number DESC
LIMIT $6 OFFSET $7;

-- name: UpdateInvoice :exec
-- 請求書を更新
UPDATE invoices
SET
    billing_period_from = COALESCE(sqlc.narg('billing_period_from'), billing_period_from),
    billing_period_to = COALESCE(sqlc.narg('billing_period_to'), billing_period_to),
    closing_date = COALESCE(sqlc.narg('closing_date'), closing_date),
    subtotal_amount = COALESCE(sqlc.narg('subtotal_amount'), subtotal_amount),
    tax_amount = COALESCE(sqlc.narg('tax_amount'), tax_amount),
    total_amount = COALESCE(sqlc.narg('total_amount'), total_amount),
    invoice_date = COALESCE(sqlc.narg('invoice_date'), invoice_date),
    payment_due_date = COALESCE(sqlc.narg('payment_due_date'), payment_due_date),
    payment_status = COALESCE(sqlc.narg('payment_status'), payment_status),
    notes = COALESCE(sqlc.narg('notes'), notes),
    updated_at = CURRENT_TIMESTAMP
WHERE id = sqlc.arg('id');

-- name: IssueInvoiceRecord :exec
-- 請求書を発行
UPDATE invoices
SET
    issued_at = CURRENT_TIMESTAMP,
    invoice_date = COALESCE(invoice_date, CURRENT_DATE),
    payment_status = '発行済',
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: RecordPayment :exec
-- 入金を記録
UPDATE invoices
SET
    payment_status = '入金済',
    payment_date = $2,
    payment_amount = $3,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $1;

-- name: DeleteInvoice :exec
-- 請求書を論理削除
UPDATE invoices
SET
    deleted_at = CURRENT_TIMESTAMP,
    payment_status = 'キャンセル'
WHERE id = $1;

-- name: AddOrderToInvoice :exec
-- オーダーを請求書に追加
INSERT INTO invoice_orders (
    invoice_id,
    order_id
) VALUES (
    $1, $2
);

-- name: RemoveOrderFromInvoice :exec
-- オーダーを請求書から削除
DELETE FROM invoice_orders
WHERE invoice_id = $1 AND order_id = $2;

-- name: GetInvoiceOrders :many
-- 請求書に含まれるオーダー一覧
SELECT 
    ord.*,
    c.name as customer_name
FROM invoice_orders io
JOIN delivery_orders ord ON io.order_id = ord.id
JOIN customers c ON ord.customer_id = c.id
WHERE io.invoice_id = $1
ORDER BY ord.operation_date, ord.order_number;

-- name: GetOrderInvoice :one
-- オーダーが含まれる請求書を取得
SELECT 
    i.*,
    c.name as customer_name
FROM invoice_orders io
JOIN invoices i ON io.invoice_id = i.id
JOIN customers c ON i.customer_id = c.id
WHERE io.order_id = $1
AND i.deleted_at IS NULL;

-- name: CountInvoices :one
-- 請求書数をカウント
SELECT COUNT(*) as count
FROM invoices
WHERE deleted_at IS NULL
AND ($1::text IS NULL OR payment_status = $1);

-- name: GetUnpaidInvoices :many
-- 未払い請求書一覧
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.payment_status IN ('発行済', '延滞')
AND i.deleted_at IS NULL
ORDER BY i.payment_due_date;

-- name: GetOverdueInvoices :many
-- 延滞請求書一覧
SELECT 
    i.*,
    c.name as customer_name,
    c.customer_code,
    CURRENT_DATE - i.payment_due_date as days_overdue
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.payment_status = '発行済'
AND i.payment_due_date < CURRENT_DATE
AND i.deleted_at IS NULL
ORDER BY i.payment_due_date;

-- name: GetInvoiceSummaryByMonth :many
-- 月別請求書集計
SELECT 
    TO_CHAR(invoice_date, 'YYYY-MM') as invoice_month,
    COUNT(*) as invoice_count,
    SUM(total_amount) as total_billed,
    SUM(CASE WHEN payment_status = '入金済' THEN payment_amount ELSE 0 END) as total_paid,
    SUM(CASE WHEN payment_status IN ('発行済', '延滞') THEN total_amount ELSE 0 END) as total_unpaid
FROM invoices
WHERE invoice_date IS NOT NULL
AND deleted_at IS NULL
AND ($1::date IS NULL OR invoice_date >= $1)
AND ($2::date IS NULL OR invoice_date <= $2)
GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
ORDER BY invoice_month DESC;
