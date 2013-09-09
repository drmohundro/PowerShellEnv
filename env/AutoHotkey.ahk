;-------------------------------
; Reference:
;   # - Windows Key
;   ! - Alt
;   ^ - Control
;   + - Shift
;-------------------------------

; Map Caps Lock to Control if pressed with another key; else map to Escape
*CapsLock::
    Send {Blind}{Ctrl Down}
    cDown := A_TickCount
Return

*CapsLock up::
    If ((A_TickCount-cDown)<400)  ; Modify press time as needed (milliseconds)
        Send {Blind}{Ctrl Up}{Esc}
    Else
        Send {Blind}{Ctrl Up}
Return


; Replace WinR to point to SlickRun (alt+q) (required in Windows 8 as far as I can tell)
$#r::
  Send, !q
return


if WinActive("ahk_class wndclass_desked_gsk")
{
  ; Process Go to next member/tag
  $!J::
    Send, !{Down}
  return

  ; Process Go to previous member/tag
  $!K::
    Send, !{Up}
  return

  ; Process Move Code Up
  $^+!K::
    Send, ^+!{Up}
  return

  ; Process Move Code Down
  $^+!J::
    Send, ^+!{Down}
  return

  ; Process Go to next usage
  $+!J::
    Send, ^!{Down}
  return

  ; Process Go to previous usage
  $+!k::
    Send, ^!{Up}
  return

  ; Process Generate Code
  $!I::
    Send, !{Insert}
  return

  ; Process Insert New File
  $^!+I::
    Send, ^!{Insert}
  return
}
