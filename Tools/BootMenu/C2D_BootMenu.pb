; C2D::Amiga BootMenu V1.0 by Promax from Kefrens
; Coded: Peace/TST - Purebasic v5.72 - 14.08.2018

; http://janeway.exotica.org.uk/release.php?id=13207

; MouseWheel	-	scroll up/down
; MouseButton	-	execute entry

; Name files as "File_x86.exe" or "File_x64.exe"

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D

	#IsC2D_Mode		=	0	; no DrawingMode()

	#IsC2D_Copper	=	1
	#IsC2D_MoveText=	1
	#IsC2D_Stars2D	=	1
	#IsC2D_GdiPlus	=	2	; short png decoder
	#IsC2D_Clear	=	2	; fast clear

	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *******************************************************
; *** Important: set to 0 in final compile + save exe ***
; -------------------------------------------------------
CompilerSelect	0	; <- choose 1,2 for test only

	; 1,2 for test only, do not use in final exe!!
	CompilerCase	1	:	Global	PATH$="..\..\Executables\",	TITLE$="CANVAS 2D EXAMPLES"
	CompilerCase	2	:	Global	PATH$="..\..\Demos\",			TITLE$="CANVAS 2D DEMOS"

	; *** 0 = final-compile! ***
	CompilerDefault

		; *** Must start with param(1) -> only for BATCH-CMD ***
		Global	PATH$=ProgramParameter(1),	TITLE$=ProgramParameter(2)

CompilerEndSelect
; *******************************************************

If	PATH$	=	""	:	End	:	EndIf

; *** Main ***

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth (zoomed)
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight (zoomed)

#ID_FONT	=	0
#ID_TEXT	=	0
#ID_COP0	=	0
#ID_COP1	=	1

#FNT_W	=	16	*	#C2D_Z	; FontWidth
#FNT_H	=	25	*	#C2D_Z	; FontHeight

#COP_H	=	#FNT_H	+	4.5		*	#C2D_Z	; CopperHeight
#Y_COP	=	(#C2D_H	-	#COP_H)	*	0.5		; CopperCenterY

#Y_SPEED	=	0.2	*	#C2D_Z				; Accleration
#Y_MIN	=	-(#C2D_H - #COP_H * 0.60)	; Last file-entry for movetext

Structure	Entry
	File$
EndStructure

Global	NewList	Entry.Entry()
Global	y_add.f, y_txt, y_spc, y_max
Global	TEXT$	=	"BOOT-MENU "	+	C2D::#C2D_XOS$	+	"|"	+	TITLE$	+	"|"

Procedure	BootMenu_Copper(x, y, PenColor, PaperColor)
	If	PaperColor	<>	$FF0000FF	; Red
		ProcedureReturn	PaperColor
	EndIf
	ProcedureReturn	PenColor
