
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 00 1e 80 00       	push   $0x801e00
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 33 0a 00 00       	call   800a91 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 78             	imul   $0x78,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
  80008a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 0c 0e 00 00       	call   800eab <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a7 09 00 00       	call   800a50 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 35 09 00 00       	call   800a13 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 4f 01 00 00       	call   800273 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 da 08 00 00       	call   800a13 <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 d1                	mov    %edx,%ecx
  80016a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800170:	8b 45 10             	mov    0x10(%ebp),%eax
  800173:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800179:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800180:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800183:	72 05                	jb     80018a <printnum+0x35>
  800185:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800188:	77 3e                	ja     8001c8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 18             	pushl  0x18(%ebp)
  800190:	83 eb 01             	sub    $0x1,%ebx
  800193:	53                   	push   %ebx
  800194:	50                   	push   %eax
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 97 19 00 00       	call   801b40 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 13                	jmp    8001cf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f ed                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 89 1a 00 00       	call   801c70 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 28 1e 80 00 	movsbl 0x801e28(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
  8001f4:	83 c4 10             	add    $0x10,%esp
}
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800202:	83 fa 01             	cmp    $0x1,%edx
  800205:	7e 0e                	jle    800215 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800207:	8b 10                	mov    (%eax),%edx
  800209:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020c:	89 08                	mov    %ecx,(%eax)
  80020e:	8b 02                	mov    (%edx),%eax
  800210:	8b 52 04             	mov    0x4(%edx),%edx
  800213:	eb 22                	jmp    800237 <getuint+0x38>
	else if (lflag)
  800215:	85 d2                	test   %edx,%edx
  800217:	74 10                	je     800229 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	ba 00 00 00 00       	mov    $0x0,%edx
  800227:	eb 0e                	jmp    800237 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800243:	8b 10                	mov    (%eax),%edx
  800245:	3b 50 04             	cmp    0x4(%eax),%edx
  800248:	73 0a                	jae    800254 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	88 02                	mov    %al,(%edx)
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025f:	50                   	push   %eax
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	ff 75 0c             	pushl  0xc(%ebp)
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 05 00 00 00       	call   800273 <vprintfmt>
	va_end(ap);
  80026e:	83 c4 10             	add    $0x10,%esp
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
  80027c:	8b 75 08             	mov    0x8(%ebp),%esi
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800282:	8b 7d 10             	mov    0x10(%ebp),%edi
  800285:	eb 12                	jmp    800299 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800287:	85 c0                	test   %eax,%eax
  800289:	0f 84 8d 03 00 00    	je     80061c <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	53                   	push   %ebx
  800293:	50                   	push   %eax
  800294:	ff d6                	call   *%esi
  800296:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800299:	83 c7 01             	add    $0x1,%edi
  80029c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a0:	83 f8 25             	cmp    $0x25,%eax
  8002a3:	75 e2                	jne    800287 <vprintfmt+0x14>
  8002a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 07                	jmp    8002cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cc:	8d 47 01             	lea    0x1(%edi),%eax
  8002cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d2:	0f b6 07             	movzbl (%edi),%eax
  8002d5:	0f b6 c8             	movzbl %al,%ecx
  8002d8:	83 e8 23             	sub    $0x23,%eax
  8002db:	3c 55                	cmp    $0x55,%al
  8002dd:	0f 87 1e 03 00 00    	ja     800601 <vprintfmt+0x38e>
  8002e3:	0f b6 c0             	movzbl %al,%eax
  8002e6:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f4:	eb d6                	jmp    8002cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800304:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800308:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80030b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80030e:	83 fa 09             	cmp    $0x9,%edx
  800311:	77 38                	ja     80034b <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800316:	eb e9                	jmp    800301 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	8d 48 04             	lea    0x4(%eax),%ecx
  80031e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800321:	8b 00                	mov    (%eax),%eax
  800323:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 26                	jmp    800351 <vprintfmt+0xde>
  80032b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80032e:	89 c8                	mov    %ecx,%eax
  800330:	c1 f8 1f             	sar    $0x1f,%eax
  800333:	f7 d0                	not    %eax
  800335:	21 c1                	and    %eax,%ecx
  800337:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033d:	eb 8d                	jmp    8002cc <vprintfmt+0x59>
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800342:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800349:	eb 81                	jmp    8002cc <vprintfmt+0x59>
  80034b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800355:	0f 89 71 ff ff ff    	jns    8002cc <vprintfmt+0x59>
				width = precision, precision = -1;
  80035b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800368:	e9 5f ff ff ff       	jmp    8002cc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800373:	e9 54 ff ff ff       	jmp    8002cc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 50 04             	lea    0x4(%eax),%edx
  80037e:	89 55 14             	mov    %edx,0x14(%ebp)
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	ff 30                	pushl  (%eax)
  800387:	ff d6                	call   *%esi
			break;
  800389:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038f:	e9 05 ff ff ff       	jmp    800299 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	99                   	cltd   
  8003a0:	31 d0                	xor    %edx,%eax
  8003a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a4:	83 f8 0f             	cmp    $0xf,%eax
  8003a7:	7f 0b                	jg     8003b4 <vprintfmt+0x141>
  8003a9:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003b0:	85 d2                	test   %edx,%edx
  8003b2:	75 18                	jne    8003cc <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8003b4:	50                   	push   %eax
  8003b5:	68 40 1e 80 00       	push   $0x801e40
  8003ba:	53                   	push   %ebx
  8003bb:	56                   	push   %esi
  8003bc:	e8 95 fe ff ff       	call   800256 <printfmt>
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c7:	e9 cd fe ff ff       	jmp    800299 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003cc:	52                   	push   %edx
  8003cd:	68 31 22 80 00       	push   $0x802231
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 7d fe ff ff       	call   800256 <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003df:	e9 b5 fe ff ff       	jmp    800299 <vprintfmt+0x26>
  8003e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 38                	mov    (%eax),%edi
  8003f8:	85 ff                	test   %edi,%edi
  8003fa:	75 05                	jne    800401 <vprintfmt+0x18e>
				p = "(null)";
  8003fc:	bf 39 1e 80 00       	mov    $0x801e39,%edi
			if (width > 0 && padc != '-')
  800401:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800405:	0f 84 91 00 00 00    	je     80049c <vprintfmt+0x229>
  80040b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80040f:	0f 8e 95 00 00 00    	jle    8004aa <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	51                   	push   %ecx
  800419:	57                   	push   %edi
  80041a:	e8 85 02 00 00       	call   8006a4 <strnlen>
  80041f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800422:	29 c1                	sub    %eax,%ecx
  800424:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1c5>
  80044b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800451:	89 c8                	mov    %ecx,%eax
  800453:	c1 f8 1f             	sar    $0x1f,%eax
  800456:	f7 d0                	not    %eax
  800458:	21 c8                	and    %ecx,%eax
  80045a:	29 c1                	sub    %eax,%ecx
  80045c:	89 75 08             	mov    %esi,0x8(%ebp)
  80045f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800462:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800465:	89 cb                	mov    %ecx,%ebx
  800467:	eb 4d                	jmp    8004b6 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800469:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046d:	74 1b                	je     80048a <vprintfmt+0x217>
  80046f:	0f be c0             	movsbl %al,%eax
  800472:	83 e8 20             	sub    $0x20,%eax
  800475:	83 f8 5e             	cmp    $0x5e,%eax
  800478:	76 10                	jbe    80048a <vprintfmt+0x217>
					putch('?', putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 0c             	pushl  0xc(%ebp)
  800480:	6a 3f                	push   $0x3f
  800482:	ff 55 08             	call   *0x8(%ebp)
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb 0d                	jmp    800497 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	52                   	push   %edx
  800491:	ff 55 08             	call   *0x8(%ebp)
  800494:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800497:	83 eb 01             	sub    $0x1,%ebx
  80049a:	eb 1a                	jmp    8004b6 <vprintfmt+0x243>
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a8:	eb 0c                	jmp    8004b6 <vprintfmt+0x243>
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b6:	83 c7 01             	add    $0x1,%edi
  8004b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004bd:	0f be d0             	movsbl %al,%edx
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	74 23                	je     8004e7 <vprintfmt+0x274>
  8004c4:	85 f6                	test   %esi,%esi
  8004c6:	78 a1                	js     800469 <vprintfmt+0x1f6>
  8004c8:	83 ee 01             	sub    $0x1,%esi
  8004cb:	79 9c                	jns    800469 <vprintfmt+0x1f6>
  8004cd:	89 df                	mov    %ebx,%edi
  8004cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d5:	eb 18                	jmp    8004ef <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	6a 20                	push   $0x20
  8004dd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004df:	83 ef 01             	sub    $0x1,%edi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb 08                	jmp    8004ef <vprintfmt+0x27c>
  8004e7:	89 df                	mov    %ebx,%edi
  8004e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	7f e4                	jg     8004d7 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f6:	e9 9e fd ff ff       	jmp    800299 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fb:	83 fa 01             	cmp    $0x1,%edx
  8004fe:	7e 16                	jle    800516 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 08             	lea    0x8(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 50 04             	mov    0x4(%eax),%edx
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800511:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800514:	eb 32                	jmp    800548 <vprintfmt+0x2d5>
	else if (lflag)
  800516:	85 d2                	test   %edx,%edx
  800518:	74 18                	je     800532 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	89 c1                	mov    %eax,%ecx
  80052a:	c1 f9 1f             	sar    $0x1f,%ecx
  80052d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800530:	eb 16                	jmp    800548 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800540:	89 c1                	mov    %eax,%ecx
  800542:	c1 f9 1f             	sar    $0x1f,%ecx
  800545:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800548:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800553:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800557:	79 74                	jns    8005cd <vprintfmt+0x35a>
				putch('-', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 2d                	push   $0x2d
  80055f:	ff d6                	call   *%esi
				num = -(long long) num;
  800561:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800564:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800567:	f7 d8                	neg    %eax
  800569:	83 d2 00             	adc    $0x0,%edx
  80056c:	f7 da                	neg    %edx
  80056e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800571:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800576:	eb 55                	jmp    8005cd <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800578:	8d 45 14             	lea    0x14(%ebp),%eax
  80057b:	e8 7f fc ff ff       	call   8001ff <getuint>
			base = 10;
  800580:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800585:	eb 46                	jmp    8005cd <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800587:	8d 45 14             	lea    0x14(%ebp),%eax
  80058a:	e8 70 fc ff ff       	call   8001ff <getuint>
			base = 8;
  80058f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800594:	eb 37                	jmp    8005cd <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 30                	push   $0x30
  80059c:	ff d6                	call   *%esi
			putch('x', putdat);
  80059e:	83 c4 08             	add    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 78                	push   $0x78
  8005a4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005be:	eb 0d                	jmp    8005cd <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c3:	e8 37 fc ff ff       	call   8001ff <getuint>
			base = 16;
  8005c8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d4:	57                   	push   %edi
  8005d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d8:	51                   	push   %ecx
  8005d9:	52                   	push   %edx
  8005da:	50                   	push   %eax
  8005db:	89 da                	mov    %ebx,%edx
  8005dd:	89 f0                	mov    %esi,%eax
  8005df:	e8 71 fb ff ff       	call   800155 <printnum>
			break;
  8005e4:	83 c4 20             	add    $0x20,%esp
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 aa fc ff ff       	jmp    800299 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	51                   	push   %ecx
  8005f4:	ff d6                	call   *%esi
			break;
  8005f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005fc:	e9 98 fc ff ff       	jmp    800299 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 25                	push   $0x25
  800607:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	eb 03                	jmp    800611 <vprintfmt+0x39e>
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800615:	75 f7                	jne    80060e <vprintfmt+0x39b>
  800617:	e9 7d fc ff ff       	jmp    800299 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80061c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061f:	5b                   	pop    %ebx
  800620:	5e                   	pop    %esi
  800621:	5f                   	pop    %edi
  800622:	5d                   	pop    %ebp
  800623:	c3                   	ret    

00800624 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	83 ec 18             	sub    $0x18,%esp
  80062a:	8b 45 08             	mov    0x8(%ebp),%eax
  80062d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800633:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800637:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80063a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800641:	85 c0                	test   %eax,%eax
  800643:	74 26                	je     80066b <vsnprintf+0x47>
  800645:	85 d2                	test   %edx,%edx
  800647:	7e 22                	jle    80066b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800649:	ff 75 14             	pushl  0x14(%ebp)
  80064c:	ff 75 10             	pushl  0x10(%ebp)
  80064f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	68 39 02 80 00       	push   $0x800239
  800658:	e8 16 fc ff ff       	call   800273 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800660:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 05                	jmp    800670 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80066b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800670:	c9                   	leave  
  800671:	c3                   	ret    

00800672 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067b:	50                   	push   %eax
  80067c:	ff 75 10             	pushl  0x10(%ebp)
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	ff 75 08             	pushl  0x8(%ebp)
  800685:	e8 9a ff ff ff       	call   800624 <vsnprintf>
	va_end(ap);

	return rc;
}
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    

0080068c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800692:	b8 00 00 00 00       	mov    $0x0,%eax
  800697:	eb 03                	jmp    80069c <strlen+0x10>
		n++;
  800699:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a0:	75 f7                	jne    800699 <strlen+0xd>
		n++;
	return n;
}
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b2:	eb 03                	jmp    8006b7 <strnlen+0x13>
		n++;
  8006b4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b7:	39 c2                	cmp    %eax,%edx
  8006b9:	74 08                	je     8006c3 <strnlen+0x1f>
  8006bb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006bf:	75 f3                	jne    8006b4 <strnlen+0x10>
  8006c1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	53                   	push   %ebx
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	83 c2 01             	add    $0x1,%edx
  8006d4:	83 c1 01             	add    $0x1,%ecx
  8006d7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006de:	84 db                	test   %bl,%bl
  8006e0:	75 ef                	jne    8006d1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e2:	5b                   	pop    %ebx
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ec:	53                   	push   %ebx
  8006ed:	e8 9a ff ff ff       	call   80068c <strlen>
  8006f2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	01 d8                	add    %ebx,%eax
  8006fa:	50                   	push   %eax
  8006fb:	e8 c5 ff ff ff       	call   8006c5 <strcpy>
	return dst;
}
  800700:	89 d8                	mov    %ebx,%eax
  800702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	56                   	push   %esi
  80070b:	53                   	push   %ebx
  80070c:	8b 75 08             	mov    0x8(%ebp),%esi
  80070f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800712:	89 f3                	mov    %esi,%ebx
  800714:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800717:	89 f2                	mov    %esi,%edx
  800719:	eb 0f                	jmp    80072a <strncpy+0x23>
		*dst++ = *src;
  80071b:	83 c2 01             	add    $0x1,%edx
  80071e:	0f b6 01             	movzbl (%ecx),%eax
  800721:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800724:	80 39 01             	cmpb   $0x1,(%ecx)
  800727:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072a:	39 da                	cmp    %ebx,%edx
  80072c:	75 ed                	jne    80071b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072e:	89 f0                	mov    %esi,%eax
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	56                   	push   %esi
  800738:	53                   	push   %ebx
  800739:	8b 75 08             	mov    0x8(%ebp),%esi
  80073c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073f:	8b 55 10             	mov    0x10(%ebp),%edx
  800742:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800744:	85 d2                	test   %edx,%edx
  800746:	74 21                	je     800769 <strlcpy+0x35>
  800748:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80074c:	89 f2                	mov    %esi,%edx
  80074e:	eb 09                	jmp    800759 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800750:	83 c2 01             	add    $0x1,%edx
  800753:	83 c1 01             	add    $0x1,%ecx
  800756:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800759:	39 c2                	cmp    %eax,%edx
  80075b:	74 09                	je     800766 <strlcpy+0x32>
  80075d:	0f b6 19             	movzbl (%ecx),%ebx
  800760:	84 db                	test   %bl,%bl
  800762:	75 ec                	jne    800750 <strlcpy+0x1c>
  800764:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800766:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800769:	29 f0                	sub    %esi,%eax
}
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800775:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800778:	eb 06                	jmp    800780 <strcmp+0x11>
		p++, q++;
  80077a:	83 c1 01             	add    $0x1,%ecx
  80077d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800780:	0f b6 01             	movzbl (%ecx),%eax
  800783:	84 c0                	test   %al,%al
  800785:	74 04                	je     80078b <strcmp+0x1c>
  800787:	3a 02                	cmp    (%edx),%al
  800789:	74 ef                	je     80077a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80078b:	0f b6 c0             	movzbl %al,%eax
  80078e:	0f b6 12             	movzbl (%edx),%edx
  800791:	29 d0                	sub    %edx,%eax
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079f:	89 c3                	mov    %eax,%ebx
  8007a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a4:	eb 06                	jmp    8007ac <strncmp+0x17>
		n--, p++, q++;
  8007a6:	83 c0 01             	add    $0x1,%eax
  8007a9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ac:	39 d8                	cmp    %ebx,%eax
  8007ae:	74 15                	je     8007c5 <strncmp+0x30>
  8007b0:	0f b6 08             	movzbl (%eax),%ecx
  8007b3:	84 c9                	test   %cl,%cl
  8007b5:	74 04                	je     8007bb <strncmp+0x26>
  8007b7:	3a 0a                	cmp    (%edx),%cl
  8007b9:	74 eb                	je     8007a6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bb:	0f b6 00             	movzbl (%eax),%eax
  8007be:	0f b6 12             	movzbl (%edx),%edx
  8007c1:	29 d0                	sub    %edx,%eax
  8007c3:	eb 05                	jmp    8007ca <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d7:	eb 07                	jmp    8007e0 <strchr+0x13>
		if (*s == c)
  8007d9:	38 ca                	cmp    %cl,%dl
  8007db:	74 0f                	je     8007ec <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007dd:	83 c0 01             	add    $0x1,%eax
  8007e0:	0f b6 10             	movzbl (%eax),%edx
  8007e3:	84 d2                	test   %dl,%dl
  8007e5:	75 f2                	jne    8007d9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f8:	eb 03                	jmp    8007fd <strfind+0xf>
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800800:	84 d2                	test   %dl,%dl
  800802:	74 04                	je     800808 <strfind+0x1a>
  800804:	38 ca                	cmp    %cl,%dl
  800806:	75 f2                	jne    8007fa <strfind+0xc>
			break;
	return (char *) s;
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	57                   	push   %edi
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 7d 08             	mov    0x8(%ebp),%edi
  800813:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800816:	85 c9                	test   %ecx,%ecx
  800818:	74 36                	je     800850 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80081a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800820:	75 28                	jne    80084a <memset+0x40>
  800822:	f6 c1 03             	test   $0x3,%cl
  800825:	75 23                	jne    80084a <memset+0x40>
		c &= 0xFF;
  800827:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80082b:	89 d3                	mov    %edx,%ebx
  80082d:	c1 e3 08             	shl    $0x8,%ebx
  800830:	89 d6                	mov    %edx,%esi
  800832:	c1 e6 18             	shl    $0x18,%esi
  800835:	89 d0                	mov    %edx,%eax
  800837:	c1 e0 10             	shl    $0x10,%eax
  80083a:	09 f0                	or     %esi,%eax
  80083c:	09 c2                	or     %eax,%edx
  80083e:	89 d0                	mov    %edx,%eax
  800840:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800842:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800845:	fc                   	cld    
  800846:	f3 ab                	rep stos %eax,%es:(%edi)
  800848:	eb 06                	jmp    800850 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	fc                   	cld    
  80084e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800850:	89 f8                	mov    %edi,%eax
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800865:	39 c6                	cmp    %eax,%esi
  800867:	73 35                	jae    80089e <memmove+0x47>
  800869:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086c:	39 d0                	cmp    %edx,%eax
  80086e:	73 2e                	jae    80089e <memmove+0x47>
		s += n;
		d += n;
  800870:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800873:	89 d6                	mov    %edx,%esi
  800875:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800877:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087d:	75 13                	jne    800892 <memmove+0x3b>
  80087f:	f6 c1 03             	test   $0x3,%cl
  800882:	75 0e                	jne    800892 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800884:	83 ef 04             	sub    $0x4,%edi
  800887:	8d 72 fc             	lea    -0x4(%edx),%esi
  80088a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80088d:	fd                   	std    
  80088e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800890:	eb 09                	jmp    80089b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800892:	83 ef 01             	sub    $0x1,%edi
  800895:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800898:	fd                   	std    
  800899:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80089b:	fc                   	cld    
  80089c:	eb 1d                	jmp    8008bb <memmove+0x64>
  80089e:	89 f2                	mov    %esi,%edx
  8008a0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a2:	f6 c2 03             	test   $0x3,%dl
  8008a5:	75 0f                	jne    8008b6 <memmove+0x5f>
  8008a7:	f6 c1 03             	test   $0x3,%cl
  8008aa:	75 0a                	jne    8008b6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008af:	89 c7                	mov    %eax,%edi
  8008b1:	fc                   	cld    
  8008b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b4:	eb 05                	jmp    8008bb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b6:	89 c7                	mov    %eax,%edi
  8008b8:	fc                   	cld    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c2:	ff 75 10             	pushl  0x10(%ebp)
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	ff 75 08             	pushl  0x8(%ebp)
  8008cb:	e8 87 ff ff ff       	call   800857 <memmove>
}
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dd:	89 c6                	mov    %eax,%esi
  8008df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e2:	eb 1a                	jmp    8008fe <memcmp+0x2c>
		if (*s1 != *s2)
  8008e4:	0f b6 08             	movzbl (%eax),%ecx
  8008e7:	0f b6 1a             	movzbl (%edx),%ebx
  8008ea:	38 d9                	cmp    %bl,%cl
  8008ec:	74 0a                	je     8008f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ee:	0f b6 c1             	movzbl %cl,%eax
  8008f1:	0f b6 db             	movzbl %bl,%ebx
  8008f4:	29 d8                	sub    %ebx,%eax
  8008f6:	eb 0f                	jmp    800907 <memcmp+0x35>
		s1++, s2++;
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fe:	39 f0                	cmp    %esi,%eax
  800900:	75 e2                	jne    8008e4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800914:	89 c2                	mov    %eax,%edx
  800916:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800919:	eb 07                	jmp    800922 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091b:	38 08                	cmp    %cl,(%eax)
  80091d:	74 07                	je     800926 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	39 d0                	cmp    %edx,%eax
  800924:	72 f5                	jb     80091b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800934:	eb 03                	jmp    800939 <strtol+0x11>
		s++;
  800936:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800939:	0f b6 01             	movzbl (%ecx),%eax
  80093c:	3c 09                	cmp    $0x9,%al
  80093e:	74 f6                	je     800936 <strtol+0xe>
  800940:	3c 20                	cmp    $0x20,%al
  800942:	74 f2                	je     800936 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800944:	3c 2b                	cmp    $0x2b,%al
  800946:	75 0a                	jne    800952 <strtol+0x2a>
		s++;
  800948:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80094b:	bf 00 00 00 00       	mov    $0x0,%edi
  800950:	eb 10                	jmp    800962 <strtol+0x3a>
  800952:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800957:	3c 2d                	cmp    $0x2d,%al
  800959:	75 07                	jne    800962 <strtol+0x3a>
		s++, neg = 1;
  80095b:	8d 49 01             	lea    0x1(%ecx),%ecx
  80095e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800962:	85 db                	test   %ebx,%ebx
  800964:	0f 94 c0             	sete   %al
  800967:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80096d:	75 19                	jne    800988 <strtol+0x60>
  80096f:	80 39 30             	cmpb   $0x30,(%ecx)
  800972:	75 14                	jne    800988 <strtol+0x60>
  800974:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800978:	0f 85 8a 00 00 00    	jne    800a08 <strtol+0xe0>
		s += 2, base = 16;
  80097e:	83 c1 02             	add    $0x2,%ecx
  800981:	bb 10 00 00 00       	mov    $0x10,%ebx
  800986:	eb 16                	jmp    80099e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800988:	84 c0                	test   %al,%al
  80098a:	74 12                	je     80099e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800991:	80 39 30             	cmpb   $0x30,(%ecx)
  800994:	75 08                	jne    80099e <strtol+0x76>
		s++, base = 8;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a6:	0f b6 11             	movzbl (%ecx),%edx
  8009a9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ac:	89 f3                	mov    %esi,%ebx
  8009ae:	80 fb 09             	cmp    $0x9,%bl
  8009b1:	77 08                	ja     8009bb <strtol+0x93>
			dig = *s - '0';
  8009b3:	0f be d2             	movsbl %dl,%edx
  8009b6:	83 ea 30             	sub    $0x30,%edx
  8009b9:	eb 22                	jmp    8009dd <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009bb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	80 fb 19             	cmp    $0x19,%bl
  8009c3:	77 08                	ja     8009cd <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009c5:	0f be d2             	movsbl %dl,%edx
  8009c8:	83 ea 57             	sub    $0x57,%edx
  8009cb:	eb 10                	jmp    8009dd <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009cd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d0:	89 f3                	mov    %esi,%ebx
  8009d2:	80 fb 19             	cmp    $0x19,%bl
  8009d5:	77 16                	ja     8009ed <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009d7:	0f be d2             	movsbl %dl,%edx
  8009da:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009dd:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e0:	7d 0f                	jge    8009f1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009e2:	83 c1 01             	add    $0x1,%ecx
  8009e5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009eb:	eb b9                	jmp    8009a6 <strtol+0x7e>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	eb 02                	jmp    8009f3 <strtol+0xcb>
  8009f1:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f7:	74 05                	je     8009fe <strtol+0xd6>
		*endptr = (char *) s;
  8009f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8009fe:	85 ff                	test   %edi,%edi
  800a00:	74 0c                	je     800a0e <strtol+0xe6>
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	f7 d8                	neg    %eax
  800a06:	eb 06                	jmp    800a0e <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a08:	84 c0                	test   %al,%al
  800a0a:	75 8a                	jne    800996 <strtol+0x6e>
  800a0c:	eb 90                	jmp    80099e <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
  800a24:	89 c3                	mov    %eax,%ebx
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	89 c6                	mov    %eax,%esi
  800a2a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a41:	89 d1                	mov    %edx,%ecx
  800a43:	89 d3                	mov    %edx,%ebx
  800a45:	89 d7                	mov    %edx,%edi
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
  800a66:	89 cb                	mov    %ecx,%ebx
  800a68:	89 cf                	mov    %ecx,%edi
  800a6a:	89 ce                	mov    %ecx,%esi
  800a6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a6e:	85 c0                	test   %eax,%eax
  800a70:	7e 17                	jle    800a89 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a72:	83 ec 0c             	sub    $0xc,%esp
  800a75:	50                   	push   %eax
  800a76:	6a 03                	push   $0x3
  800a78:	68 5f 21 80 00       	push   $0x80215f
  800a7d:	6a 23                	push   $0x23
  800a7f:	68 7c 21 80 00       	push   $0x80217c
  800a84:	e8 3b 0f 00 00       	call   8019c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa1:	89 d1                	mov    %edx,%ecx
  800aa3:	89 d3                	mov    %edx,%ebx
  800aa5:	89 d7                	mov    %edx,%edi
  800aa7:	89 d6                	mov    %edx,%esi
  800aa9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_yield>:

