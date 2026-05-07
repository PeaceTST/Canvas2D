;**********************************************
;- *** C2D Poly3D / 24.03.2020 ****************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_Poly3D	=	1

	XIncludeFile	"C2D_Enums.pbi"

	Structure	RS_Union
		StructureUnion
			a.a
			b.b
			w.w
			l.l
			q.q
		EndStructureUnion
	EndStructure

	Structure	RS_Poly
		ax.f
		ay.f
		az.f
	EndStructure
	Structure	RS_Polygon
		*Brush	; api hBrush
		*Pen		; api hPen
		*Clip		; api hClip
		*Memory	; default vertices
		*Finish	; end of *memory (+length)
		*Buffer	; cached vertices (zoom, scale)
		*Points	; calculated vertices
		*Rotate.RS_Poly	; calculated angles ax, ay, az
		*RotateFinish		; end of *rotate (+length)
		Count.i	; number of calculated vertices (*points)
		xOrg.f	; brush x-pos when clipped
		yOrg.f	; brush y-pos when clipped
	EndStructure

	Global	ID_Poly3D.C2D_ID
	Global	NewList	RS_Polygon.RS_Polygon()

	Declare	IsPoly3D(ID)
	Declare	Poly3DAngle(ID, x.f, y.f, z.f)
	Declare	Poly3DBrush(ID, *ImageID)
	Declare	Poly3DBrushMove(ID, x.f, y.f)
	Declare	Poly3DClip(x, y, w, h)
	Declare	Poly3DColor(ID, Color.l, Pen.l=#PB_Ignore, w=0)
	Declare	Poly3DDraw(ID, x.f=0, y.f=0)
	Declare	Poly3DLine(ID, x.f=0, y.f=0, Color.l=#Red)
	Declare	Poly3DFree(ID)
	Declare	Poly3DInit(ID, *Memory.Union, Color.l=#White, Pen.l=#PB_Ignore)
	Declare	Poly3DRotate(ID, x.f, y.f, z.f)
	Declare	Poly3DScale(ID, Ratio.f)
	Declare	Poly3DZoom(ID, w.f, h.f)

CompilerEndIf

Procedure	IsPoly3D(ID)

	; return ptr & sets element(id) or #null

	ID	=	ID_Poly3D\ID[ID]

	If	ID
		ChangeCurrentElement(RS_Polygon(), ID)
		ProcedureReturn	ID
	EndIf

EndProcedure
Procedure	Poly3DAngle(ID, x.f, y.f, z.f)
	If	IsPoly3D(ID)
		FillMemory(RS_Polygon()\Rotate, MemorySize(RS_Polygon()\Rotate))
		Poly3DRotate(ID, x, y, z)
	EndIf
EndProcedure
Procedure	Poly3DBrush(ID, Image)
	If	IsPoly3D(ID)
		With	RS_Polygon()
			If	\Brush	:	DeleteObject_(\Brush)	:	EndIf
			\Brush	=	CreatePatternBrush_(ImageID(Image))
		EndWith
	EndIf
EndProcedure
Procedure	Poly3DBrushMove(ID, x.f, y.f)
	ChangeCurrentElement(RS_Polygon(), ID_Poly3D\ID[ID])
	RS_Polygon()\xOrg	+	x
	RS_Polygon()\yOrg	+	y
EndProcedure
Procedure	Poly3DClip(ID, x, y, w, h)

	With	RS_Polygon()
		If	ID	=	#PB_All

			ForEach	RS_Polygon()
				If	\Clip	:	DeleteObject_(\Clip)	:	EndIf
				\Clip	=	CreateRectRgn_(x, y, x + w, y + h)
				\xOrg	=	x
				\yOrg	=	y
			Next

		ElseIf	IsPoly3D(ID)

			If	\Clip	:	DeleteObject_(\Clip)	:	EndIf

			\Clip	=	CreateRectRgn_(x, y, x + w, y + h)

			; adapt brush origins (Draw, Move)
			\xOrg	=	x
			\yOrg	=	y

		EndIf
	EndWith

EndProcedure
Procedure	Poly3DColor(ID, Color.l, Pen.l=#PB_Ignore, w=0)

	If	IsPoly3D(ID)
		With	RS_Polygon()
			
			If	Color	>=	0
				If	\Brush
					DeleteObject_(\Brush)
				EndIf
				\Brush	=	CreateSolidBrush_(Color & $00FFFFFF)
			EndIf

			If	Pen	<>	#PB_Ignore
				If	\Pen
					DeleteObject_(\Pen)
				EndIf
				\Pen	=	CreatePen_(#PS_SOLID, w, Pen & $00FFFFFF)
			EndIf

		EndWith
	EndIf

EndProcedure
Procedure	Poly3DDraw(ID, x.f=0, y.f=0)

	; Positions from center ± x / ± y

	ChangeCurrentElement(RS_Polygon(), ID_Poly3D\ID[ID])

	With	RS_Polygon()

		If	\Clip	; Clipping?
			SelectObject_(C2D\hDC, \Clip)
			SetBrushOrgEx_(C2D\hDC, \xOrg, \yOrg, #Null)
		EndIf

		SetViewportOrgEx_(C2D\hDC, C2D\cx + x, C2D\cy + y, #Null)

		SelectObject_(C2D\hDC, \Brush)
		SelectObject_(C2D\hDC, \Pen)

		Polygon_(C2D\hDC, \Points, \Count)

	EndWith

EndProcedure
Procedure	Poly3DDrawLine(ID, x.f=0, y.f=0, Color.l=#Red)

	; Positions from center ± x / ± y
	
	; saving the original pen-object
	Protected	*hPen	=	SelectObject_(C2D\hDC, GetStockObject_(#DC_PEN))

	ChangeCurrentElement(RS_Polygon(), ID_Poly3D\ID[ID])

	With	RS_Polygon()
		
		; clipping?
		If	\Clip	:	SelectObject_(C2D\hDC, \Clip)	:	EndIf
		
		; position center ± offsets
		SetViewportOrgEx_(C2D\hDC, C2D\cx + x, C2D\cy + y, #Null)

		; set the pen to color (no alpha)
		SetDCPenColor_(C2D\hDC, $00FFFFFF & Color)
		
		; draw object
		Polyline_(C2D\hDC, \Points, \Count)
		
		; restoring the original pen
		SelectObject_(C2D\hDC, *hPen)

	EndWith

EndProcedure
Procedure	Poly3DFree(ID)

	With	RS_Polygon()

		If	ID	<=	#PB_All

			ForEach	RS_Polygon()

				If	\Brush	:	DeleteObject_(\Brush)	:	EndIf
				If	\Pen		:	DeleteObject_(\Pen)		:	EndIf
				If	\Clip		:	DeleteObject_(\Clip)		:	EndIf

				If	\Memory	:	FreeMemory(\Memory)		:	EndIf
				If	\Buffer	:	FreeMemory(\Buffer)		:	EndIf
				If	\Points	:	FreeMemory(\Points)		:	EndIf
				If	\Rotate	:	FreeMemory(\Rotate)		:	EndIf

			Next

			FillMemory(@ID_Poly3D\ID, #MAX_ID	*	SizeOf(Integer))
			ClearList(RS_Polygon())

		Else

			If	IsPoly3D(ID)

				ID_Poly3D\ID[ID]	=	#Null

				If	\Brush	:	DeleteObject_(\Brush)	:	EndIf
				If	\Pen		:	DeleteObject_(\Pen)		:	EndIf
				If	\Clip		:	DeleteObject_(\Clip)		:	EndIf

				If	\Memory	:	FreeMemory(\Memory)		:	EndIf
				If	\Buffer	:	FreeMemory(\Buffer)		:	EndIf
				If	\Points	:	FreeMemory(\Points)		:	EndIf
				If	\Rotate	:	FreeMemory(\Rotate)		:	EndIf

				DeleteElement(RS_Polygon())

			EndIf

		EndIf

	EndWith

EndProcedure
Procedure	Poly3DInit(ID, *Memory.Union, Color.l=#White, Pen.l=#PB_Ignore)

	; return number of points.b, #null = error

	Protected	*Buffer.Long, Length

	Poly3DFree(ID)

	CompilerIf	#IsC2D_File
		If	*Memory\l	<>	#ID_P3D0	; Filename as *Ptr?
			*Memory	=	FileLoad(PeekS(*Memory))
		EndIf
	CompilerEndIf

	If	*Memory\l	<>	#ID_P3D0	:	ProcedureReturn	#Null	:	EndIf

	ID_Poly3D\ID[ID]	=	AddElement(RS_Polygon())	; @RS_Polygon()

	*Memory	+	SizeOf(Long)	; Skip Header -> Ptr to Size
	Length	=	*Memory\l		; Byte-Size
	*Memory	+	SizeOf(Long)	; Skip Size -> Ptr to vertices

	With	RS_Polygon()

		; fillcolor no alpha
		\Brush	=	CreateSolidBrush_($00FFFFFF & Color)

		; bordercolor?
		If	Pen	=	#PB_Ignore
			\Pen	=	CreatePen_(#PS_NULL, 0, 0)
		Else
			\Pen	=	CreatePen_(#PS_SOLID, 1, Pen)
		EndIf

		; bytes to longs unchanged defaults -> x0/y0/x1/y1
		\Memory	=	AllocateMemory(Length * SizeOf(Long))

		; copy default positions byte to long
		*Buffer	=	\Memory
		While	Length	>	0
			*Buffer\l	=	*Memory\b	; poly-vertices x0/y0/x1/y1
			*Buffer	+	SizeOf(Long)
			*Memory	+	SizeOf(Byte)
			Length	-	SizeOf(Byte)
		Wend

		Length	=	MemorySize(\Memory)

		\Buffer	=	AllocateMemory(Length)	:	MoveMemory(\Memory,	\Buffer,	Length)	; zoomed/scaled positions x0/y0/x1/y1
		\Points	=	AllocateMemory(Length)	:	MoveMemory(\Memory,	\Points,	Length)	; calculated positions (draw,scale,zoom,rotate)

		\Finish	=	\Memory	+	Length			; fast while/wend
		\Count	=	Length	/	SizeOf(POINT)	; number of x/y points

		\Rotate			=	AllocateMemory(\Count	*	SizeOf(RS_Poly))	; rotated-angles ax, ay, az
		\RotateFinish	=	\Rotate	+	MemorySize(\Rotate)					; fast while/wend

		ProcedureReturn	\Count

	EndWith

EndProcedure
Procedure	Poly3DRotate(ID, x.f, y.f, z.f)

	Static	ax, ay, az

	Static.f	x0, y0, z0
	Static.f	cx,sx, cy,sy, cz,sz

	Static	*Buffer.POINT
	Static	*Points.POINT
	Static	*Rotate.RS_Poly
	
	ChangeCurrentElement(RS_Polygon(), ID_Poly3D\ID[ID])
	
	*Buffer	=	RS_Polygon()\Buffer
	*Points	=	RS_Polygon()\Points
	*Rotate	=	RS_Polygon()\Rotate

	While	*Rotate	<	RS_Polygon()\RotateFinish
		With	*Rotate

 			\ax	+	x	:	ax	=	\ax	:	ax	&	#MAX_SIN
 			\ay	+	y	:	ay	=	\ay	:	ay	&	#MAX_SIN
 			\az	+	z	:	az	=	\az	:	az	&	#MAX_SIN

			cx	=	C2D\GCOS[ax]	:	cy	=	C2D\GCOS[ay]	:	cz	=	C2D\GCOS[az]
			sx	=	C2D\GSin[ax]	:	sy	=	C2D\GSin[ay]	:	sz	=	C2D\GSin[az]

			; Rotate about x-axis
			y0 = *Buffer\y * cx ; - \z * sx
			z0 = *Buffer\y * sx ; + \z * cx

			; Rotate about y-axis
			x0  = *Buffer\x * cy + z0 * sy
			;\pz =-\x * sy + z0 * cy

			; Rotate about z-axis
			*Points\x = x0 * cz - y0 * sz
			*Points\y = x0 * sz + y0 * cz

			*Buffer	+	SizeOf(POINT)
			*Points	+	SizeOf(POINT)
			*Rotate	+	SizeOf(RS_Poly)

		EndWith
	Wend

EndProcedure
Procedure	Poly3DScale(ID, Ratio.f)

	If	IsPoly3D(ID)
		With	RS_Polygon()

			Protected	*Memory.POINT	=	\Memory
			Protected	*Buffer.POINT	=	\Buffer

 			While	*Memory	<	\Finish

 				*Buffer\x	=	*Memory\x	*	Ratio
 				*Buffer\y	=	*Memory\y	*	Ratio

 				*Memory	+	SizeOf(POINT)
 				*Buffer	+	SizeOf(POINT)

 			Wend

 			MoveMemory(\Buffer, \Points, MemorySize(\Points))

		EndWith
	EndIf

EndProcedure
Procedure	Poly3DZoom(ID, w.f, h.f)

	If	IsPoly3D(ID)
		With	RS_Polygon()

			Protected	*Memory.POINT	=	\Memory
			Protected	*Buffer.POINT	=	\Buffer

 			While	*Memory	<	\Finish

 				*Buffer\x	=	*Memory\x	*	w
 				*Buffer\y	=	*Memory\y	*	h

 				*Memory	+	SizeOf(POINT)
 				*Buffer	+	SizeOf(POINT)

 			Wend

 			MoveMemory(\Buffer, \Points, MemorySize(\Points))

		EndWith
	EndIf

EndProcedure
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AAA-
; DisableDebugger
; CompileSourceDirectory