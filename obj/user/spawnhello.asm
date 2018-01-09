
obj/user/spawnhello:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 24 80 00       	push   $0x802400
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 24 80 00       	push   $0x80241e
  800056:	68 1e 24 80 00       	push   $0x80241e
  80005b:	e8 57 1a 00 00       	call   801ab7 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %i", r);
  800067:	50                   	push   %eax
  800068:	68 24 24 80 00       	push   $0x802424
  80006d:	6a 09                	push   $0x9
  80006f:	68 3c 24 80 00       	push   $0x80243c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800086:	e8 79 0a 00 00       	call   800b04 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 78             	imul   $0x78,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
  8000b7:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 52 0e 00 00       	call   800f1e <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 ed 09 00 00       	call   800ac3 <sys_env_destroy>
  8000d6:	83 c4 10             	add    $0x10,%esp
}
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 16 0a 00 00       	call   800b04 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 58 24 80 00       	push   $0x802458
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 27 28 80 00 	movl   $0x802827,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 35 09 00 00       	call   800a86 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 4f 01 00 00       	call   8002e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 da 08 00 00       	call   800a86 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 d1                	mov    %edx,%ecx
  8001dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f3:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001f6:	72 05                	jb     8001fd <printnum+0x35>
  8001f8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001fb:	77 3e                	ja     80023b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	53                   	push   %ebx
  800207:	50                   	push   %eax
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 14 1f 00 00       	call   802130 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 13                	jmp    800242 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	83 eb 01             	sub    $0x1,%ebx
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7f ed                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	56                   	push   %esi
  800246:	83 ec 04             	sub    $0x4,%esp
  800249:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024c:	ff 75 e0             	pushl  -0x20(%ebp)
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	e8 06 20 00 00       	call   802260 <__umoddi3>
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
  800264:	50                   	push   %eax
  800265:	ff d7                	call   *%edi
  800267:	83 c4 10             	add    $0x10,%esp
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800275:	83 fa 01             	cmp    $0x1,%edx
  800278:	7e 0e                	jle    800288 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	8b 52 04             	mov    0x4(%edx),%edx
  800286:	eb 22                	jmp    8002aa <getuint+0x38>
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 10                	je     80029c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	eb 0e                	jmp    8002aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bb:	73 0a                	jae    8002c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	88 02                	mov    %al,(%edx)
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 10             	pushl  0x10(%ebp)
  8002d6:	ff 75 0c             	pushl  0xc(%ebp)
  8002d9:	ff 75 08             	pushl  0x8(%ebp)
  8002dc:	e8 05 00 00 00       	call   8002e6 <vprintfmt>
	va_end(ap);
  8002e1:	83 c4 10             	add    $0x10,%esp
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 2c             	sub    $0x2c,%esp
  8002ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f8:	eb 12                	jmp    80030c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fa:	85 c0                	test   %eax,%eax
  8002fc:	0f 84 8d 03 00 00    	je     80068f <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	53                   	push   %ebx
  800306:	50                   	push   %eax
  800307:	ff d6                	call   *%esi
  800309:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030c:	83 c7 01             	add    $0x1,%edi
  80030f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	75 e2                	jne    8002fa <vprintfmt+0x14>
  800318:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800323:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
  800336:	eb 07                	jmp    80033f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8d 47 01             	lea    0x1(%edi),%eax
  800342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800345:	0f b6 07             	movzbl (%edi),%eax
  800348:	0f b6 c8             	movzbl %al,%ecx
  80034b:	83 e8 23             	sub    $0x23,%eax
  80034e:	3c 55                	cmp    $0x55,%al
  800350:	0f 87 1e 03 00 00    	ja     800674 <vprintfmt+0x38e>
  800356:	0f b6 c0             	movzbl %al,%eax
  800359:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800363:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800367:	eb d6                	jmp    80033f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036c:	b8 00 00 00 00       	mov    $0x0,%eax
  800371:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800374:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800377:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800381:	83 fa 09             	cmp    $0x9,%edx
  800384:	77 38                	ja     8003be <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800386:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800389:	eb e9                	jmp    800374 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 48 04             	lea    0x4(%eax),%ecx
  800391:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800394:	8b 00                	mov    (%eax),%eax
  800396:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039c:	eb 26                	jmp    8003c4 <vprintfmt+0xde>
  80039e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a1:	89 c8                	mov    %ecx,%eax
  8003a3:	c1 f8 1f             	sar    $0x1f,%eax
  8003a6:	f7 d0                	not    %eax
  8003a8:	21 c1                	and    %eax,%ecx
  8003aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b0:	eb 8d                	jmp    80033f <vprintfmt+0x59>
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bc:	eb 81                	jmp    80033f <vprintfmt+0x59>
  8003be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c8:	0f 89 71 ff ff ff    	jns    80033f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003db:	e9 5f ff ff ff       	jmp    80033f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e6:	e9 54 ff ff ff       	jmp    80033f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	83 ec 08             	sub    $0x8,%esp
  8003f7:	53                   	push   %ebx
  8003f8:	ff 30                	pushl  (%eax)
  8003fa:	ff d6                	call   *%esi
			break;
  8003fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800402:	e9 05 ff ff ff       	jmp    80030c <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	99                   	cltd   
  800413:	31 d0                	xor    %edx,%eax
  800415:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800417:	83 f8 0f             	cmp    $0xf,%eax
  80041a:	7f 0b                	jg     800427 <vprintfmt+0x141>
  80041c:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800423:	85 d2                	test   %edx,%edx
  800425:	75 18                	jne    80043f <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800427:	50                   	push   %eax
  800428:	68 93 24 80 00       	push   $0x802493
  80042d:	53                   	push   %ebx
  80042e:	56                   	push   %esi
  80042f:	e8 95 fe ff ff       	call   8002c9 <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043a:	e9 cd fe ff ff       	jmp    80030c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043f:	52                   	push   %edx
  800440:	68 71 28 80 00       	push   $0x802871
  800445:	53                   	push   %ebx
  800446:	56                   	push   %esi
  800447:	e8 7d fe ff ff       	call   8002c9 <printfmt>
  80044c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800452:	e9 b5 fe ff ff       	jmp    80030c <vprintfmt+0x26>
  800457:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80045a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
  80046b:	85 ff                	test   %edi,%edi
  80046d:	75 05                	jne    800474 <vprintfmt+0x18e>
				p = "(null)";
  80046f:	bf 8c 24 80 00       	mov    $0x80248c,%edi
			if (width > 0 && padc != '-')
  800474:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800478:	0f 84 91 00 00 00    	je     80050f <vprintfmt+0x229>
  80047e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800482:	0f 8e 95 00 00 00    	jle    80051d <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	51                   	push   %ecx
  80048c:	57                   	push   %edi
  80048d:	e8 85 02 00 00       	call   800717 <strnlen>
  800492:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c5>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	89 c8                	mov    %ecx,%eax
  8004c6:	c1 f8 1f             	sar    $0x1f,%eax
  8004c9:	f7 d0                	not    %eax
  8004cb:	21 c8                	and    %ecx,%eax
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	89 cb                	mov    %ecx,%ebx
  8004da:	eb 4d                	jmp    800529 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e0:	74 1b                	je     8004fd <vprintfmt+0x217>
  8004e2:	0f be c0             	movsbl %al,%eax
  8004e5:	83 e8 20             	sub    $0x20,%eax
  8004e8:	83 f8 5e             	cmp    $0x5e,%eax
  8004eb:	76 10                	jbe    8004fd <vprintfmt+0x217>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	52                   	push   %edx
  800504:	ff 55 08             	call   *0x8(%ebp)
  800507:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	eb 1a                	jmp    800529 <vprintfmt+0x243>
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051b:	eb 0c                	jmp    800529 <vprintfmt+0x243>
  80051d:	89 75 08             	mov    %esi,0x8(%ebp)
  800520:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800523:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800526:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	0f be d0             	movsbl %al,%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 23                	je     80055a <vprintfmt+0x274>
  800537:	85 f6                	test   %esi,%esi
  800539:	78 a1                	js     8004dc <vprintfmt+0x1f6>
  80053b:	83 ee 01             	sub    $0x1,%esi
  80053e:	79 9c                	jns    8004dc <vprintfmt+0x1f6>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	eb 18                	jmp    800562 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 20                	push   $0x20
  800550:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	eb 08                	jmp    800562 <vprintfmt+0x27c>
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	85 ff                	test   %edi,%edi
  800564:	7f e4                	jg     80054a <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	e9 9e fd ff ff       	jmp    80030c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 fa 01             	cmp    $0x1,%edx
  800571:	7e 16                	jle    800589 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 08             	lea    0x8(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 50 04             	mov    0x4(%eax),%edx
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	eb 32                	jmp    8005bb <vprintfmt+0x2d5>
	else if (lflag)
  800589:	85 d2                	test   %edx,%edx
  80058b:	74 18                	je     8005a5 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 c1                	mov    %eax,%ecx
  80059d:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a3:	eb 16                	jmp    8005bb <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 c1                	mov    %eax,%ecx
  8005b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ca:	79 74                	jns    800640 <vprintfmt+0x35a>
				putch('-', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 2d                	push   $0x2d
  8005d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005da:	f7 d8                	neg    %eax
  8005dc:	83 d2 00             	adc    $0x0,%edx
  8005df:	f7 da                	neg    %edx
  8005e1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e9:	eb 55                	jmp    800640 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 7f fc ff ff       	call   800272 <getuint>
			base = 10;
  8005f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f8:	eb 46                	jmp    800640 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 70 fc ff ff       	call   800272 <getuint>
			base = 8;
  800602:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800607:	eb 37                	jmp    800640 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 30                	push   $0x30
  80060f:	ff d6                	call   *%esi
			putch('x', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 78                	push   $0x78
  800617:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800629:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 37 fc ff ff       	call   800272 <getuint>
			base = 16;
  80063b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800647:	57                   	push   %edi
  800648:	ff 75 e0             	pushl  -0x20(%ebp)
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	50                   	push   %eax
  80064e:	89 da                	mov    %ebx,%edx
  800650:	89 f0                	mov    %esi,%eax
  800652:	e8 71 fb ff ff       	call   8001c8 <printnum>
			break;
  800657:	83 c4 20             	add    $0x20,%esp
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065d:	e9 aa fc ff ff       	jmp    80030c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	51                   	push   %ecx
  800667:	ff d6                	call   *%esi
			break;
  800669:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066f:	e9 98 fc ff ff       	jmp    80030c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 25                	push   $0x25
  80067a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	eb 03                	jmp    800684 <vprintfmt+0x39e>
  800681:	83 ef 01             	sub    $0x1,%edi
  800684:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800688:	75 f7                	jne    800681 <vprintfmt+0x39b>
  80068a:	e9 7d fc ff ff       	jmp    80030c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800692:	5b                   	pop    %ebx
  800693:	5e                   	pop    %esi
  800694:	5f                   	pop    %edi
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 18             	sub    $0x18,%esp
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 26                	je     8006de <vsnprintf+0x47>
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	7e 22                	jle    8006de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bc:	ff 75 14             	pushl  0x14(%ebp)
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	68 ac 02 80 00       	push   $0x8002ac
  8006cb:	e8 16 fc ff ff       	call   8002e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 05                	jmp    8006e3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ee:	50                   	push   %eax
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	ff 75 08             	pushl  0x8(%ebp)
  8006f8:	e8 9a ff ff ff       	call   800697 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
  80070a:	eb 03                	jmp    80070f <strlen+0x10>
		n++;
  80070c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800713:	75 f7                	jne    80070c <strlen+0xd>
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	eb 03                	jmp    80072a <strnlen+0x13>
		n++;
  800727:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072a:	39 c2                	cmp    %eax,%edx
  80072c:	74 08                	je     800736 <strnlen+0x1f>
  80072e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800732:	75 f3                	jne    800727 <strnlen+0x10>
  800734:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800742:	89 c2                	mov    %eax,%edx
  800744:	83 c2 01             	add    $0x1,%edx
  800747:	83 c1 01             	add    $0x1,%ecx
  80074a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800751:	84 db                	test   %bl,%bl
  800753:	75 ef                	jne    800744 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075f:	53                   	push   %ebx
  800760:	e8 9a ff ff ff       	call   8006ff <strlen>
  800765:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800768:	ff 75 0c             	pushl  0xc(%ebp)
  80076b:	01 d8                	add    %ebx,%eax
  80076d:	50                   	push   %eax
  80076e:	e8 c5 ff ff ff       	call   800738 <strcpy>
	return dst;
}
  800773:	89 d8                	mov    %ebx,%eax
  800775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	56                   	push   %esi
  80077e:	53                   	push   %ebx
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800785:	89 f3                	mov    %esi,%ebx
  800787:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078a:	89 f2                	mov    %esi,%edx
  80078c:	eb 0f                	jmp    80079d <strncpy+0x23>
		*dst++ = *src;
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800797:	80 39 01             	cmpb   $0x1,(%ecx)
  80079a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	39 da                	cmp    %ebx,%edx
  80079f:	75 ed                	jne    80078e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 21                	je     8007dc <strlcpy+0x35>
  8007bb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bf:	89 f2                	mov    %esi,%edx
  8007c1:	eb 09                	jmp    8007cc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cc:	39 c2                	cmp    %eax,%edx
  8007ce:	74 09                	je     8007d9 <strlcpy+0x32>
  8007d0:	0f b6 19             	movzbl (%ecx),%ebx
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ec                	jne    8007c3 <strlcpy+0x1c>
  8007d7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 06                	jmp    8007f3 <strcmp+0x11>
		p++, q++;
  8007ed:	83 c1 01             	add    $0x1,%ecx
  8007f0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	0f b6 01             	movzbl (%ecx),%eax
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strcmp+0x1c>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	74 ef                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 c0             	movzbl %al,%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 c3                	mov    %eax,%ebx
  800814:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800817:	eb 06                	jmp    80081f <strncmp+0x17>
		n--, p++, q++;
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081f:	39 d8                	cmp    %ebx,%eax
  800821:	74 15                	je     800838 <strncmp+0x30>
  800823:	0f b6 08             	movzbl (%eax),%ecx
  800826:	84 c9                	test   %cl,%cl
  800828:	74 04                	je     80082e <strncmp+0x26>
  80082a:	3a 0a                	cmp    (%edx),%cl
  80082c:	74 eb                	je     800819 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 00             	movzbl (%eax),%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
  800836:	eb 05                	jmp    80083d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083d:	5b                   	pop    %ebx
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084a:	eb 07                	jmp    800853 <strchr+0x13>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 0f                	je     80085f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 10             	movzbl (%eax),%edx
  800856:	84 d2                	test   %dl,%dl
  800858:	75 f2                	jne    80084c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 03                	jmp    800870 <strfind+0xf>
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800873:	84 d2                	test   %dl,%dl
  800875:	74 04                	je     80087b <strfind+0x1a>
  800877:	38 ca                	cmp    %cl,%dl
  800879:	75 f2                	jne    80086d <strfind+0xc>
			break;
	return (char *) s;
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	74 36                	je     8008c3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800893:	75 28                	jne    8008bd <memset+0x40>
  800895:	f6 c1 03             	test   $0x3,%cl
  800898:	75 23                	jne    8008bd <memset+0x40>
		c &= 0xFF;
  80089a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089e:	89 d3                	mov    %edx,%ebx
  8008a0:	c1 e3 08             	shl    $0x8,%ebx
  8008a3:	89 d6                	mov    %edx,%esi
  8008a5:	c1 e6 18             	shl    $0x18,%esi
  8008a8:	89 d0                	mov    %edx,%eax
  8008aa:	c1 e0 10             	shl    $0x10,%eax
  8008ad:	09 f0                	or     %esi,%eax
  8008af:	09 c2                	or     %eax,%edx
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b8:	fc                   	cld    
  8008b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bb:	eb 06                	jmp    8008c3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	fc                   	cld    
  8008c1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d8:	39 c6                	cmp    %eax,%esi
  8008da:	73 35                	jae    800911 <memmove+0x47>
  8008dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008df:	39 d0                	cmp    %edx,%eax
  8008e1:	73 2e                	jae    800911 <memmove+0x47>
		s += n;
		d += n;
  8008e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f0:	75 13                	jne    800905 <memmove+0x3b>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 0e                	jne    800905 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f7:	83 ef 04             	sub    $0x4,%edi
  8008fa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800900:	fd                   	std    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 09                	jmp    80090e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800905:	83 ef 01             	sub    $0x1,%edi
  800908:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090b:	fd                   	std    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090e:	fc                   	cld    
  80090f:	eb 1d                	jmp    80092e <memmove+0x64>
  800911:	89 f2                	mov    %esi,%edx
  800913:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	f6 c2 03             	test   $0x3,%dl
  800918:	75 0f                	jne    800929 <memmove+0x5f>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 0a                	jne    800929 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800922:	89 c7                	mov    %eax,%edi
  800924:	fc                   	cld    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 05                	jmp    80092e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 87 ff ff ff       	call   8008ca <memmove>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c6                	mov    %eax,%esi
  800952:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	eb 1a                	jmp    800971 <memcmp+0x2c>
		if (*s1 != *s2)
  800957:	0f b6 08             	movzbl (%eax),%ecx
  80095a:	0f b6 1a             	movzbl (%edx),%ebx
  80095d:	38 d9                	cmp    %bl,%cl
  80095f:	74 0a                	je     80096b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c1             	movzbl %cl,%eax
  800964:	0f b6 db             	movzbl %bl,%ebx
  800967:	29 d8                	sub    %ebx,%eax
  800969:	eb 0f                	jmp    80097a <memcmp+0x35>
		s1++, s2++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	39 f0                	cmp    %esi,%eax
  800973:	75 e2                	jne    800957 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800987:	89 c2                	mov    %eax,%edx
  800989:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098c:	eb 07                	jmp    800995 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	38 08                	cmp    %cl,(%eax)
  800990:	74 07                	je     800999 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	39 d0                	cmp    %edx,%eax
  800997:	72 f5                	jb     80098e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	eb 03                	jmp    8009ac <strtol+0x11>
		s++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	3c 09                	cmp    $0x9,%al
  8009b1:	74 f6                	je     8009a9 <strtol+0xe>
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f2                	je     8009a9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b7:	3c 2b                	cmp    $0x2b,%al
  8009b9:	75 0a                	jne    8009c5 <strtol+0x2a>
		s++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 10                	jmp    8009d5 <strtol+0x3a>
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ca:	3c 2d                	cmp    $0x2d,%al
  8009cc:	75 07                	jne    8009d5 <strtol+0x3a>
		s++, neg = 1;
  8009ce:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009d1:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d5:	85 db                	test   %ebx,%ebx
  8009d7:	0f 94 c0             	sete   %al
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 19                	jne    8009fb <strtol+0x60>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 14                	jne    8009fb <strtol+0x60>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	0f 85 8a 00 00 00    	jne    800a7b <strtol+0xe0>
		s += 2, base = 16;
  8009f1:	83 c1 02             	add    $0x2,%ecx
  8009f4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f9:	eb 16                	jmp    800a11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009fb:	84 c0                	test   %al,%al
  8009fd:	74 12                	je     800a11 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a04:	80 39 30             	cmpb   $0x30,(%ecx)
  800a07:	75 08                	jne    800a11 <strtol+0x76>
		s++, base = 8;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a19:	0f b6 11             	movzbl (%ecx),%edx
  800a1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 09             	cmp    $0x9,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x93>
			dig = *s - '0';
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 30             	sub    $0x30,%edx
  800a2c:	eb 22                	jmp    800a50 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 08                	ja     800a40 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a38:	0f be d2             	movsbl %dl,%edx
  800a3b:	83 ea 57             	sub    $0x57,%edx
  800a3e:	eb 10                	jmp    800a50 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	80 fb 19             	cmp    $0x19,%bl
  800a48:	77 16                	ja     800a60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4a:	0f be d2             	movsbl %dl,%edx
  800a4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a53:	7d 0f                	jge    800a64 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb b9                	jmp    800a19 <strtol+0x7e>
  800a60:	89 c2                	mov    %eax,%edx
  800a62:	eb 02                	jmp    800a66 <strtol+0xcb>
  800a64:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xd6>
		*endptr = (char *) s;
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a71:	85 ff                	test   %edi,%edi
  800a73:	74 0c                	je     800a81 <strtol+0xe6>
  800a75:	89 d0                	mov    %edx,%eax
  800a77:	f7 d8                	neg    %eax
  800a79:	eb 06                	jmp    800a81 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7b:	84 c0                	test   %al,%al
  800a7d:	75 8a                	jne    800a09 <strtol+0x6e>
  800a7f:	eb 90                	jmp    800a11 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	89 c6                	mov    %eax,%esi
  800a9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab4:	89 d1                	mov    %edx,%ecx
  800ab6:	89 d3                	mov    %edx,%ebx
  800ab8:	89 d7                	mov    %edx,%edi
  800aba:	89 d6                	mov    %edx,%esi
  800abc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	89 cb                	mov    %ecx,%ebx
  800adb:	89 cf                	mov    %ecx,%edi
  800add:	89 ce                	mov    %ecx,%esi
  800adf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	7e 17                	jle    800afc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	50                   	push   %eax
  800ae9:	6a 03                	push   $0x3
  800aeb:	68 9f 27 80 00       	push   $0x80279f
  800af0:	6a 23                	push   $0x23
  800af2:	68 bc 27 80 00       	push   $0x8027bc
  800af7:	e8 df f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_yield>:

void
sys_yield(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	be 00 00 00 00       	mov    $0x0,%esi
  800b50:	b8 04 00 00 00       	mov    $0x4,%eax
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5e:	89 f7                	mov    %esi,%edi
  800b60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 04                	push   $0x4
  800b6c:	68 9f 27 80 00       	push   $0x80279f
  800b71:	6a 23                	push   $0x23
  800b73:	68 bc 27 80 00       	push   $0x8027bc
  800b78:	e8 5e f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 17                	jle    800bbf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 05                	push   $0x5
  800bae:	68 9f 27 80 00       	push   $0x80279f
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 bc 27 80 00       	push   $0x8027bc
  800bba:	e8 1c f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800be0:	89 df                	mov    %ebx,%edi
  800be2:	89 de                	mov    %ebx,%esi
  800be4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7e 17                	jle    800c01 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 06                	push   $0x6
  800bf0:	68 9f 27 80 00       	push   $0x80279f
  800bf5:	6a 23                	push   $0x23
  800bf7:	68 bc 27 80 00       	push   $0x8027bc
  800bfc:	e8 da f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	89 df                	mov    %ebx,%edi
  800c24:	89 de                	mov    %ebx,%esi
  800c26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7e 17                	jle    800c43 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 08                	push   $0x8
  800c32:	68 9f 27 80 00       	push   $0x80279f
  800c37:	6a 23                	push   $0x23
  800c39:	68 bc 27 80 00       	push   $0x8027bc
  800c3e:	e8 98 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 17                	jle    800c85 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 09                	push   $0x9
  800c74:	68 9f 27 80 00       	push   $0x80279f
  800c79:	6a 23                	push   $0x23
  800c7b:	68 bc 27 80 00       	push   $0x8027bc
  800c80:	e8 56 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 0a                	push   $0xa
  800cb6:	68 9f 27 80 00       	push   $0x80279f
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 bc 27 80 00       	push   $0x8027bc
  800cc2:	e8 14 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	be 00 00 00 00       	mov    $0x0,%esi
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ceb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d00:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 cb                	mov    %ecx,%ebx
  800d0a:	89 cf                	mov    %ecx,%edi
  800d0c:	89 ce                	mov    %ecx,%esi
  800d0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 0d                	push   $0xd
  800d1a:	68 9f 27 80 00       	push   $0x80279f
  800d1f:	6a 23                	push   $0x23
  800d21:	68 bc 27 80 00       	push   $0x8027bc
  800d26:	e8 b0 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_gettime>:

int sys_gettime(void)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	89 d3                	mov    %edx,%ebx
  800d47:	89 d7                	mov    %edx,%edi
  800d49:	89 d6                	mov    %edx,%esi
  800d4b:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
  800d58:	05 00 00 00 30       	add    $0x30000000,%eax
  800d5d:	c1 e8 0c             	shr    $0xc,%eax
}
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d72:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	c1 ea 16             	shr    $0x16,%edx
  800d89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d90:	f6 c2 01             	test   $0x1,%dl
  800d93:	74 11                	je     800da6 <fd_alloc+0x2d>
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	c1 ea 0c             	shr    $0xc,%edx
  800d9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da1:	f6 c2 01             	test   $0x1,%dl
  800da4:	75 09                	jne    800daf <fd_alloc+0x36>
			*fd_store = fd;
  800da6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dad:	eb 17                	jmp    800dc6 <fd_alloc+0x4d>
  800daf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db9:	75 c9                	jne    800d84 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dbb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dce:	83 f8 1f             	cmp    $0x1f,%eax
  800dd1:	77 36                	ja     800e09 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd3:	c1 e0 0c             	shl    $0xc,%eax
  800dd6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	c1 ea 16             	shr    $0x16,%edx
  800de0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de7:	f6 c2 01             	test   $0x1,%dl
  800dea:	74 24                	je     800e10 <fd_lookup+0x48>
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	c1 ea 0c             	shr    $0xc,%edx
  800df1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df8:	f6 c2 01             	test   $0x1,%dl
  800dfb:	74 1a                	je     800e17 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e00:	89 02                	mov    %eax,(%edx)
	return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
  800e07:	eb 13                	jmp    800e1c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0e:	eb 0c                	jmp    800e1c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e15:	eb 05                	jmp    800e1c <fd_lookup+0x54>
  800e17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e27:	ba 48 28 80 00       	mov    $0x802848,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e2c:	eb 13                	jmp    800e41 <dev_lookup+0x23>
  800e2e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e31:	39 08                	cmp    %ecx,(%eax)
  800e33:	75 0c                	jne    800e41 <dev_lookup+0x23>
			*dev = devtab[i];
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	eb 2e                	jmp    800e6f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e41:	8b 02                	mov    (%edx),%eax
  800e43:	85 c0                	test   %eax,%eax
  800e45:	75 e7                	jne    800e2e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e47:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4c:	8b 40 48             	mov    0x48(%eax),%eax
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	51                   	push   %ecx
  800e53:	50                   	push   %eax
  800e54:	68 cc 27 80 00       	push   $0x8027cc
  800e59:	e8 56 f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 10             	sub    $0x10,%esp
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e82:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e83:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e89:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8c:	50                   	push   %eax
  800e8d:	e8 36 ff ff ff       	call   800dc8 <fd_lookup>
  800e92:	83 c4 08             	add    $0x8,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 05                	js     800e9e <fd_close+0x2d>
	    || fd != fd2)
  800e99:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e9c:	74 0b                	je     800ea9 <fd_close+0x38>
		return (must_exist ? r : 0);
  800e9e:	80 fb 01             	cmp    $0x1,%bl
  800ea1:	19 d2                	sbb    %edx,%edx
  800ea3:	f7 d2                	not    %edx
  800ea5:	21 d0                	and    %edx,%eax
  800ea7:	eb 41                	jmp    800eea <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 36                	pushl  (%esi)
  800eb2:	e8 67 ff ff ff       	call   800e1e <dev_lookup>
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 1a                	js     800eda <fd_close+0x69>
		if (dev->dev_close)
  800ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	74 0b                	je     800eda <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	56                   	push   %esi
  800ed3:	ff d0                	call   *%eax
  800ed5:	89 c3                	mov    %eax,%ebx
  800ed7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	56                   	push   %esi
  800ede:	6a 00                	push   $0x0
  800ee0:	e8 e2 fc ff ff       	call   800bc7 <sys_page_unmap>
	return r;
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	89 d8                	mov    %ebx,%eax
}
  800eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efa:	50                   	push   %eax
  800efb:	ff 75 08             	pushl  0x8(%ebp)
  800efe:	e8 c5 fe ff ff       	call   800dc8 <fd_lookup>
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	83 c4 08             	add    $0x8,%esp
  800f08:	85 d2                	test   %edx,%edx
  800f0a:	78 10                	js     800f1c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f0c:	83 ec 08             	sub    $0x8,%esp
  800f0f:	6a 01                	push   $0x1
  800f11:	ff 75 f4             	pushl  -0xc(%ebp)
  800f14:	e8 58 ff ff ff       	call   800e71 <fd_close>
  800f19:	83 c4 10             	add    $0x10,%esp
}
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <close_all>:

void
close_all(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f25:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	53                   	push   %ebx
  800f2e:	e8 be ff ff ff       	call   800ef1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f33:	83 c3 01             	add    $0x1,%ebx
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	83 fb 20             	cmp    $0x20,%ebx
  800f3c:	75 ec                	jne    800f2a <close_all+0xc>
		close(i);
}
  800f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 2c             	sub    $0x2c,%esp
  800f4c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	ff 75 08             	pushl  0x8(%ebp)
  800f56:	e8 6d fe ff ff       	call   800dc8 <fd_lookup>
  800f5b:	89 c2                	mov    %eax,%edx
  800f5d:	83 c4 08             	add    $0x8,%esp
  800f60:	85 d2                	test   %edx,%edx
  800f62:	0f 88 c1 00 00 00    	js     801029 <dup+0xe6>
		return r;
	close(newfdnum);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	56                   	push   %esi
  800f6c:	e8 80 ff ff ff       	call   800ef1 <close>

	newfd = INDEX2FD(newfdnum);
  800f71:	89 f3                	mov    %esi,%ebx
  800f73:	c1 e3 0c             	shl    $0xc,%ebx
  800f76:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f7c:	83 c4 04             	add    $0x4,%esp
  800f7f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f82:	e8 db fd ff ff       	call   800d62 <fd2data>
  800f87:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f89:	89 1c 24             	mov    %ebx,(%esp)
  800f8c:	e8 d1 fd ff ff       	call   800d62 <fd2data>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f97:	89 f8                	mov    %edi,%eax
  800f99:	c1 e8 16             	shr    $0x16,%eax
  800f9c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa3:	a8 01                	test   $0x1,%al
  800fa5:	74 37                	je     800fde <dup+0x9b>
  800fa7:	89 f8                	mov    %edi,%eax
  800fa9:	c1 e8 0c             	shr    $0xc,%eax
  800fac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb3:	f6 c2 01             	test   $0x1,%dl
  800fb6:	74 26                	je     800fde <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc7:	50                   	push   %eax
  800fc8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fcb:	6a 00                	push   $0x0
  800fcd:	57                   	push   %edi
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 b0 fb ff ff       	call   800b85 <sys_page_map>
  800fd5:	89 c7                	mov    %eax,%edi
  800fd7:	83 c4 20             	add    $0x20,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 2e                	js     80100c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fe1:	89 d0                	mov    %edx,%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
  800fe6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff5:	50                   	push   %eax
  800ff6:	53                   	push   %ebx
  800ff7:	6a 00                	push   $0x0
  800ff9:	52                   	push   %edx
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 84 fb ff ff       	call   800b85 <sys_page_map>
  801001:	89 c7                	mov    %eax,%edi
  801003:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801006:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801008:	85 ff                	test   %edi,%edi
  80100a:	79 1d                	jns    801029 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	53                   	push   %ebx
  801010:	6a 00                	push   $0x0
  801012:	e8 b0 fb ff ff       	call   800bc7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801017:	83 c4 08             	add    $0x8,%esp
  80101a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80101d:	6a 00                	push   $0x0
  80101f:	e8 a3 fb ff ff       	call   800bc7 <sys_page_unmap>
	return r;
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	89 f8                	mov    %edi,%eax
}
  801029:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	53                   	push   %ebx
  801035:	83 ec 14             	sub    $0x14,%esp
  801038:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103e:	50                   	push   %eax
  80103f:	53                   	push   %ebx
  801040:	e8 83 fd ff ff       	call   800dc8 <fd_lookup>
  801045:	83 c4 08             	add    $0x8,%esp
  801048:	89 c2                	mov    %eax,%edx
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 6d                	js     8010bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801058:	ff 30                	pushl  (%eax)
  80105a:	e8 bf fd ff ff       	call   800e1e <dev_lookup>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 4c                	js     8010b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801066:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801069:	8b 42 08             	mov    0x8(%edx),%eax
  80106c:	83 e0 03             	and    $0x3,%eax
  80106f:	83 f8 01             	cmp    $0x1,%eax
  801072:	75 21                	jne    801095 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801074:	a1 04 40 80 00       	mov    0x804004,%eax
  801079:	8b 40 48             	mov    0x48(%eax),%eax
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	53                   	push   %ebx
  801080:	50                   	push   %eax
  801081:	68 0d 28 80 00       	push   $0x80280d
  801086:	e8 29 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801093:	eb 26                	jmp    8010bb <read+0x8a>
	}
	if (!dev->dev_read)
  801095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801098:	8b 40 08             	mov    0x8(%eax),%eax
  80109b:	85 c0                	test   %eax,%eax
  80109d:	74 17                	je     8010b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109f:	83 ec 04             	sub    $0x4,%esp
  8010a2:	ff 75 10             	pushl  0x10(%ebp)
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	52                   	push   %edx
  8010a9:	ff d0                	call   *%eax
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	eb 09                	jmp    8010bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	eb 05                	jmp    8010bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d6:	eb 21                	jmp    8010f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	29 d8                	sub    %ebx,%eax
  8010df:	50                   	push   %eax
  8010e0:	89 d8                	mov    %ebx,%eax
  8010e2:	03 45 0c             	add    0xc(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	57                   	push   %edi
  8010e7:	e8 45 ff ff ff       	call   801031 <read>
		if (m < 0)
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 0c                	js     8010ff <readn+0x3d>
			return m;
		if (m == 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 06                	je     8010fd <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f7:	01 c3                	add    %eax,%ebx
  8010f9:	39 f3                	cmp    %esi,%ebx
  8010fb:	72 db                	jb     8010d8 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8010fd:	89 d8                	mov    %ebx,%eax
}
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	83 ec 14             	sub    $0x14,%esp
  80110e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801111:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	53                   	push   %ebx
  801116:	e8 ad fc ff ff       	call   800dc8 <fd_lookup>
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	89 c2                	mov    %eax,%edx
  801120:	85 c0                	test   %eax,%eax
  801122:	78 68                	js     80118c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112e:	ff 30                	pushl  (%eax)
  801130:	e8 e9 fc ff ff       	call   800e1e <dev_lookup>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 47                	js     801183 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801143:	75 21                	jne    801166 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801145:	a1 04 40 80 00       	mov    0x804004,%eax
  80114a:	8b 40 48             	mov    0x48(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	53                   	push   %ebx
  801151:	50                   	push   %eax
  801152:	68 29 28 80 00       	push   $0x802829
  801157:	e8 58 f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801164:	eb 26                	jmp    80118c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801166:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801169:	8b 52 0c             	mov    0xc(%edx),%edx
  80116c:	85 d2                	test   %edx,%edx
  80116e:	74 17                	je     801187 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	ff 75 10             	pushl  0x10(%ebp)
  801176:	ff 75 0c             	pushl  0xc(%ebp)
  801179:	50                   	push   %eax
  80117a:	ff d2                	call   *%edx
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	eb 09                	jmp    80118c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	89 c2                	mov    %eax,%edx
  801185:	eb 05                	jmp    80118c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801187:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80118c:	89 d0                	mov    %edx,%eax
  80118e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <seek>:

int
seek(int fdnum, off_t offset)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801199:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 75 08             	pushl  0x8(%ebp)
  8011a0:	e8 23 fc ff ff       	call   800dc8 <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0e                	js     8011ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	53                   	push   %ebx
  8011cb:	e8 f8 fb ff ff       	call   800dc8 <fd_lookup>
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 65                	js     80123e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	ff 30                	pushl  (%eax)
  8011e5:	e8 34 fc ff ff       	call   800e1e <dev_lookup>
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 44                	js     801235 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f8:	75 21                	jne    80121b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011fa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011ff:	8b 40 48             	mov    0x48(%eax),%eax
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	53                   	push   %ebx
  801206:	50                   	push   %eax
  801207:	68 ec 27 80 00       	push   $0x8027ec
  80120c:	e8 a3 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801219:	eb 23                	jmp    80123e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80121b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121e:	8b 52 18             	mov    0x18(%edx),%edx
  801221:	85 d2                	test   %edx,%edx
  801223:	74 14                	je     801239 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	50                   	push   %eax
  80122c:	ff d2                	call   *%edx
  80122e:	89 c2                	mov    %eax,%edx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb 09                	jmp    80123e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	89 c2                	mov    %eax,%edx
  801237:	eb 05                	jmp    80123e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801239:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80123e:	89 d0                	mov    %edx,%eax
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 14             	sub    $0x14,%esp
  80124c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 75 08             	pushl  0x8(%ebp)
  801256:	e8 6d fb ff ff       	call   800dc8 <fd_lookup>
  80125b:	83 c4 08             	add    $0x8,%esp
  80125e:	89 c2                	mov    %eax,%edx
  801260:	85 c0                	test   %eax,%eax
  801262:	78 58                	js     8012bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126e:	ff 30                	pushl  (%eax)
  801270:	e8 a9 fb ff ff       	call   800e1e <dev_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 37                	js     8012b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80127c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801283:	74 32                	je     8012b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801285:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801288:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128f:	00 00 00 
	stat->st_isdir = 0;
  801292:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801299:	00 00 00 
	stat->st_dev = dev;
  80129c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	53                   	push   %ebx
  8012a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a9:	ff 50 14             	call   *0x14(%eax)
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	eb 09                	jmp    8012bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	eb 05                	jmp    8012bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012bc:	89 d0                	mov    %edx,%eax
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	6a 00                	push   $0x0
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 e7 01 00 00       	call   8014bc <open>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 db                	test   %ebx,%ebx
  8012dc:	78 1b                	js     8012f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	ff 75 0c             	pushl  0xc(%ebp)
  8012e4:	53                   	push   %ebx
  8012e5:	e8 5b ff ff ff       	call   801245 <fstat>
  8012ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ec:	89 1c 24             	mov    %ebx,(%esp)
  8012ef:	e8 fd fb ff ff       	call   800ef1 <close>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 f0                	mov    %esi,%eax
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
  801305:	89 c6                	mov    %eax,%esi
  801307:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801309:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801310:	75 12                	jne    801324 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	6a 03                	push   $0x3
  801317:	e8 9c 0d 00 00       	call   8020b8 <ipc_find_env>
  80131c:	a3 00 40 80 00       	mov    %eax,0x804000
  801321:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801324:	6a 07                	push   $0x7
  801326:	68 00 50 80 00       	push   $0x805000
  80132b:	56                   	push   %esi
  80132c:	ff 35 00 40 80 00    	pushl  0x804000
  801332:	e8 30 0d 00 00       	call   802067 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801337:	83 c4 0c             	add    $0xc,%esp
  80133a:	6a 00                	push   $0x0
  80133c:	53                   	push   %ebx
  80133d:	6a 00                	push   $0x0
  80133f:	e8 bd 0c 00 00       	call   802001 <ipc_recv>
}
  801344:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	8b 40 0c             	mov    0xc(%eax),%eax
  801357:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80135c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 02 00 00 00       	mov    $0x2,%eax
  80136e:	e8 8d ff ff ff       	call   801300 <fsipc>
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 40 0c             	mov    0xc(%eax),%eax
  801381:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801386:	ba 00 00 00 00       	mov    $0x0,%edx
  80138b:	b8 06 00 00 00       	mov    $0x6,%eax
  801390:	e8 6b ff ff ff       	call   801300 <fsipc>
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	53                   	push   %ebx
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b6:	e8 45 ff ff ff       	call   801300 <fsipc>
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	85 d2                	test   %edx,%edx
  8013bf:	78 2c                	js     8013ed <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	68 00 50 80 00       	push   $0x805000
  8013c9:	53                   	push   %ebx
  8013ca:	e8 69 f3 ff ff       	call   800738 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013da:	a1 84 50 80 00       	mov    0x805084,%eax
  8013df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8013fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801401:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801407:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80140c:	76 05                	jbe    801413 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80140e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801413:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	50                   	push   %eax
  80141c:	ff 75 0c             	pushl  0xc(%ebp)
  80141f:	68 08 50 80 00       	push   $0x805008
  801424:	e8 a1 f4 ff ff       	call   8008ca <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	b8 04 00 00 00       	mov    $0x4,%eax
  801433:	e8 c8 fe ff ff       	call   801300 <fsipc>
	return write;
}
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	b8 03 00 00 00       	mov    $0x3,%eax
  80145d:	e8 9e fe ff ff       	call   801300 <fsipc>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 4b                	js     8014b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801468:	39 c6                	cmp    %eax,%esi
  80146a:	73 16                	jae    801482 <devfile_read+0x48>
  80146c:	68 58 28 80 00       	push   $0x802858
  801471:	68 5f 28 80 00       	push   $0x80285f
  801476:	6a 7c                	push   $0x7c
  801478:	68 74 28 80 00       	push   $0x802874
  80147d:	e8 59 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  801482:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801487:	7e 16                	jle    80149f <devfile_read+0x65>
  801489:	68 7f 28 80 00       	push   $0x80287f
  80148e:	68 5f 28 80 00       	push   $0x80285f
  801493:	6a 7d                	push   $0x7d
  801495:	68 74 28 80 00       	push   $0x802874
  80149a:	e8 3c ec ff ff       	call   8000db <_panic>
	memmove(buf, &fsipcbuf, r);
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	50                   	push   %eax
  8014a3:	68 00 50 80 00       	push   $0x805000
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	e8 1a f4 ff ff       	call   8008ca <memmove>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 20             	sub    $0x20,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c6:	53                   	push   %ebx
  8014c7:	e8 33 f2 ff ff       	call   8006ff <strlen>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d4:	7f 67                	jg     80153d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	e8 97 f8 ff ff       	call   800d79 <fd_alloc>
  8014e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 57                	js     801542 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	68 00 50 80 00       	push   $0x805000
  8014f4:	e8 3f f2 ff ff       	call   800738 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801501:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801504:	b8 01 00 00 00       	mov    $0x1,%eax
  801509:	e8 f2 fd ff ff       	call   801300 <fsipc>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	79 14                	jns    80152b <open+0x6f>
		fd_close(fd, 0);
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	6a 00                	push   $0x0
  80151c:	ff 75 f4             	pushl  -0xc(%ebp)
  80151f:	e8 4d f9 ff ff       	call   800e71 <fd_close>
		return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 da                	mov    %ebx,%edx
  801529:	eb 17                	jmp    801542 <open+0x86>
	}

	return fd2num(fd);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	ff 75 f4             	pushl  -0xc(%ebp)
  801531:	e8 1c f8 ff ff       	call   800d52 <fd2num>
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 05                	jmp    801542 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80153d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801542:	89 d0                	mov    %edx,%eax
  801544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 08 00 00 00       	mov    $0x8,%eax
  801559:	e8 a2 fd ff ff       	call   801300 <fsipc>
}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	57                   	push   %edi
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80156c:	6a 00                	push   $0x0
  80156e:	ff 75 08             	pushl  0x8(%ebp)
  801571:	e8 46 ff ff ff       	call   8014bc <open>
  801576:	89 c1                	mov    %eax,%ecx
  801578:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	0f 88 c6 04 00 00    	js     801a4f <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	68 00 02 00 00       	push   $0x200
  801591:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	51                   	push   %ecx
  801599:	e8 24 fb ff ff       	call   8010c2 <readn>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015a6:	75 0c                	jne    8015b4 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015a8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015af:	45 4c 46 
  8015b2:	74 33                	je     8015e7 <spawn+0x87>
		close(fd);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015bd:	e8 2f f9 ff ff       	call   800ef1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015c2:	83 c4 0c             	add    $0xc,%esp
  8015c5:	68 7f 45 4c 46       	push   $0x464c457f
  8015ca:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015d0:	68 8b 28 80 00       	push   $0x80288b
  8015d5:	e8 da eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8015e2:	e9 c8 04 00 00       	jmp    801aaf <spawn+0x54f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015e7:	b8 07 00 00 00       	mov    $0x7,%eax
  8015ec:	cd 30                	int    $0x30
  8015ee:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8015f4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	0f 88 55 04 00 00    	js     801a57 <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801602:	89 c6                	mov    %eax,%esi
  801604:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80160a:	6b f6 78             	imul   $0x78,%esi,%esi
  80160d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801613:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801619:	b9 11 00 00 00       	mov    $0x11,%ecx
  80161e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801620:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801626:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80162c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801631:	be 00 00 00 00       	mov    $0x0,%esi
  801636:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801639:	eb 13                	jmp    80164e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	50                   	push   %eax
  80163f:	e8 bb f0 ff ff       	call   8006ff <strlen>
  801644:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801648:	83 c3 01             	add    $0x1,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801655:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801658:	85 c0                	test   %eax,%eax
  80165a:	75 df                	jne    80163b <spawn+0xdb>
  80165c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801662:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801668:	bf 00 10 40 00       	mov    $0x401000,%edi
  80166d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80166f:	89 fa                	mov    %edi,%edx
  801671:	83 e2 fc             	and    $0xfffffffc,%edx
  801674:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80167b:	29 c2                	sub    %eax,%edx
  80167d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801683:	8d 42 f8             	lea    -0x8(%edx),%eax
  801686:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80168b:	0f 86 d6 03 00 00    	jbe    801a67 <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	6a 07                	push   $0x7
  801696:	68 00 00 40 00       	push   $0x400000
  80169b:	6a 00                	push   $0x0
  80169d:	e8 a0 f4 ff ff       	call   800b42 <sys_page_alloc>
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	0f 88 02 04 00 00    	js     801aaf <spawn+0x54f>
  8016ad:	be 00 00 00 00       	mov    $0x0,%esi
  8016b2:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016bb:	eb 30                	jmp    8016ed <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016bd:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  8016c3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016c9:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016d2:	57                   	push   %edi
  8016d3:	e8 60 f0 ff ff       	call   800738 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016d8:	83 c4 04             	add    $0x4,%esp
  8016db:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016de:	e8 1c f0 ff ff       	call   8006ff <strlen>
  8016e3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016e7:	83 c6 01             	add    $0x1,%esi
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  8016f3:	7c c8                	jl     8016bd <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8016f5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8016fb:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801701:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801708:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80170e:	74 19                	je     801729 <spawn+0x1c9>
  801710:	68 14 29 80 00       	push   $0x802914
  801715:	68 5f 28 80 00       	push   $0x80285f
  80171a:	68 f1 00 00 00       	push   $0xf1
  80171f:	68 a5 28 80 00       	push   $0x8028a5
  801724:	e8 b2 e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801729:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80172f:	89 f8                	mov    %edi,%eax
  801731:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  801736:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801739:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80173f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801742:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  801748:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	6a 07                	push   $0x7
  801753:	68 00 d0 7f ee       	push   $0xee7fd000
  801758:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80175e:	68 00 00 40 00       	push   $0x400000
  801763:	6a 00                	push   $0x0
  801765:	e8 1b f4 ff ff       	call   800b85 <sys_page_map>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	83 c4 20             	add    $0x20,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	0f 88 24 03 00 00    	js     801a9b <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	68 00 00 40 00       	push   $0x400000
  80177f:	6a 00                	push   $0x0
  801781:	e8 41 f4 ff ff       	call   800bc7 <sys_page_unmap>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	0f 88 08 03 00 00    	js     801a9b <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801793:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801799:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017a0:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017a6:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017ad:	00 00 00 
  8017b0:	e9 84 01 00 00       	jmp    801939 <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  8017b5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017bb:	83 38 01             	cmpl   $0x1,(%eax)
  8017be:	0f 85 67 01 00 00    	jne    80192b <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017c4:	89 c1                	mov    %eax,%ecx
  8017c6:	8b 40 18             	mov    0x18(%eax),%eax
  8017c9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017cf:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017d2:	83 f8 01             	cmp    $0x1,%eax
  8017d5:	19 c0                	sbb    %eax,%eax
  8017d7:	83 e0 fe             	and    $0xfffffffe,%eax
  8017da:	83 c0 07             	add    $0x7,%eax
  8017dd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8017e3:	89 c8                	mov    %ecx,%eax
  8017e5:	8b 49 04             	mov    0x4(%ecx),%ecx
  8017e8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8017ee:	8b 78 10             	mov    0x10(%eax),%edi
  8017f1:	8b 48 14             	mov    0x14(%eax),%ecx
  8017f4:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8017fa:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	25 ff 0f 00 00       	and    $0xfff,%eax
  801804:	74 10                	je     801816 <spawn+0x2b6>
		va -= i;
  801806:	29 c6                	sub    %eax,%esi
		memsz += i;
  801808:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  80180e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801810:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801816:	bb 00 00 00 00       	mov    $0x0,%ebx
  80181b:	e9 f9 00 00 00       	jmp    801919 <spawn+0x3b9>
		if (i >= filesz) {
  801820:	39 fb                	cmp    %edi,%ebx
  801822:	72 27                	jb     80184b <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80182d:	56                   	push   %esi
  80182e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801834:	e8 09 f3 ff ff       	call   800b42 <sys_page_alloc>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 89 c9 00 00 00    	jns    80190d <spawn+0x3ad>
  801844:	89 c7                	mov    %eax,%edi
  801846:	e9 2d 02 00 00       	jmp    801a78 <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	6a 07                	push   $0x7
  801850:	68 00 00 40 00       	push   $0x400000
  801855:	6a 00                	push   $0x0
  801857:	e8 e6 f2 ff ff       	call   800b42 <sys_page_alloc>
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	0f 88 07 02 00 00    	js     801a6e <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801870:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80187d:	e8 11 f9 ff ff       	call   801193 <seek>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 e5 01 00 00    	js     801a72 <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	89 fa                	mov    %edi,%edx
  801892:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801898:	89 d0                	mov    %edx,%eax
  80189a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8018a0:	76 05                	jbe    8018a7 <spawn+0x347>
  8018a2:	b8 00 10 00 00       	mov    $0x1000,%eax
  8018a7:	50                   	push   %eax
  8018a8:	68 00 00 40 00       	push   $0x400000
  8018ad:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018b3:	e8 0a f8 ff ff       	call   8010c2 <readn>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	0f 88 b3 01 00 00    	js     801a76 <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018cc:	56                   	push   %esi
  8018cd:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018d3:	68 00 00 40 00       	push   $0x400000
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 a6 f2 ff ff       	call   800b85 <sys_page_map>
  8018df:	83 c4 20             	add    $0x20,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	79 15                	jns    8018fb <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  8018e6:	50                   	push   %eax
  8018e7:	68 b1 28 80 00       	push   $0x8028b1
  8018ec:	68 23 01 00 00       	push   $0x123
  8018f1:	68 a5 28 80 00       	push   $0x8028a5
  8018f6:	e8 e0 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	68 00 00 40 00       	push   $0x400000
  801903:	6a 00                	push   $0x0
  801905:	e8 bd f2 ff ff       	call   800bc7 <sys_page_unmap>
  80190a:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80190d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801913:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801919:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80191f:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801925:	0f 82 f5 fe ff ff    	jb     801820 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80192b:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801932:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801939:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801940:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801946:	0f 8c 69 fe ff ff    	jl     8017b5 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80194c:	83 ec 0c             	sub    $0xc,%esp
  80194f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801955:	e8 97 f5 ff ff       	call   800ef1 <close>
  80195a:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  80195d:	ba 00 00 00 00       	mov    $0x0,%edx
  801962:	bb 00 00 00 00       	mov    $0x0,%ebx
  801967:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  80196d:	89 d8                	mov    %ebx,%eax
  80196f:	c1 f8 0a             	sar    $0xa,%eax
  801972:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801979:	a8 01                	test   $0x1,%al
  80197b:	75 10                	jne    80198d <spawn+0x42d>
  80197d:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  801983:	75 08                	jne    80198d <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  801985:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  80198b:	eb 54                	jmp    8019e1 <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  80198d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801994:	a8 01                	test   $0x1,%al
  801996:	74 49                	je     8019e1 <spawn+0x481>
  801998:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80199f:	f6 c4 04             	test   $0x4,%ah
  8019a2:	74 3d                	je     8019e1 <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  8019a4:	89 da                	mov    %ebx,%edx
  8019a6:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  8019a9:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8019b8:	50                   	push   %eax
  8019b9:	52                   	push   %edx
  8019ba:	56                   	push   %esi
  8019bb:	52                   	push   %edx
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 c2 f1 ff ff       	call   800b85 <sys_page_map>
  8019c3:	83 c4 20             	add    $0x20,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	74 17                	je     8019e1 <spawn+0x481>
                                panic("copy_shared_pages");
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	68 ce 28 80 00       	push   $0x8028ce
  8019d2:	68 3c 01 00 00       	push   $0x13c
  8019d7:	68 a5 28 80 00       	push   $0x8028a5
  8019dc:	e8 fa e6 ff ff       	call   8000db <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  8019e1:	83 c3 01             	add    $0x1,%ebx
  8019e4:	89 da                	mov    %ebx,%edx
  8019e6:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  8019ec:	0f 86 7b ff ff ff    	jbe    80196d <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019fb:	50                   	push   %eax
  8019fc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a02:	e8 44 f2 ff ff       	call   800c4b <sys_env_set_trapframe>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	79 15                	jns    801a23 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  801a0e:	50                   	push   %eax
  801a0f:	68 e0 28 80 00       	push   $0x8028e0
  801a14:	68 85 00 00 00       	push   $0x85
  801a19:	68 a5 28 80 00       	push   $0x8028a5
  801a1e:	e8 b8 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	6a 02                	push   $0x2
  801a28:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a2e:	e8 d6 f1 ff ff       	call   800c09 <sys_env_set_status>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	79 25                	jns    801a5f <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  801a3a:	50                   	push   %eax
  801a3b:	68 fa 28 80 00       	push   $0x8028fa
  801a40:	68 88 00 00 00       	push   $0x88
  801a45:	68 a5 28 80 00       	push   $0x8028a5
  801a4a:	e8 8c e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a4f:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801a55:	eb 58                	jmp    801aaf <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a57:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801a5d:	eb 50                	jmp    801aaf <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  801a5f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801a65:	eb 48                	jmp    801aaf <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a67:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801a6c:	eb 41                	jmp    801aaf <spawn+0x54f>
  801a6e:	89 c7                	mov    %eax,%edi
  801a70:	eb 06                	jmp    801a78 <spawn+0x518>
  801a72:	89 c7                	mov    %eax,%edi
  801a74:	eb 02                	jmp    801a78 <spawn+0x518>
  801a76:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a81:	e8 3d f0 ff ff       	call   800ac3 <sys_env_destroy>
	close(fd);
  801a86:	83 c4 04             	add    $0x4,%esp
  801a89:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a8f:	e8 5d f4 ff ff       	call   800ef1 <close>
	return r;
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	89 f8                	mov    %edi,%eax
  801a99:	eb 14                	jmp    801aaf <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	68 00 00 40 00       	push   $0x400000
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 1d f1 ff ff       	call   800bc7 <sys_page_unmap>
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5f                   	pop    %edi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801abc:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801abf:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac4:	eb 03                	jmp    801ac9 <spawnl+0x12>
		argc++;
  801ac6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac9:	83 c2 04             	add    $0x4,%edx
  801acc:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ad0:	75 f4                	jne    801ac6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ad2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ad9:	83 e2 f0             	and    $0xfffffff0,%edx
  801adc:	29 d4                	sub    %edx,%esp
  801ade:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ae2:	c1 ea 02             	shr    $0x2,%edx
  801ae5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801aec:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801af8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801aff:	00 
  801b00:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b02:	b8 00 00 00 00       	mov    $0x0,%eax
  801b07:	eb 0a                	jmp    801b13 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b09:	83 c0 01             	add    $0x1,%eax
  801b0c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b10:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b13:	39 d0                	cmp    %edx,%eax
  801b15:	75 f2                	jne    801b09 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	56                   	push   %esi
  801b1b:	ff 75 08             	pushl  0x8(%ebp)
  801b1e:	e8 3d fa ff ff       	call   801560 <spawn>
}
  801b23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b26:	5b                   	pop    %ebx
  801b27:	5e                   	pop    %esi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	ff 75 08             	pushl  0x8(%ebp)
  801b38:	e8 25 f2 ff ff       	call   800d62 <fd2data>
  801b3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b3f:	83 c4 08             	add    $0x8,%esp
  801b42:	68 3a 29 80 00       	push   $0x80293a
  801b47:	53                   	push   %ebx
  801b48:	e8 eb eb ff ff       	call   800738 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b4d:	8b 56 04             	mov    0x4(%esi),%edx
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	2b 06                	sub    (%esi),%eax
  801b54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b5a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b61:	00 00 00 
	stat->st_dev = &devpipe;
  801b64:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b6b:	30 80 00 
	return 0;
}
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b84:	53                   	push   %ebx
  801b85:	6a 00                	push   $0x0
  801b87:	e8 3b f0 ff ff       	call   800bc7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b8c:	89 1c 24             	mov    %ebx,(%esp)
  801b8f:	e8 ce f1 ff ff       	call   800d62 <fd2data>
  801b94:	83 c4 08             	add    $0x8,%esp
  801b97:	50                   	push   %eax
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 28 f0 ff ff       	call   800bc7 <sys_page_unmap>
}
  801b9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	57                   	push   %edi
  801ba8:	56                   	push   %esi
  801ba9:	53                   	push   %ebx
  801baa:	83 ec 1c             	sub    $0x1c,%esp
  801bad:	89 c7                	mov    %eax,%edi
  801baf:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bb9:	83 ec 0c             	sub    $0xc,%esp
  801bbc:	57                   	push   %edi
  801bbd:	e8 2e 05 00 00       	call   8020f0 <pageref>
  801bc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bc5:	89 34 24             	mov    %esi,(%esp)
  801bc8:	e8 23 05 00 00       	call   8020f0 <pageref>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd3:	0f 94 c0             	sete   %al
  801bd6:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bd9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bdf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be2:	39 cb                	cmp    %ecx,%ebx
  801be4:	74 15                	je     801bfb <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801be6:	8b 52 58             	mov    0x58(%edx),%edx
  801be9:	50                   	push   %eax
  801bea:	52                   	push   %edx
  801beb:	53                   	push   %ebx
  801bec:	68 48 29 80 00       	push   $0x802948
  801bf1:	e8 be e5 ff ff       	call   8001b4 <cprintf>
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	eb b6                	jmp    801bb1 <_pipeisclosed+0xd>
	}
}
  801bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	57                   	push   %edi
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 28             	sub    $0x28,%esp
  801c0c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c0f:	56                   	push   %esi
  801c10:	e8 4d f1 ff ff       	call   800d62 <fd2data>
  801c15:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c1f:	eb 4b                	jmp    801c6c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	89 f0                	mov    %esi,%eax
  801c25:	e8 7a ff ff ff       	call   801ba4 <_pipeisclosed>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	75 48                	jne    801c76 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c2e:	e8 f0 ee ff ff       	call   800b23 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c33:	8b 43 04             	mov    0x4(%ebx),%eax
  801c36:	8b 0b                	mov    (%ebx),%ecx
  801c38:	8d 51 20             	lea    0x20(%ecx),%edx
  801c3b:	39 d0                	cmp    %edx,%eax
  801c3d:	73 e2                	jae    801c21 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c42:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c46:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c49:	89 c2                	mov    %eax,%edx
  801c4b:	c1 fa 1f             	sar    $0x1f,%edx
  801c4e:	89 d1                	mov    %edx,%ecx
  801c50:	c1 e9 1b             	shr    $0x1b,%ecx
  801c53:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c56:	83 e2 1f             	and    $0x1f,%edx
  801c59:	29 ca                	sub    %ecx,%edx
  801c5b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c5f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c63:	83 c0 01             	add    $0x1,%eax
  801c66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c69:	83 c7 01             	add    $0x1,%edi
  801c6c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c6f:	75 c2                	jne    801c33 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c71:	8b 45 10             	mov    0x10(%ebp),%eax
  801c74:	eb 05                	jmp    801c7b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5f                   	pop    %edi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	57                   	push   %edi
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	83 ec 18             	sub    $0x18,%esp
  801c8c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c8f:	57                   	push   %edi
  801c90:	e8 cd f0 ff ff       	call   800d62 <fd2data>
  801c95:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c9f:	eb 3d                	jmp    801cde <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ca1:	85 db                	test   %ebx,%ebx
  801ca3:	74 04                	je     801ca9 <devpipe_read+0x26>
				return i;
  801ca5:	89 d8                	mov    %ebx,%eax
  801ca7:	eb 44                	jmp    801ced <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ca9:	89 f2                	mov    %esi,%edx
  801cab:	89 f8                	mov    %edi,%eax
  801cad:	e8 f2 fe ff ff       	call   801ba4 <_pipeisclosed>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	75 32                	jne    801ce8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cb6:	e8 68 ee ff ff       	call   800b23 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cbb:	8b 06                	mov    (%esi),%eax
  801cbd:	3b 46 04             	cmp    0x4(%esi),%eax
  801cc0:	74 df                	je     801ca1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc2:	99                   	cltd   
  801cc3:	c1 ea 1b             	shr    $0x1b,%edx
  801cc6:	01 d0                	add    %edx,%eax
  801cc8:	83 e0 1f             	and    $0x1f,%eax
  801ccb:	29 d0                	sub    %edx,%eax
  801ccd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cd8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdb:	83 c3 01             	add    $0x1,%ebx
  801cde:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce1:	75 d8                	jne    801cbb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce6:	eb 05                	jmp    801ced <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    