void
sys_yield(void)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  800abb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ac0:	89 d1                	mov    %edx,%ecx
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	be 00 00 00 00       	mov    $0x0,%esi
  800add:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aeb:	89 f7                	mov    %esi,%edi
  800aed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aef:	85 c0                	test   %eax,%eax
  800af1:	7e 17                	jle    800b0a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	50                   	push   %eax
  800af7:	6a 04                	push   $0x4
  800af9:	68 5f 21 80 00       	push   $0x80215f
  800afe:	6a 23                	push   $0x23
  800b00:	68 7c 21 80 00       	push   $0x80217c
  800b05:	e8 ba 0e 00 00       	call   8019c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b2c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 17                	jle    800b4c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	50                   	push   %eax
  800b39:	6a 05                	push   $0x5
  800b3b:	68 5f 21 80 00       	push   $0x80215f
  800b40:	6a 23                	push   $0x23
  800b42:	68 7c 21 80 00       	push   $0x80217c
  800b47:	e8 78 0e 00 00       	call   8019c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b62:	b8 06 00 00 00       	mov    $0x6,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 df                	mov    %ebx,%edi
  800b6f:	89 de                	mov    %ebx,%esi
  800b71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7e 17                	jle    800b8e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 06                	push   $0x6
  800b7d:	68 5f 21 80 00       	push   $0x80215f
  800b82:	6a 23                	push   $0x23
  800b84:	68 7c 21 80 00       	push   $0x80217c
  800b89:	e8 36 0e 00 00       	call   8019c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	89 df                	mov    %ebx,%edi
  800bb1:	89 de                	mov    %ebx,%esi
  800bb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7e 17                	jle    800bd0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 08                	push   $0x8
  800bbf:	68 5f 21 80 00       	push   $0x80215f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 7c 21 80 00       	push   $0x80217c
  800bcb:	e8 f4 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	b8 09 00 00 00       	mov    $0x9,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 09                	push   $0x9
  800c01:	68 5f 21 80 00       	push   $0x80215f
  800c06:	6a 23                	push   $0x23
  800c08:	68 7c 21 80 00       	push   $0x80217c
  800c0d:	e8 b2 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 0a                	push   $0xa
  800c43:	68 5f 21 80 00       	push   $0x80215f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 7c 21 80 00       	push   $0x80217c
  800c4f:	e8 70 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	be 00 00 00 00       	mov    $0x0,%esi
  800c67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 cb                	mov    %ecx,%ebx
  800c97:	89 cf                	mov    %ecx,%edi
  800c99:	89 ce                	mov    %ecx,%esi
  800c9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 17                	jle    800cb8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 0d                	push   $0xd
  800ca7:	68 5f 21 80 00       	push   $0x80215f
  800cac:	6a 23                	push   $0x23
  800cae:	68 7c 21 80 00       	push   $0x80217c
  800cb3:	e8 0c 0d 00 00       	call   8019c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_gettime>:

