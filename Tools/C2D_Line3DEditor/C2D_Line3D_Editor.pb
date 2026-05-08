; C2D::Line3D / Editor (+Tiny Polygon)
; Purebasic v5.72 (x86-64)
; Peace^TST - 18.03.20 12:35
; https://testaware.wordpress.com

; Extra: Create Polygon Objects

EnableExplicit

DeclareModule	IsC2D
	#IsC2D_Bitmap	=	1
	#IsC2D_File		=	2
	#IsC2D_Line3D	=	2	; Use Build & Fade
	#IsC2D_Poly3D	=	1
	#IsC2D_GdiPlus	=	1
	#IsC2D_Stars3D	=	2
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
EndDeclareModule

CompilerIf	IsC2D::#IsC2D_GdiPlus	=	0
	UsePNGImageDecoder()
	UseJPEGImageDecoder()
	UseTGAImageDecoder()
	UseTIFFImageDecoder()
	UseGIFImageDecoder()
CompilerEndIf

XIncludeFile	"..\..\Include\C2D_Module.pbi"

;{ - ENUMERATION / STRUCTURES - }
#WIN_W	=	760
#WIN_H	=	552

#SCR_R	=	12		; Raster-Size
#SCR_W	=	(63	|	1)	*	#SCR_R
#SCR_H	=	(43	|	1)	*	#SCR_R
#SCR_Z	=	0		; Z-Plane

#RGB_RASTER	=	$20FFFFFF
#RGB_P0		=	$FF606000
#RGB_P1		=	$FF006060
#RGB_CENTER	=	$3000FF00
#RGB_DRAW	=	$FFBBBBBB
#RGB_Z0		=	$FF0000FF
#RGB_ZN		=	$FF000060

Enumeration	; Gadgets
	#G_AREA
	#G_C2D		; Canvas2D (Main)
	#G_PURE_ED		:	#G_PURE_COPY	; Purebasic datas
	#G_Z3D_DEPTH	:	#G_Z3D_SCALE	:	#G_Z3D_IsEDGES	:	#G_Z3D_OK
	
	#G_Container0
	#G_VIEW
	#G_SIZE	; Objectsize when view
	#G_IsZ		:	#G_Z			; Z-Zoom
	#G_IsZPos	:	#G_ZPos		; Z-Plane
	#G_LEFT		:	#G_RIGHT		:	#G_UP	:	#G_DOWN	:	#G_ZU	:	#G_ZD
	#G_TURN_X	:	#G_TURN_Y	:	#G_TURN_Z
	#G_PEN
	#G_STAMP
	#G_RUBBER
	#G_UNDO
	#G_MOVE
	#G_C2D_ADD	:	#G_C2D_SUB	:	#G_C2D_SIZE	; Canvas add/sub sizemode

	#G_Container1
	#G_IsFOG	:	#G_FOG	; FogFade
	#G_IsR	; Rotate xyz
	#G_IsRX	:	#G_RX	
	#G_IsRY	:	#G_RY
	#G_IsRZ	:	#G_RZ
	#G_RESET
	
	; Image
	#IMAGE_BACK
	#IMAGE_PAUSE
	
	; Menu
	#M_ABOUT
	#M_CLEAN
	#M_FREE
	#M_RGB_LINE
	#M_RGB_BACK
	#M_RGB_POLY
	#M_IMAGE
	#M_IsIMAGE
	#M_IsRESIZE
	#M_IsDOTS
	#M_OPEN
	#M_PURE
	#M_POLY
	#M_POLYCLEAN
	#M_POLYPURE
	#M_POLYSAVE
	#M_POLYVIEW
	#M_SAVE
	#M_Z3D
	#M_ZFREE_00	:	#M_ZFREE_01
	#M_ZCOPY_00	:	#M_ZCOPY_01
	#M_STARS
	#M_VIEW
	#M_BUILD
	#M_FADE
	#M_BRUSH_OPEN
	#M_BRUSH_COPY
	#M_BRUSH_ID		; <- always at last (add menuitem)
EndEnumeration
Enumeration	; Statusbar
	#T_FILE
	#T_INFO
	#T_ELEMENTS
	#T_POS
EndEnumeration
Enumeration	; Fonts
	#C2DF_ED
	#C2DF_SMALL
EndEnumeration

#STARS_NUMBER	=	128
#STARS_SIZE		=	1
#STARS_SPEED	=	2.0

#Angle	=	199.5	; TurnXYZ

#H	=	24	; SmalImageGadget

CompilerIf	#PB_Compiler_Version	<	560
	#PB_MessageRequester_Error		=	16
	#PB_MessageRequester_Info		=	64
	#PB_MessageRequester_Warning	=	48
CompilerEndIf

Macro	MA_WaitEvent()
	Delay(100)	:	While	WindowEvent()	:	Wend
EndMacro
Macro	MA_Z_RGB(COLOR)
	RGBA(Red(COLOR) * 0.40, Green(COLOR) * 0.40, Blue(COLOR) * 0.40, $FF)
EndMacro

Structure	Union
	StructureUnion
		a.a
		b.b
		w.w
		l.l
		i.i
		q.q
	EndStructureUnion
EndStructure

Structure	RS_SET
	w.i	; C2D width
	h.i	; C2D height
	x.i
	y.i
	z.i			; PlaneZ
	Image.i		; BackImage
	IsImage.i
	IsStars.i	; Stars3D On/Off
	IsBuild.i	; Build On/Off
	IsFade.i		; FadeIN On/Off
	LineColor.l	; $FF000000|#Red
	LineZColor.l
	PolyColor.l
EndStructure	:	Global	RS_SET.RS_SET
Structure	RS_Brush
	List	ID.C2D::RS_Line3D()
EndStructure

Global	NewList	RS_PT.C2D::RS_Line3D()
Global	NewList	RS_STAMP.C2D::RS_Line3D()
Global	NewList	RS_Brush.RS_Brush()
Global	NewList	RS_Undo.Integer()

Global	File$		=	C2D::FileParent(GetCurrentDirectory(), 2)	+	"Data\Object\L3D\"
Global	Image$	=	C2D::FileParent(GetCurrentDirectory(), 2)	+	"Data\Logo\"
Global	Unsaved$	=	GetPathPart(ProgramFilename())	+	"unsaved.l3d"
Global	Poly$		=	C2D::FileParent(GetCurrentDirectory(), 2)	+	"Data\Object\P3D\"

Declare	L3D_Raster(Status=1)
;}

; *** UNDO ***
Procedure	Undo_Count()
	ProcedureReturn	ListSize(RS_Undo())
