; C2D::Gui / Gadgets - Purebasic v6.04
; ultra hard-coded -> for test only!

;UsePNGImageDecoder()

;*******************************************************************
; *** IsC2D the Init-Module, always needed! ************************
;*******************************************************************
IncludePath	"..\Include\"	; adapt path of include

DeclareModule	IsC2D	; Defaults -> all on!

	XIncludeFile	"C2D_Types.pbi"

	#IsC2D_Gui		=	-1
	;#IsC2D_SysFont	=	1
	#IsC2D_File		=	1
	#IsC2D_GdiPlus	=	1
	;#IsC2D_Stars3D	=	1
	
	XIncludeFile	"C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"C2D_Module.pbi"
;*******************************************************************

; Zoom-Factor (or set in C2D_Compiler)
CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1
CompilerEndIf

; CanvasGadget, Width & Height
#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; zoomed width
#C2D_H	=	440	*	#C2D_Z	; zoomed height

#RGB_WINDOW	=	#White-$505050;$593F35;$58514E;$AF8F6F

#RGB_GRAY	=	$AAAAAA	; 0
#RGB_BLACK	=	$000000	; 1
#RGB_WHITE	=	$FFFFFF	; 2
#RGB_BLUE	=	$BB8866	; 3
#RGB_RED		=	$3535DF	; 4
#RGB_GREEN	=	$5AB156	; 5
#RGB_ORANGE	=	$4175DB	; 6
#RGB_YELLOW	=	$13E7EF	; 7

Enumeration	10	Step	20
	#ID_TOGGLE
	#ID_FRAME
	#ID_MENU0
	#ID_MENU1
	#ID_IMAGE
	#ID_PROGRESS
	#ID_TRACK
	#ID_TEXT
	#ID_STRING
	#ID_CONTAINER
EndEnumeration

