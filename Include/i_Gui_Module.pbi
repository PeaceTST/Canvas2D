;**********************************************
;- *** C2D Gui (ßeta) / 14.04.2026 ************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	#IsC2D_Gui	=	-1	; ! (#C2D_GUI_[Type])

	XIncludeFile	"C2D_Enums.pbi"

	#Gui_DefHeight		=	22				; Default height
	#Gui_DefColor		=	$000000		; Default FrontColor
	#Gui_DefBackColor	=	$D1B499		; Default Background
	#Gui_DefGrayColor	=	$FFCACACA	; Disable grayed

	EnumerationBinary	; Gadget- / Menu Flags
		#Gui_FlagCenter; 1
		#Gui_FlagLeft	; 2
		#Gui_FlagRight	; 4
		#Gui_FlagToggle; 8
		#Gui_FlagVertical	; 16
		#Gui_FlagPercent	; 32	->	  0 - 100 (%)
		#Gui_FlagLevel		; 64	-> -50 - +50
		#Gui_FlagNumber	; 128	->	  0 - #max
		#Gui_FlagShadow	; 256	->	Text- / Menushadow
		#Gui_FlagBorder	; 512 -> Menuborder
		#Gui_FlagState		; 1024 -> Place for menu-marker
		#Gui_FlagUser		; 2048 -> do whatever you want
	EndEnumeration
	Enumeration			; FrameModes
		#Gui_FrameNone	; 0
		#Gui_Frame3D	; 1
		#Gui_FrameBar	; 2
		#Gui_FrameFine	; 3
		#Gui_FrameFlat	; 4
		#Gui_FrameLite	; 5
		#Gui_FrameRised; 6
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
	#DTC_PALETTECOLOR$	=	"PC"	:	#DTC_PALETTECOLOR	=	ID_WORD('P','C')	; {PC.#(,#)} - Palette Color FrontID(,BackID)
	#DTC_PALETTEFRONT$	=	"PF"	:	#DTC_PALETTEFRONT	=	ID_WORD('P','F')	; {PF,#} - Palette Frontcolor, #ID
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
		Gadget.i						; ID
		IsState.i					; 0/1
		IsDisable.i					; 0/1
		IsToggle.i					; 0/1
		t$								; Itemtext
		h.i							; Height of gadget
		Value.q						; ItemData
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
	Structure	RS_GuiDTC	;	DrawTextCodeID "$$"
		a.c
		b.c
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

	Global	ID_GUI.C2D_ID
	Global	RS_GUI.RS_GUI
	Global	*RS_GuiDTC.RS_GuiDTC

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
	Declare		GuiSetState(ID, State)
	Declare		GuiSetText(ID, t$, Color.l=#PB_Default)
	Declare		GuiSetToggleText(ID, t$)
	Declare		GuiShadow(Color.l, x=1, y=1)
	Declare		GuiToggleColor(Color.l=#Null)
	Declare		GuiType(ID)

	Declare		GuiDregGet(ID)
	Declare		GuiDregSet(ID, Param.f)
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
	Declare$	GuiImageKey(ID)
	Declare		GuiImageDraw(ID, x.f, y.f, Alpha=255, Flags=0)
	Declare		GuiImageFree(ID=#PB_All, Flags=#False)
	Declare		GuiImageID(ID)
	Declare		GuiImageH(ID)
	Declare		GuiImageW(ID)

	Declare		GuiDrawFont(ID)
	Declare		GuiDrawFrame(Mode, x, y, w, h, Alpha=255)
	Declare		GuiDrawText(x, y, t$, Color.l=#Black, Flags=0)
	Declare		GuiDrawTextH(t$)
	Declare		GuiDrawTextW(t$)
	Declare$	GuiDawTextRaw(t$)

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

Procedure	GuiProc_WindowGadget(*hWnd, Param)

	Protected	Gadget	=	GetProp_(*hWnd, "PB_ID")

	With	RS_WG
		If	IsGadget(Gadget)

			Select	Param
				Case	#C2D_WG_DISABLE	; disable gadgets in region of window

					If	GadgetX(Gadget)	>=	\x1	And
					  	GadgetY(Gadget)	>=	\y1	And
					  	GadgetX(Gadget)	<=	\x2	And
					  	GadgetY(Gadget)	<=	\y2
						If	GadgetType(Gadget)	=	#PB_GadgetType_Canvas
							C2D::GuiDisable(Gadget, \State)
						Else
							DisableGadget(Gadget, \State)
						EndIf
					EndIf

				Case	#C2D_WG_FREE	; free all gadgets in window

					If	GadgetType(Gadget)	=	#PB_GadgetType_Canvas	; native-check
						Select	GuiType(Gadget)	; *** NOT GadgetType() ***
							Case	#PB_GadgetType_Container, #PB_GadgetType_String
								EnumChildWindows_(*hWnd, @GuiProc_WindowGadget(), #C2D_WG_FREE)
						EndSelect
						GuiFree(Gadget)
					Else
						FreeGadget(Gadget)
					EndIf

				Case	#C2D_WG_CURSOR	; set cursor to gadgets

					Select	GadgetType(Gadget)
						Case	#PB_GadgetType_Canvas
							SetGadgetAttribute(Gadget, #PB_Canvas_CustomCursor, RS_GUI\hCursor)
							Select	GuiType(Gadget)	; *** NOT GadgetType() ***
								Case	#PB_GadgetType_Container
									EnumChildWindows_(*hWnd, @GuiProc_WindowGadget(), #C2D_WG_CURSOR)
							EndSelect
						Case	#PB_GadgetType_ScrollArea
							SetClassLongPtr_(*hWnd, #GCL_HCURSOR, RS_GUI\hCursor)
							EnumChildWindows_(*hWnd, @GuiProc_WindowGadget(), #C2D_WG_CURSOR)
						Case	#PB_GadgetType_Editor, #PB_GadgetType_Web
							; do not change in an editorgadget!
						Default
							SetClassLongPtr_(*hWnd, #GCL_HCURSOR, RS_GUI\hCursor)
					EndSelect

			EndSelect

		ElseIf	Param	=	#C2D_WG_CURSOR	And	*hWnd	; set cursor to window [gadget]

			SetClassLongPtr_(*hWnd, #GCL_HCURSOR, RS_GUI\hCursor)

		EndIf
	EndWith

	ProcedureReturn	#True

EndProcedure

Procedure	Gui_Any()

	Protected	i=#MAX_ID

	While	i	>=	#Null
		If	IsGadget(i)	=	0	;And	ID_GUI\ID[i]	=	0
			Break
		EndIf
		i	-	1
	Wend

	ProcedureReturn	i

EndProcedure
Procedure	Gui_CreateGadget(ID, x, y, w, h, Flags, Type)

	; Global create of the CanvasGadgets & set params
	; Return: #Gadget

	If	ID	<	#Null	:	ID	=	Gui_Any()	:	EndIf

	GuiFree(ID)	:	ID_GUI\ID[ID]	=	AddElement(RS_GUI\Gadget())	; -> @RS_GUI\Gadget()

	If	w	>	32000	:	w	=	32000	:	EndIf
	If	h	>	32000	:	h	=	32000	:	EndIf

	With	RS_GUI\Gadget()

		\ID		=	ID
		\Type		=	Type
		\x			=	RS_GUI\OffsetGadget\x + x
		\y			=	RS_GUI\OffsetGadget\y + y
		\w			=	w
		\h			=	h
		\Flags	=	Flags

		\Color		=	RS_GUI\Color
		\BackColor	=	RS_GUI\BackColor
		\ToggleColor=	RS_GUI\ToggleColor
		\ShadowColor=	RS_GUI\ShadowColor

		\FrameMode	=	RS_GUI\FrameMode
		\FrameSize	=	RS_GUI\FrameSize
		\CopperPtr	=	RS_GUI\CopperPtr
		\CopperMode	=	RS_GUI\CopperMode

		\hFont	=	RS_GUI\hFont

		; ButtonGadget,TextGadget
		\OffsetText\x	=	RS_GUI\OffsetText\x
		\OffsetText\y	=	RS_GUI\OffsetText\y
		\OffsetImage\x	=	RS_GUI\OffsetImage\x
		\OffsetImage\y	=	RS_GUI\OffsetImage\y

		\OffsetShadow\x	=	RS_GUI\OffsetShadow\x
		\OffsetShadow\y	=	RS_GUI\OffsetShadow\y

		; ProgressState, Copper
		\Clip\x	=	RS_GUI\OffsetText\x	+	\FrameSize
		\Clip\y	=	RS_GUI\OffsetText\y	+	\FrameSize

		If	\Flags	&	#Gui_FlagVertical
			Swap	\Clip\x, \Clip\y
		EndIf

		\Clip\w	=	w	-	\Clip\x	*	2
		\Clip\h	=	h	-	\Clip\y	*	2

		CanvasGadget(\ID, \x, \y, \w, \h, #PB_Canvas_Container * Bool(Type=#PB_GadgetType_Container Or Type=#PB_GadgetType_String))

		ProcedureReturn	\ID

	EndWith

EndProcedure

Procedure.f	GuiMaxF(a.f, b.f)
	If	a	<	b
		ProcedureReturn	b
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure.f	GuiMinF(a.f, b.f)
	If	a	>	b
		ProcedureReturn	b
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure.f	GuiLoopF(a.f, min.f, max.f)
	If	a	<	min
		ProcedureReturn	max
	ElseIf	a	>	max
		ProcedureReturn	min
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure.f	GuiRangeF(a.f, min.f, max.f)
	If	a	<	min
		ProcedureReturn	min
	ElseIf	a	>	max
		ProcedureReturn	max
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure	GuiMax(a, b)
	If	a	<	b
		ProcedureReturn	b
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure	GuiMin(a, b)
	If	a	>	b
		ProcedureReturn	b
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure	GuiLoop(a, min, max)
	If	a	<	min
		ProcedureReturn	max
	ElseIf	a	>	max
		ProcedureReturn	min
	EndIf
	ProcedureReturn	a
EndProcedure
Procedure	GuiRange(a, min, max)
	If	a	<	min
		ProcedureReturn	min
	ElseIf	a	>	max
		ProcedureReturn	max
	EndIf
	ProcedureReturn	a
EndProcedure

Procedure	Gui_TextAlignX(*Memory.Character, Flags)	; intern x-char-align when new line

	; inside StartDrawing() / StopDrawing()

	If	*Memory	<=	#Null	:	ProcedureReturn	:	EndIf

	Protected	x
	Protected	a$, Param, IsGapX
	Protected	*hFont=GuiFontID()

	While	*Memory\c

		Select	*Memory\c

			Case	#LF, '|'
				Break

			Case	#TAB
				;x	+	TextWidth(" ")	*	RS_GUI\TabWidth

				Param	=	TextWidth("0")	*	RS_GUI\TabWidth	; tabwidth
				x	+	Param	-	(x	%	Param)

			Case	'{'	; *** CtrlStart {Code,Param,...} ***

				a$	=	#Null$

				*Memory	+	SizeOf(Character)
				While	*Memory\c	And	*Memory\c	<>	'}'	; *** CtrlEnd
					a$	+	Chr(*Memory\c)	:	*Memory	+	SizeOf(Character)
				Wend

				Param	=	GuiDRegVal(StringField(a$, 2, ","))	; D0..D9

				*RS_GuiDTC	=	@a$	; Command

				Select	ID_WORD(*RS_GuiDTC\a,*RS_GuiDTC\b)	; Left(a$, 2)
					Case	#DTC_FONT	; FontID?
						GuiDrawFont(Param)
					Case	#DTC_XGAP	; X-Gap
						IsGapX	=	Param
					Case	#DTC_IMAGE	; Image
						If	IsImage(Param)
							x	+	ImageWidth(Param)	+	IsGapX
						EndIf
					Case	#DTC_GUIIMAGE	; GuiImage
						If	IsGuiImage(Param)
							x	+	RS_GuiImage()\w	+	IsGapX
						EndIf
					Case	#DTC_MENU
						x	+	12
					Case	#DTC_D0	To	#DTC_D9
						GuiDRegSet(*RS_GuiDTC\b - '0', Param)
					Case	#DTC_EXIT	; Exit
						Break
				EndSelect

			Default

				x	+	TextWidth(Chr(*Memory\c))	+	IsGapX

		EndSelect

		*Memory	+	SizeOf(Character)

	Wend

	If	Flags	&	#Gui_FlagCenter
		x	=	(OutputWidth()	-	x)	>> 1
	ElseIf	Flags	&	#Gui_FlagRight
		x	=	OutputWidth()	-	(x	+	RS_GUI\FrameSize)
	Else
		x	=	RS_GUI\OffsetText\x	+	RS_GUI\FrameSize
	EndIf

	RS_GUI\hFont	=	*hFont	; Restore font

	ProcedureReturn	x

EndProcedure

Procedure	Gui_DrawCopper(x=0, y=0, w=0, h=0)

	If	ListSize(RS_GUI\Gadget())	=	#Null	:	ProcedureReturn	:	EndIf

	Protected	*Memory.Long	=	RS_GUI\Gadget()\CopperPtr

	If	*Memory	<=	0	Or	*Memory\l	<=	1	:	ProcedureReturn	:	EndIf

	Protected	i
	Protected	*Ptr.Long	=	*Memory	+	SizeOf(Long)	; Color-Table
	Protected	c.f	=	1.0	/	(*Memory\l	-	1)			; Number of colors

	DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)

	If	w	<=	0	:	w	=	RS_GUI\Gadget()\w	:	EndIf
	If	h	<=	0	:	h	=	RS_GUI\Gadget()\h	:	EndIf

	Select	RS_GUI\Gadget()\CopperMode
		Case	1	; Horizontal
			LinearGradient(0, 0, OutputWidth()-1, 0)
		Case	2	; Center
			EllipticalGradient(x + w / 2, y + h / 2, w / 2, h / 2)
		Default	; Vertical
			LinearGradient(0, 0, 0, OutputHeight()-1)
	EndSelect

	For	i	=	0	To	*Memory\l	-	1
		GradientColor(c * i, *Ptr\l)
		*Ptr	+	SizeOf(Long)
	Next

	Box(x, y, w, h)

	DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)

EndProcedure
Procedure.l	Gui_DrawDisable(x, y, Pen.l, Paper.l)

	If	RS_GUI\Gadget()\Type	=	#C2D_Type_MenuButton	And	Paper	&	$00FFFFFF	=	RS_GUI\Gadget()\BackColor	&	$00FFFFFF
		ProcedureReturn	Paper
	EndIf

	CompilerIf	1
		Pen	=	(Paper & $FF) + (Paper >> 8 & $FF) + (Paper >> 16 & $FF)	; BGR
		Pen	*	0.3333																	; faster than / 3
		ProcedureReturn	(($FF000000 & Paper) | Pen << 16 | Pen << 8 | Pen)		; Alpha | Gray
	CompilerElse
		Protected	b.a	=	Paper			&	$FF
		Protected	g.a	=	Paper	>>	8	&	$FF
		Protected	r.a	=	Paper	>>	16	&	$FF
		Pen	=	Sqr(0.23 * r * r + 0.70 * g * g + 0.07 * b * b)	; Photoshop
		ProcedureReturn	(($FF000000 & Paper) | Pen << 16 | Pen << 8 | Pen)		; Alpha | Gray
	CompilerEndIf

EndProcedure
Procedure	Gui_DrawFrame(Mode, Flags=0)

	; draw border or nothing
	; Mode -> Frame[Mode]
	; Flags -> Clicked, Toggled
	; s. also DrawFrame()

	If	Mode	=	#Gui_FrameNone	:	ProcedureReturn	:	EndIf

	Protected	w	=	OutputWidth()
	Protected	h	=	OutputHeight()

	Protected	a.l	=	RS_GUI\FrameAlpha	|	#White
	Protected	b.l	=	RS_GUI\FrameAlpha	|	#Black

	If	Flags	:	Swap	a,b	:	EndIf	; Clicked, Toggled?

	DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)

	Select	Mode

		Case	#Gui_Frame3D, #Gui_FrameSunken

			If	Mode	=	#Gui_FrameSunken	:	Swap	a,b	:	EndIf	; Invert 3D?

			w	-	1
			h	-	1

			FrontColor(a)	:	LineXY(0, 0, w,   0)	:	LineXY(0, 1, 0, h)
			FrontColor(b)	:	LineXY(0, h, w-1, h)	:	LineXY(w, 0, w, h)

		Case	#Gui_FrameFine

			Swap	a,b

			w	-	1
			h	-	1

			FrontColor(a)	:	LineXY(0, 0, w,   0)	:	LineXY(0, 0, 0, h)
			FrontColor(b)	:	LineXY(0, h, w-1, h)	:	LineXY(w, 0, w, h)

			Swap	a,b

			w	-	1
			h	-	1

			FrontColor(a)	:	LineXY(1, 1, w,   1)	:	LineXY(1, 1, 1, h)
			FrontColor(b)	:	LineXY(1, h, w-1, h)	:	LineXY(w, 1, w, h)

		Case	#Gui_FrameFlat

			Box(0, 0, w, h, b)

		Case	#Gui_FrameLite

			Box(0, 0, w, h, a)

		Case	#Gui_FrameRised

			Box(0, 0, w-1, h-1, a)
			Box(1, 1, w-1, h-1, b)

		Case	#Gui_FrameBar

			Box(0, 0, w, h, b)
			Box(1, 1, w - 2, h - 2, a)

	EndSelect

EndProcedure
Procedure	Gui_DrawGadget(Flags)	; *** Main Gadgets-Drawings ***

	Protected	t$, i, h, w, x, y

	With	RS_GUI\Gadget()
		If	IsGadget(\ID)	And
		  	StartDrawing(CanvasOutput(\ID))
			DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
			Box(0, 0, \w, \h, \BackColor)
			FrontColor(\Color)

			If	\Text$
				DrawingFont(\hFont)
				If	\IsToggled
					t$	=	\Toggle$
				Else
					t$	=	\Text$
				EndIf
; 				w	=	TextWidth(t$)
; 				h	=	TextHeight(t$)
			EndIf

			; *** Draw the content in canvas ***
			Select	\Type
				Case	#PB_GadgetType_Button
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetButton

						w	=	TextWidth(t$)

						If	\Flags	&	#Gui_FlagVertical
							x	=	\OffsetText\x	+	(\w	-	w)	>>	1
						Else
							x	=	\tx
						EndIf
						;x	=	\OffsetText\x	+	(\w	-	w)	>>	1

						Gui_DrawCopper()	; no if/endif -> checked in copperproc

						Select	Flags

							Case	#Gui_DrawDefault
								If	\Image	:	DrawAlphaImage(ImageID(\Image), \ix, \iy, $BF)	:	EndIf
								If	t$
									If	\ShadowColor
										DrawText(x + \OffsetShadow\x, \ty + \OffsetShadow\y, t$, \ShadowColor)
									EndIf
									DrawText(x, \ty, t$)
								EndIf
								Gui_DrawFrame(\FrameMode)	; border?

							Case	#Gui_DrawHover
								If	\BackColor	&	$FFFFFF	=	$FFFFFF
									Box(0, 0, \w, \h, $18000000)
								Else
									Box(0, 0, \w, \h, $3AFFFFFF)
								EndIf
								If	\Image	:	DrawAlphaImage(ImageID(\Image), \ix, \iy)	:	EndIf
								If	t$
									If	\ShadowColor
										DrawText(x + \OffsetShadow\x, \ty + \OffsetShadow\y, t$, \ShadowColor)
									EndIf
									DrawText(x, \ty, t$)
								EndIf
								Gui_DrawFrame(\FrameMode)

							Case	#Gui_DrawPush
								Box(0, 0, \w, \h, $18000000)
								If	\Image	:	DrawAlphaImage(ImageID(\Image), \ix+1, \iy+1)	:	EndIf
								If	t$	:	DrawText(x+1, \ty+1, t$)	:	EndIf
								Gui_DrawFrame(\FrameMode, 1)	; clicked

							Case	#Gui_DrawToggle
								If	\ToggleColor
									Box(0, 0, \w, \h, \ToggleColor)
								Else
									Box(0, 0, \w, \h, $18000000)
								EndIf
								If	\Image	:	DrawAlphaImage(ImageID(\Image), \ix, \iy)	:	EndIf
								If	t$
									If	\ShadowColor
										DrawText(x + \OffsetShadow\x, \ty + \OffsetShadow\y, t$, \ShadowColor)
									EndIf
									DrawText(x, \ty, t$)
								EndIf
								Gui_DrawFrame(\FrameMode, 1)	; toggled

							Case	#Gui_DrawDisable
								Box(0, 0, \w, \h, #Gui_DefGrayColor)
								If	\Image
									DrawAlphaImage(ImageID(\Image), \ix, \iy)
									DrawingMode(#PB_2DDrawing_CustomFilter)
									CustomFilterCallback(@Gui_DrawDisable())	; grayed
									Box(0, 0, \w, \h)
									DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
								EndIf
								If	t$
									DrawText(x+1,	\ty+1,t$, $80FFFFFF)
									DrawText(x,		\ty,	t$, $80000000)
								EndIf
								Gui_DrawFrame(\FrameMode)

						EndSelect

					CompilerEndIf

				Case	#PB_GadgetType_Container
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetContainer
						Gui_DrawCopper()
						Gui_DrawFrame(\FrameMode)
					CompilerEndIf

				Case	#PB_GadgetType_Image
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetImage
						If	\Flags	>	#Null
							w	=	\w	/	(\Flags<<1)
							h	=	\h	/	\Flags
							FrontColor(\Color)
							For	y	=	0	To	h
								For	x	=	0	To	w
									Box((x * \Flags << 1) + i * \Flags, y * \Flags, \Flags, \Flags)
								Next
								i!1
							Next
						EndIf
						DrawAlphaImage(ImageID(\Image), \ix, \iy)
					CompilerEndIf

				Case	#PB_GadgetType_ProgressBar
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetProgress

						If	\State	>	0
							If	\Flags	&	#Gui_FlagVertical
								w	=	\Clip\h	-	(\Clip\h	/	\Max)	*	\State
								Box(\Clip\x, \Clip\y	+	w, \Clip\w, \Clip\h - w)
								Gui_DrawCopper(\Clip\x, \Clip\y	+	w, \Clip\w, \Clip\h - w)
								If	\SubFrame	;\Flags	&	#Gui_Frame	; draw frame?
									GuiDrawFrame(\SubFrame, \Clip\x, \Clip\y	+	w, \Clip\w, \Clip\h - w)
								EndIf
							Else
								w	=	(\Clip\w	/	\Max)	*	\State
								Box(\Clip\x, \Clip\y, w, \Clip\h)
								Gui_DrawCopper(\Clip\x, \Clip\y, w, \Clip\h)
								If	\SubFrame	;\Flags	&	#Gui_Frame	; draw frame?
									GuiDrawFrame(\SubFrame, \Clip\x, \Clip\y, w, \Clip\h)
								EndIf
							EndIf
						EndIf

						Gui_DrawFrame(\FrameMode)

					CompilerEndIf

				Case	#PB_GadgetType_String
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
						Select	Flags
							Case	#Gui_DrawDefault
								If	\IsDisabled	=	0
									SetGadgetColor(\SubGadget0, #PB_Gadget_FrontColor, \Color & $00FFFFFF)
								EndIf
							Case	#Gui_DrawDisable
								Box(0, 0, \w, \h, #Gui_DefGrayColor)
								SetGadgetColor(\SubGadget0, #PB_Gadget_BackColor,	#Gui_DefGrayColor & $00FFFFFF)
								SetGadgetColor(\SubGadget0, #PB_Gadget_FrontColor,	$00808080)
						EndSelect
						SetGadgetText(\SubGadget0, \Text$)
						SendMessage_(GadgetID(\SubGadget0),	#EM_SETSEL, -2, -1)	; cursor/scroll to end
						Gui_DrawFrame(\FrameMode)
					CompilerEndIf

				Case	#PB_GadgetType_Text
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetText

						w	=	TextWidth(t$)
						h	=	TextHeight(t$)

						If	\Flags	&	#Gui_FlagCenter
							x	=	(\w	-	w)	>> 1
						ElseIf	\Flags	&	#Gui_FlagRight
							x	=	\w	-	(w	+	\OffsetText\x)	-	\FrameSize
						Else
							x	=	\OffsetText\x	+	\FrameSize
						EndIf

						y	=	\OffsetText\y + (\h - h) >> 1

						Gui_DrawCopper()

						If	\ShadowColor
							DrawText(x + \OffsetShadow\x, y + \OffsetShadow\y, t$, \ShadowColor)
						EndIf

						DrawText(x, y, t$)

						Gui_DrawFrame(\FrameMode)

					CompilerEndIf

				Case	#PB_GadgetType_TrackBar
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack

						Select	Flags
							Case	#Gui_DrawDefault
								If	\State	>=	0

									If	\Flags	&	#Gui_FlagVertical

										If	\State	>=	\Max
											\Bar\y	=	\FrameSize
										ElseIf	\State	<=	\Min
											\Bar\y	=	\h	-	(\Bar\h	+	\FrameSize)
										Else
											\Bar\y	=	(\h	-	(\Range\h	/	\Max)	*	\State)	-	\Bar\h	*	1.5
											\Bar\y	=	GuiRange(\Bar\y + 1, \FrameSize - \Bar\h * 0.5, \Range\h)
											\Bar\y	+	\Bar\h	*	0.5
										EndIf

										Box(\Bar\x, \Bar\y, \Bar\w, \Bar\h)
										Gui_DrawCopper(\Clip\x, \Bar\y, \Clip\w, \Bar\h)

									Else	; Horizontal

										If	\State	>=	\Max
											\Bar\x	=	\w	-	(\Bar\w	+	\FrameSize)
										ElseIf	\State	<=	\Min
											\Bar\x	=	\FrameSize
										Else
											\Bar\x	=	(\Range\w	/	\Max)	*	\State	-	\Bar\w	*	0.5
											\Bar\x	=	GuiRange(\Bar\x, \FrameSize - \Bar\w * 0.5, \Range\w)
											\Bar\x	+	\Bar\w	*	0.5
										EndIf

										Box(\Bar\x, \Bar\y, \Bar\w, \Bar\h)
										Gui_DrawCopper(\Bar\x, \Clip\y, \Bar\w, \Clip\h)

									EndIf

									; text on bar?
									If	\Flags	&	(#Gui_FlagPercent | #Gui_FlagLevel | #Gui_FlagNumber)

										If	\Flags	&	#Gui_FlagPercent	; 0 - 100%
											\Text$	=	Str(Int(100.0 / \Max * \State))

										ElseIf	\Flags	&	#Gui_FlagLevel	; -100..0..+100
											w	=	200 / \Max * \State - 100
											\Text$	=	Str(w)
											If	w	>	0
												\Text$	=	"+"	+	\Text$
											EndIf

										ElseIf	\State	<	\Min	; Number
											\Text$	=	Str(\Min)
										Else
											\Text$	=	Str(\State)
										EndIf

										\tx	=	\Bar\x	+	(\Bar\w	-	TextWidth(\Text$))	*	0.5
										\ty	=	\Bar\y	+	(\Bar\h	-	TextHeight(\Text$))	*	0.5

										DrawingMode(#PB_2DDrawing_Transparent)
										DrawText(\tx, \OffsetText\y + \ty, \Text$, #Black)	; notice the offset

									EndIf

									; frame on bar?
									If	\SubFrame	;\Flags	&	#Gui_Frame	; draw frame?
										GuiDrawFrame(\SubFrame, \Bar\x, \Bar\y, \Bar\w, \Bar\h)	;, RS_GUI\FrameAlpha)
									EndIf

								EndIf

							Case	#Gui_DrawDisable

								Box(0, 0, \w, \h, #Gui_DefGrayColor)
								Box(\Bar\x, \Bar\y, \Bar\w, \Bar\h, #Gui_DefGrayColor - $00101010)

								If	\Flags	&	(#Gui_FlagPercent | #Gui_FlagLevel | #Gui_FlagNumber)
									DrawText(\tx+1,\ty+1,t$, $80FFFFFF)
									DrawText(\tx,	\ty,	t$, $80000000)
								EndIf

						EndSelect

						Gui_DrawFrame(\FrameMode)

					CompilerEndIf

				Case	#C2D_Type_DrawText	; PseudoType
					CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawText
						GuiDrawText(0, 0, t$, \Color, \Flags)
						Gui_DrawFrame(\FrameMode)
					CompilerEndIf

				Case	#C2D_Type_DrawButton, #C2D_Type_MenuButton	; PseudoTypes
					CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetDrawButton|#Gui_MenuPopup)

						;Gui_DrawCopper()	; no if/endif -> checked in copperproc

						Select	Flags

							Case	#Gui_DrawDefault
								GuiDrawText(0, 0, t$, \Color, \Flags)
								Gui_DrawFrame(\FrameMode)

							Case	#Gui_DrawHover
								If	\BackColor	&	$FFFFFF	=	$FFFFFF
									Box(0, 0, \w, \h, $18000000)
								Else
									Box(0, 0, \w, \h, $3AFFFFFF)
								EndIf
								GuiDrawText(0, 0, t$, \Color, \Flags)
								;Box(0, 0, \w, \h, $3AFFFFFF)
								Gui_DrawFrame(\FrameMode)

							Case	#Gui_DrawPush
								If	\IsToggled	And	\ToggleColor
									Box(0, 0, \w, \h, \ToggleColor)
								EndIf
								Box(0, 0, \w, \h, $18000000)
								GuiDrawText(1, 1, t$, \Color, \Flags)
								Gui_DrawFrame(\FrameMode, 1)

							Case	#Gui_DrawToggle
								If	\ToggleColor
									Box(0, 0, \w, \h, \ToggleColor)
								Else
									Box(0, 0, \w, \h, $18000000)
								EndIf
								GuiDrawText(0, 0, t$, \Color, \Flags)
								Gui_DrawFrame(\FrameMode, 1)

							Case	#Gui_DrawDisable
								If	\Type	=	#C2D_Type_DrawButton
									Box(0, 0, \w, \h, #Gui_DefGrayColor)
								EndIf
								If	FindString(t$, "{")	And	FindString(t$, "}")
									t$	=	ReplaceString(t$, "{"+#DTC_COLORFRONT$,	"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_COLORBACK$,		"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_PALETTEFRONT$,	"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_PALETTEBACK$,	"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_SHADOW$,			"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_STROKE$,			"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_BOLD$,			"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_INVERSE$,		"{"+#DTC_NIL$)
									t$	=	ReplaceString(t$, "{"+#DTC_DRAWMODE$,		"{"+#DTC_NIL$)
								EndIf
								GuiDrawText(1, 1,	t$, $80EBEBEB, \Flags)
								GuiDrawText(0, 0,	t$, $80686868, \Flags)
								DrawingMode(#PB_2DDrawing_CustomFilter)
								CustomFilterCallback(@Gui_DrawDisable())
								Box(0, 0, \w, \h)	; grayed
								DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)	; default if FrameNone
								Gui_DrawFrame(\FrameMode)

						EndSelect

					CompilerEndIf
			EndSelect

			StopDrawing()

		EndIf
	EndWith

EndProcedure

Procedure	Gui_Click()

	With	RS_GUI\Gadget()

		Protected	x	=	\x	+	GetGadgetAttribute(\ID, #PB_Canvas_MouseX)
		Protected	y	=	\y	+	GetGadgetAttribute(\ID, #PB_Canvas_MouseY)

		If	x >= \x	And	x <= (\x + \w)	And	y >= \y	And	y <= (\y + \h)
			ProcedureReturn	#True
		EndIf

	EndWith

EndProcedure
Procedure	Gui_ImageInfo(*Image.Integer, *iw.Integer, *ih.integer)

	; Set ImageID(Image) & get width & height of image/icon

	; return <> 0 -> OK / 0 -> ERROR!

	Static	ICONINFO.ICONINFO

	If	*Image\i	<	#Null	:	*Image\i	=	#Null	:	ProcedureReturn	:	EndIf

	If	IsImage(*Image\i)

		; Purebasic #Image?

		*iw\i		=	ImageWidth(*Image\i)
		*ih\i		=	ImageHeight(*Image\i)
		*Image\i	=	ImageID(*Image\i)

	ElseIf	*Image\i	>	$FFFF	And	GetIconInfo_(*Image\i, @ICONINFO)

		; Windows hIcon?

		With	ICONINFO
			*iw\i	=	\xHotspot	*	2
			*ih\i	=	\yHotspot	*	2
			If	\hbmColor	:	DeleteObject_(\hbmColor)	:	EndIf
			If	\hbmMask		:	DeleteObject_(\hbmMask)		:	EndIf
		EndWith

	Else

		; No image!

		*Image\i	=	#Null

	EndIf

	ProcedureReturn	*Image\i

EndProcedure

;- *** COMMANDS ***
Procedure	IsGuiGadget(ID)

	If	ID	>=	0	And	ID	<=	#MAX_ID

		ID	=	ID_GUI\ID[ID]

		If	ID
			ChangeCurrentElement(RS_GUI\Gadget(), ID)
			ProcedureReturn	ID
		EndIf

	EndIf

EndProcedure
Procedure	GuiColor(Front.l, Back.l=#PB_Ignore)

	; Set default color for following gadgets

	With	RS_GUI
		If	Front	<>	#PB_Ignore	:	\Color		=	$FF000000|Front	:	EndIf
		If	Back	<>	#PB_Ignore	:	\BackColor	=	$FF000000|Back		:	EndIf
	EndWith

EndProcedure
Procedure	GuiCopper(*Memory=0, Mode=#PB_Ignore)

	; Mode = 1 Horizontal, 2 = Elliptical, Default = Vertical

	RS_GUI\CopperPtr	=	*Memory

	If	Mode	<>	#PB_Ignore
		RS_GUI\CopperMode	=	Mode
	EndIf

EndProcedure
Procedure	GuiDisable(ID, State)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	State	=	Bool(State)

	With	RS_GUI\Gadget()

		If	\IsDisabled	=	State	:	ProcedureReturn	:	EndIf	; already stated

		\IsDisabled	=	State

		Select	\Type

			Case	#PB_GadgetType_Button, #C2D_Type_DrawButton, #C2D_Type_MenuButton
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetButton|#Gui_GadgetDrawButton|#Gui_MenuPopup)
					If	\IsDisabled
						State	=	\IsToggled	:	\IsToggled	=	0	; better look
						Gui_DrawGadget(#Gui_DrawDisable)
						\IsToggled	=	State
					Else
						If	\IsToggled
							Gui_DrawGadget(#Gui_DrawToggle)
						Else
							Gui_DrawGadget(#Gui_DrawDefault)
						EndIf
					EndIf
				CompilerEndIf

			Case	#PB_GadgetType_String
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
					If	\IsDisabled
						Gui_DrawGadget(#Gui_DrawDisable)
					Else
						SetGadgetColor(\SubGadget0, #PB_Gadget_BackColor, \BackColor	&	$00FFFFFF)
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

			Case	#PB_GadgetType_TrackBar
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack
					If	\IsDisabled
						Gui_DrawGadget(#Gui_DrawDisable)
					Else
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

		EndSelect

		DisableGadget(\ID, \IsDisabled)

	EndWith

EndProcedure
Procedure	GuiDisableRegion(Window, State, x1, y1, x2, y2)

	With	RS_WG
		\x1		=	x1
		\y1		=	y1
		\x2		=	x2
		\y2		=	y2
		\State	=	State
	EndWith

	EnumChildWindows_(WindowID(Window),@GuiProc_WindowGadget(), #C2D_WG_DISABLE)

EndProcedure
Procedure	GuiEvent(ID)	;- *** Event

	; Return:	-1 = no action, #Gadget (ID) = gadget pressed

	Static	Event

	If	IsGuiGadget(ID)	<=	0	Or	Event	=	EventType()
		ProcedureReturn	-1
	EndIf

	Event	=	EventType()
	ID		=	-1

	With	RS_GUI\Gadget()
		Select	\Type

			Case	#PB_GadgetType_Button, #C2D_Type_DrawButton, #C2D_Type_MenuButton
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetButton|#Gui_GadgetDrawButton|#Gui_MenuPopup)

					Select	Event

						Case	#PB_EventType_MouseEnter, #PB_EventType_MouseMove
							If	GetGadgetAttribute(\ID, #PB_Canvas_Buttons)	&	#PB_Canvas_LeftButton
								ID	=	#Gui_DrawPush	; click
							Else
								If	\IsToggled
									ID	=	#Gui_DrawToggle
								Else
									ID	=	#Gui_DrawHover	; move
								EndIf
							EndIf

						Case	#PB_EventType_LeftButtonDown
							ID	=	#Gui_DrawPush		; click

						Case	#PB_EventType_LeftButtonUp
							If	Gui_Click()
								If	\Flags
									GuiSetState(\ID, Bool(\IsToggled=0))
								EndIf
								If	\IsToggled
									ID	=	#Gui_DrawToggle	; on/off
								Else
									ID	=	#Gui_DrawHover	; move
								EndIf
								Gui_DrawGadget(ID)
								ProcedureReturn	\ID	; gadget choosed
							EndIf

						Default	; #PB_EventType_MouseLeave
							If	RS_GUI\Gadget()\IsDisabled	=	0	; Important Disable-Check!
								If	\IsToggled
									ID	=	#Gui_DrawToggle	; toggled
								Else
									ID	=	#Gui_DrawDefault	; default
								EndIf
							EndIf

					EndSelect

					; update canvas
					Gui_DrawGadget(ID)

				CompilerEndIf

			Case	#PB_GadgetType_TrackBar
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack
					Select	Event
						Case	#PB_EventType_MouseMove;, #PB_EventType_MouseEnter
							If	GetGadgetAttribute(\ID, #PB_Canvas_Buttons)	&	#PB_Canvas_LeftButton
								If	\Flags	&	#Gui_FlagVertical
									GuiSetState(\ID, (\h	-	GetGadgetAttribute(\ID, #PB_Canvas_MouseY) - \Bar\h	*	0.5)	/	(\Range\h	/	\Max))
								Else
									GuiSetState(\ID, (GetGadgetAttribute(\ID, #PB_Canvas_MouseX) - \Bar\w	*	0.5)	/	(\Range\w	/	\Max))
								EndIf
								Event	=	0	; must for loop
								Gui_DrawGadget(#Gui_DrawDefault)
								ProcedureReturn	\ID
							EndIf
						Case	#PB_EventType_LeftButtonDown	; click
							If	\Flags	&	#Gui_FlagVertical
								ID	=	\h	-	GetGadgetAttribute(\ID, #PB_Canvas_MouseY)
								If	ID	<=	\Bar\h	*	0.5
									GuiSetState(\ID, 0)
								Else
									GuiSetState(\ID, (ID - \Bar\h	*	0.5)	/	(\Range\h	/	\Max))
								EndIf
							Else
								ID	=	GetGadgetAttribute(\ID, #PB_Canvas_MouseX)
								If	ID	<=	\Bar\w	*	0.5
									GuiSetState(\ID, 0)
								Else
									GuiSetState(\ID, (ID - \Bar\w	*	0.5)	/	(\Range\w	/	\Max))
								EndIf
							EndIf
							Gui_DrawGadget(#Gui_DrawDefault)
							ProcedureReturn	\ID
					EndSelect
				CompilerEndIf

			Case	#PB_GadgetType_ProgressBar
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetProgress
					ProcedureReturn	\ID
				CompilerEndIf

		EndSelect
	EndWith

	ProcedureReturn	-1	; do nothing

EndProcedure
Procedure	GuiFrame(Mode, Alpha=0)

	With	RS_GUI

		\FrameMode	=	Mode

		Select	Mode
			Case	#Gui_Frame3D,
			    	#Gui_FrameFlat,
			    	#Gui_FrameLite,
			    	#Gui_FrameSunken
				\FrameSize	=	1
			Case	#Gui_FrameFine,
			    	#Gui_FrameRised,
			    	#Gui_FrameBar
				\FrameSize	=	2
			Default
				\FrameSize	=	0
		EndSelect

		If	Alpha	>	0
			\FrameAlpha	=	Alpha	<<	24
		EndIf

	EndWith

EndProcedure
Procedure	GuiFree(ID, Window=#PB_All)

	If	ID	<=	#PB_All

		If	Window	>=	#Null	And	IsWindow(Window)

			; Free all gadgets in #window only!
			EnumChildWindows_(WindowID(Window), @GuiProc_WindowGadget(), #C2D_WG_FREE)

		Else	; Window = #PB_All -> Frees Font, Menu, Palette

			GuiFontFree(#PB_All)
			GuiPaletteFree()

			CompilerIf	#IsC2D_Gui	&	#Gui_MenuPopup
				GuiMenuFree(#PB_All)
			CompilerEndIf

			ForEach	RS_GUI\Gadget()
				With	RS_GUI\Gadget()
					If	\Image	And	IsImage(\Image):	FreeImage(\Image)	:	EndIf
					If	IsGadget(\ID)	:	FreeGadget(\ID)	:	EndIf
				EndWith
			Next

			ClearList(RS_GUI\Gadget())

		EndIf

	Else

		If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget!

		With	RS_GUI\Gadget()
			If	\Image		And	IsImage(\Image):	FreeImage(\Image)	:	EndIf
			If	IsGadget(\ID)	:	FreeGadget(\ID)	:	EndIf
		EndWith

		DeleteElement(RS_GUI\Gadget())

		ID_GUI\ID[ID]	=	#Null

	EndIf

EndProcedure
Procedure	GuiGadget(ID)

	; Return: #GadgetNumber

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()
		Select	\Type
			Case	#PB_GadgetType_String
				ID	=	\SubGadget0
			Default
				ID	=	\ID
		EndSelect

		ProcedureReturn	ID

	EndWith

EndProcedure
Procedure	GuiGadgetColor(ID, Front.l, Back.l)

	; Re-Colorize- & redraw gadget (no redraw if disabled)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf

	With	RS_GUI\Gadget()

		If	Front	<>	#PB_Ignore	:	\Color		=	$FF000000|Front	:	EndIf
		If	Back	<>	#PB_Ignore	:	\BackColor	=	$FF000000|Back		:	EndIf

		\ToggleColor	=	RS_GUI\ToggleColor

		If	\IsDisabled	=	0
			If	\IsToggled
				Gui_DrawGadget(#Gui_DrawToggle)
			Else
				Select	\Type
					Case	#PB_GadgetType_String
						CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
							SetGadgetColor(\SubGadget0, #PB_Gadget_FrontColor,	\Color		& $00FFFFFF)
							SetGadgetColor(\SubGadget0, #PB_Gadget_BackColor,	\BackColor	& $00FFFFFF)
						CompilerEndIf
				EndSelect
				Gui_DrawGadget(#Gui_DrawDefault)
			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	GuiGadgetID(ID)

	; Return: hGadget

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()

		Select	\Type
			Case	#PB_GadgetType_String
				ID	=	\SubGadget0
			Default
				ID	=	\ID
		EndSelect

		ProcedureReturn	GadgetID(ID)

	EndWith

EndProcedure
Procedure.q	GuiGetData(ID)

	; Get private user-value of gadget

	Protected	Value.q

	PushListPosition(RS_GUI\Gadget())
	If	IsGuiGadget(ID)
		Value.q	=	RS_GUI\Gadget()\Value
	EndIf
	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	Value

EndProcedure
Procedure	GuiGetState(ID)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()
		Select	\Type

			Case	#PB_GadgetType_Button, #C2D_Type_DrawButton
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetButton|#Gui_GadgetDrawButton)
					ProcedureReturn	\IsToggled
				CompilerEndIf

			Case	#PB_GadgetType_ProgressBar
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetProgress
					ProcedureReturn	\State
				CompilerEndIf

			Case	#PB_GadgetType_TrackBar
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack
					If	\State	<	\Min
						ProcedureReturn	\Min
					EndIf
					ProcedureReturn	\State
				CompilerEndIf

		EndSelect
	EndWith

EndProcedure
Procedure$	GuiGetText(ID, Flags=0)

	; Flags	=	0	->	return text only
	;			=	1	->	return text with {code,param}

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	#Null$	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()

		Select	\Type

			Case	#PB_GadgetType_String
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
					\Text$	=	GetGadgetText(\SubGadget0)	; Important: actual textstring
				CompilerEndIf

			Case	#C2D_Type_DrawButton, #C2D_Type_DrawText
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetDrawButton|#Gui_GadgetDrawText)
					If	Flags	=	0	; text only? (no code/param)
						ProcedureReturn	GuiDrawTextRaw(\Text$)
					EndIf
				CompilerEndIf

		EndSelect

		ProcedureReturn	\Text$

	EndWith

EndProcedure
Procedure	GuiInit()

	GuiFontSet(#PB_Default)
	GuiColor(#Gui_DefColor, #Gui_DefBackColor)
	GuiFrame(#Gui_FrameNone, $60)
	GuiTab(3)

EndProcedure
Procedure	GuiIsDisabled(ID)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	ProcedureReturn	RS_GUI\Gadget()\IsDisabled

EndProcedure
Procedure	GuiLine(x, y, Length, Alpha=#PB_Default, Flags=#PB_Default)

	; return #Gadget

	Static	a = $7F, f

	If	Alpha	>	0	:	a	=	Alpha	:	EndIf
	If	Flags	>=	0	:	f	=	Flags	:	EndIf

	Protected	ID, w, h
	Protected	c0.l	=	a	<<	24	|	#Black
	Protected	c1.l	=	a	<<	24	|	#White

	If	f	&	#Gui_FlagVertical
		w	=	2	:	h	=	Length
	Else
		h	=	2	:	w	=	Length
	EndIf

	If	f	&	#Gui_FlagToggle
		Swap	c0, c1
	EndIf

	ID	=	CanvasGadget(#PB_Any, RS_GUI\OffsetGadget\x + x, RS_GUI\OffsetGadget\y + y, w, h)

	StartDrawing(CanvasOutput(ID))
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	Box(0, 0, w, h, RS_GUI\BackColor)
	If	f	&	#Gui_FlagVertical
		LineXY(0, 0, 0, h, c0)
		LineXY(1, 0, 1, h, c1)
	Else
		LineXY(0, 0, w, 0, c0)
		LineXY(0, 1, w, 1, c1)
	EndIf
	StopDrawing()

	DisableGadget(ID, #True)

	ProcedureReturn	ID

EndProcedure
Procedure	GuiRefresh(ID)

	Protected	Flags

	With	RS_GUI\Gadget()
		If	ID	<=	#PB_All

			ForEach	RS_GUI\Gadget()

				If	\Type	=	#PB_GadgetType_Container	Or	\Type	=	#C2D_Type_DrawText	:	Continue	:	EndIf

				If	\IsDisabled
					Flags	=	#Gui_DrawDisable
				ElseIf	\IsToggled
					Flags	=	#Gui_DrawToggle
				Else
					Flags	=	#Gui_DrawDefault
				EndIf

				Gui_DrawGadget(Flags)

			Next

		ElseIf	IsGuiGadget(ID)

			If	\IsDisabled
				Flags	=	#Gui_DrawDisable
			ElseIf	\IsToggled
				Flags	=	#Gui_DrawToggle
			Else
				Flags	=	#Gui_DrawDefault
			EndIf

			Gui_DrawGadget(Flags)

		EndIf
	EndWith

EndProcedure
Procedure	GuiSetData(ID, Value.q)

	; Set private user-value to gadget

	PushListPosition(RS_GUI\Gadget())
	If	IsGuiGadget(ID)
		RS_GUI\Gadget()\Value	=	Value
	EndIf
	PopListPosition(RS_GUI\Gadget())

EndProcedure
Procedure	GuiSetFrame(ID, Mode)

	If	ID	<=	#PB_All
		With	RS_GUI
			PushListPosition(\Gadget())
			ForEach	\Gadget()
				If	\Gadget()\FrameMode
					\Gadget()\FrameMode	=	Mode
				EndIf
			Next
			PopListPosition(\Gadget())
		EndWith
	ElseIf	IsGuiGadget(ID)
		RS_GUI\Gadget()\FrameMode	=	Mode
	EndIf

	GuiRefresh(ID)

EndProcedure
Procedure	GuiSetState(ID, State)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()
		Select	\Type

			Case	#PB_GadgetType_Button, #C2D_Type_DrawButton
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetButton|#Gui_GadgetDrawButton)
					If	\Flags	&	#Gui_FlagToggle	And	\IsDisabled	=	0	; Toggle and not disabled?

						\IsToggled	=	Bool(State)

						If	\IsToggled
							Gui_DrawGadget(#Gui_DrawToggle)
						Else
							Gui_DrawGadget(#Gui_DrawDefault)
						EndIf

						GuiRefresh(ID)

					EndIf
				CompilerEndIf

			Case	#PB_GadgetType_ProgressBar, #PB_GadgetType_TrackBar
				CompilerIf	#IsC2D_Gui	&	(#Gui_GadgetProgress|#Gui_GadgetTrack)
					If	\State	<>	State
						\State	=	GuiRange(State, 0, \Max)	; min=0 / max=\max
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

		EndSelect
	EndWith

EndProcedure
Procedure	GuiSetText(ID, t$, Color.l=#PB_Default)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	Protected	hDC, txt.SIZE

	With	RS_GUI\Gadget()

		\Text$	=	t$

		If	Color	<>	#PB_Default	:	\Color	=	$FF000000 | Color	:	EndIf

		Select	\Type

			Case	#PB_GadgetType_Button
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetButton
					If	\IsToggled
						Gui_DrawGadget(#Gui_DrawToggle)
					Else
						If	\Flags	&	#Gui_FlagCenter
							hDC	=	CreateCompatibleDC_(0)
							SelectObject_(hDC, \hFont)
							GetTextExtentPoint32_(hDC, @t$, Len(t$), @txt)
							\tx	=	\OffsetText\x	+	(\w	-	txt\cx)	>>	1
							DeleteDC_(hDC)
						EndIf
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

			Case	#PB_GadgetType_String
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
					If	\IsDisabled
						Gui_DrawGadget(#Gui_DrawDisable)
					Else
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

			Case	#PB_GadgetType_Text
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetText
					Gui_DrawGadget(#Gui_DrawDefault)
				CompilerEndIf

			Case	#C2D_Type_DrawText
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawText
					Gui_DrawGadget(#Gui_DrawDefault)
				CompilerEndIf

			Case	#C2D_Type_DrawButton
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawButton
					If	\IsToggled
						Gui_DrawGadget(#Gui_DrawToggle)
					Else
						Gui_DrawGadget(#Gui_DrawDefault)
					EndIf
				CompilerEndIf

		EndSelect
	EndWith

EndProcedure
Procedure	GuiSetToggleText(ID, t$)

	If	IsGuiGadget(ID)	=	0	:	ProcedureReturn	:	EndIf	; no c2d_gadget

	With	RS_GUI\Gadget()

		\Toggle$	=	t$

		Select	\Type
			Case	#PB_GadgetType_Button
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetButton
					If	\IsToggled	:	Gui_DrawGadget(#Gui_DrawToggle)	:	EndIf
				CompilerEndIf
			Case	#C2D_Type_DrawButton
				CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawButton
					If	\IsToggled	:	Gui_DrawGadget(#Gui_DrawToggle)	:	EndIf
				CompilerEndIf
		EndSelect

	EndWith

EndProcedure
Procedure	GuiShadow(Color.l, x=1, y=1)

	; alpha shadow 0-255

	If	Color	>	0	And	Color	<=	$FF	:	Color	<<	24	:	EndIf

	RS_GUI\ShadowColor		=	Color
	RS_GUI\OffsetShadow\x	=	x
	RS_GUI\OffsetShadow\y	=	y

EndProcedure
Procedure	GuiToggleColor(Color.l=#Null)

	; Backcolor when toggled

	RS_GUI\ToggleColor	=	Color & $FFFFFFFF

EndProcedure
Procedure	GuiType(ID)

	; Return type of gadget

	PushListPosition(RS_GUI\Gadget())

	If	IsGuiGadget(ID)
		ID	=	RS_GUI\Gadget()\Type
	Else
		ID	=	#False
	EndIf

	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	ID

EndProcedure

;- *** DataRegister D0 - D9 ***
Procedure	GuiDregGet(ID)
	If	ID	>=	0	And	ID	<=	9
		ProcedureReturn	RS_GUI\DReg[ID]
	EndIf
EndProcedure
Procedure	GuiDregSet(ID, Param)
	If	ID	>=	0	And	ID	<=	9
		RS_GUI\DReg[ID]	=	Param
	EndIf
EndProcedure
Procedure	GuiDregVal(t$)
	
	; Return:	D0-D9 or Val(t$)
	; "{??,D#,D#,D#...}
	
	Protected	*Memory.RS_GuiDTC = @t$
	
	If	*Memory\a	=	'D'	; "D0".."D9"?
		ProcedureReturn	RS_GUI\DReg[*Memory\b - '0']	; GuiDRegGet(*Memory\b - '0')
	EndIf
	
	ProcedureReturn	Val(t$)
	
EndProcedure

;- *** MouseCursor ***
Procedure	GuiCursorInit(ID)
	RS_GUI\hCursor	=	LoadCursor_(GetModuleHandle_(#Null), ID)	; 8001
EndProcedure
Procedure	GuiCursorSet(Window)

	; Call this after createtd all gadgets in window!

	If	IsWindow(Window)	And	RS_GUI\hCursor
		Window	=	WindowID(Window)
		SetClassLongPtr_(Window, #GCL_HCURSOR, RS_GUI\hCursor)	; Window
		EnumChildWindows_(Window, @GuiProc_WindowGadget(), #C2D_WG_CURSOR)	; Gadgets
	EndIf

EndProcedure

;- *** Palette ***
Procedure	GuiPaletteFree()
	With	RS_GUI
		If	\PalettePtr
			FreeMemory(\PalettePtr)
			\PalettePtr	=	#Null
		EndIf
	EndWith
EndProcedure
Procedure	GuiPaletteInit(*Memory, Count)

	GuiPaletteFree()

	With	RS_GUI

		Count	*	SizeOf(Long)

		\PalettePtr	=	AllocateMemory(Count)

		If	*Memory	>	#Null
			CopyMemory(*Memory, \PalettePtr, Count)
		EndIf

	EndWith

EndProcedure
Procedure.l	GuiPaletteGetColor(Index, Alpha=$FF)

	Protected	*Memory.Long

	With	RS_GUI
		If	\PalettePtr
			*Memory	=	\PalettePtr	+	Index	*	SizeOf(Long)
			ProcedureReturn	($00FFFFFF	&	*Memory\l	|	($FF000000	&	Alpha	<<	24))
		EndIf
	EndWith

EndProcedure
Procedure	GuiPaletteSetColor(Index, Color.l)

	Protected	*Memory.Long

	Index	*	SizeOf(Long)

	With	RS_GUI
		If	\PalettePtr	And	Index	<	MemorySize(\PalettePtr)
			*Memory		=	\PalettePtr	+	Index
			*Memory\l	=	Color
		EndIf
	EndWith

EndProcedure
Procedure	GuiPaletteColor(FrontIndex, BackIndex=#PB_Ignore)

	; Set default palettecolor for following gadgets

	Protected	*Memory.Long

	With	RS_GUI
		If	\PalettePtr

			If	FrontIndex	>=	#Null	; #PB_Ignore = -65535
				FrontIndex	*	SizeOf(Long)
				If	FrontIndex	<	MemorySize(\PalettePtr)
					*Memory	=	\PalettePtr	+	FrontIndex
					\Color	=	$FF000000|*Memory\l
				EndIf
			EndIf

			If	BackIndex	>=	#Null
				BackIndex	*	SizeOf(Long)
				If	BackIndex	<	MemorySize(\PalettePtr)
					*Memory		=	\PalettePtr	+	BackIndex
					\BackColor	=	$FF000000|*Memory\l
				EndIf
			EndIf

		EndIf
	EndWith

EndProcedure

;- *** ImageList ***
Procedure	IsGuiImage(ID)
	ProcedureReturn	FindMapElement(RS_GuiImage(), Str(ID))
EndProcedure
Procedure	GuiImageAdd(ID, Image, Key$=#Null$)

	RS_GuiImage(Str(ID))\ID	=	Image

	With	RS_GuiImage()
		\hID	=	ImageID(Image)
		\w		=	ImageWidth(Image)
		\h		=	ImageHeight(Image)
		\Key$	=	Key$
	EndWith

EndProcedure
Procedure	GuiImageDraw(ID, x.f, y.f, Alpha=255, Flags=0)
	If	IsGuiImage(ID)
		If	Flags	&	(#C2F_CenterX|#C2F_Center)	;Or	Flags	&	#C2F_Center
			x + (OutputWidth() - RS_GuiImage()\w)	* 0.5
		EndIf
		If	Flags	&	(#C2F_CenterY|#C2F_Center)	;	Or	Flags	&	#C2F_Center
			y + (OutputHeight() - RS_GuiImage()\h)	* 0.5
		EndIf
		DrawAlphaImage(RS_GuiImage()\hID, x, y, Alpha)
	EndIf
EndProcedure
Procedure	GuiImageFree(ID=#PB_All, Flags=#False)

	If	ID	<=	#PB_All

		If	Flags
			ForEach	RS_GuiImage()
				With	RS_GuiImage()
					If	\hID	And	IsImage(\ID)
						FreeImage(\ID)
					EndIf
				EndWith
			Next
		EndIf

		ClearMap(RS_GuiImage())

	Else

		If	IsGuiImage(ID)
			If	Flags
				With	RS_GuiImage()
					If	\hID	And	IsImage(\ID)
						FreeImage(\ID)
					EndIf
				EndWith
			EndIf
			DeleteMapElement(RS_GuiImage())
		EndIf

	EndIf

EndProcedure
Procedure	GuiImageH(ID)
	If	IsGuiImage(ID)
		ProcedureReturn	RS_GuiImage()\h
	EndIf
EndProcedure
Procedure	GuiImageID(ID)
	If	IsGuiImage(ID)
		With	RS_GuiImage()
			If	\hID	And	IsImage(\ID)
				ProcedureReturn	\ID
			EndIf
		EndWith
	EndIf
EndProcedure
Procedure$	GuiImageKey(ID)
	If	IsGuiImage(ID)
		ProcedureReturn	RS_GuiImage()\Key$
	EndIf
EndProcedure
Procedure	GuiImageW(ID)
	If	IsGuiImage(ID)
		ProcedureReturn	RS_GuiImage()\w
	EndIf
EndProcedure

;- *** DrawText {##,..} ***
Procedure	GuiDrawFont(ID)
	If	IsGuiFont(ID)
		DrawingFont(RS_GUI\Font()\hFont)
	Else
		DrawingFont(GetGadgetFont(#PB_Default))
	EndIf
EndProcedure
Procedure	GuiDrawFrame(Mode, x, y, w, h, Alpha=255)

	; draw border or nothing
	; Mode -> Frame[Mode]

	If	Mode	=	#Gui_FrameNone	:	ProcedureReturn	:	EndIf

	Protected	a.l	=	Alpha	<<	24	|	#White
	Protected	b.l	=	Alpha	<<	24	|	#Black

	DrawingMode(#PB_2DDrawing_Outlined|#PB_2DDrawing_AlphaBlend)

	Select	Mode

		Case	#Gui_Frame3D, #Gui_FrameSunken

			If	Mode	=	#Gui_FrameSunken	:	Swap	a,b	:	EndIf	; Invert 3D?

			w	+	x	-	1
			h	+	y	-	1

			FrontColor(a)	:	LineXY(x, y, w,   y)	:	LineXY(x, y+1, x, h)
			FrontColor(b)	:	LineXY(x, h, w-1, h)	:	LineXY(w, y,	w, h)

		Case	#Gui_FrameFine

			Swap	a,b

			w	+	x	-	1
			h	+	y	-	1

			FrontColor(a)	:	LineXY(x, y, w,   y)	:	LineXY(x, y+1, x, h)
			FrontColor(b)	:	LineXY(x, h, w-1, h)	:	LineXY(w, y,	w, h)

			Swap	a,b

			x	+	1
			y	+	1

			w	-	1
			h	-	1

			FrontColor(a)	:	LineXY(x, y, w,   y)	:	LineXY(x, y+1, x, h)
			FrontColor(b)	:	LineXY(x, h, w-1, h)	:	LineXY(w, y,	w, h)

		Case	#Gui_FrameFlat

			Box(x, y, w, h, b)

		Case	#Gui_FrameLite

			Box(x, y, w, h, a)

		Case	#Gui_FrameRised

			Box(x,	y,		w-1, h-1, a)
			Box(x+1,	y+1,	w-1, h-1, b)

		Case	#Gui_FrameBar

			Box(x, y, w, h, b)
			Box(x+1, y+1, w-2, h-2, a)

	EndSelect

EndProcedure
Procedure	GuiDrawText(x, y, t$, Color.l=#Black, Flags=0)	; *** DrawText ***

	; Multiline DrawText()
	; Must inside StartDrawing() / StopDrawing()

	If	Len(t$)	=	#Null	:	ProcedureReturn	:	EndIf

	Protected	*Memory.Character=@t$	; <- textstring
	Protected	*hFont=GuiFontID(), IsDrawFont=-1

	Protected	a$, a, n$, n, h, w, Mode, Param, Back.l, px, py, pw, ph
	Protected	IsSHadow.q, SHadow_X, SHadow_Y
	Protected	IsSTroke, STroke_Bold
	Protected	IsUnderLine, UnderLine_X, UnderLine_Y
	Protected	IsFRame, FRame_X, FRame_Y, FRame_XOffset, FRame_YOffset
	Protected	IsEmBos, EmBos_LColor, EmBos_RColor
	Protected	IsGapX, IsGapY, IsBolD, IsInVerse
	Protected	SplitLine_Mode, SplitLine_Alpha, SplitLine_YOffset	; SplitLine
	Protected	Circle_RadX, Circle_RadY									; CIrcle

	Gui_DrawCopper()

	Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent

	Color	|	$FF000000
	Back	=	$FF000000	|	RS_GUI\BackColor

	w	=	Gui_TextAlignX(*Memory, Flags)
	h	=	TextHeight(t$)	; lineheight (no lf)
	y	+	(OutputHeight()	-	GuiDrawTextH(t$))	>>	1	;	RS_GUI\OffsetText\y

	DrawingMode(Mode)	; Default

	While	*Memory\c

		Select	*Memory\c

			Case	#LF, '|'	;{ Linefeed  / Closeup LIne, FRame }

				If	IsUnderLine
					If	IsSHadow
						Box(UnderLine_X + SHadow_X, y + h + UnderLine_Y + SHadow_Y, x + w - UnderLine_X, IsUnderLine, IsSHadow)
					EndIf
					Box(UnderLine_X, y + h + UnderLine_Y, x + w - UnderLine_X, IsUnderLine, Color)
				EndIf
				If	IsFRame
					GuiDrawFrame(IsFRame, FRame_X - FRame_XOffset, FRame_Y - FRame_YOffset, x + w - FRame_X + FRame_XOffset * 2, y + h - FRame_Y + FRame_YOffset * 2)
				EndIf

				*Memory	+	SizeOf(Character)	; skip linefeed

				y	+	h	+	IsGapY
				w	=	Gui_TextAlignX(*Memory, Flags)

				If	IsUnderLine	:	UnderLine_X	=	x	+	w	:	EndIf
				If	IsFRame		:	FRame_Y		=	y			:	EndIf

				Continue
				;}

			Case	#TAB

				pw	=	TextWidth("0")	*	RS_GUI\TabWidth	; tabwidth
				w	+	pw	-	(w	%	pw)

			Case	'{'	; <- CtrlStart {Code,Param,...}

				a$	=	#Null$

				*Memory	+	SizeOf(Character)	; Skip the '{'
				While	*Memory\c	And	*Memory\c	<>	'}'	; <- CtrlEnd
					a$	+	Chr(*Memory\c)	:	*Memory	+	SizeOf(Character)
				Wend

				; *** 1. Param ***
				Param	=	GuiDRegVal(StringField(a$, 2, ","))	; DataRegister D0 - D9 or Val(n$)

				*RS_GuiDTC	=	@a$

				; Codes
				Select	ID_WORD(*RS_GuiDTC\a,*RS_GuiDTC\b)	;Left(a$, 2)	; *** 2. Code "$$" ***
					Case	#DTC_COLORFRONT		;{ CF - ColorFront }
						Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						DrawingMode(Mode)
						Color	=	$FF000000	|	(Param	&	$FFFFFFFF)
						;}
					Case	#DTC_COLORBACK			;{ CB - ColorBack }
						If	Param	Or	StringField(a$, 2, ",")	; CB = Transparent, CB,0 = Black
							Mode	=	#PB_2DDrawing_Default
							Back	=	$FF000000	|	(Param	&	$FFFFFFFF)
						Else
							Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						EndIf
						DrawingMode(Mode)
						;}
					Case	#DTC_FONT				;{ FN - FontNumber }
						If	Param	<>	IsDrawFont
							IsDrawFont	=	Param
							GuiDrawFont(Param)
							h	=	TextHeight(t$)
						EndIf
						;}
					Case	#DTC_SHADOW				;{ SH - SHadow (x,y)}
						IsSHadow	=	Param	&	$FFFFFFFF
						If	IsSHadow	>	0
							If	IsSHadow	<=	$FF
								IsSHadow	=	(Param	&	$FF)	<<	24		; Alpha
							ElseIf	IsSHadow	&	$FF000000	=	0
								IsSHadow	|	$FF000000
							EndIf
							n$	=	StringField(a$, 3, ",")	:	If	n$	:	SHadow_X	=	GuiDRegVal(n$)	:	EndIf	; *** 3. Param for X-offset? ***
							n$	=	StringField(a$, 4, ",")	:	If	n$	:	SHadow_Y	=	GuiDRegVal(n$)	:	EndIf	; *** 4. Param for Y-offset? ***
							If	SHadow_X	=	0	:	SHadow_X	=	1			:	EndIf	; def. Shadow X
							If	SHadow_Y	=	0	:	SHadow_Y	=	SHadow_X	:	EndIf	; def. Shadow Y
						EndIf
						;}
					Case	#DTC_XGAP				;{ XG - w + XGap }
						IsGapX	=	Param
						;}
					Case	#DTC_YGAP				;{ YG - h + YGap (after lf) }
						IsGapY	=	Param
						;}
					Case	#DTC_STROKE				;{ ST - STroke-Border }
						IsSTroke		=	(Param	&	$FF)	<<	24	; Alpha
						If	IsSTroke
							STroke_Bold	=	GuiDRegVal(StringField(a$, 3, ","))	; *** 3. Param for stroke bold? ***
						EndIf
						;}
					Case	#DTC_BOLD				;{ BD - BolD }
						IsBolD	=	Param
						;}
					Case	#DTC_PALETTEFRONT		;{ PF - Palette FrontID (,alpha)}
						Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						DrawingMode(Mode)
						Color	=	GuiPaletteGetColor(Param, GuiLoop(GuiDRegVal(StringField(a$, 3, ",")), 1, $FF))
						;}
					Case	#DTC_PALETTEBACK		;{ PB - Palette BackID (,alpha)}
						If	Param	Or	StringField(a$, 2, ",")	; PB = Transparent, PB,0 = Color 0
							Mode	=	#PB_2DDrawing_Default
							Back	=	GuiPaletteGetColor(Param, GuiRange(GuiDRegVal(StringField(a$, 3, ",")), 1, $FF))
						Else
							Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						EndIf
						DrawingMode(Mode)
						;}
					Case	#DTC_PALETTECOLOR		;{ PC - Palette FrontID (,BackID)}
						Color	=	GuiPaletteGetColor(Param)
 						If	StringField(a$, 3, ",")
 							Mode	=	#PB_2DDrawing_Default
 							Back	=	GuiPaletteGetColor(GuiDRegVal(StringField(a$, 3, ",")))
 						Else
 							Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
 						EndIf
						DrawingMode(Mode)
						;}
					Case	#DTC_IMAGE				;{ IM - IMage }
						If	IsImage(Param)
							DrawImage(ImageID(Param), x + w, y + (h - ImageHeight(Param)) / 2 + GuiDRegVal(StringField(a$, 3, ",")))
							w	+	ImageWidth(Param)	+	IsGapX
						EndIf
						;}
					Case	#DTC_XOFFSET			;{ XO - XOffset - left(+) / right(-) }
						x	+	Param
						;}
					Case	#DTC_YOFFSET			;{ YO - YOffset - top(+) / bottom(-) }
						y	+	Param
						;}
					Case	#DTC_GADGETCOLOR		;{ GC - set RGB GadgetColor - need Gui_Refresh() }
						RS_GUI\Gadget()\BackColor	=	$FF000000	|	(Param	&	$FFFFFFFF)
						;}
					Case	#DTC_GADGETPALETTE	;{ GP - set Gadgetcolor from PaletteID - need Gui_Refresh() }
						RS_GUI\Gadget()\BackColor	=	GuiPaletteGetColor(Param)
						;}
					Case	#DTC_SPLITLINE			;{ SL - SplittLine, #alpha (,#mode,#yoffset) }
						If	Param	>	0	:	SplitLine_Alpha	=	(Param	&	$FF)	<<	24	:	EndIf
						n$	=	StringField(a$, 3, ",")	:	If	n$	:	SplitLine_Mode		=	GuiDRegVal(n$)	:	EndIf	; Mode (Schattierung)
						n$	=	StringField(a$, 4, ",")	:	If	n$	:	SplitLine_YOffset	=	GuiDRegVal(n$)	:	EndIf	; Y-Offset
						If	SplitLine_Mode
							LineXY(0, y + SplitLine_YOffset,		OutputWidth(), y + SplitLine_YOffset,		SplitLine_Alpha)
							LineXY(0, y + SplitLine_YOffset + 1,OutputWidth(), y + SplitLine_YOffset + 1,	SplitLine_Alpha|#White)
						Else
							LineXY(0, y + SplitLine_YOffset,		OutputWidth(), y + SplitLine_YOffset,		SplitLine_Alpha|#White)
							LineXY(0, y + SplitLine_YOffset + 1,OutputWidth(), y + SplitLine_YOffset + 1,	SplitLine_Alpha)
						EndIf
						;}
					Case	#DTC_CIRCLE				;{ CI - CIrcle, x, y, rx (,ry) }
						py				=	GuiDRegVal(StringField(a$, 3, ","))
						CIrcle_RadX	=	GuiDRegVal(StringField(a$, 4, ","))
						CIrcle_RadY	=	GuiDRegVal(StringField(a$, 5, ","))
						If	CIrcle_RadY	=	0
							CIrcle_RadY	=	CIrcle_RadX
						EndIf
						If	IsSHadow
							Ellipse(Param + SHadow_X, py + SHadow_Y, CIrcle_RadX, CIrcle_RadY, IsSHadow)
						EndIf
						Ellipse(Param, py, CIrcle_RadX, CIrcle_RadY, Color)
						;}
					Case	#DTC_BOX					;{ BX - BoX, x, y, w, h }
						py	=	GuiDRegVal(StringField(a$, 3, ","))
						pw	=	GuiDRegVal(StringField(a$, 4, ","))
						ph	=	GuiDRegVal(StringField(a$, 5, ","))
						If	IsSHadow
							Box(Param + SHadow_X, py + SHadow_Y, pw, ph, IsSHadow)
						EndIf
						Box(Param, py, pw, ph, Color)
						;}
					Case	#DTC_LINE				;{ LI - LIne, x, y, w, h }
						py	=	GuiDRegVal(StringField(a$, 3, ","))
						pw	=	GuiDRegVal(StringField(a$, 4, ","))
						ph	=	GuiDRegVal(StringField(a$, 5, ","))
						If	IsSHadow
							Line(Param + SHadow_X, py + SHadow_Y, pw, ph, IsSHadow)
						EndIf
						Line(Param, py, pw, ph, Color)
						;}
					Case	#DTC_FILL				;{ FI - FIll, x, y }
						FillArea(Param, GuiDRegVal(StringField(a$, 3, ",")), -1, Color)
						;}
					Case	#DTC_DRAWMODE			;{ DM - DrawingMode (,#mode) }
						Mode	=	Param
						If	StringField(a$, 2, ",")	=	""	; default if {DM} only
							Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						EndIf
						DrawingMode(Mode)
						;   0 = #PB_2DDrawing_Default
						;   1 = #PB_2DDrawing_Transparent
						;   2 = #PB_2DDrawing_XOr
						;   4 = #PB_2DDrawing_Outlined
						;   8 = #PB_2DDrawing_AlphaChannel
						;  16 = #PB_2DDrawing_AlphaBlend
						;  32 = #PB_2DDrawing_AlphaClip
						;  64 = #PB_2DDrawing_Gradient
						; 128 = #PB_2DDrawing_CustomFilter
						; 256 = #PB_2DDrawing_AllChannels
						;}
					Case	#DTC_INVERSE			;{ IV - InVerse }
						If	Param
							If	IsInVerse	=	#False
								IsInVerse	!	1
								Mode	=	#PB_2DDrawing_Default
								Swap	Color,Back
							EndIf
						ElseIf	IsInVerse
							IsInVerse	=	#False
							Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
							Swap	Color,Back
						EndIf
						DrawingMode(Mode)
						;}
					Case	#DTC_UNDERLINE			;{ UL - UnderLine }
						If	Param
							IsUnderLine	=	Param	; Height
							UnderLine_X	=	x	+	w
							n$	=	StringField(a$, 3, ",")	:	If	n$	:	UnderLine_Y	=	-1	+	GuiDRegVal(n$)	:	EndIf	; Y-Offset?
						Else
							If	IsUnderLine
								If	IsSHadow
									Box(UnderLine_X + SHadow_X, y + h + UnderLine_Y + SHadow_Y, x + w - UnderLine_X, IsUnderLine, IsSHadow)
								EndIf
								Box(UnderLine_X, y + h + UnderLine_Y, x + w - UnderLine_X, IsUnderLine, Color)
							EndIf
							IsUnderLine	=	#Null
						EndIf
						;}
					Case	#DTC_FRAME				;{ FR - UnderLine }
						If	Param
							IsFRame	=	Param	; Mode
							FRame_X	=	x	+	w
							FRame_Y	=	y
							n$	=	StringField(a$, 3, ",")	:	If	n$	:	FRame_XOffset	=	GuiDRegVal(n$)	:	EndIf	; X-Offset?
							n$	=	StringField(a$, 4, ",")	:	If	n$	:	FRame_YOffset	=	GuiDRegVal(n$)	:	EndIf	; Y-Offset?
						ElseIf	IsFRame
							GuiDrawFrame(IsFRame, FRame_X - FRame_XOffset, FRame_Y - FRame_YOffset, x + w - FRame_X + FRame_XOffset * 2, y + h - FRame_Y + FRame_YOffset * 2)
							DrawingMode(Mode)
							IsFRame	=	#Null
						EndIf
						;}
					Case	#DTC_EMBOS				;{ EB - EmBos, #alpha (,#mode) }
						IsEmBos	=	(Param	&	$FF)	<<	24		; Alpha
						If	IsEmBos
							EmBos_LColor	=	IsEmBos
							EmBos_RColor	=	IsEmBos
							If	GuiDRegVal(StringField(a$, 3, ",")) ; *** 3. Param for EmBos-Mode? ***
								EmBos_LColor|#White
							Else
								EmBos_RColor|#White
							EndIf
						EndIf
						;}
					Case	#DTC_GUIIMAGE			;{ GI - GuiImage, index (,yoffset)}
						If	IsGuiImage(Param)
							DrawAlphaImage(RS_GuiImage()\hID, x + w, y + (h - RS_GuiImage()\h) / 2 + GuiDRegVal(StringField(a$, 3, ",")))
							w	+	RS_GuiImage()\w	+	IsGapX
						EndIf
						;}
					Case	#DTC_XPOSITION			;{ XP - XPosition }
						x	=	Param
						w	=	0
						;}
					Case	#DTC_YPOSITION			;{ YP - YPosition }
						y	=	Param
						;}
					Case	#DTC_EXIT				;{ EX - Exit text (break) }
						Break
						;}
					Case	#DTC_MENU				;{ MN - MeNu, #mode (,$)}
						px	=	x	+	w
						py	=	y	+	h	>>	1	-	1
						FrontColor(Color)
						Select	Param
							Case	0
								Ellipse(px + 5, py, 2, 2)
							Case	1
								Box(px + 3, py - 2, 5, 5)
							Case	2
								LineXY(px + 3, py - 2, px + 7, py + 2)
								LineXY(px + 4, py - 2, px + 8, py + 2)
								LineXY(px + 7, py - 2, px + 3, py + 2)
								LineXY(px + 8, py - 2, px + 4, py + 2)
							Case	3
								py	+	1
								ph	=	h	>>	1	-	2
								LineXY(px + 2, py, px + 5, py + ph)
								LineXY(px + 3, py, px + 6, py + ph)
								LineXY(px + 8, py - ph - 2, px + 5, py + ph)
								LineXY(px + 9, py - ph - 2, px + 6, py + ph)
							Case	4
								DrawText(px, y, StringField(a$, 3, ","))
						EndSelect
						w	+	11
						;}
					Case	#DTC_CHAR				;{ CH - CHaracter, #ascii }
						*Memory	-	SizeOf(Character)
						a	=	Param
						;}
					Case	#DTC_D0	To	#DTC_D9	;{ D0 .. D9 - set Dataregister 0-9, #}
						GuiDRegSet(*RS_GuiDTC\b - '0', Param)
						;}
					Case	#DTC_DEFAULT			;{ DF / 99 - DeFault }
						If	IsUnderLine
							If	IsSHadow
								Box(UnderLine_X + SHadow_X, y + h + UnderLine_Y + SHadow_Y, x + w - UnderLine_X, IsUnderLine, IsSHadow)
							EndIf
							Box(UnderLine_X, y + h + UnderLine_Y, x + w - UnderLine_X, IsUnderLine, Color)
							IsUnderLine	=	0
						EndIf
						If	IsFRame
							GuiDrawFrame(IsFRame, FRame_X - FRame_XOffset, FRame_Y - FRame_YOffset, x + w - FRame_X + FRame_XOffset * 2, y + h - FRame_Y + FRame_YOffset * 2)
							IsFRame	=	0
						EndIf
						IsSHadow	=	0
						IsGapX	=	0
						IsGapY	=	0
						IsSTroke	=	0
						IsBolD	=	0
						IsInverse=	0
						IsEmBos	=	0
						Color	=	$FF000000
						Back	=	0
						Mode	=	#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent
						DrawingMode(Mode)
						;}
					CompilerIf	#PB_Compiler_Debugger	; Unknown Code {28,29,98}
					Default
						Select	ID_WORD(*RS_GuiDTC\a,*RS_GuiDTC\b)
							Case	#DTC_NIL,#DTC_TEXTHEIGHT,#DTC_TEXTWIDTH,#DTC_TEXTSIZE	; {NL}&{TH}&{TW}&{TS} - s. NiL/TextH/TextW/TextS - here do nothing!
							Default
								Debug	"Error: Drawtext-Code: {"+a$+"}"
						EndSelect
					CompilerEndIf
				EndSelect

			Default	; draw text

				If	a	; CHar?
					a$	=	Chr(a)
					a	=	#Null
				Else
					a$	=	Chr(*Memory\c)
				EndIf

				px	=	x	+	w

				If	IsSHadow	:	DrawText(px + SHadow_X, y + SHadow_Y, a$, IsSHadow)	:	EndIf

				If	IsEmBos
					FrontColor(EmBos_LColor)
					DrawText(px - 1, y - 1, a$)
					DrawText(px - 1, y, a$)
					DrawText(px, y - 1, a$)
					FrontColor(EmBos_RColor)
					DrawText(px + 1 + IsBolD,y + 1, a$)
					DrawText(px + 1 + IsBolD,y, a$)
					DrawText(px, y + 1, a$)
				EndIf

				If	IsSTroke
					FrontColor(IsSTroke)
					DrawText(px + 1, y, a$)
					DrawText(px - 1, y, a$)
					DrawText(px, y + 1, a$)
					DrawText(px, y - 1, a$)
					If	STroke_Bold
						DrawText(px + 1, y + 1, a$)
						DrawText(px + 1, y - 1, a$)
						DrawText(px - 1, y + 1, a$)
						DrawText(px - 1, y - 1, a$)
					EndIf
				EndIf

				DrawText(px, y, a$, Color, Back)

				If	IsBolD
					DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
					DrawText(px + IsBolD, y, a$, Color)
					DrawingMode(Mode)
				EndIf

				w	+	TextWidth(a$)	+	IsGapX

		EndSelect

		*Memory	+	SizeOf(Character)

	Wend

	If	IsUnderLine
		If	IsSHadow
			Box(UnderLine_X + SHadow_X, y + h + UnderLine_Y + SHadow_Y, x + w - UnderLine_X, IsUnderLine, IsSHadow)
		EndIf
		Box(UnderLine_X, y + h + UnderLine_Y, x + w - UnderLine_X, IsUnderLine, Color)
	EndIf

	RS_GUI\hFont	=	*hFont	; Restore font

EndProcedure
Procedure	GuiDrawTextH(t$)

	; = real height of text (linfeed + fontchange)

	If	Len(t$)	=	0	:	ProcedureReturn	#Null	:	EndIf

	Protected	h, y
	Protected	*Memory.Character	=	@t$

	Protected	a$, Param, IsGapY
	Protected	txt.SIZE

	Protected	hDC	=	CreateCompatibleDC_(0)
	Protected	hOld	=	SelectObject_(hDC, RS_GUI\hFont)

	While	*Memory\c

		Select	*Memory\c

			Case	#LF, '|'

				If	y
					h	+	y
				Else
					GetTextExtentPoint32_(hDC, *Memory, 1, @txt)
					h	+	txt\cy
				EndIf

				h	+	IsGapY
				y	=	0

			Case	'{'	; *** CtrlStart {Code,Param} ***

				a$	=	#Null$

				*Memory	+	SizeOf(Character)
				While	*Memory\c	And	*Memory\c	<>	'}'	; *** CtrlEnd
					a$	+	Chr(*Memory\c)	:	*Memory	+	SizeOf(Character)
				Wend

				Param	=	GuiDRegVal(StringField(a$, 2, ","))	; *** 1. Param / DataRegister D0 - D9? ***

				*RS_GuiDTC	=	@a$

				Select	ID_WORD(*RS_GuiDTC\a,*RS_GuiDTC\b)	; Command
					Case	#DTC_FONT
						SelectObject_(hDC, IsGuiFont(Param))
					Case	#DTC_YGAP
						IsGapY	=	Param
					Case	#DTC_YOFFSET
						h	+	Param
					Case	#DTC_YPOSITION
						If	h	<	y	:	h	=	y	:	EndIf
						If	h	<	Param	:	h	=	Param	:	EndIf
						y	=	#Null
; 					Case	#DTC_IMAGE
; 						If	IsImage(Param)	And	y	<	ImageHeight(Param)	:	y	=	ImageHeight(Param)	:	EndIf
; 					Case	#DTC_GUIIMAGE
; 						If	IsGuiImage(Param)
; 							If	y	<	RS_GuiImage()\h	:	y	=	RS_GuiImage()\h	:	EndIf
; 							;y + RS_GuiImage()\h / 2 + Val(StringField(a$, 3, ","))
; 							;If	y	>	h	:	h	=	y	:	EndIf
; 							;y	=	#Null
; 						EndIf
					Case	#DTC_TEXTHEIGHT
						If	Param	>	0
							h	=	Param
							y	=	0
							Break
						EndIf
					Case	#DTC_TEXTSIZE
						Param	=	GuiDRegVal(StringField(a$, 3, ","))	; width(,height)
						If	Param	>	0	And	h	<	Param
							h	=	Param
						EndIf
					Case	#DTC_DEFAULT
						IsGapY	=	0
					Case	#DTC_EXIT
						Break
					Case	#DTC_CHAR
						a$	=	Chr(Param)
						GetTextExtentPoint32_(hDC, @a$, 1, @txt)
						If	txt\cy	>	y	:	y	=	txt\cy	:	EndIf
					Case	#DTC_D0	To	#DTC_D9
						GuiDRegSet(*RS_GuiDTC\b - '0', Param)	; set value of D0 - D9
				EndSelect

			Default

				GetTextExtentPoint32_(hDC, *Memory, 1, @txt)
				If	txt\cy	>	y	:	y	=	txt\cy	:	EndIf

		EndSelect

		*Memory	+	SizeOf(Character)

	Wend

	h	+	y

	SelectObject_(hDC, hOld)
	DeleteDC_(hDC)

	ProcedureReturn	h

EndProcedure
Procedure	GuiDrawTextW(t$)

	; = real width of text (GapX + fontchange)

	If	Len(t$)	=	0	:	ProcedureReturn	#Null	:	EndIf

	Protected	w, x
	Protected	*Memory.Character	=	@t$

	Protected	a$, n$, n, Param, IsGapX, IsOffsetX
	Protected	txt.SIZE

	Protected	hDC	=	CreateCompatibleDC_(0)
	Protected	hOld	=	SelectObject_(hDC, RS_GUI\hFont)

	While	*Memory\c

		Select	*Memory\c

			Case	#LF, '|'

				If	w	<	x
					w	=	x
				EndIf

				x	=	IsOffsetX	;0

			Case	#TAB

				GetTextExtentPoint32_(hDC, @"0", 1, @txt)

				Param	=	txt\cx	*	RS_GUI\TabWidth	; tabwidth
				x	+	Param	-	(x	%	Param)

			Case	'{'	; *** CtrlStart {Code,Param} ***

				a$	=	#Null$

				*Memory	+	SizeOf(Character)
				While	*Memory\c	And	*Memory\c	<>	'}'	; *** CtrlEnd
					a$	+	Chr(*Memory\c)	:	*Memory	+	SizeOf(Character)
				Wend

				Param	=	GuiDRegVal(StringField(a$, 2, ","))	; Number D0-D9 or Val(n$)

				*RS_GuiDTC	=	@a$

				Select	ID_WORD(*RS_GuiDTC\a,*RS_GuiDTC\b)	; Command
					Case	#DTC_FONT
						SelectObject_(hDC, IsGuiFont(Param))
					Case	#DTC_XGAP
						IsGapX	=	Param
					Case	#DTC_XOFFSET
						IsOffsetX	=	Param
					Case	#DTC_XPOSITION
						If	w	<	x	:	w	=	x	:	EndIf
						x	=	Param
						If	w	<	x	:	w	=	x	:	EndIf
					Case	#DTC_IMAGE
						If	IsImage(Param)
							x	+	ImageWidth(Param)	+	IsGapX
						EndIf
					Case	#DTC_GUIIMAGE
						If	IsGuiImage(Param)
							x	+	RS_GuiImage()\w	+	IsGapX
						EndIf
					Case	#DTC_TEXTWIDTH
						If	Param	>	0
							w	=	Param
							x	=	0
							Break
						EndIf
					Case	#DTC_TEXTSIZE	; 1. Param = w, 2. = Param = h
						If	Param	>	0	And	w	<	Param
							w	=	Param
						EndIf
					Case	#DTC_MENU
						x	+	12
					Case	#DTC_DEFAULT
						IsGapX	=	0
					Case	#DTC_EXIT
						Break
					Case	#DTC_CHAR
						a$	=	Chr(Param)
						GetTextExtentPoint32_(hDC, @a$, 1, @txt)
						x	+	txt\cx	+	IsGapX
					Case	#DTC_D0	To	#DTC_D9
						GuiDRegSet(*RS_GuiDTC\b - '0', Param)
				EndSelect

			Default

				GetTextExtentPoint32_(hDC, *Memory, 1, @txt)
				x	+	txt\cx	+	IsGapX

		EndSelect

		*Memory	+	SizeOf(Character)

	Wend

	SelectObject_(hDC, hOld)
	DeleteDC_(hDC)

	If	w	<	x	:	w	=	x	:	EndIf

	ProcedureReturn	w

EndProcedure
Procedure$	GuiDrawTextRaw(t$)

	; Remove all "{Code,Param,...}"

	Protected	a, b

	Repeat
		a	=	FindString(t$, "{")
		If	a
			b	=	FindString(t$, "}", a)
			If	b
				t$	=	RemoveString(t$, Mid(t$, a, b - a + 1))
			Else
				Break
			EndIf
		Else
			Break
		EndIf
	ForEver

	ProcedureReturn	t$

EndProcedure

;- *** Font ***
Procedure	IsGuiFont(ID)

	; return ptr & set element(id) or #null

	With	RS_GUI
		If	ID	>=	#Null	And	ID	<	ListSize(\Font())
			ForEach	\Font()
				If	\Font()\ID	=	ID
					ProcedureReturn	\Font()\hFont
				EndIf
			Next
		EndIf
	EndWith

EndProcedure
Procedure	GuiFontFree(ID)

	With	RS_GUI\Font()

		If	ID	<=	#PB_All

			ForEach	RS_GUI\Font()
				If	\hFont	:	DeleteObject_(\hFont)				:	EndIf
				If	\rFont	:	RemoveFontMemResourceEx_(\rFont)	:	EndIf
			Next

			ClearList(RS_GUI\Font())

		Else

			If	IsGuiFont(ID)

				If	\hFont	:	DeleteObject_(\hFont)				:	EndIf
				If	\rFont	:	RemoveFontMemResourceEx_(\rFont)	:	EndIf

				DeleteElement(RS_GUI\Font())

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	GuiFontInit(ID, Font$, *Memory, Length, h=0, w=0, Flags=0)

	; return hFont -> FontID()

	Protected	lf.LOGFONT

	; check/set size of memory
	CompilerIf	Defined(IsC2D_File, #PB_Constant)
		CompilerIf	#IsC2D_File
			If	Length	<=	0	; @Filename as *Ptr
				*Memory	=	FileLoad(PeekS(*Memory))
				Length	=	MemorySize(*Memory)
			EndIf
		CompilerEndIf
	CompilerEndIf

	If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

	GuiFontFree(ID)	:	AddElement(RS_GUI\Font())	; -> @RS_SysFont()

	RS_GUI\Font()\ID		=	ID
	RS_GUI\Font()\rFont	=	AddFontMemResourceEx_(*Memory, Length, 0, @"1")

	If	RS_GUI\Font()\rFont

		With	lf

			\lfHeight			=	h
			\lfWidth				=	w
			;\lfEscapement		=	0
			;\lfOrientation	=	0
			\lfWeight			=	Bool(Flags & #PB_Font_Bold)	*	700	; * 300 + 400
			\lfItalic			=	Bool(Flags & #PB_Font_Italic)
			\lfUnderline		=	Bool(Flags & #PB_Font_Underline)
			\lfStrikeOut		=	Bool(Flags & #PB_Font_StrikeOut)
			\lfCharSet			=	#DEFAULT_CHARSET
			\lfOutPrecision	=	#OUT_DEFAULT_PRECIS
			\lfClipPrecision	=	#CLIP_DEFAULT_PRECIS
			\lfPitchAndFamily	=	#DEFAULT_PITCH | #FF_DONTCARE

			If	Flags & #PB_Font_HighQuality
				\lfQuality		=	#CLEARTYPE_QUALITY
			Else
				\lfQuality		=	#NONANTIALIASED_QUALITY	; default
			EndIf

			PokeS(@\lfFaceName[0], Font$)	; remember: NOT "fontfile.ttf" only real TITLE of font!

		EndWith

		RS_GUI\Font()\hFont	=	CreateFontIndirect_(@lf)

		If	RS_GUI\Font()\hFont	; all OK!
			ProcedureReturn	RS_GUI\Font()\hFont
		EndIf

	EndIf

	; Error!
	GuiFontFree(ID)
	ProcedureReturn	#False

EndProcedure
Procedure	GuiFontSet(ID)
	With	RS_GUI
		If	IsGuiFont(ID)
			\hFont	=	\Font()\hFont
		Else
			\hFont	=	GetGadgetFont(#PB_Default)
		EndIf
	EndWith
EndProcedure
Procedure	GuiFontID()
	ProcedureReturn	RS_GUI\hFont
EndProcedure

;- *** Position ***
Procedure	GuiOffset(x=0, y=0, ix=0, iy=0)

	; set x/y-offset for text / image in gadget

	With	RS_GUI\OffsetText
		\x	=	x
		\y	=	y
	EndWith

	With	RS_GUI\OffsetImage
		\x	=	ix
		\y	=	iy
	EndWith

EndProcedure
Procedure	GuiPosition(x=0, y=0)
	RS_GUI\OffsetGadget\x	=	x
	RS_GUI\OffsetGadget\y	=	y
EndProcedure
Procedure	GuiPosX(x=0)
	With	RS_GUI\Gadget()
		ProcedureReturn	\x	+	\w	+	x
	EndWith
EndProcedure
Procedure	GuiPosY(y=0)
	With	RS_GUI\Gadget()
		ProcedureReturn	\y	+	\h	+	y
	EndWith
EndProcedure
Procedure	GuiX(ID)

	; return x-pos of ID

	PushListPosition(RS_GUI\Gadget())

	If	IsGuiGadget(ID)
		ID	=	RS_GUI\Gadget()\x
	Else
		ID	=	#Null
	EndIf

	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	ID

EndProcedure
Procedure	GuiY(ID)

	; return y-pos of ID

	PushListPosition(RS_GUI\Gadget())

	If	IsGuiGadget(ID)
		ID	=	RS_GUI\Gadget()\y
	Else
		ID	=	#Null
	EndIf

	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	ID

EndProcedure
Procedure	GuiW(ID)

	PushListPosition(RS_GUI\Gadget())

	If	IsGuiGadget(ID)
		ID	=	RS_GUI\Gadget()\w
	Else
		ID	=	#Null
	EndIf

	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	ID

EndProcedure
Procedure	GuiH(ID)

	PushListPosition(RS_GUI\Gadget())

	If	IsGuiGadget(ID)
		ID	=	RS_GUI\Gadget()\h
	Else
		ID	=	#Null
	EndIf

	PopListPosition(RS_GUI\Gadget())

	ProcedureReturn	ID

EndProcedure
Procedure	GuiTab(w)
	RS_GUI\TabWidth	=	w
EndProcedure

;- *** MENU ***

CompilerIf	#IsC2D_Gui	&	#Gui_MenuPopup
	Procedure	IsGuiMenu(ID)

		ID	=	ID_GuiMenu\ID[ID]

		If	ID
			ChangeCurrentElement(RS_GuiMenu(), ID)
			ProcedureReturn	ID
		EndIf

	EndProcedure
	Procedure	GuiMenuFree(ID)

		If	ID	<=	#PB_All

			ClearList(RS_GuiMenu())

			FillMemory(@ID_GuiMenu\ID, #MAX_ID	*	SizeOf(Integer))

		ElseIf	IsGuiMenu(ID)

			DeleteElement(RS_GuiMenu())

			ID_GuiMenu\ID[ID]	=	#Null

		EndIf

	EndProcedure
	Procedure	GuiMenuInit(ID, t$, Count=32)

		; t$ = "item0;item1;item2;..."

		Protected	i, i$, n$

		GuiMenuFree(ID)	:	ID_GuiMenu\ID[ID]	=	AddElement(RS_GuiMenu())	:	RS_GuiMenu()\ID	=	ID

		With	RS_GuiMenu()

			\State	=	-1	; defaultstate off

			While	i	<>	Len(t$)
				i	=	Len(t$)
				t$	=	ReplaceString(t$, ";;", ";")
			Wend

			t$	=	ReplaceString(t$, ";-;", ";" + #MENU_LINE$)

			i	=	1
			i$	=	StringField(t$, 1, ";")

			While	i$	And	i	<=	Count

				n$	=	UCase(i$)

				If	GuiDrawTextRaw(i$)	; {} commands only?

					PushListPosition(\Items())
					ForEach	\Items()
						If	UCase(\Items()\t$)	=	n$
							n$	=	#Null$
							Break
						EndIf
					Next
					PopListPosition(\Items())

				EndIf

				If	n$
					AddElement(\Items())	:	\Items()\t$	=	i$
				EndIf

				i	+	1	:	i$	=	StringField(t$, i, ";")

			Wend

			i	-	1

		EndWith

		If	i	<=	#Null
			i	=	#False	:	GuiMenuFree(ID)
		EndIf

		ProcedureReturn	i

	EndProcedure
	Procedure	GuiMenuGetState(ID)
		If	IsGuiMenu(ID)
			ProcedureReturn	RS_GuiMenu()\State
		EndIf
	EndProcedure
	Procedure	GuiMenuSetState(ID, State)
		If	IsGuiMenu(ID)
			RS_GuiMenu()\State	=	State
			ForEach	RS_GuiMenu()\Items()
				RS_GuiMenu()\Items()\IsState	=	0
			Next
		EndIf
	EndProcedure
	Procedure	GuiMenuGetItem(ID)

		Protected	i=-1

		If	IsGuiMenu(ID)
			i	=	RS_GuiMenu()\Item
		EndIf

		ProcedureReturn	i

	EndProcedure
	Procedure$	GuiMenuGetText(ID)

		Protected	i$

		If	IsGuiMenu(ID)
			i$	=	GuiDrawTextRaw(RS_GuiMenu()\Text$)
		EndIf

		ProcedureReturn	i$

	EndProcedure
	Procedure	GuiMenuSize(ID)
		If	IsGuiMenu(ID)
			ProcedureReturn	ListSize(RS_GuiMenu()\Items())
		EndIf
	EndProcedure
	Procedure	GuiMenuPopup(ID, Flags=0, Rows=16)

		; Flags	= #Gui_FlagShadow|#Gui_FlagBorder|#Gui_FlagCenter|#Gui_FlagState|#Gui_FlagToggle|#Gui_FlagUser
		; Rows	= number of items per column (only with FlagUser)

		Protected	nW	=	GetActiveWindow()
		Protected	Gadget=-1, *hGL, x, y, w, h, f, i$

		If	IsGuiMenu(ID)	<=	0	Or	nW	<	0	:	ProcedureReturn	-1	:	EndIf

		*hGL	=	UseGadgetList(0)	; actual gadgetlist

		With	RS_GuiMenu()

			\Height	=	0
			\Width	=	0

			; calculate real width / height of menu
			ForEach	\Items()
				i$	=	\Items()\t$
				If	Flags & #Gui_FlagState
					i$	=	#MENU_PAD$	+	i$
				EndIf
				\Items()\h	=	GuiMax(5, GuiDrawTextH(i$) + 2)
				If	\Items()\h	=	5	:	\Items()\IsState	=	#Null	:	EndIf	; MENU_Line?
				\Height		+	\Items()\h
				\Width		=	GuiMax(\Width, GuiDrawTextW(i$))
			Next

			\Width	+	8	+	12	*	Bool(Flags & #Gui_FlagState)

			If	Flags	&	#Gui_FlagUser	; show menu in row-order?
				w	=	\Width * (ListSize(\Items()) / Rows + Bool(ListSize(\Items()) % Rows))
				h	=	GuiMin(\Height, Rows * \Items()\h)
			Else
				w	=	\Width
				h	=	\Height
			EndIf

			; popup position
			x	=	WindowX(nW)	+	WindowMouseX(nW)	:	If	x	+	w	>	GetSystemMetrics_(#SM_CXSCREEN)	:	x	=	GetSystemMetrics_(#SM_CXSCREEN)	-	w	:	EndIf
			y	=	WindowY(nW)	+	WindowMouseY(nW)	:	If	y	+	h	>	GetSystemMetrics_(#SM_CYSCREEN)	:	y	=	GetSystemMetrics_(#SM_CYSCREEN)	-	h	:	EndIf

			\nWin	=	OpenWindow(#PB_Any, GuiMax(x,0), GuiMax(y,0), w, h, #Null$, #PB_Window_Invisible|#PB_Window_BorderLess|(#WS_BORDER * Bool(Flags & #Gui_FlagBorder)), WindowID(nW))

			If	Flags	&	#Gui_FlagUser		:	SetWindowColor(\nWin, RS_GUI\BackColor & $00FFFFFF)	:	EndIf
			If	Flags	&	#Gui_FlagShadow	:	SetClassLongPtr_(WindowID(\nWin), #GCL_STYLE, $20000)	:	EndIf

			StickyWindow(\nWin, 1)
			UseGadgetList(WindowID(\nWin))

			f	=	RS_GUI\FrameMode
			y	=	0
			x	=	0

			; create menu-gadgets
			ForEach	\Items()

				i$	=	\Items()\t$	; state-marker on selected item?
				If	Flags	&	#Gui_FlagState	:	i$	=	#MENU_PAD$	+	i$	:	EndIf

				If	Flags	&	#Gui_FlagUser	And	ListIndex(\Items())	%	Rows	=	0
					y	=	0
					x	=	GuiMax(0, (ListIndex(\Items()) / Rows) * \Width)
				EndIf

				; #MENU_LINE$ ?
				If	f	<>	#Gui_FrameNone	And	\Items()\h	<=	5	:	RS_GUI\FrameMode	=	#Gui_FrameNone	:		EndIf

				\Items()\Gadget	=	Gui_CreateGadget(#PB_Any, x, y, \Width, \Items()\h, Flags, #C2D_Type_MenuButton)

				RS_GUI\FrameMode	=	f	; restore framemode
				RS_GUI\Gadget()\Text$	=	i$

				; *** State? ***
				If	(Flags & #Gui_FlagState)
					If	\State	>=	0
						If	ListIndex(\Items())	=	RS_GuiMenu()\State
							RS_GUI\Gadget()\Text$	=	"{MN}"	+	i$
						EndIf
					ElseIf	\Items()\IsState
						RS_GUI\Gadget()\Text$	=	"{MN,3}"	+	i$
					EndIf
				EndIf

				; Toggled (already choosed)?
				RS_GUI\Gadget()\IsToggled	=	\Items()\IsToggle
				RS_GUI\Gadget()\Toggle$		=	RS_GUI\Gadget()\Text$

				y	+	\Items()\h

				; #MENU_LINE$ ?
				If	\Items()\h	<=	5	Or	Len(GuiDrawTextRaw(i$))	=	0
					DisableGadget(\Items()\Gadget, 1)
				ElseIf	\Items()\IsDisable
					GuiDisable(\Items()\Gadget, 1)
				EndIf

				GuiRefresh(\Items()\Gadget)

			Next

			GuiCursorSet(\nWin)

			HideWindow(\nWin, 0)
			SetFocus_(WindowID(\nWin))

			Repeat
				Select	WaitWindowEvent()
					Case	#PB_Event_Gadget
						x	=	GuiEvent(EventGadget())
						If	x	>	0
							If	WindowMouseX(\nWin)	<	0	Or	WindowMouseY(\nWin)	<	0
								Break
							EndIf
							ForEach	\Items()
								If	\Items()\Gadget	=	x
									\Text$	=	GuiGetText(x)	; no control-codes "{}"
									Gadget	=	ListIndex(\Items())
									\Item		=	Gadget
									If	Flags	&	#Gui_FlagToggle
										\Items()\IsToggle	=	#True
									EndIf
									Break	2
								EndIf
							Next
						EndIf
					Case	#WM_RBUTTONDOWN, #PB_Event_CloseWindow
						Break
					Case	#WM_LBUTTONUP
						If	GetActiveWindow()	<>	\nWin
							Break
						EndIf
					Case	#WM_KEYDOWN
						Select	EventwParam()
							Case	#VK_ESCAPE
								Break
						EndSelect
				EndSelect
			ForEver

			HideWindow(\nWin, 1)
			GuiFree(#PB_All, \nWin)
			CloseWindow(\nWin)

		EndWith

		UseGadgetList(*hGL)

		SetFocus_(WindowID(nW))

		While	WaitWindowEvent(8)	:	Wend

		ProcedureReturn	Gadget

	EndProcedure
	; Menu-Items
	Procedure	GuiMenuItemAdd(ID, t$, Index=-1)

		; Index 0 = first / -1= last

		Protected	i$, i

		If	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		t$	=	RemoveString(t$, ";")	; Important!

		With	RS_GuiMenu()

			If	GuiDrawTextRaw(t$)
				While	i	<>	ListSize(\Items())
					i	=	ListSize(\Items())
					ForEach	\Items()
						If	\Items()\t$	=	t$
							DeleteElement(\Items())
							Break
						EndIf
					Next
				Wend
			EndIf

			ForEach	\Items()
				If	ListIndex(\Items())	=	Index
					i$	+	";"	+	t$	:	t$	=	#Null$
				EndIf
				i$	+	";"	+	\Items()\t$
			Next

			i$	+	";"	+	t$

		EndWith

		GuiMenuInit(ID, Trim(i$, ";"))

	EndProcedure
	Procedure	GuiMenuItemDelete(ID, Index)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				DeleteElement(\Items())
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemDisable(ID, Index, State)

		; Index = #PB_All to set State to all items

		If	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	#Null
				ForEach	\Items()
					\Items()\IsDisable	=	State
				Next
			ElseIf	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				\Items()\IsDisable	=	State
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemIsDisabled(ID, Index)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				ProcedureReturn	\Items()\IsDisable
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemSetState(ID, Index, State)

		; Index = #PB_All to set State to all items

		If	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		RS_GuiMenu()\State	=	-1

		With	RS_GuiMenu()
			If	Index	<	#Null
				ForEach	\Items()
					\Items()\IsState	=	State
				Next
			ElseIf	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				\Items()\IsState	=	State
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemGetState(ID, Index)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				ProcedureReturn	\Items()\IsState
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemIsToggled(ID, Index)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				ProcedureReturn	\Items()\IsToggle
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemToggle(ID, Index, Mode)

		; Index = #PB_All to set State to all items

		If	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	#Null
				ForEach	\Items()
					\Items()\IsToggle	=	Mode
				Next
			ElseIf	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				\Items()\IsToggle	=	Mode
			EndIf
		EndWith

	EndProcedure
	Procedure.q	GuiMenuItemGetData(ID, Index)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				ProcedureReturn	\Items()\Value
			EndIf
		EndWith

	EndProcedure
	Procedure	GuiMenuItemSetData(ID, Index, Value.q)

		If	Index	<	#Null	Or	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf

		With	RS_GuiMenu()
			If	Index	<	ListSize(\Items())	; 0..n
				SelectElement(\Items(), Index)
				\Items()\Value	=	Value
			EndIf
		EndWith

	EndProcedure
CompilerEndIf

;- *** GADGETS ***

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetButton
	Procedure	GuiButtonGadget(ID, x, y, w, h, t$, Flags=0, Image=#PB_Ignore, Toggle$=#Null$)

		; Return = #Gadget

		Protected	tw, th
		Protected	iw, ih
		Protected	hDC, txt.SIZE

		Gui_ImageInfo(@Image, @iw, @ih)

		; text/toggle width & height
		hDC	=	CreateCompatibleDC_(0)
		SelectObject_(hDC, RS_GUI\hFont)
		GetTextExtentPoint32_(hDC, @t$, Len(t$), @txt)
		tw	=	txt\cx
		th	=	txt\cy
		If	Flags	&	#Gui_FlagToggle	And	Len(Toggle$)
			GetTextExtentPoint32_(hDC, @Toggle$, Len(Toggle$), @txt)
			If	txt\cx	>	tw
				tw	=	txt\cx
			EndIf
		Else
			Toggle$	=	t$
		EndIf
		DeleteDC_(hDC)

		; auto-height?
		If	h	<=	#Null
			If	Image	And	ih	>	#Gui_DefHeight
				h	=	6	+	ih	; offset top/bottom = 3 (6)
			Else
				h	=	#Gui_DefHeight
			EndIf
			If	Flags	&	#Gui_FlagVertical
				h	+	2	+	th
			EndIf
			h	+	2	*	RS_GUI\FrameSize
		EndIf

		; auto width? left/right = 3 (6)
		If	w	<=	#Null
			If	Flags	&	#Gui_FlagVertical
				If	tw	>	iw
					w	=	tw
				Else
					w	=	iw
				EndIf
				w	+	6
			Else
				w	=	6	+ iw	+	tw	+	2	-	2	*	RS_GUI\FrameSize
			EndIf
		EndIf

		Gui_CreateGadget(ID, x, y, w, h, Flags, #PB_GadgetType_Button)

		With	RS_GUI\Gadget()

			\Text$		=	t$
			\Toggle$		=	Toggle$

			If	Image	; Icon?
				CompilerIf	#PB_Compiler_Version	>=	630	; CreateImage
					\Image	=	CreateImage(#PB_Any, iw, ih, 32, #PB_Image_TransparentBlack)
				CompilerElse
					\Image	=	CreateImage(#PB_Any, iw, ih, 32, #PB_Image_Transparent)
				CompilerEndIf
				StartDrawing(ImageOutput(\Image))
				DrawingMode(#PB_2DDrawing_AlphaBlend)
				DrawImage(Image, 0, 0)
				StopDrawing()
			EndIf

			If	\Flags	&	#Gui_FlagVertical

				; CenterV Image
				\ix	=	(\w	-	iw)	>>	1
				\iy	=	(\h	-	ih	-	th)	>>	1	-	1

				; CenterV Text
				\tx	=	(\w	-	tw)	>>	1
				\ty	=	(\h	-	th	+	ih)	>>	1	+	1

			Else

				If	Len(\Text$)
					\ix	=	(\w	-	(iw	+	tw	+	3	*	Bool(\Image>#Null)))	>>	1
					\tx	=	\ix	+	iw	+	3	*	Bool(\Image>#Null)
					\ty	=	(\h	-	th)	>>	1
				Else
					\ix	=	(\w	-	iw)	>>	1
				EndIf

				\iy	=	(\h	-	ih)		>>	1

			EndIf

			If	\Flags	&	#Gui_FlagLeft	; see before for vertical center
				\ix	=	RS_GUI\FrameSize
				\tx	=	RS_GUI\FrameSize
			EndIf

			\ix	+	\OffsetImage\x
			\iy	+	\OffsetImage\y
			\tx	+	\OffsetText\x
			\ty	+	\OffsetText\y

			Gui_DrawGadget(#Gui_DrawDefault)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetContainer
	Procedure	GuiContainerGadget(ID, x, y, w, h)

		Gui_CreateGadget(ID, x, y, w, h, #PB_Canvas_Container, #PB_GadgetType_Container)
		Gui_DrawGadget(#Gui_DrawDefault)

		ProcedureReturn	RS_GUI\Gadget()\ID

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetImage
	Procedure	GuiImageGadget(ID, x, y, w, h, Image, Raster=0)

		; Return = #Gadget

		Protected	iw, ih, i

		If	Gui_ImageInfo(@Image, @iw, @ih)	=	#Null	:	ProcedureReturn	:	EndIf

		If	w	<=	0	:	w	=	iw	:	EndIf
		If	h	<=	0	:	h	=	ih	:	EndIf

		Gui_CreateGadget(ID, x, y, w, h, 0, #PB_GadgetType_Image)

		With	RS_GUI\Gadget()

			\Flags	=	Raster	; Raster width/height / 0=off
			If	\Flags
				\Color		=	$FFD2D2D2
				\BackColor	=	$FFFFFFFF
			EndIf

			; make pb image from Image
			CompilerIf	#PB_Compiler_Version	>=	630	; CreateImage
				\Image	=	CreateImage(#PB_Any, iw, ih, 32, #PB_Image_TransparentBlack)
			CompilerElse
				\Image	=	CreateImage(#PB_Any, iw, ih, 32, #PB_Image_Transparent)
			CompilerEndIf

			StartDrawing(ImageOutput(\Image))
			DrawingMode(#PB_2DDrawing_AlphaBlend)
			DrawImage(Image, 0, 0)
			StopDrawing()

			\ix	=	RS_GUI\OffsetImage\x + (\w - ImageWidth(\Image))	>> 1
			\iy	=	RS_GUI\OffsetImage\y + (\h - ImageHeight(\Image))	>> 1

			Gui_DrawGadget(#Gui_DrawDefault)

			DisableGadget(\ID, #True)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetProgress
	Procedure	GuiProgressGadget(ID, x, y, w, h, max.d, Frame=0, Flags=0)

		; Return = #Gadget

		Gui_CreateGadget(ID, x, y, w, h, Flags, #PB_GadgetType_ProgressBar)

		With	RS_GUI\Gadget()

			\Max		=	Abs(max)
			\State	=	\Max
			\SubFrame=	Frame

			Gui_DrawGadget(0)

			DisableGadget(\ID, #True)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetString
	Procedure	GuiStringGadget(ID, x, y, w, h, t$, Flags=0)

		If	h	<=	0	:	h	=	#Gui_DefHeight	:	EndIf

		Gui_CreateGadget(ID, x, y, w, h, #PB_Canvas_Container, #PB_GadgetType_String)

		With	RS_GUI\Gadget()

			\Text$	=	t$

			\SubGadget0	=	Gui_Any()

			StringGadget(\SubGadget0,
			             \FrameSize + \OffsetText\x,
			             \FrameSize + \OffsetText\y,
			             \w - (\FrameSize * 2 + \OffsetText\x	+	1),
			             \h - (\FrameSize * 2 + \OffsetText\y),
			             \Text$,
			             Flags|#PB_String_BorderLess)

			CloseGadgetList()	; CreateGadget() = Container!

			SetGadgetFont(\SubGadget0, \hFont)

			SetGadgetColor(\SubGadget0, #PB_Gadget_FrontColor,	\Color		& $00FFFFFF)
			SetGadgetColor(\SubGadget0, #PB_Gadget_BackColor,	\BackColor	& $00FFFFFF)

			;SendMessage_(GadgetID(\SubGadget0), #EM_SETBKGNDCOLOR, 0, \BackColor	& $00FFFFFF)

			Gui_DrawGadget(#Gui_DrawDefault)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetText
	Procedure	GuiTextGadget(ID, x, y, w, h, t$, Flags=0)

		; Flags = #Gui_FlagCenter or #Gui_FlagRight

		; Return = #Gadget

		Protected	hDC, txt.SIZE

		If	w	<=	#Null	Or	h	<=	#Null
			hDC	=	CreateCompatibleDC_(0)
			SelectObject_(hDC, RS_GUI\hFont)
			GetTextExtentPoint32_(hDC, @t$, Len(t$), @txt)
			If	w	<=	#Null	:	w	=	txt\cx	+	RS_GUI\FrameSize	:	EndIf
			If	h	<=	#Null	:	h	=	txt\cy	+	RS_GUI\FrameSize	+	Bool(RS_GUI\ShadowColor)	*	(RS_GUI\OffsetShadow\y	+	1)	:	EndIf
			DeleteDC_(hDC)
		EndIf

		Gui_CreateGadget(ID, x, y, w, h, Flags, #PB_GadgetType_Text)

		With	RS_GUI\Gadget()

			\Text$	=	t$

			Gui_DrawGadget(#Gui_DrawDefault)

			DisableGadget(\ID, #True)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetTrack
	Procedure	GuiTrackGadget(ID, x, y, w, h, min, max, Frame=0, Flags=0)

		; Return = #Gadget

		Protected	hDC, txt.SIZE, t$

		If	h	<=	0	:	h	=	#Gui_DefHeight	:	EndIf

		If	Flags	&	(#Gui_FlagPercent | #Gui_FlagLevel | #Gui_FlagNumber)
			t$		=	"0"
			hDC	=	CreateCompatibleDC_(0)
			SelectObject_(hDC, RS_GUI\hFont)
			GetTextExtentPoint32_(hDC, @t$, 1, @txt)
			DeleteDC_(hDC)
			txt\cx	*	GuiMax(Len(Str(max)) + 1, 3)	; bar = width of chars + "±"
		EndIf

		Gui_CreateGadget(ID, x, y, w, h, Flags, #PB_GadgetType_TrackBar)

		With	RS_GUI\Gadget()

			\Min		=	min
			\Max		=	max
			\State	=	max
			\Text$	=	t$

			\SubFrame	=	Frame	; FrameMode on?

			If	\Flags	&	#Gui_FlagLevel
				\State	*	0.5
			EndIf

			If	Flags	&	#Gui_FlagVertical

				\Bar\x	=	\FrameSize
				\Bar\w	=	\w	-	\FrameSize	*	2
				\Bar\h	=	txt\cy	+	2

				\Range\x	=	\Clip\x	+	\Bar\w	*	0.5
				\Range\y	=	\Clip\y	+	\Bar\h	*	0.5
				\Range\w	=	\Clip\w	-	\Bar\w	*	0.5
				\Range\h	=	\Clip\h	-	\Bar\h	; -	\FrameSize	*	2

			Else

				\Clip\w	+	\FrameSize	>>	1

				\Bar\y	=	\FrameSize
				\Bar\w	=	txt\cx	|	7	; correct size for frame etc.
				\Bar\h	=	\h	-	\FrameSize	*	2

				\Range\x	=	\Clip\x	+	\Bar\w	*	0.5
				\Range\y	=	\Clip\y	+	\Bar\h	*	0.5
				\Range\w	=	\Clip\w	-	\Bar\w	; -	\FrameSize	*	2
				\Range\h	=	\Clip\h	-	\Bar\h	*	0.5

			EndIf

			Gui_DrawGadget(#Gui_DrawDefault)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawText
	Procedure	GuiDrawTextGadget(ID, x, y, w, h, t$, Flags=0)

		; Return = #Gadget

		If	w	<=	#Null	:	w	=	GuiDrawTextW(t$)	:	EndIf
		If	h	<=	#Null	:	h	=	GuiDrawTextH(t$)	:	EndIf

		Gui_CreateGadget(ID, x, y, w, h, Flags, #C2D_Type_DrawText)

		With	RS_GUI\Gadget()

			\Text$	=	t$

			Gui_DrawGadget(#Gui_DrawDefault)

			DisableGadget(\ID, #True)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

CompilerIf	#IsC2D_Gui	&	#Gui_GadgetDrawButton
	Procedure	GuiDrawButtonGadget(ID, x, y, w, h, t$, Flags=#Gui_FlagCenter, Toggle$=#Null$)

		; Return = #Gadget

		If	w	<=	#Null	:	w	=	GuiDrawTextW(t$)	:	EndIf
		If	h	<=	#Null	:	h	=	GuiDrawTextH(t$)	:	EndIf

		Gui_CreateGadget(ID, x, y, w, h, Flags, #C2D_Type_DrawButton)

		With	RS_GUI\Gadget()

			\Text$	=	t$
			If	Toggle$
				t$	=	Toggle$
			EndIf
			\Toggle$	=	t$

			Gui_DrawGadget(#Gui_DrawDefault)

			ProcedureReturn	\ID

		EndWith

	EndProcedure
CompilerEndIf

;- *** END ***
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAg
; CompileSourceDirectory