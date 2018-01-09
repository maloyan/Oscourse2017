
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 00 1e 80 00       	push   $0x801e00
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
  80005b:	83 c4 10             	add    $0x10,%esp
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 33 0a 00 00       	call   800aa3 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 78             	imul   $0x78,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
  80009c:	83 c4 10             	add    $0x10,%esp
#endif
}
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 0c 0e 00 00       	call   800ebd <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 a7 09 00 00       	call   800a62 <sys_env_destroy>
  8000bb:	83 c4 10             	add    $0x10,%esp
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 35 09 00 00       	call   800a25 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 4f 01 00 00       	call   800285 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 da 08 00 00       	call   800a25 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800182:	8b 45 10             	mov    0x10(%ebp),%eax
  800185:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800192:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800195:	72 05                	jb     80019c <printnum+0x35>
  800197:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80019a:	77 3e                	ja     8001da <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 18             	pushl  0x18(%ebp)
  8001a2:	83 eb 01             	sub    $0x1,%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	50                   	push   %eax
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 95 19 00 00       	call   801b50 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 13                	jmp    8001e1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f ed                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 87 1a 00 00       	call   801c80 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 18 1e 80 00 	movsbl 0x801e18(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
  800206:	83 c4 10             	add    $0x10,%esp
}
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800214:	83 fa 01             	cmp    $0x1,%edx
  800217:	7e 0e                	jle    800227 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	8b 52 04             	mov    0x4(%edx),%edx
  800225:	eb 22                	jmp    800249 <getuint+0x38>
	else if (lflag)
  800227:	85 d2                	test   %edx,%edx
  800229:	74 10                	je     80023b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	eb 0e                	jmp    800249 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800240:	89 08                	mov    %ecx,(%eax)
  800242:	8b 02                	mov    (%edx),%eax
  800244:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800255:	8b 10                	mov    (%eax),%edx
  800257:	3b 50 04             	cmp    0x4(%eax),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	88 02                	mov    %al,(%edx)
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	e8 05 00 00 00       	call   800285 <vprintfmt>
	va_end(ap);
  800280:	83 c4 10             	add    $0x10,%esp
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	57                   	push   %edi
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	83 ec 2c             	sub    $0x2c,%esp
  80028e:	8b 75 08             	mov    0x8(%ebp),%esi
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800294:	8b 7d 10             	mov    0x10(%ebp),%edi
  800297:	eb 12                	jmp    8002ab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800299:	85 c0                	test   %eax,%eax
  80029b:	0f 84 8d 03 00 00    	je     80062e <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	ff d6                	call   *%esi
  8002a8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ab:	83 c7 01             	add    $0x1,%edi
  8002ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b2:	83 f8 25             	cmp    $0x25,%eax
  8002b5:	75 e2                	jne    800299 <vprintfmt+0x14>
  8002b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	eb 07                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 07             	movzbl (%edi),%eax
  8002e7:	0f b6 c8             	movzbl %al,%ecx
  8002ea:	83 e8 23             	sub    $0x23,%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 1e 03 00 00    	ja     800613 <vprintfmt+0x38e>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800302:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800306:	eb d6                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030b:	b8 00 00 00 00       	mov    $0x0,%eax
  800310:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800313:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800316:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800320:	83 fa 09             	cmp    $0x9,%edx
  800323:	77 38                	ja     80035d <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800325:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800328:	eb e9                	jmp    800313 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032a:	8b 45 14             	mov    0x14(%ebp),%eax
  80032d:	8d 48 04             	lea    0x4(%eax),%ecx
  800330:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800333:	8b 00                	mov    (%eax),%eax
  800335:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033b:	eb 26                	jmp    800363 <vprintfmt+0xde>
  80033d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800340:	89 c8                	mov    %ecx,%eax
  800342:	c1 f8 1f             	sar    $0x1f,%eax
  800345:	f7 d0                	not    %eax
  800347:	21 c1                	and    %eax,%ecx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034f:	eb 8d                	jmp    8002de <vprintfmt+0x59>
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800354:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035b:	eb 81                	jmp    8002de <vprintfmt+0x59>
  80035d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800360:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800367:	0f 89 71 ff ff ff    	jns    8002de <vprintfmt+0x59>
				width = precision, precision = -1;
  80036d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037a:	e9 5f ff ff ff       	jmp    8002de <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800385:	e9 54 ff ff ff       	jmp    8002de <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038a:	8b 45 14             	mov    0x14(%ebp),%eax
  80038d:	8d 50 04             	lea    0x4(%eax),%edx
  800390:	89 55 14             	mov    %edx,0x14(%ebp)
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	53                   	push   %ebx
  800397:	ff 30                	pushl  (%eax)
  800399:	ff d6                	call   *%esi
			break;
  80039b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a1:	e9 05 ff ff ff       	jmp    8002ab <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	99                   	cltd   
  8003b2:	31 d0                	xor    %edx,%eax
  8003b4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b6:	83 f8 0f             	cmp    $0xf,%eax
  8003b9:	7f 0b                	jg     8003c6 <vprintfmt+0x141>
  8003bb:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003c2:	85 d2                	test   %edx,%edx
  8003c4:	75 18                	jne    8003de <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8003c6:	50                   	push   %eax
  8003c7:	68 30 1e 80 00       	push   $0x801e30
  8003cc:	53                   	push   %ebx
  8003cd:	56                   	push   %esi
  8003ce:	e8 95 fe ff ff       	call   800268 <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d9:	e9 cd fe ff ff       	jmp    8002ab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003de:	52                   	push   %edx
  8003df:	68 31 22 80 00       	push   $0x802231
  8003e4:	53                   	push   %ebx
  8003e5:	56                   	push   %esi
  8003e6:	e8 7d fe ff ff       	call   800268 <printfmt>
  8003eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	e9 b5 fe ff ff       	jmp    8002ab <vprintfmt+0x26>
  8003f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 38                	mov    (%eax),%edi
  80040a:	85 ff                	test   %edi,%edi
  80040c:	75 05                	jne    800413 <vprintfmt+0x18e>
				p = "(null)";
  80040e:	bf 29 1e 80 00       	mov    $0x801e29,%edi
			if (width > 0 && padc != '-')
  800413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800417:	0f 84 91 00 00 00    	je     8004ae <vprintfmt+0x229>
  80041d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800421:	0f 8e 95 00 00 00    	jle    8004bc <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	51                   	push   %ecx
  80042b:	57                   	push   %edi
  80042c:	e8 85 02 00 00       	call   8006b6 <strnlen>
  800431:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800434:	29 c1                	sub    %eax,%ecx
  800436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1d4>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1c5>
  80045d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800463:	89 c8                	mov    %ecx,%eax
  800465:	c1 f8 1f             	sar    $0x1f,%eax
  800468:	f7 d0                	not    %eax
  80046a:	21 c8                	and    %ecx,%eax
  80046c:	29 c1                	sub    %eax,%ecx
  80046e:	89 75 08             	mov    %esi,0x8(%ebp)
  800471:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800474:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800477:	89 cb                	mov    %ecx,%ebx
  800479:	eb 4d                	jmp    8004c8 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047f:	74 1b                	je     80049c <vprintfmt+0x217>
  800481:	0f be c0             	movsbl %al,%eax
  800484:	83 e8 20             	sub    $0x20,%eax
  800487:	83 f8 5e             	cmp    $0x5e,%eax
  80048a:	76 10                	jbe    80049c <vprintfmt+0x217>
					putch('?', putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	ff 75 0c             	pushl  0xc(%ebp)
  800492:	6a 3f                	push   $0x3f
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	eb 0d                	jmp    8004a9 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	52                   	push   %edx
  8004a3:	ff 55 08             	call   *0x8(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	83 eb 01             	sub    $0x1,%ebx
  8004ac:	eb 1a                	jmp    8004c8 <vprintfmt+0x243>
  8004ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ba:	eb 0c                	jmp    8004c8 <vprintfmt+0x243>
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c8:	83 c7 01             	add    $0x1,%edi
  8004cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cf:	0f be d0             	movsbl %al,%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 23                	je     8004f9 <vprintfmt+0x274>
  8004d6:	85 f6                	test   %esi,%esi
  8004d8:	78 a1                	js     80047b <vprintfmt+0x1f6>
  8004da:	83 ee 01             	sub    $0x1,%esi
  8004dd:	79 9c                	jns    80047b <vprintfmt+0x1f6>
  8004df:	89 df                	mov    %ebx,%edi
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e7:	eb 18                	jmp    800501 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	6a 20                	push   $0x20
  8004ef:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	eb 08                	jmp    800501 <vprintfmt+0x27c>
  8004f9:	89 df                	mov    %ebx,%edi
  8004fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800501:	85 ff                	test   %edi,%edi
  800503:	7f e4                	jg     8004e9 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800508:	e9 9e fd ff ff       	jmp    8002ab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050d:	83 fa 01             	cmp    $0x1,%edx
  800510:	7e 16                	jle    800528 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 08             	lea    0x8(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 50 04             	mov    0x4(%eax),%edx
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	eb 32                	jmp    80055a <vprintfmt+0x2d5>
	else if (lflag)
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 18                	je     800544 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053a:	89 c1                	mov    %eax,%ecx
  80053c:	c1 f9 1f             	sar    $0x1f,%ecx
  80053f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800542:	eb 16                	jmp    80055a <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800552:	89 c1                	mov    %eax,%ecx
  800554:	c1 f9 1f             	sar    $0x1f,%ecx
  800557:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800560:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800565:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800569:	79 74                	jns    8005df <vprintfmt+0x35a>
				putch('-', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 2d                	push   $0x2d
  800571:	ff d6                	call   *%esi
				num = -(long long) num;
  800573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800576:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800579:	f7 d8                	neg    %eax
  80057b:	83 d2 00             	adc    $0x0,%edx
  80057e:	f7 da                	neg    %edx
  800580:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800588:	eb 55                	jmp    8005df <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 7f fc ff ff       	call   800211 <getuint>
			base = 10;
  800592:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800597:	eb 46                	jmp    8005df <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	e8 70 fc ff ff       	call   800211 <getuint>
			base = 8;
  8005a1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a6:	eb 37                	jmp    8005df <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 30                	push   $0x30
  8005ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b0:	83 c4 08             	add    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 78                	push   $0x78
  8005b6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d0:	eb 0d                	jmp    8005df <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 37 fc ff ff       	call   800211 <getuint>
			base = 16;
  8005da:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e6:	57                   	push   %edi
  8005e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ea:	51                   	push   %ecx
  8005eb:	52                   	push   %edx
  8005ec:	50                   	push   %eax
  8005ed:	89 da                	mov    %ebx,%edx
  8005ef:	89 f0                	mov    %esi,%eax
  8005f1:	e8 71 fb ff ff       	call   800167 <printnum>
			break;
  8005f6:	83 c4 20             	add    $0x20,%esp
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fc:	e9 aa fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	51                   	push   %ecx
  800606:	ff d6                	call   *%esi
			break;
  800608:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060e:	e9 98 fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 25                	push   $0x25
  800619:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	eb 03                	jmp    800623 <vprintfmt+0x39e>
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800627:	75 f7                	jne    800620 <vprintfmt+0x39b>
  800629:	e9 7d fc ff ff       	jmp    8002ab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800631:	5b                   	pop    %ebx
  800632:	5e                   	pop    %esi
  800633:	5f                   	pop    %edi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	83 ec 18             	sub    $0x18,%esp
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800642:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800645:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800649:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800653:	85 c0                	test   %eax,%eax
  800655:	74 26                	je     80067d <vsnprintf+0x47>
  800657:	85 d2                	test   %edx,%edx
  800659:	7e 22                	jle    80067d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065b:	ff 75 14             	pushl  0x14(%ebp)
  80065e:	ff 75 10             	pushl  0x10(%ebp)
  800661:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800664:	50                   	push   %eax
  800665:	68 4b 02 80 00       	push   $0x80024b
  80066a:	e8 16 fc ff ff       	call   800285 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800672:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	eb 05                	jmp    800682 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800682:	c9                   	leave  
  800683:	c3                   	ret    

00800684 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068d:	50                   	push   %eax
  80068e:	ff 75 10             	pushl  0x10(%ebp)
  800691:	ff 75 0c             	pushl  0xc(%ebp)
  800694:	ff 75 08             	pushl  0x8(%ebp)
  800697:	e8 9a ff ff ff       	call   800636 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069c:	c9                   	leave  
  80069d:	c3                   	ret    

0080069e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a9:	eb 03                	jmp    8006ae <strlen+0x10>
		n++;
  8006ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b2:	75 f7                	jne    8006ab <strlen+0xd>
		n++;
	return n;
}
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c4:	eb 03                	jmp    8006c9 <strnlen+0x13>
		n++;
  8006c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c9:	39 c2                	cmp    %eax,%edx
  8006cb:	74 08                	je     8006d5 <strnlen+0x1f>
  8006cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d1:	75 f3                	jne    8006c6 <strnlen+0x10>
  8006d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	53                   	push   %ebx
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	83 c2 01             	add    $0x1,%edx
  8006e6:	83 c1 01             	add    $0x1,%ecx
  8006e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006f0:	84 db                	test   %bl,%bl
  8006f2:	75 ef                	jne    8006e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f4:	5b                   	pop    %ebx
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fe:	53                   	push   %ebx
  8006ff:	e8 9a ff ff ff       	call   80069e <strlen>
  800704:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800707:	ff 75 0c             	pushl  0xc(%ebp)
  80070a:	01 d8                	add    %ebx,%eax
  80070c:	50                   	push   %eax
  80070d:	e8 c5 ff ff ff       	call   8006d7 <strcpy>
	return dst;
}
  800712:	89 d8                	mov    %ebx,%eax
  800714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800717:	c9                   	leave  
  800718:	c3                   	ret    

00800719 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	8b 75 08             	mov    0x8(%ebp),%esi
  800721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800724:	89 f3                	mov    %esi,%ebx
  800726:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800729:	89 f2                	mov    %esi,%edx
  80072b:	eb 0f                	jmp    80073c <strncpy+0x23>
		*dst++ = *src;
  80072d:	83 c2 01             	add    $0x1,%edx
  800730:	0f b6 01             	movzbl (%ecx),%eax
  800733:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800736:	80 39 01             	cmpb   $0x1,(%ecx)
  800739:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073c:	39 da                	cmp    %ebx,%edx
  80073e:	75 ed                	jne    80072d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800740:	89 f0                	mov    %esi,%eax
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	56                   	push   %esi
  80074a:	53                   	push   %ebx
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800751:	8b 55 10             	mov    0x10(%ebp),%edx
  800754:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800756:	85 d2                	test   %edx,%edx
  800758:	74 21                	je     80077b <strlcpy+0x35>
  80075a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075e:	89 f2                	mov    %esi,%edx
  800760:	eb 09                	jmp    80076b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800762:	83 c2 01             	add    $0x1,%edx
  800765:	83 c1 01             	add    $0x1,%ecx
  800768:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076b:	39 c2                	cmp    %eax,%edx
  80076d:	74 09                	je     800778 <strlcpy+0x32>
  80076f:	0f b6 19             	movzbl (%ecx),%ebx
  800772:	84 db                	test   %bl,%bl
  800774:	75 ec                	jne    800762 <strlcpy+0x1c>
  800776:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800778:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077b:	29 f0                	sub    %esi,%eax
}
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80078a:	eb 06                	jmp    800792 <strcmp+0x11>
		p++, q++;
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	84 c0                	test   %al,%al
  800797:	74 04                	je     80079d <strcmp+0x1c>
  800799:	3a 02                	cmp    (%edx),%al
  80079b:	74 ef                	je     80078c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079d:	0f b6 c0             	movzbl %al,%eax
  8007a0:	0f b6 12             	movzbl (%edx),%edx
  8007a3:	29 d0                	sub    %edx,%eax
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	89 c3                	mov    %eax,%ebx
  8007b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b6:	eb 06                	jmp    8007be <strncmp+0x17>
		n--, p++, q++;
  8007b8:	83 c0 01             	add    $0x1,%eax
  8007bb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007be:	39 d8                	cmp    %ebx,%eax
  8007c0:	74 15                	je     8007d7 <strncmp+0x30>
  8007c2:	0f b6 08             	movzbl (%eax),%ecx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	74 04                	je     8007cd <strncmp+0x26>
  8007c9:	3a 0a                	cmp    (%edx),%cl
  8007cb:	74 eb                	je     8007b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 00             	movzbl (%eax),%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
  8007d5:	eb 05                	jmp    8007dc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e9:	eb 07                	jmp    8007f2 <strchr+0x13>
		if (*s == c)
  8007eb:	38 ca                	cmp    %cl,%dl
  8007ed:	74 0f                	je     8007fe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ef:	83 c0 01             	add    $0x1,%eax
  8007f2:	0f b6 10             	movzbl (%eax),%edx
  8007f5:	84 d2                	test   %dl,%dl
  8007f7:	75 f2                	jne    8007eb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 03                	jmp    80080f <strfind+0xf>
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800812:	84 d2                	test   %dl,%dl
  800814:	74 04                	je     80081a <strfind+0x1a>
  800816:	38 ca                	cmp    %cl,%dl
  800818:	75 f2                	jne    80080c <strfind+0xc>
			break;
	return (char *) s;
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	57                   	push   %edi
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 7d 08             	mov    0x8(%ebp),%edi
  800825:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 36                	je     800862 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800832:	75 28                	jne    80085c <memset+0x40>
  800834:	f6 c1 03             	test   $0x3,%cl
  800837:	75 23                	jne    80085c <memset+0x40>
		c &= 0xFF;
  800839:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083d:	89 d3                	mov    %edx,%ebx
  80083f:	c1 e3 08             	shl    $0x8,%ebx
  800842:	89 d6                	mov    %edx,%esi
  800844:	c1 e6 18             	shl    $0x18,%esi
  800847:	89 d0                	mov    %edx,%eax
  800849:	c1 e0 10             	shl    $0x10,%eax
  80084c:	09 f0                	or     %esi,%eax
  80084e:	09 c2                	or     %eax,%edx
  800850:	89 d0                	mov    %edx,%eax
  800852:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800854:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800857:	fc                   	cld    
  800858:	f3 ab                	rep stos %eax,%es:(%edi)
  80085a:	eb 06                	jmp    800862 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	fc                   	cld    
  800860:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800862:	89 f8                	mov    %edi,%eax
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5f                   	pop    %edi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	57                   	push   %edi
  80086d:	56                   	push   %esi
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 75 0c             	mov    0xc(%ebp),%esi
  800874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800877:	39 c6                	cmp    %eax,%esi
  800879:	73 35                	jae    8008b0 <memmove+0x47>
  80087b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087e:	39 d0                	cmp    %edx,%eax
  800880:	73 2e                	jae    8008b0 <memmove+0x47>
		s += n;
		d += n;
  800882:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800885:	89 d6                	mov    %edx,%esi
  800887:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800889:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088f:	75 13                	jne    8008a4 <memmove+0x3b>
  800891:	f6 c1 03             	test   $0x3,%cl
  800894:	75 0e                	jne    8008a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800896:	83 ef 04             	sub    $0x4,%edi
  800899:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089f:	fd                   	std    
  8008a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a2:	eb 09                	jmp    8008ad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a4:	83 ef 01             	sub    $0x1,%edi
  8008a7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008aa:	fd                   	std    
  8008ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ad:	fc                   	cld    
  8008ae:	eb 1d                	jmp    8008cd <memmove+0x64>
  8008b0:	89 f2                	mov    %esi,%edx
  8008b2:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b4:	f6 c2 03             	test   $0x3,%dl
  8008b7:	75 0f                	jne    8008c8 <memmove+0x5f>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 0a                	jne    8008c8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008be:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008c1:	89 c7                	mov    %eax,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 05                	jmp    8008cd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c8:	89 c7                	mov    %eax,%edi
  8008ca:	fc                   	cld    
  8008cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	ff 75 08             	pushl  0x8(%ebp)
  8008dd:	e8 87 ff ff ff       	call   800869 <memmove>
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 c6                	mov    %eax,%esi
  8008f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f4:	eb 1a                	jmp    800910 <memcmp+0x2c>
		if (*s1 != *s2)
  8008f6:	0f b6 08             	movzbl (%eax),%ecx
  8008f9:	0f b6 1a             	movzbl (%edx),%ebx
  8008fc:	38 d9                	cmp    %bl,%cl
  8008fe:	74 0a                	je     80090a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800900:	0f b6 c1             	movzbl %cl,%eax
  800903:	0f b6 db             	movzbl %bl,%ebx
  800906:	29 d8                	sub    %ebx,%eax
  800908:	eb 0f                	jmp    800919 <memcmp+0x35>
		s1++, s2++;
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800910:	39 f0                	cmp    %esi,%eax
  800912:	75 e2                	jne    8008f6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800926:	89 c2                	mov    %eax,%edx
  800928:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80092b:	eb 07                	jmp    800934 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092d:	38 08                	cmp    %cl,(%eax)
  80092f:	74 07                	je     800938 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	39 d0                	cmp    %edx,%eax
  800936:	72 f5                	jb     80092d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800946:	eb 03                	jmp    80094b <strtol+0x11>
		s++;
  800948:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	3c 09                	cmp    $0x9,%al
  800950:	74 f6                	je     800948 <strtol+0xe>
  800952:	3c 20                	cmp    $0x20,%al
  800954:	74 f2                	je     800948 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800956:	3c 2b                	cmp    $0x2b,%al
  800958:	75 0a                	jne    800964 <strtol+0x2a>
		s++;
  80095a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095d:	bf 00 00 00 00       	mov    $0x0,%edi
  800962:	eb 10                	jmp    800974 <strtol+0x3a>
  800964:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800969:	3c 2d                	cmp    $0x2d,%al
  80096b:	75 07                	jne    800974 <strtol+0x3a>
		s++, neg = 1;
  80096d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800970:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800974:	85 db                	test   %ebx,%ebx
  800976:	0f 94 c0             	sete   %al
  800979:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097f:	75 19                	jne    80099a <strtol+0x60>
  800981:	80 39 30             	cmpb   $0x30,(%ecx)
  800984:	75 14                	jne    80099a <strtol+0x60>
  800986:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098a:	0f 85 8a 00 00 00    	jne    800a1a <strtol+0xe0>
		s += 2, base = 16;
  800990:	83 c1 02             	add    $0x2,%ecx
  800993:	bb 10 00 00 00       	mov    $0x10,%ebx
  800998:	eb 16                	jmp    8009b0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80099a:	84 c0                	test   %al,%al
  80099c:	74 12                	je     8009b0 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a6:	75 08                	jne    8009b0 <strtol+0x76>
		s++, base = 8;
  8009a8:	83 c1 01             	add    $0x1,%ecx
  8009ab:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b8:	0f b6 11             	movzbl (%ecx),%edx
  8009bb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	80 fb 09             	cmp    $0x9,%bl
  8009c3:	77 08                	ja     8009cd <strtol+0x93>
			dig = *s - '0';
  8009c5:	0f be d2             	movsbl %dl,%edx
  8009c8:	83 ea 30             	sub    $0x30,%edx
  8009cb:	eb 22                	jmp    8009ef <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009cd:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d0:	89 f3                	mov    %esi,%ebx
  8009d2:	80 fb 19             	cmp    $0x19,%bl
  8009d5:	77 08                	ja     8009df <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d7:	0f be d2             	movsbl %dl,%edx
  8009da:	83 ea 57             	sub    $0x57,%edx
  8009dd:	eb 10                	jmp    8009ef <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009df:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e2:	89 f3                	mov    %esi,%ebx
  8009e4:	80 fb 19             	cmp    $0x19,%bl
  8009e7:	77 16                	ja     8009ff <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e9:	0f be d2             	movsbl %dl,%edx
  8009ec:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ef:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f2:	7d 0f                	jge    800a03 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009fb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fd:	eb b9                	jmp    8009b8 <strtol+0x7e>
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	eb 02                	jmp    800a05 <strtol+0xcb>
  800a03:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a09:	74 05                	je     800a10 <strtol+0xd6>
		*endptr = (char *) s;
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a10:	85 ff                	test   %edi,%edi
  800a12:	74 0c                	je     800a20 <strtol+0xe6>
  800a14:	89 d0                	mov    %edx,%eax
  800a16:	f7 d8                	neg    %eax
  800a18:	eb 06                	jmp    800a20 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1a:	84 c0                	test   %al,%al
  800a1c:	75 8a                	jne    8009a8 <strtol+0x6e>
  800a1e:	eb 90                	jmp    8009b0 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5f                   	pop    %edi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
  800a36:	89 c3                	mov    %eax,%ebx
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a53:	89 d1                	mov    %edx,%ecx
  800a55:	89 d3                	mov    %edx,%ebx
  800a57:	89 d7                	mov    %edx,%edi
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a70:	b8 03 00 00 00       	mov    $0x3,%eax
  800a75:	8b 55 08             	mov    0x8(%ebp),%edx
  800a78:	89 cb                	mov    %ecx,%ebx
  800a7a:	89 cf                	mov    %ecx,%edi
  800a7c:	89 ce                	mov    %ecx,%esi
  800a7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a80:	85 c0                	test   %eax,%eax
  800a82:	7e 17                	jle    800a9b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	50                   	push   %eax
  800a88:	6a 03                	push   $0x3
  800a8a:	68 5f 21 80 00       	push   $0x80215f
  800a8f:	6a 23                	push   $0x23
  800a91:	68 7c 21 80 00       	push   $0x80217c
  800a96:	e8 3b 0f 00 00       	call   8019d6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab3:	89 d1                	mov    %edx,%ecx
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	89 d7                	mov    %edx,%edi
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_yield>:

void
sys_yield(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	be 00 00 00 00       	mov    $0x0,%esi
  800aef:	b8 04 00 00 00       	mov    $0x4,%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800afd:	89 f7                	mov    %esi,%edi
  800aff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 04                	push   $0x4
  800b0b:	68 5f 21 80 00       	push   $0x80215f
  800b10:	6a 23                	push   $0x23
  800b12:	68 7c 21 80 00       	push   $0x80217c
  800b17:	e8 ba 0e 00 00       	call   8019d6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b3e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 17                	jle    800b5e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 05                	push   $0x5
  800b4d:	68 5f 21 80 00       	push   $0x80215f
  800b52:	6a 23                	push   $0x23
  800b54:	68 7c 21 80 00       	push   $0x80217c
  800b59:	e8 78 0e 00 00       	call   8019d6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b74:	b8 06 00 00 00       	mov    $0x6,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	89 df                	mov    %ebx,%edi
  800b81:	89 de                	mov    %ebx,%esi
  800b83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7e 17                	jle    800ba0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	50                   	push   %eax
  800b8d:	6a 06                	push   $0x6
  800b8f:	68 5f 21 80 00       	push   $0x80215f
  800b94:	6a 23                	push   $0x23
  800b96:	68 7c 21 80 00       	push   $0x80217c
  800b9b:	e8 36 0e 00 00       	call   8019d6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 17                	jle    800be2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 08                	push   $0x8
  800bd1:	68 5f 21 80 00       	push   $0x80215f
  800bd6:	6a 23                	push   $0x23
  800bd8:	68 7c 21 80 00       	push   $0x80217c
  800bdd:	e8 f4 0d 00 00       	call   8019d6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 09                	push   $0x9
  800c13:	68 5f 21 80 00       	push   $0x80215f
  800c18:	6a 23                	push   $0x23
  800c1a:	68 7c 21 80 00       	push   $0x80217c
  800c1f:	e8 b2 0d 00 00       	call   8019d6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 17                	jle    800c66 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 0a                	push   $0xa
  800c55:	68 5f 21 80 00       	push   $0x80215f
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 7c 21 80 00       	push   $0x80217c
  800c61:	e8 70 0d 00 00       	call   8019d6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	be 00 00 00 00       	mov    $0x0,%esi
  800c79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 17                	jle    800cca <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 0d                	push   $0xd
  800cb9:	68 5f 21 80 00       	push   $0x80215f
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 7c 21 80 00       	push   $0x80217c
  800cc5:	e8 0c 0d 00 00       	call   8019d6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_gettime>:

int sys_gettime(void)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce2:	89 d1                	mov    %edx,%ecx
  800ce4:	89 d3                	mov    %edx,%ebx
  800ce6:	89 d7                	mov    %edx,%edi
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	05 00 00 00 30       	add    $0x30000000,%eax
  800cfc:	c1 e8 0c             	shr    $0xc,%eax
}
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d11:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d23:	89 c2                	mov    %eax,%edx
  800d25:	c1 ea 16             	shr    $0x16,%edx
  800d28:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d2f:	f6 c2 01             	test   $0x1,%dl
  800d32:	74 11                	je     800d45 <fd_alloc+0x2d>
  800d34:	89 c2                	mov    %eax,%edx
  800d36:	c1 ea 0c             	shr    $0xc,%edx
  800d39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d40:	f6 c2 01             	test   $0x1,%dl
  800d43:	75 09                	jne    800d4e <fd_alloc+0x36>
			*fd_store = fd;
  800d45:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4c:	eb 17                	jmp    800d65 <fd_alloc+0x4d>
  800d4e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d53:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d58:	75 c9                	jne    800d23 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d5a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d60:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d6d:	83 f8 1f             	cmp    $0x1f,%eax
  800d70:	77 36                	ja     800da8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d72:	c1 e0 0c             	shl    $0xc,%eax
  800d75:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	c1 ea 16             	shr    $0x16,%edx
  800d7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d86:	f6 c2 01             	test   $0x1,%dl
  800d89:	74 24                	je     800daf <fd_lookup+0x48>
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	c1 ea 0c             	shr    $0xc,%edx
  800d90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d97:	f6 c2 01             	test   $0x1,%dl
  800d9a:	74 1a                	je     800db6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9f:	89 02                	mov    %eax,(%edx)
	return 0;
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	eb 13                	jmp    800dbb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dad:	eb 0c                	jmp    800dbb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800db4:	eb 05                	jmp    800dbb <fd_lookup+0x54>
  800db6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc6:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dcb:	eb 13                	jmp    800de0 <dev_lookup+0x23>
  800dcd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dd0:	39 08                	cmp    %ecx,(%eax)
  800dd2:	75 0c                	jne    800de0 <dev_lookup+0x23>
			*dev = devtab[i];
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	eb 2e                	jmp    800e0e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800de0:	8b 02                	mov    (%edx),%eax
  800de2:	85 c0                	test   %eax,%eax
  800de4:	75 e7                	jne    800dcd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800de6:	a1 08 40 80 00       	mov    0x804008,%eax
  800deb:	8b 40 48             	mov    0x48(%eax),%eax
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	51                   	push   %ecx
  800df2:	50                   	push   %eax
  800df3:	68 8c 21 80 00       	push   $0x80218c
  800df8:	e8 56 f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 10             	sub    $0x10,%esp
  800e18:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e21:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e22:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e28:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e2b:	50                   	push   %eax
  800e2c:	e8 36 ff ff ff       	call   800d67 <fd_lookup>
  800e31:	83 c4 08             	add    $0x8,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	78 05                	js     800e3d <fd_close+0x2d>
	    || fd != fd2)
  800e38:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e3b:	74 0b                	je     800e48 <fd_close+0x38>
		return (must_exist ? r : 0);
  800e3d:	80 fb 01             	cmp    $0x1,%bl
  800e40:	19 d2                	sbb    %edx,%edx
  800e42:	f7 d2                	not    %edx
  800e44:	21 d0                	and    %edx,%eax
  800e46:	eb 41                	jmp    800e89 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e4e:	50                   	push   %eax
  800e4f:	ff 36                	pushl  (%esi)
  800e51:	e8 67 ff ff ff       	call   800dbd <dev_lookup>
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 1a                	js     800e79 <fd_close+0x69>
		if (dev->dev_close)
  800e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e62:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e65:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	74 0b                	je     800e79 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	56                   	push   %esi
  800e72:	ff d0                	call   *%eax
  800e74:	89 c3                	mov    %eax,%ebx
  800e76:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	56                   	push   %esi
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 e2 fc ff ff       	call   800b66 <sys_page_unmap>
	return r;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	89 d8                	mov    %ebx,%eax
}
  800e89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e99:	50                   	push   %eax
  800e9a:	ff 75 08             	pushl  0x8(%ebp)
  800e9d:	e8 c5 fe ff ff       	call   800d67 <fd_lookup>
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	83 c4 08             	add    $0x8,%esp
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	78 10                	js     800ebb <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	6a 01                	push   $0x1
  800eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb3:	e8 58 ff ff ff       	call   800e10 <fd_close>
  800eb8:	83 c4 10             	add    $0x10,%esp
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <close_all>:

