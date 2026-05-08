; Optimized source 27.12.2025 17:52:03
; ************************************************************
; C2D::Compiler v2.04 (x86) - Update: 18.03.2025 16:54
; ============================================================
; - hardcoded, only for "easy-life" in debug-/testphase of C2D
; - compiles whole directories with pb-sources in x86-64
; - additional create asm-sourcefile in exe-path!
; - on the fly zoom (C2D_Z=factor 0.5=half, 2=double, ..)
; - fast select of compile theme (Examples, Demos, DLL...)
; - upx exe-compressing (x86-64), https://upx.github.io/
; ************************************************************

EnableExplicit

#VER$		=	"2.04"

#SCR_W	=	700
#SCR_H	=	592

#GAD_H	=	23

#PARAM_DLL$				=	"/DLL"
#PARAM_THREAD$			=	"/THREAD"
#PARAM_DPIAWARE$		=	"/DPIAWARE"
#PARAM_XP$				=	"/XP"
#PARAM_DLLPROTECTION$=	"/DLLPROTECTION"
#PARAM_OPTIMIZER$		=	"/OPTIMIZER"
#PARAM_ICON$			=	"/ICON"
#PARAM_RESOURCE$		=	"/RESOURCE"
#PARAM_COMMENTED$		=	"/COMMENTED"
#PARAM_PREPROCESS$	=	"/PREPROCESS"
#PARAM_CONSTANT$		=	"/CONSTANT"
#PARAM_DYNAMICCPU$	=	"/DYNAMICCPU"
#PARAM_UCRT$			=	"/UCRT"

; private message: dont copy paste in MCEd
#CHR_ABORT$		=	Chr($25FC)
#CHR_REMOVE$	=	Chr($2718)
#CHR_SEARCH$	=	"🔎"	; $1F50E	Chr($2026)
#CHR_VIEW$		=	Chr($25B6)
#CHR_OPEN$		=	"🗁"	; $1F5C1	Chr($2026)	+	"/"
#CHR_COMPILE$	=	"🚀"	; $1F680
#CHR_COPY$		=	"⧉"

Enumeration	; Gadgets
	#G_GADGET_START
	#G_SavePref
	#G_OpenPref
	#G_Default
	;
	#G_SetAMP
	#G_SetBall3D
	#G_SetBoot
	#G_SetDemos
	#G_SetDLL
	#G_SetExamples
	#G_SetExe
	#G_SetLine3D
	#G_SetTest
	#G_SetTools
	#G_SetSplatter
	#G_SetSize	; must last of set..
	;
	#G_All
	#G_ASM
	#G_OutOpen
	#G_OutPath
	#G_OutSet
	#G_OutRemove
	#G_IcoPath
	#G_IcoSet
	#G_IcoRemove
	#G_IcoView
	#IS_UPX
	#G_ResSet
	#G_ResPath
	#G_ResRemove
	#G_ResView
	#G_See
	#G_Sources
	#G_SrcOpen
	#G_SrcPath
	#G_SrcSet
	#G_SrcRemove
	#G_Swp
	#G_Off
	#IS_OUTPATH
	#G_UPXPath
	#IS_COMMENTED
	#IS_PREPROCESS	; preprocess
	#IS_DPIAWARE
	#IS_ICON
	#IS_RESOURCE
	#IS_XP
	#IS_DLL
	#IS_DLLPROTECTION
	#IS_THREAD
	#IS_OPTIMIZER
	#IS_DYNAMICCPU
	#X64_Compiler
	#X64_Create
	#X64_Open
	#X64_Copy
	#X64_Remove
	#X86_Compiler
	#X86_Create
	#X86_Open
	#X86_Copy
	#X86_Remove
	#X86_Process
	#X64_Process
	#G_TempPath
	#IS_CONSTANT
	#G_CONSTANT
	#IS_CUSTOM_1	:	#G_Custom_1
	#IS_CUSTOM_2	:	#G_Custom_2
	#IS_CUSTOM_3	:	#G_Custom_3
	#IS_CUSTOM_4	:	#G_Custom_4
	#IS_PROCESSOR	:	#G_Processor
	#G_GADGET_END
EndEnumeration

Enumeration	; Listicon Column
	#LI_FILE
	#LI_DATE
	#LI_SIZE
	#LI_X86
	#LI_X64
EndEnumeration

#KB	=	1.0	/	1024.0
#KIB	=	1.0	/	1000.0

#RGB_ON	=	$C7FFFF

Macro	MA_DQ(TEXT)
	#DQUOTE$	+	TEXT	+	#DQUOTE$
EndMacro
Macro	MA_Info(TEXT)
	StatusBarText(0, 0, TEXT)
EndMacro

Structure	Entry
	Path$
	File$
	Entry$
	DatePb.i
	SizePb.i
	SizeX86.i
	SizeX64.i
	State.i
	Back.l
EndStructure
Global	NewList	Entry.Entry()

Global	UPX$
Global	PB_Path$
Global	EXE_Path$
Global	ICO_Path$
Global	X86_Compiler$
Global	X64_Compiler$
Global	Mode_Size, Mode_Sort

Procedure	WinCallBack(hWnd, Message, wParam, lParam)

	Protected	Result	=	#PB_ProcessPureBasicEvents
	Protected	i, Offset, Type, t$
	Protected	*pnmhdr.NMHDR, *pnmlistview.NMLISTVIEW

	Select Message
		Case #WM_NOTIFY

			*pnmhdr	=	lParam

			If	*pnmhdr\idFrom	=	#G_Sources	And	ListSize(Entry())	>	1

				*pnmlistview	=	lParam

				Select	*pnmhdr\code

