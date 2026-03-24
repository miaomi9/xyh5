#!/bin/bash
# 推送到GitHub脚本

cd /path/to/docker

git remote remove origin 2>/dev/null
git remote add origin https://liangminmx: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@github.com/liangminmx/xyh5.git
git push -u origin main --force

echo "推送完成!"