int sys_gettime(void)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cd0:	89 d1                	mov    %edx,%ecx
  800cd2:	89 d3                	mov    %edx,%ebx
  800cd4:	89 d7                	mov    %edx,%edi
  800cd6:	89 d6                	mov    %edx,%esi
  800cd8:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	05 00 00 00 30       	add    $0x30000000,%eax
  800cea:	c1 e8 0c             	shr    $0xc,%eax
}
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800cfa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cff:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d11:	89 c2                	mov    %eax,%edx
  800d13:	c1 ea 16             	shr    $0x16,%edx
  800d16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d1d:	f6 c2 01             	test   $0x1,%dl
  800d20:	74 11                	je     800d33 <fd_alloc+0x2d>
  800d22:	89 c2                	mov    %eax,%edx
  800d24:	c1 ea 0c             	shr    $0xc,%edx
  800d27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d2e:	f6 c2 01             	test   $0x1,%dl
  800d31:	75 09                	jne    800d3c <fd_alloc+0x36>
			*fd_store = fd;
  800d33:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	eb 17                	jmp    800d53 <fd_alloc+0x4d>
  800d3c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d41:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d46:	75 c9                	jne    800d11 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d48:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d5b:	83 f8 1f             	cmp    $0x1f,%eax
  800d5e:	77 36                	ja     800d96 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d60:	c1 e0 0c             	shl    $0xc,%eax
  800d63:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	c1 ea 16             	shr    $0x16,%edx
  800d6d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d74:	f6 c2 01             	test   $0x1,%dl
  800d77:	74 24                	je     800d9d <fd_lookup+0x48>
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	c1 ea 0c             	shr    $0xc,%edx
  800d7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d85:	f6 c2 01             	test   $0x1,%dl
  800d88:	74 1a                	je     800da4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8d:	89 02                	mov    %eax,(%edx)
	return 0;
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	eb 13                	jmp    800da9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d9b:	eb 0c                	jmp    800da9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da2:	eb 05                	jmp    800da9 <fd_lookup+0x54>
  800da4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 08             	sub    $0x8,%esp
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800db9:	eb 13                	jmp    800dce <dev_lookup+0x23>
  800dbb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dbe:	39 08                	cmp    %ecx,(%eax)
  800dc0:	75 0c                	jne    800dce <dev_lookup+0x23>
			*dev = devtab[i];
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	eb 2e                	jmp    800dfc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dce:	8b 02                	mov    (%edx),%eax
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	75 e7                	jne    800dbb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dd4:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd9:	8b 40 48             	mov    0x48(%eax),%eax
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	51                   	push   %ecx
  800de0:	50                   	push   %eax
  800de1:	68 8c 21 80 00       	push   $0x80218c
  800de6:	e8 56 f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 10             	sub    $0x10,%esp
  800e06:	8b 75 08             	mov    0x8(%ebp),%esi
  800e09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e0f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e10:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e16:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e19:	50                   	push   %eax
  800e1a:	e8 36 ff ff ff       	call   800d55 <fd_lookup>
  800e1f:	83 c4 08             	add    $0x8,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	78 05                	js     800e2b <fd_close+0x2d>
	    || fd != fd2)
  800e26:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e29:	74 0b                	je     800e36 <fd_close+0x38>
		return (must_exist ? r : 0);
  800e2b:	80 fb 01             	cmp    $0x1,%bl
  800e2e:	19 d2                	sbb    %edx,%edx
  800e30:	f7 d2                	not    %edx
  800e32:	21 d0                	and    %edx,%eax
  800e34:	eb 41                	jmp    800e77 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e3c:	50                   	push   %eax
  800e3d:	ff 36                	pushl  (%esi)
  800e3f:	e8 67 ff ff ff       	call   800dab <dev_lookup>
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 1a                	js     800e67 <fd_close+0x69>
		if (dev->dev_close)
  800e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e50:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	74 0b                	je     800e67 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	56                   	push   %esi
  800e60:	ff d0                	call   *%eax
  800e62:	89 c3                	mov    %eax,%ebx
  800e64:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	56                   	push   %esi
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 e2 fc ff ff       	call   800b54 <sys_page_unmap>
	return r;
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	89 d8                	mov    %ebx,%eax
}
  800e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e87:	50                   	push   %eax
  800e88:	ff 75 08             	pushl  0x8(%ebp)
  800e8b:	e8 c5 fe ff ff       	call   800d55 <fd_lookup>
  800e90:	89 c2                	mov    %eax,%edx
  800e92:	83 c4 08             	add    $0x8,%esp
  800e95:	85 d2                	test   %edx,%edx
  800e97:	78 10                	js     800ea9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	6a 01                	push   $0x1
  800e9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea1:	e8 58 ff ff ff       	call   800dfe <fd_close>
  800ea6:	83 c4 10             	add    $0x10,%esp
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <close_all>:

