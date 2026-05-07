;**********************************************
;- *** C2D Bounce / 07.02.2020 ****************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_Bounce	=	1

	XIncludeFile	"C2D_Enums.pbi"

	Structure	RS_Bounce
		a.f	; acceleration
		d.f	; accelerated direction
		h.f	; height of bounce
		y.f	; top-position
	EndStructure
	
	Global	ID_Bounce.C2D_ID
	Global	NewList	RS_Bounce.RS_Bounce()
	
	Declare		IsBounce(ID)
	Declare		BounceFree(ID)
	Declare		BounceInit(ID, h, Acceleration.f)
	Declare.f	Bounce(ID)
	
CompilerEndIf

Procedure	IsBounce(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Bounce\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Bounce(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	BounceFree(ID)
	With	RS_Bounce()
		If	ID	<=	#PB_All
			FillMemory(@ID_Bounce\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Bounce())
		Else
			If	IsBounce(ID)
				DeleteElement(RS_Bounce())
				ID_Bounce\ID[ID]	=	#Null
			EndIf
		EndIf
	EndWith
EndProcedure
Procedure	BounceInit(ID, y, h, Acceleration)
	
	BounceFree(ID)	:	ID_Bounce\ID[ID]	=	AddElement(RS_Bounce())	; -> @RS_Bounce()

	With	RS_Bounce()
		\y	=	y
		\h	=	y	+	h
		\a	=	0.001	*	Acceleration
	EndWith
	
EndProcedure
Procedure	Bounce(ID)
	
	; Return: Integer y-pos (y..h)
	
	ChangeCurrentElement(RS_Bounce(), ID_Bounce\ID[ID])
	
	With	RS_Bounce()

		If	\y	>=	\h	; up?
			\d	*	-1
  		Else			; acclerate ±
			\d	+	\a
		EndIf		
		
		\y	+	\d		; up & down

		ProcedureReturn	\y
		
	EndWith
	
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A-
; CompileSourceDirectory