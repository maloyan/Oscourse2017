
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 08 0e 00 00       	call   800e49 <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 25                	je     80006f <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 b2 0a 00 00       	call   800b01 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 00 22 80 00       	push   $0x802200
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 2c 10 00 00       	call   801098 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 b3 0f 00 00       	call   801032 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 78 0a 00 00       	call   800b01 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 16 22 80 00       	push   $0x802216
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 ea 0f 00 00       	call   801098 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c9:	e8 33 0a 00 00       	call   800b01 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 78             	imul   $0x78,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
  8000fa:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 de 11 00 00       	call   8012ed <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a7 09 00 00       	call   800ac0 <sys_env_destroy>
  800119:	83 c4 10             	add    $0x10,%esp
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 35 09 00 00       	call   800a83 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 4f 01 00 00       	call   8002e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 da 08 00 00       	call   800a83 <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 d1                	mov    %edx,%ecx
  8001da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001f3:	72 05                	jb     8001fa <printnum+0x35>
  8001f5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001f8:	77 3e                	ja     800238 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	53                   	push   %ebx
  800204:	50                   	push   %eax
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 07 1d 00 00       	call   801f20 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 13                	jmp    80023f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	7f ed                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 f9 1d 00 00       	call   802050 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 33 22 80 00 	movsbl 0x802233(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff d7                	call   *%edi
  800264:	83 c4 10             	add    $0x10,%esp
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	50                   	push   %eax
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 05 00 00 00       	call   8002e3 <vprintfmt>
	va_end(ap);
  8002de:	83 c4 10             	add    $0x10,%esp
}
  8002e1:	c9                   	leave  
  8002e2:	c3                   	ret    

