:: /* Build script for Windows.
:: *
:: *  @Require tools: 7zip
:: *  @author: kilfu0701
:: */
@echo off

set zipCmd=7z.exe
set ROOTDIR=%cd%

:argsParse
IF NOT "%1"=="" (
  IF "%1"=="-set-7z-path" (
    SET zipCmd=%2
    SHIFT
  )
  SHIFT
  GOTO :argsParse
)

if not exist %zipCmd% (
  echo ** Error: Command '%zipCmd%' not found.
  echo If you have 7zip in your computer, try use:
  echo   build.bat -set-7z-path "C:\xxx\7z.exe"
  pause
  goto :eof
)

if exist "nicofox.xpi" (
  del /F nicofox.xpi
)
if exist build (
  rmdir /Q /S build
)

echo "Generating directories..."

mkdir build
mkdir build\content
mkdir build\skin
mkdir build\components
mkdir build\modules
mkdir build\defaults
mkdir build\defaults\preferences
mkdir build\locale

echo "Copy files..."

:: Copy all scripts, images and stylesheets
for %%I in (install.rdf chrome.manifest LICENSE.md) do copy %%I build\ > nul
for %%I in (content\*.js content\*.xul content\*.xml content\*.swf) do copy %%I build\content\ > nul
for %%I in (skin\*.css skin\*.png) do copy %%I build\skin\ > nul
for %%I in (components\*.js) do copy %%I build\components\ > nul
for %%I in (modules\*.jsm) do copy %%I build\modules\ > nul
for %%I in (defaults\preferences\*.js) do copy %%I build\defaults\preferences\ > nul

FOR /F "tokens=*" %%G IN ('dir /b locale\*') DO @call :copyLocale %%G

echo Generate XPI file...
cd build
%zipCmd% a -tzip "%ROOTDIR%\nicofox.xpi" "%ROOTDIR%\build\*"
echo Cleanup...
cd ..
rmdir /Q /S build
echo Done!
pause

@echo on


:copyLocale
@echo off
set entry=%~n1
if exist locale\%entry% (
  if [%entry%] neq [] (
    set from_paths=locale\%entry%\*.dtd locale\%entry%\*.properties
    set to_path=build\locale\%entry%
    mkdir %to_path%
    for %%I in (%from_paths%) do copy %%I %to_path% > nul
  )
)