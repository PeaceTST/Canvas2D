;**********************************************
;- *** C2D NetWork / 26.08.2020 ***************

EnableExplicit

CompilerIf	#PB_Compiler_IsIncludeFile	=	#Null

	;#IsC2D_NetWork	=	1,2

	XIncludeFile	"C2D_Macros.pbi"
	XIncludeFile	"C2D_Enums.pbi"

	Structure	RS_NetWork
		*CallBack	; @Procedure(Param)
		*hInternet	; iNetConnection
		*hURL			; iNetURL
		BytesRead.i	; Buffered bytes
		BytesSkip.i	; Skip bytes of "header"!
		Length.i		; Bytesize of url
	EndStructure

	Global	RS_NetWork.RS_NetWork

	Declare		NetWorkFree()
	;Declare$	NetWorkUrl(Url$)
	;Declare		NetWorkInit(Url$)

	Declare	NetWorkBytes(Length=4096)
	Declare	NetWorkLoad(Url$)
	Declare	NetWorkSize(Url$)
	Declare	NetWorkSkip(Length=0)

	CompilerIf	#IsC2D_NetWork	=	2
		Declare	NetWorkDownload(Url$, File$)
	CompilerEndIf

CompilerEndIf

CompilerIf	Defined(HTTP_QUERY_CONTENT_LENGTH, 		#PB_Constant)	=	0
	#HTTP_QUERY_CONTENT_LENGTH		=	$5
CompilerEndIf
CompilerIf	Defined(INTERNET_FLAG_RELOAD, 			#PB_Constant)	=	0
	#INTERNET_FLAG_RELOAD			=	$80000000
CompilerEndIf
CompilerIf	Defined(INTERNET_FLAG_NO_CACHE_WRITE,	#PB_Constant)	=	0
	#INTERNET_FLAG_NO_CACHE_WRITE	=	$4000000
CompilerEndIf

Procedure	NetWorkFree()		; private

	With	RS_NetWork

		If	\hInternet
			InternetCloseHandle_(\hInternet)
		EndIf

		ClearStructure(@RS_NetWork, RS_NetWork)

	EndWith

EndProcedure
Procedure$	NetWorkUrl(Url$)	; private

	; Encode unsave characters (canonicalize)
	; https://www.ietf.org/rfc/rfc1738.txt

	Protected	t$, *Memory.Character=@Url$

	While	*Memory\c
		Select	*Memory\c
			Case	',',' ','!','"','#','$','&','+',';','<','=','>','@','[','\',']','^','_','`','{','|','}','~',$27	; not '-','%'
				t$	+	"%"	+	Hex(*Memory\c)
			Default
				If	*Memory\c	<>	'\'	; no "\/"
					t$	+	Chr(*Memory\c)
				EndIf
		EndSelect
		*Memory	+	SizeOf(Character)
	Wend

	ProcedureReturn	t$

EndProcedure
Procedure	NetWorkInit(Url$)	; private

	; = Filesize(Url$) or #NULL -> Error

	Protected	*Memory, Length

	With	RS_NetWork
		If	StrStrI_(Url$, "://")

			If	\hInternet	<=	#Null
				\hInternet	=	InternetOpen_("C2D/0.3", #INTERNET_OPEN_TYPE_PRECONFIG, 0, 0, 0)
			EndIf

			\Length	=	#Null

			If	\hInternet

				If	\BytesRead	<=	#Null
					NetWorkBytes()
				EndIf
				
				; Encode unsave URL-Characters (canonicalize)
				Url$		=	NetWorkUrl(Url$)
				Length	=	1024	+	Len(Url$)	+	\BytesSkip	; + space for query content
				*Memory	=	AllocateMemory(Length)
				PokeS(*Memory, Url$)

				\hURL	=	InternetOpenUrl_(\hInternet, *Memory, 0, 0, #INTERNET_FLAG_RELOAD|#INTERNET_FLAG_NO_CACHE_WRITE|#INTERNET_FLAG_NO_COOKIES, 0)
				
				If	\hURL
					If	HttpQueryInfo_(\hURL, #HTTP_QUERY_CONTENT_LENGTH, *Memory, @Length, 0)
						\Length	=	StrToInt_(*Memory)
						If	GetLastError_()	Or	\Length	<=	0	; Error?
							\Length	=	#Null
						ElseIf	\BytesSkip	; <- skip pseudoheader for deceive hoster?
							InternetReadFile_(\hURL, *Memory, \BytesSkip, @Length)
							\Length	-	Length
						EndIf
					EndIf
				EndIf

				FreeMemory(*Memory)

			EndIf

			ProcedureReturn	\Length

		EndIf
	EndWith

EndProcedure

Procedure	NetWorkBytes(Length=4096)
	; Length (BytesToRead) = Number of bytes preloaded from Url$
	If	Length	>	#Null
		RS_NetWork\BytesRead	=	Length
	EndIf
EndProcedure
Procedure	NetWorkCallBack(*CallBack=0)
	; *CallBack = @Procedure(Param)
	RS_NetWork\CallBack	=	*CallBack
EndProcedure
Procedure	NetWorkLoad(Url$)

	; = *memory

	Protected	*Memory, *Buffer, Length, hF

	If	NetWorkInit(Url$)

		With	RS_NetWork

			If	\Length	>	#Null

				*Memory	=	AllocateMemory(\Length)
				*Buffer	=	*Memory

				While	InternetReadFile_(\hURL, *Buffer, \BytesRead, @Length)

					*Buffer	+	Length

					;// If	*CallBack	And	CallFunctionFast(*CallBack, Percent)	:	Break	:	EndIf
					If	\CallBack	And	Start()
						If	CallFunctionFast(\CallBack, (100.0 / \Length) * (*Buffer - *Memory))
							Stop()
							Break
						EndIf
						Stop()
					EndIf

					If	(Length	<=	#Null)	Or	(*Buffer	>=	*Memory	+	\Length)
						Break
					EndIf

				Wend

			EndIf

			InternetCloseHandle_(\hURL)
			
			If	\CallBack	And	Start()
				CallFunctionFast(\CallBack, 100)
				Stop()
			EndIf
			
		EndWith

	EndIf

	ProcedureReturn	*Memory

EndProcedure
Procedure	NetWorkSize(Url$)

	; = size of url$

	If	NetWorkInit(Url$)
		InternetCloseHandle_(RS_NetWork\hURL)
		ProcedureReturn	RS_NetWork\Length
	EndIf

EndProcedure
Procedure	NetWorkSkip(Length=0)
	; Length (skip bytes) of decive header chars
	If	Length	>=	#Null
		RS_NetWork\BytesSkip	=	Length
	EndIf
EndProcedure

CompilerIf	#IsC2D_NetWork	=	2
	Procedure	NetWorkDownload(Url$, File$)

		; = size of saved file

		Protected	*Memory, Length, hF
		Protected	nSizeLoad, nSizeSave

		If	NetWorkInit(Url$)

			With	RS_NetWork

				If	\Length	>	#Null

					*Memory	=	AllocateMemory(\BytesRead)

					hF	=	CreateFile(#PB_Any, File$)

					If	hF

						While	InternetReadFile_(\hURL, *Memory, \BytesRead, @nSizeLoad)

							Length		=	WriteData(hF, *Memory, nSizeLoad)
							nSizeSave	+	Length

							;// If	*CallBack	And	CallFunctionFast(*CallBack, Percent)	:	Break	:	EndIf
							If	\CallBack	And	Start()
								If	CallFunctionFast(\CallBack, (100.0 / \Length) * nSizeSave)	; %Percent
									Stop()
									Break
								EndIf
								Stop()
							EndIf

							If	nSizeSave	>=	\Length	Or	Length	<	nSizeLoad	; Length -> WriteError?
								Break
							EndIf

						Wend

						FlushFileBuffers(hF)
						CloseFile(hF)

					EndIf

					FreeMemory(*Memory)

				EndIf

				InternetCloseHandle_(\hURL)
				
				If	\CallBack	And	Start()
					CallFunctionFast(\CallBack, 100)
					Stop()
				EndIf

			EndWith

		EndIf

		ProcedureReturn	nSizeSave

	EndProcedure
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = AAw
; CompileSourceDirectory