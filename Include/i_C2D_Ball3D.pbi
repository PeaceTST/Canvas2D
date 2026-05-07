;**********************************************
;- *** C2D BALL3D / 16.04.2026 ****************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	XIncludeFile	"C2D_Enums.pbi"

	Global	ID_Ball3D.C2D_ID
	Global	Ball3DBob.RS_Ball3DBob
	Global	NewList	RS_Ball3DObject.RS_Ball3DObject()

	Declare		IsBall3D(ID)
	Declare		Ball3DAngle(ID, x.f, y.f, z.f)
	Declare		Ball3DAnim(ID, AnimID, BallID)
	Declare		Ball3DCatchTheme(*Memory.Integer)
	Declare		Ball3DCount(ID)
	Declare		Ball3DDefaultTheme(*Memory.Long=0)
	Declare		Ball3DDraw(ID, x.f=0, y.f=0, Alpha=255, Fade=0)
	Declare.f	Ball3DExplode(ID, Factor=0)
	Declare		Ball3DFree(ID)
	Declare		Ball3DImage(BallID, Image=-1)
	Declare		Ball3DInit(ID, *Memory, Size, Gap.f=1.0)
	Declare		Ball3DLoadTheme(Path$, Format$="png")
	Declare		Ball3DMerge(ID1, ID2)
	Declare		Ball3DRotate(ID, x.f, y.f, z.f)
	Declare		Ball3DSpin(ID, Factor.f, BallID=#PB_All)
	Declare		Ball3DStars(ID, Number, Radius, Size, BallID=3, Rnd.f=0)

	; Default Ball3D Colors
	DataSection
		c2d_ball3d_rgb:	:	Data.l	$0020FF, $0096FF, $02D8D8, $02B402, $FF4000, $D800D8, $E8E8E8, $494848
	EndDataSection

CompilerEndIf

Procedure	IsBall3D(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Ball3D\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Ball3DObject(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	Ball3DAngle(ID, x.f, y.f, z.f)

	If	IsBall3D(ID)

		ForEach	RS_Ball3DObject()\Ball()

			With	RS_Ball3DObject()\Ball()

				\ax	=	#Null
				\ay	=	#Null
				\az	=	#Null

				CompilerIf	#IsC2D_Ball3D	=	2
					If	RS_Ball3DObject()\IsExplode
						\sx	=	\ExplodeSx
						\sy	=	\ExplodeSy
						\sz	=	\ExplodeSz
					EndIf
				CompilerEndIf

			EndWith

		Next

		CompilerIf	#IsC2D_Ball3D	=	2
			RS_Ball3DObject()\IsExplode	=	#Null
		CompilerEndIf

		Ball3DRotate(ID, x, y, z)

	EndIf

EndProcedure
Procedure	Ball3DCatchTheme(*Memory.Integer)

	; Tableformat: *Ptr to image, Size of image... [8]

	CompilerIf	#IsC2D_Bitmap	Or	#IsC2D_GdiPlus

		Protected	i, *Ptr, Length

		For	i	=	0	To	#MAX_BALL

			*Ptr		=	*Memory\i	:	*Memory	+	SizeOf(Integer)
			Length	=	*Memory\i	:	*Memory	+	SizeOf(Integer)

			If	Length	-	*Ptr	>	#Null
				Ball3DImage(i, GdipCatch(#PB_Any, *Ptr, Length))
			EndIf

		Next

	CompilerEndIf

EndProcedure
Procedure	Ball3DCount(ID)
	If	IsBall3D(ID)
		ProcedureReturn	ListSize(RS_Ball3DObject()\Ball())
	EndIf
EndProcedure
Procedure	Ball3DDefaultTheme(*Memory.Long=0)

	; *Memory = Color-Table of RGB.LONG[8] - or 0 for default ball-colors

	Protected	i

	; Default colors?
	If	*Memory	<=	0	:	*Memory	=	?c2d_ball3d_rgb	:	EndIf

	With	Ball3DBob
		For	i	=	0	To	#MAX_BALL

			If	\Image[i]	And	IsImage(\Image[i])
				FreeImage(\Image[i])
			EndIf
			
			CompilerIf	#PB_Compiler_Version	>=	630
				\Image[i]	=	CreateImage(#PB_Any, #SIZE_BALL, #SIZE_BALL, 32, #PB_Image_TransparentBlack)
			CompilerElse
				\Image[i]	=	CreateImage(#PB_Any, #SIZE_BALL, #SIZE_BALL, 32, #PB_Image_Transparent)
			CompilerEndIf

			StartDrawing(ImageOutput(\Image[i]))

			DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AllChannels)
			BackColor($FFFFFFFF)	:	FrontColor($FF000000|*Memory\l)
			CircularGradient(#SIZE_BALL * 0.35, #SIZE_BALL * 0.35, #SIZE_BALL * 0.20)
			Circle(#SIZE_BALL / 2, #SIZE_BALL / 2, #SIZE_BALL / 2)

			DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)
			BackColor(#Null)	:	FrontColor($90000000)
			CircularGradient(#SIZE_BALL * 0.30, #SIZE_BALL * 0.30, #SIZE_BALL * 0.70)
			Circle(#SIZE_BALL / 2, #SIZE_BALL / 2, #SIZE_BALL / 2)

			DrawingMode(#PB_2DDrawing_AllChannels|#PB_2DDrawing_Outlined)
			Circle(#SIZE_BALL / 2, #SIZE_BALL / 2, #SIZE_BALL / 2, $30000000|*Memory\l)

			StopDrawing()

			*Memory	+	SizeOf(Long)

		Next
	EndWith

EndProcedure
Procedure	Ball3DDraw(ID, x.f=0, y.f=0, Alpha=255, Fade=0)

	; draw object & return number of viewed balls

	Protected	Count, px.f, py.f, ps.f, pz

	ChangeCurrentElement(RS_Ball3DObject(), ID_Ball3D\ID[ID])

	x	+	C2D\cx	; + center width
	y	+	C2D\cy	; + center height

	If	Fade	<=	0
		Fade	=	0	:	pz	=	Alpha
	EndIf

	; *** Ball-Object exploding?
	CompilerIf	#IsC2D_Ball3D	=	2
		With	RS_Ball3DObject()
			If	\IsExplode

				\IsExplode	-	\ExplodeStep	; see Ball3DExplode()

				If	\IsExplode	<=	#Null

					\IsExplode	=	#Null	; Explode off

					ForEach	\Ball()
						\Ball()\sx	=	\Ball()\ExplodeSx	; Restore default spin xyz
						\Ball()\sy	=	\Ball()\ExplodeSy
						\Ball()\sz	=	\Ball()\ExplodeSz
					Next

				EndIf

			EndIf
		EndWith
	CompilerEndIf

	; *** Draw all Object-Balls ***
	With	RS_Ball3DObject()\Ball()
		ForEach	RS_Ball3DObject()\Ball()

			If	Fade
				pz	=	(Alpha	+	\pz	*	Fade)
				If	pz	>	255	:	pz	=	255	:	EndIf
			EndIf

			If	pz	>	0

				px	=	(x	+	\px	*	RS_Ball3DObject()\Size	-	\s)
				py	=	(y	+	\py	*	RS_Ball3DObject()\Size	-	\s)

				ps	=	-2	*	\s

				If	px	>	ps	And	px	<	C2D\w	And	py	>	ps	And	py	<	C2D\h
					Count	+	1
					CompilerIf	#IsC2D_Ball3D	=	2	And	#IsC2D_Anim	>	0
						If	\IsAnim
							AnimDraw(\AnimID, px, py, pz)
						Else
							DrawAlphaImage(\hImage, px, py, pz)
						EndIf
					CompilerElse
						DrawAlphaImage(\hImage, px, py, pz)
					CompilerEndIf
				EndIf

			EndIf

		Next
	EndWith

	ProcedureReturn	Count

EndProcedure
Procedure	Ball3DFree(ID)

	With	RS_Ball3DObject()

		If	ID	<=	#PB_All	; Free all objects

			ForEach	RS_Ball3DObject()

				For	ID	=	0	To	#MAX_BALL	; Default images (default size)
					If	\Image[ID]	And	IsImage(\Image[ID])
						FreeImage(\Image[ID])
					EndIf
				Next

				ForEach	RS_Ball3DObject()\Ball()	; ball/bob specified images (resized or not default size)
					If	\Ball()\Image	And	IsImage(\Ball()\Image)
						FreeImage(\Ball()\Image)
					EndIf
				Next

			Next

			FillMemory(@ID_Ball3D\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Ball3DObject())

		Else	; Free object ID only

			If	IsBall3D(ID)

				ID_Ball3D\ID[ID]	=	#Null

				For	ID	=	0	To	#MAX_BALL
					If	\Image[ID]	And	IsImage(\Image[ID])
						FreeImage(\Image[ID])
					EndIf
				Next

				ForEach	RS_Ball3DObject()\Ball()
					If	\Ball()\Image	And	IsImage(\Ball()\Image)
						FreeImage(\Ball()\Image)
					EndIf
				Next

				DeleteElement(RS_Ball3DObject())

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	Ball3DImage(BallID, Image=-1)

	; Return default Ball3D-ImageID (0 - 7) or set ballImage if image >= 0

	If	BallID	>=	0	And	BallID	<=	#MAX_BALL

		With	Ball3DBob

			If	\Image[BallID]	And	IsImage(\Image[BallID])

				If	Image	<	#Null	; ImageNumber
					ProcedureReturn	\Image[BallID]
				Else	; set new ballImage
					FreeImage(\Image[BallID])
				EndIf

			EndIf

			\Image[BallID]	=	Image

		EndWith

	EndIf

EndProcedure
Procedure	Ball3DInit(ID, *Memory.RS_Ball3D, Size, Gap.f=1.0)

	Protected	Count, Image, s.f

	Ball3DFree(ID)	; free object if already initialized!

	; ****************************************
	; *Memory -> @FileName?
	; ****************************************
	CompilerIf	#IsC2D_File
		If	PeekL(*Memory)	<>	#ID_B3D0	; Filename as *Ptr
			*Memory	=	FileLoad(PeekS(*Memory))
		EndIf
	CompilerEndIf

	; ****************************************
	; Init / Create Ball3D unlimited elements!
	; ****************************************
	If	PeekL(*Memory)	=	#ID_B3D0	; MagicID

		With	RS_Ball3DObject()

			ID_Ball3D\ID[ID]	=	AddElement(RS_Ball3DObject())	; @RS_Ball3DObject()	-> Ptr to element for fast access

			\Size	=	Size	:	If	\Size	<=	#Null	:	\Size	=	1	:	EndIf

			*Memory	+	SizeOf(Long)	; Skip HeaderID
			ID			=	PeekL(*Memory)	; Number of balls (1 to n)
			*Memory	+	SizeOf(Long)	; *Ptr to first ball (bob)

			While	ID	>	ListSize(\Ball())

				AddElement(\Ball())

				\Ball()\ID		=	ListIndex(\Ball()); Ball3D InDexing (if image/bob already exist, reduce imagenumber)
				\Ball()\Image	=	*Memory\ID			; 0 - #MAX_BALL(7)
				\Ball()\hImage	=	*Memory\ID			; temp need to check same ball & size
				\Ball()\Color	=	*Memory\ID			; temp need for default color (editor!)

				\Ball()\x	=	*Memory\x	*	Gap
				\Ball()\y	=	*Memory\y	*	Gap
				\Ball()\z	=	*Memory\z	*	Gap
				\Ball()\s	=	\Size	*	(*Memory\s	*	0.1)	; Size

				\Ball()\px	=	\Ball()\x
				\Ball()\py	=	\Ball()\y
				\Ball()\pz	=	\Ball()\z

				; Extra BallSpin?
				\Ball()\sx	=	*Memory\sx	*	#FastAngle
				\Ball()\sy	=	*Memory\sy	*	#FastAngle
				\Ball()\sz	=	*Memory\sz	*	#FastAngle

				; not standard-size?
				If	\Ball()\s	<>	0	And	\Ball()\s	<>	1.0

					; check if same ball & size already defined (reduce image-number)
					Image	=	-1
					s		=	\Ball()\s

					ForEach	\Ball()
						If	\Ball()\s = s	And	\Ball()\hImage = *Memory\ID	And	\Ball()\ID <> ListIndex(\Ball()) ; and <> actual ball
							Image	=	\Ball()\Image
							Break
						EndIf
					Next

					LastElement(\Ball())	; back to actual ball

					If	Image	<	#Null	; -1 must create & resize a new ball?

						Count	+	1

						If	s	<	1	:	s	=	1	:	EndIf	; avoid size < 1 error!

						\Ball()\Image	=	CopyImage(Ball3DBob\Image[*Memory\ID], #PB_Any)
						ResizeImage(\Ball()\Image, s, s, C2D\Quality)

					Else	; ball & size already defined, use avail image!

						\Ball()\Image	=	Image

					EndIf

				Else

					If	\Image[*Memory\ID]	=	0

						Count	+	1

						\Image[*Memory\ID]	=	CopyImage(Ball3DBob\Image[*Memory\ID], #PB_Any)
						ResizeImage(\Image[*Memory\ID], \Size, \Size, C2D\Quality)

					EndIf

					\Ball()\Image	=	\Image[*Memory\ID]	; set ID to default ImageID for faster display

				EndIf

				*Memory	+	SizeOf(RS_Ball3D)	; Set *Ptr to next ball

			Wend

			; ************************************************************************
			; Important: set center-size & bob to default ImageID() for faster display
			; ************************************************************************
			ForEach	\Ball()

				If	\Ball()\s	=	0
					\Ball()\s	=	\Size
				EndIf

				\Ball()\s	*	0.50

				\Ball()\hImage	=	ImageID(\Ball()\Image)

			Next

		EndWith

	EndIf

	ProcedureReturn	Count	; Number of images (bobs)

EndProcedure
Procedure	Ball3DRotate(ID, x.f, y.f, z.f)

	Static.f	x0, y0, z0
	Static.f	cx,sx, cy,sy, cz,sz

	x	*	#FastAngle	;/	127.0
	y	*	#FastAngle	;/	127.0
	z	*	#FastAngle	;/	127.0

	ChangeCurrentElement(RS_Ball3DObject(), ID_Ball3D\ID[ID])

	ForEach	RS_Ball3DObject()\Ball()
		With	RS_Ball3DObject()\Ball()

			; Rotate & Individual spin-rotate
			\ax	+	x	:	If	\sx	:	\ax	+	\sx	:	EndIf
			\ay	+	y	:	If	\sy	:	\ay	+	\sy	:	EndIf
			\az	+	z	:	If	\sz	:	\az	+	\sz	:	EndIf

			cx	=	Cos(\ax)	:	cy	=	Cos(\ay)	:	cz	=	Cos(\az)
			sx	=	Sin(\ax)	:	sy	=	Sin(\ay)	:	sz	=	Sin(\az)

			; Rotate about x-axis
			y0 = \y * cx - \z * sx
			z0 = \y * sx + \z * cx

			; Rotate about y-axis
			x0  =	\x * cy + z0 * sy
			\pz =-\x * sy + z0 * cy

			; Rotate about z-axis
			\px = x0 * cz - y0 * sz
			\py = x0 * sz + y0 * cz

		EndWith
	Next

	SortStructuredList(RS_Ball3DObject()\Ball(), #PB_Sort_Ascending, OffsetOf(RS_Ball3DPosition\pz), TypeOf(RS_Ball3DPosition\pz))

EndProcedure
Procedure	Ball3DSpin(ID, Factor.f, BallID=#PB_All)

	; Set extra spin-speed (1.0 -> 100%)

	If	IsBall3D(ID)
		With	RS_Ball3DObject()\Ball()

			If	BallID	<=	#PB_All	; all balls

				ForEach	RS_Ball3DObject()\Ball()
					\sx	*	Factor
					\sy	*	Factor
					\sz	*	Factor
				Next

			ElseIf	BallID	<	ListSize(RS_Ball3DObject()\Ball())	; single ball

				SelectElement(RS_Ball3DObject()\Ball(), BallID)

				\sx	*	Factor
				\sy	*	Factor
				\sz	*	Factor

			EndIf

		EndWith
	EndIf

EndProcedure

CompilerIf	#IsC2D_Ball3D	=	2

	CompilerIf	#IsC2D_Anim
		Procedure	Ball3DAnim(ID, AnimID, BallID)

			If	IsBall3D(ID)	And	IsAnim(AnimID)	And	BallID	<	ListSize(RS_Ball3DObject()\Ball())
				With	RS_Ball3DObject()\Ball()

					SelectElement(RS_Ball3DObject()\Ball(), BallID)

					\IsAnim	=	#True
					\AnimID	=	AnimID

					\s	=	(RS_Anim()\w + RS_Anim()\h) * 0.25	; not real center!

				EndWith
			EndIf

		EndProcedure
	CompilerEndIf

	Procedure.f	Ball3DExplode(ID, Factor)

		; Explode ball-object, factor -> loopmode to reset (1/2)

		If	Factor	And	IsBall3D(ID)
			
			With	RS_Ball3DObject()
				If	\IsExplode	=	#Null
					
					\IsExplode		=	#ExplodeLoop	; Explode on
					\ExplodeStep	=	Factor			; 1 or 2
					
					ForEach	\Ball()
						
						\Ball()\ExplodeSx	=	\Ball()\sx	; Temporary spin xyz to restore when explode finished
						\Ball()\ExplodeSy	=	\Ball()\sy
						\Ball()\ExplodeSz	=	\Ball()\sz
						
						\Ball()\sx	=	#FastAngle	*	(1	-	Random(1)	*	2)
						\Ball()\sy	=	#FastAngle	*	(1	-	Random(1)	*	2)
						\Ball()\sz	=	#FastAngle	*	(1	-	Random(1)	*	2)
						
					Next
					
				EndIf
			EndWith
			
		EndIf

	EndProcedure
	Procedure		Ball3DMerge(ID1, ID2)

		ID1	=	IsBall3D(ID1)
		ID2	=	IsBall3D(ID2)

		If	ID1	And	ID2

			Protected	NewList	B3D_Temp.RS_Ball3DObject()

			AddElement(B3D_Temp())

			ChangeCurrentElement(RS_Ball3DObject(), ID1)
			CopyList(RS_Ball3DObject()\Ball(), B3D_Temp()\Ball())

			ChangeCurrentElement(RS_Ball3DObject(), ID2)
			MergeLists(B3D_Temp()\Ball(), RS_Ball3DObject()\Ball())

			FreeList(B3D_Temp())

		EndIf

	EndProcedure
	Procedure		Ball3DStars(ID, Number, Radius, Size, BallID=3, Rnd.f=0)

		; Create Ball3D as a 3D-Starfield

		; Number	=	# of stars
		; Radius	=	w/h/z	<=> 1 .. 127
		; Size	=	size of ballimage
		; BallID	=	0 .. 7 or -1 for random[7] image
		; Rnd		=	random ± x/y/z-offset

		Protected	*Ptr, *rnd.RS_Ball3D, *tmp.RS_Ball3D
		Protected	x.b, y.b, z.b, i, Count

		If	Number	<=	#Null	:	Number	=	100	:	EndIf

		; ByteAlign for -127..0..+127
		If	Radius	>	127	Or	Radius	<=	0	:	Radius	=	127	:	EndIf

		; Header = MagicID.Long + Count.Long .. Count[Ball]
		*Ptr	=	AllocateMemory(Number * SizeOf(RS_Ball3D) + SizeOf(Long) * 2)
		*tmp	=	*Ptr
		PokeL(*tmp, #ID_B3D0)	:	*tmp	+	SizeOf(Long)	; MagigID '3DB0'
		PokeL(*tmp, Number)		:	*tmp	+	SizeOf(Long)	; Number of balls

		While	Number	>	Count

			x	=	Random(Radius)	*	(1 - Random(1) <<	1)	; min/max -127 .. +127
			y	=	Random(Radius)	*	(1 - Random(1) << 1)
			z	=	Random(Radius)	*	(1 - Random(1) << 1)

			*rnd	=	*Ptr

			; ball already at position ->
			For	i	=	0	To	Count
				If	*rnd\x	=	x	And	*rnd\y	=	y	And	*rnd\z	=	z
					i	=	-1	:	Break
				EndIf
				*rnd	+	SizeOf(RS_Ball3D)
			Next

			If	i	>=	#Null

				If	BallID	<	#Null
					*tmp\ID	=	Random(#MAX_BALL)
				Else
					*tmp\ID	=	BallID	; BallImage (0 - 7)
				EndIf

				*tmp\x	=	x	; x-pos
				*tmp\y	=	y	; y-pos
				*tmp\z	=	z	; z-pos

				*tmp	+	SizeOf(RS_Ball3D)

				Count	+	1

			EndIf

		Wend

		Ball3DInit(ID, *Ptr, Size)	; create Ball3D-Object

		If	Rnd	; random-offsets for more nature-chaos?
			With	RS_Ball3DObject()
				ForEach	\Ball()
					\Ball()\x	+	Rnd * (1 - Random(1) * 2)
					\Ball()\y	+	Rnd * (1 - Random(1) * 2)
					\Ball()\z	+	Rnd * (1 - Random(1) * 2)
					\Ball()\px	=	\Ball()\x
					\Ball()\py	=	\Ball()\y
					\Ball()\pz	=	\Ball()\z
				Next
			EndWith
		EndIf

		FreeMemory(*Ptr)

	EndProcedure
	
CompilerEndIf

CompilerIf	#IsC2D_File
	Procedure	Ball3DLoadTheme(Path$, Format$="png")

		Protected	i, *Memory

		If	Len(Format$)	:	Format$	=	"."	+	Format$	:	EndIf	; default extension.png

		For	i	=	0	To	#MAX_BALL

			*Memory	=	FileLoad(Path$ + Str(i) + Format$)

			If	*Memory
				Ball3DImage(i, GdipCatch(#PB_Any, *Memory, MemorySize(*Memory)))
			EndIf

		Next

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = AAAA5
; EnableXP
; CompileSourceDirectory