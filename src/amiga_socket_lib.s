
	.text

	.global	SocketBase
	.global	PPCCallOS

	.global	accept
	.type	accept,@function
	.align	3
accept:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	5,72(1)
	stw	3,36(1)
	li	11,-48
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.accept_end:
	.size	accept,.accept_end-accept

	.global	bind
	.type	bind,@function
	.align	3
bind:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	li	11,-36
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.bind_end:
	.size	bind,.bind_end-bind

	.global	CloseSocket
	.type	CloseSocket,@function
	.align	3
CloseSocket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	li	11,-120
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.CloseSocket_end:
	.size	CloseSocket,.CloseSocket_end-CloseSocket

	.global	connect
	.type	connect,@function
	.align	3
connect:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	li	11,-54
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.connect_end:
	.size	connect,.connect_end-connect

	.global	Dup2Socket
	.type	Dup2Socket,@function
	.align	3
Dup2Socket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-264
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Dup2Socket_end:
	.size	Dup2Socket,.Dup2Socket_end-Dup2Socket

	.global	Errno
	.type	Errno,@function
	.align	3
Errno:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	li	11,-162
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Errno_end:
	.size	Errno,.Errno_end-Errno

	.global	getdtablesize
	.type	getdtablesize,@function
	.align	3
getdtablesize:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	li	11,-138
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getdtablesize_end:
	.size	getdtablesize,.getdtablesize_end-getdtablesize

	.global	gethostbyaddr
	.type	gethostbyaddr,@function
	.align	3
gethostbyaddr:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	stw	4,36(1)
	stw	5,40(1)
	li	11,-216
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.gethostbyaddr_end:
	.size	gethostbyaddr,.gethostbyaddr_end-gethostbyaddr

	.global	gethostbyname
	.type	gethostbyname,@function
	.align	3
gethostbyname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-210
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.gethostbyname_end:
	.size	gethostbyname,.gethostbyname_end-gethostbyname

	.global	gethostid
	.type	gethostid,@function
	.align	3
gethostid:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	li	11,-288
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.gethostid_end:
	.size	gethostid,.gethostid_end-gethostid

	.global	gethostname
	.type	gethostname,@function
	.align	3
gethostname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	stw	4,36(1)
	li	11,-282
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.gethostname_end:
	.size	gethostname,.gethostname_end-gethostname

	.global	getnetbyaddr
	.type	getnetbyaddr,@function
	.align	3
getnetbyaddr:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-228
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getnetbyaddr_end:
	.size	getnetbyaddr,.getnetbyaddr_end-getnetbyaddr

	.global	getnetbyname
	.type	getnetbyname,@function
	.align	3
getnetbyname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-222
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getnetbyname_end:
	.size	getnetbyname,.getnetbyname_end-getnetbyname

	.global	getpeername
	.type	getpeername,@function
	.align	3
getpeername:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	5,72(1)
	stw	3,36(1)
	li	11,-108
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getpeername_end:
	.size	getpeername,.getpeername_end-getpeername

	.global	getprotobyname
	.type	getprotobyname,@function
	.align	3
getprotobyname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-246
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getprotobyname_end:
	.size	getprotobyname,.getprotobyname_end-getprotobyname

	.global	getprotobynumber
	.type	getprotobynumber,@function
	.align	3
getprotobynumber:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	li	11,-252
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getprotobynumber_end:
	.size	getprotobynumber,.getprotobynumber_end-getprotobynumber

	.global	getservbyname
	.type	getservbyname,@function
	.align	3
getservbyname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	stw	4,72(1)
	li	11,-234
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getservbyname_end:
	.size	getservbyname,.getservbyname_end-getservbyname

	.global	getservbyport
	.type	getservbyport,@function
	.align	3
getservbyport:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	li	11,-240
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getservbyport_end:
	.size	getservbyport,.getservbyport_end-getservbyport

	.global	GetSocketEvents
	.type	GetSocketEvents,@function
	.align	3
GetSocketEvents:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-300
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.GetSocketEvents_end:
	.size	GetSocketEvents,.GetSocketEvents_end-GetSocketEvents

	.global	getsockname
	.type	getsockname,@function
	.align	3
getsockname:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	5,72(1)
	stw	3,36(1)
	li	11,-102
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getsockname_end:
	.size	getsockname,.getsockname_end-getsockname

	.global	getsockopt
	.type	getsockopt,@function
	.align	3
