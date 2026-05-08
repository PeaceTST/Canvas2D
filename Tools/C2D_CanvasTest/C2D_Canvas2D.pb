; C2D::Canvas2D / TestDemo
; Purebasic v6.30
; Peace^Testaware - 25.11.17 16:44 / Update: 21.08.2023 10:34

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	1.0	; = Zoomfactor of C2D:window
CompilerEndIf

;************************************************
;- *** C2D SWITCHES *****************************
;************************************************
DeclareModule	IsC2D
	XIncludeFile	"..\..\Include\C2D_Types.pbi"
	#IsC2D_Mode				=	#PB_2DDrawing_AlphaBlend	; default drawingmode
	#IsC2D_Anim				=	1	; include anim
	#IsC2D_Ball3D			=	1	; set 2 to use Starfield, Merge, Explode commands
	#IsC2D_Bitmap			=	2	; should alway on if pictures used!
	#IsC2D_BitmapColor	=	1	; functions to colorize/set transparency of bitmaps (default off)
	#IsC2D_Brush			=	1
	#IsC2D_Buffer			=	1	; Mirror, SinX/Y, FastClear by direct access to canvasbuffer
	#IsC2D_Checker			=	1	; set 2 -> draw ColorB in Backbuffer (faster, needs Buffer)
	#IsC2D_Clear			=	0	; clear canvasbuffer -> 0 = no clear, 1 colorclear (default), 2 = fastclear (RGB black only)
	#IsC2D_Copper			=	1
	#IsC2D_Delay			=	1	; Delay(#IsC2D_Delay) every call of Start()
	#IsC2D_File				=	1	; need for file-access
	#IsC2D_FlatBar			=	1
	#IsC2D_FontColor		=	1	; shadow, copper, color (default on)
	#IsC2D_FontRaw			=	1	; s. Topaz
	#IsC2D_Fps				=	1	; calculates frames per second (Canvas2D\FPS)
	#IsC2D_GdiPlus			=	1	; 1/2 -> if 0 use a native image-decoder
	#IsC2D_Gui				=	#Gui_GadgetDrawButton|#Gui_MenuPopup
	#IsC2D_Guru				=	1
	#IsC2D_Help				=	0	; Draw MouseX/Y-Coords on canvas (Stop())
	#IsC2D_Line3D			=	1
	#IsC2D_MoveText		=	1	; vertical text (move up & down)
	#IsC2D_Music			=	#XMU_SCA	; 1 .. #XMU_(?) (s. C2D_Enums.pbi / C2D MUSIC)
	#IsC2D_Network			=	0	; 176 KB - need for online-files only
	#IsC2D_PageText		=	1
	#IsC2D_Poly3D			=	1
	#IsC2D_RotoZoom		=	1	; Display rotated & zoomed picure
	#IsC2D_ScreenShot		=	1	; easy screenshots
	#IsC2D_ScrollText		=	1	; 1/2 -> ControlCodes
	#IsC2D_Splatter		=	1	; Blood-Splatter / Fireworks, support Anim
	#IsC2D_Stars2D			=	1
	#IsC2D_Stars3D			=	2
	#IsC2D_StarsR3D		=	1	; Display/Rotate x/y/z stars
	#IsC2D_StarsZ3D		=	1	; Display/Rotate x/y/z sized stars
	#IsC2D_SysFont			=	0	; use SystemFont TTF,FON,OTF... from memory ( >= PB5.50 )
	#IsC2D_Text				=	1	; static text
	#IsC2D_Time				=	0	; 0=Elapsed (default), 1=timeGetTime, 2=GetTickCount
	#IsC2D_Topaz			=	1	; 452 bytes - default topaz rawfont / #rawfont must be acitve
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

CompilerIf	IsC2D::#IsC2D_GdiPlus	=	#Null
	UsePNGImageDecoder()
	CompilerIf	#PB_Compiler_Version	>=	560
		UseGIFImageDecoder()
	CompilerEndIf
CompilerEndIf

