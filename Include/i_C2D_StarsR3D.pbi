;**********************************************
;- *** C2D STARS R3D / 09.05.2021 *************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	; *** only for testphase ***
	
	; #IsC2D_StarsR3D	=	1

	XIncludeFile	"C2D_Enums.pbi"
	
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
	Global	RS_StarR3DField.RS_StarR3DField
	
	Declare	StarsR3DFree()
	Declare	StarsR3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default)
	Declare	StarsR3DDraw(x.f, y.f, z.f)
	
CompilerEndIf

Procedure	StarsR3DFree()

	With	RS_StarR3DField

		If	\i	:	FreeImage(\i)	:	EndIf
		
		ClearList(\RS_StarR3D())
		
	EndWith
	
EndProcedure
Procedure	StarsR3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default)

	StarsR3DFree()

	With	RS_StarR3DField
		
		If	Image	<=	#PB_Default

			If	Size	<=	#Null	:	Size	=	2	:	EndIf
			
			\Size	=	Size	*	2	+	1
			
			Image	=	CreateImage(#PB_Any, \Size, \Size, 32, #PB_Image_Transparent)
			
			StartDrawing(ImageOutput(Image))
			DrawingMode(#PB_2DDrawing_AllChannels)
			Circle(OutputWidth() * 0.5, OutputHeight() * 0.5, Size - 1, $FFFFFFFF)
			StopDrawing()
			
		Else
			
			Image	=	CopyImage(Image, #PB_Any)
			
			\Size	=	Size	:	If	\Size	<=	#Null	:	\Size	=	8	:	EndIf
			
			If	\Size	<>	ImageWidth(Image)	Or	\Size	<>	ImageHeight(Image)
				ResizeImage(Image, \Size, \Size, C2D\Quality)
			EndIf
			
		EndIf

		\n	=	Number
		\x	=	x
		\y	=	y
		\w	=	w
		\h	=	h

		\i	=	Image
		\hImage	=	ImageID(Image)
		
		\px1	=	x	-	\Size
		\py1	=	y	-	\Size
		\px2	=	x	+	w
		\py2	=	y	+	h
		
		\cx	=	\px2	-	(w	+	\Size)	/	2	; centerX
		\cy	=	\py2	-	(h	+	\Size)	/	2	; centerY
		
		\zx	=	w	*	10
		\zy	=	h	*	10
		
		Number	=	\n
		x			=	\zx	*	2
		y			=	\zy	*	2

		While	Number
			Number	-	1
			AddElement(\RS_StarR3D())
			\RS_StarR3D()\x	=	Random(x)	-	Random(x)	;	-	\zx
			\RS_StarR3D()\y	=	Random(y)	-	Random(y)	;	-	\zy
			\RS_StarR3D()\z	=	Random(#STAR_R3D_ZS)
		Wend
		
	EndWith
	
EndProcedure
Procedure	StarsR3DDraw(x.f, y.f, z.f)

	Static	xp.f, yp.f, a.a
	Protected	i
	
	With	RS_StarR3DField
		
		ClipOutput(\x, \y, \w, \h)
		
		ForEach	\RS_StarR3D()
			
			xp	=	(\RS_StarR3D()\x	/	\RS_StarR3D()\z)	+	\cx
			yp	=	(\RS_StarR3D()\y	/	\RS_StarR3D()\z)	+	\cy
			
			If xp	>=	\px1	And	xp	<=	\px2 And yp	>=	\py1 And yp	<=	\py2
				a	=	(#STAR_R3D_ZS	-	\RS_StarR3D()\z)	*	#STAR_R3D_FS
				If	a	>=	#STAR_R3D_FS	:	DrawAlphaImage(\hImage, xp, yp, a)	:	EndIf
			EndIf				

			If	x
				\RS_StarR3D()\x	+	x
				If x	>	0	And	\RS_StarR3D()\x	>	\zx
					\RS_StarR3D()\x	-	(\zx	*	2)
				ElseIf \RS_StarR3D()\x	<	-\zx
					\RS_StarR3D()\x	+	(\zx	*	2)
				EndIf
			EndIf
			
			If	y
				\RS_StarR3D()\y	+	y
				If y	>	0	And	\RS_StarR3D()\y	>	\zy
					\RS_StarR3D()\y	-	(\zy	*	2)
				ElseIf \RS_StarR3D()\y	<	-\zy
					\RS_StarR3D()\y	+	(\zy	*	2)
				EndIf
			EndIf  
			
			If	z
				\RS_StarR3D()\z	+	z
				If z	<	0	And	\RS_StarR3D()\z	<=	0 
					\RS_StarR3D()\z	+	#STAR_R3D_ZS
				ElseIf \RS_StarR3D()\z	>=	#STAR_R3D_ZS
					\RS_StarR3D()\z	-	#STAR_R3D_ZS
				EndIf
			EndIf
			
		Next
		
		UnclipOutput()
		
	EndWith

EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A-
; EnableXP
; CompileSourceDirectory