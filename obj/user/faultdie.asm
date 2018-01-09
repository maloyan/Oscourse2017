
obj/user/faultdie:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
#ifndef CONFIG_KSPACE
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 7f ee    	cmp    $0xee7fe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>
#endif

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n",(uint32_t) addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 c0 1e 80 00       	push   $0x801ec0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 6f 0a 00 00       	call   800ac3 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 26 0a 00 00       	call   800a82 <sys_env_destroy>
  80005c:	83 c4 10             	add    $0x10,%esp
}
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 a0 0c 00 00       	call   800d11 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
  80007b:	83 c4 10             	add    $0x10,%esp
}
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80008b:	e8 33 0a 00 00       	call   800ac3 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 78             	imul   $0x78,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
  8000bc:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 a3 0e 00 00       	call   800f74 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a7 09 00 00       	call   800a82 <sys_env_destroy>
  8000db:	83 c4 10             	add    $0x10,%esp
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 35 09 00 00       	call   800a45 <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 4f 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 da 08 00 00       	call   800a45 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 d1                	mov    %edx,%ecx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b2:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001b5:	72 05                	jb     8001bc <printnum+0x35>
  8001b7:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001ba:	77 3e                	ja     8001fa <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 18             	pushl  0x18(%ebp)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	50                   	push   %eax
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 25 1a 00 00       	call   801c00 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 13                	jmp    800201 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7f ed                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 17 1b 00 00       	call   801d30 <__umoddi3>
  800219:	83 c4 14             	add    $0x14,%esp
  80021c:	0f be 80 e6 1e 80 00 	movsbl 0x801ee6(%eax),%eax
  800223:	50                   	push   %eax
  800224:	ff d7                	call   *%edi
  800226:	83 c4 10             	add    $0x10,%esp
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800234:	83 fa 01             	cmp    $0x1,%edx
  800237:	7e 0e                	jle    800247 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	8b 52 04             	mov    0x4(%edx),%edx
  800245:	eb 22                	jmp    800269 <getuint+0x38>
	else if (lflag)
  800247:	85 d2                	test   %edx,%edx
  800249:	74 10                	je     80025b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80024b:	8b 10                	mov    (%eax),%edx
  80024d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800250:	89 08                	mov    %ecx,(%eax)
  800252:	8b 02                	mov    (%edx),%eax
  800254:	ba 00 00 00 00       	mov    $0x0,%edx
  800259:	eb 0e                	jmp    800269 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
  8002a0:	83 c4 10             	add    $0x10,%esp
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 8d 03 00 00    	je     80064e <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 c8             	movzbl %al,%ecx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 1e 03 00 00    	ja     800633 <vprintfmt+0x38e>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80033d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800340:	83 fa 09             	cmp    $0x9,%edx
  800343:	77 38                	ja     80037d <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 48 04             	lea    0x4(%eax),%ecx
  800350:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800353:	8b 00                	mov    (%eax),%eax
  800355:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035b:	eb 26                	jmp    800383 <vprintfmt+0xde>
  80035d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800360:	89 c8                	mov    %ecx,%eax
  800362:	c1 f8 1f             	sar    $0x1f,%eax
  800365:	f7 d0                	not    %eax
  800367:	21 c1                	and    %eax,%ecx
  800369:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036f:	eb 8d                	jmp    8002fe <vprintfmt+0x59>
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800374:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037b:	eb 81                	jmp    8002fe <vprintfmt+0x59>
  80037d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800380:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800383:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800387:	0f 89 71 ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  80038d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800390:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800393:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039a:	e9 5f ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a5:	e9 54 ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 50 04             	lea    0x4(%eax),%edx
  8003b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b3:	83 ec 08             	sub    $0x8,%esp
  8003b6:	53                   	push   %ebx
  8003b7:	ff 30                	pushl  (%eax)
  8003b9:	ff d6                	call   *%esi
			break;
  8003bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c1:	e9 05 ff ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	99                   	cltd   
  8003d2:	31 d0                	xor    %edx,%eax
  8003d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d6:	83 f8 0f             	cmp    $0xf,%eax
  8003d9:	7f 0b                	jg     8003e6 <vprintfmt+0x141>
  8003db:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8003e2:	85 d2                	test   %edx,%edx
  8003e4:	75 18                	jne    8003fe <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8003e6:	50                   	push   %eax
  8003e7:	68 fe 1e 80 00       	push   $0x801efe
  8003ec:	53                   	push   %ebx
  8003ed:	56                   	push   %esi
  8003ee:	e8 95 fe ff ff       	call   800288 <printfmt>
  8003f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f9:	e9 cd fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003fe:	52                   	push   %edx
  8003ff:	68 61 23 80 00       	push   $0x802361
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 7d fe ff ff       	call   800288 <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800411:	e9 b5 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
  800416:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800419:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041c:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 38                	mov    (%eax),%edi
  80042a:	85 ff                	test   %edi,%edi
  80042c:	75 05                	jne    800433 <vprintfmt+0x18e>
				p = "(null)";
  80042e:	bf f7 1e 80 00       	mov    $0x801ef7,%edi
			if (width > 0 && padc != '-')
  800433:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800437:	0f 84 91 00 00 00    	je     8004ce <vprintfmt+0x229>
  80043d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800441:	0f 8e 95 00 00 00    	jle    8004dc <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	51                   	push   %ecx
  80044b:	57                   	push   %edi
  80044c:	e8 85 02 00 00       	call   8006d6 <strnlen>
  800451:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1d4>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c5>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	89 c8                	mov    %ecx,%eax
  800485:	c1 f8 1f             	sar    $0x1f,%eax
  800488:	f7 d0                	not    %eax
  80048a:	21 c8                	and    %ecx,%eax
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 75 08             	mov    %esi,0x8(%ebp)
  800491:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800494:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800497:	89 cb                	mov    %ecx,%ebx
  800499:	eb 4d                	jmp    8004e8 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049f:	74 1b                	je     8004bc <vprintfmt+0x217>
  8004a1:	0f be c0             	movsbl %al,%eax
  8004a4:	83 e8 20             	sub    $0x20,%eax
  8004a7:	83 f8 5e             	cmp    $0x5e,%eax
  8004aa:	76 10                	jbe    8004bc <vprintfmt+0x217>
					putch('?', putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	ff 75 0c             	pushl  0xc(%ebp)
  8004b2:	6a 3f                	push   $0x3f
  8004b4:	ff 55 08             	call   *0x8(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb 0d                	jmp    8004c9 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	ff 75 0c             	pushl  0xc(%ebp)
  8004c2:	52                   	push   %edx
  8004c3:	ff 55 08             	call   *0x8(%ebp)
  8004c6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c9:	83 eb 01             	sub    $0x1,%ebx
  8004cc:	eb 1a                	jmp    8004e8 <vprintfmt+0x243>
  8004ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004da:	eb 0c                	jmp    8004e8 <vprintfmt+0x243>
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e8:	83 c7 01             	add    $0x1,%edi
  8004eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ef:	0f be d0             	movsbl %al,%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	74 23                	je     800519 <vprintfmt+0x274>
  8004f6:	85 f6                	test   %esi,%esi
  8004f8:	78 a1                	js     80049b <vprintfmt+0x1f6>
  8004fa:	83 ee 01             	sub    $0x1,%esi
  8004fd:	79 9c                	jns    80049b <vprintfmt+0x1f6>
  8004ff:	89 df                	mov    %ebx,%edi
  800501:	8b 75 08             	mov    0x8(%ebp),%esi
  800504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800507:	eb 18                	jmp    800521 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	6a 20                	push   $0x20
  80050f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800511:	83 ef 01             	sub    $0x1,%edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb 08                	jmp    800521 <vprintfmt+0x27c>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	85 ff                	test   %edi,%edi
  800523:	7f e4                	jg     800509 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	e9 9e fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052d:	83 fa 01             	cmp    $0x1,%edx
  800530:	7e 16                	jle    800548 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 08             	lea    0x8(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 50 04             	mov    0x4(%eax),%edx
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800546:	eb 32                	jmp    80057a <vprintfmt+0x2d5>
	else if (lflag)
  800548:	85 d2                	test   %edx,%edx
  80054a:	74 18                	je     800564 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 c1                	mov    %eax,%ecx
  80055c:	c1 f9 1f             	sar    $0x1f,%ecx
  80055f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800562:	eb 16                	jmp    80057a <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800572:	89 c1                	mov    %eax,%ecx
  800574:	c1 f9 1f             	sar    $0x1f,%ecx
  800577:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800580:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800585:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800589:	79 74                	jns    8005ff <vprintfmt+0x35a>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800596:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800599:	f7 d8                	neg    %eax
  80059b:	83 d2 00             	adc    $0x0,%edx
  80059e:	f7 da                	neg    %edx
  8005a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a8:	eb 55                	jmp    8005ff <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ad:	e8 7f fc ff ff       	call   800231 <getuint>
			base = 10;
  8005b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b7:	eb 46                	jmp    8005ff <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	e8 70 fc ff ff       	call   800231 <getuint>
			base = 8;
  8005c1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c6:	eb 37                	jmp    8005ff <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 30                	push   $0x30
  8005ce:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d0:	83 c4 08             	add    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 78                	push   $0x78
  8005d6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005eb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f0:	eb 0d                	jmp    8005ff <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 37 fc ff ff       	call   800231 <getuint>
			base = 16;
  8005fa:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800606:	57                   	push   %edi
  800607:	ff 75 e0             	pushl  -0x20(%ebp)
  80060a:	51                   	push   %ecx
  80060b:	52                   	push   %edx
  80060c:	50                   	push   %eax
  80060d:	89 da                	mov    %ebx,%edx
  80060f:	89 f0                	mov    %esi,%eax
  800611:	e8 71 fb ff ff       	call   800187 <printnum>
			break;
  800616:	83 c4 20             	add    $0x20,%esp
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061c:	e9 aa fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	51                   	push   %ecx
  800626:	ff d6                	call   *%esi
			break;
  800628:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062e:	e9 98 fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 25                	push   $0x25
  800639:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	eb 03                	jmp    800643 <vprintfmt+0x39e>
  800640:	83 ef 01             	sub    $0x1,%edi
  800643:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800647:	75 f7                	jne    800640 <vprintfmt+0x39b>
  800649:	e9 7d fc ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	83 ec 18             	sub    $0x18,%esp
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800662:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800665:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800669:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800673:	85 c0                	test   %eax,%eax
  800675:	74 26                	je     80069d <vsnprintf+0x47>
  800677:	85 d2                	test   %edx,%edx
  800679:	7e 22                	jle    80069d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067b:	ff 75 14             	pushl  0x14(%ebp)
  80067e:	ff 75 10             	pushl  0x10(%ebp)
  800681:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	68 6b 02 80 00       	push   $0x80026b
  80068a:	e8 16 fc ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800692:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb 05                	jmp    8006a2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ad:	50                   	push   %eax
  8006ae:	ff 75 10             	pushl  0x10(%ebp)
  8006b1:	ff 75 0c             	pushl  0xc(%ebp)
  8006b4:	ff 75 08             	pushl  0x8(%ebp)
  8006b7:	e8 9a ff ff ff       	call   800656 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c9:	eb 03                	jmp    8006ce <strlen+0x10>
		n++;
  8006cb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d2:	75 f7                	jne    8006cb <strlen+0xd>
		n++;
	return n;
}
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e4:	eb 03                	jmp    8006e9 <strnlen+0x13>
		n++;
  8006e6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e9:	39 c2                	cmp    %eax,%edx
  8006eb:	74 08                	je     8006f5 <strnlen+0x1f>
  8006ed:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f1:	75 f3                	jne    8006e6 <strnlen+0x10>
  8006f3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800701:	89 c2                	mov    %eax,%edx
  800703:	83 c2 01             	add    $0x1,%edx
  800706:	83 c1 01             	add    $0x1,%ecx
  800709:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800710:	84 db                	test   %bl,%bl
  800712:	75 ef                	jne    800703 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800714:	5b                   	pop    %ebx
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071e:	53                   	push   %ebx
  80071f:	e8 9a ff ff ff       	call   8006be <strlen>
  800724:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	01 d8                	add    %ebx,%eax
  80072c:	50                   	push   %eax
  80072d:	e8 c5 ff ff ff       	call   8006f7 <strcpy>
	return dst;
}
  800732:	89 d8                	mov    %ebx,%eax
  800734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	56                   	push   %esi
  80073d:	53                   	push   %ebx
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800744:	89 f3                	mov    %esi,%ebx
  800746:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800749:	89 f2                	mov    %esi,%edx
  80074b:	eb 0f                	jmp    80075c <strncpy+0x23>
		*dst++ = *src;
  80074d:	83 c2 01             	add    $0x1,%edx
  800750:	0f b6 01             	movzbl (%ecx),%eax
  800753:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800756:	80 39 01             	cmpb   $0x1,(%ecx)
  800759:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075c:	39 da                	cmp    %ebx,%edx
  80075e:	75 ed                	jne    80074d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800760:	89 f0                	mov    %esi,%eax
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800771:	8b 55 10             	mov    0x10(%ebp),%edx
  800774:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800776:	85 d2                	test   %edx,%edx
  800778:	74 21                	je     80079b <strlcpy+0x35>
  80077a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077e:	89 f2                	mov    %esi,%edx
  800780:	eb 09                	jmp    80078b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078b:	39 c2                	cmp    %eax,%edx
  80078d:	74 09                	je     800798 <strlcpy+0x32>
  80078f:	0f b6 19             	movzbl (%ecx),%ebx
  800792:	84 db                	test   %bl,%bl
  800794:	75 ec                	jne    800782 <strlcpy+0x1c>
  800796:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800798:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079b:	29 f0                	sub    %esi,%eax
}
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007aa:	eb 06                	jmp    8007b2 <strcmp+0x11>
		p++, q++;
  8007ac:	83 c1 01             	add    $0x1,%ecx
  8007af:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	84 c0                	test   %al,%al
  8007b7:	74 04                	je     8007bd <strcmp+0x1c>
  8007b9:	3a 02                	cmp    (%edx),%al
  8007bb:	74 ef                	je     8007ac <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bd:	0f b6 c0             	movzbl %al,%eax
  8007c0:	0f b6 12             	movzbl (%edx),%edx
  8007c3:	29 d0                	sub    %edx,%eax
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	89 c3                	mov    %eax,%ebx
  8007d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d6:	eb 06                	jmp    8007de <strncmp+0x17>
		n--, p++, q++;
  8007d8:	83 c0 01             	add    $0x1,%eax
  8007db:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007de:	39 d8                	cmp    %ebx,%eax
  8007e0:	74 15                	je     8007f7 <strncmp+0x30>
  8007e2:	0f b6 08             	movzbl (%eax),%ecx
  8007e5:	84 c9                	test   %cl,%cl
  8007e7:	74 04                	je     8007ed <strncmp+0x26>
  8007e9:	3a 0a                	cmp    (%edx),%cl
  8007eb:	74 eb                	je     8007d8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 00             	movzbl (%eax),%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
  8007f5:	eb 05                	jmp    8007fc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800809:	eb 07                	jmp    800812 <strchr+0x13>
		if (*s == c)
  80080b:	38 ca                	cmp    %cl,%dl
  80080d:	74 0f                	je     80081e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	0f b6 10             	movzbl (%eax),%edx
  800815:	84 d2                	test   %dl,%dl
  800817:	75 f2                	jne    80080b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082a:	eb 03                	jmp    80082f <strfind+0xf>
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800832:	84 d2                	test   %dl,%dl
  800834:	74 04                	je     80083a <strfind+0x1a>
  800836:	38 ca                	cmp    %cl,%dl
  800838:	75 f2                	jne    80082c <strfind+0xc>
			break;
	return (char *) s;
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	57                   	push   %edi
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 7d 08             	mov    0x8(%ebp),%edi
  800845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 36                	je     800882 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800852:	75 28                	jne    80087c <memset+0x40>
  800854:	f6 c1 03             	test   $0x3,%cl
  800857:	75 23                	jne    80087c <memset+0x40>
		c &= 0xFF;
  800859:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085d:	89 d3                	mov    %edx,%ebx
  80085f:	c1 e3 08             	shl    $0x8,%ebx
  800862:	89 d6                	mov    %edx,%esi
  800864:	c1 e6 18             	shl    $0x18,%esi
  800867:	89 d0                	mov    %edx,%eax
  800869:	c1 e0 10             	shl    $0x10,%eax
  80086c:	09 f0                	or     %esi,%eax
  80086e:	09 c2                	or     %eax,%edx
  800870:	89 d0                	mov    %edx,%eax
  800872:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800874:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800877:	fc                   	cld    
  800878:	f3 ab                	rep stos %eax,%es:(%edi)
  80087a:	eb 06                	jmp    800882 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	fc                   	cld    
  800880:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800882:	89 f8                	mov    %edi,%eax
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	57                   	push   %edi
  80088d:	56                   	push   %esi
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 75 0c             	mov    0xc(%ebp),%esi
  800894:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800897:	39 c6                	cmp    %eax,%esi
  800899:	73 35                	jae    8008d0 <memmove+0x47>
  80089b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089e:	39 d0                	cmp    %edx,%eax
  8008a0:	73 2e                	jae    8008d0 <memmove+0x47>
		s += n;
		d += n;
  8008a2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008a5:	89 d6                	mov    %edx,%esi
  8008a7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008af:	75 13                	jne    8008c4 <memmove+0x3b>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 0e                	jne    8008c4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b6:	83 ef 04             	sub    $0x4,%edi
  8008b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 09                	jmp    8008cd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c4:	83 ef 01             	sub    $0x1,%edi
  8008c7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ca:	fd                   	std    
  8008cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cd:	fc                   	cld    
  8008ce:	eb 1d                	jmp    8008ed <memmove+0x64>
  8008d0:	89 f2                	mov    %esi,%edx
  8008d2:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	f6 c2 03             	test   $0x3,%dl
  8008d7:	75 0f                	jne    8008e8 <memmove+0x5f>
  8008d9:	f6 c1 03             	test   $0x3,%cl
  8008dc:	75 0a                	jne    8008e8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008de:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e1:	89 c7                	mov    %eax,%edi
  8008e3:	fc                   	cld    
  8008e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e6:	eb 05                	jmp    8008ed <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e8:	89 c7                	mov    %eax,%edi
  8008ea:	fc                   	cld    
  8008eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f4:	ff 75 10             	pushl  0x10(%ebp)
  8008f7:	ff 75 0c             	pushl  0xc(%ebp)
  8008fa:	ff 75 08             	pushl  0x8(%ebp)
  8008fd:	e8 87 ff ff ff       	call   800889 <memmove>
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800914:	eb 1a                	jmp    800930 <memcmp+0x2c>
		if (*s1 != *s2)
  800916:	0f b6 08             	movzbl (%eax),%ecx
  800919:	0f b6 1a             	movzbl (%edx),%ebx
  80091c:	38 d9                	cmp    %bl,%cl
  80091e:	74 0a                	je     80092a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800920:	0f b6 c1             	movzbl %cl,%eax
  800923:	0f b6 db             	movzbl %bl,%ebx
  800926:	29 d8                	sub    %ebx,%eax
  800928:	eb 0f                	jmp    800939 <memcmp+0x35>
		s1++, s2++;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800930:	39 f0                	cmp    %esi,%eax
  800932:	75 e2                	jne    800916 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800946:	89 c2                	mov    %eax,%edx
  800948:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094b:	eb 07                	jmp    800954 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094d:	38 08                	cmp    %cl,(%eax)
  80094f:	74 07                	je     800958 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	39 d0                	cmp    %edx,%eax
  800956:	72 f5                	jb     80094d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800966:	eb 03                	jmp    80096b <strtol+0x11>
		s++;
  800968:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	3c 09                	cmp    $0x9,%al
  800970:	74 f6                	je     800968 <strtol+0xe>
  800972:	3c 20                	cmp    $0x20,%al
  800974:	74 f2                	je     800968 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800976:	3c 2b                	cmp    $0x2b,%al
  800978:	75 0a                	jne    800984 <strtol+0x2a>
		s++;
  80097a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097d:	bf 00 00 00 00       	mov    $0x0,%edi
  800982:	eb 10                	jmp    800994 <strtol+0x3a>
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800989:	3c 2d                	cmp    $0x2d,%al
  80098b:	75 07                	jne    800994 <strtol+0x3a>
		s++, neg = 1;
  80098d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800990:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800994:	85 db                	test   %ebx,%ebx
  800996:	0f 94 c0             	sete   %al
  800999:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099f:	75 19                	jne    8009ba <strtol+0x60>
  8009a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a4:	75 14                	jne    8009ba <strtol+0x60>
  8009a6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009aa:	0f 85 8a 00 00 00    	jne    800a3a <strtol+0xe0>
		s += 2, base = 16;
  8009b0:	83 c1 02             	add    $0x2,%ecx
  8009b3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b8:	eb 16                	jmp    8009d0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009ba:	84 c0                	test   %al,%al
  8009bc:	74 12                	je     8009d0 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009be:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c6:	75 08                	jne    8009d0 <strtol+0x76>
		s++, base = 8;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	0f b6 11             	movzbl (%ecx),%edx
  8009db:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009de:	89 f3                	mov    %esi,%ebx
  8009e0:	80 fb 09             	cmp    $0x9,%bl
  8009e3:	77 08                	ja     8009ed <strtol+0x93>
			dig = *s - '0';
  8009e5:	0f be d2             	movsbl %dl,%edx
  8009e8:	83 ea 30             	sub    $0x30,%edx
  8009eb:	eb 22                	jmp    800a0f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009ed:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f0:	89 f3                	mov    %esi,%ebx
  8009f2:	80 fb 19             	cmp    $0x19,%bl
  8009f5:	77 08                	ja     8009ff <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009f7:	0f be d2             	movsbl %dl,%edx
  8009fa:	83 ea 57             	sub    $0x57,%edx
  8009fd:	eb 10                	jmp    800a0f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009ff:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 19             	cmp    $0x19,%bl
  800a07:	77 16                	ja     800a1f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a09:	0f be d2             	movsbl %dl,%edx
  800a0c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a12:	7d 0f                	jge    800a23 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1d:	eb b9                	jmp    8009d8 <strtol+0x7e>
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	eb 02                	jmp    800a25 <strtol+0xcb>
  800a23:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a29:	74 05                	je     800a30 <strtol+0xd6>
		*endptr = (char *) s;
  800a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a30:	85 ff                	test   %edi,%edi
  800a32:	74 0c                	je     800a40 <strtol+0xe6>
  800a34:	89 d0                	mov    %edx,%eax
  800a36:	f7 d8                	neg    %eax
  800a38:	eb 06                	jmp    800a40 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3a:	84 c0                	test   %al,%al
  800a3c:	75 8a                	jne    8009c8 <strtol+0x6e>
  800a3e:	eb 90                	jmp    8009d0 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
  800a56:	89 c3                	mov    %eax,%ebx
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	89 c6                	mov    %eax,%esi
  800a5c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a69:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a73:	89 d1                	mov    %edx,%ecx
  800a75:	89 d3                	mov    %edx,%ebx
  800a77:	89 d7                	mov    %edx,%edi
  800a79:	89 d6                	mov    %edx,%esi
  800a7b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a90:	b8 03 00 00 00       	mov    $0x3,%eax
  800a95:	8b 55 08             	mov    0x8(%ebp),%edx
  800a98:	89 cb                	mov    %ecx,%ebx
  800a9a:	89 cf                	mov    %ecx,%edi
  800a9c:	89 ce                	mov    %ecx,%esi
  800a9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	7e 17                	jle    800abb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	50                   	push   %eax
  800aa8:	6a 03                	push   $0x3
  800aaa:	68 1f 22 80 00       	push   $0x80221f
  800aaf:	6a 23                	push   $0x23
  800ab1:	68 3c 22 80 00       	push   $0x80223c
  800ab6:	e8 d2 0f 00 00       	call   801a8d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad3:	89 d1                	mov    %edx,%ecx
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	89 d7                	mov    %edx,%edi
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_yield>:

