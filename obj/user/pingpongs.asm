
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 17 10 00 00       	call   801058 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 ee 0a 00 00       	call   800b41 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 40 22 80 00       	push   $0x802240
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d7 0a 00 00       	call   800b41 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 5a 22 80 00       	push   $0x80225a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 51 10 00 00       	call   8010d8 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 d8 0f 00 00       	call   801072 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 8e 0a 00 00       	call   800b41 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 70 22 80 00       	push   $0x802270
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 ee 0f 00 00       	call   8010d8 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800109:	e8 33 0a 00 00       	call   800b41 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 78             	imul   $0x78,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
  80013a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 de 11 00 00       	call   80132d <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a7 09 00 00       	call   800b00 <sys_env_destroy>
  800159:	83 c4 10             	add    $0x10,%esp
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 35 09 00 00       	call   800ac3 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 4f 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 da 08 00 00       	call   800ac3 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 d1                	mov    %edx,%ecx
  80021a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800226:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800229:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800230:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800233:	72 05                	jb     80023a <printnum+0x35>
  800235:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800238:	77 3e                	ja     800278 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	ff 75 18             	pushl  0x18(%ebp)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	53                   	push   %ebx
  800244:	50                   	push   %eax
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 07 1d 00 00       	call   801f60 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 13                	jmp    80027f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	85 db                	test   %ebx,%ebx
  80027d:	7f ed                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027f:	83 ec 08             	sub    $0x8,%esp
  800282:	56                   	push   %esi
  800283:	83 ec 04             	sub    $0x4,%esp
  800286:	ff 75 e4             	pushl  -0x1c(%ebp)
  800289:	ff 75 e0             	pushl  -0x20(%ebp)
  80028c:	ff 75 dc             	pushl  -0x24(%ebp)
  80028f:	ff 75 d8             	pushl  -0x28(%ebp)
  800292:	e8 f9 1d 00 00       	call   802090 <__umoddi3>
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  8002a1:	50                   	push   %eax
  8002a2:	ff d7                	call   *%edi
  8002a4:	83 c4 10             	add    $0x10,%esp
}
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	eb 22                	jmp    8002e7 <getuint+0x38>
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	74 10                	je     8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb 0e                	jmp    8002e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
  80031e:	83 c4 10             	add    $0x10,%esp
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 8d 03 00 00    	je     8006cc <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 c8             	movzbl %al,%ecx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 1e 03 00 00    	ja     8006b1 <vprintfmt+0x38e>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003be:	83 fa 09             	cmp    $0x9,%edx
  8003c1:	77 38                	ja     8003fb <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d9:	eb 26                	jmp    800401 <vprintfmt+0xde>
  8003db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003de:	89 c8                	mov    %ecx,%eax
  8003e0:	c1 f8 1f             	sar    $0x1f,%eax
  8003e3:	f7 d0                	not    %eax
  8003e5:	21 c1                	and    %eax,%ecx
  8003e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ed:	eb 8d                	jmp    80037c <vprintfmt+0x59>
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f9:	eb 81                	jmp    80037c <vprintfmt+0x59>
  8003fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800401:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800405:	0f 89 71 ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  80040b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800411:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800418:	e9 5f ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800423:	e9 54 ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	53                   	push   %ebx
  800435:	ff 30                	pushl  (%eax)
  800437:	ff d6                	call   *%esi
			break;
  800439:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043f:	e9 05 ff ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	99                   	cltd   
  800450:	31 d0                	xor    %edx,%eax
  800452:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 f8 0f             	cmp    $0xf,%eax
  800457:	7f 0b                	jg     800464 <vprintfmt+0x141>
  800459:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	75 18                	jne    80047c <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800464:	50                   	push   %eax
  800465:	68 b8 22 80 00       	push   $0x8022b8
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 95 fe ff ff       	call   800306 <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 cd fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	52                   	push   %edx
  80047d:	68 61 27 80 00       	push   $0x802761
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 7d fe ff ff       	call   800306 <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048f:	e9 b5 fe ff ff       	jmp    800349 <vprintfmt+0x26>
  800494:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800497:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 38                	mov    (%eax),%edi
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	75 05                	jne    8004b1 <vprintfmt+0x18e>
				p = "(null)";
  8004ac:	bf b1 22 80 00       	mov    $0x8022b1,%edi
			if (width > 0 && padc != '-')
  8004b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b5:	0f 84 91 00 00 00    	je     80054c <vprintfmt+0x229>
  8004bb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004bf:	0f 8e 95 00 00 00    	jle    80055a <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	51                   	push   %ecx
  8004c9:	57                   	push   %edi
  8004ca:	e8 85 02 00 00       	call   800754 <strnlen>
  8004cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c5>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	89 c8                	mov    %ecx,%eax
  800503:	c1 f8 1f             	sar    $0x1f,%eax
  800506:	f7 d0                	not    %eax
  800508:	21 c8                	and    %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 4d                	jmp    800566 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1b                	je     80053a <vprintfmt+0x217>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 10                	jbe    80053a <vprintfmt+0x217>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 0d                	jmp    800547 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	52                   	push   %edx
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 1a                	jmp    800566 <vprintfmt+0x243>
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800558:	eb 0c                	jmp    800566 <vprintfmt+0x243>
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	83 c7 01             	add    $0x1,%edi
  800569:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056d:	0f be d0             	movsbl %al,%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	74 23                	je     800597 <vprintfmt+0x274>
  800574:	85 f6                	test   %esi,%esi
  800576:	78 a1                	js     800519 <vprintfmt+0x1f6>
  800578:	83 ee 01             	sub    $0x1,%esi
  80057b:	79 9c                	jns    800519 <vprintfmt+0x1f6>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	6a 20                	push   $0x20
  80058d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb 08                	jmp    80059f <vprintfmt+0x27c>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	85 ff                	test   %edi,%edi
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	e9 9e fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 fa 01             	cmp    $0x1,%edx
  8005ae:	7e 16                	jle    8005c6 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 08             	lea    0x8(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	eb 32                	jmp    8005f8 <vprintfmt+0x2d5>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 18                	je     8005e2 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	eb 16                	jmp    8005f8 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	79 74                	jns    80067d <vprintfmt+0x35a>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d6                	call   *%esi
				num = -(long long) num;
  800611:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800617:	f7 d8                	neg    %eax
  800619:	83 d2 00             	adc    $0x0,%edx
  80061c:	f7 da                	neg    %edx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800626:	eb 55                	jmp    80067d <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 7f fc ff ff       	call   8002af <getuint>
			base = 10;
  800630:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800635:	eb 46                	jmp    80067d <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 70 fc ff ff       	call   8002af <getuint>
			base = 8;
  80063f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800644:	eb 37                	jmp    80067d <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800669:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066e:	eb 0d                	jmp    80067d <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 37 fc ff ff       	call   8002af <getuint>
			base = 16;
  800678:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800684:	57                   	push   %edi
  800685:	ff 75 e0             	pushl  -0x20(%ebp)
  800688:	51                   	push   %ecx
  800689:	52                   	push   %edx
  80068a:	50                   	push   %eax
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 71 fb ff ff       	call   800205 <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069a:	e9 aa fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	51                   	push   %ecx
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ac:	e9 98 fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 25                	push   $0x25
  8006b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 03                	jmp    8006c1 <vprintfmt+0x39e>
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c5:	75 f7                	jne    8006be <vprintfmt+0x39b>
  8006c7:	e9 7d fc ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 26                	je     80071b <vsnprintf+0x47>
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	7e 22                	jle    80071b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f9:	ff 75 14             	pushl  0x14(%ebp)
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	68 e9 02 80 00       	push   $0x8002e9
  800708:	e8 16 fc ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800710:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 05                	jmp    800720 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	50                   	push   %eax
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	ff 75 08             	pushl  0x8(%ebp)
  800735:	e8 9a ff ff ff       	call   8006d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 03                	jmp    80074c <strlen+0x10>
		n++;
  800749:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800750:	75 f7                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	eb 03                	jmp    800767 <strnlen+0x13>
		n++;
  800764:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 c2                	cmp    %eax,%edx
  800769:	74 08                	je     800773 <strnlen+0x1f>
  80076b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076f:	75 f3                	jne    800764 <strnlen+0x10>
  800771:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078e:	84 db                	test   %bl,%bl
  800790:	75 ef                	jne    800781 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 9a ff ff ff       	call   80073c <strlen>
  8007a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 c5 ff ff ff       	call   800775 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 f3                	mov    %esi,%ebx
  8007c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 0f                	jmp    8007da <strncpy+0x23>
		*dst++ = *src;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	39 da                	cmp    %ebx,%edx
  8007dc:	75 ed                	jne    8007cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	74 21                	je     800819 <strlcpy+0x35>
  8007f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fc:	89 f2                	mov    %esi,%edx
  8007fe:	eb 09                	jmp    800809 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800809:	39 c2                	cmp    %eax,%edx
  80080b:	74 09                	je     800816 <strlcpy+0x32>
  80080d:	0f b6 19             	movzbl (%ecx),%ebx
  800810:	84 db                	test   %bl,%bl
  800812:	75 ec                	jne    800800 <strlcpy+0x1c>
  800814:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800816:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800819:	29 f0                	sub    %esi,%eax
}
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	eb 06                	jmp    800830 <strcmp+0x11>
		p++, q++;
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	84 c0                	test   %al,%al
  800835:	74 04                	je     80083b <strcmp+0x1c>
  800837:	3a 02                	cmp    (%edx),%al
  800839:	74 ef                	je     80082a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 c0             	movzbl %al,%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 c3                	mov    %eax,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800854:	eb 06                	jmp    80085c <strncmp+0x17>
		n--, p++, q++;
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	74 15                	je     800875 <strncmp+0x30>
  800860:	0f b6 08             	movzbl (%eax),%ecx
  800863:	84 c9                	test   %cl,%cl
  800865:	74 04                	je     80086b <strncmp+0x26>
  800867:	3a 0a                	cmp    (%edx),%cl
  800869:	74 eb                	je     800856 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 07                	jmp    800890 <strchr+0x13>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0f                	je     80089c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 03                	jmp    8008ad <strfind+0xf>
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 04                	je     8008b8 <strfind+0x1a>
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	75 f2                	jne    8008aa <strfind+0xc>
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008c6:	85 c9                	test   %ecx,%ecx
  8008c8:	74 36                	je     800900 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d0:	75 28                	jne    8008fa <memset+0x40>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 23                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008db:	89 d3                	mov    %edx,%ebx
  8008dd:	c1 e3 08             	shl    $0x8,%ebx
  8008e0:	89 d6                	mov    %edx,%esi
  8008e2:	c1 e6 18             	shl    $0x18,%esi
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	c1 e0 10             	shl    $0x10,%eax
  8008ea:	09 f0                	or     %esi,%eax
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 06                	jmp    800900 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fd:	fc                   	cld    
  8008fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800915:	39 c6                	cmp    %eax,%esi
  800917:	73 35                	jae    80094e <memmove+0x47>
  800919:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 2e                	jae    80094e <memmove+0x47>
		s += n;
		d += n;
  800920:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800923:	89 d6                	mov    %edx,%esi
  800925:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092d:	75 13                	jne    800942 <memmove+0x3b>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0e                	jne    800942 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800934:	83 ef 04             	sub    $0x4,%edi
  800937:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093d:	fd                   	std    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 09                	jmp    80094b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 1d                	jmp    80096b <memmove+0x64>
  80094e:	89 f2                	mov    %esi,%edx
  800950:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	f6 c2 03             	test   $0x3,%dl
  800955:	75 0f                	jne    800966 <memmove+0x5f>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0a                	jne    800966 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 05                	jmp    80096b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 87 ff ff ff       	call   800907 <memmove>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c6                	mov    %eax,%esi
  80098f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	eb 1a                	jmp    8009ae <memcmp+0x2c>
		if (*s1 != *s2)
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	0f b6 1a             	movzbl (%edx),%ebx
  80099a:	38 d9                	cmp    %bl,%cl
  80099c:	74 0a                	je     8009a8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c1             	movzbl %cl,%eax
  8009a1:	0f b6 db             	movzbl %bl,%ebx
  8009a4:	29 d8                	sub    %ebx,%eax
  8009a6:	eb 0f                	jmp    8009b7 <memcmp+0x35>
		s1++, s2++;
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	75 e2                	jne    800994 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c4:	89 c2                	mov    %eax,%edx
  8009c6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c9:	eb 07                	jmp    8009d2 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	38 08                	cmp    %cl,(%eax)
  8009cd:	74 07                	je     8009d6 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	72 f5                	jb     8009cb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 03                	jmp    8009e9 <strtol+0x11>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f6                	je     8009e6 <strtol+0xe>
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f2                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f4:	3c 2b                	cmp    $0x2b,%al
  8009f6:	75 0a                	jne    800a02 <strtol+0x2a>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800a00:	eb 10                	jmp    800a12 <strtol+0x3a>
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	75 07                	jne    800a12 <strtol+0x3a>
		s++, neg = 1;
  800a0b:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a0e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a12:	85 db                	test   %ebx,%ebx
  800a14:	0f 94 c0             	sete   %al
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 19                	jne    800a38 <strtol+0x60>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 14                	jne    800a38 <strtol+0x60>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	0f 85 8a 00 00 00    	jne    800ab8 <strtol+0xe0>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 12                	je     800a4e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x76>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x93>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0f                	jge    800aa1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x7e>
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	eb 02                	jmp    800aa3 <strtol+0xcb>
  800aa1:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 05                	je     800aae <strtol+0xd6>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aae:	85 ff                	test   %edi,%edi
  800ab0:	74 0c                	je     800abe <strtol+0xe6>
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	f7 d8                	neg    %eax
  800ab6:	eb 06                	jmp    800abe <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	84 c0                	test   %al,%al
  800aba:	75 8a                	jne    800a46 <strtol+0x6e>
  800abc:	eb 90                	jmp    800a4e <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	89 c7                	mov    %eax,%edi
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aec:	b8 01 00 00 00       	mov    $0x1,%eax
  800af1:	89 d1                	mov    %edx,%ecx
  800af3:	89 d3                	mov    %edx,%ebx
  800af5:	89 d7                	mov    %edx,%edi
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 cb                	mov    %ecx,%ebx
  800b18:	89 cf                	mov    %ecx,%edi
  800b1a:	89 ce                	mov    %ecx,%esi
  800b1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	7e 17                	jle    800b39 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	50                   	push   %eax
  800b26:	6a 03                	push   $0x3
  800b28:	68 df 25 80 00       	push   $0x8025df
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 fc 25 80 00       	push   $0x8025fc
  800b34:	e8 0d 13 00 00       	call   801e46 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_yield>:

void
sys_yield(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	be 00 00 00 00       	mov    $0x0,%esi
  800b8d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9b:	89 f7                	mov    %esi,%edi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 04                	push   $0x4
  800ba9:	68 df 25 80 00       	push   $0x8025df
  800bae:	6a 23                	push   $0x23
  800bb0:	68 fc 25 80 00       	push   $0x8025fc
  800bb5:	e8 8c 12 00 00       	call   801e46 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 05                	push   $0x5
  800beb:	68 df 25 80 00       	push   $0x8025df
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 fc 25 80 00       	push   $0x8025fc
  800bf7:	e8 4a 12 00 00       	call   801e46 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 06                	push   $0x6
  800c2d:	68 df 25 80 00       	push   $0x8025df
  800c32:	6a 23                	push   $0x23
  800c34:	68 fc 25 80 00       	push   $0x8025fc
  800c39:	e8 08 12 00 00       	call   801e46 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 08 00 00 00       	mov    $0x8,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 08                	push   $0x8
  800c6f:	68 df 25 80 00       	push   $0x8025df
  800c74:	6a 23                	push   $0x23
  800c76:	68 fc 25 80 00       	push   $0x8025fc
  800c7b:	e8 c6 11 00 00       	call   801e46 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 09                	push   $0x9
  800cb1:	68 df 25 80 00       	push   $0x8025df
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 fc 25 80 00       	push   $0x8025fc
  800cbd:	e8 84 11 00 00       	call   801e46 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 0a                	push   $0xa
  800cf3:	68 df 25 80 00       	push   $0x8025df
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 fc 25 80 00       	push   $0x8025fc
  800cff:	e8 42 11 00 00       	call   801e46 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d28:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 cb                	mov    %ecx,%ebx
  800d47:	89 cf                	mov    %ecx,%edi
  800d49:	89 ce                	mov    %ecx,%esi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 17                	jle    800d68 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 0d                	push   $0xd
  800d57:	68 df 25 80 00       	push   $0x8025df
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 fc 25 80 00       	push   $0x8025fc
  800d63:	e8 de 10 00 00       	call   801e46 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_gettime>:

int sys_gettime(void)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d80:	89 d1                	mov    %edx,%ecx
  800d82:	89 d3                	mov    %edx,%ebx
  800d84:	89 d7                	mov    %edx,%edi
  800d86:	89 d6                	mov    %edx,%esi
  800d88:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	53                   	push   %ebx
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800d99:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d9b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d9f:	74 2e                	je     800dcf <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	c1 ea 16             	shr    $0x16,%edx
  800da6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800dad:	f6 c2 01             	test   $0x1,%dl
  800db0:	74 1d                	je     800dcf <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800db2:	89 c2                	mov    %eax,%edx
  800db4:	c1 ea 0c             	shr    $0xc,%edx
  800db7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800dbe:	f6 c1 01             	test   $0x1,%cl
  800dc1:	74 0c                	je     800dcf <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800dc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800dca:	f6 c6 08             	test   $0x8,%dh
  800dcd:	75 14                	jne    800de3 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 0a 26 80 00       	push   $0x80260a
  800dd7:	6a 28                	push   $0x28
  800dd9:	68 1c 26 80 00       	push   $0x80261c
  800dde:	e8 63 10 00 00       	call   801e46 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800de3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de8:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	6a 07                	push   $0x7
  800def:	68 00 f0 7f 00       	push   $0x7ff000
  800df4:	6a 00                	push   $0x0
  800df6:	e8 84 fd ff ff       	call   800b7f <sys_page_alloc>
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	79 14                	jns    800e16 <pgfault+0x87>
		panic("sys_page_alloc");
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	68 27 26 80 00       	push   $0x802627
  800e0a:	6a 2c                	push   $0x2c
  800e0c:	68 1c 26 80 00       	push   $0x80261c
  800e11:	e8 30 10 00 00       	call   801e46 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	68 00 10 00 00       	push   $0x1000
  800e1e:	53                   	push   %ebx
  800e1f:	68 00 f0 7f 00       	push   $0x7ff000
  800e24:	e8 46 fb ff ff       	call   80096f <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e29:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e30:	53                   	push   %ebx
  800e31:	6a 00                	push   $0x0
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 83 fd ff ff       	call   800bc2 <sys_page_map>
  800e3f:	83 c4 20             	add    $0x20,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 14                	jns    800e5a <pgfault+0xcb>
		panic("sys_page_map");
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 36 26 80 00       	push   $0x802636
  800e4e:	6a 2f                	push   $0x2f
  800e50:	68 1c 26 80 00       	push   $0x80261c
  800e55:	e8 ec 0f 00 00       	call   801e46 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	68 00 f0 7f 00       	push   $0x7ff000
  800e62:	6a 00                	push   $0x0
  800e64:	e8 9b fd ff ff       	call   800c04 <sys_page_unmap>
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	79 14                	jns    800e84 <pgfault+0xf5>
		panic("sys_page_unmap");
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 43 26 80 00       	push   $0x802643
  800e78:	6a 31                	push   $0x31
  800e7a:	68 1c 26 80 00       	push   $0x80261c
  800e7f:	e8 c2 0f 00 00       	call   801e46 <_panic>
	return;
}
  800e84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800e92:	68 8f 0d 80 00       	push   $0x800d8f
  800e97:	e8 f0 0f 00 00       	call   801e8c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e9c:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea1:	cd 30                	int    $0x30
  800ea3:	89 c7                	mov    %eax,%edi
  800ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 21                	jne    800ed0 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eaf:	e8 8d fc ff ff       	call   800b41 <sys_getenvid>
  800eb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb9:	6b c0 78             	imul   $0x78,%eax,%eax
  800ebc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec1:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	e9 80 01 00 00       	jmp    801050 <fork+0x1c7>
	}
	if (envid < 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 12                	jns    800ee6 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800ed4:	50                   	push   %eax
  800ed5:	68 52 26 80 00       	push   $0x802652
  800eda:	6a 70                	push   $0x70
  800edc:	68 1c 26 80 00       	push   $0x80261c
  800ee1:	e8 60 0f 00 00       	call   801e46 <_panic>
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800eeb:	89 d8                	mov    %ebx,%eax
  800eed:	c1 e8 16             	shr    $0x16,%eax
  800ef0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef7:	a8 01                	test   $0x1,%al
  800ef9:	0f 84 de 00 00 00    	je     800fdd <fork+0x154>
  800eff:	89 de                	mov    %ebx,%esi
  800f01:	c1 ee 0c             	shr    $0xc,%esi
  800f04:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0b:	a8 01                	test   $0x1,%al
  800f0d:	0f 84 ca 00 00 00    	je     800fdd <fork+0x154>
  800f13:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1a:	a8 04                	test   $0x4,%al
  800f1c:	0f 84 bb 00 00 00    	je     800fdd <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800f22:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800f29:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800f2c:	f6 c4 04             	test   $0x4,%ah
  800f2f:	74 34                	je     800f65 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	25 07 0e 00 00       	and    $0xe07,%eax
  800f39:	50                   	push   %eax
  800f3a:	56                   	push   %esi
  800f3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3e:	56                   	push   %esi
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 7c fc ff ff       	call   800bc2 <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	0f 84 8c 00 00 00    	je     800fdd <fork+0x154>
        	panic("duppage share");
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	68 62 26 80 00       	push   $0x802662
  800f59:	6a 48                	push   $0x48
  800f5b:	68 1c 26 80 00       	push   $0x80261c
  800f60:	e8 e1 0e 00 00       	call   801e46 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f65:	a9 02 08 00 00       	test   $0x802,%eax
  800f6a:	74 5d                	je     800fc9 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	68 05 08 00 00       	push   $0x805
  800f74:	56                   	push   %esi
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	56                   	push   %esi
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 42 fc ff ff       	call   800bc2 <sys_page_map>
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	79 14                	jns    800f9b <fork+0x112>
			panic("error");
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 cd 22 80 00       	push   $0x8022cd
  800f8f:	6a 4b                	push   $0x4b
  800f91:	68 1c 26 80 00       	push   $0x80261c
  800f96:	e8 ab 0e 00 00       	call   801e46 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	68 05 08 00 00       	push   $0x805
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	56                   	push   %esi
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 14 fc ff ff       	call   800bc2 <sys_page_map>
  800fae:	83 c4 20             	add    $0x20,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 28                	jns    800fdd <fork+0x154>
			panic("error");
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	68 cd 22 80 00       	push   $0x8022cd
  800fbd:	6a 4d                	push   $0x4d
  800fbf:	68 1c 26 80 00       	push   $0x80261c
  800fc4:	e8 7d 0e 00 00       	call   801e46 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	6a 05                	push   $0x5
  800fce:	56                   	push   %esi
  800fcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd2:	56                   	push   %esi
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 e8 fb ff ff       	call   800bc2 <sys_page_map>
  800fda:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fdd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe3:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  800fe9:	0f 85 fc fe ff ff    	jne    800eeb <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	6a 07                	push   $0x7
  800ff4:	68 00 f0 7f ee       	push   $0xee7ff000
  800ff9:	57                   	push   %edi
  800ffa:	e8 80 fb ff ff       	call   800b7f <sys_page_alloc>
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	79 14                	jns    80101a <fork+0x191>
		panic("1");
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	68 70 26 80 00       	push   $0x802670
  80100e:	6a 78                	push   $0x78
  801010:	68 1c 26 80 00       	push   $0x80261c
  801015:	e8 2c 0e 00 00       	call   801e46 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	68 fb 1e 80 00       	push   $0x801efb
  801022:	57                   	push   %edi
  801023:	e8 a2 fc ff ff       	call   800cca <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801028:	83 c4 08             	add    $0x8,%esp
  80102b:	6a 02                	push   $0x2
  80102d:	57                   	push   %edi
  80102e:	e8 13 fc ff ff       	call   800c46 <sys_env_set_status>
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 14                	jns    80104e <fork+0x1c5>
		panic("sys_env_set_status");
  80103a:	83 ec 04             	sub    $0x4,%esp
  80103d:	68 72 26 80 00       	push   $0x802672
  801042:	6a 7d                	push   $0x7d
  801044:	68 1c 26 80 00       	push   $0x80261c
  801049:	e8 f8 0d 00 00       	call   801e46 <_panic>

	return envid;
  80104e:	89 f8                	mov    %edi,%eax
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sfork>:

// Challenge!
int
sfork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105e:	68 85 26 80 00       	push   $0x802685
  801063:	68 86 00 00 00       	push   $0x86
  801068:	68 1c 26 80 00       	push   $0x80261c
  80106d:	e8 d4 0d 00 00       	call   801e46 <_panic>

00801072 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	8b 75 08             	mov    0x8(%ebp),%esi
  80107a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801080:	85 f6                	test   %esi,%esi
  801082:	74 06                	je     80108a <ipc_recv+0x18>
  801084:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80108a:	85 db                	test   %ebx,%ebx
  80108c:	74 06                	je     801094 <ipc_recv+0x22>
  80108e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801094:	83 f8 01             	cmp    $0x1,%eax
  801097:	19 d2                	sbb    %edx,%edx
  801099:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	50                   	push   %eax
  80109f:	e8 8b fc ff ff       	call   800d2f <sys_ipc_recv>
  8010a4:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 d2                	test   %edx,%edx
  8010ab:	75 24                	jne    8010d1 <ipc_recv+0x5f>
	if (from_env_store)
  8010ad:	85 f6                	test   %esi,%esi
  8010af:	74 0a                	je     8010bb <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  8010b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b6:	8b 40 70             	mov    0x70(%eax),%eax
  8010b9:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8010bb:	85 db                	test   %ebx,%ebx
  8010bd:	74 0a                	je     8010c9 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  8010bf:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c4:	8b 40 74             	mov    0x74(%eax),%eax
  8010c7:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8010c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ce:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  8010d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  8010ea:	83 fb 01             	cmp    $0x1,%ebx
  8010ed:	19 c0                	sbb    %eax,%eax
  8010ef:	09 c3                	or     %eax,%ebx
  8010f1:	eb 1c                	jmp    80110f <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  8010f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f6:	74 12                	je     80110a <ipc_send+0x32>
  8010f8:	50                   	push   %eax
  8010f9:	68 9b 26 80 00       	push   $0x80269b
  8010fe:	6a 36                	push   $0x36
  801100:	68 b2 26 80 00       	push   $0x8026b2
  801105:	e8 3c 0d 00 00       	call   801e46 <_panic>
		sys_yield();
  80110a:	e8 51 fa ff ff       	call   800b60 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80110f:	ff 75 14             	pushl  0x14(%ebp)
  801112:	53                   	push   %ebx
  801113:	56                   	push   %esi
  801114:	57                   	push   %edi
  801115:	e8 f2 fb ff ff       	call   800d0c <sys_ipc_try_send>
		if (ret == 0) break;
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	75 d2                	jne    8010f3 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801134:	6b d0 78             	imul   $0x78,%eax,%edx
  801137:	83 c2 50             	add    $0x50,%edx
  80113a:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801140:	39 ca                	cmp    %ecx,%edx
  801142:	75 0d                	jne    801151 <ipc_find_env+0x28>
			return envs[i].env_id;
  801144:	6b c0 78             	imul   $0x78,%eax,%eax
  801147:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80114c:	8b 40 08             	mov    0x8(%eax),%eax
  80114f:	eb 0e                	jmp    80115f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801151:	83 c0 01             	add    $0x1,%eax
  801154:	3d 00 04 00 00       	cmp    $0x400,%eax
  801159:	75 d9                	jne    801134 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80115b:	66 b8 00 00          	mov    $0x0,%ax
}
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	05 00 00 00 30       	add    $0x30000000,%eax
  80116c:	c1 e8 0c             	shr    $0xc,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80117c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801181:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 16             	shr    $0x16,%edx
  801198:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 11                	je     8011b5 <fd_alloc+0x2d>
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 0c             	shr    $0xc,%edx
  8011a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	75 09                	jne    8011be <fd_alloc+0x36>
			*fd_store = fd;
  8011b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bc:	eb 17                	jmp    8011d5 <fd_alloc+0x4d>
  8011be:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c8:	75 c9                	jne    801193 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ca:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011d0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dd:	83 f8 1f             	cmp    $0x1f,%eax
  8011e0:	77 36                	ja     801218 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e2:	c1 e0 0c             	shl    $0xc,%eax
  8011e5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 16             	shr    $0x16,%edx
  8011ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	74 24                	je     80121f <fd_lookup+0x48>
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	c1 ea 0c             	shr    $0xc,%edx
  801200:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801207:	f6 c2 01             	test   $0x1,%dl
  80120a:	74 1a                	je     801226 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120f:	89 02                	mov    %eax,(%edx)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	eb 13                	jmp    80122b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801218:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121d:	eb 0c                	jmp    80122b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801224:	eb 05                	jmp    80122b <fd_lookup+0x54>
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	ba 38 27 80 00       	mov    $0x802738,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123b:	eb 13                	jmp    801250 <dev_lookup+0x23>
  80123d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801240:	39 08                	cmp    %ecx,(%eax)
  801242:	75 0c                	jne    801250 <dev_lookup+0x23>
			*dev = devtab[i];
  801244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801247:	89 01                	mov    %eax,(%ecx)
			return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb 2e                	jmp    80127e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801250:	8b 02                	mov    (%edx),%eax
  801252:	85 c0                	test   %eax,%eax
  801254:	75 e7                	jne    80123d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801256:	a1 08 40 80 00       	mov    0x804008,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	51                   	push   %ecx
  801262:	50                   	push   %eax
  801263:	68 bc 26 80 00       	push   $0x8026bc
  801268:	e8 84 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80126d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801270:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 10             	sub    $0x10,%esp
  801288:	8b 75 08             	mov    0x8(%ebp),%esi
  80128b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801292:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801298:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129b:	50                   	push   %eax
  80129c:	e8 36 ff ff ff       	call   8011d7 <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 05                	js     8012ad <fd_close+0x2d>
	    || fd != fd2)
  8012a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ab:	74 0b                	je     8012b8 <fd_close+0x38>
		return (must_exist ? r : 0);
  8012ad:	80 fb 01             	cmp    $0x1,%bl
  8012b0:	19 d2                	sbb    %edx,%edx
  8012b2:	f7 d2                	not    %edx
  8012b4:	21 d0                	and    %edx,%eax
  8012b6:	eb 41                	jmp    8012f9 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	ff 36                	pushl  (%esi)
  8012c1:	e8 67 ff ff ff       	call   80122d <dev_lookup>
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 1a                	js     8012e9 <fd_close+0x69>
		if (dev->dev_close)
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	74 0b                	je     8012e9 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8012de:	83 ec 0c             	sub    $0xc,%esp
  8012e1:	56                   	push   %esi
  8012e2:	ff d0                	call   *%eax
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	56                   	push   %esi
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 10 f9 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 d8                	mov    %ebx,%eax
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 c5 fe ff ff       	call   8011d7 <fd_lookup>
  801312:	89 c2                	mov    %eax,%edx
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	85 d2                	test   %edx,%edx
  801319:	78 10                	js     80132b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	6a 01                	push   $0x1
  801320:	ff 75 f4             	pushl  -0xc(%ebp)
  801323:	e8 58 ff ff ff       	call   801280 <fd_close>
  801328:	83 c4 10             	add    $0x10,%esp
}
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <close_all>:

void
close_all(void)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801334:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	53                   	push   %ebx
  80133d:	e8 be ff ff ff       	call   801300 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801342:	83 c3 01             	add    $0x1,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	83 fb 20             	cmp    $0x20,%ebx
  80134b:	75 ec                	jne    801339 <close_all+0xc>
		close(i);
}
  80134d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	57                   	push   %edi
  801356:	56                   	push   %esi
  801357:	53                   	push   %ebx
  801358:	83 ec 2c             	sub    $0x2c,%esp
  80135b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	ff 75 08             	pushl  0x8(%ebp)
  801365:	e8 6d fe ff ff       	call   8011d7 <fd_lookup>
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	83 c4 08             	add    $0x8,%esp
  80136f:	85 d2                	test   %edx,%edx
  801371:	0f 88 c1 00 00 00    	js     801438 <dup+0xe6>
		return r;
	close(newfdnum);
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	56                   	push   %esi
  80137b:	e8 80 ff ff ff       	call   801300 <close>

	newfd = INDEX2FD(newfdnum);
  801380:	89 f3                	mov    %esi,%ebx
  801382:	c1 e3 0c             	shl    $0xc,%ebx
  801385:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80138b:	83 c4 04             	add    $0x4,%esp
  80138e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801391:	e8 db fd ff ff       	call   801171 <fd2data>
  801396:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801398:	89 1c 24             	mov    %ebx,(%esp)
  80139b:	e8 d1 fd ff ff       	call   801171 <fd2data>
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a6:	89 f8                	mov    %edi,%eax
  8013a8:	c1 e8 16             	shr    $0x16,%eax
  8013ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b2:	a8 01                	test   $0x1,%al
  8013b4:	74 37                	je     8013ed <dup+0x9b>
  8013b6:	89 f8                	mov    %edi,%eax
  8013b8:	c1 e8 0c             	shr    $0xc,%eax
  8013bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 26                	je     8013ed <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d6:	50                   	push   %eax
  8013d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013da:	6a 00                	push   $0x0
  8013dc:	57                   	push   %edi
  8013dd:	6a 00                	push   $0x0
  8013df:	e8 de f7 ff ff       	call   800bc2 <sys_page_map>
  8013e4:	89 c7                	mov    %eax,%edi
  8013e6:	83 c4 20             	add    $0x20,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 2e                	js     80141b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013f0:	89 d0                	mov    %edx,%eax
  8013f2:	c1 e8 0c             	shr    $0xc,%eax
  8013f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801404:	50                   	push   %eax
  801405:	53                   	push   %ebx
  801406:	6a 00                	push   $0x0
  801408:	52                   	push   %edx
  801409:	6a 00                	push   $0x0
  80140b:	e8 b2 f7 ff ff       	call   800bc2 <sys_page_map>
  801410:	89 c7                	mov    %eax,%edi
  801412:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801415:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801417:	85 ff                	test   %edi,%edi
  801419:	79 1d                	jns    801438 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	e8 de f7 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801426:	83 c4 08             	add    $0x8,%esp
  801429:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142c:	6a 00                	push   $0x0
  80142e:	e8 d1 f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	89 f8                	mov    %edi,%eax
}
  801438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 14             	sub    $0x14,%esp
  801447:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	53                   	push   %ebx
  80144f:	e8 83 fd ff ff       	call   8011d7 <fd_lookup>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	89 c2                	mov    %eax,%edx
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 6d                	js     8014ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801467:	ff 30                	pushl  (%eax)
  801469:	e8 bf fd ff ff       	call   80122d <dev_lookup>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 4c                	js     8014c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801475:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801478:	8b 42 08             	mov    0x8(%edx),%eax
  80147b:	83 e0 03             	and    $0x3,%eax
  80147e:	83 f8 01             	cmp    $0x1,%eax
  801481:	75 21                	jne    8014a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801483:	a1 08 40 80 00       	mov    0x804008,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	53                   	push   %ebx
  80148f:	50                   	push   %eax
  801490:	68 fd 26 80 00       	push   $0x8026fd
  801495:	e8 57 ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a2:	eb 26                	jmp    8014ca <read+0x8a>
	}
	if (!dev->dev_read)
  8014a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a7:	8b 40 08             	mov    0x8(%eax),%eax
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	74 17                	je     8014c5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	ff 75 10             	pushl  0x10(%ebp)
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	52                   	push   %edx
  8014b8:	ff d0                	call   *%eax
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	eb 09                	jmp    8014ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	eb 05                	jmp    8014ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ca:	89 d0                	mov    %edx,%eax
  8014cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	57                   	push   %edi
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e5:	eb 21                	jmp    801508 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	89 f0                	mov    %esi,%eax
  8014ec:	29 d8                	sub    %ebx,%eax
  8014ee:	50                   	push   %eax
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	03 45 0c             	add    0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	57                   	push   %edi
  8014f6:	e8 45 ff ff ff       	call   801440 <read>
		if (m < 0)
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 0c                	js     80150e <readn+0x3d>
			return m;
		if (m == 0)
  801502:	85 c0                	test   %eax,%eax
  801504:	74 06                	je     80150c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801506:	01 c3                	add    %eax,%ebx
  801508:	39 f3                	cmp    %esi,%ebx
  80150a:	72 db                	jb     8014e7 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80150c:	89 d8                	mov    %ebx,%eax
}
  80150e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	e8 ad fc ff ff       	call   8011d7 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 68                	js     80159b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 e9 fc ff ff       	call   80122d <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 47                	js     801592 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801552:	75 21                	jne    801575 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801554:	a1 08 40 80 00       	mov    0x804008,%eax
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	53                   	push   %ebx
  801560:	50                   	push   %eax
  801561:	68 19 27 80 00       	push   $0x802719
  801566:	e8 86 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801573:	eb 26                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801575:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	85 d2                	test   %edx,%edx
  80157d:	74 17                	je     801596 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	ff 75 10             	pushl  0x10(%ebp)
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	50                   	push   %eax
  801589:	ff d2                	call   *%edx
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 23 fc ff ff       	call   8011d7 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 0e                	js     8015c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 14             	sub    $0x14,%esp
  8015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	53                   	push   %ebx
  8015da:	e8 f8 fb ff ff       	call   8011d7 <fd_lookup>
  8015df:	83 c4 08             	add    $0x8,%esp
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 65                	js     80164d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 34 fc ff ff       	call   80122d <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 44                	js     801644 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801607:	75 21                	jne    80162a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801609:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160e:	8b 40 48             	mov    0x48(%eax),%eax
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	53                   	push   %ebx
  801615:	50                   	push   %eax
  801616:	68 dc 26 80 00       	push   $0x8026dc
  80161b:	e8 d1 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801628:	eb 23                	jmp    80164d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162d:	8b 52 18             	mov    0x18(%edx),%edx
  801630:	85 d2                	test   %edx,%edx
  801632:	74 14                	je     801648 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	50                   	push   %eax
  80163b:	ff d2                	call   *%edx
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 09                	jmp    80164d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	89 c2                	mov    %eax,%edx
  801646:	eb 05                	jmp    80164d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801648:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 14             	sub    $0x14,%esp
  80165b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	e8 6d fb ff ff       	call   8011d7 <fd_lookup>
  80166a:	83 c4 08             	add    $0x8,%esp
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 58                	js     8016cb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	ff 30                	pushl  (%eax)
  80167f:	e8 a9 fb ff ff       	call   80122d <dev_lookup>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 37                	js     8016c2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801692:	74 32                	je     8016c6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801694:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801697:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169e:	00 00 00 
	stat->st_isdir = 0;
  8016a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a8:	00 00 00 
	stat->st_dev = dev;
  8016ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	53                   	push   %ebx
  8016b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b8:	ff 50 14             	call   *0x14(%eax)
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb 09                	jmp    8016cb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	eb 05                	jmp    8016cb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cb:	89 d0                	mov    %edx,%eax
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 e7 01 00 00       	call   8018cb <open>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 db                	test   %ebx,%ebx
  8016eb:	78 1b                	js     801708 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	53                   	push   %ebx
  8016f4:	e8 5b ff ff ff       	call   801654 <fstat>
  8016f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016fb:	89 1c 24             	mov    %ebx,(%esp)
  8016fe:	e8 fd fb ff ff       	call   801300 <close>
	return r;
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	89 f0                	mov    %esi,%eax
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	89 c6                	mov    %eax,%esi
  801716:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801718:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80171f:	75 12                	jne    801733 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	6a 03                	push   $0x3
  801726:	e8 fe f9 ff ff       	call   801129 <ipc_find_env>
  80172b:	a3 00 40 80 00       	mov    %eax,0x804000
  801730:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801733:	6a 07                	push   $0x7
  801735:	68 00 50 80 00       	push   $0x805000
  80173a:	56                   	push   %esi
  80173b:	ff 35 00 40 80 00    	pushl  0x804000
  801741:	e8 92 f9 ff ff       	call   8010d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801746:	83 c4 0c             	add    $0xc,%esp
  801749:	6a 00                	push   $0x0
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	e8 1f f9 ff ff       	call   801072 <ipc_recv>
}
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 02 00 00 00       	mov    $0x2,%eax
  80177d:	e8 8d ff ff ff       	call   80170f <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 06 00 00 00       	mov    $0x6,%eax
  80179f:	e8 6b ff ff ff       	call   80170f <fsipc>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c5:	e8 45 ff ff ff       	call   80170f <fsipc>
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	85 d2                	test   %edx,%edx
  8017ce:	78 2c                	js     8017fc <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 00 50 80 00       	push   $0x805000
  8017d8:	53                   	push   %ebx
  8017d9:	e8 97 ef ff ff       	call   800775 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017de:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  80180a:	8b 55 08             	mov    0x8(%ebp),%edx
  80180d:	8b 52 0c             	mov    0xc(%edx),%edx
  801810:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801816:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80181b:	76 05                	jbe    801822 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80181d:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801822:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	50                   	push   %eax
  80182b:	ff 75 0c             	pushl  0xc(%ebp)
  80182e:	68 08 50 80 00       	push   $0x805008
  801833:	e8 cf f0 ff ff       	call   800907 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 04 00 00 00       	mov    $0x4,%eax
  801842:	e8 c8 fe ff ff       	call   80170f <fsipc>
	return write;
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 40 0c             	mov    0xc(%eax),%eax
  801857:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80185c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 03 00 00 00       	mov    $0x3,%eax
  80186c:	e8 9e fe ff ff       	call   80170f <fsipc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	85 c0                	test   %eax,%eax
  801875:	78 4b                	js     8018c2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801877:	39 c6                	cmp    %eax,%esi
  801879:	73 16                	jae    801891 <devfile_read+0x48>
  80187b:	68 48 27 80 00       	push   $0x802748
  801880:	68 4f 27 80 00       	push   $0x80274f
  801885:	6a 7c                	push   $0x7c
  801887:	68 64 27 80 00       	push   $0x802764
  80188c:	e8 b5 05 00 00       	call   801e46 <_panic>
	assert(r <= PGSIZE);
  801891:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801896:	7e 16                	jle    8018ae <devfile_read+0x65>
  801898:	68 6f 27 80 00       	push   $0x80276f
  80189d:	68 4f 27 80 00       	push   $0x80274f
  8018a2:	6a 7d                	push   $0x7d
  8018a4:	68 64 27 80 00       	push   $0x802764
  8018a9:	e8 98 05 00 00       	call   801e46 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	50                   	push   %eax
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	e8 48 f0 ff ff       	call   800907 <memmove>
	return r;
  8018bf:	83 c4 10             	add    $0x10,%esp
}
  8018c2:	89 d8                	mov    %ebx,%eax
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 20             	sub    $0x20,%esp
  8018d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d5:	53                   	push   %ebx
  8018d6:	e8 61 ee ff ff       	call   80073c <strlen>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e3:	7f 67                	jg     80194c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018eb:	50                   	push   %eax
  8018ec:	e8 97 f8 ff ff       	call   801188 <fd_alloc>
  8018f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 57                	js     801951 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	53                   	push   %ebx
  8018fe:	68 00 50 80 00       	push   $0x805000
  801903:	e8 6d ee ff ff       	call   800775 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801910:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801913:	b8 01 00 00 00       	mov    $0x1,%eax
  801918:	e8 f2 fd ff ff       	call   80170f <fsipc>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	79 14                	jns    80193a <open+0x6f>
		fd_close(fd, 0);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	6a 00                	push   $0x0
  80192b:	ff 75 f4             	pushl  -0xc(%ebp)
  80192e:	e8 4d f9 ff ff       	call   801280 <fd_close>
		return r;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 da                	mov    %ebx,%edx
  801938:	eb 17                	jmp    801951 <open+0x86>
	}

	return fd2num(fd);
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	ff 75 f4             	pushl  -0xc(%ebp)
  801940:	e8 1c f8 ff ff       	call   801161 <fd2num>
  801945:	89 c2                	mov    %eax,%edx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	eb 05                	jmp    801951 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80194c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801951:	89 d0                	mov    %edx,%eax
  801953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195e:	ba 00 00 00 00       	mov    $0x0,%edx
  801963:	b8 08 00 00 00       	mov    $0x8,%eax
  801968:	e8 a2 fd ff ff       	call   80170f <fsipc>
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 75 08             	pushl  0x8(%ebp)
  80197d:	e8 ef f7 ff ff       	call   801171 <fd2data>
  801982:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801984:	83 c4 08             	add    $0x8,%esp
  801987:	68 7b 27 80 00       	push   $0x80277b
  80198c:	53                   	push   %ebx
  80198d:	e8 e3 ed ff ff       	call   800775 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801992:	8b 56 04             	mov    0x4(%esi),%edx
  801995:	89 d0                	mov    %edx,%eax
  801997:	2b 06                	sub    (%esi),%eax
  801999:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a6:	00 00 00 
	stat->st_dev = &devpipe;
  8019a9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019b0:	30 80 00 
	return 0;
}
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c9:	53                   	push   %ebx
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 33 f2 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d1:	89 1c 24             	mov    %ebx,(%esp)
  8019d4:	e8 98 f7 ff ff       	call   801171 <fd2data>
  8019d9:	83 c4 08             	add    $0x8,%esp
  8019dc:	50                   	push   %eax
  8019dd:	6a 00                	push   $0x0
  8019df:	e8 20 f2 ff ff       	call   800c04 <sys_page_unmap>
}
  8019e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	57                   	push   %edi
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 1c             	sub    $0x1c,%esp
  8019f2:	89 c7                	mov    %eax,%edi
  8019f4:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8019fb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	57                   	push   %edi
  801a02:	e8 1c 05 00 00       	call   801f23 <pageref>
  801a07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a0a:	89 34 24             	mov    %esi,(%esp)
  801a0d:	e8 11 05 00 00       	call   801f23 <pageref>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a18:	0f 94 c0             	sete   %al
  801a1b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a1e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a24:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a27:	39 cb                	cmp    %ecx,%ebx
  801a29:	74 15                	je     801a40 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801a2b:	8b 52 58             	mov    0x58(%edx),%edx
  801a2e:	50                   	push   %eax
  801a2f:	52                   	push   %edx
  801a30:	53                   	push   %ebx
  801a31:	68 88 27 80 00       	push   $0x802788
  801a36:	e8 b6 e7 ff ff       	call   8001f1 <cprintf>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	eb b6                	jmp    8019f6 <_pipeisclosed+0xd>
	}
}
  801a40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5f                   	pop    %edi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	57                   	push   %edi
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 28             	sub    $0x28,%esp
  801a51:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a54:	56                   	push   %esi
  801a55:	e8 17 f7 ff ff       	call   801171 <fd2data>
  801a5a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a64:	eb 4b                	jmp    801ab1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a66:	89 da                	mov    %ebx,%edx
  801a68:	89 f0                	mov    %esi,%eax
  801a6a:	e8 7a ff ff ff       	call   8019e9 <_pipeisclosed>
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	75 48                	jne    801abb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a73:	e8 e8 f0 ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a78:	8b 43 04             	mov    0x4(%ebx),%eax
  801a7b:	8b 0b                	mov    (%ebx),%ecx
  801a7d:	8d 51 20             	lea    0x20(%ecx),%edx
  801a80:	39 d0                	cmp    %edx,%eax
  801a82:	73 e2                	jae    801a66 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a87:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a8b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a8e:	89 c2                	mov    %eax,%edx
  801a90:	c1 fa 1f             	sar    $0x1f,%edx
  801a93:	89 d1                	mov    %edx,%ecx
  801a95:	c1 e9 1b             	shr    $0x1b,%ecx
  801a98:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a9b:	83 e2 1f             	and    $0x1f,%edx
  801a9e:	29 ca                	sub    %ecx,%edx
  801aa0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aa4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa8:	83 c0 01             	add    $0x1,%eax
  801aab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aae:	83 c7 01             	add    $0x1,%edi
  801ab1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab4:	75 c2                	jne    801a78 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab9:	eb 05                	jmp    801ac0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5f                   	pop    %edi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	83 ec 18             	sub    $0x18,%esp
  801ad1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad4:	57                   	push   %edi
  801ad5:	e8 97 f6 ff ff       	call   801171 <fd2data>
  801ada:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae4:	eb 3d                	jmp    801b23 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae6:	85 db                	test   %ebx,%ebx
  801ae8:	74 04                	je     801aee <devpipe_read+0x26>
				return i;
  801aea:	89 d8                	mov    %ebx,%eax
  801aec:	eb 44                	jmp    801b32 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aee:	89 f2                	mov    %esi,%edx
  801af0:	89 f8                	mov    %edi,%eax
  801af2:	e8 f2 fe ff ff       	call   8019e9 <_pipeisclosed>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	75 32                	jne    801b2d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801afb:	e8 60 f0 ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b00:	8b 06                	mov    (%esi),%eax
  801b02:	3b 46 04             	cmp    0x4(%esi),%eax
  801b05:	74 df                	je     801ae6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b07:	99                   	cltd   
  801b08:	c1 ea 1b             	shr    $0x1b,%edx
  801b0b:	01 d0                	add    %edx,%eax
  801b0d:	83 e0 1f             	and    $0x1f,%eax
  801b10:	29 d0                	sub    %edx,%eax
  801b12:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b1d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b20:	83 c3 01             	add    $0x1,%ebx
  801b23:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b26:	75 d8                	jne    801b00 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b28:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2b:	eb 05                	jmp    801b32 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	e8 3d f6 ff ff       	call   801188 <fd_alloc>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	85 c0                	test   %eax,%eax
  801b52:	0f 88 2c 01 00 00    	js     801c84 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	68 07 04 00 00       	push   $0x407
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	6a 00                	push   $0x0
  801b65:	e8 15 f0 ff ff       	call   800b7f <sys_page_alloc>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	89 c2                	mov    %eax,%edx
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 0d 01 00 00    	js     801c84 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	e8 05 f6 ff ff       	call   801188 <fd_alloc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 e2 00 00 00    	js     801c72 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	68 07 04 00 00       	push   $0x407
  801b98:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 dd ef ff ff       	call   800b7f <sys_page_alloc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	0f 88 c3 00 00 00    	js     801c72 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb5:	e8 b7 f5 ff ff       	call   801171 <fd2data>
  801bba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 c4 0c             	add    $0xc,%esp
  801bbf:	68 07 04 00 00       	push   $0x407
  801bc4:	50                   	push   %eax
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 b3 ef ff ff       	call   800b7f <sys_page_alloc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 89 00 00 00    	js     801c62 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdf:	e8 8d f5 ff ff       	call   801171 <fd2data>
  801be4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801beb:	50                   	push   %eax
  801bec:	6a 00                	push   $0x0
  801bee:	56                   	push   %esi
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 cc ef ff ff       	call   800bc2 <sys_page_map>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 20             	add    $0x20,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 55                	js     801c54 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2f:	e8 2d f5 ff ff       	call   801161 <fd2num>
  801c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c39:	83 c4 04             	add    $0x4,%esp
  801c3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3f:	e8 1d f5 ff ff       	call   801161 <fd2num>
  801c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c52:	eb 30                	jmp    801c84 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	56                   	push   %esi
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 a5 ef ff ff       	call   800c04 <sys_page_unmap>
  801c5f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c62:	83 ec 08             	sub    $0x8,%esp
  801c65:	ff 75 f0             	pushl  -0x10(%ebp)
  801c68:	6a 00                	push   $0x0
  801c6a:	e8 95 ef ff ff       	call   800c04 <sys_page_unmap>
  801c6f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	ff 75 f4             	pushl  -0xc(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 85 ef ff ff       	call   800c04 <sys_page_unmap>
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c84:	89 d0                	mov    %edx,%eax
  801c86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5e                   	pop    %esi
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	ff 75 08             	pushl  0x8(%ebp)
  801c9a:	e8 38 f5 ff ff       	call   8011d7 <fd_lookup>
  801c9f:	89 c2                	mov    %eax,%edx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 d2                	test   %edx,%edx
  801ca6:	78 18                	js     801cc0 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	ff 75 f4             	pushl  -0xc(%ebp)
  801cae:	e8 be f4 ff ff       	call   801171 <fd2data>
	return _pipeisclosed(fd, p);
  801cb3:	89 c2                	mov    %eax,%edx
  801cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb8:	e8 2c fd ff ff       	call   8019e9 <_pipeisclosed>
  801cbd:	83 c4 10             	add    $0x10,%esp
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd2:	68 b9 27 80 00       	push   $0x8027b9
  801cd7:	ff 75 0c             	pushl  0xc(%ebp)
  801cda:	e8 96 ea ff ff       	call   800775 <strcpy>
	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cfd:	eb 2e                	jmp    801d2d <devcons_write+0x47>
		m = n - tot;
  801cff:	8b 55 10             	mov    0x10(%ebp),%edx
  801d02:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801d04:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801d09:	83 fa 7f             	cmp    $0x7f,%edx
  801d0c:	77 02                	ja     801d10 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0e:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d10:	83 ec 04             	sub    $0x4,%esp
  801d13:	56                   	push   %esi
  801d14:	03 45 0c             	add    0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	57                   	push   %edi
  801d19:	e8 e9 eb ff ff       	call   800907 <memmove>
		sys_cputs(buf, m);
  801d1e:	83 c4 08             	add    $0x8,%esp
  801d21:	56                   	push   %esi
  801d22:	57                   	push   %edi
  801d23:	e8 9b ed ff ff       	call   800ac3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d28:	01 f3                	add    %esi,%ebx
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	89 d8                	mov    %ebx,%eax
  801d2f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d32:	72 cb                	jb     801cff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4b:	75 07                	jne    801d54 <devcons_read+0x18>
  801d4d:	eb 28                	jmp    801d77 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d4f:	e8 0c ee ff ff       	call   800b60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d54:	e8 88 ed ff ff       	call   800ae1 <sys_cgetc>
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	74 f2                	je     801d4f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 16                	js     801d77 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d61:	83 f8 04             	cmp    $0x4,%eax
  801d64:	74 0c                	je     801d72 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d69:	88 02                	mov    %al,(%edx)
	return 1;
  801d6b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d70:	eb 05                	jmp    801d77 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d82:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d85:	6a 01                	push   $0x1
  801d87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	e8 33 ed ff ff       	call   800ac3 <sys_cputs>
  801d90:	83 c4 10             	add    $0x10,%esp
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <getchar>:

int
getchar(void)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d9b:	6a 01                	push   $0x1
  801d9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	6a 00                	push   $0x0
  801da3:	e8 98 f6 ff ff       	call   801440 <read>
	if (r < 0)
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 0f                	js     801dbe <getchar+0x29>
		return r;
	if (r < 1)
  801daf:	85 c0                	test   %eax,%eax
  801db1:	7e 06                	jle    801db9 <getchar+0x24>
		return -E_EOF;
	return c;
  801db3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db7:	eb 05                	jmp    801dbe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	ff 75 08             	pushl  0x8(%ebp)
  801dcd:	e8 05 f4 ff ff       	call   8011d7 <fd_lookup>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 11                	js     801dea <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de2:	39 10                	cmp    %edx,(%eax)
  801de4:	0f 94 c0             	sete   %al
  801de7:	0f b6 c0             	movzbl %al,%eax
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <opencons>:

int
opencons(void)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	e8 8d f3 ff ff       	call   801188 <fd_alloc>
  801dfb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dfe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 3e                	js     801e42 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	68 07 04 00 00       	push   $0x407
  801e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 69 ed ff ff       	call   800b7f <sys_page_alloc>
  801e16:	83 c4 10             	add    $0x10,%esp
		return r;
  801e19:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 23                	js     801e42 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e28:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	50                   	push   %eax
  801e38:	e8 24 f3 ff ff       	call   801161 <fd2num>
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	83 c4 10             	add    $0x10,%esp
}
  801e42:	89 d0                	mov    %edx,%eax
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e4b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e4e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e54:	e8 e8 ec ff ff       	call   800b41 <sys_getenvid>
  801e59:	83 ec 0c             	sub    $0xc,%esp
  801e5c:	ff 75 0c             	pushl  0xc(%ebp)
  801e5f:	ff 75 08             	pushl  0x8(%ebp)
  801e62:	56                   	push   %esi
  801e63:	50                   	push   %eax
  801e64:	68 c8 27 80 00       	push   $0x8027c8
  801e69:	e8 83 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e6e:	83 c4 18             	add    $0x18,%esp
  801e71:	53                   	push   %ebx
  801e72:	ff 75 10             	pushl  0x10(%ebp)
  801e75:	e8 26 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e7a:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
  801e81:	e8 6b e3 ff ff       	call   8001f1 <cprintf>
  801e86:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e89:	cc                   	int3   
  801e8a:	eb fd                	jmp    801e89 <_panic+0x43>

