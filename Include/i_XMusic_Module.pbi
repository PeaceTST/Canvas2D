;*********************************************
;- C2D MUSIC / 27.06.2022
;*********************************************

EnableExplicit

XIncludeFile	"i_XMusic_Types.pbi"

; *** Error-Check with x64 ***
CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64

	CompilerSelect	#IsC2D_Music
		CompilerCase	#XMU_AMP	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_BAS	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_BMF	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_FCP	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_MED	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_S68	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_SID	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_TSR	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_V1M	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_V2M	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_XM2	:	#XMU_ERROR	=	1
		CompilerCase	#XMU_YMP	:	#XMU_ERROR	=	1
		CompilerDefault			:	#XMU_ERROR	=	0
	CompilerEndSelect

	CompilerIf	#XMU_ERROR
		MA_ERROR("#IsC2D_Music = #XMU_(mode) not supported with x64, see i_C2D_Music.pbi")
	CompilerEndIf

CompilerEndIf

CompilerIf	#IsC2D_Music	=	#XMU_AMP	; C:\Users\Public\Documents\AmpMaster\

	PrototypeC	pAmp_Free()
	PrototypeC	pAmp_Play(*File.p-Ascii, Volume.l=255)
	PrototypeC	pAmp_MusicGetLength(Flags.i=0)
	PrototypeC	pAmp_GetPercent()
	PrototypeC	pAmp_SetAmpPath(*Path.p-Ascii)

	Structure	RS_Amp
		DLL.i
		IsPlay.i
		TimeLength.i
		TimeLoop.i
		File$
		Play.pAmp_Play
		Free.pAmp_Free
		Time.pAmp_MusicGetLength
		Done.pAmp_GetPercent
		Path.pAmp_SetAmpPath
	EndStructure

	Global	RS_Amp.RS_Amp

	ProcedureC	MusicFree()
		With	RS_Amp
			If	\DLL
				\Free()
				FreeLibrary_(\DLL)
				\DLL	=	#Null
			EndIf
		EndWith
	EndProcedure
	ProcedureC	MusicInit(Path$=#Null$)

		; Default path to AmpMaster -> "C:\Users\Public\Documents\AmpMaster\"

		If	RS_Amp\DLL	:	ProcedureReturn	RS_Amp\DLL	:	EndIf

		Protected	t$

		With	RS_Amp

			If	Path$

				t$	=	Path$

			Else	; C:\Users\Public\Documents\ + "AmpMaster\"

				CompilerIf	#PB_Compiler_Version	<	560
					t$	=	Space(#MAX_PATH)
					SHGetFolderPath_(#Null, #CSIDL_COMMON_DOCUMENTS, #Null, #Null, @t$)
					t$	+	"\"
				CompilerElse
					t$	=	GetUserDirectory(#PB_Directory_Public)
				CompilerEndIf

				t$	+	"AmpMaster\"

			EndIf

			t$	+	"AmpMaster_x86.dll"

			\DLL	=	LoadLibrary_(@t$)

			If	\DLL

				\Play	=	GetProcAddress_(\DLL, Uni2Asc(@"Amp_Play"))
				\Free	=	GetProcAddress_(\DLL, Uni2Asc(@"Amp_Free"))
				\Time	=	GetProcAddress_(\DLL, Uni2Asc(@"Amp_MusicGetLength"))
				\Done	=	GetProcAddress_(\DLL, Uni2Asc(@"Amp_GetPercent"))
				\Path	=	GetProcAddress_(\DLL, Uni2Asc(@"Amp_SetAmpPath"))

				If	Path$
					Path$	+	"AmpLibs\"	:	\Path(Uni2Asc(@Path$))	; set path of amplibs
				EndIf

			EndIf

			ProcedureReturn	\DLL

		EndWith

	EndProcedure
	ProcedureC	MusicPlay(*Memory, Length=#Null, SubSong=#Null)

		; *Memory	=	Ptr to @Filename$ only!
		; Length		=	Not supported, always #Null
		; SubSong	=	Number of subsong to play (eg. SID)

		; Return: #True = Music is playing or #False = Error!

		With	RS_Amp

			\IsPlay		=	#False
			\TimeLength	=	#Null
			\TimeLoop	=	#Null
			\File$		=	PeekS(*Memory)

			If	MusicInit()

				\Free()

				If	\Play(Uni2Asc(@\File$))	=	0
					\TimeLength	=	\Time()
					\TimeLoop	=	\TimeLength	+	C2D\Time	+	250	; <- Time to reset
					\IsPlay		=	#True
				EndIf

				ProcedureReturn	\IsPlay

			EndIf

		EndWith

	EndProcedure
	ProcedureC	MusicStop()
		RS_Amp\Free()	:	RS_Amp\IsPlay	=	#False
	EndProcedure
	ProcedureC	MusicLoop()
		If	RS_Amp\IsPlay	And	C2D\Time	>	RS_Amp\TimeLoop
			ProcedureReturn	MusicPlay(@RS_Amp\File$)
		EndIf
	EndProcedure
	ProcedureC	MusicPercent()
		If	RS_Amp\IsPlay
			ProcedureReturn	RS_Amp\Done()
		EndIf
	EndProcedure
	ProcedureC	MusicLength()
		ProcedureReturn	RS_Amp\TimeLength
	EndProcedure

CompilerElse

	Structure	RS_ModMusic
		ID.i
		Volume.l
	EndStructure

	Global	RS_ModMusic.RS_ModMusic

	IncludePath	"MusicLibs\"
	
	; *** Include libs (x86) ****************
	CompilerSelect	#IsC2D_Music

		CompilerCase	#XMU_MOD	;{ * Native PureBasic ModPlug Library * }

			; *.669;*.ABC;*.AMF;*.AMS;*.DBM;*.DMF;*.FAR;*.IT;*.J2B;*.MDL;*.MED;*.MID;*.MOD;*.MT2;*.MTM;*.OKT;*.PAT;*.PSM;*.PTM;*.S3M;*.STM;*.ULT;*.UMX;*.WAV;*.XM;*.MMCMP;*.PP

			InitSound()

			;}

		CompilerCase	#XMU_FLA	;{ * Native PureBasic FLAC Decoder * }

			; *.FLAC

			InitSound()
			UseFLACSoundDecoder()

			;}

		CompilerCase	#XMU_OGG	;{ * Native PureBasic OGG Decoder * }

			; *.OGG

			InitSound()
			UseOGGSoundDecoder()

			;}
			
		CompilerCase	#XMU_WAV	;{ * Native PureBasic WAV Decoder * }

			; *.WAV
			
			InitSound()
			;}

		CompilerCase	#XMU_MOV	;{ * Native PureBasic Movie Library * }

			; *.MP3;*.WAV;*.WMA...

			InitMovie()

			;}

		CompilerCase	#XMU_FT2	;{ * Thanx to Olav "8bitbubsy" for the opensource FT2PLAY v1.04 * }

			; Copyright (c) 2016-2020, Olav "8bitbubsy" Sørensen

			; https://16-bits.org
			; https://pastebin.com/0TLkMm0A

			; *.FT;*.MOD;*.STK;*.XM

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playFT2_x64.lib"
					ft2play_Close()
					ft2play_GetAmp()			; 1..32
					ft2play_GetMasterVol()	; 0..256
					ft2play_GetMixerTicks()	; returns the amount of milliseconds of mixed audio (not realtime)
					ft2play_GetSongName()	; max 20 chars (21 with '\0'), string is in code page 437
					ft2play_PauseSong(flag)
					ft2play_PlaySong(*moduleData, length, interpolation, volumeramping, freq)	; returns 1 = playing or 0 = error
					ft2play_SetAmp(factor)				; 1..32
					ft2play_SetInterpolation(flag)	; true/#false
					ft2play_SetMasterVol(vol)			; 0..256
					ft2play_SetVolumeRamping(flag)	; true/false
					ft2play_TogglePause()
				EndImport
			CompilerElse
				ImportC	"playFT2_x86.lib"
					ft2play_Close()						As	"_ft2play_Close"
					ft2play_GetAmp()						As	"_ft2play_GetAmp"
					ft2play_GetMasterVol()				As	"_ft2play_GetMasterVol"
					ft2play_GetMixerTicks()				As	"_ft2play_GetMixerTicks"
					ft2play_GetSongName()				As	"_ft2play_GetSongName"
					ft2play_PauseSong(flag)				As	"_ft2play_PauseSong"
					ft2play_PlaySong(*moduleData, length, interpolation, volumeramping, freq)	As	"_ft2play_PlaySong"
					ft2play_SetAmp(factor)				As	"_ft2play_SetAmp"
					ft2play_SetInterpolation(flag)	As	"_ft2play_SetInterpolation"
					ft2play_SetMasterVol(vol)			As	"_ft2play_SetMasterVol"
					ft2play_SetVolumeRamping(flag)	As	"_ft2play_SetVolumeRamping"
					ft2play_TogglePause()				As	"_ft2play_TogglePause"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_PT2	;{ * Thanx to Olav "8bitbubsy" for the opensource PT2PLAY v1.60 * }

			; https://16-bits.org
			; https://pastebin.com/pg95YduC

			; *.MOD

			#CIA_TEMPO_MODE		=	0
			#VBLANK_TEMPO_MODE	=	1

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playPT2_x64.lib"
					pt2play_Close()
					pt2play_GetMasterVol()	; 0..256
					pt2play_GetMixerTicks()	; returns the amount of milliseconds of mixed audio (not realtime)
					pt2play_GetSongName()	; max 20 chars (21 with '\0'), string is in code page 437
					pt2play_PauseSong(flag)	; true/false
					pt2play_PlaySong(*moduleData, length, tempoMode, freq)	; returns 1 = playing or 0 = error
					pt2play_SetMasterVol(vol)		; 0..256
					pt2play_SetStereoSep(percent)	; 0..100
					pt2play_TogglePause()
				EndImport
			CompilerElse
				ImportC	"playPT2_x86.lib"
					pt2play_Close()					As	"_pt2play_Close"
					pt2play_GetMasterVol()			As	"_pt2play_GetMasterVol"
					pt2play_GetMixerTicks()			As	"_pt2play_GetMixerTicks"
					pt2play_GetSongName()			As	"_pt2play_GetSongName"
					pt2play_PauseSong(flag)			As	"_pt2play_PauseSong"
					pt2play_PlaySong(*moduleData, length, tempoMode, freq)	As	"_pt2play_PlaySong"
					pt2play_SetMasterVol(vol)		As	"_pt2play_SetMasterVol"
					pt2play_SetStereoSep(percent)	As	"_pt2play_SetStereoSep"
					pt2play_TogglePause()			As	"_pt2play_TogglePause"
				EndImport
			CompilerEndIf

			;}
			
		CompilerCase	#XMU_TPT	;{ * Not offical TINY PT2PLAY v1.60 (pt2play) * }
			
			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"tinyPT2_x64.lib"
					pt2play_Close()
					pt2play_PlaySong(*moduleData, length)	; returns 1 = playing or 0 = error
				EndImport
			CompilerElse
				ImportC	"tinyPT2_x86.lib"
					pt2play_Close()	As	"_pt2play_Close"
					pt2play_PlaySong(*moduleData, length)	As	"_pt2play_PlaySong"
				EndImport
			CompilerEndIf
			
		;}

		CompilerCase	#XMU_FC4	;{ * Thanx to Olav "8bitbubsy" for the opensource FC14PLAY v1.29 * }

			; https://16-bits.org
			; https://pastebin.com/VHxZ58UC

			; *.FC;*.FC13;*.FC14;*.FC3;*.FC4;*.FCM;*.SMOD

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playFC4_x64.lib"
					fc14play_Close()
					fc14play_GetMasterVol()
					fc14play_GetMixerTicks()	; returns the amount of milliseconds of mixed audio (not realtime)
					fc14play_PauseSong(flag)	; true/false
					fc14play_PlaySong(*moduleData, length, freq)	; returns 1 = playing or 0 = error
					fc14play_SetMasterVol(vol)			; 0..256
					fc14play_SetStereoSep(percent)	; 0..100
					fc14play_TogglePause()
				EndImport
			CompilerElse
				ImportC	"playFC4_x86.lib"
					fc14play_Close()						As	"_fc14play_Close"
					fc14play_GetMasterVol()				As	"_fc14play_GetMasterVol"
					fc14play_GetMixerTicks()			As	"_fc14play_GetMixerTicks"
					fc14play_PauseSong(flag)			As	"_fc14play_PauseSong"
					fc14play_PlaySong(*moduleData, length, freq)	As	"_fc14play_PlaySong"
					fc14play_SetMasterVol(vol)			As	"_fc14play_SetMasterVol"
					fc14play_SetStereoSep(percent)	As	"_fc14play_SetStereoSep"
					fc14play_TogglePause()				As	"_fc14play_TogglePause"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_TFC	;{ * Not official TINY FC14PLAY v1.29 * }

			; https://16-bits.org
			; https://pastebin.com/VHxZ58UC

			; *.FC;*.FC13;*.FC14;*.FC3;*.FC4;*.FCM;*.SMOD

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"tinyFC4_x64.lib"
					fc14play_Close()
					fc14play_PlaySong(*moduleData, length)	; returns 1 = playing or 0 = error
				EndImport
			CompilerElse
				ImportC	"tinyFC4_x86.lib"
					fc14play_Close()	As	"_fc14play_Close"
					fc14play_PlaySong(*moduleData, length)	As	"_fc14play_PlaySong"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_AHX	;{ * Thanx to Olav "8bitbubsy" for the opensource AHX1PLAY v0.27 * }

			; https://16-bits.org
			; https://pastebin.com/fqwadbj7

			; *.AHX;*.THX

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playAHX_x64.lib"
					ahx1play_PlaySong(*moduleData, length, subsong, freq)	; returns 1 = playing or 0 = error
					ahx1play_GetSongName()				; max 64 chars (65 with '\0'), string is in latin1
					ahx1play_Close()
					ahx1play_PauseSong(flag)			; true/false
					ahx1play_TogglePause()
					ahx1play_GetMixerTicks()			; returns the amount of milliseconds of mixed audio (not realtime)
					ahx1play_SetStereoSep(percent)	; 0..100
				EndImport
			CompilerElse
				ImportC	"playAHX_x86.lib"
					ahx1play_PlaySong(*moduleData, length, subsong, freq)	As	"_ahx1play_PlaySong"
					ahx1play_GetSongName()				As	"_ahx1play_GetSongName"
					ahx1play_Close()						As	"_ahx1play_Close"
					ahx1play_PauseSong(flag)			As	"_ahx1play_PauseSong"
					ahx1play_TogglePause()				As	"_ahx1play_TogglePause"
					ahx1play_GetMixerTicks()			As	"_ahx1play_GetMixerTicks"
					ahx1play_SetStereoSep(percent)	As	"_ahx1play_SetStereoSep"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_THX	;{ * Not official TINY AHX1PLAY v0.27 * }

			; https://16-bits.org
			; https://pastebin.com/fqwadbj7

			; *.AHX;*.THX

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"tinyAHX_x64.lib"
					ahx1play_PlaySong(*moduleData, length, subsong)	; returns 1 = playing or 0 = error
					ahx1play_Close()
				EndImport
			CompilerElse
				ImportC	"tinyAHX_x86.lib"
					ahx1play_PlaySong(*moduleData, length, subsong)	As	"_ahx1play_PlaySong"
					ahx1play_Close()	As	"_ahx1play_Close"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_STM	;{ * Thanx to Olav "8bitbubsy" for the opensource STMPLAY v0.33 * }

			; https://16-bits.org
			; https://pastebin.com/ifXSCZ71

			; *.STM

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playST2_x64.lib"
					st23play_Close()
					st23play_GetMasterVol()		; 0..256
					st23play_GetMixerTicks()	; returns the amount of milliseconds of mixed audio (not realtime)
					st23play_GetSongName()		; max 20 chars (21 with '\0'), string is in code page 437
					st23play_PauseSong(flag)	; true/false
					st23play_PlaySong(*moduleData, dataLength, useInterpolationFlag, audioFreq)	; returns 1 = playing or 0 = error
					st23play_SetInterpolation(flag)	; true/false
					st23play_SetMasterVol(vol)			; 0..256
					st23play_TogglePause()
				EndImport
			CompilerElse
				ImportC	"playST2_x86.lib"
					st23play_Close()						As	"_st23play_Close"
					st23play_GetMasterVol()				As	"_st23play_GetMasterVol"
					st23play_GetMixerTicks()			As	"_st23play_GetMixerTicks"
					st23play_GetSongName()				As	"_st23play_GetSongName"
					st23play_PauseSong(flag)			As	"_st23play_PauseSong"
					st23play_PlaySong(*moduleData, dataLength, useInterpolationFlag, audioFreq)	As	"_st23play_PlaySong"
					st23play_SetInterpolation(flag)	As	"_st23play_SetInterpolation"
					st23play_SetMasterVol(vol)			As	"_st23play_SetMasterVol"
					st23play_TogglePause()				As	"_st23play_TogglePause"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_S3M	;{ * Thanx to Olav "8bitbubsy" for the opensource ST3PLAY v0.91+ (x86) / v0.99 (x64) * }

			; https://16-bits.org
			; https://pastebin.com/AwRXZAw7

			; *.S3M

			#SOUNDCARD_GUS		=	0	;/* Default */
			#SOUNDCARD_SBPRO	=	1

			Import	"winmm.lib"	:	EndImport

			CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
				Import	"playST3_x64.lib"
					st3play_Close()
					st3play_GetMasterVol()	; 0..256
					st3play_GetMixerTicks()	; returns the amount of milliseconds of mixed audio (not realtime)
					st3play_GetSongName()
					st3play_PauseSong(flag)	; true/false
					st3play_PlaySong(*moduleData, length, flag, type, freq)	; returns 1 = playing or 0 = error
					st3play_SetInterpolation(flag)	; true/false
					st3play_SetMasterVol(vol)			; 0..256
					st3play_TogglePause()
				EndImport
			CompilerElse
				ImportC	"playST3_x86.lib"	; ST3PLAY v0.91 last working for x86
					st3play_Close()						As	"_st3play_Close"
					st3play_GetMixerTicks()				As	"_st3play_GetMixerTicks"
					st3play_GetSongName()				As	"_st3play_GetSongName"
					st3play_PauseSong(flag)				As	"_st3play_PauseSong"
					st3play_PlaySong(*moduleData, length, flag, type, freq)	As	"_st3play_PlaySong"
					st3play_SetInterpolation(flag)	As	"_st3play_SetInterpolation"
					st3play_SetMasterVol(vol)			As	"_st3play_SetMasterVol"
					st3play_TogglePause()				As	"_st3play_TogglePause"
				EndImport
			CompilerEndIf

			;}

		CompilerCase	#XMU_V1M	;{ * Thanx to kb^farbrausch for the static libv2.lib v1.0 / Error * }

			; *.V2M 1.0

			Import	"winmm.lib"		:	EndImport
			Import	"dsound.lib"	:	EndImport

			Import	"libv2_x86.lib"
				ssClose()					As	"_ssClose@0"
				ssDoTick()					As	"_ssDoTick@0"
				ssFadeOut(milliseconds)	As	"_ssFadeOut@4"
				ssGetTime()					As	"_ssGetTime@0"
				ssInit(*module, *hWnd)	As	"_ssInit@8"
				ssPlay()						As	"_ssPlay@0"
				ssStop()						As	"_ssStop@0"
			EndImport
			;}

		CompilerCase	#XMU_V2M	;{ * Thanx to kb^farbrausch for the static libv2simple.lib v1.5 * }

			; *.V2M 1.5

			Prototype	DSIOCALLBACK(*param, *buf.FLOAT, length)
			Prototype	PERCENTCALLBACK(percent.f)

			Import	"dsound.lib"	:	EndImport

			Import	"libv2simple_x86.lib"
				V2MClose()											As "_V2MClose@0"
				V2MGetChannelVU(channel, *left, *right)	As	"_V2MGetChannelVU@12"
				V2MGetCurrentTime()								As	"_V2MGetCurrentTime@0"
				V2MGetTotalTime()									As	"_V2MGetTotalTime@0"
				V2MInit(*tune, samplerate, *hWnd)			As	"_V2MInit@12"
				V2MIsPlaying()										As	"_V2MIsPlaying@0"
				V2MPlay(start=0)									As	"_V2MPlay@4"
				V2MSaveAsWave(a.s, *b.PERCENTCALLBACK)		As	"_V2MSaveAsWave@8"
				V2MSetRepeat(status.b)							As	"_V2MSetRepeat@4"
				V2MSetVUMode(mode)								As	"_V2MSetVUMode@4"
				V2MStop(fade=0)									As	"_V2MStop@4"
				;initializes DirectSound output.
				;callback: your render callback function
				;parm: a pointer that'll be supplied to the function on every call
				;hWnd: window handle of your application (GetForegroundWindow() works quite well :)
				dsInit(*callback.DSIOCALLBACK, *parm, *hWnd)	As	"_dsInit@12"
				dsClose()					As	"_dsClose@0"		;shuts down DirectSound output
				dsGetCurSmp()				As	"_dsGetCurSmp@0"	;gets sample-exact and latency compensated current play position
				dsSetVolume(vol.f=1.0)	As	"_dsSetVolume@4"	;sets player volume (Default is 1.0)
				;forces rendering thread to update. On single-core CPUs it's a good idea to
				;call this once per frame (improves A/V sync And reduces any stuttering),
				;With more than one CPU it's pretty much useless.
				dsTick()	As	"_dsTick@0"
				;lock And unlock the sound thread's thread sync lock. If you want to modify
				;any of your sound variables outside the render thread, encapsulate that part
				;of code in between these two functions.
				dsLock()		As	"_dsLock@0"
				dsUnlock()	As	"_dsUnlock@0"
			EndImport

			;}

		CompilerCase	#XMU_XM2	;{ * Thanx to Quantum for the FastTracker2 uFMOD static lib }

			; *.XM

			#XM_RESOURCE			=	0
			#XM_MEMORY				=	1
			#XM_FILE					=	2
			#XM_NOLOOP				=	8
			#XM_SUSPENDED			=	16
			#uFMOD_MIN_VOL			=	0
			#uFMOD_MAX_VOL			=	25
			#uFMOD_DEFAULT_VOL	=	25

			Import	"winmm.lib"	:	EndImport

			Import	"ufmod_x86.lib"
				uFMOD_GetRowOrder()								As	"_uFMOD_GetRowOrder@0"	;Returns the current order in hi-order word and row in low-order word
				uFMOD_GetStats()									As	"_uFMOD_GetStats@0"		;Returns the L RMS volume in hi-order word and R RMS in low-order word
				uFMOD_GetTime()									As	"_uFMOD_GetTime@0"		;Returns the time in milliseconds since the song was started
				uFMOD_GetTitle()									As	"_uFMOD_GetTitle@0"		;Returns the track's title
				uFMOD_Jump2Pattern(pat)							As	"_uFMOD_Jump2Pattern@4"	;Jumps to the specified zero based pattern index
				uFMOD_Pause()										As	"_uFMOD_Pause@0"			;Pauses the currently playing song, if any
				uFMOD_PlaySong(*lpXM, param=0, fdwSong=0)	As	"_uFMOD_PlaySong@12"		;Starts playing an XM song, *lpXM -> 0 = Stopp song
				uFMOD_Resume()										As	"_uFMOD_Resume@0"			;Resumes the currently paused song, if any
				uFMOD_SetVolume(vol)								As	"_uFMOD_SetVolume@4"		;Sets global volume: 0 - 25
			EndImport

			;}

		CompilerCase	#XMU_SID	;{ * Thanx to statmat for the titchysid_extras.lib * }

			; *.SID

			#SID_RESOURCE		=	0	;Load SID file from a resource
			#SID_MEMORY			=	1	;Load SID file from provided memory

			;Options used in SIDOpen()
			#SID_DEFAULT		=	1	;Play Default subsong, as found in the PSID header
			#SID_NON_DEFAULT	=	2	;Play specified subsong

			;Import	"winmm.lib"		:	EndImport	; Not really needed!
			Import	"masm32_x86.lib"	:	EndImport

