-- Benchmark in a temporary copy to preserve the assignment data.
BEGIN;
CREATE TEMP TABLE benchmark_jobs ON COMMIT DROP AS
SELECT receipt_number, garment_type, alteration, status
FROM public.garment_jobs
WITH NO DATA;

INSERT INTO benchmark_jobs (receipt_number, garment_type, alteration, status)
SELECT (n - 1) / 3 + 1, 'Trousers', 'Shorten hems', 'ready'
FROM generate_series(1, 60000) AS sample(n);

ANALYZE benchmark_jobs;

-- Baseline plan. Run this statement separately to display the plan in pgAdmin.
EXPLAIN (ANALYZE, BUFFERS)
SELECT garment_type, alteration, status
FROM benchmark_jobs
WHERE receipt_number = 12000;

CREATE INDEX benchmark_jobs_receipt_idx ON benchmark_jobs (receipt_number);
ANALYZE benchmark_jobs;

-- Same data and predicate, now with the index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT garment_type, alteration, status
FROM benchmark_jobs
WHERE receipt_number = 12000;

ROLLBACK;
