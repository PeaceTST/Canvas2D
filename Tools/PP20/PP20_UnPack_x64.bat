@rem 0=BAT / 1=First Parameter / d=DRIVE / p=PATH / n#=PARAM#
@cd /d %~dp0
PowerPack_x64.exe "%~dpnx1" "%~dpnx1.up" -d
@echo off
@pause