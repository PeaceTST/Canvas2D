;**********************************************
;- *** C2D LINE 3D / 04.08.2023 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Line3D	=	1,2

	XIncludeFile	"C2D_Enums.pbi"

	Global	ID_Line3D.C2D_ID
	Global	NewList	RS_Line3DObject.RS_Line3DObject()

	Declare	IsLine3D(ID)
	Declare	Line3DBuild(ID, Mode, Speed)
	Declare	Line3DColor(ID, Color.l)
	Declare	Line3DDraw(ID, x.f=0, y.f=0, zx.f=1.0, zy.f=1.0)
	Declare	Line3DFade(ID, Speed)
	Declare	Line3DFog(ID, Fog.f)
	Declare	Line3DFree(ID)
	Declare	Line3DInit(ID, *Memory.RS_Line3D, Ratio.f=1.0, z.f=1.0)
	Declare	Line3DIsBuild(ID)
	Declare	Line3DIsFade(ID)
	Declare	Line3DRotate(ID, x.f, y.f, z.f)
	Declare	Line3DSetAngle(ID, x.f, y.f, z.f)
	
	; Size
	Declare	Line3DWidth(ID)
	Declare	Line3DHeight(ID)
	Declare	Line3DDepth(ID)
	Declare.f	Line3DSquare(ID, Size.f, Ratio.f=0)

CompilerEndIf