void
close_all(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	53                   	push   %ebx
  800ebb:	e8 be ff ff ff       	call   800e7e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec0:	83 c3 01             	add    $0x1,%ebx
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	83 fb 20             	cmp    $0x20,%ebx
  800ec9:	75 ec                	jne    800eb7 <close_all+0xc>
		close(i);
}
  800ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
  800ed9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800edc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800edf:	50                   	push   %eax
  800ee0:	ff 75 08             	pushl  0x8(%ebp)
  800ee3:	e8 6d fe ff ff       	call   800d55 <fd_lookup>
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	83 c4 08             	add    $0x8,%esp
  800eed:	85 d2                	test   %edx,%edx
  800eef:	0f 88 c1 00 00 00    	js     800fb6 <dup+0xe6>
		return r;
	close(newfdnum);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	56                   	push   %esi
  800ef9:	e8 80 ff ff ff       	call   800e7e <close>

	newfd = INDEX2FD(newfdnum);
  800efe:	89 f3                	mov    %esi,%ebx
  800f00:	c1 e3 0c             	shl    $0xc,%ebx
  800f03:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f09:	83 c4 04             	add    $0x4,%esp
  800f0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f0f:	e8 db fd ff ff       	call   800cef <fd2data>
  800f14:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f16:	89 1c 24             	mov    %ebx,(%esp)
  800f19:	e8 d1 fd ff ff       	call   800cef <fd2data>
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f24:	89 f8                	mov    %edi,%eax
  800f26:	c1 e8 16             	shr    $0x16,%eax
  800f29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f30:	a8 01                	test   $0x1,%al
  800f32:	74 37                	je     800f6b <dup+0x9b>
  800f34:	89 f8                	mov    %edi,%eax
  800f36:	c1 e8 0c             	shr    $0xc,%eax
  800f39:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f40:	f6 c2 01             	test   $0x1,%dl
  800f43:	74 26                	je     800f6b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f54:	50                   	push   %eax
  800f55:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f58:	6a 00                	push   $0x0
  800f5a:	57                   	push   %edi
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 b0 fb ff ff       	call   800b12 <sys_page_map>
  800f62:	89 c7                	mov    %eax,%edi
  800f64:	83 c4 20             	add    $0x20,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 2e                	js     800f99 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f6e:	89 d0                	mov    %edx,%eax
  800f70:	c1 e8 0c             	shr    $0xc,%eax
  800f73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f82:	50                   	push   %eax
  800f83:	53                   	push   %ebx
  800f84:	6a 00                	push   $0x0
  800f86:	52                   	push   %edx
  800f87:	6a 00                	push   $0x0
  800f89:	e8 84 fb ff ff       	call   800b12 <sys_page_map>
  800f8e:	89 c7                	mov    %eax,%edi
  800f90:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f93:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f95:	85 ff                	test   %edi,%edi
  800f97:	79 1d                	jns    800fb6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	53                   	push   %ebx
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 b0 fb ff ff       	call   800b54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800faa:	6a 00                	push   $0x0
  800fac:	e8 a3 fb ff ff       	call   800b54 <sys_page_unmap>
	return r;
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	89 f8                	mov    %edi,%eax
}
  800fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 14             	sub    $0x14,%esp
  800fc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	53                   	push   %ebx
  800fcd:	e8 83 fd ff ff       	call   800d55 <fd_lookup>
  800fd2:	83 c4 08             	add    $0x8,%esp
  800fd5:	89 c2                	mov    %eax,%edx
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 6d                	js     801048 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe1:	50                   	push   %eax
  800fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe5:	ff 30                	pushl  (%eax)
  800fe7:	e8 bf fd ff ff       	call   800dab <dev_lookup>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 4c                	js     80103f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ff3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff6:	8b 42 08             	mov    0x8(%edx),%eax
  800ff9:	83 e0 03             	and    $0x3,%eax
  800ffc:	83 f8 01             	cmp    $0x1,%eax
  800fff:	75 21                	jne    801022 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801001:	a1 04 40 80 00       	mov    0x804004,%eax
  801006:	8b 40 48             	mov    0x48(%eax),%eax
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	53                   	push   %ebx
  80100d:	50                   	push   %eax
  80100e:	68 cd 21 80 00       	push   $0x8021cd
  801013:	e8 29 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801020:	eb 26                	jmp    801048 <read+0x8a>
	}
	if (!dev->dev_read)
  801022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801025:	8b 40 08             	mov    0x8(%eax),%eax
  801028:	85 c0                	test   %eax,%eax
  80102a:	74 17                	je     801043 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80102c:	83 ec 04             	sub    $0x4,%esp
  80102f:	ff 75 10             	pushl  0x10(%ebp)
  801032:	ff 75 0c             	pushl  0xc(%ebp)
  801035:	52                   	push   %edx
  801036:	ff d0                	call   *%eax
  801038:	89 c2                	mov    %eax,%edx
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	eb 09                	jmp    801048 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80103f:	89 c2                	mov    %eax,%edx
  801041:	eb 05                	jmp    801048 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801043:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801048:	89 d0                	mov    %edx,%eax
  80104a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	8b 7d 08             	mov    0x8(%ebp),%edi
  80105b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80105e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801063:	eb 21                	jmp    801086 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	89 f0                	mov    %esi,%eax
  80106a:	29 d8                	sub    %ebx,%eax
  80106c:	50                   	push   %eax
  80106d:	89 d8                	mov    %ebx,%eax
  80106f:	03 45 0c             	add    0xc(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	57                   	push   %edi
  801074:	e8 45 ff ff ff       	call   800fbe <read>
		if (m < 0)
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	78 0c                	js     80108c <readn+0x3d>
			return m;
		if (m == 0)
  801080:	85 c0                	test   %eax,%eax
  801082:	74 06                	je     80108a <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801084:	01 c3                	add    %eax,%ebx
  801086:	39 f3                	cmp    %esi,%ebx
  801088:	72 db                	jb     801065 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80108a:	89 d8                	mov    %ebx,%eax
}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 14             	sub    $0x14,%esp
  80109b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	53                   	push   %ebx
  8010a3:	e8 ad fc ff ff       	call   800d55 <fd_lookup>
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 68                	js     801119 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b7:	50                   	push   %eax
  8010b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bb:	ff 30                	pushl  (%eax)
  8010bd:	e8 e9 fc ff ff       	call   800dab <dev_lookup>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 47                	js     801110 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010d0:	75 21                	jne    8010f3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d7:	8b 40 48             	mov    0x48(%eax),%eax
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	53                   	push   %ebx
  8010de:	50                   	push   %eax
  8010df:	68 e9 21 80 00       	push   $0x8021e9
  8010e4:	e8 58 f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010f1:	eb 26                	jmp    801119 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8010f9:	85 d2                	test   %edx,%edx
  8010fb:	74 17                	je     801114 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	ff 75 10             	pushl  0x10(%ebp)
  801103:	ff 75 0c             	pushl  0xc(%ebp)
  801106:	50                   	push   %eax
  801107:	ff d2                	call   *%edx
  801109:	89 c2                	mov    %eax,%edx
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	eb 09                	jmp    801119 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801110:	89 c2                	mov    %eax,%edx
  801112:	eb 05                	jmp    801119 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801114:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801119:	89 d0                	mov    %edx,%eax
  80111b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    

