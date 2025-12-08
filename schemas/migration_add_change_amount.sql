-- Add change_amount column to sales_orders table
ALTER TABLE sales_orders ADD COLUMN IF NOT EXISTS change_amount DECIMAL(10,2) NOT NULL DEFAULT 0;

-- Update sales_create function to accept change_amount
CREATE OR REPLACE FUNCTION sales_create(
    p_customer_id UUID,
    p_payment_method TEXT,
    p_subtotal NUMERIC,
    p_tax_amount NUMERIC,
    p_discount_amount NUMERIC,
    p_total_amount NUMERIC,
    p_paid_amount NUMERIC,
    p_change_amount NUMERIC, -- Added parameter
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
        subtotal, tax_amount, discount_amount, total_amount, paid_amount, change_amount,
        payment_method, notes
    ) VALUES (
        upper(v_order_number), p_customer_id, 'completed', 'paid',
        p_subtotal, p_tax_amount, p_discount_amount, p_total_amount, p_paid_amount, p_change_amount,
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