void
close_all(void)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	53                   	push   %ebx
  800ecd:	e8 be ff ff ff       	call   800e90 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed2:	83 c3 01             	add    $0x1,%ebx
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	83 fb 20             	cmp    $0x20,%ebx
  800edb:	75 ec                	jne    800ec9 <close_all+0xc>
		close(i);
}
  800edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 2c             	sub    $0x2c,%esp
  800eeb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800eee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ef1:	50                   	push   %eax
  800ef2:	ff 75 08             	pushl  0x8(%ebp)
  800ef5:	e8 6d fe ff ff       	call   800d67 <fd_lookup>
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	83 c4 08             	add    $0x8,%esp
  800eff:	85 d2                	test   %edx,%edx
  800f01:	0f 88 c1 00 00 00    	js     800fc8 <dup+0xe6>
		return r;
	close(newfdnum);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	56                   	push   %esi
  800f0b:	e8 80 ff ff ff       	call   800e90 <close>

	newfd = INDEX2FD(newfdnum);
  800f10:	89 f3                	mov    %esi,%ebx
  800f12:	c1 e3 0c             	shl    $0xc,%ebx
  800f15:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f1b:	83 c4 04             	add    $0x4,%esp
  800f1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f21:	e8 db fd ff ff       	call   800d01 <fd2data>
  800f26:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f28:	89 1c 24             	mov    %ebx,(%esp)
  800f2b:	e8 d1 fd ff ff       	call   800d01 <fd2data>
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f36:	89 f8                	mov    %edi,%eax
  800f38:	c1 e8 16             	shr    $0x16,%eax
  800f3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f42:	a8 01                	test   $0x1,%al
  800f44:	74 37                	je     800f7d <dup+0x9b>
  800f46:	89 f8                	mov    %edi,%eax
  800f48:	c1 e8 0c             	shr    $0xc,%eax
  800f4b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f52:	f6 c2 01             	test   $0x1,%dl
  800f55:	74 26                	je     800f7d <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	25 07 0e 00 00       	and    $0xe07,%eax
  800f66:	50                   	push   %eax
  800f67:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f6a:	6a 00                	push   $0x0
  800f6c:	57                   	push   %edi
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 b0 fb ff ff       	call   800b24 <sys_page_map>
  800f74:	89 c7                	mov    %eax,%edi
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 2e                	js     800fab <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f80:	89 d0                	mov    %edx,%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
  800f85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f94:	50                   	push   %eax
  800f95:	53                   	push   %ebx
  800f96:	6a 00                	push   $0x0
  800f98:	52                   	push   %edx
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 84 fb ff ff       	call   800b24 <sys_page_map>
  800fa0:	89 c7                	mov    %eax,%edi
  800fa2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fa5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fa7:	85 ff                	test   %edi,%edi
  800fa9:	79 1d                	jns    800fc8 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	53                   	push   %ebx
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 b0 fb ff ff       	call   800b66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 a3 fb ff ff       	call   800b66 <sys_page_unmap>
	return r;
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	89 f8                	mov    %edi,%eax
}
  800fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 14             	sub    $0x14,%esp
  800fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	53                   	push   %ebx
  800fdf:	e8 83 fd ff ff       	call   800d67 <fd_lookup>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	89 c2                	mov    %eax,%edx
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 6d                	js     80105a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff7:	ff 30                	pushl  (%eax)
  800ff9:	e8 bf fd ff ff       	call   800dbd <dev_lookup>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 4c                	js     801051 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801005:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801008:	8b 42 08             	mov    0x8(%edx),%eax
  80100b:	83 e0 03             	and    $0x3,%eax
  80100e:	83 f8 01             	cmp    $0x1,%eax
  801011:	75 21                	jne    801034 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801013:	a1 08 40 80 00       	mov    0x804008,%eax
  801018:	8b 40 48             	mov    0x48(%eax),%eax
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	53                   	push   %ebx
  80101f:	50                   	push   %eax
  801020:	68 cd 21 80 00       	push   $0x8021cd
  801025:	e8 29 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801032:	eb 26                	jmp    80105a <read+0x8a>
	}
	if (!dev->dev_read)
  801034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801037:	8b 40 08             	mov    0x8(%eax),%eax
  80103a:	85 c0                	test   %eax,%eax
  80103c:	74 17                	je     801055 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80103e:	83 ec 04             	sub    $0x4,%esp
  801041:	ff 75 10             	pushl  0x10(%ebp)
  801044:	ff 75 0c             	pushl  0xc(%ebp)
  801047:	52                   	push   %edx
  801048:	ff d0                	call   *%eax
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	eb 09                	jmp    80105a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801051:	89 c2                	mov    %eax,%edx
  801053:	eb 05                	jmp    80105a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801055:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801070:	bb 00 00 00 00       	mov    $0x0,%ebx
  801075:	eb 21                	jmp    801098 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	89 f0                	mov    %esi,%eax
  80107c:	29 d8                	sub    %ebx,%eax
  80107e:	50                   	push   %eax
  80107f:	89 d8                	mov    %ebx,%eax
  801081:	03 45 0c             	add    0xc(%ebp),%eax
  801084:	50                   	push   %eax
  801085:	57                   	push   %edi
  801086:	e8 45 ff ff ff       	call   800fd0 <read>
		if (m < 0)
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 0c                	js     80109e <readn+0x3d>
			return m;
		if (m == 0)
  801092:	85 c0                	test   %eax,%eax
  801094:	74 06                	je     80109c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801096:	01 c3                	add    %eax,%ebx
  801098:	39 f3                	cmp    %esi,%ebx
  80109a:	72 db                	jb     801077 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80109c:	89 d8                	mov    %ebx,%eax
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 14             	sub    $0x14,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	e8 ad fc ff ff       	call   800d67 <fd_lookup>
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 68                	js     80112b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cd:	ff 30                	pushl  (%eax)
  8010cf:	e8 e9 fc ff ff       	call   800dbd <dev_lookup>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 47                	js     801122 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010e2:	75 21                	jne    801105 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e9:	8b 40 48             	mov    0x48(%eax),%eax
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	53                   	push   %ebx
  8010f0:	50                   	push   %eax
  8010f1:	68 e9 21 80 00       	push   $0x8021e9
  8010f6:	e8 58 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801103:	eb 26                	jmp    80112b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801105:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801108:	8b 52 0c             	mov    0xc(%edx),%edx
  80110b:	85 d2                	test   %edx,%edx
  80110d:	74 17                	je     801126 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80110f:	83 ec 04             	sub    $0x4,%esp
  801112:	ff 75 10             	pushl  0x10(%ebp)
  801115:	ff 75 0c             	pushl  0xc(%ebp)
  801118:	50                   	push   %eax
  801119:	ff d2                	call   *%edx
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	eb 09                	jmp    80112b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801122:	89 c2                	mov    %eax,%edx
  801124:	eb 05                	jmp    80112b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801126:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <seek>:

int
seek(int fdnum, off_t offset)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801138:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	e8 23 fc ff ff       	call   800d67 <fd_lookup>
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 0e                	js     801159 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80114b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80114e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801151:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	53                   	push   %ebx
  80115f:	83 ec 14             	sub    $0x14,%esp
  801162:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801165:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	53                   	push   %ebx
  80116a:	e8 f8 fb ff ff       	call   800d67 <fd_lookup>
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	89 c2                	mov    %eax,%edx
  801174:	85 c0                	test   %eax,%eax
  801176:	78 65                	js     8011dd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801182:	ff 30                	pushl  (%eax)
  801184:	e8 34 fc ff ff       	call   800dbd <dev_lookup>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 44                	js     8011d4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801190:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801193:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801197:	75 21                	jne    8011ba <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801199:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80119e:	8b 40 48             	mov    0x48(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	53                   	push   %ebx
  8011a5:	50                   	push   %eax
  8011a6:	68 ac 21 80 00       	push   $0x8021ac
  8011ab:	e8 a3 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b8:	eb 23                	jmp    8011dd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011bd:	8b 52 18             	mov    0x18(%edx),%edx
  8011c0:	85 d2                	test   %edx,%edx
  8011c2:	74 14                	je     8011d8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ca:	50                   	push   %eax
  8011cb:	ff d2                	call   *%edx
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	eb 09                	jmp    8011dd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	eb 05                	jmp    8011dd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011dd:	89 d0                	mov    %edx,%eax
  8011df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 14             	sub    $0x14,%esp
  8011eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 6d fb ff ff       	call   800d67 <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 58                	js     80125b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	ff 30                	pushl  (%eax)
  80120f:	e8 a9 fb ff ff       	call   800dbd <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 37                	js     801252 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80121b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801222:	74 32                	je     801256 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801224:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801227:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80122e:	00 00 00 
	stat->st_isdir = 0;
  801231:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801238:	00 00 00 
	stat->st_dev = dev;
  80123b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	53                   	push   %ebx
  801245:	ff 75 f0             	pushl  -0x10(%ebp)
  801248:	ff 50 14             	call   *0x14(%eax)
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	eb 09                	jmp    80125b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	89 c2                	mov    %eax,%edx
  801254:	eb 05                	jmp    80125b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801256:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80125b:	89 d0                	mov    %edx,%eax
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	6a 00                	push   $0x0
  80126c:	ff 75 08             	pushl  0x8(%ebp)
  80126f:	e8 e7 01 00 00       	call   80145b <open>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 db                	test   %ebx,%ebx
  80127b:	78 1b                	js     801298 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	ff 75 0c             	pushl  0xc(%ebp)
  801283:	53                   	push   %ebx
  801284:	e8 5b ff ff ff       	call   8011e4 <fstat>
  801289:	89 c6                	mov    %eax,%esi
	close(fd);
  80128b:	89 1c 24             	mov    %ebx,(%esp)
  80128e:	e8 fd fb ff ff       	call   800e90 <close>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 f0                	mov    %esi,%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	89 c6                	mov    %eax,%esi
  8012a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012a8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012af:	75 12                	jne    8012c3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012b1:	83 ec 0c             	sub    $0xc,%esp
  8012b4:	6a 03                	push   $0x3
  8012b6:	e8 18 08 00 00       	call   801ad3 <ipc_find_env>
  8012bb:	a3 00 40 80 00       	mov    %eax,0x804000
  8012c0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012c3:	6a 07                	push   $0x7
  8012c5:	68 00 50 80 00       	push   $0x805000
  8012ca:	56                   	push   %esi
  8012cb:	ff 35 00 40 80 00    	pushl  0x804000
  8012d1:	e8 ac 07 00 00       	call   801a82 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012d6:	83 c4 0c             	add    $0xc,%esp
  8012d9:	6a 00                	push   $0x0
  8012db:	53                   	push   %ebx
  8012dc:	6a 00                	push   $0x0
  8012de:	e8 39 07 00 00       	call   801a1c <ipc_recv>
}
  8012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801303:	ba 00 00 00 00       	mov    $0x0,%edx
  801308:	b8 02 00 00 00       	mov    $0x2,%eax
  80130d:	e8 8d ff ff ff       	call   80129f <fsipc>
}
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
  80131d:	8b 40 0c             	mov    0xc(%eax),%eax
  801320:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801325:	ba 00 00 00 00       	mov    $0x0,%edx
  80132a:	b8 06 00 00 00       	mov    $0x6,%eax
  80132f:	e8 6b ff ff ff       	call   80129f <fsipc>
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	53                   	push   %ebx
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	8b 40 0c             	mov    0xc(%eax),%eax
  801346:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80134b:	ba 00 00 00 00       	mov    $0x0,%edx
  801350:	b8 05 00 00 00       	mov    $0x5,%eax
  801355:	e8 45 ff ff ff       	call   80129f <fsipc>
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	85 d2                	test   %edx,%edx
  80135e:	78 2c                	js     80138c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	68 00 50 80 00       	push   $0x805000
  801368:	53                   	push   %ebx
  801369:	e8 69 f3 ff ff       	call   8006d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80136e:	a1 80 50 80 00       	mov    0x805080,%eax
  801373:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801379:	a1 84 50 80 00       	mov    0x805084,%eax
  80137e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  80139a:	8b 55 08             	mov    0x8(%ebp),%edx
  80139d:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a0:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8013a6:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8013ab:	76 05                	jbe    8013b2 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8013ad:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8013b2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	50                   	push   %eax
  8013bb:	ff 75 0c             	pushl  0xc(%ebp)
  8013be:	68 08 50 80 00       	push   $0x805008
  8013c3:	e8 a1 f4 ff ff       	call   800869 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8013c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d2:	e8 c8 fe ff ff       	call   80129f <fsipc>
	return write;
}
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ec:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fc:	e8 9e fe ff ff       	call   80129f <fsipc>
  801401:	89 c3                	mov    %eax,%ebx
  801403:	85 c0                	test   %eax,%eax
  801405:	78 4b                	js     801452 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801407:	39 c6                	cmp    %eax,%esi
  801409:	73 16                	jae    801421 <devfile_read+0x48>
  80140b:	68 18 22 80 00       	push   $0x802218
  801410:	68 1f 22 80 00       	push   $0x80221f
  801415:	6a 7c                	push   $0x7c
  801417:	68 34 22 80 00       	push   $0x802234
  80141c:	e8 b5 05 00 00       	call   8019d6 <_panic>
	assert(r <= PGSIZE);
  801421:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801426:	7e 16                	jle    80143e <devfile_read+0x65>
  801428:	68 3f 22 80 00       	push   $0x80223f
  80142d:	68 1f 22 80 00       	push   $0x80221f
  801432:	6a 7d                	push   $0x7d
  801434:	68 34 22 80 00       	push   $0x802234
  801439:	e8 98 05 00 00       	call   8019d6 <_panic>
	memmove(buf, &fsipcbuf, r);
  80143e:	83 ec 04             	sub    $0x4,%esp
  801441:	50                   	push   %eax
  801442:	68 00 50 80 00       	push   $0x805000
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	e8 1a f4 ff ff       	call   800869 <memmove>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
}
  801452:	89 d8                	mov    %ebx,%eax
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	83 ec 20             	sub    $0x20,%esp
  801462:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801465:	53                   	push   %ebx
  801466:	e8 33 f2 ff ff       	call   80069e <strlen>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801473:	7f 67                	jg     8014dc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	e8 97 f8 ff ff       	call   800d18 <fd_alloc>
  801481:	83 c4 10             	add    $0x10,%esp
		return r;
  801484:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801486:	85 c0                	test   %eax,%eax
  801488:	78 57                	js     8014e1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	53                   	push   %ebx
  80148e:	68 00 50 80 00       	push   $0x805000
  801493:	e8 3f f2 ff ff       	call   8006d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a8:	e8 f2 fd ff ff       	call   80129f <fsipc>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	79 14                	jns    8014ca <open+0x6f>
		fd_close(fd, 0);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	6a 00                	push   $0x0
  8014bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014be:	e8 4d f9 ff ff       	call   800e10 <fd_close>
		return r;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	89 da                	mov    %ebx,%edx
  8014c8:	eb 17                	jmp    8014e1 <open+0x86>
	}

	return fd2num(fd);
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d0:	e8 1c f8 ff ff       	call   800cf1 <fd2num>
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	eb 05                	jmp    8014e1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014dc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8014f8:	e8 a2 fd ff ff       	call   80129f <fsipc>
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	ff 75 08             	pushl  0x8(%ebp)
  80150d:	e8 ef f7 ff ff       	call   800d01 <fd2data>
  801512:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	68 4b 22 80 00       	push   $0x80224b
  80151c:	53                   	push   %ebx
  80151d:	e8 b5 f1 ff ff       	call   8006d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801522:	8b 56 04             	mov    0x4(%esi),%edx
  801525:	89 d0                	mov    %edx,%eax
  801527:	2b 06                	sub    (%esi),%eax
  801529:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80152f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801536:	00 00 00 
	stat->st_dev = &devpipe;
  801539:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801540:	30 80 00 
	return 0;
}
  801543:	b8 00 00 00 00       	mov    $0x0,%eax
  801548:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801559:	53                   	push   %ebx
  80155a:	6a 00                	push   $0x0
  80155c:	e8 05 f6 ff ff       	call   800b66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801561:	89 1c 24             	mov    %ebx,(%esp)
  801564:	e8 98 f7 ff ff       	call   800d01 <fd2data>
  801569:	83 c4 08             	add    $0x8,%esp
  80156c:	50                   	push   %eax
  80156d:	6a 00                	push   $0x0
  80156f:	e8 f2 f5 ff ff       	call   800b66 <sys_page_unmap>
}
  801574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	57                   	push   %edi
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	83 ec 1c             	sub    $0x1c,%esp
  801582:	89 c7                	mov    %eax,%edi
  801584:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801586:	a1 08 40 80 00       	mov    0x804008,%eax
  80158b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	57                   	push   %edi
  801592:	e8 74 05 00 00       	call   801b0b <pageref>
  801597:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80159a:	89 34 24             	mov    %esi,(%esp)
  80159d:	e8 69 05 00 00       	call   801b0b <pageref>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015a8:	0f 94 c0             	sete   %al
  8015ab:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8015ae:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015b7:	39 cb                	cmp    %ecx,%ebx
  8015b9:	74 15                	je     8015d0 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8015bb:	8b 52 58             	mov    0x58(%edx),%edx
  8015be:	50                   	push   %eax
  8015bf:	52                   	push   %edx
  8015c0:	53                   	push   %ebx
  8015c1:	68 58 22 80 00       	push   $0x802258
  8015c6:	e8 88 eb ff ff       	call   800153 <cprintf>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	eb b6                	jmp    801586 <_pipeisclosed+0xd>
	}
}
  8015d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d3:	5b                   	pop    %ebx
  8015d4:	5e                   	pop    %esi
  8015d5:	5f                   	pop    %edi
  8015d6:	5d                   	pop    %ebp
  8015d7:	c3                   	ret    

