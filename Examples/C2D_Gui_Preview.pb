; C2D::Gui Test - Purebasic v6.04

;*******************************************************************
; *** IsC2D the Init-Module, always needed! ************************
;*******************************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"C2D_Types.pbi"
	
	#IsC2D_Clear=	0
	#IsC2D_C2D	=	1
	#IsC2D_Gui	=	-1;#Gui_GadgetTrack|#Gui_GadgetText
	#IsC2D_File		=	1
	#IsC2D_GdiPlus	=	1
	
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;*******************************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

; CanvasGadget, Width & Height
#C2D_G	=	0						; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Zoomed width
#C2D_H	=	340	*	#C2D_Z	; Zoomed height

#RGB_GRAY	=	$AAAAAA	; 0
#RGB_BLACK	=	$000000	; 1
#RGB_WHITE	=	$FFFFFF	; 2
#RGB_BLUE	=	$BB8866	; 3
#RGB_RED		=	$3535DF	; 4
#RGB_GREEN	=	$5AB156	; 5
#RGB_ORANGE	=	$4175DB	; 6
#RGB_YELLOW	=	$13E7EF	; 7

Macro	MA_CF()
	C2D::GuiCopper(PeekI(?c_tbl + SizeOf(Integer) * Random(5)), Random(2))
	C2D::GuiColor(RGB(Random($FF),Random($FF),Random($FF)), RGB(Random($FF),Random($FF),Random($FF)))
	C2D::GuiFrame(Random(7), 255)
EndMacro

