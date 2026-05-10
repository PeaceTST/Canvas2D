;*********************************************
;- *** C2D GDIP (Gdiplus API) / 10.05.2026 ***

EnableExplicit

CompilerIf	#IsC2D_GdiPlus	=	1

	; Supports: BMP,GIF,JPG,EXIF,PNG,TIFF,ICO,WMF,EMF

	Structure	StreamObject
		*block
		*bits
		stream.ISTREAM
	EndStructure

	CompilerIf Defined(GdiplusStartupInput, #PB_Structure) = #Null
		Structure	GdiplusStartupInput
			GdiPlusVersion.l
			*DebugEventCallback.DebugEventProc
			SuppressBackgroundThread.i
			SuppressExternalCodecs.i
		EndStructure
	CompilerEndIf

	Import	"gdiplus.lib"
		CompilerIf	#PB_Compiler_Processor	=	#PB_Processor_x64
			GdipCreateBitmapFromStream(stream , *bitmap)	As	"GdipCreateBitmapFromStream"
			GdipCreateFromHDC(*hdc, *graphics)				As	"GdipCreateFromHDC"
			GdipDeleteGraphics(*graphics)						As	"GdipDeleteGraphics"
			GdipDisposeImage(*bitmap)							As	"GdipDisposeImage"
			GdipDrawImageRectI(*graphics, *bitmap, x, y, Width, Height)	As	"GdipDrawImageRectI"
			GdipGetImageHeight(*bitmap, *Height)			As	"GdipGetImageHeight"
			GdipGetImageWidth(*bitmap, *Width)				As	"GdipGetImageWidth"
			GdiplusShutdown(*token)								As	"GdiplusShutdown"
			GdiplusStartup(*token, *input, Mode)			As	"GdiplusStartup"
		CompilerElse
			GdipCreateBitmapFromStream(stream , *bitmap)	As	"_GdipCreateBitmapFromStream@8"
			GdipCreateFromHDC(*hdc, *graphics)				As	"_GdipCreateFromHDC@8"
			GdipDeleteGraphics(*graphics)						As	"_GdipDeleteGraphics@4"
			GdipDisposeImage(*bitmap)							As	"_GdipDisposeImage@4"
			GdipDrawImageRectI(*graphics, *bitmap, x, y, Width, Height)	As	"_GdipDrawImageRectI@24"
			GdipGetImageHeight(*bitmap, *Height)			As	"_GdipGetImageHeight@8"
			GdipGetImageWidth(*bitmap, *Width)				As	"_GdipGetImageWidth@8"
			GdiplusShutdown(*token)								As	"_GdiplusShutdown@4"
			GdiplusStartup(*token, *input, Mode)			As	"_GdiplusStartup@12"
		CompilerEndIf
	EndImport

	Procedure	GdipCatch(Image, *Memory.Union, Length.q)

		Protected	*token, *bitmap, *graphics, *hDC, ID, w, h
		Protected	input.GdiplusStartupInput, Stream.StreamObject

		If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

		input\GdiPlusVersion	=	1

		GdiplusStartup(@*token, @input, #Null)
		If *token	=	0	:	ProcedureReturn	#Null	:	EndIf	; Error?

		Stream\block	=	GlobalAlloc_(#GHND, Length)
		If	Stream\block	=	0	; Error?
			GdiplusShutdown(*token)
			ProcedureReturn	#Null
		EndIf

		Stream\bits	=	GlobalLock_(Stream\block)
		MoveMemory(*Memory, Stream\bits, Length)

		If CreateStreamOnHGlobal_(Stream\bits, 0, @Stream\stream)	=	#S_OK
			If GdipCreateBitmapFromStream(Stream\stream , @*bitmap)	=	#Null
				
				GdipGetImageWidth(*bitmap,  @w)	; ImageWidth
				GdipGetImageHeight(*bitmap, @h)	; ImageHeight
				
				CompilerIf	#PB_Compiler_Version	>=	630
					ID	=	CreateImage(Image, w, h, 32, #PB_Image_TransparentBlack)
				CompilerElse
					ID	=	CreateImage(Image, w, h, 32, #PB_Image_Transparent)
				CompilerEndIf
				
				If	ID
					
					If	Image	<>	#PB_Any	:	ID	=	Image	:	EndIf	; ID = hImage
					
					*hDC	=	StartDrawing(ImageOutput(ID))
					If	GdipCreateFromHDC(*hDC, @*graphics)	=	#Null
						GdipDrawImageRectI(*graphics, *bitmap, 0, 0, OutputWidth(), OutputHeight())
						GdipDeleteGraphics(*graphics)
					EndIf
					StopDrawing()
					
				EndIf
				
				GdipDisposeImage(*bitmap)
				
			EndIf
			
			Stream\stream\Release()
			
		Else
			
			ID	=	#Null	; Error
			
		EndIf

		GlobalUnlock_(Stream\bits)
		GlobalFree_(Stream\block)

		GdiplusShutdown(*token)

		ProcedureReturn	ID

	EndProcedure

CompilerElse	; #IsC2D_GdiPlus = 2 -> API-Decoder PNG only ~1KB smaller *.exe

	Procedure	GdipCatch(Image, *Memory.Union, Length.q)

		Protected	ID, w, h, *hPNG

		If	Length	>	*Memory	:	Length	-	*Memory	:	EndIf

		*hPNG	=	CreateIconFromResourceEx_(*Memory, Length, #True, $30000, 0, 0, 0)

		If	*hPNG	<=	#Null	:	ProcedureReturn	#Null	:	EndIf

		*Memory	+	$12	:	w	=	UINT16(*Memory\w)
		*Memory	+	$04	:	h	=	UINT16(*Memory\w)

		CompilerIf	#PB_Compiler_Version	>=	630
			ID	=	CreateImage(Image, w, h, 32, #PB_Image_TransparentBlack)
		CompilerElse
			ID	=	CreateImage(Image, w, h, 32, #PB_Image_Transparent)
		CompilerEndIf

		If	ID

			If	Image	<>	#PB_Any	:	ID	=	Image	:	EndIf	; hImage -> #Image

			StartDrawing(ImageOutput(ID))
			DrawImage(*hPNG, 0, 0)
			StopDrawing()

		EndIf

		DestroyIcon_(*hPNG)

		ProcedureReturn	ID

	EndProcedure

CompilerEndIf
; IDE Options = PureBasic 6.30 (Windows - x86)
; Folding = B5
; DisableDebugger
; CompileSourceDirectory