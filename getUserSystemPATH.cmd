@echo off
setlocal enableDelayedExpansion
REM New and Updated Version++
REM Listing directories in User PATH variable
REM Listing directories in System PATH variable
REM Adding a directory path to the User Environment variable %path%
REM Adding a directory path to the System Environment variable %path%
REM Using registry queries
REM To change system PATH you have to run this script as administrator
REM User PATH > HKCU\Environment
REM System PATH > HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment

set "User=HKCU\Environment"
set "System=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

:head
call:menu
set /p choice="Enter your choice here: "
if "%choice%"=="1" (call:typePATH User & pause & goto:head)
if "%choice%"=="2" (call:typePATH System & pause & goto:head)
if "%choice%"=="3" (call:addToPathPrompt User & goto:head)
if "%choice%"=="4" (call:addToPathPrompt System & goto:head)
if "%choice%"=="5" (call:deleteFromPath User & goto:head)
if "%choice%"=="6" (call:deleteFromPath System & goto:head)
if "%choice%"=="0" exit
goto:eof

:typePATH
	REM Outputting the value of PATH variable (User | System)
	setlocal
	set index=1
	cls
	echo %1 PATH variable
	echo.
	for /f "tokens=2* delims= " %%i in ('reg query "!%1!" /v path ^| findstr /i "REG"') do set "_path=%%j"
	:loopType
		if "%_path%"=="" goto:eof
		for /f "delims=; tokens=1*" %%i in ("%_path%") do (
			echo [!index!]	%%i
			set /a index+=1
			set "_path=%%j"
		)
		if "%index%"=="1" (
			echo No directory instances are found in %1 PATH
			pause
			goto:eof
		)
	goto:loopType
goto:eof
	
:deleteFromPath
	setlocal
	set index=1
	cls
	echo %1 PATH variable
	echo.
	for /f "tokens=2* delims= " %%i in ('reg query "!%1!" /v path ^| findstr /i "REG"') do set "_path=%%j"
	if "%_path:~-1%"==";" (
		set pathToPaste=%_path%
	) else (
		set pathToPaste=%_path%;
	)
	:loopDelete
		if "%_path%"=="" goto:prompt
		for /f "delims=; tokens=1*" %%i in ("%_path%") do (
			echo [%index%]	%%i
			set item[%index%]=%%i;
			set "_path=%%j"
			set /a index=!index!+1
		)
	goto:loopDelete
	:prompt
	echo.
	set /p itemsToDelete="Enter the index of a directory you want to delete: "
	set itemToDelete=!item[%itemsToDelete%]!
	set pathToPaste=!pathToPaste:%itemToDelete%=!
	reg add  "!%1!" /v path /t "REG_EXPAND_SZ" /d "%pathToPaste%" /f
	pause
goto:eof

:addToPathPrompt
	REM Prompt to get an input from user which variable to change and what path to append
	REM First argument (%1) is the type of the environment variable [userPath | systemPath]
	setlocal
	:userPrompt
	cls
	set /p newPath="Enter a path you want to add to the %1 Variable (type exit to quit) : "
	if not defined newPath (
		echo You must enter non empty path 
		pause
		goto:userPrompt
	)
	if /i "%newPath%"=="exit" goto:eof
	if not exist "%newPath%" (
		echo The path you are trying to add doesn't exist
		pause
		goto:userPrompt
	)
	call:addToPath "!%1!" "%newPath%"
	pause
goto:eof

:addToPath
	setlocal
	REM Adds a path to specified PATH variable
	REM First argument (%1) is a PATH to which you want to append a new path
	REM Second argument (%2) is a directory path you want to append to the existing PATH variable
	for /f "tokens=2* delims= " %%i in ('reg query %1 /v path ^| findstr /i "REG"') do set "oldPath=%%j"
	reg add  %1 /v path /t "REG_EXPAND_SZ" /d "%oldPath%;%~2" /f
goto:eof

:menu
	REM Start menu
	cls
	color 0A
	echo Environment PATH variables controller.
	echo.
	echo Type the appropriet letter to choose the command
	echo [1] Show User PATH variable
	echo [2] Show System PATH variable
	echo [3] Add to User PATH variable
	echo [4] Add to System PATH variable
	echo [5] Delete from User PATH variable
	echo [6] Delete from System PATH variable
	echo [0] Quit the program
goto:eof