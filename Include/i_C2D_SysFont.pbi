;***********************************************
;- *** C2D SysFont (SystemFont) / 16.07.2020 ***

EnableExplicit

; Native API AddFontMemResourceEx_() at least in PureBasic v5.50+

; https://www.trueschool.se/
; https://docs.microsoft.com/en-us/windows/desktop/api/wingdi/nf-wingdi-addfontmemresourceex
; https://docs.microsoft.com/en-us/windows/desktop/api/wingdi/nf-wingdi-createfontindirectw
; https://msdn.microsoft.com/en-us/library/cc250391.aspx

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	XIncludeFile	"C2D_Enums.pbi"
	
	Structure	RS_SysFont
		*hFont	; FontID
		*rFont	; Ressource
	EndStructure
	
	Global	ID_SysFont.C2D_ID
	Global	NewList	RS_SysFont.RS_SysFont()
	
	Declare	IsSysFont(ID)
	Declare	SysFontID(ID)
	Declare	SysFontFree(ID)
	Declare	SysFontInit(ID, Font$, *Memory, Length, h=0, w=0, Flags=0)
	Declare	SysFontSet(ID)
	
CompilerEndIf

CompilerIf	#PB_Compiler_Version	<	550	; *** API AddFontMemResourceEx_() ***
	Import	"gdi32.lib"
		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			AddFontMemResourceEx_(*Memory, Length, Reserved, *NumFonts)	As	"AddFontMemResourceEx"
		CompilerElse
			AddFontMemResourceEx_(*Memory, Length, Reserved, *NumFonts)	As	"_AddFontMemResourceEx"
		CompilerEndIf
	EndImport
CompilerEndIf

Procedure	IsSysFont(ID)
	
	; return ptr & set element(id) or #null
	
	ID	=	ID_SysFont\ID[ID]
	
	If	ID
		ChangeCurrentElement(RS_SysFont(), ID)
		ProcedureReturn	ID
	EndIf
	
EndProcedure
Procedure	SysFontFree(ID)
	
	With	RS_SysFont()
		
		If	ID	<=	#PB_All
			
			ForEach	RS_SysFont()
				If	\hFont	:	DeleteObject_(\hFont)				:	EndIf
				If	\rFont	:	RemoveFontMemResourceEx_(\rFont)	:	EndIf
			Next
			
			FillMemory(@ID_SysFont\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_SysFont())
			
		Else
			
			If	IsSysFont(ID)
				
				If	\hFont	:	DeleteObject_(\hFont)				:	EndIf
				If	\rFont	:	RemoveFontMemResourceEx_(\rFont)	:	EndIf
				
				DeleteElement(RS_SysFont())
				
				ID_SysFont\ID[ID]	=	#Null
				
			EndIf
			
		EndIf
		
	EndWith
	
EndProcedure
Procedure	SysFontID(ID)

	; return hFont -> FontID()

	If	IsSysFont(ID)
		ProcedureReturn	RS_SysFont()\hFont
	EndIf

EndProcedure
Procedure	SysFontInit(ID, Font$, *Memory, Length, h=0, w=0, Flags=0)
	
	; return hFont -> FontID()
	
	Protected	lf.LOGFONT
	
	; check/set size of memory
	CompilerIf	#IsC2D_File
		If	Length	<=	0	; @Filename as *Ptr
			*Memory	=	FileLoad(PeekS(*Memory))
			Length	=	MemorySize(*Memory)
		ElseIf	Length	>	*Memory	; Included binary ?Start/?End
			Length	-	*Memory
		EndIf
	CompilerElse
		If	Length	>	*Memory	; Included binary ?Start/?End
			Length	-	*Memory
		EndIf
	CompilerEndIf
	
	SysFontFree(ID)	:	ID_SysFont\ID[ID]	=	AddElement(RS_SysFont())	; -> @RS_SysFont()
	
	RS_SysFont()\rFont	=	AddFontMemResourceEx_(*Memory, Length, 0, @"1")
	
	If	RS_SysFont()\rFont
		
		With	lf
			
			\lfHeight			=	h
			\lfWidth				=	w
			;\lfEscapement		=	0
			;\lfOrientation	=	0
			\lfWeight			=	Bool(Flags & #PB_Font_Bold)	*	700	; * 300 + 400
			\lfItalic			=	Bool(Flags & #PB_Font_Italic)
			\lfUnderline		=	Bool(Flags & #PB_Font_Underline)
			\lfStrikeOut		=	Bool(Flags & #PB_Font_StrikeOut)
			\lfCharSet			=	#DEFAULT_CHARSET
			\lfOutPrecision	=	#OUT_DEFAULT_PRECIS   
			\lfClipPrecision	=	#CLIP_DEFAULT_PRECIS
			\lfPitchAndFamily	=	#DEFAULT_PITCH | #FF_DONTCARE
			
			If	Flags & #PB_Font_HighQuality
				\lfQuality		=	#CLEARTYPE_QUALITY
			Else
				\lfQuality		=	#NONANTIALIASED_QUALITY	; default
			EndIf
			
			PokeS(@\lfFaceName[0], Font$)	; remember: not "fontfile.ttf" only real title of font!
			
		EndWith
		
		RS_SysFont()\hFont	=	CreateFontIndirect_(@lf)
		
		If	RS_SysFont()\hFont	; all OK!
			ProcedureReturn	RS_SysFont()\hFont
		EndIf
		
	EndIf
	
	; Error!
	SysFontFree(ID)
	ProcedureReturn	#False

EndProcedure
Procedure	SysFontSet(ID)
	ChangeCurrentElement(RS_SysFont(), ID_SysFont\ID[ID])
	DrawingFont(RS_SysFont()\hFont)
EndProcedure
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = Aw
; CompileSourceDirectory