008015d8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	57                   	push   %edi
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 28             	sub    $0x28,%esp
  8015e1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015e4:	56                   	push   %esi
  8015e5:	e8 17 f7 ff ff       	call   800d01 <fd2data>
  8015ea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f4:	eb 4b                	jmp    801641 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f6:	89 da                	mov    %ebx,%edx
  8015f8:	89 f0                	mov    %esi,%eax
  8015fa:	e8 7a ff ff ff       	call   801579 <_pipeisclosed>
  8015ff:	85 c0                	test   %eax,%eax
  801601:	75 48                	jne    80164b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801603:	e8 ba f4 ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801608:	8b 43 04             	mov    0x4(%ebx),%eax
  80160b:	8b 0b                	mov    (%ebx),%ecx
  80160d:	8d 51 20             	lea    0x20(%ecx),%edx
  801610:	39 d0                	cmp    %edx,%eax
  801612:	73 e2                	jae    8015f6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801614:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801617:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80161b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80161e:	89 c2                	mov    %eax,%edx
  801620:	c1 fa 1f             	sar    $0x1f,%edx
  801623:	89 d1                	mov    %edx,%ecx
  801625:	c1 e9 1b             	shr    $0x1b,%ecx
  801628:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80162b:	83 e2 1f             	and    $0x1f,%edx
  80162e:	29 ca                	sub    %ecx,%edx
  801630:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801634:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801638:	83 c0 01             	add    $0x1,%eax
  80163b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163e:	83 c7 01             	add    $0x1,%edi
  801641:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801644:	75 c2                	jne    801608 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801646:	8b 45 10             	mov    0x10(%ebp),%eax
  801649:	eb 05                	jmp    801650 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5f                   	pop    %edi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 18             	sub    $0x18,%esp
  801661:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801664:	57                   	push   %edi
  801665:	e8 97 f6 ff ff       	call   800d01 <fd2data>
  80166a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801674:	eb 3d                	jmp    8016b3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801676:	85 db                	test   %ebx,%ebx
  801678:	74 04                	je     80167e <devpipe_read+0x26>
				return i;
  80167a:	89 d8                	mov    %ebx,%eax
  80167c:	eb 44                	jmp    8016c2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80167e:	89 f2                	mov    %esi,%edx
  801680:	89 f8                	mov    %edi,%eax
  801682:	e8 f2 fe ff ff       	call   801579 <_pipeisclosed>
  801687:	85 c0                	test   %eax,%eax
  801689:	75 32                	jne    8016bd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80168b:	e8 32 f4 ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801690:	8b 06                	mov    (%esi),%eax
  801692:	3b 46 04             	cmp    0x4(%esi),%eax
  801695:	74 df                	je     801676 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801697:	99                   	cltd   
  801698:	c1 ea 1b             	shr    $0x1b,%edx
  80169b:	01 d0                	add    %edx,%eax
  80169d:	83 e0 1f             	and    $0x1f,%eax
  8016a0:	29 d0                	sub    %edx,%eax
  8016a2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016aa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b0:	83 c3 01             	add    $0x1,%ebx
  8016b3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016b6:	75 d8                	jne    801690 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bb:	eb 05                	jmp    8016c2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	e8 3d f6 ff ff       	call   800d18 <fd_alloc>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	0f 88 2c 01 00 00    	js     801814 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e8:	83 ec 04             	sub    $0x4,%esp
  8016eb:	68 07 04 00 00       	push   $0x407
  8016f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 e7 f3 ff ff       	call   800ae1 <sys_page_alloc>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 88 0d 01 00 00    	js     801814 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801707:	83 ec 0c             	sub    $0xc,%esp
  80170a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	e8 05 f6 ff ff       	call   800d18 <fd_alloc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 e2 00 00 00    	js     801802 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801720:	83 ec 04             	sub    $0x4,%esp
  801723:	68 07 04 00 00       	push   $0x407
  801728:	ff 75 f0             	pushl  -0x10(%ebp)
  80172b:	6a 00                	push   $0x0
  80172d:	e8 af f3 ff ff       	call   800ae1 <sys_page_alloc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	0f 88 c3 00 00 00    	js     801802 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	ff 75 f4             	pushl  -0xc(%ebp)
  801745:	e8 b7 f5 ff ff       	call   800d01 <fd2data>
  80174a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174c:	83 c4 0c             	add    $0xc,%esp
  80174f:	68 07 04 00 00       	push   $0x407
  801754:	50                   	push   %eax
  801755:	6a 00                	push   $0x0
  801757:	e8 85 f3 ff ff       	call   800ae1 <sys_page_alloc>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	0f 88 89 00 00 00    	js     8017f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	ff 75 f0             	pushl  -0x10(%ebp)
  80176f:	e8 8d f5 ff ff       	call   800d01 <fd2data>
  801774:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177b:	50                   	push   %eax
  80177c:	6a 00                	push   $0x0
  80177e:	56                   	push   %esi
  80177f:	6a 00                	push   $0x0
  801781:	e8 9e f3 ff ff       	call   800b24 <sys_page_map>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 20             	add    $0x20,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 55                	js     8017e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80178f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017a4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bf:	e8 2d f5 ff ff       	call   800cf1 <fd2num>
  8017c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c9:	83 c4 04             	add    $0x4,%esp
  8017cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cf:	e8 1d f5 ff ff       	call   800cf1 <fd2num>
  8017d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e2:	eb 30                	jmp    801814 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	56                   	push   %esi
  8017e8:	6a 00                	push   $0x0
  8017ea:	e8 77 f3 ff ff       	call   800b66 <sys_page_unmap>
  8017ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f8:	6a 00                	push   $0x0
  8017fa:	e8 67 f3 ff ff       	call   800b66 <sys_page_unmap>
  8017ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	6a 00                	push   $0x0
  80180a:	e8 57 f3 ff ff       	call   800b66 <sys_page_unmap>
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801814:	89 d0                	mov    %edx,%eax
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	e8 38 f5 ff ff       	call   800d67 <fd_lookup>
  80182f:	89 c2                	mov    %eax,%edx
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 d2                	test   %edx,%edx
  801836:	78 18                	js     801850 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	ff 75 f4             	pushl  -0xc(%ebp)
  80183e:	e8 be f4 ff ff       	call   800d01 <fd2data>
	return _pipeisclosed(fd, p);
  801843:	89 c2                	mov    %eax,%edx
  801845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801848:	e8 2c fd ff ff       	call   801579 <_pipeisclosed>
  80184d:	83 c4 10             	add    $0x10,%esp
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801862:	68 89 22 80 00       	push   $0x802289
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	e8 68 ee ff ff       	call   8006d7 <strcpy>
	return 0;
}
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801882:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801887:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188d:	eb 2e                	jmp    8018bd <devcons_write+0x47>
		m = n - tot;
  80188f:	8b 55 10             	mov    0x10(%ebp),%edx
  801892:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801894:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801899:	83 fa 7f             	cmp    $0x7f,%edx
  80189c:	77 02                	ja     8018a0 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80189e:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a0:	83 ec 04             	sub    $0x4,%esp
  8018a3:	56                   	push   %esi
  8018a4:	03 45 0c             	add    0xc(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	57                   	push   %edi
  8018a9:	e8 bb ef ff ff       	call   800869 <memmove>
		sys_cputs(buf, m);
  8018ae:	83 c4 08             	add    $0x8,%esp
  8018b1:	56                   	push   %esi
  8018b2:	57                   	push   %edi
  8018b3:	e8 6d f1 ff ff       	call   800a25 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b8:	01 f3                	add    %esi,%ebx
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018c2:	72 cb                	jb     80188f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5f                   	pop    %edi
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018db:	75 07                	jne    8018e4 <devcons_read+0x18>
  8018dd:	eb 28                	jmp    801907 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018df:	e8 de f1 ff ff       	call   800ac2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018e4:	e8 5a f1 ff ff       	call   800a43 <sys_cgetc>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	74 f2                	je     8018df <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 16                	js     801907 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018f1:	83 f8 04             	cmp    $0x4,%eax
  8018f4:	74 0c                	je     801902 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f9:	88 02                	mov    %al,(%edx)
	return 1;
  8018fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801900:	eb 05                	jmp    801907 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801915:	6a 01                	push   $0x1
  801917:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	e8 05 f1 ff ff       	call   800a25 <sys_cputs>
  801920:	83 c4 10             	add    $0x10,%esp
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <getchar>:

int
getchar(void)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80192b:	6a 01                	push   $0x1
  80192d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	6a 00                	push   $0x0
  801933:	e8 98 f6 ff ff       	call   800fd0 <read>
	if (r < 0)
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 0f                	js     80194e <getchar+0x29>
		return r;
	if (r < 1)
  80193f:	85 c0                	test   %eax,%eax
  801941:	7e 06                	jle    801949 <getchar+0x24>
		return -E_EOF;
	return c;
  801943:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801947:	eb 05                	jmp    80194e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801949:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801956:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	ff 75 08             	pushl  0x8(%ebp)
  80195d:	e8 05 f4 ff ff       	call   800d67 <fd_lookup>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	78 11                	js     80197a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801972:	39 10                	cmp    %edx,(%eax)
  801974:	0f 94 c0             	sete   %al
  801977:	0f b6 c0             	movzbl %al,%eax
}
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <opencons>:

int
opencons(void)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801985:	50                   	push   %eax
  801986:	e8 8d f3 ff ff       	call   800d18 <fd_alloc>
  80198b:	83 c4 10             	add    $0x10,%esp
		return r;
  80198e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801990:	85 c0                	test   %eax,%eax
  801992:	78 3e                	js     8019d2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	68 07 04 00 00       	push   $0x407
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 3b f1 ff ff       	call   800ae1 <sys_page_alloc>
  8019a6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 23                	js     8019d2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019af:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	50                   	push   %eax
  8019c8:	e8 24 f3 ff ff       	call   800cf1 <fd2num>
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	83 c4 10             	add    $0x10,%esp
}
  8019d2:	89 d0                	mov    %edx,%eax
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	56                   	push   %esi
  8019da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019de:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019e4:	e8 ba f0 ff ff       	call   800aa3 <sys_getenvid>
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	ff 75 0c             	pushl  0xc(%ebp)
  8019ef:	ff 75 08             	pushl  0x8(%ebp)
  8019f2:	56                   	push   %esi
  8019f3:	50                   	push   %eax
  8019f4:	68 98 22 80 00       	push   $0x802298
  8019f9:	e8 55 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019fe:	83 c4 18             	add    $0x18,%esp
  801a01:	53                   	push   %ebx
  801a02:	ff 75 10             	pushl  0x10(%ebp)
  801a05:	e8 f8 e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a0a:	c7 04 24 0c 1e 80 00 	movl   $0x801e0c,(%esp)
  801a11:	e8 3d e7 ff ff       	call   800153 <cprintf>
  801a16:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a19:	cc                   	int3   
  801a1a:	eb fd                	jmp    801a19 <_panic+0x43>

