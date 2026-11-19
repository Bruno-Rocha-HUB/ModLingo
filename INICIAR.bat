@echo off
title ModLingo
cd /d "%~dp0"

echo ============================================
echo  ModLingo
echo  Victoria 3 - ModLingo
echo ============================================
echo.

powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0ModLingo.ps1"

echo.
echo ============================================
echo  EXECUCAO ENCERRADA
echo ============================================
pause
