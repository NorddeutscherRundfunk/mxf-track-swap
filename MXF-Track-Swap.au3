#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon\swap.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Swaps audio tracks in mxf files.
#AutoIt3Wrapper_Res_Description=Swaps audio tracks in mxf files.
#AutoIt3Wrapper_Res_Fileversion=1.0.0.11
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Conrad Zelck
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Copyright|Conrad Zelck
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <ColorConstants.au3>
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <Date.au3>
#include <File.au3>
#include <TrayCox.au3>

; Known issues:
; - if the external stereo wav file is routed to only one channel (e.g. "[R]") it breaks: "Filter channelsplit:FL has an unconnected outut"

AutoItSetOption("GUICoordMode", 1)

Global $g_bMxfAvailable = False
Global $g_bWavAvailable = False
Global $g_hGUI
Global $g_sMXFFile, $g_sWAVFile
Global $g_aDropFiles[0]

; if parameter given via sendto or drag&drop onto AppIcon
ConsoleWrite("$CmdLineRaw: " & $CmdLineRaw & @CRLF)
If $CmdLine[0] > 0 Then
	_CheckForInputFiles($CmdLine)
EndIf

; if no parameters are given open a drag and drop gui
$g_hGUI = GUICreate("MXF-Track-Swap", 400, 340, -1, -1, -1, $WS_EX_ACCEPTFILES)
GUICtrlCreateLabel(@CRLF & "Drag&&drop your files here." & @CRLF & @CRLF & "You must provide an MXF file." & @CRLF & "Additionally you can provide a stereo WAV file too." , 20, 20, 360, 100, BitOR($SS_CENTER, $SS_SUNKEN))
GUICtrlSetFont(-1, 10)
GUICtrlCreateLabel("MXF file:" , 20, 140, 360, 20)
GUICtrlSetFont(-1, 10)
Local $hLMXF = GUICtrlCreateLabel(_FileName($g_sMXFFile) , 20, 170, 360, 20)
GUICtrlSetFont(-1, 10)
GUICtrlCreateLabel("WAV file:" , 20, 210, 360, 20)
GUICtrlSetFont(-1, 10)
Local $hLWAV = GUICtrlCreateLabel(_FileName($g_sWAVFile) , 20, 240, 360, 20)
GUICtrlSetFont(-1, 10)
Local $hBNext = GUICtrlCreateButton("Next", 100, 290, 200, 30, $BS_DEFPUSHBUTTON)
GUICtrlSetFont(-1, 10)
If Not $g_bMxfAvailable Then GUICtrlSetState(-1, $GUI_DISABLE)
Local $FILES_DROPPED = GUICtrlCreateDummy()
GUIRegisterMsg($WM_DROPFILES, 'WM_DROPFILES_FUNC')
GUISetState()

Local $sFile
While True
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $FILES_DROPPED
			_CheckForInputFiles($g_aDropFiles)
			If $g_bMxfAvailable Then
				GUICtrlSetState($hBNext, $GUI_ENABLE)
				GUICtrlSetData($hLMXF, _FileName($g_sMXFFile))
			EndIf
			If $g_bWavAvailable Then GUICtrlSetData($hLWAV, _FileName($g_sWAVFile))
		Case $hBNext
			ExitLoop
    EndSwitch
WEnd
GUIDelete($g_hGUI)

