;===================================================
; C2D:: Global macros for private use
;===================================================
Macro	MA_GSin(ANGLE)		; Float
	C2D::C2D\GSin[Int(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GCos(ANGLE)		; Float
	C2D::C2D\GCOS[Int(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GSinI(ANGLE)	; Integer
	C2D::C2D\GSin[(ANGLE) & C2D::#MAX_SIN]
EndMacro
Macro	MA_GCosI(ANGLE)	; Integer
	C2D::C2D\GCOS[(ANGLE) & C2D::#MAX_SIN]
EndMacro

Macro	MA_XC2D()	; C2D Version$
	C2D::#C2D_VER$
EndMacro
Macro	MA_XOS()		; OS Version$
	C2D::#C2D_XOS$
EndMacro
Macro	MA_XPB()		; PB Version$
	C2D::#C2D_XPB$
EndMacro

Macro	MA_C2DOS(TITLE)	; C2D:: + OS$
	"C2D::" + TITLE + " (" + MA_XOS() + ")"
EndMacro
Macro	MA_C2DPB(TITLE)	; C2D:: + PB$ + OS$
	"C2D::" + TITLE + " / PB " + MA_XPB() + " (" + MA_XOS() + ")"
EndMacro

CompilerIf	Defined(SCAL_PATH$, #PB_Constant)	=	0
	#SCAL_PATH$	=	"..\Tools\SCAL\"
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x86)
; CursorPosition = 31
; Folding = A5
; CompileSourceDirectory