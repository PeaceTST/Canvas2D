; ****************************************************
; Name:			C2D - Main Canvas 2D Module v1.00
; ----------------------------------------------------
; Description:	Custom module for Canvas 2D graphics
; Author:		Peace / Testaware
; Code:			Purebasic v5.40 upto v6.30+ (x86-64)
; Create:		29.10.2017 02:02
; Update: 		17.04.2026 23:14
; Home:			https://testaware.wordpress.com
; ****************************************************

;===================================================
;- *** IsC2D ON=1 / OFF=0 SWITCHES -> Default all on
;===================================================
CompilerIf	Defined(IsC2D, #PB_Module)	=	0
	DeclareModule	IsC2D	; Defaults -> all on!

		#IsC2D_C2D	=	1	; * Never change it! - only if Gui only is used! *

		XIncludeFile	"C2D_Types.pbi"	; Music / Gui / UnPack constants #XMU_? / XGG_? / XUP_?

		#IsC2D_Mode			=	#PB_2DDrawing_AlphaBlend	; Default drawingmode, 0=off

		#IsC2D_Anim			=	1			; Include animation
		#IsC2D_Ball3D		=	2			; 1/2 -> use Starfield, Merge, Explode commands
		#IsC2D_Bitmap		=	2			; 0/1/2 -> BitmapAdd(), BitmapScroll(), BitmapCopy()
		#IsC2D_BitmapColor=	1			; Functions to colorize/set transparency of bitmaps
		#IsC2D_Bounce		=	1			; Easy bouncing
		#IsC2D_Brush		=	1			; Include fast api brush
		#IsC2D_Buffer		=	1			; 1/2 -> BackScroll(), Noise(), for Mirror, SinX/Y, FastClear canvasbuffer access
		#IsC2D_Checker		=	2			; 1/2 -> no draw of ColorB (faster)
		#IsC2D_Clear		=	1			; 0/1/2 -> clear canvasbuffer -> 0 = off, 1 color (default), 2 = fast (black)
		#IsC2D_Copper		=	1			; Include copper
		#IsC2D_Delay		=	1			; Delay(#IsC2D_Delay) every call of Start(), 0 = off
		#IsC2D_File			=	2			; 1/2 -> need for file-access (@"Filename")
		#IsC2D_FlatBar		=	1			; Include flatbar
		#IsC2D_Font			=	1			; Special Font-Include (default or manually)
		#IsC2D_FontColor	=	1			; Shadow, copper, color
		#IsC2D_FontRaw		=	1			; s. Topaz
		#IsC2D_Fps			=	1			; Calculates frames per second (Canvas2D\FPS)
		#IsC2D_GdiPlus		=	1			; 1/2 -> if 0 define a native image-decoder
		#IsC2D_Gui			=	#PB_All	; #Gui_Gadget[Type|Type|...] (s. i_Gui_Types.pbi)
		#IsC2D_Guru			=	1			; Draw Guru-Alert (s. Stop())
		#IsC2D_Help			=	1			; Draw MouseX/Y-Coords on canvas (s. Stop())
		#IsC2D_Line3D		=	2			; 1/2 -> to Build & Fade object
		#IsC2D_MoveText	=	1			; 1/2 -> ControlCodes {Code,Param.f} #FC_Font only
		#IsC2D_Music		=	#XMU_SCA	; Music Type (s. i_XMusic_Types.pbi, default: SCA = scal dll)
		#IsC2D_NetWork		=	2			; 1/2 -> Dowload(), Size()
		#IsC2D_PageText	=	2			; 1/2 -> ControlCodes {Code,Param.f} -> #FC_Font only
		#IsC2D_Pixel3D		=	1			; Display/Rotate Image pixelwise (slow on large images)
		#IsC2D_Poly3D		=	1			; Display/Rotate API Polygons
		#IsC2D_RotoZoom	=	1			; Display rotated & zoomed picure
		#IsC2D_ScreenShot	=	1			; Easy screenshots
		#IsC2D_ScrollText	=	2			; 1/2 -> ControlCodes {Code,Param.f}
		#IsC2D_Splatter	=	1			; Blood-Splatter / Fireworks, support Anim
		#IsC2D_Stars2D		=	2			; 1/2 -> sort stars by alpha
		#IsC2D_Stars3D		=	1			; 1/2 -> fast 1px stars
		#IsC2D_StarsR3D	=	1			; Display/Rotate x/y/z stars
		#IsC2D_StarsZ3D	=	1			; 1/2 -> sort stars by alpha, Display/Rotate x/y/z zoom[16] stars
		#IsC2D_SysFont		=	1			; Use SystemFont TTF,FON,OTF... from memory
		#IsC2D_Text			=	1			; Static text
		#IsC2D_Time			=	0			; 0/1/2 -> 0=Elapsed (native,default), 1=timeGetTime, 2=GetTickCount
		#IsC2D_Topaz		=	1			; 0/1 -> default topaznew rawfont (452 bytes) / #IsC2D_FontRaw must be acitve
		#IsC2D_Twister		=	1			; Display 4 colored Twister
		#IsC2D_UCRT			=	0
		#IsC2D_XUnPack		=	#PB_All	; #XUP_(Type | Type | ... ) s. i_XUnPack_Types.pbi

		XIncludeFile	"C2D_Defaults.pbi"	; Predefined defaults

	EndDeclareModule
CompilerEndIf

Module	IsC2D	:	EndModule

;===================================================
;- *** Plugin -> XUnPack Module
;===================================================
CompilerIf	IsC2D::#IsC2D_XUnPack
	CompilerIf	Defined(IsXUP, #PB_Module)	=	0
		DeclareModule	IsXUP
			IncludeFile	"i_XUnPack_Types.pbi"
			#XUP_FLAGS	=	IsC2D::#IsC2D_XUnPack
		EndDeclareModule
	CompilerEndIf
	XIncludeFile	"i_XUnPack_Module.pbi"
CompilerEndIf

;===================================================
;- *** C2D DECLARES / #CONSTANTS / STRUCTURES / PTR
;===================================================
DeclareModule	C2D

	UseModule	IsC2D
	
	; Contstants / Structures / Macros
	XIncludeFile	"C2D_Macros.pbi"
	XIncludeFile	"C2D_Enums.pbi"
	XIncludeFile	"i_XMusic_Types.pbi"

	; Globals / Declares (gdiplus in main-module)
	CompilerIf	#IsC2D_GdiPlus			; *** GDIP ********
		Declare	GdipCatch(Image, *Memory.Union, Length)
	CompilerEndIf
	CompilerIf	#IsC2D_Bitmap			; *** BITMAP ******

		Global	ID_Bitmap.C2D_ID
		Global	NewList	RS_Bitmap.RS_Bitmap()

		CompilerIf	#IsC2D_BitmapColor
			Declare	BitmapClear(ID, Color.l)
			Declare	BitmapFill(ID, Color.l)
			Declare	BitmapGray(ID)
			Declare	BitmapLumen(ID, r.f=1.0, g.f=1.0, b.f=1.0, a.f=1.0)
			Declare	BitmapMask(ID, Color.l)
			Declare	BitmapShade(ID, Color.l)
			Declare	BitmapShine(ID, Factor.f=1.0)
		CompilerEndIf

		Declare	IsBitmap(ID)
		Declare	BitmapAdd(ID, Image)
		;Declare	BitmapCopy(ID)	; private
		Declare	BitmapDraw(ID, x.f, y.f, Alpha=255, Flags=0)
		Declare	BitmapFlip(ID, Flags=0)
		Declare	BitmapFree(ID)
		Declare	BitmapH(ID)
		Declare	BitmapID(ID)
		Declare	BitmapImage(ID)
		Declare	BitmapInit(ID, *Memory, Length=0, Color.l=#PB_Default)
		Declare	BitmapRange(ID, x.f, y.f)
		Declare	BitmapScale(ID, Ratio.f)
		Declare	BitmapW(ID)
		Declare.f	BitmapX(ID)
		Declare.f	BitmapY(ID)
		Declare	BitmapZoom(ID, w=#PB_Default, h=#PB_Default)

		CompilerIf	#IsC2D_Bitmap	=	2
			Declare	BitmapLoop(ID, Flags)
			Declare	BitmapScroll(ID, x, y, Time=0)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Bounce			; *** BOUNCE ******

		Global	ID_Bounce.C2D_ID
		Global	NewList	RS_Bounce.RS_Bounce()

		Declare	IsBounce(ID)
		Declare	BounceFree(ID)
		Declare	BounceInit(ID, y, h, Acceleration)
		Declare	Bounce(ID)

	CompilerEndIf
	CompilerIf	#IsC2D_Brush			; *** BRUSH *******

		Global	ID_Brush.C2D_ID
		Global	NewList	RS_Brush.RS_Brush()

		Declare	IsBrush(ID)
		Declare	BrushDraw(ID)
		Declare	BrushFree(ID)
		Declare	BrushInit(ID, Image, x, y, w, h)
		Declare	BrushMove(ID, x.f, y.f)
		Declare.f	BrushX(ID)
		Declare.f	BrushY(ID)

	CompilerEndIf
	CompilerIf	#IsC2D_Buffer			; *** BUFFER ******

		;Declare	BufferFree()	; called in Init(), private!
		;Declare	BufferInit()	; called in Init(), private!
		Declare	BufferClear()
		Declare	BufferCloneY(y0, y1, h)
		Declare	BufferMirror(x, y, w, h, Mask=%11111111)
		Declare	BufferSinDraw(y=0, h=0)
		Declare	BufferSinX(x, y, w, h, Width, Frequency.f, Speed.f)
		Declare	BufferSinY(x, y, w, h, Height, Frequency.f, Speed.f, Flags=#True)
		Declare	BufferBackDraw()
		Declare	BufferBackGrab()
		Declare	BufferFrontGrab()
		Declare	BufferFrontDraw(y=0, h=0)

		CompilerIf	#IsC2D_Buffer	=	2
			Declare	BufferBackScroll(x, y, Time=0)
			Declare	BufferNoise(x, y, w, h, Noise=3, Color.l=$00FFFFFF)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Font				; *** FONT ********

		Global	ID_Font.C2D_ID
		Global	NewList	RS_FontMap.RS_FontMap()

		Declare	IsFontMap(ID)
		Declare	FontScale(ID, Ratio.f)
		Declare	FontFree(ID)
		Declare	FontGap(ID, w=0, h=0)
		Declare	FontH(ID)
		Declare	FontImage(CharID)
		Declare	FontInit(ID, Image, x=0, y=0)
		Declare	FontSelect(ID)
		Declare	FontTab(ID, w=3)
		Declare	FontW(ID)
		Declare	FontZoom(ID, w, h)

		CompilerIf	#IsC2D_FontColor
			Declare	FontColor(ID, Color.l, t$=#Null$)
			Declare	FontCopper(ID, *Memory.Long, Flags=0)
			Declare	FontShadow(ID, x, y, Alpha=255)
			Declare	FontBorder(ID, Color.l=#Black)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_FontRaw			; *** FONTRAW *****

		Declare	FontRawInit(ID, *Memory.Union=#PB_Default, Length=0, zw=1, zh=1, Color.l=#White, Width=8, NumChar.a=#NUM_CHR)

	CompilerEndIf
	CompilerIf	#IsC2D_SysFont			; *** SYSFONT *****

		Global	ID_SysFont.C2D_ID
		Global	NewList	RS_SysFont.RS_SysFont()

		Declare	IsSysFont(ID)
		Declare	SysFontID(ID)
		Declare	SysFontFree(ID)
		Declare	SysFontInit(ID, Font$, *Memory, Length, h=0, w=0, Flags=0)
		Declare	SysFontSet(ID)

	CompilerEndIf
	CompilerIf	#IsC2D_Anim				; *** ANIM ********

		Global	ID_Anim.C2D_ID
		Global	NewList	RS_Anim.RS_Anim()

		Declare	IsAnim(ID)
		Declare	AnimCopper(ID, *Memory.Long, Flags=0)
		Declare	AnimCopy(ID, NewID, Flags=0)
		Declare	AnimCount(ID)
		Declare	AnimDelay(ID, Time, FrameID=#PB_All)
		Declare	AnimDirection(ID, Frames)
		Declare	AnimDraw(ID, x.f, y.f, Alpha=255, Flags=0)
		Declare	AnimFlip(ID, Flags=0)
		Declare	AnimFrame(ID, FrameID=#PB_Default)
		Declare	AnimFree(ID)
		Declare	AnimH(ID)
		Declare	AnimInit(ID, Image, x, y, Frames=#PB_All)
		Declare	AnimPause(ID, Status=1)
		Declare	AnimPlayDraw(ID, x.f, y.f, w=#PB_Default, h=#PB_Default)
		Declare	AnimPlayStart(ID, Count=1)
		Declare	AnimRange(ID, FrameID, Number)
		Declare	AnimPingPong(ID, Mode=1)
		Declare	AnimScale(ID, Ratio.f)
		Declare	AnimSeen(ID)
		Declare	AnimW(ID)
		Declare.f	AnimX(ID)
		Declare.f	AnimY(ID)
		Declare	AnimZoom(ID, w=#PB_Default, h=#PB_Default)
		Declare	AnimZone(ID, x.f, y.f)

	CompilerEndIf
	CompilerIf	#IsC2D_Ball3D			; *** BALL3D ******

		Global	ID_Ball3D.C2D_ID
		Global	Ball3DBob.RS_Ball3DBob
		Global	NewList	RS_Ball3DObject.RS_Ball3DObject()

		Declare		IsBall3D(ID)
		Declare		Ball3DAngle(ID, x.f, y.f, z.f)
		Declare		Ball3DCatchTheme(*Memory.Integer)
		Declare		Ball3DCount(ID)
		Declare		Ball3DDefaultTheme(*Memory.Long=0)
		Declare		Ball3DDraw(ID, x.f=0, y.f=0, Alpha=255, Fade=0)
		Declare		Ball3DFree(ID)
		Declare		Ball3DImage(BallID, Image=-1)
		Declare		Ball3DInit(ID, *Memory, Size, Gap.f=1.0)
		Declare		Ball3DRotate(ID, x.f, y.f, z.f)
		Declare		Ball3DSpin(ID, Factor.f, BallID=#PB_All)

		CompilerIf	#IsC2D_Ball3D	=	2
			CompilerIf	#IsC2D_Anim
				Declare	Ball3DAnim(ID, AnimID, BallID)
			CompilerEndIf
			Declare.f	Ball3DExplode(ID, Factor)
			Declare		Ball3DMerge(ID1, ID2)
			Declare		Ball3DStars(ID, Number, Radius, Size, BallID=3, Rnd.f=0)
		CompilerEndIf

		CompilerIf	#IsC2D_File
			Declare		Ball3DLoadTheme(Path$, Format$="png")
		CompilerEndIf

		; Default Ball3D Colors
		DataSection
			c2d_ball3d_rgb:	:	Data.l	$0020FF, $0096FF, $02D8D8, $02B402, $FF4000, $D800D8, $E8E8E8, $494848
		EndDataSection

	CompilerEndIf
	CompilerIf	#IsC2D_Copper			; *** COPPERBAR ***

		Global	ID_Copper.C2D_ID
		Global	CpBlt.RS_CpBlt
		Global	NewList	RS_Copper.RS_Copper()

		Declare	IsCopper(ID)
		Declare	CopperBitmap(ID, Image, x=0, y=0, Alpha=255)
		Declare	CopperScale(ID, Ratio.f)
		Declare	CopperBlit(ID, Position.f, Speed.f=0)
		Declare	CopperBlitColor(Color.l)
		Declare	CopperBlitProc(*Proc)
		Declare	CopperDraw(ID, y.f, Alpha=255, Flags=0)
		Declare	CopperFree(ID)
		Declare	CopperH(ID)
		Declare	CopperImage(ID)
		Declare	CopperInit(ID, h, *Memory.Long, Flags=#Null)
		Declare	CopperMoveDraw(ID, Position.f, Speed.f=5, Alpha=255)
		Declare	CopperZoom(ID, h)

		CompilerIf	#IsC2D_Font
			Declare	CopperText(ID, *Memory.Ascii, Flags=#C2F_Center)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Checker			; *** CHECKER *****

		Global	RS_Checker.RS_Checker

		Declare	CheckerColor(ColorA.l=#Red, ColorB.l=#White)
		Declare	CheckerDraw(SpeedY.f=1, SpeedX.f=0)
		Declare	CheckerInit(y, h, z=0, w_Shift=6)

	CompilerEndIf
	CompilerIf	#IsC2D_FlatBar			; *** FLATBAR *****

		Global	ID_FlatBar.C2D_ID
		Global	NewList	RS_FlatBar.RS_FlatBar()

		Declare	IsFlatBar(ID)
		Declare	FlatBarDraw(ID, y.f, Alpha=255)
		Declare	FlatBarFree(ID)
		Declare	FlatBarH(ID)
		Declare	FlatBarImage(ID)
		Declare	FlatBarInit(ID, h, Color.l, Frame=1)

		CompilerIf	#IsC2D_Font
			Declare	FlatBarText(ID, *Memory.Ascii, Flags=#C2F_Center)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Gui				; *** GUI *********

		Global	ID_GUI.C2D_ID
		Global	RS_GUI.RS_GUI
		Global	*RS_GuiDTC.RS_GuiDTC	; DrawTextCommand "$$"

		Global	RS_WG.RS_WindowGadget

		Global	NewMap	RS_GuiImage.RS_GuiImage()

		Global	ID_GuiMenu.C2D_ID
		Global	NewList	RS_GuiMenu.RS_GuiMenu()

		Declare.f	GuiMaxF(a.f, b.f)
		Declare.f	GuiMinF(a.f, b.f)
		Declare.f	GuiLoopF(a.f, min.f, max.f)
		Declare.f	GuiRangeF(a.f, min.f, max.f)
		Declare		GuiMax(a, b)
		Declare		GuiMin(a, b)
		Declare		GuiLoop(a, min, max)
		Declare		GuiRange(a, min, max)

		Declare		IsGuiGadget(ID)
		Declare		GuiColor(Front.l, Back.l=#PB_Ignore)
		Declare		GuiCopper(*Memory=0, Mode=#PB_Ignore)
		Declare		GuiDisable(ID, State)
		Declare		GuiDisableRegion(Window, State, x1, y1, x2, y2)
		Declare		GuiEvent(ID)
		Declare		GuiFrame(Mode, Alpha=0)
		Declare		GuiFree(ID, Window=#PB_All)
		Declare		GuiGadget(ID)
		Declare		GuiGadgetColor(ID, Front.l, Back.l)
		Declare		GuiGadgetID(ID)
		Declare.q	GuiGetData(ID)
		Declare		GuiGetState(ID)
		Declare$	GuiGetText(ID, Flags=0)
		Declare		GuiInit()
		Declare		GuiIsDisabled(ID)
		Declare		GuiLine(x, y, Length, Alpha=#PB_Default, Flags=#PB_Default)
		Declare		GuiRefresh(ID)
		Declare		GuiSetData(ID, Value.q)
		Declare		GuiSetFrame(ID, Frame)
		Declare		GuiSetState(ID, State)
		Declare		GuiSetText(ID, t$, Color.l=#PB_Default)
		Declare		GuiSetToggleText(ID, t$)
		Declare		GuiShadow(Color.l, x=1, y=1)
		Declare		GuiToggleColor(Color.l=#Null)
		Declare		GuiType(ID)
		
		Declare		GuiDregGet(ID)
		Declare		GuiDregSet(ID, Param)
		Declare		GuiDregVal(t$)

		Declare		GuiCursorInit(ID)
		Declare		GuiCursorSet(Window)

		Declare		GuiPaletteColor(FrontIndex, BackIndex=#PB_Ignore)
		Declare		GuiPaletteFree()
		Declare.l	GuiPaletteGetColor(Index, Alpha=$FF)
		Declare		GuiPaletteInit(*Memory, Count)
		Declare		GuiPaletteSetColor(Index, Color.l)

		Declare		IsGuiImage(ID)
		Declare		GuiImageAdd(ID, Image, Key$=#Null$)
		Declare		GuiImageDraw(ID, x.f, y.f, Alpha=255, Flags=0)
		Declare		GuiImageFree(ID=#PB_All, Flags=#False)
		Declare		GuiImageH(ID)
		Declare		GuiImageID(ID)
		Declare$	GuiImageKey(ID)
		Declare		GuiImageW(ID)

		Declare		GuiDrawFont(ID)
		Declare		GuiDrawFrame(Mode, x, y, w, h, Alpha=255)
		Declare		GuiDrawText(x, y, t$, Color.l=#Black, Flags=0)
		Declare		GuiDrawTextH(t$)
		Declare		GuiDrawTextW(t$)
		Declare$	GuiDrawTextRaw(t$)

		Declare		IsGuiFont(ID)
		Declare		GuiFontFree(ID)
		Declare		GuiFontInit(ID, Font$, *Memory, Length, h=0, w=0, Flags=0)
		Declare		GuiFontID()
		Declare		GuiFontSet(ID)

		Declare		GuiOffset(x=0, y=0, ix=0, iy=0)
		Declare		GuiPosition(x=0, y=0)
		Declare		GuiPosX(x=0)
		Declare		GuiPosY(y=0)
		Declare		GuiX(ID)
		Declare		GuiY(ID)
		Declare		GuiW(ID)
		Declare		GuiH(ID)
		Declare		GuiTab(w)

		CompilerIf	#IsC2D_Gui	&	#Gui_MenuPopup
			Declare		IsGuiMenu(ID)
			Declare		GuiMenuFree(ID)
			Declare		GuiMenuGetItem(ID)
			Declare		GuiMenuGetState(ID)
			Declare$	GuiMenuGetText(ID)
			Declare		GuiMenuInit(ID, Items$, Count=32)
			Declare		GuiMenuPopup(ID, Flags=0, Rows=16)
			Declare		GuiMenuSetState(ID, State)
			Declare		GuiMenuSize(ID)
			; Menu-Items
			Declare		GuiMenuItemAdd(ID, t$, Index=-1)
			Declare		GuiMenuItemDelete(ID, Index)
			Declare		GuiMenuItemDisable(ID, Index, State)
			Declare		GuiMenuItemIsDisabled(ID, Index)
			Declare		GuiMenuItemSetData(ID, Index, Value.q)
			Declare.q	GuiMenuItemGetData(ID, Index)
			Declare		GuiMenuItemToggle(ID, Index, Mode)
			Declare		GuiMenuItemIsToggled(ID, Index)
			Declare		GuiMenuItemSetState(ID, Index, State)
			Declare		GuiMenuItemGetState(ID, Index)
		CompilerEndIf

		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetButton
			Declare	GuiButtonGadget(ID, x, y, w, h, t$, Flags=0, Image=#PB_Ignore, Toggle$=#Null$)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetContainer
			Declare		GuiContainerGadget(ID, x, y, w, h)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetImage
			Declare		GuiImageGadget(ID, x, y, w, h, Image, Raster=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetProgress
			Declare		GuiProgressGadget(ID, x, y, w, h, max.d, Frame=0, Flags=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
			Declare		GuiStringGadget(ID, x, y, w, h, t$, Flags=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetText
			Declare		GuiTextGadget(ID, x, y, w, h, t$, Flags=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack
			Declare		GuiTrackGadget(ID, x, y, w, h, min, max, Frame=0, Flags=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawText
			Declare	GuiDrawTextGadget(ID, x, y, w, h, t$, Flags=0)
		CompilerEndIf
		CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawButton
			Declare	GuiDrawButtonGadget(ID, x, y, w, h, t$, Flags=#Gui_FlagCenter, Toggle$=#Null$)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Guru				; *** GURU ********

		Global	Guru.RS_Guru

		;Declare	GuruDraw()
		Declare	IsGuru()
		Declare	GuruFree()
		Declare	GuruInit(*Memory.Ascii, Color.l=#C2D_Guru_Color)

	CompilerEndIf
	CompilerIf	#IsC2D_Line3D			; *** LINE3D ******

		Global	ID_Line3D.C2D_ID
		Global	NewList	RS_Line3DObject.RS_Line3DObject()

		Declare	IsLine3D(ID)
		Declare	Line3DAngle(ID, x.f, y.f, z.f)
		Declare	Line3DColor(ID, Color.l)
		Declare	Line3DDraw(ID, x.f=0, y.f=0, zx.f=1.0, zy.f=1.0)
		Declare	Line3DFog(ID, Fog.f)
		Declare	Line3DFree(ID)
		Declare	Line3DInit(ID, *Memory.RS_Line3D, Ratio.f=1.0, z.f=1.0)
		Declare	Line3DRotate(ID, x.f, y.f, z.f)

		; Size
		Declare	Line3DWidth(ID)
		Declare	Line3DHeight(ID)
		Declare	Line3DDepth(ID)
		Declare.f	Line3DSquare(ID, Size.f, Ratio.f=0)

		; Build
		CompilerIf	#IsC2D_Line3D	=	2
			Declare	Line3DIsBuild(ID)
			Declare	Line3DIsFade(ID)
			Declare	Line3DFade(ID, Speed)
			Declare	Line3DBuild(ID, Mode, Speed)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_Music			; *** MUSIC *******

		CompilerSelect	#IsC2D_Music
			CompilerCase	#XMU_AMP

				DeclareC	MusicFree()
				DeclareC	MusicInit(Path$=#Null$)
				DeclareC	MusicLength()
				DeclareC	MusicLoop()
				DeclareC	MusicPercent()
				DeclareC	MusicPlay(*Memory, Length=#Null, SubSong=#Null)
				DeclareC	MusicStop()

			CompilerDefault

				Declare	MusicInit(Path$=#Null$, *CallBack=#Null)
				Declare	MusicFree()
				Declare	MusicPlay(*Memory, Length=#Null, SubSong=#Null)

		CompilerEndSelect

	CompilerEndIf
	CompilerIf	#IsC2D_Stars2D			; *** STARS2D *****

		Global	StarField2D.RS_StarField2D

		Declare	Stars2DColor(Color.l)
		Declare	Stars2DDirection(Flag)
		Declare	Stars2DDraw()
		Declare	Stars2DFree()
		Declare	Stars2DInit(Number, Size, x, y, w, h, Speed.f, Image=#PB_Default)

	CompilerEndIf
	CompilerIf	#IsC2D_Stars3D			; *** STARS3D *****

		Global	StarField3D.RS_StarField3D

		Declare	Stars3DColor(Color.l)
		Declare	Stars3DDistance(z)
		Declare	Stars3DDraw(x.f=0, y.f=0)
		Declare	Stars3DFree()
		Declare	Stars3DInit(Number, Size, x, y, w, h, Speed.f, Image=#PB_Default)
		Declare	Stars3DSpread(Spread)

	CompilerEndIf
	CompilerIf	#IsC2D_StarsR3D		; *** STARSR3D ****

		Global	RS_StarR3DField.RS_StarR3DField

		Declare	StarsR3DFree()
		Declare	StarsR3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default)
		Declare	StarsR3DDraw(x.f, y.f, z.f)

	CompilerEndIf
	CompilerIf	#IsC2D_StarsZ3D		; *** STARSZ3D ****

		Global	RS_StarZ3DField.RS_StarZ3DField

		Declare	StarsZ3DFree()
		Declare	StarsZ3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default, Fade=1)
		Declare	StarsZ3DDraw(x.f, y.f, z.f)

	CompilerEndIf
	CompilerIf	#IsC2D_Text				; *** TEXT ********

		Global	ID_Text.C2D_ID
		Global	NewList	RS_Text.RS_Text()

		Declare	IsText(ID)
		Declare	TextDraw(ID, x.f, y.f, Alpha=255, Flags=#Null)
		Declare	TextFree(ID)
		Declare	TextH(ID)
		Declare	TextInit(ID, *Memory.Ascii, Flags=#Null)
		Declare	TextStringDraw(x.f, y.f, Text$, Alpha=255)
		Declare	TextW(ID)

	CompilerEndIf
	CompilerIf	#IsC2D_ScrollText		; *** SCROLLTEXT **

		Global	ID_ScrollText.C2D_ID
		Global	NewList	RS_ScrollText.RS_ScrollText()

		Declare	IsScrollText(ID)
		Declare	ScrollTextDraw(ID, y.f, Alpha=255)
		Declare	ScrollTextFree(ID)
		Declare	ScrollTextH(ID)
		Declare	ScrollTextInit(ID, *Memory.Ascii)
		Declare	ScrollTextSinus(ID, Height.f=0, Frequency.f=0, Speed.f=0)
		Declare	ScrollTextSpeed(ID, Speed.f)
		Declare	ScrollTextW(ID)

		CompilerIf	#IsC2D_ScrollText	=	2
			Declare	ScrollTextPos(ID, Index=#Null)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_PageText		; *** PAGETEXT ****

		Global	RS_Page.RS_Page
		Global	NewList	RS_PageText.RS_PageText()

		Declare	PageTextColor(Color.l)
		Declare	PageTextDraw(x.f=0, y.f=0)
		Declare	PageTextFree()
		;Declare	PageTextFxChange(FX)	; private
		Declare	PageTextEffect(Mode, Effect, Speed.f, Delay.f)
		Declare	PageTextID(ID=-1)
		Declare	PageTextInit(*Memory.Ascii, x, y, w, h, Flags=#Null)
		Declare	PageTextWait(Time, PageID=-1)

	CompilerEndIf
	CompilerIf	#IsC2D_Pixel3D			; *** PIXEL3D *****

		Global	ID_Pixel3D.C2D_ID
		Global	NewList	RS_Pixel3D.RS_Pixel3D()

		Declare	IsPixel3D(ID)
		Declare	Pixel3DAngle(ID, x.f, y.f, z.f)
		Declare	Pixel3DAxis(ID, x.f, y.f)
		Declare	Pixel3DFree(ID)
		Declare	Pixel3DClip(ID, x, y, w, h)
		Declare	Pixel3DInit(ID, Image, Color.l=#Black)
		Declare	Pixel3DRotate(ID, x.f, y.f, z.f)
		Declare	Pixel3DDraw(ID, x.f, y.f, Alpha=255)
		Declare	Pixel3DDrawColor(ID, x.f, y.f, Color.l)
		Declare	Pixel3DW(ID)
		Declare	Pixel3DH(ID)
		Declare	Pixel3DCount(ID)

	CompilerEndIf
	CompilerIf	#IsC2D_Poly3D			; *** POLY3D ******

		Global	ID_Poly3D.C2D_ID
		Global	NewList	RS_Polygon.RS_Polygon()

		Declare	IsPoly3D(ID)
		Declare	Poly3DAngle(ID, x.f, y.f, z.f)
		Declare	Poly3DBrush(ID, Image)
		Declare	Poly3DBrushMove(ID, x.f, y.f)
		Declare	Poly3DClip(ID, x, y, w, h)
		Declare	Poly3DColor(ID, Color.l, Pen.l=#PB_Ignore, w=0)
		Declare	Poly3DDraw(ID, x.f=0, y.f=0)
		Declare	Poly3DDrawLine(ID, x.f=0, y.f=0, Color.l=#Red)
		Declare	Poly3DFree(ID)
		Declare	Poly3DInit(ID, *Memory.Union, Color.l=#White, Pen.l=#PB_Ignore)
		Declare	Poly3DRotate(ID, x.f, y.f, z.f)
		Declare	Poly3DScale(ID, Ratio.f)
		Declare	Poly3DZoom(ID, w.f, h.f)

	CompilerEndIf
	CompilerIf	#IsC2D_MoveText		; *** MOVETEXT ****

		Global	ID_MoveText.C2D_ID
		Global	NewList	RS_MoveText.RS_MoveText()

		Declare	IsMoveText(ID)
		Declare	MoveTextColor(ID, Color.l)
		Declare	MoveTextDraw(ID, Alpha=255)
		Declare	MoveTextFree(ID)
		Declare	MoveTextH(ID, Flags=#Null)
		Declare	MoveTextInit(ID, *Memory.Ascii, x, y, w, h, Flags=#Null)
		Declare	MoveTextSpeed(ID, Speed.f)
		Declare	MoveTextW(ID)
		Declare	MoveTextY(ID, y.f)

	CompilerEndIf
	CompilerIf	#IsC2D_File				; *** FILE/PATH ***

		Declare	FilePath(Path$)
		Declare	FileLoad(File$, Flags=0)

		CompilerIf	#IsC2D_File	=	2
			Declare		FileSave(File$, *Memory, Length)
			Declare$	FileParent(Path$=#Null$, Dirs=1)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_NetWork			; *** NETWORK *****

		Global	RS_NetWork.RS_NetWork

		Declare		NetWorkFree()		; private
		;Declare$	NetWorkUrl(Url$)	; private
		;Declare		NetWorkInit(Url$)	; private

		Declare	NetWorkBytes(Length=4096)
		Declare	NetWorkCallBack(*CallBack=0)
		Declare	NetWorkLoad(Url$)
		Declare	NetWorkSize(Url$)
		Declare	NetWorkSkip(Length=0)

		CompilerIf	#IsC2D_NetWork	=	2
			Declare	NetWorkDownload(Url$, File$)
		CompilerEndIf

	CompilerEndIf
	CompilerIf	#IsC2D_ScreenShot		; *** SCREENSHOT **
		Declare		ScreenShot()
	CompilerEndIf
	CompilerIf	#IsC2D_RotoZoom		; *** ROTOZOOM ****

		Global	RS_ROTOZOOM.RS_ROTOZOOM

		Declare	RotoZoomAlpha(Alpha)
		Declare	RotoZoomBlend(Percent)
		Declare	RotoZoomClip(x, y, w, h)
		Declare	RotoZoomDraw(rx.f, ry.f)
		Declare	RotoZoomInit(Image, Size.f=256.0, Color.l=#PB_Ignore)
		Declare	RotoZoomSet(Time, Speed, Min, Max)

	CompilerEndIf
	CompilerIf	#IsC2D_Twister			; *** TWISTER *****

		Global	ID_Twister.C2D_ID
		Global	NewList	RS_Twister.RS_Twister()

		Declare	IsTwister(ID)
		Declare	TwisterAlpha(ID, Alpha=$FF)
		Declare	TwisterColor(ID, RGB0.l=0, RGB1.l=0, RGB2.l=0, RGB3.l=0)
		Declare	TwisterCopy(ID, x.f, y.f)
		Declare	TwisterDraw(ID, x.f, y.f)
		Declare	TwisterFree(ID)
		Declare	TwisterFX(ID, Speed.f, Amplitude.f)
		Declare	TwisterInit(ID, Size, Speed.f, Amplitude.f, Mode=#C2F_VERTICAL, w=#Null, h=#Null)

	CompilerEndIf
	CompilerIf	#IsC2D_Splatter		; *** SPLATTER ****

		Global	ID_Splatter.C2D_ID
		Global	NewList	RS_Splatter.RS_Splatter()

		Declare	IsSplatter(ID)
		Declare	SplatterAcceleration(ID, x, y)
		Declare	SplatterAlpha(ID, Alpha=$FF)
		Declare	SplatterBounce(ID, Percent.f)
		Declare	SplatterDraw(ID, h.f)
		Declare	SplatterEnergy(ID, Energy)
		Declare	SplatterFade(ID, Fade)
		Declare	SplatterFree(ID)
		Declare	SplatterGravity(ID, Gravity)
		Declare	SplatterH(ID)
		Declare	SplatterImage(ID, Image)
		Declare	SplatterInit(ID, Size, Number, Color.l=#Red)
		Declare	SplatterLoop(ID, State)
		Declare	SplatterScale(ID, Ratio.f)
		Declare	SplatterSpread(ID, SpreadX, SpreadY)
		Declare	SplatterStart(ID, x.f, y.f)
		Declare	SplatterStop(ID=#PB_All)
		Declare	SplatterW(ID)

		Declare	SplatterAnim(ID, AnimID)	; Splatter + Anim

	CompilerEndIf

	; *** C2D MAIN *************************************
	CompilerIf	#IsC2D_C2D

	Global	C2D.RS_Canvas2D

	Declare	Color(Color.l)
	Declare	Free()
	Declare	Init(Gadget, Speed=5, Color.l=#Black)
	Declare	Quality(Mode)
	Declare	Start()
	Declare	Stop()

	Declare	ViewPort(x=0, y=0)
	Declare	Uni2Asc(*Text, Flags=#Null)

	CompilerEndIf

EndDeclareModule

;===================================================
;- *** C2D MAIN-MODULE
;===================================================
Module	C2D

	;================================================
	;- *** C2D InCLUDES *****************************
	;================================================
	
	CompilerIf	#IsC2D_UCRT	; Windows 10+ only (much smaller exe with PBv6.10+)
		CompilerIf	#PB_Compiler_Version	>=	610

		Import	"/NODEFAULTLIB:libucrt.lib"	:	EndImport
		Import	"ucrt.lib"							:	EndImport

		; Import	"/NODEFAULTLIB:libucrt.lib"		:	EndImport
		; Import	"/NODEFAULTLIB:libvcruntime.lib"	:	EndImport
		; Import	"/NODEFAULTLIB:libcmt.lib"			:	EndImport
		; Import	"/NODEFAULTLIB:libcpmt.lib"		:	EndImport

		; Import	"ucrt.lib"			:	EndImport	; libucrt.lib       The Universal CRT (UCRT) contains the functions and globals exported by the standard C99 CRT library.
		; Import	"vcruntime.lib"	:	EndImport	; libvcruntime.lib  The vcruntime library contains Visual C++ CRT implementation-specific code: exception handling and debugging support, runtime checks and type information, implementation details, and certain extended library functions.
		; Import	"msvcrt.lib"		:	EndImport	; libcmt.lib        This code handles CRT startup, internal per-thread data initialization, and termination.      
		; Import	"msvcprt.lib"		:	EndImport	; libcpmt.lib       C++ standard library (STL) .lib files

		CompilerEndIf
	CompilerEndIf
	
	CompilerIf	#IsC2D_GdiPlus
		; PNG/GIF/JPG..
		XIncludeFile	"i_C2D_Gdiplus.pbi"
	CompilerElseIf	#IsC2D_Bitmap
		Procedure	GdipCatch(Image, *Memory, Length=#Null)
			ProcedureReturn	CatchImage(Image, *Memory)
		EndProcedure
	CompilerEndIf
	CompilerIf	#IsC2D_Bitmap
		XIncludeFile	"i_C2D_Bitmap.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Bounce
		XIncludeFile	"i_C2D_Bounce.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Brush
		XIncludeFile	"i_C2D_Brush.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Buffer
		XIncludeFile	"i_C2D_Buffer.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Font
		; special font-module
		XIncludeFile	"i_C2D_Font.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_FontRaw
		; need font-module
		XIncludeFile	"i_C2D_FontRaw.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_SysFont
		; ttf font-module
		XIncludeFile	"i_C2D_SysFont.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Text
		XIncludeFile	"i_C2D_Text.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_PageText
		XIncludeFile	"i_C2D_PageText.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Pixel3D
		XIncludeFile	"i_C2D_Pixel3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Poly3D
		XIncludeFile	"i_C2D_Poly3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_ScrollText
		XIncludeFile	"i_C2D_ScrollText.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_MoveText
		XIncludeFile	"i_C2D_MoveText.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Anim
		XIncludeFile	"i_C2D_Anim.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Ball3D
		XIncludeFile	"i_C2D_Ball3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Checker
		XIncludeFile	"i_C2D_Checker.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Copper
		XIncludeFile	"i_C2D_Copper.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_FlatBar
		XIncludeFile	"i_C2D_FlatBar.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Line3D
		XIncludeFile	"i_C2D_Line3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Gui
		XIncludeFile	"i_Gui_Module.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Guru
		XIncludeFile	"i_C2D_Guru.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Music
		XIncludeFile	"i_XMusic_Module.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Stars2D
		XIncludeFile	"i_C2D_Stars2D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Stars3D
		XIncludeFile	"i_C2D_Stars3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_StarsR3D
		XIncludeFile	"i_C2D_StarsR3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_StarsZ3D
		XIncludeFile	"i_C2D_StarsZ3D.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_File
		XIncludeFile	"i_C2D_File.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_NetWork
		XIncludeFile	"i_C2D_NetWork.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_ScreenShot
		XIncludeFile	"i_C2D_ScreenShot.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_RotoZoom
		XIncludeFile	"i_C2D_RotoZoom.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Twister
		XIncludeFile	"i_C2D_Twister.pbi"
	CompilerEndIf
	CompilerIf	#IsC2D_Splatter
		XIncludeFile	"i_C2D_Splatter.pbi"
	CompilerEndIf

	;================================================
	;- *** C2D SYSTEM *******************************
	;================================================
	
	CompilerIf	#IsC2D_C2D

	Procedure	Init(Gadget, Speed=5, Color.l=#Black)

		Protected	i

		With	C2D

			\Gadget	=	Gadget			; #Gadget

			If	Color	&	$FF000000	=	#Null	:	Color|$FF000000	:	EndIf	; Must have an alphachannel

			\Color	=	Color				; ABGR
			\Speed	=	Speed				; ms
			\Quality	=	#PB_Image_Raw	; 1

			; get real size / buffer & clear
			StartDrawing(CanvasOutput(\Gadget))
			\w	=	OutputWidth()	; pixelWidth
			\h	=	OutputHeight()	; pixelHeight
			\cx	=	\w	*	0.5	; CenterX
			\cy	=	\h	*	0.5	; CenterY
			CompilerIf	#IsC2D_Buffer
				BufferInit()
			CompilerElseIf	#IsC2D_Guru	Or	#IsC2D_Clear = 2
				\hBuffer		=	DrawingBuffer()			; need for fastclear & guru -> update in Start()
				\hPitch		=	DrawingBufferPitch()		; real pixelWidth x #MAX_BPP
				\hSize		=	\hPitch	*	\h				; bytesize of buffer
			CompilerEndIf
			CompilerSelect	#IsC2D_Clear
				CompilerCase	2	; clear canvasbuffer by faster fillmemory (2=black only)
					FillMemory(\hBuffer, \hSize, #Null, #PB_Integer)
				CompilerDefault	; init default draw canvasbuffer with color (0/1=color, also 0 for first initialize)
					Box(0, 0, \w, \h, \Color)
			CompilerEndSelect
			StopDrawing()

			; Generate fast Sinus/Cosinus
			For	i	=	0	To	#MAX_SIN
				\GCos[i]	=	Cos(i * (2 * #PI / #MAX_SIN))
				\GSin[i]	=	Sin(i * (2 * #PI / #MAX_SIN))
			Next

			; default inits
			CompilerIf	#IsC2D_Ball3D	; Create default ball-theme
				Ball3DDefaultTheme()
			CompilerEndIf
			CompilerIf	#IsC2D_Copper	; Default CopperBlits
				CpBlt\cbColor	=	$FFFFFFFF
				CpBlt\cbProc	=	@Blt_Copper_Color()
			CompilerEndIf
			CompilerIf	#IsC2D_Stars2D	; Defaults stars2d
				Stars2DColor(#White)
				Stars2DDirection(#C2F_Right)
			CompilerEndIf
			CompilerIf	#IsC2D_Stars3D	; Defaults stars3d
				Stars3DColor(#White)
				Stars3DDistance(0)
				Stars3DSpread(\w)
			CompilerEndIf
			CompilerIf	#IsC2D_Gui
				GuiInit()
			CompilerEndIf

			\Time	=	MA_TIME()	; get actual time for speed in ms

		EndWith

	EndProcedure
	Procedure	Start()

		With	C2D

			If	(MA_TIME()	>=	\Time)

				\hDC	=	StartDrawing(CanvasOutput(\Gadget))	; hDC for Polygon etc.

				CompilerIf	#IsC2D_Help
					\MPF_Time	=	MA_Time()
				CompilerEndIf

				CompilerIf	#IsC2D_Buffer	Or	#IsC2D_Guru	Or	#IsC2D_Clear = 2
					\hBuffer		=	DrawingBuffer()
					\hBufferY	=	\hBuffer	+	\hSize	; ReversedY from 0=bottom to h=top
				CompilerEndIf

				CompilerSelect	#IsC2D_Clear
					CompilerCase	1
						Box(0, 0, \w, \h, \Color)	; notice DrawingMode after Box for the fastest (coz slow alphablend)
					CompilerCase	2
						FillMemory(\hBuffer, \hSize, #Null, #PB_Integer)	; clear canvasbuffer by faster fillmemory (black only)
				CompilerEndSelect

				; Mode order here! - coz extrem slow Box() & blend-flag!
				CompilerIf	#IsC2D_Mode
					DrawingMode(#IsC2D_Mode)	; #PB_2DDrawing_AlphaBlend
				CompilerEndIf

				; Counter for Buffer SinX/SinY
				CompilerIf	#IsC2D_Buffer
					\Count	+	1
				CompilerEndIf

				\Time	=	MA_TIME()	+	\Speed	; time for next update

				ProcedureReturn	#True	; OK -> we can draw!

			EndIf

		EndWith

		; Delay() Time < Speed only, don't waste all cpu-time!
		CompilerIf	#IsC2D_Delay
			Delay(#IsC2D_Delay)
		CompilerEndIf

	EndProcedure
	Procedure	Stop()

		CompilerIf	#IsC2D_Guru	; draw the guru-request?
			If	Guru\IsOn	:	GuruDraw()	:	EndIf
		CompilerEndIf

		CompilerIf	#IsC2D_Fps	Or	#IsC2D_Help
			With	C2D
				\FPS_Count	+	1	; counter for FPS
				If	MA_TIME()	>=	\FPS_Time
					\FPS			=	\FPS_Count	; FPS -> actual frames per seconds
					\FPS_Time	=	MA_TIME()	+	1000
					\FPS_Count	=	#Null
				EndIf
			EndWith
		CompilerEndIf

		CompilerIf	#IsC2D_Help	; draw coords?

			;Protected	mx	=	WindowMouseX(0)	+	Abs(GadgetX(C2D\Gadget))
			;Protected	my	=	WindowMouseY(0)	+	Abs(GadgetY(C2D\Gadget))
			Protected	t$

			Protected	mx	=	GadgetX(C2D\Gadget)
			Protected	my	=	GadgetY(C2D\Gadget)

			Static	Time, TimeFps, MPF

			If	mx	<>	0
				mx	=	WindowMouseX(0)	-	mx
			Else
				mx	+	WindowMouseX(0)
			EndIf
			If	my	<>	0
				my	=	WindowMouseY(0)	-	my
			Else
				my	+	WindowMouseY(0)
			EndIf

			If	mx	>=	0	And	my	>=	0

				If	C2D\FPS_Count	=	#Null
					TimeFps	=	MA_Time()	-	Time
					MPF	=	MA_Time()	-	C2D\MPF_Time
				Else
					Time	=	MA_Time()
				EndIf

				t$	=	"X:"		+ Str(mx)	+
				  	 	" - Y:"	+ Str(my)	+
				  	 	" - "		+
				  	 	"W×"	+ StrF(1.0 / C2D\w * mx, 3)	+
				  	 	" - H×" + StrF(1.0 / C2D\h * my, 3)	+
				  	 	" - FPS:"	+	Str(C2D\FPS)	+
				  	 	" - MPF:"	+	Str(MPF)	+
				  	 	" - Time:"	+	Str(TimeFps)

				DrawingMode(#PB_2DDrawing_XOr)
				DrawingFont(#PB_Default)
				FrontColor($FFFFFFFF)

				LineXY(mx, 0, mx, C2D\h)
				LineXY(0, my, C2D\w, my)

				DrawText((C2D\w - TextWidth(t$)) * 0.5, 0,	t$)

			EndIf

		CompilerEndIf

		StopDrawing()

	EndProcedure
	Procedure	Color(Color.l)
		C2D\Color	=	$FF000000|Color
	EndProcedure
	Procedure	Quality(Mode)

		; Mode = #PB_Image_Raw -> <> 0 Or #PB_Image_Smooth -> = 0

		If	Mode
			C2D\Quality	=	#PB_Image_Raw
		Else
			C2D\Quality	=	#PB_Image_Smooth
		EndIf

	EndProcedure
	Procedure	Free()
		CompilerIf	#IsC2D_Anim
			AnimFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Ball3D
			Ball3DFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Bitmap
			BitmapFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Bounce
			BounceFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Brush
			BrushFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Buffer
			BufferFree()
		CompilerEndIf
		CompilerIf	#IsC2D_Copper
			CopperFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_FlatBar
			FlatBarFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Font
			FontFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Guru
			GuruFree()
		CompilerEndIf
		CompilerIf	#IsC2D_Line3D
			Line3DFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_MoveText
			MoveTextFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Music
			MusicFree()
		CompilerEndIf
		CompilerIf	#IsC2D_PageText
			PageTextFree()
		CompilerEndIf
		CompilerIf	#IsC2D_Pixel3D
			Pixel3DFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Poly3D
			Poly3DFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_ScrollText
			ScrollTextFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Splatter
			SplatterFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Stars2D
			Stars2DFree()
		CompilerEndIf
		CompilerIf	#IsC2D_Stars3D
			Stars3DFree()
		CompilerEndIf
		CompilerIf	#IsC2D_StarsR3D
			StarsR3DFree()
		CompilerEndIf
		CompilerIf	#IsC2D_StarsZ3D
			StarsZ3DFree()
		CompilerEndIf
		CompilerIf	#IsC2D_SysFont
			SysFontFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Text
			TextFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_Twister
			TwisterFree(#PB_All)
		CompilerEndIf
		CompilerIf	#IsC2D_XUnPack
			XUP::Free()
		CompilerEndIf
		CompilerIf	#IsC2D_NetWork
			NetWorkFree()
		CompilerEndIf
		CompilerIf	#IsC2D_Gui
			GuiFree(#PB_All)	; also frees fonts / menus
		CompilerEndIf
	EndProcedure

	Procedure	ViewPort(x=0, y=0)
		; re-set to (full) viewport -> common when using poly3d
		; https://docs.microsoft.com/de-de/windows/win32/gdi/coordinate-space-and-transformation-functions
		SetViewportOrgEx_(C2D\hDC, x, y, #Null)
	EndProcedure
	Procedure	Uni2Asc(*Text, Flags=#Null)
		CompilerIf	#PB_Compiler_Unicode

			Static	*Memory

			If	*Memory
				FreeMemory(*Memory)	:	*Memory	=	#Null
			EndIf

			If	MemoryStringLength(*Text)	; faster than lstrlen_(*Text)

				If	Flags	&	#C2F_Ucase
					CharUpper_(*Text)
				EndIf

				CompilerIf	#PB_Compiler_Version	<	550
					*Memory	=	AllocateMemory(MemoryStringLength(*Text) + SizeOf(Character))
					PokeS(*Memory, PeekS(*Text), MemoryStringLength(*Text), #PB_Ascii)
				CompilerElse
					*Memory	=	Ascii(PeekS(*Text))
				CompilerEndIf

			EndIf

			ProcedureReturn	*Memory

		CompilerElse

			If	Flags	&	#C2F_Ucase
				CharUpper_(*Text)
			EndIf

			ProcedureReturn	*Text

		CompilerEndIf
	EndProcedure

	CompilerEndIf

EndModule

;===================================================
; Global macros for private use
;===================================================
Macro	MA_GSin(ANGLE)		; Float
	C2D::C2D\GSin[Int(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GCos(ANGLE)		; Float
	C2D::C2D\GCOS[Int(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GSinI(ANGLE)	; Integer
	C2D::C2D\GSin[(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GCosI(ANGLE)	; Integer
	C2D::C2D\GCOS[(ANGLE) & C2D::#MAX_SIN]
EndMacro

Macro	MA_XC2D()	; C2D Version$
	C2D::#C2D_VER$
EndMacro
Macro	MA_XOS()		; OS Version$
	C2D::#C2D_XOS$
EndMacro
Macro	MA_XPB()		; PB Version$
	C2D::#C2D_XPB$
EndMacro

Macro	MA_C2DOS(TITLE)	; C2D:: + OS$
	"C2D::" + TITLE + " (" + MA_XOS() + ")"
EndMacro
Macro	MA_C2DPB(TITLE)	; C2D:: + PB$ + OS$
	"C2D::" + TITLE + " / PB " + MA_XPB() + " (" + MA_XOS() + ")"
EndMacro

CompilerIf	Defined(SCAL_PATH$, #PB_Constant)	=	0
	#SCAL_PATH$	=	"..\Tools\SCAL\"
CompilerEndIf

; EOF
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = EAAAAAAAAAAAAAAAAAAAAAAAAAAg
; CompileSourceDirectory