void
sys_yield(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	be 00 00 00 00       	mov    $0x0,%esi
  800b0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1d:	89 f7                	mov    %esi,%edi
  800b1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 17                	jle    800b3c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	50                   	push   %eax
  800b29:	6a 04                	push   $0x4
  800b2b:	68 1f 22 80 00       	push   $0x80221f
  800b30:	6a 23                	push   $0x23
  800b32:	68 3c 22 80 00       	push   $0x80223c
  800b37:	e8 51 0f 00 00       	call   801a8d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 17                	jle    800b7e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	50                   	push   %eax
  800b6b:	6a 05                	push   $0x5
  800b6d:	68 1f 22 80 00       	push   $0x80221f
  800b72:	6a 23                	push   $0x23
  800b74:	68 3c 22 80 00       	push   $0x80223c
  800b79:	e8 0f 0f 00 00       	call   801a8d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b94:	b8 06 00 00 00       	mov    $0x6,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	89 df                	mov    %ebx,%edi
  800ba1:	89 de                	mov    %ebx,%esi
  800ba3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7e 17                	jle    800bc0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	50                   	push   %eax
  800bad:	6a 06                	push   $0x6
  800baf:	68 1f 22 80 00       	push   $0x80221f
  800bb4:	6a 23                	push   $0x23
  800bb6:	68 3c 22 80 00       	push   $0x80223c
  800bbb:	e8 cd 0e 00 00       	call   801a8d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 17                	jle    800c02 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 08                	push   $0x8
  800bf1:	68 1f 22 80 00       	push   $0x80221f
  800bf6:	6a 23                	push   $0x23
  800bf8:	68 3c 22 80 00       	push   $0x80223c
  800bfd:	e8 8b 0e 00 00       	call   801a8d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 17                	jle    800c44 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 09                	push   $0x9
  800c33:	68 1f 22 80 00       	push   $0x80221f
  800c38:	6a 23                	push   $0x23
  800c3a:	68 3c 22 80 00       	push   $0x80223c
  800c3f:	e8 49 0e 00 00       	call   801a8d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 17                	jle    800c86 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	50                   	push   %eax
  800c73:	6a 0a                	push   $0xa
  800c75:	68 1f 22 80 00       	push   $0x80221f
  800c7a:	6a 23                	push   $0x23
  800c7c:	68 3c 22 80 00       	push   $0x80223c
  800c81:	e8 07 0e 00 00       	call   801a8d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	be 00 00 00 00       	mov    $0x0,%esi
  800c99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800caa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 17                	jle    800cea <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	6a 0d                	push   $0xd
  800cd9:	68 1f 22 80 00       	push   $0x80221f
  800cde:	6a 23                	push   $0x23
  800ce0:	68 3c 22 80 00       	push   $0x80223c
  800ce5:	e8 a3 0d 00 00       	call   801a8d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_gettime>:

int sys_gettime(void)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d02:	89 d1                	mov    %edx,%ecx
  800d04:	89 d3                	mov    %edx,%ebx
  800d06:	89 d7                	mov    %edx,%edi
  800d08:	89 d6                	mov    %edx,%esi
  800d0a:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800d17:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d1e:	75 2c                	jne    800d4c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	6a 07                	push   $0x7
  800d25:	68 00 f0 7f ee       	push   $0xee7ff000
  800d2a:	6a 00                	push   $0x0
  800d2c:	e8 d0 fd ff ff       	call   800b01 <sys_page_alloc>
  800d31:	83 c4 10             	add    $0x10,%esp
  800d34:	85 c0                	test   %eax,%eax
  800d36:	79 14                	jns    800d4c <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800d38:	83 ec 04             	sub    $0x4,%esp
  800d3b:	68 4c 22 80 00       	push   $0x80224c
  800d40:	6a 1f                	push   $0x1f
  800d42:	68 ae 22 80 00       	push   $0x8022ae
  800d47:	e8 41 0d 00 00       	call   801a8d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d54:	83 ec 08             	sub    $0x8,%esp
  800d57:	68 80 0d 80 00       	push   $0x800d80
  800d5c:	6a 00                	push   $0x0
  800d5e:	e8 e9 fe ff ff       	call   800c4c <sys_env_set_pgfault_upcall>
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	85 c0                	test   %eax,%eax
  800d68:	79 14                	jns    800d7e <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 78 22 80 00       	push   $0x802278
  800d72:	6a 25                	push   $0x25
  800d74:	68 ae 22 80 00       	push   $0x8022ae
  800d79:	e8 0f 0d 00 00       	call   801a8d <_panic>
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d80:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d81:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d86:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d88:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  800d8b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  800d8d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  800d91:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  800d95:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  800d96:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  800d99:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  800d9b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  800d9e:	83 c4 04             	add    $0x4,%esp
	popal 
  800da1:	61                   	popa   
	addl $4, %esp 
  800da2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  800da5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  800da6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  800da7:	c3                   	ret    

00800da8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	05 00 00 00 30       	add    $0x30000000,%eax
  800db3:	c1 e8 0c             	shr    $0xc,%eax
}
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800dc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	c1 ea 16             	shr    $0x16,%edx
  800ddf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de6:	f6 c2 01             	test   $0x1,%dl
  800de9:	74 11                	je     800dfc <fd_alloc+0x2d>
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	c1 ea 0c             	shr    $0xc,%edx
  800df0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df7:	f6 c2 01             	test   $0x1,%dl
  800dfa:	75 09                	jne    800e05 <fd_alloc+0x36>
			*fd_store = fd;
  800dfc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800e03:	eb 17                	jmp    800e1c <fd_alloc+0x4d>
  800e05:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e0f:	75 c9                	jne    800dda <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e11:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e17:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e24:	83 f8 1f             	cmp    $0x1f,%eax
  800e27:	77 36                	ja     800e5f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e29:	c1 e0 0c             	shl    $0xc,%eax
  800e2c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	c1 ea 16             	shr    $0x16,%edx
  800e36:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3d:	f6 c2 01             	test   $0x1,%dl
  800e40:	74 24                	je     800e66 <fd_lookup+0x48>
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 0c             	shr    $0xc,%edx
  800e47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	74 1a                	je     800e6d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e56:	89 02                	mov    %eax,(%edx)
	return 0;
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5d:	eb 13                	jmp    800e72 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e64:	eb 0c                	jmp    800e72 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6b:	eb 05                	jmp    800e72 <fd_lookup+0x54>
  800e6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	ba 38 23 80 00       	mov    $0x802338,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e82:	eb 13                	jmp    800e97 <dev_lookup+0x23>
  800e84:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e87:	39 08                	cmp    %ecx,(%eax)
  800e89:	75 0c                	jne    800e97 <dev_lookup+0x23>
			*dev = devtab[i];
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 2e                	jmp    800ec5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e97:	8b 02                	mov    (%edx),%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	75 e7                	jne    800e84 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e9d:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea2:	8b 40 48             	mov    0x48(%eax),%eax
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	51                   	push   %ecx
  800ea9:	50                   	push   %eax
  800eaa:	68 bc 22 80 00       	push   $0x8022bc
  800eaf:	e8 bf f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 10             	sub    $0x10,%esp
  800ecf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800edf:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee2:	50                   	push   %eax
  800ee3:	e8 36 ff ff ff       	call   800e1e <fd_lookup>
  800ee8:	83 c4 08             	add    $0x8,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 05                	js     800ef4 <fd_close+0x2d>
	    || fd != fd2)
  800eef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef2:	74 0b                	je     800eff <fd_close+0x38>
		return (must_exist ? r : 0);
  800ef4:	80 fb 01             	cmp    $0x1,%bl
  800ef7:	19 d2                	sbb    %edx,%edx
  800ef9:	f7 d2                	not    %edx
  800efb:	21 d0                	and    %edx,%eax
  800efd:	eb 41                	jmp    800f40 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f05:	50                   	push   %eax
  800f06:	ff 36                	pushl  (%esi)
  800f08:	e8 67 ff ff ff       	call   800e74 <dev_lookup>
  800f0d:	89 c3                	mov    %eax,%ebx
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 1a                	js     800f30 <fd_close+0x69>
		if (dev->dev_close)
  800f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f19:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	74 0b                	je     800f30 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	56                   	push   %esi
  800f29:	ff d0                	call   *%eax
  800f2b:	89 c3                	mov    %eax,%ebx
  800f2d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	e8 4b fc ff ff       	call   800b86 <sys_page_unmap>
	return r;
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	89 d8                	mov    %ebx,%eax
}
  800f40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	ff 75 08             	pushl  0x8(%ebp)
  800f54:	e8 c5 fe ff ff       	call   800e1e <fd_lookup>
  800f59:	89 c2                	mov    %eax,%edx
  800f5b:	83 c4 08             	add    $0x8,%esp
  800f5e:	85 d2                	test   %edx,%edx
  800f60:	78 10                	js     800f72 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	6a 01                	push   $0x1
  800f67:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6a:	e8 58 ff ff ff       	call   800ec7 <fd_close>
  800f6f:	83 c4 10             	add    $0x10,%esp
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <close_all>:

void
close_all(void)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	53                   	push   %ebx
  800f84:	e8 be ff ff ff       	call   800f47 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f89:	83 c3 01             	add    $0x1,%ebx
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	83 fb 20             	cmp    $0x20,%ebx
  800f92:	75 ec                	jne    800f80 <close_all+0xc>
		close(i);
}
  800f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 2c             	sub    $0x2c,%esp
  800fa2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 08             	pushl  0x8(%ebp)
  800fac:	e8 6d fe ff ff       	call   800e1e <fd_lookup>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	83 c4 08             	add    $0x8,%esp
  800fb6:	85 d2                	test   %edx,%edx
  800fb8:	0f 88 c1 00 00 00    	js     80107f <dup+0xe6>
		return r;
	close(newfdnum);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	56                   	push   %esi
  800fc2:	e8 80 ff ff ff       	call   800f47 <close>

	newfd = INDEX2FD(newfdnum);
  800fc7:	89 f3                	mov    %esi,%ebx
  800fc9:	c1 e3 0c             	shl    $0xc,%ebx
  800fcc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd2:	83 c4 04             	add    $0x4,%esp
  800fd5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd8:	e8 db fd ff ff       	call   800db8 <fd2data>
  800fdd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fdf:	89 1c 24             	mov    %ebx,(%esp)
  800fe2:	e8 d1 fd ff ff       	call   800db8 <fd2data>
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fed:	89 f8                	mov    %edi,%eax
  800fef:	c1 e8 16             	shr    $0x16,%eax
  800ff2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff9:	a8 01                	test   $0x1,%al
  800ffb:	74 37                	je     801034 <dup+0x9b>
  800ffd:	89 f8                	mov    %edi,%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
  801002:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	74 26                	je     801034 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80100e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	25 07 0e 00 00       	and    $0xe07,%eax
  80101d:	50                   	push   %eax
  80101e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801021:	6a 00                	push   $0x0
  801023:	57                   	push   %edi
  801024:	6a 00                	push   $0x0
  801026:	e8 19 fb ff ff       	call   800b44 <sys_page_map>
  80102b:	89 c7                	mov    %eax,%edi
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 2e                	js     801062 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801034:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801037:	89 d0                	mov    %edx,%eax
  801039:	c1 e8 0c             	shr    $0xc,%eax
  80103c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	25 07 0e 00 00       	and    $0xe07,%eax
  80104b:	50                   	push   %eax
  80104c:	53                   	push   %ebx
  80104d:	6a 00                	push   $0x0
  80104f:	52                   	push   %edx
  801050:	6a 00                	push   $0x0
  801052:	e8 ed fa ff ff       	call   800b44 <sys_page_map>
  801057:	89 c7                	mov    %eax,%edi
  801059:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105e:	85 ff                	test   %edi,%edi
  801060:	79 1d                	jns    80107f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	53                   	push   %ebx
  801066:	6a 00                	push   $0x0
  801068:	e8 19 fb ff ff       	call   800b86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	ff 75 d4             	pushl  -0x2c(%ebp)
  801073:	6a 00                	push   $0x0
  801075:	e8 0c fb ff ff       	call   800b86 <sys_page_unmap>
	return r;
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	89 f8                	mov    %edi,%eax
}
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	53                   	push   %ebx
  80108b:	83 ec 14             	sub    $0x14,%esp
  80108e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801091:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	53                   	push   %ebx
  801096:	e8 83 fd ff ff       	call   800e1e <fd_lookup>
  80109b:	83 c4 08             	add    $0x8,%esp
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 6d                	js     801111 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ae:	ff 30                	pushl  (%eax)
  8010b0:	e8 bf fd ff ff       	call   800e74 <dev_lookup>
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 4c                	js     801108 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bf:	8b 42 08             	mov    0x8(%edx),%eax
  8010c2:	83 e0 03             	and    $0x3,%eax
  8010c5:	83 f8 01             	cmp    $0x1,%eax
  8010c8:	75 21                	jne    8010eb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cf:	8b 40 48             	mov    0x48(%eax),%eax
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	50                   	push   %eax
  8010d7:	68 fd 22 80 00       	push   $0x8022fd
  8010dc:	e8 92 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010e9:	eb 26                	jmp    801111 <read+0x8a>
	}
	if (!dev->dev_read)
  8010eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ee:	8b 40 08             	mov    0x8(%eax),%eax
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	74 17                	je     80110c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f5:	83 ec 04             	sub    $0x4,%esp
  8010f8:	ff 75 10             	pushl  0x10(%ebp)
  8010fb:	ff 75 0c             	pushl  0xc(%ebp)
  8010fe:	52                   	push   %edx
  8010ff:	ff d0                	call   *%eax
  801101:	89 c2                	mov    %eax,%edx
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	eb 09                	jmp    801111 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801108:	89 c2                	mov    %eax,%edx
  80110a:	eb 05                	jmp    801111 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801111:	89 d0                	mov    %edx,%eax
  801113:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	57                   	push   %edi
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	8b 7d 08             	mov    0x8(%ebp),%edi
  801124:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801127:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112c:	eb 21                	jmp    80114f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	89 f0                	mov    %esi,%eax
  801133:	29 d8                	sub    %ebx,%eax
  801135:	50                   	push   %eax
  801136:	89 d8                	mov    %ebx,%eax
  801138:	03 45 0c             	add    0xc(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	57                   	push   %edi
  80113d:	e8 45 ff ff ff       	call   801087 <read>
		if (m < 0)
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	78 0c                	js     801155 <readn+0x3d>
			return m;
		if (m == 0)
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 06                	je     801153 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114d:	01 c3                	add    %eax,%ebx
  80114f:	39 f3                	cmp    %esi,%ebx
  801151:	72 db                	jb     80112e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801153:	89 d8                	mov    %ebx,%eax
}
  801155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	53                   	push   %ebx
  801161:	83 ec 14             	sub    $0x14,%esp
  801164:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801167:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116a:	50                   	push   %eax
  80116b:	53                   	push   %ebx
  80116c:	e8 ad fc ff ff       	call   800e1e <fd_lookup>
  801171:	83 c4 08             	add    $0x8,%esp
  801174:	89 c2                	mov    %eax,%edx
  801176:	85 c0                	test   %eax,%eax
  801178:	78 68                	js     8011e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	ff 30                	pushl  (%eax)
  801186:	e8 e9 fc ff ff       	call   800e74 <dev_lookup>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 47                	js     8011d9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801199:	75 21                	jne    8011bc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80119b:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a0:	8b 40 48             	mov    0x48(%eax),%eax
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	53                   	push   %ebx
  8011a7:	50                   	push   %eax
  8011a8:	68 19 23 80 00       	push   $0x802319
  8011ad:	e8 c1 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ba:	eb 26                	jmp    8011e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c2:	85 d2                	test   %edx,%edx
  8011c4:	74 17                	je     8011dd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	ff 75 10             	pushl  0x10(%ebp)
  8011cc:	ff 75 0c             	pushl  0xc(%ebp)
  8011cf:	50                   	push   %eax
  8011d0:	ff d2                	call   *%edx
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	eb 09                	jmp    8011e2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	eb 05                	jmp    8011e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e2:	89 d0                	mov    %edx,%eax
  8011e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	ff 75 08             	pushl  0x8(%ebp)
  8011f6:	e8 23 fc ff ff       	call   800e1e <fd_lookup>
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 0e                	js     801210 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801202:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801205:	8b 55 0c             	mov    0xc(%ebp),%edx
  801208:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	53                   	push   %ebx
  801216:	83 ec 14             	sub    $0x14,%esp
  801219:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	53                   	push   %ebx
  801221:	e8 f8 fb ff ff       	call   800e1e <fd_lookup>
  801226:	83 c4 08             	add    $0x8,%esp
  801229:	89 c2                	mov    %eax,%edx
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 65                	js     801294 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801239:	ff 30                	pushl  (%eax)
  80123b:	e8 34 fc ff ff       	call   800e74 <dev_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 44                	js     80128b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124e:	75 21                	jne    801271 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801250:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	68 dc 22 80 00       	push   $0x8022dc
  801262:	e8 0c ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126f:	eb 23                	jmp    801294 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801271:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801274:	8b 52 18             	mov    0x18(%edx),%edx
  801277:	85 d2                	test   %edx,%edx
  801279:	74 14                	je     80128f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	50                   	push   %eax
  801282:	ff d2                	call   *%edx
  801284:	89 c2                	mov    %eax,%edx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	eb 09                	jmp    801294 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	eb 05                	jmp    801294 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80128f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801294:	89 d0                	mov    %edx,%eax
  801296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 6d fb ff ff       	call   800e1e <fd_lookup>
  8012b1:	83 c4 08             	add    $0x8,%esp
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 58                	js     801312 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	ff 30                	pushl  (%eax)
  8012c6:	e8 a9 fb ff ff       	call   800e74 <dev_lookup>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 37                	js     801309 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012d9:	74 32                	je     80130d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e5:	00 00 00 
	stat->st_isdir = 0;
  8012e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ef:	00 00 00 
	stat->st_dev = dev;
  8012f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ff:	ff 50 14             	call   *0x14(%eax)
  801302:	89 c2                	mov    %eax,%edx
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	eb 09                	jmp    801312 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801309:	89 c2                	mov    %eax,%edx
  80130b:	eb 05                	jmp    801312 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80130d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801312:	89 d0                	mov    %edx,%eax
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	6a 00                	push   $0x0
  801323:	ff 75 08             	pushl  0x8(%ebp)
  801326:	e8 e7 01 00 00       	call   801512 <open>
  80132b:	89 c3                	mov    %eax,%ebx
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 db                	test   %ebx,%ebx
  801332:	78 1b                	js     80134f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	ff 75 0c             	pushl  0xc(%ebp)
  80133a:	53                   	push   %ebx
  80133b:	e8 5b ff ff ff       	call   80129b <fstat>
  801340:	89 c6                	mov    %eax,%esi
	close(fd);
  801342:	89 1c 24             	mov    %ebx,(%esp)
  801345:	e8 fd fb ff ff       	call   800f47 <close>
	return r;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	89 f0                	mov    %esi,%eax
}
  80134f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
  80135b:	89 c6                	mov    %eax,%esi
  80135d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80135f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801366:	75 12                	jne    80137a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	6a 03                	push   $0x3
  80136d:	e8 18 08 00 00       	call   801b8a <ipc_find_env>
  801372:	a3 00 40 80 00       	mov    %eax,0x804000
  801377:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137a:	6a 07                	push   $0x7
  80137c:	68 00 50 80 00       	push   $0x805000
  801381:	56                   	push   %esi
  801382:	ff 35 00 40 80 00    	pushl  0x804000
  801388:	e8 ac 07 00 00       	call   801b39 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80138d:	83 c4 0c             	add    $0xc,%esp
  801390:	6a 00                	push   $0x0
  801392:	53                   	push   %ebx
  801393:	6a 00                	push   $0x0
  801395:	e8 39 07 00 00       	call   801ad3 <ipc_recv>
}
  80139a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c4:	e8 8d ff ff ff       	call   801356 <fsipc>
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e6:	e8 6b ff ff ff       	call   801356 <fsipc>
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 04             	sub    $0x4,%esp
  8013f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 05 00 00 00       	mov    $0x5,%eax
  80140c:	e8 45 ff ff ff       	call   801356 <fsipc>
  801411:	89 c2                	mov    %eax,%edx
  801413:	85 d2                	test   %edx,%edx
  801415:	78 2c                	js     801443 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	68 00 50 80 00       	push   $0x805000
  80141f:	53                   	push   %ebx
  801420:	e8 d2 f2 ff ff       	call   8006f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801425:	a1 80 50 80 00       	mov    0x805080,%eax
  80142a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801430:	a1 84 50 80 00       	mov    0x805084,%eax
  801435:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801451:	8b 55 08             	mov    0x8(%ebp),%edx
  801454:	8b 52 0c             	mov    0xc(%edx),%edx
  801457:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80145d:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801462:	76 05                	jbe    801469 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801464:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801469:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	50                   	push   %eax
  801472:	ff 75 0c             	pushl  0xc(%ebp)
  801475:	68 08 50 80 00       	push   $0x805008
  80147a:	e8 0a f4 ff ff       	call   800889 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 04 00 00 00       	mov    $0x4,%eax
  801489:	e8 c8 fe ff ff       	call   801356 <fsipc>
	return write;
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	8b 40 0c             	mov    0xc(%eax),%eax
  80149e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b3:	e8 9e fe ff ff       	call   801356 <fsipc>
  8014b8:	89 c3                	mov    %eax,%ebx
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 4b                	js     801509 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014be:	39 c6                	cmp    %eax,%esi
  8014c0:	73 16                	jae    8014d8 <devfile_read+0x48>
  8014c2:	68 48 23 80 00       	push   $0x802348
  8014c7:	68 4f 23 80 00       	push   $0x80234f
  8014cc:	6a 7c                	push   $0x7c
  8014ce:	68 64 23 80 00       	push   $0x802364
  8014d3:	e8 b5 05 00 00       	call   801a8d <_panic>
	assert(r <= PGSIZE);
  8014d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014dd:	7e 16                	jle    8014f5 <devfile_read+0x65>
  8014df:	68 6f 23 80 00       	push   $0x80236f
  8014e4:	68 4f 23 80 00       	push   $0x80234f
  8014e9:	6a 7d                	push   $0x7d
  8014eb:	68 64 23 80 00       	push   $0x802364
  8014f0:	e8 98 05 00 00       	call   801a8d <_panic>
	memmove(buf, &fsipcbuf, r);
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	50                   	push   %eax
  8014f9:	68 00 50 80 00       	push   $0x805000
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	e8 83 f3 ff ff       	call   800889 <memmove>
	return r;
  801506:	83 c4 10             	add    $0x10,%esp
}
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	53                   	push   %ebx
  801516:	83 ec 20             	sub    $0x20,%esp
  801519:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151c:	53                   	push   %ebx
  80151d:	e8 9c f1 ff ff       	call   8006be <strlen>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152a:	7f 67                	jg     801593 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	e8 97 f8 ff ff       	call   800dcf <fd_alloc>
  801538:	83 c4 10             	add    $0x10,%esp
		return r;
  80153b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 57                	js     801598 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	53                   	push   %ebx
  801545:	68 00 50 80 00       	push   $0x805000
  80154a:	e8 a8 f1 ff ff       	call   8006f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801552:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801557:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155a:	b8 01 00 00 00       	mov    $0x1,%eax
  80155f:	e8 f2 fd ff ff       	call   801356 <fsipc>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	79 14                	jns    801581 <open+0x6f>
		fd_close(fd, 0);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	6a 00                	push   $0x0
  801572:	ff 75 f4             	pushl  -0xc(%ebp)
  801575:	e8 4d f9 ff ff       	call   800ec7 <fd_close>
		return r;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	89 da                	mov    %ebx,%edx
  80157f:	eb 17                	jmp    801598 <open+0x86>
	}

	return fd2num(fd);
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	ff 75 f4             	pushl  -0xc(%ebp)
  801587:	e8 1c f8 ff ff       	call   800da8 <fd2num>
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	eb 05                	jmp    801598 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801593:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801598:	89 d0                	mov    %edx,%eax
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8015af:	e8 a2 fd ff ff       	call   801356 <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 ef f7 ff ff       	call   800db8 <fd2data>
  8015c9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	68 7b 23 80 00       	push   $0x80237b
  8015d3:	53                   	push   %ebx
  8015d4:	e8 1e f1 ff ff       	call   8006f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015d9:	8b 56 04             	mov    0x4(%esi),%edx
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	2b 06                	sub    (%esi),%eax
  8015e0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015e6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ed:	00 00 00 
	stat->st_dev = &devpipe;
  8015f0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015f7:	30 80 00 
	return 0;
}
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801610:	53                   	push   %ebx
  801611:	6a 00                	push   $0x0
  801613:	e8 6e f5 ff ff       	call   800b86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801618:	89 1c 24             	mov    %ebx,(%esp)
  80161b:	e8 98 f7 ff ff       	call   800db8 <fd2data>
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	50                   	push   %eax
  801624:	6a 00                	push   $0x0
  801626:	e8 5b f5 ff ff       	call   800b86 <sys_page_unmap>
}
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 1c             	sub    $0x1c,%esp
  801639:	89 c7                	mov    %eax,%edi
  80163b:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80163d:	a1 04 40 80 00       	mov    0x804004,%eax
  801642:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	57                   	push   %edi
  801649:	e8 74 05 00 00       	call   801bc2 <pageref>
  80164e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801651:	89 34 24             	mov    %esi,(%esp)
  801654:	e8 69 05 00 00       	call   801bc2 <pageref>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80165f:	0f 94 c0             	sete   %al
  801662:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801665:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80166b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80166e:	39 cb                	cmp    %ecx,%ebx
  801670:	74 15                	je     801687 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801672:	8b 52 58             	mov    0x58(%edx),%edx
  801675:	50                   	push   %eax
  801676:	52                   	push   %edx
  801677:	53                   	push   %ebx
  801678:	68 88 23 80 00       	push   $0x802388
  80167d:	e8 f1 ea ff ff       	call   800173 <cprintf>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb b6                	jmp    80163d <_pipeisclosed+0xd>
	}
}
  801687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5f                   	pop    %edi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 28             	sub    $0x28,%esp
  801698:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80169b:	56                   	push   %esi
  80169c:	e8 17 f7 ff ff       	call   800db8 <fd2data>
  8016a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8016ab:	eb 4b                	jmp    8016f8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016ad:	89 da                	mov    %ebx,%edx
  8016af:	89 f0                	mov    %esi,%eax
  8016b1:	e8 7a ff ff ff       	call   801630 <_pipeisclosed>
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	75 48                	jne    801702 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016ba:	e8 23 f4 ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8016c2:	8b 0b                	mov    (%ebx),%ecx
  8016c4:	8d 51 20             	lea    0x20(%ecx),%edx
  8016c7:	39 d0                	cmp    %edx,%eax
  8016c9:	73 e2                	jae    8016ad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016d2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016d5:	89 c2                	mov    %eax,%edx
  8016d7:	c1 fa 1f             	sar    $0x1f,%edx
  8016da:	89 d1                	mov    %edx,%ecx
  8016dc:	c1 e9 1b             	shr    $0x1b,%ecx
  8016df:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016e2:	83 e2 1f             	and    $0x1f,%edx
  8016e5:	29 ca                	sub    %ecx,%edx
  8016e7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016ef:	83 c0 01             	add    $0x1,%eax
  8016f2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f5:	83 c7 01             	add    $0x1,%edi
  8016f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016fb:	75 c2                	jne    8016bf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801700:	eb 05                	jmp    801707 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	57                   	push   %edi
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	83 ec 18             	sub    $0x18,%esp
  801718:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80171b:	57                   	push   %edi
  80171c:	e8 97 f6 ff ff       	call   800db8 <fd2data>
  801721:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172b:	eb 3d                	jmp    80176a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80172d:	85 db                	test   %ebx,%ebx
  80172f:	74 04                	je     801735 <devpipe_read+0x26>
				return i;
  801731:	89 d8                	mov    %ebx,%eax
  801733:	eb 44                	jmp    801779 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801735:	89 f2                	mov    %esi,%edx
  801737:	89 f8                	mov    %edi,%eax
  801739:	e8 f2 fe ff ff       	call   801630 <_pipeisclosed>
  80173e:	85 c0                	test   %eax,%eax
  801740:	75 32                	jne    801774 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801742:	e8 9b f3 ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801747:	8b 06                	mov    (%esi),%eax
  801749:	3b 46 04             	cmp    0x4(%esi),%eax
  80174c:	74 df                	je     80172d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80174e:	99                   	cltd   
  80174f:	c1 ea 1b             	shr    $0x1b,%edx
  801752:	01 d0                	add    %edx,%eax
  801754:	83 e0 1f             	and    $0x1f,%eax
  801757:	29 d0                	sub    %edx,%eax
  801759:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801761:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801764:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801767:	83 c3 01             	add    $0x1,%ebx
  80176a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80176d:	75 d8                	jne    801747 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80176f:	8b 45 10             	mov    0x10(%ebp),%eax
  801772:	eb 05                	jmp    801779 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5f                   	pop    %edi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	e8 3d f6 ff ff       	call   800dcf <fd_alloc>
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	89 c2                	mov    %eax,%edx
  801797:	85 c0                	test   %eax,%eax
  801799:	0f 88 2c 01 00 00    	js     8018cb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	68 07 04 00 00       	push   $0x407
  8017a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 50 f3 ff ff       	call   800b01 <sys_page_alloc>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	0f 88 0d 01 00 00    	js     8018cb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	e8 05 f6 ff ff       	call   800dcf <fd_alloc>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	0f 88 e2 00 00 00    	js     8018b9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	68 07 04 00 00       	push   $0x407
  8017df:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 18 f3 ff ff       	call   800b01 <sys_page_alloc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	0f 88 c3 00 00 00    	js     8018b9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fc:	e8 b7 f5 ff ff       	call   800db8 <fd2data>
  801801:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801803:	83 c4 0c             	add    $0xc,%esp
  801806:	68 07 04 00 00       	push   $0x407
  80180b:	50                   	push   %eax
  80180c:	6a 00                	push   $0x0
  80180e:	e8 ee f2 ff ff       	call   800b01 <sys_page_alloc>
  801813:	89 c3                	mov    %eax,%ebx
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	85 c0                	test   %eax,%eax
  80181a:	0f 88 89 00 00 00    	js     8018a9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	ff 75 f0             	pushl  -0x10(%ebp)
  801826:	e8 8d f5 ff ff       	call   800db8 <fd2data>
  80182b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801832:	50                   	push   %eax
  801833:	6a 00                	push   $0x0
  801835:	56                   	push   %esi
  801836:	6a 00                	push   $0x0
  801838:	e8 07 f3 ff ff       	call   800b44 <sys_page_map>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 20             	add    $0x20,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 55                	js     80189b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801846:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801851:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801854:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80185b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801864:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 f4             	pushl  -0xc(%ebp)
  801876:	e8 2d f5 ff ff       	call   800da8 <fd2num>
  80187b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80187e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801880:	83 c4 04             	add    $0x4,%esp
  801883:	ff 75 f0             	pushl  -0x10(%ebp)
  801886:	e8 1d f5 ff ff       	call   800da8 <fd2num>
  80188b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	eb 30                	jmp    8018cb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	56                   	push   %esi
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 e0 f2 ff ff       	call   800b86 <sys_page_unmap>
  8018a6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 d0 f2 ff ff       	call   800b86 <sys_page_unmap>
  8018b6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 c0 f2 ff ff       	call   800b86 <sys_page_unmap>
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 38 f5 ff ff       	call   800e1e <fd_lookup>
  8018e6:	89 c2                	mov    %eax,%edx
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 d2                	test   %edx,%edx
  8018ed:	78 18                	js     801907 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f5:	e8 be f4 ff ff       	call   800db8 <fd2data>
	return _pipeisclosed(fd, p);
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ff:	e8 2c fd ff ff       	call   801630 <_pipeisclosed>
  801904:	83 c4 10             	add    $0x10,%esp
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801919:	68 b9 23 80 00       	push   $0x8023b9
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	e8 d1 ed ff ff       	call   8006f7 <strcpy>
	return 0;
}
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	57                   	push   %edi
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
  801933:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801939:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80193e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801944:	eb 2e                	jmp    801974 <devcons_write+0x47>
		m = n - tot;
  801946:	8b 55 10             	mov    0x10(%ebp),%edx
  801949:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  80194b:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801950:	83 fa 7f             	cmp    $0x7f,%edx
  801953:	77 02                	ja     801957 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801955:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	56                   	push   %esi
  80195b:	03 45 0c             	add    0xc(%ebp),%eax
  80195e:	50                   	push   %eax
  80195f:	57                   	push   %edi
  801960:	e8 24 ef ff ff       	call   800889 <memmove>
		sys_cputs(buf, m);
  801965:	83 c4 08             	add    $0x8,%esp
  801968:	56                   	push   %esi
  801969:	57                   	push   %edi
  80196a:	e8 d6 f0 ff ff       	call   800a45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196f:	01 f3                	add    %esi,%ebx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	89 d8                	mov    %ebx,%eax
  801976:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801979:	72 cb                	jb     801946 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80197b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5f                   	pop    %edi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80198e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801992:	75 07                	jne    80199b <devcons_read+0x18>
  801994:	eb 28                	jmp    8019be <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801996:	e8 47 f1 ff ff       	call   800ae2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80199b:	e8 c3 f0 ff ff       	call   800a63 <sys_cgetc>
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	74 f2                	je     801996 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 16                	js     8019be <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019a8:	83 f8 04             	cmp    $0x4,%eax
  8019ab:	74 0c                	je     8019b9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b0:	88 02                	mov    %al,(%edx)
	return 1;
  8019b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b7:	eb 05                	jmp    8019be <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019cc:	6a 01                	push   $0x1
  8019ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	e8 6e f0 ff ff       	call   800a45 <sys_cputs>
  8019d7:	83 c4 10             	add    $0x10,%esp
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <getchar>:

int
getchar(void)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019e2:	6a 01                	push   $0x1
  8019e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 98 f6 ff ff       	call   801087 <read>
	if (r < 0)
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 0f                	js     801a05 <getchar+0x29>
		return r;
	if (r < 1)
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	7e 06                	jle    801a00 <getchar+0x24>
		return -E_EOF;
	return c;
  8019fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019fe:	eb 05                	jmp    801a05 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a00:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	ff 75 08             	pushl  0x8(%ebp)
  801a14:	e8 05 f4 ff ff       	call   800e1e <fd_lookup>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 11                	js     801a31 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a29:	39 10                	cmp    %edx,(%eax)
  801a2b:	0f 94 c0             	sete   %al
  801a2e:	0f b6 c0             	movzbl %al,%eax
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <opencons>:

int
opencons(void)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3c:	50                   	push   %eax
  801a3d:	e8 8d f3 ff ff       	call   800dcf <fd_alloc>
  801a42:	83 c4 10             	add    $0x10,%esp
		return r;
  801a45:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 3e                	js     801a89 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	68 07 04 00 00       	push   $0x407
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	6a 00                	push   $0x0
  801a58:	e8 a4 f0 ff ff       	call   800b01 <sys_page_alloc>
  801a5d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a60:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a62:	85 c0                	test   %eax,%eax
  801a64:	78 23                	js     801a89 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a66:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a74:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	50                   	push   %eax
  801a7f:	e8 24 f3 ff ff       	call   800da8 <fd2num>
  801a84:	89 c2                	mov    %eax,%edx
  801a86:	83 c4 10             	add    $0x10,%esp
}
  801a89:	89 d0                	mov    %edx,%eax
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a92:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a95:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a9b:	e8 23 f0 ff ff       	call   800ac3 <sys_getenvid>
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 0c             	pushl  0xc(%ebp)
  801aa6:	ff 75 08             	pushl  0x8(%ebp)
  801aa9:	56                   	push   %esi
  801aaa:	50                   	push   %eax
  801aab:	68 c8 23 80 00       	push   $0x8023c8
  801ab0:	e8 be e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ab5:	83 c4 18             	add    $0x18,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	ff 75 10             	pushl  0x10(%ebp)
  801abc:	e8 61 e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801ac1:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  801ac8:	e8 a6 e6 ff ff       	call   800173 <cprintf>
  801acd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ad0:	cc                   	int3   
  801ad1:	eb fd                	jmp    801ad0 <_panic+0x43>

