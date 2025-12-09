# Network Diagnostic Script for PROVIAL Two-PC Setup
# This script checks if the backend is accessible from the network

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PROVIAL Network Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check backend is running
Write-Host "1. Checking if backend is running on port 3001..." -ForegroundColor Yellow
$backendProcess = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue
if ($backendProcess) {
    Write-Host "   ✓ Backend is listening on port 3001" -ForegroundColor Green
    Write-Host "   Process ID: $($backendProcess.OwningProcess)" -ForegroundColor Gray
} else {
    Write-Host "   ✗ Backend is NOT listening on port 3001" -ForegroundColor Red
}
Write-Host ""

# 2. Get local IP addresses
Write-Host "2. Local IP Addresses:" -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' }
foreach ($ip in $ipAddresses) {
    Write-Host "   - $($ip.IPAddress) (Interface: $($ip.InterfaceAlias))" -ForegroundColor Gray
}
Write-Host ""

# 3. Check Windows Firewall rules for port 3001
Write-Host "3. Checking Windows Firewall for port 3001..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true -and ($_.DisplayName -like "*3001*" -or $_.DisplayName -like "*Node*") }
if ($firewallRules) {
    Write-Host "   Found firewall rules:" -ForegroundColor Green
    foreach ($rule in $firewallRules) {
        Write-Host "   - $($rule.DisplayName) ($($rule.Direction))" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠  No specific firewall rules found for port 3001" -ForegroundColor Yellow
    Write-Host "   This might cause connection issues from other devices" -ForegroundColor Yellow
}
Write-Host ""

# 4. Test localhost connection
Write-Host "4. Testing localhost connection to backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✓ Backend responds on localhost: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend not responding on localhost" -ForegroundColor Red
}
Write-Host ""

# 5. Test 0.0.0.0 connection (if backend is bound to it)
Write-Host "5. Testing 0.0.0.0 connection to backend..." -ForegroundColor Yellow
try {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" }).IPAddress | Select-Object -First 1
    if ($localIP) {
        Write-Host "   Using IP: $localIP" -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri "http://${localIP}:3001/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "   ✓ Backend responds on network IP: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "   Mobile device should connect to: http://${localIP}:3001/api" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠  Could not find local network IP" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Backend not responding on network IP" -ForegroundColor Red
    Write-Host "   This means mobile device won't be able to connect!" -ForegroundColor Red
}
Write-Host ""

# 6. Recommendations
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If mobile device can't connect:" -ForegroundColor Yellow
Write-Host "1. Add Windows Firewall rule:" -ForegroundColor Gray
Write-Host "   netsh advfirewall firewall add rule name=\"PROVIAL Backend\" dir=in action=allow protocol=TCP localport=3001" -ForegroundColor White
Write-Host ""
Write-Host "2. Or temporarily disable firewall for testing:" -ForegroundColor Gray
Write-Host "   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False" -ForegroundColor White
Write-Host ""
Write-Host "3. Ensure backend is listening on 0.0.0.0 (not just localhost)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Verify mobile device IP in api.ts matches this PC IP" -ForegroundColor Gray
Write-Host ""
