@echo off
chcp 65001 >nul
title zoogvpn.best - GitHub 仓库极速自动上传工具

echo ==========================================================
echo         zoogvpn.best GitHub 仓库一键上传工具
echo ==========================================================
echo.
echo 检测到 Windows 原生环境，使用 PowerShell 调用 GitHub API 直传！
echo 无需在本地安装 Git 软件，全自动创建仓库并上传全部文件。
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0github_upload.ps1"

echo.
echo 程序运行完毕，按任意键退出...
pause >nul