EndProcedure
Procedure	BootMenu_Dir(Path$)
	
	Static	xos$	=	C2D::#C2D_XOS$ + ".EXE"	; X86.EXE or X64.EXE

	Protected	f$, i

	If	Right(Path$, 1)	<>	"\"
		Path$	+	"\"
	EndIf

	i	=	ExamineDirectory(#PB_Any, Path$, "")

	If	i

		While NextDirectoryEntry(i)

			f$	=	DirectoryEntryName(i)

			If DirectoryEntryType(i) = #PB_DirectoryEntry_File

				If	FindString(f$, xos$, 1, #PB_String_NoCase)	And	(f$ <> GetFilePart(ProgramFilename()))	; <- don't list own program

					AddElement(Entry())	:	Entry()\File$	=	Path$	+	f$	; add full entry-exe to list

					f$	=	RemoveString(f$,	"C2D",#PB_String_NoCase)	; C2D_
					f$	=	RemoveString(f$,	xos$,	#PB_String_NoCase)	; _X86/_X64.EXE

					ReplaceString(f$, "_", " ", #PB_String_InPlace)

					TEXT$	+	"|"	+	Trim(f$)	; add formatted entry-name to move-text + lf

				EndIf

			ElseIf	DirectoryEntryType(i) = #PB_DirectoryEntry_Directory

				If	f$	<>	"."	And	f$	<>	".."
					BootMenu_Dir(Path$	+	f$)	; recursively scan of sub-dirs
				EndIf

			EndIf

		Wend

		FinishDirectory(i)
		
		Delay(1)

	EndIf

EndProcedure

Procedure	BootMenu_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("BootMenu / Kefrens - BootMenu V1.0 by Promax - 1989"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)

	C2D::Init(#C2D_G, 6)
	
	BootMenu_Dir(PATH$)

	C2D::GdipCatch(0, ?i_font, ?e_font)

	C2D::FontInit(#ID_FONT, 0)
	C2D::FontZoom(#ID_FONT, #FNT_W, #FNT_H)
	C2D::FontGap(#ID_FONT, 0, 5 * #C2D_Z)

	C2D::MoveTextInit(#ID_TEXT, @TEXT$, 0, 0, #C2D_W, #C2D_H, C2D::#C2F_Center)
	C2D::MoveTextSpeed(#ID_TEXT, #Null)
	C2D::MoveTextY(#ID_TEXT, #Y_MIN)
	
	y_max	=	-(C2D::RS_MoveText()\MaxH - 4.5 * #FNT_H + 5 * #C2D_Z)
	
	C2D::CopperInit(#ID_COP0, #COP_H, ?c_blue)
	C2D::CopperInit(#ID_COP1, #COP_H, ?c_yellow)

	C2D::CopperBlitProc(@BootMenu_Copper())

	C2D::Stars2DInit(100, #C2D_Z, 0, 0, #C2D_W, #C2D_H, 2.5 * #C2D_Z)

	TEXT$	=	#Null$
	FreeImage(0)

EndProcedure
Procedure	BootMenu_Update()

	C2D::CopperDraw(#ID_COP0, #Y_COP)

	C2D::Stars2DDraw()

	y_txt	=	C2D::MoveTextDraw(#ID_TEXT)

	If	y_spc

		If	(y_add	<	#Null	And	y_txt	<	y_spc)	Or	(y_add	>	#Null	And	y_txt	>	y_spc)
			C2D::MoveTextY(#ID_TEXT, y_spc)
			C2D::MoveTextSpeed(#ID_TEXT, #Null)
			y_add	=	#Null
			y_spc	=	#Null
		EndIf

	ElseIf	y_txt	<	y_max	And	y_add < #Null

		C2D::MoveTextY(#ID_TEXT, y_max)
		C2D::MoveTextSpeed(#ID_TEXT, #Null)
		y_add	=	#Null

	ElseIf	y_txt	>	#Y_MIN	And	y_add	>	#Null

		C2D::MoveTextY(#ID_TEXT, #Y_MIN)
		C2D::MoveTextSpeed(#ID_TEXT, #Null)
		y_add	=	#Null

	EndIf

	C2D::CopperBlit(#ID_COP1, #Y_COP)

EndProcedure
Procedure	BootMenu_Event()

	If	GetGadgetAttribute(#C2D_G, #PB_Canvas_WheelDelta)	<	#Null	; move up

		If	y_add	>	#Null
			y_add	=	#Null
			y_txt	=	Abs(y_txt / C2D::FontH(#ID_FONT))	-	7	; NO #FNT_H - coz adding gap!
			y_spc	=	#Y_MIN - y_txt * C2D::FontH(#ID_FONT)
		EndIf

		y_add	-	#Y_SPEED	:	C2D::MoveTextSpeed(#ID_TEXT, y_add)

	ElseIf	GetGadgetAttribute(#C2D_G, #PB_Canvas_WheelDelta)	>	#Null	; move down

		If	y_add	<	#Null
			y_add	=	#Null
			y_txt	=	Abs(y_txt / C2D::FontH(#ID_FONT))	-	8	; NO #FNT_H - coz adding gap!
			y_spc	=	#Y_MIN - y_txt * C2D::FontH(#ID_FONT)
		EndIf

		y_add	+	#Y_SPEED	:	C2D::MoveTextSpeed(#ID_TEXT, y_add)

	ElseIf	GetGadgetAttribute(#C2D_G, #PB_Canvas_Buttons)	&	#PB_Canvas_LeftButton	; LMB = execute entry

		If	y_add	=	#Null

			y_txt	=	Abs(y_txt / C2D::FontH(#ID_FONT))	-	7	; NO #FNT_H - coz adding gap!

			If	y_txt	>=	#Null	And	y_txt	<	ListSize(Entry())

				SelectElement(Entry(), y_txt)

				HideWindow(0, 1)
				RunProgram(Entry()\File$, #Null$, GetPathPart(Entry()\File$), #PB_Program_Wait)
				HideWindow(0, 0)

			EndIf

		EndIf

	EndIf

EndProcedure

BootMenu_Init()

Repeat
	Select	WindowEvent()

		Case	#Null
			If	C2D::Start()
				BootMenu_Update()
				C2D::Stop()
			EndIf

		Case	#PB_Event_Gadget
			Select	EventGadget()
				Case	#C2D_G
					BootMenu_Event()
			EndSelect

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf

		Case	#PB_Event_CloseWindow
			Break

	EndSelect
ForEver

C2D::Free()

DataSection

	i_font:		:	IncludeBinary	"gfx\Font.png"	:	e_font:

	c_blue:		:	Data.l	3, $00FF0000, $FFFF0000, $00FF0000
	c_yellow:	:	Data.l	3, $FF0000FF, $FF00FFFF, $FF0000FF

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A5
; Executable = C2D_BootMenu_x86.exe
; DisableDebugger
; CompileSourceDirectory