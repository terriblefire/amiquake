		.section	".text"
		.globl	ppctimer
		.type	ppctimer,@function
		.globl	_ppctimer
		.type	_ppctimer,@function

# return the timebase registers in the structure passed in

		.align	4

ppctimer:
_ppctimer:	mftbu	r4
		mftbl	r5
		mftbu	r6
		cmpw	r4,r6
		bne-	ppctimer

		stw	r4,0(r3)
		stw	r5,4(r3)
		blr
.ppctimer_end:
	.size	ppctimer,.ppctimer_end-ppctimer
