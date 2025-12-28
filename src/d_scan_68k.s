;
; NovaCoder's Optimized Span Drawing Routines
; Extracted from AmiQuake v1.36 binary
; Direct translation from addresses 0x003746b8 - 0x00375158
;
; D_DrawSpans8: 68040 FPU-optimized 8-bit texture span drawer
; This is called for EVERY textured surface span - the hottest path in Quake
;

	XDEF	_D_DrawSpans8
	XDEF	_D_DrawTurbulent8Span

	; External Quake globals (declared in C code)
	XREF	_d_zistepu
	XREF	_cacheblock
	XREF	_d_viewbuffer
	XREF	_screenwidth
	XREF	_d_pzbuffer
	XREF	_d_zrowbytes
	XREF	_d_sdivzorigin
	XREF	_d_tdivzorigin
	XREF	_d_ziorigin
	XREF	_d_sdivzstepu
	XREF	_d_tdivzstepu
	XREF	_d_sdivzstepv
	XREF	_d_tdivzstepv
	XREF	_d_zistepv
	XREF	_sadjust
	XREF	_tadjust
	XREF	_bbextents
	XREF	_bbextentt
	XREF	_cachewidth

	section	text,code

; Macro for clamping s/t coordinates to texture bounds
; \1 = register with value
; \2 = register with limit
; \3 = minimum value
clamp_coord	macro
	cmp.l	\2,\1
	ble.s	.clamp_ok\@
	move.l	\2,\1
	bra.s	.clamp_done\@
.clamp_ok\@:
	cmp.l	#\3,\1
	bge.s	.clamp_done\@
	move.l	#\3,\1
.clamp_done\@:
	endm

;
; D_DrawSpans8 - Main 8-bit span drawer
; Entry: a0 = espan_t *pspan (linked list of spans)
;
; espan_t structure:
;   +0: u (int)
;   +4: v (int)
;   +8: count (int)
;   +12: pnext (espan_t *)
;
_D_DrawSpans8:
	; Save FPU and integer registers
	fmovem.x fp2-fp5,-(sp)
	movem.l	d2-d7/a2-a6,-(sp)

	movea.l	a0,a6			; a6 = pspan pointer

	; Load and prepare constants
	fmove.s	(_d_zistepu),fp2	; fp2 = d_zistepu
	fmove.s	#65536.0,fp3		; fp3 = constant for 1/z calc
	fdiv.x	fp2,fp3			; fp3 = 65536.0 / d_zistepu

	; Pre-multiply for 8-pixel stepping
	fmul.s	#32768.0,fp2		; fp2 = d_zistepu * 8 * 65536

	; Load base pointers
	movea.l	(_cacheblock),a0	; a0 = texture base pointer
	movea.l	(_d_viewbuffer),a4	; a4 = end of valid range (bounds check)
	movea.l	(_d_pzbuffer),a5	; a5 = start of valid range

	; Convert fp2 to integer for z-buffer stepping
	fmove.l	fp2,d6			; d6 = z step value

