-- Run once after 03-queries.sql in the fresh assignment database.
-- COMMIT: keep both the new customer and the linked receipt.
BEGIN;
WITH customer AS (
    INSERT INTO public.customers (full_name, phone)
    VALUES ('Commit Demo', 'TX-COMMIT')
    RETURNING id
)
INSERT INTO public.intake_receipts (customer_id)
SELECT id FROM customer;
COMMIT;

-- ROLLBACK: perform the same two operations, then undo both.
BEGIN;
WITH customer AS (
    INSERT INTO public.customers (full_name, phone)
    VALUES ('Rollback Demo', 'TX-ROLLBACK')
    RETURNING id
)
INSERT INTO public.intake_receipts (customer_id)
SELECT id FROM customer;
ROLLBACK;

-- Expected: TX-COMMIT has 1 customer and 1 receipt. TX-ROLLBACK has 0 and 0.
SELECT demo.phone, COUNT(DISTINCT c.id) AS customer_count,
       COUNT(r.receipt_number) AS receipt_count
FROM (VALUES ('TX-COMMIT'), ('TX-ROLLBACK')) AS demo(phone)
LEFT JOIN public.customers AS c ON c.phone = demo.phone
LEFT JOIN public.intake_receipts AS r ON r.customer_id = c.id
GROUP BY demo.phone
ORDER BY demo.phone;
