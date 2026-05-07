; Formats to include in IsXUP::Module / 13.08.2019

EnumerationBinary
	#XUP_APLB	;	-> Un/Pack aPLib
	#XUP_BLZ1	;	-> Un/Pack BriefLZ (PB-Native)
	#XUP_BZP2	;	->	Un/Pack BZip2 & #XUP_XPKF->BZP2
	#XUP_FILE	;	->	*Memory = @File$ (Length must be #Null)
	#XUP_FIMP	;	->	Un/Pack Amiga FileImploder & #XUP_XPKF->FIMP/ATN!
	#XUP_GZIP	;	->	Un/Pack (G)Zip & #XUP_XPKF->GZIP
	#XUP_JCG1	;	-> Un/Pack JCalG1 (x86)
	#XUP_LZMA	;	-> Un/Pack LZMA
	#XUP_NONE	;	->	Unpack #XUP_XPKF->NONE
	#XUP_PACK	;	->	Use packing (APLB,BZP2,FIMP,GZIP,JCG1,LZMA)
	#XUP_PP20	;	->	Unpack Amiga PowerPacker Data & #XUP_XPKF->PWPK
	#XUP_PURE	;	-> Use native PB BZP2 & GZIP
	#XUP_PX20	;	->	Decode/Crack Amiga PowerPacker Crypted
	#XUP_SQSH	;	->	Unpack #XUP_XPKF->SQSH
	#XUP_UICE	;	->	Unpack Atari Ice2.4 / Atomik 3.5
	#XUP_XPKF	;	-> Use Amiga XPK Unpacking
EndEnumeration
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 18
; Folding = -
; DisableDebugger
; CompileSourceDirectory