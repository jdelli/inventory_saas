# Products Database Setup Guide

## Overview
Your inventory system now has full database integration with Supabase! This guide will help you set up the products table and start adding products to your database.

## Prerequisites
- Supabase project created
- Environment variables configured (SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE)

## Database Setup

### 1. Run the Database Schema
Execute the SQL commands in `database_schema.sql` in your Supabase SQL Editor:

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Copy and paste the entire contents of `database_schema.sql`
4. Click "Run" to execute

This will create:
- ✅ `products` table with all necessary columns
- ✅ Indexes for better performance
- ✅ Row Level Security (RLS) policies
- ✅ CRUD functions for products
- ✅ Sample product data

### 2. Verify Table Creation
After running the schema, verify the table was created:

```sql
SELECT * FROM products LIMIT 5;
```

You should see 5 sample products.

## Features Now Available

### ✅ **Add Products to Database**
- Click "Add Product" button in inventory screen
- Fill out the comprehensive form
- Products are now saved to Supabase database
- Automatic SKU and barcode generation
- Form validation and error handling

### ✅ **Database Operations**
- **Create**: Add new products via RPC function
- **Read**: Fetch all products, search, filter by category/supplier
- **Update**: Modify existing products
- **Delete**: Remove products from database
- **Stock Management**: Update stock levels

### ✅ **Advanced Features**
- **Search**: Full-text search across name, SKU, barcode, description
- **Filtering**: By category, brand, supplier, active status
- **Stock Alerts**: Low stock and out-of-stock detection
- **Fallback**: If database fails, falls back to local data

## Database Schema

### Products Table Structure
```sql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    current_stock INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 0,
    max_stock_level INTEGER,
    unit VARCHAR(20) DEFAULT 'pcs',
    warehouse VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    supplier_id VARCHAR(100) NOT NULL,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Available RPC Functions
- `products_create()` - Create new product
- `products_get(id)` - Get product by ID
- `products_list()` - List products with filters
- `products_update(id, patch)` - Update product
- `products_delete(id)` - Delete product

## Testing the Integration

### 1. Test Adding a Product
1. Run your Flutter app: `flutter run -d windows`
2. Go to Inventory screen
3. Click "Add Product"
4. Fill in the form:
   - **Product Name**: "Test Product"
   - **Cost Price**: "10.00"
   - **Selling Price**: "15.00"
   - Other fields are optional
5. Click "Add Product"
6. Check your Supabase dashboard to see the new product

### 2. Verify Database Connection
Check the console logs for any database connection errors. The system will:
- Try to connect to Supabase first
- Fall back to local dummy data if connection fails
- Show error messages if there are issues

## Troubleshooting

### Common Issues

#### 1. "Failed to fetch products" Error
- Check your Supabase URL and API key
- Verify the products table exists
- Check RLS policies allow authenticated access

#### 2. Products Not Appearing
- Check if RLS is enabled and policies are correct
- Verify the `products_list` function exists
- Check console for specific error messages

#### 3. Add Product Fails
- Ensure all required fields are filled
- Check if SKU is unique (no duplicates)
- Verify the `products_create` function exists

### Debug Steps
1. Check Supabase logs in dashboard
2. Verify environment variables are set
3. Test RPC functions directly in SQL editor
4. Check Flutter console for error messages

## Next Steps

### Recommended Enhancements
1. **Image Upload**: Add product image upload functionality
2. **Bulk Import**: CSV import for multiple products
3. **Categories Management**: Dynamic category management
4. **Suppliers Management**: Supplier database integration
5. **Stock Movements**: Track stock changes over time
6. **Reports**: Generate inventory reports

### Performance Optimization
- The database includes indexes for common queries
- RLS policies ensure secure access
- RPC functions provide optimized database operations

## Support

If you encounter any issues:
1. Check the console logs for specific error messages
2. Verify your Supabase configuration
3. Test the RPC functions directly in Supabase SQL editor
4. Ensure all environment variables are properly set

Your inventory system is now fully database-integrated! 🎉
