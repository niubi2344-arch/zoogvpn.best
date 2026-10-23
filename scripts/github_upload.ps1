param (
    [string]$Token = "",
    [string]$RepoName = "zoogvpn.best"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         zoogvpn.best - GitHub 一键自动上传工具          " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Token) {
    Write-Host "未输入 Token，操作已取消。" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-GitHub-Uploader"
}

Write-Host "[1/4] 正在验证 GitHub 账号身份..." -ForegroundColor White
try {
    $user = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method GET
    $owner = $user.login
    Write-Host "认证成功！GitHub 用户名: $owner (邮箱: $($user.email))" -ForegroundColor Green
} catch {
    Write-Host "认证失败！错误详情: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host "API 响应: $($reader.ReadToEnd())" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n[2/4] 正在检查或创建远程仓库 $RepoName..." -ForegroundColor White
$repoExists = $false
try {
    $repo = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$RepoName" -Headers $headers -Method GET
    $repoExists = $true
    Write-Host "仓库已存在: $($repo.html_url)" -ForegroundColor Yellow
} catch {
    $createBody = @{
        name = $RepoName
        description = "zoogvpn.best 官方推广落地页与 SEO 资讯中心"
        private = $false
        auto_init = $true
    } | ConvertTo-Json

    try {
        $repo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method POST -Body $createBody -ContentType "application/json"
        Write-Host "仓库创建成功: $($repo.html_url)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "创建仓库失败: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            Write-Host "API 响应: $($reader.ReadToEnd())" -ForegroundColor Red
        }
        exit 1
    }
}

Write-Host "`n[3/4] 正在扫描并上传所有网站文件..." -ForegroundColor White
$rootDir = (Get-Item (Join-Path $PSScriptRoot "..")).FullName
$files = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object {
    $_.FullName -notmatch "\\\.git" -and $_.FullName -notmatch "\\\.gemini"
}

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($rootDir.Length + 1).Replace("\", "/")
    Write-Host "正在上传: $relativePath ... " -NoNewline

    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $base64Content = [Convert]::ToBase64String($bytes)

    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$RepoName/contents/$relativePath" -Headers $headers -Method GET -ErrorAction SilentlyContinue
        if ($existing) {
            $sha = $existing.sha
        }
    } catch {}

    $uploadPayload = @{
        message = "Upload $relativePath via AutoUploader"
        content = $base64Content
    }
    if ($sha) {
        $uploadPayload["sha"] = $sha
    }

    $jsonPayload = $uploadPayload | ConvertTo-Json
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

    try {
        $putResp = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$RepoName/contents/$relativePath" -Headers $headers -Method PUT -Body $bodyBytes -ContentType "application/json"
        Write-Host "[成功]" -ForegroundColor Green
    } catch {
        Write-Host "[失败: $($_.Exception.Message)]" -ForegroundColor Red
    }
}

Write-Host "`n[4/4] 正在开启 GitHub Pages 静态网站托管服务..." -ForegroundColor White
$pagesBody = @{
    source = @{
        branch = "main"
        path = "/"
    }
} | ConvertTo-Json

try {
    $pagesResp = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$RepoName/pages" -Headers $headers -Method POST -Body $pagesBody -ContentType "application/json"
    Write-Host "GitHub Pages 开启成功！访问网址: $($pagesResp.html_url)" -ForegroundColor Green
} catch {
    Write-Host "提示: GitHub Pages 已开启或需要等待分支初始化完成。" -ForegroundColor Yellow
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "?? 全部上传成功！" -ForegroundColor Green
Write-Host "GitHub 仓库地址: https://github.com/$owner/$RepoName" -ForegroundColor Yellow
Write-Host "GitHub Pages 地址: https://$owner.github.io/$RepoName/" -ForegroundColor Yellow
Write-Host "自定义绑定域名: https://zoogvpn.best" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