getsockopt:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	6,68(1)
	stw	7,72(1)
	stw	3,36(1)
	stw	4,40(1)
	stw	5,44(1)
	li	11,-96
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.getsockopt_end:
	.size	getsockopt,.getsockopt_end-getsockopt

	.global	inet_addr
	.type	inet_addr,@function
	.align	3
inet_addr:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-180
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.inet_addr_end:
	.size	inet_addr,.inet_addr_end-inet_addr

	.global	Inet_LnaOf
	.type	Inet_LnaOf,@function
	.align	3
Inet_LnaOf:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	li	11,-186
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Inet_LnaOf_end:
	.size	Inet_LnaOf,.Inet_LnaOf_end-Inet_LnaOf

	.global	Inet_MakeAddr
	.type	Inet_MakeAddr,@function
	.align	3
Inet_MakeAddr:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-198
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Inet_MakeAddr_end:
	.size	Inet_MakeAddr,.Inet_MakeAddr_end-Inet_MakeAddr

	.global	Inet_NetOf
	.type	Inet_NetOf,@function
	.align	3
Inet_NetOf:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	li	11,-192
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Inet_NetOf_end:
	.size	Inet_NetOf,.Inet_NetOf_end-Inet_NetOf

	.global	inet_network
	.type	inet_network,@function
	.align	3
inet_network:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-204
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.inet_network_end:
	.size	inet_network,.inet_network_end-inet_network

	.global	Inet_Nto
	.type	Inet_Nto,@function
	.align	3
Inet_Nto:
	stwu	1,-128(1)
	mflr	11
	stw	11,100(1)
	lwz	11,128(1)
	stw	11,96(1)
	stw	3,104(1)
	stw	4,108(1)
	stw	5,112(1)
	stw	6,116(1)
	stw	7,120(1)
	stw	8,124(1)
	stw	9,128(1)
	stw	10,132(1)
	addi	11,1,104
	stw	11,36(1)
	li	11,-174
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,96(1)
	stw	11,128(1)
	lwz	11,100(1)
	mtlr	11
	addi	1,1,128
	blr
.Inet_Nto_end:
	.size	Inet_Nto,.Inet_Nto_end-Inet_Nto

	.global	Inet_NtoA
	.type	Inet_NtoA,@function
	.align	3
Inet_NtoA:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	li	11,-174
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.Inet_NtoA_end:
	.size	Inet_NtoA,.Inet_NtoA_end-Inet_NtoA

	.global	IoctlSocket
	.type	IoctlSocket,@function
	.align	3
