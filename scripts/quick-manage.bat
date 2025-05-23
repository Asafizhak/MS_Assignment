@echo off
setlocal enabledelayedexpansion

REM Quick AKS Infrastructure Management Script for Windows
REM Provides easy deployment and destruction for cost savings

echo.
echo 🚀 AKS Infrastructure Quick Manager
echo ==================================
echo.

REM Check if we're in the right directory
if not exist "main.tf" (
    echo ❌ ERROR: This script must be run from the Terraform project directory
    echo Please navigate to the directory containing main.tf
    pause
    exit /b 1
)

REM Function to check if infrastructure exists
terraform show -json 2>nul | findstr "azurerm_kubernetes_cluster" >nul
if %errorlevel% == 0 (
    set "INFRA_EXISTS=true"
) else (
    set "INFRA_EXISTS=false"
)

:MAIN_MENU
cls
echo.
echo 🚀 AKS Infrastructure Quick Manager
echo ==================================
echo.

REM Show current status
echo 📊 Checking current infrastructure status...
if "!INFRA_EXISTS!" == "true" (
    echo ✅ Infrastructure is currently DEPLOYED
    echo ⚠️  Monthly cost: ~$55 ^(development^) or ~$160 ^(production^)
    echo.
    echo Current resources:
    terraform output 2>nul
) else (
    echo ✅ Infrastructure is currently DESTROYED
    echo ✅ Monthly cost: $0
)

echo.
echo Available actions:
echo   1^) Deploy infrastructure ^(AKS + ACR + NGINX^)
echo   2^) Destroy infrastructure ^(save costs^)
echo   3^) Show current status
echo   4^) Show cost information
echo   5^) Exit
echo.

set /p "choice=Choose an action (1-5): "

if "%choice%"=="1" goto DEPLOY
if "%choice%"=="2" goto DESTROY
if "%choice%"=="3" goto STATUS
if "%choice%"=="4" goto COSTS
if "%choice%"=="5" goto EXIT
echo Invalid choice. Please select 1-5.
pause
goto MAIN_MENU

:DEPLOY
echo.
echo 🏗️ Deploying AKS + ACR infrastructure...
echo.

if "!INFRA_EXISTS!" == "true" (
    echo ⚠️ Infrastructure already exists!
    set /p "confirm=Do you want to redeploy? (y/N): "
    if /i not "!confirm!"=="y" (
        echo Deployment cancelled
        pause
        goto MAIN_MENU
    )
)

echo 📋 Initializing Terraform...
make init
if %errorlevel% neq 0 (
    echo ❌ Terraform initialization failed
    pause
    goto MAIN_MENU
)

echo 🚀 Deploying development environment...
make dev-deploy-all
if %errorlevel% neq 0 (
    echo ❌ Deployment failed
    pause
    goto MAIN_MENU
)

echo.
echo ✅ Infrastructure deployed successfully!
echo ✅ You can now use your AKS cluster and ACR
echo.
echo Useful commands:
echo   make aks-info          # Show cluster information
echo   make nginx-status      # Check ingress status
echo   make acr-integration   # Setup ACR integration if needed
echo.
set "INFRA_EXISTS=true"
pause
goto MAIN_MENU

:DESTROY
echo.
echo ⚠️ WARNING: This will DESTROY all infrastructure and data!
echo.
echo You will lose:
echo   - AKS cluster and all workloads
echo   - ACR and all container images
echo   - Virtual network and load balancers
echo   - All Kubernetes data and configurations
echo.

if "!INFRA_EXISTS!" == "false" (
    echo ✅ Infrastructure is already destroyed
    pause
    goto MAIN_MENU
)

set /p "confirm=Are you sure you want to destroy everything? (y/N): "
if /i not "!confirm!"=="y" (
    echo Destruction cancelled
    pause
    goto MAIN_MENU
)

echo 💥 Destroying infrastructure...
make dev-destroy
if %errorlevel% neq 0 (
    echo ❌ Destruction failed
    pause
    goto MAIN_MENU
)

echo.
echo ✅ Infrastructure destroyed successfully!
echo ✅ Monthly cost is now $0
echo.
set "INFRA_EXISTS=false"
pause
goto MAIN_MENU

:STATUS
echo.
echo 📊 CURRENT STATUS
echo ================
echo.
if "!INFRA_EXISTS!" == "true" (
    echo Status: DEPLOYED
    echo Monthly Cost: ~$55-160
    echo.
    terraform output 2>nul
) else (
    echo Status: DESTROYED
    echo Monthly Cost: $0
)
echo.
pause
goto MAIN_MENU

:COSTS
echo.
echo 💰 COST BREAKDOWN
echo ==================
echo.
echo When DEPLOYED:
echo   Development:  ~$55/month
echo   Production:   ~$160/month
echo.
echo When DESTROYED: $0/month ✅
echo.
echo 💡 Best practice: Destroy when not actively using
echo    - Overnight: Save ~$2-5
echo    - Weekends: Save ~$15-30
echo    - Extended breaks: Save hundreds
echo.
echo Usage Examples:
echo   - 2 hours/day, 5 days/week: Save $47/month
echo   - Weekend projects: Save $52/month
echo   - Demo environments: Save $48/month
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo 👋 Goodbye!
echo.
exit /b 0