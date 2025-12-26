
; 680x0 optimised Quake render routines by John Selck.

	; d_scan.c:

		XDEF	@D_WarpScreen
		XDEF	@Turbulent8
		;XDEF	@D_DrawTurbulent8Span	; used by @Turbulent8 only
		XDEF	_D_DrawSpans8
		XDEF	@D_DrawSpans8
		XDEF	@D_DrawSpans16
		XDEF	@D_DrawZSpans
		XDEF	_D_DrawZSpans

	; d_sky.c:

		XDEF	@D_DrawSkyScans8
		XDEF	_D_DrawSkyScans8
		;XDEF	@D_Sky_uv_To_st	; used by D_DrawSkyScans8 only

	; d_sprite.c:

		XDEF	_D_SpriteDrawSpans
		XDEF	@D_SpriteDrawSpans

	; d_part.c:

		XDEF	@D_DrawParticle

	; d_edge.c:

		XDEF	_D_CalcGradients
		XDEF	@D_CalcGradients

	; external defs:

		XREF	@TransformVector
		XREF	@VectorScale

		XREF	_miplevel
		XREF	_xscaleinv
		XREF	_yscaleinv
		XREF	_transformed_modelorg

		XREF	_xcenter
		XREF	_ycenter
		XREF	_d_scantable
		XREF	_d_pzbuffer
		XREF	_d_zwidth
		XREF	_d_vrectx
		XREF	_d_vrecty
		XREF	_d_vrectright_particle
		XREF	_d_vrectbottom_particle
		XREF	_d_pix_min
		XREF	_d_pix_max
		XREF	_d_pix_shift
		XREF	_d_y_aspect_shift
		XREF	_r_origin
		XREF	_r_ppn
		XREF	_r_pright
		XREF	_r_pup

		XREF	_cacheblock
		XREF	_d_sdivzstepu
		XREF	_d_sdivzstepv
		XREF	_d_sdivzorigin
		XREF	_d_tdivzstepu
		XREF	_d_tdivzstepv
		XREF	_d_tdivzorigin
		XREF	_d_zistepu
		XREF	_d_zistepv
		XREF	_d_ziorigin
		XREF	_screenwidth
		XREF	_d_viewbuffer
		XREF	_sadjust
		XREF	_tadjust
		XREF	_bbextents
		XREF	_bbextentt
		XREF	_cachewidth

		XREF	_d_zwidth
		XREF	_d_pzbuffer

		XREF	_cl
		XREF	_sintable

		XREF	_r_refdef
		XREF	_vup
		XREF	_vid
		XREF	_vright
		XREF	_vpn
		XREF	_skyspeed
		XREF	_skytime
		XREF	_r_skysource

		XREF	_scr_vrect
		XREF	_intsintable

		SECTION	"Span",CODE

@D_WarpScreen:
		fmovem.x	fp2-fp7,-(sp)
		movem.l	d2-d7/a2-a6,-(sp)

		fmove.l	_r_refdef+8,fp0		; w
		fmove.l	_r_refdef+12,fp1	; h
		fmove.x	fp0,fp2
		fmove.x	fp1,fp3
		fdiv.l	_scr_vrect+8,fp2	; wratio

		lea	oldsp(pc),a0
		move.l	sp,(a0)
		sub.w	#(1280+8+1024+8)*4,sp
		move.l	sp,d0
		and.w	#$fff0,d0
		move.l	d0,sp

		fdiv.l	_scr_vrect+12,fp3	; hratio

		move.l	_d_viewbuffer,a0

		move.l	_screenwidth,d0
		muls.l	_r_refdef+4,d0
		fmove.x	fp3,fp6
		fmul.x	fp1,fp6
		fmove.x	fp1,fp7
		fadd.s	#6,fp7
		fdiv.x	fp7,fp6	; hratio*h/(h+AMP2*2)

		;lea	rowptr(pc),a5
		lea	1288*4(sp),a5

		move.l	_scr_vrect+12,d6
		addq.l	#6,d6
		moveq	#0,d7
.w1
		fmove.l	d7,fp7
		fmul.x	fp6,fp7
		addq.l	#1,d7
		fmove.l	fp7,d1
		muls.l	_screenwidth,d1
		add.l	d0,d1
		add.l	a0,d1
		move.l	d1,(a5)+
		subq.l	#1,d6
		bne.b	.w1

		move.l	_r_refdef+4,d0
		fmove.x	fp3,fp6
		fmul.x	fp1,fp6
		fmove.x	fp1,fp7
		fadd.s	#6,fp7
		fdiv.x	fp7,fp6	; wratio*w/(w+AMP2*2)

		;lea	column(pc),a5
		move.l	sp,a5

		move.l	_scr_vrect+8,d6
		addq.l	#6,d6
		moveq	#0,d7
.w0
		fmove.l	d7,fp7
		fmul.x	fp6,fp7
		addq.l	#1,d7
		fmove.l	fp7,d1
		add.l	d0,d1
		move.l	d1,(a5)+
		subq.l	#1,d6
		bne.b	.w0

		fmove.d	_cl+$023c,fp0
		fmul.s	#20,fp0
		fmove.l	fp0,d0
		and.l	#$7f,d0
		lea	_intsintable,a0
		lea	(a0,d0.w*4),a0

		move.l	_scr_vrect+4,d0
		mulu.l	_vid+16,d0
		add.l	_scr_vrect,d0
		move.l	_vid,a1
		add.l	d0,a1


		moveq	#0,d7
.wrp0
		moveq	#0,d0
		move.l	(a0,d7.w*4),d0
		move.l	sp,a2
		;lea	column,a2
		lea	(a2,d0.w*4),a2
		lea	1288*4(sp),a3
		;lea	rowptr,a3
		lea	(a3,d7.w*4),a3

		movem.l	a0-a2,-(sp)

		moveq	#0,d6