Macro	MA_RF()
	C2D::GuiFrame(Random(C2D::#Gui_FrameSunken), Random(255,128))
EndMacro

Procedure	C2D_Gadgets()
	
	Protected	i=0, x=8, y=4, w, h, *Memory
	
	C2D::GuiFree(#PB_All, 0)
	C2D::GuiPaletteInit(?c_palette, 8)
	C2D::GuiFrame(C2D::#Gui_Frame3D, 255)
	C2D::GuiColor(#RGB_BLACK)
	C2D::GuiToggleColor($FF000000|#RGB_GREEN)
	
	*Memory	=	C2D::FileLoad("..\Data\Icon\pencil.ico")	:	C2D::GdipCatch(0, *Memory, MemorySize(*Memory))
	*Memory	=	C2D::FileLoad("..\Data\Icon\rocket.ico")	:	C2D::GdipCatch(1, *Memory, MemorySize(*Memory))
	*Memory	=	C2D::FileLoad("..\Data\Icon\star.ico")		:	C2D::GdipCatch(2, *Memory, MemorySize(*Memory))

	C2D::GuiButtonGadget(0, x, y, 0, 24, "Button Gadget")				:	x	=	C2D::GuiPosX(2)
	C2D::GuiButtonGadget(-1, x, y, 0, 24, "Button + Image + Toggle", C2D::#Gui_FlagToggle, 1, "This is the toggled text")	:	x	=	C2D::GuiPosX(2)
	
	C2D::GuiImageGadget(-1, x, y, 26, 24, Random(2))	:	x	=	C2D::GuiPosX(2)
	C2D::GuiImageGadget(-1, x, y, 28, 24, Random(2), 4)	:	x	=	C2D::GuiPosX(2)
	
	x	=	8	:	y	=	C2D::GuiPosY(6)
	MA_RF()	:	C2D::GuiDrawButtonGadget(-1, x, y, 0, 0, "{TW,128}{TH,91}{YP,8}{UL,1}Draw{UL} Button {FR,"+Str(Random(7,1))+",2,3}Gadget{FR}{YG,5}|{XP,6}{IM,0} Draw|{XP,6}{IM,1}{PF,2}{BD,1} Button{BD}|{XP,6}{IM,2}{PF,4} {SH,$FF}Gadget{SH}")	:	x	=	C2D::GuiPosX(2)
	MA_RF()	:	C2D::GuiDrawButtonGadget(-1, x, y, 0, 0, "{TW,48}{MN,0}Hallo{YG,4}|{MN,1}Hallo|{MN,2}Hallo|{MN,3}Hallo|{MN,4,+}Hallo")	:	x	=	C2D::GuiPosX(2)
	
	MA_RF()	:	C2D::GuiTextGadget(-1, x, y, #C2D_W - x - 242, 0, "Textgadget no #LF$")	:	y	=	C2D::GuiPosY(2)
	MA_RF()	:	C2D::GuiTextGadget(-1, x, y, #C2D_W - x - 242, 0, "Textgadget no #LF$")	:	y	=	C2D::GuiPosY(2)
	MA_RF()	:	C2D::GuiDrawTextGadget(-1, x, y, #C2D_W - x - 242, 0, "{TH,55}DrawTextGadget with{YG,2}|{PF,4}#LF${PF,1}. So {UL,1}use{UL} it  {FR,1,4,1}{PF,2}{ST,255}like{ST}{PF,1}{FR} {YG,2}|you {PF,7}{SH,255}need{SH}{PF,1} it have {BD,1}fun{BD}!")	:	y	=	C2D::GuiPosY(2)
	
	x	=	8	:	y	=	C2D::GuiPosY(6)
	MA_RF()	:	C2D::GuiColor(#RGB_ORANGE)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 300, 20, 0, 1000, C2D::#Gui_Frame3D, C2D::#Gui_FlagNumber)	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(2)
	MA_RF()	:	C2D::GuiColor(#RGB_YELLOW)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 300, 20, 0, 1000, C2D::#Gui_Frame3D, C2D::#Gui_FlagLevel)	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(2)
	MA_RF()	:	C2D::GuiColor(#RGB_GREEN)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 300, 20, 0, 1000, C2D::#Gui_Frame3D, C2D::#Gui_FlagPercent)	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(6)
	
	MA_RF()	:	C2D::GuiCopper(?c_rain, 1)	:	i	=	C2D::GuiProgressGadget(-1, x, y, 300, 20, 1000, Random(C2D::#Gui_FrameSunken))	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(2)
	C2D::GuiCopper()
	MA_RF()	:	C2D::GuiColor(C2D::GuiPaletteGetColor(Random(7)))	:	i	=	C2D::GuiProgressGadget(-1, x, y, 300, 20, 1000, Random(C2D::#Gui_FrameSunken))	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(2)
	MA_RF()	:	C2D::GuiColor(C2D::GuiPaletteGetColor(Random(7)))	:	i	=	C2D::GuiProgressGadget(-1, x, y, 300, 20, 1000, Random(C2D::#Gui_FrameSunken))	:	C2D::GuiSetState(i, Random(1000,100))	:	y	=	C2D::GuiPosY(6)

	C2D::GuiColor(#RGB_BLACK)
	MA_RF()	:	C2D::GuiStringGadget(-1, x, y, 300, 20, "Stringgadget Normal")	:	y	=	C2D::GuiPosY(1)
	MA_RF()	:	C2D::GuiStringGadget(-1, x, y, 300, 20, "Stringgadget Center", C2D::#Gui_FlagCenter)	:	y	=	C2D::GuiPosY(1)
	MA_RF()	:	C2D::GuiStringGadget(-1, x, y, 300, 20, "Stringgadget Right", #ES_RIGHT)		:	y	=	C2D::GuiPosY(-4)
	
	x	=	C2D::GuiPosX(6)	:	h	=	y	:	y	=	4
	MA_RF()	:	C2D::GuiColor(#RGB_ORANGE)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 36, h, 0, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagNumber |C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(2)
	MA_RF()	:	C2D::GuiColor(#RGB_YELLOW)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 36, h, 0, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagLevel  |C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(2)
	MA_RF()	:	C2D::GuiColor(#RGB_GREEN)	:	i	=	C2D::GuiTrackGadget(-1, x, y, 36, h, 0, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagPercent|C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(6)
	
	MA_RF()	:	C2D::GuiColor(C2D::GuiPaletteGetColor(Random(7)))	:	C2D::GuiCopper(?c_glass, 1)	:	i	=	C2D::GuiProgressGadget(-1, x, y, 36, h, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(2)
	MA_RF()	:	C2D::GuiCopper(?c_psy,0)	:	i	=	C2D::GuiProgressGadget(-1, x, y, 36, h, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(2)
	MA_RF()	:	C2D::GuiCopper(?c_rain,0)	:	i	=	C2D::GuiProgressGadget(-1, x, y, 36, h, 1000, Random(C2D::#Gui_FrameSunken), C2D::#Gui_FlagVertical)	:	C2D::GuiSetState(i, Random(1000,100))	:	x	=	C2D::GuiPosX(6)
	
	C2D::GuiCopper()
	
	; *** MENU ***
	C2D::GuiMenuInit(0, "Item 0;Item 1;Item 2;Item 3;Item 4;Item 5;Item 6 {IM,1}")
	
	C2D::GuiRefresh(-1)

EndProcedure

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("GUI Preview / RMB for Popupmenu"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 5, $C8C8C8)	; update every 5ms (default)

C2D_Gadgets()

Repeat
	Select	WaitWindowEvent()
			
		Case	#PB_Event_Gadget
			Gadget	=	EventGadget()
			Select	C2D::GuiEvent(Gadget)
				Case	0	:	C2D_Gadgets()
				Case	1
			EndSelect
			
		Case	#WM_RBUTTONDOWN
			C2D::GuiColor(#RGB_BLACK)
			C2D::GuiFrame(Random(7), 255)
			If	C2D::GuiMenuPopup(0, C2D::#Gui_FlagState|C2D::#Gui_FlagShadow)	>=	0
				C2D::GuiMenuItemSetState(0, C2D::GuiMenuGetItem(0), C2D::GuiMenuItemGetState(0, C2D::GuiMenuGetItem(0))!1)
			EndIf
			
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_F1		:	C2D_Gadgets()
				Case	#VK_ESCAPE	:	Break
			EndSelect
			; 			If	GetAsyncKeyState_(#VK_ESCAPE)	& $8000
			; 				Break
			; 			EndIf
			
		Case	#PB_Event_CloseWindow
			Break

	EndSelect
ForEver

C2D::Free()

DataSection
	
	c_tbl:	:	Data.i	?c_glass, ?c_top, ?c_down, ?c_rain, ?c_cop, ?c_psy	; 6 * sizeof(integer)
	
	c_glass:	:	Data.l	3, $A0FFFFFF, $00FFFFFF, $50FFFFFF
	c_top:	:	Data.l	2, $00000000, $50000000
	c_down:	:	Data.l	2, $50000000, $00000000
	c_rain:	:	Data.l	3, $FF00FF00, $FF00FFFF, $FF0000FF
	c_cop:	:	Data.l	3,	$FF000000, $00000000, $FF000000
	c_psy:	:	Data.l	3,
	      	 	      	$FF000000|#White,
	      	 	      	$FF000000|#Magenta,
	      	 	      	$FF000000|#Blue,
	      	 	      	$FF000000|#Magenta
	
	c_palette:	:	Data.l	#RGB_GRAY,#RGB_BLACK,#RGB_WHITE,#RGB_BLUE,#RGB_RED,#RGB_GREEN,#RGB_ORANGE,#RGB_YELLOW
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = g
; Optimizer
; Executable = ..\Executables\C2D_Gui_Preview_x86.exe
; CompileSourceDirectory