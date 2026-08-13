#!/usr/bin/env bash
set -euo pipefail

mkdir -p references
cd references

git clone https://github.com/xpavle00/Habo.git Habo || true
git clone https://github.com/manuelernestog/weektodo.git weektodo || true
git clone https://github.com/flow-mn/flow.git flow || true
git clone https://github.com/OpenWardrobe/app.git openwardrobe-app || true
git clone https://github.com/leechy/wanna.git wanna || true
git clone https://github.com/IMGIITRoorkee/Taskly.git Taskly || true

echo "Reference repositories cloned. Start with license and architecture audit."