#Region - GUI Routing
AutoItSetOption("GUICoordMode", 0)
$g_hGUI = GUICreate("MXF-Track-Swap Routing", 320, 450)
GUICtrlCreateLabel("Source", 20, 20, 200, 20)
GUICtrlCreateLabel("Mute", 10, 20, 30, 20)
GUICtrlCreateLabel("A1", 10, 30, 20, 20)
GUICtrlCreateLabel("A2", -1, 20, 20, 20)
GUICtrlCreateLabel("A3", -1, 30, 20, 20)
GUICtrlCreateLabel("A4", -1, 20, 20, 20)
GUICtrlCreateLabel("A5", -1, 30, 20, 20)
GUICtrlCreateLabel("A6", -1, 20, 20, 20)
GUICtrlCreateLabel("A7", -1, 30, 20, 20)
GUICtrlCreateLabel("A8", -1, 20, 20, 20)
Local $hLL = GUICtrlCreateLabel("wav L", -18, 30, 32, 20)
Local $hLR = GUICtrlCreateLabel("wav R", -1, 20, 32, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetColor($hLL, $COLOR_SILVER)
	GUICtrlSetColor($hLR, $COLOR_SILVER)
EndIf

GUIStartGroup()
Global $g_hRm1 = GUICtrlCreateRadio("", 50, -253, 20, 20)
Global $g_hR11 = GUICtrlCreateRadio("", -1, 30, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR21 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR31 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR41 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR51 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR61 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR71 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR81 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL1 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR1 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL1, $GUI_DISABLE)
	GUICtrlSetState($g_hRR1, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A1", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm2 = GUICtrlCreateRadio("", 20, -280, 20, 20)
Global $g_hR12 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR22 = GUICtrlCreateRadio("", -1, 20, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR32 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR42 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR52 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR62 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR72 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR82 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL2 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR2 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL2, $GUI_DISABLE)
	GUICtrlSetState($g_hRR2, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A2", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm3 = GUICtrlCreateRadio("", 30, -280, 20, 20)
Global $g_hR13 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR23 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR33 = GUICtrlCreateRadio("", -1, 30, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR43 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR53 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR63 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR73 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR83 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL3 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR3 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL3, $GUI_DISABLE)
	GUICtrlSetState($g_hRR3, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A3", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm4 = GUICtrlCreateRadio("", 20, -280, 20, 20)
Global $g_hR14 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR24 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR34 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR44 = GUICtrlCreateRadio("", -1, 20, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR54 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR64 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR74 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR84 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL4 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR4 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL4, $GUI_DISABLE)
	GUICtrlSetState($g_hRR4, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A4", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm5 = GUICtrlCreateRadio("", 30, -280, 20, 20)
Global $g_hR15 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR25 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR35 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR45 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR55 = GUICtrlCreateRadio("", -1, 30, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR65 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR75 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR85 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL5 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR5 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL5, $GUI_DISABLE)
	GUICtrlSetState($g_hRR5, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A5", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm6 = GUICtrlCreateRadio("", 20, -280, 20, 20)
Global $g_hR16 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR26 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR36 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR46 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR56 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR66 = GUICtrlCreateRadio("", -1, 20, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR76 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR86 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL6 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR6 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL6, $GUI_DISABLE)
	GUICtrlSetState($g_hRR6, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A6", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm7 = GUICtrlCreateRadio("", 30, -280, 20, 20)
Global $g_hR17 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR27 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR37 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR47 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR57 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR67 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR77 = GUICtrlCreateRadio("", -1, 30, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hR87 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hRL7 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR7 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL7, $GUI_DISABLE)
	GUICtrlSetState($g_hRR7, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A7", 1, 30, -1, -1)

GUIStartGroup()
Global $g_hRm8 = GUICtrlCreateRadio("", 20, -280, 20, 20)
Global $g_hR18 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR28 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR38 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR48 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR58 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR68 = GUICtrlCreateRadio("", -1, 20, 20, 20)
Global $g_hR78 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hR88 = GUICtrlCreateRadio("", -1, 20, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $g_hRL8 = GUICtrlCreateRadio("", -1, 30, 20, 20)
Global $g_hRR8 = GUICtrlCreateRadio("", -1, 20, 20, 20)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hRL8, $GUI_DISABLE)
	GUICtrlSetState($g_hRR8, $GUI_DISABLE)
EndIf
GUICtrlCreateLabel("A8", 1, 30, -1, -1)
GUICtrlCreateLabel("Target", 20, -1, 200, 20)

Global $g_hButtonChangeAD  = GUICtrlCreateButton("1+2 <--> 5+6", -250, 30, 80, 30)
Global $g_hButtonExtAD56  = GUICtrlCreateButton("ext. AD > 5+6", 100, -1, 80, 30)
Global $g_hButtonExtAD12  = GUICtrlCreateButton("ext. AD > 1+2", 100, -1, 80, 30)
If Not $g_bWavAvailable Then
	GUICtrlSetState($g_hButtonExtAD56, $GUI_DISABLE)
	GUICtrlSetState($g_hButtonExtAD12, $GUI_DISABLE)
EndIf

Global $g_hButtonOK  = GUICtrlCreateButton("Swap", -200, 50, 280, 30)

GUISetState(@SW_SHOW)
AutoItSetOption("GUICoordMode", 1)
#EndRegion GUI Routing

While True
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
		Case $g_hButtonChangeAD
			GUICtrlSetState($g_hR15, $GUI_CHECKED)
			GUICtrlSetState($g_hR26, $GUI_CHECKED)
			GUICtrlSetState($g_hR33, $GUI_CHECKED)
			GUICtrlSetState($g_hR44, $GUI_CHECKED)
			GUICtrlSetState($g_hR51, $GUI_CHECKED)
			GUICtrlSetState($g_hR62, $GUI_CHECKED)
			GUICtrlSetState($g_hR77, $GUI_CHECKED)
			GUICtrlSetState($g_hR88, $GUI_CHECKED)
		Case $g_hButtonExtAD56
			GUICtrlSetState($g_hR11, $GUI_CHECKED)
			GUICtrlSetState($g_hR22, $GUI_CHECKED)
			GUICtrlSetState($g_hR33, $GUI_CHECKED)
			GUICtrlSetState($g_hR44, $GUI_CHECKED)
			GUICtrlSetState($g_hRL5, $GUI_CHECKED)
			GUICtrlSetState($g_hRR6, $GUI_CHECKED)
			GUICtrlSetState($g_hR77, $GUI_CHECKED)
			GUICtrlSetState($g_hR88, $GUI_CHECKED)
		Case $g_hButtonExtAD12
			GUICtrlSetState($g_hRL1, $GUI_CHECKED)
			GUICtrlSetState($g_hRR2, $GUI_CHECKED)
			GUICtrlSetState($g_hR33, $GUI_CHECKED)
			GUICtrlSetState($g_hR44, $GUI_CHECKED)
			GUICtrlSetState($g_hR15, $GUI_CHECKED)
			GUICtrlSetState($g_hR26, $GUI_CHECKED)
			GUICtrlSetState($g_hR77, $GUI_CHECKED)
			GUICtrlSetState($g_hR88, $GUI_CHECKED)
		Case $g_hButtonOK
			If GUICtrlRead($g_hR11) = $GUI_CHECKED And GUICtrlRead($g_hR22) = $GUI_CHECKED And GUICtrlRead($g_hR33) = $GUI_CHECKED And GUICtrlRead($g_hR44) = $GUI_CHECKED And GUICtrlRead($g_hR55) = $GUI_CHECKED And GUICtrlRead($g_hR66) = $GUI_CHECKED And GUICtrlRead($g_hR77) = $GUI_CHECKED And GUICtrlRead($g_hR88) = $GUI_CHECKED Then
				MsgBox($MB_TOPMOST, "Warning", "Track routing is unchanged - no swapping necessary.")
			Else
				ExitLoop
			EndIf
    EndSwitch
WEnd

#Region - track setting
; set audio tracks
Global $g_aRoutingFFmpeg[9]
Global $g_aRoutingBMX[9]
Global $g_bMuteRouted = False
Global $g_bExternalWavRouted = False
; track 1
Select
	Case GUICtrlRead($g_hRm1) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "1:0"
		$g_aRoutingBMX[1] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR11) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:1"
		$g_aRoutingBMX[1] = "0"
	Case GUICtrlRead($g_hR21) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:2"
		$g_aRoutingBMX[1] = "1"
	Case GUICtrlRead($g_hR31) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:3"
		$g_aRoutingBMX[1] = "2"
	Case GUICtrlRead($g_hR41) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:4"
		$g_aRoutingBMX[1] = "3"
	Case GUICtrlRead($g_hR51) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:5"
		$g_aRoutingBMX[1] = "4"
	Case GUICtrlRead($g_hR61) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:6"
		$g_aRoutingBMX[1] = "5"
	Case GUICtrlRead($g_hR71) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:7"
		$g_aRoutingBMX[1] = "6"
	Case GUICtrlRead($g_hR81) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = "0:8"
		$g_aRoutingBMX[1] = "7"
	Case GUICtrlRead($g_hRL1) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR1) = $GUI_CHECKED
		$g_aRoutingFFmpeg[1] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 2
Select
	Case GUICtrlRead($g_hRm2) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "1:0"
		$g_aRoutingBMX[2] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR12) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:1"
		$g_aRoutingBMX[2] = "0"
	Case GUICtrlRead($g_hR22) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:2"
		$g_aRoutingBMX[2] = "1"
	Case GUICtrlRead($g_hR32) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:3"
		$g_aRoutingBMX[2] = "2"
	Case GUICtrlRead($g_hR42) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:4"
		$g_aRoutingBMX[2] = "3"
	Case GUICtrlRead($g_hR52) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:5"
		$g_aRoutingBMX[2] = "4"
	Case GUICtrlRead($g_hR62) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:6"
		$g_aRoutingBMX[2] = "5"
	Case GUICtrlRead($g_hR72) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:7"
		$g_aRoutingBMX[2] = "6"
	Case GUICtrlRead($g_hR82) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = "0:8"
		$g_aRoutingBMX[2] = "7"
	Case GUICtrlRead($g_hRL2) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR2) = $GUI_CHECKED
		$g_aRoutingFFmpeg[2] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 3
Select
	Case GUICtrlRead($g_hRm3) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "1:0"
		$g_aRoutingBMX[3] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR13) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:1"
		$g_aRoutingBMX[3] = "0"
	Case GUICtrlRead($g_hR23) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:2"
		$g_aRoutingBMX[3] = "1"
	Case GUICtrlRead($g_hR33) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:3"
		$g_aRoutingBMX[3] = "2"
	Case GUICtrlRead($g_hR43) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:4"
		$g_aRoutingBMX[3] = "3"
	Case GUICtrlRead($g_hR53) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:5"
		$g_aRoutingBMX[3] = "4"
	Case GUICtrlRead($g_hR63) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:6"
		$g_aRoutingBMX[3] = "5"
	Case GUICtrlRead($g_hR73) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:7"
		$g_aRoutingBMX[3] = "6"
	Case GUICtrlRead($g_hR83) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = "0:8"
		$g_aRoutingBMX[3] = "7"
	Case GUICtrlRead($g_hRL3) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR3) = $GUI_CHECKED
		$g_aRoutingFFmpeg[3] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 4
Select
	Case GUICtrlRead($g_hRm4) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "1:0"
		$g_aRoutingBMX[4] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR14) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:1"
		$g_aRoutingBMX[4] = "0"
	Case GUICtrlRead($g_hR24) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:2"
		$g_aRoutingBMX[4] = "1"
	Case GUICtrlRead($g_hR34) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:3"
		$g_aRoutingBMX[4] = "2"
	Case GUICtrlRead($g_hR44) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:4"
		$g_aRoutingBMX[4] = "3"
	Case GUICtrlRead($g_hR54) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:5"
		$g_aRoutingBMX[4] = "4"
	Case GUICtrlRead($g_hR64) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:6"
		$g_aRoutingBMX[4] = "5"
	Case GUICtrlRead($g_hR74) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:7"
		$g_aRoutingBMX[4] = "6"
	Case GUICtrlRead($g_hR84) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = "0:8"
		$g_aRoutingBMX[4] = "7"
	Case GUICtrlRead($g_hRL4) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR4) = $GUI_CHECKED
		$g_aRoutingFFmpeg[4] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 5
