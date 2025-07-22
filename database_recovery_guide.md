# Database Password Recovery Guide for FUNAAB Portal

## Method 1: Windows Authentication Recovery (Recommended)

If you have Windows admin access to the SQL Server machine:

### Step 1: Connect using Windows Authentication
```cmd
# Open Command Prompt as Administrator
sqlcmd -S localhost -E
```

### Step 2: Reset SA Password
```sql
-- Enable SA account if disabled
ALTER LOGIN sa ENABLE;

-- Reset SA password
ALTER LOGIN sa WITH PASSWORD = 'NewSecurePassword123!';

-- Verify the change
SELECT name, is_disabled FROM sys.server_principals WHERE name = 'sa';
GO
```

### Step 3: Create New Application User
```sql
-- Create dedicated application user
CREATE LOGIN funaab_app WITH PASSWORD = 'SecureAppPassword456!';

-- Switch to your database (replace with actual database name)
USE [FUNAAB_Portal];

-- Create database user
CREATE USER funaab_app FOR LOGIN funaab_app;

-- Grant necessary permissions
ALTER ROLE db_datareader ADD MEMBER funaab_app;
ALTER ROLE db_datawriter ADD MEMBER funaab_app;
GO
```

## Method 2: Single User Mode Recovery

If Windows Authentication doesn't work:

### Step 1: Stop SQL Server Service
```cmd
net stop MSSQLSERVER
```

### Step 2: Start in Single User Mode
```cmd
net start MSSQLSERVER /m
```

### Step 3: Connect and Reset
```cmd
sqlcmd -S localhost -E
```

```sql
ALTER LOGIN sa WITH PASSWORD = 'NewPassword123!';
ALTER LOGIN sa ENABLE;
GO
```

### Step 4: Restart Normally
```cmd
net stop MSSQLSERVER
net start MSSQLSERVER
```

## Method 3: Configuration File Recovery

### Check Web.config Location
The actual web.config file should be in:
- `C:\inetpub\wwwroot\[YourPortalFolder]\web.config`
- Or wherever IIS is hosting the application

### Look for Connection Strings
```xml
<connectionStrings>
  <add name="DefaultConnection" 
       connectionString="Server=localhost;Database=FUNAAB_Portal;User Id=username;Password=password;" />
</connectionStrings>
```

## Method 4: Application-Level Password Reset

If you can modify the application code, create a temporary admin reset page.

## Emergency Contacts Checklist
- [ ] Database Administrator
- [ ] System Administrator  
- [ ] Hosting Provider (if external)
- [ ] Previous IT Staff who set up the system

## Security Notes
- Change all passwords immediately after regaining access
- Enable auditing to track future access
- Document the recovery process
- Set up proper backup procedures