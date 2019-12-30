;
; YOCTOTRO 2 - $C2 BYTES OF INTRO
;

; Coding by T.M.R/Cosine


; Here's a reduced, sub $100 byte version of Yoctoto, reworked on
; 2019/12/30 to boil it down to $C2 bytes because meh, why not? =-)

; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with Exomizer which can be downloaded at
; https://csdb.dk/release/?id=167084

; build.bat will call both to create an assembled file and then the
; crunched release version.


; Select an output filename
		!to "yoctotro_2.prg",cbm


; Just the one label
logo_colour	= $fe
scroll_x	= $ff


; One line of Cosine Systems logo
		* = $0798
logo_data	!byte $5f,$c3,$6f,$5f,$c3,$69,$6f,$c3
		!byte $df,$c4,$e9,$78,$69,$5f,$c3,$c6
		!byte $20,$6f,$c3,$df,$52,$c3,$69,$6f
		!byte $c3,$df,$78,$a0,$78,$5f,$c3,$c6
		!byte $e9,$78,$a0,$78,$69,$6f,$c3,$df

; The obligatory scrolling message
scroll_text	!scrxor $80,"   "
		!scrxor $80,"cosine / yoctotro 2"
		!scrxor $80,"   "

		!scrxor $80,"S our friends!"


; Main code start at $07e7
		* = $07e7
entry		sei

; Colour in the logo and scroller
		ldx #$4f
		lda #$0e
screen_col_set	sta $db98,x
		dex
		bpl screen_col_set

; Reset the scroll's counter
		lda #$00
		sta scroll_x

; Set up the SID
		ldx #$11
sid_init	lda sid_data,x
		sta $d407,x
		dex
		bpl sid_init

; Wait for the start of the scroller...
main_loop	lda #$f2
		cmp $d012
		bne *-$03

		ldx #$0a
		dex
		bne *-$01

; Set scroll register for the scroller
		ldy scroll_x
		sty $d016

; Wait for the lower border (X is zero from the wait above)
		dex
		bne *-$01

; Reset the scroll register for the main screen
		lda #$08
		sta $d016

; Update the scroller (Y is previously set at scroll_x)
		dey
		bpl sy_xb

; Shift the scroll area (it wraps around, X is zero from above)
		ldy scroll_text+$00

mover		lda scroll_text+$01,x
		sta scroll_text+$00,x
		inx
		cpx #$26
		bne mover

		sty scroll_text+$26

		ldy #$07
sy_xb		sty scroll_x

; Update the logo's colour
		ldx #$27
		lda logo_colour
colour_move	sta $db98,x
		dex
		bpl colour_move

		inc logo_colour

; Check to see if space has been pressed
		lda $dc01
		cmp #$ef
		bne main_loop

; Space has been pressed so reset the C64
		jmp $fce2

; SID registers for the hum
sid_data	!byte $c0,$01,$00,$00,$21,$0f,$ff
		!byte $c4,$01,$00,$00,$21,$0f,$ff
		!byte $00,$00,$00,$0b
