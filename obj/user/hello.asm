
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 00 1e 80 00       	push   $0x801e00
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 1e 80 00       	push   $0x801e0e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
  800059:	83 c4 10             	add    $0x10,%esp
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800069:	e8 33 0a 00 00       	call   800aa1 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 78             	imul   $0x78,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
  80009a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 0c 0e 00 00       	call   800ebb <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a7 09 00 00       	call   800a60 <sys_env_destroy>
  8000b9:	83 c4 10             	add    $0x10,%esp
}
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 35 09 00 00       	call   800a23 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 4f 01 00 00       	call   800283 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 da 08 00 00       	call   800a23 <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800180:	8b 45 10             	mov    0x10(%ebp),%eax
  800183:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800186:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800189:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800190:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800193:	72 05                	jb     80019a <printnum+0x35>
  800195:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800198:	77 3e                	ja     8001d8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 18             	pushl  0x18(%ebp)
  8001a0:	83 eb 01             	sub    $0x1,%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 97 19 00 00       	call   801b50 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 13                	jmp    8001df <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f ed                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 89 1a 00 00       	call   801c80 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 2f 1e 80 00 	movsbl 0x801e2f(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800212:	83 fa 01             	cmp    $0x1,%edx
  800215:	7e 0e                	jle    800225 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800217:	8b 10                	mov    (%eax),%edx
  800219:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 02                	mov    (%edx),%eax
  800220:	8b 52 04             	mov    0x4(%edx),%edx
  800223:	eb 22                	jmp    800247 <getuint+0x38>
	else if (lflag)
  800225:	85 d2                	test   %edx,%edx
  800227:	74 10                	je     800239 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
  800237:	eb 0e                	jmp    800247 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800253:	8b 10                	mov    (%eax),%edx
  800255:	3b 50 04             	cmp    0x4(%eax),%edx
  800258:	73 0a                	jae    800264 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	88 02                	mov    %al,(%edx)
}
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 05 00 00 00       	call   800283 <vprintfmt>
	va_end(ap);
  80027e:	83 c4 10             	add    $0x10,%esp
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	8b 75 08             	mov    0x8(%ebp),%esi
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800292:	8b 7d 10             	mov    0x10(%ebp),%edi
  800295:	eb 12                	jmp    8002a9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800297:	85 c0                	test   %eax,%eax
  800299:	0f 84 8d 03 00 00    	je     80062c <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	53                   	push   %ebx
  8002a3:	50                   	push   %eax
  8002a4:	ff d6                	call   *%esi
  8002a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a9:	83 c7 01             	add    $0x1,%edi
  8002ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b0:	83 f8 25             	cmp    $0x25,%eax
  8002b3:	75 e2                	jne    800297 <vprintfmt+0x14>
  8002b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	eb 07                	jmp    8002dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8d 47 01             	lea    0x1(%edi),%eax
  8002df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e2:	0f b6 07             	movzbl (%edi),%eax
  8002e5:	0f b6 c8             	movzbl %al,%ecx
  8002e8:	83 e8 23             	sub    $0x23,%eax
  8002eb:	3c 55                	cmp    $0x55,%al
  8002ed:	0f 87 1e 03 00 00    	ja     800611 <vprintfmt+0x38e>
  8002f3:	0f b6 c0             	movzbl %al,%eax
  8002f6:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800300:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800304:	eb d6                	jmp    8002dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800309:	b8 00 00 00 00       	mov    $0x0,%eax
  80030e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800311:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800314:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800318:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031e:	83 fa 09             	cmp    $0x9,%edx
  800321:	77 38                	ja     80035b <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800323:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800326:	eb e9                	jmp    800311 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800328:	8b 45 14             	mov    0x14(%ebp),%eax
  80032b:	8d 48 04             	lea    0x4(%eax),%ecx
  80032e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800331:	8b 00                	mov    (%eax),%eax
  800333:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800339:	eb 26                	jmp    800361 <vprintfmt+0xde>
  80033b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033e:	89 c8                	mov    %ecx,%eax
  800340:	c1 f8 1f             	sar    $0x1f,%eax
  800343:	f7 d0                	not    %eax
  800345:	21 c1                	and    %eax,%ecx
  800347:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	eb 8d                	jmp    8002dc <vprintfmt+0x59>
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800352:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800359:	eb 81                	jmp    8002dc <vprintfmt+0x59>
  80035b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	0f 89 71 ff ff ff    	jns    8002dc <vprintfmt+0x59>
				width = precision, precision = -1;
  80036b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800371:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800378:	e9 5f ff ff ff       	jmp    8002dc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800383:	e9 54 ff ff ff       	jmp    8002dc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 50 04             	lea    0x4(%eax),%edx
  80038e:	89 55 14             	mov    %edx,0x14(%ebp)
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	53                   	push   %ebx
  800395:	ff 30                	pushl  (%eax)
  800397:	ff d6                	call   *%esi
			break;
  800399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039f:	e9 05 ff ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	99                   	cltd   
  8003b0:	31 d0                	xor    %edx,%eax
  8003b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b4:	83 f8 0f             	cmp    $0xf,%eax
  8003b7:	7f 0b                	jg     8003c4 <vprintfmt+0x141>
  8003b9:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	75 18                	jne    8003dc <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8003c4:	50                   	push   %eax
  8003c5:	68 47 1e 80 00       	push   $0x801e47
  8003ca:	53                   	push   %ebx
  8003cb:	56                   	push   %esi
  8003cc:	e8 95 fe ff ff       	call   800266 <printfmt>
  8003d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d7:	e9 cd fe ff ff       	jmp    8002a9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003dc:	52                   	push   %edx
  8003dd:	68 31 22 80 00       	push   $0x802231
  8003e2:	53                   	push   %ebx
  8003e3:	56                   	push   %esi
  8003e4:	e8 7d fe ff ff       	call   800266 <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	e9 b5 fe ff ff       	jmp    8002a9 <vprintfmt+0x26>
  8003f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	8b 38                	mov    (%eax),%edi
  800408:	85 ff                	test   %edi,%edi
  80040a:	75 05                	jne    800411 <vprintfmt+0x18e>
				p = "(null)";
  80040c:	bf 40 1e 80 00       	mov    $0x801e40,%edi
			if (width > 0 && padc != '-')
  800411:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800415:	0f 84 91 00 00 00    	je     8004ac <vprintfmt+0x229>
  80041b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80041f:	0f 8e 95 00 00 00    	jle    8004ba <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	51                   	push   %ecx
  800429:	57                   	push   %edi
  80042a:	e8 85 02 00 00       	call   8006b4 <strnlen>
  80042f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c5>
  80045b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800461:	89 c8                	mov    %ecx,%eax
  800463:	c1 f8 1f             	sar    $0x1f,%eax
  800466:	f7 d0                	not    %eax
  800468:	21 c8                	and    %ecx,%eax
  80046a:	29 c1                	sub    %eax,%ecx
  80046c:	89 75 08             	mov    %esi,0x8(%ebp)
  80046f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800472:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800475:	89 cb                	mov    %ecx,%ebx
  800477:	eb 4d                	jmp    8004c6 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800479:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047d:	74 1b                	je     80049a <vprintfmt+0x217>
  80047f:	0f be c0             	movsbl %al,%eax
  800482:	83 e8 20             	sub    $0x20,%eax
  800485:	83 f8 5e             	cmp    $0x5e,%eax
  800488:	76 10                	jbe    80049a <vprintfmt+0x217>
					putch('?', putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	6a 3f                	push   $0x3f
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	eb 0d                	jmp    8004a7 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	52                   	push   %edx
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a7:	83 eb 01             	sub    $0x1,%ebx
  8004aa:	eb 1a                	jmp    8004c6 <vprintfmt+0x243>
  8004ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8004af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b8:	eb 0c                	jmp    8004c6 <vprintfmt+0x243>
  8004ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c6:	83 c7 01             	add    $0x1,%edi
  8004c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cd:	0f be d0             	movsbl %al,%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 23                	je     8004f7 <vprintfmt+0x274>
  8004d4:	85 f6                	test   %esi,%esi
  8004d6:	78 a1                	js     800479 <vprintfmt+0x1f6>
  8004d8:	83 ee 01             	sub    $0x1,%esi
  8004db:	79 9c                	jns    800479 <vprintfmt+0x1f6>
  8004dd:	89 df                	mov    %ebx,%edi
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e5:	eb 18                	jmp    8004ff <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	eb 08                	jmp    8004ff <vprintfmt+0x27c>
  8004f7:	89 df                	mov    %ebx,%edi
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ff:	85 ff                	test   %edi,%edi
  800501:	7f e4                	jg     8004e7 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800506:	e9 9e fd ff ff       	jmp    8002a9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050b:	83 fa 01             	cmp    $0x1,%edx
  80050e:	7e 16                	jle    800526 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 08             	lea    0x8(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 50 04             	mov    0x4(%eax),%edx
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	eb 32                	jmp    800558 <vprintfmt+0x2d5>
	else if (lflag)
  800526:	85 d2                	test   %edx,%edx
  800528:	74 18                	je     800542 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 50 04             	lea    0x4(%eax),%edx
  800530:	89 55 14             	mov    %edx,0x14(%ebp)
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	89 c1                	mov    %eax,%ecx
  80053a:	c1 f9 1f             	sar    $0x1f,%ecx
  80053d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800540:	eb 16                	jmp    800558 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800558:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800563:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800567:	79 74                	jns    8005dd <vprintfmt+0x35a>
				putch('-', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 2d                	push   $0x2d
  80056f:	ff d6                	call   *%esi
				num = -(long long) num;
  800571:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800574:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800577:	f7 d8                	neg    %eax
  800579:	83 d2 00             	adc    $0x0,%edx
  80057c:	f7 da                	neg    %edx
  80057e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800586:	eb 55                	jmp    8005dd <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 7f fc ff ff       	call   80020f <getuint>
			base = 10;
  800590:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800595:	eb 46                	jmp    8005dd <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 70 fc ff ff       	call   80020f <getuint>
			base = 8;
  80059f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a4:	eb 37                	jmp    8005dd <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 30                	push   $0x30
  8005ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 78                	push   $0x78
  8005b4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ce:	eb 0d                	jmp    8005dd <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 37 fc ff ff       	call   80020f <getuint>
			base = 16;
  8005d8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e4:	57                   	push   %edi
  8005e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e8:	51                   	push   %ecx
  8005e9:	52                   	push   %edx
  8005ea:	50                   	push   %eax
  8005eb:	89 da                	mov    %ebx,%edx
  8005ed:	89 f0                	mov    %esi,%eax
  8005ef:	e8 71 fb ff ff       	call   800165 <printnum>
			break;
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fa:	e9 aa fc ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	51                   	push   %ecx
  800604:	ff d6                	call   *%esi
			break;
  800606:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060c:	e9 98 fc ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 25                	push   $0x25
  800617:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	eb 03                	jmp    800621 <vprintfmt+0x39e>
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800625:	75 f7                	jne    80061e <vprintfmt+0x39b>
  800627:	e9 7d fc ff ff       	jmp    8002a9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	83 ec 18             	sub    $0x18,%esp
  80063a:	8b 45 08             	mov    0x8(%ebp),%eax
  80063d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800640:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800643:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800647:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800651:	85 c0                	test   %eax,%eax
  800653:	74 26                	je     80067b <vsnprintf+0x47>
  800655:	85 d2                	test   %edx,%edx
  800657:	7e 22                	jle    80067b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800659:	ff 75 14             	pushl  0x14(%ebp)
  80065c:	ff 75 10             	pushl  0x10(%ebp)
  80065f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	68 49 02 80 00       	push   $0x800249
  800668:	e8 16 fc ff ff       	call   800283 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800670:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 05                	jmp    800680 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800680:	c9                   	leave  
  800681:	c3                   	ret    

00800682 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068b:	50                   	push   %eax
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	ff 75 08             	pushl  0x8(%ebp)
  800695:	e8 9a ff ff ff       	call   800634 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a7:	eb 03                	jmp    8006ac <strlen+0x10>
		n++;
  8006a9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b0:	75 f7                	jne    8006a9 <strlen+0xd>
		n++;
	return n;
}
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c2:	eb 03                	jmp    8006c7 <strnlen+0x13>
		n++;
  8006c4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c7:	39 c2                	cmp    %eax,%edx
  8006c9:	74 08                	je     8006d3 <strnlen+0x1f>
  8006cb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cf:	75 f3                	jne    8006c4 <strnlen+0x10>
  8006d1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	83 c2 01             	add    $0x1,%edx
  8006e4:	83 c1 01             	add    $0x1,%ecx
  8006e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ee:	84 db                	test   %bl,%bl
  8006f0:	75 ef                	jne    8006e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f2:	5b                   	pop    %ebx
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fc:	53                   	push   %ebx
  8006fd:	e8 9a ff ff ff       	call   80069c <strlen>
  800702:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	01 d8                	add    %ebx,%eax
  80070a:	50                   	push   %eax
  80070b:	e8 c5 ff ff ff       	call   8006d5 <strcpy>
	return dst;
}
  800710:	89 d8                	mov    %ebx,%eax
  800712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800722:	89 f3                	mov    %esi,%ebx
  800724:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	89 f2                	mov    %esi,%edx
  800729:	eb 0f                	jmp    80073a <strncpy+0x23>
		*dst++ = *src;
  80072b:	83 c2 01             	add    $0x1,%edx
  80072e:	0f b6 01             	movzbl (%ecx),%eax
  800731:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800734:	80 39 01             	cmpb   $0x1,(%ecx)
  800737:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073a:	39 da                	cmp    %ebx,%edx
  80073c:	75 ed                	jne    80072b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073e:	89 f0                	mov    %esi,%eax
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	8b 55 10             	mov    0x10(%ebp),%edx
  800752:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800754:	85 d2                	test   %edx,%edx
  800756:	74 21                	je     800779 <strlcpy+0x35>
  800758:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 09                	jmp    800769 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 09                	je     800776 <strlcpy+0x32>
  80076d:	0f b6 19             	movzbl (%ecx),%ebx
  800770:	84 db                	test   %bl,%bl
  800772:	75 ec                	jne    800760 <strlcpy+0x1c>
  800774:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800776:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800779:	29 f0                	sub    %esi,%eax
}
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800788:	eb 06                	jmp    800790 <strcmp+0x11>
		p++, q++;
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	84 c0                	test   %al,%al
  800795:	74 04                	je     80079b <strcmp+0x1c>
  800797:	3a 02                	cmp    (%edx),%al
  800799:	74 ef                	je     80078a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079b:	0f b6 c0             	movzbl %al,%eax
  80079e:	0f b6 12             	movzbl (%edx),%edx
  8007a1:	29 d0                	sub    %edx,%eax
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007af:	89 c3                	mov    %eax,%ebx
  8007b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b4:	eb 06                	jmp    8007bc <strncmp+0x17>
		n--, p++, q++;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bc:	39 d8                	cmp    %ebx,%eax
  8007be:	74 15                	je     8007d5 <strncmp+0x30>
  8007c0:	0f b6 08             	movzbl (%eax),%ecx
  8007c3:	84 c9                	test   %cl,%cl
  8007c5:	74 04                	je     8007cb <strncmp+0x26>
  8007c7:	3a 0a                	cmp    (%edx),%cl
  8007c9:	74 eb                	je     8007b6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cb:	0f b6 00             	movzbl (%eax),%eax
  8007ce:	0f b6 12             	movzbl (%edx),%edx
  8007d1:	29 d0                	sub    %edx,%eax
  8007d3:	eb 05                	jmp    8007da <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e7:	eb 07                	jmp    8007f0 <strchr+0x13>
		if (*s == c)
  8007e9:	38 ca                	cmp    %cl,%dl
  8007eb:	74 0f                	je     8007fc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	0f b6 10             	movzbl (%eax),%edx
  8007f3:	84 d2                	test   %dl,%dl
  8007f5:	75 f2                	jne    8007e9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 03                	jmp    80080d <strfind+0xf>
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800810:	84 d2                	test   %dl,%dl
  800812:	74 04                	je     800818 <strfind+0x1a>
  800814:	38 ca                	cmp    %cl,%dl
  800816:	75 f2                	jne    80080a <strfind+0xc>
			break;
	return (char *) s;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	57                   	push   %edi
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 7d 08             	mov    0x8(%ebp),%edi
  800823:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800826:	85 c9                	test   %ecx,%ecx
  800828:	74 36                	je     800860 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800830:	75 28                	jne    80085a <memset+0x40>
  800832:	f6 c1 03             	test   $0x3,%cl
  800835:	75 23                	jne    80085a <memset+0x40>
		c &= 0xFF;
  800837:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083b:	89 d3                	mov    %edx,%ebx
  80083d:	c1 e3 08             	shl    $0x8,%ebx
  800840:	89 d6                	mov    %edx,%esi
  800842:	c1 e6 18             	shl    $0x18,%esi
  800845:	89 d0                	mov    %edx,%eax
  800847:	c1 e0 10             	shl    $0x10,%eax
  80084a:	09 f0                	or     %esi,%eax
  80084c:	09 c2                	or     %eax,%edx
  80084e:	89 d0                	mov    %edx,%eax
  800850:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800852:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800855:	fc                   	cld    
  800856:	f3 ab                	rep stos %eax,%es:(%edi)
  800858:	eb 06                	jmp    800860 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	fc                   	cld    
  80085e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800860:	89 f8                	mov    %edi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800875:	39 c6                	cmp    %eax,%esi
  800877:	73 35                	jae    8008ae <memmove+0x47>
  800879:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	73 2e                	jae    8008ae <memmove+0x47>
		s += n;
		d += n;
  800880:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800883:	89 d6                	mov    %edx,%esi
  800885:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088d:	75 13                	jne    8008a2 <memmove+0x3b>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 0e                	jne    8008a2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800894:	83 ef 04             	sub    $0x4,%edi
  800897:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089d:	fd                   	std    
  80089e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a0:	eb 09                	jmp    8008ab <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a2:	83 ef 01             	sub    $0x1,%edi
  8008a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a8:	fd                   	std    
  8008a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ab:	fc                   	cld    
  8008ac:	eb 1d                	jmp    8008cb <memmove+0x64>
  8008ae:	89 f2                	mov    %esi,%edx
  8008b0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b2:	f6 c2 03             	test   $0x3,%dl
  8008b5:	75 0f                	jne    8008c6 <memmove+0x5f>
  8008b7:	f6 c1 03             	test   $0x3,%cl
  8008ba:	75 0a                	jne    8008c6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008bf:	89 c7                	mov    %eax,%edi
  8008c1:	fc                   	cld    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 05                	jmp    8008cb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c6:	89 c7                	mov    %eax,%edi
  8008c8:	fc                   	cld    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 87 ff ff ff       	call   800867 <memmove>
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c6                	mov    %eax,%esi
  8008ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f2:	eb 1a                	jmp    80090e <memcmp+0x2c>
		if (*s1 != *s2)
  8008f4:	0f b6 08             	movzbl (%eax),%ecx
  8008f7:	0f b6 1a             	movzbl (%edx),%ebx
  8008fa:	38 d9                	cmp    %bl,%cl
  8008fc:	74 0a                	je     800908 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fe:	0f b6 c1             	movzbl %cl,%eax
  800901:	0f b6 db             	movzbl %bl,%ebx
  800904:	29 d8                	sub    %ebx,%eax
  800906:	eb 0f                	jmp    800917 <memcmp+0x35>
		s1++, s2++;
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090e:	39 f0                	cmp    %esi,%eax
  800910:	75 e2                	jne    8008f4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800924:	89 c2                	mov    %eax,%edx
  800926:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800929:	eb 07                	jmp    800932 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092b:	38 08                	cmp    %cl,(%eax)
  80092d:	74 07                	je     800936 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	39 d0                	cmp    %edx,%eax
  800934:	72 f5                	jb     80092b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800944:	eb 03                	jmp    800949 <strtol+0x11>
		s++;
  800946:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	3c 09                	cmp    $0x9,%al
  80094e:	74 f6                	je     800946 <strtol+0xe>
  800950:	3c 20                	cmp    $0x20,%al
  800952:	74 f2                	je     800946 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800954:	3c 2b                	cmp    $0x2b,%al
  800956:	75 0a                	jne    800962 <strtol+0x2a>
		s++;
  800958:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095b:	bf 00 00 00 00       	mov    $0x0,%edi
  800960:	eb 10                	jmp    800972 <strtol+0x3a>
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800967:	3c 2d                	cmp    $0x2d,%al
  800969:	75 07                	jne    800972 <strtol+0x3a>
		s++, neg = 1;
  80096b:	8d 49 01             	lea    0x1(%ecx),%ecx
  80096e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800972:	85 db                	test   %ebx,%ebx
  800974:	0f 94 c0             	sete   %al
  800977:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097d:	75 19                	jne    800998 <strtol+0x60>
  80097f:	80 39 30             	cmpb   $0x30,(%ecx)
  800982:	75 14                	jne    800998 <strtol+0x60>
  800984:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800988:	0f 85 8a 00 00 00    	jne    800a18 <strtol+0xe0>
		s += 2, base = 16;
  80098e:	83 c1 02             	add    $0x2,%ecx
  800991:	bb 10 00 00 00       	mov    $0x10,%ebx
  800996:	eb 16                	jmp    8009ae <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800998:	84 c0                	test   %al,%al
  80099a:	74 12                	je     8009ae <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a4:	75 08                	jne    8009ae <strtol+0x76>
		s++, base = 8;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b6:	0f b6 11             	movzbl (%ecx),%edx
  8009b9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	80 fb 09             	cmp    $0x9,%bl
  8009c1:	77 08                	ja     8009cb <strtol+0x93>
			dig = *s - '0';
  8009c3:	0f be d2             	movsbl %dl,%edx
  8009c6:	83 ea 30             	sub    $0x30,%edx
  8009c9:	eb 22                	jmp    8009ed <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009cb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 19             	cmp    $0x19,%bl
  8009d3:	77 08                	ja     8009dd <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d5:	0f be d2             	movsbl %dl,%edx
  8009d8:	83 ea 57             	sub    $0x57,%edx
  8009db:	eb 10                	jmp    8009ed <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009dd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	80 fb 19             	cmp    $0x19,%bl
  8009e5:	77 16                	ja     8009fd <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e7:	0f be d2             	movsbl %dl,%edx
  8009ea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ed:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f0:	7d 0f                	jge    800a01 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fb:	eb b9                	jmp    8009b6 <strtol+0x7e>
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	eb 02                	jmp    800a03 <strtol+0xcb>
  800a01:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a07:	74 05                	je     800a0e <strtol+0xd6>
		*endptr = (char *) s;
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a0e:	85 ff                	test   %edi,%edi
  800a10:	74 0c                	je     800a1e <strtol+0xe6>
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	f7 d8                	neg    %eax
  800a16:	eb 06                	jmp    800a1e <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	84 c0                	test   %al,%al
  800a1a:	75 8a                	jne    8009a6 <strtol+0x6e>
  800a1c:	eb 90                	jmp    8009ae <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a31:	8b 55 08             	mov    0x8(%ebp),%edx
  800a34:	89 c3                	mov    %eax,%ebx
  800a36:	89 c7                	mov    %eax,%edi
  800a38:	89 c6                	mov    %eax,%esi
  800a3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a51:	89 d1                	mov    %edx,%ecx
  800a53:	89 d3                	mov    %edx,%ebx
  800a55:	89 d7                	mov    %edx,%edi
  800a57:	89 d6                	mov    %edx,%esi
  800a59:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	89 cb                	mov    %ecx,%ebx
  800a78:	89 cf                	mov    %ecx,%edi
  800a7a:	89 ce                	mov    %ecx,%esi
  800a7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7e:	85 c0                	test   %eax,%eax
  800a80:	7e 17                	jle    800a99 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a82:	83 ec 0c             	sub    $0xc,%esp
  800a85:	50                   	push   %eax
  800a86:	6a 03                	push   $0x3
  800a88:	68 5f 21 80 00       	push   $0x80215f
  800a8d:	6a 23                	push   $0x23
  800a8f:	68 7c 21 80 00       	push   $0x80217c
  800a94:	e8 3b 0f 00 00       	call   8019d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab1:	89 d1                	mov    %edx,%ecx
  800ab3:	89 d3                	mov    %edx,%ebx
  800ab5:	89 d7                	mov    %edx,%edi
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_yield>:

