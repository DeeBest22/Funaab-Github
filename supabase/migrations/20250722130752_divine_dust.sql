-- Emergency Database Access Recovery Script
-- Run this if you have Windows admin access to the SQL Server

-- Enable SA account (if disabled)
ALTER LOGIN sa ENABLE;

-- Reset SA password
ALTER LOGIN sa WITH PASSWORD = 'TempEmergencyPass123!';

-- Create emergency admin user
CREATE LOGIN emergency_admin WITH PASSWORD = 'EmergencyAccess456!';
ALTER SERVER ROLE sysadmin ADD MEMBER emergency_admin;

-- Check existing databases
SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

-- Find FUNAAB database (adjust name as needed)
USE [FUNAAB_Portal]; -- Replace with actual database name

-- Check user tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Create new application user with limited permissions
CREATE LOGIN funaab_portal_app WITH PASSWORD = 'SecureAppPassword789!';
CREATE USER funaab_portal_app FOR LOGIN funaab_portal_app;

-- Grant necessary permissions (adjust based on actual table structure)
GRANT SELECT, INSERT, UPDATE ON dbo.Students TO funaab_portal_app;
GRANT SELECT, INSERT, UPDATE ON dbo.Courses TO funaab_portal_app;
GRANT SELECT, INSERT, UPDATE ON dbo.Registrations TO funaab_portal_app;
GRANT SELECT, INSERT, UPDATE ON dbo.Payments TO funaab_portal_app;

-- Enable auditing for security
ALTER DATABASE [FUNAAB_Portal] SET TRUSTWORTHY OFF;

PRINT 'Emergency access restored. Change passwords immediately after regaining access!';