00801ad3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  801adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ade:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ae1:	85 f6                	test   %esi,%esi
  801ae3:	74 06                	je     801aeb <ipc_recv+0x18>
  801ae5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801aeb:	85 db                	test   %ebx,%ebx
  801aed:	74 06                	je     801af5 <ipc_recv+0x22>
  801aef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801af5:	83 f8 01             	cmp    $0x1,%eax
  801af8:	19 d2                	sbb    %edx,%edx
  801afa:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	50                   	push   %eax
  801b00:	e8 ac f1 ff ff       	call   800cb1 <sys_ipc_recv>
  801b05:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 d2                	test   %edx,%edx
  801b0c:	75 24                	jne    801b32 <ipc_recv+0x5f>
	if (from_env_store)
  801b0e:	85 f6                	test   %esi,%esi
  801b10:	74 0a                	je     801b1c <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801b12:	a1 04 40 80 00       	mov    0x804004,%eax
  801b17:	8b 40 70             	mov    0x70(%eax),%eax
  801b1a:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	74 0a                	je     801b2a <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801b20:	a1 04 40 80 00       	mov    0x804004,%eax
  801b25:	8b 40 74             	mov    0x74(%eax),%eax
  801b28:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2f:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801b32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b4b:	83 fb 01             	cmp    $0x1,%ebx
  801b4e:	19 c0                	sbb    %eax,%eax
  801b50:	09 c3                	or     %eax,%ebx
  801b52:	eb 1c                	jmp    801b70 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b54:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b57:	74 12                	je     801b6b <ipc_send+0x32>
  801b59:	50                   	push   %eax
  801b5a:	68 ec 23 80 00       	push   $0x8023ec
  801b5f:	6a 36                	push   $0x36
  801b61:	68 03 24 80 00       	push   $0x802403
  801b66:	e8 22 ff ff ff       	call   801a8d <_panic>
		sys_yield();
  801b6b:	e8 72 ef ff ff       	call   800ae2 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b70:	ff 75 14             	pushl  0x14(%ebp)
  801b73:	53                   	push   %ebx
  801b74:	56                   	push   %esi
  801b75:	57                   	push   %edi
  801b76:	e8 13 f1 ff ff       	call   800c8e <sys_ipc_try_send>
		if (ret == 0) break;
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 d2                	jne    801b54 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b95:	6b d0 78             	imul   $0x78,%eax,%edx
  801b98:	83 c2 50             	add    $0x50,%edx
  801b9b:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ba1:	39 ca                	cmp    %ecx,%edx
  801ba3:	75 0d                	jne    801bb2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ba5:	6b c0 78             	imul   $0x78,%eax,%eax
  801ba8:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801bad:	8b 40 08             	mov    0x8(%eax),%eax
  801bb0:	eb 0e                	jmp    801bc0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bb2:	83 c0 01             	add    $0x1,%eax
  801bb5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bba:	75 d9                	jne    801b95 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bbc:	66 b8 00 00          	mov    $0x0,%ax
}
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc8:	89 d0                	mov    %edx,%eax
  801bca:	c1 e8 16             	shr    $0x16,%eax
  801bcd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd9:	f6 c1 01             	test   $0x1,%cl
  801bdc:	74 1d                	je     801bfb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bde:	c1 ea 0c             	shr    $0xc,%edx
  801be1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801be8:	f6 c2 01             	test   $0x1,%dl
  801beb:	74 0e                	je     801bfb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bed:	c1 ea 0c             	shr    $0xc,%edx
  801bf0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bf7:	ef 
  801bf8:	0f b7 c0             	movzwl %ax,%eax
}
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    
  801bfd:	66 90                	xchg   %ax,%ax
  801bff:	90                   	nop

