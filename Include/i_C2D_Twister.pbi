;**********************************************
;- *** C2D Twister / 02.10.2021 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Twister	=	1

	IncludeFile	"C2D_Macros.pbi"
	IncludeFile	"C2D_Enums.pbi"

CompilerEndIf

Macro	MA_TSIN(ANGLE)	:	Sin((ANGLE) * (#PI/180))	:	EndMacro
Macro	MA_TCOS(ANGLE)	:	Cos((ANGLE) * (#PI/180))	:	EndMacro

Procedure	IsTwister(ID)

	ID	=	ID_Twister\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Twister(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	TwisterFree(ID)

	With	RS_Twister()

		If	ID	<=	#PB_All

			FillMemory(@ID_Twister\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Twister())

		Else

			If	IsTwister(ID)
				DeleteElement(RS_Twister())
				ID_Twister\ID[ID]	=	#Null
			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	TwisterInit(ID, Size, Speed.f, Amplitude.f, Mode=#C2F_VERTICAL, w=0, h=0)

	TwisterFree(ID)	:	ID_Twister\ID[ID]	=	AddElement(RS_Twister())	; @RS_Twister()

	With	RS_Twister()

		\Size			=	Size
		\Speed		=	Speed
		\Amplitude	=	Amplitude

		\Mode	=	Mode
		\w		=	w
		\h		=	h

		If	\Mode	&	#C2F_HORIZONTAL
			If	\w	<=	#Null	:	\w	=	C2D\w	:	EndIf
			\Loop	=	\w	-	1
			\h		=	\Size	<<	1
		Else
			If	\h	<=	#Null	:	\h	=	C2D\h	:	EndIf
			\Loop	=	\h	-	1
			\w		=	\Size	<<	1
		EndIf

		\CX	=	\w	*	0.5
		\CY	=	\h	*	0.5

		\RGB0	=	$FF000000|#Magenta
		\RGB1	=	$FF000000|#Blue
		\RGB2	=	$FF000000|#Green
		\RGB3	=	$FF000000|#Yellow

	EndWith

EndProcedure
Procedure	TwisterDraw(ID, x.f, y.f)

	Protected	i, p

	ChangeCurrentElement(RS_Twister(), ID_Twister\ID[ID])

	With	RS_Twister()

		x - \CX	:	y - \CY

		While	i	<=	\Loop

			p	=	i	/	\Amplitude	+	\Angle

							\p0	=	MA_TSIN(p)	* \Size	+	\Size
			p	+	90	:	\p1	=	MA_TSIN(p)	* \Size	+	\Size
			p	+	90	:	\p2	=	MA_TSIN(p)	* \Size	+	\Size
			p	+	90	:	\p3	=	MA_TSIN(p)	* \Size	+	\Size

			p	=	i

			If	\Mode	&	#C2F_HORIZONTAL
				p	+	x
				If \p0 < \p1	:	LineXY(p, y + \p0, p, y + \p1, \RGB0)	:	EndIf
				If \p1 < \p2	:	LineXY(p, y + \p1, p, y + \p2, \RGB1)	:	EndIf
				If \p2 < \p3	:	LineXY(p, y + \p2, p, y + \p3, \RGB2)	:	EndIf
				If \p3 < \p0	:	LineXY(p, y + \p3, p, y + \p0, \RGB3)	:	EndIf
			Else
				p	+	y
				If \p0 < \p1	:	LineXY(x + \p0, p, x + \p1, p, \RGB0)	:	EndIf
				If \p1 < \p2	:	LineXY(x + \p1, p, x + \p2, p, \RGB1)	:	EndIf
				If \p2 < \p3	:	LineXY(x + \p2, p, x + \p3, p, \RGB2)	:	EndIf
				If \p3 < \p0	:	LineXY(x + \p3, p, x + \p0, p, \RGB3)	:	EndIf
			EndIf

			i	+	1

		Wend

		\Angle	+	\Speed

	EndWith

EndProcedure
Procedure	TwisterAlpha(ID, Alpha=$FF)

	If	IsTwister(ID)

		Alpha	<<	24

		With	RS_Twister()
			\RGB0	&	$00FFFFFF	|	Alpha
			\RGB1	&	$00FFFFFF	|	Alpha
			\RGB2	&	$00FFFFFF	|	Alpha
			\RGB3	&	$00FFFFFF	|	Alpha
		EndWith

	EndIf

EndProcedure
Procedure	TwisterColor(ID, RGB0.l=0, RGB1.l=0, RGB2.l=0, RGB3.l=0)

	If	IsTwister(ID)
		With	RS_Twister()
			If	RGB0	:	\RGB0	=	RGB0	:	EndIf	; #Magenta
			If	RGB1	:	\RGB1	=	RGB1	:	EndIf	; #Blue
			If	RGB2	:	\RGB2	=	RGB2	:	EndIf	; #Green
			If	RGB3	:	\RGB3	=	RGB3	:	EndIf	; #Yellow
		EndWith
	EndIf

EndProcedure
Procedure	TwisterCopy(ID, x.f, y.f)

	If	IsTwister(ID)
		With	RS_Twister()

			Protected	a.f	=	\Angle

			\Angle	-	\Speed

			TwisterDraw(ID, x.f, y.f)

			\Angle	=	a

		EndWith
	EndIf

EndProcedure
Procedure	TwisterFX(ID, Speed.f, Amplitude.f)

	If	IsTwister(ID)
		With	RS_Twister()
			\Speed		=	Speed
			\Amplitude	=	Amplitude
		EndWith
	EndIf

EndProcedure

CompilerIf	#Null	; old
Procedure	TwisterColorize(ID, Color.l)

	Protected	a.a	=	(Color	&	$FF000000)	>>	24
	Protected	b.a	=	(Color	&	$00FF0000)	>>	16
	Protected	g.a	=	(Color	&	$0000FF00)	>>	8
	Protected	r.a	=	Color		&	$000000FF

	If	IsTwister(ID)
		With	RS_Twister()
			\RGB0	=	RGBA(r * 0.55, g * 0.55, b * 0.55, a)
			\RGB1	=	RGBA(r * 0.66, g * 0.66, b * 0.66, a)
			\RGB2	=	RGBA(r * 0.83, g * 0.83, b * 0.83, a)
			\RGB3	=	Color
		EndWith
	EndIf

EndProcedure
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = GA+
; CompileSourceDirectory