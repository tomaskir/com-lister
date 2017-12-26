#Region ; environmental settings

#RequireAdmin
#NoTrayIcon

Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

#EndRegion ; environmental settings

#Region ; wrapper settings

; output file info
#AutoIt3Wrapper_Res_Description=Lists available COM ports on Windows
#AutoIt3Wrapper_Outfile=COM-lister.exe

; wrapper options
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_UseUpx=n

#EndRegion ; wrapper settings

#Region ; includes

; AutoIt includes
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <Array.au3>

; our includes
#include "CommMG.au3"
#include "WorkArea.au3"

#EndRegion ; includes

; variables
Local $comTitle
Local $comText

Local $mainParent
Local $tooltipStatus
Local $tooltipToggle
Local $tooltipX
Local $tooltipY
Local $tooltipUpdatePos
Local $tooltipTitle
Local $tooltipText
Local $exit

Local $showTooltip = False
Local $tooltipXoffset = 0
Local $tooltipYoffset = 0

Local $tooltipWidth = 200
Local $tooltipHeight = 135

Local $ttParent
Local $ttTitle
Local $ttText

; calculate default Tooltip offset
$tooltipXoffset = _GetworkingAreaWidth() - $tooltipWidth
$tooltipYoffset = _GetworkingAreaHeight() - $tooltipHeight

; build GUI
$mainParent = GUICreate("COM-lister", 280, 290)
GUICtrlCreateLabel("Tooltip status: ", 10, 10, 100, 30, $SS_CENTERIMAGE)
$tooltipStatus = GUICtrlCreateLabel("Off", 110, 10, 50, 30, $SS_CENTERIMAGE)

$tooltipToggle = GUICtrlCreateButton("Toggle", 170, 10, 100, 30)
GUICtrlSetOnEvent($tooltipToggle, "toggleTooltip")

GUICtrlCreateLabel("Tooltip X offset: ", 10, 50, 100, 25, $SS_CENTERIMAGE)
$tooltipX = GUICtrlCreateInput($tooltipXoffset, 110, 50, 50, 25)

GUICtrlCreateLabel("Tooltip Y offset: ", 10, 75, 100, 25, $SS_CENTERIMAGE)
$tooltipY = GUICtrlCreateInput($tooltipYoffset, 110, 75, 50, 25)

$tooltipUpdatePos = GUICtrlCreateButton("Update position", 170, 60, 100, 30)
GUICtrlSetOnEvent($tooltipUpdatePos, "updateTooltipPos")

$tooltipTitle = GUICtrlCreateLabel("", 10, 105, 260, 35, $SS_CENTERIMAGE)
GUICtrlSetFont($tooltipTitle, 12)
$tooltipText = GUICtrlCreateLabel("", 10, 140, 260, 100)
GUICtrlSetFont($tooltipText, 12)

$exit = GUICtrlCreateButton("Exit", 170, 250, 100, 30)
GUISetOnEvent($GUI_EVENT_CLOSE, "exitApp")
GUICtrlSetOnEvent($exit, "exitApp")

GUISetState(@SW_SHOW, $mainParent)

; main loop
While True
	Local $rawPorts = _CommListPorts(0)
	If (@error) Then
		$comTitle = "Error loading COM ports!"
		$comText = ""
	Else
		Local $ports[1] = [0]

		For $i = 1 To $rawPorts[0]
			If ($rawPorts[$i] <> "") Then
				_ArrayAdd($ports, $rawPorts[$i])
			EndIf
		Next

		; update ports count
		$ports[0] = UBound($ports) - 1

		If ($ports[0] == 0) Then
			$comTitle = "No COM ports found"
			$comText = ""
		Else
			$comTitle = $ports[0] & " COM ports found"
			$comText = ""

			For $i = 1 To $ports[0]
				$comText = $comText & " - " & $ports[$i] & @CRLF
			Next

			_ArrayDisplay($ports)
		EndIf
	EndIf

	; update main GUI
	GUICtrlSetData($tooltipTitle, $comTitle)
	GUICtrlSetData($tooltipText, $comText)

	If ($showTooltip) Then
		; update Tooltip
		GUICtrlSetData($ttTitle, $comTitle)
		GUICtrlSetData($ttText, $comText)
	EndIf

	Sleep(1000)
WEnd

Func toggleTooltip()
	If ($showTooltip) Then
		$showTooltip = False
		GUICtrlSetData($tooltipStatus, "Off")

		; destroy Tooltip
		GUIDelete($ttParent)

	Else
		$showTooltip = True
		GUICtrlSetData($tooltipStatus, "On")

		; create Tooltip
		$ttParent = GUICreate("", $tooltipWidth, $tooltipHeight, $tooltipXoffset, $tooltipYoffset, $WS_POPUP, BitOR($WS_EX_TRANSPARENT, $WS_EX_LAYERED, $WS_EX_TOPMOST))
		WinSetTrans($ttParent, "", 200)

		$ttTitle = GUICtrlCreateLabel($comTitle, 10, 0, 180, 35, $SS_CENTERIMAGE)
		GUICtrlSetFont($ttTitle, 12)
		$ttText = GUICtrlCreateLabel($comText, 10, 35, 180, 100)
		GUICtrlSetFont($ttText, 12)

		GUISetState(@SW_SHOW, $ttParent)
	EndIf
EndFunc   ;==>toggleTooltip

Func updateTooltipPos()
	$tooltipXoffset = GUICtrlRead($tooltipX)
	$tooltipYoffset = GUICtrlRead($tooltipY)

	If ($showTooltip) Then
		toggleTooltip()
		toggleTooltip()
	EndIf
EndFunc   ;==>updateTooltipPos

Func exitApp()
	Exit
EndFunc   ;==>exitApp
