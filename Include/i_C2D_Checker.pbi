;**********************************************
;- *** C2D CHECKER / 18.10.2018 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null
	
	XIncludeFile	"C2D_Enums.pbi"
	
; 	Structure	RS_Checker
; 		y.i
; 		h.i
; 		y_Start.i	; y - offset
; 		y_End.i		; y - offset + height
; 		ColorA.l		; first color
; 		ColorB.l		; second color
; 		w_Shift.i	; 1<<bitwidth of raster 8,16,32,64..256
; 		c_x.f			; Center Width
; 		c_y.f			; Center Height
; 		camX.f		; SpeedX
; 		camY.f		; SpeedY
; 	EndStructure

	Global	RS_Checker.RS_Checker

	Declare	CheckerColor(ColorA.l=#Red, ColorB.l=#White)
	Declare	CheckerDraw(SpeedY.f=1, SpeedX.f=0)
	Declare	CheckerInit(y, h, z=0, w_Shift=6)
	
CompilerEndIf

Procedure	CheckerInit(y, h, z=0, w_Shift=6)
	
	With	RS_Checker
		
		\y	=	y
		\h	=	h
		
		\y_Start		=	y	-	z	; z -> viewpoint of checker
		\y_End		=	\y_Start	+	h
		
		\ColorA		=	$FF0000FF	; red
		\ColorB		=	$FFFFFFFF	; white

		\w_Shift		=	1	<<	w_Shift	; bitwidth of raster 8,16,32,64...
		
		\camX			-	0.4	; correction of viewpoint
		
		\c_x			=	-(C2D\w	*	0.5)
		\c_y			=	-(C2D\h	*	0.5)
		
	EndWith
	
EndProcedure
Procedure	CheckerDraw(SpeedY.f=1, SpeedX.f=0)

	With	RS_Checker

; 		Protected	w.f, u.f, v, x, i, i_alt, x_alt
; 		Protected	x_max = C2D\w + \w_Shift << 1
; 		Protected	y = \y, y_Start = \y_Start
		
		Static	w.f, u.f, v, x, i, i_alt, x_alt
		Static	x_max, y, y_Start
		
		x_max		=	C2D\w + \w_Shift << 1
		y			=	\y
		y_Start	=	\y_Start

		\camY	+	SpeedY	; vertical speed
		\camX	+	SpeedX	; horizontal speed
		
		CompilerIf	#IsC2D_Checker	=	1	; draw backcolor?
			Box(0, \y, C2D\w, \h, \ColorB)
		CompilerEndIf

		FrontColor(\ColorA)

		While	y_Start	<	\y_End

			w	=	\c_y	/	y_Start
			u	=	\c_x	*	w	+	\camX
			v	=	C2D\w	*	w	-	\camY

			x		=	0
			x_alt	=	0

			While	x	<	x_max
				
				i	=	(Int(u) ! v) & \w_Shift
				
				If	i	<>	i_alt

					If	i
						LineXY(x_alt, y, x - 1, y)
					EndIf

					x_alt	=	x
					i_alt	=	i

				EndIf

				u	+	w
				x	+	1

			Wend

			y_Start	+	1
			y			+	1

		Wend

	EndWith

EndProcedure
Procedure	CheckerColor(ColorA.l=#Red, ColorB.l=#White)
	With	RS_Checker
		\ColorA	=	ColorA	:	If	\ColorA	&	$FF000000	=	0	:	\ColorA	|	$FF000000	:	EndIf	; 0 - RasterABGR
		\ColorB	=	ColorB	:	If	\ColorB	&	$FF000000	=	0	:	\ColorB	|	$FF000000	:	EndIf	; 1 - RasterABGR
	EndWith
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = g
; CompileSourceDirectory