00801c00 <__udivdi3>:
  801c00:	55                   	push   %ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	83 ec 10             	sub    $0x10,%esp
  801c06:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c0a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c0e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c16:	85 d2                	test   %edx,%edx
  801c18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c1c:	89 34 24             	mov    %esi,(%esp)
  801c1f:	89 c8                	mov    %ecx,%eax
  801c21:	75 35                	jne    801c58 <__udivdi3+0x58>
  801c23:	39 f1                	cmp    %esi,%ecx
  801c25:	0f 87 bd 00 00 00    	ja     801ce8 <__udivdi3+0xe8>
  801c2b:	85 c9                	test   %ecx,%ecx
  801c2d:	89 cd                	mov    %ecx,%ebp
  801c2f:	75 0b                	jne    801c3c <__udivdi3+0x3c>
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	31 d2                	xor    %edx,%edx
  801c38:	f7 f1                	div    %ecx
  801c3a:	89 c5                	mov    %eax,%ebp
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	31 d2                	xor    %edx,%edx
  801c40:	f7 f5                	div    %ebp
  801c42:	89 c6                	mov    %eax,%esi
  801c44:	89 f8                	mov    %edi,%eax
  801c46:	f7 f5                	div    %ebp
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	5e                   	pop    %esi
  801c4e:	5f                   	pop    %edi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    
  801c51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c58:	3b 14 24             	cmp    (%esp),%edx
  801c5b:	77 7b                	ja     801cd8 <__udivdi3+0xd8>
  801c5d:	0f bd f2             	bsr    %edx,%esi
  801c60:	83 f6 1f             	xor    $0x1f,%esi
  801c63:	0f 84 97 00 00 00    	je     801d00 <__udivdi3+0x100>
  801c69:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c6e:	89 d7                	mov    %edx,%edi
  801c70:	89 f1                	mov    %esi,%ecx
  801c72:	29 f5                	sub    %esi,%ebp
  801c74:	d3 e7                	shl    %cl,%edi
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	89 e9                	mov    %ebp,%ecx
  801c7a:	d3 ea                	shr    %cl,%edx
  801c7c:	89 f1                	mov    %esi,%ecx
  801c7e:	09 fa                	or     %edi,%edx
  801c80:	8b 3c 24             	mov    (%esp),%edi
  801c83:	d3 e0                	shl    %cl,%eax
  801c85:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c89:	89 e9                	mov    %ebp,%ecx
  801c8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c93:	89 fa                	mov    %edi,%edx
  801c95:	d3 ea                	shr    %cl,%edx
  801c97:	89 f1                	mov    %esi,%ecx
  801c99:	d3 e7                	shl    %cl,%edi
  801c9b:	89 e9                	mov    %ebp,%ecx
  801c9d:	d3 e8                	shr    %cl,%eax
  801c9f:	09 c7                	or     %eax,%edi
  801ca1:	89 f8                	mov    %edi,%eax
  801ca3:	f7 74 24 08          	divl   0x8(%esp)
  801ca7:	89 d5                	mov    %edx,%ebp
  801ca9:	89 c7                	mov    %eax,%edi
  801cab:	f7 64 24 0c          	mull   0xc(%esp)
  801caf:	39 d5                	cmp    %edx,%ebp
  801cb1:	89 14 24             	mov    %edx,(%esp)
  801cb4:	72 11                	jb     801cc7 <__udivdi3+0xc7>
  801cb6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cba:	89 f1                	mov    %esi,%ecx
  801cbc:	d3 e2                	shl    %cl,%edx
  801cbe:	39 c2                	cmp    %eax,%edx
  801cc0:	73 5e                	jae    801d20 <__udivdi3+0x120>
  801cc2:	3b 2c 24             	cmp    (%esp),%ebp
  801cc5:	75 59                	jne    801d20 <__udivdi3+0x120>
  801cc7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801cca:	31 f6                	xor    %esi,%esi
  801ccc:	89 f2                	mov    %esi,%edx
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	31 f6                	xor    %esi,%esi
  801cda:	31 c0                	xor    %eax,%eax
  801cdc:	89 f2                	mov    %esi,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	89 f2                	mov    %esi,%edx
  801cea:	31 f6                	xor    %esi,%esi
  801cec:	89 f8                	mov    %edi,%eax
  801cee:	f7 f1                	div    %ecx
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d04:	76 0b                	jbe    801d11 <__udivdi3+0x111>
  801d06:	31 c0                	xor    %eax,%eax
  801d08:	3b 14 24             	cmp    (%esp),%edx
  801d0b:	0f 83 37 ff ff ff    	jae    801c48 <__udivdi3+0x48>
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	e9 2d ff ff ff       	jmp    801c48 <__udivdi3+0x48>
  801d1b:	90                   	nop
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 f8                	mov    %edi,%eax
  801d22:	31 f6                	xor    %esi,%esi
  801d24:	e9 1f ff ff ff       	jmp    801c48 <__udivdi3+0x48>
  801d29:	66 90                	xchg   %ax,%ax
  801d2b:	66 90                	xchg   %ax,%ax
  801d2d:	66 90                	xchg   %ax,%ax
  801d2f:	90                   	nop

