; **********************************************************
; C2D Defaults Include / 24.05.2024
; #IsC2D_(Effects) - Include by defaults: 1.. = On / 0 = Off
; **********************************************************

CompilerIf	Defined(IsC2D_C2D,	#PB_Constant)	=	0
	#IsC2D_C2D	=	1	; Initialize C2D Loop (not needed by GUI only)
CompilerEndIf

;===========================================================
; Default drawingmode
;===========================================================
CompilerIf	Defined(IsC2D_Mode,	#PB_Constant)	=	0
	#IsC2D_Mode	=	#PB_2DDrawing_AlphaBlend
CompilerEndIf

;===========================================================
; Default on=1
;===========================================================
CompilerIf	Defined(IsC2D_Clear,		#PB_Constant)	=	0
	#IsC2D_Clear	=	1
CompilerEndIf
CompilerIf	Defined(IsC2D_Delay,		#PB_Constant)	=	0
	#IsC2D_Delay	=	1
CompilerEndIf

;===========================================================
; Default off=0
;===========================================================
CompilerIf	Defined(IsC2D_Anim,			#PB_Constant)	=	0
	#IsC2D_Anim				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Ball3D,		#PB_Constant)	=	0
	#IsC2D_Ball3D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Bitmap,		#PB_Constant)	=	0
	#IsC2D_Bitmap			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_BitmapColor,	#PB_Constant)	=	0
	#IsC2D_BitmapColor	=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Bounce,		#PB_Constant)	=	0
	#IsC2D_Bounce			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Brush,			#PB_Constant)	=	0
	#IsC2D_Brush			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Buffer,		#PB_Constant)	=	0
	#IsC2D_Buffer			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Checker,		#PB_Constant)	=	0
	#IsC2D_Checker			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Copper,		#PB_Constant)	=	0
	#IsC2D_Copper			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_File,			#PB_Constant)	=	0
	#IsC2D_File				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_FlatBar,		#PB_Constant)	=	0
	#IsC2D_FlatBar			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_FontColor,	#PB_Constant)	=	0
	#IsC2D_FontColor		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_FontRaw,		#PB_Constant)	=	0
	#IsC2D_FontRaw			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Fps,			#PB_Constant)	=	0
	#IsC2D_Fps				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_GdiPlus,		#PB_Constant)	=	0
	#IsC2D_GdiPlus			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Gui,			#PB_Constant)	=	0
	#IsC2D_Gui				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Guru,			#PB_Constant)	=	0
	#IsC2D_Guru				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Help,			#PB_Constant)	=	0
	#IsC2D_Help				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Line3D,		#PB_Constant)	=	0
	#IsC2D_Line3D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_MoveText,		#PB_Constant)	=	0
	#IsC2D_MoveText	=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Music,			#PB_Constant)	=	0
	#IsC2D_Music			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Network,		#PB_Constant)	=	0
	#IsC2D_Network			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_PageText,		#PB_Constant)	=	0
	#IsC2D_PageText		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Pixel3D,		#PB_Constant)	=	0
	#IsC2D_Pixel3D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Poly3D,		#PB_Constant)	=	0
	#IsC2D_Poly3D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_RotoZoom,		#PB_Constant)	=	0
	#IsC2D_RotoZoom		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_ScreenShot,	#PB_Constant)	=	0
	#IsC2D_ScreenShot		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_ScrollText,	#PB_Constant)	=	0
	#IsC2D_ScrollText		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Splatter,		#PB_Constant)	=	0
	#IsC2D_Splatter		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Stars2D,		#PB_Constant)	=	0
	#IsC2D_Stars2D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Stars3D,		#PB_Constant)	=	0
	#IsC2D_Stars3D			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_StarsR3D,		#PB_Constant)	=	0
	#IsC2D_StarsR3D		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_StarsZ3D,		#PB_Constant)	=	0
	#IsC2D_StarsZ3D		=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_SysFont,		#PB_Constant)	=	0
	#IsC2D_SysFont			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Text,			#PB_Constant)	=	0
	#IsC2D_Text				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Time,			#PB_Constant)	=	0
	#IsC2D_Time				=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_Twister,		#PB_Constant)	=	0
	#IsC2D_Twister			=	0
CompilerEndIf
CompilerIf	Defined(IsC2D_UCRT,			#PB_Constant)	=	0
	#IsC2D_UCRT				=	0	; Win10+ only (ucrt.lb must in "..\PureLibraries\Windows\Libraries\")
CompilerEndIf
CompilerIf	Defined(IsC2D_XUnPack,		#PB_Constant)	=	0
	#IsC2D_XUnPack			=	0
CompilerEndIf

;===========================================================
; Default use of font -> always define at last!
;===========================================================
CompilerIf	Defined(IsC2D_Font,	#PB_Constant)	=	0
	#IsC2D_Font	=	#IsC2D_Text			|
	           	 	#IsC2D_Guru			|
	           	 	#IsC2D_PageText	|
	           	 	#IsC2D_ScrollText	|
	           	 	#IsC2D_MoveText	|
	           	 	#IsC2D_FontRaw
CompilerEndIf
CompilerIf	Defined(IsC2D_Topaz,	#PB_Constant)	=	0
	#IsC2D_Topaz	=	#IsC2D_Guru	; default guru-font
CompilerEndIf
; IDE Options = PureBasic 6.10 LTS (Windows - x86)
; CursorPosition = 160
; FirstLine = 15
; Folding = AAAAAAA+
; EnableXP
; CompileSourceDirectory