00801cf5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d00:	50                   	push   %eax
  801d01:	e8 73 f0 ff ff       	call   800d79 <fd_alloc>
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	89 c2                	mov    %eax,%edx
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	0f 88 2c 01 00 00    	js     801e3f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d13:	83 ec 04             	sub    $0x4,%esp
  801d16:	68 07 04 00 00       	push   $0x407
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 1d ee ff ff       	call   800b42 <sys_page_alloc>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	0f 88 0d 01 00 00    	js     801e3f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	e8 3b f0 ff ff       	call   800d79 <fd_alloc>
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	0f 88 e2 00 00 00    	js     801e2d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	68 07 04 00 00       	push   $0x407
  801d53:	ff 75 f0             	pushl  -0x10(%ebp)
  801d56:	6a 00                	push   $0x0
  801d58:	e8 e5 ed ff ff       	call   800b42 <sys_page_alloc>
  801d5d:	89 c3                	mov    %eax,%ebx
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	0f 88 c3 00 00 00    	js     801e2d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d6a:	83 ec 0c             	sub    $0xc,%esp
  801d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d70:	e8 ed ef ff ff       	call   800d62 <fd2data>
  801d75:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d77:	83 c4 0c             	add    $0xc,%esp
  801d7a:	68 07 04 00 00       	push   $0x407
  801d7f:	50                   	push   %eax
  801d80:	6a 00                	push   $0x0
  801d82:	e8 bb ed ff ff       	call   800b42 <sys_page_alloc>
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	0f 88 89 00 00 00    	js     801e1d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9a:	e8 c3 ef ff ff       	call   800d62 <fd2data>
  801d9f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801da6:	50                   	push   %eax
  801da7:	6a 00                	push   $0x0
  801da9:	56                   	push   %esi
  801daa:	6a 00                	push   $0x0
  801dac:	e8 d4 ed ff ff       	call   800b85 <sys_page_map>
  801db1:	89 c3                	mov    %eax,%ebx
  801db3:	83 c4 20             	add    $0x20,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 55                	js     801e0f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dcf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de4:	83 ec 0c             	sub    $0xc,%esp
  801de7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dea:	e8 63 ef ff ff       	call   800d52 <fd2num>
  801def:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df4:	83 c4 04             	add    $0x4,%esp
  801df7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfa:	e8 53 ef ff ff       	call   800d52 <fd2num>
  801dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e02:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0d:	eb 30                	jmp    801e3f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e0f:	83 ec 08             	sub    $0x8,%esp
  801e12:	56                   	push   %esi
  801e13:	6a 00                	push   $0x0
  801e15:	e8 ad ed ff ff       	call   800bc7 <sys_page_unmap>
  801e1a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e1d:	83 ec 08             	sub    $0x8,%esp
  801e20:	ff 75 f0             	pushl  -0x10(%ebp)
  801e23:	6a 00                	push   $0x0
  801e25:	e8 9d ed ff ff       	call   800bc7 <sys_page_unmap>
  801e2a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	ff 75 f4             	pushl  -0xc(%ebp)
  801e33:	6a 00                	push   $0x0
  801e35:	e8 8d ed ff ff       	call   800bc7 <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	ff 75 08             	pushl  0x8(%ebp)
  801e55:	e8 6e ef ff ff       	call   800dc8 <fd_lookup>
  801e5a:	89 c2                	mov    %eax,%edx
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	85 d2                	test   %edx,%edx
  801e61:	78 18                	js     801e7b <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	ff 75 f4             	pushl  -0xc(%ebp)
  801e69:	e8 f4 ee ff ff       	call   800d62 <fd2data>
	return _pipeisclosed(fd, p);
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e73:	e8 2c fd ff ff       	call   801ba4 <_pipeisclosed>
  801e78:	83 c4 10             	add    $0x10,%esp
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e8d:	68 7c 29 80 00       	push   $0x80297c
  801e92:	ff 75 0c             	pushl  0xc(%ebp)
  801e95:	e8 9e e8 ff ff       	call   800738 <strcpy>
	return 0;
}
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	57                   	push   %edi
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ead:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb8:	eb 2e                	jmp    801ee8 <devcons_write+0x47>
		m = n - tot;
  801eba:	8b 55 10             	mov    0x10(%ebp),%edx
  801ebd:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801ebf:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801ec4:	83 fa 7f             	cmp    $0x7f,%edx
  801ec7:	77 02                	ja     801ecb <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec9:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	56                   	push   %esi
  801ecf:	03 45 0c             	add    0xc(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	57                   	push   %edi
  801ed4:	e8 f1 e9 ff ff       	call   8008ca <memmove>
		sys_cputs(buf, m);
  801ed9:	83 c4 08             	add    $0x8,%esp
  801edc:	56                   	push   %esi
  801edd:	57                   	push   %edi
  801ede:	e8 a3 eb ff ff       	call   800a86 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee3:	01 f3                	add    %esi,%ebx
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	89 d8                	mov    %ebx,%eax
  801eea:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eed:	72 cb                	jb     801eba <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef2:	5b                   	pop    %ebx
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801f02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f06:	75 07                	jne    801f0f <devcons_read+0x18>
  801f08:	eb 28                	jmp    801f32 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f0a:	e8 14 ec ff ff       	call   800b23 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f0f:	e8 90 eb ff ff       	call   800aa4 <sys_cgetc>
  801f14:	85 c0                	test   %eax,%eax
  801f16:	74 f2                	je     801f0a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	78 16                	js     801f32 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f1c:	83 f8 04             	cmp    $0x4,%eax
  801f1f:	74 0c                	je     801f2d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f24:	88 02                	mov    %al,(%edx)
	return 1;
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	eb 05                	jmp    801f32 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f40:	6a 01                	push   $0x1
  801f42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f45:	50                   	push   %eax
  801f46:	e8 3b eb ff ff       	call   800a86 <sys_cputs>
  801f4b:	83 c4 10             	add    $0x10,%esp
}
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <getchar>:

int
getchar(void)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f56:	6a 01                	push   $0x1
  801f58:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 ce f0 ff ff       	call   801031 <read>
	if (r < 0)
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 0f                	js     801f79 <getchar+0x29>
		return r;
	if (r < 1)
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	7e 06                	jle    801f74 <getchar+0x24>
		return -E_EOF;
	return c;
  801f6e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f72:	eb 05                	jmp    801f79 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f74:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f84:	50                   	push   %eax
  801f85:	ff 75 08             	pushl  0x8(%ebp)
  801f88:	e8 3b ee ff ff       	call   800dc8 <fd_lookup>
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 11                	js     801fa5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f97:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f9d:	39 10                	cmp    %edx,(%eax)
  801f9f:	0f 94 c0             	sete   %al
  801fa2:	0f b6 c0             	movzbl %al,%eax
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    

00801fa7 <opencons>:

int
opencons(void)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb0:	50                   	push   %eax
  801fb1:	e8 c3 ed ff ff       	call   800d79 <fd_alloc>
  801fb6:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	78 3e                	js     801ffd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbf:	83 ec 04             	sub    $0x4,%esp
  801fc2:	68 07 04 00 00       	push   $0x407
  801fc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fca:	6a 00                	push   $0x0
  801fcc:	e8 71 eb ff ff       	call   800b42 <sys_page_alloc>
  801fd1:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 23                	js     801ffd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fda:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	50                   	push   %eax
  801ff3:	e8 5a ed ff ff       	call   800d52 <fd2num>
  801ff8:	89 c2                	mov    %eax,%edx
  801ffa:	83 c4 10             	add    $0x10,%esp
}
  801ffd:	89 d0                	mov    %edx,%eax
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	8b 75 08             	mov    0x8(%ebp),%esi
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  80200f:	85 f6                	test   %esi,%esi
  802011:	74 06                	je     802019 <ipc_recv+0x18>
  802013:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802019:	85 db                	test   %ebx,%ebx
  80201b:	74 06                	je     802023 <ipc_recv+0x22>
  80201d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802023:	83 f8 01             	cmp    $0x1,%eax
  802026:	19 d2                	sbb    %edx,%edx
  802028:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	50                   	push   %eax
  80202e:	e8 bf ec ff ff       	call   800cf2 <sys_ipc_recv>
  802033:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 d2                	test   %edx,%edx
  80203a:	75 24                	jne    802060 <ipc_recv+0x5f>
	if (from_env_store)
  80203c:	85 f6                	test   %esi,%esi
  80203e:	74 0a                	je     80204a <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  802040:	a1 04 40 80 00       	mov    0x804004,%eax
  802045:	8b 40 70             	mov    0x70(%eax),%eax
  802048:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80204a:	85 db                	test   %ebx,%ebx
  80204c:	74 0a                	je     802058 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  80204e:	a1 04 40 80 00       	mov    0x804004,%eax
  802053:	8b 40 74             	mov    0x74(%eax),%eax
  802056:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802058:	a1 04 40 80 00       	mov    0x804004,%eax
  80205d:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802060:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	57                   	push   %edi
  80206b:	56                   	push   %esi
  80206c:	53                   	push   %ebx
  80206d:	83 ec 0c             	sub    $0xc,%esp
  802070:	8b 7d 08             	mov    0x8(%ebp),%edi
  802073:	8b 75 0c             	mov    0xc(%ebp),%esi
  802076:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  802079:	83 fb 01             	cmp    $0x1,%ebx
  80207c:	19 c0                	sbb    %eax,%eax
  80207e:	09 c3                	or     %eax,%ebx
  802080:	eb 1c                	jmp    80209e <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  802082:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802085:	74 12                	je     802099 <ipc_send+0x32>
  802087:	50                   	push   %eax
  802088:	68 88 29 80 00       	push   $0x802988
  80208d:	6a 36                	push   $0x36
  80208f:	68 9f 29 80 00       	push   $0x80299f
  802094:	e8 42 e0 ff ff       	call   8000db <_panic>
		sys_yield();
  802099:	e8 85 ea ff ff       	call   800b23 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80209e:	ff 75 14             	pushl  0x14(%ebp)
  8020a1:	53                   	push   %ebx
  8020a2:	56                   	push   %esi
  8020a3:	57                   	push   %edi
  8020a4:	e8 26 ec ff ff       	call   800ccf <sys_ipc_try_send>
		if (ret == 0) break;
  8020a9:	83 c4 10             	add    $0x10,%esp
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	75 d2                	jne    802082 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  8020b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020c3:	6b d0 78             	imul   $0x78,%eax,%edx
  8020c6:	83 c2 50             	add    $0x50,%edx
  8020c9:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  8020cf:	39 ca                	cmp    %ecx,%edx
  8020d1:	75 0d                	jne    8020e0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020d3:	6b c0 78             	imul   $0x78,%eax,%eax
  8020d6:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020db:	8b 40 08             	mov    0x8(%eax),%eax
  8020de:	eb 0e                	jmp    8020ee <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e0:	83 c0 01             	add    $0x1,%eax
  8020e3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020e8:	75 d9                	jne    8020c3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ea:	66 b8 00 00          	mov    $0x0,%ax
}
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	c1 e8 16             	shr    $0x16,%eax
  8020fb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802107:	f6 c1 01             	test   $0x1,%cl
  80210a:	74 1d                	je     802129 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80210c:	c1 ea 0c             	shr    $0xc,%edx
  80210f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802116:	f6 c2 01             	test   $0x1,%dl
  802119:	74 0e                	je     802129 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80211b:	c1 ea 0c             	shr    $0xc,%edx
  80211e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802125:	ef 
  802126:	0f b7 c0             	movzwl %ax,%eax
}
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    
  80212b:	66 90                	xchg   %ax,%ax
  80212d:	66 90                	xchg   %ax,%ax
  80212f:	90                   	nop

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	83 ec 10             	sub    $0x10,%esp
  802136:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80213a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80213e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802142:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802146:	85 d2                	test   %edx,%edx
  802148:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80214c:	89 34 24             	mov    %esi,(%esp)
  80214f:	89 c8                	mov    %ecx,%eax
  802151:	75 35                	jne    802188 <__udivdi3+0x58>
  802153:	39 f1                	cmp    %esi,%ecx
  802155:	0f 87 bd 00 00 00    	ja     802218 <__udivdi3+0xe8>
  80215b:	85 c9                	test   %ecx,%ecx
  80215d:	89 cd                	mov    %ecx,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f1                	div    %ecx
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 f0                	mov    %esi,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c6                	mov    %eax,%esi
  802174:	89 f8                	mov    %edi,%eax
  802176:	f7 f5                	div    %ebp
  802178:	89 f2                	mov    %esi,%edx
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    
  802181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802188:	3b 14 24             	cmp    (%esp),%edx
  80218b:	77 7b                	ja     802208 <__udivdi3+0xd8>
  80218d:	0f bd f2             	bsr    %edx,%esi
  802190:	83 f6 1f             	xor    $0x1f,%esi
  802193:	0f 84 97 00 00 00    	je     802230 <__udivdi3+0x100>
  802199:	bd 20 00 00 00       	mov    $0x20,%ebp
  80219e:	89 d7                	mov    %edx,%edi
  8021a0:	89 f1                	mov    %esi,%ecx
  8021a2:	29 f5                	sub    %esi,%ebp
  8021a4:	d3 e7                	shl    %cl,%edi
  8021a6:	89 c2                	mov    %eax,%edx
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	d3 ea                	shr    %cl,%edx
  8021ac:	89 f1                	mov    %esi,%ecx
  8021ae:	09 fa                	or     %edi,%edx
  8021b0:	8b 3c 24             	mov    (%esp),%edi
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c3:	89 fa                	mov    %edi,%edx
  8021c5:	d3 ea                	shr    %cl,%edx
  8021c7:	89 f1                	mov    %esi,%ecx
  8021c9:	d3 e7                	shl    %cl,%edi
  8021cb:	89 e9                	mov    %ebp,%ecx
  8021cd:	d3 e8                	shr    %cl,%eax
  8021cf:	09 c7                	or     %eax,%edi
  8021d1:	89 f8                	mov    %edi,%eax
  8021d3:	f7 74 24 08          	divl   0x8(%esp)
  8021d7:	89 d5                	mov    %edx,%ebp
  8021d9:	89 c7                	mov    %eax,%edi
  8021db:	f7 64 24 0c          	mull   0xc(%esp)
  8021df:	39 d5                	cmp    %edx,%ebp
  8021e1:	89 14 24             	mov    %edx,(%esp)
  8021e4:	72 11                	jb     8021f7 <__udivdi3+0xc7>
  8021e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021ea:	89 f1                	mov    %esi,%ecx
  8021ec:	d3 e2                	shl    %cl,%edx
  8021ee:	39 c2                	cmp    %eax,%edx
  8021f0:	73 5e                	jae    802250 <__udivdi3+0x120>
  8021f2:	3b 2c 24             	cmp    (%esp),%ebp
  8021f5:	75 59                	jne    802250 <__udivdi3+0x120>
  8021f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021fa:	31 f6                	xor    %esi,%esi
  8021fc:	89 f2                	mov    %esi,%edx
  8021fe:	83 c4 10             	add    $0x10,%esp
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	31 f6                	xor    %esi,%esi
  80220a:	31 c0                	xor    %eax,%eax
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	83 c4 10             	add    $0x10,%esp
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	8d 76 00             	lea    0x0(%esi),%esi
  802218:	89 f2                	mov    %esi,%edx
  80221a:	31 f6                	xor    %esi,%esi
  80221c:	89 f8                	mov    %edi,%eax
  80221e:	f7 f1                	div    %ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	83 c4 10             	add    $0x10,%esp
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802234:	76 0b                	jbe    802241 <__udivdi3+0x111>
  802236:	31 c0                	xor    %eax,%eax
  802238:	3b 14 24             	cmp    (%esp),%edx
  80223b:	0f 83 37 ff ff ff    	jae    802178 <__udivdi3+0x48>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	e9 2d ff ff ff       	jmp    802178 <__udivdi3+0x48>
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f8                	mov    %edi,%eax
  802252:	31 f6                	xor    %esi,%esi
  802254:	e9 1f ff ff ff       	jmp    802178 <__udivdi3+0x48>
  802259:	66 90                	xchg   %ax,%ax
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	83 ec 20             	sub    $0x20,%esp
  802266:	8b 44 24 34          	mov    0x34(%esp),%eax
  80226a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802272:	89 c6                	mov    %eax,%esi
  802274:	89 44 24 10          	mov    %eax,0x10(%esp)
  802278:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80227c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802280:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802284:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802288:	89 74 24 18          	mov    %esi,0x18(%esp)
  80228c:	85 c0                	test   %eax,%eax
  80228e:	89 c2                	mov    %eax,%edx
  802290:	75 1e                	jne    8022b0 <__umoddi3+0x50>
  802292:	39 f7                	cmp    %esi,%edi
  802294:	76 52                	jbe    8022e8 <__umoddi3+0x88>
  802296:	89 c8                	mov    %ecx,%eax
  802298:	89 f2                	mov    %esi,%edx
  80229a:	f7 f7                	div    %edi
  80229c:	89 d0                	mov    %edx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	83 c4 20             	add    $0x20,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    
  8022a7:	89 f6                	mov    %esi,%esi
  8022a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022b0:	39 f0                	cmp    %esi,%eax
  8022b2:	77 5c                	ja     802310 <__umoddi3+0xb0>
  8022b4:	0f bd e8             	bsr    %eax,%ebp
  8022b7:	83 f5 1f             	xor    $0x1f,%ebp
  8022ba:	75 64                	jne    802320 <__umoddi3+0xc0>
  8022bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022c4:	0f 86 f6 00 00 00    	jbe    8023c0 <__umoddi3+0x160>
  8022ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022ce:	0f 82 ec 00 00 00    	jb     8023c0 <__umoddi3+0x160>
  8022d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022dc:	83 c4 20             	add    $0x20,%esp
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    
  8022e3:	90                   	nop
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	85 ff                	test   %edi,%edi
  8022ea:	89 fd                	mov    %edi,%ebp
  8022ec:	75 0b                	jne    8022f9 <__umoddi3+0x99>
  8022ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f7                	div    %edi
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	f7 f5                	div    %ebp
  802301:	89 c8                	mov    %ecx,%eax
  802303:	f7 f5                	div    %ebp
  802305:	eb 95                	jmp    80229c <__umoddi3+0x3c>
  802307:	89 f6                	mov    %esi,%esi
  802309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802310:	89 c8                	mov    %ecx,%eax
  802312:	89 f2                	mov    %esi,%edx
  802314:	83 c4 20             	add    $0x20,%esp
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	b8 20 00 00 00       	mov    $0x20,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	29 e8                	sub    %ebp,%eax
  802329:	d3 e2                	shl    %cl,%edx
  80232b:	89 c7                	mov    %eax,%edi
  80232d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802331:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 c1                	mov    %eax,%ecx
  80233b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80233f:	09 d1                	or     %edx,%ecx
  802341:	89 fa                	mov    %edi,%edx
  802343:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802347:	89 e9                	mov    %ebp,%ecx
  802349:	d3 e0                	shl    %cl,%eax
  80234b:	89 f9                	mov    %edi,%ecx
  80234d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802351:	89 f0                	mov    %esi,%eax
  802353:	d3 e8                	shr    %cl,%eax
  802355:	89 e9                	mov    %ebp,%ecx
  802357:	89 c7                	mov    %eax,%edi
  802359:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80235d:	d3 e6                	shl    %cl,%esi
  80235f:	89 d1                	mov    %edx,%ecx
  802361:	89 fa                	mov    %edi,%edx
  802363:	d3 e8                	shr    %cl,%eax
  802365:	89 e9                	mov    %ebp,%ecx
  802367:	09 f0                	or     %esi,%eax
  802369:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80236d:	f7 74 24 10          	divl   0x10(%esp)
  802371:	d3 e6                	shl    %cl,%esi
  802373:	89 d1                	mov    %edx,%ecx
  802375:	f7 64 24 0c          	mull   0xc(%esp)
  802379:	39 d1                	cmp    %edx,%ecx
  80237b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80237f:	89 d7                	mov    %edx,%edi
  802381:	89 c6                	mov    %eax,%esi
  802383:	72 0a                	jb     80238f <__umoddi3+0x12f>
  802385:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802389:	73 10                	jae    80239b <__umoddi3+0x13b>
  80238b:	39 d1                	cmp    %edx,%ecx
  80238d:	75 0c                	jne    80239b <__umoddi3+0x13b>
  80238f:	89 d7                	mov    %edx,%edi
  802391:	89 c6                	mov    %eax,%esi
  802393:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802397:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80239b:	89 ca                	mov    %ecx,%edx
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023a3:	29 f0                	sub    %esi,%eax
  8023a5:	19 fa                	sbb    %edi,%edx
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8023ae:	89 d7                	mov    %edx,%edi
  8023b0:	d3 e7                	shl    %cl,%edi
  8023b2:	89 e9                	mov    %ebp,%ecx
  8023b4:	09 f8                	or     %edi,%eax
  8023b6:	d3 ea                	shr    %cl,%edx
  8023b8:	83 c4 20             	add    $0x20,%esp
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
  8023bf:	90                   	nop
  8023c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023c4:	29 f9                	sub    %edi,%ecx
  8023c6:	19 c6                	sbb    %eax,%esi
  8023c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023d0:	e9 ff fe ff ff       	jmp    8022d4 <__umoddi3+0x74>
