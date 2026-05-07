;**********************************************
;- *** C2D SPLATTER / 16.04.2026 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Splatter	=	1

	XIncludeFile	"C2D_Enums.pbi"

	Structure	RS_SplatterID
		*hImage	; imageid
		a.f		; alpha
		x.f		; posX
		y.f		; posY
		x_speed.f
		y_speed.f
		a_speed.f
		gravity.f
	EndStructure

	Structure	RS_Splatter
		IsOn.i
		IsAnim.i
		AnimID.i
		Image.i
		Energy.i		; Alpha
		Fade.i		; Fadeout - AlphaGlimmtime
		AccelerationX.i
		AccelerationY.i
		SpreadX.i	; x ± spread
		SpreadY.i	; y ± spread
		Gravity.i
		Number.i
		Bounce.f		; 1.0 = 100%
		Alpha.i
		Loop.i
		x.f
		y.f
		w.i
		h.i
		r.RECT
		List	ID.RS_SplatterID()
	EndStructure

	Global	ID_Splatter.C2D_ID
	Global	NewList	RS_Splatter.RS_Splatter()

	Declare	IsSplatter(ID)
	Declare	SplatterAcceleration(ID, x, y)
	Declare	SplatterAlpha(ID, Alpha=$FF)
	Declare	SplatterBounce(ID, Percent.f)
	Declare	SplatterDraw(ID, h.f)
	Declare	SplatterEnergy(ID, Energy)
	Declare	SplatterFade(ID, Fade)
	Declare	SplatterFree(ID)
	Declare	SplatterGravity(ID, Gravity)
	Declare	SplatterH(ID)
	Declare	SplatterImage(ID, Image)
	Declare	SplatterInit(ID, Size, Number, Color.l=#Red)
	Declare	SplatterLoop(ID, State)
	Declare	SplatterScale(ID, Ratio.f)
	Declare	SplatterSpread(ID, SpreadX, SpreadY)
	Declare	SplatterStart(ID, x.f, y.f)
	Declare	SplatterStop(ID=#PB_All)
	Declare	SplatterW(ID)

	Declare	SplatterAnim(ID, AnimID)	; Splatter + Anim

CompilerEndIf

Procedure	IsSplatter(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Splatter\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Splatter(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	SplatterAcceleration(ID, x, y)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		\AccelerationX	=	Abs(x)
		\AccelerationY	=	Abs(y)

		ForEach	\ID()

			\ID()\x_speed	=	0.01	*	Random(\AccelerationX)
			\ID()\y_speed	=	0.01	*	Random(\AccelerationY)

			If	\ID()\x	<	\x	:	\ID()\x_speed	*	-1	:	EndIf
			If	\ID()\y	<	\y	:	\ID()\y_speed	*	-1	:	EndIf

		Next

	EndWith

EndProcedure
Procedure	SplatterAlpha(ID, Alpha=$FF)
	If	IsSplatter(ID)
		RS_Splatter()\Alpha	=	Alpha
	EndIf
EndProcedure
Procedure	SplatterBounce(ID, Percent.f)
	If	IsSplatter(ID)
		RS_Splatter()\Bounce	=	Percent	*	-0.01
	EndIf
EndProcedure
Procedure	SplatterDraw(ID, h.f)

	Protected	a

	ChangeCurrentElement(RS_Splatter(), ID_Splatter\ID[ID])

	If	RS_Splatter()\IsOn	<=	#Null	:	ProcedureReturn	#False	:	EndIf

	With	RS_Splatter()

		\IsOn	=	#Null

		h	-	\h

		ForEach	\ID()
			If	\ID()\a	>	#Null

				a	=	\ID()\a	:	If	a	>	\Alpha	:	a	=	\Alpha	:	EndIf

				\ID()\a	-	\ID()\a_speed
				\ID()\x	+	\ID()\x_speed
				\ID()\y	+	\ID()\y_speed

				\ID()\y_speed	+	\ID()\gravity

				If	\ID()\y	>=	h
					\ID()\y	=	h
					\ID()\y_speed	*	\Bounce	; -(%) / ping&pong
				EndIf

				If	\ID()\x	<=	\r\left	Or	\ID()\y	<=	\r\top	Or
				  	\ID()\x	>=	\r\right	Or	\ID()\y	>=	\r\bottom

					\ID()\a	=	#Null

				Else

					\IsOn	+	1

					CompilerIf	#IsC2D_Anim
						If	\IsAnim
							AnimDraw(\AnimID, \ID()\x, \ID()\y, a)
						Else
							DrawAlphaImage(\ID()\hImage, \ID()\x, \ID()\y, a)
						EndIf
					CompilerElse
						DrawAlphaImage(\ID()\hImage, \ID()\x, \ID()\y, a)
					CompilerEndIf

				EndIf

			ElseIf	\Loop

				\ID()\a			=	Random(\Energy, \Energy >> 1)
				\ID()\a_speed	=	Random(\Fade, \Fade >> 2)

				\ID()\x	=	\x	+	C2D\GSin[Random(#MAX_SIN)]	*	\SpreadX
				\ID()\y	=	\y	+	C2D\GCos[Random(#MAX_SIN)]	*	\SpreadY

				\ID()\x_speed	=	0.010	*	Random(\AccelerationX)	:	If	\ID()\x	<	\x	:	\ID()\x_speed	*	-1	:	EndIf
				\ID()\y_speed	=	0.010	*	Random(\AccelerationY)	:	If	\ID()\y	<	\y	:	\ID()\y_speed	*	-1	:	EndIf

				\ID()\gravity	=	0.001	*	Random(\Gravity, \Gravity >> 3)

			EndIf
		Next

		ProcedureReturn	\IsOn

	EndWith

EndProcedure
Procedure	SplatterEnergy(ID, Energy)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		\Energy	=	Energy
		Energy	/	2

		ForEach	\ID()
			\ID()\a	=	Random(\Energy, Energy)
		Next

	EndWith

EndProcedure
Procedure	SplatterFade(ID, Fade)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		\Fade	=	Fade
		Fade	/	4	+	1

		If	\Fade	<	Fade	:	Swap	\Fade, Fade	:	EndIf

		ForEach	\ID()
			\ID()\a_speed	=	Random(\Fade, Fade)
		Next

	EndWith

EndProcedure
Procedure	SplatterFree(ID)

	With	RS_Splatter()

		If	ID	<=	#PB_All	; Free all objects

			ForEach	RS_Splatter()
				If	\Image	And	IsImage(\Image)	:	FreeImage(\Image)	:	EndIf
				ClearList(\ID())
			Next

			FillMemory(@ID_Splatter\ID, #MAX_ID	*	SizeOf(Integer))

			ClearList(RS_Splatter())

		Else

			If	IsSplatter(ID)

				ID_Splatter\ID[ID]	=	#Null
				If	\Image	And	IsImage(\Image)	:	FreeImage(\Image)	:	EndIf

				DeleteElement(RS_Splatter())

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	SplatterGravity(ID, Gravity)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		\Gravity	=	Gravity
		Gravity	/	8

		ForEach	\ID()
			\ID()\gravity	=	0.001	*	Random(\Gravity, Gravity)
		Next

	EndWith

EndProcedure
Procedure	SplatterH(ID)
	If	IsSplatter(ID)
		ProcedureReturn	RS_Splatter()\h
	EndIf
EndProcedure
Procedure	SplatterImage(ID, Image)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		If	\Image	And	IsImage(\Image)	:	FreeImage(\Image)	:	EndIf

		\Image	=	CopyImage(Image, #PB_Any)

 		\w	=	ImageWidth(\Image)
 		\h	=	ImageHeight(\Image)

		\r\left	=	-\w
		\r\top	=	-\h

		ForEach	\ID()
			\ID()\hImage	=	ImageID(\Image)
		Next

	EndWith

EndProcedure
Procedure	SplatterInit(ID, Size, Number, Color.l=#Red)

	SplatterFree(ID)	; free splatter if already initialized!

	ID_Splatter\ID[ID]	=	AddElement(RS_Splatter())

	With	RS_Splatter()
		
		CompilerIf	#PB_Compiler_Version	>=	630
			\Image	=	CreateImage(#PB_Any, Size, Size, 32, #PB_Image_TransparentBlack)
		CompilerElse
			\Image	=	CreateImage(#PB_Any, Size, Size, 32, #PB_Image_Transparent)
		CompilerEndIf
		Size	*	0.5	-	1
		StartDrawing(ImageOutput(\Image))
		DrawingMode(#PB_2DDrawing_AlphaBlend)
		Circle(Size, Size, Size, $FF000000|Color)
		StopDrawing()

		\Energy			=	512
		\Fade				=	16
		\AccelerationX	=	100
		\AccelerationY	=	100
		\SpreadX			=	100
		\SpreadY			=	100
		\Gravity			=	50
		\Bounce			=	-0.75	; 75 * -0.01 -> 75%
		\Alpha			=	$FF

		\w	=	ImageWidth(\Image)
		\h	=	ImageHeight(\Image)

		\r\left	=	-\w
		\r\top	=	-\h
		\r\right	=	C2D::C2D\w
		\r\bottom=	C2D::C2D\h

		While	ListSize(\ID())	<	Number
			AddElement(\ID())	:	\ID()\hImage	=	ImageID(\Image)
		Wend

	EndWith

	;SplatterStart(ID, C2D::C2D\cx, C2D::C2D\cy)	; fill [0] <- [1]

	ProcedureReturn	#True

EndProcedure
Procedure	SplatterLoop(ID, State)
	If	IsSplatter(ID)
		RS_Splatter()\Loop	=	State
	EndIf
EndProcedure
Procedure	SplatterScale(ID, Ratio.f)

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

 		\w	=	Ratio	*	ImageWidth(\Image)
 		\h	=	Ratio	*	ImageHeight(\Image)

 		ResizeImage(\Image, \w, \h, C2D\Quality)

		\r\left	=	-\w
		\r\top	=	-\h

		ForEach	\ID()
			\ID()\hImage	=	ImageID(\Image)
		Next

	EndWith

EndProcedure
Procedure	SplatterSpread(ID, SpreadX, SpreadY)

	Protected	x.f, y.f

	If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

	With	RS_Splatter()

		x	=	\x	-	\w	* 0.5
		y	=	\y	-	\h	* 0.5

		If	SpreadX	<=	#Null	:	SpreadX	=	1	:	EndIf
		If	SpreadY	<=	#Null	:	SpreadY	=	1	:	EndIf

		\SpreadX	=	SpreadX
		\SpreadY	=	SpreadY

		ForEach	\ID()

 			\ID()\x	=	x	+	C2D\GSin[Random(#MAX_SIN)]	*	\SpreadX
 			\ID()\y	=	y	+	C2D\GCos[Random(#MAX_SIN)]	*	\SpreadY

			\ID()\x_speed	=	Abs(\ID()\x_speed)	:	If	\ID()\x	<	x	:	\ID()\x_speed	*	-1	:	EndIf
			\ID()\y_speed	=	Abs(\ID()\y_speed)	:	If	\ID()\y	<	y	:	\ID()\y_speed	*	-1	:	EndIf

		Next

	EndWith

EndProcedure
Procedure	SplatterStart(ID, x.f, y.f)

	ChangeCurrentElement(RS_Splatter(), ID_Splatter\ID[ID])

	With	RS_Splatter()

		\IsOn	=	#True

		\x	=	x	; prereserve (s. Spread)
		\y	=	y	; ^^

		x	-	\w	* 0.5
		y	-	\h	* 0.5

		ForEach	\ID()

			\ID()\a			=	Random(\Energy, \Energy >> 1)
			\ID()\a_speed	=	Random(\Fade, \Fade >> 2)
		
			\ID()\x	=	x	+	C2D\GSin[Random(#MAX_SIN)] *	\SpreadX	;	*	0.01	*	Random(90)
			\ID()\y	=	y	+	C2D\GCos[Random(#MAX_SIN)] *	\SpreadY	;	*	0.01	*	Random(90)

			\ID()\x_speed	=	0.010	*	Random(\AccelerationX)	:	If	\ID()\x	<	x	:	\ID()\x_speed	*	-1	:	EndIf
			\ID()\y_speed	=	0.010	*	Random(\AccelerationY)	:	If	\ID()\y	<	y	:	\ID()\y_speed	*	-1	:	EndIf

			\ID()\gravity	=	0.001	*	Random(\Gravity, \Gravity >> 3)

		Next

		ProcedureReturn	ListSize(\ID())

	EndWith

EndProcedure
Procedure	SplatterStop(ID=#PB_All)

	If	ID	<=	#PB_All

		ForEach	RS_Splatter()
			RS_Splatter()\IsOn	=	#False
		Next

	ElseIf	IsSplatter(ID)

		RS_Splatter()\IsOn	=	#False

	EndIf

EndProcedure
Procedure	SplatterW(ID)
	If	IsSplatter(ID)
		ProcedureReturn	RS_Splatter()\w
	EndIf
EndProcedure

Procedure	SplatterAnim(ID, AnimID)
	CompilerIf	#IsC2D_Anim

		; Anim < #Null -> restore splatter

		If	IsSplatter(ID)	=	0	:	ProcedureReturn	: EndIf

		With	RS_Splatter()

			If	AnimID	<	#Null	; restore splatter

				\IsAnim	=	#False

				\w	=	ImageWidth(\Image)
				\h	=	ImageHeight(\Image)

			ElseIf	IsAnim(AnimID)	; use anim?

				\IsAnim	=	#True

				\AnimID	=	AnimID

				\w	=	RS_Anim()\w
				\h	=	RS_Anim()\h

			EndIf

			\r\left	=	-\w
			\r\top	=	-\h

		EndWith

	CompilerEndIf
EndProcedure
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAAA+
; CompileSourceDirectory