00801120 <seek>:

int
seek(int fdnum, off_t offset)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801126:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	ff 75 08             	pushl  0x8(%ebp)
  80112d:	e8 23 fc ff ff       	call   800d55 <fd_lookup>
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 0e                	js     801147 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801139:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80113c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	83 ec 14             	sub    $0x14,%esp
  801150:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801153:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	53                   	push   %ebx
  801158:	e8 f8 fb ff ff       	call   800d55 <fd_lookup>
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	89 c2                	mov    %eax,%edx
  801162:	85 c0                	test   %eax,%eax
  801164:	78 65                	js     8011cb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801170:	ff 30                	pushl  (%eax)
  801172:	e8 34 fc ff ff       	call   800dab <dev_lookup>
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 44                	js     8011c2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80117e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801181:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801185:	75 21                	jne    8011a8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801187:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80118c:	8b 40 48             	mov    0x48(%eax),%eax
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	53                   	push   %ebx
  801193:	50                   	push   %eax
  801194:	68 ac 21 80 00       	push   $0x8021ac
  801199:	e8 a3 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a6:	eb 23                	jmp    8011cb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ab:	8b 52 18             	mov    0x18(%edx),%edx
  8011ae:	85 d2                	test   %edx,%edx
  8011b0:	74 14                	je     8011c6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	ff 75 0c             	pushl  0xc(%ebp)
  8011b8:	50                   	push   %eax
  8011b9:	ff d2                	call   *%edx
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	eb 09                	jmp    8011cb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	eb 05                	jmp    8011cb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011cb:	89 d0                	mov    %edx,%eax
  8011cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 14             	sub    $0x14,%esp
  8011d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	ff 75 08             	pushl  0x8(%ebp)
  8011e3:	e8 6d fb ff ff       	call   800d55 <fd_lookup>
  8011e8:	83 c4 08             	add    $0x8,%esp
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 58                	js     801249 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	ff 30                	pushl  (%eax)
  8011fd:	e8 a9 fb ff ff       	call   800dab <dev_lookup>
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 37                	js     801240 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801210:	74 32                	je     801244 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801212:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801215:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80121c:	00 00 00 
	stat->st_isdir = 0;
  80121f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801226:	00 00 00 
	stat->st_dev = dev;
  801229:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	53                   	push   %ebx
  801233:	ff 75 f0             	pushl  -0x10(%ebp)
  801236:	ff 50 14             	call   *0x14(%eax)
  801239:	89 c2                	mov    %eax,%edx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	eb 09                	jmp    801249 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	89 c2                	mov    %eax,%edx
  801242:	eb 05                	jmp    801249 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801244:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801249:	89 d0                	mov    %edx,%eax
  80124b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	6a 00                	push   $0x0
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 e7 01 00 00       	call   801449 <open>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 db                	test   %ebx,%ebx
  801269:	78 1b                	js     801286 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	ff 75 0c             	pushl  0xc(%ebp)
  801271:	53                   	push   %ebx
  801272:	e8 5b ff ff ff       	call   8011d2 <fstat>
  801277:	89 c6                	mov    %eax,%esi
	close(fd);
  801279:	89 1c 24             	mov    %ebx,(%esp)
  80127c:	e8 fd fb ff ff       	call   800e7e <close>
	return r;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	89 f0                	mov    %esi,%eax
}
  801286:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	89 c6                	mov    %eax,%esi
  801294:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801296:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80129d:	75 12                	jne    8012b1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	6a 03                	push   $0x3
  8012a4:	e8 18 08 00 00       	call   801ac1 <ipc_find_env>
  8012a9:	a3 00 40 80 00       	mov    %eax,0x804000
  8012ae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012b1:	6a 07                	push   $0x7
  8012b3:	68 00 50 80 00       	push   $0x805000
  8012b8:	56                   	push   %esi
  8012b9:	ff 35 00 40 80 00    	pushl  0x804000
  8012bf:	e8 ac 07 00 00       	call   801a70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012c4:	83 c4 0c             	add    $0xc,%esp
  8012c7:	6a 00                	push   $0x0
  8012c9:	53                   	push   %ebx
  8012ca:	6a 00                	push   $0x0
  8012cc:	e8 39 07 00 00       	call   801a0a <ipc_recv>
}
  8012d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8012e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8012fb:	e8 8d ff ff ff       	call   80128d <fsipc>
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801308:	8b 45 08             	mov    0x8(%ebp),%eax
  80130b:	8b 40 0c             	mov    0xc(%eax),%eax
  80130e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801313:	ba 00 00 00 00       	mov    $0x0,%edx
  801318:	b8 06 00 00 00       	mov    $0x6,%eax
  80131d:	e8 6b ff ff ff       	call   80128d <fsipc>
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 04             	sub    $0x4,%esp
  80132b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	8b 40 0c             	mov    0xc(%eax),%eax
  801334:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801339:	ba 00 00 00 00       	mov    $0x0,%edx
  80133e:	b8 05 00 00 00       	mov    $0x5,%eax
  801343:	e8 45 ff ff ff       	call   80128d <fsipc>
  801348:	89 c2                	mov    %eax,%edx
  80134a:	85 d2                	test   %edx,%edx
  80134c:	78 2c                	js     80137a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	68 00 50 80 00       	push   $0x805000
  801356:	53                   	push   %ebx
  801357:	e8 69 f3 ff ff       	call   8006c5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80135c:	a1 80 50 80 00       	mov    0x805080,%eax
  801361:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801367:	a1 84 50 80 00       	mov    0x805084,%eax
  80136c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801388:	8b 55 08             	mov    0x8(%ebp),%edx
  80138b:	8b 52 0c             	mov    0xc(%edx),%edx
  80138e:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801394:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801399:	76 05                	jbe    8013a0 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80139b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8013a0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ac:	68 08 50 80 00       	push   $0x805008
  8013b1:	e8 a1 f4 ff ff       	call   800857 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8013b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8013c0:	e8 c8 fe ff ff       	call   80128d <fsipc>
	return write;
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013da:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ea:	e8 9e fe ff ff       	call   80128d <fsipc>
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 4b                	js     801440 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013f5:	39 c6                	cmp    %eax,%esi
  8013f7:	73 16                	jae    80140f <devfile_read+0x48>
  8013f9:	68 18 22 80 00       	push   $0x802218
  8013fe:	68 1f 22 80 00       	push   $0x80221f
  801403:	6a 7c                	push   $0x7c
  801405:	68 34 22 80 00       	push   $0x802234
  80140a:	e8 b5 05 00 00       	call   8019c4 <_panic>
	assert(r <= PGSIZE);
  80140f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801414:	7e 16                	jle    80142c <devfile_read+0x65>
  801416:	68 3f 22 80 00       	push   $0x80223f
  80141b:	68 1f 22 80 00       	push   $0x80221f
  801420:	6a 7d                	push   $0x7d
  801422:	68 34 22 80 00       	push   $0x802234
  801427:	e8 98 05 00 00       	call   8019c4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	50                   	push   %eax
  801430:	68 00 50 80 00       	push   $0x805000
  801435:	ff 75 0c             	pushl  0xc(%ebp)
  801438:	e8 1a f4 ff ff       	call   800857 <memmove>
	return r;
  80143d:	83 c4 10             	add    $0x10,%esp
}
  801440:	89 d8                	mov    %ebx,%eax
  801442:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801445:	5b                   	pop    %ebx
  801446:	5e                   	pop    %esi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 20             	sub    $0x20,%esp
  801450:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801453:	53                   	push   %ebx
  801454:	e8 33 f2 ff ff       	call   80068c <strlen>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801461:	7f 67                	jg     8014ca <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	e8 97 f8 ff ff       	call   800d06 <fd_alloc>
  80146f:	83 c4 10             	add    $0x10,%esp
		return r;
  801472:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	78 57                	js     8014cf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	53                   	push   %ebx
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	e8 3f f2 ff ff       	call   8006c5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80148e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801491:	b8 01 00 00 00       	mov    $0x1,%eax
  801496:	e8 f2 fd ff ff       	call   80128d <fsipc>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	79 14                	jns    8014b8 <open+0x6f>
		fd_close(fd, 0);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	6a 00                	push   $0x0
  8014a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ac:	e8 4d f9 ff ff       	call   800dfe <fd_close>
		return r;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	89 da                	mov    %ebx,%edx
  8014b6:	eb 17                	jmp    8014cf <open+0x86>
	}

	return fd2num(fd);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014be:	e8 1c f8 ff ff       	call   800cdf <fd2num>
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 05                	jmp    8014cf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014ca:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014cf:	89 d0                	mov    %edx,%eax
  8014d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e6:	e8 a2 fd ff ff       	call   80128d <fsipc>
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	e8 ef f7 ff ff       	call   800cef <fd2data>
  801500:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	68 4b 22 80 00       	push   $0x80224b
  80150a:	53                   	push   %ebx
  80150b:	e8 b5 f1 ff ff       	call   8006c5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801510:	8b 56 04             	mov    0x4(%esi),%edx
  801513:	89 d0                	mov    %edx,%eax
  801515:	2b 06                	sub    (%esi),%eax
  801517:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80151d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801524:	00 00 00 
	stat->st_dev = &devpipe;
  801527:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80152e:	30 80 00 
	return 0;
}
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
  801536:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801547:	53                   	push   %ebx
  801548:	6a 00                	push   $0x0
  80154a:	e8 05 f6 ff ff       	call   800b54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80154f:	89 1c 24             	mov    %ebx,(%esp)
  801552:	e8 98 f7 ff ff       	call   800cef <fd2data>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	50                   	push   %eax
  80155b:	6a 00                	push   $0x0
  80155d:	e8 f2 f5 ff ff       	call   800b54 <sys_page_unmap>
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	57                   	push   %edi
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 1c             	sub    $0x1c,%esp
  801570:	89 c7                	mov    %eax,%edi
  801572:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801574:	a1 04 40 80 00       	mov    0x804004,%eax
  801579:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	57                   	push   %edi
  801580:	e8 74 05 00 00       	call   801af9 <pageref>
  801585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801588:	89 34 24             	mov    %esi,(%esp)
  80158b:	e8 69 05 00 00       	call   801af9 <pageref>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801596:	0f 94 c0             	sete   %al
  801599:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80159c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015a2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a5:	39 cb                	cmp    %ecx,%ebx
  8015a7:	74 15                	je     8015be <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8015a9:	8b 52 58             	mov    0x58(%edx),%edx
  8015ac:	50                   	push   %eax
  8015ad:	52                   	push   %edx
  8015ae:	53                   	push   %ebx
  8015af:	68 58 22 80 00       	push   $0x802258
  8015b4:	e8 88 eb ff ff       	call   800141 <cprintf>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb b6                	jmp    801574 <_pipeisclosed+0xd>
	}
}
  8015be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	57                   	push   %edi
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 28             	sub    $0x28,%esp
  8015cf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015d2:	56                   	push   %esi
  8015d3:	e8 17 f7 ff ff       	call   800cef <fd2data>
  8015d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e2:	eb 4b                	jmp    80162f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015e4:	89 da                	mov    %ebx,%edx
  8015e6:	89 f0                	mov    %esi,%eax
  8015e8:	e8 7a ff ff ff       	call   801567 <_pipeisclosed>
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	75 48                	jne    801639 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015f1:	e8 ba f4 ff ff       	call   800ab0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f9:	8b 0b                	mov    (%ebx),%ecx
  8015fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8015fe:	39 d0                	cmp    %edx,%eax
  801600:	73 e2                	jae    8015e4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801602:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801605:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801609:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	c1 fa 1f             	sar    $0x1f,%edx
  801611:	89 d1                	mov    %edx,%ecx
  801613:	c1 e9 1b             	shr    $0x1b,%ecx
  801616:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801619:	83 e2 1f             	and    $0x1f,%edx
  80161c:	29 ca                	sub    %ecx,%edx
  80161e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801622:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801626:	83 c0 01             	add    $0x1,%eax
  801629:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162c:	83 c7 01             	add    $0x1,%edi
  80162f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801632:	75 c2                	jne    8015f6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801634:	8b 45 10             	mov    0x10(%ebp),%eax
  801637:	eb 05                	jmp    80163e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 18             	sub    $0x18,%esp
  80164f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801652:	57                   	push   %edi
  801653:	e8 97 f6 ff ff       	call   800cef <fd2data>
  801658:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801662:	eb 3d                	jmp    8016a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801664:	85 db                	test   %ebx,%ebx
  801666:	74 04                	je     80166c <devpipe_read+0x26>
				return i;
  801668:	89 d8                	mov    %ebx,%eax
  80166a:	eb 44                	jmp    8016b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80166c:	89 f2                	mov    %esi,%edx
  80166e:	89 f8                	mov    %edi,%eax
  801670:	e8 f2 fe ff ff       	call   801567 <_pipeisclosed>
  801675:	85 c0                	test   %eax,%eax
  801677:	75 32                	jne    8016ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801679:	e8 32 f4 ff ff       	call   800ab0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80167e:	8b 06                	mov    (%esi),%eax
  801680:	3b 46 04             	cmp    0x4(%esi),%eax
  801683:	74 df                	je     801664 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801685:	99                   	cltd   
  801686:	c1 ea 1b             	shr    $0x1b,%edx
  801689:	01 d0                	add    %edx,%eax
  80168b:	83 e0 1f             	and    $0x1f,%eax
  80168e:	29 d0                	sub    %edx,%eax
  801690:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801698:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80169b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169e:	83 c3 01             	add    $0x1,%ebx
  8016a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016a4:	75 d8                	jne    80167e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a9:	eb 05                	jmp    8016b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5f                   	pop    %edi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	e8 3d f6 ff ff       	call   800d06 <fd_alloc>
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 88 2c 01 00 00    	js     801802 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	68 07 04 00 00       	push   $0x407
  8016de:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e1:	6a 00                	push   $0x0
  8016e3:	e8 e7 f3 ff ff       	call   800acf <sys_page_alloc>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	89 c2                	mov    %eax,%edx
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	0f 88 0d 01 00 00    	js     801802 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	e8 05 f6 ff ff       	call   800d06 <fd_alloc>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	0f 88 e2 00 00 00    	js     8017f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	68 07 04 00 00       	push   $0x407
  801716:	ff 75 f0             	pushl  -0x10(%ebp)
  801719:	6a 00                	push   $0x0
  80171b:	e8 af f3 ff ff       	call   800acf <sys_page_alloc>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 c3 00 00 00    	js     8017f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	ff 75 f4             	pushl  -0xc(%ebp)
  801733:	e8 b7 f5 ff ff       	call   800cef <fd2data>
  801738:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173a:	83 c4 0c             	add    $0xc,%esp
  80173d:	68 07 04 00 00       	push   $0x407
  801742:	50                   	push   %eax
  801743:	6a 00                	push   $0x0
  801745:	e8 85 f3 ff ff       	call   800acf <sys_page_alloc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 88 89 00 00 00    	js     8017e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	ff 75 f0             	pushl  -0x10(%ebp)
  80175d:	e8 8d f5 ff ff       	call   800cef <fd2data>
  801762:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801769:	50                   	push   %eax
  80176a:	6a 00                	push   $0x0
  80176c:	56                   	push   %esi
  80176d:	6a 00                	push   $0x0
  80176f:	e8 9e f3 ff ff       	call   800b12 <sys_page_map>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 20             	add    $0x20,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 55                	js     8017d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80177d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801786:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801792:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801798:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ad:	e8 2d f5 ff ff       	call   800cdf <fd2num>
  8017b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017b7:	83 c4 04             	add    $0x4,%esp
  8017ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bd:	e8 1d f5 ff ff       	call   800cdf <fd2num>
  8017c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	eb 30                	jmp    801802 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	56                   	push   %esi
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 77 f3 ff ff       	call   800b54 <sys_page_unmap>
  8017dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 67 f3 ff ff       	call   800b54 <sys_page_unmap>
  8017ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 57 f3 ff ff       	call   800b54 <sys_page_unmap>
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801802:	89 d0                	mov    %edx,%eax
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	50                   	push   %eax
  801815:	ff 75 08             	pushl  0x8(%ebp)
  801818:	e8 38 f5 ff ff       	call   800d55 <fd_lookup>
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	85 d2                	test   %edx,%edx
  801824:	78 18                	js     80183e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	e8 be f4 ff ff       	call   800cef <fd2data>
	return _pipeisclosed(fd, p);
  801831:	89 c2                	mov    %eax,%edx
  801833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801836:	e8 2c fd ff ff       	call   801567 <_pipeisclosed>
  80183b:	83 c4 10             	add    $0x10,%esp
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801850:	68 89 22 80 00       	push   $0x802289
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	e8 68 ee ff ff       	call   8006c5 <strcpy>
	return 0;
}
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	57                   	push   %edi
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801870:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801875:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187b:	eb 2e                	jmp    8018ab <devcons_write+0x47>
		m = n - tot;
  80187d:	8b 55 10             	mov    0x10(%ebp),%edx
  801880:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801882:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801887:	83 fa 7f             	cmp    $0x7f,%edx
  80188a:	77 02                	ja     80188e <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80188c:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	56                   	push   %esi
  801892:	03 45 0c             	add    0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	57                   	push   %edi
  801897:	e8 bb ef ff ff       	call   800857 <memmove>
		sys_cputs(buf, m);
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	56                   	push   %esi
  8018a0:	57                   	push   %edi
  8018a1:	e8 6d f1 ff ff       	call   800a13 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a6:	01 f3                	add    %esi,%ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	89 d8                	mov    %ebx,%eax
  8018ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018b0:	72 cb                	jb     80187d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5e                   	pop    %esi
  8018b7:	5f                   	pop    %edi
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018c0:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c9:	75 07                	jne    8018d2 <devcons_read+0x18>
  8018cb:	eb 28                	jmp    8018f5 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018cd:	e8 de f1 ff ff       	call   800ab0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018d2:	e8 5a f1 ff ff       	call   800a31 <sys_cgetc>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	74 f2                	je     8018cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 16                	js     8018f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018df:	83 f8 04             	cmp    $0x4,%eax
  8018e2:	74 0c                	je     8018f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e7:	88 02                	mov    %al,(%edx)
	return 1;
  8018e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ee:	eb 05                	jmp    8018f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801903:	6a 01                	push   $0x1
  801905:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	e8 05 f1 ff ff       	call   800a13 <sys_cputs>
  80190e:	83 c4 10             	add    $0x10,%esp
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <getchar>:

int
getchar(void)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801919:	6a 01                	push   $0x1
  80191b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	6a 00                	push   $0x0
  801921:	e8 98 f6 ff ff       	call   800fbe <read>
	if (r < 0)
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 0f                	js     80193c <getchar+0x29>
		return r;
	if (r < 1)
  80192d:	85 c0                	test   %eax,%eax
  80192f:	7e 06                	jle    801937 <getchar+0x24>
		return -E_EOF;
	return c;
  801931:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801935:	eb 05                	jmp    80193c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801937:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	ff 75 08             	pushl  0x8(%ebp)
  80194b:	e8 05 f4 ff ff       	call   800d55 <fd_lookup>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	78 11                	js     801968 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801960:	39 10                	cmp    %edx,(%eax)
  801962:	0f 94 c0             	sete   %al
  801965:	0f b6 c0             	movzbl %al,%eax
}
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <opencons>:

int
opencons(void)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 8d f3 ff ff       	call   800d06 <fd_alloc>
  801979:	83 c4 10             	add    $0x10,%esp
		return r;
  80197c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 3e                	js     8019c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801982:	83 ec 04             	sub    $0x4,%esp
  801985:	68 07 04 00 00       	push   $0x407
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	6a 00                	push   $0x0
  80198f:	e8 3b f1 ff ff       	call   800acf <sys_page_alloc>
  801994:	83 c4 10             	add    $0x10,%esp
		return r;
  801997:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 23                	js     8019c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80199d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	50                   	push   %eax
  8019b6:	e8 24 f3 ff ff       	call   800cdf <fd2num>
  8019bb:	89 c2                	mov    %eax,%edx
  8019bd:	83 c4 10             	add    $0x10,%esp
}
  8019c0:	89 d0                	mov    %edx,%eax
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019cc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019d2:	e8 ba f0 ff ff       	call   800a91 <sys_getenvid>
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	56                   	push   %esi
  8019e1:	50                   	push   %eax
  8019e2:	68 98 22 80 00       	push   $0x802298
  8019e7:	e8 55 e7 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ec:	83 c4 18             	add    $0x18,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	e8 f8 e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  8019f8:	c7 04 24 1c 1e 80 00 	movl   $0x801e1c,(%esp)
  8019ff:	e8 3d e7 ff ff       	call   800141 <cprintf>
  801a04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a07:	cc                   	int3   
  801a08:	eb fd                	jmp    801a07 <_panic+0x43>