00801d30 <__umoddi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	83 ec 20             	sub    $0x20,%esp
  801d36:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d3a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d3e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d42:	89 c6                	mov    %eax,%esi
  801d44:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d48:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d4c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d50:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d54:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d58:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	75 1e                	jne    801d80 <__umoddi3+0x50>
  801d62:	39 f7                	cmp    %esi,%edi
  801d64:	76 52                	jbe    801db8 <__umoddi3+0x88>
  801d66:	89 c8                	mov    %ecx,%eax
  801d68:	89 f2                	mov    %esi,%edx
  801d6a:	f7 f7                	div    %edi
  801d6c:	89 d0                	mov    %edx,%eax
  801d6e:	31 d2                	xor    %edx,%edx
  801d70:	83 c4 20             	add    $0x20,%esp
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    
  801d77:	89 f6                	mov    %esi,%esi
  801d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d80:	39 f0                	cmp    %esi,%eax
  801d82:	77 5c                	ja     801de0 <__umoddi3+0xb0>
  801d84:	0f bd e8             	bsr    %eax,%ebp
  801d87:	83 f5 1f             	xor    $0x1f,%ebp
  801d8a:	75 64                	jne    801df0 <__umoddi3+0xc0>
  801d8c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d90:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d94:	0f 86 f6 00 00 00    	jbe    801e90 <__umoddi3+0x160>
  801d9a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d9e:	0f 82 ec 00 00 00    	jb     801e90 <__umoddi3+0x160>
  801da4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801da8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801dac:	83 c4 20             	add    $0x20,%esp
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	85 ff                	test   %edi,%edi
  801dba:	89 fd                	mov    %edi,%ebp
  801dbc:	75 0b                	jne    801dc9 <__umoddi3+0x99>
  801dbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f7                	div    %edi
  801dc7:	89 c5                	mov    %eax,%ebp
  801dc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dcd:	31 d2                	xor    %edx,%edx
  801dcf:	f7 f5                	div    %ebp
  801dd1:	89 c8                	mov    %ecx,%eax
  801dd3:	f7 f5                	div    %ebp
  801dd5:	eb 95                	jmp    801d6c <__umoddi3+0x3c>
  801dd7:	89 f6                	mov    %esi,%esi
  801dd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 20             	add    $0x20,%esp
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    
  801deb:	90                   	nop
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	b8 20 00 00 00       	mov    $0x20,%eax
  801df5:	89 e9                	mov    %ebp,%ecx
  801df7:	29 e8                	sub    %ebp,%eax
  801df9:	d3 e2                	shl    %cl,%edx
  801dfb:	89 c7                	mov    %eax,%edi
  801dfd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 c1                	mov    %eax,%ecx
  801e0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e0f:	09 d1                	or     %edx,%ecx
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e17:	89 e9                	mov    %ebp,%ecx
  801e19:	d3 e0                	shl    %cl,%eax
  801e1b:	89 f9                	mov    %edi,%ecx
  801e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	d3 e8                	shr    %cl,%eax
  801e25:	89 e9                	mov    %ebp,%ecx
  801e27:	89 c7                	mov    %eax,%edi
  801e29:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e2d:	d3 e6                	shl    %cl,%esi
  801e2f:	89 d1                	mov    %edx,%ecx
  801e31:	89 fa                	mov    %edi,%edx
  801e33:	d3 e8                	shr    %cl,%eax
  801e35:	89 e9                	mov    %ebp,%ecx
  801e37:	09 f0                	or     %esi,%eax
  801e39:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e3d:	f7 74 24 10          	divl   0x10(%esp)
  801e41:	d3 e6                	shl    %cl,%esi
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	f7 64 24 0c          	mull   0xc(%esp)
  801e49:	39 d1                	cmp    %edx,%ecx
  801e4b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e4f:	89 d7                	mov    %edx,%edi
  801e51:	89 c6                	mov    %eax,%esi
  801e53:	72 0a                	jb     801e5f <__umoddi3+0x12f>
  801e55:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e59:	73 10                	jae    801e6b <__umoddi3+0x13b>
  801e5b:	39 d1                	cmp    %edx,%ecx
  801e5d:	75 0c                	jne    801e6b <__umoddi3+0x13b>
  801e5f:	89 d7                	mov    %edx,%edi
  801e61:	89 c6                	mov    %eax,%esi
  801e63:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e67:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e6b:	89 ca                	mov    %ecx,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e73:	29 f0                	sub    %esi,%eax
  801e75:	19 fa                	sbb    %edi,%edx
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e7e:	89 d7                	mov    %edx,%edi
  801e80:	d3 e7                	shl    %cl,%edi
  801e82:	89 e9                	mov    %ebp,%ecx
  801e84:	09 f8                	or     %edi,%eax
  801e86:	d3 ea                	shr    %cl,%edx
  801e88:	83 c4 20             	add    $0x20,%esp
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
  801e8f:	90                   	nop
  801e90:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e94:	29 f9                	sub    %edi,%ecx
  801e96:	19 c6                	sbb    %eax,%esi
  801e98:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e9c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801ea0:	e9 ff fe ff ff       	jmp    801da4 <__umoddi3+0x74>
