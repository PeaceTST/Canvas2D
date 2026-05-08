; C2D::Ball3D / Editor
; Purebasic v5.70
; Peace^Testaware - 12.03.20 00:47
; https://testaware.wordpress.com

EnableExplicit

DeclareModule	IsC2D
	
	#IsC2D_Clear	=	0
	
	#IsC2D_Buffer	=	1
	#IsC2D_GdiPlus	=	1
	#IsC2D_Stars3D	=	2
	#IsC2D_Fps		=	1
	
	#IsC2D_Ball3D	=	2
	#IsC2D_File		=	2
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

CompilerIf	IsC2D::#IsC2D_GdiPlus	=	0
	UsePNGImageDecoder()	; 148 KB (GDI = 2 KB)
CompilerEndIf

XIncludeFile	"..\..\Include\C2D_Module.pbi"

;{ *** Define constants *** }
#B_SIZE	=	20

#B_X		=	48	|	1
#B_Y		=	48	|	1
#B_Z		=	48	|	1

#B_N		=	#B_X	*	#B_Y	*	#B_Z

#SCR_W	=	#B_SIZE	*	#B_X
#SCR_H	=	#B_SIZE	*	#B_Y

#SCR_CX	=	#SCR_W	*	0.5	; ScreenCenter X
#SCR_CY	=	#SCR_H	*	0.5	; ScreenCenter Y

#WIN_W	=	822
#WIN_H	=	740

#MAX_BRUSH	=	7	; =8

#MAX_STAR	=	200
#STAR_SPEED	=	2.15
#STAR_SIZE	=	1

#RGB_RASTER	=	$20FFFFFF
#RGB_CENTER	=	$207FFF7F

#W	=	52	; Gadgetwidth
#H	=	24	; Gadgetheight
#S	=	6	; Gadget stepsize

Enumeration	; Menu
	#M_ObjectOpen
	#M_ObjectPure
	#M_ObjectSave
	#M_ObjectFlipX
	#M_ObjectFlipY
	#M_ObjectFree
	#M_Exit
	;
	#M_ThemeLoad
	#M_ThemeDefault
	#M_ThemeSmooth
	;
	#M_LayerCopy
	#M_LayerFlipX
	#M_LayerFlipY
	#M_LayerTurnZX
	#M_LayerTurnZY
	#M_LayerU
	#M_LayerD
	#M_LayerL
	#M_LayerR
	#M_LayerClear
	;
	#M_View
	#M_Color
	#M_Stars
	#M_FPS
	#M_CPU
	#M_Help
	#M_Center
	;
	#M_About
	;
	#M_BrushLoad
	#M_BrushCopy
	#M_BrushUse
EndEnumeration
Enumeration	; Gadgets / Icons
	#G_0 : #G_1 : #G_2 : #G_3 : #G_4 : #G_5 : #G_6 : #G_7
	
	#G_Area
	#G_Canvas
	#G_View
	#G_Size
	#G_Plot	:	#G_Line	:	#G_Box	:	#G_Circle	:	#G_Brush	:	#G_Fill	:	#G_Tint	; never change (toggle for/next)
	#G_Status	; rubber 0/1
	#G_Layer	:	#G_LayerZ
	#G_IsZoom	:	#G_Zoom
	
	#G_Left	:	#G_Right	:	#G_Up	:	#G_Down
	
	#G_IsSpin	:	#G_Spin	:	#G_SpinX	:	#G_SpinY	:	#G_SpinZ	; BallSpin
	;
	#G_Quit
	#G_Rotate	:	#G_IsRX	:	#G_IsRY	:	#G_IsRZ	:	#G_RX	:	#G_RY	:	#G_RZ
	#G_Angle		:	#G_AX	:	#G_AY	:	#G_AZ
	#G_IsFog		:	#G_Fog
	#G_IsSpeed	:	#G_Speed	; C2D
	#G_Explode
	#G_Ruler		; copy angles to editor
	#G_Shot
	;
	#G_Ed
	#G_EdCopy
	#G_EdSave
	;
	#G_Container0
	#G_Container1
	;
	#I_Open
	#I_Save
	#I_Pure
	#I_Copy
	#I_Bob
	#I_Clear
	#I_Color
	#I_Close
	#I_FlipX
	#I_FlipY
	#I_TurnZX
	#I_TurnZY
	#I_About
	#I_Tricky
	#I_Temp
EndEnumeration
Enumeration
	#T_FILE		; loaded/saved file
	#T_INFO		; global info
	#T_X			; mousex
	#T_Y			; mousey
	#T_S
	#T_RX
	#T_RY
	#T_RZ
	#T_COUNT		; displayed bobs
	#T_IMAGE		; number of images used in 3dball object
EndEnumeration
Enumeration	; font
	#F_GUI
	#F_ED
EndEnumeration

CompilerIf	#PB_Compiler_Version	<	560
	#PB_MessageRequester_Error		=	16
	#PB_MessageRequester_Info		=	64
	#PB_MessageRequester_Warning	=	48
CompilerEndIf

Structure	B3D	;Extends	C2D::RS_Ball3D	;C2D::Ball
	On.b
	ID.b
	x.f
	y.f
	z.f
	s.f
	sx.f
	sy.f
	sz.f
EndStructure	:	Global	Dim	Ball.B3D(#B_Z, #B_X, #B_Y)

Structure	Brush
	File$
	*Ptr
	Length.i
EndStructure	:	Global	NewList	Brush.Brush()

Declare		_LayerShow()

Define	px, py, pz, ps

Define	x, y, z
Define	BallID	=	0
Define	Mode		=	#G_Plot
Define	Gadget, Event, Type, i, Status=1
Define	Path$	=	C2D::FileParent(GetCurrentDirectory(), 2)	+	"Data\Ball\Pearl\"

Global	lz, li	; layer restore (Open, Layer)

Global	File$	=	C2D::FileParent(GetCurrentDirectory(), 2)	+	"Data\Object\B3D\"
Global	Unsaved$	=	GetPathPart(ProgramFilename())	+	"unsaved.b3d"
Global	*ObjectBuffer.C2D::RS_Ball3D
;}

