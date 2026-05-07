;**********************************************
;- *** C2D STARS 3D / 08.03.2020 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	; *** only for testphase ***
	
	; #IsC2D_Stars3D	=	1

	XIncludeFile	"C2D_Enums.pbi"
	
	Global	C2D.RS_Canvas2D
	Global	StarField3D.RS_StarField3D
	
	;StarField3D\Color		=	$FF000000|#White
	;StarField3D\Distance	=	-32
	;StarField3D\Spread		=	C2D\w
	
	Declare	Stars3DColor(Color.l)
	Declare	Stars3DDistance(z)
	Declare	Stars3DDraw(x.f=0, y.f=0)
	Declare	Stars3DFree()
	Declare	Stars3DInit(Number, Size, x, y, w, h, Speed.f, BitmapID=#PB_Default)
	Declare	Stars3DSpread(Spread)
	
CompilerEndIf

Procedure	Stars3DFree()

	With	StarField3D

		CompilerIf	#IsC2D_Stars3D	=	1
			If	\Image	:	FreeImage(\Image)	:	EndIf
		CompilerEndIf
		
		ClearList(\Star())
		
	EndWith
	
EndProcedure
Procedure	Stars3DInit(Number, Size, x, y, w, h, Speed.f, Image=#PB_Default)
	
	Protected	i
	
	Stars3DFree()

	With	StarField3D
		
		\Speed	=	Speed	*	0.005
		;\Spread	=	C2D\w	; default spread width of stars
		;\Distance=	-32	; default startdepth of stars -32..255
		;\Color	=	$FFFFFFFF

		CompilerIf	#IsC2D_Stars3D	=	1
			
			If	Image	=	#PB_Default
				
				\Size		=	Size	*	2	+	1
				\Image	=	CreateImage(#PB_Any, \Size, \Size, 32, #PB_Image_Transparent)
				
				StartDrawing(ImageOutput(\Image))
				DrawingMode(#PB_2DDrawing_AllChannels)
				If	\Size	=	1
					Box(0, 0, 1, 1, \Color)
				Else
					Circle(OutputWidth() * 0.5, OutputHeight() * 0.5, Size - 1, \Color)
				EndIf
				StopDrawing()
				
			Else
				
				\Image	=	CopyImage(Image, #PB_Any)
				\Size		=	Size	:	If	\Size	<=	#Null	:	\Size	=	8	:	EndIf
				
				If	\Size <> ImageWidth(\Image)	Or	\Size <> ImageHeight(\Image)
					ResizeImage(\Image, \Size, \Size, C2D\Quality)
				EndIf
				
			EndIf
			
			\ImageHD	=	ImageID(\Image)	; faster draw
			
			\Clip\x	=	x
			\Clip\y	=	y
			\Clip\w	=	w
			\Clip\h	=	h
			
		CompilerElse	; Plot star -> 10x faster -> but 1px only
			
			w	-	1
			h	-	1
			
			\Size		=	0
			\Color	&	$00FFFFFF	; Alpha set when draw
			
		CompilerEndIf

		\left		=	x - \Size
		\top		=	y - \Size
		\right	=	x + w
		\bottom	=	y + h
		
		\x_Center	=	(C2D\w	-	\Size)	*	0.5
		\y_Center	=	(C2D\h	-	\Size)	*	0.5

		While	Number	>	ListSize(\Star())
			
			x	=	C2D\w	+	Random(1500)	+	\Spread
			
			AddElement(\Star())
		
			i	=	MA_RMP(1024)	|	1	:	\Star()\SpeedX	=	i	*	0.001	*	\Speed	:	\Star()\SpeedX	+	\Star()\SpeedX	*	\Speed	*	x
			i	=	MA_RMP(1024)	|	1	:	\Star()\SpeedY	=	i	*	0.001	*	\Speed	:	\Star()\SpeedY	+	\Star()\SpeedY	*	\Speed	*	x

			\Star()\x	=	\x_Center	+	\Star()\SpeedX	*	x
			\Star()\y	=	\y_Center	+	\Star()\SpeedY	*	x
			\Star()\z	=	Random(3, 1)	*	\Distance	; Start z-Alpha

		Wend

	EndWith

EndProcedure
Procedure	Stars3DDraw(x.f=0, y.f=0)

	Static	sx.f, sy.f, i

	With	StarField3D
		
		CompilerIf	#IsC2D_Stars3D	=	1	; Stars as bitmap?
			ClipOutput(\Clip\x, \Clip\y, \Clip\w, \Clip\h)
		CompilerEndIf
		
		ForEach	\Star()

			sx	=	x	+	\Star()\x
			sy	=	y	+	\Star()\y

			If	sx < \left	Or	sx > \right	Or sy < \top	Or	sy > \bottom
				
				sx	=	C2D\w	+	Random(1500)	+	\Spread
				
				i	=	MA_RMP(1024)	|	1	:	\Star()\SpeedX	=	i	*	0.001	*	\Speed	:	\Star()\SpeedX	+	\Star()\SpeedX	*	\Speed	*	sx
				i	=	MA_RMP(1024)	|	1	:	\Star()\SpeedY	=	i	*	0.001	*	\Speed	:	\Star()\SpeedY	+	\Star()\SpeedY	*	\Speed	*	sx
				
				\Star()\x	=	\x_Center	+	\Star()\SpeedX	*	sx
				\Star()\y	=	\y_Center	+	\Star()\SpeedY	*	sx
				\Star()\z	=	\Distance	; Start z-Alpha

			Else

				\Star()\SpeedX	+	\Star()\SpeedX	*	\Speed	; speed up
				\Star()\SpeedY	+	\Star()\SpeedY	*	\Speed
				
				\Star()\x	+	\Star()\SpeedX	; set position
				\Star()\y	+	\Star()\SpeedY
				
				If	\Star()\z	<	255	And	C2D\Time	>=	\Star()\Time
					\Star()\z	+	#STAR3D_Z_ADD	:	If	\Star()\z	>	255	:	\Star()\z	=	255	:	EndIf
					\Star()\Time	=	C2D\Time	+	#STAR3D_Z_TIME
				EndIf
				
				If	\Star()\z	>	0
					CompilerIf	#IsC2D_Stars3D	=	1
						DrawAlphaImage(\ImageHD, sx, sy, \Star()\z)	; do not use alpha as float (damn slow)
					CompilerElse
						Plot(sx, sy, \Star()\z	<<	24	|	\Color)
					CompilerEndIf
				EndIf
				
			EndIf

		Next
		
		CompilerIf	#IsC2D_Stars3D	=	1
			UnclipOutput()
		CompilerEndIf

	EndWith

EndProcedure
Procedure	Stars3DDistance(z)
	StarField3D\Distance	=	z	; default startdepth of stars ±255
EndProcedure
Procedure	Stars3DColor(Color.l)
	; Call it before! Stars3DInit()
	StarField3D\Color	=	$FF000000|Color
EndProcedure
Procedure	Stars3DSpread(Spread)
	StarField3D\Spread	=	Spread	; default spread width of stars
EndProcedure
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AA-
; EnableXP
; CompileSourceDirectory