008002e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 2c             	sub    $0x2c,%esp
  8002ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 8d 03 00 00    	je     80068c <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	53                   	push   %ebx
  800303:	50                   	push   %eax
  800304:	ff d6                	call   *%esi
  800306:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	83 c7 01             	add    $0x1,%edi
  80030c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	75 e2                	jne    8002f7 <vprintfmt+0x14>
  800315:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800319:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800320:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 07                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8d 47 01             	lea    0x1(%edi),%eax
  80033f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800342:	0f b6 07             	movzbl (%edi),%eax
  800345:	0f b6 c8             	movzbl %al,%ecx
  800348:	83 e8 23             	sub    $0x23,%eax
  80034b:	3c 55                	cmp    $0x55,%al
  80034d:	0f 87 1e 03 00 00    	ja     800671 <vprintfmt+0x38e>
  800353:	0f b6 c0             	movzbl %al,%eax
  800356:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d6                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037e:	83 fa 09             	cmp    $0x9,%edx
  800381:	77 38                	ja     8003bb <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 48 04             	lea    0x4(%eax),%ecx
  80038e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800399:	eb 26                	jmp    8003c1 <vprintfmt+0xde>
  80039b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80039e:	89 c8                	mov    %ecx,%eax
  8003a0:	c1 f8 1f             	sar    $0x1f,%eax
  8003a3:	f7 d0                	not    %eax
  8003a5:	21 c1                	and    %eax,%ecx
  8003a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ad:	eb 8d                	jmp    80033c <vprintfmt+0x59>
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b9:	eb 81                	jmp    80033c <vprintfmt+0x59>
  8003bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003be:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c5:	0f 89 71 ff ff ff    	jns    80033c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d8:	e9 5f ff ff ff       	jmp    80033c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e3:	e9 54 ff ff ff       	jmp    80033c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	pushl  (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ff:	e9 05 ff ff ff       	jmp    800309 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	99                   	cltd   
  800410:	31 d0                	xor    %edx,%eax
  800412:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800414:	83 f8 0f             	cmp    $0xf,%eax
  800417:	7f 0b                	jg     800424 <vprintfmt+0x141>
  800419:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	75 18                	jne    80043c <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800424:	50                   	push   %eax
  800425:	68 4b 22 80 00       	push   $0x80224b
  80042a:	53                   	push   %ebx
  80042b:	56                   	push   %esi
  80042c:	e8 95 fe ff ff       	call   8002c6 <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800437:	e9 cd fe ff ff       	jmp    800309 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043c:	52                   	push   %edx
  80043d:	68 e1 26 80 00       	push   $0x8026e1
  800442:	53                   	push   %ebx
  800443:	56                   	push   %esi
  800444:	e8 7d fe ff ff       	call   8002c6 <printfmt>
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044f:	e9 b5 fe ff ff       	jmp    800309 <vprintfmt+0x26>
  800454:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800457:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
  800468:	85 ff                	test   %edi,%edi
  80046a:	75 05                	jne    800471 <vprintfmt+0x18e>
				p = "(null)";
  80046c:	bf 44 22 80 00       	mov    $0x802244,%edi
			if (width > 0 && padc != '-')
  800471:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800475:	0f 84 91 00 00 00    	je     80050c <vprintfmt+0x229>
  80047b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80047f:	0f 8e 95 00 00 00    	jle    80051a <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	51                   	push   %ecx
  800489:	57                   	push   %edi
  80048a:	e8 85 02 00 00       	call   800714 <strnlen>
  80048f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c5>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	89 c8                	mov    %ecx,%eax
  8004c3:	c1 f8 1f             	sar    $0x1f,%eax
  8004c6:	f7 d0                	not    %eax
  8004c8:	21 c8                	and    %ecx,%eax
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d5:	89 cb                	mov    %ecx,%ebx
  8004d7:	eb 4d                	jmp    800526 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	74 1b                	je     8004fa <vprintfmt+0x217>
  8004df:	0f be c0             	movsbl %al,%eax
  8004e2:	83 e8 20             	sub    $0x20,%eax
  8004e5:	83 f8 5e             	cmp    $0x5e,%eax
  8004e8:	76 10                	jbe    8004fa <vprintfmt+0x217>
					putch('?', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 0d                	jmp    800507 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	52                   	push   %edx
  800501:	ff 55 08             	call   *0x8(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800507:	83 eb 01             	sub    $0x1,%ebx
  80050a:	eb 1a                	jmp    800526 <vprintfmt+0x243>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	eb 0c                	jmp    800526 <vprintfmt+0x243>
  80051a:	89 75 08             	mov    %esi,0x8(%ebp)
  80051d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800520:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800523:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052d:	0f be d0             	movsbl %al,%edx
  800530:	85 d2                	test   %edx,%edx
  800532:	74 23                	je     800557 <vprintfmt+0x274>
  800534:	85 f6                	test   %esi,%esi
  800536:	78 a1                	js     8004d9 <vprintfmt+0x1f6>
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	79 9c                	jns    8004d9 <vprintfmt+0x1f6>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	eb 18                	jmp    80055f <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	53                   	push   %ebx
  80054b:	6a 20                	push   $0x20
  80054d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054f:	83 ef 01             	sub    $0x1,%edi
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb 08                	jmp    80055f <vprintfmt+0x27c>
  800557:	89 df                	mov    %ebx,%edi
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055f:	85 ff                	test   %edi,%edi
  800561:	7f e4                	jg     800547 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800566:	e9 9e fd ff ff       	jmp    800309 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056b:	83 fa 01             	cmp    $0x1,%edx
  80056e:	7e 16                	jle    800586 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 08             	lea    0x8(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 50 04             	mov    0x4(%eax),%edx
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	eb 32                	jmp    8005b8 <vprintfmt+0x2d5>
	else if (lflag)
  800586:	85 d2                	test   %edx,%edx
  800588:	74 18                	je     8005a2 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800598:	89 c1                	mov    %eax,%ecx
  80059a:	c1 f9 1f             	sar    $0x1f,%ecx
  80059d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a0:	eb 16                	jmp    8005b8 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 c1                	mov    %eax,%ecx
  8005b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c7:	79 74                	jns    80063d <vprintfmt+0x35a>
				putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 2d                	push   $0x2d
  8005cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d7:	f7 d8                	neg    %eax
  8005d9:	83 d2 00             	adc    $0x0,%edx
  8005dc:	f7 da                	neg    %edx
  8005de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e6:	eb 55                	jmp    80063d <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 7f fc ff ff       	call   80026f <getuint>
			base = 10;
  8005f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f5:	eb 46                	jmp    80063d <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 70 fc ff ff       	call   80026f <getuint>
			base = 8;
  8005ff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800604:	eb 37                	jmp    80063d <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 30                	push   $0x30
  80060c:	ff d6                	call   *%esi
			putch('x', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 78                	push   $0x78
  800614:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800626:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800629:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062e:	eb 0d                	jmp    80063d <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 37 fc ff ff       	call   80026f <getuint>
			base = 16;
  800638:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800644:	57                   	push   %edi
  800645:	ff 75 e0             	pushl  -0x20(%ebp)
  800648:	51                   	push   %ecx
  800649:	52                   	push   %edx
  80064a:	50                   	push   %eax
  80064b:	89 da                	mov    %ebx,%edx
  80064d:	89 f0                	mov    %esi,%eax
  80064f:	e8 71 fb ff ff       	call   8001c5 <printnum>
			break;
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065a:	e9 aa fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	51                   	push   %ecx
  800664:	ff d6                	call   *%esi
			break;
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066c:	e9 98 fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 25                	push   $0x25
  800677:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 03                	jmp    800681 <vprintfmt+0x39e>
  80067e:	83 ef 01             	sub    $0x1,%edi
  800681:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800685:	75 f7                	jne    80067e <vprintfmt+0x39b>
  800687:	e9 7d fc ff ff       	jmp    800309 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068f:	5b                   	pop    %ebx
  800690:	5e                   	pop    %esi
  800691:	5f                   	pop    %edi
  800692:	5d                   	pop    %ebp
  800693:	c3                   	ret    

00800694 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 18             	sub    $0x18,%esp
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	74 26                	je     8006db <vsnprintf+0x47>
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	7e 22                	jle    8006db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b9:	ff 75 14             	pushl  0x14(%ebp)
  8006bc:	ff 75 10             	pushl  0x10(%ebp)
  8006bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	68 a9 02 80 00       	push   $0x8002a9
  8006c8:	e8 16 fc ff ff       	call   8002e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 05                	jmp    8006e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006eb:	50                   	push   %eax
  8006ec:	ff 75 10             	pushl  0x10(%ebp)
  8006ef:	ff 75 0c             	pushl  0xc(%ebp)
  8006f2:	ff 75 08             	pushl  0x8(%ebp)
  8006f5:	e8 9a ff ff ff       	call   800694 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	eb 03                	jmp    80070c <strlen+0x10>
		n++;
  800709:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800710:	75 f7                	jne    800709 <strlen+0xd>
		n++;
	return n;
}
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	eb 03                	jmp    800727 <strnlen+0x13>
		n++;
  800724:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	39 c2                	cmp    %eax,%edx
  800729:	74 08                	je     800733 <strnlen+0x1f>
  80072b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80072f:	75 f3                	jne    800724 <strnlen+0x10>
  800731:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	53                   	push   %ebx
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073f:	89 c2                	mov    %eax,%edx
  800741:	83 c2 01             	add    $0x1,%edx
  800744:	83 c1 01             	add    $0x1,%ecx
  800747:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074e:	84 db                	test   %bl,%bl
  800750:	75 ef                	jne    800741 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800752:	5b                   	pop    %ebx
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075c:	53                   	push   %ebx
  80075d:	e8 9a ff ff ff       	call   8006fc <strlen>
  800762:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	01 d8                	add    %ebx,%eax
  80076a:	50                   	push   %eax
  80076b:	e8 c5 ff ff ff       	call   800735 <strcpy>
	return dst;
}
  800770:	89 d8                	mov    %ebx,%eax
  800772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	89 f3                	mov    %esi,%ebx
  800784:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	89 f2                	mov    %esi,%edx
  800789:	eb 0f                	jmp    80079a <strncpy+0x23>
		*dst++ = *src;
  80078b:	83 c2 01             	add    $0x1,%edx
  80078e:	0f b6 01             	movzbl (%ecx),%eax
  800791:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800794:	80 39 01             	cmpb   $0x1,(%ecx)
  800797:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079a:	39 da                	cmp    %ebx,%edx
  80079c:	75 ed                	jne    80078b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	74 21                	je     8007d9 <strlcpy+0x35>
  8007b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bc:	89 f2                	mov    %esi,%edx
  8007be:	eb 09                	jmp    8007c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c0:	83 c2 01             	add    $0x1,%edx
  8007c3:	83 c1 01             	add    $0x1,%ecx
  8007c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c9:	39 c2                	cmp    %eax,%edx
  8007cb:	74 09                	je     8007d6 <strlcpy+0x32>
  8007cd:	0f b6 19             	movzbl (%ecx),%ebx
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ec                	jne    8007c0 <strlcpy+0x1c>
  8007d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d9:	29 f0                	sub    %esi,%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e8:	eb 06                	jmp    8007f0 <strcmp+0x11>
		p++, q++;
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	84 c0                	test   %al,%al
  8007f5:	74 04                	je     8007fb <strcmp+0x1c>
  8007f7:	3a 02                	cmp    (%edx),%al
  8007f9:	74 ef                	je     8007ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 c0             	movzbl %al,%eax
  8007fe:	0f b6 12             	movzbl (%edx),%edx
  800801:	29 d0                	sub    %edx,%eax
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800814:	eb 06                	jmp    80081c <strncmp+0x17>
		n--, p++, q++;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	74 15                	je     800835 <strncmp+0x30>
  800820:	0f b6 08             	movzbl (%eax),%ecx
  800823:	84 c9                	test   %cl,%cl
  800825:	74 04                	je     80082b <strncmp+0x26>
  800827:	3a 0a                	cmp    (%edx),%cl
  800829:	74 eb                	je     800816 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 12             	movzbl (%edx),%edx
  800831:	29 d0                	sub    %edx,%eax
  800833:	eb 05                	jmp    80083a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800847:	eb 07                	jmp    800850 <strchr+0x13>
		if (*s == c)
  800849:	38 ca                	cmp    %cl,%dl
  80084b:	74 0f                	je     80085c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
  800853:	84 d2                	test   %dl,%dl
  800855:	75 f2                	jne    800849 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800868:	eb 03                	jmp    80086d <strfind+0xf>
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800870:	84 d2                	test   %dl,%dl
  800872:	74 04                	je     800878 <strfind+0x1a>
  800874:	38 ca                	cmp    %cl,%dl
  800876:	75 f2                	jne    80086a <strfind+0xc>
			break;
	return (char *) s;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	57                   	push   %edi
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 7d 08             	mov    0x8(%ebp),%edi
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800886:	85 c9                	test   %ecx,%ecx
  800888:	74 36                	je     8008c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800890:	75 28                	jne    8008ba <memset+0x40>
  800892:	f6 c1 03             	test   $0x3,%cl
  800895:	75 23                	jne    8008ba <memset+0x40>
		c &= 0xFF;
  800897:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	89 d3                	mov    %edx,%ebx
  80089d:	c1 e3 08             	shl    $0x8,%ebx
  8008a0:	89 d6                	mov    %edx,%esi
  8008a2:	c1 e6 18             	shl    $0x18,%esi
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	c1 e0 10             	shl    $0x10,%eax
  8008aa:	09 f0                	or     %esi,%eax
  8008ac:	09 c2                	or     %eax,%edx
  8008ae:	89 d0                	mov    %edx,%eax
  8008b0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b5:	fc                   	cld    
  8008b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b8:	eb 06                	jmp    8008c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bd:	fc                   	cld    
  8008be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c0:	89 f8                	mov    %edi,%eax
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d5:	39 c6                	cmp    %eax,%esi
  8008d7:	73 35                	jae    80090e <memmove+0x47>
  8008d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dc:	39 d0                	cmp    %edx,%eax
  8008de:	73 2e                	jae    80090e <memmove+0x47>
		s += n;
		d += n;
  8008e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008e3:	89 d6                	mov    %edx,%esi
  8008e5:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ed:	75 13                	jne    800902 <memmove+0x3b>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 0e                	jne    800902 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f4:	83 ef 04             	sub    $0x4,%edi
  8008f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008fd:	fd                   	std    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 09                	jmp    80090b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800902:	83 ef 01             	sub    $0x1,%edi
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 1d                	jmp    80092b <memmove+0x64>
  80090e:	89 f2                	mov    %esi,%edx
  800910:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	f6 c2 03             	test   $0x3,%dl
  800915:	75 0f                	jne    800926 <memmove+0x5f>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 0a                	jne    800926 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091f:	89 c7                	mov    %eax,%edi
  800921:	fc                   	cld    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 05                	jmp    80092b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800932:	ff 75 10             	pushl  0x10(%ebp)
  800935:	ff 75 0c             	pushl  0xc(%ebp)
  800938:	ff 75 08             	pushl  0x8(%ebp)
  80093b:	e8 87 ff ff ff       	call   8008c7 <memmove>
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 c6                	mov    %eax,%esi
  80094f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	eb 1a                	jmp    80096e <memcmp+0x2c>
		if (*s1 != *s2)
  800954:	0f b6 08             	movzbl (%eax),%ecx
  800957:	0f b6 1a             	movzbl (%edx),%ebx
  80095a:	38 d9                	cmp    %bl,%cl
  80095c:	74 0a                	je     800968 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095e:	0f b6 c1             	movzbl %cl,%eax
  800961:	0f b6 db             	movzbl %bl,%ebx
  800964:	29 d8                	sub    %ebx,%eax
  800966:	eb 0f                	jmp    800977 <memcmp+0x35>
		s1++, s2++;
  800968:	83 c0 01             	add    $0x1,%eax
  80096b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	39 f0                	cmp    %esi,%eax
  800970:	75 e2                	jne    800954 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800984:	89 c2                	mov    %eax,%edx
  800986:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800989:	eb 07                	jmp    800992 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	38 08                	cmp    %cl,(%eax)
  80098d:	74 07                	je     800996 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	39 d0                	cmp    %edx,%eax
  800994:	72 f5                	jb     80098b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	eb 03                	jmp    8009a9 <strtol+0x11>
		s++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	3c 09                	cmp    $0x9,%al
  8009ae:	74 f6                	je     8009a6 <strtol+0xe>
  8009b0:	3c 20                	cmp    $0x20,%al
  8009b2:	74 f2                	je     8009a6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b4:	3c 2b                	cmp    $0x2b,%al
  8009b6:	75 0a                	jne    8009c2 <strtol+0x2a>
		s++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c0:	eb 10                	jmp    8009d2 <strtol+0x3a>
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c7:	3c 2d                	cmp    $0x2d,%al
  8009c9:	75 07                	jne    8009d2 <strtol+0x3a>
		s++, neg = 1;
  8009cb:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009ce:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d2:	85 db                	test   %ebx,%ebx
  8009d4:	0f 94 c0             	sete   %al
  8009d7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009dd:	75 19                	jne    8009f8 <strtol+0x60>
  8009df:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e2:	75 14                	jne    8009f8 <strtol+0x60>
  8009e4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e8:	0f 85 8a 00 00 00    	jne    800a78 <strtol+0xe0>
		s += 2, base = 16;
  8009ee:	83 c1 02             	add    $0x2,%ecx
  8009f1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f6:	eb 16                	jmp    800a0e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f8:	84 c0                	test   %al,%al
  8009fa:	74 12                	je     800a0e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	75 08                	jne    800a0e <strtol+0x76>
		s++, base = 8;
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a16:	0f b6 11             	movzbl (%ecx),%edx
  800a19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 09             	cmp    $0x9,%bl
  800a21:	77 08                	ja     800a2b <strtol+0x93>
			dig = *s - '0';
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 30             	sub    $0x30,%edx
  800a29:	eb 22                	jmp    800a4d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 19             	cmp    $0x19,%bl
  800a33:	77 08                	ja     800a3d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 57             	sub    $0x57,%edx
  800a3b:	eb 10                	jmp    800a4d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 19             	cmp    $0x19,%bl
  800a45:	77 16                	ja     800a5d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a47:	0f be d2             	movsbl %dl,%edx
  800a4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a50:	7d 0f                	jge    800a61 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5b:	eb b9                	jmp    800a16 <strtol+0x7e>
  800a5d:	89 c2                	mov    %eax,%edx
  800a5f:	eb 02                	jmp    800a63 <strtol+0xcb>
  800a61:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a67:	74 05                	je     800a6e <strtol+0xd6>
		*endptr = (char *) s;
  800a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a6e:	85 ff                	test   %edi,%edi
  800a70:	74 0c                	je     800a7e <strtol+0xe6>
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	f7 d8                	neg    %eax
  800a76:	eb 06                	jmp    800a7e <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	84 c0                	test   %al,%al
  800a7a:	75 8a                	jne    800a06 <strtol+0x6e>
  800a7c:	eb 90                	jmp    800a0e <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cgetc>:

int
sys_cgetc(void)
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
  800aac:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab1:	89 d1                	mov    %edx,%ecx
  800ab3:	89 d3                	mov    %edx,%ebx
  800ab5:	89 d7                	mov    %edx,%edi
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 cb                	mov    %ecx,%ebx
  800ad8:	89 cf                	mov    %ecx,%edi
  800ada:	89 ce                	mov    %ecx,%esi
  800adc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	7e 17                	jle    800af9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	50                   	push   %eax
  800ae6:	6a 03                	push   $0x3
  800ae8:	68 5f 25 80 00       	push   $0x80255f
  800aed:	6a 23                	push   $0x23
  800aef:	68 7c 25 80 00       	push   $0x80257c
  800af4:	e8 0d 13 00 00       	call   801e06 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_yield>:

void
sys_yield(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	be 00 00 00 00       	mov    $0x0,%esi
  800b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	89 f7                	mov    %esi,%edi
  800b5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 04                	push   $0x4
  800b69:	68 5f 25 80 00       	push   $0x80255f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 7c 25 80 00       	push   $0x80257c
  800b75:	e8 8c 12 00 00       	call   801e06 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 05                	push   $0x5
  800bab:	68 5f 25 80 00       	push   $0x80255f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 7c 25 80 00       	push   $0x80257c
  800bb7:	e8 4a 12 00 00       	call   801e06 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 06                	push   $0x6
  800bed:	68 5f 25 80 00       	push   $0x80255f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 7c 25 80 00       	push   $0x80257c
  800bf9:	e8 08 12 00 00       	call   801e06 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 08                	push   $0x8
  800c2f:	68 5f 25 80 00       	push   $0x80255f
  800c34:	6a 23                	push   $0x23
  800c36:	68 7c 25 80 00       	push   $0x80257c
  800c3b:	e8 c6 11 00 00       	call   801e06 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 09                	push   $0x9
  800c71:	68 5f 25 80 00       	push   $0x80255f
  800c76:	6a 23                	push   $0x23
  800c78:	68 7c 25 80 00       	push   $0x80257c
  800c7d:	e8 84 11 00 00       	call   801e06 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 0a                	push   $0xa
  800cb3:	68 5f 25 80 00       	push   $0x80255f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 7c 25 80 00       	push   $0x80257c
  800cbf:	e8 42 11 00 00       	call   801e06 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	be 00 00 00 00       	mov    $0x0,%esi
  800cd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 cb                	mov    %ecx,%ebx
  800d07:	89 cf                	mov    %ecx,%edi
  800d09:	89 ce                	mov    %ecx,%esi
  800d0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 0d                	push   $0xd
  800d17:	68 5f 25 80 00       	push   $0x80255f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 7c 25 80 00       	push   $0x80257c
  800d23:	e8 de 10 00 00       	call   801e06 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_gettime>:

int sys_gettime(void)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d40:	89 d1                	mov    %edx,%ecx
  800d42:	89 d3                	mov    %edx,%ebx
  800d44:	89 d7                	mov    %edx,%edi
  800d46:	89 d6                	mov    %edx,%esi
  800d48:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	53                   	push   %ebx
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800d59:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d5b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d5f:	74 2e                	je     800d8f <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	c1 ea 16             	shr    $0x16,%edx
  800d66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d6d:	f6 c2 01             	test   $0x1,%dl
  800d70:	74 1d                	je     800d8f <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	c1 ea 0c             	shr    $0xc,%edx
  800d77:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800d7e:	f6 c1 01             	test   $0x1,%cl
  800d81:	74 0c                	je     800d8f <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800d83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d8a:	f6 c6 08             	test   $0x8,%dh
  800d8d:	75 14                	jne    800da3 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 8a 25 80 00       	push   $0x80258a
  800d97:	6a 28                	push   $0x28
  800d99:	68 9c 25 80 00       	push   $0x80259c
  800d9e:	e8 63 10 00 00       	call   801e06 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800da3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da8:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	6a 07                	push   $0x7
  800daf:	68 00 f0 7f 00       	push   $0x7ff000
  800db4:	6a 00                	push   $0x0
  800db6:	e8 84 fd ff ff       	call   800b3f <sys_page_alloc>
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	79 14                	jns    800dd6 <pgfault+0x87>
		panic("sys_page_alloc");
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	68 a7 25 80 00       	push   $0x8025a7
  800dca:	6a 2c                	push   $0x2c
  800dcc:	68 9c 25 80 00       	push   $0x80259c
  800dd1:	e8 30 10 00 00       	call   801e06 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	68 00 10 00 00       	push   $0x1000
  800dde:	53                   	push   %ebx
  800ddf:	68 00 f0 7f 00       	push   $0x7ff000
  800de4:	e8 46 fb ff ff       	call   80092f <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800de9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df0:	53                   	push   %ebx
  800df1:	6a 00                	push   $0x0
  800df3:	68 00 f0 7f 00       	push   $0x7ff000
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 83 fd ff ff       	call   800b82 <sys_page_map>
  800dff:	83 c4 20             	add    $0x20,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 14                	jns    800e1a <pgfault+0xcb>
		panic("sys_page_map");
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	68 b6 25 80 00       	push   $0x8025b6
  800e0e:	6a 2f                	push   $0x2f
  800e10:	68 9c 25 80 00       	push   $0x80259c
  800e15:	e8 ec 0f 00 00       	call   801e06 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	6a 00                	push   $0x0
  800e24:	e8 9b fd ff ff       	call   800bc4 <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	79 14                	jns    800e44 <pgfault+0xf5>
		panic("sys_page_unmap");
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	68 c3 25 80 00       	push   $0x8025c3
  800e38:	6a 31                	push   $0x31
  800e3a:	68 9c 25 80 00       	push   $0x80259c
  800e3f:	e8 c2 0f 00 00       	call   801e06 <_panic>
	return;
}
  800e44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800e52:	68 4f 0d 80 00       	push   $0x800d4f
  800e57:	e8 f0 0f 00 00       	call   801e4c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e5c:	b8 07 00 00 00       	mov    $0x7,%eax
  800e61:	cd 30                	int    $0x30
  800e63:	89 c7                	mov    %eax,%edi
  800e65:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	75 21                	jne    800e90 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e6f:	e8 8d fc ff ff       	call   800b01 <sys_getenvid>
  800e74:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e79:	6b c0 78             	imul   $0x78,%eax,%eax
  800e7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e81:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	e9 80 01 00 00       	jmp    801010 <fork+0x1c7>
	}
	if (envid < 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	79 12                	jns    800ea6 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800e94:	50                   	push   %eax
  800e95:	68 d2 25 80 00       	push   $0x8025d2
  800e9a:	6a 70                	push   $0x70
  800e9c:	68 9c 25 80 00       	push   $0x80259c
  800ea1:	e8 60 0f 00 00       	call   801e06 <_panic>
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800eab:	89 d8                	mov    %ebx,%eax
  800ead:	c1 e8 16             	shr    $0x16,%eax
  800eb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb7:	a8 01                	test   $0x1,%al
  800eb9:	0f 84 de 00 00 00    	je     800f9d <fork+0x154>
  800ebf:	89 de                	mov    %ebx,%esi
  800ec1:	c1 ee 0c             	shr    $0xc,%esi
  800ec4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ecb:	a8 01                	test   $0x1,%al
  800ecd:	0f 84 ca 00 00 00    	je     800f9d <fork+0x154>
  800ed3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eda:	a8 04                	test   $0x4,%al
  800edc:	0f 84 bb 00 00 00    	je     800f9d <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800ee2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800ee9:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800eec:	f6 c4 04             	test   $0x4,%ah
  800eef:	74 34                	je     800f25 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef9:	50                   	push   %eax
  800efa:	56                   	push   %esi
  800efb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efe:	56                   	push   %esi
  800eff:	6a 00                	push   $0x0
  800f01:	e8 7c fc ff ff       	call   800b82 <sys_page_map>
  800f06:	83 c4 20             	add    $0x20,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	0f 84 8c 00 00 00    	je     800f9d <fork+0x154>
        	panic("duppage share");
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	68 e2 25 80 00       	push   $0x8025e2
  800f19:	6a 48                	push   $0x48
  800f1b:	68 9c 25 80 00       	push   $0x80259c
  800f20:	e8 e1 0e 00 00       	call   801e06 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f25:	a9 02 08 00 00       	test   $0x802,%eax
  800f2a:	74 5d                	je     800f89 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	68 05 08 00 00       	push   $0x805
  800f34:	56                   	push   %esi
  800f35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f38:	56                   	push   %esi
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 42 fc ff ff       	call   800b82 <sys_page_map>
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	79 14                	jns    800f5b <fork+0x112>
			panic("error");
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	68 60 22 80 00       	push   $0x802260
  800f4f:	6a 4b                	push   $0x4b
  800f51:	68 9c 25 80 00       	push   $0x80259c
  800f56:	e8 ab 0e 00 00       	call   801e06 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	68 05 08 00 00       	push   $0x805
  800f63:	56                   	push   %esi
  800f64:	6a 00                	push   $0x0
  800f66:	56                   	push   %esi
  800f67:	6a 00                	push   $0x0
  800f69:	e8 14 fc ff ff       	call   800b82 <sys_page_map>
  800f6e:	83 c4 20             	add    $0x20,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 28                	jns    800f9d <fork+0x154>
			panic("error");
  800f75:	83 ec 04             	sub    $0x4,%esp
  800f78:	68 60 22 80 00       	push   $0x802260
  800f7d:	6a 4d                	push   $0x4d
  800f7f:	68 9c 25 80 00       	push   $0x80259c
  800f84:	e8 7d 0e 00 00       	call   801e06 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	6a 05                	push   $0x5
  800f8e:	56                   	push   %esi
  800f8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f92:	56                   	push   %esi
  800f93:	6a 00                	push   $0x0
  800f95:	e8 e8 fb ff ff       	call   800b82 <sys_page_map>
  800f9a:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f9d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa3:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  800fa9:	0f 85 fc fe ff ff    	jne    800eab <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	6a 07                	push   $0x7
  800fb4:	68 00 f0 7f ee       	push   $0xee7ff000
  800fb9:	57                   	push   %edi
  800fba:	e8 80 fb ff ff       	call   800b3f <sys_page_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 14                	jns    800fda <fork+0x191>
		panic("1");
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 f0 25 80 00       	push   $0x8025f0
  800fce:	6a 78                	push   $0x78
  800fd0:	68 9c 25 80 00       	push   $0x80259c
  800fd5:	e8 2c 0e 00 00       	call   801e06 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	68 bb 1e 80 00       	push   $0x801ebb
  800fe2:	57                   	push   %edi
  800fe3:	e8 a2 fc ff ff       	call   800c8a <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	6a 02                	push   $0x2
  800fed:	57                   	push   %edi
  800fee:	e8 13 fc ff ff       	call   800c06 <sys_env_set_status>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	79 14                	jns    80100e <fork+0x1c5>
		panic("sys_env_set_status");
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	68 f2 25 80 00       	push   $0x8025f2
  801002:	6a 7d                	push   $0x7d
  801004:	68 9c 25 80 00       	push   $0x80259c
  801009:	e8 f8 0d 00 00       	call   801e06 <_panic>

	return envid;
  80100e:	89 f8                	mov    %edi,%eax
}
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sfork>:

// Challenge!
int
sfork(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80101e:	68 05 26 80 00       	push   $0x802605
  801023:	68 86 00 00 00       	push   $0x86
  801028:	68 9c 25 80 00       	push   $0x80259c
  80102d:	e8 d4 0d 00 00       	call   801e06 <_panic>

00801032 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
  801037:	8b 75 08             	mov    0x8(%ebp),%esi
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801040:	85 f6                	test   %esi,%esi
  801042:	74 06                	je     80104a <ipc_recv+0x18>
  801044:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80104a:	85 db                	test   %ebx,%ebx
  80104c:	74 06                	je     801054 <ipc_recv+0x22>
  80104e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801054:	83 f8 01             	cmp    $0x1,%eax
  801057:	19 d2                	sbb    %edx,%edx
  801059:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	e8 8b fc ff ff       	call   800cef <sys_ipc_recv>
  801064:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 d2                	test   %edx,%edx
  80106b:	75 24                	jne    801091 <ipc_recv+0x5f>
	if (from_env_store)
  80106d:	85 f6                	test   %esi,%esi
  80106f:	74 0a                	je     80107b <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801071:	a1 04 40 80 00       	mov    0x804004,%eax
  801076:	8b 40 70             	mov    0x70(%eax),%eax
  801079:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80107b:	85 db                	test   %ebx,%ebx
  80107d:	74 0a                	je     801089 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  80107f:	a1 04 40 80 00       	mov    0x804004,%eax
  801084:	8b 40 74             	mov    0x74(%eax),%eax
  801087:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801089:	a1 04 40 80 00       	mov    0x804004,%eax
  80108e:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  8010aa:	83 fb 01             	cmp    $0x1,%ebx
  8010ad:	19 c0                	sbb    %eax,%eax
  8010af:	09 c3                	or     %eax,%ebx
  8010b1:	eb 1c                	jmp    8010cf <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  8010b3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010b6:	74 12                	je     8010ca <ipc_send+0x32>
  8010b8:	50                   	push   %eax
  8010b9:	68 1b 26 80 00       	push   $0x80261b
  8010be:	6a 36                	push   $0x36
  8010c0:	68 32 26 80 00       	push   $0x802632
  8010c5:	e8 3c 0d 00 00       	call   801e06 <_panic>
		sys_yield();
  8010ca:	e8 51 fa ff ff       	call   800b20 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8010cf:	ff 75 14             	pushl  0x14(%ebp)
  8010d2:	53                   	push   %ebx
  8010d3:	56                   	push   %esi
  8010d4:	57                   	push   %edi
  8010d5:	e8 f2 fb ff ff       	call   800ccc <sys_ipc_try_send>
		if (ret == 0) break;
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	75 d2                	jne    8010b3 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010f4:	6b d0 78             	imul   $0x78,%eax,%edx
  8010f7:	83 c2 50             	add    $0x50,%edx
  8010fa:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801100:	39 ca                	cmp    %ecx,%edx
  801102:	75 0d                	jne    801111 <ipc_find_env+0x28>
			return envs[i].env_id;
  801104:	6b c0 78             	imul   $0x78,%eax,%eax
  801107:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80110c:	8b 40 08             	mov    0x8(%eax),%eax
  80110f:	eb 0e                	jmp    80111f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801111:	83 c0 01             	add    $0x1,%eax
  801114:	3d 00 04 00 00       	cmp    $0x400,%eax
  801119:	75 d9                	jne    8010f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80111b:	66 b8 00 00          	mov    $0x0,%ax
}
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	05 00 00 00 30       	add    $0x30000000,%eax
  80112c:	c1 e8 0c             	shr    $0xc,%eax
}
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80113c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801141:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801153:	89 c2                	mov    %eax,%edx
  801155:	c1 ea 16             	shr    $0x16,%edx
  801158:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 11                	je     801175 <fd_alloc+0x2d>
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 ea 0c             	shr    $0xc,%edx
  801169:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801170:	f6 c2 01             	test   $0x1,%dl
  801173:	75 09                	jne    80117e <fd_alloc+0x36>
			*fd_store = fd;
  801175:	89 01                	mov    %eax,(%ecx)
			return 0;
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
  80117c:	eb 17                	jmp    801195 <fd_alloc+0x4d>
  80117e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801183:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801188:	75 c9                	jne    801153 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801190:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80119d:	83 f8 1f             	cmp    $0x1f,%eax
  8011a0:	77 36                	ja     8011d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a2:	c1 e0 0c             	shl    $0xc,%eax
  8011a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	c1 ea 16             	shr    $0x16,%edx
  8011af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b6:	f6 c2 01             	test   $0x1,%dl
  8011b9:	74 24                	je     8011df <fd_lookup+0x48>
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	c1 ea 0c             	shr    $0xc,%edx
  8011c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	74 1a                	je     8011e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d6:	eb 13                	jmp    8011eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dd:	eb 0c                	jmp    8011eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb 05                	jmp    8011eb <fd_lookup+0x54>
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f6:	ba b8 26 80 00       	mov    $0x8026b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011fb:	eb 13                	jmp    801210 <dev_lookup+0x23>
  8011fd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801200:	39 08                	cmp    %ecx,(%eax)
  801202:	75 0c                	jne    801210 <dev_lookup+0x23>
			*dev = devtab[i];
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	89 01                	mov    %eax,(%ecx)
			return 0;
  801209:	b8 00 00 00 00       	mov    $0x0,%eax
  80120e:	eb 2e                	jmp    80123e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801210:	8b 02                	mov    (%edx),%eax
  801212:	85 c0                	test   %eax,%eax
  801214:	75 e7                	jne    8011fd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801216:	a1 04 40 80 00       	mov    0x804004,%eax
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	51                   	push   %ecx
  801222:	50                   	push   %eax
  801223:	68 3c 26 80 00       	push   $0x80263c
  801228:	e8 84 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  80122d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801230:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	83 ec 10             	sub    $0x10,%esp
  801248:	8b 75 08             	mov    0x8(%ebp),%esi
  80124b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80124e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801251:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801252:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801258:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125b:	50                   	push   %eax
  80125c:	e8 36 ff ff ff       	call   801197 <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 05                	js     80126d <fd_close+0x2d>
	    || fd != fd2)
  801268:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80126b:	74 0b                	je     801278 <fd_close+0x38>
		return (must_exist ? r : 0);
  80126d:	80 fb 01             	cmp    $0x1,%bl
  801270:	19 d2                	sbb    %edx,%edx
  801272:	f7 d2                	not    %edx
  801274:	21 d0                	and    %edx,%eax
  801276:	eb 41                	jmp    8012b9 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	ff 36                	pushl  (%esi)
  801281:	e8 67 ff ff ff       	call   8011ed <dev_lookup>
  801286:	89 c3                	mov    %eax,%ebx
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 1a                	js     8012a9 <fd_close+0x69>
		if (dev->dev_close)
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80129a:	85 c0                	test   %eax,%eax
  80129c:	74 0b                	je     8012a9 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80129e:	83 ec 0c             	sub    $0xc,%esp
  8012a1:	56                   	push   %esi
  8012a2:	ff d0                	call   *%eax
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	56                   	push   %esi
  8012ad:	6a 00                	push   $0x0
  8012af:	e8 10 f9 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	89 d8                	mov    %ebx,%eax
}
  8012b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 c5 fe ff ff       	call   801197 <fd_lookup>
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	85 d2                	test   %edx,%edx
  8012d9:	78 10                	js     8012eb <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	6a 01                	push   $0x1
  8012e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e3:	e8 58 ff ff ff       	call   801240 <fd_close>
  8012e8:	83 c4 10             	add    $0x10,%esp
}
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <close_all>:

void
close_all(void)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	53                   	push   %ebx
  8012fd:	e8 be ff ff ff       	call   8012c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801302:	83 c3 01             	add    $0x1,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	83 fb 20             	cmp    $0x20,%ebx
  80130b:	75 ec                	jne    8012f9 <close_all+0xc>
		close(i);
}
  80130d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	57                   	push   %edi
  801316:	56                   	push   %esi
  801317:	53                   	push   %ebx
  801318:	83 ec 2c             	sub    $0x2c,%esp
  80131b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80131e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 6d fe ff ff       	call   801197 <fd_lookup>
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 d2                	test   %edx,%edx
  801331:	0f 88 c1 00 00 00    	js     8013f8 <dup+0xe6>
		return r;
	close(newfdnum);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	56                   	push   %esi
  80133b:	e8 80 ff ff ff       	call   8012c0 <close>

	newfd = INDEX2FD(newfdnum);
  801340:	89 f3                	mov    %esi,%ebx
  801342:	c1 e3 0c             	shl    $0xc,%ebx
  801345:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80134b:	83 c4 04             	add    $0x4,%esp
  80134e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801351:	e8 db fd ff ff       	call   801131 <fd2data>
  801356:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801358:	89 1c 24             	mov    %ebx,(%esp)
  80135b:	e8 d1 fd ff ff       	call   801131 <fd2data>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801366:	89 f8                	mov    %edi,%eax
  801368:	c1 e8 16             	shr    $0x16,%eax
  80136b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801372:	a8 01                	test   $0x1,%al
  801374:	74 37                	je     8013ad <dup+0x9b>
  801376:	89 f8                	mov    %edi,%eax
  801378:	c1 e8 0c             	shr    $0xc,%eax
  80137b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801382:	f6 c2 01             	test   $0x1,%dl
  801385:	74 26                	je     8013ad <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801387:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	25 07 0e 00 00       	and    $0xe07,%eax
  801396:	50                   	push   %eax
  801397:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139a:	6a 00                	push   $0x0
  80139c:	57                   	push   %edi
  80139d:	6a 00                	push   $0x0
  80139f:	e8 de f7 ff ff       	call   800b82 <sys_page_map>
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	83 c4 20             	add    $0x20,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 2e                	js     8013db <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013b0:	89 d0                	mov    %edx,%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
  8013b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c4:	50                   	push   %eax
  8013c5:	53                   	push   %ebx
  8013c6:	6a 00                	push   $0x0
  8013c8:	52                   	push   %edx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 b2 f7 ff ff       	call   800b82 <sys_page_map>
  8013d0:	89 c7                	mov    %eax,%edi
  8013d2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013d5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d7:	85 ff                	test   %edi,%edi
  8013d9:	79 1d                	jns    8013f8 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 de f7 ff ff       	call   800bc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013e6:	83 c4 08             	add    $0x8,%esp
  8013e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 d1 f7 ff ff       	call   800bc4 <sys_page_unmap>
	return r;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	89 f8                	mov    %edi,%eax
}
  8013f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5f                   	pop    %edi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	53                   	push   %ebx
  80140f:	e8 83 fd ff ff       	call   801197 <fd_lookup>
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	89 c2                	mov    %eax,%edx
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 6d                	js     80148a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801427:	ff 30                	pushl  (%eax)
  801429:	e8 bf fd ff ff       	call   8011ed <dev_lookup>
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 4c                	js     801481 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801435:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801438:	8b 42 08             	mov    0x8(%edx),%eax
  80143b:	83 e0 03             	and    $0x3,%eax
  80143e:	83 f8 01             	cmp    $0x1,%eax
  801441:	75 21                	jne    801464 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801443:	a1 04 40 80 00       	mov    0x804004,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	53                   	push   %ebx
  80144f:	50                   	push   %eax
  801450:	68 7d 26 80 00       	push   $0x80267d
  801455:	e8 57 ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801462:	eb 26                	jmp    80148a <read+0x8a>
	}
	if (!dev->dev_read)
  801464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801467:	8b 40 08             	mov    0x8(%eax),%eax
  80146a:	85 c0                	test   %eax,%eax
  80146c:	74 17                	je     801485 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	ff 75 10             	pushl  0x10(%ebp)
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	52                   	push   %edx
  801478:	ff d0                	call   *%eax
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 09                	jmp    80148a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	89 c2                	mov    %eax,%edx
  801483:	eb 05                	jmp    80148a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801485:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	57                   	push   %edi
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80149d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a5:	eb 21                	jmp    8014c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	29 d8                	sub    %ebx,%eax
  8014ae:	50                   	push   %eax
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	03 45 0c             	add    0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	57                   	push   %edi
  8014b6:	e8 45 ff ff ff       	call   801400 <read>
		if (m < 0)
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 0c                	js     8014ce <readn+0x3d>
			return m;
		if (m == 0)
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	74 06                	je     8014cc <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c6:	01 c3                	add    %eax,%ebx
  8014c8:	39 f3                	cmp    %esi,%ebx
  8014ca:	72 db                	jb     8014a7 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014cc:	89 d8                	mov    %ebx,%eax
}
  8014ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 14             	sub    $0x14,%esp
  8014dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	53                   	push   %ebx
  8014e5:	e8 ad fc ff ff       	call   801197 <fd_lookup>
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 68                	js     80155b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	ff 30                	pushl  (%eax)
  8014ff:	e8 e9 fc ff ff       	call   8011ed <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 47                	js     801552 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801512:	75 21                	jne    801535 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801514:	a1 04 40 80 00       	mov    0x804004,%eax
  801519:	8b 40 48             	mov    0x48(%eax),%eax
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	53                   	push   %ebx
  801520:	50                   	push   %eax
  801521:	68 99 26 80 00       	push   $0x802699
  801526:	e8 86 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801533:	eb 26                	jmp    80155b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801535:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801538:	8b 52 0c             	mov    0xc(%edx),%edx
  80153b:	85 d2                	test   %edx,%edx
  80153d:	74 17                	je     801556 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	ff 75 10             	pushl  0x10(%ebp)
  801545:	ff 75 0c             	pushl  0xc(%ebp)
  801548:	50                   	push   %eax
  801549:	ff d2                	call   *%edx
  80154b:	89 c2                	mov    %eax,%edx
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	eb 09                	jmp    80155b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801552:	89 c2                	mov    %eax,%edx
  801554:	eb 05                	jmp    80155b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801556:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80155b:	89 d0                	mov    %edx,%eax
  80155d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <seek>:

int
seek(int fdnum, off_t offset)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801568:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	ff 75 08             	pushl  0x8(%ebp)
  80156f:	e8 23 fc ff ff       	call   801197 <fd_lookup>
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 0e                	js     801589 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80157b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80157e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801581:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801584:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 14             	sub    $0x14,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801595:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	53                   	push   %ebx
  80159a:	e8 f8 fb ff ff       	call   801197 <fd_lookup>
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 65                	js     80160d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b2:	ff 30                	pushl  (%eax)
  8015b4:	e8 34 fc ff ff       	call   8011ed <dev_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 44                	js     801604 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c7:	75 21                	jne    8015ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015c9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	68 5c 26 80 00       	push   $0x80265c
  8015db:	e8 d1 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e8:	eb 23                	jmp    80160d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ed:	8b 52 18             	mov    0x18(%edx),%edx
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	74 14                	je     801608 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	50                   	push   %eax
  8015fb:	ff d2                	call   *%edx
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 09                	jmp    80160d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	89 c2                	mov    %eax,%edx
  801606:	eb 05                	jmp    80160d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801608:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80160d:	89 d0                	mov    %edx,%eax
  80160f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 14             	sub    $0x14,%esp
  80161b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	ff 75 08             	pushl  0x8(%ebp)
  801625:	e8 6d fb ff ff       	call   801197 <fd_lookup>
  80162a:	83 c4 08             	add    $0x8,%esp
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 58                	js     80168b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	ff 30                	pushl  (%eax)
  80163f:	e8 a9 fb ff ff       	call   8011ed <dev_lookup>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 37                	js     801682 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80164b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801652:	74 32                	je     801686 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801654:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801657:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80165e:	00 00 00 
	stat->st_isdir = 0;
  801661:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801668:	00 00 00 
	stat->st_dev = dev;
  80166b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	53                   	push   %ebx
  801675:	ff 75 f0             	pushl  -0x10(%ebp)
  801678:	ff 50 14             	call   *0x14(%eax)
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	eb 09                	jmp    80168b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	89 c2                	mov    %eax,%edx
  801684:	eb 05                	jmp    80168b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801686:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80168b:	89 d0                	mov    %edx,%eax
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	6a 00                	push   $0x0
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 e7 01 00 00       	call   80188b <open>
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 db                	test   %ebx,%ebx
  8016ab:	78 1b                	js     8016c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	53                   	push   %ebx
  8016b4:	e8 5b ff ff ff       	call   801614 <fstat>
  8016b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016bb:	89 1c 24             	mov    %ebx,(%esp)
  8016be:	e8 fd fb ff ff       	call   8012c0 <close>
	return r;
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	89 f0                	mov    %esi,%eax
}
  8016c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
  8016d4:	89 c6                	mov    %eax,%esi
  8016d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016df:	75 12                	jne    8016f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	6a 03                	push   $0x3
  8016e6:	e8 fe f9 ff ff       	call   8010e9 <ipc_find_env>
  8016eb:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016f3:	6a 07                	push   $0x7
  8016f5:	68 00 50 80 00       	push   $0x805000
  8016fa:	56                   	push   %esi
  8016fb:	ff 35 00 40 80 00    	pushl  0x804000
  801701:	e8 92 f9 ff ff       	call   801098 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801706:	83 c4 0c             	add    $0xc,%esp
  801709:	6a 00                	push   $0x0
  80170b:	53                   	push   %ebx
  80170c:	6a 00                	push   $0x0
  80170e:	e8 1f f9 ff ff       	call   801032 <ipc_recv>
}
  801713:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	8b 40 0c             	mov    0xc(%eax),%eax
  801726:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80172b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801733:	ba 00 00 00 00       	mov    $0x0,%edx
  801738:	b8 02 00 00 00       	mov    $0x2,%eax
  80173d:	e8 8d ff ff ff       	call   8016cf <fsipc>
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80174a:	8b 45 08             	mov    0x8(%ebp),%eax
  80174d:	8b 40 0c             	mov    0xc(%eax),%eax
  801750:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801755:	ba 00 00 00 00       	mov    $0x0,%edx
  80175a:	b8 06 00 00 00       	mov    $0x6,%eax
  80175f:	e8 6b ff ff ff       	call   8016cf <fsipc>
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	8b 40 0c             	mov    0xc(%eax),%eax
  801776:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 05 00 00 00       	mov    $0x5,%eax
  801785:	e8 45 ff ff ff       	call   8016cf <fsipc>
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	85 d2                	test   %edx,%edx
  80178e:	78 2c                	js     8017bc <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	68 00 50 80 00       	push   $0x805000
  801798:	53                   	push   %ebx
  801799:	e8 97 ef ff ff       	call   800735 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80179e:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8017ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d0:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8017d6:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8017db:	76 05                	jbe    8017e2 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8017dd:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	68 08 50 80 00       	push   $0x805008
  8017f3:	e8 cf f0 ff ff       	call   8008c7 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801802:	e8 c8 fe ff ff       	call   8016cf <fsipc>
	return write;
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	b8 03 00 00 00       	mov    $0x3,%eax
  80182c:	e8 9e fe ff ff       	call   8016cf <fsipc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 4b                	js     801882 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801837:	39 c6                	cmp    %eax,%esi
  801839:	73 16                	jae    801851 <devfile_read+0x48>
  80183b:	68 c8 26 80 00       	push   $0x8026c8
  801840:	68 cf 26 80 00       	push   $0x8026cf
  801845:	6a 7c                	push   $0x7c
  801847:	68 e4 26 80 00       	push   $0x8026e4
  80184c:	e8 b5 05 00 00       	call   801e06 <_panic>
	assert(r <= PGSIZE);
  801851:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801856:	7e 16                	jle    80186e <devfile_read+0x65>
  801858:	68 ef 26 80 00       	push   $0x8026ef
  80185d:	68 cf 26 80 00       	push   $0x8026cf
  801862:	6a 7d                	push   $0x7d
  801864:	68 e4 26 80 00       	push   $0x8026e4
  801869:	e8 98 05 00 00       	call   801e06 <_panic>
	memmove(buf, &fsipcbuf, r);
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	50                   	push   %eax
  801872:	68 00 50 80 00       	push   $0x805000
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	e8 48 f0 ff ff       	call   8008c7 <memmove>
	return r;
  80187f:	83 c4 10             	add    $0x10,%esp
}
  801882:	89 d8                	mov    %ebx,%eax
  801884:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 20             	sub    $0x20,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801895:	53                   	push   %ebx
  801896:	e8 61 ee ff ff       	call   8006fc <strlen>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a3:	7f 67                	jg     80190c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	e8 97 f8 ff ff       	call   801148 <fd_alloc>
  8018b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 57                	js     801911 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	53                   	push   %ebx
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	e8 6d ee ff ff       	call   800735 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d8:	e8 f2 fd ff ff       	call   8016cf <fsipc>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	79 14                	jns    8018fa <open+0x6f>
		fd_close(fd, 0);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	6a 00                	push   $0x0
  8018eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ee:	e8 4d f9 ff ff       	call   801240 <fd_close>
		return r;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	89 da                	mov    %ebx,%edx
  8018f8:	eb 17                	jmp    801911 <open+0x86>
	}

	return fd2num(fd);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801900:	e8 1c f8 ff ff       	call   801121 <fd2num>
  801905:	89 c2                	mov    %eax,%edx
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	eb 05                	jmp    801911 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80190c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801911:	89 d0                	mov    %edx,%eax
  801913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191e:	ba 00 00 00 00       	mov    $0x0,%edx
  801923:	b8 08 00 00 00       	mov    $0x8,%eax
  801928:	e8 a2 fd ff ff       	call   8016cf <fsipc>
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 08             	pushl  0x8(%ebp)
  80193d:	e8 ef f7 ff ff       	call   801131 <fd2data>
  801942:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801944:	83 c4 08             	add    $0x8,%esp
  801947:	68 fb 26 80 00       	push   $0x8026fb
  80194c:	53                   	push   %ebx
  80194d:	e8 e3 ed ff ff       	call   800735 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801952:	8b 56 04             	mov    0x4(%esi),%edx
  801955:	89 d0                	mov    %edx,%eax
  801957:	2b 06                	sub    (%esi),%eax
  801959:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801966:	00 00 00 
	stat->st_dev = &devpipe;
  801969:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801970:	30 80 00 
	return 0;
}
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801989:	53                   	push   %ebx
  80198a:	6a 00                	push   $0x0
  80198c:	e8 33 f2 ff ff       	call   800bc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801991:	89 1c 24             	mov    %ebx,(%esp)
  801994:	e8 98 f7 ff ff       	call   801131 <fd2data>
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	50                   	push   %eax
  80199d:	6a 00                	push   $0x0
  80199f:	e8 20 f2 ff ff       	call   800bc4 <sys_page_unmap>
}
  8019a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	57                   	push   %edi
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	83 ec 1c             	sub    $0x1c,%esp
  8019b2:	89 c7                	mov    %eax,%edi
  8019b4:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8019bb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	57                   	push   %edi
  8019c2:	e8 1c 05 00 00       	call   801ee3 <pageref>
  8019c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 11 05 00 00       	call   801ee3 <pageref>
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019d8:	0f 94 c0             	sete   %al
  8019db:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019de:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e7:	39 cb                	cmp    %ecx,%ebx
  8019e9:	74 15                	je     801a00 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8019eb:	8b 52 58             	mov    0x58(%edx),%edx
  8019ee:	50                   	push   %eax
  8019ef:	52                   	push   %edx
  8019f0:	53                   	push   %ebx
  8019f1:	68 08 27 80 00       	push   $0x802708
  8019f6:	e8 b6 e7 ff ff       	call   8001b1 <cprintf>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	eb b6                	jmp    8019b6 <_pipeisclosed+0xd>
	}
}
  801a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	57                   	push   %edi
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 28             	sub    $0x28,%esp
  801a11:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a14:	56                   	push   %esi
  801a15:	e8 17 f7 ff ff       	call   801131 <fd2data>
  801a1a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a24:	eb 4b                	jmp    801a71 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a26:	89 da                	mov    %ebx,%edx
  801a28:	89 f0                	mov    %esi,%eax
  801a2a:	e8 7a ff ff ff       	call   8019a9 <_pipeisclosed>
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	75 48                	jne    801a7b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a33:	e8 e8 f0 ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a38:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3b:	8b 0b                	mov    (%ebx),%ecx
  801a3d:	8d 51 20             	lea    0x20(%ecx),%edx
  801a40:	39 d0                	cmp    %edx,%eax
  801a42:	73 e2                	jae    801a26 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a47:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a4b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a4e:	89 c2                	mov    %eax,%edx
  801a50:	c1 fa 1f             	sar    $0x1f,%edx
  801a53:	89 d1                	mov    %edx,%ecx
  801a55:	c1 e9 1b             	shr    $0x1b,%ecx
  801a58:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a5b:	83 e2 1f             	and    $0x1f,%edx
  801a5e:	29 ca                	sub    %ecx,%edx
  801a60:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a64:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a68:	83 c0 01             	add    $0x1,%eax
  801a6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6e:	83 c7 01             	add    $0x1,%edi
  801a71:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a74:	75 c2                	jne    801a38 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a76:	8b 45 10             	mov    0x10(%ebp),%eax
  801a79:	eb 05                	jmp    801a80 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5f                   	pop    %edi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	57                   	push   %edi
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 18             	sub    $0x18,%esp
  801a91:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a94:	57                   	push   %edi
  801a95:	e8 97 f6 ff ff       	call   801131 <fd2data>
  801a9a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa4:	eb 3d                	jmp    801ae3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aa6:	85 db                	test   %ebx,%ebx
  801aa8:	74 04                	je     801aae <devpipe_read+0x26>
				return i;
  801aaa:	89 d8                	mov    %ebx,%eax
  801aac:	eb 44                	jmp    801af2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aae:	89 f2                	mov    %esi,%edx
  801ab0:	89 f8                	mov    %edi,%eax
  801ab2:	e8 f2 fe ff ff       	call   8019a9 <_pipeisclosed>
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	75 32                	jne    801aed <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801abb:	e8 60 f0 ff ff       	call   800b20 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac0:	8b 06                	mov    (%esi),%eax
  801ac2:	3b 46 04             	cmp    0x4(%esi),%eax
  801ac5:	74 df                	je     801aa6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ac7:	99                   	cltd   
  801ac8:	c1 ea 1b             	shr    $0x1b,%edx
  801acb:	01 d0                	add    %edx,%eax
  801acd:	83 e0 1f             	and    $0x1f,%eax
  801ad0:	29 d0                	sub    %edx,%eax
  801ad2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ada:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801add:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae0:	83 c3 01             	add    $0x1,%ebx
  801ae3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ae6:	75 d8                	jne    801ac0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ae8:	8b 45 10             	mov    0x10(%ebp),%eax
  801aeb:	eb 05                	jmp    801af2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	e8 3d f6 ff ff       	call   801148 <fd_alloc>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 2c 01 00 00    	js     801c44 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 ec 04             	sub    $0x4,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	ff 75 f4             	pushl  -0xc(%ebp)
  801b23:	6a 00                	push   $0x0
  801b25:	e8 15 f0 ff ff       	call   800b3f <sys_page_alloc>
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	89 c2                	mov    %eax,%edx
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 0d 01 00 00    	js     801c44 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b3d:	50                   	push   %eax
  801b3e:	e8 05 f6 ff ff       	call   801148 <fd_alloc>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	0f 88 e2 00 00 00    	js     801c32 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b50:	83 ec 04             	sub    $0x4,%esp
  801b53:	68 07 04 00 00       	push   $0x407
  801b58:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 dd ef ff ff       	call   800b3f <sys_page_alloc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	0f 88 c3 00 00 00    	js     801c32 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 f4             	pushl  -0xc(%ebp)
  801b75:	e8 b7 f5 ff ff       	call   801131 <fd2data>
  801b7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7c:	83 c4 0c             	add    $0xc,%esp
  801b7f:	68 07 04 00 00       	push   $0x407
  801b84:	50                   	push   %eax
  801b85:	6a 00                	push   $0x0
  801b87:	e8 b3 ef ff ff       	call   800b3f <sys_page_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 89 00 00 00    	js     801c22 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9f:	e8 8d f5 ff ff       	call   801131 <fd2data>
  801ba4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bab:	50                   	push   %eax
  801bac:	6a 00                	push   $0x0
  801bae:	56                   	push   %esi
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 cc ef ff ff       	call   800b82 <sys_page_map>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 20             	add    $0x20,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 55                	js     801c14 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bbf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bd4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	ff 75 f4             	pushl  -0xc(%ebp)
  801bef:	e8 2d f5 ff ff       	call   801121 <fd2num>
  801bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf9:	83 c4 04             	add    $0x4,%esp
  801bfc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bff:	e8 1d f5 ff ff       	call   801121 <fd2num>
  801c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c07:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c12:	eb 30                	jmp    801c44 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	56                   	push   %esi
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 a5 ef ff ff       	call   800bc4 <sys_page_unmap>
  801c1f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c22:	83 ec 08             	sub    $0x8,%esp
  801c25:	ff 75 f0             	pushl  -0x10(%ebp)
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 95 ef ff ff       	call   800bc4 <sys_page_unmap>
  801c2f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c32:	83 ec 08             	sub    $0x8,%esp
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 85 ef ff ff       	call   800bc4 <sys_page_unmap>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c44:	89 d0                	mov    %edx,%eax
  801c46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c56:	50                   	push   %eax
  801c57:	ff 75 08             	pushl  0x8(%ebp)
  801c5a:	e8 38 f5 ff ff       	call   801197 <fd_lookup>
  801c5f:	89 c2                	mov    %eax,%edx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	85 d2                	test   %edx,%edx
  801c66:	78 18                	js     801c80 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	e8 be f4 ff ff       	call   801131 <fd2data>
	return _pipeisclosed(fd, p);
  801c73:	89 c2                	mov    %eax,%edx
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	e8 2c fd ff ff       	call   8019a9 <_pipeisclosed>
  801c7d:	83 c4 10             	add    $0x10,%esp
}
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c92:	68 39 27 80 00       	push   $0x802739
  801c97:	ff 75 0c             	pushl  0xc(%ebp)
  801c9a:	e8 96 ea ff ff       	call   800735 <strcpy>
	return 0;
}
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	57                   	push   %edi
  801caa:	56                   	push   %esi
  801cab:	53                   	push   %ebx
  801cac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cb7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbd:	eb 2e                	jmp    801ced <devcons_write+0x47>
		m = n - tot;
  801cbf:	8b 55 10             	mov    0x10(%ebp),%edx
  801cc2:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801cc4:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801cc9:	83 fa 7f             	cmp    $0x7f,%edx
  801ccc:	77 02                	ja     801cd0 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cce:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	56                   	push   %esi
  801cd4:	03 45 0c             	add    0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	57                   	push   %edi
  801cd9:	e8 e9 eb ff ff       	call   8008c7 <memmove>
		sys_cputs(buf, m);
  801cde:	83 c4 08             	add    $0x8,%esp
  801ce1:	56                   	push   %esi
  801ce2:	57                   	push   %edi
  801ce3:	e8 9b ed ff ff       	call   800a83 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce8:	01 f3                	add    %esi,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	89 d8                	mov    %ebx,%eax
  801cef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf2:	72 cb                	jb     801cbf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0b:	75 07                	jne    801d14 <devcons_read+0x18>
  801d0d:	eb 28                	jmp    801d37 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d0f:	e8 0c ee ff ff       	call   800b20 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d14:	e8 88 ed ff ff       	call   800aa1 <sys_cgetc>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	74 f2                	je     801d0f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 16                	js     801d37 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d21:	83 f8 04             	cmp    $0x4,%eax
  801d24:	74 0c                	je     801d32 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d29:	88 02                	mov    %al,(%edx)
	return 1;
  801d2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d30:	eb 05                	jmp    801d37 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d45:	6a 01                	push   $0x1
  801d47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	e8 33 ed ff ff       	call   800a83 <sys_cputs>
  801d50:	83 c4 10             	add    $0x10,%esp
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <getchar>:

int
getchar(void)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d5b:	6a 01                	push   $0x1
  801d5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	e8 98 f6 ff ff       	call   801400 <read>
	if (r < 0)
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 0f                	js     801d7e <getchar+0x29>
		return r;
	if (r < 1)
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	7e 06                	jle    801d79 <getchar+0x24>
		return -E_EOF;
	return c;
  801d73:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d77:	eb 05                	jmp    801d7e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d79:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	ff 75 08             	pushl  0x8(%ebp)
  801d8d:	e8 05 f4 ff ff       	call   801197 <fd_lookup>
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 11                	js     801daa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da2:	39 10                	cmp    %edx,(%eax)
  801da4:	0f 94 c0             	sete   %al
  801da7:	0f b6 c0             	movzbl %al,%eax
}
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <opencons>:

int
opencons(void)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 8d f3 ff ff       	call   801148 <fd_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 3e                	js     801e02 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	68 07 04 00 00       	push   $0x407
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 69 ed ff ff       	call   800b3f <sys_page_alloc>
  801dd6:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 23                	js     801e02 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ddf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	50                   	push   %eax
  801df8:	e8 24 f3 ff ff       	call   801121 <fd2num>
  801dfd:	89 c2                	mov    %eax,%edx
  801dff:	83 c4 10             	add    $0x10,%esp
}
  801e02:	89 d0                	mov    %edx,%eax
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e0b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e0e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e14:	e8 e8 ec ff ff       	call   800b01 <sys_getenvid>
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	ff 75 0c             	pushl  0xc(%ebp)
  801e1f:	ff 75 08             	pushl  0x8(%ebp)
  801e22:	56                   	push   %esi
  801e23:	50                   	push   %eax
  801e24:	68 48 27 80 00       	push   $0x802748
  801e29:	e8 83 e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e2e:	83 c4 18             	add    $0x18,%esp
  801e31:	53                   	push   %ebx
  801e32:	ff 75 10             	pushl  0x10(%ebp)
  801e35:	e8 26 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e3a:	c7 04 24 97 26 80 00 	movl   $0x802697,(%esp)
  801e41:	e8 6b e3 ff ff       	call   8001b1 <cprintf>
  801e46:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e49:	cc                   	int3   
  801e4a:	eb fd                	jmp    801e49 <_panic+0x43>

