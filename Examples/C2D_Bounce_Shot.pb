; C2D::Bouncebomber / Anim / Splatter - Purebasic v5.72

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	1
CompilerEndIf

DeclareModule	IsC2D
	XIncludeFile	"..\Include\C2D_Types.pbi"
	#IsC2D_Bitmap		=	1
	#IsC2D_Anim			=	1
	#IsC2D_Bounce		=	1
	#IsC2D_File			=	1
	#IsC2D_GdiPlus		=	2
	#IsC2D_Clear		=	0
	#IsC2D_GUI			=	0
	#IsC2D_Buffer		=	1
	#IsC2D_Font			=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Text			=	1
	#IsC2D_Splatter	=	1
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#Y0	=	32	*	#C2D_Z
#Y1	=	#C2D_H	-	#Y0

Structure	Ball
	ID.i
	IsEnemy.i
	IsActive.i
	x.f
	y.f
	s.i
	xd.f
	aw.i
EndStructure
Structure	Hero
	m_x.i
	m_y.i
	t_y.i
	t_x.i
	Count_Enemy.i
	Count_Missed.i
	t_missed$
	t_enemy$
	IsFlash.i
	IsExplosion.i
	IsSplatter.i
	IsGameOver.i
	Color.l
EndStructure

Global	Hero.Hero
Global	NewList	Ball.Ball(), *Memory_Explosion, *Memory_Shot

Procedure	C2D_Reset()
	
	Hero\IsGameOver	=	0
	Hero\Count_Enemy	=	0
	Hero\Count_Missed	=	0

	ForEach	Ball()
		Ball()\IsActive	=	#True
		If	Ball()\IsEnemy
			Hero\Count_Enemy	+	1
		EndIf
	Next

	Hero\t_missed$	=	"0"
	Hero\t_enemy$	=	Str(Hero\Count_Enemy)

	Hero\t_x	=	#C2D_W - 2 - Len(Hero\t_missed$) * C2D::FontW(0)

EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("Bounce / Anim / Splatter / Shot the Silverballs"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	;SetClassLongPtr_(WindowID(0), #GCL_HCURSOR, LoadCursor_(GetModuleHandle_(#Null), 8001))
	;SetClassLongPtr_(WindowID(0), #GCL_HCURSOR, LoadImage_(0, "..\Data\Misc\Hunt20.cur", #IMAGE_CURSOR, 32, 32, #LR_LOADFROMFILE))
	SetClassLongPtr_(WindowID(0), #GCL_HCURSOR, LoadCursorFromFile_("..\Data\Misc\Hunt20.cur"))

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 8)
	;C2D::Quality(#PB_Image_Smooth)

	; soundfx
	*Memory_Shot		=	C2D::FileLoad("..\Data\Sound\Phaser2.wav", 1)
	*Memory_Explosion	=	C2D::FileLoad("..\Data\Sound\medium_explosion.wav", 1)

	; ball-animation
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_Paradoxion25_4x4.png")	; silver
	C2D::BitmapInit(1, @"..\Data\Anim\Anim_Paradoxion27_4x4.png")	; gold

	While	ListSize(Ball())	<	20

		AddElement(Ball())

		With	Ball()

			\ID	=	ListIndex(Ball())

			\IsActive	=	#True
			\IsEnemy		=	Bool(\ID % 2 = 0)	; silver

			C2D::AnimInit(\ID,	C2D::BitmapImage(\ID % 2), 4, 4)	; 2 = # of images (0..1)
			C2D::AnimScale(\ID,	#C2D_Z * (1.0 + Random(16) * 0.06))
			C2D::AnimDelay(\ID,	8 + Random(20))

			\aw	=	#C2D_W	-	C2D::AnimW(\ID)

			\x		=	Random(\aw)
			\y		=	#Y0
			\s		=	C2D::AnimW(\ID)

			\xd	=	(1.1 + Random(80) * 0.01)	*	C2D::MA_RMP(1)	*	#C2D_Z

			C2D::BounceInit(\ID, #Y0, #C2D_H - #Y0 * 2 - C2D::AnimH(\ID), (60 + Random(777) * 0.1) * #C2D_Z)

		EndWith

	Wend

	C2D_Reset()

	; explosion-animation
	C2D::BitmapInit(0, @"..\Data\Anim\Anim_Explosion_5x4.png")
	C2D::AnimInit(100, C2D::BitmapImage(0), 5, 4)
	C2D::AnimScale(100, 0.70 * #C2D_Z)
	C2D::AnimDelay(100, 28)

	; font + scroller
	C2D::BitmapInit(0, @"..\Data\Font\PNG\Xenon_16x22.png")
	C2D::FontInit(0, C2D::BitmapImage(0))
	C2D::FontScale(0, #C2D_Z)
	C2D::ScrollTextInit(0, ?t_scroller)
	C2D::ScrollTextSpeed(0, #C2D_Z)

	; fast background
	Hero\t_y	=	(#Y0 - C2D::FontH(0)) / 2
	StartDrawing(CanvasOutput(#C2D_G))
	Box(0, #Y0, #C2D_W, #C2D_H - #Y0 * 2, $FF500000)
	LineXY(0, #Y0, #C2D_W, #Y0, $FF00FFFF)
	LineXY(0, #Y1, #C2D_W, #Y1, $FF00FFFF)
	C2D::TextStringDraw((#C2D_W - 12 * C2D::FontW(0)) / 2, Hero\t_y, "BOUNCEBOMBER")
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()

	; Metall-Splatter
	C2D::SplatterInit(0, 6 * #C2D_Z, 200, $078DAD)
	C2D::SplatterSpread(0, 80 * #C2D_Z, 40 * #C2D_Z)
	C2D::SplatterGravity(0, 80 * #C2D_Z)
	C2D::SplatterEnergy(0, 1024 * #C2D_Z)
	C2D::SplatterAcceleration(0, 200 * #C2D_Z, 300 * #C2D_Z)

	C2D::BitmapFree(-1)

EndProcedure
Procedure	C2D_Update()

	Static	xe, ye, we, he

	C2D::BufferBackDraw()

	ClipOutput(0, #Y0 + 1, #C2D_W, #Y1-#Y0-1)

	; when shot, draw red circle on position
	If	Hero\m_x	Or	Hero\m_y
		Circle(Hero\m_x, Hero\m_y, Random(6, 1), Random(255,32)<<24|#Red)
		C2D::BufferBackGrab()
	EndIf

	; draw all animated balls
	ForEach	Ball()
		With	Ball()

			If	\IsActive

				\x	+	\xd

				If	\x	<	0	Or	\x	>	\aw
					\xd	*	-1
					C2D::AnimDirection(\ID, Bool(\xd > 0) * 2 - 1)
				EndIf

				\y	=	C2D::Bounce(\ID)

				C2D::AnimDraw(\ID, \x, \y)	; Bounce = y-pos

			EndIf

		EndWith
	Next

	; when shot, check if a silver-ball was hit
	If	Hero\m_x	Or	Hero\m_y

		ForEach	Ball()
			With	Ball()
				If	\IsActive
					If	Hero\m_x	>=	\x	And	Hero\m_x	<=	\x	+	\s	And	Hero\m_y	>=	\y	And	Hero\m_y	<=	\y	+	\s
						If	\IsEnemy

							Hero\Color	=	Point(Hero\m_x, Hero\m_y)

							If	(Hero\Color	>>	16	&	$FF)	=	(Hero\Color	>>	8	&	$FF)

								we	=	C2D::AnimW(\ID)	*	2
								he	=	C2D::AnimH(\ID)	*	2

								xe	=	Hero\m_x - we * 0.5
								ye	=	Hero\m_y - he * 0.5

								\IsActive	=	#False

								If	Hero\IsGameOver	=	0	:	Hero\Count_Enemy	-	1	:	EndIf
								Hero\t_enemy$		=	Str(Hero\Count_Enemy)

								Hero\IsExplosion	=	C2D::AnimPlayStart(100, 1)

								PlaySound_(*Memory_Explosion, #Null, #SND_MEMORY|#SND_ASYNC|#SND_NODEFAULT)
								
								If	Hero\Count_Enemy	<=	0
									Hero\IsGameOver	=	#True
								EndIf

							Else

								Hero\IsFlash	=	$FF

							EndIf

						Else

							Hero\IsFlash	=	$FF

						EndIf

						If	Hero\IsFlash	=	$FF	And	Hero\IsSplatter	=	#False
							Hero\IsSplatter	=	C2D::SplatterStart(0, Hero\m_x, Hero\m_y)
						EndIf

						Break

					EndIf
				EndIf
			EndWith
		Next

		; not hit
		If	Hero\IsExplosion	=	#False
			
			If	Hero\IsGameOver	=	0	:	Hero\Count_Missed	+	1	:	EndIf
			
			Hero\t_missed$	=	Str(Hero\Count_Missed)
			Hero\t_x			=	#C2D_W - 2 - Len(Hero\t_missed$) * C2D::FontW(0)
			
			PlaySound_(*Memory_Shot, #Null, #SND_MEMORY|#SND_ASYNC|#SND_NODEFAULT)
			
			If	Hero\Count_Missed	>=	10
				Hero\IsGameOver	=	#True
			EndIf
			
		EndIf

		Hero\m_x	=	0
		Hero\m_y	=	0

	EndIf

	; explosion when silver-ball was hit
	If	Hero\IsExplosion
		Hero\IsExplosion	=	C2D::AnimPlayDraw(100, xe, ye, we, he)
	EndIf

	; splatter when golden-ball was hit
	If	Hero\IsSplatter
		Hero\IsSplatter	=	C2D::SplatterDraw(0, #Y1 - 6 * #C2D_Z)
	EndIf

	UnclipOutput()

	; flash screen when a wrong golden-ball was hit
	If	Hero\IsFlash	>	0
		Box(0, #Y0, #C2D_W, #C2D_H - 2 * #Y0, Hero\IsFlash<<24|#White)
		Hero\IsFlash	-	2
	EndIf

	; update text
	C2D::TextStringDraw(4, Hero\t_y, Hero\t_enemy$)
	C2D::TextStringDraw(Hero\t_x, Hero\t_y, Hero\t_missed$)
	
	If	Hero\IsGameOver
		C2D::TextStringDraw(#C2D_W * 0.36, #C2D_H * 0.40, "GAME OVER")
		If	Hero\Count_Enemy	<=	0
			C2D::TextStringDraw(#C2D_W * 0.38, #C2D_H * 0.40 + C2D::FontH(0) + 5 * #C2D_Z, "YOU WON!")
		Else
			C2D::TextStringDraw(#C2D_W * 0.36, #C2D_H * 0.40 + C2D::FontH(0) + 5 * #C2D_Z, "YOU LOST!")
		EndIf
	EndIf

	C2D::ScrollTextDraw(0, #Y1 + 6 * #C2D_Z)

	; some focus-lines like space-wars
; 	FrontColor($6000FF0F)
; 	LineXY(0, #y0, WindowMouseX(0), WindowMouseY(0))
; 	LineXY(#c2d_w, #y0, WindowMouseX(0), WindowMouseY(0))
; 	LineXY(0, #y1, WindowMouseX(0), WindowMouseY(0))
; 	LineXY(#c2d_w, #y1, WindowMouseX(0), WindowMouseY(0))

EndProcedure

C2D_Init()
C2D_Reset()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf

		Case	#WM_LBUTTONDOWN	; fire with left mb

			With	Hero

				\m_x	=	WindowMouseX(0)
				\m_y	=	WindowMouseY(0)

				If	\m_x	<	0	Or	\m_x	>	#C2D_W	Or	\m_y	<	#Y0	Or	\m_y	>	#Y1
					\m_x	=	0
					\m_y	=	0
				EndIf

			EndWith

		Case	#WM_RBUTTONDOWN
			C2D_Reset()
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
				Case	#VK_SPACE	:	C2D_Reset()
			EndSelect
	EndSelect
ForEver

C2D::Free()

DataSection
	t_scroller: 	:	Data.s	"BOUNCEBOMBER - THE ULTIMATIVE MEGA BALLER GAME... NO MERCY WITH THE SILVER BALLS... TO SHOT SMASH THE LEFT MOUSE... TO RESET USE THE RIGHT MOUSE... NOW BALLER TILL DA BRAIN IS BURNING"
EndDataSection
; IDE Options = PureBasic 6.01 LTS (Windows - x86)
; CursorPosition = 164
; FirstLine = 102
; Folding = 7-
; Executable = ..\Executables\C2D_Bounce_Shot_x86.exe
; CompileSourceDirectory