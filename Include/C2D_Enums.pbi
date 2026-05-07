;*****************************************
;- C2D Enumeration / Structures 13.04.2026
;*****************************************

;***  C2D Version$ ***
#C2D_VER		=	1.00
#C2D_VER$	=	"1.00"

; #OS_Processor x86-64
CompilerIf	Defined(C2D_OS,#PB_Constant)	=	0
	CompilerSelect	#PB_Compiler_Processor
		CompilerCase	#PB_Processor_x64
			#C2D_XOS		=	1
			#C2D_XOS$	=	"x64"
		CompilerDefault
			#C2D_XOS		=	0
			#C2D_XOS$	=	"x86"
	CompilerEndSelect
CompilerEndIf

; #PB_VerisonString 5.xx - 6.xx - (5.40 = minimum compatible version)
#C2D_VH	=	#PB_Compiler_Version	/	100
#C2D_VZ	=	(#PB_Compiler_Version-	#C2D_VH	*	100) 	/	10
#C2D_VE	=	#PB_Compiler_Version	-	#C2D_VH	*	100	-	#C2D_VZ	*	10
#C2D_XPB$	=	Chr(#C2D_VH + '0')	+	"."	+	Chr(#C2D_VZ + '0')	+	Chr(#C2D_VE + '0')


; Native undefined? #Constants
CompilerIf	Defined(Orange,#PB_Constant)	=	0
	#Orange	=	$008CFF
CompilerEndIf
CompilerIf	Defined(Null,	#PB_Constant)	=	0
	#Null		=	0
CompilerEndIf
CompilerIf	Defined(Null$,	#PB_Constant)	=	0
	#Null$	=	Chr(0)
CompilerEndIf
CompilerIf	Defined(PI,		#PB_Constant)	=	0
	#PI		=	3.1415926535897931
CompilerEndIf
CompilerIf	Defined(TAB,	#PB_Constant)	=	0
	#TAB	=	9
CompilerEndIf
CompilerIf	Defined(TAB$,	#PB_Constant)	=	0
	#TAB	=	Chr(9)
CompilerEndIf
CompilerIf	Defined(LF,		#PB_Constant)	=	0
	#LF	=	10
CompilerEndIf
CompilerIf	Defined(LF$,	#PB_Constant)	=	0
	#LF$	=	Chr(10)
CompilerEndIf
CompilerIf	Defined(SND_NODEFAULT,	#PB_Constant)	=	0
	#SND_NODEFAULT	=	2
CompilerEndIf
CompilerIf	Defined(PB_MessageRequester_Error,	#PB_Constant)	=	0
	#PB_MessageRequester_Error		=	16
CompilerEndIf
CompilerIf	Defined(PB_MessageRequester_Info,	#PB_Constant)	=	0
	#PB_MessageRequester_Info		=	64
CompilerEndIf
CompilerIf	Defined(PB_MessageRequester_Warning,#PB_Constant)	=	0
	#PB_MessageRequester_Warning	=	48
CompilerEndIf
CompilerIf	Defined(PB_Image_TransparentBlack,	#PB_Constant)	=	0
	#PB_Image_TransparentBlack	=	0
CompilerEndIf

;************************************************
;- === GLOBAL IDENTIFER =========================
#MAX_ID		=	9999		; Maximal FX elements, enough? 10K = Error!
#MAX_ANGLE	=	360		; rotation ball3d, line3d
#MAX_BPP		=	3			; BytesPerPixel on canvas
#MAX_SIN		=	2047		; 4 * 360 + %1001011111 -> GCos/GSin for Buffer()

Structure	C2D_ID
	ID.i[#MAX_ID + 1]		; Used by all Objects/Elements
EndStructure


;************************************************
;- === CLIPPING =================================
Structure	RS_Clip
	x.i
	y.i
	w.i
	h.i
EndStructure


;************************************************
;- === UNION (ID, HEADER...) ====================
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


;************************************************
;- === DREG (D0, D1.. D9) =======================
Structure	RS_DReg	;	D0..D9 s. DReg.f[10]
	D.c	; 'D' data
	R.c	; '#' register
EndStructure


;************************************************
;- === CANVAS 2D MAIN MODULE ====================
Structure	RS_Canvas2D
	Gadget.i		; #GadgetNumber
	*hDC			; DeviceContext (Polygon)
	w.i			; Width
	h.i			; Height
	cx.i			; CenterX w/2
	cy.i			; CenterY h/2
	Color.l		; Back-Color
	Speed.i		; Update in miliseconds
	Time.q		; Timer -> MACRO MA_TIME()
	Quality.i	; #PB_Image_Raw(1) Or #PB_Image_Smooth(0)
	hBuffer.i	; DrawingBuffer()
	hBufferY.i	; DrawingBuffer() + h * Pitch & ReversedY
	hPitch.i		; DrawingBufferPitch()
	hMemory.i	; Buffered Canvas used in Buffer()
	hMemoryY.i	; CanvasBuffer + Size -> ReversedY for canvasbuffer
	hBackGrab.i	; Buffered RGB-"Screenshot" used in Buffer() for fast background
	hSize.i		; Bytesize of hMemory
	hFrontGrab.i; Buffered RGB-Shot, Black is always transparent
	Count.i		; Counter (+1) for Buffer SinX/SinY
	FPS.i			; Actual #FramesPerSeconds -> use as Str(\FPS)
	FPS_Count.i	; Counter for FPS (0 - FPS)
	FPS_Time.i	; 1/1000ms
	MPF_Time.i	; Miliseconds per Frame
	GSin.f[#MAX_SIN + 1]	; Precalculated sinus
	GCos.f[#MAX_SIN + 1]	; Precalculated cosinus
	FilePath.s	; Default path added to WWW/Files
EndStructure


;************************************************
;- === C2D GLOBAL FLAGS =========================
EnumerationBinary	; #C2F_?
	#C2F_Bottom		;    1
	#C2F_Center		;    2
	#C2F_CenterX	;    4
	#C2F_CenterY	;    8
	#C2F_Down		;   16
	#C2F_Horizontal;   32
	#C2F_Left		;   64
	#C2F_Random		;  128
	#C2F_Right		;  512
	#C2F_Top			; 1024
	#C2F_Ucase		; 2048
	#C2F_Up			; 4096
	#C2F_Vertical	; 8182
EndEnumeration

; Flags for text/fx
#C2F_End	=	-1	; Returned when EndOfText

; Flags for ControlCodes {Code,Param.f}
Enumeration	; #C2C_?
	#C2C_Bitmap	; 0 -> BitmapImage	{0,#ID}
	#C2C_Font	; 1 -> Change font	{1,#ID}
	#C2C_Pause	; 2 -> Pause text		{2,ms}
	#C2C_Space	; 3 -> 100%=C2D_W		{3,%percent.f}
	#C2C_Speed	; 4 -> Scrollspeed	{4,speed.f}
	#C2C_Center	; 5 -> {5}Center{5}	{5,%offset.f}
	#C2C_Return	; 6 -> Returns Param	{6,value}
	#C2C_MoveY	; 7 -> 50%=y+C2D_H/2	{7,%percent.f}
	#C2C_Pixel3D; 8 -> Pixel3DBitmap {8,#ID)
EndEnumeration


;************************************************
;- === C2D BITMAP ===============================
Structure	RS_Bitmap
	Image.i		; #Image
	hImage.i		; ImageID(Image)
	x.f			; real X
	y.f			; real Y
	w.i			; width
	h.i			; height
	TimeDelay.i	; delay for BitmapScroll()
EndStructure
; Structure	RS_BitmapScroll
; 	i.i	; #Image
; 	x.i	; StepX
; 	y.i	; StepY
; 	w.i	; Width
; 	h.i	; Height
; 	t.i	; Time (delay)
; 	*mx	; MemoryX
; 	*my	; MemoryY
; EndStructure


;************************************************
;- === C2D ANIM =================================
#ANIM_FRAME_TIME	=	50	; ms

Structure	RS_Frame
	Image.i	; #Image
	*hImage	; ImageID(Frame\Image)
	Time.i
EndStructure
Structure	RS_Anim
	FrameID.i		; Actual frame
	FrameNumber.i	; Number (x*y)-1
	FrameStart.i	; Default #Null
	FrameFinish.i	; Default FrameNumber
	x.f
	y.f
	w.i
	h.i
	Time.i
	Pause.i
	PingPong.i
	Direction.i
	PlayCount.i
	List	Frame.RS_Frame()
EndStructure


;************************************************
;- === C2D BOUNCE ===============================
Structure	RS_Bounce
	a.f	; acceleration
	d.f	; accelerated direction
	h.f	; height of bounce
	y.f	; position
EndStructure


;************************************************
;- === C2D BRUSH ================================
Structure	RS_Brush
	*hBrush	; api hBrush
	*hRegion	; api hRGN
	x.f		; clipped brush x-pos in region
	y.f		; cliiped brush y-pos in region
	rc.RECT	; region
	ImageW.i
	ImageH.i
EndStructure

;************************************************
;- === C2D FONT =================================
#ID_RF	=	ID_WORD('R','F')	; RawFont HeaderID

#FontX	=	8	; #Chars horizontal
#FontY	=	8	; #Chars vertical

#NUM_CHR	=	#FontX	*	#FontY	; Number of chars (64)
#MIN_CHR	=	32	; " "	= Char-Start of fontmap alphabet
#MAX_CHR	=	95	; "_" = Char-End of fontmap alphabet

Structure	RS_FontChar
	ID.i	; -> 0 .. 63 (#CharN - 1)
	i.i	; -> ImageID(Char\i)
	x.f	; -> X = horizonal position
	y.f	; -> Y = vertical position
	z.i	; -> Z = alpha 0..255
EndStructure
Structure	RS_FontMap
	ChrID.i[#NUM_CHR]	; ElementID to ChrI-Image
	ChrW.i
	ChrH.i
	GapW.i	; X-Line gab
	GapH.i	; Y-Line gap (leading)
	TabW.i	; Number of Space(TabW) when #TAB
	List	Char.Integer()	; Charcter-Images
EndStructure


;************************************************
;- === C2D SYSFONT ==============================
Structure	RS_SysFont
	*hFont	; Handle of FontID
	*rFont	; Handle of FontResource
EndStructure


;************************************************
;- === C2D TEXT-FX {Code,Param.f} ===============
Structure	RS_TextCtrl
	Code.i	; -> Code (FC_(Code))
	Param.f	; -> Param for pause, speed..
	PosX.f	; -> x-pos of scroller
	State.i	; -> on/off
EndStructure


;************************************************
;- === C2D TEXT =================================
Structure	RS_Text
	w.i
	h.i
	ChrW.i
	ChrH.i
	List	Char.RS_FontChar()
EndStructure


;************************************************
;- === C2D SCROLL-TEXT ==========================
Structure	RS_ScrollText
	x.f				; Actual position
	y.f
	Speed.f			; Scrollspeed
	MaxW.i			; n x -1
	MinW.i			; -ChrW
	ChrW.i			; FontWidth (GapW)
	ChrH.i			; FontHeight (GapH)
	Ctrl_Speed.f	; Stored Speed for Ctrl
	Ctrl_Pause.i	; ms
	SinHeight.f		; also for sin on/off
	SinFreq.f		; x 0.001
	SinSpeed.f		; x 0.010
	List	Char.RS_FontChar()
	List	Ctrl.RS_TextCtrl()
EndStructure


;************************************************
;- === C2D MOVE-TEXT ============================
Structure	RS_MoveText
	y.f			; actual position
	ClipX.i
	ClipY.i
	ClipW.i
	ClipH.i
	v_Start.i	; pixel-start vertical
	v_End.i		; pixel-end vertical
	Color.l		; Back-Color
	Speed.f		; up to down scrollspeed
	MaxH.i
	MaxW.i
	MinH.i
	ChrW.i
	ChrH.i
	List	Char.RS_FontChar()
EndStructure


;************************************************
;- === C2D PAGE-TEXT ============================
#Page_Next$	=	"~"	; Chr(96) -> indicates new page
#Page_Next	=	'~'	; Asc(96) -> indicates new page

; PageTextFX IN Effects
Enumeration	PageTextFX
	#PFX_Default
	#PFX_Fade
	#PFX_FadeCenter
	#PFX_FadeChr
	#PFX_FadeLeft
	#PFX_FadeRight
	#PFX_FadeStep
	#PFX_FadeTop
	#PFX_Stop	; always! last of FX_In
EndEnumeration

; PageTextFX OUT Effects
Enumeration	PageTextFX
	#PFX_OutDefault
	#PFX_OutFade
	#PFX_OutFadeCenter
	#PFX_OutFadeChr
	#PFX_OutFadeLeft
	#PFX_OutFadeRight
	#PFX_OutFadeStep
	#PFX_OutFadeTop
	#PFX_OutStop	; always! last of FX_Out
EndEnumeration

#PFX_Random	=	-1	; IN & OUT random

Structure	RS_PageText
	MaxW.i	; block-width (widest x of page char)
	MaxH.i
	Pause.i	; ms wait until next page
	List	Char.RS_FontChar()
EndStructure
Structure	RS_Page
	FX.i				; Current FX (in/out?)
	FX_Speed.f		; speed of in/out
	FX_Delay.f		; delay of in/out

	FX_In.i			; #In??
	FX_InSpeed.f	; speed of fx
	FX_InDelay.f	; delay if fx starts
	FX_InRnd.i		; not 0 if random fx

	FX_Out.i			; #Out??
	FX_OutSpeed.f
	FX_OutDelay.f
	FX_OutRnd.i

	ClipX.i
	ClipY.i
	ClipW.i
	ClipH.i

	Color.l

	MaxW.i	; x + width of all pages
	MaxH.i	; y + height of all pages

	ChrW.i	; width of fontchar
	ChrH.i	; height of fontchar

	Wait.i	; WaitTime until next page
	Time.i	; Time of actual displayed page
	Status.i	; all chars displayed (fx finished)
EndStructure


;************************************************
;- === C2D GURU =================================
#ID_GuruFont			=	#MAX_ID
#C2D_Guru_Color		=	$0022FF	; Default Amiga RED
#C2D_Guru_FrameTime	=	900		; ms

Structure	RS_Guru
	IsOn.i
	Frame.i	; Frame On/Off
	Time.i
	h.i		; Pixelheight
	hY.i		; ReversedY
	*hBrush	; BlackBack
	*hPen		; Framecolor
	*hClip	; Fullclip
	List	Char.RS_FontChar()	; hChar of font
EndStructure


;************************************************
;- === C2D GUI ==================================
#Gui_DefHeight		=	22				; Default height
#Gui_DefColor		=	$000000		; Default FrontColor
#Gui_DefBackColor	=	$D1B499		; Default Background
#Gui_DefGrayColor	=	$FFCACACA	; Disable grayed

EnumerationBinary	; Gadget- / Menu Flags
	#Gui_FlagCenter	; 1
	#Gui_FlagLeft		; 2
	#Gui_FlagRight		; 4
	#Gui_FlagToggle	; 8
	#Gui_FlagVertical	; 16
	#Gui_FlagPercent	; 32	->	  0 - 100 (%)
	#Gui_FlagLevel		; 64	-> -50 - +50
	#Gui_FlagNumber	; 128	->	  0 - #max
	#Gui_FlagShadow	; 256	->	Text- / Menushadow
	#Gui_FlagBorder	; 512 -> Menuborder
	#Gui_FlagState		; 1024 -> Place for menu-marker
	#Gui_FlagUser		; 2048 -> do whatever you want
	#Gui_FlagEmpty		; 4096 -> no string (stringgadget)
EndEnumeration
Enumeration			; FrameModes
	#Gui_FrameNone		; 0
	#Gui_Frame3D		; 1
	#Gui_FrameBar		; 2
	#Gui_FrameFine		; 3
	#Gui_FrameFlat		; 4
	#Gui_FrameLite		; 5
	#Gui_FrameRised	; 6
	#Gui_FrameSunken	; 7
EndEnumeration
Enumeration			; Draw CanvasButton-State
	#Gui_DrawDefault	; 0
	#Gui_DrawHover		; 1
	#Gui_DrawPush		; 2
	#Gui_DrawToggle	; 3
	#Gui_DrawDisable	; 4
EndEnumeration

#C2D_Type_DrawText	=	-1	; pseudotype
#C2D_Type_DrawButton	=	-2	; pseudotype
#C2D_Type_MenuButton	=	-3	; pseudotype

; DrawTextCommands
#DTC_BOLD$				=	"BD"	:	#DTC_BOLD			=	ID_WORD('B','D')	; {BD,#} - BolD,#=1 on/0 off
#DTC_BOX$				=	"BX"	:	#DTC_BOX				=	ID_WORD('B','X')	; {BX,#(,#)} - BoX,#alpha (,#mode)
#DTC_CHAR$				=	"CH"	:	#DTC_CHAR			=	ID_WORD('C','H')	; {CH,#}	- CHaracter,#Ascii
#DTC_CIRCLE$			=	"CI"	:	#DTC_CIRCLE			=	ID_WORD('C','I')	; {CI,#(,#)} - CIrcle,#alpha (,#mode)
#DTC_COLORBACK$		=	"CB"	:	#DTC_COLORBACK		=	ID_WORD('C','B')	; {CB,#} - Color Back,#rgb
#DTC_COLORFRONT$		=	"CF"	:	#DTC_COLORFRONT	=	ID_WORD('C','F')	; {CF,#} - Color Front,#rgb
#DTC_D0$					=	"D0"	:	#DTC_D0				=	ID_WORD('D','0')	; {D0,#} - Data-Register 0
#DTC_D1$					=	"D1"	:	#DTC_D1				=	ID_WORD('D','1')	; {D1,#} - Data-Register 1
#DTC_D2$					=	"D2"	:	#DTC_D2				=	ID_WORD('D','2')	; {D2,#} - Data-Register 2
#DTC_D3$					=	"D3"	:	#DTC_D3				=	ID_WORD('D','3')	; {D3,#} - Data-Register 3
#DTC_D4$					=	"D4"	:	#DTC_D4				=	ID_WORD('D','4')	; {D4,#} - Data-Register 4
#DTC_D5$					=	"D5"	:	#DTC_D5				=	ID_WORD('D','5')	; {D5,#} - Data-Register 5
#DTC_D6$					=	"D6"	:	#DTC_D6				=	ID_WORD('D','6')	; {D6,#} - Data-Register 6
#DTC_D7$					=	"D7"	:	#DTC_D7				=	ID_WORD('D','7')	; {D7,#} - Data-Register 7
#DTC_D8$					=	"D8"	:	#DTC_D8				=	ID_WORD('D','8')	; {D8,#} - Data-Register 8
#DTC_D9$					=	"D9"	:	#DTC_D9				=	ID_WORD('D','9')	; {D9,#} - Data-Register 9
#DTC_DEFAULT$			=	"DF"	:	#DTC_DEFAULT		=	ID_WORD('D','F')	; {DF} - Default
#DTC_DRAWMODE$			=	"DM"	:	#DTC_DRAWMODE		=	ID_WORD('D','M')	; {DM,#(,#)} - DrawingMode,#mode)
#DTC_EMBOS$				=	"EB"	:	#DTC_EMBOS			=	ID_WORD('E','B')	; {EB,#} - EmBos, #=alpha
#DTC_EXIT$				=	"EX"	:	#DTC_EXIT			=	ID_WORD('E','X')	; {EX,#}	- Exit text (breakout)
#DTC_FILL$				=	"FI"	:	#DTC_FILL			=	ID_WORD('F','I')	; {FI,#(,#)} - FIll,#alpha (,#mode)
#DTC_FONT$				=	"FN"	:	#DTC_FONT			=	ID_WORD('F','N')	; {FN,#} - FontNumber,#ID
#DTC_FRAME$				=	"FR"	:	#DTC_FRAME			=	ID_WORD('F','R')	; {FR,#(,#(,#))} - FRame, #=mode (#=lroffset,#udoffset)
#DTC_GADGETCOLOR$		=	"GC"	:	#DTC_GADGETCOLOR	=	ID_WORD('G','C')	; {GC,#}	- GadgetColor,#rgb
#DTC_GADGETPALETTE$	=	"GP"	:	#DTC_GADGETPALETTE=	ID_WORD('G','P')	; {GP,#}	- Gadgetcolor,Palette #ID
#DTC_GUIIMAGE$			=	"GI"	:	#DTC_GUIIMAGE		=	ID_WORD('G','I')	; {GI,#(,#)} - GuiImage,#index(,#yoffset)
#DTC_IMAGE$				=	"IM"	:	#DTC_IMAGE			=	ID_WORD('I','M')	; {IM,#(,#) - IMage,#number (,#yoffset)
#DTC_INVERSE$			=	"IV"	:	#DTC_INVERSE		=	ID_WORD('I','V')	; {IV,#} - InVerse)
#DTC_LINE$				=	"LI"	:	#DTC_LINE			=	ID_WORD('L','I')	; {LI,#(,#)} - LIne,#alpha (,#mode)
#DTC_MENU$				=	"MN"	:	#DTC_MENU			=	ID_WORD('M','N')	; {MN,#(,$)} - MeNu,#mode (,$character)
#DTC_NIL$				=	"NI"	:	#DTC_NIL				=	ID_WORD('N','I')	; {NI} - Nil do nothing! (s. disable proc-call)
#DTC_PALETTEBACK$		=	"PB"	:	#DTC_PALETTEBACK	=	ID_WORD('P','B')	; {PB,#} - Palette Backcolor, #ID
#DTC_PALETTECOLOR$	=	"PC"	:	#DTC_PALETTECOLOR	=	ID_WORD('P','C')	; {PC,#(,#)} - Palette Color FrontID(,BackID)
#DTC_PALETTEFRONT$	=	"PF"	:	#DTC_PALETTEFRONT	=	ID_WORD('P','F')	; {PF,#} - Palette Frontcolor, #ID
#DTC_RANDOM$			=	"RD"	:	#DTC_RANDOM			=	ID_WORD('R','D')	; {RD,#(,#)} - RanDom, #max (,#min)
#DTC_SHADOW$			=	"SH"	:	#DTC_SHADOW			=	ID_WORD('S','H')	; {SH,#(,#,#)} - SHadow,#alpha (,#xoffset,#yoffset)
#DTC_SPLITLINE$		=	"SL"	:	#DTC_SPLITLINE		=	ID_WORD('S','L')	; {SL,#(,#,#)} - SplittLine, #alpha (,#mode,#yoffset)
#DTC_STROKE$			=	"ST"	:	#DTC_STROKE			=	ID_WORD('S','T')	; {ST,#(,#)} - ST,#alpha (,bold #=1)
#DTC_TEXTHEIGHT$		=	"TH"	:	#DTC_TEXTHEIGHT	=	ID_WORD('T','H')	; {TH,#} - TextHeight (finalize)
#DTC_TEXTSIZE$			=	"TS"	:	#DTC_TEXTSIZE		=	ID_WORD('T','S')	; {TS,#(,#)} - Minimal TextSize #width (,#height)
#DTC_TEXTWIDTH$		=	"TW"	:	#DTC_TEXTWIDTH		=	ID_WORD('T','W')	; {TW,#} - TextWidth (finalize)
#DTC_UNDERLINE$		=	"UL"	:	#DTC_UNDERLINE		=	ID_WORD('U','L')	; {UL,#} - UnderLine, #=size
#DTC_XGAP$				=	"XG"	:	#DTC_XGAP			=	ID_WORD('X','G')	; {XG,#} - horizontal,#XGap
#DTC_XOFFSET$			=	"XO"	:	#DTC_XOFFSET		=	ID_WORD('X','O')	; {XO,#}	- X ± Offset
#DTC_XPOSITION$		=	"XP"	:	#DTC_XPOSITION		=	ID_WORD('X','P')	; {XP,#} - horizontal PixelPosition
#DTC_YGAP$				=	"YG"	:	#DTC_YGAP			=	ID_WORD('Y','G')	; {YG,#} - vertical,#YGap
#DTC_YOFFSET$			=	"YO"	:	#DTC_YOFFSET		=	ID_WORD('Y','O')	; {YO,#}	- Y ± Offset
#DTC_YPOSITION$		=	"YP"	:	#DTC_YPOSITION		=	ID_WORD('Y','P')	; {YP,#} - vertical PixelPosition

Structure	RS_GuiDTC	; DrawTextCommand "$$"
	a.c
	b.c
EndStructure
Structure	RS_GuiImage
	ID.i
	*hID
	w.i
	h.i
	Key$	; Map
EndStructure
Structure	RS_GuiFont
	ID.i		; ID
	*hFont	; hFontID
	*rFont	; hRessource
EndStructure
Structure	RS_GuiGadget
	ID.i				; #Gadget
	Type.i			; Gadget-Type
	x.i				; x-Pos
	y.i				; y-Pos
	w.i				; Width
	h.i				; Height
	Flags.i			; Toggle/Right/Frame...
	tx.i				; Text X-Position
	ty.i				; Text Y-Position
	ix.i				; Image X-Position
	iy.i				; Image Y-Position
	Image.i			; #Image
	FrameMode.i		; FrameMode
	FrameSize.i		; Pixelwidth/height
	State.i			; State Toggle/Progress
	SubGadget0.i	; #PB_Any -> StingGadget
	SubGadget1.i	; #PB_Any -> SpinGadget +
	SubGadget2.i	; #PB_Any -> SpinGadget -
	SubFrame.i		; FrameMode for Track/Progress
	Min.d				; min. Track
	Max.d				; max. Progress, Track
	IsToggled.i		; Toggled?
	IsDisabled.i	; Disabled?
	Color.l			; FrontColor
	BackColor.l		; BackColor
	ToggleColor.l	; ToggledColor
	ShadowColor.l	; Textshadow
	*hFont			; FontID()
	CopperPtr.i		; Ptr to copper(struct)
	CopperMode.i	; 0,1,2
	Text$				; GadgetText
	Toggle$			; Toggle/SubText
	Value.q			; User-Value or privat use
	Clip.RS_Clip	; Progress, Copper
	Range.RS_Clip
	Bar.RS_Clip
	OffsetText.POINT
	OffsetImage.POINT
	OffsetShadow.POINT
EndStructure
Structure	RS_GUI	; Global Defaults
	Color.l				; Text,Progress
	BackColor.l			; Background
	ToggleColor.l		; Toggled color
	ShadowColor.l		; Textshadow $00000000 - $FFFFFFFF
	*hFont				; FontID()
	*hCursor				; Windows hCursor (manually)
	CopperPtr.i			; Ptr to copper(Struct)
	CopperMode.i		; 0,1,2
	FrameMode.i			; #C2D_Gui_Frame[Mode]
	FrameSize.i			; Pixel-width/height
	FrameAlpha.l		; Alpha $FF000000
	*PalettePtr			; Ptr to colortable
	PaletteID.l			; ColorID (0..n)
	TabWidth.i			; Default = 3
	DReg.i[10]			; D0-D9 Register (DrawText)
	OffsetGadget.POINT; xOrg/yOrg
	OffsetText.POINT	; Offset X/Y-Text
	OffsetImage.POINT	; Offset X/Y-Image
	OffsetShadow.POINT; Offset X/Y-Shadow
	List	Gadget.RS_GuiGadget()
	List	Font.RS_GuiFont()
EndStructure

#MENU_LINE$		=	"{TH,2}{SL,$7F,1,1};"
#MENU_PAD$		=	"{XP,0}{XO,11}"

Structure	RS_GuiMenuItem	; Menu
	Gadget.i		; ID
	IsState.i	; 0/1
	IsDisable.i	; 0/1
	IsToggle.i	; 0/1
	t$				; Itemtext
	h.i			; Height of gadget
	Value.q		; ItemData
EndStructure
Structure	RS_GuiMenu
	ID.i		; MenuID
	nWin.i	; Window
	Height.i	; WinH
	Width.i	; WinW
	State.i	; ItemState
	Item.i	; Last choosed item
	Text$		; Last choosed text of item
	List	Items.RS_GuiMenuItem()	; Gadgets
EndStructure

Enumeration	; Commands GuiProc_WindowGadget()
	#C2D_WG_DISABLE
	#C2D_WG_FREE
	#C2D_WG_CURSOR
EndEnumeration
Structure	RS_WindowGadget
	x1.i
	y1.i
	x2.i
	y2.i
	State.i
EndStructure


;************************************************
;- === C2D COPPER ===============================
Structure	RS_Copper
	ID.i
	Image.i
	hImage.i
	w.i
	h.i
	x.f
	y.f
	Flags.i
EndStructure
Structure	RS_CpBlt
	*cbProc		; default @Blt_Copper_Color()	-> ptr to procedure (PB bug in x64)
	cbColor.l	; default $FFFFFFFF	-> copperblit on color onlay
EndStructure


;************************************************
;- === C2D FLATBAR ==============================
Structure	RS_FlatBar
	Color.l
	Frame.i
	h.i
	Image.i
	hImage.i
EndStructure


;************************************************
;- === C2D STARS 2D =============================
Structure	RS_Star2D
	x.f
	y.f
	z.i
	SpeedX.f
	SpeedY.f
EndStructure
Structure	RS_StarField2D	Extends	RECT
	Image.i
	*ImageHD			; Faster -> ImageID(Image)
	Size.i
	Direction.i
	Speed.f
	Color.l
	Clip.RS_Clip	; Clipping Starfield
	List	Star.RS_Star2D()
EndStructure


;************************************************
;- === C2D STARS 3D =============================
#STAR3D_Z_TIME	=	20; ms
#STAR3D_Z_ADD	=	3	; add alpha to star

Structure	RS_Star3D
	Time.i
	x.f
	y.f
	z.i
	SpeedX.f
	SpeedY.f
EndStructure
Structure	RS_StarField3D	Extends	RECT
	Image.i
	*ImageHD	; faster -> ImageID(Image)
	x_Center.f
	y_Center.f
	Speed.f
	Size.i
	Spread.i
	Distance.i
	Color.l
	Clip.RS_Clip
	List	Star.RS_Star3D()
EndStructure


;************************************************
;- === C2D STARS R3D ============================
#STAR_R3D_FS	=	10.5
#STAR_R3D_ZS	=	255.0	/	#STAR_R3D_FS

Structure	RS_StarR3D
	x.f
	y.f
	z.f
EndStructure
Structure	RS_StarR3DField
	n.i	; number
	x.i	; clipping
	y.i
	w.i
	h.i
	Size.i
	i.i	; image
	*hImage
	cx.f	; centerX
	cy.f	; centerY
	zx.i	; spreadX
	zy.i	; spreadY
	px1.i	; positions min/max
	py1.i
	px2.i
	py2.i
	List	RS_StarR3D.RS_StarR3D()
EndStructure


;************************************************
;- === C2D STARS Z3D ============================
#STAR_Z3D_FS	=	15.0
#STAR_Z3D_ZS	=	255.0	/	#STAR_Z3D_FS

Structure	RS_StarZ3D
	x.f
	y.f
	z.f
EndStructure
Structure	RS_StarZ3DField
	n.i	; number
	x.i	; clipping
	y.i
	w.i
	h.i
	s.i	; size (width & height)
	IsFade.i	; Z-Fade stars
	i.i[16]	; image
	*hImage[16]
	po.f[16]	; position-offset x/y
	cx.f	; centerX
	cy.f	; centerY
	sx.i	; spreadX
	sy.i	; spreadY
	px1.i	; positions min/max
	py1.i
	px2.i
	py2.i
	List	RS_StarZ3D.RS_StarZ3D()
EndStructure


;************************************************
;- === C2D BALL 3D ==============================
#FastDivisor	=	127.0	; Ball3D / Line3D
#FastAngle		=	1.0	/	#FastDivisor

#ID_B3DR			=	ID_LONG('B','3','D','R')
#ID_B3D0			=	ID_LONG('B','3','D', 0 )

#ExplodeLoop	=	798.0	; Full rotation of all random moved balls

#MAX_BALL		=	7	; 0 .. 7 [8]
#SIZE_BALL		=	63	; Default size (w & h)

Structure	RS_Ball3D		; Ball3D[..]-File-Structure (extends)
	ID.b	; BobID 0 - 7
	x.b	; x-pos
	y.b	; y-pos
	z.b	; z-pos
	s.b	; %Size
	sx.b	; spin rotate bob x-axis
	sy.b	; spin rotate bob y-axis
	sz.b	; spin rotate bob z-axis
EndStructure
Structure	RS_Ball3DBob	; Default images (0-7)
	Image.i[#MAX_BALL+1]
EndStructure
Structure	RS_Ball3DPosition
	ID.i		; Ball-Index
	hImage.i	; ImageID(Image-Number/handle)
	Image.i	; Image-Number of Bob-ball
	Color.l	; ID to restore angles
	x.f		; Object Position xy/z(alpha)
	y.f
	z.f
	s.f		; Size
	px.f		; Position xyz
	py.f
	pz.f
	ax.f		; Angle xyz
	ay.f
	az.f
	sx.f		; Spin xyz
	sy.f
	sz.f
	ExplodeSx.f	; Temp Spin xyz
	ExplodeSy.f
	ExplodeSz.f
	IsAnim.i	; Anim On?
	AnimID.i	; Number of Anim
EndStructure
Structure	RS_Ball3DObject
	Image.i[#MAX_BALL+1]
	Size.i
	IsExplode.f		; -> #ExplodeLoop
	ExplodeStep.f	; -> Sqr(#ExplodeLoop) * Factor
	List	Ball.RS_Ball3DPosition()
EndStructure


;************************************************
;- === C2D LINE 3D ==============================
#ID_L3D0	=	ID_LONG('L','3','D', 0)

Structure	RS_Line3D	; Line3D[..]-File-Structure (extends)
	x0.b	; x-pos
	y0.b	; y-pos
	z0.b	; z-pos
	x1.b	; x-pos
	y1.b	; y-pos
	z1.b	; z-pos
EndStructure
Structure	RS_Line3DPosition
	x.f[2]	; Object-Position xy/z(size)
	y.f[2]
	z.f[2]
	px.f[2]	; Line-Position xyz -> 0=Start / 1=End
	py.f[2]
	pz.f[2]
EndStructure
Structure	RS_Line3DObject
	Color.l
	Fog.f				; Fog * 0.1
	FadeSpeed.i		; -n / +n
	FadeAlpha.i		; 0..$FF
	BuildMode.i		; -1 / +1 = Build on, create object line by line
	BuildTime.i		; Buildtime in ms
	BuildSpeed.i	; Build next line in ms
	BuildCount.i	; Number of builded lines
	sw.i				; SizeWidth
	sh.i				; SizeHeight
	sz.i				; SizeDepth (z)
	ax.f				; Object-Angle xyz
	ay.f
	az.f
	List	VP.RS_Line3DPosition()
EndStructure


;************************************************
;- === C2D PIXEL 3D =============================
Structure	RS_Pixel
	x.f
	y.f
	z.f
	px.f
	py.f
	;pz.f
	ax.f
	ay.f
	az.f
	c.l
EndStructure
Structure	RS_Pixel3D	Extends	RECT
	w.i
	h.i
	List	RS_Pixel.RS_Pixel()
EndStructure


;************************************************
;- === C2D POLYGON 3D ===========================
#ID_P3D0	=	ID_LONG('P','3','D', 0)

Structure	RS_Poly
	ax.f
	ay.f
	az.f
EndStructure
Structure	RS_Polygon
	*Brush	; api hBrush
	*Pen		; api hPen
	*Clip		; api hClip
	*Memory	; default vertices
	*Finish	; end of *memory (+length)
	*Buffer	; cached vertices (zoom, scale)
	*Points	; calculated vertices
	*Rotate.RS_Poly	; calculated angles ax, ay, az
	*RotateFinish		; end of *rotate (+length)
	Count.i	; number of calculated vertices (*points)
	xOrg.f	; brush x-pos when clipped
	yOrg.f	; brush y-pos when clipped
EndStructure


;************************************************
;- === C2D CHECKER ==============================
Structure	RS_Checker
	y.i
	h.i
	y_Start.i	; y - offset
	y_End.i		; y - offset + height
	ColorA.l		; first color
	ColorB.l		; second color
	w_Shift.i	; 1<<bitwidth of raster 8,16,32,64..256
	c_x.f			; Center Width
	c_y.f			; Center Height
	camX.f		; SpeedX
	camY.f		; SpeedY
EndStructure


;************************************************
;- === C2D NETWORK C2D/0.3 ======================
Structure	RS_NetWork
	*CallBack	; @Procedure(Param)
	*hInternet	; iNetConnection
	*hURL			; iNetURL
	BytesRead.i	; Buffered bytes
	BytesSkip.i	; Skip Header?
	Length.i		; Bytesize of url
EndStructure


;************************************************
;- === C2D ROTOZOOM =============================
Structure	RS_ROTOZOOM
	Time.q
	Wait.i
	x.i
	y.i
	w.i
	h.i
	ZoomSpeed.i
	ZoomPos.i
	ZoomMin.i
	ZoomMax.i
	RZ_SIN.f[361]
	RZ_COS.f[361]
	RZ_POINT.l[256 * 256 + 1]
EndStructure


;************************************************
;- === C2D TWISTER ==============================
Structure	RS_Twister
	w.i
	h.i
	CX.f
	CY.f
	Loop.i
	Mode.i
	;
	RGB0.l
	RGB1.l
	RGB2.l
	RGB3.l
	;
	Size.i
	Speed.f
	Angle.f
	Amplitude.f
	;
	p0.f
	p1.f
	p2.f
	p3.f
EndStructure


;************************************************
;- === C2D SPLATTER =============================
Structure	RS_SplatterID
	*hImage	; imageid
	a.f		; alpha
	x.f		; posX
	y.f		; posY
	x_speed.f
	y_speed.f
	a_speed.f
	gravity.f
EndStructure
Structure	RS_Splatter
	IsOn.i
	IsAnim.i
	AnimID.i
	Image.i
	Energy.i		; Alpha
	Fade.i		; Fadeout - AlphaGlimmtime
	AccelerationX.i
	AccelerationY.i
	SpreadX.i	; x ± spread
	SpreadY.i	; y ± spread
	Gravity.i
	Number.i
	Bounce.f		; 1.0 = 100%
	Alpha.i
	Loop.i
	x.f
	y.f
	w.i
	h.i
	r.RECT
	List	ID.RS_SplatterID()
EndStructure


; END
; IDE Options = PureBasic 6.30 (Windows - x86)
; CursorPosition = 123
; FirstLine = 33
; Folding = AAADAAAQAAAAA+
; EnableXP
; CompileSourceDirectory