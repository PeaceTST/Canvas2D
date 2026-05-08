@rem 0=BAT / 1=First Parameter / d=DRIVE / p=PATH / n#=PARAM#
@cd /d %~dp0
PowerPack_x86.exe "%~dpnx1" "%~dpnx1.pp" -c -e=5 -o
@echo off
@pause