00801e8c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801e92:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e99:	75 2c                	jne    801ec7 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	6a 07                	push   $0x7
  801ea0:	68 00 f0 7f ee       	push   $0xee7ff000
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 d3 ec ff ff       	call   800b7f <sys_page_alloc>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	79 14                	jns    801ec7 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	68 ec 27 80 00       	push   $0x8027ec
  801ebb:	6a 1f                	push   $0x1f
  801ebd:	68 50 28 80 00       	push   $0x802850
  801ec2:	e8 7f ff ff ff       	call   801e46 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ecf:	83 ec 08             	sub    $0x8,%esp
  801ed2:	68 fb 1e 80 00       	push   $0x801efb
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 ec ed ff ff       	call   800cca <sys_env_set_pgfault_upcall>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	79 14                	jns    801ef9 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	68 18 28 80 00       	push   $0x802818
  801eed:	6a 25                	push   $0x25
  801eef:	68 50 28 80 00       	push   $0x802850
  801ef4:	e8 4d ff ff ff       	call   801e46 <_panic>
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801efb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801efc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f01:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f03:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801f06:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801f08:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801f0c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801f10:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801f11:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801f14:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801f16:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801f19:	83 c4 04             	add    $0x4,%esp
	popal 
  801f1c:	61                   	popa   
	addl $4, %esp 
  801f1d:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801f20:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801f21:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801f22:	c3                   	ret    