Procedure	IsLine3D(ID)

	ID	=	ID_Line3D\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Line3DObject(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	Line3DAngle(ID, x.f, y.f, z.f)

	If	IsLine3D(ID)

		With	RS_Line3DObject()
			\ax	=	#Null
			\ay	=	#Null
			\az	=	#Null
		EndWith

		Line3DRotate(ID, x, y, z)

	EndIf

EndProcedure
Procedure	Line3DFree(ID)

	If	ID	<=	#PB_All	; Free all objects
		
		FillMemory(@ID_Line3D\ID, #MAX_ID	*	SizeOf(Integer))
		ClearList(RS_Line3DObject())

	Else	; Free object ID only

		If	IsLine3D(ID)
			DeleteElement(RS_Line3DObject())
			ID_Line3D\ID[ID]	=	#Null
		EndIf

	EndIf

EndProcedure
Procedure	Line3DInit(ID, *Memory.RS_Line3D, Ratio.f=1.0, z.f=1.0)
	
	Protected	x0,x1, y0,y1, z0,z1

	Line3DFree(ID)
	
	; ****************************************
	; *Memory -> @FileName?
	; ****************************************
	CompilerIf	#IsC2D_File
		If	PeekL(*Memory)	<>	#ID_L3D0	; Filename as *Ptr
			*Memory	=	FileLoad(PeekS(*Memory))
		EndIf
	CompilerEndIf
	
	; *****************************************
	; Init / Create Line3D unlimited elements!
	; *****************************************
	If	PeekL(*Memory)	=	#ID_L3D0	; Check Header-ID

		With	RS_Line3DObject()

			ID_Line3D\ID[ID]	=	AddElement(RS_Line3DObject())	; @RS_Line3DObject()

			\Color	=	$FF000000|#Red	; Default-Color = full RED!

			*Memory	+	SizeOf(Long)	; Skip HeaderID
			ID			=	PeekL(*Memory)	; Number of pairs (1 to n)
			*Memory	+	SizeOf(Long)	; Ptr to vectors xy0/xy1

			While	ID	>	ListSize(\VP())

				AddElement(\VP())
				
				If	*Memory\x0	<	x0	:	x0	=	*Memory\x0	:	EndIf
				If	*Memory\x1	>	x1	:	x1	=	*Memory\x1	:	EndIf
				If	*Memory\y0	<	y0	:	y0	=	*Memory\y0	:	EndIf
				If	*Memory\y1	>	y1	:	y1	=	*Memory\y1	:	EndIf
				If	*Memory\z0	<	z0	:	z0	=	*Memory\z0	:	EndIf
				If	*Memory\z1	>	z1	:	z1	=	*Memory\z1	:	EndIf

				\VP()\x[0]	=	*Memory\x0	*	Ratio	; reserve Center0[xyz]
				\VP()\y[0]	=	*Memory\y0	*	Ratio
				\VP()\z[0]	=	*Memory\z0	*	Ratio	*	z

				\VP()\x[1]	=	*Memory\x1	*	Ratio	; reserve End[xyz]
				\VP()\y[1]	=	*Memory\y1	*	Ratio
				\VP()\z[1]	=	*Memory\z1	*	Ratio	*	z

				\VP()\px[0]	=	\VP()\x[0]	; Rotated xyz
				\VP()\py[0]	=	\VP()\y[0]
				\VP()\pz[0]	=	\VP()\z[0]

				\VP()\px[1]	=	\VP()\x[1]
				\VP()\py[1]	=	\VP()\y[1]
				\VP()\pz[1]	=	\VP()\z[1]

				*Memory	+	SizeOf(RS_Line3D)

			Wend
			
			\sw	=	Abs(x0)	+	Abs(x1)
			\sh	=	Abs(y0)	+	Abs(y1)
			\sz	=	Abs(z0)	+	Abs(z1)

		EndWith

	EndIf

EndProcedure
Procedure	Line3DColor(ID, Color.l)
	If	ID	=	#PB_All
		ForEach	RS_Line3DObject()
			RS_Line3DObject()\Color	=	Color
		Next
	ElseIf	IsLine3D(ID)
		RS_Line3DObject()\Color	=	Color	; remember the use of Alpha-Channel $FF000000 ($FF<<24) ;)
	EndIf
EndProcedure
Procedure	Line3DRotate(ID, x.f, y.f, z.f)

	; optimized / faster 3d xyz

	Static.f	ax, ay, az
	Static.f	cx,sx, cy,sy, cz,sz

	ChangeCurrentElement(RS_Line3DObject(), ID_Line3D\ID[ID])

	With	RS_Line3DObject()

		\ax	+	x	*	#FastAngle
		\ay	+	y	*	#FastAngle
		\az	+	z	*	#FastAngle

		cx	=	Cos(\ax)	:	cy	=	Cos(\ay)	:	cz	=	Cos(\az)
		sx	=	Sin(\ax)	:	sy	=	Sin(\ay)	:	sz	=	Sin(\az)

		ForEach	\VP()

			; Start XYZ
			ay	= \VP()\y[0] * cx - \VP()\z[0] * sx		; Rotate about x-axis
			az	= \VP()\y[0] * sx + \VP()\z[0] * cx
			ax	= \VP()\x[0] * cy + az * sy				; Rotate about y-axis

			\VP()\pz[0]=-\VP()\x[0] * sy + az * cy		; -\VP()\x[0]
			\VP()\px[0]= ax * cz - ay * sz				; Rotate about z-axis
			\VP()\py[0]= ax * sz + ay * cz

			; End XYZ
			ay	= \VP()\y[1] * cx - \VP()\z[1] * sx		; Rotate about x-axis
			az	= \VP()\y[1] * sx + \VP()\z[1] * cx
			ax	= \VP()\x[1] * cy + az * sy				; Rotate about y-axis

			\VP()\pz[1]=-\VP()\x[1] * sy + az * cy		; -\VP()\x[1]
			\VP()\px[1]= ax * cz - ay * sz				; Rotate about z-axis
			\VP()\py[1]= ax * sz + ay * cz

		Next

	EndWith

EndProcedure
Procedure	Line3DFog(ID, Fog.f)
	If	ID	=	#PB_All
		ForEach	RS_Line3DObject()
			RS_Line3DObject()\Fog	=	Fog
		Next
	ElseIf	IsLine3D(ID)
		RS_Line3DObject()\Fog	=	Fog
	EndIf
EndProcedure
Procedure	Line3DDraw(ID, x.f=0, y.f=0, zx.f=1.0, zy.f=1.0)

	Static	FogAlpha

	ChangeCurrentElement(RS_Line3DObject(), ID_Line3D\ID[ID])

	With	RS_Line3DObject()

		x	+	C2D\cx	; + center width
		y	+	C2D\cy	; + center height

		; Fade in/out object
		CompilerIf	#IsC2D_Line3D	=	2
			If	\FadeSpeed

				\FadeAlpha	+	\FadeSpeed

				If	\FadeAlpha	>	$FF

					\FadeSpeed	=	#False
					\FadeAlpha	=	$FF

				ElseIf	\FadeAlpha	<	#Null

					\FadeSpeed	=	#False
					\FadeAlpha	=	#Null

					ProcedureReturn

				EndIf

				\Color & $00FFFFFF | (\FadeAlpha << 24)

			EndIf
		CompilerEndIf

		FrontColor(\Color)	; Default RGB if Fog=0

		ForEach	\VP()

			; Build up / down line by line?
			CompilerIf	#IsC2D_Line3D	=	2
				If	\BuildMode

					If	C2D\Time	-	\BuildTime	>=	\BuildSpeed

						\BuildCount	+	\BuildMode

						If	\BuildCount	>=	ListSize(\VP())
							\BuildMode	=	#False
						ElseIf	\BuildCount	<=	#Null
							\BuildMode	=	#False
							ProcedureReturn
						EndIf

						\BuildTime	=	C2D\Time

					EndIf

					If	\BuildCount	=	ListIndex(\VP())
						ProcedureReturn
					EndIf

				EndIf
			CompilerEndIf

			; Fog lines?
			If	\Fog
				If	\VP()\pz[0]	>	#Null
					FogAlpha	=	Alpha(\Color)	-	\VP()\pz[0]	*	\Fog
					If	FogAlpha	<=	#Null
						Continue
					EndIf
					FrontColor(\Color & $00FFFFFF | (FogAlpha << 24))
				Else
					FrontColor(\Color)
				EndIf
			EndIf

			LineXY(x + \VP()\px[0] * zx, y + \VP()\py[0] * zy, x + \VP()\px[1] * zx, y + \VP()\py[1] * zy)

		Next

	EndWith

EndProcedure

; Size
Procedure	Line3DWidth(ID)
	If	IsLine3D(ID)
		ProcedureReturn	RS_Line3DObject()\sw
	EndIf
EndProcedure
Procedure	Line3DHeight(ID)
	If	IsLine3D(ID)
		ProcedureReturn	RS_Line3DObject()\sh
	EndIf
EndProcedure
Procedure	Line3DDepth(ID)
	If	IsLine3D(ID)
		ProcedureReturn	RS_Line3DObject()\sz
	EndIf
EndProcedure
Procedure.f	Line3DSquare(ID, Size.f, Ratio.f=0)
	
	Protected.f	w, h, z
	
	If	IsLine3D(ID)
		
		w	=	RS_Line3DObject()\sw
		h	=	RS_Line3DObject()\sh
		z	=	RS_Line3DObject()\sz
		
		If	z	>	w
			w	=	z
		ElseIf	z	>	h
			h	=	z
		EndIf
		
		While	Sqr(Pow(w * Ratio, 2) + Pow(h * Ratio, 2)) <	Size
			Ratio	+	0.05
		Wend
		
		ProcedureReturn	Ratio
		
	EndIf

EndProcedure

; Build / Fade
CompilerIf	#IsC2D_Line3D	=	2
	Procedure	Line3DIsBuild(ID)
		If	IsLine3D(ID)
			ProcedureReturn	RS_Line3DObject()\BuildMode
		EndIf
	EndProcedure
	Procedure	Line3DBuild(ID, Mode, Speed)

		If	IsLine3D(ID)
			With	RS_Line3DObject()

				\BuildTime	=	C2D\Time
				\BuildSpeed	=	Speed	; ms

				If	Mode	<	0
					\BuildMode	=	-1
					\BuildCount	=	ListSize(\VP())
				Else
					\BuildMode	=	1
					\BuildCount	=	0
				EndIf

			EndWith
		EndIf

	EndProcedure
	Procedure	Line3DIsFade(ID)
		If	IsLine3D(ID)
			ProcedureReturn	RS_Line3DObject()\FadeSpeed
		EndIf
	EndProcedure
	Procedure	Line3DFade(ID, Speed)

		If	IsLine3D(ID)
			With	RS_Line3DObject()

				\FadeSpeed	=	Speed	; - / +

				If	Speed	<	0
					\FadeAlpha	=	$FF
				Else
					\FadeAlpha	=	0
				EndIf

				\Color & ($00FFFFFF | \FadeAlpha << 24)

			EndWith
		EndIf

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; Folding = BAQ5
; EnableXP
; CompileSourceDirectory