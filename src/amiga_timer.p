;		.section	".text"
;		.globl	_ppctimer
;		.globl	_ppcaddtimer
;		.globl	_ppcsubtimer
;		.type	_ppctimer,@function
;		.type	_ppcaddtimer,@function
;		.type	_ppcsubtimer,@function
;
;# return the timebase registers in the structure passed in
;
;		.align	4

		noexe
		xdef	_ppctimer
		xdef	_ppcaddtimer
		xdef	_ppcsubtimer

		vea

_ppctimer:	mftbu	r4
		mftbl	r5
		mftbu	r6
		cmpw	r4,r6
		bne-	_ppctimer

		stw	r4,0(r3)
		stw	r5,4(r3)
		blr

_ppcaddtimer:	lwz	r0,4(r3)
		lwz	r9,4(r4)
		addo	r0,r0,r9
		stw	r0,4(r3)
		lwz	r0,0(r3)
		lwz	r9,0(r4)
		adde	r0,r0,r9
		stw	r0,0(r3)
		blr

_ppcsubtimer:	lwz	r0,4(r3)
		lwz	r9,4(r4)
		subfo	r0,r9,r0
		stw	r0,4(r3)
		lwz	r0,0(r3)
		lwz	r9,0(r4)
		subfe	r0,r9,r0
		stw	r0,0(r3)
		blr