IoctlSocket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	5,68(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-114
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.IoctlSocket_end:
	.size	IoctlSocket,.IoctlSocket_end-IoctlSocket

	.global	listen
	.type	listen,@function
	.align	3
listen:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-42
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.listen_end:
	.size	listen,.listen_end-listen

	.global	ObtainSocket
	.type	ObtainSocket,@function
	.align	3
ObtainSocket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	stw	5,44(1)
	stw	6,48(1)
	li	11,-144
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.ObtainSocket_end:
	.size	ObtainSocket,.ObtainSocket_end-ObtainSocket

	.global	recv
	.type	recv,@function
	.align	3
recv:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	stw	6,44(1)
	li	11,-78
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.recv_end:
	.size	recv,.recv_end-recv

	.global	recvfrom
	.type	recvfrom,@function
	.align	3
recvfrom:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	7,72(1)
	stw	8,76(1)
	stw	3,36(1)
	stw	5,40(1)
	stw	6,44(1)
	li	11,-72
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.recvfrom_end:
	.size	recvfrom,.recvfrom_end-recvfrom

	.global	recvmsg
	.type	recvmsg,@function
	.align	3
recvmsg:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	li	11,-276
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.recvmsg_end:
	.size	recvmsg,.recvmsg_end-recvmsg

	.global	ReleaseCopyOfSocket
	.type	ReleaseCopyOfSocket,@function
	.align	3
ReleaseCopyOfSocket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-156
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.ReleaseCopyOfSocket_end:
	.size	ReleaseCopyOfSocket,.ReleaseCopyOfSocket_end-ReleaseCopyOfSocket

	.global	ReleaseSocket
	.type	ReleaseSocket,@function
	.align	3
ReleaseSocket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-150
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.ReleaseSocket_end:
	.size	ReleaseSocket,.ReleaseSocket_end-ReleaseSocket

	.global	send
	.type	send,@function
	.align	3
send:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	stw	6,44(1)
	li	11,-66
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.send_end:
	.size	send,.send_end-send

	.global	sendmsg
	.type	sendmsg,@function
	.align	3
sendmsg:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	3,36(1)
	stw	5,40(1)
	li	11,-270
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.sendmsg_end:
	.size	sendmsg,.sendmsg_end-sendmsg

	.global	sendto
	.type	sendto,@function
	.align	3
sendto:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	7,72(1)
	stw	3,36(1)
	stw	5,40(1)
	stw	6,44(1)
	stw	8,48(1)
	li	11,-60
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.sendto_end:
	.size	sendto,.sendto_end-sendto

	.global	SetErrnoPtr
	.type	SetErrnoPtr,@function
	.align	3
SetErrnoPtr:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	stw	4,36(1)
	li	11,-168
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.SetErrnoPtr_end:
	.size	SetErrnoPtr,.SetErrnoPtr_end-SetErrnoPtr

	.global	SetSocketSignals
	.type	SetSocketSignals,@function
	.align	3
SetSocketSignals:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	stw	5,44(1)
	li	11,-132
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.SetSocketSignals_end:
	.size	SetSocketSignals,.SetSocketSignals_end-SetSocketSignals

	.global	setsockopt
	.type	setsockopt,@function
	.align	3
setsockopt:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	6,68(1)
	stw	3,36(1)
	stw	4,40(1)
	stw	5,44(1)
	stw	7,48(1)
	li	11,-90
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.setsockopt_end:
	.size	setsockopt,.setsockopt_end-setsockopt

	.global	shutdown
	.type	shutdown,@function
	.align	3
shutdown:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	li	11,-84
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.shutdown_end:
	.size	shutdown,.shutdown_end-shutdown

	.global	socket
	.type	socket,@function
	.align	3
socket:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,36(1)
	stw	4,40(1)
	stw	5,44(1)
	li	11,-30
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.socket_end:
	.size	socket,.socket_end-socket

	.global	SocketBaseTagList
	.type	SocketBaseTagList,@function
	.align	3
SocketBaseTagList:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	3,68(1)
	li	11,-294
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.SocketBaseTagList_end:
	.size	SocketBaseTagList,.SocketBaseTagList_end-SocketBaseTagList

	.global	SocketBaseTags
	.type	SocketBaseTags,@function
	.align	3
SocketBaseTags:
	stwu	1,-128(1)
	mflr	11
	stw	11,100(1)
	lwz	11,128(1)
	stw	11,96(1)
	stw	3,104(1)
	stw	4,108(1)
	stw	5,112(1)
	stw	6,116(1)
	stw	7,120(1)
	stw	8,124(1)
	stw	9,128(1)
	stw	10,132(1)
	addi	11,1,104
	stw	11,68(1)
	li	11,-294
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,96(1)
	stw	11,128(1)
	lwz	11,100(1)
	mtlr	11
	addi	1,1,128
	blr
.SocketBaseTags_end:
	.size	SocketBaseTags,.SocketBaseTags_end-SocketBaseTags

	.global	vsyslog
	.type	vsyslog,@function
	.align	3
vsyslog:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	5,72(1)
	stw	3,36(1)
	li	11,-258
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.vsyslog_end:
	.size	vsyslog,.vsyslog_end-vsyslog

	.global	WaitSelect
	.type	WaitSelect,@function
WaitSelect:
	stwu	1,-96(1)
	mflr	11
	stw	11,100(1)
	stw	4,68(1)
	stw	5,72(1)
	stw	6,76(1)
	stw	7,80(1)
	stw	3,36(1)
	stw	8,40(1)
	li	11,-126
	stw	11,8(1)
	li	11,1
	stw	11,12(1)
	stw	11,24(1)
	lis	11,SocketBase@ha
	lwz	11,SocketBase@l(11)
	stw	11,92(1)
	addi	3,1,8
	bl	PPCCallOS
	lwz	11,100(1)
	mtlr	11
	addi	1,1,96
	blr
.WaitSelect_end:
	.size	WaitSelect,.WaitSelect_end-WaitSelect
