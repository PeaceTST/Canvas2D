; C2D::FontRaw / Preview - Purebasic v5.62 (x86-64)

; -> copies current rawfont as fontmap-image to clipboard

DeclareModule	IsC2D
	
	#IsC2D_Bitmap		=	0
	#IsC2D_Clear		=	2
	#IsC2D_Text			=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	0
	#IsC2D_File			=	1
	
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
	
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

CompilerIf	Defined(PB_MessageRequester_Warning,#PB_Constant)	=	0
	#PB_MessageRequester_Warning	=	48
CompilerEndIf

#C2D_G	=	0	; #Gadget
#C2D_W	=	8 * 64			; Width
#C2D_H	=	8 * 64	+	9	; Height

#EXP_G	=	1
#EXP_W	=	300

#DEF_PATH$	=	"..\..\Data\Font\RAW\*.rf;*.rw;*.raw"

Global	Title$	=	MA_C2DOS("FontRaw - Preview")

Procedure	C2D_Recycle(File$)
	
	; Move File$ to trashcan
	
	Protected	i
	Protected	SHFileOp.SHFILEOPSTRUCT
	Protected	*Memory	=	AllocateMemory((Len(File$) + 2) * SizeOf(Character))
	
	If	*Memory
		
		PokeS(*Memory, File$)
		
		SHFileOp\pFrom		=	*Memory
		SHFileOp\wFunc		=	#FO_DELETE
		SHFileOp\fFlags	=	#FOF_ALLOWUNDO|#FOF_NOERRORUI|#FOF_NOCONFIRMATION|#FOF_SIMPLEPROGRESS|#FOF_SILENT
		
		i	=	SHFileOperation_(@SHFileOp)
		
		If	i
			i	=	#False	; error
		Else
			i	=	#True		; deleted!
		EndIf
		
		FreeMemory(*Memory)
		
	EndIf
	
	ProcedureReturn	i
	
EndProcedure
Procedure	C2D_OpenRaw(File$, x=0, y=0)
	
	; x, y = font gaps

	Protected	Width, *Memory
	
	If	File$
		
		*Memory	=	C2D::FileLoad(File$)

		If	*Memory
			
			Width	=	Val(StringField(File$, CountString(File$, "_")	+	1, "_"))
			
			If	Width	<=	0
				Width	=	8
			EndIf
			
			C2D::FontRawInit(0, *Memory, MemorySize(*Memory), 1, 1, #White,Width)
			C2D::FontRawInit(1, *Memory, MemorySize(*Memory), 3, 3, #Red,	Width)
			
			C2D::FontGap(0, x, y)
			C2D::FontGap(1, x, y)
			
			C2D::FontSelect(0)	:	C2D::TextInit(0, ?t_text)
			C2D::FontSelect(1)	:	C2D::ScrollTextInit(0, ?t_Scroll)
			
			; copy rawfont as fontmap to clipboard
			CreateImage(0, C2D::TextW(0), C2D::TextH(0))
			StartDrawing(ImageOutput(0))
			C2D::TextDraw(0, 0, 0)
			StopDrawing()
			
			SetClipboardImage(0)
			
			FreeImage(0)
			
		EndIf
		
	EndIf

EndProcedure

Procedure	C2D_Init()

	OpenWindow(0, 0, 0, #C2D_W + #EXP_W, #C2D_H, Title$, #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	
	ExplorerListGadget(#EXP_G, #C2D_W, 0, #EXP_W, #C2D_H, #DEF_PATH$ , #PB_Explorer_AlwaysShowSelection|#PB_Explorer_GridLines|#PB_Explorer_FullRowSelect)
	
	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)
	
	C2D::Init(#C2D_G, 10)

EndProcedure
Procedure	C2D_Update()
	
	Static	t$="Choose RawFont, [ESC] = Exit"
	
	If	C2D::IsText(0)
		
		C2D::TextDraw(0, 0, 0, 255, C2D::#C2F_Center)
		C2D::ScrollTextDraw(0, #C2D_H - C2D::ScrollTextH(0) - 8)
		
	Else
		
		DrawText((#C2D_W - TextWidth(t$)) * 0.5, 0, t$, $FF707070)
		
	EndIf
	
EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
			
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
			
		Case #PB_Event_Gadget
			If	EventGadget()	=	#EXP_G
				Select	EventType()
					Case	#PB_EventType_LeftClick
						If	GetGadgetState(#EXP_G)	>=	0
							File$	=	GetGadgetText(#EXP_G)	+	GetGadgetItemText(#EXP_G, GetGadgetState(#EXP_G))
							Length=	FileSize(File$)
							If	Length	>	#Null
								C2D_OpenRaw(File$, 0, 0)
								SetWindowTitle(0, Title$ + " :: " + File$ + " = " + Str(C2D::FontW(0)) + " x " + Str(C2D::FontH(0)) + " (" + Str(Length) + " bytes)")
							EndIf
						EndIf
				EndSelect
			EndIf
			
		Case	#PB_Event_CloseWindow
			Break
			
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			ElseIf	GetAsyncKeyState_(#VK_DELETE)
				If	File$	And	FileSize(File$)	>	#Null
					If	MessageRequester("Delete file", "Really delete Rawfont?" + #LF$ + #LF$ + File$, #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)	=	#PB_MessageRequester_Yes
						C2D_Recycle(File$)
					EndIf
				EndIf
			EndIf
			
	EndSelect
ForEver

C2D::Free()

DataSection

	t_Scroll:
	Data.s	" !" + #DQUOTE$ + "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"	+
				"	(W) [W] EXAMPLE USING THE TINY C2D MODULE CODED IN PUREBASIC V5.62 (" + C2D::#C2D_XOS$ + ") ... VISIT US AT ... TESTAWARE.WORDPRESS.COM"

	t_text:
	Data.s  	" !" + #DQUOTE$ + "#$%&'"	+	#LF$	+
	        	"()*+,-./"	+	#LF$	+
	        	"01234567"	+	#LF$	+
	        	"89:;<=>?"	+	#LF$	+
	        	"@ABCDEFG"	+	#LF$	+
	        	"HIJKLMNO"	+	#LF$	+
	        	"PQRSTUVW"	+	#LF$	+
	        	"XYZ[\]^_"

EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = g-
; EnableXP
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = FontRaw_Preview_x86.exe
; CompileSourceDirectory