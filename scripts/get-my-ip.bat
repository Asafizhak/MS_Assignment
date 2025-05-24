@echo off
REM Script to get your current public IP address for AKS authorized IP ranges
REM This helps secure your public AKS cluster by restricting API access

echo 🔍 Getting your current public IP address...
echo.

REM Method 1: Using PowerShell with Invoke-RestMethod
echo Method 1 - PowerShell (ipinfo.io):
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://ipinfo.io/ip').Trim()" 2^>nul') do set PUBLIC_IP1=%%i
if defined PUBLIC_IP1 (
    echo   Your public IP: %PUBLIC_IP1%
    echo   CIDR format: %PUBLIC_IP1%/32
) else (
    echo   ❌ Failed to get IP from ipinfo.io
)

echo.

REM Method 2: Using PowerShell with different service
echo Method 2 - PowerShell (ifconfig.me):
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://ifconfig.me').Trim()" 2^>nul') do set PUBLIC_IP2=%%i
if defined PUBLIC_IP2 (
    echo   Your public IP: %PUBLIC_IP2%
    echo   CIDR format: %PUBLIC_IP2%/32
) else (
    echo   ❌ Failed to get IP from ifconfig.me
)

echo.

REM Method 3: Using curl if available
echo Method 3 - curl (if available):
curl --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%i in ('curl -s https://api.ipify.org 2^>nul') do set PUBLIC_IP3=%%i
    if defined PUBLIC_IP3 (
        echo   Your public IP: %PUBLIC_IP3%
        echo   CIDR format: %PUBLIC_IP3%/32
    ) else (
        echo   ❌ Failed to get IP via curl
    )
) else (
    echo   ⚠️  curl not available
)

echo.
echo 📋 Usage Instructions:
echo.
echo 1. Copy one of the IP addresses above
echo 2. Add it to your terraform.tfvars file:
echo    aks_authorized_ip_ranges = ["YOUR_IP/32"]
echo.
echo 3. Or set it as an environment variable:
echo    set TF_VAR_aks_authorized_ip_ranges=["YOUR_IP/32"]
echo.
echo 4. For multiple IPs (office, home, etc.):
echo    aks_authorized_ip_ranges = ["IP1/32", "IP2/32", "OFFICE_RANGE/24"]
echo.
echo ⚠️  Note: If you don't set authorized_ip_ranges, the cluster will be
echo    accessible from any IP address on the internet.
echo.
echo 🔒 For maximum security, always specify your IP ranges!
echo.
pause