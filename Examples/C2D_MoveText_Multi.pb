; C2D::MoveText / Multi - Purebasic v5.72 (x86-64)

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1	; Zoom-Factor
CompilerEndIf

DeclareModule	IsC2D
	#IsC2D_Bitmap		=	0
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_Topaz		=	0	; we use own rawfont
	#IsC2D_MoveText	=	1
	#IsC2D_Clear		=	0
	XIncludeFile	"..\Include\C2D_Defaults.pbi"
EndDeclareModule
XIncludeFile	"..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	550	*	#C2D_Z	; Width
#C2D_H	=	340	*	#C2D_Z	; Height

#T_W0	=	#C2D_W	-	298	*	#C2D_Z
#T_W1	=	#C2D_W	-	#T_W0

Procedure	C2D_Init()
	
	Protected	i

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DPB("MoveText / Multi"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 7)

	C2D::FontRawInit(0, ?f_rw, ?e_rw, #C2D_Z, #C2D_Z, #White, 6)
	C2D::FontShadow(0, 2, 2, $6F)
	C2D::FontGap(0, 0, 2 * #C2D_Z)

	C2D::MoveTextInit(0, ?t_text, 0,			0,				#T_W0,	#C2D_H*0.5)
	C2D::MoveTextInit(1, ?t_text, #T_W0,	0,				#T_W1,	#C2D_H*0.5, C2D::#C2F_Center)
	C2D::MoveTextInit(2, ?t_text, 0,			#C2D_H*0.5,	#T_W1,	#C2D_H*0.5, C2D::#C2F_Random)
	C2D::MoveTextInit(3, ?t_text, #T_W1,	#C2D_H*0.5,	#T_W0,	#C2D_H*0.5, C2D::#C2F_Right)
	
	For	i	=	0	To	3
		C2D::MoveTextColor(i, RGBA(Random(200), Random(200), Random(200), $FF))
		C2D::MoveTextSpeed(i, 0.25 * (Random(7) + 1) * (1 - Random(1) * 2))
	Next

EndProcedure
Procedure	C2D_Update()
	
	Protected	i
	
	For	i	=	0	To	3
		If	C2D::MoveTextDraw(i)	=	C2D::#C2F_End
			C2D::MoveTextSpeed(i, 0.25 * (Random(7) + 1) * (1 - Random(1) * 2) * #C2D_Z)
		EndIf
	Next

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	GetAsyncKeyState_(#VK_ESCAPE)
				Break
			EndIf
	EndSelect
ForEver

C2D::Free()
	
DataSection
	
	f_rw:	:	IncludeBinary	"..\Data\Font\RAW\Amiga_Pyrotechnics_6.rw"	:	e_rw:
	
	t_text:
	Data.s	"1. Das ist ein Text zum anzeigen!|"		+
	      	"Mal sehen ob es klappt mit dem text?||"	+
	      	"hier ein tab:<	> bis hierher.||||"		+
	      	"das eben war'n nen paar Freizeilen."		+
	      	"||"	+
	      	"2. huch ein seitenwechsel|"				+
	      	"das hat also geklappt >hoffentlich<."	+
	      	"||"	+
	      	"3. Klasse, aber warum beginnt er nicht mit|"+
	      	"Seite 1 des PageText?||"							+
	      	"Habe da wohl was uebersehen.||"					+
	      	"ahh > resetlist benoetigt nextelement|"		+
	      	"boa ey... man man!"									+
	      	"||"	+
	      	"4. jetzt aber...||"							+
	      	"* der text wird zentriert angezeigt|"	+
	      	"* und auch ohne  diese  freizeichen|"	+
	      	"* ordentlich  dargestellt   werden!"	+
	      	"||"	+
	      	"5. ok... alles von vorn >|"	+
	      	"zuvor aber alle buchstaben"	+
	      	"||"	+
	      	" !"	+ #DQUOTE$ + "#$%&'|"	+
	      	"()*+,-./|"	+
	      	"01234567|"	+
	      	"89:;<=>?|"	+
	      	"@ABCDEFG|"	+
	      	"HIJKLMNO|"	+
	      	"PQRSTUVW|"	+
	      	"XYZ[\]^_"
	
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = w
; Executable = ..\Executables\C2D_MoveText_Multi_x86.exe
; DisableDebugger
; CompileSourceDirectory