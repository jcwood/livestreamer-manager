@echo off

setlocal enabledelayedexpansion
title=Livestreamer Stream Manager
mode con: cols=80 lines=40

:: Globals
set menu.selected=1

for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A

call:init

:menu
	cls
	echo.
	echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	
	set /a menu.index=1
	set /a menu.add=!menu.options!+!menu.index!
	set /a menu.index+=1
	
	call:buildChoiceList menu.choiceList !menu.options!
	
	if !menu.options! gtr 0 (
		set /a menu.delete=!menu.options!+!menu.index!
		set /a menu.index+=1
	)
	
	set /a menu.quit=!menu.options!+!menu.index!
	
	if !menu.options! gtr 0 (
		echo  บ                                                                            บ
		echo  บ          Stream                                              Quality       บ
		echo  บ          --------------------------------------------------  ------------  บ
	
		set streamIndex=0
		set /a streamEndIndex=!menu.options!-1
		
		for /l %%a in (0,1,!streamEndIndex!) do (
			set stream.content=!livestreams[%%a]!
			set /a streamPos=%%a+1	
			set col=0
			
			for %%s in (!stream.content!) do (
				if !col! equ 1 (set stream.url=%%s)
				if !col! equ 2 (set stream.quality=%%s)
				set /a col+=1
			)
			
			call:getStringLength stream.url.length "!stream.url!"
			call:getStringLength stream.quality.length "!stream.quality!"
			call:getSpaces urlSpaces 49-!stream.url.length!
			call:getSpaces qualitySpaces 13-!stream.quality.length!
			
			set selectedChar= 
			if !streamPos! EQU !menu.selected! (
				set selectedChar=*
			)
			
			echo  บ  !streamPos!. ^(!selectedChar!^)  !stream.url! !urlSpaces!  !stream.quality! !qualitySpaces!บ
		)
		
		echo  บ                                                                            บ
	)
	
	echo  บ                                                                            บ
	echo  บ  Instructions                                                              บ
	echo  บ  ------------                                                              บ
	echo  บ                                                                            บ
	
	if !menu.options! gtr 1 (
		call:printMenuLine "  [1-!menu.options!] select a stream"
		echo  บ                                                                            บ
	)
	
	echo  บ   [a] add stream                                                           บ
	
	if !menu.options! gtr 1 (
		echo  บ   [d] delete selected stream                                               บ
	)
	
	if !menu.options! equ 1 (
		echo  บ   [d] delete stream                                                        บ
	)
	
	if !menu.options! gtr 1 (echo  บ   [q] quit                                            ^(*^) Selected Stream  บ)
	if !menu.options! lss 2 (echo  บ   [q] quit                                                                 บ)
		
	echo  บ                                                                            บ
	echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	
	choice /C !menu.choiceList! /n /M ".%BS% Choice: "
	
	if ERRORLEVEL !menu.quit! goto end
	
	if !menu.options! gtr 0 (
		if ERRORLEVEL !menu.delete! goto deleteSelectedStream
    )

	if ERRORLEVEL !menu.add! goto addStream
	
	for /L %%c IN (!menu.options!,-1,1) do (
		if ERRORLEVEL %%c (
			set /a menu.selected=%%c
			goto menu
		)
	)
	