Macro	M_Center()
	SetGadgetAttribute(#G_Area, #PB_ScrollArea_X, (#SCR_W - #WIN_W) * 0.5)
	SetGadgetAttribute(#G_Area, #PB_ScrollArea_Y, (#SCR_H - GadgetHeight(#G_Area)) * 0.5)
EndMacro
Macro	M_GetX()
	(GetGadgetAttribute(#G_Canvas, #PB_Canvas_MouseX)	/	#B_SIZE)	;(WindowMouseX(0)	/	#B_SIZE)
EndMacro
Macro	M_GetY()
	(GetGadgetAttribute(#G_Canvas, #PB_Canvas_MouseY)	/	#B_SIZE)	;(WindowMouseY(0)	/	#B_SIZE)
EndMacro
Macro	M_GetZ()
	(GetGadgetState(#G_LayerZ) + #B_Z / 2)	;(#B_Z - 1) * 0.5)
EndMacro
Macro	M_GetBobSize()
	(GetGadgetState(#G_Zoom) * (Bool(GetGadgetState(#G_IsZoom))))
EndMacro
Macro	M_SetBobSize(BOBSIZE)
	SetGadgetState(#G_Zoom, BOBSIZE)
	SetGadgetText(#G_Zoom,	StrF((BOBSIZE) * 0.1, 1))
EndMacro
Macro	M_GetBobColor(INDEX)
	PeekL(C2D::?c2d_ball3d_rgb + (INDEX) * SizeOf(Long))
EndMacro

Procedure	WinCallback(hWnd, uMsg, wParam, lParam)
	Protected	Result	=	#PB_ProcessPureBasicEvents
	Protected	n, t$
	Static	Gadget	=	-1
	Select uMsg
		Case	#WM_SETCURSOR
			n	=	GetProp_(wParam, "PB_ID")
			If	n	<>	Gadget
				Gadget	=	n
				Select	Gadget
					Case	#G_View			:	t$	=	"View Object [F5]"
					Case	#G_Size			:	t$	=	"Object Zoom-Size"
					Case	#G_Layer			:	t$	=	"Swap Z-Layer ± & 0"
					Case	#G_LayerZ		:	t$	=	"Set Z-Layer ± " + Str(#B_Z / 2)
					Case	#G_Plot			:	t$	=	"Draw Freehand"
					Case	#G_Line			:	t$	=	"Draw Line"
					Case	#G_Box			:	t$	=	"Draw Box"
					Case	#G_Circle		:	t$	=	"Draw Circle"
					Case	#G_Fill			:	t$	=	"Fill With Color"
					Case	#G_Tint			:	t$	=	"Replace Layer Color With Ball Color"
					Case	#G_Brush			:	t$	=	"Draw Copied Layer"
					Case	#G_Status		:	t$	=	"Rubber (Freehand, Layer)"
					Case	#G_IsZoom		:	t$	=	"Activate Zoom-Ball"
					Case	#G_Zoom			:	t$	=	"Ball Zoom Size"
					Case	#G_IsSpin		:	t$	=	"Activate Spin-Ball (Freehand Only)"
					Case	#G_SpinX			:	t$	=	"Ball X-Spin"
					Case	#G_SpinY			:	t$	=	"Ball Y-Spin"
					Case	#G_SpinZ			:	t$	=	"Ball Z-Spin"
					Case	#G_Spin			:	t$	=	"XYZ Spin-Speed"
					Case	#G_Left			:	t$	=	"Move Object Left"
					Case	#G_Right			:	t$	=	"Move Object Right"
					Case	#G_Up				:	t$	=	"Move Object Up"
					Case	#G_Down			:	t$	=	"Move Object Down"
					Case	#G_0	To	#G_7
						If	Gadget	=	#G_0	And	wParam	<>	GadgetID(#G_0)
							t$	=	#Null$
						Else
							t$	=	"Ball Color " + Str(Gadget)
						EndIf
						
					Case	#G_Quit		:	t$	=	"Exit [ESC]"
					Case	#G_Rotate	:	t$	=	"Start / Stop Rotate"
					Case	#G_IsRX		:	t$	=	"X-Rotate"
					Case	#G_IsRY		:	t$	=	"Y-Rotate"
					Case	#G_IsRZ		:	t$	=	"Z-Rotate"
					Case	#G_RX			:	t$	=	"X-Rotate Speed"
					Case	#G_RY			:	t$	=	"Y-Rotate Speed"
					Case	#G_RZ			:	t$	=	"Z-Rotate Speed"
					Case	#G_Angle		:	t$	=	"Set Current Angles"
					Case	#G_AX			:	t$	=	"X-Angle"
					Case	#G_AY			:	t$	=	"Y-Angle"
					Case	#G_AZ			:	t$	=	"Z-Angle"
					Case	#G_IsFog		:	t$	=	"Fog On / Off"
					Case	#G_Fog		:	t$	=	"Fog Density"
					Case	#G_IsSpeed	:	t$	=	"Delay On / Off"
					Case	#G_Speed		:	t$	=	"Delay n:50"
					Case	#G_Explode	:	t$	=	"Explode Object"
					Case	#G_Ruler		:	t$	=	"Set Object Angles"
					Case	#G_Shot		:	t$	=	"Screenshot To Clipboard"
				EndSelect
				If	t$
					StatusBarText(0, #T_INFO, t$, #PB_StatusBar_Center)
				EndIf
			EndIf
	EndSelect
	ProcedureReturn	Result
EndProcedure

Procedure	_SmallImageGadget(Gadget, x, y, w, h, ImageID, Flags=0)
	
	ContainerGadget(#PB_Any, x, y, w, h, #PB_Container_Single)
	ButtonImageGadget(Gadget, (w - #H) * 0.5 - 1, (h - #H) * 0.5 - 1, #H, #H, ImageID) 
	CloseGadgetList()
	
EndProcedure

Procedure	_MenuCreate()
	
	If	IsMenu(0)	=	0
		
		CreateImageMenu(0, WindowID(0));, #PB_Menu_ModernLook)
		
		; *** 0
		MenuTitle("?")
		MenuItem(#M_About,	"About",	ImageID(#I_About))
		
		; *** 1
		MenuTitle("Object")
		MenuItem(#M_ObjectOpen,	"Object Open"		+	#TAB$	+	"Ctrl+O",	ImageID(#I_Open))
		MenuBar()
		MenuItem(#M_ObjectPure,	"Object Pure"		+	#TAB$	+	"Ctrl+A",	ImageID(#I_Pure))
		MenuBar()
		MenuItem(#M_ObjectSave,	"Object Save"		+	#TAB$	+	"Ctrl+S",	ImageID(#I_Save))
		MenuBar()
		MenuItem(#M_ObjectFlipX,"Object Flip X",	ImageID(#I_FlipX))
		MenuItem(#M_ObjectFlipY,"Object Flip Y",	ImageID(#I_FlipY))
		MenuBar()
		MenuItem(#M_ObjectFree,	"Object Free"		+	#TAB$	+	"Ctrl+F",	ImageID(#I_Clear))
		MenuBar()
		MenuItem(#M_Exit,			"Exit",				ImageID(#I_Close))
		
		; *** 2
		MenuTitle("View")
		MenuItem(#M_View,		"View / Quit"	+	#TAB$	+	"F5",			ImageID(#G_View))
		MenuBar()
		MenuItem(#M_Color,	"Back Color"	+	#TAB$	+	"Ctrl+B",	ImageID(#I_Color))
		MenuBar()
		MenuItem(#M_Stars,	"Stars 3D")
		MenuItem(#M_FPS,		"Framerate")
		MenuItem(#M_CPU,		"CPU Friendly"	+	#TAB$	+	"Ctrl+W")
		MenuBar()
		MenuItem(#M_Help,		"Help Message"	+	#TAB$	+	"F1")
		MenuItem(#M_Center,	"Center Canvas"+	#TAB$	+	"F4")
		
		; *** 3
		MenuTitle("Theme")
		MenuItem(#M_ThemeLoad,		"Theme Load"		+	#TAB$	+	"Ctrl+T",	ImageID(#I_Bob))
		MenuItem(#M_ThemeDefault,	"Theme Default"	+	#TAB$	+	"Ctrl+R",	ImageID(#I_Bob))
		MenuBar()
		MenuItem(#M_ThemeSmooth,	"Smooth Resize")
		
		; *** 4
		MenuTitle("Layer")
		MenuItem(#M_LayerCopy,	"Layer Copy"	+	#TAB$	+	"Alt+C",		ImageID(#I_Copy))
		MenuBar()
		MenuItem(#M_LayerFlipX,	"Layer Flip X",	ImageID(#I_FlipX))
		MenuItem(#M_LayerFlipY,	"Layer Flip Y",	ImageID(#I_FlipY))
		MenuItem(#M_LayerTurnZX,"Layer Turn ZX",	ImageID(#I_TurnZX))
		MenuItem(#M_LayerTurnZY,"Layer Turn ZY",	ImageID(#I_TurnZY))
		MenuBar()
		MenuItem(#M_LayerU,	"Layer Up"		+	#TAB$	+	"Alt+U")
		MenuItem(#M_LayerD,	"Layer Down"	+	#TAB$	+	"Alt+D")
		MenuItem(#M_LayerL,	"Layer Left"	+	#TAB$	+	"Alt+L")
		MenuItem(#M_LayerR,	"Layer Right"	+	#TAB$	+	"Alt+R")
		MenuBar()
		MenuItem(#M_LayerClear,	"Layer Clear"	+	#TAB$	+	"Alt+X",		ImageID(#I_Clear))
		
		; *** 5
		MenuTitle("Brush")
		MenuItem(#M_BrushLoad,	"Brush Load",	ImageID(#I_Open))
		MenuItem(#M_BrushCopy,	"Brush Copy"	+	#TAB$	+	"Ctrl+C",	ImageID(#I_Copy))
		
		; shortcuts
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_O, #M_ObjectOpen)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_A, #M_ObjectPure)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_S, #M_ObjectSave)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_F, #M_ObjectFree)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_T, #M_ThemeLoad)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_R, #M_ThemeDefault)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_C,		#M_LayerCopy)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_X,		#M_LayerClear)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_D,		#M_LayerD)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_L,		#M_LayerL)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_R,		#M_LayerR)
		AddKeyboardShortcut(0, #PB_Shortcut_Alt|#PB_Shortcut_U,		#M_LayerU)
		AddKeyboardShortcut(0, #PB_Shortcut_F1,	#M_Help)
		AddKeyboardShortcut(0, #PB_Shortcut_F4,	#M_Center)
		AddKeyboardShortcut(0, #PB_Shortcut_F5,	#M_View)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_B, #M_Color)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_W, #M_CPU)
		AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_C, #M_BrushCopy)
		
		; defaults
		SetMenuItemState(0, #M_CPU,	1)
		;SetMenuItemState(0, #M_Help,	1)

	EndIf
	
	While	WindowEvent()	:	Wend
	
EndProcedure

Procedure	_About()
	
	Protected	t$
	
	t$	=	MA_C2DOS("Ball3D / Editor "	+	ReplaceString(FormatDate("v%yy.%mm%ddß", #PB_Compiler_Date), ".0", "."))	+	#LF$	+	#LF$	+
	  	 	"Module:"	+	#TAB$	+	"Canvas2D v"+	MA_XC2D()	+	#LF$	+	#LF$	+
	  	 	"Window:"	+	#TAB$	+	Str(WindowWidth(0)) + " × " + Str(WindowHeight(0))	+	#LF$	+
	  	 	"Canvas:"	+	#TAB$	+	Str(GadgetWidth(#G_Canvas)) + " × " + Str(GadgetHeight(#G_Canvas))	+	#LF$	+
	  	 	"Matrix:"	+	#TAB$	+	"X ± " + Str(#B_X / 2) + " × Y ± " + Str(#B_Y / 2) + " × Z ± " + Str(#B_Z / 2) + " = " + StrF(#B_N * 0.001, 3)	+	" balls"	+	#LF$	+	#LF$	+
	  	 	"Theme:"		+	#TAB$	+	Str(ImageWidth(C2D::Ball3DBob\Image[0])) + " × " + Str(ImageHeight(C2D::Ball3DBob\Image[0]))	+	#LF$	+	#LF$	+
	  	 	FormatDate("Compiled: %dd.%mm.%yyyy %hh:%ii:%ss - Purebasic v" + StrF(#PB_Compiler_Version * 0.01, 2)	+	#LF$	+	#LF$	+
	  	 	"Peace^TST - testaware.wordpress.com", #PB_Compiler_Date)

	MessageRequester("About", t$, #PB_MessageRequester_Ok|#PB_MessageRequester_Info)
	
EndProcedure

Procedure	_BallCount()
	
	Protected	x, y, z, Count
	
	For	z	=	0	To	#B_Z	-	1
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				If	Ball(z, x, y)\On
					Count	+	1
				EndIf
			Next
		Next
	Next
	
	ProcedureReturn	Count
	
EndProcedure
Procedure	_Theme(Path$=#Null$)
	
	Protected	i, color.l
	
	If	Path$
		C2D::Ball3DLoadTheme(Path$)
	Else
		C2D::Ball3DDefaultTheme()
	EndIf
	
	For	i	=	#G_0	To	#G_0 + C2D::#MAX_BALL	; *** Ball images ***
		
		color	=	M_GetBobColor(i - #G_0)

		; draw bob on canvasgadget
		StartDrawing(CanvasOutput(i))
		Box(0, 0, #H, #H, #Black)
		DrawingMode(#PB_2DDrawing_AllChannels|#PB_2DDrawing_Outlined)
		DrawImage(ImageID(C2D::Ball3DBob\Image[i - #G_0]), 3, 3, #H-6, #H-6)
		Box(1, 1, #H-2, #H-2, $FF000000|color)
		StopDrawing()
		
	Next
	
EndProcedure

Procedure	_SetHelp()
	
	SetMenuItemState(0, #M_Help, Bool(GetMenuItemState(0, #M_Help))!1)

	SetWindowCallback(@WinCallback() * Bool(GetMenuItemState(0, #M_Help)))
	
	If	Bool(GetMenuItemState(0, #M_Help))
		StatusBarText(0, #T_INFO, "Help On", #PB_StatusBar_Center)
	Else
		StatusBarText(0, #T_INFO, "Help Off", #PB_StatusBar_Center)
	EndIf
	
EndProcedure
Procedure	_SetBackColor()
	
	Protected	Color	=	ColorRequester(C2D::C2D\Color)
	
	; Fast clear background with BufferBackGrab(), BufferBackDraw()
	If	Color	>=	#Null
		C2D::C2D\Color	=	$FF000000 | Color	; Alpha + RGB
		StartDrawing(CanvasOutput(#G_Canvas))
		Box(0, 0, OutputWidth(), OutputHeight(), C2D::C2D\Color)
		C2D::BufferBackGrab()
		StopDrawing()
	EndIf
	
EndProcedure
Procedure	_SetDrawMode(Gadget=#G_Plot)
	
	Protected	i
	
	For	i	=	#G_Plot	To	#G_Tint
		SetGadgetState(i, Bool(i=Gadget))
	Next
	
	DisableGadget(#G_Brush, Bool(*ObjectBuffer)!1)
	
	ProcedureReturn	Gadget
	
EndProcedure
Procedure	_SetDrawBall(BallID)
	
	; set actual drawing ball3d on gadget
	
	If	IsImage(#G_Plot)	=	#Null
		CreateImage(#G_Plot, 16, 16, 32, #PB_Image_Transparent)
	EndIf
	
	StartDrawing(ImageOutput(#G_Plot))
	
	DrawingMode(#PB_2DDrawing_AllChannels)
	Box(0, 0, OutputWidth(), OutputHeight(), #Null)
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	DrawImage(ImageID(C2D::Ball3DBob\Image[BallID]), 4, 4, OutputWidth()-8, OutputHeight()-8)
	
	StopDrawing()
	
	SetGadgetAttribute(#G_Plot, #PB_Button_Image, ImageID(#G_Plot))
	
EndProcedure

Procedure	_LayerCount(pz)
	
	Protected	x, y, Count
	
	For	y	=	0	To	#B_Y	-	1
		For	x	=	0	To	#B_X	-	1
			If	Ball(pz, x, y)\On
				Count	+	1
			EndIf
		Next
	Next
	
	ProcedureReturn	Count
	
EndProcedure
Procedure	_LayerXY(pz, px, py)
	
	Static	x, y
	
	If	x	<>	px	Or	y	<>	py
		
		With	Ball(pz, px, py)
			
			; 		x	=	\x
			; 		y	=	\y
			
			StatusBarText(0, #T_X, Str(\x), #PB_StatusBar_Center)
			StatusBarText(0, #T_Y, Str(\y), #PB_StatusBar_Center)
			
			StatusBarText(0, #T_S, StrF(\s * 0.1, 1), #PB_StatusBar_Center)
			
			StatusBarText(0, #T_RX, Str(\sx), #PB_StatusBar_Center)
			StatusBarText(0, #T_RY, Str(\sy), #PB_StatusBar_Center)
			StatusBarText(0, #T_RZ, Str(\sz), #PB_StatusBar_Center)
			
			; 		_LayerShow()
			; 		
			; 		x * #B_SIZE + #SCR_CX
			; 		y * #B_SIZE + #SCR_CY
			; 		
			; 		StartDrawing(CanvasOutput(#G_Canvas))
			; 		DrawingMode(#PB_2DDrawing_XOr)
			; 		LineXY(x, 0, x, #SCR_H)
			; 		LineXY(0, y, #SCR_W, y)
			; 		StopDrawing()
			
			x	=	px
			y	=	py
			
		EndWith

	EndIf
	
EndProcedure
Procedure	_LayerShow()
	
	Protected	x, y, z, Count, px, py, ps.f, Color.l, pz=M_GetZ()
	
	StartDrawing(CanvasOutput(#G_Canvas))
	C2D::BufferBackDraw()
	
	DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
	
	; draw balls of layer only
	For	y	=	0	To	#B_Y	-	1
		For	x	=	0	To	#B_X	-	1
			With	Ball(pz, x, y)
				If	\On
					
					Count	+	1
					
					ps	=	\s	*	0.1	:	If	ps	<=	#Null	:	ps	=	1.0	:	EndIf
					
					ps	*	#B_SIZE
					
					px	=	#SCR_CX	+	\x	*	#B_SIZE	-	ps	*	0.50
					py	=	#SCR_CY	+	\y	*	#B_SIZE	-	ps	*	0.50
					
					DrawImage(ImageID(C2D::Ball3DBob\Image[\ID]), px, py, ps, ps)
					
				EndIf
			EndWith
		Next
	Next
	
	StatusBarText(0, #T_IMAGE, Str(Count),	#PB_StatusBar_Center)	; balls on layer only
	
	Count	=	#Null
	
	; draw circles exept actual layer (balls already displayed) 
	For	z	=	0	To	#B_Z	-	1
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				With	Ball(z, x, y)
					If	\On
						
						Count	+	1
						
						If	Ball(pz, x, y)\On	=	#Null	Or	(Ball(pz, x, y)\On	And	Ball(pz, x, y)\s	<>	\s	And	z	<>	pz)
							
							ps	=	\s	*	0.1	:	If	ps	<=	#Null	:	ps	=	1.0	:	EndIf
							ps	*	#B_SIZE	*	0.50
							
							px	=	#SCR_CX	+	\x	*	#B_SIZE
							py	=	#SCR_CY	+	\y	*	#B_SIZE
							
							Color	=	$7F000000	|	M_GetBobColor(\ID)
							
							Circle(px, py, ps, Color)
							
						EndIf

					EndIf
				EndWith
			Next
		Next
	Next
	
	; Raster
	FrontColor(#RGB_RASTER);$90C0C0C0)
	For	x	=	0	To	#SCR_W	Step	#B_SIZE
		LineXY(x, 0, x, #SCR_H)
	Next
	For	y	=	0	To	#SCR_H	Step	#B_SIZE
		LineXY(0, y, #SCR_W, y)
	Next
	Box(0, 0, #SCR_W, #SCR_H)	; Border
	
	; Center
	DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined);|#PB_2DDrawing_XOr)
	FrontColor(#RGB_CENTER)
	Box(#SCR_CX - #B_SIZE * 0.5, #SCR_CY - #B_SIZE * 0.5, #B_SIZE + 1, #B_SIZE + 1)
	LineXY(0, #SCR_CY, #SCR_W, #SCR_CY)
	LineXY(#SCR_CX, 0, #SCR_CX, #SCR_H)
	
	StopDrawing()
	
	StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)	; all balls in object

	While	WindowEvent()	:	Wend
	
EndProcedure
Procedure	_LayerTint(BallID, pz, px, py, Status)
	
	; all ball3d(x,y) to ballid
	
	Protected	ID, x, y, i
	
	ID	=	Ball(pz, px, py)\ID
	i	=	Ball(pz, px, py)\On
	
	For	y	=	0	To	#B_Y	-	1
		For	x	=	0	To	#B_X	-	1
			With	Ball(pz, x, y)
				If	\On	=	i
					If	\ID	=	ID	Or	(Status	=	#Null	And	\On	=	#Null)
						\On	=	Status
						\ID	=	BallID
					EndIf
				EndIf
			EndWith
		Next
	Next
	
EndProcedure
Procedure	_LayerPlot(BallID, pz, px, py, ps, Status)
	
	Protected	Spin	=	GetGadgetState(#G_Spin)	*	Bool(GetGadgetState(#G_IsSpin))	*	Status
	
	;Debug	Str(px-20)+","+Str(py-20)+","+Str(pz-20)

	With	Ball(pz, px, py)
		
		\On	=	Status
		\ID	=	BallID	; 0 - 7
		
		\s		=	ps			; size
		
		\sx	=	Spin	*	Bool(GetGadgetState(#G_SpinX))
		\sy	=	Spin	*	Bool(GetGadgetState(#G_SpinY))
		\sz	=	Spin	*	Bool(GetGadgetState(#G_SpinZ))
		
	EndWith
	
	px	*	#B_SIZE	+	1
	py	*	#B_SIZE	+	1
	
	StartDrawing(CanvasOutput(#G_Canvas))
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	Box(px, py, #B_SIZE - 1, #B_SIZE - 1, C2D::C2D\Color)
	
	If	Status
		DrawImage(ImageID(C2D::Ball3DBob\Image[BallID]), px, py, #B_SIZE - 1, #B_SIZE - 1)
	EndIf
	
	StopDrawing()
	
EndProcedure
Procedure	_LayerDraw(BallID, pz, px, py, ps, Status)
	
	Protected	BitmapID, Mode, i, xa, ya, x, y
	
	;Debug	Str(px-20)+","+Str(py-20)+","+Str(pz-20)
	
	For	i	=	#G_Plot	To	#G_Tint
		If	GetGadgetState(i)	:	Mode	=	i	:	Break	:	EndIf
	Next
	
	BitmapID	=	ImageID(C2D::Ball3DBob\Image[BallID])	; for faster draw
	
	Select	Mode
			
		Case	#G_Line, #G_Box, #G_Circle, #G_Fill
			
			If	IsImage(#I_Tricky)	=	0
				CreateImage(#I_Tricky, #B_X, #B_Y)
			EndIf
			
			; create temporary backimage for canvas
			If	Mode	<>	#G_Fill
				CreateImage(#I_Temp, GadgetWidth(#G_Canvas), GadgetHeight(#G_Canvas))
				StartDrawing(ImageOutput(#I_Temp))
				DrawImage(GetGadgetAttribute(#G_Canvas, #PB_Canvas_Image), 0, 0)
				StopDrawing()
			EndIf
			
			Repeat
				
				If	WaitWindowEvent()	=	#PB_Event_Gadget
					
					i	=	GetGadgetAttribute(#G_Canvas, #PB_Canvas_Buttons)	& (#PB_Canvas_LeftButton|#PB_Canvas_RightButton)
					
					If i Or	(EventType()=#PB_EventType_MouseMove And i)	Or	Mode=#G_Fill
						
						xa	=	M_GetX()	; mousex
						ya	=	M_GetY()	; mousey
						
						; first draw pixels on tricky shape
						StartDrawing(ImageOutput(#I_Tricky))
						Box(0, 0, OutputWidth(), OutputHeight(), #Black)
						DrawingMode(#PB_2DDrawing_Outlined)
						FrontColor(#White)
						Select	Mode
							Case	#G_Line		:	LineXY(px, py, xa, ya)
							Case	#G_Box		:	Box(px, py, xa - px + Bool(px < xa), ya - py + Bool(py < ya))
							Case	#G_Circle	:	Ellipse(px, py, Abs(xa - px), Abs(ya - py))
							Case	#G_Fill
								For	y	=	0	To	#B_Y	-	1
									For	x	=	0	To	#B_X	-	1
										If	Ball(pz, x, y)\On
											Plot(x, y, Ball(pz, x, y)\ID + 1)
										EndIf
									Next
								Next
								FillArea(px, py, -1, #White)
								StopDrawing()
								Break
						EndSelect
						StopDrawing()
						
						; now lets draw the point(balls)
						If	x	<>	xa	Or	y	<>	ya
							
							StartDrawing(CanvasOutput(#G_Canvas))	; update canvas background
							DrawImage(ImageID(#I_Temp), 0, 0)
							StopDrawing()
							
							StartDrawing(ImageOutput(#I_Tricky))
							For	y	=	0	To	#B_Y	-	1
								For	x	=	0	To	#B_X	-	1
									
									If	Point(x, y)	&	#White	; draw the balls on canvas
										
										StopDrawing()
										
										StartDrawing(CanvasOutput(#G_Canvas))
										DrawingMode(#PB_2DDrawing_AlphaBlend)
										If	Status
											DrawImage(BitmapID, x * #B_SIZE + 1, y * #B_SIZE + 1, #B_SIZE - 1, #B_SIZE - 1)
										Else
											Box(x * #B_SIZE + 1, y * #B_SIZE + 1, #B_SIZE - 1, #B_SIZE - 1, $FF000000)
										EndIf
										StopDrawing()
										
										StartDrawing(ImageOutput(#I_Tricky))
										
									EndIf
									
								Next
							Next
							StopDrawing()
							
							x	=	xa
							y	=	ya
							
							_LayerXY(pz, x, y)
							
						EndIf
						
					Else

						Break	; MouseButton Up!
						
					EndIf
					
				EndIf
				
			ForEver
			
			If	IsImage(#I_Temp)	:	FreeImage(#I_Temp)	:	EndIf
			
			; Now set balls by drawed pixels (bad tricky but funny easy)
			StartDrawing(ImageOutput(#I_Tricky))
			For	y	=	0	To	#B_Y	-	1
				For	x	=	0	To	#B_X	-	1
					
					If	Point(x, y)	=	#White
						
						Ball(pz, x, y)\On	=	Status
						Ball(pz, x, y)\ID	=	BallID
						
						If	Mode	<>	#G_Fill	; don't change size if mode:fill
							Ball(pz, x, y)\s	=	ps
						EndIf
						
					EndIf
					
				Next
			Next
			Box(0, 0, OutputWidth(), OutputHeight(), #Black)	; clear for next use
			StopDrawing()
			
			_LayerShow()
			
	EndSelect

EndProcedure
Procedure	_LayerFlipX(pz)
	
	Protected	x, y, i, n.f
	
	For	x	=	0	To	#B_X	/	2	-	1
		
		i	=	#B_X	-	(x	+	1)
		
		For	y	=	0	To	#B_Y	-	1

			With	Ball(pz, x, y)
				n	=	\On	:	\On	=	Ball(pz, i, y)\On	:	Ball(pz, i, y)\On	=	n
				n	=	\ID	:	\ID	=	Ball(pz, i, y)\ID	:	Ball(pz, i, y)\ID	=	n
				n	=	\s		:	\s		=	Ball(pz, i, y)\s	:	Ball(pz, i, y)\s	=	n
				n	=	\sx	:	\sx	=	Ball(pz, i, y)\sx	:	Ball(pz, i, y)\sx	=	n
				n	=	\sy	:	\sy	=	Ball(pz, i, y)\sy	:	Ball(pz, i, y)\sy	=	n
				n	=	\sz	:	\sz	=	Ball(pz, i, y)\sz	:	Ball(pz, i, y)\sz	=	n
			EndWith
			
		Next
	Next
	
EndProcedure
Procedure	_LayerFlipY(pz)
	
	Protected	x, y, i, n.f

	For	y	=	0	To	#B_Y	/	2	-	1
		
		i	=	#B_Y	-	(y	+	1)
		
		For	x	=	0	To	#B_X	-	1
			
			With	Ball(pz, x, y)
				n	=	\On	:	\On	=	Ball(pz, x, i)\On	:	Ball(pz, x, i)\On	=	n
				n	=	\ID	:	\ID	=	Ball(pz, x, i)\ID	:	Ball(pz, x, i)\ID	=	n
				n	=	\s		:	\s		=	Ball(pz, x, i)\s	:	Ball(pz, x, i)\s	=	n
				n	=	\sx	:	\sx	=	Ball(pz, x, i)\sx	:	Ball(pz, x, i)\sx	=	n
				n	=	\sy	:	\sy	=	Ball(pz, x, i)\sy	:	Ball(pz, x, i)\sy	=	n
				n	=	\sz	:	\sz	=	Ball(pz, x, i)\sz	:	Ball(pz, x, i)\sz	=	n
			EndWith
			
		Next
	Next
	
EndProcedure
Procedure	_LayerClear()
	
	StatusBarText(0, #T_INFO, StringField(GetMenuItemText(0, #M_LayerClear), 1, #TAB$), #PB_StatusBar_Center)
	
	Protected	x, y, pz = M_GetZ()

	For	y	=	0	To	#B_Y	-	1
		For	x	=	0	To	#B_X	-	1
			
			With	Ball(pz, x, y)
				\On	=	#Null
				\ID	=	#Null
				\s		=	#Null
				\sx	=	#Null
				\sy	=	#Null
				\sz	=	#Null
			EndWith
			
		Next
	Next
	
	_LayerShow()
	
EndProcedure
Procedure	_LayerCopy()
	
	; planecopy
	
	Protected	*tmp.C2D::RS_Ball3D
	Protected	pz, x, y, Count
	
	pz		=	M_GetZ()
	Count	=	_LayerCount(pz)
	
	If	Count	=	#Null	:	ProcedureReturn	#Null	:	EndIf
	
	ForEach	Brush()
		SetMenuItemState(0, #M_BrushUse + ListIndex(Brush()), 0)
	Next
	
	If	*ObjectBuffer
		FreeMemory(*ObjectBuffer)
	EndIf
	
	; Header = MagicID.Long + Count.Long .. Count[Ball]
	*ObjectBuffer	=	AllocateMemory(Count * SizeOf(C2D::RS_Ball3D) + SizeOf(Long) * 2)
	
	If	*ObjectBuffer
		
		*tmp	=	*ObjectBuffer
		
		PokeL(*tmp, C2D::#ID_B3DR)	:	*tmp	+	SizeOf(Long)	; MagigID '3DBO'
		PokeL(*tmp, Count)			:	*tmp	+	SizeOf(Long)	; Number of balls on plane
		
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				With	Ball(pz, x, y)
					If	\On
						
						*tmp\ID	=	\ID	; BallImage (0 - 7)
						
						*tmp\x	=	\x		; x-pos
						*tmp\y	=	\y		; y-pos
						*tmp\z	=	0		; z-pos alway zero (as drawing plane)
						
						*tmp\s	=	\s		; size (factor)
						
						*tmp\sx	=	\sx	; spin x-axis
						*tmp\sy	=	\sy	; spin y-axis
						*tmp\sz	=	\sz	; spin z-axis
						
						*tmp	+	SizeOf(C2D::RS_Ball3D)
						
					EndIf
				EndWith
			Next
		Next
		
		StatusBarText(0, #T_INFO, StringField(GetMenuItemText(0, #M_LayerCopy), 1, #TAB$) + " (" + Str(Count) + " Balls)", #PB_StatusBar_Center)
		
	EndIf
	
	DisableGadget(#G_Brush, Bool(*ObjectBuffer)!1)
	
	While	WindowEvent()	:	Wend

	ProcedureReturn	Bool(*ObjectBuffer)
	
EndProcedure
Procedure	_LayerMove(z, Direction)
	
	Protected	i, x, y
	
	With	Ball(z, x, y)
		
		Select	Direction
			Case	#M_LayerU, #G_Up
				For	y	=	0	To	#B_Y-1
					For	x	=	0	To	#B_X-1
						If	y	<	#B_Y	-	1
							i	=	y	+	1
							\On	=	Ball(z, x, i)\On
							\ID	=	Ball(z, x, i)\ID
							\s		=	Ball(z, x, i)\s
							\sx	=	Ball(z, x, i)\sx
							\sy	=	Ball(z, x, i)\sy
							\sz	=	Ball(z, x, i)\sz
						Else
							\On	=	#Null
						EndIf
					Next
				Next
				
			Case	#M_LayerD, #G_Down
				For	y	=	#B_Y - 1	To	0	Step	-1
					For	x	=	0	To	#B_X-1
						If	y	>	#Null
							i	=	y	-	1
							\On	=	Ball(z, x, i)\On
							\ID	=	Ball(z, x, i)\ID
							\s		=	Ball(z, x, i)\s
							\sx	=	Ball(z, x, i)\sx
							\sy	=	Ball(z, x, i)\sy
							\sz	=	Ball(z, x, i)\sz
						Else
							\On	=	#Null
						EndIf
					Next
				Next
				
			Case	#M_LayerL, #G_Left
				For	x	=	0	To	#B_X-1
					For	y	=	0	To	#B_Y-1
						If	x	<	#B_X	-	1
							i	=	x	+	1
							\On	=	Ball(z, i, y)\On
							\ID	=	Ball(z, i, y)\ID
							\s		=	Ball(z, i, y)\s
							\sx	=	Ball(z, i, y)\sx
							\sy	=	Ball(z, i, y)\sy
							\sz	=	Ball(z, i, y)\sz
						Else
							\On	=	#Null
						EndIf
					Next
				Next
				
			Case	#M_LayerR, #G_Right
				For	x	=	#B_X - 1	To	0	Step	-1
					For	y	=	0	To	#B_Y - 1
						If	x	>	#Null
							i	=	x	-	1
							\On	=	Ball(z, i, y)\On
							\ID	=	Ball(z, i, y)\ID
							\s		=	Ball(z, i, y)\s
							\sx	=	Ball(z, i, y)\sx
							\sy	=	Ball(z, i, y)\sy
							\sz	=	Ball(z, i, y)\sz
						Else
							\On	=	#Null
						EndIf
					Next
				Next
				
		EndSelect
		
	EndWith
	
EndProcedure

Procedure	_LayerTurnZX(pz)
	
	Protected	z, x, y
	Protected	px	=	(#B_X	-	1)	/	2
	
	For	x	=	0	To	#B_X	-	1
		For	y	=	0	To	#B_Y	-	1
			
			z	=	pz	+	x	-	px
			
			With	Ball(pz, x, y)

				If	\On
					
					\On	=	#False
					
					If	z	>=	0	And	z	<	#B_Z
						
						Ball(z, px, y)\On	=	#True
						Ball(z, px, y)\ID	=	\ID
						Ball(z, px, y)\s	=	\s
						Ball(z, px, y)\sx	=	\sx
						Ball(z, px, y)\sy	=	\sy
						Ball(z, px, y)\sz	=	\sz
						
					Else
						
						\ID	=	#Null
						\s		=	#Null
						\sx	=	#Null
						\sy	=	#Null
						\sz	=	#Null

					EndIf
					
				EndIf

			EndWith
			
		Next
	Next
	
EndProcedure
Procedure	_LayerTurnZY(pz)
	
	Protected	z, x, y
	Protected	py	=	(#B_Y	-	1)	/	2
	
	For	x	=	0	To	#B_X	-	1
		For	y	=	0	To	#B_Y	-	1
			
			z	=	pz	+	y	-	py
			
			With	Ball(pz, x, y)

				If	\On
					
					\On	=	#False
					
					If	z	>=	0	And	z	<	#B_Z
						
						Ball(z, x, py)\On	=	#True
						Ball(z, x, py)\ID	=	\ID
						Ball(z, x, py)\s	=	\s
						Ball(z, x, py)\sx	=	\sx
						Ball(z, x, py)\sy	=	\sy
						Ball(z, x, py)\sz	=	\sz
						
					Else
						
						\ID	=	#Null
						\s		=	#Null
						\sx	=	#Null
						\sy	=	#Null
						\sz	=	#Null

					EndIf
					
				EndIf

			EndWith
			
		Next
	Next
	
EndProcedure

Procedure	_ObjectBuffer()
	
	; Create/copy Ball3D Array to memory.RS_Ball3D
	
	; LONG	MagicID 3DBO"
	; LONG	Number of balls
	; REPT	ID.b, x.b, y.b, z.b, s.b...
	
	Protected	*Ptr, *tmp.C2D::RS_Ball3D
	Protected	x, y, z, Count
	
	Count	=	_BallCount()	:	If	Count	=	#Null	:	ProcedureReturn	#Null	:	EndIf
	
	; Header = MagicID.Long + Count.Long .. Count[Ball]
	*Ptr	=	AllocateMemory(Count * SizeOf(C2D::RS_Ball3D) + SizeOf(Long) * 2)
	*tmp	=	*Ptr
	
	PokeL(*tmp, C2D::#ID_B3D0)	:	*tmp	+	SizeOf(Long)	; MagigID '3DB0'
	PokeL(*tmp, Count)			:	*tmp	+	SizeOf(Long)	; Number of balls
	
	For	z	=	0	To	#B_Z	-	1
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				With	Ball(z, x, y)
					
					If	\On
						
						*tmp\ID	=	\ID	; BallImage (0 - 7)
						
						*tmp\x	=	\x		; x-pos
						*tmp\y	=	\y		; y-pos
						*tmp\z	=	\z		; z-pos
						
						*tmp\s	=	\s		; size (factor)

						*tmp\sx	=	\sx	; spin x-axis
						*tmp\sy	=	\sy	; spin y-axis
						*tmp\sz	=	\sz	; spin z-axis
						
						; ****** TEST + ONLY + STARFIELD + ONLY + TEST *****
; 						*tmp\ID	=	7	; BallImage (0 - 7)
; 						*tmp\x	=	\x	*	(0.1	*	Random(20, 10))	; x-pos
; 						*tmp\y	=	\y	*	(0.1	*	Random(20, 10))	; y-pos
; 						*tmp\z	=	\z	*	(0.1	*	Random(20, 10))	; z-pos
; 						*tmp\s	=	0;\s		; size (factor)
												
						*tmp	+	SizeOf(C2D::RS_Ball3D)
						
					EndIf
					
				EndWith
			Next
		Next
	Next
	
	ProcedureReturn	*Ptr
	
EndProcedure
Procedure	_ObjectFree()
	
	StatusBarText(0, #T_INFO, StringField(GetMenuItemText(0, #M_ObjectFree), 1, #TAB$), #PB_StatusBar_Center)
	StatusBarText(0, #T_FILE, FormatDate(GetWindowTitle(0) + " %dd.%mm.%yyyy %hh:%ii:%ss", #PB_Compiler_Date))
	
	Protected	i, x, y, z
	
	For	z	=	0	To	#B_Z - 1
		For	y	=	0	To	#B_Y - 1
			For	x	=	0	To	#B_X - 1
				
				With	Ball(z, x, y)
					
					\On	=	#Null
					\ID	=	#Null
					
					\x		=	x - (#B_X - 1) * 0.5 ; 0-x/2
					\y		=	y - (#B_Y - 1) * 0.5	; 0-y/2
					\z		=	z - (#B_Z - 1) * 0.5	; 0-z/2
					
					\s		=	#Null
					
					\sx	=	#Null
					\sy	=	#Null
					\sz	=	#Null
					
				EndWith
				
			Next
		Next
	Next
	
	SetGadgetState(#G_LayerZ,	0)	; CenterZ
	SetGadgetState(#G_IsZoom,	0)	; No bobsize
	M_SetBobSize(10)					; Default bobsize (0 / 1.0 = 100%)
	DisableGadget(#G_Zoom,		1)
	
	; BallSpin
	SetGadgetState(#G_IsSpin, 0)
	For	i	=	#G_Spin	To	#G_SpinZ
		SetGadgetState(i,	0)
		DisableGadget(i,	1)
	Next
	
	If	IsImage(#I_Tricky)	:	FreeImage(#I_Tricky)	:	EndIf	; TrickyDraw
	If	IsImage(#I_Temp)		:	FreeImage(#I_Temp)	:	EndIf

	_LayerShow()
	
EndProcedure
Procedure	_ObjectSave(Flags=0)
	
	; Flags <> 0 -> save current edited object on end
	
	If	_BallCount()	=	#Null
		If	Flags	:	DeleteFile(Unsaved$)	:	EndIf	; no balls on end -> delete last edited
		ProcedureReturn	#Null
	EndIf
	
	Protected	*Ptr, t$
	
	If	Flags
		t$	=	Unsaved$
	Else
		t$	=	SaveFileRequester("Save as", File$, "B3D - Ball3D Object|*.b3d|All files|*.*", SelectedFilePattern())
	EndIf
	
	If	t$
		
		File$	=	GetPathPart(t$)	+	GetFilePart(t$, #PB_FileSystem_NoExtension)	+	".b3d"
		
		If	Flags	=	#False
			If	FileSize(File$)	>	0
				If	MessageRequester("Save Ball3D Object", File$ + #LF$ + #LF$ + "File already exist, overwrite?", #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)	<>	#PB_MessageRequester_Yes
					ProcedureReturn
				EndIf
			EndIf
		EndIf
		
		*Ptr	=	_ObjectBuffer()
		
		If	*Ptr	; any balls avail?
			
			If	CreateFile(0, File$)
				WriteData(0, *Ptr, MemorySize(*Ptr))
				CloseFile(0)
			EndIf

			StatusBarText(0, #T_FILE, GetFilePart(File$))
			StatusBarText(0, #T_INFO, "Saved object: " + Str(MemorySize(*Ptr)) + " Bytes (" + StrF(MemorySize(*Ptr) / 1024.0, 2) + " KB)", #PB_StatusBar_Center)
			
			FreeMemory(*Ptr)

		EndIf
		
	EndIf
	
EndProcedure
Procedure	_ObjectOpen(Flags=0)
	
	; Flags <> 0 -> install last edited object
	
	Protected	ID_B3D.l	; Objectmode
	Protected	Count, i
	Protected.b	ID, x, y, z, s, rx, ry, rz
	Protected	t$, temp$
	
	If	Flags
		temp$	=	File$
		t$		=	Unsaved$
	Else
		t$	=	OpenFileRequester("Open", File$, "B3D - Ball3D Object|*.b3d|All files|*.*", SelectedFilePattern())
	EndIf
	
	If	t$
		
		File$	=	t$
		
		_ObjectFree()
		
		If	ReadFile(0, File$)
			
			ID_B3D	=	ReadLong(0)	; MagicID
			
			If	ID_B3D	=	C2D::#ID_B3D0	Or	ID_B3D	=	C2D::#ID_B3DR
				
				Count	=	ReadLong(0)	-	1	; Number of balls
				
				For	i	=	0	To	Count
					
					ID	=	ReadByte(0)	; BallID 0 - 7
					x	=	ReadByte(0)	; x
					y	=	ReadByte(0)	; y
					z	=	ReadByte(0)	; z
					s	=	ReadByte(0)	; s(ize)

					rx	=	ReadByte(0)	; Spin X
					ry	=	ReadByte(0)	; Spin Y
					rz	=	ReadByte(0)	; Spin Z

					x	=	(#B_X - 1) * 0.5	+	x
					y	=	(#B_Y - 1) * 0.5	+	y
					z	=	(#B_Z - 1) * 0.5	+	z

					If	(z	>=	0	And	z	<=	#B_Z)	And	(x	>=	0	And	x	<=	#B_X)	And	(y	>=	0	And	y	<=	#B_Y)
						With	Ball(z, x, y)
							
							\On	=	#True
							\ID	=	ID
							\s		=	s
							\sx	=	rx	;+	1-Random(2)
							\sy	=	ry	;+	1-Random(2)
							\sz	=	rz	;+	1-Random(2)
							
						EndWith
					EndIf
					
				Next
				
				; swap layer, layerz
				li	=	#Null
				lz	=	z	-	(#B_Z - 1) * 0.5

			EndIf
			
			CloseFile(0)	
			
			If	Flags	=	#False
				StatusBarText(0, #T_FILE, GetFilePart(File$))
				t$	=	"Loaded: " + Str(FileSize(File$)) + " Bytes"
				If	ID_B3D	<>	C2D::#ID_B3D0
					t$	+	" (old)"
				EndIf
				StatusBarText(0, #T_INFO, t$, #PB_StatusBar_Center)
			EndIf
			
		EndIf
		
	EndIf
	
	If	Flags
		File$	=	temp$
	EndIf
	
	_LayerShow()
	
EndProcedure
Procedure	_ObjectPure()
	
	; Copy as Purebasic includefile (pbi/ascii)

	Protected	t$, b$, x, y, z, Count, i, w, h, Event
	
	Count	=	_BallCount()	:	If	Count	=	0	:	ProcedureReturn	:	EndIf
	
	w	=	#WIN_W	*	0.75
	h	=	297
	x	=	4
	y	=	4
	
	If	IsFont(#F_ED)	=	0
		LoadFont(#F_ED, "Courier new", 8)
	EndIf
	
	OpenWindow(1, 0, 0, w, h, "Purebasic Include", #PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_SystemMenu, WindowID(0))
	EditorGadget(#G_Ed, x, y, w - x*2, h-y*3-#H)	:	SetGadgetFont(#G_Ed, FontID(#F_ED))
	
	y	=	h	-	y	-	#H
	
	ButtonImageGadget(#G_EdCopy, x, y, #H, #H, ImageID(#I_Copy))	:	x	+	#H	+	2
	ButtonImageGadget(#G_EdSave, x, y, #H, #H, ImageID(#I_Save))

	DisableGadget(#G_Ed,	#True)

	t$	=	"b3d_object:"								+	#LF$	; Label
	t$	+	"Data.l"	+	#TAB$	+	"C2D::#ID_B3D0"+	#LF$	; MagicID ($52424433) - ($4F424433)
	t$	+	"Data.l"	+	#TAB$	+	Str(Count)					; Number of balls
	
	AddGadgetItem(#G_Ed, -1, t$)
	
	w	=	Len(t$)	+	1
	
	t$	=	#Null$
	
	; Data = ID.b, x.b, y.b, z.b, s.b
	For	z	=	0	To	#B_Z	-	1
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				With	Ball(z, x, y)
					
					If	\On
						
						t$	+	Str(\ID)	+	","	+	; ImageNumber (0 - 7)
						  	 	Str(\x)	+	","	+
						  	 	Str(\y)	+	","	+
						  	 	Str(\z)	+	","	+
						  	 	Str(\s)	+	","	+
						  	 	Str(\sx)	+	","	+
						  	 	Str(\sy)	+	","	+
						  	 	Str(\sz)	+	","	+
						  	 	#TAB$
						
						i	+	1
						
					EndIf
					
					If	Len(t$)
						If	i	>=	Count	Or	(i	%	8	=	0)
							
							t$	=	"Data.b"	+	#TAB$	+	RTrim(RTrim(t$, #TAB$), ",")
							
							AddGadgetItem(#G_Ed, -1, t$)
							
							w	+	Len(t$)	+	1
							t$	=	#Null$
							
							StatusBarProgress(0, #T_INFO, i, #PB_StatusBar_BorderLess, 0, Count)
							
							While	WindowEvent()	:	Wend
							
						EndIf
					EndIf
					
				EndWith
			Next
		Next
	Next
	
	DisableGadget(#G_Ed, #False)
	
	StatusBarText(0, #T_INFO, "Generated data: " + Str(w) + " Bytes", #PB_StatusBar_Center)
	
	Repeat
		Event	=	WaitWindowEvent()
		Select	Event
			Case	#PB_Event_Gadget
				Select	EventGadget()
						
					Case	#G_EdCopy
						SendMessage_(GadgetID(#G_Ed), #EM_SETSEL,	0,-1)
						SendMessage_(GadgetID(#G_Ed), #WM_COPY,	0,	0)
						StatusBarText(0, #T_INFO, "Copied as include: " + Str(w) + " Bytes", #PB_StatusBar_Center)
						
					Case	#G_EdSave
						SendMessage_(GadgetID(#G_Ed), #EM_SETSEL,	0,-1)
						
						t$	=	GetPathPart(File$)	+	GetFilePart(File$, #PB_FileSystem_NoExtension)	+	".pbi"
						t$	=	SaveFileRequester("Save as", t$, "PBI - Purebasic include|*.pbi|All files|*.*", SelectedFilePattern())
						
						If	t$
							i	=	#True
							File$	=	GetPathPart(t$)	+	GetFilePart(t$, #PB_FileSystem_NoExtension)	+	".pbi"
							If	FileSize(File$)	>	0
								If	MessageRequester("Save Purebasic include", File$ + #LF$ + #LF$ + "File already exist, overwrite?", #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)	<>	#PB_MessageRequester_Yes
									i	=	#False
								EndIf
							EndIf
						Else
							i	=	#False
						EndIf
						
						If	i
							If	CreateFile(0, File$)
								
								Count	=	CountGadgetItems(#G_Ed)	-	1
								
								For	i	=	0	To	Count
									WriteStringN(0, GetGadgetItemText(#G_Ed, i), #PB_Ascii)
									StatusBarProgress(0, #T_INFO, i, #PB_StatusBar_BorderLess, 0, Count)
									While	WindowEvent()	:	Wend
								Next
								
								CloseFile(0)
								
								Count	=	FileSize(File$)
								StatusBarText(0, #T_FILE, GetFilePart(File$))
								StatusBarText(0, #T_INFO, "Saved PBI: " + Str(Count) + " Bytes (" + StrF(Count / 1024.0, 2) + " KB)", #PB_StatusBar_Center)
								
							EndIf
						EndIf
						
				EndSelect
		EndSelect
	Until	Event	=	#PB_Event_CloseWindow
	
	CloseWindow(1)
	
	While	WindowEvent()	:	Wend
	
EndProcedure
Procedure	_ObjectAngle()
	
	; copy c2d-angles of view-object
	
	If	MessageRequester("Set Angles",
	  	                 "Really set angles to main object,"	+	#LF$	+
	  	                 "ballspins will be lost & perhaps corrupt angles?",
	  	                 #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)	<>	#PB_MessageRequester_Yes
		ProcedureReturn
	EndIf

	Protected	x, y, z, px.f, py.f, pz.f
	
	For	z	=	0	To	#B_Z	-	1
		For	y	=	0	To	#B_Y	-	1
			For	x	=	0	To	#B_X	-	1
				With	Ball(z, x, y)
					If	\On
						\ID	=	#Null
						\On	=	#Null
						\sx	=	#Null
						\sy	=	#Null
						\sz	=	#Null
						\s		=	#Null
					EndIf
				EndWith
			Next
		Next
	Next
	
	ForEach	C2D::RS_Ball3DObject()\Ball()
		
		With	C2D::RS_Ball3DObject()\Ball()
			px	=	Round(\px, #PB_Round_Nearest)
			py	=	Round(\py, #PB_Round_Nearest)
			pz	=	Round(\pz, #PB_Round_Nearest)
		EndWith
		
; Try for 3D-Starfield
; 		With	C2D::RS_Ball3DObject()\Ball()
; 			px	=	Random(#B_X) - Random(#B_X)
; 			py	=	Random(#B_Y) - Random(#B_Y)
; 			pz	=	Random(#B_Z) - Random(#B_Z)
; 		EndWith

		For	z	=	0	To	#B_Z	-	1
			For	y	=	0	To	#B_Y	-	1
				For	x	=	0	To	#B_X	-	1
					With	Ball(z, x, y)
						
						If	\On	=	#Null	And	\z	=	pz	And	\x	=	px	And	\y	=	py
							
							\On	=	#True
							
							\ID	=	C2D::RS_Ball3DObject()\Ball()\Color
							\s		=	C2D::RS_Ball3DObject()\Ball()\s
							
							If	\s	<	1	:	\s	=	1	:	EndIf
							
							;\sx	=	Round(C2D::RS_Ball3DObject()\Ball()\sx * C2D::#FastDivisor, #PB_Round_Nearest)
							;\sy	=	Round(C2D::RS_Ball3DObject()\Ball()\sy * C2D::#FastDivisor, #PB_Round_Nearest)
							;\sz	=	Round(C2D::RS_Ball3DObject()\Ball()\sz * C2D::#FastDivisor, #PB_Round_Nearest)
							
							Break	3
							
						EndIf
						
					EndWith
				Next
			Next
		Next
		
		StatusBarProgress(0, #T_INFO, ListIndex(C2D::RS_Ball3DObject()\Ball()), #PB_StatusBar_BorderLess, 0, ListSize(C2D::RS_Ball3DObject()\Ball()))
		
		While	WindowEvent()	:	Wend

	Next
	
	StatusBarText(0, #T_INFO, "Angles used: " + Str(ListSize(C2D::RS_Ball3DObject()\Ball())), #PB_StatusBar_Center)
	
EndProcedure
Procedure	_ObjectView()
	
	Protected		*Ptr
	Protected.i	i, Count, Smooth
	Protected.i	IsFPS=Bool(GetMenuItemState(0, #M_FPS)), IsCPU=Bool(GetMenuItemState(0, #M_CPU))
	Protected.f	px = #Null, py = #Null
	Protected.f	ax, ay, az, rx, ry, rz, a
	Protected.a	Fog, Alpha, IsSpeed, IsView, IsUseAngle
	
	Static	Shot, InitStars
	
	; Create/Copy 3DBall to memory
	*Ptr	=	_ObjectBuffer()	:	If	*Ptr	=	#Null	:	ProcedureReturn	:	EndIf
	
	StatusBarText(0, #T_INFO, "View Ball3D Object", #PB_StatusBar_Center)
	
	; Stars		
	Protected	IsStars	= Bool(GetMenuItemState(0, #M_Stars))
	If	IsStars	And	InitStars	=	#Null
		InitStars	=	#True
		C2D::Stars3DInit(#MAX_STAR, #STAR_SIZE, 0, 0, #SCR_W, #SCR_H, #STAR_SPEED)
	EndIf
	
	; Get/Set rotation/angles
	ax	=	GetGadgetState(#G_AX)
	ay	=	GetGadgetState(#G_AY)
	az	=	GetGadgetState(#G_AZ)
	
	a	=	0.1	*	Bool(GetGadgetState(#G_Rotate))
	rx	=	a		*	GetGadgetState(#G_RX)	*	Bool(GetGadgetState(#G_IsRX))
	ry	=	a		*	GetGadgetState(#G_RY)	*	Bool(GetGadgetState(#G_IsRY))
	rz	=	a		*	GetGadgetState(#G_RZ)	*	Bool(GetGadgetState(#G_IsRZ))
	
	; fade
	Fog	=	GetGadgetState(#G_Fog)	*	GetGadgetState(#G_IsFog)
	Alpha	=	255	-	Fog
	
	If	GetMenuItemState(0, #M_ThemeSmooth)
		C2D::Quality(#PB_Image_Smooth)
	Else
		C2D::Quality(#PB_Image_Raw)
	EndIf

	i	=	C2D::Ball3DInit(0, *Ptr, GetGadgetState(#G_SIZE))		; Init Ball3D Object (returns number of created images)
	
	C2D::Ball3DAngle(0, ax, ay, az)	; set to last used angles
	
	C2D::C2D\Time	=	0
	C2D::Start()
	C2D::BufferBackDraw()
	Count	=	C2D::Ball3DDraw(0, px, py, Alpha, Fog)
	If	GetGadgetState(#G_Angle)
		IsView	=	#False
		DrawingMode(#PB_2DDrawing_XOr)
		LineXY(#SCR_CX, 0, #SCR_CX, #SCR_CY * 2, $FFFFFFFF)
		LineXY(0, #SCR_CY, #SCR_CX * 2, #SCR_CY)
	Else
		IsView	=	#True
	EndIf
	C2D::C2D\Time	=	0
	C2D::Stop()

	FreeMemory(*Ptr)	; Free buffer of Ball3D-Object
	
	IsSpeed	=	Bool(GetGadgetState(#G_IsSpeed))	; CPU-Speedup?
	DisableGadget(#G_Speed,	IsSpeed)

	StatusBarText(0, #T_IMAGE, Str(i),		#PB_StatusBar_Center)	; Number of created images
	StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)	; Number of viewed balls
	
	HideGadget(#G_Container1,	0)	:	DisableGadget(#G_Container1,	0)
	HideGadget(#G_Container0,	1)	:	DisableGadget(#G_Container0,	1)
	
	While	WindowEvent()	:	Wend
	
	; Mainloop
	Repeat
		
		Select WindowEvent()

			Case	#Null	; *** Draw 3DBall Object ***

				If	IsView	And	C2D::Start()
					
					C2D::BufferBackDraw()
					
					If	IsStars
						;C2D::Stars3DDraw(px - #SCR_CX, py - #SCR_CY)
						C2D::Stars3DDraw()
					EndIf
					
					C2D::Ball3DRotate(0, rx, ry, rz)
					
					Count	=	C2D::Ball3DDraw(0, px, py, Alpha, Fog)
					
					If	IsFPS
						DrawText(GetGadgetAttribute(#G_Area,#PB_ScrollArea_X), GetGadgetAttribute(#G_Area,#PB_ScrollArea_Y), Str(C2D::C2D\FPS), $FFFFFFFF)
					EndIf

					C2D::Stop()
					
					If	i	<>	Count
						i	=	Count	:	StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)
					EndIf
					
				ElseIf	IsCPU	Or	IsView	=	#False
					
					Delay(1)	; ~20% CPU-friendly
					
				EndIf
				
			Case #PB_Event_Gadget
				Select	EventGadget()
						
					Case	#G_Rotate
						
						If	GetGadgetState(#G_Rotate)	And	GetGadgetState(#G_Angle)
							SetGadgetState(#G_Angle, 0)
						EndIf
						
						a	=	0.1	*	Bool(GetGadgetState(#G_Rotate))
						
						rx	=	a	*	GetGadgetState(#G_RX)	*	Bool(GetGadgetState(#G_IsRX))
						ry	=	a	*	GetGadgetState(#G_RY)	*	Bool(GetGadgetState(#G_IsRY))
						rz	=	a	*	GetGadgetState(#G_RZ)	*	Bool(GetGadgetState(#G_IsRZ))
						
						IsView	=	#True
						
					Case	#G_IsRX, #G_IsRY, #G_IsRZ, #G_RX, #G_RY, #G_RZ
						
						a	=	0.1	*	Bool(GetGadgetState(#G_Rotate))
						
						rx	=	a	*	GetGadgetState(#G_RX)	*	Bool(GetGadgetState(#G_IsRX))
						ry	=	a	*	GetGadgetState(#G_RY)	*	Bool(GetGadgetState(#G_IsRY))
						rz	=	a	*	GetGadgetState(#G_RZ)	*	Bool(GetGadgetState(#G_IsRZ))
						
					Case	#G_Angle
						
						C2D::C2D\Time	=	0
						
						If	GetGadgetState(#G_Angle)	; first on
							IsView	=	#False
							px			=	#Null
							py			=	#Null
							SetGadgetState(#G_Rotate, 0)
						EndIf
						
						C2D::Ball3DAngle(0, ax, ay, az)
						
						If	C2D::Start()
			
							C2D::BufferBackDraw()
							
							Count	=	C2D::Ball3DDraw(0, px, py, Alpha, Fog)
							
							If	GetGadgetState(#G_Angle)
								DrawingMode(#PB_2DDrawing_XOr)
								LineXY(#SCR_CX, 0, #SCR_CX, #SCR_H, #White)
								LineXY(0, #SCR_CY, #SCR_W, #SCR_CY)
							EndIf
							
							C2D::Stop()
							
						EndIf
						
						StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)

					Case	#G_AX, #G_AY, #G_AZ
						
						ax	=	GetGadgetState(#G_AX)
						ay	=	GetGadgetState(#G_AY)
						az	=	GetGadgetState(#G_AZ)
						
						If	GetGadgetState(#G_Angle)
							
							C2D::C2D\Time	=	0
							
							C2D::Ball3DAngle(0, ax, ay, az)
							
							If	C2D::Start()
								
								C2D::BufferBackDraw()
								
								Count	=	C2D::Ball3DDraw(0, px, py, Alpha, Fog)

								DrawingMode(#PB_2DDrawing_XOr)
								LineXY(#SCR_CX, 0, #SCR_CX, #SCR_H, #White)
								LineXY(0, #SCR_CY, #SCR_W, #SCR_CY)
								
								C2D::Stop()
								
							EndIf
							
							StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)

						EndIf
						
					Case	#G_IsFog, #G_Fog
						
						Fog	=	GetGadgetState(#G_Fog)	*	GetGadgetState(#G_IsFog)
						Alpha	=	255	-	Fog
						
						C2D::C2D\Time	=	0
						If	C2D::Start()
							Count	=	C2D::Ball3DDraw(0, px, py, Alpha, Fog)
							C2D::Stop()
						EndIf
						
						StatusBarText(0, #T_COUNT, Str(Count), #PB_StatusBar_Center)
						
					Case	#G_Speed
						C2D::C2D\Speed	=	GetGadgetState(#G_Speed)
						
					Case	#G_IsSpeed
						IsSpeed	=	Bool(GetGadgetState(#G_IsSpeed))
						DisableGadget(#G_Speed, IsSpeed)
						C2D::C2D\Speed	=	GetGadgetState(#G_Speed)	*	(IsSpeed!1)	; global!
						
					Case	#G_Canvas
						If	GetGadgetAttribute(#G_Canvas, #PB_Canvas_Buttons)&#PB_Canvas_LeftButton	And	GetGadgetState(#G_Rotate)
							px	=	GetGadgetAttribute(#G_Canvas, #PB_Canvas_MouseX)	-	#SCR_CX
							py	=	GetGadgetAttribute(#G_Canvas, #PB_Canvas_MouseY)	-	#SCR_CY
							StatusBarText(0, #T_X, Str(px / #B_SIZE), #PB_StatusBar_Center)
							StatusBarText(0, #T_Y, Str(py / #B_SIZE), #PB_StatusBar_Center)
						EndIf
						
					Case	#G_Explode
						C2D::Ball3DExplode(0, 2)	; 1 or 2
						
					Case	#G_Ruler
						_ObjectAngle()
						IsUseAngle	=	#True
						
					Case	#G_Shot
						CreateImage(#I_Temp, #SCR_W, #SCR_H)
						StartDrawing(ImageOutput(#I_Temp))
						DrawImage(GetGadgetAttribute(#G_Canvas, #PB_Canvas_Image), 0, 0)
						StopDrawing()
						SetClipboardImage(#I_Temp)
						Delay(8)
						Shot	+	1	:	StatusBarText(0, #T_INFO, "Screenshot: " + Str(Shot), #PB_StatusBar_Center)
						FreeImage(#I_Temp)
						
					Case	#G_Quit	:	Break
						
				EndSelect
				
			Case	#PB_Event_Menu
				Select	EventMenu()
					Case	#M_Color	:	_SetBackColor()
					Case	#M_Stars
						IsStars!1	:	SetMenuItemState(0, #M_Stars, IsStars)
						If	IsStars	And	InitStars	=	#Null
							InitStars	=	#True
							C2D::Stars3DInit(#MAX_STAR, #STAR_SIZE, 0, 0, #SCR_W, #SCR_H, #STAR_SPEED)
						EndIf
					Case	#M_FPS	:	IsFPS!1	:	SetMenuItemState(0, #M_FPS, IsFPS)
					Case	#M_CPU	:	IsCPU!1	:	SetMenuItemState(0, #M_CPU, IsCPU)
					Case	#M_Help	:	_SetHelp()	
					Case	#M_Center:	M_Center()
					Case	#M_About	:	_About()
					Case	#M_View	:	Break
				EndSelect
				
			Case	#PB_Event_CloseWindow, #WM_MBUTTONDOWN	:	Break
				
			Case	#WM_KEYDOWN
				Select	EventwParam()
					Case	#VK_ESCAPE	:	Break
				EndSelect
				
		EndSelect
		
	ForEver
	
	If	IsUseAngle	; Angles were copied to object
		SetGadgetState(#G_AX,	0)
		SetGadgetState(#G_AY,	0)
		SetGadgetState(#G_AZ,	0)	
	EndIf
	
	HideGadget(#G_Container0,	0)	:	DisableGadget(#G_Container0,	0)
	HideGadget(#G_Container1,	1)	:	DisableGadget(#G_Container1,	1)
	
	_LayerShow()
	
	C2D::Ball3DFree(0)

EndProcedure

Procedure	_BrushPaste(px, py, Status)
	
	Protected	*tmp.C2D::RS_Ball3D	=	*ObjectBuffer
	Protected	i, z, x, y, Count
	Protected	pz=GetGadgetState(#G_LayerZ) 
	
	If	*ObjectBuffer
		
		px	-	(#B_X	/	2)	; CenterX
		py	-	(#B_Y	/	2)	; CenterY

		*tmp	+	SizeOf(Long)	; Jump over MagicID
		Count	=	PeekL(*tmp)		; Get number of balls
		*tmp	+	SizeOf(Long)	; Set ptr to BallID's
		
		For	i	=	0	To	Count	-	1
			
			z	=	(#B_Z / 2)	+	*tmp\z	+	pz	; paste to current planeZ
			x	=	(#B_X / 2)	+	*tmp\x	+	px	; mousex
			y	=	(#B_Y	/ 2)	+	*tmp\y	+	py	; mousey
			
			If	z	<	#B_Z	And	z	>=	#Null
				If	x	<	#B_X	And	x	>=	#Null
					If	y	<	#B_Y	And	y	>=	#Null
						
						With	Ball(z, x, y)
							\On	=	Status
							\ID	=	*tmp\ID	*	Status
							\s		=	*tmp\s	*	Status
							\sx	=	*tmp\sx	*	Status
							\sy	=	*tmp\sy	*	Status
							\sz	=	*tmp\sz	*	Status
						EndWith
						
					EndIf
				EndIf
			EndIf
			
			*tmp	+	SizeOf(C2D::RS_Ball3D)
			
		Next
		
		_LayerShow()
		
	EndIf
	
EndProcedure
Procedure	_BrushCopy()
	
	If	_BallCount()	=	#Null	:	ProcedureReturn	:	EndIf
	
	ForEach	Brush()
		SetMenuItemState(0, #M_BrushUse + ListIndex(Brush()), 0)
	Next
	
	If	*ObjectBuffer
		FreeMemory(*ObjectBuffer)
	EndIf
	
	*ObjectBuffer	=	_ObjectBuffer()
	
	DisableGadget(#G_Brush, Bool(*ObjectBuffer)!1)
	
	If	*ObjectBuffer
		StatusBarText(0, #T_INFO, StringField(GetMenuItemText(0, #M_BrushCopy), 1, #TAB$) + " (" + Str(PeekL(*ObjectBuffer + SizeOf(Long))) + " Balls)", #PB_StatusBar_Center)
	EndIf
	
	ProcedureReturn	Bool(*ObjectBuffer)
	
EndProcedure
Procedure	_BrushUse(ID)
	
	If	ID	>=	ListSize(Brush())	:	ProcedureReturn	:	EndIf
	
	If	*ObjectBuffer
		FreeMemory(*ObjectBuffer)
	EndIf
	
	ForEach	Brush()
		SetMenuItemState(0, #M_BrushUse + ListIndex(Brush()), 0)
	Next
	
	SelectElement(Brush(), ID)
	
	*ObjectBuffer	=	AllocateMemory(Brush()\Length)

	If	*ObjectBuffer
		CopyMemory(Brush()\Ptr, *ObjectBuffer, Brush()\Length)
		SetMenuItemState(0, #M_BrushUse + ID,	1)
		SetGadgetState(#G_Brush,	1)
		StatusBarText(0, #T_INFO, "Brush use: " + Brush()\File$ + " (" + Str(PeekL(*ObjectBuffer + SizeOf(Long))) + " Balls)", #PB_StatusBar_Center)
	EndIf
	
	DisableGadget(#G_Brush,	Bool(*ObjectBuffer)!1)
	
	ProcedureReturn	Bool(*ObjectBuffer)

EndProcedure
Procedure	_BrushLoad()
	
	Protected	ID, MagicID.l
	Protected	t$	=	OpenFileRequester("Load brush", File$, "B3D - Ball3D Object|*.b3d|All files|*.*", SelectedFilePattern())
	
	If	t$
		
		File$	=	t$
		
		If	ReadFile(0, File$)
			
			MagicID	=	ReadLong(0)
			
			If	MagicID	=	C2D::#ID_B3D0	Or	MagicID	=	C2D::#ID_B3DR
				
				FileSeek(0, 0)
				
				t$	=	GetFilePart(File$)
				ForEach	Brush()
					If	UCase(Brush()\File$)	=	UCase(t$)
						ID	=	#True
						Break
					EndIf
				Next
				
				If	ID
					FreeMemory(Brush()\Ptr)
					DeleteElement(Brush())
				EndIf
				
				SelectElement(Brush(),	0)
				InsertElement(Brush())
				
				Brush()\File$	=	GetFilePart(File$)
				Brush()\Length	=	Lof(0)
				Brush()\Ptr		=	AllocateMemory(Brush()\Length)
				
				ReadData(0, Brush()\Ptr, Brush()\Length)
				
				If	ListSize(Brush())	=	1
					MenuBar()
				EndIf
				
				If	ID	=	#Null
					MenuItem(#M_BrushUse	+	ListSize(Brush())	-	1, #Null$)
				EndIf
				
				ForEach	Brush()
					SetMenuItemText(0, #M_BrushUse	+	ListIndex(Brush()),	Brush()\File$)
				Next
				
				ID	=	_BrushUse(0)
				
			EndIf
			
			CloseFile(0)
			
		EndIf
		
		If	ID	=	#Null
			StatusBarText(0, #T_INFO, "Error: " + GetFilePart(File$), #PB_StatusBar_Center)
		EndIf
		
	EndIf
	
	While	WindowEvent()	:	Delay(15)	:	Wend
	
	ProcedureReturn	ID
	
EndProcedure

;{ *** ICONS *** }
CatchImage(#G_Box,	?l_box)
CatchImage(#G_Circle,?l_circle)
CatchImage(#G_Fill,	?l_fill)
CatchImage(#G_Fog,	?l_fog)
CatchImage(#G_Line,	?l_line)
CatchImage(#G_Angle,	?l_angle)
CatchImage(#G_Ruler,	?l_ruler)
CatchImage(#G_Tint,	?l_tint)
CatchImage(#G_Brush,	?l_brush)
CatchImage(#G_View,	?l_view)
CatchImage(#G_Status,?l_status)
CatchImage(#G_Zoom,	?l_zoom)
CatchImage(#G_Speed,	?l_speed)
CatchImage(#G_Right,	?l_right)
CatchImage(#G_Left,	?l_left)
CatchImage(#G_Up,		?l_up)
CatchImage(#G_Down,	?l_down)
CatchImage(#G_IsSpin,?l_spin)
CatchImage(#G_Layer,	?l_layer)
CatchImage(#G_Shot,	?l_shot)
CatchImage(#G_Explode,?l_explode)

CatchImage(#I_FlipX,	?l_flipx)
CatchImage(#I_FlipY,	?l_flipy)
CatchImage(#I_TurnZX,?l_turnzx)
CatchImage(#I_TurnZY,?l_turnzy)
CatchImage(#I_Bob,	?l_bob)
CatchImage(#I_Clear,	?l_clear)
CatchImage(#I_Close,	?l_close)
CatchImage(#I_Color,	?l_color)
CatchImage(#I_Copy,	?l_copy)
CatchImage(#I_Open,	?l_open)
CatchImage(#I_Pure,	?l_pure)
CatchImage(#I_Save,	?l_save)
CatchImage(#I_About,	?l_about)
;}

;{ *** GUI *** }

LoadFont(#F_GUI,"Arial", 8)	:	SetGadgetFont(#PB_Default, FontID(#F_GUI))

OpenWindow(0, 0, 0, #WIN_W, #WIN_H, MA_C2DOS("Ball3D / Editor"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)

CreateStatusBar(0, WindowID(0))	:	SendMessage_(StatusBarID(0), #WM_SETFONT, FontID(#F_GUI), 0)
AddStatusBarField(#PB_Ignore)	; #T_FILE
AddStatusBarField(#PB_Ignore)	; #T_INFO
AddStatusBarField(38)	; #T_X
AddStatusBarField(38)	; #T_Y
AddStatusBarField(38)	; #T_S
AddStatusBarField(38)	; #T_RX
AddStatusBarField(38)	; #T_RY
AddStatusBarField(38)	; #T_RZ
AddStatusBarField(64)	; #T_COUNT
AddStatusBarField(64)	; #T_IMAGE

_MenuCreate()

ResizeWindow(0, #PB_Ignore, #PB_Ignore, #PB_Ignore, (#WIN_H + StatusBarHeight(0) + MenuHeight())&$FF2)

; *** Canvas 2D ***
ScrollAreaGadget(#G_Area, 0, 0, #WIN_W, WindowHeight(0) - 74, #SCR_W, #SCR_H, #B_SIZE, #PB_ScrollArea_BorderLess|#PB_ScrollArea_Center|#PB_Container_Single)
CanvasGadget(#G_Canvas, 0, 0, #SCR_W, #SCR_H, #PB_Canvas_ClipMouse)	:	SetGadgetAttribute(#G_Canvas, #PB_Canvas_Cursor, #PB_Cursor_Cross)
CloseGadgetList()

C2D::Init(#G_Canvas)

; *** Fast clear ***
StartDrawing(CanvasOutput(#G_Canvas))
Box(0, 0, OutputWidth(), OutputHeight(), $FF000000)
C2D::BufferBackGrab()
StopDrawing()

; ---------------------------------------------
;{ Main Gadgets
ContainerGadget(#G_Container0, 4, GadgetHeight(#G_Area) + 4, GadgetWidth(#G_Area) - 8, #H)	:	x	=	0

ButtonImageGadget(#G_View,	x, 0, #H, #H, ImageID(#G_View))	:	x	+	#H
SpinGadget(#G_Size,			x, 0, #W-4, #H, 1, 100, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_Size)	+	#S

For	i	=	0	To	C2D::#MAX_BALL	; *** Ball Gadgets ***
	CanvasGadget(#G_0+i, x, 0, #H, #H, #PB_Canvas_DrawFocus|#PB_Canvas_ClipMouse)	:	x	+	#H	;+	1
Next

x	+	#S	-	1

ButtonImageGadget(#G_Layer,x, 0, #H, #H, ImageID(#G_Layer))	:	x	+	#H
SpinGadget(#G_LayerZ, 		x, 0, #W-4, #H, -#B_Z/2, #B_Z/2, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_LayerZ)	+	#S

; Drawingmode
ButtonImageGadget(#G_Plot,		x, 0, #H, #H, #Null,					#PB_Button_Toggle)	:	x	+	#H
ButtonImageGadget(#G_Line,		x, 0, #H, #H, ImageID(#G_Line),	#PB_Button_Toggle)	:	x	+	#H
ButtonImageGadget(#G_Box,		x, 0, #H, #H, ImageID(#G_Box),	#PB_Button_Toggle)	:	x	+	#H
ButtonImageGadget(#G_Circle,	x, 0, #H, #H, ImageID(#G_Circle),#PB_Button_Toggle)	:	x	+	#H	+	#S
ButtonImageGadget(#G_Fill,		x, 0, #H, #H, ImageID(#G_Fill),	#PB_Button_Toggle)	:	x	+	#H
ButtonImageGadget(#G_Tint,		x, 0, #H, #H, ImageID(#G_Tint),	#PB_Button_Toggle)	:	x	+	#H	+	#S
ButtonImageGadget(#G_Brush,	x, 0, #H, #H, ImageID(#G_Brush),	#PB_Button_Toggle)	:	x	+	#H	+	#S
ButtonImageGadget(#G_Status,	x, 0, #H, #H, ImageID(#G_Status),#PB_Button_Toggle)	:	x	+	#H	+	#S

; Zoom
ButtonImageGadget(#G_IsZoom,	x, 0, #H, #H, ImageID(#G_Zoom),	#PB_Button_Toggle)	:	x	+	#H
SpinGadget(#G_Zoom, 				x, 0, #W-4, #H, 0, 127)	:	x	+	GadgetWidth(#G_Zoom)	+	#S	; Byte = ±127

; Spin
ButtonImageGadget(#G_IsSpin,	x, 0, #H, #H, ImageID(#G_IsSpin),	#PB_Button_Toggle)	:	x	+	#H
ButtonGadget(#G_SpinX,	x, 0, 16, #H, "X", #PB_Button_Toggle)	:	x	+	16
ButtonGadget(#G_SpinY,	x, 0, 16, #H, "Y", #PB_Button_Toggle)	:	x	+	16
ButtonGadget(#G_SpinZ,	x, 0, 16, #H, "Z", #PB_Button_Toggle)	:	x	+	16
SpinGadget(#G_Spin,		x, 0, #W-4, #H, -32, 32, #PB_Spin_Numeric)

; Move
x	=	GadgetWidth(#G_Container0)	-	#H	*	1.70
_SmallImageGadget(#G_Left,	x,					#H * 0.25,	#H * 0.5, #H * 0.5, ImageID(#G_Left))
_SmallImageGadget(#G_Right,x + #H,			#H * 0.25,	#H * 0.5, #H * 0.5, ImageID(#G_Right))
_SmallImageGadget(#G_Up,	x + #H * 0.50, 0,				#H * 0.5, #H * 0.5, ImageID(#G_Up))
_SmallImageGadget(#G_Down,	x + #H * 0.50, #H * 0.5,	#H * 0.5, #H * 0.5, ImageID(#G_Down))

CloseGadgetList()
;}
; ---------------------------------------------
;{ View Gadgets
ContainerGadget(#G_Container1, 4, GadgetHeight(#G_Area) + 4, GadgetWidth(#G_Area) - 8, #H)		:	x	=	0

ButtonImageGadget(#G_Quit,	x,	0,	#H, #H, ImageID(#I_Close))	:	x	+	#H	+	#S

ButtonImageGadget(#G_Rotate,	x,	0,	#H, #H, ImageID(#G_View), #PB_Button_Toggle)	:	x	+	#H	+	2
ButtonGadget(#G_IsRX,			x, 0, #H, #H, "X",	#PB_Button_Toggle)	:	x	+	#H	:	SpinGadget(#G_RX, x, 0, #W, #H, -100, 100, #PB_Spin_Numeric)	:	x	+	#W
ButtonGadget(#G_IsRY,			x, 0, #H, #H, "Y",	#PB_Button_Toggle)	:	x	+	#H	:	SpinGadget(#G_RY, x, 0, #W, #H, -100, 100, #PB_Spin_Numeric)	:	x	+	#W	
ButtonGadget(#G_IsRZ,			x, 0, #H, #H, "Z",	#PB_Button_Toggle)	:	x	+	#H	:	SpinGadget(#G_RZ, x, 0, #W, #H, -100, 100, #PB_Spin_Numeric)	:	x	+	#W	+	#S

ButtonImageGadget(#G_Angle,x, 0, #H, #H, ImageID(#G_Angle), #PB_Button_Toggle)		:	x	+	#H
SpinGadget(#G_AX,				x, 0, #W, #H, -C2D::#ExplodeLoop, C2D::#ExplodeLoop, #PB_Spin_Numeric)	:	x	+	#W
SpinGadget(#G_AY,				x, 0, #W, #H, -C2D::#ExplodeLoop, C2D::#ExplodeLoop, #PB_Spin_Numeric)	:	x	+	#W
SpinGadget(#G_AZ,				x, 0, #W, #H, -C2D::#ExplodeLoop, C2D::#ExplodeLoop, #PB_Spin_Numeric)	:	x	+	#W	+	#S

ButtonImageGadget(#G_IsFog,	x, 0, #H, #H, ImageID(#G_Fog),	#PB_Button_Toggle)	:	x	+	#H	:	SpinGadget(#G_Fog,	x, 0, #W, #H,	0,	128,	#PB_Spin_Numeric)	:	x	+	#W	+	#S
ButtonImageGadget(#G_IsSpeed, x, 0, #H, #H, ImageID(#G_Speed),	#PB_Button_Toggle)	:	x	+	#H	:	SpinGadget(#G_Speed, x, 0, #W, #H,	0, 1000,	#PB_Spin_Numeric)	:	x	+	#W	+	#S

ButtonImageGadget(#G_Explode, GadgetWidth(#G_Container1) - #H*3-#S*2, 0, #H, #H, ImageID(#G_Explode))

ButtonImageGadget(#G_Ruler,GadgetWidth(#G_Container1) - #H*2-#S, 0, #H, #H, ImageID(#G_Ruler))
ButtonImageGadget(#G_Shot, GadgetWidth(#G_Container1) - #H, 0, #H, #H, ImageID(#G_Shot))

CloseGadgetList()
;}
; ---------------------------------------------
;{ Default setup
SetGadgetState(#G_Size, #B_SIZE)	; BallSize (20)

SetGadgetState(#G_LayerZ,	z)	; PlaneZ
DisableGadget(#G_Zoom, Bool(GetGadgetState(#G_IsZoom)) ! 1)

SetGadgetState(#G_Rotate,	1)	; Rotate XYZ
SetGadgetState(#G_IsRX,		1)	:	SetGadgetState(#G_RX,	13)
SetGadgetState(#G_IsRY,		1)	:	SetGadgetState(#G_RY,	 9)
SetGadgetState(#G_IsRZ,		1)	:	SetGadgetState(#G_RZ,	 6)

SetGadgetState(#G_AX,		0)	; Angle XYZ
SetGadgetState(#G_AY,		0)
SetGadgetState(#G_AZ,		0)

SetGadgetState(#G_IsFog,	1)	:	SetGadgetState(#G_Fog,	20)	; Fog

SetGadgetState(#G_IsSpeed,	0)
SetGadgetState(#G_Speed,	C2D::C2D\Speed)	; Canvas speed

_Theme()	; Default bobs
_SetDrawBall(BallID)

Mode	=	_SetDrawMode()	; DrawingMode: Pencil
;}
; ---------------------------------------------

DisableGadget(#G_Container1,	1)	:	HideGadget(#G_Container1, 1)

_ObjectFree()
_ObjectOpen(#True)
_LayerShow()

StatusBarText(0, #T_INFO, #Null$)
M_Center()

HideWindow(0, 0, #PB_Window_ScreenCentered)

;CreateThread(@_ProcessCPU(), 0)
;}

SetWindowCallback(@WinCallback() * Bool(GetMenuItemState(0, #M_Help)))

Repeat

	Event = WaitWindowEvent()
	
	Select	Event
		Case	#PB_Event_Gadget
			
			Gadget	=	EventGadget()
			
			Select	Gadget
				Case	#G_Canvas
					;{ *** Draw on Canvas *** }
					px	=	M_GetX()
					py	=	M_GetY()
					pz	=	M_GetZ()

					If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(#G_Canvas, #PB_Canvas_Buttons)&#PB_Canvas_LeftButton)

						Status	=	Bool(GetGadgetState(#G_Status)) ! 1	; rubber?

						ps	=	M_GetBobSize()	*	Status	; size (0 if rubber)
						i	=	BallID			*	Status	; 0 - 7 (0 if rubber)
						
						_LayerXY(pz, px, py)	; position
						
						Select	Mode
							Case	#G_Plot	:	_LayerPlot(i, pz, px, py, ps, Status)
							Case	#G_Tint	:	_LayerTint(i, pz, px, py, Status)
							Case	#G_Line,
							    	#G_Box,
							    	#G_Circle,
							    	#G_Fill	:	_LayerDraw(i, pz, px, py, ps, Status)
							Case	#G_Brush	:	_BrushPaste(px, py, Status)
						EndSelect
						
					Else
						
						Select	EventType()
							Case	 #PB_EventType_MouseMove		; x/y position
								_LayerXY(pz, px, py)
							Case	#PB_EventType_LeftButtonUp		; drawing stoped
								_LayerXY(pz, px, py)
								_LayerShow()
								
							Case	#PB_EventType_RightButtonUp	; get/set size of bob
								
								With	Ball(pz, px, py)
									
									; size
									SetGadgetState(#G_IsZoom,	Bool(\s))
									DisableGadget(#G_Zoom,		Bool(\s) ! 1)
									M_SetBobSize(\s)
									
									; spin
									If	\sx
										i	=	\sx
									ElseIf	\sy
										i	=	\sy
									ElseIf	\sz
										i	=	\sz
									Else
										i	=	#Null
									EndIf
									
									SetGadgetState(#G_Spin,	i)
									
									i	=	Bool(i)

									SetGadgetState(#G_IsSpin,	i)		:	DisableGadget(#G_Spin,		i!1)
									
									DisableGadget(#G_SpinX,		i!1)	:	SetGadgetState(#G_SpinX,	Bool(\sx<>0))
									DisableGadget(#G_SpinY,		i!1)	:	SetGadgetState(#G_SpinY,	Bool(\sy<>0))
									DisableGadget(#G_SpinZ,		i!1)	:	SetGadgetState(#G_SpinZ,	Bool(\sz<>0))

								EndWith
								
								_LayerXY(pz, px, py)
								
							Case	#PB_EventType_MouseLeave
								_LayerShow()
						EndSelect
						
					EndIf
					;}
					
				Case	#G_Layer	; swap layer (set in ObjectOpen)
					li	+	1	:	If	li	>	3	:	li	=	0	:	EndIf
					Select	li
						Case	1		:	SetGadgetState(#G_LayerZ,	Abs(lz))
						Case	3		:	SetGadgetState(#G_LayerZ,	-Abs(lz))
						Case	2,0	:	SetGadgetState(#G_LayerZ,	0)
					EndSelect
					_LayerShow()
				Case	#G_LayerZ	; Plane up/down
					pz	=	M_GetZ()
					If	z	<>	pz
						z	=	pz	:	_LayerShow()
					EndIf
					lz	=	GetGadgetState(#G_LayerZ)	; swap layer

				Case	#G_0 To #G_7	; DrawingBall
					If EventType() = #PB_EventType_LeftButtonDown
						If	BallID	<>	Gadget	-	#G_0
							BallID	=	Gadget	-	#G_0	:	_SetDrawBall(BallID)
						EndIf
						SetGadgetState(#G_Status, 0)	; rubber off
					EndIf

				Case	#G_Plot To	#G_Tint	; PaintMode
					Mode	=	_SetDrawMode(Gadget)
					
				Case	#G_IsZoom
					DisableGadget(#G_Zoom, Bool(GetGadgetState(#G_IsZoom))!1)
					
				Case	#G_Zoom
					M_SetBobSize(GetGadgetState(#G_Zoom))

				Case	#G_View	; Show Ball3D Object
					_ObjectView()
					
				Case	#G_IsSpin
					For	i	=	#G_Spin	To	#G_SpinZ
						DisableGadget(i, GetGadgetState(#G_IsSpin)!1)
					Next
				Case	#G_SpinX, #G_SpinY, #G_SpinZ
					DisableGadget(#G_Spin, Bool(GetGadgetState(#G_SpinX) + GetGadgetState(#G_SpinY) + GetGadgetState(#G_SpinZ))!1)
					
				Case	#G_Left, #G_Right, #G_Up, #G_Down
					For	i	=	0	To	#B_Z	-	1
						_LayerMove(i, Gadget)
					Next
					_LayerShow()
					
			EndSelect
			
		Case	#PB_Event_Menu
			;{ *** Menu-Events *** }
			SetGadgetState(#G_Status, 0)		; rubber off by default (damn loosy mind)
			Mode	=	_SetDrawMode(#G_Plot)	; reset plot by default (fill/tint off)
			
			Select	EventMenu()
				Case	#M_ObjectOpen		:	_ObjectOpen()	:	z	=	-1	; z-Layer must reset (#G_LayerZ)
				Case	#M_ObjectFree		:	_ObjectFree()	:	z	=	-1
				Case	#M_ObjectSave		:	_ObjectSave()
				Case	#M_ObjectPure		:	_ObjectPure()
				Case	#M_ObjectFlipX
					For	pz	=	0	To	#B_Z	-	1
						_LayerFlipX(pz)
					Next
					_LayerShow()
				Case	#M_ObjectFlipY
					For	pz	=	0	To	#B_Z	-	1
						_LayerFlipY(pz)
					Next
					_LayerShow()
				Case	#M_Exit		:	Break
					
				Case	#M_ThemeLoad
					Path$	=	PathRequester("Load Ball3D Bobs (0.png - 7.png)", Path$)
					If	Path$
						_Theme(Path$)
						_SetDrawBall(BallID)
						_LayerShow()
					EndIf
				Case	#M_ThemeDefault
					_Theme()
					_SetDrawBall(BallID)
					_LayerShow()
				Case	#M_ThemeSmooth
					SetMenuItemState(0, #M_ThemeSmooth, Bool(GetMenuItemState(0,#M_ThemeSmooth)!1))
					
				Case	#M_LayerClear	:	_LayerClear()
				Case	#M_LayerCopy
					If	_LayerCopy()
						Mode	=	_SetDrawMode(#G_Brush)
					EndIf
				Case	#M_LayerFlipX
					pz	=	M_GetZ()
					_LayerFlipX(pz)
					_LayerShow()
				Case	#M_LayerFlipY
					pz	=	M_GetZ()
					_LayerFlipY(pz)
					_LayerShow()
				Case	#M_LayerTurnZX
					pz	=	M_GetZ()
					_LayerTurnZX(pz)
					_LayerShow()
				Case	#M_LayerTurnZY
					pz	=	M_GetZ()
					_LayerTurnZY(pz)
					_LayerShow()
				Case	#M_LayerD, #M_LayerL, #M_LayerR, #M_LayerU	; MoveXY
					pz	=	M_GetZ()
					_LayerMove(pz, EventMenu())
					_LayerShow()

				Case	#M_View		:	_ObjectView()
				Case	#M_Color
					_SetBackColor()
					_LayerShow()
				Case	#M_Stars		:	SetMenuItemState(0, #M_Stars,	Bool(GetMenuItemState(0, #M_Stars))	!	1)
				Case	#M_FPS		:	SetMenuItemState(0, #M_FPS,	Bool(GetMenuItemState(0, #M_FPS))	!	1)
				Case	#M_CPU		:	SetMenuItemState(0, #M_CPU,	Bool(GetMenuItemState(0, #M_CPU))	!	1)
				Case	#M_Help		:	_SetHelp()
				Case	#M_Center	:	M_Center()
				Case	#M_About		:	_About()
					
				Case	#M_BrushLoad
					If	_BrushLoad()
						Mode	=	_SetDrawMode(#G_Brush)
					EndIf
				Case	#M_BrushCopy
					If	_BrushCopy()
						Mode	=	_SetDrawMode(#G_Brush)
					EndIf
				Case	#M_BrushUse	To	#M_BrushUse	+	ListSize(Brush())
					If	_BrushUse(EventMenu() - #M_BrushUse)
						Mode	=	_SetDrawMode(#G_Brush)
					EndIf
			EndSelect
			;}

		Case	#WM_MBUTTONDOWN	:	_ObjectView()

	EndSelect
	
Until Event = #PB_Event_CloseWindow

_ObjectSave(#True)	; save current edited object

C2D::Free()

End

DataSection
	; icons
	IncludePath	"..\..\Data\Icon\"
	l_save:		:	IncludeBinary	"save.ico"
	l_open:		:	IncludeBinary	"open.ico"
	l_close:		:	IncludeBinary	"close.ico"
	l_view:		:	IncludeBinary	"view.ico"
	l_line:		:	IncludeBinary	"line.ico"
	l_box:		:	IncludeBinary	"box.ico"
	l_circle:	:	IncludeBinary	"circle.ico"
	l_fill:		:	IncludeBinary	"fill.ico"
	l_tint:		:	IncludeBinary	"tint.ico"
	l_fog:		:	IncludeBinary	"fog.ico"
	l_ruler:		:	IncludeBinary	"ruler.ico"
	l_angle:		:	IncludeBinary	"angle.ico"
	l_clear:		:	IncludeBinary	"clear.ico"
	l_copy:		:	IncludeBinary	"copy.ico"
	l_brush:		:	IncludeBinary	"brush.ico"
	l_pure:		:	IncludeBinary	"pure.ico"
	l_bob:		:	IncludeBinary	"bob.ico"
	l_color:		:	IncludeBinary	"color.ico"
	l_status:	:	IncludeBinary	"status.ico"
	l_zoom:		:	IncludeBinary	"zoom.ico"
	l_speed:		:	IncludeBinary	"speed.ico"
	l_spin:		:	IncludeBinary	"spin.ico"
	l_about:		:	IncludeBinary	"about.ico"
	l_layer:		:	IncludeBinary	"layer.ico"
	l_shot:		:	IncludeBinary	"shot.ico"
	l_explode:	:	IncludeBinary	"explode.ico"
	
	l_flipx:		:	IncludeBinary	"flipx.ico"
	l_flipy:		:	IncludeBinary	"flipy.ico"
	l_turnzx:	:	IncludeBinary	"turnzx.ico"
	l_turnzy:	:	IncludeBinary	"turnzy.ico"
	
	l_right:		:	IncludeBinary	"right.ico"
	l_left:		:	IncludeBinary	"left.ico"
	l_up:			:	IncludeBinary	"up.ico"
	l_down:		:	IncludeBinary	"down.ico"
EndDataSection
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AAAAAAAAAw
; EnableXP
; DPIAware
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = C2D_Ball3D_Editor_x86.exe
; CompileSourceDirectory