.wrp1		move.l	(a0)+,d0
		move.l	(a3,d0.w*4),a5
		add.l	(a2)+,a5
		move.b	(a5),(a1)+
		move.l	(a0)+,d0
		move.l	(a3,d0.w*4),a5
		add.l	(a2)+,a5
		move.b	(a5),(a1)+
		move.l	(a0)+,d0
		move.l	(a3,d0.w*4),a5
		add.l	(a2)+,a5
		move.b	(a5),(a1)+
		move.l	(a0)+,d0
		move.l	(a3,d0.w*4),a5
		add.l	(a2)+,a5
		move.b	(a5),(a1)+
		addq.l	#4,d6
		cmp.l	_scr_vrect+8,d6
		blt.b	.wrp1
		movem.l	(sp)+,a0-a2

		add.l	_vid+16,a1
		addq.l	#1,d7
		cmp.l	_scr_vrect+12,d7
		blt.b	.wrp0

		move.l	oldsp(pc),sp

		movem.l	(sp)+,d2-d7/a2-a6
		fmovem.x	(sp)+,fp2-fp7
		rts
		cnop	0,4
oldsp:		dc.l	0

; void __asm D_DrawTurbulent8Span (void);
; void __asm Turbulent8 (register __a0 espan_t *pspan)

;	turbulent polygon span renderer

		cnop	0,4
@Turbulent8:
		fmovem.x	fp2-fp7,-(sp)

		fmove.d	_cl+$023c,fp0
		fmul.s	#20,fp0
		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,a6
		lea	_sintable,a2
		fmove.l	fp0,d0

		fmove.s	#16,fp4
		fmove.x	fp4,fp5
		fmove.x	fp4,fp6
		fmul.s	_d_sdivzstepu,fp4
		and.w	#$7f,d0
		lea	(a2,d0.w*4),a2
		fmul.s	_d_tdivzstepu,fp5
		move.l	_cacheblock,a0
		move.l	_sadjust,a3
		fmul.s	_d_zistepu,fp6
		subq.l	#4,sp
.t1
		move.l	(a6),d0		; pspan->u
		fmove.l	d0,fp3

		fmove.s	_d_sdivzstepu,fp0
		fmul.x	fp3,fp0
	move.l	4(a6),d1	; pspan->v
	fmove.l	d1,fp7
		fmove.s	_d_sdivzstepv,fp1
		fmul.x	fp7,fp1
		fadd.x	fp1,fp0
		fadd.s	_d_sdivzorigin,fp0

		fmove.s	_d_tdivzstepu,fp1
		fmul.x	fp3,fp1
		fmove.s	_d_tdivzstepv,fp2
		fmul.x	fp7,fp2
	move.l	8(a6),d7	; pspan->count
		fadd.x	fp2,fp1
		fadd.s	_d_tdivzorigin,fp1

		fmove.s	_d_zistepu,fp2
		fmul.x	fp3,fp2
	move.l	_d_viewbuffer,a1
		fmove.s	_d_zistepv,fp3
		fmul.x	fp7,fp3
	muls.l	_screenwidth,d1
		fadd.x	fp3,fp2
		fadd.s	_d_ziorigin,fp2

		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3

	add.l	d0,a1
	add.l	d1,a1

	move.l	_bbextents,d0
	move.l	_bbextentt,d1

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
		fmove.l	fp7,d2

		fmul.x	fp1,fp3

		add.l	a3,d2

		cmp.l	d0,d2
		ble.b	.f0
		move.l	d0,d2
		bra.b	.f1
.f0
		tst.l	d2
		bpl.b	.f1
		moveq	#0,d2
.f1
		fmove.l	fp3,d3
		add.l	_tadjust,d3

		cmp.l	d1,d3
		ble.b	.f2
		move.l	d1,d3
		bra.b	.f3
.f2
		tst.l	d3
		bpl.b	.f3
		moveq	#0,d3
.f3

.t0
		moveq	#16,d1
		cmp.l	d1,d7
		blt.b	.tt

		fadd.x	fp4,fp0
		fadd.x	fp5,fp1
		fadd.x	fp6,fp2
		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3

		move.l	d1,d6
		sub.l	d1,d7
		move.l	d7,(sp)

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
	move.l	_bbextents,d0
	move.l	_bbextentt,d7
		fmove.l	fp7,d4
		add.l	a3,d4

		cmp.l	d0,d4
		ble.b	.f4
		move.l	d0,d4
		bra.b	.f5
.f4
		cmp.l	d1,d4
		bge.b	.f5
		move.l	d1,d4
.f5
		fmul.x	fp1,fp3
		fmove.l	fp3,d5
		add.l	_tadjust,d5

		cmp.l	d7,d5
		ble.b	.f6
		move.l	d7,d5
		bra.b	.f7
.f6
		cmp.l	d1,d5
		bge.b	.f7
		move.l	d1,d5
.f7
		move.l	d4,a4
		move.l	d5,a5
		sub.l	d2,d4
		sub.l	d3,d5
		asr.l	#4,d4
		asr.l	#4,d5
		bra.w	.ttrend
.tt
		move.l	d7,d6
		clr.l	(sp)

		move.l	d6,d0
		subq.l	#1,d0
		ble.w	.ttrend
		fmove.l	d0,fp7

		fmove.s	_d_sdivzstepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp0
		fmove.s	_d_tdivzstepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp1
		fmove.s	_d_zistepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp2
		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3

		move.l	_bbextents,d0
		move.l	_bbextentt,d7

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
		fmove.l	fp7,d4

		fmul.x	fp1,fp3

		add.l	a3,d4

		cmp.l	d0,d4
		ble.b	.f8
		move.l	d0,d4
		bra.b	.f9
