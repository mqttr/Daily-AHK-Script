#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
SetTitleMatchMode 2
DetectHiddenWindows, On

; if not A_IsAdmin
; {
;    Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
;    ExitApp
; }

;pin window to be always on top
^!x::  Winset, Alwaysontop, , A

>^NumPad0::
{
   Run python main.py, D:\My Projects\018 Computer Web Control\Computer-Web-Control
   return
}

; Change refresh rate ChangeResolution(32,x,y,hz)
>^1::
{
   ChangeResolution(32,1920,1080,144)
   SoundGet, sound_mute, Master, mute
   if sound_mute = On
   {
      Send {Volume_Mute} 
   }
   return
   >^2::
   ChangeResolution(32,1920,1080,60)
   SoundGet, sound_mute, Master, mute
   if sound_mute = Off
   {
      Send {Volume_Mute} 
   }
   return
}


ChangeResolution( cD, sW, sH, rR ) 
{
VarSetCapacity(dM,156,0), NumPut(156,2,&dM,36)
DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ),
NumPut(0x5c0000,dM,40)
NumPut(cD,dM,104), NumPut(sW,dM,108), NumPut(sH,dM,112), NumPut(rR,dM,120)
Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
}

^g::
{
   MyClip := ClipboardAll
   Clipboard = ; empty the clipboard
   Send, ^c
   ClipWait, 2
   if ErrorLevel  ; ClipWait timed out.
   {
      return
   }
   if RegExMatch(Clipboard, "^[^ ]*\.[^ ]*$")
   {
      Run "C:\Program Files\Mozilla Firefox\Firefox.exe" %Clipboard%
   }
   else  
   {
      ; Modify some characters that screw up the URL
      ; RFC 3986 section 2.2 Reserved Characters (January 2005):  !*'();:@&=+$,/?#[]
      StringReplace, Clipboard, Clipboard, `r`n, %A_Space%, All
      StringReplace, Clipboard, Clipboard, #, `%23, All
      StringReplace, Clipboard, Clipboard, &, `%26, All
      StringReplace, Clipboard, Clipboard, +, `%2b, All
      StringReplace, Clipboard, Clipboard, ", `%22, All
      Run % "https://www.ecosia.org/search?q=" . clipboard . "&addon=firefox&addonversion=4.1.0&method=topbar" ; uriEncode(clipboard)
   }
   Clipboard := MyClip
   return
}

; Handy function.
; Copies the selected text to a variable while preserving the clipboard.
GetText(ByRef MyText = "")
{
   SavedClip := ClipboardAll
   Clipboard =
   Send ^c
   ClipWait 0.5
   If ERRORLEVEL
   {
      Clipboard := SavedClip
      MyText =
      Return
   }
   MyText := Clipboard
   Clipboard := SavedClip
   Return MyText
}

; Pastes text from a variable while preserving the clipboard.
PutText(MyText)
{
   SavedClip := ClipboardAll 
   Clipboard =              ; For better compatability
   Sleep 20                 ; with Clipboard History
   Clipboard := MyText
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}


; Get the HWND of the Spotify main window.
getSpotifyHwnd() {
	WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
	Return spotifyHwnd
}
; Send a key to Spotify.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}

; Win+alt+p: Play/Pause
>^>Shift::
{
	spotifyKey("{Space}")
	Return
}

; Win+alt+down: Next
>^right::
{
	spotifyKey("^{Right}")
	Return
}

; Win+alt+up: Previous
>^left::
{
	spotifyKey("^{Left}")
	Return
}

; Win+alt+right: Seek forward
>+Right::
{
	spotifyKey("+{Right}")
	Return
}

; Win+alt+left: Seek backward
>+Left::
{
	spotifyKey("+{Left}")
	Return
}

; shift+volumeUp: Volume up
>^up::
{
	spotifyKey("^{Up}")
	Return
}

; shift+volumeDown: Volume down
>^Down::
{
	spotifyKey("^{Down}")
	Return
}