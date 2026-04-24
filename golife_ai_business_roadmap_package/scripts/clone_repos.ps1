New-Item -ItemType Directory -Force -Path references | Out-Null
Set-Location references

git clone https://github.com/xpavle00/Habo.git Habo
git clone https://github.com/manuelernestog/weektodo.git weektodo
git clone https://github.com/flow-mn/flow.git flow
git clone https://github.com/OpenWardrobe/app.git openwardrobe-app
git clone https://github.com/leechy/wanna.git wanna
git clone https://github.com/IMGIITRoorkee/Taskly.git Taskly

Write-Host "Reference repositories cloned. Start with license and architecture audit."
