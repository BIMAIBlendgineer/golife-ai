#!/usr/bin/env bash
set -euo pipefail

mkdir -p source_repos

git clone https://github.com/xpavle00/Habo.git source_repos/habo || true
git clone https://github.com/manuelernestog/weektodo.git source_repos/weektodo || true
git clone https://github.com/flow-mn/flow.git source_repos/flow || true
git clone https://github.com/OpenWardrobe/app.git source_repos/openwardrobe_app || true
git clone https://github.com/OpenWardrobe/db.git source_repos/openwardrobe_db || true
git clone https://github.com/leechy/wanna.git source_repos/wanna || true
git clone https://github.com/IMGIITRoorkee/Taskly.git source_repos/taskly || true

echo "Repositorios clonados o ya existentes en source_repos/"