.f8
		cmp.l	d1,d4
		bge.b	.f9
		move.l	d1,d4
.f9
		fmove.l	fp3,d5
		add.l	_tadjust,d5

		cmp.l	d7,d5
		ble.b	.f10
		move.l	d7,d5
		bra.b	.f11
.f10
		cmp.l	d1,d5
		bge.b	.f11
		move.l	d1,d5
.f11
		move.l	d4,a4
		move.l	d6,d0
		move.l	d5,a5
		subq.l	#1,d0
		sub.l	d2,d4
		lsl.l	#8,d0
		sub.l	d3,d5
		divs.w	d0,d4
		divs.w	d0,d5
		ext.l	d4
		ext.l	d5
		lsl.l	#8,d4
		lsl.l	#8,d5
.ttrend
		moveq	#$7f,d7
.ti
		move.l	d2,d0
		move.l	d3,d1
		swap	d0
		swap	d1
		and.w	d7,d0
		and.w	d7,d1
		move.l	(a2,d0.w*4),d0
		move.l	(a2,d1.w*4),d1

		add.l	d3,d0
		add.l	d2,d1
		swap	d0
		swap	d1
		and.w	#$3f,d0
		and.w	#$3f,d1
		lsl.w	#6,d0
		add.l	d4,d2
		add.w	d1,d0
		add.l	d5,d3
		move.b	(a0,d0.w),(a1)+

		subq.l	#1,d6
		bgt.b	.ti

		move.l	a4,d2
		move.l	a5,d3

		move.l	(sp),d7
		bgt.w	.t0

		move.l	12(a6),a6
		move.l	a6,d0
		bne.w	.t1

		addq.l	#4,sp
		movem.l	(sp)+,d2-d7/a2-a6
		fmovem.x	(sp)+,fp2-fp7
		rts

; void __asm D_DrawSpans8 (register __a0 espan_t *pspan)

;	perspective texture mapped polygon span renderer

		cnop	0,4
@D_DrawSpans16:
@D_DrawSpans8:
_D_DrawSpans8:
		fmovem.x	fp2-fp7,-(sp)

		fmove.s	#16,fp4
		fmove.x	fp4,fp5
		fmove.x	fp4,fp6
		fmul.s	_d_sdivzstepu,fp4
	movem.l	d2-d7/a2-a6,-(sp)
		fmul.s	_d_tdivzstepu,fp5
	move.l	_cacheblock,a1
		fmul.s	_d_zistepu,fp6
	move.l	_sadjust,a6
.l1
		move.l	(a0),d0		; pspan->u
		fmove.l	d0,fp3

		fmove.s	_d_sdivzstepu,fp0
		fmul.x	fp3,fp0
	move.l	4(a0),d1	; pspan->v
	fmove.l	d1,fp7
		fmove.s	_d_sdivzstepv,fp1
		fmul.x	fp7,fp1
		fadd.x	fp1,fp0
		fadd.s	_d_sdivzorigin,fp0

		fmove.s	_d_tdivzstepu,fp1
		fmul.x	fp3,fp1
		fmove.s	_d_tdivzstepv,fp2
		fmul.x	fp7,fp2
	move.l	8(a0),d7	; pspan->count
		fadd.x	fp2,fp1
		fadd.s	_d_tdivzorigin,fp1

		fmove.s	_d_zistepu,fp2
		fmul.x	fp3,fp2
	move.l	_d_viewbuffer,a2
		fmove.s	_d_zistepv,fp3
		fmul.x	fp7,fp3
	muls.l	_screenwidth,d1
		fadd.x	fp3,fp2
		fadd.s	_d_ziorigin,fp2

		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3

	add.l	d0,a2
	add.l	d1,a2

		; fp0 = sdivz
		; fp1 = tdivz
		; fp2 = zi
		; fp3 = z

	move.l	_bbextents,d0
	move.l	_bbextentt,d1

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
		fmove.l	fp7,d2

		fmul.x	fp1,fp3

		add.l	a6,d2

		cmp.l	d0,d2
		ble.b	.ss0
		move.l	d0,d2
		bra.b	.ss1
.ss0
		tst.l	d2
		bpl.b	.ss1
		moveq	#0,d2
.ss1
		fmove.l	fp3,d3

		cmp.w	#16,d7		;
		blt.b	.sdiv		;
		fmove.s	#65536,fp3	;
		fadd.x	fp6,fp2		;
		fdiv.x	fp2,fp3		;
.sdiv
		add.l	_tadjust,d3

		cmp.l	d1,d3
		ble.b	.ss2
		move.l	d1,d3
		bra.b	.ss3
.ss2
		tst.l	d3
		bpl.b	.ss3
		moveq	#0,d3
.ss3

.here
		moveq	#16,d1
		cmp.l	d1,d7
		blt.w	.sx1

		fadd.x	fp4,fp0
		fadd.x	fp5,fp1

		move.l	d7,a3
		move.l	d1,d6
		sub.l	d1,a3

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
	move.l	_bbextents,d0
	move.l	_bbextentt,d7
		fmove.l	fp7,d4
		add.l	a6,d4

		fmul.x	fp1,fp3

		cmp.l	d0,d4
		ble.b	.ss4
		move.l	d0,d4
		bra.b	.ss5
.ss4
		cmp.l	d1,d4
		bge.b	.ss5
		move.l	d1,d4
.ss5
		fmove.l	fp3,d5
		add.l	_tadjust,d5

		cmp.l	d1,a3		;
		blt.b	.abc		;
		fadd.x	fp6,fp2		;
		fmove.s	#65536,fp3	;
		fdiv.x	fp2,fp3		;
