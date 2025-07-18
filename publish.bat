@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo 正在读取版本号...

REM 提取版本号字段（使用 findstr 定位 version 行）
for /f "tokens=2 delims=:," %%i in ('findstr /c:"\"version\"" package.json') do (
    set "version=%%~i"
)

REM 去除引号和空格
set "version=%version:"=%"
set "version=%version: =%"

REM 拆分版本号 x.y.z
for /f "tokens=1,2,3 delims=." %%a in ("%version%") do (
    set /a major=%%a
    set /a minor=%%b
    set /a patch=%%c
)

REM 版本号加一逻辑
set /a patch+=1
if !patch! GEQ 10 (
    set /a patch=0
    set /a minor+=1
)
if !minor! GEQ 10 (
    set /a minor=0
    set /a major+=1
)

REM 构建新的版本号，保持格式
set "new_version=!major!.!minor!.!patch!"

echo 当前版本号：%version%
echo 新版本号：!new_version!

REM 修改 package.json 中的 version 字段
(for /f "delims=" %%l in (package.json) do (
    set "line=%%l"
    echo !line! | findstr /c:"\"version\"" >nul
    if !errorlevel! == 0 (
        echo     "version": "!new_version!",
    ) else (
        echo !line!
    )
)) > package.tmp.json

move /y package.tmp.json package.json > nul

echo 正在发布到 npm...
npm publish

pause
