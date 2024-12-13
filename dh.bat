@echo off
setlocal enabledelayedexpansion

set "dirList="
set "currentDir=%cd%"

set "index=1"
ECHO ----DOTNET_TESTHUB----
for /r "%cd%" %%d in (.) do (
    if exist "%%d\*test*.csproj" (
        set "relativeDir=%%d"
        set "relativeDir=!relativeDir:%currentDir%=!"
        REM set "relativeDir=!relativeDir:\=!"
        set "relativeDir=!relativeDir:~1!"
        set "relativeDir=!relativeDir:~0,-2!"
        if !index! lss 10 (
            echo !index!.  !relativeDir!
        ) else (
            echo !index!. !relativeDir!
        )
        set "dirList=!dirList! !relativeDir!"
        set /a index+=1
    )
)

:loop

set /p userInput="  >> "

set "index=1"
if "%userInput%" == "" (
    set "userInput=%lastUserInput%"
)
set "lastUserInput=%userInput%"
if "%userInput%" == "?" (
    echo 1      runs dotnet test on the project at index 1
    echo        just pressing enter reruns the last command
    echo mytest runs dotnet test on the first project matching on string contains 
    echo cls    clears screen and lists the detected test projects
    echo dir    lists the detected test projects
    echo q      exits
    echo exit   exits
    echo ?      prints this help menu 
    goto loop
)
if "%userInput%" == "q" (
    goto exitloop
)
if "%userInput%" == "exit" (
    goto exitloop
)
if "%userInput%" == "cls" (
    cls
    goto listtestprojects
)

if "%userInput%" == "dir" (
    :listtestprojects
    for %%d in (!dirList!) do (
        if !index! lss 10 (
            echo !index!.  %%d
        ) else (
            echo !index!. %%d 
        )
        set /a index+=1
    )
    goto loop
)

for %%d in (!dirList!) do (
    if "%userInput%" == "!index!" (
        dotnet test %%d --nologo -v m
    ) else (
        echo %%d | findstr /I /C:"%userInput%" >nul
        if not errorlevel 1 (
              dotnet test %%d --nologo -v m
        )
    )
    set /a index+=1
)

goto loop

:exitloop
endlocal