00801e4c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801e52:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e59:	75 2c                	jne    801e87 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801e5b:	83 ec 04             	sub    $0x4,%esp
  801e5e:	6a 07                	push   $0x7
  801e60:	68 00 f0 7f ee       	push   $0xee7ff000
  801e65:	6a 00                	push   $0x0
  801e67:	e8 d3 ec ff ff       	call   800b3f <sys_page_alloc>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	79 14                	jns    801e87 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801e73:	83 ec 04             	sub    $0x4,%esp
  801e76:	68 6c 27 80 00       	push   $0x80276c
  801e7b:	6a 1f                	push   $0x1f
  801e7d:	68 d0 27 80 00       	push   $0x8027d0
  801e82:	e8 7f ff ff ff       	call   801e06 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801e8f:	83 ec 08             	sub    $0x8,%esp
  801e92:	68 bb 1e 80 00       	push   $0x801ebb
  801e97:	6a 00                	push   $0x0
  801e99:	e8 ec ed ff ff       	call   800c8a <sys_env_set_pgfault_upcall>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	79 14                	jns    801eb9 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	68 98 27 80 00       	push   $0x802798
  801ead:	6a 25                	push   $0x25
  801eaf:	68 d0 27 80 00       	push   $0x8027d0
  801eb4:	e8 4d ff ff ff       	call   801e06 <_panic>
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ebb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ebc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801ec6:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801ec8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801ecc:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801ed0:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801ed1:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801ed4:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801ed6:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801ed9:	83 c4 04             	add    $0x4,%esp
	popal 
  801edc:	61                   	popa   
	addl $4, %esp 
  801edd:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801ee0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801ee1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801ee2:	c3                   	ret    

