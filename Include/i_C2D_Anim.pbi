;**********************************************
;- *** C2D ANIM / 28.03.2023 ******************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	XIncludeFile	"C2D_Defaults.pbi"
	XIncludeFile	"C2D_Macros.pbi"
	XIncludeFile	"C2D_Enums.pbi"

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

Procedure	Anim_Any()

	Protected	i=#MAX_ID

	While	i	>=	0
		If	ID_Anim\ID[i]	=	#Null
			Break
		EndIf
		i	-	1
	Wend

	ProcedureReturn	i

EndProcedure
Procedure	IsAnim(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Anim\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Anim(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	AnimCopper(ID, *Memory.Long, Flags=0)

	Protected	*Ptr.Long, i
	Protected	c.f = 1.0 / (*Memory\l - 1)	; Number of gradients

	If	IsAnim(ID)
		With	RS_Anim()
			ForEach	\Frame()

				StartDrawing(ImageOutput(\Frame()\Image))
				DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)

				If	Flags	&	#C2F_Horizontal
					LinearGradient(0, 0, OutputWidth(), 0)
				Else	; #C2F_Vertical
					LinearGradient(0, 0, 0, OutputHeight())
				EndIf

				*Ptr	=	*Memory	+	SizeOf(Long)	; ptr to number of RGBA-Longs
				For	i	=	0	To	*Memory\l	-	1
					GradientColor(c * i, *Ptr\l)
					*Ptr	+	SizeOf(Long)
				Next

				Box(0, 0, OutputWidth(), OutputHeight())

				StopDrawing()

			Next
		EndWith
	EndIf

EndProcedure
Procedure	AnimCopy(ID, NewID, Flags=0)

	; creates a clone of ID to NewID
	; Flags = 0 : uses same frames for less memory
	; Flags = 1 : creates new frames for resize, flip etc.

	Protected	NewList	tmp.RS_Anim()

	If	NewID	<	#Null	:	NewID	=	Anim_Any()	:	EndIf

	AnimFree(NewID)

	If	IsAnim(ID)

		AddElement(tmp())	:	CopyList(RS_Anim(), tmp())

		ID_Anim\ID[NewID]	=	AddElement(RS_Anim())	; -> @RS_Anim()

		With	RS_Anim()

			\Direction	=	tmp()\Direction
			\FrameID		=	tmp()\FrameID
			\FrameStart	=	tmp()\FrameStart
			\FrameFinish=	tmp()\FrameFinish
			\FrameNumber=	tmp()\FrameNumber
			\h				=	tmp()\h
			\Pause		=	tmp()\Pause
			\PingPong	=	tmp()\PingPong
			\Time			=	tmp()\Time
			\w				=	tmp()\w
			\x				=	tmp()\x
			\y				=	tmp()\y

			If	Flags	=	0	; less memory usage with same images (default)

				CopyList(tmp()\Frame(), \Frame())

			Else	; creates new images for resize, flip etc.

				ResetList(tmp()\Frame())

				While	NextElement(tmp()\Frame())

					AddElement(\Frame())

					\Frame()\Image	=	CopyImage(tmp()\Frame()\Image, #PB_Any)
					\Frame()\hImage=	ImageID(\Frame()\Image)
					\Frame()\Time	=	tmp()\Frame()\Time

				Wend

			EndIf

		EndWith
	EndIf

	FreeList(tmp())

	ProcedureReturn	NewID

EndProcedure
Procedure	AnimCount(ID)

	; return number of total frames or 0 = error

	If	IsAnim(ID)
		ProcedureReturn	ListSize(RS_Anim()\Frame())
	EndIf

EndProcedure
Procedure	AnimDelay(ID, Time, FrameID=#PB_All)

	If	IsAnim(ID)
		With	RS_Anim()

			If	FrameID	=	#PB_All

				ForEach	\Frame()
					\Frame()\Time	=	Time
				Next

			Else

				SelectElement(\Frame(), FrameID)
				\Frame()\Time	=	Time

			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	AnimDirection(ID, Frames)

	; Frames = step number of ± frames (eg. 2=show every 2. frame)

	If	IsAnim(ID)
		RS_Anim()\Direction	=	Frames
	EndIf

EndProcedure
Procedure	AnimDraw(ID, x.f, y.f, Alpha=255, Flags=0)

	; return actual #FrameID

	ChangeCurrentElement(RS_Anim(), ID_Anim\ID[ID])

	With	RS_Anim()

		If	\Pause	=	0	And	C2D\Time	-	\Time	>=	\Frame()\Time

			\FrameID	+	\Direction

			If	\PingPong
				If	\FrameID	<	\FrameStart
					\FrameID		=	\FrameStart
					\Direction	*	-1
				ElseIf	\FrameID	>	\FrameFinish
					\FrameID		=	\FrameFinish		;\FrameNumber	-	1
					\Direction	*	-1
				EndIf
			Else
				If	\FrameID	>	\FrameFinish
					\FrameID	=	\FrameStart
				ElseIf	\FrameID	<	\FrameStart
					\FrameID	=	\FrameFinish
				EndIf
			EndIf

			SelectElement(\Frame(), \FrameID)

			\Time	=	C2D\Time

		EndIf

		; set position by flags?
		If	Flags

			If			Flags	&	(#C2F_CenterX|#C2F_Center)	:	x	+	(C2D\w	-	\w)	*	0.5
			ElseIf	Flags	&	#C2F_Right						:	x	+	(C2D\w	-	\w)
			EndIf

			If			Flags	&	(#C2F_CenterY|#C2F_Center)	:	y	+	(C2D\h	-	\h)	*	0.5
			ElseIf	Flags	&	#C2F_Bottom						:	y	+	(C2D\h	-	\h)
			EndIf

		EndIf

		\x	=	x
		\y	=	y

		DrawAlphaImage(\Frame()\hImage, x, y, Alpha)

		ProcedureReturn	\FrameID

	EndWith

EndProcedure
Procedure	AnimFlip(ID, Flags=0)

	Protected	hDC, w, h

	If	IsAnim(ID)
		With	RS_Anim()
			ForEach	\Frame()
				If	IsImage(\Frame()\Image)

					hDC	=	StartDrawing(ImageOutput(\Frame()\Image))

					w	=	OutputWidth()
					h	=	OutputHeight()

					Select	Flags
						Case	#C2F_Vertical
							StretchBlt_(hDC, #NUL, h-1, w ,-h, hDC, #NUL, #NUL, w, h, #SRCCOPY)
						Default
							StretchBlt_(hDC, w-1, #NUL, -w, h, hDC, #NUL, #NUL, w, h, #SRCCOPY)
					EndSelect

					StopDrawing()

				EndIf
			Next
		EndWith
	EndIf

EndProcedure
Procedure	AnimFrame(ID, FrameID=#PB_Default)

	; set frame and/or return current-frame only

	If	IsAnim(ID)
		With	RS_Anim()

			If	FrameID	<>	#PB_Default
				\FrameID	=	FrameID
				SelectElement(\Frame(), \FrameID)
			EndIf

			ProcedureReturn	\FrameID

		EndWith
	EndIf

EndProcedure
Procedure	AnimFree(ID)

	With	RS_Anim()

		If	ID	<=	#PB_All

			ForEach	RS_Anim()
				ForEach	\Frame()
					If	IsImage(\Frame()\Image)
						FreeImage(\Frame()\Image)
					EndIf
				Next
			Next

			FillMemory(@ID_Anim\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Anim())

		Else

			If	IsAnim(ID)

				ForEach	\Frame()
					If	IsImage(\Frame()\Image)
						FreeImage(\Frame()\Image)
					EndIf
				Next

				DeleteElement(RS_Anim())

				ID_Anim\ID[ID]	=	#Null

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	AnimH(ID)

	; return frame-height

	If	IsAnim(ID)
		ProcedureReturn	RS_Anim()\h
	EndIf

EndProcedure
Procedure	AnimInit(ID, Image, x, y, Frames=#PB_All)

	If	ID	<	#Null	:	ID	=	Anim_Any()	:	EndIf	; #PB_Any?

	AnimFree(ID)	:	ID_Anim\ID[ID]	=	AddElement(RS_Anim())	; -> @RS_Anim()

	With	RS_Anim()

		\w	=	ImageWidth(Image)		/	x	; frame pixel-width
		\h	=	ImageHeight(Image)	/	y	; frame pixel-height

		If	Frames	=	#PB_All
			\FrameNumber	=	x	*	y	-	1
		Else
			\FrameNumber	=	Frames	-	1
		EndIf

		While	\FrameNumber	>=	ListSize(\Frame())

			AddElement(\Frame())

			\Frame()\Image		=	GrabImage(Image,
			              		 	          #PB_Any,
			              		 	          (ListIndex(\Frame())	% x)	*	\w,
			              		 	          (ListIndex(\Frame())	/ x)	*	\h,
			              		 	          \w, \h)

			\Frame()\hImage	=	ImageID(\Frame()\Image)	; fast drawing
			\Frame()\Time		=	#ANIM_FRAME_TIME			; default

		Wend

		FirstElement(\Frame())	; reset to first frame-image
		
		\FrameStart		=	#Null
		\FrameFinish	=	\FrameNumber

		;\FrameID	=	#Null	; Startframe
		;\Rewind		=	#Null	; No loop rewind
		\Direction	=	1		; Foreward one frame

		\Time	=	C2D\Time

	EndWith

	ProcedureReturn	ID

EndProcedure
Procedure	AnimPause(ID, Status=1)

	; pause on/off

	If	IsAnim(ID)
		RS_Anim()\Pause	=	Status
	EndIf

EndProcedure
Procedure	AnimPingPong(ID, Mode=1)

	; loop anim reverse or reset to normal

	If	IsAnim(ID)
		RS_Anim()\PingPong	=	Mode	; fwd/rwd loop on eof?
	EndIf

EndProcedure
Procedure	AnimPlayDraw(ID, x.f, y.f, w=#PB_Default, h=#PB_Default)

	; plays an anim a count-times
	; return <> 0 if playing

	ChangeCurrentElement(RS_Anim(), ID_Anim\ID[ID])

	With	RS_Anim()
		If	\PlayCount	>	0

			If	w	<=	#Null	:	w	=	\w	:	EndIf
			If	h	<=	#Null	:	h	=	\h	:	EndIf

			\x	=	x
			\y	=	y

			DrawImage(\Frame()\hImage, x, y, w, h)

			If	C2D\Time	-	\Time	>=	\Frame()\Time

				\FrameID	+	\Direction

				If	\FrameID	>	\FrameFinish
					\PlayCount	-	1
					\FrameID		=	\FrameStart	;0
				ElseIf	\FrameID	<	#Null
					\PlayCount	-	1
					\FrameID		=	\FrameFinish
				EndIf

				SelectElement(\Frame(), \FrameID)

				\Time	=	C2D\Time

			EndIf

			ProcedureReturn	\PlayCount

		EndIf
	EndWith

EndProcedure
Procedure	AnimPlayStart(ID, Count=1)
	If	IsAnim(ID)
		With	RS_Anim()
			If	\Direction	<	#Null
				\FrameID	=	\FrameFinish	; end
			Else
				\FrameID	=	\FrameStart		; 0
			EndIf
			\PlayCount	=	Count
			\Time			=	MA_Time()	+	\Frame()\Time
			SelectElement(\Frame(), \FrameID)
		EndWith
		ProcedureReturn	Count
	EndIf
EndProcedure
Procedure	AnimRange(ID, FrameID, Number)
	
	; Plays anim from FrameID to FrameID + Number
	
	; FrameID = 0 to Number - 1
	; Number  = FrameID + Number - 1
	
	If	IsAnim(ID)
		With	RS_Anim()
			
			If	FrameID	>	\FrameNumber	:	FrameID	=	\FrameNumber	:	EndIf
			
			Number	+	FrameID	:	If	Number	>	\FrameNumber	:	Number	=	\FrameNumber	:	EndIf
			
			\FrameStart	=	FrameID
			\FrameFinish=	Number

		EndWith
	EndIf
	
EndProcedure
Procedure	AnimScale(ID, Ratio.f)

	If	IsAnim(ID)
		With	RS_Anim()

			If	Ratio	<>	1.0

				\w	*	Ratio
				\h	*	Ratio

				ForEach	\Frame()
					\Frame()\hImage	=	ResizeImage(\Frame()\Image, \w, \h, C2D\Quality)
				Next

			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	AnimSeen(ID)

	; return #true if anim is inside canvas

	ChangeCurrentElement(RS_Anim(), ID_Anim\ID[ID])	; no check for fastest selection

	With	RS_Anim()
		If	(\x	>=	-\w	And	\x	<=	C2D\w)	And	(\y	>=	-\h	And	\y	<=	C2D\h)
			ProcedureReturn	#True
		EndIf
	EndWith

EndProcedure
Procedure	AnimW(ID)

	; return frame-width

	If	IsAnim(ID)
		ProcedureReturn	RS_Anim()\w
	EndIf

EndProcedure
Procedure.f	AnimX(ID)
	If	IsAnim(ID)
		ProcedureReturn	RS_Anim()\x
	EndIf
EndProcedure
Procedure.f	AnimY(ID)
	If	IsAnim(ID)
		ProcedureReturn	RS_Anim()\y
	EndIf
EndProcedure
Procedure	AnimZoom(ID, w=#PB_Default, h=#PB_Default)
	If	IsAnim(ID)
		With	RS_Anim()

			If	w	>	#Null	:	\w	=	w	:	EndIf
			If	h	>	#Null	:	\h	=	h	:	EndIf

			ForEach	\Frame()
				\Frame()\hImage	=	ResizeImage(\Frame()\Image, \w, \h, C2D\Quality)
			Next

		EndWith
	EndIf
EndProcedure
Procedure	AnimZone(ID, x.f, y.f)

	; return #true if x/y points inside anim

	ChangeCurrentElement(RS_Anim(), ID_Anim\ID[ID])	; no check for fastest selection

	With	RS_Anim()
		If	x	>=	\x	And	x	<=	\x	+	\w	And	y	>=	\y	And	y	<=	\y	+	\h
			ProcedureReturn	#True
		EndIf
	EndWith

EndProcedure
; IDE Options = PureBasic 6.01 LTS (Windows - x86)
; Folding = AAAA9
; EnableXP
; CompileSourceDirectory