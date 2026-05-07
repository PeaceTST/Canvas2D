;**********************************************
;- *** C2D Pixel3D / 04.05.2022 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	;#IsC2D_Pixel3D	=	1

	XIncludeFile	"C2D_Enums.pbi"
	XIncludeFile	"i_C2D_Gdiplus.pbi"
	
	Structure	RS_Pixel
		x.f
		y.f
		z.f
		px.f
		py.f
		pz.f
		ax.f
		ay.f
		az.f
		c.l
	EndStructure
	Structure	RS_Pixel3D	Extends	RECT
		w.i
		h.i
		List	RS_Pixel.RS_Pixel()
	EndStructure
	
	Global	ID_Pixel3D.C2D_ID
	Global	NewList	RS_Pixel3D.RS_Pixel3D()
	
CompilerEndIf

Procedure	IsPixel3D(ID)

	; return ptr & set element(id) or #null

	ID	=	ID_Pixel3D\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Pixel3D(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	Pixel3DFree(ID)

	With	RS_Pixel3D()

		If	ID	<=	#PB_All
			
			FillMemory(@ID_Pixel3D\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Pixel3D())

		Else

			If	IsPixel3D(ID)
				DeleteElement(RS_Pixel3D())
				ID_Pixel3D\ID[ID]	=	#Null
			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	Pixel3DClip(ID, x, y, w, h)
	
	If	IsPixel3D(ID)
		With	RS_Pixel3D()
			\left		=	x
			\top		=	y
			\right	=	x	+	w	-	1
			\bottom	=	y	+	h	-	1
		EndWith
	EndIf
	
EndProcedure
Procedure	Pixel3DInit(ID, Image, Color.l=#Black)
	
	; Return = number of real used pixels, #Null = error
	
	Protected	x, y, c.l
	
	Pixel3DFree(ID)
	
	ID_Pixel3D\ID[ID]	=	AddElement(RS_Pixel3D())
	
	With	RS_Pixel3D()

		If	Color	&	$FF000000	=	#Null
			Color	|	$FF000000
		EndIf

		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_AllChannels)
		
		\w	=	OutputWidth()
		\h	=	OutputHeight()
		
		For	y	=	0	To	\h	-	1
			For	x	=	0	To	\w	-	1
				
				c	=	Point(x, y)

				If	c	<>	Color	And	c	&	$FF000000	; No Alpha = No Pixel
					
					AddElement(\RS_Pixel())
					
					\RS_Pixel()\c	=	c	&	$00FFFFFF
					\RS_Pixel()\x	=	x	-	Int(\w	*	0.5)
					\RS_Pixel()\y	=	y	-	Int(\h	*	0.5)
					
					\RS_Pixel()\px	=	\RS_Pixel()\x
					\RS_Pixel()\py	=	\RS_Pixel()\y
					
				EndIf

			Next
		Next
		
		StopDrawing()
		
		; Calculate half width/height from drawing on x/y & return used pixelnumber
		If	ListSize(\RS_Pixel())
			
			\w	=	0
			\h	=	0
			
			ForEach	\RS_Pixel()
				x	=	Abs(\RS_Pixel()\x)	:	If	x	>	\w	:	\w	=	x	:	EndIf
				y	=	Abs(\RS_Pixel()\y)	:	If	y	>	\h	:	\h	=	y	:	EndIf
			Next

			;\w	*	2
			;\h	*	2
			
			Pixel3DClip(ID, 0, 0, C2D\w, C2D\H)
			
			ProcedureReturn	ListSize(\RS_Pixel())
			
		Else	; Error - no pixels
			Pixel3DFree(ID)
		EndIf
		
	EndWith

	ProcedureReturn	#Null
	
EndProcedure
Procedure	Pixel3DRotate(ID, x.f, y.f, z.f)
	
	Static	ax, ay, az

	Static.f	x0, y0, z0
	Static.f	cx,sx, cy,sy, cz,sz

	ChangeCurrentElement(RS_Pixel3D(), ID_Pixel3D\ID[ID])

	ForEach	RS_Pixel3D()\RS_Pixel()
		With	RS_Pixel3D()\RS_Pixel()

 			\ax	+	x	:	ax	=	\ax	:	ax	&	#MAX_SIN
 			\ay	+	y	:	ay	=	\ay	:	ay	&	#MAX_SIN
 			\az	+	z	:	az	=	\az	:	az	&	#MAX_SIN

			cx	=	C2D\GCOS[ax]	:	cy	=	C2D\GCOS[ay]	:	cz	=	C2D\GCOS[az]
			sx	=	C2D\GSin[ax]	:	sy	=	C2D\GSin[ay]	:	sz	=	C2D\GSin[az]

			; Rotate about x-axis
			y0 = \y * cx ;- \z * sx
			z0 = \y * sx ;+ \z * cx

			; Rotate about y-axis
			x0  = \x * cy + z0 * sy
			;\pz =-\x * sy + z0 * cy

			; Rotate about z-axis
			\px = x0 * cz - y0 * sz
			\py = x0 * sz + y0 * cz

		EndWith
	Next

	;SortStructuredList(RS_Pixel3D()\RS_Pixel(), #PB_Sort_Ascending, OffsetOf(RS_Pixel\pz), TypeOf(RS_Pixel\pz))

EndProcedure
Procedure	Pixel3DAngle(ID, x.f, y.f, z.f)

	If	IsPixel3D(ID)

		ForEach	RS_Pixel3D()\RS_Pixel()
			With	RS_Pixel3D()\RS_Pixel()
				\ax	=	#Null
				\ay	=	#Null
				\az	=	#Null
			EndWith
		Next

		Pixel3DRotate(ID, x, y, z)

	EndIf

EndProcedure
Procedure	Pixel3DAxis(ID, x.f, y.f)

	If	IsPixel3D(ID)
		ForEach	RS_Pixel3D()\RS_Pixel()
			With	RS_Pixel3D()\RS_Pixel()
				\x	+	x
				\y	+	y
			EndWith
		Next
	EndIf

EndProcedure
Procedure	Pixel3DDraw(ID, x.f, y.f, Alpha=255)
	
	; Return: number of plotted pixels

	Protected	Count, px, py, px_tmp, py_tmp

	ChangeCurrentElement(RS_Pixel3D(), ID_Pixel3D\ID[ID])	;	fast element-change
	
	x	+	C2D\cx	; + center width
	y	+	C2D\cy	; + center heigth
	Alpha	<<	24

	With	RS_Pixel3D()
		ForEach	\RS_Pixel()
			
			; float to integer
			px	=	x + \RS_Pixel()\px
			py	=	y + \RS_Pixel()\py
			
			; check already plotted at x/y & inside clip?
			If	(px <> px_tmp Or py <> py_tmp)	And	(px >= \left And px < \right And py >= \top And py < \bottom)
				Plot(px, py, Alpha | \RS_Pixel()\c)
				Count	+	1	:	px_tmp	=	px	:	py_tmp	=	py
			EndIf

		Next
	EndWith

	ProcedureReturn	Count

EndProcedure
Procedure	Pixel3DDrawColor(ID, x.f, y.f, Color.l)
	
	; Bit faster but no return, monocolor only
	
	Protected	px, py, px_tmp, py_tmp
	
	ChangeCurrentElement(RS_Pixel3D(), ID_Pixel3D\ID[ID])
	
	FrontColor(Color)
	
	x	+	C2D\cx	; + center width
	y	+	C2D\cy	; + center heigth

	With	RS_Pixel3D()
		ForEach	\RS_Pixel()

			px	=	x + \RS_Pixel()\px
			py	=	y + \RS_Pixel()\py

			If	(px <> px_tmp Or py <> py_tmp)	And	(px >= \left And px < \right And py >= \top And py < \bottom)
				Plot(px, py)	:	px_tmp	=	px	:	py_tmp	=	py
			EndIf

		Next
	EndWith

EndProcedure
Procedure	Pixel3DW(ID)
	If	IsPixel3D(ID)
		ProcedureReturn	RS_Pixel3D()\w	; half width ±0
	EndIf
EndProcedure
Procedure	Pixel3DH(ID)
	If	IsPixel3D(ID)
		ProcedureReturn	RS_Pixel3D()\h	; half height ±0
	EndIf
EndProcedure
Procedure	Pixel3DCount(ID)
	If	IsPixel3D(ID)
		ProcedureReturn	ListSize(RS_Pixel3D()\RS_Pixel())
	EndIf
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = AA5
; DisableDebugger
; CompileSourceDirectory