00801ee3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee9:	89 d0                	mov    %edx,%eax
  801eeb:	c1 e8 16             	shr    $0x16,%eax
  801eee:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efa:	f6 c1 01             	test   $0x1,%cl
  801efd:	74 1d                	je     801f1c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eff:	c1 ea 0c             	shr    $0xc,%edx
  801f02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f09:	f6 c2 01             	test   $0x1,%dl
  801f0c:	74 0e                	je     801f1c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f0e:	c1 ea 0c             	shr    $0xc,%edx
  801f11:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f18:	ef 
  801f19:	0f b7 c0             	movzwl %ax,%eax
}
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	83 ec 10             	sub    $0x10,%esp
  801f26:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f2a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f2e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f36:	85 d2                	test   %edx,%edx
  801f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3c:	89 34 24             	mov    %esi,(%esp)
  801f3f:	89 c8                	mov    %ecx,%eax
  801f41:	75 35                	jne    801f78 <__udivdi3+0x58>
  801f43:	39 f1                	cmp    %esi,%ecx
  801f45:	0f 87 bd 00 00 00    	ja     802008 <__udivdi3+0xe8>
  801f4b:	85 c9                	test   %ecx,%ecx
  801f4d:	89 cd                	mov    %ecx,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f1                	div    %ecx
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 f0                	mov    %esi,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c6                	mov    %eax,%esi
  801f64:	89 f8                	mov    %edi,%eax
  801f66:	f7 f5                	div    %ebp
  801f68:	89 f2                	mov    %esi,%edx
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	5e                   	pop    %esi
  801f6e:	5f                   	pop    %edi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    
  801f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f78:	3b 14 24             	cmp    (%esp),%edx
  801f7b:	77 7b                	ja     801ff8 <__udivdi3+0xd8>
  801f7d:	0f bd f2             	bsr    %edx,%esi
  801f80:	83 f6 1f             	xor    $0x1f,%esi
  801f83:	0f 84 97 00 00 00    	je     802020 <__udivdi3+0x100>
  801f89:	bd 20 00 00 00       	mov    $0x20,%ebp
  801f8e:	89 d7                	mov    %edx,%edi
  801f90:	89 f1                	mov    %esi,%ecx
  801f92:	29 f5                	sub    %esi,%ebp
  801f94:	d3 e7                	shl    %cl,%edi
  801f96:	89 c2                	mov    %eax,%edx
  801f98:	89 e9                	mov    %ebp,%ecx
  801f9a:	d3 ea                	shr    %cl,%edx
  801f9c:	89 f1                	mov    %esi,%ecx
  801f9e:	09 fa                	or     %edi,%edx
  801fa0:	8b 3c 24             	mov    (%esp),%edi
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801faf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fb3:	89 fa                	mov    %edi,%edx
  801fb5:	d3 ea                	shr    %cl,%edx
  801fb7:	89 f1                	mov    %esi,%ecx
  801fb9:	d3 e7                	shl    %cl,%edi
  801fbb:	89 e9                	mov    %ebp,%ecx
  801fbd:	d3 e8                	shr    %cl,%eax
  801fbf:	09 c7                	or     %eax,%edi
  801fc1:	89 f8                	mov    %edi,%eax
  801fc3:	f7 74 24 08          	divl   0x8(%esp)
  801fc7:	89 d5                	mov    %edx,%ebp
  801fc9:	89 c7                	mov    %eax,%edi
  801fcb:	f7 64 24 0c          	mull   0xc(%esp)
  801fcf:	39 d5                	cmp    %edx,%ebp
  801fd1:	89 14 24             	mov    %edx,(%esp)
  801fd4:	72 11                	jb     801fe7 <__udivdi3+0xc7>
  801fd6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fda:	89 f1                	mov    %esi,%ecx
  801fdc:	d3 e2                	shl    %cl,%edx
  801fde:	39 c2                	cmp    %eax,%edx
  801fe0:	73 5e                	jae    802040 <__udivdi3+0x120>
  801fe2:	3b 2c 24             	cmp    (%esp),%ebp
  801fe5:	75 59                	jne    802040 <__udivdi3+0x120>
  801fe7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801fea:	31 f6                	xor    %esi,%esi
  801fec:	89 f2                	mov    %esi,%edx
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
  801ff8:	31 f6                	xor    %esi,%esi
  801ffa:	31 c0                	xor    %eax,%eax
  801ffc:	89 f2                	mov    %esi,%edx
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    
  802005:	8d 76 00             	lea    0x0(%esi),%esi
  802008:	89 f2                	mov    %esi,%edx
  80200a:	31 f6                	xor    %esi,%esi
  80200c:	89 f8                	mov    %edi,%eax
  80200e:	f7 f1                	div    %ecx
  802010:	89 f2                	mov    %esi,%edx
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802024:	76 0b                	jbe    802031 <__udivdi3+0x111>
  802026:	31 c0                	xor    %eax,%eax
  802028:	3b 14 24             	cmp    (%esp),%edx
  80202b:	0f 83 37 ff ff ff    	jae    801f68 <__udivdi3+0x48>
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	e9 2d ff ff ff       	jmp    801f68 <__udivdi3+0x48>
  80203b:	90                   	nop
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 f8                	mov    %edi,%eax
  802042:	31 f6                	xor    %esi,%esi
  802044:	e9 1f ff ff ff       	jmp    801f68 <__udivdi3+0x48>
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	83 ec 20             	sub    $0x20,%esp
  802056:	8b 44 24 34          	mov    0x34(%esp),%eax
  80205a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802062:	89 c6                	mov    %eax,%esi
  802064:	89 44 24 10          	mov    %eax,0x10(%esp)
  802068:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80206c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802070:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802074:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802078:	89 74 24 18          	mov    %esi,0x18(%esp)
  80207c:	85 c0                	test   %eax,%eax
  80207e:	89 c2                	mov    %eax,%edx
  802080:	75 1e                	jne    8020a0 <__umoddi3+0x50>
  802082:	39 f7                	cmp    %esi,%edi
  802084:	76 52                	jbe    8020d8 <__umoddi3+0x88>
  802086:	89 c8                	mov    %ecx,%eax
  802088:	89 f2                	mov    %esi,%edx
  80208a:	f7 f7                	div    %edi
  80208c:	89 d0                	mov    %edx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	83 c4 20             	add    $0x20,%esp
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    
  802097:	89 f6                	mov    %esi,%esi
  802099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020a0:	39 f0                	cmp    %esi,%eax
  8020a2:	77 5c                	ja     802100 <__umoddi3+0xb0>
  8020a4:	0f bd e8             	bsr    %eax,%ebp
  8020a7:	83 f5 1f             	xor    $0x1f,%ebp
  8020aa:	75 64                	jne    802110 <__umoddi3+0xc0>
  8020ac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8020b0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8020b4:	0f 86 f6 00 00 00    	jbe    8021b0 <__umoddi3+0x160>
  8020ba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8020be:	0f 82 ec 00 00 00    	jb     8021b0 <__umoddi3+0x160>
  8020c4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020c8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8020cc:	83 c4 20             	add    $0x20,%esp
  8020cf:	5e                   	pop    %esi
  8020d0:	5f                   	pop    %edi
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    
  8020d3:	90                   	nop
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	85 ff                	test   %edi,%edi
  8020da:	89 fd                	mov    %edi,%ebp
  8020dc:	75 0b                	jne    8020e9 <__umoddi3+0x99>
  8020de:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f7                	div    %edi
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8020ed:	31 d2                	xor    %edx,%edx
  8020ef:	f7 f5                	div    %ebp
  8020f1:	89 c8                	mov    %ecx,%eax
  8020f3:	f7 f5                	div    %ebp
  8020f5:	eb 95                	jmp    80208c <__umoddi3+0x3c>
  8020f7:	89 f6                	mov    %esi,%esi
  8020f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 20             	add    $0x20,%esp
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
  80210b:	90                   	nop
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	b8 20 00 00 00       	mov    $0x20,%eax
  802115:	89 e9                	mov    %ebp,%ecx
  802117:	29 e8                	sub    %ebp,%eax
  802119:	d3 e2                	shl    %cl,%edx
  80211b:	89 c7                	mov    %eax,%edi
  80211d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802121:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 c1                	mov    %eax,%ecx
  80212b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80212f:	09 d1                	or     %edx,%ecx
  802131:	89 fa                	mov    %edi,%edx
  802133:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802137:	89 e9                	mov    %ebp,%ecx
  802139:	d3 e0                	shl    %cl,%eax
  80213b:	89 f9                	mov    %edi,%ecx
  80213d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802141:	89 f0                	mov    %esi,%eax
  802143:	d3 e8                	shr    %cl,%eax
  802145:	89 e9                	mov    %ebp,%ecx
  802147:	89 c7                	mov    %eax,%edi
  802149:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80214d:	d3 e6                	shl    %cl,%esi
  80214f:	89 d1                	mov    %edx,%ecx
  802151:	89 fa                	mov    %edi,%edx
  802153:	d3 e8                	shr    %cl,%eax
  802155:	89 e9                	mov    %ebp,%ecx
  802157:	09 f0                	or     %esi,%eax
  802159:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80215d:	f7 74 24 10          	divl   0x10(%esp)
  802161:	d3 e6                	shl    %cl,%esi
  802163:	89 d1                	mov    %edx,%ecx
  802165:	f7 64 24 0c          	mull   0xc(%esp)
  802169:	39 d1                	cmp    %edx,%ecx
  80216b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80216f:	89 d7                	mov    %edx,%edi
  802171:	89 c6                	mov    %eax,%esi
  802173:	72 0a                	jb     80217f <__umoddi3+0x12f>
  802175:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802179:	73 10                	jae    80218b <__umoddi3+0x13b>
  80217b:	39 d1                	cmp    %edx,%ecx
  80217d:	75 0c                	jne    80218b <__umoddi3+0x13b>
  80217f:	89 d7                	mov    %edx,%edi
  802181:	89 c6                	mov    %eax,%esi
  802183:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802187:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80218b:	89 ca                	mov    %ecx,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802193:	29 f0                	sub    %esi,%eax
  802195:	19 fa                	sbb    %edi,%edx
  802197:	d3 e8                	shr    %cl,%eax
  802199:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80219e:	89 d7                	mov    %edx,%edi
  8021a0:	d3 e7                	shl    %cl,%edi
  8021a2:	89 e9                	mov    %ebp,%ecx
  8021a4:	09 f8                	or     %edi,%eax
  8021a6:	d3 ea                	shr    %cl,%edx
  8021a8:	83 c4 20             	add    $0x20,%esp
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    
  8021af:	90                   	nop
  8021b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021b4:	29 f9                	sub    %edi,%ecx
  8021b6:	19 c6                	sbb    %eax,%esi
  8021b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021c0:	e9 ff fe ff ff       	jmp    8020c4 <__umoddi3+0x74>