.abc
		cmp.l	d7,d5
		ble.b	.ss6
		move.l	d7,d5
		bra.b	.ss7
.ss6
		cmp.l	d1,d5
		bge.b	.ss7
		move.l	d1,d5
.ss7
		move.l	d4,a4
		move.l	d5,a5
		sub.l	d2,d4
		sub.l	d3,d5
		asr.l	#4,d4
		asr.l	#4,d5

		moveq	#16,d6
		move.l	_cachewidth,d7
iter	MACRO
		move.l	d2,d1
		move.l	d3,d0
		lsr.l	d6,d1
		lsr.l	d6,d0
		mulu.w	d7,d0
		add.l	d4,d2
		add.w	d1,d0
		move.b	(a1,d0.l),(a2)+
		add.l	d5,d3
	ENDM
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		iter
		move.l	d2,d1
		move.l	d3,d0
		lsr.l	d6,d1
		lsr.l	d6,d0
		mulu.w	d7,d0
		move.l	a4,d2
		add.w	d1,d0
		move.b	(a1,d0.l),(a2)+
		move.l	a5,d3

		move.l	a3,d7
		bgt.w	.here

		move.l	12(a0),a0
		move.l	a0,d0
		bne.w	.l1
		bra.w	.dexit
.sx1
		move.l	d7,d6
		sub.l	a3,a3

		move.l	d6,d0
		subq.l	#1,d0
		ble.w	.ssrend
	;	fmove.l	d0,fp7
		lea	l_to_s(pc),a4
		fmove.s	(a4,d0.w*4),fp7

		fmove.s	_d_sdivzstepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp0
		fmove.s	_d_tdivzstepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp1
		fmove.s	_d_zistepu,fp3
		fmul.x	fp7,fp3
		fadd.x	fp3,fp2
		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3

		move.l	_bbextents,d0
		move.l	_bbextentt,d7

		fmove.x	fp0,fp7
		fmul.x	fp3,fp7
		fmove.l	fp7,d4
		add.l	a6,d4

		fmul.x	fp1,fp3

		cmp.l	d0,d4
		ble.b	.ss4b
		move.l	d0,d4
		bra.b	.ss5b
.ss4b
		cmp.l	d1,d4
		bge.b	.ss5b
		move.l	d1,d4
.ss5b
		fmove.l	fp3,d5
		add.l	_tadjust,d5

		cmp.l	d7,d5
		ble.b	.ss6b
		move.l	d7,d5
		bra.b	.ss7b
.ss6b
		cmp.l	d1,d5
		bge.b	.ss7b
		move.l	d1,d5
.ss7b
		move.l	d6,d0
		sub.l	d2,d4
		subq.l	#1,d0
		sub.l	d3,d5
		lsl.l	#8,d0
		divs.w	d0,d4
		divs.w	d0,d5
.ssrend
		lsr.l	#8,d2
		lsr.l	#8,d3

		move.l	_cachewidth,d7

.l0		move.w	d2,d1
		move.w	d3,d0
		lsr.w	#8,d1
		lsr.w	#8,d0
		mulu.w	d7,d0
		add.w	d4,d2
		add.w	d1,d0
		move.b	(a1,d0.l),(a2)+
		add.w	d5,d3
		subq.l	#1,d6
		bgt.b	.l0

		move.l	12(a0),a0
		move.l	a0,d0
		bne.w	.l1
.dexit
		movem.l	(sp)+,d2-d7/a2-a6
		fmovem.x	(sp)+,fp2-fp7
		rts

		cnop	0,8
l_to_s:
		dc.l	$00000000	; 0
		dc.l	$3f800000	; 1
		dc.l	$40000000	; 2
		dc.l	$40400000	; 3
		dc.l	$40800000	; 4
		dc.l	$40a00000	; 5
		dc.l	$40c00000	; 6
		dc.l	$40e00000	; 7
		dc.l	$41000000	; 8
		dc.l	$41100000	; 9
		dc.l	$41200000	; 10
		dc.l	$41300000	; 11
		dc.l	$41400000	; 12
		dc.l	$41500000	; 13
		dc.l	$41600000	; 14
		dc.l	$41700000	; 15

; void __asm D_DrawZSpans (register __a0 espan_t *pspan)

;	z-buffer render loop

		cnop	0,4
@D_DrawZSpans:
_D_DrawZSpans:
		FMOVEM.X	FP2/FP5-FP7,-(SP)
		MOVEM.L	D2/D5-D7/A2/A3/A5,-(SP)
		FMOVE.S	(_d_zistepu).L,FP7
		FMOVE.X	FP7,FP1
		fmul.s	#2147483648,fp1
		MOVE.L	A0,A5
		MOVE.L	(_d_pzbuffer).L,A3
		FMOVE.S	(_d_ziorigin).L,FP5
		FMOVE.L	FP1,D7
		FMOVE.S	(_d_zistepv).L,FP6
.j4
		move.l	(a5)+,d0
		fmove.l	d0,fp1
		fmul.x	fp7,fp1
		move.l	(a5)+,d1
		fmove.l	d1,fp2
		fmul.x	fp6,fp2
		mulu.l	_d_zwidth,d1
		add.l	d1,d0
		fadd.x	fp5,fp2
		fadd.x	fp1,fp2
		fmul.s	#2147483648,fp2
		lea	(a3,d0.l*2),a1
		MOVE.L	(A5)+,D6
		fmove.l	fp2,d5

		MOVE.L	A1,D0
		BTST	#1,D0
		BEQ.B	.j3
		MOVE.L	D5,D0
		SWAP	D0
		SUBQ.L	#1,D6
		ADD.L	D7,D5
		MOVE.W	D0,(A1)+
