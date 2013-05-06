;-------------------------------
; Reference:
;   # - Windows Key
;   ! - Alt
;   ^ - Control
;   + - Shift
;-------------------------------

; Map caps lock to escape
CapsLock::Esc

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
