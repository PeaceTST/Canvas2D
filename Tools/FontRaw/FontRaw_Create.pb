; Create RawFont RF/RAW (8..64 bits) - Purebasic v5.70 (x86-64)

EnableExplicit

#IsC2D_GdiPlus	=	1

Structure	Union
	StructureUnion
		a.a
		b.b
		w.w
		l.l
		i.i
		q.q
	EndStructureUnion
EndStructure

CompilerIf	Defined(IsC2D_GdiPlus, #PB_Constant)
	IncludeFile	"..\..\Include\i_C2D_Gdiplus.pbi"
CompilerElse
	UsePNGImageDecoder()
	CompilerIf	#PB_Compiler_Version	>=	560
		UseGIFImageDecoder()
	CompilerEndIf
CompilerEndIf

CompilerSelect	#PB_Compiler_Processor
	CompilerCase	#PB_Processor_x64
		#C2D_XOS$	=	"x64"
	CompilerDefault
		#C2D_XOS$	=	"x86"
CompilerEndSelect

#ID_IMAGE	=	0

#C2D_W	=	10	*	64	; Width
#C2D_H	=	6	*	64	; Height

Enumeration
	#G_ED
	#G_COPY
	#G_PASTE
	#G_OPEN
	#G_SAVE_RW
	#G_SAVE_RF
EndEnumeration

Global	File$="..\..\Data\Font\PNG\8x8_Fairlight.png"
Define	w, x, y, *Memory

Procedure	CreateRawFont(Image)
	
	; Create RawFont of a 8 x 8 Char-Bitmapimage

	;  !"#$%&'
	; ()*+,-./
	; 01234567
	; 89:;<=>?
	; @ABCDEFG
	; HIJKLMNO
	; PQRSTUVW
	; XYZ[\]^_
	
	Static	*Memory
	
	If	*Memory	And	MemorySize(*Memory)
		FreeMemory(*Memory)
	EndIf
	
	Protected	Type, x, y, cx, cy, n.q, n$
	
	Protected	w	=	ImageWidth(Image)		>>	3	; / 8 * 8
	Protected	h	=	ImageHeight(Image)	>>	3
	
	Protected	Length	=	4	*	SizeOf(Ascii)	; HeaderID RF + BitW + BitH
	
	*Memory	=	AllocateMemory(Length + 64 * 64 * 64)
	
	Protected	*Ptr.Union	=	*Memory

	If			w	<=	8	:	Type	=	#PB_Ascii
	ElseIf	w	<=	16	:	Type	=	#PB_Word
	ElseIf	w	<=	32	:	Type	=	#PB_Long
	Else					:	Type	=	#PB_Quad
	EndIf
	
	; RawFont Header
	*Ptr\a	=	'R'	:	*Ptr	+	SizeOf(Ascii)	; Raw
	*Ptr\a	=	'F'	:	*Ptr	+	SizeOf(Ascii)	; Font
	*Ptr\a	=	 w		:	*Ptr	+	SizeOf(Ascii)	; BitWidth
	*Ptr\a	=	 h		:	*Ptr	+	SizeOf(Ascii)	; BitHeight

	AddGadgetItem(#G_ED, -1, "Data.a	"	+	"'R', 'F', " + Str(w) + ", " + Str(h)	+	#TAB$	+	"; Width x Height of " + GetFilePart(File$))
	
	; RawFont BitMask
	StartDrawing(ImageOutput(Image))
	For	y	=	0	To	7
		For	x	=	0	To	7
			
			Select	Type
				Case	#PB_Ascii	:	n$	=	"Data.a"	+	#TAB$
				Case	#PB_Word		:	n$	=	"Data.w"	+	#TAB$
				Case	#PB_Long		:	n$	=	"Data.l"	+	#TAB$
				Case	#PB_Quad		:	n$	=	"Data.q"	+	#TAB$
			EndSelect
			
			For	cy	=	0	To	h - 1
				
				n	=	#NUL
				
				For	cx	=	0	To	w - 1
					If	Point(x * w + cx, y * h + cy)
						n | 1 << ( w - cx - 1 )
					EndIf
				Next
				
				n$	+	"%" + RSet(Bin(n), w, "0")	+	","
				
				Select	Type
					Case	#PB_Ascii	:	*Ptr\a	=	n	:	*Ptr	+	SizeOf(Ascii)	:	Length	+	SizeOf(Ascii)
					Case	#PB_Word		:	*Ptr\w	=	n	:	*Ptr	+	SizeOf(Word)	:	Length	+	SizeOf(Word)
					Case	#PB_Long		:	*Ptr\l	=	n	:	*Ptr	+	SizeOf(Long)	:	Length	+	SizeOf(Long)
					Case	#PB_Quad		:	*Ptr\q	=	n	:	*Ptr	+	SizeOf(Quad)	:	Length	+	SizeOf(Quad)
				EndSelect
				
			Next
			
			n$	=	Left(n$, Len(n$) - 1)	+	#TAB$	+	"; " + #DQUOTE$ + Chr(32 + x + y << 3) + #DQUOTE$
			
			AddGadgetItem(#G_ED, -1, n$)
			
		Next
	Next
	StopDrawing()
	
	If	Length	<	MemorySize(*Memory)
		*Memory	=	ReAllocateMemory(*Memory, Length)
	EndIf

	ProcedureReturn	*Memory

EndProcedure

Procedure	Open()
	
	Protected	*Memory, Length, t$

	t$	=	OpenFileRequester("Load 8 x 8 Char-BitMap-Font", File$, "Image|*.bmp;*.png;*.gif", 0)

	If	t$

		File$	=	t$

		ClearGadgetItems(#G_ED)

		CompilerIf	Defined(IsC2D_GdiPlus, #PB_Constant)
			If	ReadFile(0, File$)
				Length	=	Lof(0)
				*Memory	=	AllocateMemory(Length)
				ReadData(0, *Memory, Length)
				CloseFile(0)
				GdipCatch(#ID_IMAGE, *Memory, Length)
				FreeMemory(*Memory)
			EndIf
		CompilerElse
			LoadImage(#ID_IMAGE, File$)
		CompilerEndIf
		
		If	IsImage(#ID_IMAGE)
			*Memory	=	CreateRawFont(#ID_IMAGE)
		EndIf

	EndIf
	
	ProcedureReturn	*Memory
	
EndProcedure
Procedure	Paste()
	
	Protected	*Memory
	
	ClearGadgetItems(#G_ED)
	GetClipboardImage(#ID_IMAGE)
	
	If	IsImage(#ID_IMAGE)
		*Memory	=	CreateRawFont(#ID_IMAGE)
	EndIf
	
	ProcedureReturn	*Memory
	
EndProcedure
Procedure	Save(*Memory, Mode)
	
	Static	Save$
	
	Protected	Mode$, Ext$, Header, n$
	
	If	*Memory	And	MemorySize(*Memory)
		
		Select	Mode	; rf/raw?
			Case	#G_SAVE_RF
				Ext$	=	".rf"
				Mode$	=	"Canvas2D RawFont (*.rf)|*.rf"
			Default
				Ext$	=	".rw"
				Mode$	=	"Amiga RawFont (*.rw)|*.rw"
		EndSelect
		
		If	Len(Save$)
			Save$	=	GetPathPart(Save$)
		Else
			Save$	=	GetPathPart(File$)
		EndIf
		
		Save$	+	GetFilePart(File$, #PB_FileSystem_NoExtension) + Ext$
		Save$	=	SaveFileRequester("Save RawFont", Save$, Mode$, 0)
		
		If	Save$
			
			Save$	=	GetPathPart(Save$) + GetFilePart(Save$, #PB_FileSystem_NoExtension)
			
			Select	Mode	; rf/raw?
				Case	#G_SAVE_RF
					Header	=	0
					Save$	+	".rf"
				Default
					Header	=	4	; remove rf-header
					n$	=	GetFilePart(Save$)
					n$	=	RemoveString(n$, "Amiga_")
					n$	=	RemoveString(n$, "_"	+	Str(PeekA(*Memory + 2)))
					n$	=	RemoveString(n$, "_")
					Save$	=	GetPathPart(Save$)	+	"Amiga_" + 	n$	+	"_"	+	Str(PeekA(*Memory + 2))	+	".rw"
			EndSelect
			
			If	FileSize(Save$)	>	0	And	MessageRequester("File exists!", "Really save as: " + GetFilePart(Save$), #PB_MessageRequester_YesNo)	=	#PB_MessageRequester_No
				ProcedureReturn
			EndIf
			
			If	CreateFile(0, Save$)
				WriteData(0, *Memory + Header, MemorySize(*Memory) - Header)
				CloseFile(0)
				MessageRequester("RawFont saved.", Save$ + #LF$ + #LF$ + Str(MemorySize(*Memory) - Header) + " Bytes")
			EndIf
			
		EndIf
		
	EndIf
	
EndProcedure

OpenWindow(0, 0, 0, #C2D_W, #C2D_H, "C2D::FontRaw - Create (" + #C2D_XOS$ + ")", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

EditorGadget(#G_ED, 0, 0, #C2D_W, #C2D_H - 27)

w	=	(#C2D_W - 5	*	120)	/	5
x	=	w	/	2	:	y	=	#C2D_H - 25

ButtonGadget(#G_PASTE,		x, y, 120, 22, "Paste Bitmap Font")		:	x	+	GadgetWidth(#G_PASTE)	+	w
ButtonGadget(#G_OPEN,		x, y, 120, 22, "Open Bitmap Font")		:	x	+	GadgetWidth(#G_OPEN)		+	w
ButtonGadget(#G_COPY,		x, y, 120, 22, "Copy to Clipboard")		:	x	+	GadgetWidth(#G_COPY)		+	w
ButtonGadget(#G_SAVE_RF,	x, y, 120, 22, "Save C2D RawFont")		:	x	+	GadgetWidth(#G_SAVE_RF)	+	w
ButtonGadget(#G_SAVE_RW,	x, y, 120, 22, "Save Amiga RawFont")	:	x	+	GadgetWidth(#G_SAVE_RW)

Repeat
	Select	WaitWindowEvent()

 		Case #PB_Event_Gadget
 			Select	EventGadget()
 				Case	#G_PASTE
 					*Memory	=	Paste()
 				Case	#G_OPEN
 					*Memory	=	Open()
 				Case	#G_COPY
 					SendMessage_(GadgetID(#G_ED), #EM_SETSEL, 0, -1)
 					SendMessage_(GadgetID(#G_ED), #WM_COPY, 0, 0)
 				Case	#G_SAVE_RF, #G_SAVE_RW
 					Save(*Memory, EventGadget())
 			EndSelect
			
		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
			
	EndSelect
ForEver

End
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = Aw
; EnableXP
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = FontRaw_Create_x86.exe
; CompileSourceDirectory