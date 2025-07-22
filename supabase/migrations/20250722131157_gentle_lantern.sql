-- Quick Database Recovery Check Script
-- Run this after connecting to SQL Server

PRINT '🔍 FUNAAB Portal Database Recovery Check';
PRINT '==========================================';

-- Check current user and permissions
PRINT CHAR(13) + '👤 Current User Information:';
SELECT 
    SYSTEM_USER as 'Current Login',
    USER_NAME() as 'Current User',
    IS_SRVROLEMEMBER('sysadmin') as 'Is SysAdmin'

-- List all databases
PRINT CHAR(13) + '📊 Available Databases:';
SELECT 
    name as 'Database Name',
    database_id,
    create_date,
    collation_name
FROM sys.databases 
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
ORDER BY name;

-- Check for common FUNAAB database names
PRINT CHAR(13) + '🎯 Potential FUNAAB Databases:';
SELECT name as 'Potential Database'
FROM sys.databases 
WHERE name LIKE '%funaab%' 
   OR name LIKE '%portal%' 
   OR name LIKE '%student%'
   OR name LIKE '%university%'
   OR name LIKE '%school%';

-- List all logins
PRINT CHAR(13) + '🔐 SQL Server Logins:';
SELECT 
    name as 'Login Name',
    type_desc as 'Type',
    is_disabled as 'Disabled',
    create_date,
    modify_date
FROM sys.server_principals 
WHERE type IN ('S', 'U') -- SQL and Windows logins
ORDER BY name;

-- If we can identify the database, check its structure
-- Replace 'FUNAAB_Portal' with the actual database name found above
DECLARE @dbname NVARCHAR(128)
DECLARE db_cursor CURSOR FOR 
    SELECT name FROM sys.databases 
    WHERE name LIKE '%funaab%' OR name LIKE '%portal%' OR name LIKE '%student%'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CHAR(13) + '📋 Checking database: ' + @dbname
    
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = 'USE [' + @dbname + ']; 
    SELECT ''' + @dbname + ''' as Database_Name, TABLE_NAME as Table_Name, TABLE_TYPE
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = ''BASE TABLE''
    AND (TABLE_NAME LIKE ''%user%'' 
         OR TABLE_NAME LIKE ''%student%'' 
         OR TABLE_NAME LIKE ''%admin%''
         OR TABLE_NAME LIKE ''%login%''
         OR TABLE_NAME LIKE ''%account%'')
    ORDER BY TABLE_NAME'
    
    BEGIN TRY
        EXEC sp_executesql @sql
    END TRY
    BEGIN CATCH
        PRINT '❌ Cannot access database: ' + @dbname
    END CATCH
    
    FETCH NEXT FROM db_cursor INTO @dbname
END

CLOSE db_cursor
DEALLOCATE db_cursor

-- Check for failed logins in error log
PRINT CHAR(13) + '⚠️ Recent Failed Login Attempts:';
EXEC xp_readerrorlog 0, 1, N'Login failed'

PRINT CHAR(13) + '✅ Database check complete!';
PRINT 'Next steps:';
PRINT '1. Identify the correct database from the list above';
PRINT '2. Check user tables in that database';
PRINT '3. Reset passwords using the emergency tool';
PRINT '4. Update connection strings in web.config';