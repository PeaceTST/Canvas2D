;**********************************************
;- *** C2D Brush / 29.03.2020 *****************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Brush	=	1,2

	XIncludeFile	"C2D_Enums.pbi"

	Structure	RS_Brush
		*Brush	; api hBrush
		*Pen		; api hPen
		*Clip		; api hClip
		x.f	; brush x-pos when clipped
		y.f	; brush y-pos when clipped
		rc.RECT	; clip, draw
		ImageW.i
		ImageH.i
	EndStructure

	Global	ID_Brush.C2D_ID
	Global	NewList	RS_Brush.RS_Brush()

	Declare	IsBrush(ID)
	Declare	BrushDraw(ID)
	Declare	BrushFree(ID)
	Declare	BrushInit(ID, Image, x, y, w, h)
	Declare	BrushMove(ID, x.f, y.f)
	Declare.f	BrushX(ID)
	Declare.f	BrushY(ID)
	
; 	Declare	BrushDrawEllipse(ID)
; 	Declare	BrushDrawRound(ID, w, h)
; 	Declare	BrushPen(ID, Mode=#PS_SOLID, w=1, Color.l=#Red)

CompilerEndIf

Procedure	IsBrush(ID)

	; return ptr & sets element(id) or #null

	ID	=	ID_Brush\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Brush(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	BrushDraw(ID)

	ChangeCurrentElement(RS_Brush(), ID_Brush\ID[ID])

	With	RS_Brush()
		
		; update position of brush
		SetBrushOrgEx_(C2D\hDC, \x, \y, #Null)
		
		; fill region with brush
		FillRgn_(C2D\hDC, \hRegion, \hBrush)

	EndWith

EndProcedure
Procedure	BrushFree(ID)

	With	RS_Brush()

		If	ID	<=	#PB_All

			ForEach	RS_Brush()
				If	\hBrush	:	DeleteObject_(\hBrush)	:	EndIf
				If	\hRegion	:	DeleteObject_(\hRegion)	:	EndIf
			Next

			FillMemory(@ID_Brush\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Brush())

		Else

			If	IsBrush(ID)

				ID_Brush\ID[ID]	=	#Null

				If	\hBrush	:	DeleteObject_(\hBrush)	:	EndIf
				If	\hRegion	:	DeleteObject_(\hRegion)	:	EndIf

				DeleteElement(RS_Brush())

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	BrushInit(ID, Image, x, y, w, h)

	BrushFree(ID)

	ID_Brush\ID[ID]	=	AddElement(RS_Brush())	; @RS_Brush()

	With	RS_Brush()
		
		; create brush from image (no alpha)
		\ImageW	=	ImageWidth(Image)
		\ImageH	=	ImageHeight(Image)
		\hBrush	=	CreatePatternBrush_(ImageID(Image))
		
		; create clipped region
		\rc\left		=	x
		\rc\top		=	y
		\rc\right	=	x	+	w
		\rc\bottom	=	y	+	h
		\hRegion		=	CreateRectRgnIndirect_(@\rc)
		
		; adapt brush origins (Draw, Move)
		x	%	w	:	\x	=	x
		y	%	h	:	\y	=	y

	EndWith

EndProcedure
Procedure	BrushMove(ID, x.f, y.f)
	
	ChangeCurrentElement(RS_Brush(), ID_Brush\ID[ID])
	
	With	RS_Brush()
		\x	+	x	:	If	Abs(\x)	>	\ImageW	:	\x	=	#Null	:	EndIf
		\y	+	y	:	If	Abs(\y)	>	\ImageH	:	\y	=	#Null	:	EndIf
	EndWith
	
EndProcedure
Procedure.f	BrushX(ID)
	ChangeCurrentElement(RS_Brush(), ID_Brush\ID[ID])
	ProcedureReturn	RS_Brush()\x
EndProcedure
Procedure.f	BrushY(ID)
	ChangeCurrentElement(RS_Brush(), ID_Brush\ID[ID])
	ProcedureReturn	RS_Brush()\y
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A5
; DisableDebugger
; CompileSourceDirectory