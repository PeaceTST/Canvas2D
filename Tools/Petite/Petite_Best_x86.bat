@rem 0=BAT / 1=First Parameter / d=DRIVE / p=PATH / n=FILE
@cd /d %~dp0
petite.exe -y "%~dpnx1" -v0 -r** -e2 -9
@echo off
@pause