00801a0a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a18:	85 f6                	test   %esi,%esi
  801a1a:	74 06                	je     801a22 <ipc_recv+0x18>
  801a1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a22:	85 db                	test   %ebx,%ebx
  801a24:	74 06                	je     801a2c <ipc_recv+0x22>
  801a26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a2c:	83 f8 01             	cmp    $0x1,%eax
  801a2f:	19 d2                	sbb    %edx,%edx
  801a31:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	50                   	push   %eax
  801a37:	e8 43 f2 ff ff       	call   800c7f <sys_ipc_recv>
  801a3c:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 d2                	test   %edx,%edx
  801a43:	75 24                	jne    801a69 <ipc_recv+0x5f>
	if (from_env_store)
  801a45:	85 f6                	test   %esi,%esi
  801a47:	74 0a                	je     801a53 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a49:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4e:	8b 40 70             	mov    0x70(%eax),%eax
  801a51:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a53:	85 db                	test   %ebx,%ebx
  801a55:	74 0a                	je     801a61 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 40 74             	mov    0x74(%eax),%eax
  801a5f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a61:	a1 04 40 80 00       	mov    0x804004,%eax
  801a66:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a82:	83 fb 01             	cmp    $0x1,%ebx
  801a85:	19 c0                	sbb    %eax,%eax
  801a87:	09 c3                	or     %eax,%ebx
  801a89:	eb 1c                	jmp    801aa7 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a8b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8e:	74 12                	je     801aa2 <ipc_send+0x32>
  801a90:	50                   	push   %eax
  801a91:	68 bc 22 80 00       	push   $0x8022bc
  801a96:	6a 36                	push   $0x36
  801a98:	68 d3 22 80 00       	push   $0x8022d3
  801a9d:	e8 22 ff ff ff       	call   8019c4 <_panic>
		sys_yield();
  801aa2:	e8 09 f0 ff ff       	call   800ab0 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa7:	ff 75 14             	pushl  0x14(%ebp)
  801aaa:	53                   	push   %ebx
  801aab:	56                   	push   %esi
  801aac:	57                   	push   %edi
  801aad:	e8 aa f1 ff ff       	call   800c5c <sys_ipc_try_send>
		if (ret == 0) break;
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	75 d2                	jne    801a8b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acc:	6b d0 78             	imul   $0x78,%eax,%edx
  801acf:	83 c2 50             	add    $0x50,%edx
  801ad2:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ad8:	39 ca                	cmp    %ecx,%edx
  801ada:	75 0d                	jne    801ae9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801adc:	6b c0 78             	imul   $0x78,%eax,%eax
  801adf:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae4:	8b 40 08             	mov    0x8(%eax),%eax
  801ae7:	eb 0e                	jmp    801af7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af1:	75 d9                	jne    801acc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af3:	66 b8 00 00          	mov    $0x0,%ax
}
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aff:	89 d0                	mov    %edx,%eax
  801b01:	c1 e8 16             	shr    $0x16,%eax
  801b04:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	f6 c1 01             	test   $0x1,%cl
  801b13:	74 1d                	je     801b32 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b15:	c1 ea 0c             	shr    $0xc,%edx
  801b18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1f:	f6 c2 01             	test   $0x1,%dl
  801b22:	74 0e                	je     801b32 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b24:	c1 ea 0c             	shr    $0xc,%edx
  801b27:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2e:	ef 
  801b2f:	0f b7 c0             	movzwl %ax,%eax
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    
  801b34:	66 90                	xchg   %ax,%ax
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	66 90                	xchg   %ax,%ax
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	83 ec 10             	sub    $0x10,%esp
  801b46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b56:	85 d2                	test   %edx,%edx
  801b58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b5c:	89 34 24             	mov    %esi,(%esp)
  801b5f:	89 c8                	mov    %ecx,%eax
  801b61:	75 35                	jne    801b98 <__udivdi3+0x58>
  801b63:	39 f1                	cmp    %esi,%ecx
  801b65:	0f 87 bd 00 00 00    	ja     801c28 <__udivdi3+0xe8>
  801b6b:	85 c9                	test   %ecx,%ecx
  801b6d:	89 cd                	mov    %ecx,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f1                	div    %ecx
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c6                	mov    %eax,%esi
  801b84:	89 f8                	mov    %edi,%eax
  801b86:	f7 f5                	div    %ebp
  801b88:	89 f2                	mov    %esi,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b98:	3b 14 24             	cmp    (%esp),%edx
  801b9b:	77 7b                	ja     801c18 <__udivdi3+0xd8>
  801b9d:	0f bd f2             	bsr    %edx,%esi
  801ba0:	83 f6 1f             	xor    $0x1f,%esi
  801ba3:	0f 84 97 00 00 00    	je     801c40 <__udivdi3+0x100>
  801ba9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bae:	89 d7                	mov    %edx,%edi
  801bb0:	89 f1                	mov    %esi,%ecx
  801bb2:	29 f5                	sub    %esi,%ebp
  801bb4:	d3 e7                	shl    %cl,%edi
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	89 e9                	mov    %ebp,%ecx
  801bba:	d3 ea                	shr    %cl,%edx
  801bbc:	89 f1                	mov    %esi,%ecx
  801bbe:	09 fa                	or     %edi,%edx
  801bc0:	8b 3c 24             	mov    (%esp),%edi
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bc9:	89 e9                	mov    %ebp,%ecx
  801bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bd3:	89 fa                	mov    %edi,%edx
  801bd5:	d3 ea                	shr    %cl,%edx
  801bd7:	89 f1                	mov    %esi,%ecx
  801bd9:	d3 e7                	shl    %cl,%edi
  801bdb:	89 e9                	mov    %ebp,%ecx
  801bdd:	d3 e8                	shr    %cl,%eax
  801bdf:	09 c7                	or     %eax,%edi
  801be1:	89 f8                	mov    %edi,%eax
  801be3:	f7 74 24 08          	divl   0x8(%esp)
  801be7:	89 d5                	mov    %edx,%ebp
  801be9:	89 c7                	mov    %eax,%edi
  801beb:	f7 64 24 0c          	mull   0xc(%esp)
  801bef:	39 d5                	cmp    %edx,%ebp
  801bf1:	89 14 24             	mov    %edx,(%esp)
  801bf4:	72 11                	jb     801c07 <__udivdi3+0xc7>
  801bf6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bfa:	89 f1                	mov    %esi,%ecx
  801bfc:	d3 e2                	shl    %cl,%edx
  801bfe:	39 c2                	cmp    %eax,%edx
  801c00:	73 5e                	jae    801c60 <__udivdi3+0x120>
  801c02:	3b 2c 24             	cmp    (%esp),%ebp
  801c05:	75 59                	jne    801c60 <__udivdi3+0x120>
  801c07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c0a:	31 f6                	xor    %esi,%esi
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	31 c0                	xor    %eax,%eax
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	f7 f1                	div    %ecx
  801c30:	89 f2                	mov    %esi,%edx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c44:	76 0b                	jbe    801c51 <__udivdi3+0x111>
  801c46:	31 c0                	xor    %eax,%eax
  801c48:	3b 14 24             	cmp    (%esp),%edx
  801c4b:	0f 83 37 ff ff ff    	jae    801b88 <__udivdi3+0x48>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e9 2d ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c5b:	90                   	nop
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	31 f6                	xor    %esi,%esi
  801c64:	e9 1f ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c69:	66 90                	xchg   %ax,%ax
  801c6b:	66 90                	xchg   %ax,%ax
  801c6d:	66 90                	xchg   %ax,%ax
  801c6f:	90                   	nop

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	83 ec 20             	sub    $0x20,%esp
  801c76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c82:	89 c6                	mov    %eax,%esi
  801c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	75 1e                	jne    801cc0 <__umoddi3+0x50>
  801ca2:	39 f7                	cmp    %esi,%edi
  801ca4:	76 52                	jbe    801cf8 <__umoddi3+0x88>
  801ca6:	89 c8                	mov    %ecx,%eax
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	f7 f7                	div    %edi
  801cac:	89 d0                	mov    %edx,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	83 c4 20             	add    $0x20,%esp
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
  801cb7:	89 f6                	mov    %esi,%esi
  801cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cc0:	39 f0                	cmp    %esi,%eax
  801cc2:	77 5c                	ja     801d20 <__umoddi3+0xb0>
  801cc4:	0f bd e8             	bsr    %eax,%ebp
  801cc7:	83 f5 1f             	xor    $0x1f,%ebp
  801cca:	75 64                	jne    801d30 <__umoddi3+0xc0>
  801ccc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cd4:	0f 86 f6 00 00 00    	jbe    801dd0 <__umoddi3+0x160>
  801cda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cde:	0f 82 ec 00 00 00    	jb     801dd0 <__umoddi3+0x160>
  801ce4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ce8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cec:	83 c4 20             	add    $0x20,%esp
  801cef:	5e                   	pop    %esi
  801cf0:	5f                   	pop    %edi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    
  801cf3:	90                   	nop
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	85 ff                	test   %edi,%edi
  801cfa:	89 fd                	mov    %edi,%ebp
  801cfc:	75 0b                	jne    801d09 <__umoddi3+0x99>
  801cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f7                	div    %edi
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	f7 f5                	div    %ebp
  801d11:	89 c8                	mov    %ecx,%eax
  801d13:	f7 f5                	div    %ebp
  801d15:	eb 95                	jmp    801cac <__umoddi3+0x3c>
  801d17:	89 f6                	mov    %esi,%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 20             	add    $0x20,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	b8 20 00 00 00       	mov    $0x20,%eax
  801d35:	89 e9                	mov    %ebp,%ecx
  801d37:	29 e8                	sub    %ebp,%eax
  801d39:	d3 e2                	shl    %cl,%edx
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 c1                	mov    %eax,%ecx
  801d4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d4f:	09 d1                	or     %edx,%ecx
  801d51:	89 fa                	mov    %edi,%edx
  801d53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d57:	89 e9                	mov    %ebp,%ecx
  801d59:	d3 e0                	shl    %cl,%eax
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	89 c7                	mov    %eax,%edi
  801d69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	09 f0                	or     %esi,%eax
  801d79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d7d:	f7 74 24 10          	divl   0x10(%esp)
  801d81:	d3 e6                	shl    %cl,%esi
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	f7 64 24 0c          	mull   0xc(%esp)
  801d89:	39 d1                	cmp    %edx,%ecx
  801d8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	72 0a                	jb     801d9f <__umoddi3+0x12f>
  801d95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d99:	73 10                	jae    801dab <__umoddi3+0x13b>
  801d9b:	39 d1                	cmp    %edx,%ecx
  801d9d:	75 0c                	jne    801dab <__umoddi3+0x13b>
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801da7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dab:	89 ca                	mov    %ecx,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801db3:	29 f0                	sub    %esi,%eax
  801db5:	19 fa                	sbb    %edi,%edx
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dbe:	89 d7                	mov    %edx,%edi
  801dc0:	d3 e7                	shl    %cl,%edi
  801dc2:	89 e9                	mov    %ebp,%ecx
  801dc4:	09 f8                	or     %edi,%eax
  801dc6:	d3 ea                	shr    %cl,%edx
  801dc8:	83 c4 20             	add    $0x20,%esp
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    
  801dcf:	90                   	nop
  801dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dd4:	29 f9                	sub    %edi,%ecx
  801dd6:	19 c6                	sbb    %eax,%esi
  801dd8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ddc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801de0:	e9 ff fe ff ff       	jmp    801ce4 <__umoddi3+0x74>
