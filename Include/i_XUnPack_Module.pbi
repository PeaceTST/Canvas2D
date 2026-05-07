; ***********************************************************
; Name:			XUP::XUnPack Module v19.11.21 [eXtended UnPack]
; -----------------------------------------------------------
; Description:	Custom module to pack/unpack
; Author:		Peace^TST
; Code:			Purebasic v5.70 LTS (x86-64)
; Create:		21.11.2019 10:50
; Home:			https://testaware.wordpress.com
; ***********************************************************

; https://www.7-zip.org/sdk.html
; http://www.ibsensoftware.com/products_aPLib.html
; https://github.com/jibsen/tinf/blob/master/src/tinfzlib.c
; https://www.exotica.org.uk/wiki/Imploder_file_formats

CompilerIf	Defined(IsXUP, #PB_Module)	=	0
	DeclareModule	IsXUP

		IncludeFile	"i_XUnPack_Types.pbi"
		
		; EnumerationBinary
		; 	#XUP_APLB	;	-> Un/Pack aPLib
		; 	#XUP_BLZ1	;	-> Un/Pack BriefLZ (PB-Native)
		; 	#XUP_BZP2	;	->	Un/Pack BZip2 & #XUP_XPKF->BZP2
		; 	#XUP_FILE	;	->	*Memory = @File$ (Length must be #Null)
		; 	#XUP_FIMP	;	->	Un/Pack Amiga FileImploder & #XUP_XPKF->FIMP/ATN!
		; 	#XUP_GZIP	;	->	Un/Pack (G)Zip & #XUP_XPKF->GZIP
		; 	#XUP_JCG1	;	-> Un/Pack JCalG1 (x86)
		; 	#XUP_LZMA	;	-> Un/Pack LZMA
		; 	#XUP_NONE	;	->	Unpack #XUP_XPKF->NONE
		; 	#XUP_PACK	;	->	Use packing (APLB,BZP2,FIMP,GZIP,JCG1,LZMA)
		; 	#XUP_PP20	;	->	Unpack Amiga PowerPacker Data & #XUP_XPKF->PWPK
		; 	#XUP_PURE	;	-> Use native PB BZP2 & GZIP
		; 	#XUP_PX20	;	->	Decode/Crack Amiga PowerPacker Crypted
		; 	#XUP_SQSH	;	->	Unpack #XUP_XPKF->SQSH
		; 	#XUP_UICE	;	->	Unpack Atari Ice2.4 / Atomik 3.5
		; 	#XUP_XPKF	;	-> Use Amiga XPK Unpacking
		; EndEnumeration

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			#XUP_FLAGS	=	#PB_All	!	#XUP_JCG1	; JCalG1 not supported in x64
		CompilerElse
			;#XUP_FLAGS	=	#PB_All	!	(#XUP_PACK|#XUP_PX20)	; no packing, no decrypt
			#XUP_FLAGS	=	#PB_All	; default -> use all!
		CompilerEndIf

	EndDeclareModule
CompilerEndIf

Module	IsXUP
	; Warn if using x86 static libs on x64 (#XUP_JCG1)
	CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
		CompilerIf	#XUP_FLAGS	&	#XUP_JCG1
			CompilerWarning	"#XUP_JCG1 - x86 support only - set #XUP_FLAGS ! #XUP_JCG1"
			End
		CompilerEndIf
	CompilerEndIf
EndModule

DeclareModule	XUP
	
	#XUP_VER$	=	"19.11.21"
	
	; ----------------------------------------------------------
	; /* flag-constants -> include to unconfuse code */
	; ----------------------------------------------------------
	IncludeFile	"i_XUnPack_Types.pbi"

	#XUP_FLAGS	=	IsXUP::#XUP_FLAGS	; *** Main combined flags (Module IsXUP)!

	IncludePath	"PackLibs\"	; *** Set here default-path of static libs

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
	
	#UNKNOWN_SIZE	=	128	; Unsure -> factor for unknown unpacked size (BZP2,GZIP)

	;/* Amiga XPK MASTER & Compressors */
	#ID_XPKF	=	ID_MAGIC('X','P','K','F')	; XPK ID		->	Header
	#ID_BZP2	=	ID_MAGIC('B','Z','P','2')	; XPK BZP2 	->	BZip2
	#ID_GZIP	=	ID_MAGIC('G','Z','I','P')	; XPK GZIP	->	GnuZip
	#ID_IMPL	=	ID_MAGIC('I','M','P','L')	; XPK IMPL 	->	Imploder
	#ID_NONE	=	ID_MAGIC('N','O','N','E')	; XPK NONE 	->	Not packed (buggy)
	#ID_PWPK	=	ID_MAGIC('P','W','P','K')	; XPK PWPK 	->	PowerPacker (xpkPWPK v0.90)
	#ID_SQSH	=	ID_MAGIC('S','Q','S','H')	; XPK SQSH 	->	Squash

	;/* xupFIMP.lib */
	#ID_FIMP	=	ID_MAGIC('I','M','P','!')	; FImp (Amiga FileImploder)
	#ID_ATNI	=	ID_MAGIC('A','T','N','!')	; FImp Static Lib (no checksum)
	#ID_9CDR	=	ID_MAGIC('9','C','D','R')	; FImp Custom ID
	#ID_DUPA	=	ID_MAGIC('D','u','p','a')
	#ID_FLTI	=	ID_MAGIC('F','L','T','!')
	#ID_IFHC	=	ID_MAGIC('I','F','H','C')
	#ID_MADE	=	ID_MAGIC('M','A','D','E')
	#ID_M_H_	=	ID_MAGIC('M','.','H','.')
	#ID_PARA	=	ID_MAGIC('P','A','R','A')

	;/* xupPP20.lib */
	#ID_PP20	=	ID_MAGIC('P','P','2','0')	; PowerPacker Data
	#ID_PP11	=	ID_MAGIC('P','P','1','1')	; PowerPacker v1.x (very old/clone?)
	#ID_PPbk	=	ID_MAGIC('P','P','b','k')	; PowerPacker AMOSPro Bank
	#ID_PPLS	=	ID_MAGIC('P','P','L','S')	; PowerPacker LoadSegement Data
	#ID_PX20	=	ID_MAGIC('P','X','2','0')	; PowerPacker Crypted

	;/* lzma.lib */
	#ID_LZMA	=	ID_MAGIC('L','Z','M','A')	; LZMA ID (Pseudo for ']')
	
	;/* aPLib.lib */
	#ID_APLB	=	ID_MAGIC('A','P','L','B')	; aPLib ID

	;/* bzip2.lib */
	#ID_BZ	=	ID_WORD('B','Z')				; Magic BZip2 Header WORD
	
	;/* BriefLZ PB-Native */
	#ID_BLZ1	=	ID_MAGIC('1','z','l','b')	; 1zlb ID (why not BLZ1?)

	;/* JCalG1 PB-Native */
	#ID_JCG1	=	ID_MAGIC('J','C','G','1')	; JCalG1 ID
	#ID_JC	=	ID_WORD('J','C')				; Magic JCalG1 Header WORD
	
	;/* xupUICE.lib */
	#ID_UICE	=	ID_MAGIC('U','I','C','E')	; ID
	#ID_ATM5	=	ID_MAGIC('A','T','M','5')	; Atari Atomik Packer 3.5
	#ID_ICE1	=	ID_MAGIC('I','c','e','!')	; Atari Ice! Packer 2.1
	#ID_ICE4	=	ID_MAGIC('I','C','E','!')	; Atari ICE! Packer 2.4

	;/* private structures */
	Structure	RS_Union
		StructureUnion
			a.a
			w.w
			l.l
		EndStructureUnion
	EndStructure
	Structure	RS_XID
		ID.l		; Packed Header ID
		Size.l	; Unpacked size
	EndStructure
	Structure	RS_XPK
		; Amiga XPK Header - small, don't change order!
		ID.l		; XPKF
		InLen.l	; Size - 8
		Mode.l	; SQSH, IMPL..
		OutLen.l	; Unpacked size
	EndStructure
	
	Structure	RS_XUP
		ID.l			; Packed header #ID_MAGIC or #Null on error
		*InBuf		; *Memory to Un/Pack or @File (InSize must be 0)
		InSize.i		; Size of *Memory to Un/Pack, 0 = @File
		*OutBuf		; Un/Packed *Memory
		OutSize.i	; Un/Packed Size
		PassKey.l	; PX20 PasswordKey
		CheckKey.w	; PX20 FileKey
		*IsFile		; FlagMemory for Load()
		*Memory		; FileMemory
		Length.i		; FileSize (Memory)
	EndStructure
	Global	RS_XUP.RS_XUP
	
	;/* xupFIMP.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_FIMP

		;/* FIMP lib error codes */
		#ERR_FIMP_NONE					=	0
		#ERR_FIMP_TOOSHORT			=	-1
		#ERR_FIMP_UNKNOWNFORMAT		=	-2
		#ERR_FIMP_COMPNOTEVEN		=	-3
		#ERR_FIMP_COMPTOOSHORT		=	-4
		#ERR_FIMP_NOTENOUGHDATA		=	-5
		#ERR_FIMP_OUTPUTLTINPUT		=	-6
		#ERR_FIMP_CANNOTALLOCMEM	=	-7
		#ERR_FIMP_CANNOTDEPLODE		=	-8

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	"xupFIMP_x64.lib"
				FIMP_Unpack(*src, src_len, *dst, dst_len)	As	"Explode"
				FIMP_Pack(*src, src_len, level)				As	"Implode"
			EndImport
		CompilerElse
			ImportC	"xupFIMP_x86.lib"
				FIMP_Unpack(*src, src_len, *dst, dst_len)	As	"_Explode"
				FIMP_Pack(*src, src_len, level)				As	"_Implode"
			EndImport
		CompilerEndIf

	CompilerEndIf

	;/* xupPP20.lib */
	CompilerIf	#XUP_FLAGS	&	(#XUP_PP20|#XUP_PX20)

		;/* PP20 lib error codes */
		#PPERR_OK			=	 0	; no error
		#PPERR_ARGS			=	-1	; bad arguments to function
		#PPERR_OPEN			=	-2	; error opening file
		#PPERR_READ			=	-3	; error reading from file
		#PPERR_SEEK			=	-4	; error seeking in file
		#PPERR_NOMEMORY	=	-5	; out of memory
		#PPERR_DATAFORMAT	=	-6	; error in data format
		#PPERR_PASSWORD	=	-7	; bad or missing password
		#PPERR_DECRUNCH	=	-8	; error decrunching data

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	"xupPP20_x64.lib"
				PP20_Unpack(*src, *dst, src_len, dst_len, password.p-ascii)				As	"ppDecrunchMemory"
				PP20_GetCrunchMode(*src)															As	"ppGetCrunchMode"
				PP20_GetDecrunchSize(*src, src_len)												As	"ppGetDecrunchSize"
				PX20_CalcPasskey(password.p-ascii)												As	"ppCalcPasskey"
				PX20_CalcChecksum(password.p-ascii)												As	"ppCalcChecksum"
				PX20_DecodeMemory(*src, *dst, src_len, dst_len, passkey.l, *restore)	As	"ppDecodeMemory"
			EndImport
		CompilerElse
			ImportC	"xupPP20_x86.lib"
				PP20_Unpack(*src, *dst, src_len, dst_len, password.p-ascii)				As	"_ppDecrunchMemory"
				PP20_GetCrunchMode(*src)															As	"_ppGetCrunchMode"
				PP20_GetDecrunchSize(*src, src_len)												As	"_ppGetDecrunchSize"
				PX20_CalcPasskey(password.p-ascii)												As	"_ppCalcPasskey"
				PX20_CalcChecksum(password.p-ascii)												As	"_ppCalcChecksum"
				PX20_DecodeMemory(*src, *dst, src_len, dst_len, passkey.l, *restore)	As	"_ppDecodeMemory"	; crack memory
			EndImport
		CompilerEndIf

	CompilerEndIf

	;/* xupSQSH.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_SQSH

		;/* XPK SQSH lib error codes */
		#XPKERR_OK				=	0
		#XPKERR_NOXPK			=	-1
		#XPKERR_UNKNOWNCOMP	=	-2
		#XPKERR_FORMAT			=	-3
		#XPKERR_CHKSUM			=	-4
		#XPKERR_UNKNOWNCHUNK	=	-5

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
 			Import	"xupSQSH_x64.lib"
				xpkSQSH_Check(*src, *srclen, *dstlen)	As	"xpk_sqsh_check"
				xpkSQSH_Unpack(*src, *dst)					As	"xpk_sqsh_unpack"
			EndImport
		CompilerElse
 			ImportC	"xupSQSH_x86.lib"
				xpkSQSH_Check(*src, *srclen, *dstlen)	As	"_xpk_sqsh_check"
				xpkSQSH_Unpack(*src, *dst)					As	"_xpk_sqsh_unpack"
			EndImport
		CompilerEndIf

	CompilerEndIf

	;/* xupUICE.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_UICE
		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	"xupUICE_x64.lib"
				; Atomik Packer 3.5
				atm_35_header(src)		As	"atm_35_header"
				atm_35_packedsize(src)	As	"atm_35_packedsize"
				atm_35_origsize(src)		As	"atm_35_origsize"
				atm_35_depack(src,dest)	As	"atm_35_depack"
				; Pack Ice 2.1
				ice_21_header(src)		As	"ice_21_header"
				ice_21_packedsize(src)	As	"ice_21_packedsize"
				ice_21_origsize(src)		As	"ice_21_origsize"
				ice_21_depack(src,dest)	As	"ice_21_depack"
				; Pack ICE 2.4
				ice_24_header(src)		As	"ice_24_header"
				ice_24_packedsize(src)	As	"ice_24_packedsize"
				ice_24_origsize(src)		As	"ice_24_origsize"
				ice_24_depack(src,dest)	As	"ice_24_depack"
			EndImport
		CompilerElse
			ImportC	"xupUICE_x86.lib"
				; Atomik Packer 3.5
				atm_35_header(src)		As	"_atm_35_header"
				atm_35_packedsize(src)	As	"_atm_35_packedsize"
				atm_35_origsize(src)		As	"_atm_35_origsize"
				atm_35_depack(src,dest)	As	"_atm_35_depack"
				; Pack Ice 2.1
				ice_21_header(src)		As	"_ice_21_header"
				ice_21_packedsize(src)	As	"_ice_21_packedsize"
				ice_21_origsize(src)		As	"_ice_21_origsize"
				ice_21_depack(src,dest)	As	"_ice_21_depack"
				; Pack ICE 2.4
				ice_24_header(src)		As	"_ice_24_header"
				ice_24_packedsize(src)	As	"_ice_24_packedsize"
				ice_24_origsize(src)		As	"_ice_24_origsize"
				ice_24_depack(src,dest)	As	"_ice_24_depack"
			EndImport
		CompilerEndIf
	CompilerEndIf

	;/* bzip2.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_BZP2

		;/* BZP2 lib error codes */
		#BZ_OK					=	0
		#BZ_RUN_OK				=	1
		#BZ_FLUSH_OK			=	2
		#BZ_FINISH_OK			=	3
		#BZ_STREAM_END			=	4
		#BZ_SEQUENCE_ERROR	=	-1
		#BZ_PARAM_ERROR		=	-2
		#BZ_MEM_ERROR			=	-3
		#BZ_DATA_ERROR			=	-4
		#BZ_DATA_ERROR_MAGIC	=	-5
		#BZ_IO_ERROR			=	-6
		#BZ_UNEXPECTED_EOF	=	-7
		#BZ_OUTBUFF_FULL		=	-8
		#BZ_CONFIG_ERROR		=	-9

		CompilerIf	#XUP_FLAGS	&	#XUP_PURE
			#LIB_BZP2_X64$	=	"libbzip2.lib"
			#LIB_BZP2_X86$	=	"libbzip2.lib"
		CompilerElse
			#LIB_BZP2_X64$	=	"bzip2_x64.lib"
			#LIB_BZP2_X86$	=	"bzip2_x86.lib"
		CompilerEndIf

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	#LIB_BZP2_X64$
				BZP2_Unpack(*dst, *dst_len, *src, src_len, small, verbosity)				As	"BZ2_bzBuffToBuffDecompress"
				BZP2_Pack(*dst, *dst_len, *src, src_len, level, verbosity, workFactor)	As	"BZ2_bzBuffToBuffCompress"
			EndImport
		CompilerElse
			Import	#LIB_BZP2_X86$
				BZP2_Unpack(*dst, *dst_len, *src, src_len, small, verbosity)				As	"_BZ2_bzBuffToBuffDecompress@24"
				BZP2_Pack(*dst, *dst_len, *src, src_len, level, verbosity, workFactor)	As	"_BZ2_bzBuffToBuffCompress@28"
			EndImport
		CompilerEndIf
		
	CompilerEndIf

	;/* (g)zip.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_GZIP

		;/* Return codes for the compression/decompression functions. Negative values
		; * are errors, positive values are used for special but normal events.
		; */
		#Z_OK					=	0
		#Z_STREAM_END		=	1
		#Z_NEED_DICT		=	2
		#Z_ERRNO				=	-1
		#Z_STREAM_ERROR	=	-2
		#Z_DATA_ERROR		=	-3
		#Z_MEM_ERROR		=	-4
		#Z_BUF_ERROR		=	-5
		#Z_VERSION_ERROR	=	-6
		
		CompilerIf	#XUP_FLAGS	&	#XUP_PURE
			#LIB_GZIP_X64$	=	"zlib.lib"
			#LIB_GZIP_X86$	=	"zlib.lib"
		CompilerElse
			#LIB_GZIP_X64$	=	"zlib_x64.lib"
			#LIB_GZIP_X86$	=	"zlib_x86.lib"
		CompilerEndIf

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	#LIB_GZIP_X64$
				GZIP_Unpack(*dst, *dst_len, *src, src_len)		As	"uncompress"
				GZIP_Pack(*dst, *dst_len, *src, src_len, level)	As	"compress2"
			EndImport
		CompilerElse
			ImportC	#LIB_GZIP_X86$
				GZIP_Unpack(*dst, *dst_len, *src, src_len)		As	"_uncompress"
				GZIP_Pack(*dst, *dst_len, *src, src_len, level)	As	"_compress2"
			EndImport
		CompilerEndIf

	CompilerEndIf

	;/* lzma.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_LZMA

		#LZMA_PROPS_SIZE	=	5

		; error codes for LZMA
		Enumeration
			#LZMA_OK	; 0 = all ok
			#LZMA_ERROR
			#LZMA_ERROR_MEM
			#LZMA_ERROR_OUTPUT
			#LZMA_ERROR_PARAM
			#LZMA_ERROR_DATA
			#LZMA_ERROR_THREAD
		EndEnumeration

		; dictionary size (1 << #LZMA_DICT_*)
		Enumeration	12
			#LZMA_DICT_4K
			#LZMA_DICT_8K
			#LZMA_DICT_16K
			#LZMA_DICT_32K
			#LZMA_DICT_64K
			#LZMA_DICT_128K
			#LZMA_DICT_256K
			#LZMA_DICT_512K
			#LZMA_DICT_1M
			#LZMA_DICT_2M
			#LZMA_DICT_4M
			#LZMA_DICT_8M
			#LZMA_DICT_16M
			#LZMA_DICT_32M
			#LZMA_DICT_64M
			#LZMA_DICT_128M
			#LZMA_DICT_256M
		EndEnumeration

		Structure T_LZMA_HEADER
			Props.b        ; Special LZMA properties (lc,lp, pb in encoded form)
			DictSize.l		; Dictionary size
			SourceSize.q	; Uncompressed size (Need Quad 8 Bytes -> not Long -> s. github)
		EndStructure

		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			Import	"lzma_x64.lib"
				LZMA_Pack(*dst, *dst_len, *src, src_len, *props, *props_len, level, dict, Lc, Lp, Pb, Fb, threads)	As	"LzmaCompress"
				LZMA_Unpack(*dst, *dst_len, *src, *src_len, *props, props_len)													As	"LzmaUncompress"
			EndImport
		CompilerElse
			Import	"lzma_x86.lib"
				LZMA_Pack(*dst, *dst_len, *src, src_len, *props, *props_len, level, dict, Lc, Lp, Pb, Fb, threads)	As	"_LzmaCompress@52"
				LZMA_Unpack(*dst, *dst_len, *src, *src_len, *props, props_len)													As	"_LzmaUncompress@24"
			EndImport
		CompilerEndIf

	CompilerEndIf
	
	;/* aPLib.lib */
	CompilerIf	#XUP_FLAGS	&	#XUP_APLB

		; aPLib v1.1.1 - compression library
		; http://www.ibsensoftware.com/products_aPLib.html
		
		; This product uses the aPLib compression library,
		; Copyright 1998-2009 by Jørgen Ibsen, All Rights Reserved.
		; aPLib is free to use even for commercial use. 
		
		; Wrapper 1.0 for PB 4.41 by Luis (Feb 2010)
		; Rewritten by Peace^TST (May 2019)
		; + aPLib updated v1.0.1 to v1.1.1
		; + Header
		; + Less parameter
		; + Less procedures
		; + Smaller exe
		
		; In brief:
		; compression: good ratio, average speed, low memory requirements (around 640 KB)
		; decompression: extremely fast, extremely low memory requirements 

		; error codes for aPLib
		#APLIB_OK				=	0
		#APLIB_ERROR			=	1
		#APLIB_ERROR_MEM		=	2
		#APLIB_ERROR_OUTPUT	=	3
		#APLIB_ERROR_PARAM	=	4
		
		CompilerIf	#PB_Compiler_Processor = #PB_Processor_x64
			Import	"aPlib_x64.lib" 
				aP_pack(*SourceBuff, *DestBuff, iSourceSize, *WorkBuff, *callback, *cbparam)
				aP_workmem_size(input_size)
				aP_max_packed_size(input_size)
				aP_depack_asm_safe(*SourceBuff, iSourceSize, *DestBuff, iDestSize)   
			EndImport
		CompilerElse   
			ImportC	"aPlib_x86.lib" 
				aP_pack(*SourceBuff, *DestBuff, iSourceSize, *WorkBuff, *callback, *cbparam)
				aP_workmem_size(input_size)
				aP_max_packed_size(input_size)
				aP_depack_asm_safe(*SourceBuff, iSourceSize, *DestBuff, iDestSize)   
			EndImport
		CompilerEndIf

	CompilerEndIf
	
	;/* BriefLZ */
	CompilerIf	#XUP_FLAGS	&	#XUP_BLZ1
		UseBriefLZPacker()
	CompilerEndIf

	;/* JCalG1 x86 */
	CompilerIf	#XUP_FLAGS	&	#XUP_JCG1
		CompilerIf	#XUP_FLAGS	&	#XUP_PURE
			#LIB_JCG1_X86$	=	"jcalg1.lib"
		CompilerElse
			#LIB_JCG1_X86$	=	"jcalg1_x86.lib"
		CompilerEndIf
		Import	#LIB_JCG1_X86$
			JCG1_Unpack(*src, *dst)				As	"_JCALG1_Decompress_Fast@8"	; return unpacked size or 0
			JCG1_GetUnpackSize(*src)			As	"_JCALG1_GetUncompressedSizeOfCompressedBlock@4"
			JCG1_GetNeededBufferSize(*src)	As	"_JCALG1_GetNeededBufferSize@4"
			JCG1_Compress(*src, srclen, *dst, nWindowSize, *AllocFunc, *DeallocFunc, *Callback, bDisableChecksum)	As	"_JCALG1_Compress@32"	; = packed size
		EndImport
	CompilerEndIf

	; ----------------------------------------------------------
	; /* Default XUnPack::Commands */
	; ----------------------------------------------------------
	Declare		Buffer()
	Declare		Free()
	Declare		ID(*Memory.RS_Union=0)
	Declare$	Magic(*Memory=0)
	Declare		Size()
	Declare		Unpack(*Memory.RS_XPK, Length=0, Password$=#Null$)

	CompilerIf	#XUP_FLAGS	&	#XUP_PX20
		Declare	PX20CalcCheckSum(Password$)
		Declare	PX20CalcPassKey(Password$)
		Declare	PX20Decode(*Memory.Long, Length, PassKey.q, BruteStep=1, *CallBack=0)
		Declare	PX20CheckSum(*Memory.RS_Union)
		Declare	PX20PassKey()
	CompilerEndIf

	CompilerIf	#XUP_FLAGS	&	#XUP_PACK
		Declare	Pack(*Memory, Length=0, Level=9, Mode=#XUP_LZMA, *CallBack=#Null)
	CompilerEndIf

EndDeclareModule

Module	XUP
	
	; ----------------------------------------------------------
	; /* intern */
	; ----------------------------------------------------------
	CompilerIf	#XUP_FLAGS	&	#XUP_LZMA	; LZMA specific (by Luis)
		Procedure	LZMA_UnpackMemory(*Memory.T_LZMA_HEADER, Length)

			; *Memory  = ptr to the source buffer
			; Length  = size of the source buffer

			; NOTE: The source buffer must contain a T_LZMA_HEADER followed by the packed data

			; NOTE: Memory required for decompression = dictionary size + 16 KB

			If *Memory <= 0	Or	Length <= 0
				ProcedureReturn	#False	;#LZMA_ERROR_PARAM
			EndIf

			Protected *Buffer, Buffer_Len.q
			Protected iOffSourceSize = Length - SizeOf(T_LZMA_HEADER)
			Protected *Props

			; retrieve Props from header
			*Props = AllocateMemory(#LZMA_PROPS_SIZE) ; 5 bytes
			CopyMemory(*Memory, *Props, #LZMA_PROPS_SIZE)

			Buffer_Len	=	*Memory\SourceSize
			*Buffer	=	AllocateMemory(Buffer_Len)

			If	LZMA_Unpack(*Buffer, @Buffer_Len, *Memory + SizeOf(T_LZMA_HEADER), @iOffSourceSize, *Props, #LZMA_PROPS_SIZE)	<>	#LZMA_OK
				FreeMemory(*Buffer)
				*Buffer	=	#False
			EndIf

			FreeMemory(*Props)

			ProcedureReturn	*Buffer

		EndProcedure
		CompilerIf	#XUP_FLAGS	&	#XUP_PACK
			Procedure	LZMA_PackMemory(*Memory, Length.q, Level=9, Dict=#LZMA_DICT_64M)

				; *Memory  = ptr to the source buffer
				; Length   = size of the source buffer

				; NOTE: The size of the destination buffer *should* be at least the size of the source + SizeOf(T_LZMA_HEADER)
				;       You can use the procedure CalcDestBufferSize_LZMA() to get it.

				; NOTE: Level must be between 0 (lowest) and 9 (highest) - default 9

				; NOTE: Dict must be between 12 (1 << 12 = 4 KB) and 28 (1 << 28 = 256 MB) - default 4MB

				; NOTE: The destination buffer will contain a T_LZMA_HEADER followed by the packed data

				Protected *OutProps, OutProps_Len
				Protected *Buffer.T_LZMA_HEADER, Buffer_Len

				If Level < 0 Or Level > 9	:	Level	=	9	:	EndIf

				If Dict < #LZMA_DICT_4K Or Dict > #LZMA_DICT_256M ; 4 KB to 256 MB
					Dict	=	#LZMA_DICT_64M ; default 26 = 64 MB
				EndIf

				Dict	=	1	<<	Dict

				; Allocate memory for the properties section
				*OutProps		=	AllocateMemory(#LZMA_PROPS_SIZE) ; 5 bytes, I refuse to check for this!
				OutProps_Len	=	#LZMA_PROPS_SIZE

				*Buffer		=	AllocateMemory(Length + SizeOf(T_LZMA_HEADER))
				Buffer_Len	=	MemorySize(*Buffer) - SizeOf(T_LZMA_HEADER)

				If	LZMA_Pack(*Buffer + SizeOf(T_LZMA_HEADER), @Buffer_Len, *Memory, Length, *OutProps, @OutProps_Len, Level, Dict, 3,0,2,32, 2)	=	#LZMA_OK
					
					If Buffer_Len	>=	Length	; Error (even if OK?)
						
						FreeMemory(*Buffer)
						*Buffer	=	#False
						
					Else
						
						; write the header for the destination buffer
						CopyMemory(*OutProps, *Buffer, #LZMA_PROPS_SIZE)
						
						*Buffer\SourceSize	=	Length	; unpacked size
						*Buffer	=	ReAllocateMemory(*Buffer, Buffer_Len + SizeOf(T_LZMA_HEADER), #PB_Memory_NoClear)
						
					EndIf
					
				Else	; Error
					
					FreeMemory(*Buffer)
					*Buffer	=	#False
					
				EndIf

				FreeMemory(*OutProps)

				ProcedureReturn	*Buffer

			EndProcedure
		CompilerEndIf
	CompilerEndIf
	CompilerIf	#XUP_FLAGS	&	#XUP_APLB
		Procedure	APLIB_UnpackMemory(*Memory.RS_XID, Length)
			
			; *Memory	=	ptr to the source buffer
			; Length		=	size of the source buffer
			; Return		=	ptr to unpacked *buffer -> MemorySize(*buffer)
			
			Protected *Buffer, Buffer_Len
			
			If *Memory <= 0	Or	Length <= 0
				ProcedureReturn	#False	; #APLIB_ERROR_PARAM
			EndIf
			
			; Header check
			If	*Memory\ID	<>	#ID_APLB
				ProcedureReturn	#False	; #APLIB_ERROR
			EndIf
			
			; ptr to the destination buffer
			Buffer_Len	=	*Memory\Size
			*Buffer		=	AllocateMemory(Buffer_Len)
			If	*Buffer	=	#Null
				ProcedureReturn	#False	; #APLIB_ERROR_MEM
			EndIf
			
			Buffer_Len	=	aP_depack_asm_safe(*Memory + SizeOf(RS_XID), Length - SizeOf(RS_XID), *Buffer, Buffer_Len)
			
			If	Buffer_Len	<=	0	; #APLIB_ERROR
				FreeMemory(*Buffer)
				*Buffer	=	#False
			Else	; #APLIB_OK
				*Buffer	=	ReAllocateMemory(*Buffer, Buffer_Len, #PB_Memory_NoClear)
			EndIf
			
			ProcedureReturn	*Buffer
			
		EndProcedure
		CompilerIf	#XUP_FLAGS	&	#XUP_PACK
			; ProcedureC	APLB_CallbackFunc(insize, inpos, outpos, *cbparm)
			; 	User stuff, return 0 to abort
			; 	Debug "APLB: " + Str(insize) + " / " + Str(inpos) + " / " + Str(outpos) + " / Ratio = " + StrF(100.0 / inpos * outpos, 3) + "%"
			; 	While	WindowEvent()	:	Wend
			; 	ProcedureReturn	#True
			; EndProcedure
			Procedure	APLIB_PackMemory(*Memory, Length, *CallBack=0)
				
				; *Memory	=	ptr to the source buffer
				; Length		=	size of the source buffer
				; *CallBack	=	@APLIB_CallbackFunc(insize, inpos, outpos, *cbparm)
				; Return		=	ptr to packed *buffer -> MemorySize(*buffer)
				
				Protected *WorkBuff, *Buffer.RS_XID, Buffer_Len
				
				If *Memory <= 0	Or	Length <= 0
					ProcedureReturn	#False	;#APLIB_ERROR_PARAM
				EndIf
				
				*WorkBuff	=	AllocateMemory(aP_workmem_size(Length)) ; it should be hard-coded 640 KB
				
				If	*WorkBuff	=	#Null
					ProcedureReturn	#False	;#APLIB_ERROR_MEM
				EndIf
				
				; ptr to the destination buffer
				Buffer_Len	=	aP_max_packed_size(Length) + SizeOf(RS_XID)
				*Buffer		=	AllocateMemory(Buffer_Len)
				If	*Buffer	<=	#Null
					FreeMemory(*WorkBuff)
					ProcedureReturn	#False	;#APLIB_ERROR_MEM
				EndIf
				
				; *CallBack = @APLIB_CallbackFunc(insize, inpos, outpos, *cbparm)
				; User stuff, return 0 to abort
				; Debug	Str(insize) + " / " + Str(inpos) + " / " + Str(outpos) + " / Ratio = " + StrF(100.0 / inpos * outpos, 3) + "%"
				;If	*CallBack
					Buffer_Len	=	aP_pack(*Memory, *Buffer + SizeOf(RS_XID), Length, *WorkBuff, *CallBack, #Null)
				;Else
				;	Buffer_Len	=	aP_pack(*Memory, *Buffer + SizeOf(RS_XID), Length, *WorkBuff, #Null, #Null)
				;EndIf

				If	Buffer_Len	>	0	And	Buffer_Len	<	Length	; #APLIB_OK
					*Buffer\ID		=	#ID_APLB	; HeaderID APLB
					*Buffer\Size	=	Length	; unpacked! length
					*Buffer			=	ReAllocateMemory(*Buffer, Buffer_Len + SizeOf(RS_XID), #PB_Memory_NoClear)
				Else	; #APLIB_ERROR
					FreeMemory(*Buffer)
					*Buffer	=	#False
				EndIf    
				
				FreeMemory(*WorkBuff)
				
				ProcedureReturn	*Buffer
				
			EndProcedure
		CompilerEndIf
	CompilerEndIf
	CompilerIf	#XUP_FLAGS	&	#XUP_FILE	; Load(*File, ID.l=0)
		Procedure	Load(*File, ID.l=0)

			Protected	hF	=	ReadFile(#PB_Any, PeekS(*File))

			With	RS_XUP

				\Memory	=	#Null
				\Length	=	#Null

				If	hF
					
					If	ID	; HeaderCheck LONG
						If	ReadLong(hF)	<>	ID
							CloseFile(hF)
							ProcedureReturn	#False
						EndIf
						FileSeek(hF, 0)
					EndIf
					
					\Length	=	Lof(hF)
					
					If	\Length	>	#Null
						\Memory	=	AllocateMemory(\Length)
						If	\Memory	>	#Null
							\Length	=	ReadData(hF, \Memory, \Length)
						EndIf
					EndIf
					
					CloseFile(hF)
					
				EndIf
				
				ProcedureReturn	\Memory

			EndWith

		EndProcedure
	CompilerEndIf
	CompilerIf	#XUP_FLAGS	&	#XUP_JCG1	; x86
		CompilerIf	#XUP_FLAGS	&	#XUP_PACK
			; Procedure	JCG1_CallbackFunc(pSourcePos, pDestinationPos)
			; 	User stuff, return 0 to abort
			; 	Debug "JCG1: " + Str(pSourcePos) + " / " + Str(pDestinationPos) + " / Ratio = " + StrF(100.0 / pSourcePos * pDestinationPos, 3) + "%"
			; 	While	WindowEvent()	:	Wend
			; 	ProcedureReturn	#True
			; EndProcedure
			Procedure	JCG1_AllocFunc(nMemSize)
				ProcedureReturn	GlobalAlloc_(#GMEM_FIXED, nMemSize)
			EndProcedure
			Procedure	JCG1_DeAllocFunc(*pBuffer)
				GlobalFree_(*pBuffer)
				ProcedureReturn	#True
			EndProcedure
			Procedure	JCG1_Pack(*Memory, Length, Level=9, *CallBack=0)
				
				; return ptr to packed *Buffer, 0 = error
				
				Protected	*Buffer, BufferSize
				
				; avoid length = *finish
				If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf
				
				; level always 1 upto 9
				If	Level	<	1
					Level	=	1
				ElseIf	Level	>	9
					Level	=	9
				EndIf
				
				; min. = 4.096 .. max. = 1.048.576 bytesize
				Level	=	(1	<<	(Level	+	1))	*	1024
				
				; claculate buffersize to pack ( length + 4 )
				BufferSize	=	JCG1_GetNeededBufferSize(Length)
				
				If	BufferSize	>	#Null
					
					*Buffer	=	AllocateMemory(BufferSize)
					
					If	*Buffer
						
						; param *CallBack not really needed, set #Null for no custom access
						; JCG1_CallbackFunc(pSourcePos, pDestinationPos)
						; User stuff, return 0 to abort
						;If	*CallBack
							BufferSize	=	JCG1_Compress(*Memory, Length, *Buffer, Level, @JCG1_AllocFunc(), @JCG1_DeAllocFunc(), *CallBack, #Null)
						;Else
						;	BufferSize	=	JCG1_Compress(*Memory, Length, *Buffer, Level, @JCG1_AllocFunc(), @JCG1_DeAllocFunc(), #Null, #Null)
						;EndIf
						
						If	BufferSize	>	#Null
							; OK -> packed, reduce to final packed size
							*Buffer	=	ReAllocateMemory(*Buffer, BufferSize, #PB_Memory_NoClear)
						Else
							; ERROR -> cannot pack (buffer overflow)
							FreeMemory(*Buffer)
							*Buffer	=	#False
						EndIf
						
					EndIf
					
				EndIf
				
				ProcedureReturn	*Buffer
				
			EndProcedure	
		CompilerEndIf
	CompilerEndIf
	
	; ----------------------------------------------------------
	; /* default commands */
	; ----------------------------------------------------------
	Procedure	Buffer()

		; return ptr of un/packed *memory

		ProcedureReturn	RS_XUP\OutBuf

	EndProcedure
	Procedure	Free()

		With	RS_XUP

			If	\OutBuf	And	\OutBuf	<>	\InBuf	:	FreeMemory(\OutBuf)	:	EndIf
			If	\IsFile	:	FreeMemory(\IsFile)	:	EndIf

			ClearStructure(@RS_XUP, RS_XUP)

		EndWith

	EndProcedure
	Procedure	ID(*Memory.RS_Union=0)

		; return magic header as long
		
		Protected	cmf.a

		If	*Memory	<=	0
			ProcedureReturn	RS_XUP\ID
		EndIf

		With	*Memory
			Select	\l

				Case	#ID_XPKF
					CompilerIf	#XUP_FLAGS	&	#XUP_XPKF
						*Memory	+	OffsetOf(RS_XPK\Mode)
						Select	\l	; Amiga XPK supported Packmode?
							Case	#ID_SQSH,#ID_IMPL,#ID_PWPK,#ID_BZP2,#ID_GZIP,#ID_NONE
								ProcedureReturn	\l
						EndSelect
					CompilerElse
						*Memory	+	OffsetOf(RS_XPK\Mode)
						Select	\l	; Amiga XPKF/SQSH Packmode only?
							Case	#ID_SQSH	:	ProcedureReturn	\l
						EndSelect
					CompilerEndIf

				Case	#ID_PP20,#ID_PPbk,#ID_PX20,#ID_PPLS,#ID_PP11
					CompilerIf	#XUP_FLAGS	&	(#XUP_PP20|#XUP_PX20)
						ProcedureReturn	#ID_PP20
					CompilerEndIf
					
				Case	#ID_APLB
					CompilerIf	#XUP_FLAGS	&	#XUP_APLB
						ProcedureReturn	#ID_APLB
					CompilerEndIf
					
				Case	#ID_FIMP,#ID_ATNI,#ID_9CDR,#ID_DUPA,#ID_FLTI,#ID_IFHC,#ID_MADE,#ID_M_H_,#ID_PARA
					CompilerIf	#XUP_FLAGS	&	#XUP_FIMP
						ProcedureReturn	#ID_FIMP
					CompilerEndIf

				Case	#ID_BLZ1
					CompilerIf	#XUP_FLAGS	&	#XUP_BLZ1
						ProcedureReturn	#ID_BLZ1
					CompilerEndIf
					
				Case	#ID_ATM5,#ID_ICE1,#ID_ICE4
					CompilerIf	#XUP_FLAGS	&	#XUP_UICE
						ProcedureReturn	#ID_UICE
					CompilerEndIf

				Default	; ascii or word header (JCG1 bad 10MB distress check)
					
					If	\a	=	']'	; LZMA marker?
					CompilerIf	#XUP_FLAGS	&	#XUP_LZMA
						ProcedureReturn	#ID_LZMA
					CompilerEndIf
						
					CompilerIf	#XUP_FLAGS	&	#XUP_BZP2
					ElseIf	\w	=	#ID_BZ	Or	PeekW(*Memory + OffsetOf(RS_XPK\InLen))	=	#ID_BZ	; BZIP2 $5A42 & (XPKF)
						If	\w	<>	#ID_BZ	:	*Memory	+	OffsetOf(RS_XPK\InLen)	:	EndIf					; packed with Amiga XPK->BZP2?
						*Memory	+	SizeOf(Long)
						If	\l	=	$26594131	; BZip2 UINT32($PI) check
							ProcedureReturn	#ID_BZP2
						EndIf
					CompilerEndIf
					
					CompilerIf	#XUP_FLAGS	&	#XUP_GZIP
					ElseIf	\a	=	'x'	Or	PeekA(*Memory + OffsetOf(RS_XPK\InLen))	=	'x'	; GZip & (XPKF)?
						If	\a	<>	'x'	:	*Memory	+	OffsetOf(RS_XPK\InLen)	:	EndIf				; packed with Amiga XPK->GZIP?
						cmf	=	\a	:	*Memory	+	SizeOf(Ascii)
						If	((256 * cmf + \a) % 31) = 0	And	(\a & $20) = 0	; GZip/Zip Header-Check
							ProcedureReturn	#ID_GZIP
						EndIf
					CompilerEndIf
					
					CompilerIf	(#XUP_FLAGS	&	#XUP_JCG1)	And	(#PB_Compiler_Processor	=	#PB_Processor_x86)
						ElseIf	\w	=	#ID_JC	And	JCG1_GetUnpackSize(*Memory)	&	$F0000000	=	#Null	; JCalG1 Marker (Word) & stupid firlefanz check
							ProcedureReturn	#ID_JCG1
					CompilerEndIf
						
					EndIf

			EndSelect
		EndWith

		ProcedureReturn	#False

	EndProcedure
	Procedure$	Magic(*Memory=0)

		; return magic header as 4 byte string
		; PeekS(XUnPack::@RS_XUP\ID, 4, #PB_Ascii)

		*Memory	=	ID(*Memory)
		
		If	*Memory
			ProcedureReturn	PeekS(@*Memory, 4, #PB_Ascii)
		Else
			ProcedureReturn	#Null$
		EndIf

	EndProcedure
	Procedure	Size()

		; return size of un/packed *memory

		ProcedureReturn	RS_XUP\OutSize

	EndProcedure
	Procedure	Unpack(*Memory.RS_XPK, Length=0, Password$=#Null$)

		; return unpacked *Memory of Buffer(), Size()

		Free()

		With	RS_XUP

			; ------------------------------------------------------
			; /* *Memory = @File$ and Length=0 ? */
			; ------------------------------------------------------
			CompilerIf	#XUP_FLAGS	&	#XUP_FILE
				If	*Memory	And	Length	<=	#Null	; *Memory = @File?
					If	Load(*Memory)
						Length	=	\Length
						*Memory	=	\Memory
						\IsFile	=	*Memory	;// marker for free()
					EndIf
				EndIf
			CompilerEndIf

			If	Length	<=	#Null		:	Free()	:	ProcedureReturn	#False	:	EndIf
			If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

			; ------------------------------------------------------
			; /* not packed -> unpacked = Buffer(), Size() */
			; ------------------------------------------------------
			If	ID(*Memory)	=	#Null
				\InBuf	=	*Memory
				\InSize	=	Length
				\OutBuf	=	*Memory
				\OutSize	=	Length
				ProcedureReturn	\OutBuf
			EndIf

			; ------------------------------------------------------------
			; /* convert XPK packed memory? -> IMPL,PWPK,BZP2,GZIP,NONE */
			; ------------------------------------------------------------
			CompilerIf	#XUP_FLAGS	&	#XUP_XPKF
				If	*Memory\ID	=	#ID_XPKF
					Select	*Memory\Mode			; XPKF Master
						Case	#ID_IMPL					; XPK IMPL -> Bug! Unpacked Size > 65535!
							CompilerIf	#XUP_FLAGS	&	#XUP_FIMP
								;MoveMemory(*Memory + $0C, *Memory + $34, SizeOf(Long))
								MoveMemory(*Memory + $30, *Memory, Length - $30)
								Length	-	$36
							CompilerEndIf
						Case	#ID_PWPK					; XPK PWPK v0.90
							CompilerIf	#XUP_FLAGS	&	#XUP_PP20
								Select	PeekB(*Memory + Length - 13)
									Case	0	:	*Memory\InLen	=	$09090909
									Case	1	:	*Memory\InLen	=	$0A0A0A09	;01010100
									Case	2	:	*Memory\InLen	=	$0B0B0A09	;02020100
									Case	3	:	*Memory\InLen	=	$0C0C0A09	;03030200
									Default	:	*Memory\InLen	=	$0D0C0A09	;04030100
								EndSelect
								*Memory\ID	=	#ID_PP20
								MoveMemory(*Memory + $30, *Memory + $8, Length - $30)
								Length	-	$40
								;MoveMemory(*Memory + $30, *Memory + $8, Length - $38)
								;Length	-	$38
							CompilerEndIf
						Case	#ID_BZP2, #ID_GZIP	; XPK BZP2|GZIP
							CompilerIf	#XUP_FLAGS	&	(#XUP_BZP2|#XUP_GZIP)
								MoveMemory(*Memory + $2C, *Memory, Length - $2C)
								Length	-	$38
							CompilerEndIf
						Case	#ID_NONE					; XPK NONE (unknown bug)
							CompilerIf	#XUP_FLAGS	&	#XUP_NONE
								\ID		=	#ID_NONE
								\InSize	=	Length	; packed size
								\InBuf	=	*Memory	; packed buffer
								Length	=	UINT32(*Memory\OutLen)	+	$28
								MoveMemory(*Memory + $2C, *Memory, Length)
								\OutBuf	=	*Memory
								\OutSize	=	Length
								ProcedureReturn	#True
							CompilerEndIf
					EndSelect
				EndIf
			CompilerEndIf

			\InBuf	=	*Memory	; packed buffer
			\InSize	=	Length	; packed size

			; ------------------------------------------------------------
			; /* main ************************************************* */
			; ------------------------------------------------------------
			Select	ID(*Memory)	;*Memory\ID

				Case	#ID_PP20	;, #ID_PPbk, #ID_PX20, #ID_PPLS, #ID_PP11
					; ---------------------------------------------------
					; /* powerpacker decrunch memory -> NOT! #XUP_PX20 */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	(#XUP_PP20|#XUP_PX20)

						\ID	=	*Memory\ID	; ID_MAGIC (PP20..)

						\OutSize	=	PP20_GetDecrunchSize(\InBuf, \InSize)	; get decrunched size
						\OutBuf	=	AllocateMemory(\OutSize)

						If	PP20_Unpack(\InBuf, \OutBuf, \InSize, \OutSize, Password$)	=	#PPERR_OK	; Unpack
							If	\ID	=	#ID_PPbk																			; AMOSPro powerpacked bank (abk)?
								\OutSize	-	8																				; size - abkheadername[8]
								MoveMemory(\OutBuf + 8, \OutBuf, \OutSize)										; remove amos abkheader[8]
								\OutBuf	=	ReAllocateMemory(\OutBuf, \OutSize, #PB_Memory_NoClear)		; resize decrunched buffer - abkheader
							ElseIf	\ID	=	#ID_PX20
								CompilerIf	#XUP_FLAGS	&	#XUP_PX20
									\PassKey	=	PX20CalcPassKey(Password$)
								CompilerEndIf
							EndIf
						Else
							Free()
						EndIf

					CompilerEndIf

				Case	#ID_SQSH
					; ---------------------------------------------------
					; /* xpk master -> sqsh unpack memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_SQSH

						\ID	=	*Memory\Mode	; ID_MAGIC (SQSH)
						
						If	xpkSQSH_Check(*Memory, @\InSize, @\OutSize)	=	#XPKERR_OK
							
							\InSize	=	UINT32(*Memory\InLen)	; Size of packed buffer
							\OutSize	=	UINT32(*Memory\OutLen)	; Size of unpacked buffer
							
							\OutBuf	=	AllocateMemory(\OutSize + SizeOf(Long))	; add long to remain overflow
							
							If	xpkSQSH_Unpack(\InBuf, \OutBuf)	=	#XPKERR_OK		; Unpacked?
								\OutBuf	=	ReAllocateMemory(\OutBuf, \OutSize, #PB_Memory_NoClear)	; sub overflow-long for real memorysize
							Else
								Free()	; error!
							EndIf
							
						EndIf

					CompilerEndIf

				Case	#ID_UICE
					; ---------------------------------------------------
					; /* Atari Atomik 3.5 / Ice 2.1/2.4 -> uice unpack */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_UICE

						\ID	=	#ID_UICE	; ID_MAGIC (ATM5,Ice!,ICE!)
						
						If	ice_21_header(*Memory)	; Ice! 2.1
							
							\OutSize	=	ice_21_origsize(*Memory)	; unpacked size
							\InSize	=	ice_21_packedsize(*Memory)	; packed size
							\OutBuf	=	AllocateMemory(\OutSize)	; reserve memory to unpack
							
							If	ice_21_depack(*Memory, \OutBuf)	<=	#Null
								Free()
							EndIf
							
						ElseIf	ice_24_header(*Memory)	; ICE! 2.4
							
							\OutSize	=	ice_24_origsize(*Memory)
							\InSize	=	ice_24_packedsize(*Memory)
							\OutBuf	=	AllocateMemory(\OutSize)

							If	ice_24_depack(*Memory, \OutBuf)	<=	#Null
								Free()
							EndIf
							
						ElseIf	atm_35_header(*Memory)	; Atomik 3.5
							
							\OutSize	=	atm_35_origsize(*Memory)
							\InSize	=	atm_35_packedsize(*Memory)
							\OutBuf	=	AllocateMemory(\OutSize)

							If	atm_35_depack(*Memory, \OutBuf)	<=	#Null
								Free()
							EndIf
							
						Else
							
							Free()

						EndIf

					CompilerEndIf

				Case	#ID_FIMP	;, #ID_ATNI, #ID_9CDR, #ID_DUPA, #ID_FLTI, #ID_IFHC, #ID_MADE, #ID_PARA
					; ---------------------------------------------------
					; /* fimp explode memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_FIMP
						
						\ID	=	*Memory\ID	; ID_MAGIC (IMP!..)
						
						\OutSize	=	UINT32(*Memory\InLen)	; Size of unpacked buffer
						\OutBuf	=	AllocateMemory(\OutSize)

						If	FIMP_Unpack(\InBuf, \InSize, \OutBuf, \OutSize)	<>	#ERR_FIMP_NONE	; Unpack
							Free()
						EndIf
						
					CompilerEndIf
					
				Case	#ID_APLB
					; ---------------------------------------------------
					; /* aPLib decompress memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_APLB
						
						\ID	=	#ID_APLB
						
						\OutBuf	=	APLIB_UnpackMemory(\InBuf, \InSize)
						
						If	\OutBuf
							\OutSize	=	MemorySize(\OutBuf)
						Else
							Free()
						EndIf
						
						;ProcedureReturn	\OutBuf
						
					CompilerEndIf

				Case	#ID_BLZ1
					; ---------------------------------------------------
					; /* BriefLZ decompress memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_BLZ1
						
						\ID	=	#ID_BLZ1

						\OutSize	=	*Memory\Mode	; Size of unpacked buffer (long? or quad? -> no infos avail)
						\OutBuf	=	AllocateMemory(\OutSize + 32)
						
						If	UncompressMemory(\InBuf, \InSize, \OutBuf, \OutSize, #PB_PackerPlugin_BriefLZ)	>	#Null
							\OutBuf	=	ReAllocateMemory(\OutBuf, \OutSize, #PB_Memory_NoClear)
						Else
							Free()
						EndIf
						
						;ProcedureReturn	\OutBuf
						
					CompilerEndIf

				Case	#ID_BZP2
					; ---------------------------------------------------
					; /* BZip2 decompress memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_BZP2

						If	*Memory\InLen	&	$FFFF	=	#ID_BZ	; $5A42 -> marker of XPKF BZP2

							\ID	=	#ID_BZP2

							\OutSize	=	UINT32(*Memory\ID)	; XPK abuse ;)
							\OutBuf	=	AllocateMemory(\OutSize)

							If	BZP2_Unpack(\OutBuf, @\OutSize, \InBuf + SizeOf(Long), \OutSize - SizeOf(Long), 0, 0)	<>	#BZ_OK
								Free()
							EndIf

							;ProcedureReturn	\OutBuf

						ElseIf	*Memory\ID	&	$FFFF	=	#ID_BZ	; $5A42 -> marker of raw bzp2ed *memory

							\ID	=	#ID_BZP2
							
							; UNKNOWN UNPACKED SIZE!
							; why the hell use BZ2 two headers 0:BZ.Word & 4:#PI.Hex[6]
							; instead the unpacked length for the useless #PI?
							Length	=	#UNKNOWN_SIZE
							While	Length
								\OutSize	=	\InSize	*	Length
								\OutBuf	=	AllocateMemory(\OutSize)
								If	\OutBuf	:	Break	:	EndIf
								Length	-	1
							Wend
							
							If	\OutBuf	; hope no error -> out of memory?
								If	BZP2_Unpack(\OutBuf, @\OutSize, \InBuf, \InSize, 0, 0)	<>	#BZ_OK
									Free()
								Else
									\OutBuf	=	ReAllocateMemory(\OutBuf, \OutSize, #PB_Memory_NoClear)
								EndIf
							Else
								Free()
							EndIf

							;ProcedureReturn	\OutBuf

						EndIf
					CompilerEndIf
					
				Case	#ID_GZIP
					; ---------------------------------------------------
					; /* GZip uncompress memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_GZIP

						If	*Memory\InLen	&	$FF	=	'x'	; $78 -> marker of XPKF GZIP?

							\ID	=	#ID_GZIP

							\OutSize	=	UINT32(*Memory\ID)	; XPK abuse ;)
							\OutBuf	=	AllocateMemory(\OutSize)

							If	GZIP_Unpack(\OutBuf, @\OutSize, \InBuf + SizeOf(Long), \InSize - SizeOf(Long))	<>	#Z_OK
								Free()
							EndIf

							;ProcedureReturn	\OutBuf

						ElseIf	*Memory\ID	&	$FF	=	'x'	; $78 -> marker of raw gzipped *memory?

							\ID	=	#ID_GZIP
							
							; UNKNOWN UNPACKED SIZE!
							Length	=	#UNKNOWN_SIZE
							While	Length
								\OutSize	=	\InSize	*	Length
								\OutBuf	=	AllocateMemory(\OutSize)
								If	\OutBuf	:	Break	:	EndIf
								Length	-	1
							Wend
							
							If	\OutBuf	; hope no error -> out of memory?
								If	GZIP_Unpack(\OutBuf, @\OutSize, \InBuf, \InSize)	<>	#Z_OK
									Free()
								Else
									\OutBuf	=	ReAllocateMemory(\OutBuf, \OutSize, #PB_Memory_NoClear)
								EndIf
							Else
								Free()
							EndIf

							;ProcedureReturn	\OutBuf

						EndIf
					CompilerEndIf
					
				Case	#ID_LZMA
					; ---------------------------------------------------
					; /* lzma uncompress memory */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_LZMA

						;If	*Memory\ID	&	$FF	=	']'	; $5D -> marker of raw lzma packed *memory?

							\ID	=	#ID_LZMA

							\OutBuf	=	LZMA_UnpackMemory(\InBuf, \InSize)

							If	\OutBuf
								\OutSize	=	MemorySize(\OutBuf)
							Else
								Free()
							EndIf

							;ProcedureReturn	\OutBuf

						;EndIf
					CompilerEndIf
					
				Case	#ID_JCG1	; * x86 *
					; ---------------------------------------------------
					; /* JCalG1 decompress memory - x86 */
					; ---------------------------------------------------
					CompilerIf	#XUP_FLAGS	&	#XUP_JCG1
						
						\ID	=	#ID_JCG1
						
						CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x86

							\OutSize	=	JCG1_GetUnpackSize(*Memory)	;PeekL(*Memory + SizeOf(Word))
							\OutBuf	=	AllocateMemory(\OutSize)
							
							If	JCG1_Unpack(\InBuf, \OutBuf)	<=	#Null	;UncompressMemory(\InBuf, \InSize, \OutBuf, \OutSize, #PB_PackerPlugin_JCALG1)	<=	#Null
								Free()
							EndIf
							
						CompilerElse

							\OutSize	=	\InSize
							\OutBuf	=	\InBuf
							
						CompilerEndIf
						
					CompilerEndIf

				Default
					; ---------------------------------------------------
					; /* unknown packer or not defined #XUP_(Format) */
					; ---------------------------------------------------
					Free()

			EndSelect

			ProcedureReturn	\OutBuf

		EndWith

	EndProcedure

	; ----------------------------------------------------------
	; /* powerpacker px20 crack with brute-force passkey */
	; ----------------------------------------------------------
	CompilerIf	#XUP_FLAGS	&	#XUP_PX20
		Procedure	PX20CalcCheckSum(Password$)

			;Protected	shift, cksum

			;*Password	=	Uni2Asc(*Password)

			;While	*Password\a
			;	shift	=	*Password\a	&	$0F
			;	If	shift
			;		cksum	>>	shift	|	(cksum << (16	-	shift))
			;	EndIf
			;	cksum	=	(cksum	+	*Password\a)	&	$FFFF
			;	*Password	+	SizeOf(Ascii)
			;Wend

			;ProcedureReturn	cksum

			ProcedureReturn	PX20_CalcChecksum(Password$)

		EndProcedure
		Procedure	PX20CalcPassKey(Password$)

			;Protected	key.l

			;*Password	=	Uni2Asc(*Password)

			;While	*Password\a
			;	key	<<	1	|	key	>>	31	+	*Password\a
			;	key	<<	16	|	key	>>	16
			;	*Password	+	SizeOf(Ascii)
			;Wend

			;ProcedureReturn	key

			ProcedureReturn	PX20_CalcPasskey(Password$)

		EndProcedure
		Procedure	PX20Decode(*Memory.Long, Length, PassKey.q, BruteStep=1, *CallBack=0)

			; Return -> 0 = Error

			Free()

			If	BruteStep	<=	#Null	:	BruteStep	=	1	:	EndIf

			With	RS_XUP

				;/* *Memory = @File$ and Length = 0 ? */
				CompilerIf	#XUP_FLAGS	&	#XUP_FILE
					If	*Memory	And	Length	<=	#Null		; *Memory = @File?
						If	Load(*Memory, #ID_PX20)	; Header  = PX20?
							Length	=	\Length
							*Memory	=	\Memory
							\IsFile	=	*Memory	; marker for free()
						EndIf
					EndIf
				CompilerEndIf

				If	Length	<=	#Null	Or	*Memory\l	<>	#ID_PX20
					Free()	:	ProcedureReturn	#False	;#PPERR_DATAFORMAT
				EndIf

				If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

				; ---------------------------------------------------
				; /* px20 crack initialize */
				; ---------------------------------------------------
				\InBuf	=	*Memory		; packed buffer
				\InSize	=	Length		; packed size
				\ID		=	*Memory\l	; PX20
				\OutSize	=	PP20_GetDecrunchSize(\InBuf, \InSize)
				\OutBuf	=	AllocateMemory(\OutSize)

				;/* temporary restore InBuf every wrong passkey (recomended, byte-swapped inbuf!) */
				*Memory	=	AllocateMemory(\InSize)
				MoveMemory(\InBuf, *Memory, \InSize)

				;/* brute-force encrypt & decrunch with passkey ($0 .. $FFFFFFFF) -> very slow but works guaranteed */
				While	PassKey	<=	$FFFFFFFF

					; try to crack px20 with brute passkey (possible 4.294.967.295 passkeys)
					If	PX20_DecodeMemory(\InBuf, \OutBuf, \InSize, \OutSize, PassKey, *Memory)	=	#PPERR_OK
						\PassKey	=	Passkey
						Break
					EndIf

					; call custom proc? (draw stuff, return <> 0 breaks decoding)
					If	*CallBack	And	CallFunctionFast(*CallBack, PassKey)
						Break
					EndIf

					Passkey	+	BruteStep

				Wend

				FreeMemory(*Memory)

				;/* damn, not cracked - use crypted data! */
				If	\PassKey	=	#Null
					\OutBuf	=	\InBuf
					\OutSize	=	\InSize
					ProcedureReturn	#False	;#PPERR_PASSWORD
				EndIf

				;/* yeep, cracked! */
				ProcedureReturn	#True	;#PPERR_OK

			EndWith

		EndProcedure
		Procedure	PX20CheckSum(*Memory.RS_Union)
			If	*Memory\l	=	#ID_PX20
				*Memory	+	SizeOf(Long)
				ProcedureReturn	*Memory\w
			EndIf
		EndProcedure
		Procedure	PX20PassKey()
			ProcedureReturn	RS_XUP\PassKey
		EndProcedure
	CompilerEndIf

	; ----------------------------------------------------------
	; /* pack aPLib, BriefLZ, BZip2, GZip, FImp, JCalG1, LZMA */
	; ----------------------------------------------------------
	CompilerIf	#XUP_FLAGS	&	#XUP_PACK
		Procedure	Pack(*Memory, Length=0, Level=9, Mode=#XUP_LZMA, *CallBack=#Null)

			Protected	*Buffer, Buffer_Len

			Free()
			
			; (Pack)Mode used but not included?
			CompilerIf	#XUP_FLAGS	&	#XUP_APLB	=	#Null
				If	Mode	=	#XUP_APLB	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_BZP2	=	#Null
				If	Mode	=	#XUP_BZP2	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_BLZ1	=	#Null
				If	Mode	=	#XUP_BLZ1	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_FIMP	=	#Null
				If	Mode	=	#XUP_FIMP	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_GZIP	=	#Null
				If	Mode	=	#XUP_GZIP	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_LZMA	=	#Null
				If	Mode	=	#XUP_LZMA	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf
			CompilerIf	#XUP_FLAGS	&	#XUP_JCG1	=	#Null	; x86
				If	Mode	=	#XUP_JCG1	:	ProcedureReturn	#False	:	EndIf
			CompilerEndIf

			; *Memory = @File$ and Length=0 ?
			CompilerIf	#XUP_FLAGS	&	#XUP_FILE
				If	*Memory	And	Length	<=	#Null	; *Memory = @File?
					If	Load(*Memory)
						Length	=	RS_XUP\Length
						*Memory	=	RS_XUP\Memory
					EndIf
				EndIf
			CompilerEndIf

			; file-error?
			If	Length	<=	#Null	:	ProcedureReturn	#False	:	EndIf

			; already packed?
			If	ID(*Memory)
				RS_XUP\ID		=	ID(*Memory)
				RS_XUP\OutBuf	=	*Memory
				RS_XUP\OutSize	=	Length
				ProcedureReturn	#True
			EndIf

			If	Length	>	*Memory			:	Length	-	*Memory	:	EndIf
			If	Level	<=	0	Or	Level	>	9	:	Level	=	9				:	EndIf

			; aplb,lzma,jcg1 use own buffer!
			Select	Mode
				Case	#XUP_BLZ1,#XUP_BZP2,#XUP_FIMP,#XUP_GZIP
					Buffer_Len	=	Length	*	2
					*Buffer		=	AllocateMemory(Buffer_Len)
			EndSelect
			
			Select	Mode
				Case	#XUP_APLB	; compress with aPLib?
					CompilerIf	#XUP_FLAGS	&	#XUP_APLB
						RS_XUP\OutBuf	=	APLIB_PackMemory(*Memory, Length, *CallBack)	; no Level
						If	RS_XUP\OutBuf
							RS_XUP\OutSize	=	MemorySize(RS_XUP\OutBuf)
							RS_XUP\ID		=	#ID_APLB
						EndIf
						ProcedureReturn	RS_XUP\OutBuf
					CompilerEndIf
				Case	#XUP_BLZ1	; compress with native brieflz?
					CompilerIf	#XUP_FLAGS	&	#XUP_BLZ1
						Buffer_Len	=	CompressMemory(*Memory, Length, *Buffer, Buffer_Len, #PB_PackerPlugin_BriefLZ, Level)
						Mode	=	Bool(Buffer_Len<=#Null)
					CompilerEndIf
				Case	#XUP_BZP2	; compress with bzp2?
					CompilerIf	#XUP_FLAGS	&	#XUP_BZP2
						Mode	=	BZP2_Pack(*Buffer, @Buffer_Len, *Memory, Length, Level, 0, 0)
					CompilerEndIf
				Case	#XUP_FIMP	; compress with fimp?
					CompilerIf	#XUP_FLAGS	&	#XUP_FIMP
						MoveMemory(*Memory, *Buffer, Length)
						Buffer_Len	=	FIMP_Pack(*Buffer, Length, 9 - Level)	; Level should always 8/9 -> (0/1)
						If	Buffer_Len	>	#Null
							Mode	=	#ERR_FIMP_NONE
						EndIf
					CompilerEndIf
				Case	#XUP_GZIP	; compress with gzip?
					CompilerIf	#XUP_FLAGS	&	#XUP_GZIP
						Mode	=	GZIP_Pack(*Buffer, @Buffer_Len, *Memory, Length, Level)
					CompilerEndIf
				Case	#XUP_LZMA	; compress with lzma?
					CompilerIf	#XUP_FLAGS	&	#XUP_LZMA
						RS_XUP\OutBuf	=	LZMA_PackMemory(*Memory, Length, Level)
						If	RS_XUP\OutBuf
							RS_XUP\OutSize	=	MemorySize(RS_XUP\OutBuf)
							RS_XUP\ID		=	#ID_LZMA
						EndIf
						ProcedureReturn	RS_XUP\OutBuf
					CompilerEndIf
				Case	#XUP_JCG1	; compress with jcalg1 x86?
					CompilerIf	#XUP_FLAGS	&	#XUP_JCG1
						RS_XUP\OutBuf	=	JCG1_Pack(*Memory, Length, Level, *CallBack)
						If	RS_XUP\OutBuf
							RS_XUP\OutSize	=	MemorySize(RS_XUP\OutBuf)
							RS_XUP\ID		=	#ID_JCG1
						EndIf
						ProcedureReturn	RS_XUP\OutBuf
					CompilerEndIf
			EndSelect

			If	Mode	<>	#Null	; Error!
				FreeMemory(*Buffer)
			Else	; #BZ_OK, #Z_OK, #ERR_FIMP_NONE
				RS_XUP\OutBuf	=	ReAllocateMemory(*Buffer, Buffer_Len, #PB_Memory_NoClear)
				RS_XUP\OutSize	=	Buffer_Len
				RS_XUP\ID		=	ID(RS_XUP\OutBuf)
			EndIf

			ProcedureReturn	RS_XUP\OutBuf

		EndProcedure
	CompilerEndIf
	
EndModule
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = ABAAAAACAAAAAAAAAAA5
; DisableDebugger
; CompileSourceDirectory