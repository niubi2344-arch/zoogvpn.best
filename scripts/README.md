# zoogvpn.best - IndexNow 搜索引擎推送脚本包

本文件夹包含用于向微软 Bing、Yandex、Naver 等支持 IndexNow 开放协议的搜索引擎自动推送网站最新 URL 列表的工具。

## 📁 文件清单

1. **`indexnow_submit.bat`**：Windows 一键批处理启动脚本。电脑即使**未安装 Python 环境**也可以直接双击运行！它将调用系统自带的 PowerShell 核心完成安全推送。
2. **`indexnow_submit.ps1`**：Windows 原生 PowerShell 推送脚本，支持彩色控制台提示与详细的 HTTP 状态码诊断。
3. **`indexnow_submit.py`**：跨平台 Python 3 提交脚本，使用原生 `urllib` 标准库编写，无需额外 `pip install` 任何第三方包。
4. **`e4f1a98c0b2d45e69738c82f10b7a65d.txt`**：IndexNow 验证密钥文件（此文件也已放置在网站根目录下）。

## 🚀 使用方法

### 方法一（Windows 最简推荐，双击即用）：
- 直接在文件管理器中**双击运行 `indexnow_submit.bat`** 即可。

### 方法二（PowerShell 手动执行）：
```powershell
powershell -ExecutionPolicy Bypass -File .\indexnow_submit.ps1
```

### 方法三（Python 环境执行）：
```bash
python indexnow_submit.py
```

## ⚠️ 上线注意事项
1. 网站正式部署到服务器后，请确保可以在浏览器中正常打开：
   `https://zoogvpn.best/e4f1a98c0b2d45e69738c82f10b7a65d.txt`
   搜索引擎在接收到提交后，会自动访问该文件以验证域名所有权。
2. 首次提交后，搜索引擎通常会在几分钟到数小时内对已提交的新页面进行快速爬取并建立索引。