; 			Import	"titchysid_extras_x86.lib"
; 				SIDOpen(*mem, len, mode, options, subsong)	As	"_SIDOpen@20"		;Returns non-zero on success
; 				SIDClose()												As	"_SIDClose@0"		;Close the SID library
; 				SIDChangeSong(song)									As	"_SIDChangeSong@4";Change to another sub song in the currently playing SID file
; 				SIDPause()												As	"_SIDPause@0"		;Pause the currently playing SID song
; 				SIDPlay()												As	"_SIDPlay@0"		;Start the SID playback
; 				SIDResume()												As	"_SIDResume@0"		;Resume playing the SID song after a pause
; 				SIDStop()												As	"_SIDStop@0"		;Stop the SID playback
; 			EndImport
			Import	"titchysid_x86.lib"
				SIDOpen(*mem, len, mode, options, subsong)	As	"_SIDOpen@20"		;Returns non-zero on success
				SIDClose()												As	"_SIDClose@0"		;Close the SID library
			EndImport

			;}

		CompilerCase	#XMU_TSR	;{ * Thanx to unknown? for the tsidreplay.lib * }

			; *.SID

			ImportC	"tsidreplay_x86.lib"
				sid_sound_server_replay_init(*mem, len, subsong)	As	"_sid_sound_server_replay_init"
				sid_sound_server_replay_play()							As	"_sid_sound_server_replay_play"
				sid_sound_server_replay_stop()							As	"_sid_sound_server_replay_stop"
			EndImport

			;}

		CompilerCase	#XMU_FCP	;{ * Thanx to SiRioKD for the tFCLIB.lib (FutureComposer 1.4) * }

			; *.FC;*.FC4;*.FC14

			Import	"winmm.lib"		:	EndImport	; Not really needed?
			Import	"dsound.lib"	:	EndImport

			Import	"tFCLIB_x86.lib"
				FCp_Open(*hWnd)		As	"_FCp_Open@4"
				FCp_InitModule(*Ptr)	As	"_FCp_InitModule@4"
				FCp_Start()				As	"_FCp_Start@0"
				FCp_Close()				As	"_FCp_Close@0"
			EndImport

			;}

		CompilerCase	#XMU_BAS	;{ * Thanx to Ghandi for the ripped bassmod.lib * }

			; *.XM;*.IT;*.S3M;*.MOD;*.MTM;*.UMX

			#BASS_OK                 = 0   ; all is OK
			#BASS_ERROR_MEM          = 1	 ; memory error
			#BASS_ERROR_FILEOPEN     = 2	 ; can't open the file
			#BASS_ERROR_DRIVER       = 3	 ; can't find a free/valid driver
			#BASS_ERROR_HANDLE       = 5	 ; invalid handle
			#BASS_ERROR_FORMAT       = 6	 ; unsupported format
			#BASS_ERROR_POSITION     = 7	 ; invalid playback position
			#BASS_ERROR_INIT         = 8	 ; BASS_Init has not been successfully called
			#BASS_ERROR_ALREADY      = 14	 ; already initialized/loaded
			#BASS_ERROR_ILLTYPE      = 19	 ; an illegal type was specified
			#BASS_ERROR_ILLPARAM     = 20	 ; an illegal parameter was specified
			#BASS_ERROR_DEVICE       = 23	 ; illegal device number
			#BASS_ERROR_NOPLAY       = 24	 ; not playing
			#BASS_ERROR_NOMUSIC      = 28	 ; no MOD music has been loaded
			#BASS_ERROR_NOSYNC       = 30	 ; synchronizers have been disabled
			#BASS_ERROR_NOTAVAIL     = 37	 ; requested data is not available
			#BASS_ERROR_DECODE       = 38	 ; the channel is a "decoding channel"
			#BASS_ERROR_FILEFORM     = 41	 ; unsupported file format
			#BASS_ERROR_UNKNOWN      = -1	 ; some other mystery error

			; Device setup flags
			#BASS_DEVICE_8BITS       = 1   ; use 8 bit resolution, else 16 bit
			#BASS_DEVICE_MONO        = 2	 ; use mono, else stereo
			#BASS_DEVICE_NOSYNC      = 16	 ; disable synchronizers

			#BASS_MUSIC_RAMP         =       1	; normal ramping
			#BASS_MUSIC_RAMPS        =       2	; sensitive ramping
			#BASS_MUSIC_LOOP         =       4	; loop music
			#BASS_MUSIC_FT2MOD       =      16	; play .MOD as FastTracker 2 does
			#BASS_MUSIC_PT1MOD       =      32	; play .MOD as ProTracker 1 does
			#BASS_MUSIC_POSRESET     =     256	; stop all notes when moving position
			#BASS_MUSIC_SURROUND     =     512	; surround sound
			#BASS_MUSIC_SURROUND2    =    1024	; surround sound (mode 2)
			#BASS_MUSIC_STOPBACK     =    2048	; stop the music on a backwards jump effect
			#BASS_MUSIC_CALCLEN      =    8192	; calculate playback length
			#BASS_MUSIC_NONINTER     =   16384	; non-interpolated mixing
			#BASS_MUSIC_NOSAMPLE     = $400000	; don't load the samples

			#BASS_UNICODE            = $80000000

			#BASS_SYNC_MUSICPOS      = 0
			#BASS_SYNC_POS           = 0
			#BASS_SYNC_MUSICINST     = 1
			#BASS_SYNC_END           = 2
			#BASS_SYNC_MUSICFX       = 3
			#BASS_SYNC_ONETIME       = $80000000	; FLAG: sync only once, else continuously

			; BASSMOD_ChannelIsActive return values
			#BASS_ACTIVE_STOPPED     = 0
			#BASS_ACTIVE_PLAYING     = 1
			#BASS_ACTIVE_PAUSED      = 3

			Import	"winmm.lib"		:	EndImport

			Import	"bassmod_x86.lib"
				BASSMOD_DllMain(*hInstance, fdwReason, lpvReserved)
				BASSMOD_Init(device=-1, freq=44100, flags=0)
				BASSMOD_GetVolume()
				BASSMOD_SetVolume(volume)
				BASSMOD_Free()
				BASSMOD_MusicLoad(mem, *file, offset=#Null, length=#Null, flags=#BASS_MUSIC_LOOP|#BASS_MUSIC_POSRESET)	;mem=#true -> Load from *memory
				BASSMOD_MusicPlay()
				BASSMOD_MusicStop()
				BASSMOD_MusicSetVolume(chanins, volume)
				BASSMOD_MusicGetLength(playlen)
				BASSMOD_MusicFree()
			EndImport
			;}

		CompilerCase	#XMU_S68	;{ * Thanx to benjihan for the MC68000 Amiga/Atari SC68 libsc68replay.lib * }

			; http://sc68.atari.org/index.html

			; *.S68

			#SC68Replay_MEMORY	=	0
			#SC68Replay_FILE		=	1

			Import	"winmm.lib"	:	EndImport

			ImportC	"libsc68replay_x86.lib"
				sc68replay_Init(*Ptr, Size, Mode)	As	"_sc68replay_Init"
				sc68replay_Play()							As	"_sc68replay_Play"
				sc68replay_Stop()							As	"_sc68replay_Stop"
			EndImport
			;}

		CompilerCase	#XMU_BMF	;{ * Thanx to BeRo^farbraush for the BR404 Software Synthesizer libbr404.lib BMF * }

			; *.BRO

			Import	"libbr404_x86.lib"
				SynthCreate(SampleRate, BufferSize, ThreadPlay, SoundOutput)	As	"_SynthCreate@16"	; = int Track
				SynthReadBMFSampleRate(*Ptr, Size)										As	"_SynthReadBMFSampleRate@8"
				SynthReadBMF(Track, *Ptr, Size)											As	"_SynthReadBMF@12"
				SynthPlay(Track)																As	"_SynthPlay@4"
				SynthSetLooping(Track, Looping)											As	"_SynthSetLooping@8"
				SynthEnter(Track)																As	"_SynthEnter@4"
				SynthStop(Track)																As	"_SynthStop@4"
				SynthLeave(Track)																As	"_SynthLeave@4"
				SynthDestroy(Track)															As	"_SynthDestroy@4"
			EndImport
			;}

		CompilerCase	#XMU_MED	;{ * MEDPDLL static lib ripped by Peace^TST (best medplayer) * }

			; *.MED;*.MMD0;*.MMD1;*.MMD2;*.MMD3;*.MOD (PP20)

			Import	"winmm.lib"	:	EndImport
			Import	"dsound.lib":	EndImport

			Import	"medpdll_x86.lib"
				MEDPDLL_DllMain(*hinstDLL, fdwReason, lpvReserved)	As	"_MEDPDLL_DllMain@12"
				MEDP_Initialize(*instance, *mainwindow)				As	"__MEDP_Initialize@8"
				MEDP_ChangeOption(option, newvalue)						As	"__MEDP_ChangeOption@8"
				MEDP_Load(*filename)											As	"__MEDP_Load@4"
				MEDP_IsLoaded()												As	"__MEDP_IsLoaded@0"
				MEDP_Play()														As	"__MEDP_Play@0"
				MEDP_Stop()														As	"__MEDP_Stop@0"
				MEDP_Unload()													As	"__MEDP_Unload@0"
				MEDP_ModuleLength()											As	"__MEDP_ModuleLength@0"
				MEDP_ModuleTime()												As	"__MEDP_ModuleTime@0"
				MEDP_PlayPosition()											As	"__MEDP_PlayPosition@0"
				MEDP_SetPlayPosition(pos)									As	"__MEDP_SetPlayPosition@4"
				MEDP_IsPlaying()												As	"__MEDP_IsPlaying@0"
				MEDP_ModuleName(*buffer, max)								As	"__MEDP_ModuleName@8"
				MEDP_Release()													As	"__MEDP_Release@0"
			EndImport
			;}

		CompilerCase	#XMU_YMP	;{ * YmPluginDLL static lib ripped by Peace^TST * }

			; *.YM