.j3
		MOVE.L	D6,D2
		ASR.L	#1,D2
		BLE.B	.j1


		; d5=izi
		; d7=izistep
.j0
		move.l	d5,d0
		add.l	d7,d5
		move.l	d5,d1
		swap	d1
		add.l	d7,d5
		move.w	d1,d0
		move.l	d0,(a1)+
		subq.l	#1,d2
		bgt.b	.j0

.j1		BTST	#0,D6
		BEQ.B	.j2
		SWAP	D5
		MOVE.W	D5,(A1)
.j2
		MOVE.L	(A5),A5
		MOVE.L	A5,D0
		bne.b	.j4
		MOVEM.L	(SP)+,D2/D5-D7/A2/A3/A5
		FMOVEM.X	(SP)+,FP2/FP5-FP7
		RTS

; void __asm D_DrawSkyScans8 (register __a0 espan_t *pspan)

;	sky span renderer

		cnop	0,4
@D_DrawSkyScans8:
_D_DrawSkyScans8:
		fmovem.x	fp2-fp5,-(sp)
		movem.l	d2-d7/a2-a6,-(sp)
		subq.l	#4,sp

		move.l	a0,a6
.l2s
		move.l	(a6),d2		; pspan->u
		move.l	4(a6),d3	; pspan->v

		move.l	_d_viewbuffer,a1
		add.l	d2,a1
		move.l	_screenwidth,d0
		muls.w	d3,d0
		add.l	d0,a1

		move.l	d2,a2
		move.l	d3,a3
		bsr.w	D_Sky_uv_To_st
		move.l	d6,d2
		move.l	d7,d3

		move.l	8(a6),d5	; pspan->count
.l1s
		moveq	#$20,d0
		cmp.l	d0,d5
		blt.b	.s0s
		move.l	d0,d4
		dc.w	$0c40
.s0s		move.l	d5,d4

		sub.l	d4,d5
		move.l	d5,(sp)
		beq.b	.s1s

	; full 32 pixels

		add.l	d4,a2
		bsr.w	D_Sky_uv_To_st
		move.l	d6,a4
		move.l	d7,a5
		sub.l	d2,d6
		sub.l	d3,d7
		asr.l	#5,d6
		asr.l	#5,d7
		bra.b	.dol0
.s1s
	; less than 32 pixels

		move.l	d4,d5
		subq.l	#1,d5
		ble.b	.dol0

	; 2 to 31 pixels

		add.l	d5,a2
		bsr.b	D_Sky_uv_To_st
		move.l	d6,a4
		move.l	d7,a5
		sub.l	d2,d6
		lsl.l	#8,d5
		sub.l	d3,d7
		divs.w	d5,d6
		divs.w	d5,d7
		ext.l	d6
		ext.l	d7
		lsl.l	#8,d6
		lsl.l	#8,d7

;		move.l	d6,a4
;		move.l	d7,a5
;		sub.l	d2,d6
;		sub.l	d3,d7
;		divs.l	d5,d6
;		divs.l	d5,d7
.dol0
		move.l	_r_skysource,a0
		move.l	#$7f0000,d5
.l0s
		move.l	d2,d0
		move.l	d3,d1
		and.l	d5,d0
		and.l	d5,d1
		lsl.l	#8,d1
		add.l	d1,d0
		swap	d0
		move.b	(a0,d0.w),(a1)+
		add.l	d6,d2
		add.l	d7,d3
		subq.l	#1,d4
		bgt.b	.l0s

		move.l	a4,d2
		move.l	a5,d3

		move.l	(sp),d5
		bgt.b	.l1s

		move.l	12(a6),a6
		move.l	a6,d0
		bne.w	.l2s

		addq.l	#4,sp
		movem.l	(sp)+,d2-d7/a2-a6
		fmovem.x	(sp)+,fp2-fp5
		rts

; void D_Sky_uv_To_st (int u, int v, fixed16_t *s, fixed16_t *t)

;	support routine for sky span renderer

		cnop	0,4
D_Sky_uv_To_st:
		fmove.s	#4096,fp1
		fmul.s	_vpn+4,fp1

		move.l	a2,d0
		move.l	a3,d1

		movem.l	d2-d3,-(sp)

		move.l	_r_refdef+12,d2
		move.l	_r_refdef+8,d3
		cmp.l	d2,d3
		blt.b	.r0
		fmove.l	d3,fp0
		bra.b	.r1
.r0
		fmove.l	d2,fp0
.r1				; FP0=temp

		move.l	_vid+$14,d2
		asr.l	#1,d2
		sub.l	d2,d0
		fmove.l	d0,fp2
		fmul.s	#8192,fp2
		fdiv.x	fp0,fp2	; wu=8192*(u-vid.width>>1)/temp

		move.l	_vid+$18,d2
		asr.l	#1,d2
		sub.l	d1,d2
		fmove.l	d2,fp3
		fmul.s	#8192,fp3
		fdiv.x	fp0,fp3	; wv=8192*(vid.height>>1-v)/temp

		fmove.s	#4096,fp0
		fmul.s	_vpn+0,fp0
		fmove.x	fp2,fp4
		fmul.s	_vright+0,fp4
		fmove.x	fp3,fp5
		fmul.s	_vup+0,fp5
		fadd.x	fp4,fp0
		fadd.x	fp5,fp0

		;fmove.s	#4096,fp1	; moved up for pipelining
		;fmul.s	_vpn+4,fp1
		fmove.x	fp2,fp4
		fmul.s	_vright+4,fp4
		fmove.x	fp3,fp5
		fmul.s	_vup+4,fp5
		fadd.x	fp4,fp1
		fadd.x	fp5,fp1

		fmul.s	_vright+8,fp2
		fmul.s	_vup+8,fp3
		fmove.s	#4096,fp4
		fmul.s	_vpn+8,fp4
		fadd.x	fp3,fp2
		fadd.x	fp4,fp2
		fmul.s	#3,fp2

		fmove.x	fp0,fp3
		fmove.x	fp1,fp4
		fmove.x	fp2,fp5
		fmul.x	fp3,fp3
		fmul.x	fp4,fp4
		fmul.x	fp5,fp5
		fadd.x	fp4,fp3
		fadd.x	fp5,fp3
		fsqrt.x	fp3
		fmove.s	#1,fp4
		fdiv.x	fp3,fp4
		fmul.x	fp4,fp0
		fmul.x	fp4,fp1
		fmul.x	fp4,fp2

		fmove.s	_skytime,fp2
		fmul.s	_skyspeed,fp2

		fmul.s	#378,fp0
		fadd.x	fp2,fp0
		fmul.s	#65536,fp0
		fmove.l	fp0,d6

		fmul.s	#378,fp1
		fadd.x	fp2,fp1
		fmul.s	#65536,fp1

		movem.l	(sp)+,d2-d3
		fmove.l	fp1,d7
		rts

