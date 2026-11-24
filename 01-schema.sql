BEGIN;

CREATE TABLE public.customers (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL
);

CREATE TABLE public.intake_receipts (
    receipt_number INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES public.customers (id) ON DELETE RESTRICT,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.garment_jobs (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    receipt_number INTEGER NOT NULL
        REFERENCES public.intake_receipts (receipt_number) ON DELETE RESTRICT,
    garment_type TEXT NOT NULL,
    alteration TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'received',
    CONSTRAINT valid_garment_status
        CHECK (status IN ('received', 'in_progress', 'ready', 'picked_up'))
);

COMMIT;
