;**********************************************
;- *** C2D COPPER / 17.04.2026 ****************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_Copper	=	1
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Global	ID_Copper.C2D_ID
	Global	CpBlt.RS_CpBlt
	Global	NewList	RS_Copper.RS_Copper()
	
	Declare	IsCopper(ID)
	Declare	CopperScale(ID, Ratio.f)
	Declare	CopperBitmap(ID, BitmapID)
	Declare	CopperBlit(ID, Position.f, Speed.f=0)
	Declare	CopperBlitColor(Color.l)
	Declare	CopperBlitProc(*Proc)
	Declare	CopperDraw(ID, y.f, Alpha=255, Flags=0)
	Declare	CopperFree(ID)
	Declare	CopperH(ID)
	Declare	CopperImage(ID)
	Declare	CopperInit(ID, h, *Memory.Long, Flags=#Null)
	Declare	CopperMoveDraw(ID, Position.f, Speed.f=5, Alpha=255)
	Declare	CopperText(ID, *Memory.Ascii, Flags=#C2F_Center)
	Declare	CopperZoom(ID, h)
	
	CpBlt\cbColor	=	$FFFFFFFF
	CpBlt\cbProc	=	@Blt_Copper_Color()	; doesn't work on x64
	
CompilerEndIf

Procedure.l	Blt_Copper_Color(x, y, PenColor.l, PaperColor.l)	; private default CopperBlit Color
	If	PaperColor	<>	CpBlt\cbColor
		ProcedureReturn	PaperColor
	EndIf
	ProcedureReturn	PenColor
EndProcedure

Procedure	IsCopper(ID)

	ID	=	ID_Copper\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Copper(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	CopperBitmap(ID, Image, x=0, y=0, Alpha=255)

	If	IsCopper(ID)
		StartDrawing(ImageOutput(RS_Copper()\Image))
		DrawingMode(#PB_2DDrawing_AllChannels)
		DrawAlphaImage(ImageID(Image), x, y, Alpha)
		StopDrawing()
	EndIf

EndProcedure
Procedure	CopperBlit(ID, Position.f, Speed.f=0)
	
	DrawingMode(#PB_2DDrawing_CustomFilter)
	CustomFilterCallback(CpBlt\cbProc)
	
	CopperMoveDraw(ID, Position, Speed)
		
EndProcedure
Procedure	CopperBlitColor(Color.l)
	CpBlt\cbColor	=	$FF000000|Color
EndProcedure
Procedure	CopperBlitProc(*Proc)
	CpBlt\cbProc	=	*Proc
EndProcedure
Procedure	CopperDraw(ID, y.f, Alpha=255, Flags=0)
		
	ChangeCurrentElement(RS_Copper(), ID_Copper\ID[ID])
	
	With	RS_Copper()
		
		If	Flags
			If			Flags	&	(#C2F_Center|#C2F_CenterY)	:	y	+	(C2D\h	-	\h)	*	0.5
			ElseIf	Flags	&	#C2F_Bottom						:	y	+	(C2D\h	-	\h)
			EndIf
		EndIf
		
		DrawAlphaImage(\hImage, \x, y, Alpha)	; \x -> for custom-copper by coder
		
	EndWith

EndProcedure
Procedure	CopperFree(ID)

	With	RS_Copper()
		
		If	ID	<=	#PB_All
			
			ForEach	RS_Copper()
				If	\Image	And	IsImage(\Image)
					FreeImage(\Image)
				EndIf
			Next
			
			FillMemory(@ID_Copper\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Copper())
			
		Else
			
			If	IsCopper(ID)
				
				If	\Image	And	IsImage(\Image)
					FreeImage(\Image)
				EndIf
				
				DeleteElement(RS_Copper())
				
				ID_Copper\ID[ID]	=	#Null
				
			EndIf
			
		EndIf
		
	EndWith

EndProcedure
Procedure	CopperH(ID)
	If	IsCopper(ID)
		ProcedureReturn	RS_Copper()\h
	EndIf
EndProcedure
Procedure	CopperImage(ID)
	If	IsCopper(ID)
		ProcedureReturn	RS_Copper()\Image
	EndIf
EndProcedure
Procedure	CopperInit(ID, h, *Memory.Long, Flags=#Null)

	If	*Memory\l	<=	1	:	ProcedureReturn	:	EndIf

	Protected	*Ptr.Long	=	*Memory	+	SizeOf(Long)	; Color-Table
	Protected	c.f	=	1.0	/	(*Memory\l	-	1)			; Number of colors

	CopperFree(ID)	:	ID_Copper\ID[ID]	=	AddElement(RS_Copper())	; @RS_Copper()

	With	RS_Copper()

		\h			=	h
		\w			=	C2D\w
		\Flags	=	Flags
		
		CompilerIf	#PB_Compiler_Version	>=	630
			\Image	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_TransparentBlack)
		CompilerElse
			\Image	=	CreateImage(#PB_Any, \w, \h, 32, #PB_Image_Transparent)
		CompilerEndIf

		StartDrawing(ImageOutput(\Image))
		DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)

		If	\Flags	&	#C2F_Horizontal
			LinearGradient(0, 0, OutputWidth()-1, 0)
		Else
			\Flags	|	#C2F_Vertical
			LinearGradient(0, 0, 0, OutputHeight()-1)
		EndIf

		For	ID	=	0	To	*Memory\l	-	1
			GradientColor(c * ID, *Ptr\l)
			*Ptr	+	SizeOf(Long)
		Next

		;Box(0, 0, OutputWidth(), OutputHeight())
		Box(0, 0, \w, \h)

		StopDrawing()
		
		\hImage	=	ImageID(\Image)

	EndWith

EndProcedure
Procedure	CopperMoveDraw(ID, Position.f, Speed.f=5, Alpha=255)
		
	ChangeCurrentElement(RS_Copper(), ID_Copper\ID[ID])
	
	With	RS_Copper()
		
		If	\Flags	&	#C2F_Horizontal
			
			\x	+	Speed
			
			If	\x	>=	\w	Or	\x	<=	-\w
				\x	=	#Null
			EndIf
			
			DrawAlphaImage(\hImage, \x, Position, Alpha)
			
			If	\x	>	0
				DrawAlphaImage(\hImage, \x - \w, Position, Alpha)
			ElseIf	\x	<	0
				DrawAlphaImage(\hImage, \x + \w, Position, Alpha)
			EndIf
			
		Else	; \x -> for custom-copper (see Demo:Switch)
			
			\y	+	Speed
			
			If	\y	>=	\h	Or	\y	<=	-\h
				\y	=	#Null
			EndIf
			
			ClipOutput(0, Position, C2D\w, \h)
			
			Position	+	\y
			
			DrawAlphaImage(\hImage, \x, Position, Alpha)
			
			If	\y	>	0
				DrawAlphaImage(\hImage, \x, Position - \h, Alpha)
			ElseIf	\y	<	0
				DrawAlphaImage(\hImage, \x, Position + \h, Alpha)
			EndIf
			
			UnclipOutput()
			
		EndIf
		
	EndWith
		
EndProcedure
Procedure	CopperScale(ID, Ratio.f)

	If	IsCopper(ID)
		With	RS_Copper()

			If	Ratio	<>	1.0

				\h	=	ImageHeight(\Image)	*	Ratio

				\hImage	=	ResizeImage(\Image, #PB_Ignore, \h, C2D\Quality)

			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	CopperZoom(ID, h)
	If	IsCopper(ID)
		With	RS_Copper()
			\h	=	h
			\hImage	=	ResizeImage(\Image, \w, \h, C2D\Quality)
		EndWith
	EndIf
EndProcedure

CompilerIf	#IsC2D_Font
	Procedure	CopperText(ID, *Memory.Ascii, Flags=#C2F_Center)

		; draw text direct on copperimage

		Protected	x.f, y.f, x_pos.f

		If	IsCopper(ID)

			StartDrawing(ImageOutput(RS_Copper()\Image))
			DrawingMode(#PB_2DDrawing_AlphaBlend)

			If	MemoryStringLength(*Memory)

				*Memory	=	Uni2Asc(*Memory, #C2F_Ucase)

				If	Flags&(#C2F_CenterX|#C2F_Center)
					x	=	(OutputWidth()	- RS_FontMap()\GapW * MemoryStringLength(*Memory, #PB_Ascii)) * 0.5
				EndIf

				x_pos	=	x
				y		=	(OutputHeight() - RS_FontMap()\GapH) * 0.5

				While	*Memory\a

					If	*Memory\a	>	#MIN_CHR	And	*Memory\a	<=	#MAX_CHR
						DrawAlphaImage(ImageID(FontImage(*Memory\a - #MIN_CHR)), x_pos, y)	; font-char-image
						x_pos	+	RS_FontMap()\GapW
					ElseIf	*Memory\a	=	#TAB
						x_pos	+	RS_FontMap()\GapW	*	RS_FontMap()\TabW
					Else
						x_pos	+	RS_FontMap()\GapW
					EndIf

					*Memory	+	SizeOf(Ascii)

				Wend

			EndIf

			StopDrawing()

		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAQ-
; DisableDebugger
; CompileSourceDirectory