Select
	Case GUICtrlRead($g_hRm5) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "1:0"
		$g_aRoutingBMX[5] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR15) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:1"
		$g_aRoutingBMX[5] = "0"
	Case GUICtrlRead($g_hR25) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:2"
		$g_aRoutingBMX[5] = "1"
	Case GUICtrlRead($g_hR35) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:3"
		$g_aRoutingBMX[5] = "2"
	Case GUICtrlRead($g_hR45) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:4"
		$g_aRoutingBMX[5] = "3"
	Case GUICtrlRead($g_hR55) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:5"
		$g_aRoutingBMX[5] = "4"
	Case GUICtrlRead($g_hR65) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:6"
		$g_aRoutingBMX[5] = "5"
	Case GUICtrlRead($g_hR75) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:7"
		$g_aRoutingBMX[5] = "6"
	Case GUICtrlRead($g_hR85) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = "0:8"
		$g_aRoutingBMX[5] = "7"
	Case GUICtrlRead($g_hRL5) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR5) = $GUI_CHECKED
		$g_aRoutingFFmpeg[5] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 6
Select
	Case GUICtrlRead($g_hRm6) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "1:0"
		$g_aRoutingBMX[6] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR16) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:1"
		$g_aRoutingBMX[6] = "0"
	Case GUICtrlRead($g_hR26) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:2"
		$g_aRoutingBMX[6] = "1"
	Case GUICtrlRead($g_hR36) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:3"
		$g_aRoutingBMX[6] = "2"
	Case GUICtrlRead($g_hR46) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:4"
		$g_aRoutingBMX[6] = "3"
	Case GUICtrlRead($g_hR56) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:5"
		$g_aRoutingBMX[6] = "4"
	Case GUICtrlRead($g_hR66) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:6"
		$g_aRoutingBMX[6] = "5"
	Case GUICtrlRead($g_hR76) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:7"
		$g_aRoutingBMX[6] = "6"
	Case GUICtrlRead($g_hR86) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = "0:8"
		$g_aRoutingBMX[6] = "7"
	Case GUICtrlRead($g_hRL6) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR6) = $GUI_CHECKED
		$g_aRoutingFFmpeg[6] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 7
