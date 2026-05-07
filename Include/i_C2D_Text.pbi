;**********************************************
;- *** C2D TEXT / 08.03.2020 ******************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_Text	=	1
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Global	ID_Text.C2D_ID
	Global	NewList	RS_Text.RS_Text()
	
	Declare	IsText(ID)
	Declare	TextDraw(ID, x.f, y.f, Alpha=255, Flags=#Null)
	Declare	TextFree(ID)
	Declare	TextH(ID)
	Declare	TextInit(ID, *Memory.Ascii, Flags=#Null)
	Declare	TextStringDraw(x.f, y.f, Text$, Alpha=255)
	Declare	TextW(ID)

CompilerEndIf

Procedure	TextAlignX(*Memory.Ascii)	; intern x-char-align when new line
	
	Protected	x
	
	While	*Memory\a
		
		Select	*Memory\a
			Case	#LF, '|'
				Break
			Case	#TAB
				x	+	RS_FontMap()\TabW
			Default
				x	+	1
		EndSelect
		
		*Memory	+	SizeOf(Ascii)
		
	Wend
	
	x	=	(C2D\w	-	x	*	RS_FontMap()\GapW)	>>	1
	
	ProcedureReturn	x
	
EndProcedure

Procedure	IsText(ID)

	ID	=	ID_Text\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Text(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	TextFree(ID)
	With	RS_Text()
		If	ID	=	#PB_All
			FillMemory(@ID_Text\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Text())
		Else
			If	IsText(ID)
				DeleteElement(RS_Text())
				ID_Text\ID[ID]	=	#Null
			EndIf
		EndIf
	EndWith
EndProcedure
Procedure	TextInit(ID, *Memory.Ascii, Flags=#Null)

	Protected	x, y
	
	*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)
	
	TextFree(ID)	:	ID_Text\ID[ID]	=	AddElement(RS_Text())	; @RS_Text()
	
	With	RS_Text()
		
		\ChrW	=	RS_FontMap()\GapW
		\ChrH	=	RS_FontMap()\GapH	; scrolltext height
		
		If	Flags	&	(#C2F_CenterX|#C2F_Center)
			x	=	TextAlignX(*Memory)
		EndIf
		
		While	*Memory\a
			
			Select	*Memory\a
					
				Case	#MIN_CHR + 1	To	#MAX_CHR
					AddElement(\Char())
					
					\Char()\i	=	ImageID(FontImage(*Memory\a - #MIN_CHR))
					\Char()\x	=	x
					\Char()\y	=	y
					
					x	+	\ChrW
					
				Case	#TAB
					x	+	RS_FontMap()\TabW	*	\ChrW
					
				Case	#LF, '|'
					
					If	Flags	&	(#C2F_CenterX|#C2F_Center)
						x	=	TextAlignX(*Memory + SizeOf(Ascii))
					Else
						x	=	0
					EndIf

					y	+	\ChrH
					
				Default
					x	+	\ChrW
					
			EndSelect

			*Memory	+	SizeOf(Ascii)	; don't forget!
			
		Wend
		
		; get total width/height of text-block
		ForEach	\Char()
			If	\Char()\x	>	\w	:	\w	=	\Char()\x	:	EndIf
			If	\Char()\y	>	\h	:	\h	=	\Char()\y	:	EndIf
		Next
		
		\w	+	\ChrW
		\h	+	\ChrH
		
	EndWith

EndProcedure
Procedure	TextW(ID)
	If	IsText(ID)
		ProcedureReturn	RS_Text()\w
	EndIf
EndProcedure
Procedure	TextH(ID)
	If	IsText(ID)
		ProcedureReturn	RS_Text()\h
	EndIf
EndProcedure
Procedure	TextDraw(ID, x.f, y.f, Alpha=255, Flags=#Null)
	
	Static	x_pos.f, y_pos.f

	ChangeCurrentElement(RS_Text(), ID_Text\ID[ID])
	
	With	RS_Text()
		
		If	Flags
			If			Flags	&	(#C2F_CenterX|#C2F_Center)	:	x	+	(C2D\w	-	\w)	*	0.5
			ElseIf	Flags	&	#C2F_Right							:	x	+	(C2D\w	-	\w)
			EndIf
			If			Flags	&	(#C2F_CenterY|#C2F_Center)	:	y	+	(C2D\h	-	\h)	*	0.5
			ElseIf	Flags	&	#C2F_Bottom						:	y	+	(C2D\h	-	\h)
			EndIf
		EndIf
		
		ForEach	\Char()
			
			x_pos	=	x	+	\Char()\x
			y_pos	=	y	+	\Char()\y
			
			;If	x_pos	>	-\ChrW	And	x_pos	<	C2D\w	And	y_pos	>	-\ChrH	And	y_pos	<	C2D\h
			If	Alpha	>=	255
				DrawAlphaImage(\Char()\i, x_pos, y_pos)
			ElseIf	Alpha	>	0
				DrawAlphaImage(\Char()\i, x_pos, y_pos, Alpha)
			EndIf
			;EndIf
			
		Next
		
	EndWith

EndProcedure
Procedure	TextStringDraw(x.f, y.f, Text$, Alpha=255)

	Static	*Ptr.Ascii
	Static	x_pos.f
	
	*Ptr	=	Uni2Asc(@Text$, #C2F_Ucase)
	x_pos	=	x

	While	*Ptr\a

		Select	*Ptr\a

			Case	#MIN_CHR + 1	To	#MAX_CHR

				DrawAlphaImage(ImageID(FontImage(*Ptr\a - #MIN_CHR)), x_pos, y, Alpha)

				x_pos	+	RS_FontMap()\GapW

			Case	#LF, '|'

				x_pos	=	x
				y	+	RS_FontMap()\GapH

			Case	#TAB

				x_pos	+	RS_FontMap()\GapW	*	RS_FontMap()\TabW

			Default

				x_pos	+	RS_FontMap()\GapW

		EndSelect

		*Ptr	+	SizeOf(Ascii)

	Wend

EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A5
; EnableXP
; CompileSourceDirectory