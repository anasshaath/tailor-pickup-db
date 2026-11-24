-- Run the blocks individually in pgAdmin to see each result grid.
-- CRUD uses a temporary demonstration row inside a transaction.
BEGIN;

-- CREATE: capture the generated job ID for the subsequent operations.
CREATE TEMP TABLE crud_demo_job ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO public.garment_jobs (receipt_number, garment_type, alteration)
    SELECT receipt_number, 'Coat', 'Replace button'
    FROM public.intake_receipts
    ORDER BY receipt_number
    LIMIT 1
    RETURNING id
)
SELECT id FROM inserted;

-- READ: one Coat row with status received.
SELECT * FROM public.garment_jobs
WHERE id = (SELECT id FROM crud_demo_job);

-- UPDATE: the same Coat row now has status ready.
UPDATE public.garment_jobs
SET status = 'ready'
WHERE id = (SELECT id FROM crud_demo_job)
RETURNING id, garment_type, status;

-- DELETE: only the demonstration row.
DELETE FROM public.garment_jobs
WHERE id = (SELECT id FROM crud_demo_job)
RETURNING id, garment_type;

SELECT COUNT(*) AS remaining_demo_rows
FROM public.garment_jobs
WHERE id = (SELECT id FROM crud_demo_job);

COMMIT;

-- JOIN: list the garments that Deniz can pick up.
SELECT c.full_name, r.receipt_number, j.garment_type, j.alteration
FROM public.customers AS c
JOIN public.intake_receipts AS r ON r.customer_id = c.id
JOIN public.garment_jobs AS j ON j.receipt_number = r.receipt_number
WHERE c.phone = 'DEMO-001' AND j.status = 'ready'
ORDER BY r.receipt_number, j.id;

-- GROUP BY: count the jobs in each status.
SELECT status, COUNT(*) AS job_count
FROM public.garment_jobs
GROUP BY status
ORDER BY status;

-- Pagination: two jobs per page with a unique ordering key.
SELECT id, garment_type FROM public.garment_jobs ORDER BY id LIMIT 2 OFFSET 0;
SELECT id, garment_type FROM public.garment_jobs ORDER BY id LIMIT 2 OFFSET 2;
