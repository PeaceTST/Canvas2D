;*****************************************************
; Music-Engines Types / 27.06.2022
; Music	:	#IsC2D_Music	=	#XMU_[Type]
;=====================================================
Enumeration	1
	#XMU_AHX	;  1	=	(x86-64)	ahxPlay				*.AHX;*.THX -> (doesn't play HVL)
	#XMU_AMP	;  2	=	(x86)		AmpMaster_x86.dll	*.* -> (933+ Formats)
	#XMU_API	;  3	=	(x86-64)	Windows-API Sound	*.WAV
	#XMU_BAS	;  4	=	(x86)		bassmod				*.XM;*.IT;*.S3M;*.MOD;*.MTM;*.UMX
	#XMU_BMF	;  5	=	(x86)		libbr404				*.BMF
	#XMU_FC4	;  6	=	(x86-64)	fc4Play				*.FC;*.FC13;*.FC14;*.FC3;*.FC4;*.FCM;*.SMOD
	#XMU_FCP	;  7	=	(x86)		tFCLIB				*.FC;*.FC4;*.FC14 & (Custom FC4)
	#XMU_FLA	;  8	=	(x86-64)	Purebasic native	*.FLAC;*.FLA
	#XMU_FT2	;  9	=	(x86-64)	ft2Play				*.FT;*.MOD;*.STK;*.OKT;*.XM (no OKTA)
	#XMU_MCI	; 10	=	(x86-64)	System-Driver		*.MID;*.MP3;*.OGG;*.WAV;*.WMA...
	#XMU_MED	; 11	=	(x86)		medpdll				*.MED;*.MMD0;*.MMD1;*.MMD2;*.MMD3;*.MOD;*.IT;*S3M;*.XM (PP20)
	#XMU_MOD	; 12	=	(x86-64)	Purebasic native	*.XM;*.IT;*.S3M;*.MOD;*.MTM;*.UMX;*.OKT;*.MED (PP20)
	#XMU_MOV	; 13	=	(x86-64)	Purebasic native	*.MP3;*.WMA;*.WAV / *.AVI;*.MP4;*.WMV
	#XMU_OGG	; 14	=	(x86-64)	Purebasic native	*.OGG
	#XMU_PT2	; 15	=	(x86-64)	pt2Play				*.MOD (Protracker 2.3D)
	#XMU_S3M	; 16	=	(x86-64)	st3Play				*.S3M (Scream Tracker 3.21)
	#XMU_S68	; 17	=	(x86)		libsc68Replay		*.SC68
	#XMU_SCA	; 18	=	(x86-64)	SCAL_(x86-64).dll	*.* -> C64, Amiga, Atari, PC System-Driver...
	#XMU_SID	; 19	=	(x86)		titchysid			*.SID
	#XMU_STM	; 20	=	(x86-64)	st2Play				*.STM (Scream Tracker 2.3)
	#XMU_TFC	; 21	=	(x86-64)	TinyFC4				*.FC;*.FC13;*.FC14;*.FC3;*.FC4;*.FCM;*.SMOD (not official tiny fc4play = x86 -3.3KB / x64 -3.2KB)
	#XMU_THX	; 22	=	(x86-64)	TinyAHX				*.AHX;*.THX - Tiny AHX (not official tiny ahxplay = x86 -2.2Kb / x64 -2.6Kb)
	#XMU_TPT	; 23	=	(x86-64)	TinyPT2				*.MOD (Tiny Protracker 2.3D - not official tiny pt2play = x86 -6.1Kb / x64 -6.9Kb)
	#XMU_TSR	; 24	=	(x86)		tsidreplay			*.SID
	#XMU_V1M	; 25	=	(x86)		libv2					*.V2M (1.0) ERROR!
	#XMU_V2M	; 26	=	(x86)		libv2simple			*.V2M (1.5)
	#XMU_WAV	; 27	=	(x86-64)	Purebasic native	*.WAV
	#XMU_XM2	; 28	=	(x86)		ufmod					*.XM (FastTracker2 often False/true)
	#XMU_YMP	; 29	=	(x86)		YmPlugin				*.YM
EndEnumeration
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = -
; CompileSourceDirectory