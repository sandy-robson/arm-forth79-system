
.macro addr addr1
  .long \addr1
.endm

.macro cfa addr1
  .align 2, 0
  .long \addr1
.endm

.macro const
  .long _b_docon + 4
.endm

.macro exit
  .long _b_semi_s
.endm

.macro istat byt1
  .align 2, 0
  .byte \byt1 + 0xC0
.endm

.macro len byt1
  .byte \byt1
.endm

.macro link addr1
  .align 2, 0
  .long \addr1
.endm

.macro mcode
  .long . + 4
.endm

.macro next
  b inext
.endm

.macro nolink
  .align 2, 0
.endm

.macro pfa addr1
  .long \addr1 + 4
.endm

.macro stat byt1
  .align 2, 0
  .byte \byt1 + 0x80
.endm

.macro svar
  .long _b_dosys + 4
.endm

.macro does_thread
  .byte  ((((_b_code_to_tc - 0x04) - .) >> 2) && 0xFF)
  .byte (((((_b_code_to_tc - 0x04) - .) >> 2) >>  8)  && 0xFF)
  .byte (((((_b_code_to_tc - 0x04) - .) >> 2) >> 16)  && 0xFF)
  .byte BRANCHCODE
.endm

.macro term byt1
  .byte \byt1 + 0x80
.endm

.macro thread
  .long _b_docol + 4
.endm

.macro uvar
  .long _b_douse + 4
.endm

.macro val val1
  .long \val1
.endm

.macro var
  .long _b_dovar + 4
.endm