EndProcedure
Procedure	Undo_Push()
	
	AddElement(RS_Undo())
	RS_Undo()\i	=	ListSize(RS_PT())
	
	DisableGadget(#G_UNDO,	0)
	
EndProcedure
Procedure	Undo_Pop()
	
	If	Undo_Count()	=	0	:	ProcedureReturn	:	EndIf
		
	LastElement(RS_Undo())
	
	While	ListSize(RS_PT())	>	RS_Undo()\i
		LastElement(RS_PT())
		DeleteElement(RS_PT())
	Wend
	
	DeleteElement(RS_Undo())
	
	DisableGadget(#G_UNDO,	Bool(ListSize(RS_Undo())=0))
	
	L3D_Raster()
	
EndProcedure
Procedure	Undo_Free()
	ClearList(RS_Undo())
	DisableGadget(#G_UNDO,	1)
EndProcedure

; *** GUI ***
Procedure	GUI_Text(Field, Text$, Flags=0)
	StatusBarText(0, Field, Text$, Flags)
EndProcedure
Procedure	GUI_Pos(x0, y0, z0, x1, y1, z1)
	
	x0	=	(x0 / #SCR_R - RS_SET\w >> 1 / #SCR_R)
	y0	=	(y0 / #SCR_R - RS_SET\h >> 1 / #SCR_R)
	
	x1	=	(x1 / #SCR_R - RS_SET\w >> 1 / #SCR_R)
	y1	=	(y1 / #SCR_R - RS_SET\h >> 1 / #SCR_R)
	
	GUI_Text(#T_POS,"[" + 
	                Str(x0) + "," + Str(y0) + "," + Str(z0) + 
	                "] : ["	+	
	                Str(x1) + "," + Str(y1) + "," + Str(z1) +
	                "]", #PB_StatusBar_Center)
	
EndProcedure
Procedure	GUI_SmallImageGadget(Gadget, x, y, w, h, ImageID, Flags=0)
	
	y	+	4
	
	ContainerGadget(#PB_Any, x, y, w, h, #PB_Container_Single)
	ButtonImageGadget(Gadget, (w - #H) >> 1 - 1, (h - #H) >> 1 - 1, #H, #H, ImageID) 
	CloseGadgetList()
	
EndProcedure
Procedure	GUI_Init()	; Gadgets & Menu
	
	Protected	x = 4, y = #WIN_H - 27
	
	If	Not	IsFont(#C2DF_SMALL)
		LoadFont(#C2DF_SMALL, "Arial", 7)
		SetGadgetFont(#PB_Default, FontID(#C2DF_SMALL))
	EndIf
	
	; ___________________________________________________
	;{ *** Icons ***
	C2D::BitmapInit(#M_ABOUT,	?i_about,	?e_about)
	C2D::BitmapInit(#M_OPEN,	?i_open, 	?e_open)
	C2D::BitmapInit(#M_SAVE,	?i_save,		?e_save)
	C2D::BitmapInit(#M_FREE,	?i_free,		?e_free)
	C2D::BitmapInit(#M_CLEAN,	?i_clean,	?e_clean)
	C2D::BitmapInit(#M_PURE,	?i_pure,		?e_pure)
	C2D::BitmapInit(#M_Z3D,		?i_z3d,		?e_z3d)
	C2D::BitmapInit(#M_RGB_LINE,?i_color,	?e_color)
	C2D::BitmapInit(#M_IMAGE,	?i_image,	?e_image)
	C2D::BitmapInit(#M_POLY,	?i_poly,		?e_poly)
	
	C2D::BitmapInit(#M_BRUSH_COPY,	?i_copy,	?e_copy)
	
	C2D::BitmapInit(#G_VIEW,	?i_view,		?e_view)
	C2D::BitmapInit(#G_FOG,		?i_fog,		?e_fog)
	C2D::BitmapInit(#G_PEN,		?i_pen,		?e_pen)
	C2D::BitmapInit(#G_UNDO,	?i_undo,		?e_undo)
	C2D::BitmapInit(#G_STAMP,	?i_stamp,	?e_stamp)
	C2D::BitmapInit(#G_RUBBER,	?i_rubber,	?e_rubber)
	C2D::BitmapInit(#G_RIGHT,	?i_right,	?e_right)
	C2D::BitmapInit(#G_LEFT,	?i_left,		?e_left)
	C2D::BitmapInit(#G_UP,		?i_up,		?e_up)
	C2D::BitmapInit(#G_DOWN,	?i_down,		?e_down)
	C2D::BitmapInit(#G_TURN_X,	?i_turnx,	?e_turnx)
	C2D::BitmapInit(#G_TURN_Y,	?i_turny,	?e_turny)
	C2D::BitmapInit(#G_TURN_Z,	?i_turnz,	?e_turnz)
	C2D::BitmapInit(#G_MOVE,	?i_move,		?e_move)
	
	C2D::BitmapInit(#IMAGE_PAUSE,	?i_pause,	?e_pause)
	;}
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	
	OpenWindow(0, 0, 0, #WIN_W, #WIN_H, MA_C2DOS("Line3D / Editor"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CreateStatusBar(0, WindowID(0))	:	SendMessage_(StatusBarID(0), #WM_SETFONT, FontID(#C2DF_SMALL), 0)
	AddStatusBarField(#PB_Ignore)		; #T_FILE
	AddStatusBarField(#PB_Ignore)		; #T_INFO
	AddStatusBarField(#SCR_W * 0.12)	; #T_ELEMENTS
	AddStatusBarField(#SCR_W * 0.20)	; #T_POS
	
	; ___________________________________________________
	;{ *** Menu ***
	CreateImageMenu(0, WindowID(0))
	MenuTitle("?")
	MenuItem(#M_ABOUT,	"About",				C2D::BitmapID(#M_ABOUT))
	
	MenuTitle("Object")
	MenuItem(#M_OPEN,		"Object Open",		C2D::BitmapID(#M_OPEN))
	MenuBar()
	MenuItem(#M_CLEAN,	"Object Clean",	C2D::BitmapID(#M_CLEAN))
	MenuBar()
	MenuItem(#M_PURE,		"Object Pure",		C2D::BitmapID(#M_PURE))
	MenuBar()
	MenuItem(#M_SAVE,		"Object Save",		C2D::BitmapID(#M_SAVE))
	MenuBar()
	OpenSubMenu("Polygon",	C2D::BitmapID(#M_POLY))
	MenuItem(#M_POLYVIEW,	"Poly Preview"	+	#TAB$	+	"F1",	C2D::BitmapID(#G_VIEW))
	MenuBar()
	MenuItem(#M_RGB_POLY,	"Poly Color",	C2D::BitmapID(#M_RGB_LINE))
	MenuBar()
	MenuItem(#M_POLYCLEAN,	"Poly Clean",	C2D::BitmapID(#M_CLEAN))
	MenuItem(#M_POLYPURE,	"Poly Pure",	C2D::BitmapID(#M_PURE))
	MenuItem(#M_POLYSAVE,	"Poly Save",	C2D::BitmapID(#M_SAVE))
	CloseSubMenu()
	MenuBar()
	MenuItem(#M_FREE,		"Object Free",		C2D::BitmapID(#M_FREE))

	MenuTitle("View")
	MenuItem(#M_VIEW,		"Preview"	+	#TAB$	+	"F5",		C2D::BitmapID(#G_VIEW))
	MenuBar()
	OpenSubMenu("Color",	C2D::BitmapID(#M_RGB_LINE))
	MenuItem(#M_RGB_LINE,	"Line",	C2D::BitmapID(#M_RGB_LINE))
	MenuItem(#M_RGB_BACK,	"Back",	C2D::BitmapID(#M_RGB_LINE))
	CloseSubMenu()
	MenuBar()
	MenuItem(#M_STARS,	"Stars On / Off")
	MenuBar()
	MenuItem(#M_FADE,		"Fade On / Off")
	MenuItem(#M_BUILD,	"Build On / Off")
	
	MenuTitle("Plane")
	MenuItem(#M_Z3D,			"Create 3D",	C2D::BitmapID(#M_Z3D))
	MenuBar()
	OpenSubMenu("Plane Copy",	C2D::BitmapID(#M_BRUSH_COPY))
	MenuItem(#M_ZCOPY_00,	"Current",	C2D::BitmapID(#M_BRUSH_COPY))
	MenuItem(#M_ZCOPY_01,	"Z0 - Z1",	C2D::BitmapID(#M_BRUSH_COPY))
	CloseSubMenu()
	OpenSubMenu("Plane Free",	C2D::BitmapID(#M_FREE))
	MenuItem(#M_ZFREE_00,	"Current",	C2D::BitmapID(#M_FREE))
	MenuItem(#M_ZFREE_01,	"Z0 - Z1",	C2D::BitmapID(#M_FREE))
	CloseSubMenu()

	MenuTitle("Edit")
	MenuItem(#M_IMAGE,	"Image Open",		C2D::BitmapID(#M_IMAGE))
	MenuItem(#M_IsRESIZE,"Image Resize")
	MenuItem(#M_IsIMAGE,	"Image On / Off")
	MenuBar()
	MenuItem(#M_IsDOTS,	"Dots On / Off")

	MenuTitle("Brush")
	MenuItem(#M_BRUSH_OPEN,	"Brush Open",		C2D::BitmapID(#G_STAMP))
	MenuItem(#M_BRUSH_COPY,	"Brush Copy",		C2D::BitmapID(#M_BRUSH_COPY))
	;} -> ... after here BRUSH_IDs
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	
	ResizeWindow(0, #PB_Ignore, #PB_Ignore, #PB_Ignore, WindowHeight(0) + MenuHeight() + StatusBarHeight(0))
	
	; *** Gadgets ***
	ScrollAreaGadget(#G_AREA, 0, 0, #WIN_W, #WIN_H - 32, #SCR_W, #SCR_H, #SCR_R, #PB_ScrollArea_Center)
	CanvasGadget(#G_C2D, 0, 0, #SCR_W, #SCR_H)
	CloseGadgetList()
	
	; View / Stop
	ButtonImageGadget(#G_VIEW,	x, y - 3, 28, 28, C2D::BitmapID(#G_VIEW), #PB_Button_Toggle)	:	x	+	GadgetWidth(#G_VIEW)	+	2
	SetGadgetAttribute(#G_VIEW, #PB_Button_PressedImage, C2D::BitmapID(#IMAGE_PAUSE))
	
	; ___________________________________________________
	;{ *** Tools Container
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	ContainerGadget(#G_Container0, x, GadgetY(#G_AREA)	+	GadgetHeight(#G_AREA) + 1, GadgetWidth(#G_AREA) - x - 4, 28)
	
	x	=	8	:	y	=	4

	x	+	GadgetWidth(TextGadget(#PB_Any, x, y + 5, 22, 9, "Size:"))
	SpinGadget(#G_SIZE, x, y, 37, 22, 1, 80,	#PB_Spin_Numeric)				:	x	+	GadgetWidth(#G_SIZE)	+	8

	ButtonGadget(#G_IsZ, x, y, 44, 22, "Z Depth", #PB_Button_Toggle)		:	x	+	GadgetWidth(#G_IsZ)
	SpinGadget(#G_Z, x, y, 46, 22, -100, 100, #PB_Spin_Numeric)				:	x	+	GadgetWidth(#G_Z)		+	8

	ButtonGadget(#G_IsZPos, x, y, 41, 22, "Z Only", #PB_Button_Toggle)	:	x	+	GadgetWidth(#G_IsZPos)
	SpinGadget(#G_ZPos, x, y, 46, 22, -127, 127, #PB_Spin_Numeric)			:	x	+	GadgetWidth(#G_ZPos)	+	8	

	y	-	3
	
	; Move XY
	GUI_SmallImageGadget(#G_LEFT,	x,					#H * 0.25,	#H * 0.5, #H * 0.5, C2D::BitmapID(#G_LEFT))
	GUI_SmallImageGadget(#G_RIGHT,x + #H,			#H * 0.25,	#H * 0.5, #H * 0.5, C2D::BitmapID(#G_RIGHT))
	GUI_SmallImageGadget(#G_UP,	x + #H * 0.50, 0,				#H * 0.5, #H * 0.5, C2D::BitmapID(#G_UP))
	GUI_SmallImageGadget(#G_DOWN,	x + #H * 0.50, #H * 0.5,	#H * 0.5, #H * 0.5, C2D::BitmapID(#G_DOWN))

	x	+	#H	+	6
	
	; Move Z
	GUI_SmallImageGadget(#G_ZU,	x + #H * 0.50, 0,				#H * 0.5, #H * 0.5, C2D::BitmapID(#G_UP))
	GUI_SmallImageGadget(#G_ZD,	x + #H * 0.50, #H * 0.5,	#H * 0.5, #H * 0.5, C2D::BitmapID(#G_DOWN))

	x	+	#H	+	8
	
	; Turn XYZ
	ButtonImageGadget(#G_TURN_X, x, y, 28, 28, C2D::BitmapID(#G_TURN_X))	:	x	+	GadgetWidth(#G_TURN_X)
	ButtonImageGadget(#G_TURN_Y, x, y, 28, 28, C2D::BitmapID(#G_TURN_Y))	:	x	+	GadgetWidth(#G_TURN_Y)
	ButtonImageGadget(#G_TURN_Z, x, y, 28, 28, C2D::BitmapID(#G_TURN_Z))	:	x	+	GadgetWidth(#G_TURN_Z)	+	8
	
	; Move -> Connections
	ButtonImageGadget(#G_MOVE,	x, y, 28, 28, C2D::BitmapID(#G_MOVE),	#PB_Button_Toggle)	:	x	+	GadgetWidth(#G_MOVE)	+	8
	
	; Pen -> fast drawing
	ButtonImageGadget(#G_PEN,	x, y, 28, 28, C2D::BitmapID(#G_PEN),	#PB_Button_Toggle)	:	x	+	GadgetWidth(#G_PEN)
	ButtonImageGadget(#G_STAMP,x, y, 28, 28, C2D::BitmapID(#G_STAMP),	#PB_Button_Toggle)	:	x	+	GadgetWidth(#G_STAMP)
	ButtonImageGadget(#G_RUBBER,x,y,	28, 28, C2D::BitmapID(#G_RUBBER),#PB_Button_Toggle)	:	x	+	GadgetWidth(#G_RUBBER)		+	8

	; Undo
	ButtonImageGadget(#G_UNDO,	x, y, 28, 28, C2D::BitmapID(#G_UNDO))
	DisableGadget(#G_UNDO, 1)
	
	x	=	GadgetWidth(#G_Container0)	-	80	-	#H	-	4
	
	; Width/Height
	GUI_SmallImageGadget(#G_C2D_ADD,	x + #H * 0.50, 0,			#H * 0.5, #H * 0.5, C2D::BitmapID(#G_UP))
	GUI_SmallImageGadget(#G_C2D_SUB,	x + #H * 0.50, #H * 0.5,#H * 0.5, #H * 0.5, C2D::BitmapID(#G_DOWN))
	
	x	+	#H	+	2
	
	ComboBoxGadget(#G_C2D_SIZE, x, y + 3, 80, 21)
	AddGadgetItem(#G_C2D_SIZE, -1, "Width/Height")
	AddGadgetItem(#G_C2D_SIZE, -1, "Width")
	AddGadgetItem(#G_C2D_SIZE, -1, "Height")
	
	CloseGadgetList()
	;}
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	; ___________________________________________________
	;{ *** Preview Container
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	ContainerGadget(#G_Container1, GadgetX(#G_Container0), GadgetY(#G_Container0), GadgetWidth(#G_Container0), GadgetHeight(#G_Container0))
	HideGadget(#G_Container1, #True)
	
	x	=	8	:	y	=	4
	
	; Fade
	ButtonImageGadget(#G_IsFOG, x, y - 3, 28, 28, C2D::BitmapID(#G_FOG), #PB_Button_Toggle)	:	x	+	GadgetWidth(#G_IsFOG)	+	2
	SpinGadget(#G_FOG, x, y, 42, 22, 0, 127, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_FOG)	+	8	
	
	; Rotate XYZ
	ButtonGadget(#G_IsR, x, y, 40, 22, "Rotate", #PB_Button_Toggle):	x	+	GadgetWidth(#G_IsR)	+	2
	ButtonGadget(#G_IsRX, x, y, 18, 22, "X", #PB_Button_Toggle)		:	x	+	GadgetWidth(#G_IsRX)
	SpinGadget(#G_RX, x, y, 46, 22, -100, 100, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_RX)	+	2
	ButtonGadget(#G_IsRY, x, y, 18, 22, "Y", #PB_Button_Toggle)		:	x	+	GadgetWidth(#G_IsRY)
	SpinGadget(#G_RY, x, y, 46, 22, -100, 100, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_RY)	+	2
	ButtonGadget(#G_IsRZ, x, y, 18, 22, "Z", #PB_Button_Toggle)		:	x	+	GadgetWidth(#G_IsRZ)
	SpinGadget(#G_RZ, x, y, 46, 22, -100, 100, #PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_RZ)	+	8

	ButtonGadget(#G_RESET, x, y, 40, 22, "Reset")
	
	CloseGadgetList()
	;}
	; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

EndProcedure

; *** MENU ***
Procedure	L3D_About()
	
	MessageRequester("About", 
	                 MA_C2DOS("Line3D / Editor "	+	ReplaceString(FormatDate("v%yy.%mm%ddß", #PB_Compiler_Date), ".0", "."))	+	#LF$	+	#LF$	+
	                 "Module:"	+	#TAB$	+	"Canvas2D v"+	MA_XC2D()	+	#LF$	+	#LF$	+
	                 "Window:"	+	#TAB$	+	Str(#WIN_W)					+ " × "	+ Str(#WIN_H)		+	#LF$	+
	                 "Canvas:"	+	#TAB$	+	Str(RS_SET\w)				+ " × "	+ Str(RS_SET\h)	+	#LF$	+
	                 "Line3D:"	+	#TAB$	+	Str(RS_SET\w / #SCR_R)	+ " × "	+ Str(RS_SET\h / #SCR_R)	+	#LF$	+	#LF$	+
	                 FormatDate("Compiled: %dd.%mm.%yyyy %hh:%ii:%ss - Purebasic v" + StrF(#PB_Compiler_Version * 0.01, 2)	+	#LF$	+	#LF$	+
	                 "Peace^TST - testaware.wordpress.com", #PB_Compiler_Date),
	                 #PB_MessageRequester_Ok|#PB_MessageRequester_Info)
	
	MA_WaitEvent()
	
EndProcedure

Procedure	L3D_Image_Open()
	
	Static	ID
	
	Protected	t$
	
	t$	=	OpenFileRequester("Open Back Image", Image$, "Image (*.*)|*.gif;*jpeg;*.jpg;*.png;*.bmp;*.ico;*.tif;*.tiff;*.tga|All Files|*.*", ID)
	
	If	t$
		Image$	=	t$
		RS_SET\Image	=	C2D::BitmapInit(#IMAGE_BACK, @Image$, 0, #Black)
	EndIf
	
	If	RS_SET\Image	=	0	Or	IsImage(RS_SET\Image)	=	0
		RS_SET\Image	=	0
	Else
		If	GetMenuItemState(0, #M_IsRESIZE)	; ReSize image to dimensions of canvas?
			C2D::BitmapZoom(#IMAGE_BACK, RS_SET\w, RS_SET\h)
		EndIf
	EndIf
	
	RS_SET\IsImage	=	Bool(RS_SET\Image)
	SetMenuItemState(0, #M_IsIMAGE,	RS_SET\IsImage)
	
	L3D_Raster()
	
	MA_WaitEvent()

EndProcedure
Procedure	L3D_Image_Draw()
	
	If	RS_SET\IsImage	And IsImage(RS_SET\Image)	; Back-Image
		C2D::BitmapDraw(#IMAGE_BACK, 0, 0, 96, C2D::#C2F_Center)
	EndIf
	
EndProcedure

Procedure	L3D_RGB_Line(Status=1)
	
	With	RS_SET
		
		Protected	Color	=	ColorRequester(\LineColor)
		
		If	Color	>=	#Null
			\LineColor	=	$FF000000	|	Color	; Alpha + RGB
			\LineZColor	=	MA_Z_RGB(\LineColor)	; Alpha + RGB (darker)
		EndIf
		
		If	Status
			L3D_Raster()
		Else	; view active!
			C2D::RS_Line3DObject()\Color	=	\LineColor
		EndIf
		
	EndWith
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_RGB_Back(Status=1)
	
	With	RS_SET
		
		Protected	Color	=	ColorRequester(C2D::C2D\Color)
		
		If	Color	>=	#Null
			C2D::C2D\Color	=	$FF000000	|	Color	; Alpha + RGB
		EndIf
		
	EndWith
	
	If	Status	:	L3D_Raster()	:	EndIf
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Raster(Status=1)
	
	Protected	n, x, y, x0, y0, x1, y1
	
	RS_SET\z	=	GetGadgetState(#G_ZPos)

	If	Status	; 1 = Own output!
		GUI_Text(#T_ELEMENTS, "Elements: " + Str(ListSize(RS_PT())))
		StartDrawing(CanvasOutput(#G_C2D))
	EndIf
	
	Box(0, 0, OutputWidth(), OutputHeight(), C2D::C2D\Color)
	
	L3D_Image_Draw()	; BackImage

	DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
	
	; Dots or lines
	If	GetMenuItemState(0, #M_IsDOTS)
		FrontColor($3F000000|#RGB_RASTER)
		While	x	<=	OutputWidth()
			While	y	<=	OutputHeight()
				LineXY(x, y, x, y)	; avoid error out of paint
				y	+	#SCR_R
			Wend
			x	+	#SCR_R
			y	=	#Null
		Wend
	Else
		FrontColor(#RGB_RASTER)
		While	x	<	OutputWidth()
			LineXY(x, 0, x, OutputHeight())
			x	+	#SCR_R
		Wend
		While	y	<	OutputHeight()
			LineXY(0, y, OutputWidth(), y)
			y	+	#SCR_R
		Wend
	EndIf
	
	If	ListSize(RS_PT())
		
		; FIRST inactive Z-Plane(s)
		ResetList(RS_PT())
		While	NextElement(RS_PT())
			If	RS_PT()\z0	<>	RS_SET\z
				x0	=	OutputWidth()	>> 1 + RS_PT()\x0	*	#SCR_R
				y0	=	OutputHeight()	>> 1 + RS_PT()\y0	*	#SCR_R
				x1	=	OutputWidth()	>> 1 + RS_PT()\x1	*	#SCR_R
				y1	=	OutputHeight()	>> 1 + RS_PT()\y1	*	#SCR_R
				LineXY(x0, y0, x1, y1, RS_SET\LineZColor)
			EndIf
		Wend
		
		; Active Z-Plane(s)
		ResetList(RS_PT())
		While	NextElement(RS_PT())
			
			x0	=	OutputWidth()	>> 1 + RS_PT()\x0	*	#SCR_R
			y0	=	OutputHeight()	>> 1 + RS_PT()\y0	*	#SCR_R
			x1	=	OutputWidth()	>> 1 + RS_PT()\x1	*	#SCR_R
			y1	=	OutputHeight()	>> 1 + RS_PT()\y1	*	#SCR_R
			
			If	RS_PT()\z0	=	RS_SET\z
				LineXY(x0, y0, x1, y1, RS_SET\LineColor)
			ElseIf	RS_PT()\z1	=	RS_SET\z
				LineXY(x0, y0, x1, y1, RS_SET\LineZColor)
			EndIf
			
			If	(RS_PT()\z0	=	RS_SET\z	Or	RS_PT()\z1	=	RS_SET\z)
				Circle(x0, y0, 0.2 * #SCR_R, #RGB_P0)
				Circle(x1, y1, 0.2 * #SCR_R, #RGB_P1)
			EndIf
			
		Wend

	EndIf
	
	; CenterXY
	LineXY(0, OutputHeight() >> 1, OutputWidth(), OutputHeight() >> 1,#RGB_CENTER)
	LineXY(OutputWidth() >> 1, 0, OutputWidth() >> 1, OutputHeight(),	#RGB_CENTER)
	Circle(OutputWidth() >> 1, OutputHeight() >> 1, 0.4 * #SCR_R,		#RGB_CENTER)
	
	If	Status	:	StopDrawing()	:	EndIf
	
EndProcedure
Procedure	L3D_Default()	; set GUI states
	
	With	RS_SET
		
		\z	=	#SCR_Z	; Z-Plane -127.. 0.. +127
		
		\w	=	#SCR_W
		\h	=	#SCR_H
		
		\LineColor	=	$FF000000|#Red
		\LineZColor	=	MA_Z_RGB(\LineColor)
		
		C2D::C2D\Color	=	$FF000000|#Black	; Intern Canvas2D
		
		SetGadgetState(#G_SIZE,	#SCR_R)	; Object Size-Factor
		
		SetGadgetState(#G_Z,	10)	; Z-Depth
		DisableGadget(#G_Z,	GetGadgetState(#G_IsZ)!1)
		
		SetGadgetState(#G_IsZPos,	0)			; Actual Z-Only
		SetGadgetState(#G_ZPos,		#SCR_Z)	; Active Z-Plane
		
		SetGadgetState(#G_IsR,	1)	; Rotate xyz On
		SetGadgetState(#G_IsRX,	1)
		SetGadgetState(#G_IsRY,	1)
		SetGadgetState(#G_IsRZ,	1)
		SetGadgetState(#G_RX,	7)
		SetGadgetState(#G_RY,	5)
		SetGadgetState(#G_RZ,  -3)

		SetGadgetState(#G_IsFOG, 0)
		SetGadgetState(#G_FOG,	 #SCR_R)

		SetGadgetState(#G_C2D_SIZE, 0)

		SetGadgetState(#G_STAMP, 0)	:	DisableGadget(#G_STAMP, Bool(ListSize(RS_STAMP())=#Null))

		ResizeGadget(#G_C2D, #PB_Ignore, #PB_Ignore, \w, \h)
		SetGadgetAttribute(#G_C2D, #PB_Canvas_Cursor, #PB_Cursor_Cross)

		SetGadgetAttribute(#G_AREA, #PB_ScrollArea_InnerWidth,	\w)
		SetGadgetAttribute(#G_AREA, #PB_ScrollArea_InnerHeight,	\h)

		L3D_Raster()

	EndWith
	
EndProcedure
Procedure	L3D_C2DSize(Mode)

	With	RS_SET
		
		Select	Mode
			Case	#G_C2D_ADD
				Select	GetGadgetState(#G_C2D_SIZE)
					Case	0
						\w	=	(\w	/	#SCR_R	+	1)	|	1	*	#SCR_R
						\h	=	(\h	/	#SCR_R	+	1)	|	1	*	#SCR_R
					Case	1
						\w	=	(\w	/	#SCR_R	+	1)	|	1	*	#SCR_R
					Case	2
						\h	=	(\h	/	#SCR_R	+	1)	|	1	*	#SCR_R
				EndSelect
			Case	#G_C2D_SUB
				Select	GetGadgetState(#G_C2D_SIZE)
					Case	0
						\w	=	(\w	/	#SCR_R	-	2)	|	1	*	#SCR_R
						\h	=	(\h	/	#SCR_R	-	2)	|	1	*	#SCR_R
					Case	1
						\w	=	(\w	/	#SCR_R	-	2)	|	1	*	#SCR_R
					Case	2
						\h	=	(\h	/	#SCR_R	-	2)	|	1	*	#SCR_R
				EndSelect
		EndSelect
		
		If	\w	<	#SCR_R	*	3		:	\w	=	#SCR_R	*	3		:	EndIf
		If	\w	>	#SCR_R	*	255	:	\w	=	#SCR_R	*	255	:	EndIf
		If	\h	<	#SCR_R	*	3		:	\h	=	#SCR_R	*	3		:	EndIf
		If	\h	>	#SCR_R	*	255	:	\h	=	#SCR_R	*	255	:	EndIf
		
		\z	=	GetGadgetState(#G_ZPos)
		
		If	\w	<>	GadgetWidth(#G_C2D)	Or	\h	<>	GadgetHeight(#G_C2D)
			
			;SendMessage_(GadgetID(#G_C2D),#WM_SETREDRAW,#False,0)
			
			ResizeGadget(#G_C2D, #PB_Ignore, #PB_Ignore, \w, \h)
			
			SetGadgetAttribute(#G_AREA, #PB_ScrollArea_InnerWidth,	\w)
			SetGadgetAttribute(#G_AREA, #PB_ScrollArea_InnerHeight,	\h)
			
			C2D::C2D\w	=	\w	; for draw backimage
			C2D::C2D\h	=	\h
			
			L3D_Raster()
			
			;SendMessage_(GadgetID(#G_C2D),#WM_SETREDRAW,#True,0)
			
		EndIf
		
		GUI_Text(#T_INFO, "Raster-Size: " + Str(\w / #SCR_R) + " × " + Str(\h / #SCR_R))
		
	EndWith
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Free(Merge=0)
	
	If	ListSize(RS_PT())
		If	Merge
			If	MessageRequester("Migrate object", "Do you want migrate object?", #MB_ICONQUESTION|#PB_MessageRequester_YesNo)	=	#PB_MessageRequester_Yes
				Undo_Push()	:	ProcedureReturn
			EndIf
		ElseIf	Undo_Count()
			If	MessageRequester("Clear object", "Really clear object?", #PB_MessageRequester_Warning|#PB_MessageRequester_YesNo)	<>	#PB_MessageRequester_Yes
				ProcedureReturn
			EndIf
		EndIf
	EndIf
	
	Undo_Free()

	ClearList(RS_PT())
	
	RS_SET\z	=	#Null	; Center-Z-Plane[0]
	
	SetGadgetState(#G_IsZPos, #PB_Checkbox_Unchecked)	; All Z-Planes active
	SetGadgetState(#G_ZPos,	RS_SET\z)	; Current active Z-Plane[0]
	
	L3D_Raster()
	
	MA_WaitEvent()

EndProcedure
Procedure	L3D_Clean(Message=1)
	
	; Cleanup not needed elements & positions
	; if message=0 no inforequester (s. L3D_Z3D())
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	x0,y0,z0, x1,y1,z1
	Protected	Length = ListSize(RS_PT()), Count, Time, i, TimeCount
	
	Static	NeverPoly
	
	If	Message	And	NeverPoly	=	0
		NeverPoly	=	#True
		If	MessageRequester("Hint", "Do never clean a C2D::Polygon object!" + #LF$ + #LF$ + "Clean the object?", #MB_ICONQUESTION|#PB_MessageRequester_YesNo)	<>	#PB_MessageRequester_Yes
			MA_WaitEvent()
			ProcedureReturn
		EndIf
	EndIf
	
	Undo_Free()
	
	SetGadgetState(#G_VIEW,	1)	; for abort
	
	TimeCount	=	ElapsedMilliseconds()
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		
		With	RS_PT()
			
			; Byte-Bits only (-127..0..+127
			\x0	&	255
			\y0	&	255
			\z0	&	255
			
			\x1	&	255
			\y1	&	255
			\z1	&	255
			
			If	\x0	>	\x1	; should be for better fade-fx
				Count	+	1
				Swap	\x0, \x1
				Swap	\y0, \y1
				Swap	\z0, \z1
			EndIf
			
			x0	=	\x0
			y0	=	\y0
			z0	=	\z0

			x1	=	\x1
			y1	=	\y1
			z1	=	\z1
			
			PushListPosition(RS_PT())
			While	NextElement(RS_PT())
				
				If	\x0	>	\x1
					Count	+	1
					Swap	\x0, \x1
					Swap	\y0, \y1
					Swap	\z0, \z1
				EndIf
				
				If	(x0 = \x0	And	y0 = \y0)	And	(x1 = \x1	And	y1 = \y1)	And	(z0 = \z0	And	z1 = \z1)
					DeleteElement(RS_PT())
				EndIf
				
			Wend
			PopListPosition(RS_PT())
			
		EndWith
		
		If	C2D::MA_Time()	-	Time	>	100	Or	ListIndex(RS_PT())	=	ListSize(RS_PT())	-	1
			
			If	GetGadgetState(#G_VIEW)
				GUI_Text(#T_INFO, "Clean: " + StrF(100.0 / ListSize(RS_PT())	*	ListIndex(RS_PT()), 2) + "%")
			Else
				Break
			EndIf
			
			While	WindowEvent()	:	Wend
			
			Time	=	C2D::MA_Time()
			
		EndIf
		
	Wend
	
	TimeCount	=	ElapsedMilliseconds()	-	TimeCount
	
	SortStructuredList(RS_PT(), #PB_Sort_Descending, OffsetOf(C2D::RS_Line3D\z0), TypeOf(C2D::RS_Line3D\z0))	; + to -
	
	L3D_Raster()
	
	SetGadgetState(#G_VIEW, 0)
	
	If	Message
		MessageRequester("Clean object", "Elements before:"		+	#TAB$	+	#TAB$	+	Str(Length)					+	#LF$	+
		                                 "Elements after:"			+	#TAB$	+	#TAB$	+	Str(ListSize(RS_PT()))	+	#LF$	+
		                                 "Elements removed:"		+	#TAB$	+	Str(Length - ListSize(RS_PT()))	+	#LF$	+	#LF$	+
		                                 "Position correction:"	+	#TAB$	+	Str(Count)								+	#LF$	+	#LF$	+
		                                 "Elapsed time:"			+	#TAB$	+	#TAB$	+	StrF(TimeCount * 0.001, 3),
		                 #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
	EndIf
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Create()
	
	Protected	NewList	L3D.C2D::RS_Line3D()
	Protected	*Ptr.C2D::RS_Line3D
	
	Static	*Memory
	
	If	*Memory
		FreeMemory(*Memory)
		*Memory	=	#Null
	EndIf
	
	If	GetGadgetState(#G_IsZPos)	; Current Z only?
		
		ResetList(RS_PT())
		While	NextElement(RS_PT())
			With	RS_PT()
				If	\z0 = RS_SET\z	And	\z1 = RS_SET\z
					AddElement(L3D())
					L3D()\x0	=	\x0
					L3D()\y0	=	\y0
					L3D()\z0	=	\z0
					L3D()\x1	=	\x1
					L3D()\y1	=	\y1
					L3D()\z1	=	\z1
				EndIf
			EndWith
		Wend
		
	Else
		
		CopyList(RS_PT(), L3D())
		
	EndIf

	*Memory	=	AllocateMemory(ListSize(L3D()) * SizeOf(C2D::RS_Line3D) + SizeOf(Long) * 2)
	*Ptr		=	*Memory
	
	PokeL(*Ptr, C2D::#ID_L3D0)		:	*Ptr	+	SizeOf(Long)
	PokeL(*Ptr, ListSize(L3D()))	:	*Ptr	+	SizeOf(Long)
	
	ResetList(L3D())
	While	NextElement(L3D())
		
		With	L3D()
			*Ptr\x0	=	\x0
			*Ptr\y0	=	\y0
			*Ptr\z0	=	\z0
			*Ptr\x1	=	\x1
			*Ptr\y1	=	\y1
			*Ptr\z1	=	\z1
		EndWith
		
		*Ptr	+	SizeOf(C2D::RS_Line3D)
		
	Wend
	
	FreeList(L3D())
	
	ProcedureReturn	*Memory
	
EndProcedure
Procedure	L3D_Save(Flags=#False)
	
	Static	ID
	Protected	t$, *Memory

	If	Flags	And	FileSize(Unsaved$)	>	#Null
		DeleteFile(Unsaved$)
	EndIf
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	If	Flags	=	#False
		t$	=	SaveFileRequester("Save L3D-Object", File$, "Line3D (*.l3d)|*.l3d|All Files|*.*", ID)
	Else
		t$	=	Unsaved$
	EndIf
	
	If	t$
		
		If	GetExtensionPart(t$)
			t$	=	Left(t$, Len(t$) - Len(GetExtensionPart(t$)) - 1)
		EndIf
		
		File$	=	t$	+	".l3d"
		
		; not if autosave on exit?
		If	Flags	=	#False
			
			ID		=	SelectedFilePattern()
			
			If	GetGadgetState(#G_IsZPos)
				Select	MessageRequester("Z-Plane Only", "Really save current z-plane only?", #PB_MessageRequester_Warning|#PB_MessageRequester_YesNoCancel)
					Case	#PB_MessageRequester_Cancel
						ProcedureReturn
					Case	#PB_MessageRequester_No
						SetGadgetState(#G_IsZPos, #PB_Checkbox_Unchecked)
				EndSelect
			EndIf
			
			If	FileSize(File$)	>	0
				If	MessageRequester("Save", File$ + #LF$ + #LF$ + "already exist, overwrite?", #MB_ICONQUESTION|#PB_MessageRequester_YesNo)	<>	#PB_MessageRequester_Yes
					ProcedureReturn
				EndIf
			EndIf
			
		EndIf
		
		If	CreateFile(0, File$)
			
			*Memory	=	L3D_Create()
			WriteData(0, *Memory, MemorySize(*Memory))
			CloseFile(0)
			
			GUI_Text(#T_FILE, File$)
			GUI_Text(#T_INFO, "Saved elements: " + Str(ListSize(RS_PT())) + " / Size: " + Str(MemorySize(*Memory)) + " bytes")
			
		EndIf
		
	EndIf
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Pure()
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	t$, w=320, h=280, *Memory, *Ptr
	
	OpenWindow(1, 0, 0, w, h, "L3D - Purebasic", #PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Tool, WindowID(0))
	EditorGadget(#G_PURE_ED, 0, 0, w, h - 32)
	
	ButtonImageGadget(#G_PURE_COPY, w - 30, h - 30, 28, 28, C2D::BitmapID(#M_BRUSH_COPY))
	
	t$	=	"l3d_object:"	+	#LF$	+
	  	 	"Data.l	C2D::#ID_L3D0, " + Str(ListSize(RS_PT()))	+	#LF$	+
	  	 	"Data.b	"
	
	*Memory	=	AllocateMemory((Len(t$) + ListSize(RS_PT()) * 32) * SizeOf(Character))
	*Ptr		=	*Memory
	
	PokeS(*Ptr, t$, Len(t$), #PB_String_NoZero)	:	*Ptr	+	Len(t$)	*	SizeOf(Character)
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		
		t$	=	Str(RS_PT()\x0) + "," + Str(RS_PT()\y0) + "," + Str(RS_PT()\z0)+","	+
		  	 	#TAB$	+
		  	 	Str(RS_PT()\x1) + "," + Str(RS_PT()\y1) + "," + Str(RS_PT()\z1)
		
		If	ListIndex(RS_PT())	<	ListSize(RS_PT())	-	1
			t$	+	","	+	#LF$	+	#TAB$
		EndIf
		
		PokeS(*Ptr, t$, Len(t$), #PB_String_NoZero)	:	*Ptr	+	Len(t$)	*	SizeOf(Character)
		
	Wend
	
	SendMessage_(GadgetID(#G_PURE_ED), #WM_SETTEXT, 0, *Memory)
	
	FreeMemory(*Memory)

	Repeat
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Select	EventGadget()
					Case	#G_PURE_COPY
						SendMessage_(GadgetID(#G_PURE_ED), #EM_SETSEL, 0, -1)
						SendMessage_(GadgetID(#G_PURE_ED), #WM_COPY, 0, 0)
				EndSelect
			Case	#PB_Event_CloseWindow
				Break
		EndSelect
	ForEver
	
	CloseWindow(1)
	
	MA_WaitEvent()

EndProcedure
Procedure	L3D_Open(Flags=#False)
	
	Static	ID
	Protected	t$, i, n
	
	If	Flags	=	#False
		t$	=	OpenFileRequester("Open L3D/P3D-Object", File$, "Object (l3d/p3d)|*.l3d;*.p3d|All Files|*.*", ID)
	Else
		t$	=	Unsaved$
	EndIf
	
	If	t$
		
		If	Flags	=	#False
			File$	=	t$
			ID		=	SelectedFilePattern()
		EndIf
		
		L3D_Free(1)
		
		If	ReadFile(0, t$)
			Select	ReadLong(0)
				Case	C2D::#ID_L3D0	; Line3D Object?
					n	=	ReadLong(0)	; # of pairs (x0,y0,z0,x1,y1,z1)
					For	i	=	1	To	n
						AddElement(RS_PT())
						RS_PT()\x0	=	ReadByte(0)
						RS_PT()\y0	=	ReadByte(0)
						RS_PT()\z0	=	ReadByte(0)
						RS_PT()\x1	=	ReadByte(0)
						RS_PT()\y1	=	ReadByte(0)
						RS_PT()\z1	=	ReadByte(0)
					Next
				Case	C2D::#ID_P3D0	; Poly3D Object? (no z)
					n	=	ReadLong(0)	/	4	; # of vertices (x0,y0,x1,y1)
					For	i	=	1	To	n
						AddElement(RS_PT())
						RS_PT()\x0	=	ReadByte(0)
						RS_PT()\y0	=	ReadByte(0)
						RS_PT()\z0	=	0
						RS_PT()\x1	=	ReadByte(0)
						RS_PT()\y1	=	ReadByte(0)
						RS_PT()\z1	=	0
					Next
			EndSelect
			CloseFile(0)
		EndIf
		
		If	ListSize(RS_PT())
			L3D_Raster()
			GUI_Text(#T_FILE, t$)
		ElseIf	Flags	=	#False
			MessageRequester("Error", File$ + #LF$ + #LF$ + "Can't open Line3D-Object!", #PB_MessageRequester_Error)
		EndIf
		
	EndIf
	
	If	Flags	=	#False
		MA_WaitEvent()
	EndIf
	
EndProcedure

; *** PLANE Z ***
Procedure	L3D_ZFree(Mode)
	
	; Mode = 00 -> clear current Z-plane only / 01 = clear Z0 - Z1
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	Status, Elements
	
	Undo_Free()
	
	ResetList(RS_PT())
	While NextElement(RS_PT())
		With	RS_PT()
			
			Status	=	#False
			
			Select	Mode
					
				Case	#M_ZFREE_00
					
					If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z
						Status	=	#True
					EndIf
					
				Case	#M_ZFREE_01
					
					If	\z0	=	RS_SET\z	Or	\z1	=	RS_SET\z
						Status	=	#True
					EndIf
					
			EndSelect
			
			If	Status
				Elements	+	1	:	DeleteElement(RS_PT())
			EndIf
			
		EndWith
	Wend
	
	L3D_Raster()
	
	GUI_Text(#T_INFO, "Elements removed: " + Str(Elements))
	
	MA_WaitEvent()

EndProcedure
Procedure	L3D_ZCopy(Mode)
	
	; Mode = 00 -> clear current Z-plane only / 01 = clear Z0 - Z1
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	If	ListSize(RS_STAMP())	:	ClearList(RS_STAMP())	:	EndIf
	
	Protected	Status
	
	RS_SET\z	=	GetGadgetState(#G_ZPos)
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		With	RS_PT()

			Select	Mode
					
				Case	#M_ZCOPY_00
					
					If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z
						Status	=	#True
					EndIf
					
				Case	#M_ZCOPY_01
					
					If	\z0	=	RS_SET\z	Or	\z1	=	RS_SET\z
						Status	=	#True
					EndIf
					
			EndSelect
			
			If	Status
				
				AddElement(RS_STAMP())
				
				RS_STAMP()\x0	=	RS_PT()\x0
				RS_STAMP()\y0	=	RS_PT()\y0
				RS_STAMP()\z0	=	RS_PT()\z0	-	RS_SET\z
				RS_STAMP()\x1	=	RS_PT()\x1
				RS_STAMP()\y1	=	RS_PT()\y1
				RS_STAMP()\z1	=	RS_PT()\z1	-	RS_SET\z
				
				Status	=	#False
				
			EndIf
			
		EndWith
	Wend
	
	DisableGadget(#G_STAMP,	Bool(ListSize(RS_STAMP())=0))
	
	GUI_Text(#T_INFO, "Elements copied: " + Str(ListSize(RS_STAMP())) + " of " + Str(ListSize(RS_PT())))
	
	MA_WaitEvent()

EndProcedure
Procedure	L3D_Z3D()
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	NewList L3D.C2D::RS_Line3D()
	Protected	x, y, x0,y0,z0, x1,y1,z1, Factor.f, Time

	Static	Z3D=1, S3D=100, IsEdge=#PB_Checkbox_Checked
	
	RS_SET\z	=	GetGadgetState(#G_ZPos)	; actual plane-z
	
	OpenWindow(1, 0, 0, 278, 60, "Create scaled Z-Plane 3D", #PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Tool, WindowID(0))
	
	x	=	8	:	y	=	7
	
	x	+	GadgetWidth(TextGadget(#PB_Any, x, y + 4, 40, 12, "Z-Depth:"))		:	SpinGadget(#G_Z3D_DEPTH,x, y, 50, 22, -127, 127,#PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_Z3D_DEPTH)	+	8
	x	+	GadgetWidth(TextGadget(#PB_Any, x, y + 4, 50, 12, "Scale in %:"))	:	SpinGadget(#G_Z3D_SCALE,x, y, 50, 22, 1, 2000,	#PB_Spin_Numeric)	:	x	+	GadgetWidth(#G_Z3D_SCALE)	+	8
	
	ButtonGadget(#G_Z3D_OK, WindowWidth(1) - 50 - 8, y, 50, 22, "Ok")
	
	y	+	31	; Edge connections?
	CheckBoxGadget(#G_Z3D_IsEDGES, 8, y, 130, 15, "Create edge-connections")

	SetGadgetState(#G_Z3D_DEPTH,	Z3D)
	SetGadgetState(#G_Z3D_SCALE,	S3D)
	SetGadgetState(#G_Z3D_IsEDGES,IsEdge)
	
	Repeat
		
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Select	EventGadget()
					Case	#G_Z3D_OK
						
						SetGadgetState(#G_VIEW,	1)	; for abort
						
						Z3D	=	GetGadgetState(#G_Z3D_DEPTH)
						S3D	=	GetGadgetState(#G_Z3D_SCALE)
						IsEdge=	GetGadgetState(#G_Z3D_IsEDGES)

						Factor	=	0.01	*	S3D
						
						ForEach	RS_PT()
							With	RS_PT()
								
								If	\z0 = RS_SET\z	And	\z1 = RS_SET\z
									
									AddElement(L3D())	; clone plane z to plane + Z3D and scale
									L3D()\x0	=	\x0	*	Factor
									L3D()\y0	=	\y0	*	Factor
									L3D()\z0	=	(\z0	+	Z3D)	&	255	; byte (0..255 / -127..+127)
									L3D()\x1	=	\x1	*	Factor
									L3D()\y1	=	\y1	*	Factor
									L3D()\z1	=	(\z1	+	Z3D)	&	255
									
									If	IsEdge	=	#PB_Checkbox_Checked
										
										AddElement(L3D())	; add connections between planes P0
										L3D()\x0	=	\x0
										L3D()\y0	=	\y0
										L3D()\z0	=	\z0
										L3D()\x1	=	\x0	*	Factor
										L3D()\y1	=	\y0	*	Factor
										L3D()\z1	=	(\z0	+	Z3D)	&	255
										
										AddElement(L3D())	; add connections between planes P1
										L3D()\x0	=	\x1
										L3D()\y0	=	\y1
										L3D()\z0	=	\z0
										L3D()\x1	=	\x1	*	Factor
										L3D()\y1	=	\y1	*	Factor
										L3D()\z1	=	(\z0	+	Z3D)	&	255
										
									EndIf

								EndIf
								
							EndWith
						Next
						
						Break
						
				EndSelect
				
			Case	#PB_Event_CloseWindow
				Break
				
		EndSelect
	ForEver
	
	CloseWindow(1)
	
	; create Z-Plane 3D?
	If	ListSize(L3D())

		; clean up equal pairs
		ResetList(L3D())
		While	NextElement(L3D())
			With	L3D()
				
				; Byte-Bits only (-127..0..+127
				\x0	&	255
				\y0	&	255
				\z0	&	255
				\x1	&	255
				\y1	&	255
				\z1	&	255
				
				x0	=	\x0
				y0	=	\y0
				z0	=	\z0
				x1	=	\x1
				y1	=	\y1
				z1	=	\z1
				
				PushListPosition(L3D())
				While	NextElement(L3D())
					If	(x0 = \x0	And	y0 = \y0)	And	(x1 = \x1	And	y1 = \y1)	And	(z0 = \z0	And	z1 = \z1)
						DeleteElement(L3D())
					EndIf
				Wend
				PopListPosition(L3D())
				
				If	C2D::MA_Time()	-	Time	>	100
					
					If	GetGadgetState(#G_VIEW)
						GUI_Text(#T_INFO, "3D-Optimize: " + StrF(100.0 / ListSize(L3D())	*	ListIndex(L3D()), 2) + "%")
					Else
						Break
					EndIf
					
					While	WindowEvent()	:	Wend
					
					Time	=	C2D::MA_Time()
					
				EndIf

			EndWith
		Wend
		
		Undo_Push()
		
		ResetList(RS_PT())
		MergeLists(L3D(), RS_PT(), #PB_List_Last)

	EndIf
	
	SetGadgetState(#G_VIEW,	0)
	
	FreeList(L3D())
	L3D_Raster()
	MA_WaitEvent()
	
EndProcedure

; *** BRUSH ***
Procedure	L3D_Brush_Set(Item)
	
	Protected	i
	
	Item	-	#M_BRUSH_ID
	
	If	Item	>=	0	And	Item	<	ListSize(RS_Brush())
		
		For	i	=	#M_BRUSH_ID	To	#M_BRUSH_ID	+	ListSize(RS_Brush())	-	1
			SetMenuItemState(0, i, Bool(Item = i - #M_BRUSH_ID))
		Next
		
		SelectElement(RS_Brush(), Item)
		CopyList(RS_Brush()\ID(),	RS_STAMP())
		
		GUI_Text(#T_INFO, "Active brush: " + GetMenuItemText(0, EventMenu()) + " - Elements: " + Str(ListSize(RS_STAMP())))
		
	EndIf
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Brush_Open()
	
	Static	ID
	Protected	t$, i, n
	
	t$	=	OpenFileRequester("Open L3D-Object as brush", File$, "Line3D (*.l3d)|*.l3d|All Files|*.*", ID)
	
	If	t$
		
		File$	=	t$
		ID		=	SelectedFilePattern()
		
		If	ReadFile(0, File$)
			If	ReadLong(0)	=	C2D::#ID_L3D0
				
				n	=	ReadLong(0)	; # of pairs (x0,y0,z0,x1,y1,z1)
				
				If	ListSize(RS_Brush())	=	0	; add bar if first brush
					MenuBar()
				EndIf
				
				LastElement(RS_Brush())
				AddElement(RS_Brush())
				
				For	i	=	0	To	n	-	1
					AddElement(RS_Brush()\ID())
					RS_Brush()\ID()\x0	=	ReadByte(0)
					RS_Brush()\ID()\y0	=	ReadByte(0)
					RS_Brush()\ID()\z0	=	ReadByte(0)
					RS_Brush()\ID()\x1	=	ReadByte(0)
					RS_Brush()\ID()\y1	=	ReadByte(0)
					RS_Brush()\ID()\z1	=	ReadByte(0)
				Next
				
				MenuItem(#M_BRUSH_ID + ListSize(RS_Brush()) - 1, GetFilePart(File$))
				L3D_Brush_Set(#M_BRUSH_ID + ListSize(RS_Brush()) - 1)

			EndIf
			
			CloseFile(0)
			
		EndIf
		
	EndIf
	
	DisableGadget(#G_STAMP,	Bool(ListSize(RS_Brush())=0 And ListSize(RS_STAMP())=0))
	
	GUI_Text(#T_INFO, "Elements of brush " + GetFilePart(File$) + ": " + Str(ListSize(RS_Brush()\ID())))
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Brush_Copy()
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	If	ListSize(RS_STAMP())	:	ClearList(RS_STAMP())	:	EndIf
		
	CopyList(RS_PT(), RS_STAMP())
	
	DisableGadget(#G_STAMP,	Bool(ListSize(RS_Brush())=0 And ListSize(RS_STAMP())=0))
	
	GUI_Text(#T_INFO, "Elements copied: " + Str(ListSize(RS_STAMP())))
	
	MA_WaitEvent()
	
EndProcedure

; *** DRAW ***
Procedure	L3D_Draw_Brush()
	
	If	ListSize(RS_STAMP())	<=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	x, y, z
	
	Static	xa, ya, za=256	; 256 > Byte[255] for first draw z<>za
	
	If (EventType()	=	#PB_EventType_LeftButtonDown)	Or
	   (EventType()	=	#PB_EventType_MouseMove	And
	    GetGadgetAttribute(#G_C2D, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
		
		x	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX) / #SCR_R - RS_SET\w >> 1 / #SCR_R
		y	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY) / #SCR_R - RS_SET\h >> 1 / #SCR_R
		z	=	RS_SET\z
		
		If	x	<>	xa	Or	y	<>	ya	Or	z	<>	za
			
			Undo_Push()
			
			ResetList(RS_STAMP())
			While	NextElement(RS_STAMP())
				
				AddElement(RS_PT())
				
				RS_PT()\x0	=	(RS_STAMP()\x0	+	x)	&	255
				RS_PT()\y0	=	(RS_STAMP()\y0	+	y)	&	255
				RS_PT()\z0	=	(RS_STAMP()\z0	+	z)	&	255
				RS_PT()\x1	=	(RS_STAMP()\x1	+	x)	&	255
				RS_PT()\y1	=	(RS_STAMP()\y1	+	y)	&	255
				RS_PT()\z1	=	(RS_STAMP()\z1	+	z)	&	255
				
			Wend
			
			xa	=	x
			ya	=	y
			za	=	z
			
			L3D_Raster()
			
		EndIf
		
	EndIf

EndProcedure
Procedure	L3D_Draw_Fast()
	
	; Freehand
	
	Protected	x0, y0, x1, y1
	
	If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(#G_C2D, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
		
		x0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)
		y0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)
		
		Undo_Push()
		
		Repeat
			
			Select	WaitWindowEvent()
				Case	#PB_Event_Gadget
					Select	EventGadget()
						Case	#G_C2D
							Select	EventType()
									
								Case	#PB_EventType_MouseMove, #PB_EventType_MouseEnter, #PB_EventType_LeftButtonDown
									
									x1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)
									y1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)
										
									If	Abs(x0-x1) >= #SCR_R	Or	Abs(y0-y1) >= #SCR_R
										
										StartDrawing(CanvasOutput(#G_C2D))
										LineXY(x0, y0, x1, y1)
										StopDrawing()
										
										AddElement(RS_PT())
										
										RS_PT()\x0	=	(x0 / #SCR_R - RS_SET\w >> 1 / #SCR_R)
										RS_PT()\y0	=	(y0 / #SCR_R - RS_SET\h >> 1 / #SCR_R)
										RS_PT()\z0	=	RS_SET\z
										RS_PT()\x1	=	(x1 / #SCR_R - RS_SET\w >> 1 / #SCR_R)
										RS_PT()\y1	=	(y1 / #SCR_R - RS_SET\h >> 1 / #SCR_R)
										RS_PT()\z1	=	RS_SET\z
										
										x0	=	x1
										y0	=	y1
										
									EndIf
									
								Case	#PB_EventType_LeftButtonUp, #PB_EventType_MouseLeave

									Break
									
							EndSelect
					EndSelect
			EndSelect
			
		ForEver
		
		L3D_Raster()
		
		MA_WaitEvent()
		
	EndIf
	
EndProcedure
Procedure	L3D_Draw_Line()
	
	Protected	x0,y0,z0, x1,y1, xa,ya
	
	If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(#G_C2D, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
		
		x0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)	/	#SCR_R	*	#SCR_R
		y0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)	/	#SCR_R	*	#SCR_R
		z0	=	RS_SET\z
		
		; start-pt
		StartDrawing(CanvasOutput(#G_C2D))
		DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
		Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, 0.2 * #SCR_R, #RGB_DRAW)
		StopDrawing()

		xa	=	x0
		ya	=	y0
		
		GUI_Pos(x0, y0, z0, x0, y0, z0)

		Repeat
			
			Select	WaitWindowEvent()
				Case	#PB_Event_Gadget
					Select	EventGadget()
						Case	#G_C2D
							Select	EventType()
									
								Case	#PB_EventType_MouseMove, #PB_EventType_MouseEnter
									
									x1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)	/	#SCR_R	*	#SCR_R
									y1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)	/	#SCR_R	*	#SCR_R
									
									If	x1	<>	xa	Or	y1	<>	ya
										
										StartDrawing(CanvasOutput(#G_C2D))
										
										L3D_Raster(0)	; 0 -> No start/stop drawing (no flicker)
										
										DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
										
										FrontColor(#RGB_DRAW)

										LineXY(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, x1 + #SCR_R >> 1, y1 + #SCR_R >> 1)
										Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, #SCR_R * 0.2)
										Circle(x1 + #SCR_R >> 1, y1 + #SCR_R >> 1, #SCR_R * 0.2)
										
										StopDrawing()
							
										xa	=	x1
										ya	=	y1
										
										GUI_Pos(x0, y0, z0, x1, y1, RS_SET\z)

									EndIf

								Case	#PB_EventType_MouseLeave

									StartDrawing(CanvasOutput(#G_C2D))
									
									L3D_Raster(0)
									
									DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
									Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, #SCR_R * 0.2, #RGB_DRAW)
									
									StopDrawing()
									
									xa	=	x0	; Reset for enter
									ya	=	y0
									
								Case	#PB_EventType_LeftButtonDown
									
									If	x0	<>	x1	Or	y0	<>	y1	Or	z0	<>	RS_SET\z
										
										x0 / #SCR_R - RS_SET\w >> 1 / #SCR_R
										y0 / #SCR_R - RS_SET\h >> 1 / #SCR_R
										x1 / #SCR_R - RS_SET\w >> 1 / #SCR_R
										y1 / #SCR_R - RS_SET\h >> 1 / #SCR_R
										
										If	GetGadgetState(#G_MOVE)	; move all element-links
											
											With	RS_PT()
												ForEach	RS_PT()
													If			\z0	=	z0	And	\x0	=	x0	And	\y0	=	y0
														\z0	=	RS_SET\z	:	\x0	=	x1	:	\y0	=	y1
													ElseIf	\z1	=	z0	And	\x1	=	x0	And	\y1	=	y0
														\z1	=	RS_SET\z	:	\x1	=	x1	:	\y1	=	y1
													EndIf
												Next
											EndWith
											
										Else	; add new element
											
											Undo_Push()
											
											AddElement(RS_PT())
											
											RS_PT()\x0	=	x0
											RS_PT()\y0	=	y0
											RS_PT()\z0	=	z0
											RS_PT()\x1	=	x1
											RS_PT()\y1	=	y1
											RS_PT()\z1	=	RS_SET\z
											
										EndIf
										
									EndIf
									
									Break
										
								Case	#PB_EventType_RightButtonDown

									Break
									
							EndSelect
							
						Case	#G_ZPos
							
							RS_SET\z	=	GetGadgetState(#G_ZPos)
							
							StartDrawing(CanvasOutput(#G_C2D))
							
							L3D_Raster(0)
							
							DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
							Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, 0.2 * #SCR_R, #RGB_DRAW)
							
							StopDrawing()
							
					EndSelect
					
			EndSelect
			
		ForEver
		
		L3D_Raster()

	EndIf
	
	MA_WaitEvent()
	
EndProcedure
Procedure	L3D_Draw_Erase()
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	x0,y0,z0, x1,y1,z1
	
	If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(#G_C2D, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
		
		x0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)	/	#SCR_R	*	#SCR_R
		y0	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)	/	#SCR_R	*	#SCR_R
		z0	=	RS_SET\z
		
		; start-pt
		StartDrawing(CanvasOutput(#G_C2D))
		DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
		Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, 0.2 * #SCR_R, #RGB_DRAW)
		StopDrawing()
		
		Repeat
			
			Select	WaitWindowEvent()
				Case	#PB_Event_Gadget
					Select	EventGadget()
						Case	#G_C2D
							Select	EventType()
									
								Case	#PB_EventType_MouseMove, #PB_EventType_MouseEnter
									
									x1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseX)	/	#SCR_R	*	#SCR_R
									y1	=	GetGadgetAttribute(#G_C2D, #PB_Canvas_MouseY)	/	#SCR_R	*	#SCR_R
									
									If	x0	<>	x1	Or	y0	<>	y1	Or	z0 <> RS_SET\z
										
										StartDrawing(CanvasOutput(#G_C2D))
										
										L3D_Raster(0)	; 0 -> No start/stop drawing (no flicker)
										
										DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
										
										FrontColor(#RGB_DRAW)
										
										If	z0 <> RS_SET\z	; equalize Xor if plane-z changed
											Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, #SCR_R * 0.2)
										EndIf

										LineXY(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, x1 + #SCR_R >> 1, y1 + #SCR_R >> 1, RS_SET\LineColor)
										
										Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, #SCR_R * 0.2)
										Circle(x1 + #SCR_R >> 1, y1 + #SCR_R >> 1, #SCR_R * 0.2)
										
										StopDrawing()
										
									EndIf

								Case	#PB_EventType_MouseLeave

									StartDrawing(CanvasOutput(#G_C2D))
									
									L3D_Raster(0)
									
									DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
									Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, #SCR_R * 0.2, #RGB_DRAW)
									
									StopDrawing()
									
								Case	#PB_EventType_LeftButtonDown
									
									If	x0	<>	x1	Or	y0	<>	y1	Or	z0	<>	RS_SET\z
										
										x0 / #SCR_R - RS_SET\w >> 1 / #SCR_R
										y0 / #SCR_R - RS_SET\h >> 1 / #SCR_R

										x1 / #SCR_R - RS_SET\w >> 1 / #SCR_R
										y1 / #SCR_R - RS_SET\h >> 1 / #SCR_R
										
										ResetList(RS_PT())
										While	NextElement(RS_PT())
											If	(RS_PT()\z0 = z0	And	RS_PT()\z1 = RS_SET\z)	Or	(RS_PT()\z0 = RS_SET\z	And	RS_PT()\z1 = z0)
												If	(RS_PT()\x0 = x0	And	RS_PT()\x1 = x1)	Or	(RS_PT()\x0 = x1	And	RS_PT()\x1 = x0)
													If	(RS_PT()\y0 = y0	And	RS_PT()\y1 = y1)	Or	(RS_PT()\y0 = y1	And	RS_PT()\y1 = y0)
														DeleteElement(RS_PT())
													EndIf
												EndIf
											EndIf
										Wend
										
										z0	=	RS_SET\z
										
									EndIf
									
									Break
										
								Case	#PB_EventType_RightButtonDown

									Break
									
							EndSelect
							
						Case	#G_ZPos
							
							RS_SET\z	=	GetGadgetState(#G_ZPos)
							
							StartDrawing(CanvasOutput(#G_C2D))
							
							L3D_Raster(0)
							
							DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined|#PB_2DDrawing_XOr)
							Circle(x0 + #SCR_R >> 1, y0 + #SCR_R >> 1, 0.2 * #SCR_R, #RGB_DRAW)
							
							StopDrawing()
							
					EndSelect
					
			EndSelect
			
		ForEver
		
		L3D_Raster()

	EndIf
	
	MA_WaitEvent()
	
EndProcedure

Procedure	L3D_Move(Gadget)
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	IsPlaneZ	=	GetGadgetState(#G_IsZPos)
	Protected	IsMove	=	Bool(IsPlaneZ=0)
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		With	RS_PT()
			
			If	IsPlaneZ	; actual PlaneZ only?
				If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z	; ~ or <-> and... hm
					IsMove	=	#True
				Else
					IsMove	=	#False
				EndIf
			EndIf
			
			If	IsMove	
				Select	Gadget
					Case	#G_UP
						\y0	-	1
						\y1	-	1
					Case	#G_DOWN
						\y0	+	1
						\y1	+	1
					Case	#G_LEFT
						\x0	-	1
						\x1	-	1
					Case	#G_RIGHT
						\x0	+	1
						\x1	+	1
					Case	#G_ZD
						\z0	-	1
						\z1	-	1
					Case	#G_ZU
						\z0	+	1
						\z1	+	1
				EndSelect
			EndIf
			
		EndWith
	Wend
	
	L3D_Raster()
	
EndProcedure
Procedure	L3D_Turn(Gadget)
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf

	Protected	ax.f, ay.f, az.f
	
	SetGadgetState(#G_IsZPos, #PB_Checkbox_Unchecked)	; <- must oer error! (see create)
	
	Select	Gadget
		Case	#G_TURN_X	:	ay	=	#Angle
		Case	#G_TURN_Y	:	ax	=	#Angle
		Case	#G_TURN_Z	:	az	=	#Angle
	EndSelect
	
	C2D::Line3DInit(0, L3D_Create(), #SCR_R)
	C2D::Line3DAngle(0, ax, ay, az)
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		SelectElement(C2D::RS_Line3DObject()\VP(), ListIndex(RS_PT()))
		RS_PT()\x0	=	C2D::RS_Line3DObject()\VP()\px[0] / #SCR_R
		RS_PT()\x1	=	C2D::RS_Line3DObject()\VP()\px[1] / #SCR_R
		RS_PT()\y0	=	C2D::RS_Line3DObject()\VP()\py[0] / #SCR_R
		RS_PT()\y1	=	C2D::RS_Line3DObject()\VP()\py[1] / #SCR_R
		RS_PT()\z0	=	C2D::RS_Line3DObject()\VP()\pz[0] / #SCR_R
		RS_PT()\z1	=	C2D::RS_Line3DObject()\VP()\pz[1] / #SCR_R
	Wend
	
	C2D::Line3DFree(0)
	
	L3D_Raster()
	
	MA_WaitEvent()
	
EndProcedure

Procedure	L3D_View()

	; View Line3D-Object
	; Interna: C2D::C2D\Time always zero on first call, so we use the MA_Time() macro
	
	If	ListSize(RS_PT())	=	#Null	:	SetGadgetState(#G_VIEW, 0)	:	ProcedureReturn	:	EndIf
	
	HideGadget(#G_Container1,	0)
	HideGadget(#G_Container0,	1)	; Hide maintools
	SetGadgetState(#G_VIEW, 	1)	; Must set, if called from menu
	
	DisableGadget(#G_C2D, 1)

	Protected	rx.f	=	0.1	*	GetGadgetState(#G_RX)	*	GetGadgetState(#G_IsRX)
	Protected	ry.f	=	0.1	*	GetGadgetState(#G_RY)	*	GetGadgetState(#G_IsRY)
	Protected	rz.f	=	0.1	*	GetGadgetState(#G_RZ)	*	GetGadgetState(#G_IsRZ)
	
	Protected	IsRotate	=	Bool(rx + ry + rz)	*	GetGadgetState(#G_IsR)
	
	Protected	z.f	=	1.0
	
	C2D::Init(#G_C2D, 5, C2D::C2D\Color)	; MUST - size changed?
	
	If	GetGadgetState(#G_IsZ)	; Z Depth?
		z	=	0.1	*	GetGadgetState(#G_Z)
	EndIf

	C2D::Line3DInit(0, L3D_Create(), GetGadgetState(#G_SIZE), z)
	C2D::Line3DColor(0, RS_SET\LineColor)
	C2D::Line3DFog(0, 0.1 * GetGadgetState(#G_FOG) * Bool(GetGadgetState(#G_IsFOG)))
	
	If	RS_SET\IsFade	:	C2D::Line3DFade(0,	1)		:	EndIf
	If	RS_SET\IsBuild	:	C2D::Line3DBuild(0,	1, 1)	:	EndIf
	
	If	RS_SET\IsStars
		C2D::Stars3DInit(#STARS_NUMBER, #STARS_SIZE, 0, 0, C2D::C2D\w, C2D::C2D\h, #STARS_SPEED)
	EndIf
	
	While	GetGadgetState(#G_VIEW)
		Select	WindowEvent()
				
			Case	#Null
				
				If	C2D::Start()
					
					If	RS_SET\IsImage	; Back-Image
						L3D_Image_Draw()
					EndIf
					
					If	RS_SET\IsStars
						C2D::Stars3DDraw()
					EndIf
					
					If	IsRotate
						C2D::Line3DRotate(0, rx, ry, rz)
					EndIf

					C2D::Line3DDraw(0);, 0, 0, 1, 1)

					C2D::Stop()
					
				EndIf
				
			Case	#PB_Event_Gadget
				Select	EventGadget()
						
					Case	#G_IsR, #G_RX, #G_RY, #G_RZ, #G_IsRX,	#G_IsRY,	#G_IsRZ
						rx	=	0.1	*	GetGadgetState(#G_RX)	*	Bool(GetGadgetState(#G_IsRX))
						ry	=	0.1	*	GetGadgetState(#G_RY)	*	Bool(GetGadgetState(#G_IsRY))
						rz	=	0.1	*	GetGadgetState(#G_RZ)	*	Bool(GetGadgetState(#G_IsRZ))
						
						IsRotate	=	Bool(rx + ry + rz)	*	GetGadgetState(#G_IsR)
						
					Case	#G_IsFOG, #G_FOG
						C2D::Line3DFog(0, 0.1 * GetGadgetState(#G_FOG) * Bool(GetGadgetState(#G_IsFOG)))
						
					Case	#G_RESET
						IsRotate	=	0
						SetGadgetState(#G_IsR, 0)
						C2D::Line3DAngle(0, 0, 0, 0)
						
				EndSelect
				
			Case	#PB_Event_Menu
				Select	EventMenu()
						
					Case	#M_STARS
						RS_SET\IsStars	!	1	:	SetMenuItemState(0, #M_STARS, RS_SET\IsStars)
						If	RS_SET\IsStars	And	ListSize(C2D::StarField3D\Star())	=	#Null
							C2D::Stars3DInit(#STARS_NUMBER, #STARS_SIZE, 0, 0, C2D::C2D\w, C2D::C2D\h, #STARS_SPEED)
						EndIf
						
					Case	#M_RGB_BACK	:	L3D_RGB_Back(0)
					Case	#M_RGB_LINE	:	L3D_RGB_Line(0)
						
					Case	#M_IsIMAGE
						RS_SET\IsImage	!	1	:	SetMenuItemState(0, #M_IsIMAGE, RS_SET\IsImage)
						
					Case	#M_VIEW	:	Break	; Abort
						
				EndSelect
				
			Case	#PB_Event_CloseWindow
				Break

			Case	#WM_KEYDOWN
				Select	EventwParam()
					Case	#VK_X		:	C2D::Line3DRotate(0, GetGadgetState(#G_RX), 0, 0)
					Case	#VK_Y		:	C2D::Line3DRotate(0, 0, GetGadgetState(#G_RY), 0)
					Case	#VK_Z		:	C2D::Line3DRotate(0, 0, 0, GetGadgetState(#G_RZ))
					Case	#VK_ESCAPE	:	Break
				EndSelect
				
		EndSelect
	Wend
	
	C2D::Stars3DFree()
	C2D::Line3DFree(0)
	
	HideGadget(#G_Container0,	0)	; show maintools
	HideGadget(#G_Container1,	1)
	SetGadgetState(#G_VIEW, 	0)
	
	DisableGadget(#G_C2D, 0)
	
	L3D_Raster()
	
	While	WindowEvent()	:	Wend

EndProcedure

; *** POLYGON ***
Procedure	Poly_Clean()
	
	; Cleanup polygon multiple vertices on positions
	; if message=0 no inforequester (s. L3D_Z3D())
	
	If	ListSize(RS_PT())	=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	x0,y0,z0, x1,y1,z1
	Protected	Length, Count, Time, TimeCount

	Undo_Free()
	
	SetGadgetState(#G_VIEW,	1)	; for abort
	
	RS_SET\z	=	GetGadgetState(#G_ZPos)

	TimeCount	=	ElapsedMilliseconds()
	
	; Count number of elements in plane
	ForEach	RS_PT()
		With	RS_PT()
			If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z
				
				; Byte-Bits only (-127..0..+127
				\x0	&	255	:	\y0	&	255	;:	\z0	&	255
				\x1	&	255	:	\y1	&	255	;:	\z1	&	255
				
				Length	+	1	; vertices

			EndIf
		EndWith
	Next
	
	ForEach	RS_PT()
		
		With	RS_PT()
			If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z	; actual plane for polygons (no z)

				x0	=	\x0	:	y0	=	\y0	;:	z0	=	\z0
				x1	=	\x1	:	y1	=	\y1	;:	z1	=	\z1
				
				PushListPosition(RS_PT())
				While	NextElement(RS_PT())
					If	\z0	=	RS_SET\z	And	\z1	=	RS_SET\z
						If	(x0 = \x0	And	y0 = \y0)	And	(x1 = \x1	And	y1 = \y1)	Or
						  	(x0 = \x1	And	y0 = \y1)	And	(x1 = \x0	And	y1 = \y0)
							Count	+	1	:	DeleteElement(RS_PT())
						EndIf
					EndIf
				Wend
				PopListPosition(RS_PT())
				
			EndIf
		EndWith
		
		If	C2D::MA_Time()	>	Time	Or	ListIndex(RS_PT())	=	ListSize(RS_PT())	-	1
			
			If	GetGadgetState(#G_VIEW)
				GUI_Text(#T_INFO, "Cleaned: " + StrF(100.0 / Length * Count, 2) + "% - Vertices: " + Str(Count))
			Else
				Break
			EndIf
			
			While	WindowEvent()	:	Wend
			
			Time	=	C2D::MA_Time()	+	100
			
		EndIf
		
	Next
	
	TimeCount	=	ElapsedMilliseconds()	-	TimeCount
	
	L3D_Raster()
	
	SetGadgetState(#G_VIEW, 0)
	
	MessageRequester("Clean Polygon",
	                 "Vertices before:"		+	#TAB$	+	Str(Length)				+	#LF$	+
	                 "Vertices after:"		+	#TAB$	+	Str(Length - Count)	+	#LF$	+
	                 "Vertices removed:"	+	#TAB$	+	Str(Count)				+	#LF$	+	#LF$	+
	                 "Elapsed time:"			+	#TAB$	+	StrF(TimeCount * 0.001, 3),
	                 #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
	
	MA_WaitEvent()
	
EndProcedure
Procedure	Poly_Color()
	
	With	RS_SET
		
		Protected	Color	=	ColorRequester(\PolyColor)
		
		If	Color	>=	#Null
			\PolyColor	=	$00FFFFFF	&	Color	; No Alpha!
		EndIf
		
	EndWith
	
	MA_WaitEvent()
	
EndProcedure
Procedure	Poly_Create()
	
	Static	*Memory
	Protected	*Ptr.Union, Length
	
	If	*Memory	:	FreeMemory(*Memory)	:	*Memory	=	#Null	:	EndIf
	
	; current z-plane only!
	ForEach	RS_PT()
		With	RS_PT()
			If	\z0 = RS_SET\z	And	\z1 = RS_SET\z
				Length	+	1
			EndIf
		EndWith
	Next
	
	If	Length	<	2	:	ProcedureReturn	#Null	:	EndIf
	
	*Memory	=	AllocateMemory(Length * 4 + SizeOf(Long) * 2)	; x0/y0-x1/y1 -> 4 bytes
	*Ptr		=	*Memory
	
	; header
	*Ptr\l	=	C2D::#ID_P3D0				:	*Ptr	+	SizeOf(Long)
	*Ptr\l	=	Length * SizeOf(Long)	:	*Ptr	+	SizeOf(Long)
	
	; vertices of current z-plane
	ResetList(RS_PT())
	While	NextElement(RS_PT())
		With	RS_PT()
			If	\z0 = RS_SET\z	And	\z1 = RS_SET\z
				*Ptr\b	=	RS_PT()\x0	:	*Ptr	+	SizeOf(Byte)
				*Ptr\b	=	RS_PT()\y0	:	*Ptr	+	SizeOf(Byte)
				*Ptr\b	=	RS_PT()\x1	:	*Ptr	+	SizeOf(Byte)
				*Ptr\b	=	RS_PT()\y1	:	*Ptr	+	SizeOf(Byte)
			EndIf
		EndWith
	Wend
	
	ProcedureReturn	*Memory
	
EndProcedure
Procedure	Poly_View()

	; View Poly3D-Object
	
	Protected	*Memory	=	Poly_Create()
	
	If	*Memory	<=	#Null
		SetGadgetState(#G_VIEW, 0)
		GUI_Text(#T_INFO, "No closed polygon in plane!")
		ProcedureReturn
	EndIf
	
	HideGadget(#G_Container1,	0)
	HideGadget(#G_Container0,	1)	; Hide maintools
	SetGadgetState(#G_VIEW, 	1)	; Must set, if called from menu
	
	DisableGadget(#G_C2D, 1)	:	DisableGadget(#G_IsFOG, 1)	:	DisableGadget(#G_FOG, 1)

	Protected	rx.f	=	0.25	*	GetGadgetState(#G_RX)	*	GetGadgetState(#G_IsRX)
	Protected	ry.f	=	0.25	*	GetGadgetState(#G_RY)	*	GetGadgetState(#G_IsRY)
	Protected	rz.f	=	0.25	*	GetGadgetState(#G_RZ)	*	GetGadgetState(#G_IsRZ)
	
	Protected	IsRotate	=	Bool(rx + ry + rz)	*	GetGadgetState(#G_IsR)
	
	C2D::Init(#G_C2D, 5, C2D::C2D\Color)	; MUST - size changed?
	
	If	RS_SET\PolyColor	=	0	:	RS_SET\PolyColor	=	#White	:	EndIf
	
	C2D::Poly3DInit(0, *Memory, RS_SET\PolyColor)
	C2D::Poly3DScale(0, GetGadgetState(#G_SIZE))
	
	If	RS_SET\IsStars
		C2D::Stars3DInit(#STARS_NUMBER, #STARS_SIZE, 0, 0, C2D::C2D\w, C2D::C2D\h, #STARS_SPEED)
	EndIf
	
	While	GetGadgetState(#G_VIEW)
		Select	WindowEvent()
				
			Case	#Null
				
				If	C2D::Start()
					
					If	RS_SET\IsImage	; Back-Image
						L3D_Image_Draw()
					EndIf
					
					If	RS_SET\IsStars
						C2D::Stars3DDraw()
					EndIf
					
					If	IsRotate
						C2D::Poly3DRotate(0, rx, ry, rz)
					EndIf

					C2D::Poly3DDraw(0, 0, 0)

					C2D::Stop()
					
				EndIf
				
			Case	#PB_Event_Gadget
				Select	EventGadget()
					Case	#G_IsR, #G_RX, #G_RY, #G_RZ, #G_IsRX,	#G_IsRY,	#G_IsRZ
						rx	=	0.25	*	GetGadgetState(#G_RX)	*	Bool(GetGadgetState(#G_IsRX))
						ry	=	0.25	*	GetGadgetState(#G_RY)	*	Bool(GetGadgetState(#G_IsRY))
						rz	=	0.25	*	GetGadgetState(#G_RZ)	*	Bool(GetGadgetState(#G_IsRZ))
						IsRotate	=	Bool(rx + ry + rz)	*	GetGadgetState(#G_IsR)
					Case	#G_RESET
						IsRotate	=	0
						SetGadgetState(#G_IsR, 0)
						C2D::Poly3DAngle(0, 0, 0, 0)
				EndSelect
				
			Case	#PB_Event_Menu
				Select	EventMenu()
						
					Case	#M_STARS
						RS_SET\IsStars	!	1	:	SetMenuItemState(0, #M_STARS, RS_SET\IsStars)
						If	RS_SET\IsStars	And	ListSize(C2D::StarField3D\Star())	=	#Null
							C2D::Stars3DInit(#STARS_NUMBER, #STARS_SIZE, 0, 0, C2D::C2D\w, C2D::C2D\h, #STARS_SPEED)
						EndIf
						
					Case	#M_IsIMAGE
						RS_SET\IsImage	!	1	:	SetMenuItemState(0, #M_IsIMAGE, RS_SET\IsImage)
						
					Case	#M_POLYVIEW	:	Break	; Abort
						
				EndSelect
				
			Case	#PB_Event_CloseWindow
				Break

			Case	#WM_KEYDOWN
				Select	EventwParam()
					Case	#VK_X		:	C2D::Poly3DRotate(0, GetGadgetState(#G_RX), 0, 0)
					Case	#VK_Y		:	C2D::Poly3DRotate(0, 0, GetGadgetState(#G_RY), 0)
					Case	#VK_Z		:	C2D::Poly3DRotate(0, 0, 0, GetGadgetState(#G_RZ))
					Case	#VK_ESCAPE	:	Break
				EndSelect
				
		EndSelect
	Wend
	
	C2D::Stars3DFree()
	C2D::Poly3DFree(0)
	
	HideGadget(#G_Container0,	0)	; show maintools
	HideGadget(#G_Container1,	1)
	SetGadgetState(#G_VIEW, 	0)
	
	DisableGadget(#G_C2D, 0)	:	DisableGadget(#G_IsFOG, 0)	:	DisableGadget(#G_FOG, 0)
	
	L3D_Raster()
	
	While	WindowEvent()	:	Wend

EndProcedure
Procedure	Poly_Pure()
	
	; Create Polygon() as PureBasic Datasection
	
	If	Poly_Create()	<=	#Null	:	ProcedureReturn	:	EndIf
	
	Protected	t$, w=400, h=280, *Memory, *Ptr, i
	
	OpenWindow(1, 0, 0, w, h, "Polygon - Purebasic", #PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Tool, WindowID(0))
	EditorGadget(#G_PURE_ED, 0, 0, w, h - 32)
	
	ButtonImageGadget(#G_PURE_COPY, w - 30, h - 30, 28, 28, C2D::BitmapID(#M_BRUSH_COPY))

	t$	=	#TAB$	+	"l_p:"	+	#TAB$	+	#TAB$	+	"; Plygon-Vertices: "	+	Str(ListSize(RS_PT()))	+
	  	 	#LF$	+	#TAB$	+
	  	 	"Data.l	C2D::#ID_P3D0, "	+	Str(ListSize(RS_PT())	*	4)	+
	  	 	#LF$	+	#TAB$	+
	  	 	"Data.b	"
	
	*Memory	=	AllocateMemory((Len(t$) + ListSize(RS_PT()) * 32) * SizeOf(Character))
	*Ptr		=	*Memory
	
	PokeS(*Ptr, t$, Len(t$), #PB_String_NoZero)	:	*Ptr	+	Len(t$)	*	SizeOf(Character)
	
	ResetList(RS_PT())
	While	NextElement(RS_PT())

		t$	=	Str(RS_PT()\x0) + "," + Str(RS_PT()\y0) + "," +
		  	 	Str(RS_PT()\x1) + "," + Str(RS_PT()\y1) + ","
		
		If	i	=	3	And ListIndex(RS_PT())	<	ListSize(RS_PT())	-	1
			t$	+	#LF$	+	#TAB$	+	#TAB$	+	#TAB$	+	#TAB$
		EndIf
		
		If	ListIndex(RS_PT())	>=	ListSize(RS_PT())	-	1
			t$	=	Trim(t$, ",")
		EndIf

		PokeS(*Ptr, t$, Len(t$), #PB_String_NoZero)	:	*Ptr	+	Len(t$)	*	SizeOf(Character)
		
		i	+	1	:	If	i	>	3	:	i	=	#Null	:	EndIf
		
	Wend

	i	=	12
	SendMessage_(GadgetID(#G_PURE_ED), #EM_SETTABSTOPS, 1, @i)
	SendMessage_(GadgetID(#G_PURE_ED), #WM_SETTEXT, 0, *Memory)
	
	FreeMemory(*Memory)

	Repeat
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Select	EventGadget()
					Case	#G_PURE_COPY
						SendMessage_(GadgetID(#G_PURE_ED), #EM_SETSEL, 0, -1)
						SendMessage_(GadgetID(#G_PURE_ED), #WM_COPY, 0, 0)
				EndSelect
			Case	#PB_Event_CloseWindow
				Break
		EndSelect
	ForEver
	
	CloseWindow(1)
	
	MA_WaitEvent()

EndProcedure
Procedure	Poly_Save()
	
	Static	ID
	Protected	*Memory	=	Poly_Create()
	Protected	t$, Vertices
	
	If	*Memory	<=	#Null	:	ProcedureReturn	:	EndIf
	
	t$	=	SaveFileRequester("Save P3D-Polygon Object", Poly$, "Polygon (*.p3d)|*.p3d|All Files|*.*", ID)
	
	If	t$
		
		If	GetExtensionPart(t$)
			t$	=	Left(t$, Len(t$) - Len(GetExtensionPart(t$)) - 1)
		EndIf
		
		Poly$	=	t$	+	".p3d"
			
		ID		=	SelectedFilePattern()
		
		If	FileSize(Poly$)	>	0
			If	MessageRequester("Save Polygon", Poly$ + #LF$ + #LF$ + "already exist, overwrite?", #MB_ICONQUESTION|#PB_MessageRequester_YesNo)	<>	#PB_MessageRequester_Yes
				ProcedureReturn
			EndIf
		EndIf
		
		If	CreateFile(0, Poly$)
			WriteData(0, *Memory, MemorySize(*Memory))
			CloseFile(0)
			
			Vertices	=	(MemorySize(*Memory)	-	SizeOf(Long)	*	2)	/	4
			
			GUI_Text(#T_FILE, Poly$)
			GUI_Text(#T_INFO, "Saved polygon-vertices: " + Str(Vertices) + " / Size: " + Str(Vertices * 4 + 8) + " bytes")
			
		EndIf
		
	EndIf
	
	MA_WaitEvent()
	
EndProcedure

GUI_Init()

C2D::Init(#G_C2D)

L3D_Default()
L3D_Open(#True)

Repeat

	Select	WaitWindowEvent()
			
		Case	#PB_Event_Gadget

			Select	EventGadget()
				Case	#G_C2D
					If	GetGadgetState(#G_RUBBER)
						L3D_Draw_Erase()	; Erase line
					ElseIf	GetGadgetState(#G_PEN)
						L3D_Draw_Fast()	; Freehand
					ElseIf	GetGadgetState(#G_STAMP)
						L3D_Draw_Brush()	; Brush
					Else
						L3D_Draw_Line()	; Line XY (Move links)
					EndIf
					
				Case	#G_IsZ	:	DisableGadget(#G_Z, GetGadgetState(#G_IsZ)!1)
				Case	#G_ZPos	:	L3D_Raster()	; Actual Z-Plane
				Case	#G_VIEW	:	L3D_View()
				Case	#G_UNDO	:	Undo_Pop()
					
				Case	#G_LEFT, #G_RIGHT, #G_UP, #G_DOWN, #G_ZD, #G_ZU
					L3D_Move(EventGadget())
				Case	#G_TURN_X, #G_TURN_Y, #G_TURN_Z
					L3D_Turn(EventGadget())
				Case	#G_C2D_SUB, #G_C2D_ADD
					L3D_C2DSize(EventGadget())

				Case	#G_MOVE
					If	GetGadgetState(#G_MOVE)
						GUI_Text(#T_INFO, "Move links on")
					Else
						GUI_Text(#T_INFO, "Move links off")
					EndIf
					SetGadgetState(#G_PEN,		0)	:	DisableGadget(#G_PEN,	Bool(GetGadgetState(#G_MOVE)))
					SetGadgetState(#G_RUBBER,	0)	:	DisableGadget(#G_RUBBER,Bool(GetGadgetState(#G_MOVE)))
					SetGadgetState(#G_STAMP,	0)	:	DisableGadget(#G_STAMP,	Bool(GetGadgetState(#G_MOVE)	Or	ListSize(RS_Brush())+ListSize(RS_STAMP())=0))
					
				Case	#G_PEN
					If	GetGadgetState(#G_PEN)
						GUI_Text(#T_INFO, "Freehand on (call '" + GetMenuItemText(0, #M_CLEAN) + "' before save)")
					Else
						GUI_Text(#T_INFO, "Freehand off")
					EndIf
					SetGadgetState(#G_RUBBER,	0)	:	DisableGadget(#G_RUBBER,Bool(GetGadgetState(#G_PEN)))
					SetGadgetState(#G_STAMP,	0)	:	DisableGadget(#G_STAMP,	Bool(GetGadgetState(#G_PEN)	Or	ListSize(RS_Brush())+ListSize(RS_STAMP())=0))
					
				Case	#G_RUBBER
					If	GetGadgetState(#G_RUBBER)
						GUI_Text(#T_INFO, "Erase line on (select start- / enpoint)")
					Else
						GUI_Text(#T_INFO, "Erase line off")
					EndIf
					SetGadgetState(#G_PEN,	0)	:	DisableGadget(#G_PEN,	Bool(GetGadgetState(#G_RUBBER)))
					SetGadgetState(#G_STAMP,0)	:	DisableGadget(#G_STAMP,	Bool(GetGadgetState(#G_RUBBER)	Or	ListSize(RS_Brush())+ListSize(RS_STAMP())=0))
					
				Case	#G_STAMP
					If	GetGadgetState(#G_STAMP)
						GUI_Text(#T_INFO, "Brush on (call '" + GetMenuItemText(0, #M_CLEAN) + "' before save)")
					Else
						GUI_Text(#T_INFO, "Brush off")
					EndIf
					SetGadgetState(#G_PEN,		0)	:	DisableGadget(#G_PEN,		Bool(GetGadgetState(#G_STAMP)))
					SetGadgetState(#G_RUBBER,	0)	:	DisableGadget(#G_RUBBER,	Bool(GetGadgetState(#G_STAMP)))
			EndSelect
			
		Case	#PB_Event_Menu
			Select	EventMenu()
				Case	#M_ABOUT	:	L3D_About()
				Case	#M_OPEN	:	L3D_Open()
				Case	#M_SAVE	:	L3D_Save()
				Case	#M_PURE	:	L3D_Pure()
				Case	#M_CLEAN	:	L3D_Clean()
				Case	#M_FREE	:	L3D_Free()
					
				Case	#M_POLYCLEAN:	Poly_Clean()
				Case	#M_POLYPURE	:	Poly_Pure()
				Case	#M_POLYSAVE	:	Poly_Save()
				Case	#M_POLYVIEW	:	Poly_View()
				Case	#M_RGB_POLY	:	Poly_Color()
					
				Case	#M_Z3D	:	L3D_Z3D()	; Create Z-3D
				Case	#M_ZCOPY_00, #M_ZCOPY_01	:	L3D_ZCopy(EventMenu())
				Case	#M_ZFREE_00, #M_ZFREE_01	:	L3D_ZFree(EventMenu())

				Case	#M_VIEW		:	L3D_View()
				Case	#M_RGB_LINE	:	L3D_RGB_Line()
				Case	#M_RGB_BACK	:	L3D_RGB_Back()
				Case	#M_IMAGE		:	L3D_Image_Open()	; Open BackImage
				Case	#M_IsRESIZE								; BackImage ReSize
					SetMenuItemState(0, #M_IsRESIZE, GetMenuItemState(0, #M_IsRESIZE)!1)
				Case	#M_IsIMAGE	; BackImage On/Off
					RS_SET\IsImage	!	1	:	SetMenuItemState(0, #M_IsIMAGE, RS_SET\IsImage)
					L3D_Raster()
				Case	#M_IsDOTS
					SetMenuItemState(0, #M_IsDOTS, GetMenuItemState(0, #M_IsDOTS)!1)
					L3D_Raster()
					
				Case	#M_STARS	:	RS_SET\IsStars	!	1	:	SetMenuItemState(0, #M_STARS, RS_SET\IsStars)
				Case	#M_FADE	:	RS_SET\IsFade	!	1	:	SetMenuItemState(0, #M_FADE,	RS_SET\IsFade)
				Case	#M_BUILD	:	RS_SET\IsBuild	!	1	:	SetMenuItemState(0, #M_BUILD, RS_SET\IsBuild)
					
				Case	#M_BRUSH_COPY	:	L3D_Brush_Copy()
				Case	#M_BRUSH_OPEN	:	L3D_Brush_Open()
				Default
					L3D_Brush_Set(EventMenu())
			EndSelect
			
		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_F1	:	Poly_View()
				Case	#VK_F5	:	L3D_View()
			EndSelect

	EndSelect

ForEver

L3D_Save(#True)
C2D::Free()

DataSection
	IncludePath	"..\..\Data\Icon\PNG\"
	i_about:		:	IncludeBinary	"about.png"			:	e_about:
	i_clean:		:	IncludeBinary	"brush.png"			:	e_clean:
	i_free:		:	IncludeBinary	"clear.png"			:	e_free:
	i_color:		:	IncludeBinary	"color.png"			:	e_color:
	i_copy:		:	IncludeBinary	"copy.png"			:	e_copy:
	i_down:		:	IncludeBinary	"down.png"			:	e_down:
	i_fog:		:	IncludeBinary	"fog.png"			:	e_fog:
	i_image:		:	IncludeBinary	"shot.png"			:	e_image:
	i_left:		:	IncludeBinary	"left.png"			:	e_left:
	i_undo:		:	IncludeBinary	"undo.png"			:	e_undo:
	i_open:		:	IncludeBinary	"open.png"			:	e_open:
	i_pause:		:	IncludeBinary	"pause.png"			:	e_pause:
	i_pure:		:	IncludeBinary	"pure.png"			:	e_pure:
	i_right:		:	IncludeBinary	"right.png"			:	e_right:
	i_pen:		:	IncludeBinary	"pencil.png"		:	e_pen:
	i_poly:		:	IncludeBinary	"star.png"			:	e_poly:
	i_save:		:	IncludeBinary	"save.png"			:	e_save:
	i_stamp:		:	IncludeBinary	"stamp.png"			:	e_stamp:
	i_turnx:		:	IncludeBinary	"turn_x.png"		:	e_turnx:
	i_turny:		:	IncludeBinary	"turn_y.png"		:	e_turny:
	i_turnz:		:	IncludeBinary	"turn_z.png"		:	e_turnz:
	i_up:			:	IncludeBinary	"up.png"				:	e_up:
	i_view:		:	IncludeBinary	"view.png"			:	e_view:
	i_z3d:		:	IncludeBinary	"layer.png"			:	e_z3d:
	i_rubber:	:	IncludeBinary	"status.png"		:	e_rubber:
	i_move:		:	IncludeBinary	"move.png"			:	e_move:
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = AAAAAAAAA5
; EnableXP
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = C2D_Line3D_Editor_x86.exe
; DisableDebugger
; CompileSourceDirectory