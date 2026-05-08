@rem 0=BAT / 1=First Parameter / d=DRIVE / p=PATH / n#=PARAM#
@cd /d %~dp0
upx_x64.exe -d "%~dpnx1"
@echo off
@pause