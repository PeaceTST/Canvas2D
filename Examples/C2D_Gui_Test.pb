; C2D::Gui Test - Purebasic v6.04

;*******************************************************************
; *** IsC2D the Init-Module, always needed! ************************
;*******************************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"C2D_Types.pbi"
	
	#IsC2D_Clear=	0
	#IsC2D_C2D	=	1
	#IsC2D_Gui	=	#Gui_GadgetTrack|#Gui_GadgetText
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

Macro	MA_CF()
	C2D::GuiCopper(PeekI(?c_tbl + SizeOf(Integer) * Random(5)), Random(2))
	C2D::GuiColor(RGB(Random($FF),Random($FF),Random($FF)), RGB(Random($FF),Random($FF),Random($FF)))
	C2D::GuiFrame(Random(7), 255)
EndMacro

Procedure	C2D_Gadgets()
	
	Protected	i=0, x=8, y=4
	
	C2D::GuiFree(#PB_All, 0)

	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 35, #C2D_H - 2 * y, 0, 70, Random(7), C2D::#Gui_FlagNumber|C2D::#Gui_FlagVertical)
	
	x	=	C2D::GuiPosX(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 35, 200+Random(100), 0, 70, Random(7), C2D::#Gui_FlagLevel|C2D::#Gui_FlagVertical)

	x	=	C2D::GuiPosX(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 35, 200+Random(100), 0, 170, Random(7), C2D::#Gui_FlagNumber|C2D::#Gui_FlagVertical)
	
	x	=	C2D::GuiPosX(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 910000, Random(7), C2D::#Gui_FlagNumber)
	
	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 99999, Random(7), C2D::#Gui_FlagLevel)
	
	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 100, Random(7), C2D::#Gui_FlagPercent)
	
	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 1100, Random(7), C2D::#Gui_FlagPercent)
	
	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 100, Random(7), C2D::#Gui_FlagPercent)

	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 250+Random(150), 30, 0, 100, Random(7), C2D::#Gui_FlagPercent)
	
	y	=	C2D::GuiPosY(8)
	MA_CF()	:	C2D::GuiTrackGadget(-1, x, y, 45+Random(1), 20, 0, 1, Random(7), C2D::#Gui_FlagNumber)
	
	C2D::GuiColor(#Black, #White)
	MA_CF()	:	C2D::GuiTextGadget(1, x, C2D::GuiPosY(8), 64, 20, "?", C2D::#Gui_FlagCenter)
	
	C2D::GuiRefresh(-1)

EndProcedure

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("GUI Test / Press F1"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
DisableGadget(#C2D_G, 1)

C2D::Init(#C2D_G, 5, $C8C8C8)	; update every 5ms (default)

C2D_Gadgets()

Repeat
	Select	WaitWindowEvent()
			
		Case	#PB_Event_Gadget
			Gadget	=	EventGadget()
			If	C2D::GuiEvent(Gadget)
				C2D::GuiSetText(1, Str(C2D::GuiGetState(Gadget)))
			EndIf

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_F1		:	C2D_Gadgets()
				Case	#VK_ESCAPE	:	Break
			EndSelect
; 			If	GetAsyncKeyState_(#VK_ESCAPE)	& $8000
; 				Break
; 			EndIf

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
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = 5
; Executable = ..\Executables\C2D_Gui_Test_x86.exe
; CompileSourceDirectory