;**********************************************
;- *** C2D STARS Z3D / 26.06.2022 *************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	; *** only for testphase ***

	; #IsC2D_StarsZ3D	=	1/2

	XIncludeFile	"C2D_Enums.pbi"

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
		cx.f		; centerX
		cy.f		; centerY
		sx.i		; spreadX
		sy.i		; spreadY
		px1.i		; positions min/max
		py1.i
		px2.i
		py2.i
		List	RS_StarZ3D.RS_StarZ3D()
	EndStructure

	Global	RS_StarZ3DField.RS_StarZ3DField
	
	Declare	StarsZ3DFree()
	Declare	StarsZ3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default)
	Declare	StarsZ3DDraw(x.f, y.f, z.f)
	
CompilerEndIf

Procedure	StarsZ3DFree()
	
	Protected	i

	With	RS_StarZ3DField
		
		For	i	=	0	To	7
			If	\i[i]	:	FreeImage(\i[i])	:	EndIf
		Next
		
		ClearList(\RS_StarZ3D())
		
	EndWith
	
EndProcedure
Procedure	StarsZ3DInit(Number, x, y, w, h, Size=#PB_Default, Image=#PB_Default, Fade=1)

	StarsZ3DFree()
	
	If	Size	<	5	:	Size	=	5	:	EndIf

	With	RS_StarZ3DField
		
		If	Image	<=	#PB_Default

			Image	=	CreateImage(#PB_Any, Size, Size, 32, #PB_Image_Transparent)
			
			StartDrawing(ImageOutput(Image))
			DrawingMode(#PB_2DDrawing_AllChannels)
			Circle(OutputWidth() * 0.5, OutputHeight() * 0.5, (Size - 2) * 0.5, $FFFFFFFF)
			StopDrawing()
			
		Else
			
			Image	=	CopyImage(Image, #PB_Any)

			If	Size	<>	ImageWidth(Image)	Or	Size	<>	ImageHeight(Image)
				ResizeImage(Image, Size, Size, C2D\Quality)
			EndIf
			
		EndIf

		\n	=	Number
		\x	=	x
		\y	=	y
		\w	=	w
		\h	=	h
		
		\s	=	Size
		
		\IsFade	=	Fade
		
		\px1	=	\x	-	\s
		\py1	=	\y	-	\s
		\px2	=	\x	+	\w
		\py2	=	\y	+	\h
		
		\cx	=	\px2	-	(\w	+	\s)	/	2	; centerX
		\cy	=	\py2	-	(\h	+	\s)	/	2	; centerY
		
		\sx	=	\w	*	10	; spread width
		\sy	=	\h	*	10	; spread height
		
		\i[15]		=	Image
		\hImage[15]	=	ImageID(Image)
		
		Number	=	15
		While	Number
			Number	-	1
			w	=	\s - (Size / 16.0)	*	(15 - Number)
			If	w	<=	0	:	w	=	1	:	EndIf		
			\i[Number]			=	CopyImage(Image, #PB_Any)
			\hImage[Number]	=	ResizeImage(\i[Number], w, w, C2D\Quality)	; = ImageID()
			\po[Number]			=	0.5	*	w	; offsets
		Wend

		Number	=	\n
		x			=	\sx	*	2
		y			=	\sy	*	2

		While	Number
			Number	-	1
			AddElement(\RS_StarZ3D())
			\RS_StarZ3D()\x	=	Random(x)	-	Random(x)	;	-	\zx
			\RS_StarZ3D()\y	=	Random(y)	-	Random(y)	;	-	\zy
			\RS_StarZ3D()\z	=	Random(#STAR_Z3D_ZS)
		Wend
		
	EndWith
	
EndProcedure
Procedure	StarsZ3DDraw(x.f, y.f, z.f)

	Static	xp.f, yp.f, a.a

	With	RS_StarZ3DField
		
		CompilerIf	IsC2D::#IsC2D_StarsZ3D	=	2	; sortieren nach Alpha (Distanz)?
			SortStructuredList(\RS_StarZ3D(), #PB_Sort_Descending, OffsetOf(RS_StarZ3D\z), TypeOf(RS_StarZ3D\z))
		CompilerEndIf
		
		ClipOutput(\x, \y, \w, \h)

		ForEach	\RS_StarZ3D()
			
			a	=	(#STAR_Z3D_ZS	-	\RS_StarZ3D()\z)	*	#STAR_Z3D_FS
			a	>>	4

			xp	=	(\RS_StarZ3D()\x	/	\RS_StarZ3D()\z)	+	\cx	-	\po[a]
			yp	=	(\RS_StarZ3D()\y	/	\RS_StarZ3D()\z)	+	\cy	-	\po[a]

			If xp	>=	\px1	And	xp	<=	\px2 And yp	>=	\py1 And yp		<=	\py2
				If	\IsFade
					DrawAlphaImage(\hImage[a], xp, yp, (a << 4) | 15)
				Else
					DrawAlphaImage(\hImage[a], xp, yp)
				EndIf
			EndIf

			If	x
				\RS_StarZ3D()\x	+	x
				If x	>	0	And	\RS_StarZ3D()\x	>	\sx
					\RS_StarZ3D()\x	-	(\sx	*	2)
				ElseIf \RS_StarZ3D()\x	<	-\sx
					\RS_StarZ3D()\x	+	(\sx	*	2)
				EndIf
			EndIf
			
			If	y
				\RS_StarZ3D()\y	+	y
				If y	>	0	And	\RS_StarZ3D()\y	>	\sy
					\RS_StarZ3D()\y	-	(\sy	*	2)
				ElseIf \RS_StarZ3D()\y	<	-\sy
					\RS_StarZ3D()\y	+	(\sy	*	2)
				EndIf
			EndIf  
			
			If	z
				\RS_StarZ3D()\z	+	z
				If z	<	0	And	\RS_StarZ3D()\z	<=	0 
					\RS_StarZ3D()\z	+	#STAR_Z3D_ZS
				ElseIf \RS_StarZ3D()\z	>	#STAR_Z3D_ZS
					\RS_StarZ3D()\z	-	#STAR_Z3D_ZS
				EndIf
			EndIf

		Next

		UnclipOutput()

	EndWith

EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = A+
; EnableXP
; CompileSourceDirectory