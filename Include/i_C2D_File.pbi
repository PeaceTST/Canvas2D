;**********************************************
;- *** C2D FILE - PATH / 06.05.2023 ***********
;- Fixed StrStrI_() / bug in PB 6.01

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	XIncludeFile	"C2D_Macros.pbi"
	XIncludeFile	"C2D_Enums.pbi"

	Declare	FilePath(Path$)
	Declare	FileLoad(File$, Flags=0)

	CompilerIf	#IsC2D_File	=	2
		Declare		FileSave(File$, *Memory, Length)
		Declare$	FileParent(Path$=#Null$, Dirs=1)
	CompilerEndIf

CompilerEndIf

Procedure	FilePath(Path$)
	C2D\FilePath	=	Path$
EndProcedure
Procedure	FileLoad(File$, Flags=0)

	; Return -> *Memory -> ByteSize = MemorySize(*Memory)

	; Flags = 0 -> free *Memory when next call (Ball3D, Line3D..)
	; Flags = 1 -> user free *Memory, do nothing (XUnPack, NetWork..)

	Static	*Buffer, *Memory
	Protected	hF

	If	*Memory	>	#Null	:	FreeMemory(*Memory)	:	*Memory	=	#Null	:	:	EndIf
	
	; add defaultpath to file?
	If	Len(C2D\FilePath) And FindString(File$, ":")=0	And	FindString(File$, ".\")=0	;StrStrI_(@File$, @":")=#Null And StrStrI_(@File$, @".\")=#Null
		File$	=	C2D\FilePath	+	File$
	EndIf

	CompilerIf	#IsC2D_NetWork
		*Memory	=	NetWorkLoad(File$)
	CompilerEndIf

	If	*Memory	<=	#Null
		hF	=	ReadFile(#PB_Any, File$)
		If	hF
			*Memory	=	AllocateMemory(Lof(hF))
			ReadData(hF, *Memory, MemorySize(*Memory))
			CloseFile(hF)
		EndIf
	EndIf

	CompilerIf	#PB_Compiler_Debugger
		If	Len(File$)	And	*Memory	<=	0
			Debug	"FILE-ERROR: " + File$
			Free()
			End
		EndIf
	CompilerEndIf

	*Buffer	=	*Memory	:	If	Flags	:	*Memory	=	#Null	:	EndIf

	ProcedureReturn	*Buffer

EndProcedure

CompilerIf	#IsC2D_File	=	2
	Procedure$	FileParent(Path$=#Null$, Dirs=1)

		Protected	Count

		If	Len(Path$)	<	1
			Path$	=	GetCurrentDirectory()
		EndIf

		Path$	=	GetPathPart(Path$)

		While	Dirs	>	0

			Count	=	CountString(Path$, "\")

			If	Count	>	1
				Path$	=	Left(Path$, Len(Path$) - Len(StringField(Path$, Count, "\")) - 1)
			Else
				Break
			EndIf

			Dirs	-	1

		Wend

		ProcedureReturn	Path$

	EndProcedure
	Procedure	FileSave(File$, *Memory, Length)

		; Return = numbytes written or #NULL = Error

		Protected	hF

		If	Len(File$)	And	*Memory	And	Length

			If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

			; add defaultpath to file?
			If	Len(C2D\FilePath) And FindString(File$, ":")=0	And	FindString(File$, ".\")=0	;StrStrI_(File$, ":")=#Null And StrStrI_(File$, ".\")=#Null
				File$	=	C2D\FilePath	+	File$
			EndIf

			hF	=	CreateFile(#PB_Any, File$)
			If	hF
				Length	=	WriteData(hF, *Memory, Length)
				CloseFile(hF)
				ProcedureReturn	Length
			EndIf

		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 29
; Folding = I5
; CompileSourceDirectory