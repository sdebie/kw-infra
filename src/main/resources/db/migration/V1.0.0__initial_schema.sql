-- V1.0.0__create_products_table.sql
CREATE TABLE test (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1. Categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES categories(id)
);

-- 2. Products (The Parent)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    product_type VARCHAR(20) DEFAULT 'SIMPLE', -- SIMPLE or VARIABLE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Product Variants (Handles Color/Size via JSONB)
CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    attributes JSONB, -- Stores {"color": "Red", "size": "XL"}
    weight_kg DECIMAL(5,2)
);

-- 4. Product Gallery (Multiple Images)
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE
);

-- 5. Customer Profiles & Base Address
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    address_line_1 TEXT,
    address_line_2 TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Quotations / Orders
CREATE TABLE quotations (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    total_amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Quotation Items (Line Items)
CREATE TABLE quotation_items (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER REFERENCES quotations(id) ON DELETE CASCADE,
    variant_id INTEGER REFERENCES product_variants(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL
);

CREATE TABLE payment_gateway_logs (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER REFERENCES quotations(id) ON DELETE CASCADE,

    -- Gateway Identification
    gateway_name VARCHAR(50) NOT NULL, -- 'PAYFAST', 'IKHOKHA', 'FASTPAY'

    -- Mapping IDs
    external_reference VARCHAR(100), -- The ID from the gateway (e.g., pf_payment_id)
    internal_reference VARCHAR(100), -- Your unique ID (e.g., m_payment_id or UUID)

    -- Universal Financial Data
    amount_gross DECIMAL(12, 2) NOT NULL,
    amount_fee DECIMAL(12, 2) DEFAULT 0,
    amount_net DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'ZAR',

    -- Status and Raw Data
    status VARCHAR(50) NOT NULL, -- 'INITIATED', 'SUCCESS', 'FAILED', 'REFUNDED'
    raw_response JSONB,          -- Stores the unique JSON body from EACH gateway

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
