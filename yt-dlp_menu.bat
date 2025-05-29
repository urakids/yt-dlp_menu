@ECHO OFF
SETLOCAL enabledelayedexpansion
cd %~dp0
rem =====================================================
IF NOT EXIST yt-dlp.exe (
	cls
	echo yt-dlpをDL
	if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
		echo "64bit OS"
    	powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'yt-dlp.exe'"
	) else (
		echo "32bit OS"
    	powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_x86.exe' -OutFile 'yt-dlp.exe'"
	)
)

IF NOT EXIST ffmpeg.exe (
	cls
	echo ffmpegをDL
	echo ファイルサイズが大きいので時間が掛かります。
	powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'"
	powershell -Command "Expand-Archive -LiteralPath 'ffmpeg.zip' -DestinationPath './' -Force"
	:: ffmpeg-*-essentials_build フォルダを探す
	for /d %%D in ("ffmpeg-*-essentials_build") do (
    	set "FFMPEGDIR=%%D"
	)
	:: bin\ffmpeg.exe をカレントフォルダにコピー
	if exist "!FFMPEGDIR!\bin\ffmpeg.exe" (
    	copy /Y "!FFMPEGDIR!\bin\ffmpeg.exe" ".\" >NUL
	) else (
    	echo ffmpeg.exe が見つかりませんでした。
    	pause
    	exit
	)
	if exist "!FFMPEGDIR!\bin\ffprobe.exe" (
		copy /Y "!FFMPEGDIR!\bin\ffprobe.exe" ".\" >NUL
	) else (
		echo ffprobe.exe が見つかりませんでした。
		pause
		exit
	)
	rmdir /s /q !FFMPEGDIR!
	del /q ffmpeg.zip
)
rem =====================================================
rem =====================================================
:MENU
cls
echo 1) List
echo 2) DL movie
echo 3) DL mp3
echo 4) yt-dlp UpdateCheck
echo 0) exit
SET /p menu="choice mode[0-3]>>>"
IF %menu%==1 GOTO LIST
IF %menu%==2 GOTO DLMOVEI
IF %menu%==3 GOTO DLAUDIO
IF %menu%==4 GOTO UPDATE
IF %menu%==0 GOTO EXIT
GOTO :MENU

rem =====================================================
:LIST
CLS
echo list
SET /p url="URL>>>"
yt-dlp.exe -F %url%
pause
GOTO :MENU

rem =====================================================
:DLMOVEI
echo DLMOVE
SET /p url="URL>>>"
SET /p th="スレッド数>>>"

echo "%url%" | find "http" >NUL
if not ERRORLEVEL 1 goto MVDL
set url=%~dp0%url%
yt-dlp.exe -f "bestvideo+bestaudio/best" -N %th% -a %url%
pause
GOTO :MENU

:MVDL
yt-dlp.exe -f "bestvideo+bestaudio/best" -N %th% %url%
pause
GOTO :MENU

rem =====================================================
:DLAUDIO
echo DLAUDIO
SET /p url="URL>>>"
SET /p th="スレッド数>>>"
SET /p tn="サムネイル[0:false 1:true]>>>"
IF %tn%==0 SET ts=
IF %tn%==1 SET ts=--write-thumbnail --embed-thumbnail
echo "%url%" | find "http" >NUL
if not ERRORLEVEL 1 goto ADDL
set url=%~dp0%url%
yt-dlp.exe -x -f "ba" --audio-format mp3 --audio-quality 0 -N %th% %ts% -a %url%
pause
GOTO :MENU

:ADDL
yt-dlp.exe -x -f "ba" --audio-format mp3 --audio-quality 0 -N %th% %ts% %url%
pause
GOTO :MENU
rem =====================================================
:UPDATE
ECHO update check...
yt-dlp.exe -U
pause
GOTO :MENU
rem =====================================================
:EXIT
