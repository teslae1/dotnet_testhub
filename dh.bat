@echo off
setlocal enabledelayedexpansion

set "dirList="
set "currentDir=%cd%"

set "index=1"
ECHO ----DOTNET_CLIHUB----
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
    echo b      runs a silent version of dotnet build in the current directory - only printing errors
    echo r      executes dotnet run and exits 
	echo s      executes the first .sln file found in current dir or immediate child dirs
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

if "%userInput%" == "b" (
    dotnet build --nologo -v q --property WarningLevel=0 /clp:ErrorsOnly
    goto loop
)
if "%userInput%" == "r" (
    goto exitloop
)

if "%userInput%" == "s" (
    REM Search for .sln file in current directory
    for %%f in ("%currentDir%\*.sln") do (
        start "" "%%f"
        goto exitloop
    )
    REM Search for .sln file in immediate subdirectories
    for /d %%d in ("%currentDir%\*") do (
        for %%f in ("%%d\*.sln") do (
            start "" "%%f"
            goto exitloop
        )
    )
    echo no .sln file found in current dir or immediate sub dirs
    goto exitloop
)

if "%userInput%" == "dir" (
    :listtestprojects
    for %%d in (!dirList!) do (
        set "lastTestRunMsgVarName=lastTestRunMsg_!index!"
        call set "lastTestRunMsgVal=%%!lastTestRunMsgVarName!%%"
        if !index! lss 10 (
            call echo !index!.  %%d !lastTestRunMsgVal!
        ) else (
            call echo !index!. %%d !lastTestRunMsgVal!
        )
        set /a index+=1
    )
    goto loop
)

REM split user input by space
REM use the first arg as act input
REM if the second arg is "-s" do the silent build thing

for %%d in (!dirList!) do (
    if "%userInput%" == "!index!" (
        dotnet test %%d 
        if !ERRORLEVEL! == 0 (
            set "lastTestRunMsg_!index!=----Passed"
        )  else (
            set "lastTestRunMsg_!index!=----Failed"
        )
        
    ) else (
        echo %%d | findstr /I /C:"%userInput%" >nul
        if not errorlevel 1 (
              dotnet test %%d 
        if !ERRORLEVEL! == 0 (
                  set "lastTestRunMsg_!index!=----Passed"
              )  else (
                  set "lastTestRunMsg_!index!=----Failed"
              )
        )
    )
  if "%userInput:~-2%" == "-s" (
        echo YES
    )
    set /a index+=1
)

goto loop

:exitloop

REM The dotnet run needs to be executed here in order to have minimum amount of ctrl+c (interrupt) presses 
if "%userInput%" == "r" (
    dotnet run || CALL IF EnsureError
)

endlocal