void
sys_yield(void)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  800acb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad0:	89 d1                	mov    %edx,%ecx
  800ad2:	89 d3                	mov    %edx,%ebx
  800ad4:	89 d7                	mov    %edx,%edi
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	be 00 00 00 00       	mov    $0x0,%esi
  800aed:	b8 04 00 00 00       	mov    $0x4,%eax
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	8b 55 08             	mov    0x8(%ebp),%edx
  800af8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800afb:	89 f7                	mov    %esi,%edi
  800afd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 17                	jle    800b1a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	50                   	push   %eax
  800b07:	6a 04                	push   $0x4
  800b09:	68 5f 21 80 00       	push   $0x80215f
  800b0e:	6a 23                	push   $0x23
  800b10:	68 7c 21 80 00       	push   $0x80217c
  800b15:	e8 ba 0e 00 00       	call   8019d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 17                	jle    800b5c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	50                   	push   %eax
  800b49:	6a 05                	push   $0x5
  800b4b:	68 5f 21 80 00       	push   $0x80215f
  800b50:	6a 23                	push   $0x23
  800b52:	68 7c 21 80 00       	push   $0x80217c
  800b57:	e8 78 0e 00 00       	call   8019d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b72:	b8 06 00 00 00       	mov    $0x6,%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	89 df                	mov    %ebx,%edi
  800b7f:	89 de                	mov    %ebx,%esi
  800b81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 17                	jle    800b9e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 06                	push   $0x6
  800b8d:	68 5f 21 80 00       	push   $0x80215f
  800b92:	6a 23                	push   $0x23
  800b94:	68 7c 21 80 00       	push   $0x80217c
  800b99:	e8 36 0e 00 00       	call   8019d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	89 df                	mov    %ebx,%edi
  800bc1:	89 de                	mov    %ebx,%esi
  800bc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 17                	jle    800be0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 08                	push   $0x8
  800bcf:	68 5f 21 80 00       	push   $0x80215f
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 7c 21 80 00       	push   $0x80217c
  800bdb:	e8 f4 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	b8 09 00 00 00       	mov    $0x9,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 17                	jle    800c22 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 09                	push   $0x9
  800c11:	68 5f 21 80 00       	push   $0x80215f
  800c16:	6a 23                	push   $0x23
  800c18:	68 7c 21 80 00       	push   $0x80217c
  800c1d:	e8 b2 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 0a                	push   $0xa
  800c53:	68 5f 21 80 00       	push   $0x80215f
  800c58:	6a 23                	push   $0x23
  800c5a:	68 7c 21 80 00       	push   $0x80217c
  800c5f:	e8 70 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 cb                	mov    %ecx,%ebx
  800ca7:	89 cf                	mov    %ecx,%edi
  800ca9:	89 ce                	mov    %ecx,%esi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 0d                	push   $0xd
  800cb7:	68 5f 21 80 00       	push   $0x80215f
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 7c 21 80 00       	push   $0x80217c
  800cc3:	e8 0c 0d 00 00       	call   8019d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_gettime>:

int sys_gettime(void)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce0:	89 d1                	mov    %edx,%ecx
  800ce2:	89 d3                	mov    %edx,%ebx
  800ce4:	89 d7                	mov    %edx,%edi
  800ce6:	89 d6                	mov    %edx,%esi
  800ce8:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	05 00 00 00 30       	add    $0x30000000,%eax
  800cfa:	c1 e8 0c             	shr    $0xc,%eax
}
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d0f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	c1 ea 16             	shr    $0x16,%edx
  800d26:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d2d:	f6 c2 01             	test   $0x1,%dl
  800d30:	74 11                	je     800d43 <fd_alloc+0x2d>
  800d32:	89 c2                	mov    %eax,%edx
  800d34:	c1 ea 0c             	shr    $0xc,%edx
  800d37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d3e:	f6 c2 01             	test   $0x1,%dl
  800d41:	75 09                	jne    800d4c <fd_alloc+0x36>
			*fd_store = fd;
  800d43:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4a:	eb 17                	jmp    800d63 <fd_alloc+0x4d>
  800d4c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d51:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d56:	75 c9                	jne    800d21 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d58:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d5e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d6b:	83 f8 1f             	cmp    $0x1f,%eax
  800d6e:	77 36                	ja     800da6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d70:	c1 e0 0c             	shl    $0xc,%eax
  800d73:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d78:	89 c2                	mov    %eax,%edx
  800d7a:	c1 ea 16             	shr    $0x16,%edx
  800d7d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d84:	f6 c2 01             	test   $0x1,%dl
  800d87:	74 24                	je     800dad <fd_lookup+0x48>
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	c1 ea 0c             	shr    $0xc,%edx
  800d8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d95:	f6 c2 01             	test   $0x1,%dl
  800d98:	74 1a                	je     800db4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9d:	89 02                	mov    %eax,(%edx)
	return 0;
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800da4:	eb 13                	jmp    800db9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dab:	eb 0c                	jmp    800db9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800db2:	eb 05                	jmp    800db9 <fd_lookup+0x54>
  800db4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 08             	sub    $0x8,%esp
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dc9:	eb 13                	jmp    800dde <dev_lookup+0x23>
  800dcb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dce:	39 08                	cmp    %ecx,(%eax)
  800dd0:	75 0c                	jne    800dde <dev_lookup+0x23>
			*dev = devtab[i];
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	eb 2e                	jmp    800e0c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dde:	8b 02                	mov    (%edx),%eax
  800de0:	85 c0                	test   %eax,%eax
  800de2:	75 e7                	jne    800dcb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800de4:	a1 04 40 80 00       	mov    0x804004,%eax
  800de9:	8b 40 48             	mov    0x48(%eax),%eax
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	51                   	push   %ecx
  800df0:	50                   	push   %eax
  800df1:	68 8c 21 80 00       	push   $0x80218c
  800df6:	e8 56 f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e0c:	c9                   	leave  
  800e0d:	c3                   	ret    

