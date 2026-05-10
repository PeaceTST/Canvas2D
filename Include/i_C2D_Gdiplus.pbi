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
			GdipCreateBitmapFromStream(stream , *img)					As	"GdipCreateBitmapFromStream"
			GdipCreateFromHDC(*hdc, *gfx)									As	"GdipCreateFromHDC"
			GdipDeleteGraphics(*gfx)										As	"GdipDeleteGraphics"
			GdipDisposeImage(*img)											As	"GdipDisposeImage"
			GdipDrawImageRectI(*gfx, *img, x, y, Width, Height)	As	"GdipDrawImageRectI"
			GdipGetImageHeight(*img, *Height)							As	"GdipGetImageHeight"
			GdipGetImageWidth(*img, *Width)								As	"GdipGetImageWidth"
			GdiplusShutdown(*token)											As	"GdiplusShutdown"
			GdiplusStartup(*token, *input, Mode)						As	"GdiplusStartup"
		CompilerElse
			GdipCreateBitmapFromStream(stream , *img)					As	"_GdipCreateBitmapFromStream@8"
			GdipCreateFromHDC(*hdc, *gfx)									As	"_GdipCreateFromHDC@8"
			GdipDeleteGraphics(*gfx)										As	"_GdipDeleteGraphics@4"
			GdipDisposeImage(*img)											As	"_GdipDisposeImage@4"
			GdipDrawImageRectI(*gfx, *img, x, y, Width, Height)	As	"_GdipDrawImageRectI@24"
			GdipGetImageHeight(*img, *Height)							As	"_GdipGetImageHeight@8"
			GdipGetImageWidth(*img, *Width)								As	"_GdipGetImageWidth@8"
			GdiplusShutdown(*token)											As	"_GdiplusShutdown@4"
			GdiplusStartup(*token, *input, Mode)						As	"_GdiplusStartup@12"
		CompilerEndIf
	EndImport

	Procedure	GdipCatch(Image, *Memory.Union, Length.q)

		Protected	*token, *img, *gfx, *hDC, ID, w, h
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

			GdipCreateBitmapFromStream(Stream\stream , @*img)

			If *img

				GdipGetImageWidth(*img,  @w)	; ImageWidth
				GdipGetImageHeight(*img, @h)	; ImageHeight

				CompilerIf	#PB_Compiler_Version	>=	630
					ID	=	CreateImage(Image, w, h, 32, #PB_Image_TransparentBlack)
				CompilerElse
					ID	=	CreateImage(Image, w, h, 32, #PB_Image_Transparent)
				CompilerEndIf

				If	ID

					If	Image	<>	#PB_Any	:	ID	=	Image	:	EndIf

					*hDC	=	StartDrawing(ImageOutput(ID))
					GdipCreateFromHDC(*hDC, @*gfx)
					GdipDrawImageRectI(*gfx, *img, 0, 0, OutputWidth(), OutputHeight())
					StopDrawing()

					GdipDeleteGraphics(*gfx)

				EndIf

				GdipDisposeImage(*img)

			EndIf

		Else

			ID	=	#Null	; Error

		EndIf

		Stream\stream\Release()
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