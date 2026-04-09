@echo off
echo === Setting up CCS project structure ===

REM --- Backend ---
echo Scaffolding .NET 9 backend...
cd /d "%~dp0"
dotnet new webapi -n backend --framework net9.0 --output backend --force

cd backend
echo Installing NuGet packages...
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Swashbuckle.AspNetCore

echo Creating backend folders...
mkdir Controllers 2>nul
mkdir Models 2>nul
mkdir Data 2>nul
mkdir DTOs 2>nul

REM Remove scaffold boilerplate
del /f /q Controllers\WeatherForecastController.cs 2>nul
del /f /q WeatherForecast.cs 2>nul

cd ..

REM --- Frontend ---
echo Creating frontend folders...
mkdir frontend\src\assets 2>nul
mkdir frontend\src\components 2>nul
mkdir frontend\src\views\auth 2>nul
mkdir frontend\src\views\steps 2>nul
mkdir frontend\src\stores 2>nul
mkdir frontend\src\router 2>nul
mkdir frontend\src\services 2>nul

echo.
echo === Done! Now return to Copilot to have it fill in all source files. ===
pause
