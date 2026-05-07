;**********************************************
;- *** C2D STARS 2D / 08.03.2020 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	XIncludeFile	"C2D_Enums.pbi"

	Global	StarField2D.RS_StarField2D
	
	;StarField2D\Color		=	$FF000000|#White
	;StarField2D\Direction	=	#Flag_Right
	
	Declare	Stars2DColor(Color.l)
	Declare	Stars2DDirection(Flag)
	Declare	Stars2DDraw()
	Declare	Stars2DFree()
	Declare	Stars2DInit(Number, Size, x, y, w, h, Speed.f, BitmapID=#PB_Default)

CompilerEndIf

Procedure	Stars2DFree()
	With	StarField2D
		If	\Image	:	FreeImage(\Image)	:	EndIf
		ClearList(\Star())
	EndWith
EndProcedure
Procedure	Stars2DInit(Number, Size, x, y, w, h, Speed.f, Image=#PB_Default)

	Stars2DFree()

	With	StarField2D
		
		;\Color		=	$FFFFFFFF
		;\Direction	=	#Flag_Right
		\Speed		=	Speed

		If	Image	=	#PB_Default
			
			\Size	=	Size	*	2	+	1
			
			\Image	=	CreateImage(#PB_Any, \Size, \Size, 32, #PB_Image_Transparent)
			
			StartDrawing(ImageOutput(\Image))
			DrawingMode(#PB_2DDrawing_AllChannels)
			FrontColor(\Color)
			If	\Size	=	1
				Box(0, 0, 1, 1)
			Else
				Circle(OutputWidth() * 0.5, OutputHeight() * 0.5, Size - 1)
			EndIf
			StopDrawing()
			
		Else

			\Image	=	CopyImage(Image, #PB_Any)
			
			\Size	=	Size	:	If	\Size	<=	#Null	:	\Size	=	8	:	EndIf
			
			If	\Size <> ImageWidth(\Image)	Or	\Size <> ImageHeight(\Image)
				ResizeImage(\Image, \Size, \Size, C2D\Quality)
			EndIf
			
		EndIf
		
		\ImageHD	=	ImageID(\Image)
		
		\Clip\x	=	x
		\Clip\y	=	y
		\Clip\w	=	w
		\Clip\h	=	h

		\left		=	x - \Size
		\top		=	y - \Size
		\right	=	x + w
		\bottom	=	y + h
		
		w - \Size	; max. width
		h - \Size	; max. height
		
		While	Number	>	ListSize(\Star())

			AddElement(\Star())

			\Star()\SpeedX	=	(\Speed * 0.05) * Random(17, 3)

			\Star()\x	=	x	+	Random(w)
			\Star()\y	=	y	+	Random(h)
			
			\Star()\z	=	255.0 / \Speed	*	\Star()\SpeedX	; Alpha
			\Star()\z	|	%11111	; min. alpha 15

			\Star()\SpeedX	=	(\Star()\SpeedX	+	0.05 * Random(\Star()\SpeedX))	*	Bool(\Speed)	; Speed = NULL
			\Star()\SpeedY	=	\Star()\SpeedX		*	0.9

		Wend

		CompilerIf	IsC2D::#IsC2D_Stars2D	=	2	; sortieren nach Alpha?
			SortStructuredList(\Star(), #PB_Sort_Ascending, OffsetOf(RS_Star2D\z), TypeOf(RS_Star2D\z))
		CompilerEndIf

	EndWith

EndProcedure
Procedure	Stars2DDraw()
	
	; n & %1111 -> 33% faster pseudo-rnd (0..15) than Random(15)

	Static	n

	With	StarField2D

		ClipOutput(\Clip\x, \Clip\y, \Clip\w, \Clip\h)

		Select	\Direction

			Case	#C2F_Left
				ForEach	\Star()
					\Star()\x	-	\Star()\SpeedX
					If	\Star()\x	<	\left
						n	=	Random(\Clip\h - \Size)	:	\Star()\y	=	\Clip\y	+	n
						n	&	%1111	:	\Star()\x	=	\right	+	n
					Else
						DrawAlphaImage(\ImageHD, \Star()\x, \Star()\y, \Star()\z)
					EndIf
				Next

			Case	#C2F_Down
				ForEach	\Star()
					\Star()\y	+	\Star()\SpeedY
					If	\Star()\y	>	\bottom
						n	=	Random(\Clip\w - \Size)	:	\Star()\x	=	\Clip\x	+	n
						n	&	%1111	:	\Star()\y	=	\top	-	n
					Else
						DrawAlphaImage(\ImageHD, \Star()\x, \Star()\y, \Star()\z)
					EndIf
				Next

			Case	#C2F_Up
				ForEach	\Star()
					\Star()\y	-	\Star()\SpeedY
					If	\Star()\y	<	\top
						n	=	Random(\Clip\w - \Size)	:	\Star()\x	=	\Clip\x	+	n
						n	&	%1111	:	\Star()\y	=	\bottom	+	n
					Else
						DrawAlphaImage(\ImageHD, \Star()\x, \Star()\y, \Star()\z)
					EndIf
				Next

			Default	;Case	#C2F_Right
				ForEach	\Star()
					\Star()\x	+	\Star()\SpeedX
					If	\Star()\x	>	\right
						n	=	Random(\Clip\h - \Size)	:	\Star()\y	=	\Clip\y	+	n
						n	&	%1111	:	\Star()\x	=	\left	-	n
					Else
						DrawAlphaImage(\ImageHD, \Star()\x, \Star()\y, \Star()\z)
					EndIf
				Next

		EndSelect

		UnclipOutput()

	EndWith

EndProcedure
Procedure	Stars2DColor(Color.l)
	StarField2D\Color	=	$FF000000|Color
EndProcedure
Procedure	Stars2DDirection(Flag)
	StarField2D\Direction	=	Flag
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; EnableXP
; CompileSourceDirectory