00800e0e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 10             	sub    $0x10,%esp
  800e16:	8b 75 08             	mov    0x8(%ebp),%esi
  800e19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e20:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e26:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e29:	50                   	push   %eax
  800e2a:	e8 36 ff ff ff       	call   800d65 <fd_lookup>
  800e2f:	83 c4 08             	add    $0x8,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	78 05                	js     800e3b <fd_close+0x2d>
	    || fd != fd2)
  800e36:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e39:	74 0b                	je     800e46 <fd_close+0x38>
		return (must_exist ? r : 0);
  800e3b:	80 fb 01             	cmp    $0x1,%bl
  800e3e:	19 d2                	sbb    %edx,%edx
  800e40:	f7 d2                	not    %edx
  800e42:	21 d0                	and    %edx,%eax
  800e44:	eb 41                	jmp    800e87 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e4c:	50                   	push   %eax
  800e4d:	ff 36                	pushl  (%esi)
  800e4f:	e8 67 ff ff ff       	call   800dbb <dev_lookup>
  800e54:	89 c3                	mov    %eax,%ebx
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 1a                	js     800e77 <fd_close+0x69>
		if (dev->dev_close)
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	74 0b                	je     800e77 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	56                   	push   %esi
  800e70:	ff d0                	call   *%eax
  800e72:	89 c3                	mov    %eax,%ebx
  800e74:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	56                   	push   %esi
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 e2 fc ff ff       	call   800b64 <sys_page_unmap>
	return r;
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	89 d8                	mov    %ebx,%eax
}
  800e87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e97:	50                   	push   %eax
  800e98:	ff 75 08             	pushl  0x8(%ebp)
  800e9b:	e8 c5 fe ff ff       	call   800d65 <fd_lookup>
  800ea0:	89 c2                	mov    %eax,%edx
  800ea2:	83 c4 08             	add    $0x8,%esp
  800ea5:	85 d2                	test   %edx,%edx
  800ea7:	78 10                	js     800eb9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	6a 01                	push   $0x1
  800eae:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb1:	e8 58 ff ff ff       	call   800e0e <fd_close>
  800eb6:	83 c4 10             	add    $0x10,%esp
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <close_all>:

void
close_all(void)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	53                   	push   %ebx
  800ecb:	e8 be ff ff ff       	call   800e8e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed0:	83 c3 01             	add    $0x1,%ebx
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	83 fb 20             	cmp    $0x20,%ebx
  800ed9:	75 ec                	jne    800ec7 <close_all+0xc>
		close(i);
}
  800edb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 2c             	sub    $0x2c,%esp
  800ee9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800eec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eef:	50                   	push   %eax
  800ef0:	ff 75 08             	pushl  0x8(%ebp)
  800ef3:	e8 6d fe ff ff       	call   800d65 <fd_lookup>
  800ef8:	89 c2                	mov    %eax,%edx
  800efa:	83 c4 08             	add    $0x8,%esp
  800efd:	85 d2                	test   %edx,%edx
  800eff:	0f 88 c1 00 00 00    	js     800fc6 <dup+0xe6>
		return r;
	close(newfdnum);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	56                   	push   %esi
  800f09:	e8 80 ff ff ff       	call   800e8e <close>

	newfd = INDEX2FD(newfdnum);
  800f0e:	89 f3                	mov    %esi,%ebx
  800f10:	c1 e3 0c             	shl    $0xc,%ebx
  800f13:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f19:	83 c4 04             	add    $0x4,%esp
  800f1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f1f:	e8 db fd ff ff       	call   800cff <fd2data>
  800f24:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f26:	89 1c 24             	mov    %ebx,(%esp)
  800f29:	e8 d1 fd ff ff       	call   800cff <fd2data>
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f34:	89 f8                	mov    %edi,%eax
  800f36:	c1 e8 16             	shr    $0x16,%eax
  800f39:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f40:	a8 01                	test   $0x1,%al
  800f42:	74 37                	je     800f7b <dup+0x9b>
  800f44:	89 f8                	mov    %edi,%eax
  800f46:	c1 e8 0c             	shr    $0xc,%eax
  800f49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f50:	f6 c2 01             	test   $0x1,%dl
  800f53:	74 26                	je     800f7b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f64:	50                   	push   %eax
  800f65:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f68:	6a 00                	push   $0x0
  800f6a:	57                   	push   %edi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 b0 fb ff ff       	call   800b22 <sys_page_map>
  800f72:	89 c7                	mov    %eax,%edi
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 2e                	js     800fa9 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f7e:	89 d0                	mov    %edx,%eax
  800f80:	c1 e8 0c             	shr    $0xc,%eax
  800f83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f92:	50                   	push   %eax
  800f93:	53                   	push   %ebx
  800f94:	6a 00                	push   $0x0
  800f96:	52                   	push   %edx
  800f97:	6a 00                	push   $0x0
  800f99:	e8 84 fb ff ff       	call   800b22 <sys_page_map>
  800f9e:	89 c7                	mov    %eax,%edi
  800fa0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fa3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fa5:	85 ff                	test   %edi,%edi
  800fa7:	79 1d                	jns    800fc6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	53                   	push   %ebx
  800fad:	6a 00                	push   $0x0
  800faf:	e8 b0 fb ff ff       	call   800b64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 a3 fb ff ff       	call   800b64 <sys_page_unmap>
	return r;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	89 f8                	mov    %edi,%eax
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 14             	sub    $0x14,%esp
  800fd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	53                   	push   %ebx
  800fdd:	e8 83 fd ff ff       	call   800d65 <fd_lookup>
  800fe2:	83 c4 08             	add    $0x8,%esp
  800fe5:	89 c2                	mov    %eax,%edx
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 6d                	js     801058 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff5:	ff 30                	pushl  (%eax)
  800ff7:	e8 bf fd ff ff       	call   800dbb <dev_lookup>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 4c                	js     80104f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801003:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801006:	8b 42 08             	mov    0x8(%edx),%eax
  801009:	83 e0 03             	and    $0x3,%eax
  80100c:	83 f8 01             	cmp    $0x1,%eax
  80100f:	75 21                	jne    801032 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801011:	a1 04 40 80 00       	mov    0x804004,%eax
  801016:	8b 40 48             	mov    0x48(%eax),%eax
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	53                   	push   %ebx
  80101d:	50                   	push   %eax
  80101e:	68 cd 21 80 00       	push   $0x8021cd
  801023:	e8 29 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801030:	eb 26                	jmp    801058 <read+0x8a>
	}
	if (!dev->dev_read)
  801032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801035:	8b 40 08             	mov    0x8(%eax),%eax
  801038:	85 c0                	test   %eax,%eax
  80103a:	74 17                	je     801053 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	ff 75 10             	pushl  0x10(%ebp)
  801042:	ff 75 0c             	pushl  0xc(%ebp)
  801045:	52                   	push   %edx
  801046:	ff d0                	call   *%eax
  801048:	89 c2                	mov    %eax,%edx
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	eb 09                	jmp    801058 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104f:	89 c2                	mov    %eax,%edx
  801051:	eb 05                	jmp    801058 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801053:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801058:	89 d0                	mov    %edx,%eax
  80105a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80106e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801073:	eb 21                	jmp    801096 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	89 f0                	mov    %esi,%eax
  80107a:	29 d8                	sub    %ebx,%eax
  80107c:	50                   	push   %eax
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	03 45 0c             	add    0xc(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	57                   	push   %edi
  801084:	e8 45 ff ff ff       	call   800fce <read>
		if (m < 0)
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 0c                	js     80109c <readn+0x3d>
			return m;
		if (m == 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	74 06                	je     80109a <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801094:	01 c3                	add    %eax,%ebx
  801096:	39 f3                	cmp    %esi,%ebx
  801098:	72 db                	jb     801075 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80109a:	89 d8                	mov    %ebx,%eax
}
  80109c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 14             	sub    $0x14,%esp
  8010ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b1:	50                   	push   %eax
  8010b2:	53                   	push   %ebx
  8010b3:	e8 ad fc ff ff       	call   800d65 <fd_lookup>
  8010b8:	83 c4 08             	add    $0x8,%esp
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 68                	js     801129 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cb:	ff 30                	pushl  (%eax)
  8010cd:	e8 e9 fc ff ff       	call   800dbb <dev_lookup>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 47                	js     801120 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010e0:	75 21                	jne    801103 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	53                   	push   %ebx
  8010ee:	50                   	push   %eax
  8010ef:	68 e9 21 80 00       	push   $0x8021e9
  8010f4:	e8 58 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801101:	eb 26                	jmp    801129 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801103:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801106:	8b 52 0c             	mov    0xc(%edx),%edx
  801109:	85 d2                	test   %edx,%edx
  80110b:	74 17                	je     801124 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	ff 75 10             	pushl  0x10(%ebp)
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	50                   	push   %eax
  801117:	ff d2                	call   *%edx
  801119:	89 c2                	mov    %eax,%edx
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	eb 09                	jmp    801129 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801120:	89 c2                	mov    %eax,%edx
  801122:	eb 05                	jmp    801129 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801124:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801129:	89 d0                	mov    %edx,%eax
  80112b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <seek>:

int
seek(int fdnum, off_t offset)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801136:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	ff 75 08             	pushl  0x8(%ebp)
  80113d:	e8 23 fc ff ff       	call   800d65 <fd_lookup>
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	78 0e                	js     801157 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801149:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801157:	c9                   	leave  
  801158:	c3                   	ret    

00801159 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	53                   	push   %ebx
  80115d:	83 ec 14             	sub    $0x14,%esp
  801160:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801163:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801166:	50                   	push   %eax
  801167:	53                   	push   %ebx
  801168:	e8 f8 fb ff ff       	call   800d65 <fd_lookup>
  80116d:	83 c4 08             	add    $0x8,%esp
  801170:	89 c2                	mov    %eax,%edx
  801172:	85 c0                	test   %eax,%eax
  801174:	78 65                	js     8011db <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801180:	ff 30                	pushl  (%eax)
  801182:	e8 34 fc ff ff       	call   800dbb <dev_lookup>
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 44                	js     8011d2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801191:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801195:	75 21                	jne    8011b8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801197:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80119c:	8b 40 48             	mov    0x48(%eax),%eax
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	53                   	push   %ebx
  8011a3:	50                   	push   %eax
  8011a4:	68 ac 21 80 00       	push   $0x8021ac
  8011a9:	e8 a3 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b6:	eb 23                	jmp    8011db <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011bb:	8b 52 18             	mov    0x18(%edx),%edx
  8011be:	85 d2                	test   %edx,%edx
  8011c0:	74 14                	je     8011d6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	ff 75 0c             	pushl  0xc(%ebp)
  8011c8:	50                   	push   %eax
  8011c9:	ff d2                	call   *%edx
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	eb 09                	jmp    8011db <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	eb 05                	jmp    8011db <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011db:	89 d0                	mov    %edx,%eax
  8011dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 14             	sub    $0x14,%esp
  8011e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	ff 75 08             	pushl  0x8(%ebp)
  8011f3:	e8 6d fb ff ff       	call   800d65 <fd_lookup>
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 58                	js     801259 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	ff 30                	pushl  (%eax)
  80120d:	e8 a9 fb ff ff       	call   800dbb <dev_lookup>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 37                	js     801250 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801220:	74 32                	je     801254 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801222:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801225:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80122c:	00 00 00 
	stat->st_isdir = 0;
  80122f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801236:	00 00 00 
	stat->st_dev = dev;
  801239:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	53                   	push   %ebx
  801243:	ff 75 f0             	pushl  -0x10(%ebp)
  801246:	ff 50 14             	call   *0x14(%eax)
  801249:	89 c2                	mov    %eax,%edx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	eb 09                	jmp    801259 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801250:	89 c2                	mov    %eax,%edx
  801252:	eb 05                	jmp    801259 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801254:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801259:	89 d0                	mov    %edx,%eax
  80125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	6a 00                	push   $0x0
  80126a:	ff 75 08             	pushl  0x8(%ebp)
  80126d:	e8 e7 01 00 00       	call   801459 <open>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 db                	test   %ebx,%ebx
  801279:	78 1b                	js     801296 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	53                   	push   %ebx
  801282:	e8 5b ff ff ff       	call   8011e2 <fstat>
  801287:	89 c6                	mov    %eax,%esi
	close(fd);
  801289:	89 1c 24             	mov    %ebx,(%esp)
  80128c:	e8 fd fb ff ff       	call   800e8e <close>
	return r;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	89 f0                	mov    %esi,%eax
}
  801296:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	89 c6                	mov    %eax,%esi
  8012a4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012a6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ad:	75 12                	jne    8012c1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012af:	83 ec 0c             	sub    $0xc,%esp
  8012b2:	6a 03                	push   $0x3
  8012b4:	e8 18 08 00 00       	call   801ad1 <ipc_find_env>
  8012b9:	a3 00 40 80 00       	mov    %eax,0x804000
  8012be:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012c1:	6a 07                	push   $0x7
  8012c3:	68 00 50 80 00       	push   $0x805000
  8012c8:	56                   	push   %esi
  8012c9:	ff 35 00 40 80 00    	pushl  0x804000
  8012cf:	e8 ac 07 00 00       	call   801a80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012d4:	83 c4 0c             	add    $0xc,%esp
  8012d7:	6a 00                	push   $0x0
  8012d9:	53                   	push   %ebx
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 39 07 00 00       	call   801a1a <ipc_recv>
}
  8012e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801301:	ba 00 00 00 00       	mov    $0x0,%edx
  801306:	b8 02 00 00 00       	mov    $0x2,%eax
  80130b:	e8 8d ff ff ff       	call   80129d <fsipc>
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801318:	8b 45 08             	mov    0x8(%ebp),%eax
  80131b:	8b 40 0c             	mov    0xc(%eax),%eax
  80131e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801323:	ba 00 00 00 00       	mov    $0x0,%edx
  801328:	b8 06 00 00 00       	mov    $0x6,%eax
  80132d:	e8 6b ff ff ff       	call   80129d <fsipc>
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	8b 40 0c             	mov    0xc(%eax),%eax
  801344:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801349:	ba 00 00 00 00       	mov    $0x0,%edx
  80134e:	b8 05 00 00 00       	mov    $0x5,%eax
  801353:	e8 45 ff ff ff       	call   80129d <fsipc>
  801358:	89 c2                	mov    %eax,%edx
  80135a:	85 d2                	test   %edx,%edx
  80135c:	78 2c                	js     80138a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	68 00 50 80 00       	push   $0x805000
  801366:	53                   	push   %ebx
  801367:	e8 69 f3 ff ff       	call   8006d5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80136c:	a1 80 50 80 00       	mov    0x805080,%eax
  801371:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801377:	a1 84 50 80 00       	mov    0x805084,%eax
  80137c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801398:	8b 55 08             	mov    0x8(%ebp),%edx
  80139b:	8b 52 0c             	mov    0xc(%edx),%edx
  80139e:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8013a4:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8013a9:	76 05                	jbe    8013b0 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8013ab:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8013b0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	50                   	push   %eax
  8013b9:	ff 75 0c             	pushl  0xc(%ebp)
  8013bc:	68 08 50 80 00       	push   $0x805008
  8013c1:	e8 a1 f4 ff ff       	call   800867 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8013c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d0:	e8 c8 fe ff ff       	call   80129d <fsipc>
	return write;
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fa:	e8 9e fe ff ff       	call   80129d <fsipc>
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	85 c0                	test   %eax,%eax
  801403:	78 4b                	js     801450 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801405:	39 c6                	cmp    %eax,%esi
  801407:	73 16                	jae    80141f <devfile_read+0x48>
  801409:	68 18 22 80 00       	push   $0x802218
  80140e:	68 1f 22 80 00       	push   $0x80221f
  801413:	6a 7c                	push   $0x7c
  801415:	68 34 22 80 00       	push   $0x802234
  80141a:	e8 b5 05 00 00       	call   8019d4 <_panic>
	assert(r <= PGSIZE);
  80141f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801424:	7e 16                	jle    80143c <devfile_read+0x65>
  801426:	68 3f 22 80 00       	push   $0x80223f
  80142b:	68 1f 22 80 00       	push   $0x80221f
  801430:	6a 7d                	push   $0x7d
  801432:	68 34 22 80 00       	push   $0x802234
  801437:	e8 98 05 00 00       	call   8019d4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	50                   	push   %eax
  801440:	68 00 50 80 00       	push   $0x805000
  801445:	ff 75 0c             	pushl  0xc(%ebp)
  801448:	e8 1a f4 ff ff       	call   800867 <memmove>
	return r;
  80144d:	83 c4 10             	add    $0x10,%esp
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 20             	sub    $0x20,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801463:	53                   	push   %ebx
  801464:	e8 33 f2 ff ff       	call   80069c <strlen>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801471:	7f 67                	jg     8014da <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	e8 97 f8 ff ff       	call   800d16 <fd_alloc>
  80147f:	83 c4 10             	add    $0x10,%esp
		return r;
  801482:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801484:	85 c0                	test   %eax,%eax
  801486:	78 57                	js     8014df <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	53                   	push   %ebx
  80148c:	68 00 50 80 00       	push   $0x805000
  801491:	e8 3f f2 ff ff       	call   8006d5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801496:	8b 45 0c             	mov    0xc(%ebp),%eax
  801499:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a6:	e8 f2 fd ff ff       	call   80129d <fsipc>
  8014ab:	89 c3                	mov    %eax,%ebx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	79 14                	jns    8014c8 <open+0x6f>
		fd_close(fd, 0);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	6a 00                	push   $0x0
  8014b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bc:	e8 4d f9 ff ff       	call   800e0e <fd_close>
		return r;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	89 da                	mov    %ebx,%edx
  8014c6:	eb 17                	jmp    8014df <open+0x86>
	}

	return fd2num(fd);
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ce:	e8 1c f8 ff ff       	call   800cef <fd2num>
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 05                	jmp    8014df <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f6:	e8 a2 fd ff ff       	call   80129d <fsipc>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	ff 75 08             	pushl  0x8(%ebp)
  80150b:	e8 ef f7 ff ff       	call   800cff <fd2data>
  801510:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	68 4b 22 80 00       	push   $0x80224b
  80151a:	53                   	push   %ebx
  80151b:	e8 b5 f1 ff ff       	call   8006d5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801520:	8b 56 04             	mov    0x4(%esi),%edx
  801523:	89 d0                	mov    %edx,%eax
  801525:	2b 06                	sub    (%esi),%eax
  801527:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801534:	00 00 00 
	stat->st_dev = &devpipe;
  801537:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80153e:	30 80 00 
	return 0;
}
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
  801546:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801557:	53                   	push   %ebx
  801558:	6a 00                	push   $0x0
  80155a:	e8 05 f6 ff ff       	call   800b64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80155f:	89 1c 24             	mov    %ebx,(%esp)
  801562:	e8 98 f7 ff ff       	call   800cff <fd2data>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	50                   	push   %eax
  80156b:	6a 00                	push   $0x0
  80156d:	e8 f2 f5 ff ff       	call   800b64 <sys_page_unmap>
}
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 1c             	sub    $0x1c,%esp
  801580:	89 c7                	mov    %eax,%edi
  801582:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801584:	a1 04 40 80 00       	mov    0x804004,%eax
  801589:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	57                   	push   %edi
  801590:	e8 74 05 00 00       	call   801b09 <pageref>
  801595:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801598:	89 34 24             	mov    %esi,(%esp)
  80159b:	e8 69 05 00 00       	call   801b09 <pageref>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015a6:	0f 94 c0             	sete   %al
  8015a9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8015ac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015b2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015b5:	39 cb                	cmp    %ecx,%ebx
  8015b7:	74 15                	je     8015ce <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8015b9:	8b 52 58             	mov    0x58(%edx),%edx
  8015bc:	50                   	push   %eax
  8015bd:	52                   	push   %edx
  8015be:	53                   	push   %ebx
  8015bf:	68 58 22 80 00       	push   $0x802258
  8015c4:	e8 88 eb ff ff       	call   800151 <cprintf>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	eb b6                	jmp    801584 <_pipeisclosed+0xd>
	}
}
  8015ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 28             	sub    $0x28,%esp
  8015df:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015e2:	56                   	push   %esi
  8015e3:	e8 17 f7 ff ff       	call   800cff <fd2data>
  8015e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f2:	eb 4b                	jmp    80163f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f4:	89 da                	mov    %ebx,%edx
  8015f6:	89 f0                	mov    %esi,%eax
  8015f8:	e8 7a ff ff ff       	call   801577 <_pipeisclosed>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	75 48                	jne    801649 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801601:	e8 ba f4 ff ff       	call   800ac0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801606:	8b 43 04             	mov    0x4(%ebx),%eax
  801609:	8b 0b                	mov    (%ebx),%ecx
  80160b:	8d 51 20             	lea    0x20(%ecx),%edx
  80160e:	39 d0                	cmp    %edx,%eax
  801610:	73 e2                	jae    8015f4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801615:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801619:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	c1 fa 1f             	sar    $0x1f,%edx
  801621:	89 d1                	mov    %edx,%ecx
  801623:	c1 e9 1b             	shr    $0x1b,%ecx
  801626:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801629:	83 e2 1f             	and    $0x1f,%edx
  80162c:	29 ca                	sub    %ecx,%edx
  80162e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801632:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801636:	83 c0 01             	add    $0x1,%eax
  801639:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163c:	83 c7 01             	add    $0x1,%edi
  80163f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801642:	75 c2                	jne    801606 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801644:	8b 45 10             	mov    0x10(%ebp),%eax
  801647:	eb 05                	jmp    80164e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801649:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80164e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	57                   	push   %edi
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	83 ec 18             	sub    $0x18,%esp
  80165f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801662:	57                   	push   %edi
  801663:	e8 97 f6 ff ff       	call   800cff <fd2data>
  801668:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801672:	eb 3d                	jmp    8016b1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801674:	85 db                	test   %ebx,%ebx
  801676:	74 04                	je     80167c <devpipe_read+0x26>
				return i;
  801678:	89 d8                	mov    %ebx,%eax
  80167a:	eb 44                	jmp    8016c0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80167c:	89 f2                	mov    %esi,%edx
  80167e:	89 f8                	mov    %edi,%eax
  801680:	e8 f2 fe ff ff       	call   801577 <_pipeisclosed>
  801685:	85 c0                	test   %eax,%eax
  801687:	75 32                	jne    8016bb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801689:	e8 32 f4 ff ff       	call   800ac0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80168e:	8b 06                	mov    (%esi),%eax
  801690:	3b 46 04             	cmp    0x4(%esi),%eax
  801693:	74 df                	je     801674 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801695:	99                   	cltd   
  801696:	c1 ea 1b             	shr    $0x1b,%edx
  801699:	01 d0                	add    %edx,%eax
  80169b:	83 e0 1f             	and    $0x1f,%eax
  80169e:	29 d0                	sub    %edx,%eax
  8016a0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ab:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ae:	83 c3 01             	add    $0x1,%ebx
  8016b1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016b4:	75 d8                	jne    80168e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b9:	eb 05                	jmp    8016c0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5f                   	pop    %edi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	e8 3d f6 ff ff       	call   800d16 <fd_alloc>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	0f 88 2c 01 00 00    	js     801812 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	68 07 04 00 00       	push   $0x407
  8016ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f1:	6a 00                	push   $0x0
  8016f3:	e8 e7 f3 ff ff       	call   800adf <sys_page_alloc>
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	0f 88 0d 01 00 00    	js     801812 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801705:	83 ec 0c             	sub    $0xc,%esp
  801708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	e8 05 f6 ff ff       	call   800d16 <fd_alloc>
  801711:	89 c3                	mov    %eax,%ebx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	0f 88 e2 00 00 00    	js     801800 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	68 07 04 00 00       	push   $0x407
  801726:	ff 75 f0             	pushl  -0x10(%ebp)
  801729:	6a 00                	push   $0x0
  80172b:	e8 af f3 ff ff       	call   800adf <sys_page_alloc>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	0f 88 c3 00 00 00    	js     801800 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	ff 75 f4             	pushl  -0xc(%ebp)
  801743:	e8 b7 f5 ff ff       	call   800cff <fd2data>
  801748:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174a:	83 c4 0c             	add    $0xc,%esp
  80174d:	68 07 04 00 00       	push   $0x407
  801752:	50                   	push   %eax
  801753:	6a 00                	push   $0x0
  801755:	e8 85 f3 ff ff       	call   800adf <sys_page_alloc>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	0f 88 89 00 00 00    	js     8017f0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	ff 75 f0             	pushl  -0x10(%ebp)
  80176d:	e8 8d f5 ff ff       	call   800cff <fd2data>
  801772:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801779:	50                   	push   %eax
  80177a:	6a 00                	push   $0x0
  80177c:	56                   	push   %esi
  80177d:	6a 00                	push   $0x0
  80177f:	e8 9e f3 ff ff       	call   800b22 <sys_page_map>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	83 c4 20             	add    $0x20,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 55                	js     8017e2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80178d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801796:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017a2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bd:	e8 2d f5 ff ff       	call   800cef <fd2num>
  8017c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c7:	83 c4 04             	add    $0x4,%esp
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	e8 1d f5 ff ff       	call   800cef <fd2num>
  8017d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	eb 30                	jmp    801812 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	56                   	push   %esi
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 77 f3 ff ff       	call   800b64 <sys_page_unmap>
  8017ed:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 67 f3 ff ff       	call   800b64 <sys_page_unmap>
  8017fd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	ff 75 f4             	pushl  -0xc(%ebp)
  801806:	6a 00                	push   $0x0
  801808:	e8 57 f3 ff ff       	call   800b64 <sys_page_unmap>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801812:	89 d0                	mov    %edx,%eax
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	ff 75 08             	pushl  0x8(%ebp)
  801828:	e8 38 f5 ff ff       	call   800d65 <fd_lookup>
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 d2                	test   %edx,%edx
  801834:	78 18                	js     80184e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	ff 75 f4             	pushl  -0xc(%ebp)
  80183c:	e8 be f4 ff ff       	call   800cff <fd2data>
	return _pipeisclosed(fd, p);
  801841:	89 c2                	mov    %eax,%edx
  801843:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801846:	e8 2c fd ff ff       	call   801577 <_pipeisclosed>
  80184b:	83 c4 10             	add    $0x10,%esp
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801860:	68 89 22 80 00       	push   $0x802289
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	e8 68 ee ff ff       	call   8006d5 <strcpy>
	return 0;
}
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	57                   	push   %edi
  801878:	56                   	push   %esi
  801879:	53                   	push   %ebx
  80187a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801880:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801885:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188b:	eb 2e                	jmp    8018bb <devcons_write+0x47>
		m = n - tot;
  80188d:	8b 55 10             	mov    0x10(%ebp),%edx
  801890:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801892:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801897:	83 fa 7f             	cmp    $0x7f,%edx
  80189a:	77 02                	ja     80189e <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80189c:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	56                   	push   %esi
  8018a2:	03 45 0c             	add    0xc(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	57                   	push   %edi
  8018a7:	e8 bb ef ff ff       	call   800867 <memmove>
		sys_cputs(buf, m);
  8018ac:	83 c4 08             	add    $0x8,%esp
  8018af:	56                   	push   %esi
  8018b0:	57                   	push   %edi
  8018b1:	e8 6d f1 ff ff       	call   800a23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b6:	01 f3                	add    %esi,%ebx
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	89 d8                	mov    %ebx,%eax
  8018bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018c0:	72 cb                	jb     80188d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5f                   	pop    %edi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d9:	75 07                	jne    8018e2 <devcons_read+0x18>
  8018db:	eb 28                	jmp    801905 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018dd:	e8 de f1 ff ff       	call   800ac0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018e2:	e8 5a f1 ff ff       	call   800a41 <sys_cgetc>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	74 f2                	je     8018dd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 16                	js     801905 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018ef:	83 f8 04             	cmp    $0x4,%eax
  8018f2:	74 0c                	je     801900 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f7:	88 02                	mov    %al,(%edx)
	return 1;
  8018f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fe:	eb 05                	jmp    801905 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801913:	6a 01                	push   $0x1
  801915:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	e8 05 f1 ff ff       	call   800a23 <sys_cputs>
  80191e:	83 c4 10             	add    $0x10,%esp
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <getchar>:

int
getchar(void)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801929:	6a 01                	push   $0x1
  80192b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192e:	50                   	push   %eax
  80192f:	6a 00                	push   $0x0
  801931:	e8 98 f6 ff ff       	call   800fce <read>
	if (r < 0)
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 0f                	js     80194c <getchar+0x29>
		return r;
	if (r < 1)
  80193d:	85 c0                	test   %eax,%eax
  80193f:	7e 06                	jle    801947 <getchar+0x24>
		return -E_EOF;
	return c;
  801941:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801945:	eb 05                	jmp    80194c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801947:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	ff 75 08             	pushl  0x8(%ebp)
  80195b:	e8 05 f4 ff ff       	call   800d65 <fd_lookup>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 11                	js     801978 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801970:	39 10                	cmp    %edx,(%eax)
  801972:	0f 94 c0             	sete   %al
  801975:	0f b6 c0             	movzbl %al,%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <opencons>:

int
opencons(void)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801980:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801983:	50                   	push   %eax
  801984:	e8 8d f3 ff ff       	call   800d16 <fd_alloc>
  801989:	83 c4 10             	add    $0x10,%esp
		return r;
  80198c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 3e                	js     8019d0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	68 07 04 00 00       	push   $0x407
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	6a 00                	push   $0x0
  80199f:	e8 3b f1 ff ff       	call   800adf <sys_page_alloc>
  8019a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 23                	js     8019d0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	50                   	push   %eax
  8019c6:	e8 24 f3 ff ff       	call   800cef <fd2num>
  8019cb:	89 c2                	mov    %eax,%edx
  8019cd:	83 c4 10             	add    $0x10,%esp
}
  8019d0:	89 d0                	mov    %edx,%eax
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019d9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019dc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019e2:	e8 ba f0 ff ff       	call   800aa1 <sys_getenvid>
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	56                   	push   %esi
  8019f1:	50                   	push   %eax
  8019f2:	68 98 22 80 00       	push   $0x802298
  8019f7:	e8 55 e7 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019fc:	83 c4 18             	add    $0x18,%esp
  8019ff:	53                   	push   %ebx
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	e8 f8 e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a08:	c7 04 24 0c 1e 80 00 	movl   $0x801e0c,(%esp)
  801a0f:	e8 3d e7 ff ff       	call   800151 <cprintf>
  801a14:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a17:	cc                   	int3   
  801a18:	eb fd                	jmp    801a17 <_panic+0x43>

