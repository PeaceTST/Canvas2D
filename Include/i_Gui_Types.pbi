;*******************************************************
; #Enumeration:	GuiGadgets / 07.07.2023
;*******************************************************

;=======================================================
; #IsC2D_Gui	=	#Gui_Gadget[Type|Type|...]
;=======================================================
EnumerationBinary
	#Gui_GadgetButton			;	 1	=	GuiButtonGadget
	#Gui_GadgetContainer		;	 2	=	GuiContainerGadget
	#Gui_GadgetImage			;	 4	=	GuiImageGadget
	#Gui_GadgetProgress		;   8	=	GuiProgressGadget
	#Gui_GadgetString			;	16	=	GuiStrinGadget
	#Gui_GadgetText			;  32	=	GuiTextGadget
	#Gui_GadgetTrack			;	64	=	GuiTrackGadget
	#Gui_GadgetDrawText		; 128	=	GuiMessageGadget [GuiDrawText()]
	#Gui_GadgetDrawButton	; 256	=	GuiDrawButtonGadget [GuiDrawText()]
	#Gui_MenuPopup				; 512	=	GuiMenuPopup (MenuButton=private!)
EndEnumeration
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = -
; CompileSourceDirectory