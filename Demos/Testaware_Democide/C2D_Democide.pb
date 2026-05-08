; C2D::Testaware - Democide - 2019
; Purebasic v5.72 (x86-64) / 04.08.2019
; Update: Corona / 14.12.2021

; *** links to examine death tolls ***
; http://necrometrics.com/all20c.htm
; http://www.hawaii.edu/powerkills/20TH.HTM
; http://www.hawaii.edu/powerkills/DBG.CHAP1.HTM#14
; http://www.hawaii.edu/powerkills/POWER.TAB4.GIF
; https://en.wikipedia.org/wiki/List_of_wars_and_anthropogenic_disasters_by_death_toll
; https://www.fifa.com/worldcup/matches/match/300331552/#france-v-croatia-2018-fifa-world-cup-russia-final-81
; https://www.imf.org/external/about/histcoop.htm
; https://www.imf.org/external/pubs/nft/op/230/op230.pdf

; *** keys ***
; P		=	pause
; SPACE	=	info
; CSR		=	jump
; M		=	music
; ESC		=	end

EnableExplicit

CompilerIf	Defined(C2D_Z, #PB_Constant)	=	0	; Zoom-Factor
	#C2D_Z	=	2
CompilerEndIf

DeclareModule	IsC2D
	XIncludeFile	"..\..\Include\C2D_Types.pbi"
	#IsC2D_Music		=	#XMU_S3M
	#IsC2D_Mode			=	0
	#IsC2D_Anim			=	1
	#IsC2D_Ball3D		=	2
	#IsC2D_Buffer		=	2	; noise
	#IsC2D_File			=	1
	#IsC2D_Bitmap		=	1
	#IsC2D_GdiPlus		=	1
	#IsC2D_NetWork		=	1	; remark if no internet
	#IsC2D_Stars3D		=	1
	#IsC2D_Text			=	1
	#IsC2D_FontColor	=	1	; shadow
	#IsC2D_Clear		=	0
	;#IsC2D_Help	=	1
	XIncludeFile	"..\..\Include\C2D_Defaults.pbi"
EndDeclareModule

XIncludeFile	"..\..\Include\C2D_Module.pbi"

#C2D_G	=	0	; #Gadget
#C2D_W	=	320	*	#C2D_Z	; Width
#C2D_H	=	240	*	#C2D_Z	; Height

#FNT_W0	=	20	*	#C2D_Z	:	#FNT_H0	=	20	*	#C2D_Z
#FNT_W1	=	10	*	#C2D_Z	:	#FNT_H1	=	10	*	#C2D_Z
#FNT_W2	=	5	*	#C2D_Z	:	#FNT_H2	=	5	*	#C2D_Z
#FNT_W3	=	7	*	#C2D_Z	:	#FNT_H3	=	7	*	#C2D_Z

#BAK_H	=	#C2D_H	*	0.67	; <- the height of background
#BAK_Y	=	(#C2D_H	-	#BAK_H)	*	0.5

#TIT_Y	=	#BAK_Y	+	#FNT_H2	*	1.7
#NUM_Y	=	(#C2D_H	-	#FNT_H0)	*	0.5

; WW1 & WW2
#DEATH_WW1	=	23568559	; + half/max difference of official deaths
#DEATH_WW2	=	69069811	; + half/max difference of official deaths

; Death tolls
#DEATH_TOTAL	=	203224000.0	- (#DEATH_WW1 + #DEATH_WW2)	; Total 1914 - 2010 (no WW1, WW2)
#DEATH_SECOND	=	#DEATH_TOTAL /	(65 * 365 * 86400 - (4 * 31 + 7) * 86400)		; nBase 1945 - 2010 -> deaths per second
#DEATH_MINUTE	=	#DEATH_SECOND	*	60
#DEATH_HOUR		=	#DEATH_MINUTE	*	60
#DEATH_DAY		=	#DEATH_HOUR		*	24
#DEATH_WEEK		=	#DEATH_DAY		*	7
#DEATH_MONTH	=	#DEATH_WEEK		*	4
#DEATH_YEAR		=	#DEATH_MONTH	*	12

Enumeration
	#T_HOUR
	#T_DAY
	#T_WEEK
	#T_MONTH
	#T_YEAR
	#T_FIFA		; %4
	#T_CORONA	; 2019.12.31
	#T_ASSANGE	; 2019.04.11
	#T_POPE		; 2013.03.13
	#T_GADDAFI	; 2011.10.20 8:30
	#T_OBAMA		; 2009.10.12
	#T_911		; 2001.09.11 8:46
	#T_DOLLAR	; 1996
	#T_EU			; 1993.11.01
	#T_BERLIN	; 1989.11.10
	#T_LUTHER	; 1968.04.04 18:01
	#T_KENNEDY	; 1963.11.22 12:30
	#T_OECD		; 1961.09.30
	#T_NATO		; 1949.04.04
	#T_ZION		; 1948.05.14
	#T_IWF		; 1947.03.01
	#T_UNO		; 1945.10.24
	#T_1945		; Base
	#T_YOU
EndEnumeration

#FILE_TOTAL	=	0.01	/	6
#TIME_NEXT	=	12666

Macro	MA_RXY()
	(Random(2 * #C2D_Z) - Random(2 * #C2D_Z))
EndMacro

Global	SYSTEMTIME.SYSTEMTIME, NUMBERFMT.NUMBERFMT
Global	*MusicMemory, FileCount, ModeInfo, TimeNoise, TimeWatch, TimeNext, TimeDeath=-1

Define	Pause, Time, Music

CompilerIf	IsC2D::#IsC2D_NetWork	; Callback
	Procedure.i	_CallBack(Param)

		; NO! StartDrawing()/StopDrawing()
		; Param = download-status in percent

		Protected	x = 16 * #C2D_Z, y = 8 * #C2D_Z, i = 1.5 * #C2D_Z

		Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $FFFFFFFF)	:	x	+	i	:	y	-	i
		Box(x, #C2D_H / 2 - y, #C2D_W - 2 * x, 2 * y, $FF000000)	:	x	+	i	:	y	-	i

		Box(x, #C2D_H / 2 - y, ((#C2D_W - 2 * x) * #FILE_TOTAL) * (Param + FileCount * 100), 2 * y, $FFFFFFFF)

		If	WindowEvent()	=	#Null
			Delay(1)
		EndIf

	EndProcedure
CompilerEndIf

Procedure.s	_Format(Number.d, NbDecimals=0)

	Protected t$ = Space(32)

	With	NUMBERFMT
		\Grouping		=	3
		\LeadingZero	=	1
		\lpDecimalSep	=	@"."
		\lpThousandSep	=	@"."
		\NegativeOrder	=	1
		\NumDigits		=	NbDecimals
	EndWith

	GetNumberFormat_(#LOCALE_SYSTEM_DEFAULT, 0, StrD(Number), NUMBERFMT, @t$, Len(t$))

	ProcedureReturn t$

EndProcedure
Procedure.d	_Tolls(y, m=1, d=1, h=0, i=0, s=0)

	Protected	Count.d

	If	y	>=	1945	:	y	-	1945	:	EndIf

	m	-	1	:	If	m	<	#Null	:	m	=	0	:	EndIf
	d	-	1	:	If	d	<	#Null	:	d	=	0	:	EndIf

	Count	=	#DEATH_YEAR		*	y
	Count	+	#DEATH_MONTH	*	m
	Count	+	#DEATH_DAY		*	d
	Count	+	#DEATH_HOUR		*	h
	Count	+	#DEATH_MINUTE	*	i
	Count	+	#DEATH_SECOND	*	s

	ProcedureReturn	Count

EndProcedure

Procedure	C2D_Init()

	Protected	t$

	OpenWindow(0, 0, 0, #C2D_W, #C2D_H, MA_C2DOS("Testaware - Democide - 2019"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

	CanvasGadget(#C2D_G, 0, 0, #C2D_W, #C2D_H)
	DisableGadget(#C2D_G, 1)

	C2D::Init(#C2D_G, 15)
	C2D::Quality(#PB_Image_Smooth)

	C2D::Stars3DInit(40, 1, 0, #BAK_Y, #C2D_W, #BAK_H, 2.8)
	C2D::Stars3DDistance(-80)

	; default path for next files
	CompilerIf	IsC2D::#IsC2D_NetWork
		C2D::NetWorkCallBack(@_CallBack())
		C2D::NetWorkBytes(10240*4)
		C2D::FilePath("https://testaware.files.wordpress.com/2019/05/")
	CompilerElse
		C2D::FilePath("media/")
	CompilerEndIf

	C2D::BitmapInit(0, @"2animearth10x8.png")		:	FileCount	+	1	; earth
	C2D::AnimInit(0, C2D::BitmapImage(0), 10, 8)
	C2D::AnimZoom(0, 94 * #C2D_Z, 94 * #C2D_Z)
	C2D::AnimDelay(0, 50)
	
	C2D::BitmapInit(0, @"2animcoin10x8.png")		:	FileCount	+	1	; coin
	C2D::AnimInit(1, C2D::BitmapImage(0), 10, 8)
	C2D::AnimZoom(1, 42 * #C2D_Z, 42 * #C2D_Z)
	C2D::AnimDirection(1, -1)
	C2D::AnimDelay(1, 19)
	
	C2D::AnimCopy(1, 2)	; copy ID = 1 to new AnimID = 2 (use same frames for less memory)

	C2D::Ball3DInit(0, ?b3d_coins, 7.5 * #C2D_Z)	; ball3d
	C2D::Ball3DAnim(0, 1, 0)	; AnimID 1 -> BallID 0
	C2D::Ball3DAnim(0, 2, 1)	; AnimID 2 -> BallID 1

	C2D::BitmapInit(0, @"2goldfont.png")			:	FileCount	+	1	; font
	C2D::FontInit(0, C2D::BitmapImage(0))	:	C2D::FontShadow(0, 4, 4, 140)	:	C2D::FontZoom(0, #FNT_W0, #FNT_H0)
	C2D::FontInit(1, C2D::BitmapImage(0))	:	C2D::FontShadow(1, 4, 4, 112)	:	C2D::FontZoom(1, #FNT_W1, #FNT_H1)
	C2D::FontInit(2, C2D::BitmapImage(0))	:	C2D::FontShadow(2, 4, 4, 112)	:	C2D::FontZoom(2, #FNT_W2, #FNT_H2)
	C2D::FontInit(3, C2D::BitmapImage(0))	:	C2D::FontShadow(3, 4, 4, 112)	:	C2D::FontZoom(3, #FNT_W3, #FNT_H3)
	
	C2D::BitmapInit(1, @"2novusordo_color.png")	:	FileCount	+	1	; novus
	C2D::BitmapZoom(1, C2D::AnimW(0)-2, C2D::AnimH(0)-2)

	C2D::BitmapInit(0, @"2urall_blue.jpg")			:	FileCount	+	1	; urall
	C2D::BitmapZoom(0, #C2D_W, #BAK_H)

	; at last of files play screamtracker music?
	CompilerIf	IsC2D::#IsC2D_Music
		CompilerIf	IsC2D::#IsC2D_NetWork
			*MusicMemory	=	C2D::FileLoad("http://ftp.modland.com/pub/modules/Screamtracker%203/Maral/n'trance.s3m")
			C2D::NetWorkFree()
		CompilerElse
			*MusicMemory	=	C2D::FileLoad("n'trance.s3m")
		CompilerEndIf
		If	*MusicMemory
			C2D::MusicPlay(*MusicMemory, MemorySize(*MusicMemory))
		EndIf
	CompilerEndIf

	t$	=	"FREE AND INDOMITABLE PEOPLE WERE MURDERED IN WAR CRIMES|"	+
	  	 	"JUST SO THE GREEDY 1% CAN TAKE THEIR STOCK MARKET PROFITS"
	C2D::FontSelect(2)	:	C2D::FontGap(2, 0, 2 * #C2D_Z)	:	C2D::TextInit(0, @t$, C2D::#C2F_CenterX)

	;_________________________________________
	;/* start create fast static background */
	StartDrawing(CanvasOutput(#C2D_G))
	C2D::BufferClear()
	C2D::BitmapDraw(0, 0, 0, 255, C2D::#C2F_Center)
	C2D::BitmapDraw(1, 0, 0,  64, C2D::#C2F_Center)
	C2D::TextDraw(0, 0, #BAK_Y + #BAK_H - #FNT_H2 * 3.6, 255)
	C2D::BufferBackGrab()
	C2D::BufferClear()
	StopDrawing()
	;/* end of create fast static background */
	;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	; base-statistic [space-bar]
	t$	=	"THE OFFICIAL DEMOCIDE DEATHS TOLLS BASED ON CAPITALISTICALLY|"	+
	  	 	"WAR CRIMES BY SO CALLED " + #DQUOTE$ + "DEMOCRATIC" + #DQUOTE$ + " GOVERNMENTS|"	+
	  	 	"AGAINST ANY HUMAN RIGHT IN THE PERIOD FROM 1945 TO 2010"
	C2D::TextInit(0, @t$, C2D::#C2F_CenterX)

	t$	=	"SECOND......"			+	_Format(#DEATH_SECOND, 5)	+
	  	 	"|MINUTE............"+	_Format(Round(#DEATH_MINUTE,	#PB_Round_Up))	+
	  	 	"|HOUR............"	+	_Format(Round(#DEATH_HOUR,		#PB_Round_Up))	+
	  	 	"|DAY..........."		+	_Format(Round(#DEATH_DAY,		#PB_Round_Up))	+
	  	 	"|WEEK........."		+	_Format(Round(#DEATH_WEEK,		#PB_Round_Up))	+
	  	 	"|MONTH......."		+	_Format(Round(#DEATH_MONTH,	#PB_Round_Up))	+
	  	 	"|YEAR......"			+	_Format(Round(#DEATH_YEAR,		#PB_Round_Up))	+
	  	 	"|PERIOD.."				+	_Format(Round(#DEATH_TOTAL,	#PB_Round_Up))
	C2D::FontSelect(3)	:	C2D::FontGap(3, 0, 2 * #C2D_Z)	:	C2D::TextInit(1, @t$)

	; no more needed
	C2D::BitmapFree(0)
	C2D::BitmapFree(1)

	; timestep to next
	TimeWatch	=	C2D::MA_TIME()

EndProcedure
Procedure	C2D_Update()

	Static	t$, t_0$, n$, n_0$, TimeCount, Fade=255, Font, Font_0

	Protected	Time.d, TimeBase.d

	; *** noise?
	If	TimeNoise	>	C2D::C2D\Time
		C2D::BufferNoise(0, #BAK_Y, #C2D_W, #BAK_H, 3 * #C2D_Z)
		ProcedureReturn
	EndIf

	; *** update background
	C2D::BufferBackDraw()
	C2D::Stars3DDraw()

	; *** view base statistic?
	If	ModeInfo
		C2D::TextDraw(0, 0, #TIT_Y)
		C2D::TextDraw(1, 0, 0, 255, C2D::#C2F_Center)
		ProcedureReturn
	EndIf

	; *** set title
	If	TimeNext	<=	C2D::C2D\Time

		t_0$		=	t$
		Font_0	=	Font

		TimeDeath	+	1
		If	TimeDeath	>	#T_YOU
			TimeDeath	=	#Null
			t_0$			=	#Null$
			TimeNoise	=	C2D::C2D\Time	+	360
		ElseIf	TimeDeath	<	#Null
			TimeDeath	=	#T_YOU
		EndIf

		Select	TimeDeath
			Case	#T_HOUR		:	t$	=	"DURING THIS HOUR"
			Case	#T_DAY		:	t$	=	"DURING THIS DAY"
			Case	#T_WEEK		:	t$	=	"DURING THIS WEEK"
			Case	#T_MONTH		:	t$	=	"DURING THIS MONTH"
			Case	#T_YEAR		:	t$	=	"DURING THIS YEAR"
			Case	#T_FIFA		:	t$	=	"SINCE LAST FIFA WORLD CUP"
			Case	#T_CORONA	:	t$	=	"SINCE THE FEAR OF CORONA"
			Case	#T_ASSANGE	:	t$	=	"SINCE ASSANGE OF WIKILEAKS WAS ARRESTED"
			Case	#T_POPE		:	t$	=	"SINCE JESUIT POPE FRANCIS ELECTED"
			Case	#T_GADDAFI	:	t$	=	"SINCE LIBYAN GADDAFI WAS MURDERED"
			Case	#T_OBAMA		:	t$	=	"SINCE OBAMA RECEIVED THE NOBEL PEACE PRIZE"
			Case	#T_911		:	t$	=	"SINCE 9/11"
			Case	#T_DOLLAR	:	t$	=	"SINCE DOLLARIZATION OF ECONOMIC"
			Case	#T_EU			:	t$	=	"SINCE THE FOUNDING OF EU"
			Case	#T_BERLIN	:	t$	=	"SINCE THE FALL OF BERLIN WALL"
			Case	#T_LUTHER	:	t$	=	"SINCE MARTIN LUTHER KING WAS ASSASSINATED"
			Case	#T_KENNEDY	:	t$	=	"SINCE PRESIDENT KENNEDY WAS ASSASSINATED"
			Case	#T_OECD		:	t$	=	"SINCE THE FOUNDING OF OECD"
			Case	#T_NATO		:	t$	=	"SINCE THE FOUNDING OF NATO"
			Case	#T_ZION		:	t$	=	"SINCE ZIONISM RULED ISRAEL"	;"SINCE THE FOUNDING OF ISRAEL"
			Case	#T_IWF		:	t$	=	"SINCE THE IMF LOANS"
			Case	#T_UNO		:	t$	=	"SINCE THE FOUNDING OF UN"
			Case	#T_1945		:	t$	=	"AFTER THE END OF WORLD WAR II"
			Case	#T_YOU		:	t$	=	"WHILE YOU ARE WATCHING"
		EndSelect

		Fade	=	0

		If	Len(t$)	>	31
			Font	=	3
		Else
			Font	=	1
		EndIf

		TimeCount	=	#Null
		TimeNext		=	C2D::C2D\Time	+	#TIME_NEXT

	EndIf

	; *** update count
	If	TimeCount	<=	C2D::C2D\Time

		n_0$	=	n$

		GetLocalTime_(@SYSTEMTIME)

		With	SYSTEMTIME

			TimeBase	=	_Tolls(\wYear, \wMonth, \wDay, \wHour, \wMinute, \wSecond)

			Select	TimeDeath
				Case	#T_HOUR		:	Time	=	_Tolls(0, 0, 0, 0, \wMinute, \wSecond)
				Case	#T_DAY		:	Time	=	_Tolls(0, 0, 0, \wHour, \wMinute, \wSecond)
				Case	#T_WEEK		:	Time	=	_Tolls(0, 0, \wDayOfWeek, \wHour, \wMinute, \wSecond)
				Case	#T_MONTH		:	Time	=	_Tolls(0, 0, \wDay, \wHour, \wMinute, \wSecond)
				Case	#T_YEAR		:	Time	=	_Tolls(0, \wMonth, \wDay, \wHour, \wMinute, \wSecond)
				Case	#T_FIFA		:	Time	=	TimeBase	-	_Tolls(\wYear - (\wYear - 2) % 4, 7, 15, 19, 53)
				Case	#T_CORONA	:	Time	=	TimeBase	-	_Tolls(2020,  1, 27)
				Case	#T_ASSANGE	:	Time	=	TimeBase	-	_Tolls(2019,  4, 11)
				Case	#T_POPE		:	Time	=	TimeBase	-	_Tolls(2013,  3, 13)
				Case	#T_GADDAFI	:	Time	=	TimeBase	-	_Tolls(2011, 10, 20, 8, 30)
				Case	#T_OBAMA		:	Time	=	TimeBase	-	_Tolls(2009, 10, 12)
				Case	#T_911		:	Time	=	TimeBase	-	_Tolls(2001,  9, 11, 8, 46)
				Case	#T_DOLLAR	:	Time	=	TimeBase	-	_Tolls(1996)
				Case	#T_EU			:	Time	=	TimeBase	-	_Tolls(1993, 11,  1)
				Case	#T_BERLIN	:	Time	=	TimeBase	-	_Tolls(1989, 11, 10)
				Case	#T_LUTHER	:	Time	=	TimeBase	-	_Tolls(1968,  4,  4, 18,  1)
				Case	#T_KENNEDY	:	Time	=	TimeBase	-	_Tolls(1963, 11, 22, 12, 30)
				Case	#T_OECD		:	Time	=	TimeBase	-	_Tolls(1961,  9, 30)
				Case	#T_NATO		:	Time	=	TimeBase	-	_Tolls(1949,  4,  4)
				Case	#T_ZION		:	Time	=	TimeBase	-	_Tolls(1948,  5, 14)
				Case	#T_IWF		:	Time	=	TimeBase	-	_Tolls(1947,  3,  1)
				Case	#T_UNO		:	Time	=	TimeBase	-	_Tolls(1945, 10, 24)
				Case	#T_1945		:	Time	=	TimeBase
				Case	#T_YOU		:	Time	=	#DEATH_SECOND	*	((C2D::C2D\Time - TimeWatch) * 0.001)
			EndSelect
			
		EndWith

		n$	=	_Format(Time)

		TimeCount	=	C2D::C2D\Time	+	2250

	EndIf

	; *** draw earth & Deep $tate
	C2D::AnimDraw(0, 0, 0, 255, C2D::#C2F_Center)
	C2D::Ball3DRotate(0, 0, -1.1, 0)
	C2D::Ball3DDraw(0, 0, 0, 237, 18)

	If	Fade	<	255
		Fade	+	3	:	If	Fade	>	255	:	Fade	=	255	:	EndIf
	EndIf

	C2D::FontSelect(Font)	:	C2D::TextStringDraw((#C2D_W - Len(t$)  * C2D::FontW(Font)) * 0.50, #TIT_Y, t$, Fade)	; title
	C2D::FontSelect(0)		:	C2D::TextStringDraw((#C2D_W - Len(n$)  * #FNT_W0) * 0.50, #NUM_Y, n$, Fade)				; #count

	If	Fade	<	255	And	Len(t_0$)
		C2D::FontSelect(Font_0)	:	C2D::TextStringDraw((#C2D_W - Len(t_0$)  * C2D::FontW(Font_0)) * 0.50 + MA_RXY(), #TIT_Y + MA_RXY(), t_0$, 255-Fade)	; title
		C2D::FontSelect(0)		:	C2D::TextStringDraw((#C2D_W - Len(n_0$)  * #FNT_W0) * 0.50 + MA_RXY(), #NUM_Y + MA_RXY(), n_0$, 255-Fade)				; #count
	EndIf

EndProcedure

C2D_Init()

Repeat
	Select	WindowEvent()

		Case	#WM_KEYDOWN

			If	ModeInfo	=	0
				Select	EventwParam()
					Case	#VK_LEFT
						TimeNext		=	#Null
						TimeDeath	-	2
					Case	#VK_RIGHT
						TimeNext	=	#Null
					Case	#VK_UP
						TimeNext		=	#Null
						TimeDeath	=	-1
					Case	#VK_DOWN
						TimeNext		=	#Null
						TimeDeath	=	#T_YOU	-	1
					Case	#VK_P
						Pause	!	1
						If	Pause
							Time	=	TimeNext	-	C2D::MA_Time()
						Else
							TimeNext	=	C2D::MA_Time()	+	Time
						EndIf
				EndSelect
			EndIf

			Select	EventwParam()
				Case	#VK_SPACE
					ModeInfo	!	1
					If	ModeInfo
						Time	=	TimeNext	-	C2D::MA_Time()
					Else
						TimeNext	=	C2D::MA_Time()	+	Time
					EndIf
					TimeNoise	=	C2D::MA_Time()	+	250
				Case	#VK_M
					CompilerIf	IsC2D::#IsC2D_Music
						If	*MusicMemory
							Music	!	1
							If	Music
								C2D::MusicFree()
							Else
								C2D::MusicPlay(*MusicMemory, MemorySize(*MusicMemory))
							EndIf
						EndIf
					CompilerEndIf
				Case	#VK_ESCAPE
					Break
			EndSelect

		Case	#PB_Event_CloseWindow
			Break
			
		Default

			If	Pause
				Delay(15)
			ElseIf	C2D::Start()
				C2D_Update()
				C2D::Stop()
			EndIf

	EndSelect
ForEver

C2D::Free()

DataSection
	b3d_coins:	; ball3d coin-object
	Data.l	C2D::#ID_B3D0, 2
	Data.b	0,0,0,-15,0,0,0,0
	Data.b	0,0,0, 15,0,0,0,0
EndDataSection
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = AA9
; Executable = C2D_Democide_x86.exe
; CompileSourceDirectory