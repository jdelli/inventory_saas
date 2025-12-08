-- MERGED SCHEMA from database_schema.sql and database_schema_sales.sql
-- Run this entire file to set up the complete database from scratch.

-- ==========================================
-- PART 1: Core Tables (Employees, Products)
-- ==========================================

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'terminated')),
    manager_id UUID REFERENCES employees(id),
    termination_date DATE,
    address TEXT,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department);
CREATE INDEX IF NOT EXISTS idx_employees_status ON employees(status);
CREATE INDEX IF NOT EXISTS idx_employees_hire_date ON employees(hire_date);
CREATE INDEX IF NOT EXISTS idx_employees_manager_id ON employees(manager_id);
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_employee_id ON employees(employee_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_employees_updated_at 
    BEFORE UPDATE ON employees 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- Allow authenticated users to read all employees
CREATE POLICY "Allow authenticated users to read employees" ON employees
    FOR SELECT USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert employees
CREATE POLICY "Allow authenticated users to insert employees" ON employees
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update employees
CREATE POLICY "Allow authenticated users to update employees" ON employees
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Allow authenticated users to delete employees
CREATE POLICY "Allow authenticated users to delete employees" ON employees
    FOR DELETE USING (auth.role() = 'authenticated');

-- Insert sample data (optional)
INSERT INTO employees (
    first_name, 
    last_name, 
    email, 
    phone, 
    department, 
    position, 
    employee_id, 
    hire_date, 
    salary, 
    status
) VALUES 
    ('John', 'Doe', 'john.doe@company.com', '+1234567890', 'Engineering', 'Software Engineer', 'EMP001', '2023-01-15', 75000.00, 'active'),
    ('Jane', 'Smith', 'jane.smith@company.com', '+1234567891', 'Marketing', 'Marketing Manager', 'EMP002', '2022-11-20', 85000.00, 'active'),
    ('Mike', 'Johnson', 'mike.johnson@company.com', '+1234567892', 'Sales', 'Sales Representative', 'EMP003', '2023-03-10', 65000.00, 'active'),
    ('Sarah', 'Williams', 'sarah.williams@company.com', '+1234567893', 'HR', 'HR Specialist', 'EMP004', '2022-08-05', 70000.00, 'active'),
    ('David', 'Brown', 'david.brown@company.com', '+1234567894', 'Engineering', 'Senior Engineer', 'EMP005', '2021-06-15', 95000.00, 'active'),
    ('Lisa', 'Davis', 'lisa.davis@company.com', '+1234567895', 'Finance', 'Accountant', 'EMP006', '2023-02-28', 68000.00, 'active'),
    ('Robert', 'Wilson', 'robert.wilson@company.com', '+1234567896', 'Operations', 'Operations Manager', 'EMP007', '2022-04-12', 90000.00, 'active'),
    ('Emily', 'Taylor', 'emily.taylor@company.com', '+1234567897', 'Engineering', 'QA Engineer', 'EMP008', '2023-05-20', 72000.00, 'active'),
    ('Michael', 'Anderson', 'michael.anderson@company.com', '+1234567898', 'Sales', 'Sales Manager', 'EMP009', '2021-12-01', 88000.00, 'active'),
    ('Jessica', 'Martinez', 'jessica.martinez@company.com', '+1234567899', 'Marketing', 'Content Creator', 'EMP010', '2023-07-08', 62000.00, 'active')
ON CONFLICT (email) DO NOTHING;

-- Update manager relationships
UPDATE employees SET manager_id = (SELECT id FROM employees WHERE employee_id = 'EMP002') WHERE employee_id = 'EMP001';
UPDATE employees SET manager_id = (SELECT id FROM employees WHERE employee_id = 'EMP005') WHERE employee_id = 'EMP008';
UPDATE employees SET manager_id = (SELECT id FROM employees WHERE employee_id = 'EMP009') WHERE employee_id = 'EMP003';
 
 -- CRUD functions for employees
 create or replace function employees_create(
   p_first_name text,
   p_last_name text,
   p_email text,
   p_department text,
   p_position text,
   p_employee_id text,
   p_hire_date date,
   p_salary numeric,
   p_phone text default null,
   p_status text default 'active',
   p_manager_id uuid default null,
   p_address text default null,
   p_emergency_contact text default null,
   p_emergency_phone text default null
 )
 returns employees
 language plpgsql
 as $$
 declare
   v_employee employees;
 begin
   insert into employees (
     first_name, last_name, email, phone, department, position, employee_id,
     hire_date, salary, status, manager_id, address, emergency_contact, emergency_phone
   ) values (
     p_first_name, p_last_name, p_email, p_phone, p_department, p_position, p_employee_id,
     p_hire_date, p_salary, coalesce(p_status, 'active'), p_manager_id, p_address, p_emergency_contact, p_emergency_phone
   )
   returning * into v_employee;
 
   return v_employee;
 end;
 $$;
 
 create or replace function employees_get(p_id uuid)
 returns employees
 language sql
 stable
 as $$
   select *
   from employees
   where id = p_id;
 $$;
 
 create or replace function employees_list(
   p_search text default null,
   p_department text default null,
   p_status text default null,
   p_limit int default 50,
   p_offset int default 0
 )
 returns setof employees
 language plpgsql
 stable
 as $$
 begin
   return query
   select *
   from employees
   where (p_department is null or department = p_department)
     and (p_status is null or status = p_status)
     and (
       p_search is null or
       first_name ilike '%' || p_search || '%' or
       last_name ilike '%' || p_search || '%' or
       email ilike '%' || p_search || '%' or
       employee_id ilike '%' || p_search || '%'
     )
   order by created_at desc
   limit greatest(p_limit, 0)
   offset greatest(p_offset, 0);
 end;
 $$;
 
 create or replace function employees_update(p_id uuid, p_patch jsonb)
 returns employees
 language plpgsql
 as $$
 declare
   v_employee employees;
 begin
   update employees set
     first_name = coalesce(p_patch->>'first_name', first_name),
     last_name = coalesce(p_patch->>'last_name', last_name),
     email = coalesce(p_patch->>'email', email),
     phone = coalesce(p_patch->>'phone', phone),
     department = coalesce(p_patch->>'department', department),
     position = coalesce(p_patch->>'position', position),
     employee_id = coalesce(p_patch->>'employee_id', employee_id),
     hire_date = coalesce((p_patch->>'hire_date')::date, hire_date),
     salary = coalesce((p_patch->>'salary')::numeric, salary),
     status = coalesce(p_patch->>'status', status),
     manager_id = coalesce((p_patch->>'manager_id')::uuid, manager_id),
     termination_date = coalesce((p_patch->>'termination_date')::date, termination_date),
     address = coalesce(p_patch->>'address', address),
     emergency_contact = coalesce(p_patch->>'emergency_contact', emergency_contact),
     emergency_phone = coalesce(p_patch->>'emergency_phone', emergency_phone)
   where id = p_id
   returning * into v_employee;
 
   return v_employee;
 end;
 $$;
 
 create or replace function employees_delete(p_id uuid)
 returns boolean
 language plpgsql
 as $$
 begin
   delete from employees where id = p_id;
   return found;
 end;
 $$;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    current_stock INTEGER NOT NULL DEFAULT 0,
    min_stock_level INTEGER NOT NULL DEFAULT 0,
    max_stock_level INTEGER,
    unit VARCHAR(20) NOT NULL DEFAULT 'pcs',
    warehouse VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    supplier_id VARCHAR(100) NOT NULL,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for products table
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_supplier_id ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_warehouse ON products(warehouse);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_current_stock ON products(current_stock);

-- Create trigger to automatically update updated_at for products
CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security for products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies for products RLS
CREATE POLICY "Allow authenticated users to read products" ON products
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to insert products" ON products
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update products" ON products
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to delete products" ON products
    FOR DELETE USING (auth.role() = 'authenticated');

-- Insert sample products data
INSERT INTO products (
    name, description, sku, barcode, category, brand, cost_price, selling_price,
    current_stock, min_stock_level, max_stock_level, unit, warehouse, location,
    supplier_id, image_url, is_active
) VALUES 
    ('iPhone 15 Pro', 'Latest iPhone with advanced features, A17 Pro chip, and titanium design', 'IPH15PRO-256-BLK', '1234567890123', 'Electronics', 'Apple', 899.99, 1199.99, 15, 10, 50, 'pcs', 'Main Warehouse', 'A1-B2-C3', 'supp_001', '', true),
    ('Samsung Galaxy S24', 'Premium Android smartphone with AI features', 'SAMS24-128-BLK', '1234567890124', 'Electronics', 'Samsung', 699.99, 899.99, 8, 10, 40, 'pcs', 'Main Warehouse', 'A1-B2-C4', 'supp_002', '', true),
    ('MacBook Pro 14"', 'Professional laptop for developers with M3 chip', 'MBP14-512-SLV', '1234567890125', 'Computers', 'Apple', 1899.99, 2499.99, 5, 5, 20, 'pcs', 'Main Warehouse', 'A2-B1-C1', 'supp_001', '', true),
    ('Dell XPS 13', 'Ultrabook for business users with 13th gen Intel', 'DLLXPS13-256-BLK', '1234567890126', 'Computers', 'Dell', 999.99, 1299.99, 0, 3, 15, 'pcs', 'Main Warehouse', 'A2-B1-C2', 'supp_003', '', true),
    ('AirPods Pro', 'Wireless earbuds with active noise cancellation', 'AIRPODS-PRO-WHT', '1234567890127', 'Audio', 'Apple', 199.99, 249.99, 25, 20, 100, 'pcs', 'Main Warehouse', 'A3-B1-C1', 'supp_001', '', true)
ON CONFLICT (sku) DO NOTHING;

-- CRUD functions for products
CREATE OR REPLACE FUNCTION products_create(
    p_name TEXT,
    p_sku TEXT,
    p_category TEXT,
    p_brand TEXT,
    p_cost_price NUMERIC,
    p_selling_price NUMERIC,
    p_warehouse TEXT,
    p_supplier_id TEXT,
    p_description TEXT DEFAULT NULL,
    p_barcode TEXT DEFAULT NULL,
    p_current_stock INTEGER DEFAULT 0,
    p_min_stock_level INTEGER DEFAULT 0,
    p_max_stock_level INTEGER DEFAULT NULL,
    p_unit TEXT DEFAULT 'pcs',
    p_location TEXT DEFAULT NULL,
    p_image_url TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS products
LANGUAGE plpgsql
AS $$
DECLARE
    v_product products;
BEGIN
    INSERT INTO products (
        name, description, sku, barcode, category, brand, cost_price, selling_price,
        current_stock, min_stock_level, max_stock_level, unit, warehouse, location,
        supplier_id, image_url, is_active
    ) VALUES (
        p_name, p_description, p_sku, p_barcode, p_category, p_brand, p_cost_price, p_selling_price,
        p_current_stock, p_min_stock_level, p_max_stock_level, p_unit, p_warehouse, p_location,
        p_supplier_id, p_image_url, p_is_active
    )
    RETURNING * INTO v_product;
    
    RETURN v_product;
END;
$$;

CREATE OR REPLACE FUNCTION products_get(p_id UUID)
RETURNS products
LANGUAGE sql
STABLE
AS $$
    SELECT *
    FROM products
    WHERE id = p_id;
$$;

CREATE OR REPLACE FUNCTION products_list(
    p_search TEXT DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_brand TEXT DEFAULT NULL,
    p_supplier_id TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS SETOF products
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM products
    WHERE (p_category IS NULL OR category = p_category)
        AND (p_brand IS NULL OR brand = p_brand)
        AND (p_supplier_id IS NULL OR supplier_id = p_supplier_id)
        AND (p_is_active IS NULL OR is_active = p_is_active)
        AND (
            p_search IS NULL OR
            name ILIKE '%' || p_search || '%' OR
            sku ILIKE '%' || p_search || '%' OR
            barcode ILIKE '%' || p_search || '%' OR
            description ILIKE '%' || p_search || '%'
        )
    ORDER BY created_at DESC
    LIMIT GREATEST(p_limit, 0)
    OFFSET GREATEST(p_offset, 0);
END;
$$;

CREATE OR REPLACE FUNCTION products_update(p_id UUID, p_patch JSONB)
RETURNS products
LANGUAGE plpgsql
AS $$
DECLARE
    v_product products;
BEGIN
    UPDATE products SET
        name = COALESCE(p_patch->>'name', name),
        description = COALESCE(p_patch->>'description', description),
        sku = COALESCE(p_patch->>'sku', sku),
        barcode = COALESCE(p_patch->>'barcode', barcode),
        category = COALESCE(p_patch->>'category', category),
        brand = COALESCE(p_patch->>'brand', brand),
        cost_price = COALESCE((p_patch->>'cost_price')::NUMERIC, cost_price),
        selling_price = COALESCE((p_patch->>'selling_price')::NUMERIC, selling_price),
        current_stock = COALESCE((p_patch->>'current_stock')::INTEGER, current_stock),
        min_stock_level = COALESCE((p_patch->>'min_stock_level')::INTEGER, min_stock_level),
        max_stock_level = COALESCE((p_patch->>'max_stock_level')::INTEGER, max_stock_level),
        unit = COALESCE(p_patch->>'unit', unit),
        warehouse = COALESCE(p_patch->>'warehouse', warehouse),
        location = COALESCE(p_patch->>'location', location),
        supplier_id = COALESCE(p_patch->>'supplier_id', supplier_id),
        image_url = COALESCE(p_patch->>'image_url', image_url),
        is_active = COALESCE((p_patch->>'is_active')::BOOLEAN, is_active)
    WHERE id = p_id
    RETURNING * INTO v_product;
    
    RETURN v_product;
END;
$$;

CREATE OR REPLACE FUNCTION products_delete(p_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM products WHERE id = p_id;
    RETURN FOUND;
END;
$$;

-- ==========================================
-- PART 2: Sales Tables (Customers, Orders)
-- ==========================================

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for customers
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(last_name, first_name);

-- Enable RLS for customers
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read customers" ON customers
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to insert customers" ON customers
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update customers" ON customers
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to delete customers" ON customers
    FOR DELETE USING (auth.role() = 'authenticated');

-- Create sales_orders table
CREATE TABLE IF NOT EXISTS sales_orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id),
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    payment_status VARCHAR(50) NOT NULL DEFAULT 'paid',
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    paid_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(50) DEFAULT 'cash',
    notes TEXT,
    created_by UUID, -- Reference to auth.users or employees
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for sales_orders
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_id ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_order_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_sales_orders_order_number ON sales_orders(order_number);

-- Enable RLS for sales_orders
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read sales_orders" ON sales_orders
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to insert sales_orders" ON sales_orders
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update sales_orders" ON sales_orders
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create sales_order_items table
CREATE TABLE IF NOT EXISTS sales_order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL, -- Cache name in case product is deleted/changed
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for sales_order_items
CREATE INDEX IF NOT EXISTS idx_sales_order_items_order_id ON sales_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_sales_order_items_product_id ON sales_order_items(product_id);

-- Enable RLS for sales_order_items
ALTER TABLE sales_order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read sales_order_items" ON sales_order_items
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to insert sales_order_items" ON sales_order_items
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- -------------------------------------------------------------------------
-- RPC FUNCTIONS
-- -------------------------------------------------------------------------

-- 1. Create Sale (Transaction: Create Order + Items + Deduct Stock)
CREATE OR REPLACE FUNCTION sales_create(
    p_customer_id UUID,
    p_payment_method TEXT,
    p_subtotal NUMERIC,
    p_tax_amount NUMERIC,
    p_discount_amount NUMERIC,
    p_total_amount NUMERIC,
    p_paid_amount NUMERIC,
    p_notes TEXT,
    p_items JSONB -- Array of objects: {product_id, quantity, unit_price, discount}
)
RETURNS UUID -- Returns the new Order ID
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_item JSONB;
    v_product products%ROWTYPE;
    v_product_id UUID;
    v_quantity INTEGER;
BEGIN
    -- Generate Order Number (e.g., ORD-YYYYMMDD-XXXX)
    v_order_number := 'ORD-' || to_char(NOW(), 'YYYYMMDD') || '-' || substring(md5(random()::text) from 1 for 4);

    -- 1. Create Order Record
    INSERT INTO sales_orders (
        order_number, customer_id, status, payment_status,
        subtotal, tax_amount, discount_amount, total_amount, paid_amount,
        payment_method, notes
    ) VALUES (
        upper(v_order_number), p_customer_id, 'completed', 'paid',
        p_subtotal, p_tax_amount, p_discount_amount, p_total_amount, p_paid_amount,
        p_payment_method, p_notes
    ) RETURNING id INTO v_order_id;

    -- 2. Process Items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INTEGER;

        -- Check Stock
        SELECT * INTO v_product FROM products WHERE id = v_product_id FOR UPDATE;
        
        IF v_product.current_stock < v_quantity THEN
            RAISE EXCEPTION 'Insufficient stock for product: % (Available: %, Requested: %)', 
                v_product.name, v_product.current_stock, v_quantity;
        END IF;

        -- Create Order Item
        INSERT INTO sales_order_items (
            order_id, product_id, product_name, quantity, unit_price, total_price, discount
        ) VALUES (
            v_order_id,
            v_product_id,
            v_product.name,
            v_quantity,
            (v_item->>'unit_price')::NUMERIC,
            (v_item->>'quantity')::INTEGER * (v_item->>'unit_price')::NUMERIC,
            COALESCE((v_item->>'discount')::NUMERIC, 0)
        );

        -- Deduct Stock
        UPDATE products 
        SET current_stock = current_stock - v_quantity,
            updated_at = NOW()
        WHERE id = v_product_id;
        
    END LOOP;

    RETURN v_order_id;
END;
$$;

-- 2. List Sales
CREATE OR REPLACE FUNCTION sales_list(
    p_search TEXT DEFAULT NULL,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    order_number VARCHAR,
    customer_name TEXT, -- Computed
    total_amount DECIMAL,
    status VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        so.id,
        so.order_number,
        (c.first_name || ' ' || c.last_name) as customer_name,
        so.total_amount,
        so.status,
        so.created_at
    FROM sales_orders so
    LEFT JOIN customers c ON so.customer_id = c.id
    WHERE (p_search IS NULL OR so.order_number ILIKE '%' || p_search || '%')
      AND (p_start_date IS NULL OR so.created_at >= p_start_date)
      AND (p_end_date IS NULL OR so.created_at <= p_end_date)
    ORDER BY so.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- 3. Get Sale Details (with items)
CREATE OR REPLACE FUNCTION sales_get_details(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'order', to_jsonb(so.*),
        'customer', to_jsonb(c.*),
        'items', (
            SELECT jsonb_agg(to_jsonb(soi.*))
            FROM sales_order_items soi
            WHERE soi.order_id = so.id
        )
    ) INTO v_result
    FROM sales_orders so
    LEFT JOIN customers c ON so.customer_id = c.id
    WHERE so.id = p_order_id;

    RETURN v_result;
END;
$$;

-- 4. Customer Management
CREATE OR REPLACE FUNCTION customers_create(
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT DEFAULT NULL,
    p_phone TEXT DEFAULT NULL,
    p_address TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_zip TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO customers (first_name, last_name, email, phone, address, city, zip_code)
    VALUES (p_first_name, p_last_name, p_email, p_phone, p_address, p_city, p_zip)
    RETURNING id INTO v_id;
    
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION customers_search(p_query TEXT)
RETURNS SETOF customers
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM customers
    WHERE first_name ILIKE '%' || p_query || '%'
       OR last_name ILIKE '%' || p_query || '%'
       OR email ILIKE '%' || p_query || '%'
       OR phone ILIKE '%' || p_query || '%'
    LIMIT 20;
END;
$$;
