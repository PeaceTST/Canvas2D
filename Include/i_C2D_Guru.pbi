;**********************************************
;- *** C2D Guru Meditation / 09.04.2020 *******

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_Guru	=	1
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Global	Guru.RS_Guru
	
	Declare	GuruDraw()
	Declare	GuruFree()
	Declare	GuruInit(*Memory.Ascii)
	
CompilerEndIf

CompilerIf	#IsC2D_FontRaw	=	0
	MA_ERROR("#IsC2D_FontRaw = 1 for Guru")
CompilerEndIf

Procedure	GuruAlignX(*Memory.Ascii)	; intern x-char-align when new line
	
	Protected	x
	
	While	*Memory\a
		
		Select	*Memory\a
			Case	#LF, '|'
				Break
			Case	#TAB
				x	+	3
			Default
				x	+	1
		EndSelect
		
		*Memory	+	SizeOf(Ascii)
		
	Wend
	
	x	=	(C2D\w	-	x	*	8)	>>	1
	
	ProcedureReturn	x
	
EndProcedure

Procedure	IsGuru()
	ProcedureReturn	Guru\IsOn
EndProcedure
Procedure	GuruFree()
	With	Guru

		\IsOn	=	#False

		If	\hBrush	:	DeleteObject_(\hBrush)	:	EndIf
		If	\hPen		:	DeleteObject_(\hPen)		:	EndIf
		If	\hClip	:	DeleteObject_(\hClip)	:	EndIf

		ClearList(\Char())

		;ResetStructure(@Guru, RS_Guru)

	EndWith
EndProcedure
Procedure	GuruInit(*Memory.Ascii, Color.l=#C2D_Guru_Color)

	; *Memory = Ptr to text

	Protected	x

	GuruFree()

	*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)

	Color	&	$00FFFFFF	; No Alpha!

	; Create & set topaz-font in text-color
	FontRawInit(#ID_GuruFont, #PB_Default, 0, 1, 1, Color)

	With	Guru
		
		\IsOn		=	#True
		\h			=	14

		x	=	GuruAlignX(*Memory)

		While	*Memory\a

			Select	*Memory\a

				Case	#MIN_CHR + 1	To	#MAX_CHR

					AddElement(\Char())
					\Char()\i	=	ImageID(FontImage(*Memory\a - #MIN_CHR))
					\Char()\x	=	x
					\Char()\y	=	\h

					x	+	8

				Case	#TAB

					x	+	3	*	8

				Case	#LF, '|'

					x	=	GuruAlignX(*Memory + SizeOf(Ascii))
					\h	+	9

				Default

					x	+	8

			EndSelect

			*Memory	+	SizeOf(Ascii)	; don't forget!

		Wend

		\h	+	7	+	14

		; GuruHeight <= max. CanvasHeight - 1 -> don't change!
		If	\h	>=	C2D\h	:	\h	=	C2D\h	-	1	:	EndIf

		; ReversedY -> copy canvas to bottom of frame
		\hY	=	(C2D\h - \h) * C2D\hPitch

		\hBrush	=	CreateSolidBrush_(#Black)					; Back always black
		\hPen		=	CreatePen_(#PS_INSIDEFRAME, 6, Color)	; Frame
		\hClip	=	CreateRectRgn_(0, 0, C2D\w, C2D\h)		; Needed if poly3d

	EndWith

EndProcedure
Procedure	GuruDraw()
	
	With	Guru
		
		If	\IsOn
			
			; copy canvas to bottom of frame
			MoveMemory(C2D\hBufferY - \hY, C2D\hBuffer, \hY)
			
			; set guru
			SetViewportOrgEx_(C2D\hDC, 0, 0, #Null)	; reset view if poly3d
			SelectObject_(C2D\hDC, \hClip)				; full clipping
			SelectObject_(C2D\hDC, \hBrush)				; back
			
			; is frame on?
			If	\Frame
				SelectObject_(C2D\hDC, \hPen)
			EndIf
			
			; draw guru-mask
			Rectangle_(C2D\hDC, 0, 0, C2D\w + Bool(\Frame=0), \h + Bool(\Frame=0))
			
			; draw guru-text
			DrawingMode(#PB_2DDrawing_Default)
			ForEach	\Char()
				DrawImage(\Char()\i, \Char()\x, \Char()\y)
			Next
			
			; frame on/off
			If	C2D\Time	>=	\Time
				\Frame	!	1
				\Time		=	C2D\Time	+	#C2D_Guru_FrameTime
			EndIf

		EndIf
		
	EndWith
	
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; EnableXP
; DisableDebugger
; CompileSourceDirectory