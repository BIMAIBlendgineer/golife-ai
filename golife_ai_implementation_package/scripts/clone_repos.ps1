New-Item -ItemType Directory -Force -Path source_repos | Out-Null

git clone https://github.com/xpavle00/Habo.git source_repos/habo
git clone https://github.com/manuelernestog/weektodo.git source_repos/weektodo
git clone https://github.com/flow-mn/flow.git source_repos/flow
git clone https://github.com/OpenWardrobe/app.git source_repos/openwardrobe_app
git clone https://github.com/OpenWardrobe/db.git source_repos/openwardrobe_db
git clone https://github.com/leechy/wanna.git source_repos/wanna
git clone https://github.com/IMGIITRoorkee/Taskly.git source_repos/taskly

Write-Output "Repositorios clonados en source_repos/"
