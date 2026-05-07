;**********************************************
;- *** C2D SCROLLTEXT / 12.03.2020 ************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	; #IsC2D_ScrollText = 1,2

	XIncludeFile	"C2D_Enums.pbi"

	Global	ID_ScrollText.C2D_ID
	Global	NewList	RS_ScrollText.RS_ScrollText()

	Declare	IsScrollText(ID)
	Declare	ScrollTextDraw(ID, y.f, Alpha=255)
	Declare	ScrollTextFree(ID)
	Declare	ScrollTextH(ID)
	Declare	ScrollTextInit(ID, *Memory.Ascii)
	Declare	ScrollTextSinus(ID, Height.f=0, Frequency.f=0, Speed.f=0)
	Declare	ScrollTextSpeed(ID, Speed.f)
	Declare	ScrollTextW(ID)

	Declare	ScrollTextPos(ID, Index=#Null)

CompilerEndIf

Procedure	IsScrollText(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_ScrollText\ID[ID]

	If	ID
		ChangeCurrentElement(RS_ScrollText(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	ScrollTextFree(ID)

	If	ID	=	#PB_All
		
		FillMemory(@ID_ScrollText\ID, #MAX_ID	*	SizeOf(Integer))
		ClearList(RS_ScrollText())

	Else

		If	IsScrollText(ID)
			DeleteElement(RS_ScrollText())
			ID_ScrollText\ID[ID]	=	#Null
		EndIf

	EndIf

EndProcedure
Procedure	ScrollTextInit(ID, *Memory.Ascii)

	*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)

	ScrollTextFree(ID)	:	ID_ScrollText\ID[ID]	=	AddElement(RS_ScrollText())	; @RS_ScrollText()

	With	RS_ScrollText()

		ScrollTextSpeed(ID, 1.0)

		; Default FontMap by called FontSelect()
		\ChrW	=	RS_FontMap()\GapW	; CharWidth
		\ChrH	=	RS_FontMap()\GapH	; CharHeight

		\MinW	=	\ChrW	; left out
		\x		=	C2D\w	; start on right side of canvas

		While	*Memory\a

			Select	*Memory\a

				Case	#MIN_CHR + 1	To	#MAX_CHR	; +1 = no space

					AddElement(\Char())

					\Char()\i	=	ImageID(FontImage(*Memory\a - #MIN_CHR))
					\Char()\x	=	\MaxW
					\Char()\y	=	\y		; vertical %position by {#C2C_Y, param}

					; CenterY if higher/smaller font used by {#C2C_Font,param}
					If	RS_FontMap()\GapH	<>	\ChrH
						\Char()\y	+	(\ChrH	-	RS_FontMap()\GapH)	*	0.5
					EndIf

					\MaxW	+	\ChrW

				Case	#TAB

					\MaxW	+	RS_FontMap()\TabW	*	\ChrW

				; ****************************************
				; *** Included Flags for ControlCodes? ***
				; ****************************************
				CompilerIf	#IsC2D_ScrollText	=	2

					Case	'{'	; *** Flag-CtrlStart {Code,Param.f}

						Protected	t$=#Null$, Code, Param.f, Center

						While	*Memory\a	And	*Memory\a	<>	'}'	; *** Flag-CtrlEnd = "}"
							*Memory	+	SizeOf(Ascii)	:	t$	+	Chr(*Memory\a)
						Wend

						Code	=	ValF(StringField(t$,	1,	","))	; #C2C_(Speed,Pause,Font..)
						Param	=	ValF(StringField(t$,	2,	","))	; Number.f

						Select	Code

							Case	#C2C_Pause, #C2C_Speed, #C2C_Return

								If	Param	<=	#Null
									If			Code	=	#C2C_Pause	:	Param	=	1000	; Default Pause 1 sec.
									ElseIf	Code	=	#C2C_Speed	:	Param	=	1		; Default Speed 1 pix.
									EndIf
								EndIf

								LastElement(\Ctrl())	; always add fx at last in list

								AddElement(\Ctrl())

								\Ctrl()\State	=	#True	; on! for first call
								\Ctrl()\Code	=	Code
								\Ctrl()\Param	=	Param

								\Ctrl()\PosX	=	C2D\w	-	\MaxW	; charpos to pixelpos

								FirstElement(\Ctrl())	; always reset to first fx in list

							Case	#C2C_Font

								FontSelect(Param)

								\ChrW	=	FontW(Param)	; New FontCharWidth!

								If	\MinW	<	\ChrW	:	\MinW	=	\ChrW	:	EndIf	; Left hide?

							Case	#C2C_Bitmap

								CompilerIf	#IsC2D_Bitmap

									AddElement(RS_ScrollText()\Char())

									\Char()\i	=	BitmapID(Param)
									\Char()\x	=	\MaxW
									\Char()\y	=	(\ChrH	-	BitmapH(Param))	*	0.5

									If	\MinW	<	BitmapW(Param)	:	\MinW	=	BitmapW(Param)	:	EndIf	; Left hide?

									\MaxW	+	BitmapW(Param)

								CompilerEndIf
								
							Case	#C2C_Pixel3D
								
								CompilerIf	#IsC2D_Pixel3D

									AddElement(RS_ScrollText()\Char())

									\Char()\i	=	Param
									\Char()\x	=	\MaxW	+	\ChrW	*	0.5
									\Char()\y	=	\ChrH	*	0.5

									\MaxW	+	\ChrW

								CompilerEndIf

							Case	#C2C_Space

								If	Param	<=	#Null	:	Param	=	100	:	EndIf

								\MaxW	+	C2D\w	*	0.01	*	Param	; add %space (pixel-exact)

							Case	#C2C_Center

								If	Center	; CenterEnd{5,offset=0} & reset
									\MaxW		+	(C2D\w - (\MaxW - Center)) * 0.5 + C2D\w * 0.01 * Param
									Center	=	#Null
								Else			; {5}CenterStart
									Center	=	\MaxW	|	1	; 1 -> if MaxW = 0
								EndIf

							Case	#C2C_MoveY

								\y	=	C2D\h * 0.01 * Param	; vertical move %Param from ScrollerStartY

						EndSelect

					CompilerEndIf

				Default

					\MaxW	+	\ChrW	; all unused signs

			EndSelect

			*Memory	+	SizeOf(Ascii)	; don't forget, next char!

		Wend

		\MinW	*	-1	; negate for left out
		\MaxW	*	-1	; negate total-length for faster restart

	EndWith

EndProcedure
Procedure	ScrollTextDraw(ID, y.f, Alpha=255)

	Static	x.f, sin_y.f

	ChangeCurrentElement(RS_ScrollText(), ID_ScrollText\ID[ID])

	With	RS_ScrollText()

		; {#C2C_Pause}?
		CompilerIf	#IsC2D_ScrollText	=	2

			Protected	RetVal

			If	\Ctrl_Pause	<	C2D\Time
				\x	-	\Speed
			EndIf

		CompilerElse
			\x	-	\Speed
		CompilerEndIf

		; *** restart scroller?
		If	\x	<	\MaxW

			\x	=	C2D\w

			; {#C2C_(Code)} Reactivate ControlCodes?
			CompilerIf	#IsC2D_ScrollText	=	2
				If	ListSize(\Ctrl())		; reset textfx
					ForEach	\Ctrl()
						\Ctrl()\State	=	#True
					Next
					FirstElement(\Ctrl())
				EndIf
			CompilerEndIf

			ProcedureReturn	#C2F_End	; textend (-1)

		EndIf

		; *** draw scroller + fx?
		ForEach	\Char()

			x	=	\x	+	\Char()\x

			If	x	>=	C2D\w	; > right out?
				Break
			ElseIf	x	>	\MinW	; > left out?

				sin_y	=	y

				If	\SinHeight	; sinustext? set in ScrollTextSinY()
					sin_y	+	Sin((x + C2D\Time * \SinSpeed) * \SinFreq) * \SinHeight
				EndIf
				
				CompilerIf	#IsC2D_ScrollText	=	2	And	#IsC2D_Pixel3D
					If	\Char()\i	>=	#Null	And	\Char()\i	<=	#NUM_CHR			; max. 64
						Pixel3DDraw(\Char()\i, x - C2D\cx, \Char()\y + sin_y - C2D\cy, Alpha)	; draw pixel3d, \i = ID
					Else
						DrawAlphaImage(\Char()\i, x, \Char()\y + sin_y, Alpha)	; draw font-char, \i = handle
					EndIf
				CompilerElse
					DrawAlphaImage(\Char()\i, x, \Char()\y + sin_y, Alpha)		; draw font-char, \i = handle
				CompilerEndIf

			EndIf

			;==============================================
			; *** {Code,Param.f} check of ControlCodes? ***
			;==============================================
			CompilerIf	#IsC2D_ScrollText	=	2
				If	ListSize(\Ctrl())	And	\Ctrl()\State	And	x	<=	\Ctrl()\PosX	; check actual FX-char-index

					Select	\Ctrl()\Code

						Case	#C2C_Pause	; pause scrolling by param-time in ms
							\x	=	\Ctrl()\PosX
							\Ctrl_Pause	=	C2D\Time	+	\Ctrl()\Param

						Case	#C2C_Speed	; speed up/down by param
							\Speed	=	\Ctrl_Speed	*	\Ctrl()\Param

						Case	#C2C_Return	; return param for private use
							RetVal	=	\Ctrl()\Param

					EndSelect

					; current fx off & goto next fx
					\Ctrl()\State	=	#False	:	NextElement(\Ctrl())

				EndIf
			CompilerEndIf

		Next

	EndWith

	; {#C2C_Return,Parm} for private use
	CompilerIf	#IsC2D_ScrollText	=	2
		ProcedureReturn	RetVal
	CompilerEndIf

EndProcedure
Procedure	ScrollTextSinus(ID, Height.f=0, Frequency.f=0, Speed.f=0)

	If	IsScrollText(ID)
		With	RS_ScrollText()

			\SinHeight	=	Height	; also to check sin on/off

			If	Frequency	:	\SinFreq		=	Frequency	*	0.001	:	EndIf
			If	Speed			:	\SinSpeed	=	Speed			*	0.010	:	EndIf

		EndWith
	EndIf

EndProcedure
Procedure	ScrollTextSpeed(ID, Speed.f)

	If	IsScrollText(ID)

		RS_ScrollText()\Speed	=	Abs(Speed)

		CompilerIf	#IsC2D_ScrollText	=	2
			RS_ScrollText()\Ctrl_Speed	=	Abs(Speed)
		CompilerEndIf

	EndIf

EndProcedure
Procedure	ScrollTextH(ID)

	If	IsScrollText(ID)
		ProcedureReturn	RS_ScrollText()\ChrH
	EndIf

EndProcedure
Procedure	ScrollTextW(ID)

	If	IsScrollText(ID)
		ProcedureReturn	Abs(RS_ScrollText()\MaxW)
	EndIf

EndProcedure

CompilerIf	#IsC2D_ScrollText	=	2	; {Code,Param.f}
	Procedure	ScrollTextPos(ID, Index=#Null)

		; return and/or set char-position

		If	IsScrollText(ID)
			With	RS_ScrollText()

				If	Index	>	#Null

					\x	=	C2D\w - (Index - 1) * \ChrW

					; must turn off TextFX (pause!/speed) & set FX element to new position
					ForEach	\Ctrl()
						If	\x	<=	\Ctrl()\PosX
							\Ctrl()\State	=	#False
						Else
							Break
						EndIf
					Next

				EndIf

				ProcedureReturn	Abs((\x - C2D\w) / \ChrW)

			EndWith
		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = AAA9
; EnableXP
; CompileSourceDirectory