;void __asm D_SpriteDrawSpans (register __a0 sspan_t *pspan);

		cnop	0,4
_D_SpriteDrawSpans:
@D_SpriteDrawSpans:
		fmovem.x	fp2-fp5,-(sp)

		fmove.s	_d_ziorigin,fp2
		fmove.s	#65536,fp3
		fdiv.x	fp2,fp3		; z

		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,a6
		move.l	_cacheblock,a0	; pbase

		fmul.s	#32768,fp2

		move.l	_bbextents,a4
		move.l	_sadjust,a5

		fmove.l	fp2,d6		; izi
.ls1
		move.l	8(a6),d7	; count
		ble.w	.skip

		move.l	(a6),d0
		fmove.l	d0,fp4	; du

		fmove.s	_d_sdivzstepu,fp0
		fmul.x	fp4,fp0
	move.l	4(a6),d1
	fmove.l	d1,fp5	; dv
		fmove.s	_d_sdivzstepv,fp1
		fmul.x	fp5,fp1
	move.l	_d_viewbuffer,a1
	move.l	d1,d2
	add.l	d0,a1
		fadd.x	fp1,fp0
		fadd.s	_d_sdivzorigin,fp0	; sdivz

		fmove.s	_d_tdivzstepu,fp1
		fmul.x	fp4,fp1
	mulu.l	_screenwidth,d2
	add.l	d2,a1	; pdest
		fmove.s	_d_tdivzstepv,fp2
		fmul.x	fp5,fp2
	move.l	_d_pzbuffer,a2
	move.l	d1,d2
	mulu.l	_d_zwidth,d2
		fadd.x	fp2,fp1
		fadd.s	_d_tdivzorigin,fp1	; tdivz

		fmove.x	fp0,fp4
		fmul.x	fp3,fp4
	add.l	d0,d2
	moveq	#-1,d1
	add.l	d2,d2
	move.l	d7,d0
	add.l	d2,a2	; pz
	subq.l	#1,d0
		fmove.l	fp4,d2
	fmove.l	d0,fp4		; spancountminus1
		fmul.x	fp3,fp1

		add.l	a5,d2	; s

		cmp.l	a4,d2
		ble.b	.s0
		move.l	a4,d2
		bra.b	.s1
.s0
		tst.l	d2
		bpl.b	.s1
		moveq	#0,d2
.s1
		fmove.l	fp1,d3
	fmove.s	_d_sdivzstepu,fp5
	fmul.x	fp4,fp5
		add.l	_tadjust,d3	; t

		move.l	_bbextentt,d0
		cmp.l	d0,d3
		ble.b	.s2
		move.l	d0,d3
		bra.b	.s3
.s2
		tst.l	d3
		bpl.b	.s3
		moveq	#0,d3
.s3
		fadd.x	fp5,fp0
		fmul.x	fp3,fp0
	swap	d3
	muls.w	_cachewidth+2,d3
	move.l	a0,a3
	move.l	a4,d0
	add.l	d3,a3
		fmove.l	fp0,d4
		add.l	a5,d4

		cmp.l	d0,d4
		bgt.b	.s4
		moveq	#8,d0
		cmp.l	d0,d4
		bge.b	.s5
.s4
		move.l	d0,d4
.s5

		move.l	d7,d0
		subq.l	#1,d0
		ble.b	.sd
		sub.l	d2,d4
		divs.l	d0,d4
.sd
.ls0
		move.l	d2,d0
		swap	d0
		move.b	(a3,d0.w),d3
		cmp.b	d1,d3
		beq.b	.ss
		cmp.w	(a2),d6
		ble.b	.ss
		move.w	d6,(a2)
		move.b	d3,(a1)
.ss
		add.l	d4,d2
		addq.l	#2,a2
		addq.l	#1,a1
		subq.l	#1,d7
		bgt.b	.ls0
.skip
		add.w	#12,a6
		moveq	#-128,d0
		cmp.l	8(a6),d0
		bne.w	.ls1

		movem.l	(sp)+,d2-d7/a2-a6
		fmovem.x	(sp)+,fp2-fp5
		rts

; void __asm D_DrawParticle (register __a0 particle_t *pparticle);

;	Draws a single particle.

		cnop	0,4