Select
	Case GUICtrlRead($g_hRm7) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "1:0"
		$g_aRoutingBMX[7] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR17) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:1"
		$g_aRoutingBMX[7] = "0"
	Case GUICtrlRead($g_hR27) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:2"
		$g_aRoutingBMX[7] = "1"
	Case GUICtrlRead($g_hR37) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:3"
		$g_aRoutingBMX[7] = "2"
	Case GUICtrlRead($g_hR47) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:4"
		$g_aRoutingBMX[7] = "3"
	Case GUICtrlRead($g_hR57) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:5"
		$g_aRoutingBMX[7] = "4"
	Case GUICtrlRead($g_hR67) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:6"
		$g_aRoutingBMX[7] = "5"
	Case GUICtrlRead($g_hR77) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:7"
		$g_aRoutingBMX[7] = "6"
	Case GUICtrlRead($g_hR87) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = "0:8"
		$g_aRoutingBMX[7] = "7"
	Case GUICtrlRead($g_hRL7) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR7) = $GUI_CHECKED
		$g_aRoutingFFmpeg[7] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
; track 8
Select
	Case GUICtrlRead($g_hRm8) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "1:0"
		$g_aRoutingBMX[8] = "s1"
		$g_bMuteRouted = True
	Case GUICtrlRead($g_hR18) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:1"
		$g_aRoutingBMX[8] = "0"
	Case GUICtrlRead($g_hR28) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:2"
		$g_aRoutingBMX[8] = "1"
	Case GUICtrlRead($g_hR38) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:3"
		$g_aRoutingBMX[8] = "2"
	Case GUICtrlRead($g_hR48) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:4"
		$g_aRoutingBMX[8] = "3"
	Case GUICtrlRead($g_hR58) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:5"
		$g_aRoutingBMX[8] = "4"
	Case GUICtrlRead($g_hR68) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:6"
		$g_aRoutingBMX[8] = "5"
	Case GUICtrlRead($g_hR78) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:7"
		$g_aRoutingBMX[8] = "6"
	Case GUICtrlRead($g_hR88) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = "0:8"
		$g_aRoutingBMX[8] = "7"
	Case GUICtrlRead($g_hRL8) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = '"[L]"'
		$g_bExternalWavRouted = True
	Case GUICtrlRead($g_hRR8) = $GUI_CHECKED
		$g_aRoutingFFmpeg[8] = '"[R]"'
		$g_bExternalWavRouted = True