00801a1a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a28:	85 f6                	test   %esi,%esi
  801a2a:	74 06                	je     801a32 <ipc_recv+0x18>
  801a2c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a32:	85 db                	test   %ebx,%ebx
  801a34:	74 06                	je     801a3c <ipc_recv+0x22>
  801a36:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a3c:	83 f8 01             	cmp    $0x1,%eax
  801a3f:	19 d2                	sbb    %edx,%edx
  801a41:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	50                   	push   %eax
  801a47:	e8 43 f2 ff ff       	call   800c8f <sys_ipc_recv>
  801a4c:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 d2                	test   %edx,%edx
  801a53:	75 24                	jne    801a79 <ipc_recv+0x5f>
	if (from_env_store)
  801a55:	85 f6                	test   %esi,%esi
  801a57:	74 0a                	je     801a63 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a59:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5e:	8b 40 70             	mov    0x70(%eax),%eax
  801a61:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	74 0a                	je     801a71 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a67:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6c:	8b 40 74             	mov    0x74(%eax),%eax
  801a6f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a71:	a1 04 40 80 00       	mov    0x804004,%eax
  801a76:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a92:	83 fb 01             	cmp    $0x1,%ebx
  801a95:	19 c0                	sbb    %eax,%eax
  801a97:	09 c3                	or     %eax,%ebx
  801a99:	eb 1c                	jmp    801ab7 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a9b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9e:	74 12                	je     801ab2 <ipc_send+0x32>
  801aa0:	50                   	push   %eax
  801aa1:	68 bc 22 80 00       	push   $0x8022bc
  801aa6:	6a 36                	push   $0x36
  801aa8:	68 d3 22 80 00       	push   $0x8022d3
  801aad:	e8 22 ff ff ff       	call   8019d4 <_panic>
		sys_yield();
  801ab2:	e8 09 f0 ff ff       	call   800ac0 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ab7:	ff 75 14             	pushl  0x14(%ebp)
  801aba:	53                   	push   %ebx
  801abb:	56                   	push   %esi
  801abc:	57                   	push   %edi
  801abd:	e8 aa f1 ff ff       	call   800c6c <sys_ipc_try_send>
		if (ret == 0) break;
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	75 d2                	jne    801a9b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801adc:	6b d0 78             	imul   $0x78,%eax,%edx
  801adf:	83 c2 50             	add    $0x50,%edx
  801ae2:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ae8:	39 ca                	cmp    %ecx,%edx
  801aea:	75 0d                	jne    801af9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aec:	6b c0 78             	imul   $0x78,%eax,%eax
  801aef:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801af4:	8b 40 08             	mov    0x8(%eax),%eax
  801af7:	eb 0e                	jmp    801b07 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af9:	83 c0 01             	add    $0x1,%eax
  801afc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b01:	75 d9                	jne    801adc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b03:	66 b8 00 00          	mov    $0x0,%ax
}
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0f:	89 d0                	mov    %edx,%eax
  801b11:	c1 e8 16             	shr    $0x16,%eax
  801b14:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b20:	f6 c1 01             	test   $0x1,%cl
  801b23:	74 1d                	je     801b42 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2f:	f6 c2 01             	test   $0x1,%dl
  801b32:	74 0e                	je     801b42 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b34:	c1 ea 0c             	shr    $0xc,%edx
  801b37:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3e:	ef 
  801b3f:	0f b7 c0             	movzwl %ax,%eax
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    
  801b44:	66 90                	xchg   %ax,%ax
  801b46:	66 90                	xchg   %ax,%ax
  801b48:	66 90                	xchg   %ax,%ax
  801b4a:	66 90                	xchg   %ax,%ax
  801b4c:	66 90                	xchg   %ax,%ax
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	83 ec 10             	sub    $0x10,%esp
  801b56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b66:	85 d2                	test   %edx,%edx
  801b68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6c:	89 34 24             	mov    %esi,(%esp)
  801b6f:	89 c8                	mov    %ecx,%eax
  801b71:	75 35                	jne    801ba8 <__udivdi3+0x58>
  801b73:	39 f1                	cmp    %esi,%ecx
  801b75:	0f 87 bd 00 00 00    	ja     801c38 <__udivdi3+0xe8>
  801b7b:	85 c9                	test   %ecx,%ecx
  801b7d:	89 cd                	mov    %ecx,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f1                	div    %ecx
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c6                	mov    %eax,%esi
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	f7 f5                	div    %ebp
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
  801ba1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	3b 14 24             	cmp    (%esp),%edx
  801bab:	77 7b                	ja     801c28 <__udivdi3+0xd8>
  801bad:	0f bd f2             	bsr    %edx,%esi
  801bb0:	83 f6 1f             	xor    $0x1f,%esi
  801bb3:	0f 84 97 00 00 00    	je     801c50 <__udivdi3+0x100>
  801bb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bbe:	89 d7                	mov    %edx,%edi
  801bc0:	89 f1                	mov    %esi,%ecx
  801bc2:	29 f5                	sub    %esi,%ebp
  801bc4:	d3 e7                	shl    %cl,%edi
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	89 e9                	mov    %ebp,%ecx
  801bca:	d3 ea                	shr    %cl,%edx
  801bcc:	89 f1                	mov    %esi,%ecx
  801bce:	09 fa                	or     %edi,%edx
  801bd0:	8b 3c 24             	mov    (%esp),%edi
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd9:	89 e9                	mov    %ebp,%ecx
  801bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801be3:	89 fa                	mov    %edi,%edx
  801be5:	d3 ea                	shr    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e7                	shl    %cl,%edi
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	d3 e8                	shr    %cl,%eax
  801bef:	09 c7                	or     %eax,%edi
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	f7 74 24 08          	divl   0x8(%esp)
  801bf7:	89 d5                	mov    %edx,%ebp
  801bf9:	89 c7                	mov    %eax,%edi
  801bfb:	f7 64 24 0c          	mull   0xc(%esp)
  801bff:	39 d5                	cmp    %edx,%ebp
  801c01:	89 14 24             	mov    %edx,(%esp)
  801c04:	72 11                	jb     801c17 <__udivdi3+0xc7>
  801c06:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c0a:	89 f1                	mov    %esi,%ecx
  801c0c:	d3 e2                	shl    %cl,%edx
  801c0e:	39 c2                	cmp    %eax,%edx
  801c10:	73 5e                	jae    801c70 <__udivdi3+0x120>
  801c12:	3b 2c 24             	cmp    (%esp),%ebp
  801c15:	75 59                	jne    801c70 <__udivdi3+0x120>
  801c17:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	31 f6                	xor    %esi,%esi
  801c2a:	31 c0                	xor    %eax,%eax
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	89 f2                	mov    %esi,%edx
  801c3a:	31 f6                	xor    %esi,%esi
  801c3c:	89 f8                	mov    %edi,%eax
  801c3e:	f7 f1                	div    %ecx
  801c40:	89 f2                	mov    %esi,%edx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c54:	76 0b                	jbe    801c61 <__udivdi3+0x111>
  801c56:	31 c0                	xor    %eax,%eax
  801c58:	3b 14 24             	cmp    (%esp),%edx
  801c5b:	0f 83 37 ff ff ff    	jae    801b98 <__udivdi3+0x48>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	e9 2d ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c6b:	90                   	nop
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	31 f6                	xor    %esi,%esi
  801c74:	e9 1f ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	83 ec 20             	sub    $0x20,%esp
  801c86:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c92:	89 c6                	mov    %eax,%esi
  801c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ca0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ca4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ca8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	75 1e                	jne    801cd0 <__umoddi3+0x50>
  801cb2:	39 f7                	cmp    %esi,%edi
  801cb4:	76 52                	jbe    801d08 <__umoddi3+0x88>
  801cb6:	89 c8                	mov    %ecx,%eax
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	f7 f7                	div    %edi
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	83 c4 20             	add    $0x20,%esp
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
  801cc7:	89 f6                	mov    %esi,%esi
  801cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cd0:	39 f0                	cmp    %esi,%eax
  801cd2:	77 5c                	ja     801d30 <__umoddi3+0xb0>
  801cd4:	0f bd e8             	bsr    %eax,%ebp
  801cd7:	83 f5 1f             	xor    $0x1f,%ebp
  801cda:	75 64                	jne    801d40 <__umoddi3+0xc0>
  801cdc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ce0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ce4:	0f 86 f6 00 00 00    	jbe    801de0 <__umoddi3+0x160>
  801cea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cee:	0f 82 ec 00 00 00    	jb     801de0 <__umoddi3+0x160>
  801cf4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cf8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cfc:	83 c4 20             	add    $0x20,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
  801d03:	90                   	nop
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	85 ff                	test   %edi,%edi
  801d0a:	89 fd                	mov    %edi,%ebp
  801d0c:	75 0b                	jne    801d19 <__umoddi3+0x99>
  801d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f7                	div    %edi
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f5                	div    %ebp
  801d21:	89 c8                	mov    %ecx,%eax
  801d23:	f7 f5                	div    %ebp
  801d25:	eb 95                	jmp    801cbc <__umoddi3+0x3c>
  801d27:	89 f6                	mov    %esi,%esi
  801d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 20             	add    $0x20,%esp
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    
  801d3b:	90                   	nop
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	b8 20 00 00 00       	mov    $0x20,%eax
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	29 e8                	sub    %ebp,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 c7                	mov    %eax,%edi
  801d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d5f:	09 d1                	or     %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d67:	89 e9                	mov    %ebp,%ecx
  801d69:	d3 e0                	shl    %cl,%eax
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	89 c7                	mov    %eax,%edi
  801d79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d7d:	d3 e6                	shl    %cl,%esi
  801d7f:	89 d1                	mov    %edx,%ecx
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	09 f0                	or     %esi,%eax
  801d89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d8d:	f7 74 24 10          	divl   0x10(%esp)
  801d91:	d3 e6                	shl    %cl,%esi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	f7 64 24 0c          	mull   0xc(%esp)
  801d99:	39 d1                	cmp    %edx,%ecx
  801d9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	72 0a                	jb     801daf <__umoddi3+0x12f>
  801da5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801da9:	73 10                	jae    801dbb <__umoddi3+0x13b>
  801dab:	39 d1                	cmp    %edx,%ecx
  801dad:	75 0c                	jne    801dbb <__umoddi3+0x13b>
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801db7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dbb:	89 ca                	mov    %ecx,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dc3:	29 f0                	sub    %esi,%eax
  801dc5:	19 fa                	sbb    %edi,%edx
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dce:	89 d7                	mov    %edx,%edi
  801dd0:	d3 e7                	shl    %cl,%edi
  801dd2:	89 e9                	mov    %ebp,%ecx
  801dd4:	09 f8                	or     %edi,%eax
  801dd6:	d3 ea                	shr    %cl,%edx
  801dd8:	83 c4 20             	add    $0x20,%esp
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop
  801de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801de4:	29 f9                	sub    %edi,%ecx
  801de6:	19 c6                	sbb    %eax,%esi
  801de8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dec:	89 74 24 18          	mov    %esi,0x18(%esp)
  801df0:	e9 ff fe ff ff       	jmp    801cf4 <__umoddi3+0x74>
