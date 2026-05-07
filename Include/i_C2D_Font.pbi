;**********************************************************
;- *** C2D FONT / TEXT, RAW, PAGE, GURU... / 16.04.2026 ***

EnableExplicit

; http://eab.abime.net/showthread.php?t=21960
; http://eab.abime.net/showthread.php?t=2980

; FontMap-Characters 0 - 63:

;##+ 01234567
; 0:  !"#$%&'
; 8: ()*+,-./
;16: 01234567
;24: 89:;<=>?
;32: @ABCDEFG
;40: HIJKLMNO
;48: PQRSTUVW
;56: XYZ[\]^_

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	XIncludeFile	"C2D_Enums.pbi"

	Global	ID_Font.C2D_ID
	Global	NewList	RS_FontMap.RS_FontMap()

	Declare	IsFontMap(ID)
	Declare	FontScale(ID, Ratio.f)
	Declare	FontFree(ID)
	Declare	FontGap(ID, w=0, h=0)
	Declare	FontH(ID)
	Declare	FontImage(CharID)
	Declare	FontInit(ID, Image, x=0, y=0)
	Declare	FontSelect(ID)
	Declare	FontTab(ID, w=3)
	Declare	FontW(ID)
	Declare	FontZoom(ID, w, h)

	CompilerIf	#IsC2D_FontColor
		Declare	FontColor(ID, Color.l, t$=#Null$)
		Declare	FontCopper(ID, *Memory.Long, Flags=0)
		Declare	FontShadow(ID, x, y, Alpha=255)
		Declare	FontBorder(ID, Color.l=#Black)
	CompilerEndIf

CompilerEndIf

CompilerIf	#IsC2D_FontColor

	Procedure.l	Blt_FontColor(x, y, Pen.l, Paper.l)

		Protected	c.f

		If	Paper	&	$FF000000

			c	=	((Red(Paper)	+	Green(Paper)	+	Blue(Paper))	*	0.333)	*	(1.0 / 255)

			ProcedureReturn	RGBA(Red(Pen)		*	c,
			               	     Green(Pen)	*	c,
			               	     Blue(Pen)		*	c,
			               	     Alpha(Paper))

		EndIf

	EndProcedure
	Procedure.l	Blt_FontCopper(x, y, Pen.l, Paper.l)
		If	Paper	&	$FF000000
			ProcedureReturn	Pen
		EndIf
	EndProcedure

	Procedure	FontColor(ID, Color.l, t$=#Null$)

		Protected	*Ptr.Ascii

		If	IsFontMap(ID)

			With	RS_FontMap()

				If	t$	; colorize chars in t$ only

					*Ptr	=	Uni2Asc(@t$, #C2F_Ucase)

					While	*Ptr\a

						If	*Ptr\a	>=	#MIN_CHR	And	*Ptr\a	<=	#MAX_CHR

							ChangeCurrentElement(\Char(), \ChrID[*Ptr\a - #MIN_CHR])

							StartDrawing(ImageOutput(\Char()\i))
							DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_CustomFilter)
							CustomFilterCallback(@Blt_FontColor())
							Box(0, 0, OutputWidth(), OutputHeight(), Color)
							StopDrawing()

						EndIf

						*Ptr	+	SizeOf(Ascii)

					Wend

				Else	; colorize whole font

					ForEach	\Char()
						StartDrawing(ImageOutput(\Char()\i))
						DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_CustomFilter)
						CustomFilterCallback(@Blt_FontColor())
						Box(0, 0, OutputWidth(), OutputHeight(), Color)
						StopDrawing()
					Next

				EndIf

			EndWith

		EndIf

	EndProcedure
	Procedure	FontCopper(ID, *Memory.Long, Flags=0)

		Protected	*Ptr.Long, i
		Protected	c.f = 1.0 / (*Memory\l - 1)	; Number of gradients

		If	IsFontMap(ID)

			ForEach	RS_FontMap()\Char()

				StartDrawing(ImageOutput(RS_FontMap()\Char()\i))
				DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient|#PB_2DDrawing_CustomFilter)

				If	Flags	&	#C2F_Horizontal
					LinearGradient(0, 0, OutputWidth()-1, 0)
				Else	; default #C2F_Vertical
					LinearGradient(0, 0, 0, OutputHeight()-1)
				EndIf

				*Ptr	=	*Memory	+	SizeOf(Long)	; ptr to number of ABGR-Longs
				For	i	=	0	To	*Memory\l	-	1
					GradientColor(c * i, *Ptr\l)
					*Ptr	+	SizeOf(Long)
				Next

				CustomFilterCallback(@Blt_FontCopper())
				Box(0, 0, OutputWidth(), OutputHeight())

				StopDrawing()

			Next

		EndIf

	EndProcedure
	Procedure	FontShadow(ID, x, y, Alpha=255)

		Protected	Image, w, h, xs, ys

		If	IsFontMap(ID)
			With	RS_FontMap()

				w	=	\ChrW	+	Abs(x)
				h	=	\ChrH	+	Abs(y)

				If	x	>	0
					x	=	0	:	xs	=	w	-	\ChrW
				Else	;x	<	0
					x	=	w	-	\ChrW	;:	xs	=	0
				EndIf

				If	y	>	0
					y	=	0	:	ys	=	h	-	\ChrH
				Else	;y	<	0
					y	=	h	-	\ChrH	;:	ys	=	0
				EndIf

				Alpha << 24

				ForEach	\Char()
					
					CompilerIf	#PB_Compiler_Version	>=	630
						Image	=	CreateImage(#PB_Any, w, h, 32, #PB_Image_TransparentBlack)
					CompilerElse
						Image	=	CreateImage(#PB_Any, w, h, 32, #PB_Image_Transparent)
					CompilerEndIf

					StartDrawing(ImageOutput(Image))

					DrawingMode(#PB_2DDrawing_AllChannels)
					DrawImage(ImageID(\Char()\i), xs, ys)

					DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_CustomFilter)	; Shadow
					CustomFilterCallback(@Blt_FontCopper())
					Box(0, 0, OutputWidth(), OutputHeight(), Alpha)

					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage(ImageID(\Char()\i), x, y)

					StopDrawing()

					FreeImage(\Char()\i)	:	\Char()\i	=	Image

				Next

			EndWith
		EndIf

	EndProcedure
	Procedure	FontBorder(ID, Color.l=#Black)

		Protected	Image

		If	IsFontMap(ID)
			With	RS_FontMap()
				
				If	Color	&	$FF000000	=	#Null	:	Color	|	$FF000000	:	EndIf

				\ChrW	+	2
				\ChrH	+	2

				ForEach	\Char()

					CompilerIf	#PB_Compiler_Version	>=	630
						Image	=	CreateImage(#PB_Any, \ChrW, \ChrH, 32, #PB_Image_TransparentBlack)
					CompilerElse
						Image	=	CreateImage(#PB_Any, \ChrW, \ChrH, 32, #PB_Image_Transparent)
					CompilerEndIf

					StartDrawing(ImageOutput(Image))

					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage(ImageID(\Char()\i), 0, 0)
					DrawImage(ImageID(\Char()\i), 1, 0)
					DrawImage(ImageID(\Char()\i), 2, 0)
 					DrawImage(ImageID(\Char()\i), 0, 1)
 					DrawImage(ImageID(\Char()\i), 1, 1)
 					DrawImage(ImageID(\Char()\i), 2, 1)
 					DrawImage(ImageID(\Char()\i), 0, 2)
 					DrawImage(ImageID(\Char()\i), 1, 2)
 					DrawImage(ImageID(\Char()\i), 2, 2)

					DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_CustomFilter)	; Shadow
					CustomFilterCallback(@Blt_FontCopper())
					Box(0, 0, OutputWidth(), OutputHeight(), Color)

					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage(ImageID(\Char()\i), 1, 1)

					StopDrawing()

					FreeImage(\Char()\i)	:	\Char()\i	=	Image

				Next

			EndWith
		EndIf

	EndProcedure

CompilerEndIf

Procedure	IsFontMap(ID)

	ID	=	ID_Font\ID[ID]

	If	ID
		ChangeCurrentElement(RS_FontMap(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	FontFree(ID)

	With	RS_FontMap()

		If	ID	=	#PB_All

			ForEach	RS_FontMap()
				ForEach	\Char()
					FreeImage(\Char()\i)
				Next
			Next
			
			FillMemory(@ID_Font\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_FontMap())

		Else

			If	IsFontMap(ID)

				ForEach	\Char()
					FreeImage(\Char()\i)
				Next

				DeleteElement(RS_FontMap())

				ID_Font\ID[ID]	=	#Null

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	FontInit(ID, Image, x=0, y=0)

	FontFree(ID)	:	ID_Font\ID[ID]	=	AddElement(RS_FontMap())	; -> @RS_FontMap()

	With	RS_FontMap()

		\TabW	=	3	; Default Tabwidth = 3 x ChrW

		\ChrW	=	ImageWidth(Image)		/	#FontX
		\ChrH	=	ImageHeight(Image)	/	#FontY

		While	ListSize(\Char())	<	#NUM_CHR

			AddElement(\Char())	:	\ChrID[ListIndex(\Char())]	=	@\Char()	; for fast element-change

			\Char()\i	=	GrabImage(Image, #PB_Any,
			         	 	          (ListIndex(\Char()) % #FontX) * \ChrW,
			         	 	          (ListIndex(\Char()) / #FontX) * \ChrH,
			         	 	          \ChrW - x, \ChrH - y)
		Wend

		\ChrW - x
		\ChrH - y

		\GapW	=	\ChrW
		\GapH	=	\ChrH

	EndWith

EndProcedure
Procedure	FontImage(CharID)

	; CharID = 0 - 63
	; Return: ImageNumber of font-character

	With	RS_FontMap()

		ChangeCurrentElement(\Char(), \ChrID[CharID])	; @charelement

		ProcedureReturn	\Char()\i	; Imagenumber

	EndWith

EndProcedure
Procedure	FontSelect(ID)

	; set font for textinit (kein Fehlertest!)
	ChangeCurrentElement(RS_FontMap(), ID_Font\ID[ID])

EndProcedure
Procedure	FontGap(ID, w=0, h=0)

	; w/h = pixels add to x/y line gap (w & h + gap)

	If	IsFontMap(ID)
		With	RS_FontMap()
			\GapW	=	\ChrW	+	w
			\GapH	=	\ChrH	+	h
		EndWith
	EndIf

EndProcedure
Procedure	FontW(ID)
	If	IsFontMap(ID)
		ProcedureReturn	RS_FontMap()\GapW
	EndIf
EndProcedure
Procedure	FontH(ID)
	If	IsFontMap(ID)
		ProcedureReturn	RS_FontMap()\GapH
	EndIf
EndProcedure
Procedure	FontTab(ID, w=3)
	If	IsFontMap(ID)
		RS_FontMap()\TabW	=	w	; #Tab$ -> number of free spaces
	EndIf
EndProcedure
Procedure	FontScale(ID, Ratio.f)

	If	IsFontMap(ID)
		With	RS_FontMap()

			If	Ratio	<>	1.0

				\ChrW	*	Ratio
				\ChrH	*	Ratio

				ForEach	\Char()
					ResizeImage(\Char()\i, \ChrW, \ChrH, C2D\Quality)
				Next

				FontGap(ID)	; set chars to zero x/y gap-distance

			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	FontZoom(ID, w, h)

	If	IsFontMap(ID)
		With	RS_FontMap()

			If	w	<=	#Null	:	w	=	\ChrW	:	EndIf
			If	h	<=	#Null	:	h	=	\ChrH	:	EndIf

			If	\ChrW	<>	w	Or	\ChrH	<>	h

				\ChrW	=	w
				\ChrH	=	h

				ForEach	\Char()
					ResizeImage(\Char()\i, \ChrW, \ChrH, C2D\Quality)
				Next

			EndIf

			FontGap(ID)	; reset gaps

		EndWith
	EndIf

EndProcedure
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAAw
; EnableXP
; CompileSourceDirectory