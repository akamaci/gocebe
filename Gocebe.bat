@echo off
REM ============================================================================
REM  GOCEBE v1.0.0  -  site tasima tezgahi (cift tik / surukle-birak)
REM
REM  AMAC: site KOPYALAMAK DEGIL. PHP/HTML/WordPress sitelerini tasiyanlara
REM        kolaylik saglamak. Her calistirmada 3 yorum uretir.
REM
REM  Kullanim:
REM    - Cift tik  -> kaynak sorar
REM    - URL'yi bu dosyanin uzerine SURUKLE-BIRAK
REM    - cmd: Gocebe.bat https://ornek.com
REM ============================================================================
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
cd /d "%~dp0"

title GOCEBE v1.0.0

if "%~1"=="" goto soru

set "KAYNAK=%~1"
goto calistir

:soru
echo.
echo  ==============================================================
echo    GOCEBE v1.0.0  -  site tasima tezgahi
echo  ==============================================================
echo.
echo   AMAC: site KOPYALAMAK DEGIL.
echo   PHP / HTML / WordPress sitelerini tasiyanlara KOLAYLIK saglamak.
echo.
echo   Yalnizca HAKKINIZ OLAN siteleri tasiyin.
echo.
echo  --------------------------------------------------------------
set /p "KAYNAK=  Kaynak (URL veya klasor yolu): "

if "%KAYNAK%"=="" (
  echo.
  echo  [IPTAL] Kaynak girilmedi.
  pause
  exit /b 1
)

:calistir
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gocebe.ps1" "%KAYNAK%" %2 %3 %4 %5

echo.
echo  --------------------------------------------------------------
pause
