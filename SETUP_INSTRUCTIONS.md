# Environment Variables Setup

## Securing Your Supabase Credentials

This project uses environment variables to keep your Supabase URL and anon key secure.

### Setup Instructions

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Open `.env` and add your actual credentials:**
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key_here
   ```

3. **Never commit `.env` to version control**
   - The `.env` file is already in `.gitignore`
   - Keep your actual credentials secret

### Getting Your Supabase Credentials

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Settings** > **API**
4. Copy:
   - **Project URL** (this is your SUPABASE_URL)
   - **anon public key** (this is your SUPABASE_ANON_KEY)

### Important Security Notes

⚠️ **The anon key is safe to use in client-side applications**
- It's designed to be public
- Row Level Security (RLS) should be enabled on your database tables
- Use RLS policies to restrict access, not by hiding the key

🔒 **For extra security:**
- Always enable RLS on your Supabase database tables
- Use environment-specific keys (development vs production)
- Consider using a backend proxy for sensitive operations

### Usage in Code

The credentials are loaded in `main.dart` before Supabase is initialized:

```dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```
