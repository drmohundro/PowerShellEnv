;-------------------------------
; Reference:
;   # - Windows Key
;   ! - Alt
;   ^ - Control
;   + - Shift
;-------------------------------

;Author: Autohotkey forum user RHCP
;http://www.autohotkey.com/board/topic/103174-dual-function-control-key/
;if !state
  ;state := (GetKeyState("Shift", "P") ||  GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
;return

;$~ctrl up::
;if instr(A_PriorKey, "control") && !state
  ;send {esc}
;state := 0
;return


if WinActive("ahk_class wndclass_desked_gsk") {
  ; Process Go to next member/tag
  $!J:: {
    Send("!{Down}")
    return
  }

  ; Process Go to previous member/tag
  $!K:: {
    Send("!{Up}")
    return
  }

  ; Process Move Code Up
  $^+!K:: {
    Send("^+!{Up}")
    return
  }

  ; Process Move Code Down
  $^+!J:: {
    Send("^+!{Down}")
    return
  }

  ; Process Go to next usage
  $+!J:: {
    Send("^!{Down}")
    return
  }

  ; Process Go to previous usage
  $+!k:: {
    Send("^!{Up}")
    return
  }

  ; Process Generate Code
  $!I:: {
    Send("!{Insert}")
    return
  }

  ; Process Insert New File
  $^!+I:: {
    Send("^!{Insert}")
    return
  }
}