@D_DrawParticle:
		fmovem.x	fp2-fp7,-(sp)
		movem.l	d4-d7/a2-a3/a5,-(sp)

		move.l	a0,a5

		fmove.s	(a5),fp5
		fsub.s	_r_origin,fp5
		fmove.s	4(a5),fp6
		fsub.s	_r_origin+4,fp6
		fmove.s	8(a5),fp7
		fsub.s	_r_origin+8,fp7

		fmove.s	_r_ppn,fp0
		fmul.x	fp5,fp0
		fmove.s	_r_ppn+4,fp1
		fmul.x	fp6,fp1
		fmove.s	_r_ppn+8,fp2
		fmul.x	fp7,fp2
		fadd.x	fp1,fp0
		fadd.x	fp2,fp0

		fcmp.s	#8,fp0
		fbult.w	.end

		fmove.s	#1,fp4
		fdiv.x	fp0,fp4

		fmove.s	_r_pright,fp0
		fmul.x	fp5,fp0
		fmove.s	_r_pright+4,fp1
		fmul.x	fp6,fp1
		fmove.s	_r_pright+8,fp2
		fmul.x	fp7,fp2
		fadd.x	fp1,fp0
		fadd.x	fp2,fp0
		fmul.x	fp4,fp0
		fadd.s	_xcenter,fp0
		fadd.s	#0.5,fp0
		fmove.l	fp0,d7

		cmp.l	_d_vrectright_particle,d7
		bgt.w	.end
		cmp.l	_d_vrectx,d7
		blt.w	.end

		fmove.s	_r_pup,fp0
		fmul.x	fp5,fp0
		fmove.s	_r_pup+4,fp1
		fmul.x	fp6,fp1
		fmove.s	_r_pup+8,fp2
		fmul.x	fp7,fp2
		fadd.x	fp1,fp0
		fadd.x	fp2,fp0
		fmul.x	fp4,fp0
		fmove.s	_ycenter,fp1
		fsub.x	fp0,fp1
		fadd.s	#0.5,fp1
		fmove.l	fp1,d6

		cmp.l	_d_vrectbottom_particle,d6
		bgt.w	.end
		cmp.l	_d_vrecty,d6
		blt.w	.end

		fmul.s	#32768,fp4

		move.l	_d_zwidth,d0
		mulu.w	d6,d0
		move.l	_d_pzbuffer,a3
		add.l	d7,d0
		add.l	d0,a3
		add.l	d0,a3

		lea	_d_scantable,a1
		move.l	_d_viewbuffer,a2
		add.l	(a1,d6.l*4),a2
		add.l	d7,a2

		fmove.l	fp4,d7	; z
		move.l	_d_pix_shift,d0
		move.l	d7,d6
		asr.l	d0,d6	; size

		move.l	_d_pix_min,d0
		cmp.l	d0,d6
		blt.b	.r0p
		move.l	_d_pix_max,d0
		cmp.l	d0,d6
		ble.b	.r1p
.r0p
		move.l	d0,d6
.r1p
		fmove.s	12(a5),fp0
		fmove.l	fp0,d1
		move.l	_d_zwidth,a5
		add.l	a5,a5

		move.l	d6,d0
		subq.l	#1,d0
		beq.b	.part0
		subq.l	#1,d0
		beq.b	.part1
		subq.l	#1,d0
		beq.b	.part2
		subq.l	#1,d0
		beq.w	.part3
		bra.w	.partx
.part0
		move.l	_d_y_aspect_shift,d0
		moveq	#0,d6
		bset	d0,d6
		tst.l	d6
		beq.w	.end
.l0p
		cmp.w	(a3),d7
		ble.b	.s0p
		move.w	d7,(a3)
		move.b	d1,(a2)
.s0p
		add.l	_screenwidth,a2
		add.l	a5,a3
		subq.l	#1,d6
		bne.b	.l0p
		bra.w	.end

.part1
		move.l	_d_y_aspect_shift,d0
		moveq	#2,d6
		lsl.l	d0,d6
		tst.l	d6
		beq.w	.end
.l1p
		cmp.w	(a3),d7
		ble.b	.s1a
		move.w	d7,(a3)
		move.b	d1,(a2)
.s1a
		cmp.w	2(a3),d7
		ble.b	.s1b
		move.w	d7,2(a3)
		move.b	d1,1(a2)
.s1b
		add.l	_screenwidth,a2
		add.l	a5,a3
		subq.l	#1,d6
		bne.b	.l1p
		bra.w	.end

.part2
		move.l	_d_y_aspect_shift,d0
		moveq	#3,d6
		lsl.l	d0,d6
		tst.l	d6
		beq.w	.end
.l2p
		cmp.w	(a3),d7
		ble.b	.s2a
		move.w	d7,(a3)
		move.b	d1,(a2)
.s2a
		cmp.w	2(a3),d7
		ble.b	.s2b
		move.w	d7,2(a3)
		move.b	d1,1(a2)
.s2b
		cmp.w	4(a3),d7
		ble.b	.s2c
		move.w	d7,4(a3)
		move.b	d1,2(a2)
.s2c
		add.l	_screenwidth,a2
		add.l	a5,a3
		subq.l	#1,d6
		bne.b	.l2p
		bra.b	.end

.part3
		move.l	_d_y_aspect_shift,d0
		moveq	#4,d6
		lsl.l	d0,d6
		tst.l	d6
		beq.b	.end
.l3p
		cmp.w	(a3),d7
		ble.b	.s3a
		move.w	d7,(a3)
		move.b	d1,(a2)
.s3a
		cmp.w	2(a3),d7
		ble.b	.s3b
		move.w	d7,2(a3)
		move.b	d1,1(a2)
.s3b
		cmp.w	4(a3),d7
		ble.b	.s3c
		move.w	d7,4(a3)
		move.b	d1,2(a2)
.s3c
		cmp.w	6(a3),d7
		ble.b	.s3d
		move.w	d7,6(a3)
		move.b	d1,3(a2)