Procedure	Range(a, min, max)
	If	a	<	min
		a	=	max
	ElseIf	a	>	max
		a	=	min
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure	RGB_Back()
	C2D::GuiColor(#PB_Ignore, RGB($80|Random($7F), $80|Random($7F), $80|Random($7F)))
	;C2D::GuiColor(#PB_Ignore, $58514E+$1F1F1F)
EndProcedure
Procedure	RGB_Front()
	C2D::GuiColor(RGB($80|Random($7F), $80|Random($7F), $80|Random($7F)))
	;C2D::GuiColor(#PB_Ignore, $58514E)
EndProcedure

Procedure	C2D_Init()
	
	Protected	ID, x, y, w, *Memory
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("GUI / Gadgets"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H, #PB_Canvas_Container)
	
	C2D::Init(#C2D_G, 15, #RGB_WINDOW)
	C2D::Quality(0)
	C2D::GuiInit()
	C2D::GuiPaletteInit(?c_palette, 8)
	
	*Memory	=	C2D::FileLoad("..\Data\Icon\pencil.ico")		:	C2D::GdipCatch(0, *Memory, MemorySize(*Memory))
	*Memory	=	C2D::FileLoad("..\Data\Icon\rocket.ico")		:	C2D::GdipCatch(1, *Memory, MemorySize(*Memory))
	*Memory	=	C2D::FileLoad("..\Data\Logo\Testaware.png")	:	C2D::GdipCatch(2, *Memory, MemorySize(*Memory))
	*Memory	=	C2D::FileLoad("..\Data\Logo\X-Out_logo.png")	:	C2D::GdipCatch(3, *Memory, MemorySize(*Memory))
	
	x	=	(#C2D_W - ImageWidth(2)) / 2	:	y	=	4
	
	C2D::GuiColor(#Black, #RGB_WINDOW)
	C2D::GuiImageGadget(#ID_IMAGE, x, y, 0, 0, 2)	:	y	=	C2D::GuiPosY(2)
	
	C2D::GuiLine(0, y, #C2D_W)	;:	C2D::GuiLine(3 * 55 + 2, y+1, 83, 0, C2D::#Gui_FlagVertical)
	y	+	8
	
	;LoadFont(0, "Arial", 7)	:	C2D::GuiFont(FontID(0))
	
	x	=	2
	
	; ********************************************************
	; *** TOGGLE BUTTON ***
	; ********************************************************
	C2D::GuiColor(0, C2D::#Gui_DefBackColor)
	C2D::GuiCopper(?c_glass)
	C2D::GuiFrame(C2D::#Gui_FrameNone)
	C2D::GuiButtonGadget(#ID_TOGGLE, 2, y, 3 * 56 - 1, 0, "Swap Disable", 0, Random(1))	:	y	=	C2D::GuiPosY(2)
	i	=	Random(C2D::#Gui_FrameSunken)
	C2D::GuiCopper(?c_top)
	For	ID	=	#ID_TOGGLE	+	1	To	#ID_TOGGLE	+	6
		If	ID	=	#ID_TOGGLE	+	4
			x	=	2	:	y	=	C2D::GuiPosY(2)
			C2D::GuiCopper(?c_down)
		EndIf
		RGB_Back()
		i	=	Range(i + 1, C2D::#Gui_FrameNone, C2D::#Gui_FrameSunken)
		C2D::GuiFrame(i)
		C2D::GuiDrawButtonGadget(ID, x, y, 54, 22, "Button " + Str(ID), C2D::#Gui_FlagToggle, "{XO,3}Down " + Str(ID))
		x	=	C2D::GuiPosX(2)
	Next
	
	x	=	C2D::GuiPosX(3)
	y	=	GadgetY(#ID_TOGGLE)
	
	; ********************************************************
	; *** FRAME BUTTON ***
	; ********************************************************
	ID	=	#ID_FRAME
	C2D::GuiColor(0, C2D::#Gui_DefBackColor)
	C2D::GuiCopper(?c_glass)
	C2D::GuiFrame(C2D::#Gui_FrameNone)
	C2D::GuiButtonGadget(#ID_FRAME, x, y, #C2D_W*0.70 - x - 2, 0, "Swap States", 0, Random(1))	:	x	=	C2D::GuiPosX()
	C2D::GuiButtonGadget(#ID_MENU0, x, y, #C2D_W*0.15, 0, "MENU 0", 0, Random(1))	:	x	=	C2D::GuiPosx()
	C2D::GuiButtonGadget(#ID_MENU1, x, y, #C2D_W*0.15, 0, "MENU 1", 0, Random(1))	:	y	=	C2D::GuiPosY(2)
	x	=	GadgetX(#ID_FRAME)
	C2D::GuiCopper(?c_top)
	;C2D::GuiOffset(-16, -14, -10, -4)
	For	i	=	C2D::#Gui_FrameNone	To	C2D::#Gui_FrameSunken
		Select	i
			Case	C2D::#Gui_FrameNone	:	t$	=	"None"	:	toggle$	=	"Toggle"
			Case	C2D::#Gui_FrameFine	:	t$	=	"Fine"	:	toggle$	=	"Toggle"
			Case	C2D::#Gui_FrameFlat	:	t$	=	"Flat"	:	toggle$	=	"Toggle"
			Case	C2D::#Gui_FrameLite	:	t$	=	"Lite"	:	toggle$	=	"Toggle"
			Case	C2D::#Gui_Frame3D		:	t$	=	"3D"		:	toggle$	=	"Toggle"
			Case	C2D::#Gui_FrameRised	:	t$	=	"Rised"	:	toggle$	=	"Toggle"
			Case	C2D::#Gui_FrameSunken:	t$	=	"Sunken"	:	toggle$	=	"Toggle"
		EndSelect
		RGB_Back()
		C2D::GuiFrame(i)
		ID	+	1	:	C2D::GuiButtonGadget(ID, x, y, 54-Bool(i=C2D::#Gui_FrameSunken)*7, 2 * C2D::#Gui_DefHeight + 2, t$, C2D::#Gui_FlagToggle|C2D::#Gui_FlagVertical,	Random(1), toggle$)
		x	=	C2D::GuiPosX(1)
	Next
	;C2D::GuiOffset()
	
	y	=	C2D::GuiPosY(6)
	
	C2D::GuiColor(0, #RGB_WINDOW)	:	C2D::GuiLine(0, y, #C2D_W, 0, 0)	:	y	+	8
	
	x	=	2
	
	; ********************************************************
	; *** TEXT ***
	; ********************************************************
	ID	=	#ID_TEXT
	w	=	(#C2D_W	-	2	*	x	-	12)	/	6
	ID	+	0	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiTextGadget(-1, x, y, w, 0, "Text Normal")		:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiFrame(C2D::#Gui_Frame3D)		:	C2D::GuiTextGadget(-1, x, y, w, 0, "Text Border")		:	x	=	C2D::GuiPosX(2)
	ID	+	2	:	C2D::GuiFrame(C2D::#Gui_FrameFlat)	:	C2D::GuiDrawTextGadget(-1, x, y, w, 0, "{IM,1,6} DrawText|{XP,20}Flat + Icon")	:	x	=	C2D::GuiPosX(2)
	ID	+	3	:	C2D::GuiFrame(C2D::#Gui_FrameLite)	:	tID=C2D::GuiDrawTextGadget(-1, x, y, w, 0, "{YG,1}DrawText|{CF,$FFFFFF}{CB,$FF} Lorem {CB}{CF}|et {BD,1}iPsum{BD}", C2D::#Gui_FlagCenter)		:	x	=	C2D::GuiPosX(2)
	ID	+	4	:	C2D::GuiFrame(C2D::#Gui_FrameRised)	:	C2D::GuiDrawTextGadget(-1, x, y, w, 0, "DrawText|Center", C2D::#Gui_FlagCenter)	:	x	=	C2D::GuiPosX(2)
	ID	+	5	:	C2D::GuiFrame(C2D::#Gui_FrameSunken):	C2D::GuiDrawTextGadget(-1, x, y,w+2,0, "{YO,-2}DrawText|Right", C2D::#Gui_FlagRight)
	
	y	=	C2D::GuiPosY(27)
	
	C2D::GuiLine(0, y, #C2D_W)	:	y	+	7
	
	x	=	2
	
	; ********************************************************
	; *** PROGRESS ***
	; ********************************************************
	ID	=	#ID_PROGRESS
	
	C2D::GuiOffset()
	C2D::GuiFrame(timeGetTime_()%C2D::#Gui_FrameSunken)
	RGB_Back()	:	RGB_Front()
	C2D::GuiCopper(?c_cop)
	
	C2D::GuiProgressGadget(ID,	x, y, #C2D_W - x * 2, 18, 100, Random(7))
	
	x	=	2	:	y	=	C2D::GuiPosY(5)
	
	C2D::GuiColor(#Black, #RGB_WINDOW)	:	C2D::GuiLine(0, y, #C2D_W)	:	y	+	8
	
	ID	+	1	:	C2D::GuiCopper(?c_rain,	0)	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiColor(#Blue)	:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiCopper(?c_psy,	0)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)		:	C2D::GuiColor(#Red)	:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiCopper(?c_glass,1)	:	C2D::GuiFrame(C2D::#Gui_FrameFlat)	:	RGB_Front()				:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiCopper(?c_cop,	1)	:	C2D::GuiFrame(C2D::#Gui_FrameLite)	:	RGB_Front()				:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiCopper(?c_top,	0)	:	C2D::GuiFrame(C2D::#Gui_FrameRised)	:	RGB_Front()				:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	ID	+	1	:	C2D::GuiCopper(0)				:	C2D::GuiFrame(C2D::#Gui_FrameSunken):	RGB_Front()				:	C2D::GuiProgressGadget(ID, x, y,	18, 148, 100, Random(7), C2D::#Gui_FlagVertical)	:	x	=	C2D::GuiPosX(2)
	
	C2D::GuiColor(#Black, #RGB_WINDOW)	:	C2D::GuiLine(x+2, y-7, 160, -1, C2D::#Gui_FlagVertical)	:	x	+	8
	
	y	+	20
	
	; ********************************************************
	; *** IMAGE ***
	; ********************************************************
	x	=	C2D::GuiX(#ID_PROGRESS+6)	+	30
	y	=	C2D::GuiY(#ID_PROGRESS+6)
	C2D::GuiCopper(0)
	C2D::GuiColor(#Black, #RGB_WINDOW)
	
	ID	=	#ID_IMAGE
	C2D::GuiImageGadget(ID+1, x, y, 0, 0, 0)	:	x	=	C2D::GuiPosX(8)
	C2D::GuiImageGadget(ID+2, x, y, ImageWidth(1), ImageHeight(1), 1)	:	x	=	C2D::GuiPosX(6)
	
	C2D::GuiFrame(C2D::#Gui_FrameFlat)
	C2D::GuiButtonGadget(ID+3, x, y, 0, 0, "", 0, 1)	:	x	=	C2D::GuiPosX(6)
	
	C2D::GuiFrame(C2D::#Gui_FrameFine)
	C2D::GuiButtonGadget(ID+4, x, y, 40, 25,	"", C2D::#Gui_FlagToggle, 0)	:	x	=	C2D::GuiPosX(6)
	;C2D::GuiButtonGadget(ID+5, x, y,  0,  0,	"", C2D::#Gui_FlagToggle, 3)
	
	y	=	C2D::GuiPosY(4)
	x	=	C2D::GuiX(#ID_PROGRESS+6)	+	30
	;C2D::GuiPosition(x, y)
	ID	=	#ID_STRING
	ID	+	0	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiStringGadget(ID, x, y, 120, 18, "FrameNone")	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_Frame3D)		:	C2D::GuiStringGadget(ID, x, y, 120, 18, "Frame3D")		:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameFlat)	:	C2D::GuiStringGadget(ID, x, y, 120, 18, "FrameFlat")	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameRised)	:	C2D::GuiStringGadget(ID, x, y, 120, 18, "FrameRised")	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameLite)	:	C2D::GuiStringGadget(ID, x, y, 120, 18, "FrameLite")	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameSunken):	C2D::GuiStringGadget(ID, x, y, 120, 18, "FrameSunken"):	y	=	C2D::GuiPosY(2)
	x	=	C2D::GuiPosX(8)
	
	; ********************************************************
	; *** CONTAINER + TRACK VERTICAL ***
	; ********************************************************
	C2D::GuiFrame(Random(C2D::#Gui_FrameSunken))	:	RGB_Back()
	C2D::GuiContainerGadget(#ID_CONTAINER, x, C2D::GuiY(#ID_PROGRESS+6), #C2D_W - x - 4, 148)
	
	x	=	4	:	y	=	6
	
	ID	=	#ID_TRACK
	ID	+	0	:	RGB_Back()	:	RGB_Front()	:	C2D::GuiCopper(0)	:	C2D::GuiFrame(timeGetTime_()%C2D::#Gui_FrameSunken)
	C2D::GuiTrackGadget(ID, x, y, 22, 136, 0, 255, 0, C2D::#Gui_FlagVertical|C2D::#Gui_FlagPercent)	:	x	=	C2D::GuiPosX(4)
	
	h	=	C2D::GuiH(ID)	/	6	-	1
	w	=	C2D::GuiW(#ID_CONTAINER) - C2D::GuiW(ID)	-	12
	
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiFrame(C2D::#Gui_FrameNone)	:	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 333, 0, C2D::#Gui_FlagNumber)	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiCopper(?c_down)		:	C2D::GuiFrame(C2D::#Gui_Frame3D)		:	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 100, Random(7), C2D::#Gui_FlagPercent)	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiCopper(?c_rain,1)	:	C2D::GuiFrame(C2D::#Gui_FrameFlat)	:	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 100, Random(7), C2D::#Gui_FlagLevel)		:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiCopper(?c_top,0)	:	C2D::GuiFrame(C2D::#Gui_FrameRised)	:	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 100, Random(7), C2D::#Gui_FlagNumber)	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiCopper(?c_cop,0)	:	C2D::GuiFrame(C2D::#Gui_FrameLite)	:	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 100, Random(7), C2D::#Gui_FlagNumber)	:	y	=	C2D::GuiPosY(2)
	ID	+	1	:	RGB_Front()	:	RGB_Back()	:	C2D::GuiCopper(?c_psy,1)	:	C2D::GuiFrame(C2D::#Gui_FrameSunken):	C2D::GuiTrackGadget(ID, x, y, w, h, 0, 1100,Random(7), C2D::#Gui_FlagNumber)	:	y	=	C2D::GuiPosY(2)
	
	CloseGadgetList()	; Container
	
	CloseGadgetList()
	
	CompilerIf	IsC2D::#IsC2D_Stars3D
		*Memory	=	C2D::FileLoad("..\Data\Ball\Pearl\"+Str(timeGetTime_()%7)+".png")	:	C2D::GdipCatch(0, *Memory, MemorySize(*Memory))
		C2D::Stars3DDistance(-100)
		C2D::Stars3DInit(200 * #C2D_Z, 11, 0, 0, #C2D_W, #C2D_H, 5.0, 0)
	CompilerEndIf
	
	;FreeImage(0)
	;FreeImage(1)
	;FreeImage(2)
	;FreeImage(3)
	
	C2D::GuiMenuInit(0, "{MN,0}! = open prompt for params;"	+
	                    "-;"	+
	                    "{TH,44}{YP,10}{IM,2}{YG,3}|{PF,7}{SH,$FF}Install file as prefs;"+
	                    ";-;"	+
	                    "{MN,1}$ = view {PF,3}{ST,$FF}file as{ST}{PF,1} text;"		+
	                    "{MN,2}{TH,32}{YP,10}* = view {PF,4}file{PF,1} as  {FR,6,4,4}picture{FR};"	+
	                    "{MN}{TH,18}{IM,0} # = play file as media;"	+
	                    "{TH,18}{IM,1} % = run {BD,1}file{BD} and exit;"		+
	                    "{MN,3}Link{PB,6} as {PB}youtube;"	+
	                    "Web as youtube;"	+
	                    "View url as youtube;"	+
	                    ";-;"	+
	                    "{PF,3}Abort")
; 	
	C2D::GuiMenuItemAdd(0, ";-;", 7)
	C2D::GuiMenuItemAdd(0, "A {BD,1}Text{BD} with {IV,1}the{IV} {ST,$FF}{PF,6}{DM,2}entry{DM} 8", 8)
	C2D::GuiMenuItemAdd(0, ";-;", 9)
	C2D::GuiMenuItemAdd(0, " ", 10)
	C2D::GuiMenuItemAdd(0, ";-;", 11)
	
	C2D::GuiMenuInit(1, "{PF,2}{SH,$7F}Öffnen;-;Speichern als;y-Löschen;{FN,"	+	Str(Random(3))	+	"}Bearbeiten;Kopieren		{IV,1} STRG+C {IV};Einfügen		{IV,1} STRG+V {IV};Formatieren	{IV,1} STRG+F {IV};Ersetzen;Farbe;-;{PF,4}{SH,$7F}Abbruch")

EndProcedure
Procedure	C2D_Update()
	
	CompilerIf	IsC2D::#IsC2D_Stars3D
		C2D::Stars3DDraw()
	CompilerEndIf

EndProcedure

C2D_Init()	; Must always called before Update

Repeat
	Select	WindowEvent()

		;************************************************
		;- *** Mainloop ***
		;************************************************
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
			
		Case	#PB_Event_Gadget
			Gadget	=	EventGadget()
			Select	C2D::GuiEvent(Gadget)
					
				Case	#ID_TOGGLE
					
					d	!	1	; disable
					
					With	C2D::RS_GUI\Gadget()
						ForEach	C2D::RS_GUI\Gadget()
							PushListPosition(C2D::RS_GUI\Gadget())
							Select	\Type
								Case	#PB_GadgetType_Button, C2D::#C2D_Type_DrawButton
									If	\ID	<>	#ID_TOGGLE	; not the set-toggle-button
										C2D::GuiDisable(\ID, d)
									EndIf
								Case	#PB_GadgetType_TrackBar
									If	\ID	<>	#ID_TOGGLE	; not the set-toggle-button
										;C2D::GuiState(\ID, \Max)
										C2D::GuiDisable(\ID, d)
									EndIf
								Case	#PB_GadgetType_ProgressBar
									C2D::GuiSetState(\ID, \Max)
								Case	#PB_GadgetType_String
									C2D::GuiDisable(\ID, d)
							EndSelect
							PopListPosition(C2D::RS_GUI\Gadget())
						Next
					EndWith
					t$	=	"What"
					If	Random(1)	:	t$	+	"|OK"	:	EndIf
					If	Random(1)	:	t$	+	"|"+Str(Random(300000))	:	EndIf
					
					C2D::GuiSetText(tID, t$)
	
				Case	#ID_FRAME
					
					s	!	1	; state

					With	C2D::RS_GUI\Gadget()
						ForEach	C2D::RS_GUI\Gadget()
							PushListPosition(C2D::RS_GUI\Gadget())
							
							Select	\Type
								Case	#PB_GadgetType_Button, C2D::#C2D_Type_DrawButton
									
									If	\ID	<>	#ID_TOGGLE	And	\ID	<>	#ID_FRAME
										C2D::GuiSetState(\ID, s)
									EndIf
									
								Case	#PB_GadgetType_ProgressBar

									C2D::GuiSetState(\ID, Random(\Max * 1.3))

								Case	#PB_GadgetType_TrackBar

									C2D::GuiSetState(\ID, Random(\Max))

								Case	#PB_GadgetType_Text
									
									C2D::GuiSetText(\ID, C2D::GuiGetText(\ID), Random($4040FF))
							
							EndSelect
							
							PopListPosition(C2D::RS_GUI\Gadget())
						Next
					EndWith
					
				Case	#ID_TRACK	To	#ID_TRACK	+	6
					C2D::GuiSetText(#ID_TEXT, StrF(C2D::GuiGetState(Gadget), 3))
					
				Case	#ID_MENU0
					C2D::GuiFrame(0)
					C2D::GuiCopper(?c_glass*Random(1)*0, C2D::#Gui_FlagVertical)
					C2D::GuiColor(#RGB_BLACK, #RGB_GRAY|Random($FFFFFF))
					C2D::GuiMenuItemSetState(0, Random(C2D::GuiMenuSize(0)-1), 1)
					C2D::GuiMenuPopup(0, C2D::#Gui_FlagShadow|C2D::#Gui_FlagBorder|C2D::#Gui_FlagState|(C2D::#Gui_FlagUser*Random(1)))
				Case	#ID_MENU1
					C2D::GuiFrame(0)
					C2D::GuiCopper(?c_glass*Random(1)*0, C2D::#Gui_FlagVertical)
					C2D::GuiColor(#RGB_BLACK, #RGB_GRAY|Random($FFFFFF))
					i	=	C2D::GuiMenuPopup(1, C2D::#Gui_FlagShadow|C2D::#Gui_FlagBorder|C2D::#Gui_FlagState)
					If	i	>=	2	And	i	<=	C2D::GuiMenuSize(1)	-	2
						C2D::GuiMenuItemSetState(1, i, C2D::GuiMenuItemGetState(1, i) ! 1)
					EndIf
					
				Default
					;Debug	C2D::GuiState(Gadget)
			EndSelect

		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_RBUTTONDOWN
			;C2D::GuiFrame(Random(7), $FF)
			C2D::GuiFrame(0)
			C2D::GuiCopper(?c_glass*Random(1)*0, C2D::#Gui_FlagVertical)
			C2D::GuiColor(#RGB_BLACK, #RGB_GRAY|Random($FFFFFF))
			
			
			If	Random(1)
				If	C2D::IsGuiMenu(1)
; 					ForEach	C2D::RS_GuiMenu()\Items()
; 						If	ListIndex(C2D::RS_GuiMenu()\Items())	>=	2	And	ListIndex(C2D::RS_GuiMenu()\Items())	<=	C2D::GuiMenuSize(1)	-	2
; 							C2D::RS_GuiMenu()\Items()\IsState	=	Random(1)
; 						EndIf
; 					Next
					i	=	C2D::GuiMenuPopup(1, C2D::#Gui_FlagShadow|C2D::#Gui_FlagBorder|C2D::#Gui_FlagState)
					If	i	>=	2	And	i	<=	C2D::GuiMenuSize(1)	-	2
						C2D::GuiMenuItemSetState(1, i, C2D::GuiMenuItemGetState(1, i) ! 1)
					EndIf
				EndIf
			Else
				C2D::GuiMenuItemSetState(0, Random(6), 1)
				C2D::GuiMenuPopup(0, C2D::#Gui_FlagShadow|C2D::#Gui_FlagBorder|C2D::#Gui_FlagState|(C2D::#Gui_FlagUser*Random(1)))
			EndIf

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
			EndSelect

	EndSelect
ForEver

C2D::Free()

DataSection
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
; Folding = Aw
; Executable = ..\Executables\C2D_Gui_Gadgets_x86.exe
; CompileSourceDirectory