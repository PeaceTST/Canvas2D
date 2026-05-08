; C2D::AmpMaster / MusicBox v1.18.5.7 (x86)
; Peace^Testaware - 08.05.18 19:29
; Purebasic v5.62 (x86)

; Important:
; - AmpMaster must be installed (s. Tools\AmpInstaller\)
; - AmpMaster accept only AscII-Stringformat

EnableExplicit

PrototypeC	pAmp_MusicBox(*File.p-Ascii, Mode.l=1)

Define	Amp_MusicBox.pAmp_MusicBox
Define	amp_DLL, amp_File$, amp_Name$

amp_File$	=	ProgramParameter(0)
amp_Name$	=	GetUserDirectory(#PB_Directory_Public)	+	"AmpMaster\AmpMaster_x86.dll"

amp_DLL	=	LoadLibrary_(amp_Name$)

If	amp_DLL

	Amp_MusicBox	=	GetProcAddress_(amp_DLL, Ascii("Amp_MusicBox"))
	Amp_MusicBox(Ascii(amp_File$))
	
	FreeLibrary_(amp_DLL)
	
EndIf
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 23
; EnableXP
; UseIcon = ..\..\Data\Icon\amp.ico
; Executable = AmpPlayer_x86.exe
; DisableDebugger