.s3d
		add.l	_screenwidth,a2
		add.l	a5,a3
		subq.l	#1,d6
		bne.b	.l3p
		bra.b	.end

.partx
		move.l	_d_y_aspect_shift,d0
		move.l	d6,d5
		beq.b	.end
		lsl.l	d0,d5
		tst.l	d5
		beq.b	.end
.l4p
		move.l	a3,a0
		move.l	d6,d4
.l5p
		cmp.w	(a0),d7
		ble.b	.s4p
		move.w	d7,(a0)
		move.b	d1,(a2,d4.w)
.s4p
		addq.l	#2,a0
		subq.l	#1,d4
		bne.b	.l5p

		add.l	_screenwidth,a2
		add.l	a5,a3
		subq.l	#1,d5
		bne.b	.l4p
.end
		movem.l	(sp)+,d4-d7/a2-a3/a5
		fmovem.x	(sp)+,fp2-fp7
		rts

		cnop	0,4
_D_CalcGradients:
@D_CalcGradients:
		fmovem.x	fp2-fp6,-(sp)

		moveq	#0,d0
		move.l	_miplevel,d1
		bset	d1,d0
		fmove.s	#1,fp2
		fdiv.l	d0,fp2	; mipscale

		move.l	a5,-(sp)

		move.l	a0,a5

		move.l	$34(a5),a0
		lea	p_saxis(pc),a1
		jsr	@TransformVector

		move.l	$34(a5),a0
		add.w	#16,a0
		lea	p_taxis,a1
		jsr	@TransformVector

		fmove.x	fp2,fp0
		fmul.s	_xscaleinv,fp0
	lea	p_saxis,a0
	lea	p_taxis,a1
		fmove.x	fp0,fp1
		fmul.s	(a0)+,fp1
	move.l	$30(a5),d0
	sub.w	d0,d0
		fmove.s	fp1,_d_sdivzstepu
		fmul.s	(a1)+,fp0
	move.l	_miplevel,d1
	asr.l	d1,d0
		fmove.s	fp0,_d_tdivzstepu

		fneg.x	fp2,fp0
		fmul.s	_yscaleinv,fp0
	subq.l	#1,d0
	move.l	d0,_bbextents
		fmove.x	fp0,fp1
		fmul.s	(a0)+,fp1
	move.l	$32(a5),d0
	sub.w	d0,d0
		fmove.s	fp1,_d_sdivzstepv
		fmul.s	(a1)+,fp0
	move.l	_miplevel,d1
	asr.l	d1,d0
		fmove.s	fp0,_d_tdivzstepv

		fmove.s	(a0),fp0
		fmul.x	fp2,fp0
	subq.l	#1,d0
	move.l	d0,_bbextentt
		fmove.s	_xcenter,fp1
		fmul.s	_d_sdivzstepu,fp1
		fsub.x	fp1,fp0
		fmove.s	_ycenter,fp1
		fmul.s	_d_sdivzstepv,fp1
		fsub.x	fp1,fp0
		fmove.s	fp0,_d_sdivzorigin

		fmove.s	(a1),fp0
		fmul.x	fp2,fp0
		fmove.s	_xcenter,fp1
		fmul.s	_d_tdivzstepu,fp1
		fsub.x	fp1,fp0
		fmove.s	_ycenter,fp1
		fmul.s	_d_tdivzstepv,fp1
	lea	_transformed_modelorg,a0
		fsub.x	fp1,fp0
		fmove.s	fp0,_d_tdivzorigin

		fmove.s	(a0)+,fp4
		fmul.x	fp2,fp4
		fmove.s	(a0)+,fp5
		fmul.x	fp2,fp5
		fmove.s	(a0),fp6
		fmul.x	fp2,fp6

		fmove.s	#65536,fp3
		fmul.x	fp2,fp3

		lea	p_saxis,a1
		fmove.x	fp4,fp0
		fmul.s	(a1)+,fp0
		fmove.x	fp5,fp1
		fmul.s	(a1)+,fp1
		fadd.x	fp1,fp0
		fmove.x	fp6,fp1
		fmul.s	(a1),fp1
	move.l	$2c(a5),d0
	sub.w	d0,d0
		fadd.x	fp1,fp0
		fmul.s	#65536,fp0
	move.l	_miplevel,d1
	asr.l	d1,d0
	move.l	$34(a5),a0
		fadd.s	#0.5,fp0
		fintrz.x	fp0
		fmove.s	12(a0),fp1
		fmul.x	fp3,fp1
	lea	p_taxis,a1
		fadd.x	fp1,fp0
		fmove.l	fp0,d1

		fmove.x	fp4,fp0
		fmul.s	(a1)+,fp0
	sub.l	d0,d1
	move.l	d1,_sadjust
		fmove.x	fp5,fp1
		fmul.s	(a1)+,fp1
		fadd.x	fp1,fp0
		fmove.x	fp6,fp1
		fmul.s	(a1),fp1
	move.l	$2e(a5),d0
	sub.w	d0,d0
		fadd.x	fp1,fp0
		fmul.s	#65536,fp0
	move.l	_miplevel,d1
	asr.l	d1,d0
	move.l	$34(a5),a0
		fadd.s	#0.5,fp0
		fintrz.x	fp0
		fmove.s	$1c(a0),fp1
		fmul.x	fp3,fp1
	move.l	(sp)+,a5
		fadd.x	fp1,fp0
		fmove.l	fp0,d1
		sub.l	d0,d1
		move.l	d1,_tadjust

		fmovem.x	(sp)+,fp2-fp6
		rts

		cnop	0,8
p_saxis:	dc.l	0,0,0
p_taxis:	dc.l	0,0,0

;		cnop	0,8
;column:		ds.l	1280
;rowptr:		ds.l	1024

		END