; 					Case	#LVN_ITEMCHANGED
; 						With	*pnmlistview
; 							Select	\uNewState>>12&$FFFF
; 								Case	1	;off
; 									SelectElement(Entry(), \iItem)
; 									;SetGadgetItemColor(\hdr\idFrom, \iItem, #PB_Gadget_BackColor, #PB_Default)
; 								Case	2	;on
; 									SelectElement(Entry(), \iItem)
; 									;SetGadgetItemColor(\hdr\idFrom, \iItem, #PB_Gadget_FrontColor, #RGB_ON)
; 							EndSelect
; 						EndWith
; 						With	Entry()
; 							i	=	ListIndex(Entry())
; 							If	\State	&	#PB_ListIcon_Checked	And	GetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor)	<>	#RGB_ON
; 								\Back	=	#RGB_ON	:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #RGB_ON)
; 							ElseIf	\State	&	#PB_ListIcon_Checked	=	#Null	And	GetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor)	<>	#PB_Default
; 								\Back	=	#PB_Default	:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #PB_Default)
; 							EndIf
; 						EndWith

					Case	#LVN_COLUMNCLICK   ; sort if column click?

						With	Entry
							Select	*pnmlistview\iSubItem
								Case	#LI_FILE	:	Offset	=	OffsetOf(\Entry$)		:	Type	=	TypeOf(\Entry$)
								Case	#LI_DATE	:	Offset	=	OffsetOf(\DatePb)		:	Type	=	TypeOf(\DatePb)
								Case	#LI_SIZE	:	Offset	=	OffsetOf(\SizePb)		:	Type	=	TypeOf(\SizePb)
								Case	#LI_X86	:	Offset	=	OffsetOf(\SizeX86)	:	Type	=	TypeOf(\SizeX86)
								Case	#LI_X64	:	Offset	=	OffsetOf(\SizeX64)	:	Type	=	TypeOf(\SizeX64)
							EndSelect
						EndWith

						With	Entry()

							ForEach	Entry()
								\State	=	GetGadgetItemState(#G_Sources, ListIndex(Entry()))
							Next

							Mode_Sort	!	1	:	SortStructuredList(Entry(), Mode_Sort, Offset, Type)

							ForEach	Entry()

								i	=	ListIndex(Entry())

								t$	=	\Entry$ + #LF$ + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", \DatePb) + #LF$

								If	\SizePb
									If	Mode_Size
										t$	+	Str(Round(\SizePb * #KB, #PB_Round_Up))
									Else
										t$	+	FormatNumber(\SizePb, 0)
									EndIf
								EndIf
								t$	+	#LF$
								If	\SizeX86
									If	Mode_Size
										t$	+	Str(Round(\SizeX86 * #KB, #PB_Round_Up))
									Else
										t$	+	FormatNumber(\SizeX86, 0)
									EndIf
								EndIf
								t$	+	#LF$
								If	\SizeX64
									If	Mode_Size
										t$	+	Str(Round(\SizeX64 * #KB, #PB_Round_Up))
									Else
										t$	+	FormatNumber(\SizeX64, 0)
									EndIf
								EndIf

								SetGadgetItemText(#G_Sources, i, t$)
								SetGadgetItemState(#G_Sources, i, \State)

								If	\State	&	#PB_ListIcon_Checked	And	GetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor)	<>	#RGB_ON
									\Back	=	#RGB_ON	:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #RGB_ON)
								ElseIf	\State	&	#PB_ListIcon_Checked	=	#Null	And	GetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor)	<>	#PB_Default
									\Back	=	#PB_Default	:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #PB_Default)
								EndIf

							Next

							SetGadgetState(#G_Sources, GetGadgetState(#G_Sources))

						EndWith

				EndSelect

			EndIf

	EndSelect

	ProcedureReturn	Result

EndProcedure

Procedure	_FX()
	Beep_(800, 100)
	Beep_(800, 300)
EndProcedure
Procedure	_BG(ID, x, y, t$, Flags=0)

	Protected	SIZE.SIZE

	ButtonGadget(ID, x, y, 1, 16, t$, Flags)
	SendMessage_(GadgetID(ID), #BCM_GETIDEALSIZE, 0, @SIZE)
	ResizeGadget(ID, #PB_Ignore, #PB_Ignore, SIZE\cx, #PB_Ignore)

	ProcedureReturn	GadgetWidth(ID)

EndProcedure
Procedure	_CG(ID, x, y, t$, Flags=0)

	Protected	SIZE.SIZE

	CheckBoxGadget(ID, x, y, 1, 14, t$, Flags)
	SendMessage_(GadgetID(ID), #BCM_GETIDEALSIZE, 0, @SIZE)
	ResizeGadget(ID, #PB_Ignore, #PB_Ignore, SIZE\cx, #PB_Ignore)

	ProcedureReturn	GadgetWidth(ID)

EndProcedure
Procedure	_Disable()

	DisableGadget(#G_IcoPath,	Bool(GetGadgetState(#IS_ICON)			=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_IcoSet,	Bool(GetGadgetState(#IS_ICON)			=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_OutPath,	Bool(GetGadgetState(#IS_OUTPATH)		=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_CONSTANT,	Bool(GetGadgetState(#IS_CONSTANT)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_UPXPath,	Bool(GetGadgetState(#IS_UPX)			=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_OutPath,	Bool(GetGadgetState(#IS_OUTPATH)		=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_ResSet,	Bool(GetGadgetState(#IS_RESOURCE)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_ResPath,	Bool(GetGadgetState(#IS_RESOURCE)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_ASM,		Bool(GetGadgetState(#IS_COMMENTED)	+	GetGadgetState(#IS_PREPROCESS)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#X86_Process,Bool(GetGadgetState(#G_ASM)			=	#PB_Checkbox_Unchecked))
	DisableGadget(#X64_Process,Bool(GetGadgetState(#G_ASM)			=	#PB_Checkbox_Unchecked))

	DisableGadget(#G_Custom_1, Bool(GetGadgetState(#IS_CUSTOM_1)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_Custom_2, Bool(GetGadgetState(#IS_CUSTOM_2)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_Custom_3, Bool(GetGadgetState(#IS_CUSTOM_3)	=	#PB_Checkbox_Unchecked))
	DisableGadget(#G_Custom_4, Bool(GetGadgetState(#IS_CUSTOM_4)	=	#PB_Checkbox_Unchecked))

	DisableGadget(#G_Processor, Bool(GetGadgetState(#IS_PROCESSOR)	=	#PB_Checkbox_Unchecked))

EndProcedure

Procedure$	StrSize(Value.d)

	Protected	s.d
	Protected	t$	; return param

	If	Value	<=	1024	; also negative size
		t$	=	FormatNumber(Value,0)	+	" Bytes"
		ProcedureReturn	t$
	ElseIf	Value	>=	Pow(1024,4)
		s	=	Value	/	Pow(1024,4)	:	t$	=	"TB"
	ElseIf	Value	>=	Pow(1024,3)
		s	=	Value	/	Pow(1024,3)	:	t$	=	"GB"
	ElseIf	Value	>=	Pow(1024,2)
		s	=	Value	/	Pow(1024,2)	:	t$	=	"MB"
	ElseIf	Value	>=	1024
		s	=	Value	/	1024.0		:	t$	=	"KB"
	EndIf

	t$	=	Trim(Trim(FormatNumber(s,2),"0"),".") + " " + t$
	t$	+	" ("	+	FormatNumber(Value,0)	+	")"	; Bytes

	ProcedureReturn	t$

EndProcedure
Procedure$	StrTime(Time)

	; Milliseconds to TimeString: HH:MM:SS,TTT

	;ProcedureReturn	FormatDate("%hh:%ii:%ss,", Time * 0.001)	+	Str(Time % 1000)

	Protected	t$

	t$	=	RSet(Str( Time / 3600000),				2, "0")	+	":"	+	; HH:
	  	 	RSet(Str((Time /   60000)	% 60),	2, "0")	+	":"	+	; MM:
	  	 	RSet(Str((Time /    1000)	% 60),	2, "0")					; SS

	If	(Time % 1000)	; Rest milliseconds?
		t$	+	","	+	RTrim(Str(Time % 1000), "0")	; ,TTT
	EndIf

	ProcedureReturn	t$

EndProcedure
Procedure$	Parent(Path$=#Null$, Dirs=1)

	Protected	Count

	If	Len(Path$)	<	1
		Path$	=	GetPathPart(ProgramFilename())
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
Procedure	SizeMode()

	Protected	t$

	Select	Mode_Size
		Case	1	:	SetGadgetItemText(#G_Sources, -1, "KB",	#LI_SIZE)
		Case	2	:	SetGadgetItemText(#G_Sources, -1, "KiB",	#LI_SIZE)
		Default	:	SetGadgetItemText(#G_Sources, -1, "Size",	#LI_SIZE)
	EndSelect

	ForEach	Entry()
		With	Entry()

			If	\SizePb
				Select	Mode_Size
					Case	1	:	t$	=	Str(Round(\SizePb * #KB,	#PB_Round_Up))
					Case	2	:	t$	=	Str(Round(\SizePb * #KIB,	#PB_Round_Up))
					Default	:	t$	=	FormatNumber(\SizePb, 0)
				EndSelect
				SetGadgetItemText(#G_Sources, ListIndex(Entry()), t$, #LI_SIZE)
			EndIf

			If	\SizeX86
				Select	Mode_Size
				Case	1	:	t$	=	Str(Round(\SizeX86 * #KB,	#PB_Round_Up))
				Case	2	:	t$	=	Str(Round(\SizeX86 * #KIB,	#PB_Round_Up))
				Default	:	t$	=	FormatNumber(\SizeX86, 0)
				EndSelect
				SetGadgetItemText(#G_Sources, ListIndex(Entry()), t$, #LI_X86)
			EndIf

			If	\SizeX64
				Select	Mode_Size
				Case	1	:	t$	=	Str(Round(\SizeX64 * #KB,	#PB_Round_Up))
				Case	2	:	t$	=	Str(Round(\SizeX64 * #KIB,	#PB_Round_Up))
				Default	:	t$	=	FormatNumber(\SizeX64, 0)
				EndSelect
				SetGadgetItemText(#G_Sources, ListIndex(Entry()), t$, #LI_X64)
			EndIf

		EndWith
	Next

EndProcedure
Procedure	_SetPath(Gadget, Path$)

	If	Len(Path$)	=	0	:	ProcedureReturn	#False	:	EndIf

	Protected	i, n=CountGadgetItems(Gadget)-1

	If	n	>=	#Null
		For	i	=	0	To	n
			If	UCase(GetGadgetItemText(Gadget, i))	=	UCase(Path$)
				RemoveGadgetItem(Gadget, i)
				Break
			EndIf
		Next
	EndIf

	AddGadgetItem(Gadget, 0, Path$)
	SetGadgetState(Gadget, 0)

	ProcedureReturn	#True

EndProcedure
Procedure	_RemPath(Gadget)

	If	CountGadgetItems(Gadget)
		RemoveGadgetItem(Gadget, 0)
		If	CountGadgetItems(Gadget)
			SetGadgetState(Gadget, 0)
		EndIf
	EndIf

	ProcedureReturn	CountGadgetItems(Gadget)

EndProcedure

Procedure	ViewText(File$, Format=#PB_Ascii)

	Static	hFont, x, y, w=800, h=600, m=#PB_Window_WindowCentered, t=3*7

	Protected	*Mem, Length.q, gE, gI, gR, gP, t$, Time.q, i, i$

	If	ReadFile(0, File$)
		Length	=	Lof(0)
		*Mem		=	AllocateMemory(Length + 4)
		ReadData(0, *Mem, Length)
		CloseFile(0)
	Else
		MA_Info("Error: cannot view " + GetFilePart(File$))
		ProcedureReturn
	EndIf

	If	hFont	=	0
		hFont	=	FontID(LoadFont(#PB_Any, "Courier new", 9))
	EndIf

	OpenWindow(1, x, y, w, h, File$, #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_SizeGadget|m, WindowID(0))

	gE	=	EditorGadget(#PB_Any, 4, 4,		w - 8, h - 30)
	gI	=	StringGadget(#PB_Any, 4, h - 24,	w - 8 - 32, 20, File$, #PB_String_ReadOnly)
	gR	=	ButtonGadget(#PB_Any, 4 + GadgetWidth(gI), GadgetY(gI), 32, 20, "Rem")

	;SendMessage_(GadgetID(gE), #EM_SETTEXTMODE, #TM_RICHTEXT, 0)
	SendMessage_(GadgetID(gE), #EM_SETTABSTOPS, 1, @t)

	SetGadgetFont(gE, hFont)
	AddGadgetItem(gE, 0, PeekS(*Mem, -1, Format))
	SendMessage_(GadgetID(gE), #EM_SETSEL, 0, 0)
	SetActiveGadget(gE)

	FreeMemory(*Mem)

	SetActiveWindow(1)

	Repeat
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Select	EventGadget()
					Case	gR	; remove remarks ";" or "//"
						x	=	CountGadgetItems(gE)	-	1
						DisableGadget(gR, 1)
						HideGadget(gI, 1)
						gP	=	ProgressBarGadget(#PB_Any, GadgetX(gI), GadgetY(gI), GadgetWidth(gI), GadgetHeight(gI), 0, x)
						For	i	=	0	To	x
							File$	=	GetGadgetItemText(gE, i)
							If	Left(File$, 1)	=	";"	And	Len(File$)	>	2	Or	Left(File$, 1)	=	"/"	And	Len(File$)	>	3	; ASM / C
								If	Time	<=	ElapsedMilliseconds()
									SetGadgetState(gP, i)
									While	WindowEvent()	:	Wend
									Time	=	ElapsedMilliseconds()	+	100
								EndIf
							Else
								t$ +	Trim(File$)	+	#LF$
							EndIf
						Next
						i	=	0
						If	FindString(t$, #LF$ + "//" + #LF$)
							i$	=	"//" + #LF$ + "//" + #LF$
						ElseIf	FindString(t$, #LF$ + ";" + #LF$)
							i$	=	";" + #LF$ + ";" + #LF$
						EndIf
						While	i	<>	Len(t$)
							i	=	Len(t$)
							t$	=	RemoveString(t$, i$)
						Wend
						SetGadgetState(gP, x)
						ClearGadgetItems(gE)
						AddGadgetItem(gE, 0, Trim(t$,#LF$))
						FreeGadget(gP)
						HideGadget(gI, 0)
						SendMessage_(GadgetID(gE), #EM_SETSEL, 0, 0)
						SetActiveGadget(gE)
				EndSelect
			Case	#PB_Event_SizeWindow
				w	=	WindowWidth(1)
				h	=	WindowHeight(1)
				ResizeGadget(gE, #PB_Ignore, #PB_Ignore,	w - 8, h - 30)
				ResizeGadget(gI, #PB_Ignore, h - 24,		w - 8, #PB_Ignore)
			Case	#PB_Event_CloseWindow
				Break
		EndSelect
	ForEver

	m	=	0
	x	=	WindowX(1)
	y	=	WindowY(1)

	FreeGadget(gE)
	FreeGadget(gI)
	CloseWindow(1)

EndProcedure
Procedure	ViewIcon(File$)

	Protected	i, w, Length.q=FileSize(File$)

	If	Length	>	0

		i	=	LoadImage(#PB_Any, File$)

		If	i	>	0

			MA_Info("View as icon: " + GetFilePart(File$) + " - Size: " + StrSize(Length))

			w	=	OpenWindow(#PB_Any, 0, 0, ImageWidth(i) + 80, ImageHeight(i) + 80, GetFilePart(File$), #PB_Window_WindowCentered|#PB_Window_SystemMenu, WindowID(0))
			ImageGadget(#PB_Any, (WindowWidth(w) - ImageWidth(i)) / 2, (WindowHeight(w) - ImageHeight(i)) / 2, ImageWidth(i), ImageHeight(i), ImageID(i))

			Repeat
				Select	WaitWindowEvent()
					Case	#PB_Event_CloseWindow	:	Break
				EndSelect
			ForEver

			FreeImage(i)
			CloseWindow(w)

		EndIf
	EndIf

	If	i	<=	#Null
		MA_Info("Error: cannot view " + GetFilePart(File$))
	EndIf

	While	WindowEvent()	:	Wend	:	Delay(5)

EndProcedure

Procedure	CheckCommented()

	; ASM-Output + checked sources in list

	Protected	n
	Protected	i	=	GetGadgetItemState(#G_Sources, GetGadgetState(#G_Sources))

	If	i	&	#PB_ListIcon_Selected
		SetGadgetText(#G_ASM, GetFilePart(GetGadgetText(#G_Sources)))
		DisableGadget(#G_ASM, Bool(i & #PB_ListIcon_Checked = 0 Or (GetGadgetState(#IS_COMMENTED) & #PB_Checkbox_Checked = 0 And GetGadgetState(#IS_PREPROCESS) & #PB_Checkbox_Checked = 0)))
	EndIf

	With	Entry()
		ForEach	Entry()

			i	=	ListIndex(Entry())

			\State	=	GetGadgetItemState(#G_Sources, i)

			If	\State	&	#PB_ListIcon_Checked
				n	+	1
				If	\Back	<>	#RGB_ON		:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #RGB_ON)		:	EndIf
			Else
				If	\Back	<>	#PB_Default	:	SetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor, #PB_Default)	:	EndIf
			EndIf

			\Back	=	GetGadgetItemColor(#G_Sources, i, #PB_Gadget_BackColor)

		Next
	EndWith

	SetGadgetItemText(#G_Sources, -1, "Sources: " + Str(n) + " / " + Str(ListSize(Entry())), #LI_FILE)
	SetActiveGadget(#G_Sources)

EndProcedure
Procedure	Scan_Full(Path$)

	; Recursiveley scan of Path$ + SubDirs

	Static	Time.q, tm

	If	GetGadgetState(#G_SrcSet)	=	0	:	ProcedureReturn	:	EndIf

	Protected	p$, f$, s.q, i

	; blinking to abort scan
	If	ElapsedMilliseconds()	>	Time
		tm	!	1
		If	tm
			SetGadgetText(#G_SrcSet, Chr($2716))
		Else
			SetGadgetText(#G_SrcSet, #Null$)
		EndIf
		Time	=	ElapsedMilliseconds()	+	500
	EndIf

	Path$	=	Trim(Path$, "\")	+	"\"

	If	GetGadgetState(#IS_OUTPATH)
		p$	=	GetGadgetText(#G_OutPath)
	Else
		p$	=	Path$
	EndIf

	MA_Info(Path$)	:	While	WindowEvent()	:	Wend	:	Delay(1)

	i	=	ExamineDirectory(#PB_Any, Path$, "")

	If	i

		While NextDirectoryEntry(i)

			f$	=	DirectoryEntryName(i)

			If DirectoryEntryType(i) = #PB_DirectoryEntry_File

				If	UCase(Right(f$, 3))	=	".PB"

					AddElement(Entry())

					With	Entry()

						\Path$	=	Path$
						\File$	=	f$
						\Entry$	=	Path$	+	f$
						\DatePb	=	DirectoryEntryDate(i, #PB_Date_Modified)
						\SizePb	=	DirectoryEntrySize(i)

						If	FindString(f$,		"defaultexample.pb",	1, #PB_String_NoCase)	=	0	And	; no C2D_DefaultExample.pb
						  	FindString(f$,		"_0",				1, #PB_String_NoCase)	=	0	And			; _000? tempfiles
						  	FindString(Path$,	"compile",		1, #PB_String_NoCase)	=	0	And			; no PureCompile
						  	FindString(Path$,	"temp",			1, #PB_String_NoCase)	=	0	And
						  	FindString(Path$,	"misc",			1, #PB_String_NoCase)	=	0	And
						  	FindString(Path$,	"sources",		1, #PB_String_NoCase)	=	0	And
						  	FindString(Path$,	"ampplayer",	1, #PB_String_NoCase)	=	0	And
						  	FindString(Path$,	"bootmenu",		1, #PB_String_NoCase)	=	0	And
						  	FindString(Path$,	"mmp",			1, #PB_String_NoCase)	=	0

							\State	=	#PB_ListIcon_Checked

						EndIf

						s	=	FileSize(p$	+	GetFilePart(\File$, #PB_FileSystem_NoExtension)	+	"_x86.exe")	:	If	s	>	0	:	\SizeX86	=	s	:	EndIf
						s	=	FileSize(p$	+	GetFilePart(\File$, #PB_FileSystem_NoExtension)	+	"_x64.exe")	:	If	s	>	0	:	\SizeX64	=	s	:	EndIf

					EndWith

				EndIf

			ElseIf	DirectoryEntryType(i) = #PB_DirectoryEntry_Directory

				If	f$	<>	"."	And	f$	<>	".."
					Scan_Full(Path$ + f$)	; recursively scan of sub-dirs
				EndIf

			EndIf

		Wend

		FinishDirectory(i)

	EndIf

EndProcedure
Procedure	ScanSources(Path$)

	; Get all PB sources

	Protected	Count, t$

	Mode_Size	=	#Null
	Mode_Sort	=	#Null

	ClearList(Entry())
	ClearGadgetItems(#G_Sources)
	SizeMode()	; always reset to bytesize
	SetGadgetItemText(#G_Sources, -1, "Scan...", 0)
	While	WindowEvent()	:	Wend	:	Delay(1)

	Path$	=	Trim(Path$, "\")	+	"\"

	SendMessage_(GadgetID(#G_Sources), #WM_SETREDRAW, 0, 0)

	SetGadgetText(#G_SrcSet, Chr($2716))
	SetGadgetState(#G_SrcSet, 1)

	Scan_Full(Path$)

	SetGadgetText(#G_SrcSet, #CHR_SEARCH$)
	SetGadgetState(#G_SrcSet, 0)

	Count	=	ListSize(Entry())

	DisableGadget(#X86_Create, Bool(Count=#Null))
	DisableGadget(#X64_Create, Bool(Count=#Null))

	If	Count

		With	Entry()

			ForEach	Entry()	; correct path

				\Entry$	=	RemoveString(\Entry$, Path$, #PB_String_NoCase)
				AddGadgetItem(#G_Sources, -1, \Entry$ + #LF$ + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", \DatePb) + #LF$ + FormatNumber(\SizePb, 0))

				If	\SizeX86
					SetGadgetItemText(#G_Sources, ListIndex(Entry()), FormatNumber(\SizeX86, 0), #LI_X86)
				EndIf
				If	\SizeX64
					SetGadgetItemText(#G_Sources, ListIndex(Entry()), FormatNumber(\SizeX64, 0), #LI_X64)
				EndIf

				SetGadgetItemState(#G_Sources, ListIndex(Entry()), \State)

			Next

			ForEach	Entry()
				If	\State	&	#PB_ListIcon_Checked
					\State	|	#PB_ListIcon_Selected
					SetGadgetState(#G_Sources, ListIndex(Entry()))
					Break
				EndIf
			Next

			If	GetGadgetState(#G_Sources)	<	#Null
				SetGadgetState(#G_Sources, 0)
			EndIf

		EndWith

	EndIf

	CheckCommented()

	SendMessage_(GadgetID(#G_Sources), #WM_SETREDRAW, 1, 0)

	MA_Info(Path$)

EndProcedure
Procedure	PrecompileSelected(Gadget)

	; Kuddelmuddel but works

	Protected	XP$, Compiler$, Add_Exe$, Path$, Param$, c$, SRC$, EXE$, OUT$, t$
	Protected	i

	If	ListSize(Entry())	=	#Null	:	ProcedureReturn	:	EndIf

	i	=	-1

	With	Entry()
		ForEach	Entry()
			\State	=	GetGadgetItemState(#G_Sources, ListIndex(Entry()))
			If	\State	&	#PB_ListIcon_Checked	And	\State	&	#PB_ListIcon_Selected
				i	=	ListIndex(Entry())
				Break
			EndIf
		Next
	EndWith
	If	i	<	#Null
		MA_Info("Aborted, nothing selected to precompile!")
		SetGadgetState(Gadget,#Null)
		ProcedureReturn	_FX()
	EndIf

	MA_Info("Precompile, please wait...")

	SelectElement(Entry(), i)
	Path$	=	GetTemporaryDirectory()	;Entry()\Path$
	SRC$	=	Entry()\Path$	+	Entry()\File$

	Select	Gadget
		Case	#X86_Process
			XP$	=	"x86"	:	Compiler$	=	GetGadgetText(#X86_Compiler)
		Case	#X64_Process
			XP$	=	"x64"	:	Compiler$	=	GetGadgetText(#X64_Compiler)
	EndSelect

	Add_Exe$	=	"_"	+	XP$	; suffix Filename_x86/_x64

	; /DLL ?
	If	GetGadgetState(#IS_DLL)
		Add_Exe$	+	".dll"
	Else
		Add_Exe$	+	".exe"
	EndIf

	; Param-Options XP-Theme & Icon
	If	GetGadgetState(#IS_DLL)	=	#PB_Checkbox_Checked
		Param$	+	"/DLL "
	EndIf
	If	GetGadgetState(#IS_THREAD)=	#PB_Checkbox_Checked
		Param$	+	"/THREAD "
	EndIf
	If	GetGadgetState(#IS_DPIAWARE)	=	#PB_Checkbox_Checked	; ab PB v5.70
		Param$	+	"/DPIAWARE "
	EndIf
	If	GetGadgetState(#IS_XP)		=	#PB_Checkbox_Checked
		Param$	+	"/XP "
	EndIf
	If	GetGadgetState(#IS_DLLPROTECTION)	=	#PB_Checkbox_Checked	; ab PB v6.04
		Param$	+	"/DLLPROTECTION "
	EndIf
	If	GetGadgetState(#IS_OPTIMIZER)	=	#PB_Checkbox_Checked
		Param$	+	"/OPTIMIZER "
	EndIf
	If	GetGadgetState(#IS_ICON)	=	#PB_Checkbox_Checked
		Param$	+	"/ICON "	+	MA_DQ(GetGadgetText(#G_IcoPath))
	EndIf

	If	GetGadgetState(#IS_RESOURCE)	=	#PB_Checkbox_Checked
		Param$	+	" /RESOURCE "	+	MA_DQ(GetGadgetText(#G_ResPath))	+	" "
	EndIf

	; Param-#Constant (#G_C2D=?)
	If	GetGadgetState(#IS_CONSTANT)	=	#PB_Checkbox_Checked	; #C2D_Z=Number
		c$	=	GetGadgetText(#G_CONSTANT)
		c$	=	RemoveString(c$, "#")
		c$	=	RemoveString(c$, " ")
		SetGadgetText(#G_CONSTANT, c$)
		If	ValF(StringField(c$, 2, "="))	>	0
			Param$	+	"/CONSTANT "	+	MA_DQ(c$)
		EndIf
	EndIf

	If	Param$
		Param$	=	Trim(Param$)
	EndIf

	EXE$	=	Path$	+	GetFilePart(SRC$, #PB_FileSystem_NoExtension)	+	Add_Exe$	; compiled exe

	;==========================================================================================================
	; Compile entries / create Purebasic.asm
	;==========================================================================================================
	If	GetGadgetState(#IS_COMMENTED)	=	#PB_Checkbox_Checked

		If	FindString(Compiler$, "c.exe", 1, #PB_String_NoCase)
			OUT$	=	"Purebasic.c"
		Else
			OUT$	=	"Purebasic.asm"
		EndIf

		EXE$	=	Path$ + OUT$	:	If	FileSize(EXE$)	:	DeleteFile(EXE$)	:	Delay(15)	:	EndIf

		t$	=	MA_DQ(SRC$)	+	" /COMMENTED /QUIET"

		If	RunProgram(Compiler$, t$, Path$, #PB_Program_Wait|#PB_Program_Hide)	>	#Null		; Purebasic.asm
			_FX()	; short hint
			EXE$	=	Path$ + OUT$
			If	FindString(Compiler$, "c.exe", 1, #PB_String_NoCase)
				OUT$	=	"_c_"
			Else
				OUT$	=	"_asm_"
			EndIf
			t$	=	Path$ + GetFilePart(SRC$, #PB_FileSystem_NoExtension) + OUT$ + XP$ + ".txt"
			If	FileSize(EXE$)	>	0
				If	FileSize(t$)	>	0
					DeleteFile(t$)	:	Delay(15)
				EndIf
				RenameFile(EXE$, t$)
			EndIf
			MA_Info("Done - file commented as: " + t$)
			;RunProgram(t$)	:	Delay(1000)
			ViewText(t$)
		Else
			MA_Info("Error.")
		EndIf

	Else	; Preprocess

		EXE$	=	Path$ + "Purebasic.pb"	:	If	FileSize(EXE$)	:	DeleteFile(EXE$)	:	Delay(15)	:	EndIf

		t$	=	MA_DQ(SRC$)	+	" /PREPROCESS " + EXE$

		If	RunProgram(Compiler$, t$, Path$, #PB_Program_Wait|#PB_Program_Hide)	>	#Null
			_FX()	; short hint
			EXE$	=	Path$ + "Purebasic.pb"
			t$	=	Path$ + GetFilePart(SRC$, #PB_FileSystem_NoExtension) + "_pp_" + XP$ + ".txt"
			If	FileSize(EXE$)	>	0
				If	FileSize(t$)	>	0
					DeleteFile(t$)	:	Delay(15)
				EndIf
				RenameFile(EXE$, t$)
			EndIf
			MA_Info("Done - file processed as: " + t$)
			;RunProgram(t$)	:	Delay(1000)
			ViewText(t$)
		Else
			MA_Info("Error.")
		EndIf

	EndIf

EndProcedure
Procedure	CompileSources(Gadget)

	; Kuddelmuddel but works

	Protected	b_t$, XP$, Compiler$, Add_Exe$, Path$, Param$, c$, SRC$, EXE$, OUT$, t$, p$, n$
	Protected	Time, i, p, Item_Default, LI_X
	Protected	exe_size, upx_size, exe_time, exe_total.q, upx_total.q

	If	ListSize(Entry())	=	#Null	:	ProcedureReturn	:	EndIf

	With	Entry()
		ForEach	Entry()
			\State	=	GetGadgetItemState(#G_Sources, ListIndex(Entry()))
			If	\State	&	#PB_ListIcon_Checked
				i	=	#True
			EndIf
		Next
	EndWith
	If	i	=	#False
		MA_Info("Aborted, nothing activated to compile!")
		SetGadgetState(Gadget,#Null)
		ProcedureReturn	_FX()
	EndIf

	Mode_Size	=	#Null	:	SizeMode()	; reset always to bytesize

	MA_Info("Compile, please wait...")

	For	i	=	#G_GADGET_START	To	#G_GADGET_END
		If	i	<>	Gadget	And	IsGadget(i)	And	GadgetType(i)	<>	#PB_GadgetType_ListIcon
			DisableGadget(i, 1)
		EndIf
	Next
	While	WindowEvent()	:	Wend	:	Delay(8)

	Item_Default	=	GetGadgetState(#G_Sources)

	; clear old compiled sizes
	ForEach	Entry()
		Select	Gadget
			Case	#X86_Create	:	SetGadgetItemText(#G_Sources, ListIndex(Entry()), #Null$, #LI_X86)	:	Entry()\SizeX86	=	#Null
			Case	#X64_Create	:	SetGadgetItemText(#G_Sources, ListIndex(Entry()), #Null$, #LI_X64)	:	Entry()\SizeX64	=	#Null
		EndSelect
	Next

	; Get buttontext to restore "Compile x86/64"
	b_t$	=	GetGadgetText(Gadget)	:	SetGadgetText(Gadget, #CHR_ABORT$ + " Abort")

	Select	Gadget
		Case	#X86_Create
			LI_X			=	#LI_X86
			XP$			=	"x86"
			Compiler$	=	GetGadgetText(#X86_Compiler)
		Case	#X64_Create
			LI_X			=	#LI_X64
			XP$			=	"x64"
			Compiler$	=	GetGadgetText(#X64_Compiler)
	EndSelect

	Add_Exe$	=	"_"	+	XP$	; suffix Filename_x86/_x64

	; /DLL ?
	If	GetGadgetState(#IS_DLL)
		Add_Exe$	+	".dll"
	Else
		Add_Exe$	+	".exe"
	EndIf

	; Create all exes in outpath?
	If	GetGadgetState(#IS_OUTPATH)	=	#PB_Checkbox_Checked
		Path$	=	GetGadgetText(#G_OutPath)
	EndIf

	If	GetGadgetState(#IS_CUSTOM_1)	:	Param$	+	Trim(GetGadgetText(#G_Custom_1))	+	Space(1)	:	EndIf	;"/UCRT"
	If	GetGadgetState(#IS_CUSTOM_2)	:	Param$	+	Trim(GetGadgetText(#G_Custom_2))	+	Space(1)	:	EndIf	;"/ADMINISTRATOR"
	If	GetGadgetState(#IS_CUSTOM_3)	:	Param$	+	Trim(GetGadgetText(#G_Custom_3))	+	Space(1)	:	EndIf	;"/USER /CONSOLE"
	If	GetGadgetState(#IS_CUSTOM_4)	:	Param$	+	Trim(GetGadgetText(#G_Custom_4))	+	Space(1)	:	EndIf	;"/USER /CONSOLE"

	If	GetGadgetState(#IS_PROCESSOR)	:	Param$	+	Trim(GetGadgetText(#G_Processor))	+	Space(1)	:	EndIf	; Processor

	; Param-Options XP-Theme & Icon
	If	GetGadgetState(#IS_DLL)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_DLL$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_THREAD)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_THREAD$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_DPIAWARE)	=	#PB_Checkbox_Checked	; ab PB v5.70
		Param$	+	#PARAM_DPIAWARE$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_XP)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_XP$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_DYNAMICCPU)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_DYNAMICCPU$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_OPTIMIZER)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_OPTIMIZER$	+	Space(1)
	EndIf
	If	GetGadgetState(#IS_DLLPROTECTION)	=	#PB_Checkbox_Checked	; ab PB v6.04
		Param$	+	#PARAM_DLLPROTECTION$	+	Space(1)
	EndIf

	If	GetGadgetState(#IS_ICON)	=	#PB_Checkbox_Checked
		Param$	+	#PARAM_ICON$	+	Space(1)	+	MA_DQ(GetGadgetText(#G_IcoPath))
	EndIf

	If	GetGadgetState(#IS_RESOURCE)	=	#PB_Checkbox_Checked
		Param$	+	Space(1)	+	#PARAM_RESOURCE$	+	Space(1)	+	MA_DQ(GetGadgetText(#G_ResPath))	+	Space(1)
	EndIf

	; Param-#Constant (#G_C2D=?)
	If	GetGadgetState(#IS_CONSTANT)	=	#PB_Checkbox_Checked	; #C2D_Z=Number
		c$	=	GetGadgetText(#G_CONSTANT)
		c$	=	RemoveString(c$, "#")
		c$	=	RemoveString(c$, " ")
		SetGadgetText(#G_CONSTANT, c$)
		If	ValF(StringField(c$, 2, "="))	>	0
			Param$	+	#PARAM_CONSTANT$	+	Space(1)	+	MA_DQ(c$)
		EndIf
	EndIf

	If	Param$
		Param$	=	Trim(Param$)
	EndIf

	exe_time	=	ElapsedMilliseconds()

	;==========================================================================================================
	; Compile entries / create Purebasic.asm
	;==========================================================================================================
	ForEach	Entry()
		With	Entry()
			If	\State	&	#PB_ListIcon_Checked

				; Include Ressource? -> Only the selected will be compiled!
				If	GetGadgetState(#IS_RESOURCE)	&	#PB_Checkbox_Checked
					If	\State	&	#PB_ListIcon_Selected	=	0	:	Continue	:	EndIf
				EndIf

				i	=	ListIndex(Entry())

				SRC$	=	\Path$	+	\File$	; pb sourcefile

				If	GetGadgetState(#IS_OUTPATH)	=	#PB_Checkbox_Unchecked
					Path$	=	GetPathPart(SRC$)
				EndIf

				EXE$	=	Path$	+	GetFilePart(SRC$, #PB_FileSystem_NoExtension)	+	Add_Exe$	; compiled exe

				;====================================================================================================
				;{ *** /EXE create all [/DLL /THREAD /XP /ICON /DPIAWARE /DLLPROTECTION]
				;====================================================================================================
				If	FileSize(EXE$)	>	0	:	DeleteFile(EXE$, #PB_FileSystem_Force)	:	EndIf	; allways delete exe

				SetGadgetState(#G_Sources, i)	:	SetGadgetItemText(#G_Sources, i, "compile...", LI_X)	:	UpdateWindow_(GadgetID(#G_Sources))

				t$	=	MA_DQ(SRC$)	+	" /EXE "	+	MA_DQ(EXE$)	; <- Default always /EXE!!!

				If	Param$	:	t$	+	Space(1)	+	Param$	:	EndIf	; <- use params? (/DLL /THREAD icon/xp-theme)

				;Debug	MA_DQ(Compiler$) + " " + t$

				; *** Compile ***
				p	=	RunProgram(Compiler$, t$, GetPathPart(Compiler$), #PB_Program_Wait|#PB_Program_Hide)

				exe_size	=	FileSize(EXE$)	; compied size

				If	p	>	#Null	And	exe_size	>	0

					exe_total	+	exe_size

					; +++++++++++++++++++++
					; *** UPX compress? ***
					; +++++++++++++++++++++
					If	GetGadgetState(#IS_UPX)	=	#PB_Checkbox_Checked
						p	=	RunProgram(UPX$, "--best --ultra-brute -q " + MA_DQ(EXE$), GetPathPart(EXE$), #PB_Program_Open|#PB_Program_Hide)
						If	p
							While	ProgramRunning(p)
								If	WindowEvent()	=	0
									If	ElapsedMilliseconds()	>	Time
										n$	+	"."	:	If	Len(n$)	>	3	:	n$	=	""	:	EndIf
										SetGadgetItemText(#G_Sources, i, "compress" + n$, LI_X)
										Delay(1)	:	Time	=	ElapsedMilliseconds()	+	500
									EndIf
								EndIf
							Wend
							CloseProgram(p)
							exe_size		=	FileSize(EXE$)
							upx_total	+	exe_size
						Else
							SetGadgetState(#IS_UPX, #PB_Checkbox_Unchecked)	; no upx? no compressing at all!
						EndIf
					EndIf

					If	LI_X	=	#LI_X86
						\SizeX86	=	exe_size
					Else
						\SizeX64	=	exe_size
					EndIf

					;SetGadgetItemText(#G_Sources, i, Str(Round(exe_size * #KB, #PB_Round_Up)), LI_X)
					SetGadgetItemText(#G_Sources, i, FormatNumber(exe_size, 0), LI_X)

				Else
					Item_Default	=	i
					SetGadgetItemText(#G_Sources, i, Str(p) + " ERROR", LI_X)
					Break
				EndIf
				;}
				;====================================================================================================
			EndIf

			; Info about compiled sources
			If	GetGadgetState(#IS_DLL)	=	#PB_Checkbox_Checked
				t$	=	"DLL: "
			Else
				t$	=	"EXE: "
			EndIf
			t$	+	StrSize(exe_total)
			If	upx_total
				t$	+	" - UPX: " + StrSize(upx_total) + " - Gain: " + StrSize(exe_total-upx_total) + " - Ø: " + StrF((100.0 / exe_total) * upx_total, 2) + "%"
			EndIf
			t$	+	" - Time: " + StrTime(ElapsedMilliseconds() - exe_time)

			MA_Info(t$)

			If	Not	GetGadgetState(Gadget)	; Abort?
				Break
			ElseIf	p
				While	WindowEvent()	:	Wend	:	Delay(100)
			EndIf

			p	=	#Null

		EndWith
	Next

	SetGadgetState(#G_Sources, Item_Default)
	SetGadgetText(Gadget, b_t$)	; "Compile x86/64"
	SetGadgetState(Gadget,#Null)	; off

	For	i	=	#G_GADGET_START	To	#G_GADGET_END
		If	i	<>	Gadget	And	IsGadget(i)	And	GadgetType(i)	<>	#PB_GadgetType_ListIcon	And	GadgetType(i)	<>	#PB_GadgetType_Text
			DisableGadget(i, 0)
		EndIf
	Next

	_Disable()

	_FX()	; short hint

EndProcedure

Procedure	SetCompileTheme(Gadget)

	; set quick predefined compile options

	Protected	Path$	=	Parent(#Null$, 2), i

	SetGadgetState(#IS_OUTPATH,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_DLL,			#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_RESOURCE,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_COMMENTED,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_PREPROCESS,#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_DPIAWARE,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_THREAD,		#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_CONSTANT,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_DYNAMICCPU,#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_UPX,			#PB_Checkbox_Unchecked)	; avoid fals/true
	SetGadgetState(#IS_CUSTOM_1,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_CUSTOM_2,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_CUSTOM_3,	#PB_Checkbox_Unchecked)
	SetGadgetState(#IS_PROCESSOR,	#PB_Checkbox_Unchecked)

	_SetPath(#G_IcoPath,	Path$	+	"Data\Icon\ProjectSmall.ico")
	_SetPath(#G_ResPath,	Path$	+	"Data\Misc\Amiga20.rc")

	Select	Gadget

		Case	#G_SetDemos

			SetGadgetState(#IS_ICON,	#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_XP,		#PB_Checkbox_Unchecked)

			_SetPath(#G_SrcPath, Path$	+	"Demos\")

		Case	#G_SetExamples

			SetGadgetState(#IS_OUTPATH,#PB_Checkbox_Checked)
			SetGadgetState(#IS_ICON,	#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_XP,		#PB_Checkbox_Unchecked)

			_SetPath(#G_SrcPath, Path$	+	"Examples\")
			_SetPath(#G_OutPath, Path$	+	"Executables\")

		Case	#G_SetTools, #G_SetBall3D, #G_SetLine3D, #G_SetAMP, #G_SetTest, #G_SetSplatter

			SetGadgetState(#IS_ICON,	#PB_Checkbox_Checked)
			SetGadgetState(#IS_XP,		#PB_Checkbox_Checked)

			Path$	+	"Tools\"

			Select	Gadget
				Case	#G_SetAMP		:	_SetPath(#G_SrcPath, Path$	+	"AmpInstaller\")
				Case	#G_SetBall3D	:	_SetPath(#G_SrcPath, Path$	+	"C2D_Ball3DEditor\")
				Case	#G_SetLine3D	:	_SetPath(#G_SrcPath, Path$	+	"C2D_Line3DEditor\")
				Case	#G_SetTest		:	_SetPath(#G_SrcPath, Path$	+	"C2D_CanvasTest\")
				Case	#G_SetTools		:	_SetPath(#G_SrcPath, Path$)
				Case	#G_SetSplatter	:	_SetPath(#G_SrcPath, Path$	+	"C2D_SplatterEditor\")
			EndSelect

		Case	#G_SetBoot

			SetGadgetState(#IS_ICON,	#PB_Checkbox_Checked)
			SetGadgetState(#IS_XP,		#PB_Checkbox_Unchecked)

			_SetPath(#G_SrcPath, Path$	+	"Tools\BootMenu\")

		Case	#G_SetExe

			SetGadgetState(#IS_ICON,	#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_XP,		#PB_Checkbox_Checked)

		Case	#G_SetDLL

			SetGadgetState(#IS_DLL,			#PB_Checkbox_Checked)
			SetGadgetState(#IS_DPIAWARE,	#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_THREAD,		#PB_Checkbox_Checked)
			SetGadgetState(#IS_ICON,		#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_XP,			#PB_Checkbox_Unchecked)

	EndSelect

	If	Gadget	<>	#G_SetExe	And	Gadget	<>	#G_SetDLL
		ScanSources(GetGadgetText(#G_SrcPath))
	EndIf

	If	CountGadgetItems(#G_Sources)	=	1
		SetGadgetItemState(#G_Sources, 0, #PB_ListIcon_Checked)
		CheckCommented()
		SetGadgetState(#G_Sources, 0)
	EndIf

	_Disable()

	;_SetPath(#G_SrcPath, Path$)

EndProcedure

Procedure	Prefs(Gadget)

	Static	Path$
	Protected	t$, i$, i

	If	Len(Path$)	=	0	:	Path$	=	GetPathPart(ProgramFilename())	:	EndIf

	Select	Gadget
		Case	#G_SavePref
			t$	=	SaveFileRequester("Save preferences as...", Path$, "Preferences (*.prefs)|*.prefs|All files (*.*)|*.*", 0)
			If	t$
				Path$	=	t$
				PathRenameExtension_(@Path$, @".prefs")
				If	CreatePreferences(Path$, #PB_Preference_NoSpace)
					PreferenceGroup("PureCompile")

					WritePreferenceInteger("IsDLL",		GetGadgetState(#IS_DLL))
					WritePreferenceInteger("IsTHREAD",	GetGadgetState(#IS_THREAD))
					WritePreferenceInteger("IsDPI",		GetGadgetState(#IS_DPIAWARE))
					WritePreferenceInteger("IsXP",		GetGadgetState(#IS_XP))
					WritePreferenceInteger("IsOPT",		GetGadgetState(#IS_OPTIMIZER))
					WritePreferenceInteger("IsCONSTANT",GetGadgetState(#IS_CONSTANT))
					WritePreferenceInteger("IsASM",		GetGadgetState(#IS_COMMENTED))
					WritePreferenceInteger("IsPRE",		GetGadgetState(#IS_PREPROCESS))

					PreferenceGroup("UPX")
					WritePreferenceInteger("IsUPX", GetGadgetState(#IS_UPX))
					WritePreferenceString("0",	UPX$)

					PreferenceGroup("Icopath")
					WritePreferenceInteger("IsICO", GetGadgetState(#IS_ICON))
					For	i	=	0	To	CountGadgetItems(#G_IcoPath)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#G_IcoPath, i))
					Next

					PreferenceGroup("Srcpath")
					For	i	=	0	To	CountGadgetItems(#G_SrcPath)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#G_SrcPath, i))
					Next

					PreferenceGroup("Outpath")
					WritePreferenceInteger("IsOut", GetGadgetState(#IS_OUTPATH))
					For	i	=	0	To	CountGadgetItems(#G_OutPath)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#G_OutPath, i))
					Next

					PreferenceGroup("Ressource")
					WritePreferenceInteger("IsRC", GetGadgetState(#IS_RESOURCE))
					For	i	=	0	To	CountGadgetItems(#G_ResPath)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#G_ResPath, i))
					Next

					PreferenceGroup("X86Compiler")
					For	i	=	0	To	CountGadgetItems(#X86_Compiler)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#X86_Compiler, i))
					Next

					PreferenceGroup("X64Compiler")
					For	i	=	0	To	CountGadgetItems(#X64_Compiler)	-	1
						WritePreferenceString(Str(i),	GetGadgetItemText(#X64_Compiler, i))
					Next

					PreferenceGroup("Param")
					WritePreferenceInteger("IsC1", GetGadgetState(#IS_CUSTOM_1))	:	WritePreferenceString("C1", GetGadgetText(#G_Custom_1))
					WritePreferenceInteger("IsC2", GetGadgetState(#IS_CUSTOM_2))	:	WritePreferenceString("C2", GetGadgetText(#G_Custom_2))
					WritePreferenceInteger("IsC3", GetGadgetState(#IS_CUSTOM_3))	:	WritePreferenceString("C3", GetGadgetText(#G_Custom_3))
					WritePreferenceInteger("IsC4", GetGadgetState(#IS_CUSTOM_4))	:	WritePreferenceString("C4", GetGadgetText(#G_Custom_4))

					WritePreferenceInteger("IsProcessor", GetGadgetState(#IS_PROCESSOR))	:	WritePreferenceInteger("Processor", GetGadgetState(#G_Processor))

					ClosePreferences()
					MA_Info("Preferences saved as: " + Path$)

				Else
					MA_Info("Error - can't save: " + Path$)
				EndIf
			EndIf

		Case	#G_OpenPref
			t$	=	OpenFileRequester("Open preferences...", Path$, "Preferences (*.prefs)|*.prefs|All files (*.*)|*.*", 0)
			If	t$
				Path$	=	t$
				PathRenameExtension_(@Path$, @".prefs")
				If	OpenPreferences(Path$, #PB_Preference_NoSpace)
					If	PreferenceGroup("PureCompile")

						SetGadgetState(#IS_DLL,			ReadPreferenceInteger("IsDLL",		#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_THREAD,		ReadPreferenceInteger("IsTHREAD",	#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_DPIAWARE,	ReadPreferenceInteger("IsDPI",		#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_XP,			ReadPreferenceInteger("IsXP",			#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_OPTIMIZER,	ReadPreferenceInteger("IsOPT",		#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_CONSTANT,	ReadPreferenceInteger("IsCONSTANT",	#PB_Checkbox_Unchecked))

						SetGadgetState(#IS_COMMENTED,	ReadPreferenceInteger("IsASM",		#PB_Checkbox_Unchecked))
						SetGadgetState(#IS_PREPROCESS,ReadPreferenceInteger("IsPP",			#PB_Checkbox_Unchecked))

						PreferenceGroup("UPX")
						SetGadgetState(#IS_UPX, ReadPreferenceInteger("IsUPX", #PB_Checkbox_Unchecked))
						UPX$	=	ReadPreferenceString("UPX_PATH",	UPX$)

						PreferenceGroup("Ressource")
						SetGadgetState(#IS_RESOURCE, ReadPreferenceInteger("IsRC", #PB_Checkbox_Unchecked))
						i	=	1	:	While	_SetPath(#G_ResPath, ReadPreferenceString(Str(i), #Null$))		:	i	+	1	:	Wend	:	_SetPath(#G_ResPath, ReadPreferenceString("0", #Null$))

						PreferenceGroup("Icopath")
						SetGadgetState(#IS_ICON, ReadPreferenceInteger("IsICO", #PB_Checkbox_Unchecked))
						i	=	1	:	While	_SetPath(#G_IcoPath,	ReadPreferenceString(Str(i), #Null$))		:	i	+	1	:	Wend	:	_SetPath(#G_IcoPath,	ReadPreferenceString("0", #Null$))

						PreferenceGroup("Outpath")
						SetGadgetState(#IS_OUTPATH, ReadPreferenceInteger("IsOut", #PB_Checkbox_Unchecked))
						i	=	1	:	While	_SetPath(#G_OutPath,	ReadPreferenceString(Str(i), #Null$))		:	i	+	1	:	Wend	:	_SetPath(#G_OutPath,	ReadPreferenceString("0", #Null$))

						PreferenceGroup("Srcpath")
						i	=	1	:	While	_SetPath(#G_SrcPath,	ReadPreferenceString(Str(i), #Null$))		:	i	+	1	:	Wend	:	_SetPath(#G_SrcPath,	ReadPreferenceString("0", #Null$))

						PreferenceGroup("X86Compiler")
						i	=	1	:	While	_SetPath(#X86_Compiler,	ReadPreferenceString(Str(i), #Null$))	:	i	+	1	:	Wend	:	_SetPath(#X86_Compiler,	ReadPreferenceString("0", #Null$))

						PreferenceGroup("X64Compiler")
						i	=	1	:	While	_SetPath(#X64_Compiler,	ReadPreferenceString(Str(i), #Null$))	:	i	+	1	:	Wend	:	_SetPath(#X64_Compiler,	ReadPreferenceString("0", #Null$))

						PreferenceGroup("Param")
						SetGadgetState(#IS_CUSTOM_1, ReadPreferenceInteger("IsC1", #PB_Checkbox_Unchecked))	:	SetGadgetText(#G_Custom_1, ReadPreferenceString("C1", GetGadgetText(#G_Custom_1)))
						SetGadgetState(#IS_CUSTOM_2, ReadPreferenceInteger("IsC2", #PB_Checkbox_Unchecked))	:	SetGadgetText(#G_Custom_2, ReadPreferenceString("C2", GetGadgetText(#G_Custom_2)))
						SetGadgetState(#IS_CUSTOM_3, ReadPreferenceInteger("IsC3", #PB_Checkbox_Unchecked))	:	SetGadgetText(#G_Custom_3, ReadPreferenceString("C3", GetGadgetText(#G_Custom_3)))
						SetGadgetState(#IS_CUSTOM_4, ReadPreferenceInteger("IsC4", #PB_Checkbox_Unchecked))	:	SetGadgetText(#G_Custom_4, ReadPreferenceString("C4", GetGadgetText(#G_Custom_4)))

						SetGadgetState(#IS_PROCESSOR, ReadPreferenceInteger("IsC4", #PB_Checkbox_Unchecked))	:	SetGadgetState(#G_Processor,ReadPreferenceInteger("C4",GetGadgetState(#G_Processor)))

						ScanSources(GetGadgetText(#G_SrcPath))
						MA_Info("Preferences installed: " + Path$)

					Else
						MA_Info("Error - not a valid preferences!")
					EndIf
					ClosePreferences()
				Else
					MA_Info("Error - can't open: " + Path$)
				EndIf
			EndIf

		Case	#G_Default

			UPX$	=	"..\UPX\upx_x64.exe"

			_SetPath(#G_SrcPath, 	PB_Path$)
			_SetPath(#G_OutPath, 	EXE_Path$)
			_SetPath(#G_IcoPath,		ICO_Path$)
			_SetPath(#X86_Compiler,	X86_Compiler$)
			_SetPath(#X64_Compiler,	X64_Compiler$)

			SetGadgetState(#IS_ICON,			#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_DLLPROTECTION,#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_XP,				#PB_Checkbox_Unchecked)
			SetGadgetState(#IS_OPTIMIZER,		#PB_Checkbox_Checked)

			SetCompileTheme(#G_Default)

			MA_Info("Defaults restored.")

	EndSelect

	_Disable()

EndProcedure

; Set defaults here
UPX$				=	"..\UPX\upx_x64.exe"
PB_Path$			=	Parent(#Null$, 2)	+	"Examples\"
EXE_Path$		=	Parent(#Null$, 2)	+	"Executables\"
ICO_Path$		=	Parent(#Null$, 2)	+	"Data\Icon\ProjectSmall.ico"
X86_Compiler$	=	#PB_Compiler_Home	+	"Compilers\pbcompiler.exe"
X64_Compiler$	=	#PB_Compiler_Home	+	"x64\Compilers\pbcompiler.exe"

Define	t$
Define	Gadget, x, y, i, *hLIC
Define	Align.LV_COLUMN

;{ *** GUI *** }
OpenWindow(0, 0, 0, #SCR_W, #SCR_H + 24, "C2D::Compiler v" + #VER$, #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
CreateStatusBar(0, WindowID(0))
AddStatusBarField(#SCR_W * 0.72)
AddStatusBarField(#SCR_W * 0.28)
StatusBarText(0, 1, FormatDate("C2D::Compiler v" + #VER$ + " ® %dd.%mm.%yyyy %hh:%ii:%ss", #PB_Compiler_Date))

LoadFont(0, #Null$, 7, #PB_Font_Bold)
LoadFont(1, #Null$, 7)
LoadFont(2, #Null$, 8, #PB_Font_Bold)

SetGadgetFont(#PB_Default, FontID(1))

SendMessage_(StatusBarID(0), #WM_SETFONT, FontID(1), 0)
SendMessage_(StatusBarID(0), #WM_SETFONT, FontID(1), 1)

x	=	4	:	y	=	4

;SetGadgetFont(TextGadget(#PB_Any, x, y-2, 180, 11, "Inputpath of Purebasic sources (*.pb)"), FontID(0))	:	y	+	13
ButtonGadget(#G_SrcSet,	x, y, 24, #GAD_H, Chr($2026), #PB_Button_Toggle)	:	SetGadgetFont(#G_SrcSet, #PB_Default)	:	x	+	GadgetWidth(#G_SrcSet)		+	2
ComboBoxGadget(#G_SrcPath,x, y, #SCR_W - x - 30 - 26, #GAD_H)	:	x	+	GadgetWidth(#G_SrcPath)		+	2	:	SetGadgetFont(#G_SrcPath,	#PB_Default)
ButtonGadget(#G_SrcRemove,x, y, 24, #GAD_H, #CHR_REMOVE$)		:	x	+	GadgetWidth(#G_SrcRemove)	+	2	:	SetGadgetFont(#G_SrcRemove,#PB_Default)
ButtonGadget(#G_SrcOpen,x, y, 24, #GAD_H, #CHR_OPEN$)	:	SetGadgetFont(#G_SrcOpen, #PB_Default)

AddGadgetItem(#G_SrcPath, 0, PB_Path$)

x	=	4	:	y	+	GadgetHeight(#G_SrcSet)	+	4

*hLIC	=	ListIconGadget(#G_Sources, x, y, #SCR_W - 8, 220, #Null$, #SCR_W - 29 - 3 * 70 - 104, #PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
AddGadgetColumn(#G_Sources, #LI_SIZE,"Size",70)
AddGadgetColumn(#G_Sources, #LI_DATE,"Modified",104)
AddGadgetColumn(#G_Sources, #LI_X86, "x86", 70)
AddGadgetColumn(#G_Sources, #LI_X64, "x64", 70)

Align\mask	=	#LVCF_FMT
Align\fmt	=	#LVCFMT_RIGHT
SendMessage_(*hLIC, #LVM_SETCOLUMN, #LI_SIZE,@Align)
Align\fmt	=	#LVCFMT_CENTER
SendMessage_(*hLIC, #LVM_SETCOLUMN, #LI_X86, @Align)
SendMessage_(*hLIC, #LVM_SETCOLUMN, #LI_X64, @Align)

x	=	#SCR_W	-	32	:	y	+	GadgetHeight(#G_Sources)

ButtonGadget(#G_Swp, x, y, 28, 16, "Swp")	:	x	-	28
ButtonGadget(#G_Off, x, y, 28, 16, "Off")	:	x	-	28
ButtonGadget(#G_All, x, y, 28, 16, "All")	:	x	-	28
ButtonGadget(#G_See, x, y, 28, 16, "View")

x	=	4

x	+	_BG(#G_SavePref,	x, y, "Save Pref")
x	+	_BG(#G_OpenPref,	x, y, "Load Pref")
x	+	_BG(#G_Default,	x, y, "Default")	+	4

x	+	_BG(#G_SetExamples,	x, y, "Examples")
x	+	_BG(#G_SetDemos,		x, y, "Demos")
x	+	_BG(#G_SetBoot,		x, y, "Boot")
x	+	_BG(#G_SetBall3D,		x, y, "Ball3D")
x	+	_BG(#G_SetLine3D,		x, y, "Line3D")
x	+	_BG(#G_SetSplatter,	x,	y,	"Splatter")
x	+	_BG(#G_SetTest,		x, y, "TestC2D")
x	+	_BG(#G_SetTools,		x, y, "Tools")	+	4
x	+	_BG(#G_SetAMP,			x, y, "Amp")	+	4

x	+	_BG(#G_SetEXE,	x, y, "EXE")
x	+	_BG(#G_SetDLL,	x, y, "DLL")	+	4

x	+	_BG(#G_SetSize,x,	y,	"Size/KB")

x	=	4	:	y	=	GadgetY(#G_Sources)	+	GadgetHeight(#G_Sources)	+	#GAD_H	+	4

CheckBoxGadget(#IS_OUTPATH,x, y, 338, 14, "Outputpath for compiled executables (*.exe ; *.dll) - default: Inputpath")	:	SetGadgetFont(#IS_OUTPATH, FontID(0))	:	y	+	15
ButtonGadget(#G_OutSet,		x, y, 24, #GAD_H, #CHR_SEARCH$)		:	x	+	26	:	SetGadgetFont(#G_OutSet,	#PB_Default)
ComboBoxGadget(#G_OutPath,	x, y, #SCR_W - x - 30 - 26, #GAD_H)	:	x	+	GadgetWidth(#G_OutPath)	+	2	:	SetGadgetFont(#G_OutPath,	#PB_Default)
ButtonGadget(#G_OutRemove,	x, y, 24, #GAD_H, #CHR_REMOVE$)		:	x	+	26	:	SetGadgetFont(#G_OutRemove, #PB_Default)
ButtonGadget(#G_OutOpen,	x, y, 24, #GAD_H, #CHR_OPEN$)			:	SetGadgetFont(#G_OutOpen, #PB_Default);FontID(2))

AddGadgetItem(#G_OutPath, 0, EXE_Path$)

x	=	4	:	y	+	#GAD_H	+	10

SetGadgetFont(TextGadget(#PB_Any, x, y, 160, 12, "Purebasic Compiler x86 / x64"), FontID(0))
SetGadgetFont(TextGadget(#PB_Any, #SCR_W - 102, y, 98, 12, "Create executable"),FontID(0))

y	+	13

ButtonGadget(#X86_Open,			x, y, 40, #GAD_H, "x86")					:	x	+	GadgetWidth(#X86_Open)		+	2
ComboBoxGadget(#X86_Compiler,	x, y, #SCR_W - x - 104 - 48,	#GAD_H)	:	x	+	GadgetWidth(#X86_Compiler)	+	2	:	SetGadgetFont(#X86_Compiler,	#PB_Default)
ButtonGadget(#X86_Copy,			x, y, 24, #GAD_H, #CHR_COPY$)				:	x	+	GadgetWidth(#X86_Copy)		+	2	:	SetGadgetFont(#X86_Copy,		#PB_Default)
ButtonGadget(#X86_Remove,		x, y, 24, #GAD_H, #CHR_REMOVE$)			:	x	+	GadgetWidth(#X86_Remove)	+	2	:	SetGadgetFont(#X86_Remove,		#PB_Default)
ButtonGadget(#X86_Create,		x, y, #SCR_W - x - 4, #GAD_H, #CHR_COMPILE$ + " Compile x86", #PB_Button_Toggle)	:	SetGadgetFont(#X86_Create, 	#PB_Default);FontID(2))

AddGadgetItem(#X86_Compiler, 0, #PB_Compiler_Home	+	"Compilers\pbcompilerc.exe")
AddGadgetItem(#X86_Compiler, 0, X86_Compiler$)

x	=	4	:	y	+	#GAD_H	+	2

ButtonGadget(#X64_Open,			x, y, 40, #GAD_H, "x64")					:	x	+	GadgetWidth(#X64_Open)		+	2
ComboBoxGadget(#X64_Compiler,	x, y, #SCR_W - x - 104 - 48, #GAD_H)	:	x	+	GadgetWidth(#X64_Compiler)	+	2	:	SetGadgetFont(#X64_Compiler,	#PB_Default)
ButtonGadget(#X64_Copy,			x, y, 24, #GAD_H, #CHR_COPY$)				:	x	+	GadgetWidth(#X64_Copy)		+	2	:	SetGadgetFont(#X64_Copy,		#PB_Default)
ButtonGadget(#X64_Remove,		x, y, 24, #GAD_H, #CHR_REMOVE$)			:	x	+	GadgetWidth(#X64_Remove)	+	2	:	SetGadgetFont(#X64_Remove,		#PB_Default)
ButtonGadget(#X64_Create,		x, y, #SCR_W - x - 4, #GAD_H, #CHR_COMPILE$ + " Compile x64", #PB_Button_Toggle)	:	SetGadgetFont(#X64_Create,		#PB_Default);FontID(2))

AddGadgetItem(#X64_Compiler, 0, #PB_Compiler_Home	+	"x64\Compilers\pbcompilerc.exe")
AddGadgetItem(#X64_Compiler, 0, X64_Compiler$)

x	=	4	:	y	+	#GAD_H	+	10

SetGadgetFont(TextGadget(#PB_Any, x, y, 128, 12, "Compiler options x86 / x64"),	FontID(0))

y	+	13

_CG(#IS_DLL,		x, y+3,#PARAM_DLL$)		:	x	+	GadgetWidth(#IS_DLL)		+	2
_CG(#IS_THREAD,	x, y+3,#PARAM_THREAD$)	:	x	+	GadgetWidth(#IS_THREAD)	+	2
_CG(#IS_DPIAWARE,	x, y+3,#PARAM_DPIAWARE$):	x	+	GadgetWidth(#IS_DPIAWARE)	+	2
_CG(#IS_XP,			x, y+3,#PARAM_XP$)		:	x	+	GadgetWidth(#IS_XP)	+	2
_CG(#IS_DLLPROTECTION,	x, y+3,#PARAM_DLLPROTECTION$)	:	x	+	GadgetWidth(#IS_DLLPROTECTION)+	2
_CG(#IS_DYNAMICCPU,		x, y+3,#PARAM_DYNAMICCPU$)		:	x	+	GadgetWidth(#IS_DYNAMICCPU)	+	2
_CG(#IS_OPTIMIZER,		x, y+3,#PARAM_OPTIMIZER$)		:	x	+	GadgetWidth(#IS_OPTIMIZER)		+	2

; *** Zoom ***
_CG(#IS_CONSTANT,x, y + 3,#PARAM_CONSTANT$)	:	x	+	GadgetWidth(#IS_CONSTANT)	+	1
SetGadgetFont(TextGadget(#PB_Any, x, y-12, 28, 12, "Zoom"),	FontID(0))
StringGadget(#G_CONSTANT, x, y, 56, 18, "C2D_Z=1", #PB_String_UpperCase)
SetGadgetColor(#G_CONSTANT, #PB_Gadget_FrontColor,$00008B)
SetGadgetColor(#G_CONSTANT, #PB_Gadget_BackColor, #RGB_ON)

; *** UPX Compress ***
SetGadgetFont(TextGadget(#PB_Any, GadgetX(#X64_Create), y-12, 94, 12, "Compress Compiled"),FontID(0))
CheckBoxGadget(#IS_UPX, GadgetX(#X64_Create), y + 3, 14, 14, #Null$)
ButtonGadget(#G_UPXPath, GadgetX(#IS_UPX) + 16, y, 81, 18, ReplaceString(GetFilePart(UPX$, #PB_FileSystem_NoExtension), "upx_", "UPX "), #PB_Button_Default)

x	=	4	:	y	+	18	+	4

CheckBoxGadget(#IS_CUSTOM_1, x, y + 3, 14, 14, "")	:	x	+	GadgetWidth(#IS_CUSTOM_1)+1	:	StringGadget(#G_Custom_1, x, y, #SCR_W/6-2, 18, "/UCRT")					:	x	+	GadgetWidth(#G_Custom_1)	+	4
CheckBoxGadget(#IS_CUSTOM_2, x, y + 3, 14, 14, "")	:	x	+	GadgetWidth(#IS_CUSTOM_2)+1	:	StringGadget(#G_Custom_2, x, y, #SCR_W/6-2, 18, "/ADMINISTRATOR")		:	x	+	GadgetWidth(#G_Custom_2)	+	4
CheckBoxGadget(#IS_CUSTOM_3, x, y + 3, 14, 14, "")	:	x	+	GadgetWidth(#IS_CUSTOM_3)+1	:	StringGadget(#G_Custom_3, x, y, #SCR_W/6-2, 18, "/USER /CONSOLE")		:	x	+	GadgetWidth(#G_Custom_3)	+	4
CheckBoxGadget(#IS_CUSTOM_4, x, y + 3, 14, 14, "")	:	x	+	GadgetWidth(#IS_CUSTOM_4)+1	:	StringGadget(#G_Custom_4, x, y, #SCR_W/6-2, 18, "/LINKER /RESSOURCE"):	x	+	GadgetWidth(#G_Custom_4)	+	4

_CG(#IS_PROCESSOR, x, y + 3, "Processor")	:	x	+	GadgetWidth(#IS_PROCESSOR) + 1	:	ComboBoxGadget(#G_Processor, x, y, #SCR_W - x - 4, 18)
AddGadgetItem(#G_Processor, 0, "/SSE2")
AddGadgetItem(#G_Processor, 0, "/SSE")
AddGadgetItem(#G_Processor, 0, "/MMX")
AddGadgetItem(#G_Processor, 0, "/3DNOW")
SetGadgetState(#G_Processor, 0)

x	=	4	:	y	+	18	+	9

; *** ICON ***
SetGadgetFont(TextGadget(#PB_Any, x, y, 198, 12, "Adding an icon to all compiled executables"),	FontID(0))

y	+	14

_CG(#IS_ICON, x, y + 5,#PARAM_ICON$)	:	x	+	GadgetWidth(#IS_ICON)	+	2
ButtonGadget(#G_IcoSet,		x, y, 40, #GAD_H, "*.ico")					:	x	+	GadgetWidth(#G_IcoSet)	+	2
ComboBoxGadget(#G_IcoPath,	x, y, #SCR_W - x - 4 - 2 * 26, #GAD_H)	:	x	+	GadgetWidth(#G_IcoPath)	+	2	:	SetGadgetFont(#G_IcoPath, #PB_Default);:	SendMessage_(GadgetID(#G_IcoPath), #EM_SETSEL, Len(ICO_Path$), -1)
ButtonGadget(#G_IcoRemove,	x, y, 24, #GAD_H, #CHR_REMOVE$)	:	SetGadgetFont(#G_IcoRemove,#PB_Default)	:	x	+	GadgetWidth(#G_IcoRemove)	+	2
ButtonGadget(#G_IcoView,	x, y, 24, #GAD_H, #CHR_VIEW$)		:	SetGadgetFont(#G_IcoView,	#PB_Default)

AddGadgetItem(#G_IcoPath, 0, ICO_Path$)
SendMessage_(GadgetID(#G_IcoPath), #CB_SETDROPPEDWIDTH, Len(ICO_Path$) * 5, #Null)

x	=	4	:	y	+	GadgetHeight(#G_IcoPath)	+	9

SetGadgetFont(TextGadget(#PB_Any, x, y, 420, 12, "Include resource (selected source only - full path ..\icon, cursor must manually scripted)"),	FontID(0))

y	+	14

_CG(#IS_RESOURCE, x, y + 5, #PARAM_RESOURCE$)			:	x	+	GadgetWidth(#IS_RESOURCE)
ButtonGadget(#G_ResSet,		x, y, 40, #GAD_H, "*.rc")	:	x	+	GadgetWidth(#G_ResSet)	+	2
ComboBoxGadget(#G_ResPath,	x, y, #SCR_W - x - 4 - 2 * 26, #GAD_H)	:	x	+	GadgetWidth(#G_ResPath)		+	2	:	SetGadgetFont(#G_ResPath,	#PB_Default)
ButtonGadget(#G_ResRemove,	x, y, 24, #GAD_H, #CHR_REMOVE$)			:	x	+	GadgetWidth(#G_ResRemove)	+	2	:	SetGadgetFont(#G_ResRemove,#PB_Default)
ButtonGadget(#G_ResView,	x, y, 24, #GAD_H, #CHR_VIEW$)				:	SetGadgetFont(#G_ResView, #PB_Default)

x	=	4	:	y	+	GadgetHeight(#G_IcoPath)	+	9

SetGadgetFont(TextGadget(#PB_Any, x, y, 250, 12, "Asm / C or Preprocessed output (selected source only)"),	FontID(0))

y	+	14

_CG(#IS_COMMENTED,	x, y + 5, #PARAM_COMMENTED$)	:	x	+	GadgetWidth(#IS_COMMENTED)
_CG(#IS_PREPROCESS,	x, y + 5, #PARAM_PREPROCESS$)	:	x	+	GadgetWidth(#IS_PREPROCESS)

StringGadget(#G_ASM, x, y, #SCR_W - (x + 6 + 2 * 38 + 24), #GAD_H, #Null$, #PB_String_ReadOnly)	:	SetGadgetFont(#G_ASM, #PB_Default)
SetGadgetColor(#G_ASM,	#PB_Gadget_BackColor, #RGB_ON)

x	=	#SCR_W	-	(2	*	38	+	24	+	4)

; Commented / Preprocess
ButtonGadget(#X86_Process,	x, y, 38, #GAD_H, "X86")	:	x	+	38
ButtonGadget(#X64_Process,	x, y, 38, #GAD_H, "X64")	:	x	+	38
ButtonGadget(#G_TempPath,	x, y, 24, #GAD_H, #CHR_OPEN$)	:	SetGadgetFont(#G_TempPath, #PB_Default)

;SetGadgetState(#IS_DLLPROTECTION,	#PB_Checkbox_Checked)
SetGadgetState(#IS_OPTIMIZER, #PB_Checkbox_Checked)

;SetGadgetState(#G_SrcPath, 0)
SetGadgetState(#G_OutPath, 0)
SetGadgetState(#X86_Compiler, 0)
SetGadgetState(#X64_Compiler, 0)

DisableGadget(#X86_Process, 1)	:	DisableGadget(#X64_Process, 1)

;}

SetCompileTheme(#G_SetExamples)
SetWindowCallback(@WinCallBack())

Repeat

	Select	WaitWindowEvent()
		Case	#PB_Event_Gadget

			Gadget	=	EventGadget()

			Select	Gadget

				Case	#G_SrcPath
					If	EventType()	=	#PB_EventType_Change
						t$	=	GetGadgetText(#G_SrcPath)
						_SetPath(#G_SrcPath, t$)
						ScanSources(t$)
					EndIf

				Case	#G_SavePref	To	#G_Default
					Prefs(EventGadget())

				Case	#G_SetAMP	To	#G_SetSplatter
					SetCompileTheme(EventGadget())

				Case	#G_SetSize
					Mode_Size	+	1	:	If	Mode_Size	>	2	:	Mode_Size	=	0	:	EndIf
					SizeMode()

				Case	#G_All
					ForEach	Entry()
						Entry()\State	|	#PB_ListIcon_Checked		:	SetGadgetItemState(#G_Sources, ListIndex(Entry()), Entry()\State)
					Next
					CheckCommented()

				Case	#G_Off
					ForEach	Entry()
						Entry()\State	&	#PB_ListIcon_Selected	:	SetGadgetItemState(#G_Sources, ListIndex(Entry()), Entry()\State)
					Next
					CheckCommented()

				Case	#G_Swp
					ForEach	Entry()
						Entry()\State	!	#PB_ListIcon_Checked		:	SetGadgetItemState(#G_Sources, ListIndex(Entry()), Entry()\State)
					Next
					CheckCommented()

				Case	#G_See
					If	ListSize(Entry())
						t$	=	GetGadgetText(#G_SrcPath) + GetGadgetItemText(#G_Sources, GetGadgetState(#G_Sources))
						;RunProgram("notepad.exe", t$, GetPathPart(t$))
						ViewText(t$)
					EndIf

				Case	#G_SrcSet
					SetGadgetState(#G_SrcSet, 0)
					t$	=	PathRequester("Select path with Purebasic-Sources", GetGadgetText(#G_SrcPath))
					If	t$
						_SetPath(#G_SrcPath, t$)
						SetGadgetState(#IS_OUTPATH, #PB_Checkbox_Unchecked)
						DisableGadget(#G_OutPath, 1)
						ScanSources(t$)
					EndIf

				Case	#G_OutSet	:	_SetPath(#G_OutPath, PathRequester("Select outpath for compiled sources", GetGadgetText(#G_OutPath)))

				Case	#G_SrcOpen	:	RunProgram(GetGadgetText(#G_SrcPath))
				Case	#G_OutOpen	:	RunProgram(GetGadgetText(#G_OutPath))

				Case	#G_SrcRemove
					_RemPath(#G_SrcPath)	:	ScanSources(GetGadgetText(#G_SrcPath))
				Case	#G_OutRemove
					If	_RemPath(#G_OutPath)	<=	0
						SetGadgetState(#IS_OUTPATH, 0)
						DisableGadget(#G_OutPath, 1)
					EndIf

				Case	#X86_Open	:	_SetPath(#X86_Compiler, OpenFileRequester("Select Purebasic-Compiler x86", GetGadgetText(#X86_Compiler), "Compiler x86|*pbcompiler*.exe", 0))
				Case	#X64_Open	:	_SetPath(#X64_Compiler, OpenFileRequester("Select Purebasic-Compiler x64", GetGadgetText(#X64_Compiler), "Compiler x64|*pbcompiler*.exe", 0))

				Case	#X86_Compiler, #X64_Compiler, #G_IcoPath, #G_ResPath
					If	EventType()	=	#PB_EventType_Change
						_SetPath(Gadget, GetGadgetText(Gadget))
					EndIf

				Case	#X86_Create	; *** start compile ***
					DisableGadget(#X64_Create, 1)
					CompileSources(Gadget)
					DisableGadget(#X64_Create, 0)
				Case	#X64_Create	; *** start compile ***
					DisableGadget(#X86_Create, 1)
					CompileSources(Gadget)
					DisableGadget(#X86_Create, 0)

				Case	#X86_Remove
					If	_RemPath(#X86_Compiler)	<=	0	; last removed?
						_SetPath(#X86_Compiler, X86_Compiler$)	; x86 default
					EndIf
				Case	#X64_Remove
					If	_RemPath(#X64_Compiler)	<=	0	; last removed?
						_SetPath(#X64_Compiler, X64_Compiler$)	; x64 default
					EndIf

				Case	#X86_Copy
					SetClipboardText(GetGadgetText(#X86_Compiler))	:	MA_Info("X86 compilerpath copied to clipboard")
				Case	#X64_Copy
					SetClipboardText(GetGadgetText(#X64_Compiler))	:	MA_Info("X64 compilerpath copied to clipboard")

				Case	#G_IcoSet		:	_SetPath(#G_IcoPath, OpenFileRequester("Select Icon-File", GetGadgetText(#G_IcoPath), "Icon|*.ico", 0))
				Case	#G_IcoRemove	:	_RemPath(#G_IcoPath)
				Case	#G_IcoView		:	ViewIcon(GetGadgetText(#G_IcoPath))

				Case	#G_ResRemove	:	_RemPath(#G_ResPath)
				Case	#G_ResSet		:	_SetPath(#G_ResPath, OpenFileRequester("Select Resource-File", GetGadgetText(#G_ResPath), "RC|*.rc", 0))
				Case	#G_ResView
					t$	=	GetGadgetText(#G_ResPath)
					If	t$
						ViewText(t$, #PB_Unicode)
					EndIf

				Case	#G_UPXPath
					t$	=	OpenFileRequester("Select UPX Packer", UPX$, "UPX|upx*.exe", 0)
					If	t$
						UPX$	=	t$
						SetGadgetText(#G_UPXPath, ReplaceString(GetFilePart(UPX$, #PB_FileSystem_NoExtension), "upx_", "UPX "))
					EndIf

				Case	#G_Sources	:	CheckCommented()

				Case	#IS_COMMENTED, #IS_PREPROCESS

					If	Gadget	=	#IS_COMMENTED
						SetGadgetState(#IS_PREPROCESS,0)
					Else	;If	GetGadgetState(#IS_PREPROCESS)
						SetGadgetState(#IS_COMMENTED,	0)
					EndIf

					x	=	Bool(GetGadgetState(#IS_PREPROCESS) Or GetGadgetState(#IS_COMMENTED))
					DisableGadget(#X86_Create, x)	:	DisableGadget(#X64_Create, x)

					x	!	1	:	DisableGadget(#X86_Process, x)	:	DisableGadget(#X64_Process, x)

					CheckCommented()

				Case	#X86_Process, #X64_Process
					PrecompileSelected(Gadget)

				Case	#G_TempPath		:	RunProgram(GetTemporaryDirectory())

				Case	#IS_OUTPATH, #IS_UPX, #IS_CONSTANT, #IS_RESOURCE, #IS_ICON,  #IS_CUSTOM_1, #IS_CUSTOM_2, #IS_CUSTOM_3, #IS_PROCESSOR
					_Disable()

			EndSelect

			While	WindowEvent()	:	Wend	:	Delay(5)

		Case	#PB_Event_CloseWindow
			Break

	EndSelect

ForEver
; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 2
; Folding = AAAA5
; Optimizer
; EnableThread
; EnableXP
; SharedUCRT
; UseIcon = ..\..\Data\Icon\rocket.ico
; Executable = C2D_Compiler_x86.exe
; CompileSourceDirectory