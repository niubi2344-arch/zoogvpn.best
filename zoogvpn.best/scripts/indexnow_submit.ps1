# ==============================================================================
# IndexNow 搜索引擎极速收录自动提交脚本 (PowerShell 原生版)
# 专为 Windows 系统打造，无需安装 Python 环境，开箱即用！
# 支持搜索引擎: Bing (必应), Yandex, Naver, Seznam 等
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       zoogvpn.best - IndexNow 搜索引擎推送工具         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$hostName = "zoogvpn.best"
$apiKey = "e4f1a98c0b2d45e69738c82f10b7a65d"
$keyLocation = "https://$hostName/$apiKey.txt"

$urlList = @(
    "https://$hostName/",
    "https://$hostName/insights.html",
    "https://$hostName/about.html",
    "https://$hostName/terms.html",
    "https://$hostName/privacy.html",
    "https://$hostName/sitemap.html"
)

Write-Host ""
Write-Host "[1/3] 准备推送数据..." -ForegroundColor White
Write-Host "目标域名: $hostName" -ForegroundColor Gray
Write-Host "API 密钥: $apiKey" -ForegroundColor Gray
Write-Host "密钥验证路径: $keyLocation" -ForegroundColor Gray
Write-Host "待提交 URL 数量: $($urlList.Count) 个" -ForegroundColor Gray

$payloadObj = @{
    host = $hostName
    key = $apiKey
    keyLocation = $keyLocation
    urlList = $urlList
}

$jsonPayload = $payloadObj | ConvertTo-Json -Depth 5

Write-Host ""
Write-Host "[2/3] 正在向 IndexNow 网关发送推送请求..." -ForegroundColor White

$endpoints = @(
    @{ Name = "IndexNow 官方中央网关"; Url = "https://api.indexnow.org/indexnow" },
    @{ Name = "Bing 微软必应网关"; Url = "https://www.bing.com/indexnow" }
)

foreach ($ep in $endpoints) {
    Write-Host ("正在推送到 " + $ep.Name + "... ") -NoNewline
    try {
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)
        $resp = Invoke-WebRequest -Uri $ep.Url -Method POST -ContentType "application/json; charset=utf-8" -Body $bodyBytes -UseBasicParsing -TimeoutSec 15
        $code = $resp.StatusCode

        if ($code -eq 200) {
            Write-Host "[成功 200 OK]" -ForegroundColor Green
            Write-Host "   -> 搜索引擎已成功接收并确认 URL 提交！" -ForegroundColor DarkGreen
        } elseif ($code -eq 202) {
            Write-Host "[已接收 202 Accepted]" -ForegroundColor Green
            Write-Host "   -> 请求已接收，正在排队验证密钥并抓取。" -ForegroundColor DarkGreen
        } else {
            Write-Host "[返回代码: $code]" -ForegroundColor Yellow
        }
    } catch {
        $errResp = $_.Exception.Response
        if ($errResp) {
            $errCode = [int]$errResp.StatusCode
            Write-Host "[响应代码: $errCode]" -ForegroundColor Red
            if ($errCode -eq 400) {
                Write-Host "   -> 400 格式错误：请检查 JSON 数据格式。" -ForegroundColor Red
            } elseif ($errCode -eq 403) {
                Write-Host "   -> 403 密钥无效：请确保网站正式上线后根目录可访问 $keyLocation" -ForegroundColor Yellow
            } elseif ($errCode -eq 422) {
                Write-Host "   -> 422 域名不匹配：提交的 URL 与 Host 不属于同一域名。" -ForegroundColor Red
            }
        } else {
            Write-Host "[请求状态: $($_.Exception.Message)]" -ForegroundColor Red
            Write-Host "   -> 提示：当前未正式部署或网络限制，请在网站正式上线后再次运行推送。" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "[3/3] 推送操作已执行完毕！" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "重要提示：" -ForegroundColor Yellow
Write-Host "1. 请确保已将密钥文件 $apiKey.txt 上传至网站根目录。"
Write-Host "2. 访问测试: 确保在浏览器中可直接访问 $keyLocation"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""