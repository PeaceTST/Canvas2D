@rem 0=BAT / 1=First Parameter / d=DRIVE / p=PATH / n=FILE
@echo off
set	vexe=Tools\BootMenu\C2D_BootMenu_x86.exe
set	vpath=Demos\
set	vtitle=CANVAS_2D_MEGADEMO
start "" /B ""%vexe% %vpath% %vtitle%""