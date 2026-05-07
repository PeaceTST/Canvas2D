;**********************************************
;- *** C2D FontRaw / 13.04.2026 ***************

EnableExplicit

; !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_FontRaw	=	1

	XIncludeFile	"C2D_Enums.pbi"

	Declare	FontRawInit(ID, *Memory.Union=#PB_Default, Length=0, zw=1, zh=1, Color.l=#White, Width=8, NumChar.a=#NUM_CHR)

CompilerEndIf

Procedure	FontRawInit(ID, *Memory.Union=#PB_Default, Length=0, zw=1, zh=1, Color.l=#White, Width=8, NumChar.a=#NUM_CHR)

	Protected	Image, x, y, w, h, bit_w, bit_h, bit_p.q
	
	FontFree(ID)	; free font if already initialized!

	; ****************************************
	; *Memory = Default -> RawFont = TopazNew?
	; ****************************************
	CompilerIf	#IsC2D_Topaz
		If	*Memory	<=	#Null	And	Length	<=	#Null
			*Memory	=	?c2d_raw_fontS
			Length	=	?c2d_raw_fontE
		EndIf
	CompilerEndIf
	
	; ****************************************
	; Length = Default -> RawFont = @FileName?
	; ****************************************
	CompilerIf	#IsC2D_File
		If	Length	<=	#Null	; Filename as *Ptr
			*Memory	=	FileLoad(PeekS(*Memory))
			Length	=	MemorySize(*Memory)
		EndIf
	CompilerEndIf

	; *****************************************
	; Init / Create RawFont-Bitmap (8..64 bits)
	; *****************************************
	If	*Memory
		
		ID_Font\ID[ID]	=	AddElement(RS_FontMap())	; -> @RS_FontMap()

		If	Length	<	*Memory	:	Length	+	*Memory	:	EndIf	; Length = *Finish

		; Header.ASCII: 'R', 'F', BitWidth, BitRows
		If	*Memory\w	=	#ID_RF

			*Memory	+	SizeOf(Word)	; Skip RawFont-HeaderID 'RF'

			w	=	*Memory\a	:	*Memory	+	SizeOf(Ascii)	; BitWidth
			h	=	*Memory\a	:	*Memory	+	SizeOf(Ascii)	; BitRows

		Else	; No header -> Amiga Font2Raw (F2R)

			w	=	Width	; max. horizontal bits(1..64) = BitWidth
			h	=	(Length	-	*Memory)	/	NumChar	; current 64 chars only

			If			w	>	32	:	h	/	SizeOf(Quad)	; Quad
			ElseIf	w	>	16	:	h	/	SizeOf(Long)	; Long
			ElseIf	w	>	8	:	h	/	SizeOf(Word)	; Word
			EndIf

		EndIf

		; Dimension 8 * w x 8 * h -> 0 .. 63 (64) chars
		CompilerIf	#PB_Compiler_Version	>=	630
			Image	=	CreateImage(#PB_Any, w * #FontX * zw, h * #FontY * zh, 32, #PB_Image_TransparentBlack)
		CompilerElse
			Image	=	CreateImage(#PB_Any, w * #FontX * zw, h * #FontY * zh, 32, #PB_Image_Transparent)
		CompilerEndIf

		StartDrawing(ImageOutput(Image))
		DrawingMode(#PB_2DDrawing_AlphaBlend)
		FrontColor($FF000000|Color)

		For	y	=	0	To	#FontY - 1
			For	x	=	0	To	#FontX - 1
				For	bit_h	=	0	To	h - 1

					If			w	<=	8	:	bit_p	=	*Memory\a	:	*Memory	+	SizeOf(Ascii)
					ElseIf	w	<=	16	:	bit_p	=	*Memory\w	:	*Memory	+	SizeOf(Word)
					ElseIf	w	<=	32	:	bit_p	=	*Memory\l	:	*Memory	+	SizeOf(Long)
					Else					:	bit_p	=	*Memory\q	:	*Memory	+	SizeOf(Quad)
					EndIf

					; set pixel if bit = true
					For	bit_w	=	0	To	w - 1
						If	bit_p & 1 << (w - bit_w - 1)
							Box((x * w + bit_w) * zw, (y * h + bit_h) * zh, zw, zh)
						EndIf
					Next

					; out of memory? (not a 8x8 charmap)
					If	*Memory	>=	Length
						Break	3
					EndIf

				Next
			Next
		Next

		StopDrawing()

		; *****************************************************
		; Create 8x8 Char-FontMap to access with font functions
		; *****************************************************
		With	RS_FontMap()

			\TabW	=	3	; Default Tabwidth = 3 x ChrW

			\ChrW	=	ImageWidth(Image)		/	#FontX
			\ChrH	=	ImageHeight(Image)	/	#FontY

			\GapW	=	\ChrW
			\GapH	=	\ChrH

			While	ListSize(\Char())	<	#NUM_CHR

				AddElement(\Char())	:	\ChrID[ListIndex(\Char())]	=	@\Char()	; for fast element-change

				\Char()\i	=	GrabImage(Image, #PB_Any,
				         	 	          (ListIndex(\Char()) % #FontX) * \ChrW,
				         	 	          (ListIndex(\Char()) / #FontX) * \ChrH,
				         	 	          \ChrW, \ChrH)
			Wend

		EndWith

		FreeImage(Image)

		ProcedureReturn	#True

	EndIf

EndProcedure

;{ Default Amiga 1200 TopazNew.font / 8 }
CompilerIf	#IsC2D_Topaz
	DataSection
		c2d_raw_fontS:
		Data.a	'R', 'F', 8, 7	; Width x Height bitwise of RawFont TopazNew 8 x 7
		Data.a	%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000	; " "
		Data.a	%00110000,%00110000,%00110000,%00110000,%00110000,%00000000,%00110000	; "!"
		Data.a	%01101100,%01101100,%00000000,%00000000,%00000000,%00000000,%00000000	; """
		Data.a	%01101100,%01101100,%11111110,%01101100,%11111110,%01101100,%01101100	; "#"
		Data.a	%00110000,%01111100,%11000000,%01111000,%00001100,%11111000,%00110000	; "$"
		Data.a	%00000000,%01100110,%10101100,%11011000,%00110110,%01101010,%11001100	; "%"
		Data.a	%00111000,%01101100,%01101000,%01110110,%11011100,%11001110,%01111011	; "&"
		Data.a	%00110000,%00110000,%01100000,%00000000,%00000000,%00000000,%00000000	; "'"
		Data.a	%00001100,%00011000,%00110000,%00110000,%00110000,%00011000,%00001100	; "("
		Data.a	%01100000,%00110000,%00011000,%00011000,%00011000,%00110000,%01100000	; ")"
		Data.a	%00000000,%01100110,%00111100,%11111111,%00111100,%01100110,%00000000	; "*"
		Data.a	%00000000,%00011000,%00011000,%01111110,%00011000,%00011000,%00000000	; "+"
		Data.a	%00000000,%00000000,%00000000,%00000000,%00110000,%00110000,%01100000	; ","
		Data.a	%00000000,%00000000,%00000000,%01111110,%00000000,%00000000,%00000000	; "-"
		Data.a	%00000000,%00000000,%00000000,%00000000,%00000000,%01100000,%01100000	; "."
		Data.a	%00000011,%00000110,%00001100,%00011000,%00110000,%01100000,%11000000	; "/"
		Data.a	%01111000,%11001100,%11011100,%11111100,%11101100,%11001100,%01111000	; "0"
		Data.a	%00110000,%01110000,%11110000,%00110000,%00110000,%00110000,%00110000	; "1"
		Data.a	%01111000,%11001100,%00001100,%00011000,%00110000,%01100000,%11111100	; "2"
		Data.a	%01111000,%11001100,%00001100,%00111000,%00001100,%11001100,%01111000	; "3"
		Data.a	%00011100,%00111100,%01101100,%11001100,%11111110,%00001100,%00001100	; "4"
		Data.a	%11111100,%11000000,%11111000,%00001100,%00001100,%11001100,%01111000	; "5"
		Data.a	%00111000,%01100000,%11000000,%11111000,%11001100,%11001100,%01111000	; "6"
		Data.a	%11111100,%00001100,%00001100,%00011000,%00110000,%00110000,%00110000	; "7"
		Data.a	%01111000,%11001100,%11001100,%01111000,%11001100,%11001100,%01111000	; "8"
		Data.a	%01111000,%11001100,%11001100,%01111100,%00001100,%00011000,%01110000	; "9"
		Data.a	%00000000,%01100000,%01100000,%00000000,%00000000,%01100000,%01100000	; ":"
		Data.a	%00110000,%00110000,%00000000,%00000000,%00110000,%00110000,%01100000	; ";"
		Data.a	%00000000,%00000110,%00011000,%01100000,%00011000,%00000110,%00000000	; "<"
		Data.a	%00000000,%00000000,%01111110,%00000000,%01111110,%00000000,%00000000	; "="
		Data.a	%00000000,%01100000,%00011000,%00000110,%00011000,%01100000,%00000000	; ">"
		Data.a	%01111000,%11001100,%00001100,%00011000,%00110000,%00000000,%00110000	; "?"
		Data.a	%01111100,%11000110,%11011110,%11010110,%11011110,%11000000,%01111000	; "@"
		Data.a	%01111000,%11001100,%11001100,%11111100,%11001100,%11001100,%11001100	; "A"
		Data.a	%11111000,%11001100,%11001100,%11111000,%11001100,%11001100,%11111000	; "B"
		Data.a	%00111100,%01100000,%11000000,%11000000,%11000000,%01100000,%00111100	; "C"
		Data.a	%11110000,%11011000,%11001100,%11001100,%11001100,%11011000,%11110000	; "D"
		Data.a	%11111100,%11000000,%11000000,%11110000,%11000000,%11000000,%11111100	; "E"
		Data.a	%11111100,%11000000,%11000000,%11110000,%11000000,%11000000,%11000000	; "F"
		Data.a	%01111000,%11001100,%11000000,%11011100,%11001100,%11001100,%01111100	; "G"
		Data.a	%11001100,%11001100,%11001100,%11111100,%11001100,%11001100,%11001100	; "H"
		Data.a	%01111000,%00110000,%00110000,%00110000,%00110000,%00110000,%01111000	; "I"
		Data.a	%00001100,%00001100,%00001100,%00001100,%00001100,%11001100,%01111000	; "J"
		Data.a	%11000110,%11001100,%11011000,%11110000,%11011000,%11001100,%11000110	; "K"
		Data.a	%11000000,%11000000,%11000000,%11000000,%11000000,%11000000,%11111100	; "L"
		Data.a	%11000110,%11101110,%11111110,%11010110,%11000110,%11000110,%11000110	; "M"
		Data.a	%11000110,%11100110,%11110110,%11011110,%11001110,%11000110,%11000110	; "N"
		Data.a	%01111000,%11001100,%11001100,%11001100,%11001100,%11001100,%01111000	; "O"
		Data.a	%11111000,%11001100,%11001100,%11111000,%11000000,%11000000,%11000000	; "P"
		Data.a	%01111000,%11001100,%11001100,%11001100,%11001100,%11011100,%01111110	; "Q"
		Data.a	%11111000,%11001100,%11001100,%11111000,%11011000,%11001100,%11001100	; "R"
		Data.a	%01111000,%11001100,%11100000,%01111000,%00011100,%11001100,%01111000	; "S"
		Data.a	%11111100,%00110000,%00110000,%00110000,%00110000,%00110000,%00110000	; "T"
		Data.a	%11001100,%11001100,%11001100,%11001100,%11001100,%11001100,%01111000	; "U"
		Data.a	%11001100,%11001100,%11001100,%11001100,%01111000,%01111000,%00110000	; "V"
		Data.a	%11000110,%11000110,%11000110,%11010110,%11111110,%11101110,%11000110	; "W"
		Data.a	%11001100,%11001100,%01111000,%00110000,%01111000,%11001100,%11001100	; "X"
		Data.a	%11001100,%11001100,%01111000,%00110000,%00110000,%00110000,%00110000	; "Y"
		Data.a	%11111110,%00001100,%00011000,%00110000,%01100000,%11000000,%11111110	; "Z"
		Data.a	%00111100,%00110000,%00110000,%00110000,%00110000,%00110000,%00111100	; "["
		Data.a	%11000000,%01100000,%00110000,%00011000,%00001100,%00000110,%00000011	; "\"
		Data.a	%00111100,%00001100,%00001100,%00001100,%00001100,%00001100,%00111100	; "]"
		Data.a	%00010000,%00111000,%01101100,%11000110,%00000000,%00000000,%00000000	; "^"
		Data.a	%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%11111110	; "_"
		c2d_raw_fontE:
	EndDataSection
CompilerEndIf
;}
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = A+
; DisableDebugger
; CompileSourceDirectory