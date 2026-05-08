; C2D::AmpMaster / Installer v1.23.9.19 (x86)
; Peace^Testaware - 30.10.23 10:32
; Purebasic v6.02 (x86) - no music in x64!

;EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0
	#C2D_Z	=	1.25	; Zoom-Factor
CompilerEndIf

#IsFinal	=	1	; *** for test: 0 -> no download & no unpacking

CompilerIf	#IsFinal
	UseZipPacker()
CompilerEndIf

IncludePath	"..\..\Include\"

DeclareModule	IsC2D

	XIncludeFile	"C2D_Types.pbi"

	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x86	; #Music
		#IsC2D_Music	=	#XMU_V2M	; x86
	CompilerEndIf

	#IsC2d_Help			=	0

	#IsC2D_Bitmap		=	1
	#IsC2D_BitmapColor=	1
	#IsC2D_Copper		=	1
	#IsC2D_Buffer		=	1	; Mirror/SinusX
	#IsC2D_NetWork		=	2	; Download
	#IsC2D_FontColor	=	1
	#IsC2D_FontRaw		=	1
	#IsC2D_ScrollText	=	1
	#IsC2D_Stars3D		=	2	; Fast stars 1px
	#IsC2D_Text			=	1
	#IsC2D_Topaz		=	1

	#IsC2D_Ball3D		=	2	; Explode
	#IsC2D_Clear		=	2	; FastClear(black)

	XIncludeFile	"C2D_Defaults.pbi"

EndDeclareModule

XIncludeFile	"C2D_Module.pbi"

; *** Main ***

#C2D_G	=	0	; #ID of CanvasGadget
#C2D_H	=	220		*	#C2D_Z	; Height (zoomed)
#C2D_W	=	#C2D_H	*	1.7777	; Width (16/9)

#C2D_CX	=	-0.64	*	#C2D_W	; Ball left start
#C2D_CY	=	-10.0	*	#C2D_Z	; Ball vertical

Enumeration	1
	#G_PATH
	#G_INSTALL
	#G_OPEN
EndEnumeration

Enumeration
	#ID_FONT
	#ID_FONT_SCROLL
	#ID_FONT_BLEND
	#ID_TEXT
	#ID_AMPMASTER_I
	#ID_INSTALLER_I
	#ID_AMPMASTER_O
	#ID_INSTALLER_O
	#ID_COPPER_IO
	#ID_LINE0
	#ID_LINE1
	#ID_RASTER
	#ID_MESSAGE
	#ID_BALL0
	#ID_BALL1
	#ID_BitMap
EndEnumeration

#MIN_B3D		=	0
#MAX_B3D		=	6
#B3D_Z		=	10	*	#C2D_Z

#FONT_H		=	31	*	#C2D_Z	; 31 = Pixel-Height of original-font

#V_START		=	40 * #C2D_Z
#V_HEIGHT	=	#C2D_H - #V_START	*	2

#TIME_FADE	=	8000 ; ms

#B3D_MoveX	=	(#C2D_W	/	(510.0 * #C2D_Z))	*	#C2D_Z
#B3D_RX		=	200
#B3D_RY		=	200
#B3D_RZ		=	100

#MIR_Y		=	164	*	#C2D_Z	; Mirrorstart
#MIR_H		=	40		*	#C2D_Z	; Mirrorheight

#TITLE_Y	=	(#V_START -	#FONT_H) * 0.5
#SCROLL_Y	=	#C2D_H - #MIR_H - 16 * #C2D_Z - 31

#PATH$		=	"AmpMaster\"
#AMP_HEAD$	=	"GIF89a"	; Arc-Header (6 bytes)

Global	ID0, ID1, IsUnpacked