:addStream
	set new.url=
	set new.quality=
	
	:addStreamInner
	cls
	echo.
	echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo  บ                              Add a Stream                                  บ
	echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo  1. What is the stream you'd like to add? (eg: twitch.tv/cosmowright)
	echo.

	if "!new.url!" == "" (
		set /p new.url=.%BS% ^> 
	) else (
		echo  ^> !new.url!
	)
	
	:: Make sure we've specified something
	if "!new.url!" == "" (goto menu)
	
	:: Check if the stream is already in the list
	for /l %%a in (0,1,!menu.options!-1) do (
		set /a col=0
	
		for %%b in (!livestreams[%%a]!) do (
			if !col! EQU 1 (
				if "%%b" == "!new.url!" (
					echo.
					echo ERROR: Stream already in your list!
					pause
					goto menu
				)
			)
			set /a col+=1
		)
	)
	
	echo.
	echo  2. What is the quality you'd like?
	echo.
	
	if "!new.quality!" == "" (
		echo    [b] best ^(source^)
		echo    [h] high
		echo    [m] medium
		echo    [l] low
		echo    [w] worst ^(mobile^)
		echo    [a] audio
		echo.
		
		choice /C bhmlwa /n /M " Choice: "
		
		if ERRORLEVEL 6 (set new.quality=audio&goto addStreamInner)
		if ERRORLEVEL 5 (set new.quality=worst&goto addStreamInner)
		if ERRORLEVEL 4 (set new.quality=low&goto addStreamInner)
		if ERRORLEVEL 3 (set new.quality=medium&goto addStreamInner)
		if ERRORLEVEL 2 (set new.quality=high&goto addStreamInner)
		if ERRORLEVEL 1 (set new.quality=best&goto addStreamInner)
	)

	echo  ^> !new.quality!
	echo.
	
	choice /C yn /n /M ".%BS% 3. Is this correct? [Y/N]: "
	
	if ERRORLEVEL 2 goto menu
	
	call:writeStream "!new.url!" "!new.quality!"
	call:init
	
	goto menu
	
	echo.
goto:eof

:writestream
	:: Build filename from stream url
	set ws.url=%~1
	set ws.quality=%~2
	set ws.urlPrefix=!ws.url:.=!
	set ws.filename=livestream-!ws.urlPrefix:/=-!.bat
		
	echo livestreamer !ws.url! !ws.quality! > !ws.filename!
goto:eof

:deleteSelectedStream 
	cls
	echo.
	echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo  บ                            Delete a Stream                                 บ
	echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	
	set /a selectedIndex=!menu.selected!-1
	
	for /l %%i IN (0,1,!menu.options!-1) do (
		set /a col=0
		
		if %%i equ !selectedIndex! (
			for %%a in (!livestreams[%%i]!) do (
				if !col! equ 0 (set stream.file=%%a)
				if !col! equ 1 (
					choice /C yn /n /M ".%BS% Are you sure you want to delete %%a? [Y/N] "
					
					if ERRORLEVEL 2 goto menu
					
					set toDelete=!stream.file:%20= !
					
					del "!toDelete!"
					set /a menu.selected=1
					
					call:init
					goto menu
				)
				set /a col+=1
			)
		)
	)
	
goto:eof
	
:init
	set livestreams=
	set menu.options=0
	set streamIndex=0
	
	for /r %%i IN (livestream-*.bat) do (
		set stream.file=%%i
		set /p stream.contents=<!stream.file!
		set /a col=0
		
		for %%a in (!stream.contents!) do (
			if !col! equ 1 (set stream.url=%%a)
			if !col! equ 2 (set stream.quality=%%a)
			set /a col+=1
		)

		set livestreams[!streamIndex!]=!stream.file: =%20! !stream.url! !stream.quality!		
		set /a streamIndex+=1
	)
	
	set /a menu.options=!streamIndex!
goto:eof

:buildChoiceList
	set #=
	for /l %%i in (1,1,%~2) do (
		set #=!#!%%i
	)
	set "%~1=!#!adq"
goto:eof
	
:printMenuLine
	set line=%~1
	call:getStringLength length "%line%"
	set /a length=74-%length%
	call:getSpaces spaces %length%
	echo  บ %line% %spaces%บ
goto:eof

:getStringLength
	set #=%~2%
	set /a length=0
	:stringLengthLoop
	if defined # (set #=%#:~1%&set /a length += 1&goto stringLengthLoop)
	set "%~1=%length%"
goto:eof

:getSpaces
	set #=%2%
	set spaces= 
	:spaceLoop
	if %#% gtr 1 (set /a #=%#%-1&set spaces=%spaces% &goto spaceLoop)
	set "%~1=%spaces%"
goto:eof

:end
	exit