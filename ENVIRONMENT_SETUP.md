# Environment Setup Guide

## Quick Fix for Missing Environment Variables

The app is currently running in **offline mode** because Supabase environment variables are not set. Here's how to fix it:

### Option 1: Set Environment Variables (Recommended)

1. **Get your Supabase credentials:**
   - Go to your Supabase Dashboard
   - Navigate to Settings → API
   - Copy your Project URL and anon/public key

2. **Set environment variables in Windows:**
   ```powershell
   # In PowerShell (run as Administrator)
   [Environment]::SetEnvironmentVariable("SUPABASE_URL", "your_supabase_url", "User")
   [Environment]::SetEnvironmentVariable("SUPABASE_ANON_KEY", "your_supabase_anon_key", "User")
   ```

3. **Or set them temporarily for this session:**
   ```powershell
   $env:SUPABASE_URL="your_supabase_url"
   $env:SUPABASE_ANON_KEY="your_supabase_anon_key"
   flutter run -d windows
   ```

### Option 2: Run in Offline Mode (Current)

The app is currently working in offline mode with dummy data. You can:
- ✅ Add products (stored locally)
- ✅ View inventory
- ✅ Use all features
- ❌ Products won't persist after app restart
- ❌ No database integration

### Option 3: Create a .env file (Alternative)

1. Create a `.env` file in your project root:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE=your_service_role_key
   ```

2. Update `pubspec.yaml` to include `flutter_dotenv` package

## Current Status

✅ **App is running** - GUI should now be visible
✅ **Offline mode active** - Using dummy data
⚠️ **Database disabled** - Products stored locally only

## Next Steps

1. **Test the app** - Try adding a product to see if it works locally
2. **Set up Supabase** - Follow Option 1 above to enable database features
3. **Run database schema** - Execute `database_schema.sql` in Supabase SQL Editor

The app should now load properly! 🎉