00801a1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 75 08             	mov    0x8(%ebp),%esi
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a2a:	85 f6                	test   %esi,%esi
  801a2c:	74 06                	je     801a34 <ipc_recv+0x18>
  801a2e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a34:	85 db                	test   %ebx,%ebx
  801a36:	74 06                	je     801a3e <ipc_recv+0x22>
  801a38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a3e:	83 f8 01             	cmp    $0x1,%eax
  801a41:	19 d2                	sbb    %edx,%edx
  801a43:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	50                   	push   %eax
  801a49:	e8 43 f2 ff ff       	call   800c91 <sys_ipc_recv>
  801a4e:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 d2                	test   %edx,%edx
  801a55:	75 24                	jne    801a7b <ipc_recv+0x5f>
	if (from_env_store)
  801a57:	85 f6                	test   %esi,%esi
  801a59:	74 0a                	je     801a65 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a5b:	a1 08 40 80 00       	mov    0x804008,%eax
  801a60:	8b 40 70             	mov    0x70(%eax),%eax
  801a63:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a65:	85 db                	test   %ebx,%ebx
  801a67:	74 0a                	je     801a73 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a69:	a1 08 40 80 00       	mov    0x804008,%eax
  801a6e:	8b 40 74             	mov    0x74(%eax),%eax
  801a71:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a73:	a1 08 40 80 00       	mov    0x804008,%eax
  801a78:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a94:	83 fb 01             	cmp    $0x1,%ebx
  801a97:	19 c0                	sbb    %eax,%eax
  801a99:	09 c3                	or     %eax,%ebx
  801a9b:	eb 1c                	jmp    801ab9 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a9d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa0:	74 12                	je     801ab4 <ipc_send+0x32>
  801aa2:	50                   	push   %eax
  801aa3:	68 bc 22 80 00       	push   $0x8022bc
  801aa8:	6a 36                	push   $0x36
  801aaa:	68 d3 22 80 00       	push   $0x8022d3
  801aaf:	e8 22 ff ff ff       	call   8019d6 <_panic>
		sys_yield();
  801ab4:	e8 09 f0 ff ff       	call   800ac2 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ab9:	ff 75 14             	pushl  0x14(%ebp)
  801abc:	53                   	push   %ebx
  801abd:	56                   	push   %esi
  801abe:	57                   	push   %edi
  801abf:	e8 aa f1 ff ff       	call   800c6e <sys_ipc_try_send>
		if (ret == 0) break;
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	75 d2                	jne    801a9d <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ade:	6b d0 78             	imul   $0x78,%eax,%edx
  801ae1:	83 c2 50             	add    $0x50,%edx
  801ae4:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801aea:	39 ca                	cmp    %ecx,%edx
  801aec:	75 0d                	jne    801afb <ipc_find_env+0x28>
			return envs[i].env_id;
  801aee:	6b c0 78             	imul   $0x78,%eax,%eax
  801af1:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801af6:	8b 40 08             	mov    0x8(%eax),%eax
  801af9:	eb 0e                	jmp    801b09 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afb:	83 c0 01             	add    $0x1,%eax
  801afe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b03:	75 d9                	jne    801ade <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b05:	66 b8 00 00          	mov    $0x0,%ax
}
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b11:	89 d0                	mov    %edx,%eax
  801b13:	c1 e8 16             	shr    $0x16,%eax
  801b16:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b22:	f6 c1 01             	test   $0x1,%cl
  801b25:	74 1d                	je     801b44 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b27:	c1 ea 0c             	shr    $0xc,%edx
  801b2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b31:	f6 c2 01             	test   $0x1,%dl
  801b34:	74 0e                	je     801b44 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b36:	c1 ea 0c             	shr    $0xc,%edx
  801b39:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b40:	ef 
  801b41:	0f b7 c0             	movzwl %ax,%eax
}
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    
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