EndSelect
#EndRegion - track setting
;~ _ArrayDisplay($g_aRoutingFFmpeg)
For $i = 1 To UBound($g_aRoutingFFmpeg) -1
	ConsoleWrite($g_aRoutingFFmpeg[$i] & @CRLF)
Next
ConsoleWrite("$g_bMuteRouted: " & $g_bMuteRouted & @CRLF)
ConsoleWrite("$g_bExternalWavRouted: " & $g_bExternalWavRouted & @CRLF)

SplashTextOn("Be patient", "MXF-Track-Swap will be prepared ...", 300, 50)
If Not FileExists(@TempDir & "\ffmpeg.exe") Then
	FileInstall('K:\ffmpeg\bin\ffmpeg.exe', @TempDir & "\ffmpeg.exe", $FC_OVERWRITE)
EndIf
If Not FileExists(@TempDir & "\bmxtranswrap.exe") Then
	FileInstall('K:\bmxtranswrap\bmxtranswrap.exe', @TempDir & "\bmxtranswrap.exe", $FC_OVERWRITE)
EndIf
If Not FileExists(@TempDir & "\vcruntime140_1.dll") Then ; this is needed by bmxtranswrap and normally located at "C:\Windows\System32\vcruntime140_1.dll"
	FileInstall('K:\bmxtranswrap\vcruntime140_1.dll', @TempDir & "\vcruntime140_1.dll", $FC_OVERWRITE)
EndIf
SplashOff()

Local $sPathTempFolder = @TempDir & "\"
Global $g_hTimerStart
Global $g_sStdErrAll

_ReWrap()
ShellExecute(@TempDir)
While True
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd
GUIDelete($g_hGUI)
Exit

;~ #cs
#Region Funcs
Func _CheckForInputFiles($aFiles)
;~ 	_ArrayDisplay($aFiles)
	Local $bFoundMXF = False, $bFoundWAV = False
	Local $sDrive, $sDir, $sFileName, $sExtension
	For $i = 1 To $aFiles[0]
		_PathSplit($aFiles[$i], $sDrive, $sDir, $sFileName, $sExtension)
		; ignore folder
		If $sExtension = "" Then ContinueLoop
		; only look for mxf or wav
		Switch StringLower($sExtension)
			Case ".mxf"
				If Not $bFoundMXF Then
					If FileExists($aFiles[$i]) Then
						$g_sMXFFile = $aFiles[$i]
						$g_bMxfAvailable = True
						$bFoundMXF = True
					EndIf
				EndIf
			Case ".wav"
				If Not $bFoundWAV Then
					If FileExists($aFiles[$i]) Then
						$g_sWAVFile = $aFiles[$i]
						$g_bWavAvailable = True
						$bFoundWAV = True
					EndIf
				EndIf
		EndSwitch
		If $bFoundMXF = True And $bFoundWAV = True Then ExitLoop
	Next

EndFunc


