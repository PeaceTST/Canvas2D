;**********************************************
;- *** C2D FLATBAR / 01.04.2020 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_FlatBar	=	1
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Global	ID_FlatBar.C2D_ID
	Global	NewList	RS_FlatBar.RS_FlatBar()
	
	Declare	IsFlatBar(ID)
	Declare	FlatBarDraw(ID, y.f, Alpha=255)
	Declare	FlatBarFree(ID)
	Declare	FlatBarH(ID)
	Declare	FlatBarImage(ID)
	Declare	FlatBarInit(ID, h, Color.l, Frame=1)
	Declare	FlatBarText(ID, *Memory.Ascii, Flags=#C2F_Center)
	
CompilerEndIf

Procedure	IsFlatBar(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_FlatBar\ID[ID]

	If	ID
		ChangeCurrentElement(RS_FlatBar(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	FlatBarFree(ID)

	With	RS_FlatBar()

		If	ID	<=	#PB_All

			ForEach	RS_FlatBar()
				If	\Image	And	IsImage(\Image)
					FreeImage(\Image)
				EndIf
			Next

			FillMemory(@ID_FlatBar\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_FlatBar())

		Else
			
			If	IsFlatBar(ID)
				
				ID_FlatBar\ID[ID]	=	#Null
				
				If	\Image	And	IsImage(\Image)
					FreeImage(\Image)
				EndIf

				DeleteElement(RS_FlatBar())
				
			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	FlatBarInit(ID, h, Color.l, Frame=1)

	FlatBarFree(ID)	:	ID_FlatBar\ID[ID]	=	AddElement(RS_FlatBar())	; @RS_FlatBar()

	With	RS_FlatBar()

		\Color	=	Color
		\Frame	=	Frame
		\h			=	h

		\Image	=	CreateImage(#PB_Any, C2D\w, \h, 32)

		StartDrawing(ImageOutput(\Image))
		DrawingMode(#PB_2DDrawing_AlphaBlend)

		Box(0, 0, OutputWidth(), OutputHeight(), $FF000000|\Color)

		Box(0,	0,			OutputWidth(), \Frame, $70FFFFFF)
		Box(0,	\Frame,	OutputWidth(), \Frame, $50FFFFFF)

		Box(0, OutputHeight() - \Frame * 2,	OutputWidth(), \Frame, $50000000)
		Box(0, OutputHeight() - \Frame,		OutputWidth(), \Frame, $70000000)

		StopDrawing()
		
		\hImage	=	ImageID(\Image)	; for faster drawing

	EndWith

EndProcedure
Procedure	FlatBarImage(ID)
	
	; return #Image of FlarBar or error = 0
	
	If	IsFlatBar(ID)
		ProcedureReturn	RS_FlatBar()\Image
	EndIf
	
EndProcedure
Procedure	FlatBarDraw(ID, y.f, Alpha=255)
	ChangeCurrentElement(RS_FlatBar(), ID_FlatBar\ID[ID])
	DrawAlphaImage(RS_FlatBar()\hImage, 0, y, Alpha)
EndProcedure
Procedure	FlatBarH(ID)
	If	IsFlatBar(ID)
		ProcedureReturn	RS_FlatBar()\h
	EndIf
EndProcedure

CompilerIf	#IsC2D_Font
	Procedure	FlatBarText(ID, *Memory.Ascii, Flags=#C2F_Center)

		Protected	x.f, y.f, x_pos.f

		If	IsFlatBar(ID)

			With	RS_FlatBar()

				StartDrawing(ImageOutput(\Image))
				DrawingMode(#PB_2DDrawing_AlphaBlend)

				Box(0, \Frame * 2, OutputWidth(), OutputHeight() - \Frame * 4, $FF000000|\Color)

				If	MemoryStringLength(*Memory)

					*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)

					If	Flags	&	#C2F_Center
						x	=	(OutputWidth()	- RS_FontMap()\GapW * MemoryStringLength(*Memory, #PB_Ascii)) * 0.5
					EndIf

					x_pos	=	x
					y		=	(OutputHeight() - RS_FontMap()\GapH) * 0.5

					While	*Memory\a

						If	*Memory\a	>	#MIN_CHR	And	*Memory\a	<=	#MAX_CHR
							DrawAlphaImage(ImageID(FontImage(*Memory\a - #MIN_CHR)), x_pos, y)
							x_pos	+	RS_FontMap()\GapW
						;ElseIf	*Memory\a	=	#LF	Or	*Memory\a	=	'|'
							;	x_pos	=	x
							;	y		+	RS_FontMap()\GapH
						ElseIf	*Memory\a	=	#TAB
							x_pos	+	RS_FontMap()\GapW	*	RS_FontMap()\TabW
						Else
							x_pos	+	RS_FontMap()\GapW
						EndIf

						*Memory	+	SizeOf(Ascii)

					Wend

				EndIf

				StopDrawing()

			EndWith

		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A5
; EnableXP
; CompileSourceDirectory