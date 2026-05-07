;**********************************************
;- *** C2D MOVETEXT / 15.01.2020 **************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Global	ID_MoveText.C2D_ID
	Global	NewList	RS_MoveText.RS_MoveText()
	
	Declare	IsMoveText(ID)
	Declare	MoveTextColor(ID, Color.l)
	Declare	MoveTextDraw(ID, Alpha=255)
	Declare	MoveTextFree(ID)
	Declare	MoveTextH(ID, Flags=#Null)
	Declare	MoveTextInit(ID, *Memory.Ascii, x, y, w, h, Flags=#Null)
	Declare	MoveTextSpeed(ID, Speed.f)
	Declare	MoveTextW(ID)
	Declare	MoveTextY(ID, y.f)

CompilerEndIf

Procedure	MoveAlignX(*Memory.Ascii, Flags)	; intern x-char-align when new line
	
	Protected	x

	With	RS_MoveText()

		If	Flags	&	(#C2F_CenterX|#C2F_Center|#C2F_Right|#C2F_Random)	; horizontal-center/right align text?

			While	*Memory\a
				
				Select	*Memory\a
					Case	#LF, '|', #Page_Next
						Break
					Case	#TAB
						x	+	RS_FontMap()\TabW

					CompilerIf	#IsC2D_MoveText	=	2
					Case	'{'	; *** Flag-CtrlStart {Code,Param.f}
						While	*Memory\a	And	*Memory\a	<>	'}'	; *** Flag-CtrlEnd = "}"
							*Memory	+	SizeOf(Ascii)
						Wend
					CompilerEndIf
					
					Default
						x	+	1
				EndSelect
				
				*Memory	+	SizeOf(Ascii)
				
			Wend
			
			x	*	\ChrW

			If	Flags	&	#C2F_Right
				x	=	\MaxW	-	x
			ElseIf	Flags	&	#C2F_Random
				x	=	\ClipX	+	Random((\ClipW	-	x) & $FFF)
			Else	; Center
				x	=	\MaxW	- (\ClipW	+	x)	>>	1
			EndIf

		Else

			x	=	\ClipX	; default left-align

		EndIf

	EndWith

	ProcedureReturn	x
	
EndProcedure

Procedure	IsMoveText(ID)

	ID	=	ID_MoveText\ID[ID]

	If	ID
		ChangeCurrentElement(RS_MoveText(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	MoveTextFree(ID)
	
	If	ID	=	#PB_All
		
		FillMemory(@ID_MoveText\ID, #MAX_ID	*	SizeOf(Integer))
		ClearList(RS_MoveText())
		
	Else
		
		If	IsMoveText(ID)
			DeleteElement(RS_MoveText())
			ID_MoveText\ID[ID]	=	#Null
		EndIf
		
	EndIf
	
EndProcedure
Procedure	MoveTextInit(ID, *Memory.Ascii, x, y, w, h, Flags=#Null)
	
	*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)
	
	MoveTextFree(ID)	:	ID_MoveText\ID[ID]	=	AddElement(RS_MoveText())	; @RS_MoveText()
	
	With	RS_MoveText()
		
		\Speed	=	-0.25	; default speed & up
		
		\ChrW		=	RS_FontMap()\GapW
		\ChrH		=	RS_FontMap()\GapH	; scrolltext height
		
		\ClipX	=	x	; x-start
		\ClipY	=	y	; y-start
		\ClipW	=	w	; w-width
		\ClipH	=	h	; h-height
		
		\v_Start	=	\ClipY	-	\ChrH		; vertical start of text
		\v_End	=	\ClipY	+	\ClipH	; vertical end of text
		
		\MaxW		=	\ClipX	+	\ClipW
		\MaxH		=	\v_End
		
		x	=	MoveAlignX(*Memory, Flags)	; set first line of align-start-x
		
		While	*Memory\a
			
			Select	*Memory\a
					
				Case	#MIN_CHR + 1	To	#MAX_CHR	; +1 = no space
					If	x	>=	\ClipX	And	x	<=	\MaxW	-	\ChrW
						
						AddElement(RS_MoveText()\Char())
						
						\Char()\i	=	ImageID(FontImage(*Memory\a - #MIN_CHR))
						\Char()\x	=	x
						\Char()\y	=	\MaxH
						
					EndIf
					
					x	+	\ChrW
					
				Case	#TAB
					x	+	RS_FontMap()\TabW	*	\ChrW

				Case	#LF, '|', #Page_Next
					x		=	MoveAlignX(*Memory + SizeOf(Ascii), Flags)
					\MaxH	+	\ChrH

				; *****************************************************************
				; *** Included Flags for ControlCodes? #FC_Font {1,#Font} only! ***
				; *****************************************************************
				CompilerIf	#IsC2D_MoveText	=	2
				Case	'{'	; *** Flag-CtrlStart {Code,Param.f}
					Protected	t$=#Null$, Code, Param.f
					While	*Memory\a	And	*Memory\a	<>	'}'	; *** Flag-CtrlEnd = "}"
						*Memory	+	SizeOf(Ascii)	:	t$	+	Chr(*Memory\a)
					Wend
					Code	=	ValF(StringField(t$,	1,	","))	; #FC_(Speed,Pause,Font..)
					Param	=	ValF(StringField(t$,	2,	","))	; Number.f
					Select	Code
						Case	#C2C_Font	:	FontSelect(Param)
					EndSelect
				CompilerEndIf

				Default
					x	+	\ChrW	; even for space
					
			EndSelect

			*Memory	+	SizeOf(Ascii)	; don't forget!
			
		Wend
		
		\MinH	=	-(\MaxH	-	\ClipY	+	\ChrH)
		
	EndWith
	
EndProcedure
Procedure	MoveTextDraw(ID, Alpha=255)

	Static	y.f
		
	ChangeCurrentElement(RS_MoveText(), ID_MoveText\ID[ID])
	
	With	RS_MoveText()
		
		If	\Color
			Box(\ClipX, \ClipY, \ClipW, \ClipH, \Color)
		EndIf
		
		\y	+	\Speed
		
		; Restart?
		If	\Speed	<	#Null	And	\y	<	\MinH			; up
			\y	=	#Null
			ProcedureReturn	#C2F_End
		ElseIf	\Speed	>	#Null	And	\y	>=	#Null	; down
			\y	=	-(\MaxH	+	\ChrH)	+	\ClipY
			ProcedureReturn	#C2F_End
		EndIf
		
		ClipOutput(\ClipX, \ClipY, \ClipW, \ClipH)
		
		ForEach	\Char()
			
			y	=	\Char()\y	+	\y
			
			If	y	>=	\v_End
				Break
			ElseIf	y	>	\v_Start
				DrawAlphaImage(\Char()\i, \Char()\x, y, Alpha)
			EndIf
			
		Next
		
		UnclipOutput()
		
		ProcedureReturn	\y	;/	\ChrH
		
	EndWith

EndProcedure
Procedure	MoveTextSpeed(ID, Speed.f)
	If	IsMoveText(ID)
		RS_MoveText()\Speed	=	Speed
	EndIf
EndProcedure
Procedure	MoveTextH(ID, Flags=#Null)
	
	; full pixelheight or clipheight
	
	If	IsMoveText(ID)
		With	RS_MoveText()
			
			If	Flags
				ProcedureReturn	(\MaxH	-	\v_End	+	\ChrH)
			EndIf
			
			ProcedureReturn	\ClipH
			
		EndWith
	EndIf
	
EndProcedure
Procedure	MoveTextW(ID)
	If	IsMoveText(ID)
		ProcedureReturn	RS_MoveText()\ClipW
	EndIf
EndProcedure
Procedure	MoveTextY(ID, y.f)
	If	IsMoveText(ID)
		RS_MoveText()\y	=	y
	EndIf
EndProcedure
Procedure	MoveTextColor(ID, Color.l)
	If	IsMoveText(ID)
		RS_MoveText()\Color	=	Color	; set back-color + alpha-channel
	EndIf
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = AA+
; CompileSourceDirectory