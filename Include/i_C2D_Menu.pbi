;**********************************************
;- *** C2D FLATBAR / 01.04.2020 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
Structure	RS_GuiMenuItem
	Gadget.i
	i$
EndStructure
Structure	RS_GuiMenu
	ID.i
	Count.i
	h.i
	w.i
	Item.i
	Item$
	List	Items.RS_GuiMenuItem()	;String()
EndStructure
Global	ID_GuiMenu.C2D_ID
Global	NewList	RS_GuiMenu.RS_GuiMenu()

CompilerEndIf

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
		
		If	ListSize(RS_GuiMenu()\Items())
			ClearList(RS_GuiMenu()\Items())
		EndIf
		
		DeleteElement(RS_GuiMenu())
		
		ID_GuiMenu\ID[ID]	=	#Null
		
	EndIf
	
EndProcedure
Procedure	GuiMenuInit(ID, t$)
	
	Protected	i=1, i$
	
	GuiMenuFree(ID)	:	ID_GuiMenu\ID[ID]	=	AddElement(RS_GuiMenu())	:	RS_GuiMenu()\ID	=	ID
	
	i$	=	StringField(t$, 1, ";")
	While	i$
		AddElement(RS_GuiMenu()\Items())
		RS_GuiMenu()\Items()\i$	=	i$
		i	+	1	:	i$	=	StringField(t$, i, ";")
	Wend
	
	i	-	1	:	RS_GuiMenu()\Count	=	i
	
	If	i	<=	#Null
		i	=	#False	:	GuiMenuFree(ID)
	EndIf
	
	ProcedureReturn	i
	
EndProcedure
Procedure	GuiMenuPopup(ID)
	
	Protected	nWin, Gadget=-1, *hGL, nAW, x, y, h, w=64
	
	If	IsGuiMenu(ID)	<=	#Null	:	ProcedureReturn	:	EndIf
	
	nAW	=	GetActiveWindow()	:	If	nAW	<	#Null	:	ProcedureReturn	-1	:	EndIf
	
	ForEach	RS_GuiMenu()\Items()
		x	=	GuiDrawTextW(RS_GuiMenu()\Items()\i$)
		y	=	GuiDrawTextH(RS_GuiMenu()\Items()\i$)
		If	x	>	w	:	w	=	x	:	EndIf
		If	y	>	h	:	h	=	y	:	EndIf
	Next
	
	w	+	8
	h	+	3
	
	x	=	WindowX(nAW)	+	WindowMouseX(nAW)
	y	=	WindowY(nAW)	+	WindowMouseY(nAW)
	
	nWin	=	OpenWindow(#PB_Any, x, y, w, RS_GuiMenu()\Count * h, #Null$, #PB_Window_Invisible|#PB_Window_BorderLess, WindowID(nAW))
	SetClassLongPtr_(WindowID(nWin),#GCL_STYLE,$00020000)
  
	StickyWindow(nWin, 1)
	
	*hGL	=	UseGadgetList(WindowID(nWin))

	ForEach	RS_GuiMenu()\Items()
		RS_GuiMenu()\Items()\Gadget	=	GuiDrawButtonGadget(#PB_Any, 0, ListIndex(RS_GuiMenu()\Items()) * h, WindowWidth(nWin), h, RS_GuiMenu()\Items()\i$, 0)
		If	GuiGetText(RS_GuiMenu()\Items()\Gadget)	=	""	:	DisableGadget(RS_GuiMenu()\Items()\Gadget, 1)	:	EndIf
		GuiRefresh(RS_GuiMenu()\Items()\Gadget)
	Next
	
	DisableWindow(nAW, 1)
	HideWindow(nWin, 0)
	SetFocus_(WindowID(nWin))

	Repeat
		Select	WaitWindowEvent()
			Case	#PB_Event_Gadget
				Gadget	=	GuiEvent(EventGadget())
				If	Gadget	>	0
					ForEach	RS_GuiMenu()\Items()
						If	RS_GuiMenu()\Items()\Gadget	=	Gadget
							RS_GuiMenu()\Item$=	GuiGetText(Gadget)	; no control-codes "{}"
							Gadget	=	ListIndex(RS_GuiMenu()\Items())
							RS_GuiMenu()\Item	=	Gadget
							Break	2
						EndIf	
					Next
				EndIf
				Gadget	=	-1
			Case	#PB_Event_CloseWindow
				Break
			Case #WM_RBUTTONDOWN
				Break
			Case	#WM_KEYDOWN
				Select	EventwParam()
					Case	#VK_ESCAPE, #VK_RETURN
						Break
				EndSelect
			Default
				Gadget	=	-1
		EndSelect
	ForEver
	
	DisableWindow(nAW, 0)
	UseGadgetList(*hGL)
	
	HideWindow(nWin, 1)
	GuiFree(#PB_All, nWin)
	CloseWindow(nWin)

	SetFocus_(WindowID(nAW))
	
	While	WindowEvent()	:	Wend	:	Delay(1)

	ProcedureReturn	Gadget
	
EndProcedure
Procedure	GuiMenuItemID(ID)
	
	Protected	i=-1
	
	If	IsGuiMenu(ID)
		i	=	RS_GuiMenu()\Item
	EndIf
	
	ProcedureReturn	i
	
EndProcedure
Procedure$	GuiMenuItemStr(ID)
	
	Protected	i$
	
	If	IsGuiMenu(ID)
		i$	=	RS_GuiMenu()\Item$
	EndIf
	
	ProcedureReturn	i$
	
EndProcedure
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 127
; FirstLine = 120
; Folding = --
; CompileSourceDirectory