#Include <WinAPI.au3>

;
; Found on AutoIt forums
;
; https://www.autoitscript.com/forum/topic/119681-resolution-of-the-working-area-of-the-desktop/#comment-831856
;

Func _GetworkingAreaWidth()
    Local $aRect[4]
    Local $iWidth = 0

    $aRect = _GetworkingAreaRect()
    If Not @error Then
        $iWidth = $aRect[2] - $aRect[0]
        Return $iWidth
    Else
        Return SetError(1,0,0)
    EndIf
EndFunc

Func _GetworkingAreaHeight()
    Local $aRect[4]
    Local $iWidth = 0

    $aRect = _GetworkingAreaRect()
    If Not @error Then
        $iWidth = $aRect[3] - $aRect[1]
        Return $iWidth
    Else
        Return SetError(1,0,0)
    EndIf
EndFunc

Func _GetworkingAreaRect()
    Local $aRect[4]
    Const $SPI_GETWORKAREA = 0x0030
    Local $rect = DllStructCreate("int;int;int;int")
    Local $iResult = 0

    $iResult = _WinAPI_SystemParametersInfo($SPI_GETWORKAREA, 0 , DllStructGetPtr($rect))
    If $iResult Then
        $aRect[0] = DllStructGetData($rect,1)
        $aRect[1] = DllStructGetData($rect,2)
        $aRect[2] = DllStructGetData($rect,3)
        $aRect[3] = DllStructGetData($rect,4)
        Return $aRect
    Else
        Return SetError(1,0,0)
    EndIf
EndFunc
