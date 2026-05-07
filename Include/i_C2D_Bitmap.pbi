;************************************************
;- *** C2D Bitmap / 17.04.2026 ******************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Bitmap	=	1,2

	XIncludeFile	"C2D_Enums.pbi"

	Global	ID_Bitmap.C2D_ID
	Global	NewList	RS_Bitmap.RS_Bitmap()
	Global	NewList	RS_BitmapScroll.RS_BitmapScroll()

	CompilerIf	#IsC2D_BitmapColor
		Declare	BitmapClear(ID, Color.l)
		Declare	BitmapFill(ID, Color.l)
		Declare	BitmapGray(ID)
		Declare	BitmapLumen(ID, r.f=1.0, g.f=1.0, b.f=1.0, a.f=1.0)
		Declare	BitmapMask(ID, Color.l)
		Declare	BitmapShade(ID, Color.l)
		Declare	BitmapShine(ID, Factor.f=1.0)
	CompilerEndIf
	
		Declare	IsBitmap(ID)
		Declare	BitmapAdd(ID, Image)
		;Declare	BitmapCopy(ID)	; private
		Declare	BitmapDraw(ID, x.f, y.f, Alpha=255, Flags=0)
		Declare	BitmapFlip(ID, Flags=0)
		Declare	BitmapFree(ID)
		Declare	BitmapH(ID)
		Declare	BitmapID(ID)
		Declare	BitmapImage(ID)
		Declare	BitmapInit(ID, *Memory, Length=0, Color.l=#PB_Default)
		Declare	BitmapRange(ID, x.f, y.f)
		Declare	BitmapScale(ID, Ratio.f)
		Declare	BitmapW(ID)
		Declare.f	BitmapX(ID)
		Declare.f	BitmapY(ID)
		Declare	BitmapZoom(ID, w=#PB_Default, h=#PB_Default)
	
	CompilerIf	#IsC2D_Bitmap	=	2
		BitmapLoop(ID, Flags)
		BitmapScroll(ID, x, y, Time=0)
	CompilerEndIf

CompilerEndIf

CompilerIf	#IsC2D_BitmapColor	; Colorize bitmap?

	; 3 ways for custom accsess

	Procedure.l	Blt_Clear(x, y, Pen.l, Paper.l)

		; set pen to 0

		If	Pen	=	Paper
			ProcedureReturn	#Null
		EndIf

		ProcedureReturn	Paper

	EndProcedure
	Procedure.l	Blt_Mask(x, y, Pen.l, Paper.l)

		; set all <> pen to 0

		If	Pen	<>	Paper
			ProcedureReturn	#Null
		EndIf

		ProcedureReturn	$FF000000

	EndProcedure
	Procedure.l	Blt_Shade(x, y, Pen.l, Paper.l)

		Protected	c.f

		If	Paper	&	$FF000000

			c	=	((Red(Paper)	+	Green(Paper)	+	Blue(Paper))	*	0.333)	*	(1.0 / 255)

			ProcedureReturn	RGBA(Red(Pen)		*	c,
			               	     Green(Pen)	*	c,
			               	     Blue(Pen)		*	c,
			               	     Alpha(Paper))

		EndIf

	EndProcedure
	Procedure.l	Blt_Fill(x, y, Pen.l, Paper.l)

		; set all to pen if Alpha(paper) > 0

		If	Paper	&	$FF000000
			ProcedureReturn	RGBA(Red(Pen), Green(Pen), Blue(Pen), Alpha(Pen))
		EndIf

	EndProcedure
	Procedure.l	Blt_Gray(x, y, Pen.l, Paper.l)

		Protected	c	=	(Sqr(0.23 * Red(Paper) * Red(Paper) + 0.70 * Green(Paper) * Green(Paper) + 0.07 * Blue(Paper) * Blue(Paper)))

		ProcedureReturn	RGBA(c, c, c, Alpha(Paper))

	EndProcedure

	Procedure	ColorShade(Image, Color.l)
		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_CustomFilter|#PB_2DDrawing_AllChannels)
		CustomFilterCallback(@Blt_Shade())
		Box(0, 0, OutputWidth(), OutputHeight(), Color)
		StopDrawing()
	EndProcedure
	Procedure	ColorClear(Image, Color.l)
		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_CustomFilter|#PB_2DDrawing_AllChannels)
		CustomFilterCallback(@Blt_Clear())
		Box(0, 0, OutputWidth(), OutputHeight(), $FF000000|Color)
		StopDrawing()
	EndProcedure
	Procedure	ColorMask(Image, Color.l)
		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_CustomFilter|#PB_2DDrawing_AllChannels)
		CustomFilterCallback(@Blt_Mask())
		Box(0, 0, OutputWidth(), OutputHeight(), $FF000000|Color)
		StopDrawing()
	EndProcedure
	Procedure	ColorFill(Image, Color.l)
		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_CustomFilter|#PB_2DDrawing_AllChannels)
		CustomFilterCallback(@Blt_Fill())
		Box(0, 0, OutputWidth(), OutputHeight(), Color)
		StopDrawing()
	EndProcedure
	Procedure	ColorGray(Image)
		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_CustomFilter|#PB_2DDrawing_AllChannels)
		CustomFilterCallback(@Blt_Gray())
		Box(0, 0, OutputWidth(), OutputHeight())
		StopDrawing()
	EndProcedure

	Procedure	BitmapClear(ID, Color.l)
		If	IsBitmap(ID)
			ColorClear(RS_Bitmap()\Image, Color)
		EndIf
	EndProcedure
	Procedure	BitmapShade(ID, Color.l)
		If	IsBitmap(ID)
			ColorShade(RS_Bitmap()\Image, Color)
		EndIf
	EndProcedure
	Procedure	BitmapMask(ID, Color.l)
		If	IsBitmap(ID)
			ColorMask(RS_Bitmap()\Image, Color)
		EndIf
	EndProcedure
	Procedure	BitmapFill(ID, Color.l)
		If	IsBitmap(ID)
			ColorFill(RS_Bitmap()\Image, Color)
		EndIf
	EndProcedure
	Procedure	BitmapGray(ID)
		If	IsBitmap(ID)
			ColorGray(RS_Bitmap()\Image)
		EndIf
	EndProcedure
	
	Procedure	BitmapLumen(ID, r.f=1.0, g.f=1.0, b.f=1.0, a.f=1.0)

		Protected	*p.Long, *f
		Protected	rp, gp, bp, ap

		If	IsBitmap(ID)
			ID	=	RS_Bitmap()\Image
		ElseIf	IsImage(ID)	<=	0
			ProcedureReturn
		EndIf

		StartDrawing(ImageOutput(ID))
		
		*p	=	DrawingBuffer()
		*f	=	*p	+	DrawingBufferPitch()	*	OutputHeight()
		
		While	*p	<	*f
			
			If	*p\l

				bp	=	*p\l			&	$FF
				gp	=	*p\l	>>	8	&	$FF
				rp	=	*p\l	>>	16	&	$FF
				ap	=	*p\l	>>	24	&	$FF

				If	rp	And	r	<>	1.0
					rp	*	r	:	If	rp	>	$FF	:	rp	=	$FF	:	EndIf
				EndIf

				If	gp	And	g	<>	1.0
					gp	*	g	:	If	gp	>	$FF	:	gp	=	$FF	:	EndIf
				EndIf

				If	bp	And	b	<>	1.0
					bp	*	b	:	If	bp	>	$FF	:	bp	=	$FF	:	EndIf
				EndIf

				If	ap	And	a	<>	1.0
					ap	*	a	:	If	ap	>	$FF	:	ap	=	$FF	:	EndIf
				EndIf

				*p\l	=	(ap<<24)	|	(rp<<16)	|	(gp<<8)	|	bp

			EndIf

			*p	+	SizeOf(Long)

		Wend

		StopDrawing()

	EndProcedure
	Procedure	BitmapShine(ID, Factor.f=1.0)

		; set alpha by light of color (white = $FF / black = $0)

		Protected	*p.Long, *f, a

		If	IsBitmap(ID)
			ID	=	RS_Bitmap()\Image
		ElseIf	IsImage(ID)	<=	0
			ProcedureReturn
		EndIf

		Factor	*	0.334

		StartDrawing(ImageOutput(ID))

		*p	=	DrawingBuffer()
		*f	=	*p	+	DrawingBufferPitch()	*	OutputHeight()
		
		While	*p	<	*f

			If	*p\l	&	$FF000000
				
				a	=	(*p\l >> 16 & $FF) + (*p\l >> 8 & $FF) + (*p\l & $FF)

				a	*	Factor	:	If	a	>	$FF	:	a	=	$FF	:	EndIf
				
				*p\l	&	$00FFFFFF	|	(a << 24)
				
			Else
				
				*p\l	=	#Null
				
			EndIf

			*p	+	SizeOf(Long)

		Wend

		StopDrawing()

	EndProcedure
	
CompilerEndIf

Procedure	Bitmap_Any()

	Protected	i=#MAX_ID

	While	i	>=	#Null
		If	ID_Bitmap\ID[i]	=	0
			Break
		EndIf
		i	-	1
	Wend

	ProcedureReturn	i

EndProcedure

Procedure	IsBitmap(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Bitmap\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Bitmap(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	BitmapAdd(ID, Image)

	BitmapFree(ID)	:	ID_Bitmap\ID[ID]	=	AddElement(RS_Bitmap())

	With	RS_Bitmap()

		\Image	=	CopyImage(Image, #PB_Any)
		\hImage	=	ImageID(\Image)

		\w	=	ImageWidth(\Image)
		\h	=	ImageHeight(\Image)

		ProcedureReturn	\Image

	EndWith

EndProcedure
Procedure	BitmapCopy(ID)

	; return new Image-Number

	If	IsBitmap(ID)	; Error? use #IsC2D_RawFont, no #PB_Any... or else
		With	RS_Bitmap()
			
			CompilerIf	#PB_Compiler_Version	>=	630
				ID	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_TransparentBlack)
			CompilerElse
				ID	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_Transparent)
			CompilerEndIf

			StartDrawing(ImageOutput(ID))
			DrawingMode(#PB_2DDrawing_AllChannels)
			DrawAlphaImage(\hImage, 0, 0)
			StopDrawing()

			ProcedureReturn	ID

		EndWith
	EndIf

EndProcedure
Procedure	BitmapDraw(ID, x.f, y.f, Alpha=255, Flags=0)

	; if Flags -> x,y used as offsets

	ChangeCurrentElement(RS_Bitmap(), ID_Bitmap\ID[ID])	;	direct element-change for faster display

	With	RS_Bitmap()

		If	Flags
			If			Flags	&	(#C2F_CenterX|#C2F_Center)	:	x	+	(C2D\w	-	\w)	*	0.5
			ElseIf	Flags	&	#C2F_Right						:	x	+	(C2D\w	-	\w)
			EndIf
			If			Flags	&	(#C2F_CenterY|#C2F_Center)	:	y	+	(C2D\h	-	\h)	*	0.5
			ElseIf	Flags	&	#C2F_Bottom						:	y	+	(C2D\h	-	\h)
			EndIf
		EndIf

		\x	=	x	; for actual x/y-position
		\y	=	y

		DrawAlphaImage(\hImage, x, y, Alpha)

	EndWith

EndProcedure
Procedure	BitmapFlip(ID, Flags=0)

	; #C2F_Horizontal = default

	Protected	hDC, w, h

	If	IsBitmap(ID)

		hDC	=	StartDrawing(ImageOutput(RS_Bitmap()\Image))

		w	=	OutputWidth()	;RS_Bitmap()\w
		h	=	OutputHeight()	;RS_Bitmap()\h

		Select	Flags
			Case	#C2F_Vertical
				StretchBlt_(hDC, #NUL, h-1, w ,-h, hDC, #NUL, #NUL, w, h, #SRCCOPY)
			Default
				StretchBlt_(hDC, w-1, #NUL, -w, h, hDC, #NUL, #NUL, w, h, #SRCCOPY)
		EndSelect

		StopDrawing()

	EndIf

EndProcedure
Procedure	BitmapFree(ID)

	With	RS_Bitmap()

		If	ID	<=	#PB_All

			ForEach	RS_Bitmap()
				If	\Image	And IsImage(\Image)	:	FreeImage(\Image)	:	EndIf
			Next

			FillMemory(@ID_Bitmap\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Bitmap())

		Else

			If	IsBitmap(ID)

				If	\Image	And	IsImage(\Image)
					FreeImage(\Image)
				EndIf

				DeleteElement(RS_Bitmap())

				ID_Bitmap\ID[ID]	=	#Null

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	BitmapH(ID)

	; return pixel-height

	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\h
	EndIf

EndProcedure
Procedure	BitmapID(ID)

	; return handle of image (ImageID) or 0 = error

	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\hImage
	EndIf

EndProcedure
Procedure	BitmapImage(ID)

	; return number of #image or 0 = error

	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\Image
	EndIf

EndProcedure
Procedure	BitmapInit(ID, *Memory, Length=0, Color.l=#PB_Default)
	
	If	ID	<	#Null	:	ID	=	Bitmap_Any()	:	EndIf
	
	BitmapFree(ID)	:	ID_Bitmap\ID[ID]	=	AddElement(RS_Bitmap())	; @RS_Bitmap()

	With	RS_Bitmap()

		; check/set size of memory
		CompilerIf	#IsC2D_File
			If	Length	<=	#Null	; Filename as *Ptr?
				*Memory	=	FileLoad(PeekS(*Memory))
				Length	=	MemorySize(*Memory)
			EndIf
		CompilerEndIf

		\Image	=	GdipCatch(#PB_Any, *Memory, Length)
		
		If	IsImage(\Image)	=	#Null	:	ProcedureReturn	#Null	:	EndIf

		\w	=	ImageWidth(\Image)
		\h	=	ImageHeight(\Image)

		CompilerIf	#IsC2D_BitmapColor
			If	ImageDepth(\Image, #PB_Image_OriginalDepth)	<	32	Or	Color	<>	#PB_Default

				CompilerIf	#PB_Compiler_Version	>=	630
					ID	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_TransparentBlack)
				CompilerElse
					ID	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_Transparent)
				CompilerEndIf

				StartDrawing(ImageOutput(ID))
				DrawingMode(#PB_2DDrawing_AllChannels)
				DrawAlphaImage(ImageID(\Image), 0, 0)
				StopDrawing()

				If	Color	<>	#PB_Default
					ColorClear(ID, $FF000000|Color)
				EndIf

				FreeImage(\Image)

				\Image	=	ID

			EndIf
		CompilerEndIf

		\hImage	=	ImageID(\Image)	; HanDle of image for faster drawing

	;	ProcedureReturn	\Image
		
		ProcedureReturn	ID

	EndWith

EndProcedure
Procedure	BitmapRange(ID, x.f, y.f)

	; return #true if x/y points inside bitmap

	ChangeCurrentElement(RS_Bitmap(), ID_Bitmap\ID[ID])	; risiko for fastest selection

	With	RS_Bitmap()
		If	x	>=	\x	And	x	<=	\x	+	\w	And	y	>=	\y	And	y	<=	\y	+	\h
			ProcedureReturn	#True
		EndIf
	EndWith

EndProcedure
Procedure	BitmapScale(ID, Ratio.f)

	; Resize image proportional × ratio

	If	IsBitmap(ID)
		With	RS_Bitmap()

			If	Ratio	<>	1.0

				\w	=	ImageWidth(\Image)	*	Ratio
				\h	=	ImageHeight(\Image)	*	Ratio

				\hImage	=	ResizeImage(\Image, \w, \h, C2D\Quality)

			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	BitmapW(ID)

	; return pixelwidth

	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\w
	EndIf

EndProcedure
Procedure.f	BitmapX(ID)
	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\x
	EndIf
EndProcedure
Procedure.f	BitmapY(ID)
	If	IsBitmap(ID)
		ProcedureReturn	RS_Bitmap()\y
	EndIf
EndProcedure
Procedure	BitmapZoom(ID, w=#PB_Default, h=#PB_Default)

	; Zoom image unproportional w & h

	If	IsBitmap(ID)
		With	RS_Bitmap()

			If	w	>	#Null	:	\w	=	w	:	EndIf
			If	h	>	#Null	:	\h	=	h	:	EndIf

			If	\w	<>	ImageWidth(\Image)	Or	\h	<>	ImageHeight(\Image)
				\hImage	=	ResizeImage(\Image, \w, \h, C2D\Quality)
			EndIf

		EndWith
	EndIf

EndProcedure

CompilerIf	#IsC2D_Bitmap	=	2
	Procedure	BitmapLoop(ID, Flags)
		
		Protected	Image, w, h, *hDC
		
		If	IsBitmap(ID)	=	#Null	Or	Flags	&	(#C2F_Horizontal	|	#C2F_Vertical)	=	#Null	:	ProcedureReturn	:	EndIf
		
		With	RS_Bitmap()

			w	=	\w
			h	=	\h
			
			If	Flags	&	#C2F_Horizontal	:	w	*	2	:	EndIf
			If	Flags	&	#C2F_Vertical		:	h	*	2	:	EndIf
			
			CompilerIf	#PB_Compiler_Version	>=	630
				Image	=	CreateImage(#PB_Any, w, h, 32, #PB_Image_Transparent)
			CompilerElse
				Image	=	CreateImage(#PB_Any, w, h, 32, #PB_Image_Transparent)
			CompilerEndIf
			
			*hDC	=	StartDrawing(ImageOutput(Image))
			
			DrawAlphaImage(\hImage, 0, 0)
			
			If	Flags	&	#C2F_Horizontal
				StretchBlt_(*hDC, w - 1, #Null, -\w, \h, *hDC, #Null, #Null, \w, \h, #SRCCOPY)
			EndIf
			
			\w	=	w
			
 			If	Flags	&	#C2F_Vertical
 				StretchBlt_(*hDC, #Null, h - 1, \w, -\h, *hDC, #Null, #Null, \w, \h, #SRCCOPY)
 			EndIf
 			
 			\h	=	h
 			
 			StopDrawing()
			
			FreeImage(\Image)
			
			\Image	=	Image
			\hImage	=	ImageID(Image)
		
	EndWith

	EndProcedure
	Procedure	BitmapScroll(ID, x, y, Time=0)
		
		; https://www.purebasic.fr/french/viewtopic.php?p=193929#p193929

		Static	*Memory

		If	IsBitmap(ID)

			Protected	*Buffer, Pitch, PixelFormat, *Ptr

			With	RS_Bitmap()

				\TimeDelay	+	1	; delayed scrolling?

				If	\TimeDelay	>=	Time

					\TimeDelay	=	#Null

					x	=	(x	+	\w)	%	\w
					y	=	(y	+	\h)	%	\h

					If	x	=	0	And	y	=	0	:	ProcedureReturn	:	EndIf

					StartDrawing(ImageOutput(\Image))

					*Buffer	=	DrawingBuffer()
					Pitch		=	DrawingBufferPitch()

					If	y

						If	DrawingBufferPixelFormat()	&	#PB_PixelFormat_ReversedY
							y	=	\h	-	y	; reverse the Y value
						EndIf

						*Memory	=	ReAllocateMemory(*Memory,	Pitch * y, #PB_Memory_NoClear)

						MoveMemory(*Buffer, *Memory, Pitch * y)
						MoveMemory(*Buffer + Pitch * y, *Buffer, Pitch * (\h - y))
						MoveMemory(*Memory, *Buffer + Pitch * (\h - y), Pitch * y)

					EndIf

					If	x

						PixelFormat	=	DrawingBufferPixelFormat()	&	~#PB_PixelFormat_ReversedY

						If	PixelFormat	>=	#PB_PixelFormat_32Bits_RGB
							x	<<	2
						ElseIf PixelFormat	>=	#PB_PixelFormat_24Bits_RGB
							x	*	3
						ElseIf PixelFormat	>=	#PB_PixelFormat_15Bits
							x	<<	1
						EndIf

						*Memory	=	ReAllocateMemory(*Memory, x, #PB_Memory_NoClear)

						y	=	\h

						While	y
							y		-	1
							*Ptr	=	*Buffer	+	Pitch	*	y
							MoveMemory(*Ptr, *Memory, x)
							MoveMemory(*Ptr + x, *Ptr, Pitch - x)
							MoveMemory(*Memory, *Ptr + Pitch - x, x)
						Wend

					EndIf

					StopDrawing()

				EndIf

			EndWith

		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = IAAAAAAx
; EnableXP
; CompileSourceDirectory