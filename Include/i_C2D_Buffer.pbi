;**********************************************
;- *** C2D BUFFER / 08.03.2020 ****************

; Direct access to canvas drawingbuffer, 1 pixel = 3 bytes (RGB) - no alpha!

EnableExplicit

CompilerIf	Defined(MAX_BPP,	#PB_Constant)	=	0	; Canvas BytesPerPixel[3]
	#MAX_BPP	=	3	; R,G,B = 1 Pixel
CompilerEndIf
CompilerIf	Defined(MAX_SIN,	#PB_Constant)	=	0	; Precalculated cos/sin values
	#MAX_SIN	=	2047	; Sin[]/Cos[]
CompilerEndIf

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Buffer	=	1,2
	
	XIncludeFile	"C2D_Macros.pbi"
	XIncludeFile	"C2D_Enums.pbi"

	For	i	=	0	To	#MAX_SIN
		C2D\GCos[i]	=	Cos(i * (2 * #PI / #MAX_SIN))
		C2D\GSin[i]	=	Sin(i * (2 * #PI / #MAX_SIN))
	Next

	Declare	BufferFree()
	Declare	BufferInit()
	Declare	BufferClear()
	Declare	BufferCloneY(y0, y1, h)
	Declare	BufferMirror(x, y, w, h, Mask=%11111111)
	Declare	BufferSinX(x, y, w, h, Width, Frequency.f, Speed.f)
	Declare	BufferSinY(x, y, w, h, Height, Frequency.f, Speed.f, Flags=#True)
	Declare	BufferSinDraw(y=0, h=0)
	Declare	BufferBackDraw()
	Declare	BufferBackGrab()
	
	CompilerIf	#IsC2D_Buffer	=	2
		Declare	BufferBackScroll(x, y, Time=0)
		Declare	BufferNoise(x, y, w, h, Noise=3, Color.l=$00FFFFFF)
	CompilerEndIf

CompilerEndIf

Procedure	BufferFree()	; called by Free()

	With	C2D
		If	\hMemory		:	FreeMemory(\hMemory)		:	\hMemory		=	#Null	:	EndIf
		If	\hBackGrab	:	FreeMemory(\hBackGrab)	:	\hBackGrab	=	#Null	:	EndIf
		If	\hFrontGrab	:	FreeMemory(\hFrontGrab)	:	\hFrontGrab	=	#Null	:	EndIf
	EndWith

EndProcedure
Procedure	BufferInit()	; called by Init()

	Protected	i

	With	C2D

		BufferFree()	; don't overrun memory, who knows?

		\hBuffer		=	DrawingBuffer()				; will be updated in Start()
		\hPitch		=	DrawingBufferPitch()			; real pixelWidth x #MAX_BPP
		\hSize		=	\hPitch	*	OutputHeight()	; bytesize of buffer

		\hMemory		=	AllocateMemory(\hSize)		; temp-buffer (SinY/DrawBuffer)
		\hMemoryY	=	\hMemory	+	\hSize

	EndWith

EndProcedure
Procedure	BufferBackGrab()

	With	C2D

		If	\hBackGrab	=	#Null
			\hBackGrab	=	AllocateMemory(\hSize)	; fast restore of background
		EndIf

		MoveMemory(DrawingBuffer(), \hBackGrab, \hSize)

	EndWith

EndProcedure
Procedure	BufferBackDraw()
	With	C2D
		MoveMemory(\hBackGrab, \hBuffer, \hSize)
	EndWith
EndProcedure
Procedure	BufferFrontGrab()

	With	C2D

		If	\hFrontGrab	=	#Null
			\hFrontGrab	=	AllocateMemory(\hSize)	; fast restore of background
		EndIf

		MoveMemory(DrawingBuffer(), \hFrontGrab, \hSize)

	EndWith

EndProcedure
Procedure	BufferFrontDraw(y=0, h=0)
	
	Static	*Buffer.Long	; buffer updated in Start()
	Static	*Front.Long		; buffered in BufferFrontGrab()
	Static	Length			; Loop / #MAX_BPP (3)
	
	*Buffer	=	C2D\hBufferY
	*Front	=	C2D\hFrontGrab	+	C2D\hSize
	Length	=	C2D\hSize
	
	; top / bottom loop-reduce?
	If	y	>	0
		y	*	C2D\hPitch
		*Buffer	-	y
		Length	-	y	<<	1
	EndIf
	
	; reduce loop in while/wend
	If	h	>	#Null
		Length	=	(h	*	C2D\hPitch	*	#MAX_BPP)
	EndIf

	While	Length	>	0
		
		*Buffer	-	#MAX_BPP
		*Front	-	#MAX_BPP
		Length	-	#MAX_BPP

		If	*Front\l	&	$FFFFFF00	; -> No Alpha & No Black!
			*Buffer\l	=	*Front\l
		EndIf

	Wend

EndProcedure
Procedure	BufferClear()
	With	C2D
		FillMemory(\hBuffer, \hSize, #Null, #PB_Integer)
	EndWith
EndProcedure
Procedure	BufferMirror(x, y, w, h, Mask=%11111111)
	
	Static	*Buffer, *Memory

	With	C2D

		*Buffer	=	\hBufferY	-	y	*	\hPitch	+	x	*	#MAX_BPP
		*Memory	=	*Buffer

		w	*	#MAX_BPP	; PixelFormat[3] BytesPerPixel * width
		y	=	#Null		; Return real masked height

		While	h	>=	0

			*Buffer	+	\hPitch

			If	h	&	Mask	; fast vertical pseudo-resize by mask

				*Memory	-	\hPitch

				MoveMemory(*Buffer, *Memory, w)

				y	+	1	; add to real returned height

			EndIf

			h	-	1

		Wend

	EndWith

	ProcedureReturn	y

EndProcedure
Procedure	BufferSinX(x, y, w, h, Width, Frequency.f, Speed.f)

	Static	*Memory, *Buffer, s

	Speed	*	C2D\Count	; Count -> s. Start()

	x	*	#MAX_BPP	; x PixelFormat[3] BytesPerPixel left
	w	*	#MAX_BPP	; x PixelFormat[3] BytesPerPixel width

	y	+	h	+	1	; Canvas in ReversedY

	*Buffer	=	C2D\hBufferY	+	x

	While	h	>	0

		*Memory	=	*Buffer	-	(y	-	h)	*	C2D\hPitch

		s	=	Speed	+	h	*	Frequency
		s	=	C2D\GSin[s	&	#MAX_SIN]	*	Width

		MoveMemory(*Memory - s * #MAX_BPP, *Memory, w)

		h	-	1	; from buttom to top

	Wend

EndProcedure
Procedure	BufferSinY(x, y, w, h, Height, Frequency.f, Speed.f, Flags=#True)

	Static	*Buffer.Long, *Ptr.Long, *Memory, Length, s

	Speed	*	C2D\Count

	x	*	#MAX_BPP
	w	*	#MAX_BPP

	x	-	w

	With	C2D

		FillMemory(\hMemory, \hSize, #Null, #PB_Integer)

		While	h	>	0

			Length	=	w
			s			=	x	+	(y + h)	*	\hPitch	; - w

			*Buffer	=	\hBufferY	-	s	; Drawingbuffer reversed
			*Memory	=	\hMemoryY	-	s	; Sinusbuffer

			While	Length	>	0

				*Buffer	-	#MAX_BPP	; first to reduce l+r pitch overlapping
				*Memory	-	#MAX_BPP

				If	*Buffer\l	&	$FFFFFF00	; PixelRGB0 <> #Black -> much faster on black background!

					s	=	Speed	+	Length	*	Frequency
					s	=	\GCos[s	&	#MAX_SIN]	*	Height

					*Ptr	=	*Memory	+	s	*	\hPitch
					
					If	*Ptr	<	\hMemoryY	And	*Ptr	>=	\hMemory
						*Ptr\l	=	*Buffer\l	; CanvasPixel to memory
					EndIf

					;MoveMemory(*Buffer, *Memory + s * \hPitch, #MAX_BPP)	; CanvasPixel to memory

				EndIf

				Length	-	#MAX_BPP

			Wend

			h	-	1

		Wend

		; Flags <> 0 = fast clear & draw into canvasbuffer
		If	Flags
			MoveMemory(\hMemory, \hBuffer, \hSize)
		EndIf

	EndWith

EndProcedure
Procedure	BufferCloneY(y0, y1, h)
	With	C2D
		MoveMemory(\hBufferY - (y0 + h) * \hPitch, \hBufferY - (y1 + h) * \hPitch, h * \hPitch)
	EndWith
EndProcedure
Procedure	BufferSinDraw(y=0, h=0)

	; Filled with BufferSinY() & Flags=0 before, call it to draw
	; manually directly into canvasbuffer (black=transparent)

	Static	*Buffer.Long	; buffer updated in Start()
	Static	*Sinus.Long		; buffered in BufferSinY()
	Static	Length			; Loop / #MAX_BPP (3)
	
	*Buffer	=	C2D\hBuffer
	*Sinus	=	C2D\hMemory
	Length	=	C2D\hSize

	; top / bottom loop-reduce?
	If	y	>	0
		y	*	C2D\hPitch
		*Buffer	+	y
		*Sinus	+	y
		Length	-	y	<<	1
	EndIf
	
	; reduce loop in while/wend
	If	h	>	#Null
		Length	=	(h	*	C2D\hPitch	*	#MAX_BPP)
	EndIf
	
	While	Length	>	0

		; No Alpha -> transparent on black background only!
		If	*Sinus\l	&	$FFFFFF00
			*Buffer\l	=	*Sinus\l
		EndIf

		*Buffer	+	#MAX_BPP
		*Sinus	+	#MAX_BPP
		Length	-	#MAX_BPP

	Wend

EndProcedure

CompilerIf	#IsC2D_Buffer	=	2
	Procedure	BufferBackScroll(x, y, Time=0)

		Static	BufferTime, *Memory
		Static	*Buffer, Pitch, *Ptr

		With	C2D

			BufferTime	+	1	; delayed scrolling?

			If	BufferTime	>=	Time

				BufferTime	=	#Null

				x	=	(x	+	\w)	%	\w
				y	=	(y	+	\h)	%	\h

				*Buffer	=	\hBackGrab
				Pitch		=	\hPitch

				If	y

					y	=	\h	-	y	; reverse the Y value

					*Memory	=	ReAllocateMemory(*Memory, Pitch * y, #PB_Memory_NoClear)

					MoveMemory(*Buffer, *Memory, Pitch * y)
					MoveMemory(*Buffer + Pitch * y, *Buffer, Pitch * (\h - y))
					MoveMemory(*Memory, *Buffer + Pitch * (\h - y), Pitch * y)

				EndIf

				If	x	; buggy

					x	*	#MAX_BPP
					y	=	\h

 					*Memory	=	ReAllocateMemory(*Memory, x, #PB_Memory_NoClear)

					While	y
						y		-	1
						*Ptr	=	*Buffer	+	Pitch	*	y
						MoveMemory(*Ptr, *Memory, x)
						MoveMemory(*Ptr + x, *Ptr, Pitch - x)
						MoveMemory(*Memory, *Ptr + Pitch - x, x)
					Wend

				EndIf

			EndIf
		EndWith

	EndProcedure
	Procedure	BufferNoise(x, y, w, h, Noise=3, Color.l=$00FFFFFF)
		
		Static	*Buffer, *Memory.Long
		
		With	C2D
			
			;Protected	*Buffer	=	\hBuffer	+	(\h	-	y)	*	\hPitch	+	x	*	#MAX_BPP
			*Buffer	=	\hBufferY	-	y	*	\hPitch	+	x	*	#MAX_BPP
			
			While	h
				
				*Memory	=	*Buffer	-	h	*	\hPitch
				
				h	-	1
				x	=	w
				
				While	x
					
					If	Random(Noise)
						*Memory\l	=	#Null
					Else
						*Memory\l	=	Color
					EndIf
					
					x	-	1
					*Memory	+	#MAX_BPP
					
				Wend	

			Wend
			
		EndWith
		
	EndProcedure	
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AAQ+
; DisableDebugger
; CompileSourceDirectory