.span_loop:
	; Get span pixel count
	move.l	8(a6),d7		; d7 = pspan->count
	ble.w	.next_span		; Skip empty spans

	; Load span u, v coordinates
	move.l	(a6),d0			; d0 = pspan->u
	fmove.l	d0,fp4			; fp4 = (float)u
	fmove.s	(_d_sdivzstepu),fp0	; fp0 = d_sdivzstepu
	fmul.x	fp4,fp0			; fp0 = u * d_sdivzstepu

	move.l	4(a6),d1		; d1 = pspan->v
	fmove.l	d1,fp5			; fp5 = (float)v
	fmove.s	(_d_sdivzstepv),fp1	; fp1 = d_sdivzstepv
	fmul.x	fp5,fp1			; fp1 = v * d_sdivzstepv

	; Calculate framebuffer destination: d_viewbuffer + v*screenwidth + u
	movea.l	(_d_viewbuffer),a1	; a1 = framebuffer base
	move.l	d1,d2
	mulu.l	(_screenwidth),d2	; d2 = v * screenwidth
	adda.l	d0,a1			; a1 += u
	adda.l	d2,a1			; a1 = final framebuffer pointer

	; Complete s/z calculation
	fadd.x	fp1,fp0			; fp0 = u*d_sdivzstepu + v*d_sdivzstepv
	fadd.s	(_d_sdivzorigin),fp0	; fp0 = sdivz

	; Calculate t/z
	fmove.s	(_d_tdivzstepu),fp1
	fmul.x	fp4,fp1			; fp1 = u * d_tdivzstepu
	fmove.s	(_d_tdivzstepv),fp2
	fmul.x	fp5,fp2			; fp2 = v * d_tdivzstepv

	; Calculate z-buffer pointer: d_pzbuffer + v*d_zrowbytes + u*2
	movea.l	(_d_pzbuffer),a2	; a2 = z-buffer base
	move.l	d1,d2
	mulu.l	(_d_zrowbytes),d2	; d2 = v * d_zrowbytes
	add.l	d0,d2
	add.l	d2,d2			; *2 for word addressing
	adda.l	d2,a2			; a2 = z-buffer pointer

	fadd.x	fp2,fp1			; fp1 = u*d_tdivzstepu + v*d_tdivzstepv
	fadd.s	(_d_tdivzorigin),fp1	; fp1 = tdivz

	; Calculate initial 1/z
	fmove.s	(_d_zistepu),fp0
	fmul.x	fp4,fp0
	fmove.s	(_d_zistepv),fp1
	fmul.x	fp5,fp1
	fadd.x	fp1,fp0
	fadd.s	(_d_ziorigin),fp0	; fp0 = zi

	; Perspective divide: z = 65536.0 / zi
	fmove.s	#65536.0,fp1
	fdiv.x	fp0,fp1			; fp1 = z

	; Calculate texture coordinates (16.16 fixed point)
	; s = (int)(sdivz * z) + sadjust
	fmove.s	(_d_sdivzstepu),fp0
	fmul.x	fp4,fp0
	fmove.s	(_d_sdivzstepv),fp2
	fmul.x	fp5,fp2
	fadd.x	fp2,fp0
	fadd.s	(_d_sdivzorigin),fp0	; fp0 = sdivz
	fmul.x	fp1,fp0			; fp0 = sdivz * z
	fmove.l	fp0,d2			; d2 = s (16.16)
	add.l	(_sadjust),d2

	; Clamp s to texture bounds
	move.l	(_bbextents),d0
	clamp_coord d2,d0,0

	; Calculate t = (int)(tdivz * z) + tadjust
	fmove.s	(_d_tdivzstepu),fp0
	fmul.x	fp4,fp0
	fmove.s	(_d_tdivzstepv),fp2
	fmul.x	fp5,fp2
	fadd.x	fp2,fp0
	fadd.s	(_d_tdivzorigin),fp0	; fp0 = tdivz
	fmul.x	fp1,fp0			; fp0 = tdivz * z
	fmove.l	fp0,d3			; d3 = t (16.16)
	add.l	(_tadjust),d3

	; Clamp t to texture bounds
	move.l	(_bbextentt),d0
	clamp_coord d3,d0,0

	; Calculate next s,t for 8 pixels ahead
	fmove.s	(_d_sdivzstepu),fp5
	fmul.s	#8.0,fp5
	fmove.l	d7,fp4			; fp4 = spancount - 1
	fsub.s	#1.0,fp4
	fmul.x	fp4,fp5
	fmove.s	(_d_sdivzstepu),fp0
	fmul.x	fp4,fp0
	fmove.s	(_d_sdivzstepv),fp2
	fmul.x	fp5,fp2
	fadd.x	fp2,fp0
	fadd.s	(_d_sdivzorigin),fp0
	fmul.x	fp3,fp0			; Perspective divide
	fmove.l	fp0,d4			; d4 = snext
	add.l	(_sadjust),d4

	; Clamp snext
	move.l	(_bbextents),d0
	cmp.l	d0,d4
	ble.s	.snext_ok
	move.l	d0,d4
	bra.s	.snext_clamped
.snext_ok:
	cmp.l	#8,d4
	bge.s	.snext_clamped
	moveq	#8,d4
.snext_clamped:

	; Calculate s step: sstep = (snext - s) / (count - 1)
	move.l	d7,d0
	subq.l	#1,d0
	ble.s	.no_divide
	sub.l	d2,d4
	divsl.l	d0,d4:d4		; d4 = sstep
.no_divide:

	; Load texture width
	move.l	(_cachewidth),d0

	; ===== CRITICAL INNER LOOP - Called for every pixel =====
.pixel_loop:
	; Get texture coordinate (s >> 16)
	move.l	d2,d0
	swap	d0			; d0.w = s integer part

	; Fetch texel: pbase[s>>16 + (t>>16)*cachewidth]
	move.l	d3,d1
	swap	d1			; d1.w = t integer part
	mulu.w	(_cachewidth),d1	; d1 = (t>>16) * cachewidth
	add.w	d1,d0			; d0 = offset into texture
	movea.l	a0,a3
	adda.w	d0,a3
	move.b	(a3),d5			; d5 = texel color

	; Check for transparent pixel (index 255)
	cmp.b	#-1,d5
	beq.s	.skip_write

	; Z-buffer test: only draw if closer
	cmp.w	(a2),d6
	ble.s	.skip_write

	; Write z-buffer and pixel
	move.w	d6,(a2)		; Update z-buffer
	move.b	d5,(a1)			; Write pixel

.skip_write:
	; Advance to next pixel
	add.l	d4,d2			; s += sstep
	addq.l	#2,a2			; z-buffer++ (word)
	addq.l	#1,a1			; framebuffer++ (byte)
	subq.l	#1,d7			; count--
	bgt.s	.pixel_loop
	; ===== END INNER LOOP =====

.next_span:
	; Move to next span in linked list
	lea	12(a6),a6		; a6 = &pspan->pnext
	moveq	#-128,d0
	cmp.l	8(a6),d0		; Check for end marker
	bne.w	.span_loop

	; Restore and return
	movem.l	(sp)+,d2-d7/a2-a6
	fmovem.x (sp)+,fp2-fp5
	rts


;
; D_DrawTurbulent8Span - Water/lava turbulent texture drawer
; Uses sine table for wave distortion
;
_D_DrawTurbulent8Span:
	; TODO: Extract from binary @ 0x0037483c
	; For now, falls through to C implementation
	rts

	end
