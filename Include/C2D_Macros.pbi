;********************************
;- C2D GLOBAL MACROS / 13.07.2020

Macro	UINT8(a)
	((((a)<<4)&$FF)|(((a)>>4)&$FF))
EndMacro
Macro	UINT16(a)
	((((a)<<8)&$FF00)|(((a)>>8)&$FF))
EndMacro
Macro	UINT32(a)
	((((a)&$FF)<<24)|(((a)&$FF00)<<8)|(((a)>>8)&$FF00)|(((a)>>24)&$FF))
EndMacro

Macro	ID_MAGIC(a,b,c,d)
	((a)|(b<<8)|(c<<16)|(d<<24))
EndMacro
Macro	ID_LONG(a,b,c,d)
	((a)|(b<<8)|(c<<16)|(d<<24))
EndMacro
Macro	ID_WORD(a,b)
	((a)|(b<<8))
EndMacro

; Time-Mode 0, 1, 2
CompilerIf	Defined(IsC2D, #PB_Module)
	CompilerSelect	IsC2D::#IsC2D_Time
		CompilerCase	1
			Macro	MA_TIME()	; best for C2D!
				timeGetTime_()
			EndMacro
		CompilerCase	2
			Macro	MA_TIME()	; fastest
				GetTickCount_()
			EndMacro
		CompilerDefault
			Macro	MA_TIME()	; PB native
				ElapsedMilliseconds()
			EndMacro
	CompilerEndSelect
CompilerEndIf

Macro	MA_ERROR(TEXT)
	Free()
	CompilerWarning	TEXT
	End
EndMacro

Macro	MA_RMP(N)	; RandomMinusPlus(±n)
	(N - Random(N) * 2)
EndMacro
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AA+
; CompileSourceDirectory