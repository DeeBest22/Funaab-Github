# PowerShell script to find connection strings in web.config files
# Run this on the web server to locate configuration files

Write-Host "🔍 Searching for FUNAAB Portal configuration files..." -ForegroundColor Green

# Common IIS locations
$searchPaths = @(
    "C:\inetpub\wwwroot",
    "C:\inetpub\wwwroot\funaab*",
    "C:\inetpub\wwwroot\portal*",
    "C:\inetpub\wwwroot\student*",
    "D:\inetpub\wwwroot",
    "E:\inetpub\wwwroot"
)

# Search for web.config files
Write-Host "`n📁 Looking for web.config files..." -ForegroundColor Yellow

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $webConfigs = Get-ChildItem -Path $path -Name "web.config" -Recurse -ErrorAction SilentlyContinue
        
        foreach ($config in $webConfigs) {
            $fullPath = Join-Path $path $config
            Write-Host "Found: $fullPath" -ForegroundColor Cyan
            
            # Try to read connection strings
            try {
                $content = Get-Content $fullPath -Raw
                if ($content -match '<connectionStrings>.*?</connectionStrings>') {
                    Write-Host "  ✅ Contains connection strings!" -ForegroundColor Green
                    
                    # Extract connection strings (masked for security)
                    $connectionStrings = [regex]::Matches($content, 'connectionString="([^"]*)"')
                    foreach ($match in $connectionStrings) {
                        $connStr = $match.Groups[1].Value
                        # Mask password for display
                        $maskedConnStr = $connStr -replace '(Password|Pwd)=[^;]*', 'Password=***'
                        Write-Host "    Connection: $maskedConnStr" -ForegroundColor White
                    }
                }
            }
            catch {
                Write-Host "  ❌ Cannot read file (permissions?)" -ForegroundColor Red
            }
        }
    }
}

# Search for backup files
Write-Host "`n📋 Looking for backup configuration files..." -ForegroundColor Yellow

$backupPatterns = @("*.config.bak", "*.config.old", "web.config.*", "*.backup")

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        foreach ($pattern in $backupPatterns) {
            $backups = Get-ChildItem -Path $path -Name $pattern -Recurse -ErrorAction SilentlyContinue
            foreach ($backup in $backups) {
                Write-Host "Backup found: $(Join-Path $path $backup)" -ForegroundColor Magenta
            }
        }
    }
}

# Check IIS application pools
Write-Host "`n🌐 Checking IIS Application Pools..." -ForegroundColor Yellow

try {
    Import-Module WebAdministration -ErrorAction Stop
    
    $sites = Get-Website | Where-Object { $_.Name -like "*funaab*" -or $_.Name -like "*portal*" -or $_.Name -like "*student*" }
    
    foreach ($site in $sites) {
        Write-Host "IIS Site: $($site.Name)" -ForegroundColor Cyan
        Write-Host "  Physical Path: $($site.PhysicalPath)" -ForegroundColor White
        Write-Host "  App Pool: $($site.ApplicationPool)" -ForegroundColor White
        
        $configPath = Join-Path $site.PhysicalPath "web.config"
        if (Test-Path $configPath) {
            Write-Host "  ✅ web.config exists at: $configPath" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "Cannot access IIS configuration (run as administrator)" -ForegroundColor Red
}

# Check for SQL Server instances
Write-Host "`n🗄️ Checking SQL Server instances..." -ForegroundColor Yellow

try {
    $sqlServices = Get-Service | Where-Object { $_.Name -like "*SQL*" -and $_.Status -eq "Running" }
    foreach ($service in $sqlServices) {
        Write-Host "SQL Service: $($service.Name) - $($service.Status)" -ForegroundColor Cyan
    }
    
    # Try to connect with Windows Authentication
    try {
        $connectionString = "Server=localhost;Integrated Security=true;Connection Timeout=5"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        
        Write-Host "✅ Windows Authentication to localhost works!" -ForegroundColor Green
        
        # List databases
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')"
        $reader = $command.ExecuteReader()
        
        Write-Host "  Available databases:" -ForegroundColor White
        while ($reader.Read()) {
            Write-Host "    - $($reader['name'])" -ForegroundColor White
        }
        
        $connection.Close()
    }
    catch {
        Write-Host "❌ Cannot connect with Windows Authentication" -ForegroundColor Red
    }
}
catch {
    Write-Host "Cannot check SQL Server services" -ForegroundColor Red
}

Write-Host "`n✅ Search complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check the web.config files found above" -ForegroundColor White
Write-Host "2. Try Windows Authentication if SQL Server is local" -ForegroundColor White
Write-Host "3. Use the emergency reset tool if you can connect to the database" -ForegroundColor White