; 			Structure RS_ymMusicInfo_t
; 				*pSongName
; 				*pSongAuthor
; 				*pSongComment
; 				*pSongType
; 				*pSongPlayer
; 				musicTimeInSec.l
;				musicTimeInMs.l
; 			EndStructure

			Import	"winmm.lib"	:	EndImport

			Import	"YmPlugin_x86.lib"
				YMPLUGIN_DllMain(*hinstDLL, fdwReason, lpvReserved)	As	"_YMPLUGIN_DllMain@12"
				YM_Close()							As	"__YM_Close@0"
				YM_FFT()								As	"__YM_FFT@0"
				YM_Get_Info(struct)				As	"__YM_Get_Info@4"		; RS_ymMusicInfo_t
				YM_Init()							As	"__YM_Init@0"
				YM_Open(*file, *memory, size)	As	"__YM_Open@12"			; file (size=0) or memory (size <>0)
				YM_Pause()							As	"__YM_Pause@0"
				YM_Play()							As	"__YM_Play@0"
				YM_Seek(seconds)					As	"__YM_Seek@4"
				YM_SetVolume(vol)					As	"__YM_SetVolume@4"	; 0..255
				YM_Stop()							As	"__YM_Stop@0"
			EndImport
			;}

		CompilerCase	#XMU_SCA	;{ * SCAL_X86-64 DLL by Peace^TST * }

			Prototype	SCAL_CallBack(*CallBack=0)
			Prototype	SCAL_Formats(Mode, Flags)
			Prototype	SCAL_Free()
			Prototype	SCAL_GetLength(Flags=0)
			Prototype	SCAL_GetMode(Flags=0)
			Prototype	SCAL_GetPosition(Flags=0)
			Prototype	SCAL_GetSize(Flags=0)
			Prototype	SCAL_GetSubsongs()
			Prototype	SCAL_GetTitle()
			Prototype	SCAL_GetTracker()
			Prototype	SCAL_Info(Flags=0)
			Prototype	SCAL_IsFormat(Mode, *Memory.Long, Length=0)
			Prototype	SCAL_Pause(Flags)
			Prototype	SCAL_Play(Mode, *Memory, Length=0, Subsong=0)
			Prototype	SCAL_SetFreq(Freq)
			Prototype	SCAL_SetString(Format)
			Prototype	SCAL_SetVolume(Percent)
			Prototype	SCAL_Version()

			Structure	RS_SCAL
				DLL.i
				*Proc
				CallBack		.SCAL_CallBack
				Formats		.SCAL_Formats
				Free			.SCAL_Free
				GetLength	.SCAL_GetLength
				GetMode		.SCAL_GetMode
				GetPosition	.SCAL_GetPosition
				GetSize		.SCAL_GetSize
				GetSubsongs	.SCAL_GetSubsongs
				GetTitle		.SCAL_GetTitle
				GetTracker	.SCAL_GetTracker
				Info			.SCAL_Info
				IsFormat		.SCAL_IsFormat
				Pause			.SCAL_Pause
				Play			.SCAL_Play
				SetFreq		.SCAL_SetFreq
				SetString	.SCAL_SetString
				SetVolume	.SCAL_SetVolume
				Version		.SCAL_Version
			EndStructure

			Global	RS_SCAL.RS_SCAL
			;}

		;CompilerCase	#XMU_MCI	; *.MID;*.MO3;*.MP3;*.OGG;*.WMA...
		;CompilerCase	#XMU_API	; *.WAV

	CompilerEndSelect

	Procedure	MusicInit(Path$=#Null$, *CallBack=#Null)
		CompilerSelect	#IsC2D_Music
			CompilerCase	#XMU_SCA

				Protected	DLL$

				With	RS_SCAL

					\Proc	=	*CallBack	; call custom proc(param) while download?

					If	\DLL
						ProcedureReturn	#True	; Important!
					EndIf

					CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
						DLL$	=	"SCAL_x64.dll"
					CompilerElse
						DLL$	=	"SCAL_x86.dll"
					CompilerEndIf

					If	Len(Path$)
						PathAddBackslash_(Path$)
					Else
						Path$	=	GetPathPart(ProgramFilename())
					EndIf
					
					DLL$	=	Path$	+	DLL$

					\DLL =	LoadLibrary_(@DLL$)

					If	\DLL

						\CallBack		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_CallBack"))		; callback for download
						\Formats			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Formats"))			; return count of formats or ptr to formatsstring (full/mode)
						\Free				=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Free"))				; stop the song
						\GetLength		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetLength"))		; length of playtime or ptr to timestring
						\GetMode			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetMode"))			; #Mode or ptr to modestring
						\GetPosition	=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetPosition"))	; current play-position in ms or ptr to timestring
						\GetSize			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetSize"))			; ByteSize or ptr to sizestring of media (net/file/memory)
						\GetSubsongs	=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetSubsongs"))	; #Number of subsongs of current playing media (sid only)
						\GetTitle		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetTitle"))		; ptr to name auf current playing song
						\GetTracker		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_GetTracker"))		; ptr to name auf tracker
						\Info				=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Info"))				; if playing opens msgbox with infos (for easy use only)
						\IsFormat		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_IsFormat"))		; check file.extension ?.* and *.? or *Memoryblock (length<>0)
						\Pause			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Pause"))			; pause/resume
						\Play				=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Play"))				; false = error
						\SetFreq			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_SetFreq"))			; set frequency (default 44100)
						\SetString		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_SetString"))		; set unicode or ascii if @filename
						\SetVolume		=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_SetVolume"))		; set volume 0 .. 100
						\Version			=	GetProcAddress_(\DLL, Uni2Asc(@"SCAL_Version"))			; dll version (100 = 1.00)

						\SetString(SizeOf(Character))	; set AscII[1] or Unicode[2]
						\CallBack(\Proc)

					EndIf

					ProcedureReturn	\DLL

				EndWith
		CompilerEndSelect
	EndProcedure
	Procedure	MusicFree()

		With	RS_ModMusic

			If	\ID	=	#Null	:	ProcedureReturn	:	EndIf
			
			CompilerSelect	#IsC2D_Music
				CompilerCase	#XMU_AHX
					ahx1play_Close()

				CompilerCase	#XMU_API
					PlaySound_(#Null, #Null, #Null)

				CompilerCase	#XMU_BAS
					BASSMOD_MusicStop()
					BASSMOD_MusicFree()
					BASSMOD_Free()

				CompilerCase	#XMU_BMF
					SynthEnter(\ID)
					SynthStop(\ID)
					SynthLeave(\ID)
					SynthDestroy(\ID)

				CompilerCase	#XMU_FC4
					fc14play_Close()
					
				CompilerCase	#XMU_FCP
					FCp_Close()
					
				CompilerCase	#XMU_FLA
					FreeSound(\ID)
					
				CompilerCase	#XMU_FT2
					ft2play_Close()
					
				CompilerCase	#XMU_MCI
					mciSendString_("CLOSE 0", 0, 0, 0)
					
				CompilerCase	#XMU_MED
					MEDP_Stop()
					MEDP_Unload()
					MEDP_Release()
					
				CompilerCase	#XMU_MOD
					FreeMusic(\ID)
					
				CompilerCase	#XMU_MOV
					FreeMovie(\ID)
					
				CompilerCase	#XMU_OGG
					FreeSound(\ID)
					
				CompilerCase	#XMU_PT2
					pt2play_Close()
					
				CompilerCase	#XMU_S68
					sc68replay_Stop()

				CompilerCase	#XMU_SCA
					If	RS_SCAL\DLL
						RS_SCAL\Free()
						FreeLibrary_(RS_SCAL\DLL)
					EndIf
					RS_SCAL\DLL	=	#Null
					
				CompilerCase	#XMU_SID
					SIDClose()
					
				CompilerCase	#XMU_STM
					st23play_Close()
					
				CompilerCase	#XMU_S3M
					st3play_Close()
					
				CompilerCase	#XMU_TFC
					fc14play_Close()
					
				CompilerCase	#XMU_THX
					ahx1play_Close()
					
				CompilerCase	#XMU_TPT
					pt2play_Close()
					
				CompilerCase	#XMU_TSR
					sid_sound_server_replay_stop()
					
				CompilerCase	#XMU_V1M
					ssStop()
					ssClose()
					
				CompilerCase	#XMU_V2M
					V2MStop()
					dsClose()
					
				CompilerCase	#XMU_WAV
					FreeSound(\ID)
					
				CompilerCase	#XMU_XM2
					uFMOD_PlaySong(#Null)
					
				CompilerCase	#XMU_YMP
					YM_Stop()
					YM_Close()
					
			CompilerEndSelect
			
			\ID	=	#False
			
		EndWith

	EndProcedure
	Procedure	MusicPlay(*Memory, Length=#Null, SubSong=#Null)

		; *Memory	=	Ptr to data or @Filename$
		; Length		=	Size(End) of data or #Null if *Memory = @Filename$
		; SubSong	=	Number of subsong to play (eg. SID, AHX)

		; Return: #False = Error - else music plays

		MusicFree()	; stop if playing

		With	RS_ModMusic

			; *** @File or *Memory?
			CompilerSelect	#IsC2D_Music
				CompilerCase	#XMU_API	; *Memory or @File (ascii & utf8)
				CompilerCase	#XMU_BAS	; *Memory or @File (ascii)
				CompilerCase	#XMU_FLA	; *Memory or @File (ascii & utf8)
				CompilerCase	#XMU_MCI	; *Memory must @File (ascii & utf8)
				CompilerCase	#XMU_MED	; *Memory must @File (ascii)
				CompilerCase	#XMU_MOD	; *Memory or @File (ascii & utf8)
				CompilerCase	#XMU_MOV	; *Memory must @File (ascii & utf8)
				CompilerCase	#XMU_OGG	; *Memory or @File (ascii & utf8)
				CompilerCase	#XMU_S68	; *Memory or @File (ascii)
				CompilerCase	#XMU_SCA	; *Memory or @File (ascii & utf8) - DLL
				CompilerCase	#XMU_WAV	; *Memory or @File (ascii & utf8)
				CompilerCase	#XMU_XM2	; *Memory or @File (ascii)
				CompilerCase	#XMU_YMP	; *Memory or @File (ascii)
				CompilerDefault
				CompilerIf	#IsC2D_File
					If	Length	<=	#Null
						*Memory	=	FileLoad(PeekS(*Memory))
						Length	=	MemorySize(*Memory)
					EndIf
				CompilerElse
					If	 Length	<=	#Null
						ProcedureReturn	#Null
					EndIf
				CompilerEndIf
			CompilerEndSelect

			\ID	=	#True	; ok by default

			If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

			; *** Play music
			CompilerSelect	#IsC2D_Music

				CompilerCase	#XMU_AHX
					; *** AHX (no HVL) (*Memory)
					ahx1play_SetStereoSep(100)
					ahx1play_PlaySong(*Memory, Length, SubSong, 44100)

				CompilerCase	#XMU_BAS
					; *** Modules (*.XM;*.IT;*.S3M;*.MOD;*.MTM;*.UMX) (@File / *Memory)
					BASSMOD_DllMain(GetModuleHandle_(#Null), #DLL_PROCESS_ATTACH, #Null)
					If	BASSMOD_Init()
						If	Length
							BASSMOD_MusicLoad(#True, *Memory, 0, Length)
						Else
							BASSMOD_MusicLoad(#False, Uni2Asc(*Memory))
						EndIf
						BASSMOD_MusicPlay()
					Else
						\ID	=	#False
					EndIf

				CompilerCase	#XMU_BMF
					; *** BeroTracker 404 (*.BMF) (*Memory)
					\ID	=	SynthCreate(SynthReadBMFSampleRate(*Memory, Length), 2048, 1, 1)
					If	\ID
						SynthReadBMF(\ID, *Memory, Length)
						SynthPlay(\ID)
						SynthSetLooping(\ID, 1)
					EndIf

				CompilerCase	#XMU_FC4
					; *** FutureComposer 1..4 (FC) (*Memory)
					fc14play_SetStereoSep(100)
					fc14play_PlaySong(*Memory, Length, 44100)

				CompilerCase	#XMU_FCP
					; *** FutureComposer 1.4 (*.FC;*.FC14;*.FC4) (*Memory)
					FCp_Open(GetForegroundWindow_())
					FCp_InitModule(*Memory)
					FCp_Start()

				CompilerCase	#XMU_FLA
					; *** Native FlacDecoder (*.FLAC) (@File / *Memory)
					If	Length
						\ID	=	CatchSound(#PB_Any, *Memory, Length)
					Else
						\ID	=	LoadSound(#PB_Any, PeekS(*Memory))
					EndIf
					If	\ID
						PlaySound(\ID, #PB_Sound_Loop)
					EndIf

				CompilerCase	#XMU_FT2
					; *** FastTracker I (FT) & Amiga Tracker (MOD) (*Memory)
					ft2play_PlaySong(*Memory, Length, 1, 1, 44100)

				CompilerCase	#XMU_MCI
					; *** Systemdriver (*.MP3;*.OGG;*.WAV;*.WMA...) (@File)
					If	mciSendString_("OPEN " + #DQUOTE$ + PeekS(*Memory) + #DQUOTE$ + " TYPE MPEGVIDEO ALIAS 0", 0, 0, 0)	=	#S_OK
						mciSendString_("PLAY 0 REPEAT", 0, 0, 0)
						;mciSendString_("SETAUDIO 0 VOLUME TO 255", 0, 0, 0)
					Else
						\ID	=	#False
					EndIf

				CompilerCase	#XMU_MED
					; *** OctaMED (*.MED;*.MMD0;*.MMD1;*.MMD2;*.MMD3;*.MOD + PP20) (@File)
					MEDPDLL_DllMain(GetModuleHandle_(#Null), #DLL_PROCESS_ATTACH, #Null)
					MEDP_Initialize(#Null, GetForegroundWindow_())
					If	MEDP_Load(Uni2Asc(*Memory))	; *Memory = always @Filename$
						If	MEDP_IsLoaded()
							MEDP_Play()
						EndIf
					EndIf

				CompilerCase	#XMU_MOD
					; *** Native Traker (*.XM;*.IT;*.S3M;*.MOD;*.MTM;*.UMX;*.OKT;*.MED;*.MMD0;*.MMD1;*.MMD2;*.MMD3 + PP20) (@File / *Memory)
					If	Length
						\ID	=	CatchMusic(#PB_Any, *Memory, Length)
					Else
						\ID	=	LoadMusic(#PB_Any, PeekS(*Memory))
					EndIf
					If	\ID
						PlayMusic(\ID)
					EndIf

				CompilerCase	#XMU_MOV
					; *** Native Movie / Audio (*.MP3;*.WAV...) (@File)
					\ID	=	LoadMovie(#PB_Any, PeekS(*Memory))
					If	\ID
						PlayMovie(\ID, GadgetID(C2D\Gadget))
					EndIf

				CompilerCase	#XMU_OGG
					; *** Native OggDecoder (*.OGG) (@File / *Memory)
					If	Length
						\ID	=	CatchSound(#PB_Any, *Memory, Length)
					Else
						\ID	=	LoadSound(#PB_Any, PeekS(*Memory))
					EndIf
					If	\ID
						PlaySound(\ID, #PB_Sound_Loop)
					EndIf

				CompilerCase	#XMU_PT2
					; *** ProTracker 2.3D (MOD) (*Memory)
					pt2play_SetStereoSep(100)
					pt2play_PlaySong(*Memory, Length, #CIA_TEMPO_MODE, 44100)

				CompilerCase	#XMU_S68
					; *** SC68 MC68000 Amiga/Atari (*.SC68;*.SNDH + GZIP) (@File / *Memory)
					If	Length
						\ID	=	sc68replay_Init(*Memory, Length, #SC68Replay_MEMORY)
					Else
						\ID	=	sc68replay_Init(Uni2Asc(*Memory), #Null, #SC68Replay_FILE)
					EndIf
					If	\ID
						sc68replay_Play()
					EndIf

				CompilerCase	#XMU_SCA
					; *** SCAL_x86-64.dll (@File / *Memory)
					If	MusicInit(#Null$, RS_SCAL\CallBack)
						\ID	=	RS_SCAL\Play(-1, *Memory, Length, SubSong)
					Else
						\ID	=	#False
					EndIf

				CompilerCase	#XMU_SID
					; *** C64 (*.SID) (*Memory) (need masm32.lib)
					If	SubSong
						\ID	=	SIDOpen(*Memory, Length, #SID_MEMORY, #SID_NON_DEFAULT, SubSong)
					Else
						\ID	=	SIDOpen(*Memory, Length, #SID_MEMORY, #SID_DEFAULT, #Null)
					EndIf

				CompilerCase	#XMU_STM
					; *** Scream Tracker 2.3 (STM) (*Memory)
					st23play_PlaySong(*Memory, Length, 0, 44100)

				CompilerCase	#XMU_S3M
					; *** ScreamTracker III (S3M) (*Memory)
					st3play_PlaySong(*Memory, Length, 0, #SOUNDCARD_GUS, 44100)
					
				CompilerCase	#XMU_TFC
					; *** Tiny FutureComposer 1..4 (FC) (*Memory)
					fc14play_PlaySong(*Memory, Length)
					
				CompilerCase	#XMU_THX
					; *** Tiny AHX (AHX,THX) (*Memory)
					ahx1play_PlaySong(*Memory, Length, SubSong)
				
				CompilerCase	#XMU_TPT
					; *** Tiny ProTracker 2.3D (MOD) (*Memory)
					pt2play_PlaySong(*Memory, Length)

				CompilerCase	#XMU_TSR
					; *** C64 (*.SID) (*Memory) (no masm32.lib)
					sid_sound_server_replay_init(*Memory, Length, SubSong)
					sid_sound_server_replay_play()

				CompilerCase	#XMU_V1M
					; *** LibV2 1.0 (*.V2M) (*Memory)
					If	ssInit(*Memory, GetForegroundWindow_())
						ssPlay()
						ssDoTick()
					Else
						\ID	=	#False
					EndIf

				CompilerCase	#XMU_V2M
					; *** LibV2 1.5 (*.V2M) (*Memory)
					If	V2MInit(*Memory, 44100, GetForegroundWindow_())
						V2MSetRepeat(1)
						V2MPlay()
					Else
						\ID	=	#False
					EndIf

				CompilerCase	#XMU_API
					; *** Wave (*.WAV) (@File / *Memory)
					If	Length
						\ID	=	PlaySound_(*Memory, #Null, #SND_MEMORY|#SND_ASYNC|#SND_LOOP|#SND_NODEFAULT)	; play from *Memory
					Else
						\ID	=	PlaySound_(*Memory, #Null, #SND_FILENAME|#SND_ASYNC|#SND_LOOP|#SND_NODEFAULT)	; play from file -> *Memory = @Filename$
					EndIf
					
				CompilerCase	#XMU_WAV
					; *** Native WavDecoder (*.WAV) (@File / *Memory)
					If	Length
						\ID	=	CatchSound(#PB_Any, *Memory, Length)
					Else
						\ID	=	LoadSound(#PB_Any, PeekS(*Memory))
					EndIf
					If	\ID
						PlaySound(\ID, #PB_Sound_Loop)
					EndIf

				CompilerCase	#XMU_XM2
					; *** FastTracker II (*.XM) (@File / *Memory)
					If	Length
						uFMOD_PlaySong(*Memory, Length, #XM_MEMORY)			; *memory
					Else
						uFMOD_PlaySong(Uni2Asc(*Memory), #Null, #XM_FILE)	; @file
					EndIf

				CompilerCase	#XMU_YMP
					; *** Atari (*.YMP) (@File / *Memory)
					YMPLUGIN_DllMain(GetModuleHandle_(#Null), #DLL_PROCESS_ATTACH, #Null)
					YM_Init()
					If	Length
						YM_Open(#Null, *Memory, Length)
					Else
						YM_Open(Uni2Asc(*Memory), #Null, #Null)
					EndIf
					YM_Play()

			CompilerEndSelect

			ProcedureReturn	\ID

		EndWith

	EndProcedure

CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x86)
; Folding = AAAAAAAAAA-
; CompileSourceDirectory