CompilerIf	#PB_Compiler_Version	<	560	; -> Install_Path$

	Global	Install_Path${#MAX_PATH}

	SHGetFolderPath_(#Null, #CSIDL_COMMON_DOCUMENTS, #Null, #Null, @Install_Path$)
	PathAddBackslash_(@Install_Path$)

CompilerElse

	Global	Install_Path$	=	GetUserDirectory(#PB_Directory_Public)

CompilerEndIf

Global	Update_Path$	=	GetPathPart(ProgramFilename())	+	"update\"
Global	Archive_Name$	=	GetTemporaryDirectory()				+	"AmpMaster_x86.zip"	; PB supports not mode 7z ultra-pack

Declare	AM_Update()

Procedure	Download_CallBack(Param)

	Protected	x = 32 * #C2D_Z, y = 13 * #C2D_Z, i = 3 * #C2D_Z

	If	WindowEvent()	=	#Null
		SetGadgetText(#G_PATH, "Download... " + Str(Param) + "%")
	EndIf

	AM_Update()

	If	Param	>	100	:	Param	=	100	:	EndIf

	Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $50FFFFFF)	:	x	+	i	:	y	-	i
	Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $50000000)	:	x	+	i	:	y	-	i

	Box(x, #C2D_H / 2 - y, ((#C2D_W - 2 * x) * 0.01) * Param, 2 * y, $50FFFFFF)

EndProcedure

Procedure	Copper_Blit(x, y, PenColor, PaperColor)
	If	PaperColor	<>	$FF734132	; color of scroller
		ProcedureReturn	PaperColor
	EndIf
	ProcedureReturn	PenColor
EndProcedure

Procedure	Archive_Download()

	; Zip
	Protected	File$	=	"https://testaware.files.wordpress.com/2023/10/ampmaster_2023-09-19.gif"

	C2D::NetWorkCallBack(@Download_CallBack())
	C2D::NetWorkSkip(Len(#AMP_HEAD$))

	ProcedureReturn	Bool(C2D::NetWorkDownload(File$, Archive_Name$)=0)

EndProcedure
Procedure	Archive_Update()

	Shared	Bytes.q

	Protected	File$, *Memory, Updates

	If	ExamineDirectory(0, Update_Path$, "*.dll")
		While	NextDirectoryEntry(0)

			If	DirectoryEntryType(0)	=	#PB_DirectoryEntry_File

				File$	=	DirectoryEntryName(0)

				If	ReadFile(0, Update_Path$ + File$)

					SetGadgetText(#G_PATH, "Update... " + File$)
					While	WaitWindowEvent(15)	:	Wend

					*Memory	=	AllocateMemory(Lof(0))
					ReadData(0, *Memory, MemorySize(*Memory))
					CloseFile(0)

					If	UCase(File$)	=	UCase("AmpMaster_x86.dll")				; *** Update AmpMaster_x86.dll ***
						File$	=	Install_Path$ + "AmpMaster\" + File$
					Else
						File$	=	Install_Path$ + "AmpMaster\AmpLibs\" + File$	; *** Update in/out_??.dll ... ***
					EndIf

					If	CreateFile(0, File$)
						WriteData(0, *Memory, MemorySize(*Memory))
						CloseFile(0)
						Updates	+	1
						Bytes		+	MemorySize(*Memory)
					EndIf

					FreeMemory(*Memory)

					Delay(15)

				EndIf

			EndIf

		Wend

		FinishDirectory(0)

	EndIf

	ProcedureReturn	Updates

EndProcedure
Procedure	Archive_Install()

	Shared	Bytes.q

	Protected	IsError, Files, Dirs, Updates, *Memory
	Protected	File$, Message$

	IsUnpacked	=	#False	; Messages off

	If	MessageRequester("Install: AmpMaster x86 Freeware",
	  	                 "Archive-Name:"	+	#LF$	+
	  	                "https://testaware.files.wordpress.com/AmpMaster_x86.zip"	+	#LF$	+	#LF$	+
	  	                 "Install-Path:"	+	#LF$	+
	  	                 Install_Path$	+	#LF$	+	#LF$	+
	  	                 "No changes in registry, no addons, full freeware!"	+	#LF$	+	#LF$	+	#LF$	+
	  	                 "Download and install now?",	#PB_MessageRequester_YesNo)	<>	#PB_MessageRequester_Yes

		ProcedureReturn

	EndIf

	CompilerIf	#IsFinal

		IsError	=	Archive_Download()

		If IsError	=	0	And	OpenPack(0, Archive_Name$)

			If ExaminePack(0)
				While NextPackEntry(0)

					File$	=	PackEntryName(0)
					SetGadgetText(#G_PATH, "Extract... " + File$)

					File$	=	Install_Path$	+	File$

					Select	PackEntryType(0)

						Case	#PB_Packer_File

							If	UncompressPackFile(0, File$)	>	#Null
								Files	+	1
								Bytes	+	PackEntrySize(0)
							Else
								IsError	+	1
							EndIf

						Case	#PB_Packer_Directory

							If	FileSize(File$)	=	-1
								If	CreateDirectory(File$)
									Dirs	+	1
								Else
									IsError	+	1
								EndIf
							Else
								Dirs	+	1
							EndIf

					EndSelect

					If	C2D::Start()	; update filebar
						Download_CallBack((100.0 / 125) * Files)
						C2D::Stop()
					EndIf

				Wend
			EndIf

			ClosePack(0)

			Updates	=	Archive_Update()	; *** install updates ***

		Else

			IsError	+	1

		EndIf
	CompilerEndIf

	IsUnpacked	=	#True	; Need for message on C2D

	; *** ALL correct unpacked?
	If	IsError	=	#Null

		ButtonGadget(#G_OPEN, GadgetX(#G_INSTALL), GadgetY(#G_INSTALL), GadgetWidth(#G_INSTALL), GadgetHeight(#G_INSTALL), "Open", #BS_FLAT)
		FreeGadget(#G_INSTALL)

		Message$	=	"INSTALLATION SUCCESSFUL!||"	+
		        	 	"DIRECTORIES..: "	+	Str(Dirs)	+	#LF$	+
		        	 	"UNPACKED.....: "	+	Str(Files)	+	" FILES|"	+
		        	 	"UPDATES......: "	+	Str(Updates)+	" FILES||"	+
		        	 	"SIZE TOTAL...: "	+	StrF(Bytes	*	(1.0/1048576), 2)	+	" MB"
	Else

		Message$	=	Space(7)	+	"ERROR!||INSTALLATION FAILED"

	EndIf

	; Message-Font / Text (Default-RawFont Topaz, Installation)
	C2D::FontRawInit(#ID_MESSAGE)
	C2D::FontScale(#ID_MESSAGE, Int(#C2D_Z))

	If	IsError
		C2D::FontCopper(#ID_MESSAGE,	?c_err)
	Else
		C2D::FontCopper(#ID_MESSAGE,	?c_mess)
	EndIf

	C2D::FontShadow(#ID_MESSAGE,	1,	1)
	C2D::FontGap(#ID_MESSAGE,		0,	2	*	#C2D_Z)

	C2D::TextInit(#ID_MESSAGE,	@Message$)

	SetGadgetText(#G_PATH,	Install_Path$	+	#PATH$)

EndProcedure

Procedure	AM_Init()

	Protected	i

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H + 28, MA_C2DOS("AmpMaster / Installer"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
	CompilerIf	#IsFinal	=	0
		SetWindowTitle(0, GetWindowTitle(0) + " *** Test ***")
	CompilerEndIf

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)

	StringGadget(#G_PATH, 4, #C2D_H + 4, #C2D_W - 92, 20, Install_Path$ + #PATH$, #ES_READONLY)
	SetWindowLongPtr_(GadgetID(#G_PATH), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(#G_PATH), #GWL_EXSTYLE) | #WS_EX_STATICEDGE & ~#WS_EX_CLIENTEDGE)
	SetWindowPos_(GadgetID(#G_PATH), 0, 0, 0, 0, 0, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOSIZE | #SWP_FRAMECHANGED)

	ButtonGadget(#G_INSTALL, #C2D_W - 84, #C2D_H + 4, 80, 20, "Install", #BS_FLAT)

	; *** CANVAS 2D ***
	C2D::Init(#C2D_G, 10)

	; Starfield
	C2D::Stars3DDistance(-36)
	C2D::Stars3DInit(160, #C2D_Z, 0, #V_START, #C2D_W, #V_HEIGHT - #MIR_H * 0.5 + 4, 3.1)

	C2D::CopperInit(#ID_COPPER_IO, #V_HEIGHT, ?c_IO, C2D::#C2F_Horizontal)	; L+R Fade 3DBall
	C2D::CopperInit(#ID_LINE0, 1, ?c_white, C2D::#C2F_Horizontal)
	C2D::CopperInit(#ID_LINE1, 1, ?c_white, C2D::#C2F_Horizontal)

	C2D::CopperInit(#ID_RASTER, #FONT_H, ?c_ras)	; CopperFX Scrolltext
	C2D::CopperBlitProc(@Copper_Blit())				; Define own coz bug in PB x64

	; Original-Font / Text
	C2D::BitmapInit(#ID_BitMap,?f_font,	?f_fontE, #Black)
	C2D::FontInit(#ID_FONT,	C2D::BitmapImage(#ID_BitMap))
	C2D::FontScale(#ID_FONT,#C2D_Z)

	C2D::TextInit(#ID_AMPMASTER_I, ?t_AmpMaster)
	C2D::TextInit(#ID_INSTALLER_I, ?t_Installer)

	; Scroller
	C2D::FontInit(#ID_FONT_SCROLL,C2D::BitmapImage(#ID_BitMap))
	C2D::ScrollTextInit(#ID_TEXT,	?t_text)
	C2D::ScrollTextSpeed(#ID_TEXT,Int(#C2D_Z))

	; Blend Original-Font / Text
	C2D::BitmapFill(#ID_BitMap,	$FF000000|#White)
	C2D::FontInit(#ID_FONT_BLEND,	C2D::BitmapImage(#ID_BitMap))
	C2D::FontScale(#ID_FONT_BLEND,#C2D_Z)

	C2D::TextInit(#ID_AMPMASTER_O,?t_AmpMaster)
	C2D::TextInit(#ID_INSTALLER_O,?t_Installer)

	; Ball3D set new image-balls
	C2D::Ball3DImage(6, C2D::BitmapInit(#ID_BALL0, ?b6, ?b6E, #Black))
	C2D::Ball3DImage(2, C2D::BitmapInit(#ID_BALL1, ?b2, ?b2E, #Black))

	i	=	0	:	C2D::Ball3DInit(i, ?b3d_airplane,	#B3D_Z)			:	C2D::Ball3DSpin(i, 1.7)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_amptst,		#B3D_Z)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_cube,			#B3D_Z * 1.1)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_rotor,		#B3D_Z)			:	C2D::Ball3DSpin(i, 1.1)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_cube2,		#B3D_Z * 0.6)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_ampmaster,	#B3D_Z * 0.8)	:	C2D::Ball3DSpin(i,-1.7)
	i	+	1	:	C2D::Ball3DInit(i, ?b3d_enterprise,	#B3D_Z * 0.7)

	C2D::BitmapFree(#ID_BitMap)

	ID0	=	Random(#MAX_B3D - 1, #MIN_B3D)
	ID1	=	ID0	+	1

	IsExplode	=	C2D::Ball3DExplode(ID0, 2)

	CompilerIf	IsC2D::#IsC2D_Music
		C2D::MusicPlay(?m_music, ?e_music)
	CompilerEndIf

EndProcedure
Procedure	AM_Update()

	Static	x0.f=#C2D_CX, x1.f, IsID1=0 ; no B3D move-in at first call
	Static	ax.f=0.81, ay.f=0.93, az.f=-0.35
	Static	LogoID=2, LogoAlpha, LogoTime, LogoFade

	Static	a_logo=#ID_INSTALLER_I,	a_blend=#ID_INSTALLER_O
	Static	b_logo=#ID_AMPMASTER_I,	b_blend=#ID_AMPMASTER_O

	;  --------------------------
	;  *** Blend title in/out ***
	;{ --------------------------
	If	C2D::C2D\Time	>=	LogoTime
		LogoID	+	1
		If	LogoID	>	2
			LogoID	=	0
			Swap	a_logo,	b_logo
			Swap	a_blend,	b_blend
		EndIf
		LogoFade		=	#True
		LogoAlpha	=	0
		LogoTime		=	C2D::C2D\Time	+	#TIME_FADE
	EndIf

	If	LogoFade
		LogoAlpha	+	5	:	If	LogoAlpha	>=	255	:	LogoFade	=	#False	:	LogoAlpha	=	255	:	EndIf
	EndIf

	; blend logo(s) in/out
	Select	LogoID
		Case	0
			C2D::TextDraw(a_blend, 0, #TITLE_Y, LogoAlpha, C2D::#C2F_CenterX)
			If	LogoAlpha	>=	255	:	LogoTime	=	0	:	EndIf	; next step, no wait
		Case	1
			C2D::TextDraw(a_logo, 0, #TITLE_Y, 255, C2D::#C2F_CenterX)
			If	LogoFade	:	C2D::TextDraw(a_blend, 0, #TITLE_Y, 255 - LogoAlpha, C2D::#C2F_CenterX)	:	EndIf
		Case	2
			C2D::TextDraw(a_logo, 0, #TITLE_Y, 255 - LogoAlpha, C2D::#C2F_CenterX)
			If	LogoAlpha	>=	255	:	LogoTime	=	0	:	EndIf	; next step, no wait
	EndSelect
	;}

	; -----------------------------------
	; *** 3DBall / Stars / Scrolltext ***
	; -----------------------------------

	If	IsID1	=	0
		C2D::Stars3DDraw()	; uses own clipping
	EndIf

	ClipOutput(0, #V_START, #C2D_W, #V_HEIGHT + 2)

	If	x0	<	#Null
		x0	+	#B3D_MoveX	:	If	x0	>=	#Null	:	x0	=	#Null	:	EndIf
	EndIf

	C2D::Ball3DRotate(ID0, ax, ay, az)
	C2D::Ball3DDraw(ID0, x0, #C2D_CY, 255-32, 32)

	If	IsID1	; Move old B3D out + I/O-FadeCopper (left+right borders)
		x1	+	#B3D_MoveX
		C2D::Ball3DRotate(ID1, ax, ax, ay)
		IsID1	=	C2D::Ball3DDraw(ID1, x1, #C2D_CY, 255-32, 32)
		C2D::CopperDraw(#ID_COPPER_IO, #V_START)
	EndIf

	; Move next B3D in/out & calc new rotation
	If	LogoID=2	And	a_logo=#ID_INSTALLER_I	And	IsID1=0

		IsID1	=	#True

		x0		=	#C2D_CX
		x1		=	#Null
		ID1	=	ID0
		ID0	+	1	:	If	ID0	>	#MAX_B3D	:	ID0	=	#MIN_B3D	:	EndIf

		ax	=	(0.013 * Random(#B3D_RX, 0.43 * #B3D_RX)) * (1 - Random(1) * 2)
		ay	=	(0.013 * Random(#B3D_RY, 0.43 * #B3D_RY)) * (1 - Random(1) * 2)
		az	=	(0.013 * Random(#B3D_RZ, 0.33 * #B3D_RZ)) * (1 - Random(1) * 2)
		C2D::Ball3DAngle(ID0, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))

		C2D::Ball3DExplode(ID0, 2)

	EndIf

	UnclipOutput()

	If	IsID1	; only if b3d blend left / right
		C2D::Stars3DDraw()	; uses own clipping
	EndIf

	; top / down borders
	C2D::CopperMoveDraw(#ID_LINE0, #V_START - 1, -3)
	C2D::CopperMoveDraw(#ID_LINE1, #C2D_H - 16 * #C2D_Z, 3)

	If	IsUnpacked	; textmessage of not/unpacked AmpMaster
		C2D::TextDraw(#ID_MESSAGE, 0, -14 * #C2D_Z, 255, C2D::#C2F_Center)
	EndIf

	ClipOutput(4, #SCROLL_Y, #C2D_W-2*4, #FONT_H)
	C2D::ScrollTextDraw(#ID_TEXT, #SCROLL_Y)
	C2D::CopperBlit(#ID_RASTER, #SCROLL_Y, 0.45)
	UnclipOutput()

	; reset mode coz blit use its own
	DrawingMode(#PB_2DDrawing_AlphaBlend)

	C2D::BufferMirror(0, #MIR_Y, #C2D_W, #MIR_H*2, %1)
	C2D::BufferSinX(3, #MIR_Y, #C2D_W-6, #MIR_H, 3, 99, 15)
	Box(0, #MIR_Y, #C2D_W, #MIR_H, $A0330000)

EndProcedure

AM_Init()

Repeat
	Select	WindowEvent()
		Case	#Null
			If	C2D::Start()
				AM_Update()
				C2D::Stop()
			EndIf
		Case	#PB_Event_Gadget
			Select	EventGadget()
				Case	#G_INSTALL
					Archive_Install()
				Case	#G_OPEN
					RunProgram(Install_Path$ + "AmpMaster\")
					Delay(500)
			EndSelect
		Case	#PB_Event_CloseWindow
			Break
		Case	#WM_KEYDOWN
			If	EventwParam()	=	#VK_ESCAPE
				Break
			EndIf
	EndSelect
ForEver

C2D::Free()

DataSection

	; Copper
	c_IO:		:	Data.l	4,	$FF000000,$00000000,$00000000,$FF000000	; text in/out
	c_white:	:	Data.l	3,	$FF303030,$FFFFFFFF,$FF303030	; lines
	c_mess:	:	Data.l	3,	$FFA0A0A0,$FFFFFFFF,$FFA0A0A0	; message
	c_err:	:	Data.l	3,	$FF0000A0,$FF0020FF,$FF0000A0	; error-message
	c_ras:	:	Data.l	5,	$FFFF00FF,$FFFF0000,$FFFFFF00,$FFFFFFFF,$FFFF00FF	; scrolltext

	t_AmpMaster:	:	Data.s	"AMPMASTER"
	t_Installer:	:	Data.s	"INSTALLER"

	t_text:	:	Data.s	"AMPMASTER LIBRARY V1.23+ (WINDOWS X86 - ASCII ONLY) ... "	+
	       	 	      	"AUDIO MULTIFORMAT PLAYER BASED ON THE CLASSIC WINAMP IN- AND OUT-PLUGINS ... "	+
	       	 	      	"SUPPORTS 946+ MEDIA-FORMATS (EXTENSION) BY 88+ ENGINES ... "	+
	       	 	      	"CONVERTS NEARLY ALL AUDIO-FORMATS TO WAV OR MP3, "	+
	       	 	      	"FAST INTEGRATION IN OWN PROJECTS BY AN EASY TO USE API (THINK SO ]) ... "	+
	       	 	      	"CODED IN PUREBASIC, ABSOLUTLY FREEWARE, NO ADDONS, NO CHANGE IN REGISTRY BUT NO GUARANTEE FOR 3RD PARTY STUFF! ... "	+
	       	 	      	"SEE EXAMPLES IN PUREBASIC FOR MORE ... "	+
	       	 	      	"PEACE OF TESTAWARE 2K23"

	IncludePath	"b3d\"
	b3d_airplane:		:	IncludeBinary	"Airplane.b3d"
	b3d_amptst:			:	IncludeBinary	"AmpTst.b3d"
	b3d_ampmaster:		:	IncludeBinary	"AmpMaster.b3d"
	b3d_cube:			:	IncludeBinary	"Cube.b3d"
	b3d_cube2:			:	IncludeBinary	"Cube2.b3d"
	b3d_enterprise:	:	IncludeBinary	"Enterprise.b3d"
	b3d_rotor:			:	IncludeBinary	"Rotor.b3d"

	IncludePath	"gfx\"
	b2:	:	IncludeBinary	"2.bmp"	:	b2E:	; Blue
	b6:	:	IncludeBinary	"6.bmp"	:	b6E:	; Orange

	f_font:	:	IncludeBinary	"Font.bmp"	:	f_fontE:

	CompilerSelect	IsC2D::#IsC2D_Music
		CompilerCase	IsC2D::#XMU_V2M
			IncludePath	"mus\"	:	m_music:	:	IncludeBinary	"IJs - Multi Theft Auto Credits.v2m"	:	e_music:
	CompilerEndSelect

EndDataSection
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = AAA+
; Optimizer
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = C2D_AmpMaster_x86.exe
; CompileSourceDirectory