;================================================
;- *** WINDOW GUI *******************************
;================================================
;{ **********************************************	<- GUI ********* ->
#C2D_G	=	0
#C2D_H	=	388		*	#C2D_Z
#C2D_W	=	#C2D_H	*	1.618
#SCR_X	=	2	:	#SCR_Y	=	2

#BAR_SIZE	=	48	*	#C2D_Z

#BUT_W	=	36	:	#BUT_H	=	21
#WIN_W	=	#C2D_W;	+	#SCR_X*2
#WIN_H	=	#C2D_H	+	#SCR_Y*2	+	#BUT_H

#X_STEP	=	2
#W_MIN	=	8

#SIN_X	=	20	*	#C2D_Z	; Buffer horizontal sinuswidth
#SIN_Y	=	20	*	#C2D_Z	; Buffer vertical sinusheight

#Orange	=	$008CFF

Enumeration	1	; 0 = #C2D_G
	#G_Star2D
	#G_Star3D
	#G_StarR3D
	#G_StarZ3D
	#G_L
	#G_R
	#G_U
	#G_D
	#G_Ball3D
	#G_Line3D
	#G_Poly3D
	#G_Copper
	#G_Flat
	#G_Brush
	#G_Logo
	#G_Anim
	#G_TextH
	#G_TextS
	#G_TextP
	#G_TextV
	#G_RotoZ
	#G_Checker
	#G_Mirror
	#G_SinX
	#G_SinY
	#G_Guru
	#G_Music
	#G_Speed
	#G_Color
	#G_Info
EndEnumeration
Enumeration
	#ID_LOGO0
	#ID_ANIM0
	#ID_ANIM1
EndEnumeration
Enumeration
	#ID_FONT_TITLE
	#ID_FONT_SCROLL
	#ID_FONT_SINUS
	#ID_FONT_INFO
	#ID_FONT_PAGE
	#ID_FONT_VTEXT
EndEnumeration
Enumeration
	#TEXT0
	#SCROLLH
	#TEXTH1
	#SINUS0
EndEnumeration
Enumeration	; Menu
	#M_S2D
	#M_S3D
	#M_B3D
	#M_L3D
	#M_P3D
EndEnumeration

Global	IsAnim	=	0
Global	IsBall3D	=	0
Global	IsBrush	=	0
Global	IsChecker=	0
Global	IsCopper	=	1
Global	IsFlat	=	0
Global	IsGuru	=	0
Global	IsInfo	=	0
Global	IsLine3D	=	0
Global	IsLogo	=	1
Global	IsMirror	=	0
Global	IsMusic	=	0
Global	IsPoly3D	=	0
Global	IsStar2D	=	0
Global	IsStar3D	=	0
Global	IsStarR3D=	0
Global	IsStarZ3D=	0
Global	IsSinX	=	0
Global	IsSinY	=	0
Global	IsTextH	=	1
Global	IsTextP	=	0
Global	IsTextS	=	0
Global	IsTextV	=	0
Global	IsRotoZ	=	0

Define	i, t$, File$, Path$="..\..\Data\"	; <- *** GLOBAL Path *** ->
Define.f	x, y, z, w, h, d, x0, y0, z0
Define.f	xs, xa, l3d_z=1.0


Procedure.l	xRGB()
	ProcedureReturn	(Random($FF) << 16 | Random($FF) << 8 | Random($FF)) | $FF101010
EndProcedure

Procedure	_SetBackColor(Requester=1)	; using BufferBackGrab()
	
	If	Requester
		Protected	Color	=	ColorRequester(C2D::C2D\Color)
		If	Color	>=	#Null
			C2D::C2D\Color	=	$FF000000 | Color	; Alpha + RGB
		EndIf
	EndIf
	
	CompilerIf	IsC2D::#IsC2D_Buffer
		StartDrawing(CanvasOutput(#C2D_G))
		Box(0, 0, OutputWidth(), OutputHeight(), C2D::C2D\Color)
		C2D::BufferBackGrab()
		StopDrawing()
	CompilerEndIf

EndProcedure

Procedure	_BG(ID, t$, Flags=C2D::#Gui_FlagToggle)
	
	; Buttongadget & textwidth
	
	Static	x	=	#SCR_X
	
	Protected	w	=	C2D::GuiDrawTextW(t$)	+	6
	
	C2D::GuiDrawButtonGadget(ID, x, #WIN_H-#BUT_H-#SCR_Y, w, #BUT_H, "{YG,-3}"+t$, Flags|C2D::#Gui_FlagCenter)
	
	x	=	C2D::GuiPosX()

EndProcedure

Procedure	_Swap()
	
	Static	Mode
	
	Mode!1

	IsAnim	=	Mode	:	C2D::GuiSetState(#G_Anim,		IsAnim)
	IsBall3D	=	Mode	:	C2D::GuiSetState(#G_Ball3D,	IsBall3D)
	IsBrush	=	Mode	:	C2D::GuiSetState(#G_Brush,		IsBrush)
	IsChecker=	Mode	:	C2D::GuiSetState(#G_Checker,	IsChecker)
	IsCopper	=	Mode	:	C2D::GuiSetState(#G_Copper,	IsCopper)
	IsFlat	=	Mode	:	C2D::GuiSetState(#G_Flat,		IsFlat)
	;IsGuru	=	Mode	:	C2D::GuiSetState(#G_Guru,		IsGuru)
	;IsInfo	=	Mode	:	C2D::GuiSetState(#G_Info,		IsInfo)
	IsLine3D	=	Mode	:	C2D::GuiSetState(#G_Line3D,	IsLine3D)
	IsLogo	=	Mode	:	C2D::GuiSetState(#G_Logo,		IsLogo)
	IsMirror	=	Mode	:	C2D::GuiSetState(#G_Mirror,	IsMirror)
	;IsMusic	=	Mode	:	C2D::GuiSetState(#G_Music,		IsMusic)
	IsPoly3D	=	Mode	:	C2D::GuiSetState(#G_Poly3D,	IsPoly3D)
	IsStar2D	=	Mode	:	C2D::GuiSetState(#G_Star2D,	IsStar2D)
	IsStar3D	=	Mode	:	C2D::GuiSetState(#G_Star3D,	IsStar3D)
	IsStarR3D=	Mode	:	C2D::GuiSetState(#G_StarR3D,	IsStarR3D)
	IsStarZ3D=	Mode	:	C2D::GuiSetState(#G_StarZ3D,	IsStarZ3D)
	IsSinX	=	Mode	:	C2D::GuiSetState(#G_SinX,		IsSinX)
	IsSinY	=	Mode	:	C2D::GuiSetState(#G_SinY,		IsSinY)
	IsTextH	=	Mode	:	C2D::GuiSetState(#G_TextH,		IsTextH)
	IsTextP	=	Mode	:	C2D::GuiSetState(#G_TextP,		IsTextP)
	IsTextS	=	Mode	:	C2D::GuiSetState(#G_TextS,		IsTextS)
	IsTextV	=	Mode	:	C2D::GuiSetState(#G_TextV,		IsTextV)
	
	CompilerIf	IsC2D::#IsC2D_Line3D
		C2D::GuiMenuItemToggle(#M_L3D, #PB_All, Mode)
	CompilerEndIf
	CompilerIf	IsC2D::#IsC2D_Ball3D
		C2D::GuiMenuItemToggle(#M_B3D, #PB_All, Mode)
	CompilerEndIf
	CompilerIf	IsC2D::#IsC2D_Poly3D
		C2D::GuiMenuItemToggle(#M_P3D, #PB_All, Mode)
	CompilerEndIf
	
EndProcedure

SetGadgetFont(#PB_Default, LoadFont(0, #Null$, 7))

OpenWindow(0, 0, 0, #WIN_W, #WIN_H, MA_C2DPB("Canvas2D v" + MA_XC2D() + " - TestDemo"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)	:	DisableGadget(#C2D_G, 1)
C2D::GuiInit()	:	C2D::GuiOffset(0, 1)	:	C2D::GuiCopper(?gui_copper0)	:	C2D::GuiFrame(C2D::#Gui_Frame3D)

;C2D::GuiColor()
_BG(#G_Star2D,	"2D|Stars",0)
_BG(#G_Star3D,	"3D|Stars",0)
_BG(#G_StarR3D,"R3D|Stars")
_BG(#G_StarZ3D,"Z3D|Stars")
_BG(#G_L,		"L")
_BG(#G_R,		"R")
_BG(#G_U,		"U")
_BG(#G_D,		"D")

C2D::GuiColor(#Black, $B6CE96)
_BG(#G_Ball3D,	"B3D", 0)
_BG(#G_Line3D,	"L3D", 0)
_BG(#G_Poly3D,	"P3D", 0)

C2D::GuiColor(#Black, C2D::#Gui_DefBackColor)
_BG(#G_Copper,	"C")
_BG(#G_Flat,	"F")

_BG(#G_Brush,	"Brush")
_BG(#G_Logo,	"Logo")
_BG(#G_Anim,	"Anim")

C2D::GuiColor(#Black, $82CDCE)
_BG(#G_TextH,	"T")
_BG(#G_TextS,	"S")
_BG(#G_TextP,	"P")
_BG(#G_TextV,	"M")

C2D::GuiColor(#Black, C2D::#Gui_DefBackColor)
_BG(#G_RotoZ,	"RZ")
_BG(#G_Checker,"Chk")
_BG(#G_Mirror,	"Mir")
_BG(#G_SinX,	"SX")
_BG(#G_SinY,	"SY")

C2D::GuiColor(#Black, C2D::#Gui_DefBackColor|$A0)
_BG(#G_Guru,	"Guru")
_BG(#G_Music,	"Music")	; Music

C2D::GuiColor(#Black, C2D::#Gui_DefBackColor)
_BG(#G_Color,	"RGB", #Null)	;+	#X_STEP

C2D::GuiColor(#Black, C2D::#Gui_DefBackColor|$FF)
_BG(#G_Info,	"I")

SpinGadget(#G_Speed,	#WIN_W-#SCR_X-#BUT_W, #WIN_H-#BUT_H-#SCR_Y, #BUT_W, #BUT_H,0, 64,#PB_Spin_Numeric)
;}
C2D::Init(#C2D_G)
C2D::Quality(1)
_SetBackColor(0)

DataSection
	gui_copper0:	:	Data.l	2, $40000000, $40FFFFFF
EndDataSection
;================================================

C2D::FilePath("..\..\Data\")	; Default path of files!

;================================================
;- *** Create Text ******************************
CompilerIf	IsC2D::#IsC2D_Text

	CompilerSelect	0	; <-- Set here 0 to 4
		CompilerCase	1	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font0.png"
		CompilerCase	2	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x34_font0.png"
		CompilerCase	3	:	File$	=	"http://testaware.files.wordpress.com/2017/09/48x48_font1.png"
		CompilerCase	4	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font2.png"
		CompilerCase	5	:	File$	=	"http://testaware.files.wordpress.com/2017/09/topaz.png"
		CompilerDefault	:	File$	=	"Font\PNG\48x48_Gold.png"
	CompilerEndSelect

	C2D::BitmapInit(0, @File$, #Null, #Black)
	
	; Title
	C2D::Quality(#PB_Image_Smooth)
	C2D::FontInit(#ID_FONT_TITLE,	C2D::BitmapImage(0))
	C2D::FontZoom(#ID_FONT_TITLE,	22*#C2D_Z, 24*#C2D_Z)
	C2D::FontColor(#ID_FONT_TITLE, #Green, "0123456789")
	C2D::TextInit(#TEXT0, @"canvas 2d")

; 	CompilerSelect	0	; <-- Set here 0 to 4
; 		CompilerCase	1	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font0.png"
; 		CompilerCase	2	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x34_font0.png"
; 		CompilerCase	3	:	File$	=	"http://testaware.files.wordpress.com/2017/09/48x48_font1.png"
; 		CompilerCase	4	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font2.png"
; 		CompilerCase	5	:	File$	=	"http://testaware.files.wordpress.com/2017/09/topaz.png"
; 		CompilerDefault	:	File$	=	"Font\PNG\16x16_Font2.png"
; 	CompilerEndSelect
; 
; 	C2D::BitmapInit(0,@File$, #Null, #Black)
	
	; Info
	C2D::FontRawInit(#ID_FONT_INFO)
	C2D::FontShadow(#ID_FONT_INFO, 1, 1, 128)
	C2D::FontGap(#ID_FONT_INFO, 0, 2)

	Define.f	ytxt0=(#BAR_SIZE-C2D::TextH(#TEXT0))*0.5

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_ScrollText

	t$	=	"tiny canvas 2d v"+MA_XC2D()+" example"+	#LF$	+
	  	 	"no screen no sprites so"		+	#LF$	+
	  	 	"it could be very slowly at"	+	#LF$	+
	  	 	"all cause using images only" +	#LF$	+	#LF$	+
	  	 	"C2D Size: "	+	Str(#C2D_W)	+	"X"	+	Str(#C2D_H)	+	#LF$	+
	  	 	"Peace Of Testaware 2017"
	
	C2D::Quality(#PB_Image_Raw)
	
	; Sinus
	C2D::FontRawInit(#ID_FONT_SINUS)
	C2D::FontZoom(#ID_FONT_SINUS, 24 * #C2D_Z, 32 * #C2D_Z)
	C2D::FontCopper(#ID_FONT_SINUS, ?c_textsinus)
	C2D::ScrollTextInit(#SINUS0, @t$)
	C2D::ScrollTextSinus(#SINUS0, 98.0 * #C2D_Z, 8.0 / #C2D_Z, 56 * #C2D_Z)
	C2D::ScrollTextSpeed(#SINUS0, 1.0 * #C2D_Z)
	
	; Scroller
	C2D::FontRawInit(#ID_FONT_SCROLL)
	C2D::FontZoom(#ID_FONT_SCROLL, 38 * #C2D_Z, 38 * #C2D_Z)
	C2D::FontCopper(#ID_FONT_SCROLL, ?c_textscroller)
	C2D::FontShadow(#ID_FONT_SCROLL, 2, 1, 100)
	C2D::FontSelect(#ID_FONT_SCROLL)		:	C2D::ScrollTextInit(#SCROLLH, @t$)	:	C2D::ScrollTextSpeed(#SCROLLH, #C2D_Z)
	
	Define.f	yscroll=#C2D_H-(#BAR_SIZE+C2D::ScrollTextH(#SCROLLH))*0.5
	
	DataSection
		c_textscroller:	:	Data.l	3, $FFFF0000, $FFFFFFFF, $FFFF00FF
		c_textsinus:		:	Data.l	3, $FFCF00AF, $FFFFFFFF, $FFFFFF44
	EndDataSection
	
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_PageText

	CompilerSelect	0	; <-- Set here 0 to 6
		CompilerCase	1	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font0.png"
		CompilerCase	2	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x34_font0.png"
		CompilerCase	3	:	File$	=	"http://testaware.files.wordpress.com/2017/09/48x48_font1.png"
		CompilerCase	4	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font2.png"
		CompilerCase	5	:	File$	=	"http://testaware.files.wordpress.com/2017/09/topaz.png"
		CompilerCase	6	:	File$	=	"Font\PNG\Xenon_16x22.png"
		CompilerDefault	:	File$	=	"Font\PNG\16x16_Font0.png"
	CompilerEndSelect

	C2D::Quality(#PB_Image_Smooth)

	C2D::BitmapInit(0, @File$, #Null, #Black)
	C2D::FontInit(#ID_FONT_PAGE, C2D::BitmapImage(0))
	C2D::FontZoom(#ID_FONT_PAGE, 12 * #C2D_Z, 18 * #C2D_Z)
	C2D::FontGap(#ID_FONT_PAGE, 1, 2)

	C2D::PageTextInit(?t_page, 0, 2, #C2D_W, #C2D_H, C2D::#C2F_CenterY|C2D::#C2F_CenterX)
	C2D::PageTextWait(2800)
	C2D::PageTextEffect(1, C2D::#PFX_Random, 5, 35)
	C2D::PageTextEffect(0, C2D::#PFX_Random, 5, 35)

	C2D::Quality(#PB_Image_Raw)

	DataSection
		t_page:	:	Data.s	"1. Das ist ein Text zum anzeigen!"	+	#LF$	+
		       	 	      	"Mal sehen ob es klappt mit dem text?"		+	#LF$	+
		       	 	      	"hier ein tab:" + #TAB$ + "<- bis hierher."	+	#LF$	+	#LF$	+
		       	 	      	"das eben war ne Freizeile."	+
		       	 	      	C2D::#Page_Next$	+
		       	 	      	"2. huch ein seitenwechsel"	+	#LF$	+
		       	 	      	"ob dat jeklappt hett?"	+
		       	 	      	C2D::#Page_Next$	+
		       	 	      	"3. Klasse, aber warum beginnt er nicht mit"	+	#LF$	+
		       	 	      	"Seite 1 des PageText() ?"	+	#LF$	+	#LF$	+
		       	 	      	"Habe da wohl was Uebersehen?"	+	#LF$	+	#LF$	+
		       	 	      	"ahh... resetlist() benoetigt nextelement()"	+	#LF$	+
		       	 	      	"boa ey... man man!"	+	#LF$	+	#LF$	+
		       	 	      	"jetzt aber... der text wird zentriert"	+	#LF$	+
		       	 	      	"angezeigt und sollte ohne diese freizeichen"	+	#LF$	+
		       	 	      	"ordentlich schnell angezeigt werden, gucken!"	+
		       	 	      	C2D::#Page_Next$	+
		       	 	      	"4. ok... alles von vorn :)"	+
		       	 	      	"~"	+
		       	 	      	" !" + #DQUOTE$ + "#$%&'|"	+
									"()*+,-./|"	+
									"01234567|"	+
									"89:;<=>?|"	+
									"@ABCDEFG|"	+
									"HIJKLMNO|"	+
									"PQRSTUVW|"	+
									"XYZ[\]^_"
	EndDataSection
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_MoveText

	CompilerSelect	0	; <-- Set here 0 to 6
		CompilerCase	1	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font0.png"
		CompilerCase	2	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x34_font0.png"
		CompilerCase	3	:	File$	=	"http://testaware.files.wordpress.com/2017/09/48x48_font1.png"
		CompilerCase	4	:	File$	=	"http://testaware.files.wordpress.com/2017/09/16x16_font2.png"
		CompilerCase	5	:	File$	=	"http://testaware.files.wordpress.com/2017/09/topaz.png"
		CompilerCase	6	:	File$	=	"Font\PNG\Xenon_16x22.png"
		CompilerDefault	:	File$	=	"Font\PNG\16x16_Font2.png"
	CompilerEndSelect

	C2D::Quality(#PB_Image_Smooth)

	C2D::BitmapInit(0, @File$, #Null, #Black)
	C2D::FontInit(#ID_FONT_VTEXT, C2D::BitmapImage(0))
	C2D::FontColor(#ID_FONT_VTEXT, $00FF00, "13579")
	C2D::FontZoom(#ID_FONT_VTEXT, 16 * #C2D_Z, 16 * #C2D_Z)
	C2D::FontShadow(#ID_FONT_VTEXT, 2, 2, 128)
	C2D::FontGap(#ID_FONT_VTEXT, -2, 0)

	C2D::MoveTextInit(0, ?t_vtext, 0, #BAR_SIZE + 1, #C2D_W, #C2D_H - #BAR_SIZE * 2 - 2, C2D::#C2F_Center)
	C2D::MoveTextSpeed(0, -0.25)

	C2D::Quality(#PB_Image_Raw)

	DataSection
		t_vtext:
		Data.s	"Das ist ein Text zum anzeigen!|"			+
		      	"Mal sehen ob es klappt mit dem text?||"	+
		      	"					 <--->					|"		+
		      	"hier ein tab:=	=bis hierher.|"			+
		      	"					 (---)					||||"	+
		      	"das eben war'n nen paar Freizeilen.|"		+
		      	"||"	+
		      	"huch ein seitenwechsel|"						+
		      	"das hat also geklappt $ hoffentlich $"	+
		      	"||"	+
		      	"Klasse, aber warum beginnt er nicht mit|"	+
		      	"Seite 1 des PageText?||"							+
		      	"Habe da wohl was uebersehen.||"					+
		      	"ahh @ resetlist benoetigt nextelement|"		+
		      	"boa ey & man man!"									+
		      	"||"	+
		      	"jetzt aber &||"								+
		      	"* der text wird zentriert angezeigt|"	+
		      	"* und auch ohne  diese  freizeichen|"	+
		      	"* ordentlich  dargestellt	werden!"		+
		      	"||"	+
		      	"ok & alles von vorn @|"		+
		      	"zuvor aber alle buchstaben &"+
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

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Checker
	C2D::CheckerInit(#C2D_H * 0.6, #C2D_H * 0.4 - #BAR_SIZE, 170 * #C2D_Z, 6)
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Copper

	C2D::CopperInit(1, #BAR_SIZE,	?l_cred);,	C2D::#C2F_Horizontal)
	C2D::CopperInit(2, #BAR_SIZE,	?l_cblue)
	C2D::CopperInit(3, 1, ?l_cbow, C2D::#C2F_Horizontal)
	C2D::CopperInit(4, 1, ?l_cbow, C2D::#C2F_Horizontal)

	Define.f	ycopper=#C2D_H-C2D::CopperH(2)

	DataSection
		l_cred:		:	Data.l	3,	#Red,			$FF707000|#Red,		#Red
		l_cgreen:	:	Data.l	3,	#Green,		$FF700070|#Green,		#Green
		l_cblue:		:	Data.l	3,	#Blue,		$FF007070|#Blue,		#Blue
		l_cyellow:	:	Data.l	3,	#Yellow,		$FF700000|#Yellow,	#Yellow
		l_ccyan:		:	Data.l	3,	#Cyan,		$FF000070|#Cyan,		#Cyan
		l_cmagenta:	:	Data.l	3,	#Magenta,	$FF000000|#Magenta,	#Magenta
		l_cwhite:	:	Data.l	3,	#White,		$FF000000|#White,		#White
		l_cbow:		:	Data.l	7,
		       		 	      	$FF000000|#Magenta,
		       		 	      	$FF000000|$FFBB00,
		       		 	      	$FF000000|#Green,
		       		 	      	$FF000000|#Yellow,
		       		 	      	$FF000000|#Orange,
		       		 	      	$FF000000|#Red,
		       		 	      	$FF000000|#Magenta
	EndDataSection

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_FlatBar
	C2D::FlatBarInit(1, #BAR_SIZE, xRGB(), 2)
	C2D::FlatBarInit(2, #BAR_SIZE, xRGB(), 2)
	Define.f	yflat=#C2D_H  - C2D::FlatBarH(2)
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Stars2D

	#S2D_SPEED	=	#C2D_W/#C2D_H	*	#C2D_Z

	x	=	0
	y	=	#BAR_SIZE	+	1
	w	=	#C2D_W	-	x	*	2
	h	=	#C2D_H	-	y	*	2

	CompilerSelect	0	; <-- Set here 0 to 2
		CompilerCase	1
			C2D::BitmapInit(0, @"Ball\Plastic\6.png")
			C2D::Stars2DInit(230, 8 * #C2D_Z, x, y, w, h, #S2D_SPEED, C2D::BitmapImage(0))
		CompilerCase	2
			C2D::BitmapAdd(0, C2D::Ball3DImage(Random(C2D::#MAX_BALL)))
			C2D::Stars2DInit(230, 8 * #C2D_Z, x, y, w, h, #S2D_SPEED, C2D::BitmapImage(0))
		CompilerDefault
			C2D::Stars2DInit(280, 1, x, y, w, h, #S2D_SPEED)
	CompilerEndSelect
	
	C2D::GuiMenuInit(#M_S2D, "2D Stars Left;2D Stars Right;2D Stars Up;2D Stars Down;-;2D Stars Off")

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Stars3D

	x	=	0
	y	=	#BAR_SIZE	+	1
	w	=	#C2D_W	-	x	*	2	-	2
	h	=	#C2D_H	-	y	*	2

	CompilerSelect	0	; <-- Set here 0 to 3
		CompilerCase	1
			C2D::BitmapInit(0, @"Ball\Pearl\5.png")
			C2D::Stars3DInit(280 * #C2D_Z, 12 * #C2D_Z, x, y, w, h, 2.5, C2D::BitmapImage(0))
		CompilerCase	2
			C2D::BitmapInit(0, @"Misc\AlphaBall.png")
			C2D::Stars3DInit(280 * #C2D_Z, 12 * #C2D_Z, x, y, w, h, 2.5, C2D::BitmapImage(0))
		CompilerCase	3
			C2D::BitmapAdd(0, C2D::Ball3DImage(Random(C2D::#MAX_BALL)))
			C2D::Stars3DInit(280 * #C2D_Z, 12 * #C2D_Z, x, y, w, h, 2.5, C2D::BitmapImage(0))
		CompilerDefault
			C2D::Stars3DInit(360 * #C2D_Z, 1, x, y, w, h, 2.1)
	CompilerEndSelect
	
	C2D::GuiMenuInit(#M_S3D, "3D Stars Center;3D Stars Left;3D Stars Right;-;3D Stars Off")

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_StarsR3D

	x	=	0
	y	=	#BAR_SIZE	+	1
	w	=	#C2D_W	-	x	*	2
	h	=	#C2D_H	-	y	*	2

	CompilerSelect	3	; <-- Set here 0 to 3
		CompilerCase	1
			C2D::BitmapInit(0, @"Ball\Pearl\5.png")
			C2D::StarsR3DInit(400 * #C2D_Z, x, y, w, h, 12 * #C2D_Z, C2D::BitmapImage(0))
		CompilerCase	2
			C2D::BitmapInit(0, @"Misc\AlphaBall.png")
			C2D::StarsR3DInit(400 * #C2D_Z, x, y, w, h, 12 * #C2D_Z, C2D::BitmapImage(0))
		CompilerCase	3
			C2D::StarsR3DInit(400 * #C2D_Z, x, y, w, h, 16 * #C2D_Z, C2D::Ball3DImage(Random(C2D::#MAX_BALL)))
		CompilerDefault
			C2D::StarsR3DInit(400 * #C2D_Z, x, y, w, h, 2 * #C2D_Z)
	CompilerEndSelect

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_StarsZ3D

	x	=	0
	y	=	#BAR_SIZE	+	1
	w	=	#C2D_W	-	x	*	2
	h	=	#C2D_H	-	y	*	2

	CompilerSelect	0	; <-- Set here 0 to 3
		CompilerCase	1
			C2D::BitmapInit(0, @"Ball\Pearl\5.png")
			C2D::StarsZ3DInit(400 * #C2D_Z, x, y, w, h, 21 * #C2D_Z, C2D::BitmapImage(0))
		CompilerCase	2
			C2D::BitmapInit(0, @"Misc\AlphaBall.png")
			C2D::StarsZ3DInit(400 * #C2D_Z, x, y, w, h, 21 * #C2D_Z, C2D::BitmapImage(0))
		CompilerCase	3
			C2D::StarsZ3DInit(400 * #C2D_Z, x, y, w, h, 21 * #C2D_Z, C2D::Ball3DImage(Random(C2D::#MAX_BALL)))
		CompilerDefault
			C2D::StarsZ3DInit(400 * #C2D_Z, x, y, w, h, 9 * #C2D_Z)
	CompilerEndSelect

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Ball3D

	#MAX_B3D	=	13	; max. Ball3D objects (0-x)

	CompilerSelect	0	; <-- Set here 0 to 2 (0=Default)
		CompilerCase	1
			C2D::Ball3DLoadTheme("Ball\Pearl\")
		CompilerCase	2
			C2D::Ball3DLoadTheme("Ball\Plastic\")
	CompilerEndSelect
	
	C2D::Quality(0)
	
	i	=	#Null
	t$ = "{CF,$8F}Ball3D Off;"	+	"{TH,12}{YP,5}{SL,$FF,1};"
	
	If	ExamineDirectory(0, "..\..\Data\Object\B3D\", "*.b3d")
		While	NextDirectoryEntry(0)
			If	DirectoryEntryType(0)	=	#PB_DirectoryEntry_File
				File$	=	DirectoryEntryName(0)
				t$	+	Str(i) + ":	" + StringField(File$, 1, ".")	+	"	;"
				File$	=	"Object\B3D\" + File$
				C2D::Ball3DInit(i, @File$, 12 * #C2D_Z)
				i	+	1
			EndIf
		Wend
	EndIf

	ID_B3D	=	Random(i-1)
	C2D::Ball3DAngle(ID_B3D, C2D::MA_RMP(398) * Bool(ID_B3D<>#MAX_B3D), C2D::MA_RMP(398), C2D::MA_RMP(398))
	
	C2D::Quality(1)
	
	C2D::GuiMenuInit(#M_B3D, t$, i + 2)
	C2D::GuiMenuItemSetData(#M_B3D, 0, -1)

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Line3D

	#MAX_L3D	=	15	; max. Line3D objects (0..i)
	
	i	=	#Null
	t$ = "{CF,$8F}Line3D Off;"	+	"{TH,12}{YP,5}{SL,$FF,1};"
	;t$ = "{CF,$8F}0;"	+	"{TH,12}{YP,5}{SL,$FF,1};"

	If	ExamineDirectory(0, "..\..\Data\Object\L3D\", "*.l3d")
		While	NextDirectoryEntry(0)
			If	DirectoryEntryType(0)	=	#PB_DirectoryEntry_File
				File$	=	DirectoryEntryName(0)
				t$	+	Str(i) + ":	" + StringField(File$, 1, ".")	+	"	;"
				;t$	+	Str(i) + ";"
				File$	=	"Object\L3D\" + File$
				C2D::Line3DInit(i, @File$);, 1.0 * #C2D_Z);, 28 * #C2D_Z)
				i	+	1
			EndIf
		Wend
	EndIf

	C2D::Line3DFog(#PB_All, 14.8)
	
	C2D::GuiMenuInit(#M_L3D, t$, i + 2)
	C2D::GuiMenuItemSetData(#M_L3D, 0, -1)

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Anim

	CompilerSelect	3	; <-- Set here 0 to 4
		CompilerCase	1
			C2D::BitmapInit(0, @"Anim\Anim_IK+Dance_16x18.png")
			C2D::BitmapScale(0, 3)
			C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 16, 18)
			C2D::AnimDelay(#ID_ANIM0, 60)
		CompilerCase	2
			C2D::BitmapInit(0, @"Anim\Anim_AgonyOwl_16x1.png")
			C2D::BitmapScale(0, 2)
			C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 16, 1)
		CompilerCase	3
			C2D::BitmapInit(0, @"Anim\Anim_TRS_17x3_51.png")
			C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 17, 3)
			C2D::AnimDelay(#ID_ANIM0, 80)
			C2D::AnimDelay(#ID_ANIM0, 2500, 50)
			C2D::AnimDelay(#ID_ANIM0, 2500, 0)
			C2D::AnimPingPong(#ID_ANIM0)
		CompilerCase	4
			C2D::BitmapInit(0, @"Anim\Anim_OSDM_Gold_5x3.png")
			C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 5, 3)
			C2D::AnimDelay(#ID_ANIM0, 60)
		CompilerDefault
			C2D::BitmapInit(0, @"Anim\Anim_Earth_8x6.png")
			C2D::AnimInit(#ID_ANIM0, C2D::BitmapImage(0), 8, 6, 48)
			C2D::AnimDelay(#ID_ANIM0, 43)
	CompilerEndSelect

	C2D::AnimScale(#ID_ANIM0, #C2D_Z)

CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Poly3D
	
	i	=	#Null
	t$ = "{CF,$8F}Poly3D Off;"	;+	"{TH,12}{YP,5}{SL,$FF,1};"
	
	If	ExamineDirectory(0, "..\..\Data\Object\P3D\", "*.p3d")
		While	NextDirectoryEntry(0)
			If	DirectoryEntryType(0)	=	#PB_DirectoryEntry_File
				File$	=	DirectoryEntryName(0)
				t$	+	Str(i) + ":	"	+	StringField(File$, 1, ".")	+	"	;"
				File$	=	"Object\P3D\" + File$
				C2D::Poly3DInit(i, @File$)	:	C2D::Poly3DScale(0, 6)
				i	+	1
			EndIf
		Wend
	EndIf
	
	C2D::Poly3DClip(#PB_All, 0, #BAR_SIZE, #C2D_W, #C2D_H-#BAR_SIZE*2)

	C2D::GuiMenuInit(#M_P3D, t$, i + 2)
	C2D::GuiMenuItemSetData(#M_P3D, 0, -1)
	
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Brush
	#MOVE_XB	=	0.15
	#MOVE_YB	=	0.15
	CompilerSelect	2
		CompilerCase	1	:	C2D::BitmapInit(#ID_LOGO0, @"Back\Asia_IK+.png")
		CompilerCase	2	:	C2D::BitmapInit(#ID_LOGO0, @"..\..\Demos\Testaware_Democide\media\2urall_blue.jpg")
		CompilerCase	3	:	C2D::BitmapInit(#ID_LOGO0, @"D:\Testaware\OldSkool DemoMaker\Data\Layer\Gods_Back.png")
		CompilerCase	4	:	C2D::BitmapInit(#ID_LOGO0, @"D:\Testaware\OldSkool DemoMaker\Data\Layer\Beast_Mountain.png")
		CompilerCase	5	:	C2D::BitmapInit(#ID_LOGO0, @"D:\Testaware\OldSkool DemoMaker\Data\Layer\Beast.png")
		CompilerCase	6	:	C2D::BitmapInit(#ID_LOGO0, @"D:\Testaware\OldSkool DemoMaker\Data\Layer\Matrix.png")
		CompilerDefault	:	C2D::BitmapInit(#ID_LOGO0, @"Back\Cloud_Sky.png",0, $EFB237)
	CompilerEndSelect
	C2D::BitmapLoop(#ID_LOGO0, C2D::#C2F_Horizontal|C2D::#C2F_Vertical)
	C2D::BrushInit(0, C2D::BitmapImage(#ID_LOGO0), 0, #BAR_SIZE, #C2D_W, #C2D_H-#BAR_SIZE*2)
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_RotoZoom
	x	=	0
	y	=	#BAR_SIZE	+	1
	w	=	#C2D_W	-	x	*	2	-	2
	h	=	#C2D_H	-	y	*	2
	C2D::BitmapInit(#ID_LOGO0, @"..\..\Data\Logo\Psygnosis.bmp")
	C2D::RotoZoomInit(C2D::BitmapImage(#ID_LOGO0), 224, #Black)
	C2D::RotoZoomSet(15, 3, 140, 2100)
	C2D::RotoZoomClip(x, y, w, h)
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Splatter
	
	Define	SplatterID, SplatterCount
	
	For	i	=	0	To	7
		Select	i
			Case	0	:	x	=	#Red
			Case	1	:	x	=	#Yellow
			Case	2	:	x	=	#Magenta
			Case	3	:	x	=	#Cyan
			Case	4	:	x	=	#Green
			Case	5	:	x	=	#White
			Case	6	:	x	=	#Orange	; Orange
			Case	7	:	x	=	$C79E6F	; bluegray
			Default	:	x	=	RGB(Random(255,64),Random(255,32),Random(255,16))
		EndSelect
		C2D::SplatterInit(i, Random(12, 5), Random(128, 8), x)
		C2D::SplatterSpread(i, Random(16), Random(16))
		C2D::SplatterEnergy(i, Random(8000, 1000))
		C2D::SplatterGravity(i, Random(50))
		C2D::SplatterStop(i)
	Next
	
CompilerEndIf

CompilerIf	IsC2D::#IsC2D_Music
	Music$	=	Path$	+	"Music\MOD\Estrayk - Mirror.mod"
	;C2D::MusicInit()	;"Path:\ + AmpMaster\")
CompilerEndIf

;- *** Create Logos *****************************
CompilerSelect	0	; <-- Set here 0 to 4 (InitNetwork)
	CompilerCase	1	:	File$	=	"http://testaware.files.wordpress.com/2013/10/testawarelogobig.gif"
	CompilerCase	2	:	File$	=	"http://ftp.amigascne.org/pub/amiga/Gfx/A/Angeldawn/Unsorted/flt-medi.png"
	CompilerCase	3	:	File$	=	"http://ftp.amigascne.org/pub/amiga/Gfx/S/Seen/Quartex-logo.bmp"
	CompilerCase	4	:	File$	=	"http://testaware.files.wordpress.com/2013/10/testaware_2k2.png"
	CompilerDefault	:	File$	=	"Logo\Testaware_Logo.png"
CompilerEndSelect
If	FindString(File$, "://")	:	Color=#Black	:	Else	:	Color=#PB_Default	:	EndIf

C2D::BitmapInit(#ID_LOGO0, @File$, #Null, Color)
C2D::BitmapScale(#ID_LOGO0, #C2D_Z)

;************************************************
; *** MainLoop **********************************
;************************************************
C2D::GuiSetState(#G_Anim,		IsAnim)
C2D::GuiSetState(#G_Ball3D,	IsBall3D)
C2D::GuiSetState(#G_Brush,		IsBrush)
C2D::GuiSetState(#G_Checker,	IsChecker)
C2D::GuiSetState(#G_RotoZ,		IsRotoZ)
C2D::GuiSetState(#G_Copper,	IsCopper)
C2D::GuiSetState(#G_Flat,		IsFlat)
C2D::GuiSetState(#G_Guru,		IsGuru)
C2D::GuiSetState(#G_Info,		IsInfo)
C2D::GuiSetState(#G_Line3D,	IsLine3D)
C2D::GuiSetState(#G_Logo,		IsLogo)
C2D::GuiSetState(#G_Mirror,	IsMirror)
C2D::GuiSetState(#G_Music,		IsMusic)
C2D::GuiSetState(#G_Poly3D,	IsPoly3D)
C2D::GuiSetState(#G_Star2D,	IsStar2D)
C2D::GuiSetState(#G_Star3D,	IsStar3D)
C2D::GuiSetState(#G_StarR3D,	IsStarR3D)
C2D::GuiSetState(#G_StarZ3D,	IsStarZ3D)
C2D::GuiSetState(#G_SinX,		IsSinX)
C2D::GuiSetState(#G_SinY,		IsSinY)
C2D::GuiSetState(#G_TextH,		IsTextH)
C2D::GuiSetState(#G_TextP,		IsTextP)
C2D::GuiSetState(#G_TextS,		IsTextS)
C2D::GuiSetState(#G_TextV,		IsTextV)
C2D::GuiSetState(#G_R, 1)	:	i	=	#G_R

SetGadgetState(#G_Speed, C2D::C2D\Speed)

Define.f	xb=-#MOVE_XB, yb	; Brush

x	=	0	:	y	=	0

Repeat

	Select WindowEvent()

		Case	#Null	; *** Demo ***

			If	C2D::Start()	; <-- Update after here all C2D gfx
				
				mx	=	WindowMouseX(0)
				my	=	WindowMouseY(0)
				
				CompilerIf	IsC2D::#IsC2D_Buffer	; Clear backbuffer
					C2D::BufferBackDraw()
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Brush
					If	IsBrush
						C2D::BrushMove(0, xb, yb)	:	C2D::BrushDraw(0)
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_RotoZoom
					If	IsRotoZ
						C2D::RotoZoomDraw(500, 1780)
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Checker
					If	IsChecker
						C2D::CheckerDraw(2.0, MA_GSin(C2D::C2D\Time * 0.1) * 2.0)
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Ball3D
					If	IsBall3D
						C2D::Ball3DRotate(ID_B3D,  0.82 * Bool(ID_B3D<>#MAX_B3D), -0.77,  0.43)	; Rotate Ball3D Object
						b3d	=	C2D::Ball3DDraw(ID_B3D, 0, 0, 215, 40)	; Display Ball3D Object
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Line3D
					If	IsLine3D
						x	=	C2D::C2D\Time	*	0.000215
						C2D::Line3DRotate(ID_L3D,  Cos(x*0.5)*1.03, Sin(x*0.7)*1.04, Cos(x*0.9)*1.05)	; Rotate Line3D Object
						;C2D::Line3DRotate(ID_L3D,  MA_GCos(x*0.5)*1.03, MA_GSin(x*0.7)*1.04, MA_GCos(x*0.9)*1.05)	; Rotate Line3D Object
						C2D::Line3DDraw(ID_L3D, 0, 0, l3d_z, l3d_z)	; Display Line3D Object
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Poly3D
					If	IsPoly3D
						C2D::Poly3DRotate(ID_P3D, 2.713, 2.131, Sin(ElapsedMilliseconds()*0.167));*0.167)
						C2D::Poly3DDraw(ID_P3D)
					EndIf
				CompilerEndIf
				
				CompilerIf	IsC2D::#IsC2D_Anim
					If	IsAnim
						C2D::AnimDraw(#ID_ANIM0, 0, 0, 255, C2D::#C2F_Center)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_PageText
					If	IsTextP
						C2D::PageTextDraw(0, 0)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_ScrollText
					If	IsTextS
						C2D::ScrollTextDraw(#SINUS0, (#C2D_H - 32 * #C2D_Z) * 0.5)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_MoveText
					If	IsTextV
						C2D::MoveTextDraw(0)
					EndIf
				CompilerEndIf
				
				If	IsLogo
					C2D::BitmapDraw(#ID_LOGO0, 0, 0, 255, C2D::#C2F_Center)
				EndIf
				
				CompilerIf	IsC2D::#IsC2D_Splatter
					If	SplatterCount
						SplatterCount	=	#Null
						ClipOutput(0, #BAR_SIZE, #C2D_W, #C2D_H - #BAR_SIZE)
						For	i	=	0	To	7
							SplatterCount	+	C2D::SplatterDraw(i, #C2D_H-#BAR_SIZE)
						Next
						UnclipOutput()
					EndIf
				CompilerEndIf

				CompilerIf	IsC2D::#IsC2D_Buffer	; <-- SinY, SinX, Mirror
					If	IsSinY
						C2D::BufferSinY(0, #BAR_SIZE + #SIN_Y, #C2D_W, #C2D_H - (#BAR_SIZE + #SIN_Y) * 2, #SIN_Y, 0.62*4, 2.05*3, 1)
					EndIf
					If	IsSinX
						C2D::BufferSinX(#SIN_X, 0, #C2D_W - #SIN_X * 2 - C2D::#MAX_BPP, #C2D_H, #SIN_X, 2.06*4, 2.018*4)
					EndIf
					If	IsMirror
						C2D::BufferMirror(0, #C2D_H - #BAR_SIZE - 50 * #C2D_Z, #C2D_W, 100 * #C2D_Z, %10)
						Box(0, #C2D_H - #BAR_SIZE - 50 * #C2D_Z, #C2D_W, 50, $40FF0000)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_Stars2D
					If	IsStar2D
						C2D::Stars2DDraw()
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_Stars3D
					If	IsStar3D
						C2D::Stars3DDraw(x, y)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_StarsR3D
					If	IsStarR3D
						C2D::StarsR3DDraw(MA_GCos(C2D::C2D\Time * 0.091) * 13 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.083) * 5 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.111) * 0.05)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_StarsZ3D
					If	IsStarZ3D
						C2D::StarsZ3DDraw(MA_GCos(C2D::C2D\Time * 0.091) * 13 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.083) * 5 * #C2D_Z, MA_GCos(C2D::C2D\Time * 0.111) * 0.05)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_FlatBar
					If	IsFlat
						C2D::FlatBarDraw(1, 0)
						C2D::FlatBarDraw(2, yflat)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_Copper
					If	IsCopper
						C2D::CopperDraw(1, 0)
						C2D::CopperDraw(2, ycopper)
						;C2D::CopperMoveDraw(1, 100, Cos(ElapsedMilliseconds()*0.001))
						;C2D::CopperMoveDraw(2, 100, Sin(ElapsedMilliseconds()*0.001))
						C2D::CopperMoveDraw(3, #BAR_SIZE-1,			-0.8 * #C2D_Z)
						C2D::CopperMoveDraw(4, #C2D_H-#BAR_SIZE,	 0.8 * #C2D_Z)
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_Text
					If	IsTextH
						C2D::TextDraw(#TEXT0, 0, ytxt0, 255, C2D::#C2F_CenterX)	; Title
					EndIf
				CompilerEndIf
				CompilerIf	IsC2D::#IsC2D_ScrollText
					If	IsTextH
						C2D::ScrollTextDraw(#SCROLLH, yscroll)	; Scroller
					EndIf
				CompilerEndIf
				
				; *** Infos ***
				If	IsInfo

					t$	=	"FPS  :"	+	Str(C2D::C2D\FPS)	+	#LF$	+
					  	 	"SPEED:"	+	Str(spd)	+	#LF$	+
					  	 	"SIZE :"	+	Str(C2D::C2D\w) + "/" + Str(C2D::C2D\h)
					CompilerIf	IsC2D::#IsC2D_Ball3D
						If	IsBall3D
							t$	+	#LF$	+	"BALLS:"	+	Str(b3d)
						EndIf
					CompilerEndIf

					t$	+	#LF$	+	"X/Y  :" + Str(mx) + "/" + Str(my)
					
					CompilerIf	IsC2D::#IsC2D_Splatter
						If	SplatterCount
							t$	+	#LF$	+	"COUNT:"	+	Str(SplatterCount)
						EndIf
					CompilerEndIf

					C2D::FontSelect(#ID_FONT_INFO)
					C2D::TextStringDraw(0, 2, t$)

					DrawingMode(#PB_2DDrawing_XOr)
					FrontColor($FFFFFFFF)
					LineXY(mx, 0, mx, #C2D_H)
					LineXY(0, my, #C2D_W, my)

					If	C2D::C2D\FPS_Count	=	#Null
						spd	=	C2D::C2D\Time	-	spd_t
					Else
						spd_t	=	C2D::C2D\Time
					EndIf

				EndIf

				C2D::Stop()	; <-- Must call at last after finish updates!

			EndIf

		Case #PB_Event_Gadget	; *** Gadget-Events ***
			
			Gadget	=	EventGadget()

			Select	C2D::GuiEvent(Gadget)
				Case	#G_Copper	:	IsCopper!1
				Case	#G_Flat		:	IsFlat!1
					CompilerIf	IsC2D::#IsC2D_FlatBar
						If	IsFlat
							C2D::FlatBarInit(1, #BAR_SIZE, xRGB(), 2)
							C2D::FlatBarInit(2, #BAR_SIZE, xRGB(), 2)
						EndIf
					CompilerEndIf
					
				Case	#G_Star2D	;:	IsStar2D!1
					CompilerIf	IsC2D::#IsC2D_Stars2D
						C2D::GuiCopper()	:	C2D::GuiOffset(4)
						Select	C2D::GuiMenuPopup(#M_S2D)
							Case	0	:	IsStar2D=1	:	C2D::Stars2DDirection(C2D::#C2F_Left)
							Case	1	:	IsStar2D=1	:	C2D::Stars2DDirection(C2D::#C2F_Right)
							Case	2	:	IsStar2D=1	:	C2D::Stars2DDirection(C2D::#C2F_Up)
							Case	3	:	IsStar2D=1	:	C2D::Stars2DDirection(C2D::#C2F_Down)
							Case	C2D::GuiMenuSize(#M_S2D)-1	:	IsStar2D=0
						EndSelect
					CompilerEndIf
					
				Case	#G_Star3D	;:	IsStar3D!1
					CompilerIf	IsC2D::#IsC2D_Stars3D
						C2D::GuiCopper()	:	C2D::GuiOffset(4)
						Select	C2D::GuiMenuPopup(#M_S3D)
							Case	0	:	IsStar3D=1	:	x	=	0	:	y	=	0
							Case	1	:	IsStar3D=1	:	x	=	#C2D_W 	*	0.30
							Case	2	:	IsStar3D=1	:	x	=	-#C2D_W	*	0.30
							Case	C2D::GuiMenuSize(#M_S3D)-1	:	IsStar3D=0	
						EndSelect
					CompilerEndIf
					
				Case	#G_StarR3D	:	IsStarR3D!1
					
				Case	#G_StarZ3D	:	IsStarZ3D!1

				Case	#G_Brush		:	IsBrush!1
					CompilerIf	IsC2D::#IsC2D_Brush
						xb	=	-#MOVE_XB	:	yb	=	0
						C2D::BrushMove(0, C2D::MA_RMP(798), C2D::MA_RMP(798))
					CompilerEndIf
					
				Case	#G_Logo		:	IsLogo!1
				Case	#G_Anim		:	IsAnim!1
				Case	#G_TextH		:	IsTextH!1
				Case	#G_TextS		:	IsTextS!1
				Case	#G_TextP		:	IsTextP!1
				Case	#G_TextV		:	IsTextV!1
				Case	#G_Checker	:	IsChecker!1
				Case	#G_RotoZ		:	IsRotoZ!1
				Case	#G_Mirror	:	IsMirror!1	; Buffer
				Case	#G_SinX		:	IsSinX!1		; Buffer
				Case	#G_SinY		:	IsSinY!1		; Buffer
					
				Case	#G_Guru		:	IsGuru!1
					CompilerIf	IsC2D::#IsC2D_Guru
						If	IsGuru
							Select	GuruID
								Case	0
									t$	=	"GURU MEDITATION||"	+
									  	 	"DON'T WORRY - THIS IS ONLY A TEST-PREVIEW!"		+	#LF$	+	#LF$	+
									  	 	"BUT WHY A GURU MEDITATION FOR ERRORMESSAGES?"	+ #LF$	+
									  	 	"COZ IT REMEBERS ON GOOD OLD AMIGA TIMES THEN!" + #LF$	+	#LF$	+
									  	 	"PRESS THE [GURU] BUTTON OR STAY IN MEDITATION ;)"
									C2D::GuruInit(@t$)
								Case	1
									C2D::GuruInit(@"GURU MEDITATION")
								Case	2
									t$	=	"<<<<<<<<<<< THE GOODWILL I/98 VIRUS ALARM! >>>>>>>>>>>||"	+
									  	 	"ARE  YOU  A  FOOLISH  USER  OR  ARE  YOU  ONLY  STUPID" + #LF$ +
									  	 	"WHAT COULD ALL BE HAPPEN IF I WOULD BE A FUCKIN' VIRUS" + #LF$ +
									  	 	"SO YOU  SHOULD CHECK  YOUR DISKS AS  SOON  AS POSSIBLE" + #LF$ +
									  	 	"AND IN FUTURE  ALWAYS CHECK YOUR DISKS BEFORE USING IT" + #LF$ +
									  	 	"BUT AT FIRST WE REALLY HOPE THAT WE HAVE SHOCKED YOU!!" + #LF$ + #LF$ +
									  	 	"<<<<<<<<<<<<<<<<< BYE, YOUR PAPILLON! >>>>>>>>>>>>>>>>"
									C2D::GuruInit(@t$)
							EndSelect
							GuruID	+	1	:	If	GuruID	>	2	:	GuruID	=	0	:	EndIf
						Else
							C2D::GuruFree()
						EndIf
					CompilerEndIf

				Case	#G_Ball3D	;:	IsBall3D!1
					CompilerIf	IsC2D::#IsC2D_Ball3D
						
						i	=	(C2D::#Gui_FlagState*Random(1))
						
						C2D::GuiCopper()	:	C2D::GuiOffset(2*Bool(i=0))	:	C2D::GuiFrame(Random(7),Random($FF))	:	C2D::GuiToggleColor($FF555555|Random($FFFFFF))
						
						If	C2D::GuiMenuPopup(#M_B3D, C2D::#Gui_FlagToggle|C2D::#Gui_FlagUser|i, Random(32,5))	>=	0
							
							i	=	C2D::GuiMenuGetItem(#M_B3D)
							
							Select	i
								Case	0
									C2D::GuiMenuSetState(#M_B3D, -1)
									IsBall3D	=	0
								Default
									IsBall3D	=	1
									ID_B3D	=	i	-	2	;Val(C2D::GuiDrawTextRaw(C2D::GuiMenuGetText(#M_B3D)))
									C2D::Ball3DAngle(ID_B3D, C2D::MA_RMP(798) * Bool(ID_B3D<>#MAX_B3D), C2D::MA_RMP(798), C2D::MA_RMP(798))
									C2D::GuiMenuSetState(#M_B3D, i)
									;C2D::GuiMenuItemToggle(#M_B3D, i, 1)
							EndSelect
						EndIf
						
						C2D::GuiFrame(C2D::#Gui_Frame3D, $7F)
						
					CompilerEndIf

				Case	#G_Line3D	;:	IsLine3D!1
					CompilerIf	IsC2D::#IsC2D_Line3D
						
						C2D::GuiCopper()	:	C2D::GuiColor(C2D::RS_GUI\Gadget()\Color, C2D::RS_GUI\Gadget()\BackColor)
						C2D::GuiOffset(0)	:	C2D::GuiFrame(C2D::#Gui_Frame3D * Random(1))
						
						If	C2D::GuiMenuPopup(#M_L3D, C2D::#Gui_FlagState|C2D::#Gui_FlagToggle|C2D::#Gui_FlagUser, Random(32,5))	>=	0
							
							i	=	C2D::GuiMenuGetItem(#M_L3D)
							
							Select	i
								Case	0	To	C2D::GuiMenuSize(#M_L3D)
									If	C2D::GuiMenuItemGetData(#M_L3D, i)	<	#Null	; Off
										IsLine3D	=	0
										C2D::GuiMenuSetState(#M_L3D, -1)
									Else
										IsLine3D	=	1
										ID_L3D	=	i	-	2	;Val(C2D::GuiDrawTextRaw(C2D::GuiMenuGetText(#M_L3D)))
										l3d_z		=	C2D::Line3DSquare(ID_L3D, 240.0 * #C2D_Z, 1.0)
										C2D::Line3DColor(ID_L3D, xRGB())
										C2D::Line3DAngle(ID_L3D, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
										C2D::GuiMenuSetState(#M_L3D, i)
										;C2D::GuiMenuItemToggle(#M_L3D, i, 1)	; toggle
									EndIf
							EndSelect
							
							C2D::GuiMenuItemToggle(#M_L3D, 0, 0)	; Off->off
							
						EndIf
						
					CompilerEndIf
					
				Case	#G_Poly3D	;:	IsPoly3D!1
					CompilerIf	IsC2D::#IsC2D_Poly3D
						
						C2D::GuiCopper()	:	C2D::GuiOffset(4 * Bool(IsPoly3D=0))	:	C2D::GuiColor(#Black, $BCBABA)
						
						If	C2D::GuiMenuPopup(#M_P3D, C2D::#Gui_FlagToggle|C2D::#Gui_FlagUser|(C2D::#Gui_FlagState * IsPoly3D))	>=	0
							
							i	=	C2D::GuiMenuGetItem(#M_P3D)

							Select	i
								Case	0	To	C2D::GuiMenuSize(#M_P3D)	
									If	C2D::GuiMenuItemGetData(#M_P3D, i)	<	#Null	; Off
										IsPoly3D	=	0
										C2D::GuiMenuSetState(#M_P3D, -1)	; Menustate off
									Else
										IsPoly3D	=	1
										ID_P3D	=	Val(C2D::GuiDrawTextRaw(C2D::GuiMenuGetText(#M_P3D)))
										C2D::Poly3DScale(ID_P3D, Random(8,1))
										If	Random(1)
											C2D::Poly3DColor(ID_P3D, xRGB(), xRGB(), Random(3))
										Else
											C2D::Poly3DColor(ID_P3D, xRGB())
										EndIf
										C2D::Poly3DAngle(ID_P3D, C2D::MA_RMP(798), C2D::MA_RMP(798), C2D::MA_RMP(798))
										C2D::GuiMenuSetState(#M_P3D, C2D::GuiMenuGetItem(#M_P3D))
									EndIf
							EndSelect
							
						EndIf
	
					CompilerEndIf

				Case	#G_Music	; <- *** Music *** ->
					CompilerSelect	IsC2D::#IsC2D_Music
						CompilerCase	IsC2D::#XMU_SCA
							If	IsMusic
								IsMusic	=	0
								C2D::MusicFree()
							Else
								t$	=	OpenFileRequester("Music", Music$, "Music|*.*", 0)
								If	t$
									Music$	=	t$
									C2D::MusicInit("..\SCAL\")	; set default-path to scal.dll (x86-64)
									IsMusic	=	C2D::MusicPlay(@Music$)
									CompilerIf	IsC2D::#IsC2D_Guru
										If	IsMusic	=	0
											IsGuru	=	1
											C2D::GuiSetState(#G_Guru,	#True)
											t$	=	"**** Fatal Error ****||"	+
											  	 	"Cannot load or play music" + #LF$	+	#LF$	+
											  	 	Music$	+ #LF$	+	#LF$	+
											  	 	"Please check path of " + #DQUOTE$ + "SCAL_x86-64.dll" + #DQUOTE$ + " or try an other musicformat!"	+	#LF$	+
											  	 	"press the [guru] button to wake up from red alert meditation!"
											C2D::GuruInit(@t$)
										EndIf
									CompilerEndIf
								EndIf
							EndIf
							C2D::GuiSetState(#G_Music, Bool(IsMusic))
							
					CompilerEndSelect

				Case	#G_Color
					_SetBackColor()
					
				Case	#G_Info	:	IsInfo!1
					
				Case	#G_L	; Left/Right/Up/Down
					If	i <>	#G_L	:	C2D::GuiSetState(i, 0)	:	EndIf	:	i	=	#G_L
					x	=	#C2D_W 	*	0.30
					xb	=	-#MOVE_XB	*	C2D::GuiGetState(i)
				Case	#G_R
					If	i <>	#G_R	:	C2D::GuiSetState(i, 0)	:	EndIf	:	i	=	#G_R
					x	=	-#C2D_W	*	0.30
					xb	=	#MOVE_XB	*	C2D::GuiGetState(i)
				Case	#G_U
					If	i <>	#G_U	:	C2D::GuiSetState(i, 0)	:	EndIf	:	i	=	#G_U
					y	=	#C2D_H 	*	0.38	-	#BAR_SIZE
					yb	=	-#MOVE_YB	*	C2D::GuiGetState(i)
				Case	#G_D
					If	i <>	#G_D	:	C2D::GuiSetState(i, 0)	:	EndIf	:	i	=	#G_D
					y	=	-#C2D_H 	*	0.38	+	#BAR_SIZE
					yb	=	#MOVE_YB	*	C2D::GuiGetState(i)

				Default	; Windows-Gadget
					Select	Gadget
						Case	#G_Speed	:	C2D::C2D\Speed	=	GetGadgetState(#G_Speed)
					EndSelect

			EndSelect
			
		Case	#WM_LBUTTONUP,#WM_RBUTTONUP
			CompilerIf	IsC2D::#IsC2D_Splatter
				If	my	>	#BAR_SIZE	And	my	<	#C2D_H	-	#BAR_SIZE
					SplatterID	+	1	:	If	SplatterID	>	7	:	SplatterID	=	0	:	EndIf
					C2D::SplatterStart(SplatterID, mx, my)
					C2D::SplatterGravity(SplatterID, Random(50))
					SplatterCount	=	#True
				EndIf
			CompilerEndIf
			
		Case #PB_Event_CloseWindow
			Break

		Case	#WM_KEYDOWN
			Select	EventwParam()
				Case	#VK_ESCAPE	:	Break
				Case	#VK_RETURN	:	_Swap()
				Case	#VK_F1		:	C2D::ScreenShot()
			EndSelect

	EndSelect

ForEver

C2D::Free()

Delay(15)
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAAAEAAAAAAAAw
; Optimizer
; EnableXP
; UseIcon = ..\..\Data\Icon\ProjectSmall.ico
; Executable = C2D_Canvas2D_x86.exe
; CompileSourceDirectory
; Compiler = PureBasic 6.30 (Windows - x64)