Func _ReWrap()
	$g_hTimerStart = TimerInit()
	GUIDelete($g_hGUI)

	$g_hGUI = GUICreate("MXF-Track-Swap Muxing", 600, 270)
	GUICtrlCreateLabel("MXF-File: " & _FileName($g_sMXFFile), 10, 10, 580, 60)
	GUICtrlSetFont(-1, 14, 400, 0, "Courier New")
	Global $g_hLabelInsert = GUICtrlCreateLabel("Insert Audio:", 10, 80, 580, 30)
	GUICtrlSetFont(-1, 12, 400, 0, "Courier New")
	Global $Progress1 = GUICtrlCreateProgress(10, 110, 580, 20)
	GUICtrlCreateLabel("Rewrapping:", 10, 150, 580, 30)
	GUICtrlSetFont(-1, 12, 400, 0, "Courier New")
	Global $Progress2 = GUICtrlCreateProgress(10, 180, 580, 20)
	Global $Edit = GUICtrlCreateLabel("", 10, 230, 260, 60)
	GUICtrlSetFont(-1, 14, 400, 0, "Courier New")
	Global $g_hLabelRunningTime = GUICtrlCreateLabel("", 440, 230, 150, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 14, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	; do everything with bmxwrap at the end, as only this creates valid v1.3 mxf files
	; bmxwrap can't insert external audio, so if that should be done, run ffmpeg first
	Local $sFFmpegCommand, $sBMXCommand, $sSuffix, $sSuffixTemp
	For $i = 1 To UBound($g_aRoutingFFmpeg) -1
		$sSuffix &= '_' & $i & '-' & StringRegExpReplace(StringRegExpReplace($g_aRoutingFFmpeg[$i], "\d:", ""), '[\[\]"]', "")
	Next
	$sSuffixTemp = $sSuffix & '_ffmpegTemp.mxf"'
	$sSuffix &= '.mxf"'

	; this is the default bmxtranswrap command line
	; set TC 10:00:00:00
	$sBMXCommand = '-y 10:00:00:00'
	; type RDD09
	$sBMXCommand &= ' -t rdd9'
	; Active Format Descriptor 4-bit code from table 1 in SMPTE ST 2016-1 - full frame 16:9
	$sBMXCommand &= ' --afd 8'
	; the ARD ZDF HDF profile for op1a/rdd9
	$sBMXCommand &= ' --ard-zdf-hdf'
	; print progress percentage to stdout
	$sBMXCommand &= ' -p'
	; set the wave essence descriptor channel assignment label which identifies the audio layout mode in operation
	$sBMXCommand &= ' --audio-layout as11-mode-0'

	If $g_bExternalWavRouted Then
		; ffmpeg first
		;~ Code zum Remuxen: Video erhalten, Audio: 1>5, 2>6, 3>3, 4>4, 5 mute, 6 mute, 7>L, 8>R
		;~ ffmpeg -i Video.mxf  -f lavfi -i anullsrc=r=48000:cl=mono -i Stereo.wav -ar 48000 -filter_complex "[2:a]apad,channelsplit=channel_layout=stereo[L][R]" -map 0:0 -map 0:5 -map 0:6 -map 0:3 -map 0:4 -map 1:0 -map 1:0 -map "[L]" -map "[R]" -c:v copy -c:a pcm_s24le -shortest -y Video_swapped.mxf
		; video file
		$sFFmpegCommand = '-i "' & $g_sMXFFile & '"'
		; muted source
		If $g_bMuteRouted Then
			$sFFmpegCommand &= ' -f lavfi -i anullsrc=r=48000:cl=mono'
		EndIf
		; external wav file
		$sFFmpegCommand &= ' -i "' & $g_sWAVFile & '" -ar 48000 -filter_complex "['
		If Not $g_bMuteRouted Then
			$sFFmpegCommand &= '1'
		Else
			$sFFmpegCommand &= '2'
		EndIf
		$sFFmpegCommand &= ':a]apad,channelsplit=channel_layout=stereo[L][R]"'
		; video mapping
		$sFFmpegCommand &= ' -map 0:0'
		; audio mapping
		For $i = 1 To UBound($g_aRoutingFFmpeg) -1
			$sFFmpegCommand &= ' -map ' & $g_aRoutingFFmpeg[$i]
		Next
		; copy video, set audio to 24 bit, use shortest file (always the mxf file) as length, overwrite existing file
		$sFFmpegCommand &= ' -c:v copy -c:a pcm_s24le -shortest -y'
		; set encoding date as ffmpeg otherwise wouldn't create a valid op1a v1.3 file
		Local $sDate
		$sDate = _NowCalc()
		$sDate = StringReplace($sDate, "/", "-") & ".000" ; including ms
		$sFFmpegCommand &= ' -metadata creation_time="' & $sDate & '"'
		; output file
		$sFFmpegCommand &= ' "' & @TempDir & '\' & _StripFileExtension(_FileName($g_sMXFFile)) & $sSuffixTemp
		ConsoleWrite("$sFFmpegcommand: " & $sFFmpegCommand & @CRLF)
		_runFFmpeg('ffmpeg ' & $sFFmpegCommand, $sPathTempFolder)
		; bmxtranswrap second
		_runBMXwrap('bmxtranswrap ' & $sBMXCommand & ' -o "' & @TempDir & '\' & _StripFileExtension(_FileName($g_sMXFFile)) & $sSuffix & ' "' & @TempDir & '\' & _StripFileExtension(_FileName($g_sMXFFile)) & $sSuffixTemp, $sPathTempFolder)
	Else
		GUICtrlSetState($Progress1, $GUI_DISABLE) ; no external audio inserted
		GUICtrlSetState($g_hLabelInsert, $GUI_DISABLE) ; no external audio inserted
		; add audio mapping to bmx command
		; '--track-map "4;5;0;1;2;3;s1;s1"'
		; audio mapping
		$sBMXCommand &= ' --track-map "'
		For $i = 1 To UBound($g_aRoutingBMX) -1
			$sBMXCommand &= $g_aRoutingBMX[$i] & ';'
		Next
		$sBMXCommand = StringTrimRight($sBMXCommand, 1) ; remove the last semicolon
		$sBMXCommand &= '"'
		_runBMXwrap('bmxtranswrap ' & $sBMXCommand & ' -o "' & @TempDir & '\' & _StripFileExtension(_FileName($g_sMXFFile)) & $sSuffix & ' "' & $g_sMXFFile & '"', $sPathTempFolder)
	EndIf
	GUICtrlSetData($Progress2, 100)
	GUICtrlSetData($Edit, "Done")
	WinSetOnTop($g_hGUI, "", $WINDOWS_ONTOP)

EndFunc

Func _runFFmpeg($command, $wd)
	Local $hPid = Run('"' & @ComSpec & '" /c ' & $command, $wd, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	Local $sStdErr, $sTimer
	Local $iTicksDuration = 0, $iTicksTime = 0, $iTimer
	While 1
		Sleep(500)
		$sStdErr = StderrRead($hPid)
		If @error Then ExitLoop
		$g_sStdErrAll &= $sStdErr
		If StringLen($sStdErr) > 0 Then
			If Not $iTicksDuration Then $iTicksDuration = _GetDuration($sStdErr)
			$iTicksTime = _GetTime($sStdErr)
			If Not @error Then $sStdErr = ""
			GUICtrlSetData($Progress1, $iTicksTime * 100 / $iTicksDuration)
		EndIf
		$iTimer = TimerDiff($g_hTimerStart)
		$sTimer = _Zeit($iTimer)
		If GUICtrlRead($g_hLabelRunningTime) <> $sTimer Then
			GUICtrlSetData($g_hLabelRunningTime, $sTimer)
		EndIf
	WEnd
EndFunc

Func _runBMXwrap($command, $wd)
	ConsoleWrite("$sBMXcommand: " & $command & @CRLF)
	Local $hPid = Run('"' & @ComSpec & '" /c ' & $command, $wd, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	Local $sStdErr, $sTimer
	Local $iPercent = 0, $iTimer
	While 1
		Sleep(500)
		$sStdErr = StdoutRead($hPid)
		If @error Then ExitLoop
		$g_sStdErrAll &= $sStdErr
		If StringLen($sStdErr) > 0 Then
;~ 			ConsoleWrite("StdOut: " & $sStdErr & @CRLF)
			$iPercent = _GetPercent($sStdErr)
			If Not @error Then $sStdErr = ""
			GUICtrlSetData($Progress2, $iPercent)
		EndIf
		$iTimer = TimerDiff($g_hTimerStart)
		$sTimer = _Zeit($iTimer)
		If GUICtrlRead($g_hLabelRunningTime) <> $sTimer Then
			GUICtrlSetData($g_hLabelRunningTime, $sTimer)
		EndIf
	WEnd
EndFunc

Func _GetDuration($sStdErr)
    If Not StringInStr($sStdErr, "Duration:") Then Return SetError(1, 0, 0)
    Local $aRegExp = StringRegExp($sStdErr, "(?i)Duration.+?([0-9:]+)", 3)
    If @error Or Not IsArray($aRegExp) Then Return SetError(2, 0, 0)
    Local $sTime = $aRegExp[0]
    Local $aTime = StringSplit($sTime, ":", 2)
    If @error Or Not IsArray($aTime) Then Return SetError(3, 0, 0)
    Return _TimeToTicks($aTime[0], $aTime[1], $aTime[2])
EndFunc   ;==>_GetDuration

Func _GetTime($sStdErr)
    If Not StringInStr($sStdErr, "time=") Then Return SetError(1, 0, 0)
    Local $aRegExp = StringRegExp($sStdErr, "(?i)time.+?([0-9:]+)", 3)
    If @error Or Not IsArray($aRegExp) Then Return SetError(2, 0, 0)
    Local $sTime = $aRegExp[UBound($aRegExp) - 1]
    Local $aTime = StringSplit($sTime, ":", 2)
    If @error Or Not IsArray($aTime) Then Return SetError(3, 0, 0)
    Return _TimeToTicks($aTime[0], $aTime[1], $aTime[2])
EndFunc   ;==>_GetTime

Func _GetPercent($sStdErr)
    If Not StringInStr($sStdErr, "%") Then Return SetError(1, 0, 0)
    Local $aRegExp = StringRegExp($sStdErr, "(?i)\d{1,2}\.\d%", 3)
    If @error Or Not IsArray($aRegExp) Then Return SetError(2, 0, 0)
    Local $sPercent = $aRegExp[0]
	$sPercent = StringTrimRight($sPercent, 1) ; remove %
	ConsoleWrite("Percent: " & $sPercent & @CRLF)
    Return $sPercent
EndFunc


Func _FileName($sFullPath)
	Local $iDelimiter = StringInStr($sFullPath, "\", 0, -1)
	Return StringTrimLeft($sFullPath, $iDelimiter)
EndFunc

Func _StripFileExtension($sFile)
	Local $iDelimiter = StringInStr($sFile, ".", 0, -1)
	Return StringLeft($sFile, $iDelimiter - 1)
EndFunc

Func _Zeit($iMs, $bComfortView = True) ; from ms to a format: "12h 36m 56s 13f" (with special space between - ChrW(8239))
	Local $sReturn
	$iMs = Int($iMs)
	Local $iFrames, $iMSec, $iSec, $iMin, $iHour, $sSign
	If $iMs < 0 Then
		$iMs = Abs($iMs)
		$sSign = '-'
	EndIf
	$iMSec = StringRight($iMs, 3)
	$iFrames = $iMSec / 40
	$iSec = $iMs / 1000
	$iMin = $iSec / 60
	$iHour = $iMin / 60
	$iMin -= Int($iHour) * 60
	$iSec -= Int($iMin) * 60
	If $bComfortView Then ; no hours if not present and no frames
		If Not Int($iHour) = 0 Then $sReturn &= StringRight('0' & Int($iHour), 2) & 'h' & ChrW(8239)
		$sReturn &= StringRight('0' & Int($iMin), 2) & 'm' & ChrW(8239)
		If Int($iHour) = 0 Then $sReturn &= StringRight('0' & Int($iSec), 2) & 's' ; zum DEBUGGING auskommentieren
	Else
		$sReturn = $sSign & StringRight('0' & Int($iHour), 2) & 'h' & ChrW(8239) & StringRight('0' & Int($iMin), 2) & 'm' & ChrW(8239) & StringRight('0' & Int($iSec), 2) & 's' & ChrW(8239) & StringRight('0' & Int($iFrames), 2) & 'f'
	EndIf
	Return $sReturn
EndFunc   ;==>_Zeit

Func WM_DROPFILES_FUNC($hWnd, $msgID, $wParam, $lParam)
	If $bPaused Then Return
	#forceref $hWnd, $msgID, $wParam, $lParam
    Local $nSize, $pFileName
    Local $nAmt = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'hwnd', $wParam, 'int', 0xFFFFFFFF, 'ptr', 0, 'int', 0)
    ReDim $g_aDropFiles[$nAmt[0]]
    For $i = 0 To $nAmt[0] - 1
        $nSize = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'hwnd', $wParam, 'int', $i, 'ptr', 0, 'int', 0)
        $nSize = $nSize[0] + 1
        $pFileName = DllStructCreate('wchar[' & $nSize & ']')
        DllCall('shell32.dll', 'int', 'DragQueryFileW', 'hwnd', $wParam, 'int', $i, 'ptr', DllStructGetPtr($pFileName), 'int', $nSize)
        $g_aDropFiles[$i] = DllStructGetData($pFileName, 1)
        $pFileName = 0
    Next
	_ArrayInsert($g_aDropFiles, 0, UBound($g_aDropFiles))
    GUICtrlSendToDummy($FILES_DROPPED, $nAmt[0])
EndFunc   ;==>WM_DROPFILES_FUNC
#EndRegion
