;**********************************************
;- *** C2D PAGETEXT / 13.05.2024 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_PageText	=	1,2

	XIncludeFile	"C2D_Enums.pbi"
	XIncludeFile	"i_C2D_Font.pbi"

	Global	RS_Page.RS_Page
	Global	NewList	RS_PageText.RS_PageText()

	Declare	PageTextColor(Color.l)
	Declare	PageTextDraw(x.f=0, y.f=0)
	Declare	PageTextFree()
	;Declare	PageTextFxChange(FX)
	Declare	PageTextEffect(Mode, Effect, Speed.f, Delay.f)
	Declare	PageTextID(PageID=-1)
	Declare	PageTextInit(*Memory.Ascii, x, y, w, h, Flags=#Null)
	Declare	PageTextWait(Time, PageID=-1)

CompilerEndIf

Procedure	PageAlignX(*Memory.Ascii, Flags)	; intern x-char-align when new line

	Protected	x

	With	RS_Page

		; flags to align text?
		If	Flags	&	(#C2F_CenterX|#C2F_Center|#C2F_Right|#C2F_Random)

			While	*Memory\a
				Select	*Memory\a

					CompilerIf	#IsC2D_PageText	=	2	; Control-Codes?

					Case	'{'

						Protected	t$, Code, Param.f

						t$	=	#Null$

						While	*Memory\a	And	*Memory\a	<>	'}'	; *** CtrlEnd
							*Memory	+	SizeOf(Ascii)	:	t$	+	Chr(*Memory\a)
						Wend

						Code	=	Val(StringField(t$,	1,	","))	; CtrlCode
						Param	=	ValF(StringField(t$,	2,	","))	; Number.f

						Select	Code
							Case	#C2C_Bitmap
								CompilerIf	#IsC2D_Bitmap
									x	+	BitMapW(Param)	+	Val(StringField(t$, 3, ","))	; XOffset
								CompilerEndIf
							Case	#C2C_Font
								FontSelect(Param)
						EndSelect

					CompilerEndIf

					Case	#LF, '|', #Page_Next
						Break
					Case	#TAB
						x	+	RS_FontMap()\TabW	*	\ChrW
					Default
						x	+	\ChrW

				EndSelect

				*Memory	+	SizeOf(Ascii)

			Wend

			If	Flags	&	#C2F_Right
				x	=	\MaxW	-	x
			ElseIf	Flags	&	#C2F_Random
				x	=	\ClipX	+	Random((\ClipW	-	x) & $FFF)
			Else	; Center
				x	=	\ClipX	+	(\ClipW	-	x)	>>	1
			EndIf

		Else

			x	=	\ClipX	; default left-align

		EndIf

	EndWith

	ProcedureReturn	x

EndProcedure
Procedure	PageAlignY(*Memory.Ascii, Flags)	; intern y-char-align

	Protected	y

	With	RS_Page

		If	Flags	&	(#C2F_CenterY|#C2F_Center|#C2F_Bottom)	; vertical-center/bottom align text?

			y	=	\ChrH

			While	*Memory\a

				Select	*Memory\a

					CompilerIf	#IsC2D_PageText	=	2	; Control-Codes?

					Case	'{'

						Protected	t$, Code, Param.f, h

						t$	=	#Null$

						While	*Memory\a	And	*Memory\a	<>	'}'	; *** CtrlEnd
							*Memory	+	SizeOf(Ascii)	:	t$	+	Chr(*Memory\a)
						Wend

						Code	=	Val(StringField(t$,	1,	","))	; CtrlCode
						Param	=	ValF(StringField(t$,	2,	","))	; Number.f

						Select	Code
							Case	#C2C_Bitmap
								CompilerIf	#IsC2D_Bitmap
									Param	=	y	+	BitMapH(Param)	+	Val(StringField(t$, 4, ","))	; YOffset
									If	h	<	Param
										h	=	Param
									EndIf
								CompilerEndIf
							Case	#C2C_Font
								FontSelect(Param)
							Case	#C2C_MoveY	; vertical move %Param relativ
								Param	=	y	+	C2D\h * 0.01 * Param
								If	y	<	Param
									y	=	Param
								EndIf
						EndSelect

					CompilerEndIf

					Case	#LF, '|'
						y	+	\ChrH
						CompilerIf	#IsC2D_PageText	=	2
							If	h	>	y
								y	=	h
							EndIf
							h	=	0
						CompilerEndIf
					Case	#Page_Next
						Break

				EndSelect

				*Memory	+	SizeOf(Ascii)

			Wend

			CompilerIf	#IsC2D_PageText	=	2
				If	h	>	y	:	y	=	h	:	EndIf
				If	h	:	y	-	\ChrH		:	EndIf
			CompilerEndIf

			If	Flags	&	#C2F_Bottom
				y	=	\MaxH	-	y
			Else
				y	=	\ClipY	+	(\ClipH	-	y)	>>	1
			EndIf

		Else

			y	=	\ClipY	; default top-align

		EndIf

	EndWith

	ProcedureReturn	y

EndProcedure

Procedure	PageTextFxChange(FX)

	With	RS_Page
		If	FX	=	\FX_In

			If	\FX_InRnd	; Random InFX (-1)?
				FX	=	Random(#PFX_Stop - 1, #PFX_Default + 1)
				\FX_In	=	FX
			EndIf

			\FX_Delay	=	\FX_InDelay
			\FX_Speed	=	\FX_InSpeed

		Else

			If	\FX_OutRnd	; Random OutFX (-1)?
				FX	=	Random(#PFX_OutStop - 1, #PFX_OutDefault + 1)
				\FX_Out	=	FX
			EndIf

			\FX_Delay	=	\FX_OutDelay
			\FX_Speed	=	\FX_OutSpeed

		EndIf
	EndWith

	RS_Page\FX	=	FX

	With	RS_PageText()\Char()
		ForEach	RS_PageText()\Char()
			Select	RS_Page\FX

				; ====================================================
				; *** PAGE FX IN *************************************
				; ====================================================
				Case	#PFX_Default		; no fx
					\z	=	255
				Case	#PFX_Fade			; fade all in
					\z	=	0
				Case	#PFX_FadeCenter	; fade center to left/right
					\z	=	Abs(\x - (RS_Page\MaxW + RS_Page\ClipX) * 0.5) * -RS_Page\FX_Speed
				Case	#PFX_FadeChr		; fade random char
					\z	=	(Random(255) / (RS_Page\FX_Delay + 1))	*	-255
				Case	#PFX_FadeLeft		; fade page left to right
					\z	=	(\x / RS_Page\ChrW)	*	-RS_Page\FX_Delay
				Case	#PFX_FadeRight		; fade page right to left
					\z	=	-(RS_Page\MaxW	-	\x)	/	RS_Page\ChrW	*	RS_Page\FX_Delay
				Case	#PFX_FadeStep		; fade chars left to end
					\z	=	(ListIndex(RS_PageText()\Char()) + 1)	*	-RS_Page\FX_Delay
				Case	#PFX_FadeTop		; fade linewise
					\z	=	(\y / RS_Page\ChrH) * RS_Page\FX_Delay	*	-2

				; ====================================================
				; *** PAGE FX OUT (generated from FX PAGE IN) ********
				; ====================================================
				Case	#PFX_OutDefault
					\z	=	0
				Case	#PFX_OutFade
					\z	=	255
				Case	#PFX_OutFadeCenter
					\z	=	Abs(\x - (RS_Page\MaxW + RS_Page\ClipX) * 0.5) * RS_Page\FX_Speed
				Case	#PFX_OutFadeChr
					\z	=	255 + (Random(255) / (RS_Page\FX_Delay + 1)) * 255
				Case	#PFX_OutFadeLeft
					\z	=	(\x / RS_Page\ChrW) * RS_Page\FX_Delay
				Case	#PFX_OutFadeRight
					\z	=	(RS_Page\MaxW	-	\x)	/	RS_Page\ChrW	*	RS_Page\FX_Delay
				Case	#PFX_OutFadeStep
					\z	=	(ListSize(RS_PageText()\Char()) - ListIndex(RS_PageText()\Char()) + 1) * RS_Page\FX_Delay
				Case	#PFX_OutFadeTop
					\z	=	(\y / RS_Page\ChrH) * RS_Page\FX_Delay	*	2

			EndSelect
		Next
	EndWith

EndProcedure

Procedure	PageTextColor(Color.l)
	RS_Page\Color	=	Color	; back-color + alpha-channel
EndProcedure
Procedure	PageTextDraw(x.f=0, y.f=0)

	Protected	Count, i

	With	RS_Page

		ClipOutput(\ClipX, \ClipY, \ClipW, \ClipH)

		If	\Color
			Box(\ClipX, \ClipY, \ClipW, \ClipH, \Color)
		EndIf

		;LineXY(\ClipX + \ClipW * 0.5, \ClipY, \ClipX + \ClipW * 0.5, \ClipY + \ClipH, $FFFFFFFF)
		;LineXY(\ClipX, \ClipY + \ClipH * 0.5, \ClipX + \ClipW, \ClipY + \ClipH * 0.5, $FFFFFFFF)

	EndWith

	If	RS_PageText()\Pause	<	0	; skip page "{2,-1}"?

		RS_Page\Status	=	#True
		RS_Page\Time	=	-1
		RS_Page\FX		=	-1

	Else	; draw pagetext

		ForEach	RS_PageText()\Char()
			With	RS_PageText()\Char()

				; *** display chars
				If	\z	>=	255
					DrawAlphaImage(\i, x + \x, y + \y)
				ElseIf	\z	>	0
					DrawAlphaImage(\i, x + \x, y + \y, \z)
				EndIf

				; *** use fx on every char
				If	RS_Page\Status	=	#False
					Select	RS_Page\FX

						Case	#PFX_Default + 1 To #PFX_Stop - 1

							If	\z	<	255
								\z	+	RS_Page\FX_Speed	:	If	\z	>	255	:	\z	=	255	:	EndIf
							Else
								Count	+	1
							EndIf

						Case	#PFX_OutDefault + 1 To #PFX_OutStop - 1

							If	\z	>	0
								\z	-	RS_Page\FX_Speed	:	If	\z	<	0		:	\z	=	0		:	EndIf
							Else
								Count	+	1
							EndIf

						Default	; #PFX_Default / #PFX_OutDefault (no fx)

							Count	=	ListSize(RS_PageText()\Char())

					EndSelect
				EndIf

			EndWith
		Next

	EndIf

	; *** if page fully displayed (fx finished on all chars)?
	If	RS_Page\Status	=	#False	And	Count	>=	ListSize(RS_PageText()\Char())

		RS_Page\Status	=	#True	; all chars displayed then flag yes!

		If	RS_Page\FX	=	RS_Page\FX_IN	; if page fx_in only than wait pagetime
			RS_Page\Time	=	C2D\Time	+	RS_PageText()\Pause	;Page\Wait
		EndIf

	EndIf

	; *** page fully displayed & wait pagetime over than swap fx_in/fx_out
	If	RS_Page\Status	And	C2D\Time	>	RS_Page\Time

		RS_Page\Status	=	#False

		If	ListSize(RS_PageText())	>	1	; more then #1 page?
			If	RS_Page\FX	=	RS_Page\FX_IN

				PageTextFxChange(RS_Page\FX_OUT)	; page fx_out (no wait of time)

			Else

				If	NextElement(RS_PageText())	=	0	; last page?
					FirstElement(RS_PageText())		; repeat with first page
				EndIf

				PageTextFxChange(RS_Page\FX_IN)	; page fx_in

			EndIf
		EndIf

	EndIf

	UnclipOutput()

	ProcedureReturn	ListIndex(RS_PageText())	; return number of actual page 0..n

EndProcedure
Procedure	PageTextEffect(Mode, Effect, Speed.f, Delay.f)

	With	RS_Page

		If	Mode	; <> 0 -> Page IN

			\FX_In		=	Effect	; Effect #PFX_[]
			\FX_InSpeed	=	Speed		; Fadespeed ms
			\FX_InDelay	=	Delay		; Wait until fadenext ms

			\FX_InRnd	=	Bool(Effect<=#PFX_Random)	; Random Effect?

			; initialize for first call
			\FX			=	\FX_In
			\FX_Speed	=	\FX_InSpeed
			\FX_Delay	=	\FX_InDelay

			PageTextFxChange(\FX_In)

		Else	; = 0 -> Page OUT

			\FX_Out			=	#PFX_OutDefault	+	Effect
			\FX_OutSpeed	=	Speed
			\FX_OutDelay	=	Delay

			\FX_OutRnd	=	Bool(Effect<=#PFX_Random)

		EndIf

	EndWith

EndProcedure
Procedure	PageTextFree()

	ClearList(RS_PageText())
	ClearStructure(@RS_Page, RS_Page)

EndProcedure
Procedure	PageTextID(PageID=-1)

	; PageID	<=	-1	=	Return current page (default)
	; PageID >=	 0	=	Set textpage to PageID

	If	PageID	>=	0	And	PageID	<	ListSize(RS_PageText())
		SelectElement(RS_PageText(), PageID)
	EndIf

	ProcedureReturn	ListIndex(RS_PageText())

EndProcedure
Procedure	PageTextInit(*Memory.Ascii, x, y, w, h, Flags=0)

	*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)

	PageTextFree()	:	AddElement(RS_PageText())	; first page

	With	RS_Page

		\ChrW	=	RS_FontMap()\GapW	; should call FontSelect(#ID) before
		\ChrH	=	RS_FontMap()\GapH

		\ClipX	=	x
		\ClipY	=	y
		\ClipW	=	w
		\ClipH	=	h

		\MaxW		=	\ClipX	+	\ClipW
		\MaxH		=	\ClipY	+	\ClipH

		\FX		=	#PFX_Default		; start with default page in
		\FX_In	=	#PFX_Default		; default page in
		\FX_Out	=	#PFX_OutDefault	; default page out

		If	\Wait	<=	#Null
			\Wait	=	5000	; default milliseconds
		EndIf

		RS_PageText()\Pause	=	\Wait	; first page

		x	=	PageAlignX(*Memory, Flags)	; set first line of align-start-x
		y	=	PageAlignY(*Memory, Flags)	; and y

		While	*Memory\a

			Select	*Memory\a

				Case	#MIN_CHR + 1	To	#MAX_CHR	; +1 = no space

					If	x	>=	\ClipX - \ChrW	And	x	<	\MaxW	And	y	>=	\ClipY - \ChrH	And	y	<	\MaxH

						AddElement(RS_PageText()\Char())

						RS_PageText()\Char()\i	=	ImageID(FontImage(*Memory\a - #MIN_CHR))
						RS_PageText()\Char()\x	=	x
						RS_PageText()\Char()\y	=	y
						RS_PageText()\Char()\z	=	255

					EndIf

					x	+	\ChrW

				Case	#TAB

					x	+	RS_FontMap()\TabW	*	\ChrW

				Case	#LF, '|'	; linefeed

					x	=	PageAlignX(*Memory + SizeOf(Ascii), Flags)
					y	+	\ChrH

				Case	#Page_Next	; '~' = new page

					x	=	PageAlignX(*Memory + SizeOf(Ascii), Flags)	; start X
					y	=	PageAlignY(*Memory + SizeOf(Ascii), Flags)	; start Y

					AddElement(RS_PageText())	; add new page
					RS_PageText()\Pause	=	\Wait

					; -----------------------------------------
					; *** Include Text ControlCodes? "{#,#} ***
					; -----------------------------------------
				CompilerIf	#IsC2D_PageText	=	2

					Case	'{'	; *** CtrlStart {Code,Param.f} / Code=#C2C_[Font,Pause,Bitmap,MoveY]

						Protected	t$, Code, Param.f

						t$	=	#Null$

						While	*Memory\a	And	*Memory\a	<>	'}'	; *** CtrlEnd
							*Memory	+	SizeOf(Ascii)	:	t$	+	Chr(*Memory\a)
						Wend

						Code	=	Val(StringField(t$,	1,	","))	; CtrlCode
						Param	=	ValF(StringField(t$,	2,	","))	; Number.f

						Select	Code
							Case	#C2C_Bitmap
								CompilerIf	#IsC2D_Bitmap
									AddElement(RS_PageText()\Char())
									RS_PageText()\Char()\i	=	BitmapID(Param)
									RS_PageText()\Char()\x	=	x	+	Val(StringField(t$, 3, ","))	; XOffset?
									RS_PageText()\Char()\y	=	y	+	Val(StringField(t$, 4, ","))	; YOffset?
									RS_PageText()\Char()\z	=	255
									x	+	BitMapW(Param)
								CompilerEndIf
							Case	#C2C_Font
								FontSelect(Param)
							Case	#C2C_Pause
								RS_PageText()\Pause	=	Param
							Case	#C2C_MoveY
								y	+	C2D\h * 0.01 * Param	; vertical move %Param relativ
						EndSelect

				CompilerEndIf

				Default

					x	+	\ChrW	; even for space

			EndSelect

			*Memory	+	SizeOf(Ascii)	; don't forget!

		Wend

	EndWith

	FirstElement(RS_PageText())	; set first page

EndProcedure
Procedure	PageTextWait(Time, PageID=-1)

	PushListPosition(RS_PageText())

	If	PageID	<	#Null	; all pages

		RS_Page\Wait	=	Time	; time in ms between page-swap

		ForEach	RS_PageText()
			RS_PageText()\Pause	=	Time
		Next

	ElseIf	PageID	<	ListSize(RS_PageText())

		SelectElement(RS_PageText(), PageID)
		RS_PageText()\Pause	=	Time

	EndIf

	PopListPosition(RS_PageText())

EndProcedure

CompilerIf	0
Procedure	PageTextFxIn(Effect, Speed.f, Delay.f)

	With	RS_Page

		\FX_In		=	Effect	; Effect #PFX_[]
		\FX_InSpeed	=	Speed		; Fadespeed ms
		\FX_InDelay	=	Delay		; Wait until fadenext ms

		\FX_InRnd	=	Bool(Effect<=#PFX_Random)	; < 0 = Random Effect?

		; initialize for first call
		\FX			=	\FX_In
		\FX_Speed	=	\FX_InSpeed
		\FX_Delay	=	\FX_InDelay

		PageTextFxChange(\FX_In)

	EndWith

EndProcedure
Procedure	PageTextFxOut(Effect, Speed.f, Delay.f)

	With	RS_Page

		\FX_Out			=	#PFX_OutDefault	+	Effect
		\FX_OutSpeed	=	Speed
		\FX_OutDelay	=	Delay

		\FX_OutRnd	=	Bool(Effect<=#PFX_Random)

	EndWith

EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = AAAw
; CompileSourceDirectory