@echo off
chcp 65001 >nul
title zoogvpn.best - IndexNow URL 一键提交推送工具

echo ==========================================================
echo        zoogvpn.best IndexNow 搜索引擎推送工具
echo ==========================================================
echo.
echo 检测到当前运行环境: Windows (无需安装 Python，使用原生 PowerShell 执行)
echo 正在执行提交程序，请稍候...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0indexnow_submit.ps1"

echo.
echo 提交程序已执行完毕。按任意键退出窗口...
pause >nul
