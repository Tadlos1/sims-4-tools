; The Sims 4 Language changer by anadius
; normal usage (GUI): 
;   language-changer
; select language with no GUI:
;   language-changer en_US

#include <GUIConstantsEx.au3>
#include <Array.au3>

Global Const $sKEY = '\SOFTWARE\Maxis\The Sims 4', $sVALUENAME = 'Locale', _
    $sRLDConfigs[4] = ['Game\Bin\RldOrigin.ini', 'Game-cracked\Bin\RldOrigin.ini', 'Game\Bin_LE\RldOrigin.ini', 'Game-cracked\Bin_LE\RldOrigin.ini']

If $CmdLine[0] > 0 Then
    SetLanguage($CmdLine[1])
Else
    ShowGUI()
EndIf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func ShowGUI()
    Local Const $aLangCodes[18] = ['cs_CZ', 'da_DK', 'de_DE', 'en_US', 'es_ES', 'fr_FR', 'it_IT', _
        'nl_NL', 'no_NO', 'pl_PL', 'pt_BR', 'fi_FI', 'sv_SE', 'ru_RU', 'ja_JP', 'zh_TW', 'zh_CN', _
        'ko_KR'], _
        $aLangNames[18] = ['Čeština', 'Dansk', 'Deutsch', 'English', 'Español', 'Français', _
        'Italiano', 'Nederlands', 'Norsk', 'Polski', 'Português (Brasil)', 'Suomi', 'Svenska', _
        'Русский', '日本語', '繁體中文', '简体中文', '한국어']
    Local $iLangIndex = -1, $sLang, $hGUI, $hComboBox, $hOkButton

    ; create main GUI window
    $hGUI = GUICreate('Language changer', 300, 58)

    $iFromTop = 5
    GUICtrlCreateLabel('made by anadius', 9, $iFromTop)
    $dsc = GUICtrlCreateLabel('Discord', 100, $iFromTop, 38)
    GUICtrlSetColor(-1, 0x0000FF)
    GUICtrlSetCursor(-1, 0)
    $site = GUICtrlCreateLabel('website', 142, $iFromTop, 38)
    GUICtrlSetColor(-1, 0x0000FF)
    GUICtrlSetCursor(-1, 0)

    ; create dropdown menu
    $hComboBox = GUICtrlCreateCombo('', 10, 28, 250)
    GUICtrlSetData($hComboBox, _ArrayToString($aLangNames))
    ; create OK button
    $hOkButton =  GUICtrlCreateButton('OK', 268, 26)

    ; try to get language from registry
    $sLang = RegRead('HKLM' & $sKEY, $sVALUENAME)
    If @error <> 0 Then ; fallback to 64bit registry tree
        $sLang = RegRead('HKLM64' & $sKEY, $sVALUENAME)
    EndIf
    If @error <> 0 Then ; fallback to english
        $sLang = 'en_US'
    EndIf

    ; get index of language
    $iLangIndex = _ArraySearch($aLangCodes, $sLang)
    If $iLangIndex == -1 Then $iLangIndex = _ArraySearch($aLangCodes, 'en_US')
    ; set default language
    GUICtrlSetData($hComboBox, $aLangNames[$iLangIndex])

    ; show GUI
    GUISetState(@SW_SHOW, $hGUI)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                $iLangIndex = -1
                ExitLoop
            Case $hOkButton
                $iLangIndex = _ArraySearch($aLangNames, GUICtrlRead($hComboBox))
                ExitLoop
            Case $dsc
                ShellExecute('https://anadius.hermietkreeft.site/discord')
            Case $site
                ShellExecute('https://anadius.hermietkreeft.site/')
        EndSwitch
    WEnd

    ; Delete the previous GUI and all controls.
    GUIDelete($hGUI)

    If $iLangIndex <> -1 Then SetLanguage($aLangCodes[$iLangIndex])
EndFunc

Func SetLanguage($sLanguage)
    Local $success
    $success = RegWrite('HKLM' & $sKEY, $sVALUENAME, 'REG_SZ', $sLanguage)
    ; on fail run the script as admin
    If $success == 0 Then
        If @Compiled == 1 Then
            ShellExecute(@ScriptName, $sLanguage, '', 'runas')
        Else
            ShellExecute(@AutoItExe, @ScriptName & ' ' & $sLanguage, '', 'runas')
        EndIf
        Exit
    ElseIf @OSArch = 'X64' Then
        RegWrite('HKLM64' & $sKEY, $sVALUENAME, 'REG_SZ', $sLanguage)
    EndIf
    For $i = 0 To UBound($sRLDConfigs) - 1
        If FileExists($sRLDConfigs[$i]) Then
            IniWrite($sRLDConfigs[$i], 'Origin', 'Language', $sLanguage)
        EndIf
    Next
EndFunc
