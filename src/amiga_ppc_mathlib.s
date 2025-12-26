# Copyright (C) 2000 Peter McGavin.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
#
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

########################################################################
		.section	".text"

		.align	2
		.globl	Length
		.globl	_Length
		.type	Length,@function
		.type	_Length,@function

Length:
_Length:
		lfs	f0,4(r3)	# f0 = v[1]
		fmuls	f0,f0,f0	# f0 = v[1]*v[1]
		lfs	f13,0(r3)	# f13 = v[0]
		lfs	f12,8(r3)	# f12 = v[2]
		fmadds	f13,f13,f13,f0	# f13 = v[0]*v[0] + f0
		fmadds	f1,f12,f12,f13	# f1 = v[2]*v[2] + f13
#		b	sqrt
.Length_end:
		.size			Length,.Length_end-Length

# No blr !!   Drop thru to sqrt !!

########################################################################
		.section	".rodata"
		.align	2
.consts:
		.long	0x3f000000	# 0.5
		.long	0x3f800000	# 1.0

		.section	".text"

		.align	2
		.globl	sqrt
		.globl	_sqrt
		.type	sqrt,@function
		.type	_sqrt,@function

sqrt:
_sqrt:

# Returns approx sqrt(f1) in f1.
# Accurate to about 1 part in 1000.
# Preserve the following registers: r3, r4, f10, f11, f12
# Also return 0.0 in f2 and 1.0 in f3

		fsubs	f2,f1,f1	# f2 = 0.0
		lis	r9,.consts@ha
		fcmpu	cr0,f1,f2	# f1 <= 0.0?
		la	r9,.consts@l(r9)
		ble-	.end
		frsqrte	f9,f1		# f9 ~ 1.0 / sqrt(f1)
		lfs	f3,4(r9)	# f3 = 1.0
		lfs	f7,0(r9)	# f7 = 0.5
		fdivs	f8,f3,f9	# f8 = 1.0 / f9
		fmadds	f9,f1,f9,f8	# f9 = f1 * f9 + f8
		fmuls	f1,f7,f9	# f1 = 0.5 * f9

# To get accuracy to 1 part in 1000000, replace the previous fmuls with
# the following:
#		fmuls	f9,f7,f9	# f9 *= 0.5
#		fmuls	f8,f7,f9	# f8 = 0.5 * f9
#		fdivs	f9,f1,f9	# f9 = f1 / f9
#		fmadds	f1,f7,f9,f8	# f1 = 0.5 * f9 + f8
.end:
		blr
.sqrt_end:
		.size			sqrt,.sqrt_end-sqrt

########################################################################
		.section	".rodata"
		.align	2
.one:
		.long	0x3f800000	# 1.0

		.section	".text"

		.align	2
		.globl	VectorNormalize
		.globl	_VectorNormalize
		.type	VectorNormalize,@function
		.type	_VectorNormalize,@function

VectorNormalize:
_VectorNormalize:

# float VectorNormalize (vec3_t v)
# {
#   float length, ilength;
#
#   length = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];
#   length = sqrt (length);
#   if (length) {
#     ilength = 1/length;
#     v[0] *= ilength;
#     v[1] *= ilength;
#     v[2] *= ilength;
#   }
#   return length;
# }

		mflr	r4

		lfs	f10,0(r3)	# f10 = v[0]
		lfs	f11,4(r3)	# f11 = v[1]
		lfs	f12,8(r3)	# f12 = v[2]
		fmuls	f1,f10,f10	# f1 = v[0]*v[0]
		fmadds	f1,f11,f11,f1	# f1 = v[1]*v[1] + f1
		fmadds	f1,f12,f12,f1	# f1 = v[2]*v[2] + f1

		bl	sqrt		# f1 = sqrt(f1), f2 = 0.0, f3 = 1.0

		fcmpu	cr0,f1,f2
		mtlr	r4
		ble-	.skip

		fdivs	f0,f3,f1	# ilength = 1.0 / length
		fmuls	f10,f10,f0	# f10 *= ilength
		fmuls	f11,f11,f0	# f11 *= ilength
		fmuls	f12,f12,f0	# f12 *= ilength
		stfs	f10,0(r3)	# v[0] = f10
		stfs	f11,4(r3)	# v[1] = f11
		stfs	f12,8(r3)	# v[2] = f12
.skip:
		blr
.VectorNormalize_end:
		.size			VectorNormalize,.VectorNormalize_end-VectorNormalize
