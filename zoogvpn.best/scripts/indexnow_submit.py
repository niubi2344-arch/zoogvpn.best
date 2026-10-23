#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
zoogvpn.best - IndexNow 搜索引擎推送脚本 (Python 3 原生版)
使用 Python 标准库 urllib 构建，无需 pip 安装任何第三方依赖库即可直接运行。
"""

import sys
import json
import urllib.request
import urllib.error

HOST = "zoogvpn.best"
KEY = "e4f1a98c0b2d45e69738c82f10b7a65d"
KEY_LOCATION = f"https://{HOST}/{KEY}.txt"

URL_LIST = [
    f"https://{HOST}/",
    f"https://{HOST}/insights.html",
    f"https://{HOST}/about.html",
    f"https://{HOST}/terms.html",
    f"https://{HOST}/privacy.html",
    f"https://{HOST}/sitemap.html",
]

ENDPOINTS = [
    ("IndexNow 官方中央网关", "https://api.indexnow.org/indexnow"),
    ("Bing (微软必应) 网关", "https://www.bing.com/indexnow"),
]

def submit_indexnow():
    print("=" * 60)
    print("       zoogvpn.best - IndexNow URL 推送工具 (Python 版)     ")
    print("=" * 60)
    print(f"站点域名: {HOST}")
    print(f"API 密钥: {KEY}")
    print(f"密钥路径: {KEY_LOCATION}")
    print(f"待提交 URL 数量: {len(URL_LIST)} 条\n")

    payload = {
        "host": HOST,
        "key": KEY,
        "keyLocation": KEY_LOCATION,
        "urlList": URL_LIST,
    }

    data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    headers = {
        "Content-Type": "application/json; charset=utf-8",
        "User-Agent": f"IndexNowSubmitter/{HOST}",
    }

    for name, endpoint in ENDPOINTS:
        print(f"正在提交至 {name} ({endpoint})...", end="", flush=True)
        req = urllib.request.Request(endpoint, data=data, headers=headers, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=15) as response:
                status_code = response.getcode()
                if status_code in (200, 202):
                    print(f" [成功 - HTTP {status_code}]")
                else:
                    print(f" [返回状态 - HTTP {status_code}]")
        except urllib.error.HTTPError as e:
            print(f" [HTTP 错误: {e.code} {e.reason}]")
            if e.code == 403:
                print(f"  -> 提示：密钥验证未通过，请确认公网能正常访问 {KEY_LOCATION}")
            elif e.code == 422:
                print(f"  -> 提示：URL 列表中的域名与 host ({HOST}) 不匹配。")
        except urllib.error.URLError as e:
            print(f" [网络错误: {e.reason}]")
            print("  -> 提示：若当前处于离线开发环境，请在站点部署到公网后再行执行。")

    print("\n" + "=" * 60)
    print("执行完成！")
    print("=" * 60)

if __name__ == "__main__":
    submit_indexnow()