00801f23 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f29:	89 d0                	mov    %edx,%eax
  801f2b:	c1 e8 16             	shr    $0x16,%eax
  801f2e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f35:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3a:	f6 c1 01             	test   $0x1,%cl
  801f3d:	74 1d                	je     801f5c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f3f:	c1 ea 0c             	shr    $0xc,%edx
  801f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f49:	f6 c2 01             	test   $0x1,%dl
  801f4c:	74 0e                	je     801f5c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f4e:	c1 ea 0c             	shr    $0xc,%edx
  801f51:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f58:	ef 
  801f59:	0f b7 c0             	movzwl %ax,%eax
}
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	83 ec 10             	sub    $0x10,%esp
  801f66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f76:	85 d2                	test   %edx,%edx
  801f78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f7c:	89 34 24             	mov    %esi,(%esp)
  801f7f:	89 c8                	mov    %ecx,%eax
  801f81:	75 35                	jne    801fb8 <__udivdi3+0x58>
  801f83:	39 f1                	cmp    %esi,%ecx
  801f85:	0f 87 bd 00 00 00    	ja     802048 <__udivdi3+0xe8>
  801f8b:	85 c9                	test   %ecx,%ecx
  801f8d:	89 cd                	mov    %ecx,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f1                	div    %ecx
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 f0                	mov    %esi,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c6                	mov    %eax,%esi
  801fa4:	89 f8                	mov    %edi,%eax
  801fa6:	f7 f5                	div    %ebp
  801fa8:	89 f2                	mov    %esi,%edx
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	5e                   	pop    %esi
  801fae:	5f                   	pop    %edi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    
  801fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	3b 14 24             	cmp    (%esp),%edx
  801fbb:	77 7b                	ja     802038 <__udivdi3+0xd8>
  801fbd:	0f bd f2             	bsr    %edx,%esi
  801fc0:	83 f6 1f             	xor    $0x1f,%esi
  801fc3:	0f 84 97 00 00 00    	je     802060 <__udivdi3+0x100>
  801fc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fce:	89 d7                	mov    %edx,%edi
  801fd0:	89 f1                	mov    %esi,%ecx
  801fd2:	29 f5                	sub    %esi,%ebp
  801fd4:	d3 e7                	shl    %cl,%edi
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	d3 ea                	shr    %cl,%edx
  801fdc:	89 f1                	mov    %esi,%ecx
  801fde:	09 fa                	or     %edi,%edx
  801fe0:	8b 3c 24             	mov    (%esp),%edi
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fe9:	89 e9                	mov    %ebp,%ecx
  801feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ff3:	89 fa                	mov    %edi,%edx
  801ff5:	d3 ea                	shr    %cl,%edx
  801ff7:	89 f1                	mov    %esi,%ecx
  801ff9:	d3 e7                	shl    %cl,%edi
  801ffb:	89 e9                	mov    %ebp,%ecx
  801ffd:	d3 e8                	shr    %cl,%eax
  801fff:	09 c7                	or     %eax,%edi
  802001:	89 f8                	mov    %edi,%eax
  802003:	f7 74 24 08          	divl   0x8(%esp)
  802007:	89 d5                	mov    %edx,%ebp
  802009:	89 c7                	mov    %eax,%edi
  80200b:	f7 64 24 0c          	mull   0xc(%esp)
  80200f:	39 d5                	cmp    %edx,%ebp
  802011:	89 14 24             	mov    %edx,(%esp)
  802014:	72 11                	jb     802027 <__udivdi3+0xc7>
  802016:	8b 54 24 04          	mov    0x4(%esp),%edx
  80201a:	89 f1                	mov    %esi,%ecx
  80201c:	d3 e2                	shl    %cl,%edx
  80201e:	39 c2                	cmp    %eax,%edx
  802020:	73 5e                	jae    802080 <__udivdi3+0x120>
  802022:	3b 2c 24             	cmp    (%esp),%ebp
  802025:	75 59                	jne    802080 <__udivdi3+0x120>
  802027:	8d 47 ff             	lea    -0x1(%edi),%eax
  80202a:	31 f6                	xor    %esi,%esi
  80202c:	89 f2                	mov    %esi,%edx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	31 f6                	xor    %esi,%esi
  80203a:	31 c0                	xor    %eax,%eax
  80203c:	89 f2                	mov    %esi,%edx
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	89 f2                	mov    %esi,%edx
  80204a:	31 f6                	xor    %esi,%esi
  80204c:	89 f8                	mov    %edi,%eax
  80204e:	f7 f1                	div    %ecx
  802050:	89 f2                	mov    %esi,%edx
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802064:	76 0b                	jbe    802071 <__udivdi3+0x111>
  802066:	31 c0                	xor    %eax,%eax
  802068:	3b 14 24             	cmp    (%esp),%edx
  80206b:	0f 83 37 ff ff ff    	jae    801fa8 <__udivdi3+0x48>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	e9 2d ff ff ff       	jmp    801fa8 <__udivdi3+0x48>
  80207b:	90                   	nop
  80207c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 f8                	mov    %edi,%eax
  802082:	31 f6                	xor    %esi,%esi
  802084:	e9 1f ff ff ff       	jmp    801fa8 <__udivdi3+0x48>
  802089:	66 90                	xchg   %ax,%ax
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	83 ec 20             	sub    $0x20,%esp
  802096:	8b 44 24 34          	mov    0x34(%esp),%eax
  80209a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a2:	89 c6                	mov    %eax,%esi
  8020a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	89 c2                	mov    %eax,%edx
  8020c0:	75 1e                	jne    8020e0 <__umoddi3+0x50>
  8020c2:	39 f7                	cmp    %esi,%edi
  8020c4:	76 52                	jbe    802118 <__umoddi3+0x88>
  8020c6:	89 c8                	mov    %ecx,%eax
  8020c8:	89 f2                	mov    %esi,%edx
  8020ca:	f7 f7                	div    %edi
  8020cc:	89 d0                	mov    %edx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	83 c4 20             	add    $0x20,%esp
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    
  8020d7:	89 f6                	mov    %esi,%esi
  8020d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020e0:	39 f0                	cmp    %esi,%eax
  8020e2:	77 5c                	ja     802140 <__umoddi3+0xb0>
  8020e4:	0f bd e8             	bsr    %eax,%ebp
  8020e7:	83 f5 1f             	xor    $0x1f,%ebp
  8020ea:	75 64                	jne    802150 <__umoddi3+0xc0>
  8020ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8020f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8020f4:	0f 86 f6 00 00 00    	jbe    8021f0 <__umoddi3+0x160>
  8020fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8020fe:	0f 82 ec 00 00 00    	jb     8021f0 <__umoddi3+0x160>
  802104:	8b 44 24 14          	mov    0x14(%esp),%eax
  802108:	8b 54 24 18          	mov    0x18(%esp),%edx
  80210c:	83 c4 20             	add    $0x20,%esp
  80210f:	5e                   	pop    %esi
  802110:	5f                   	pop    %edi
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    
  802113:	90                   	nop
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	85 ff                	test   %edi,%edi
  80211a:	89 fd                	mov    %edi,%ebp
  80211c:	75 0b                	jne    802129 <__umoddi3+0x99>
  80211e:	b8 01 00 00 00       	mov    $0x1,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f7                	div    %edi
  802127:	89 c5                	mov    %eax,%ebp
  802129:	8b 44 24 10          	mov    0x10(%esp),%eax
  80212d:	31 d2                	xor    %edx,%edx
  80212f:	f7 f5                	div    %ebp
  802131:	89 c8                	mov    %ecx,%eax
  802133:	f7 f5                	div    %ebp
  802135:	eb 95                	jmp    8020cc <__umoddi3+0x3c>
  802137:	89 f6                	mov    %esi,%esi
  802139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 20             	add    $0x20,%esp
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    
  80214b:	90                   	nop
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	b8 20 00 00 00       	mov    $0x20,%eax
  802155:	89 e9                	mov    %ebp,%ecx
  802157:	29 e8                	sub    %ebp,%eax
  802159:	d3 e2                	shl    %cl,%edx
  80215b:	89 c7                	mov    %eax,%edi
  80215d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802161:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 c1                	mov    %eax,%ecx
  80216b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80216f:	09 d1                	or     %edx,%ecx
  802171:	89 fa                	mov    %edi,%edx
  802173:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802177:	89 e9                	mov    %ebp,%ecx
  802179:	d3 e0                	shl    %cl,%eax
  80217b:	89 f9                	mov    %edi,%ecx
  80217d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802181:	89 f0                	mov    %esi,%eax
  802183:	d3 e8                	shr    %cl,%eax
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	89 c7                	mov    %eax,%edi
  802189:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80218d:	d3 e6                	shl    %cl,%esi
  80218f:	89 d1                	mov    %edx,%ecx
  802191:	89 fa                	mov    %edi,%edx
  802193:	d3 e8                	shr    %cl,%eax
  802195:	89 e9                	mov    %ebp,%ecx
  802197:	09 f0                	or     %esi,%eax
  802199:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80219d:	f7 74 24 10          	divl   0x10(%esp)
  8021a1:	d3 e6                	shl    %cl,%esi
  8021a3:	89 d1                	mov    %edx,%ecx
  8021a5:	f7 64 24 0c          	mull   0xc(%esp)
  8021a9:	39 d1                	cmp    %edx,%ecx
  8021ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8021af:	89 d7                	mov    %edx,%edi
  8021b1:	89 c6                	mov    %eax,%esi
  8021b3:	72 0a                	jb     8021bf <__umoddi3+0x12f>
  8021b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021b9:	73 10                	jae    8021cb <__umoddi3+0x13b>
  8021bb:	39 d1                	cmp    %edx,%ecx
  8021bd:	75 0c                	jne    8021cb <__umoddi3+0x13b>
  8021bf:	89 d7                	mov    %edx,%edi
  8021c1:	89 c6                	mov    %eax,%esi
  8021c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021cb:	89 ca                	mov    %ecx,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021d3:	29 f0                	sub    %esi,%eax
  8021d5:	19 fa                	sbb    %edi,%edx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021de:	89 d7                	mov    %edx,%edi
  8021e0:	d3 e7                	shl    %cl,%edi
  8021e2:	89 e9                	mov    %ebp,%ecx
  8021e4:	09 f8                	or     %edi,%eax
  8021e6:	d3 ea                	shr    %cl,%edx
  8021e8:	83 c4 20             	add    $0x20,%esp
  8021eb:	5e                   	pop    %esi
  8021ec:	5f                   	pop    %edi
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    
  8021ef:	90                   	nop
  8021f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021f4:	29 f9                	sub    %edi,%ecx
  8021f6:	19 c6                	sbb    %eax,%esi
  8021f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802200:	e9 ff fe ff ff       	jmp    802104 <__umoddi3+0x74>
