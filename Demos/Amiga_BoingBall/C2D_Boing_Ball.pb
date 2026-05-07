; C2D::Amiga Boing Ball - Dale Luck and R. J. Mical - 1984
; Purebasic v6.04 (x86-64) / 09.11.2018

; http://amiga.lychesis.net/special/ColorCycling/Boing.html

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	2	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	
	XIncludeFile	"..\..\Include\C2D_Types.pbi"	; include musictype #XMU_[Type]
	
	#IsC2D_Mode			=	0
	#IsC2D_Anim			=	1
	#IsC2D_Bitmap		=	1	; 2 -> BitmapAdd()
	#IsC2D_BitmapColor=	1
	#IsC2D_Bounce		=	1
	#IsC2D_GdiPlus		=	2	; 2 -> API-PNG-Decoder only!
	#IsC2D_Buffer		=	1
	#IsC2D_Clear		=	0
	
	#IsC2D_Help	=	0
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID-Number of CanvasGadget
#C2D_W	=	320	*	#C2D_Z	; CanvasWidth
#C2D_H	=	240	*	#C2D_Z	; CanvasHeight

#BB_W	=	113	*	#C2D_Z	; BoingBall animframe width
#BB_H	=	98		*	#C2D_Z	; BoingBall animframe height

; BoingBall horizontal speed
#X_Speed	=	0.630	*	#C2D_Z

; BoingBall bounce parameter
#Y_Speed	=	60	*	#C2D_Z
#Y_Top	=	21	*	#C2D_Z
#Y_Height=	95	*	#C2D_Z
#Y_Boom	=	#Y_Top	+	#Y_Height

InitSound()

Global	*hDC

Procedure	_LineXY(x0, y0, x1, y1)
	MoveToEx_(*hDC, x0, y0, #Null)
	LineTo_(*hDC, x1, y1)
EndProcedure

Procedure	BB_PlaySFX(x.f)

	; l+r by boingball position
	
	PlaySound(0)
	SoundPan(0, (#C2D_W * 0.5 - (x + #BB_W * 0.55))	/ -#C2D_Z)
	
EndProcedure

Procedure	BB_Init()
	
	Protected	i
	Protected	*hPen	=	CreatePen_(#PS_SOLID, #C2D_Z, $AA00AA)
	
	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Amiga / Boing Ball - 1984"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 10, $AAAAAA)

	; create famous 3d-raster then :) as static background
	*hDC	=	StartDrawing(CanvasOutput(#C2D_G))
	SelectObject_(*hDC, *hPen)
	For	i	=	0	To	15
		_LineXY((38 + i * 16) * #C2D_Z, 12 * #C2D_Z,					(38 + i * 16)		* #C2D_Z,	(13 * 16 - 4)	* #C2D_Z)
		_LineXY((38 + i * 16) * #C2D_Z, (12 + 12 * 16) * #C2D_Z,	(12 + i * 19.75)	* #C2D_Z,	(11 + 12 * 18)	* #C2D_Z)
	Next
	For	i	=	0	To	12
		_LineXY(38 * #C2D_Z, (12 + i * 16) * #C2D_Z, (38 + 15 * 16) * #C2D_Z, (12 + i * 16) * #C2D_Z)
	Next
	_LineXY(36 * #C2D_Z, 206 * #C2D_Z, (41 + 15 * 16) * #C2D_Z, 206 * #C2D_Z)
	_LineXY(32 * #C2D_Z, 209 * #C2D_Z, (45 + 15 * 16) * #C2D_Z, 209 * #C2D_Z)
	_LineXY(28 * #C2D_Z, 213 * #C2D_Z, (50 + 15 * 16) * #C2D_Z, 213 * #C2D_Z)
	_LineXY(21 * #C2D_Z, 219 * #C2D_Z, (58 + 15 * 16) * #C2D_Z, 219 * #C2D_Z)
	_LineXY(12 * #C2D_Z, 227 * #C2D_Z, (68 + 15 * 16) * #C2D_Z, 227 * #C2D_Z)
	C2D::BufferBackGrab()
	StopDrawing()
	
	DeleteObject_(*hPen)
	
	; create the Boing Ball (animation)
	C2D::BitmapInit(0, ?i_ball, ?e_ball)
	C2D::AnimInit(0, C2D::BitmapImage(0), 14, 1)
	C2D::AnimScale(0, #C2D_Z)
	C2D::AnimDelay(0, 22)
	
	; create shadow of Boing Ball's first frame-image
	FirstElement(C2D::RS_Anim())
	C2D::BitmapAdd(0, C2D::RS_Anim()\Frame()\Image)
	C2D::BitmapFill(0, $64000000)
	
	; set bounce-parameter
	C2D::BounceInit(0, #Y_Top, #Y_Height, #Y_Speed)
	
	; krawoom, door shut down ;)
	CatchSound(0, ?m_boing)

EndProcedure
Procedure	BB_Update()
	
	Protected	y

	Static	x.f = (#C2D_W - #BB_W) * 0.5,	x_d.f = #X_Speed
	
	; restore buffered background (fast)
	C2D::BufferBackDraw()
	
	x	+	x_d	; move ball left & right
	
	; swap horizontal movement & sfx-boom?
	If	x	>	#C2D_W * 0.57	Or	x	<	#C2D_H * 0.053
		x_d	*	-1
		C2D::RS_Anim()\Direction	*	-1
		BB_PlaySFX(x)
	EndIf
	
	; get bounce y-pos & boom on floor?
	y	=	C2D::Bounce(0)
	If	y	>=	#Y_Boom
		BB_PlaySFX(x)
	EndIf

	; draw shadow + BoingBall
	C2D::BitmapDraw(0, x + 26 * #C2D_Z, y)
	C2D::AnimDraw(0, x, y, 255)
	
EndProcedure

BB_Init()

Repeat
	Select	WindowEvent()

		Case	#PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)	&	$8000
				Break
			EndIf

		Default
			If	C2D::Start()
				BB_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

FreeSound(0)

C2D::Free()

DataSection
	i_ball:		:	IncludeBinary	"gfx\Ball_14x1.png"	:	e_ball:
	m_boing:		:	IncludeBinary	"mus\Boing.wav"
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = A-
; Executable = C2D_Boing_Ball_x86.exe
; CompileSourceDirectory