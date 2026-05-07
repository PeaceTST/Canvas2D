;**********************************************
;- *** C2D RotoZoom / 02.08.2021 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_RotoZoom	=	1

	Structure	RS_ROTOZOOM
		Time.q
		Wait.i
		x.i
		y.i
		w.i
		h.i
		ZoomSpeed.i
		ZoomPos.i
		ZoomMin.i
		ZoomMax.i
		RZ_SIN.f[361]
		RZ_COS.f[361]
		RZ_POINT[256 * 256 + 1]
	EndStructure

	Global	RS_ROTOZOOM.RS_ROTOZOOM
	
	Declare	RotoZoomAlpha(Alpha)
	Declare	RotoZoomBlend(Percent)
	Declare	RotoZoomClip(x, y, w, h)
	Declare	RotoZoomDraw(rx.f, ry.f)
	Declare	RotoZoomInit(Image, Size.f=256.0, Color.l=#PB_Ignore)
	Declare	RotoZoomSet(Time, Speed, Min, Max)

CompilerEndIf

Procedure	RotoZoomAlpha(Alpha)

	Protected	i

	For	i	=	0	To	256	*	256
		If	RS_ROTOZOOM\RZ_POINT[i]
			RS_ROTOZOOM\RZ_POINT[i]	&	$00FFFFFF	|	Alpha	<<	24
		EndIf
	Next

EndProcedure
Procedure	RotoZoomBlend(Percent)

	Protected	i, a.a

	For	i	=	0	To	256	*	256
		If	RS_ROTOZOOM\RZ_POINT[i]
			a	=	(RS_ROTOZOOM\RZ_POINT[i]	&	$FF000000)	>>	24
			a	*	0.01	*	Percent
			RS_ROTOZOOM\RZ_POINT[i]	&	$00FFFFFF	|	a	<<	24
		EndIf
	Next

EndProcedure
Procedure	RotoZoomClip(x, y, w, h)
	With	RS_ROTOZOOM
		\x	=	x
		\y	=	y
		\w	=	x	+	w
		\h	=	y	+	h
	EndWith
EndProcedure
Procedure	RotoZoomSet(Time, Speed, Min, Max)
	With	RS_ROTOZOOM
		\Wait			=	Time
		\ZoomSpeed	=	Speed
		\ZoomMin		=	Min
		\ZoomMax		=	Max
		\ZoomPos		=	Max
	EndWith
EndProcedure
Procedure	RotoZoomInit(Image, Size.f=256.0, Color.l=#PB_Ignore)

	Protected	a.f, i, x, y, c.l

	Protected	w	=	ImageWidth(Image)
	Protected	h	=	ImageHeight(Image)

	If	Size	<=	#Null	Or	Size	>	256	:	Size	=	256	:	EndIf

	; Align width/height to size
	If	w	>	h
		If	w	>=	Size
			a	=	w	/	Size
			h	/	a
		ElseIf	w	<	Size
			a	=	Size	/	w
			h	*	a
		EndIf
		w	=	Size
	ElseIf	h	>	w
		If	h	>=	Size
			a	=	h	/	Size
			w	/	a
		ElseIf	h	<	Size
			a	=	Size	/	h
			w	*	a
		EndIf
		h	=	Size
	Else
		w	=	Size
		h	=	Size
	EndIf

	If	w	>	Size	:	w	=	Size	:	EndIf
	If	h	>	Size	:	h	=	Size	:	EndIf

	; Always copy as 32bit alpha-image
	i	=	CreateImage(#PB_Any, ImageWidth(Image), ImageHeight(Image), 32, #PB_Image_Transparent)
	StartDrawing(ImageOutput(i))
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	DrawImage(ImageID(Image), 0, 0)
	StopDrawing()

	Image	=	i
	ResizeImage(Image, w, h, C2D\Quality)

	; Must 256pix in width & height to avoid bordersizeing
	If	w	<>	256	Or	h	<>	256
		i	=	CreateImage(#PB_Any, 256, 256, 32, #PB_Image_Transparent)
		StartDrawing(ImageOutput(i))
		DrawingMode(#PB_2DDrawing_AlphaBlend)
		DrawImage(ImageID(Image), (256 - w) / 2, (256 - h) / 2)
		StopDrawing()
		FreeImage(Image)
		Image	=	i
	EndIf

	; user transparent color?
	If	Color	<>	#PB_Ignore
		Color	|	$FF000000
	EndIf
	
	;generate texture
	StartDrawing(ImageOutput(Image))
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	For x	=	0	To	256-1
		For y	=	0	To	256-1
			c	=	Point(x, y)
			If	c	&	$FF000000	=	0	Or	(Color	<>	#PB_Ignore	And	c	=	Color)
				c	=	0
			EndIf
			RS_ROTOZOOM\RZ_POINT[x << 8 + y]	=	c
		Next
	Next
	StopDrawing()
	
	; generate rotation
	For i	=	0 To 360
		RS_ROTOZOOM\RZ_SIN[i]	=	Sin(i	*	(2	*	#PI	/	360))
		RS_ROTOZOOM\RZ_COS[i]	=	Cos(i	*	(2	*	#PI	/	360))
	Next
	
	FreeImage(Image)

	RotoZoomClip(0, 0, C2D\w, C2D\h)	; default full display
	RotoZoomSet(10, 4, 210, 2100)

EndProcedure
Procedure	RotoZoomDraw(rx.f, ry.f)

	Static	z=1, x, y, u.a, v.a, c.l
	Static	i, xs.f, xc.f

	With	RS_ROTOZOOM

		If	MA_TIME()	>=	\Time

			i	%	360	+	1
			
			If	\ZoomPos	<=	\ZoomMin	And	z	<	0
				z	=	\ZoomSpeed
			ElseIf	\ZoomPos	>=	\ZoomMax	And	z	>	0
				z	=	-\ZoomSpeed
			EndIf
			
			\ZoomPos	+	z
			
			\Time	=	MA_TIME()	+	\Wait

		EndIf

		rx	*	\RZ_SIN[i]	; x-rotationspeed
		ry	*	\RZ_COS[i]	; y-rotationspeed

		x	=	\x	; startx
		
		While	x	<	\w	; endx

			y	=	\y	; starty

			xs	=	x * rx
			xc	=	x * ry

			While	y	<	\h	; endy

				u =  (xc - y * rx) / \ZoomPos
				v =  (xs + y * ry) / \ZoomPos

				c	=	\RZ_POINT[u <<	8 + v]

				If  c
					Plot(x, y, c)
				EndIf

				y	+	1

			Wend

			x	+	1

		Wend

	EndWith

EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = B9
; CompileSourceDirectory