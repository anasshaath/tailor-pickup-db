-- Run once in the fresh assignment database.
WITH customer AS (
    INSERT INTO public.customers (full_name, phone)
    VALUES ('Deniz Kaya', 'DEMO-001')
    RETURNING id
), receipt AS (
    INSERT INTO public.intake_receipts (customer_id)
    SELECT id FROM customer
    RETURNING receipt_number
)
INSERT INTO public.garment_jobs (receipt_number, garment_type, alteration, status)
SELECT receipt.receipt_number, job.garment_type, job.alteration, job.status
FROM receipt
CROSS JOIN (VALUES
    ('Trousers', 'Shorten hems', 'ready'),
    ('Jacket', 'Replace zipper', 'in_progress'),
    ('Shirt', 'Shorten sleeves', 'received')
) AS job(garment_type, alteration, status)
RETURNING *;
