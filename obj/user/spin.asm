
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 00 22 80 00       	push   $0x802200
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 f7 0d 00 00       	call   800e40 <fork>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 12                	jne    800064 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800052:	83 ec 0c             	sub    $0xc,%esp
  800055:	68 78 22 80 00       	push   $0x802278
  80005a:	e8 49 01 00 00       	call   8001a8 <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		while (1)
			/* do nothing */;
  800062:	eb fe                	jmp    800062 <umain+0x2f>
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 22 80 00       	push   $0x802228
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 a1 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  800076:	e8 9c 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  80007b:	e8 97 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  800080:	e8 92 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  800085:	e8 8d 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  80008a:	e8 88 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  80008f:	e8 83 0a 00 00       	call   800b17 <sys_yield>
	sys_yield();
  800094:	e8 7e 0a 00 00       	call   800b17 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 50 22 80 00 	movl   $0x802250,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 0a 0a 00 00       	call   800ab7 <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 33 0a 00 00       	call   800af8 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 78             	imul   $0x78,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
  8000f1:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 ef 10 00 00       	call   8011f5 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a7 09 00 00       	call   800ab7 <sys_env_destroy>
  800110:	83 c4 10             	add    $0x10,%esp
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 35 09 00 00       	call   800a7a <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 4f 01 00 00       	call   8002da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 da 08 00 00       	call   800a7a <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 d1                	mov    %edx,%ecx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e7:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001ea:	72 05                	jb     8001f1 <printnum+0x35>
  8001ec:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001ef:	77 3e                	ja     80022f <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	50                   	push   %eax
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 10 1d 00 00       	call   801f20 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 02 1e 00 00       	call   802050 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff d7                	call   *%edi
  80025b:	83 c4 10             	add    $0x10,%esp
}
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800269:	83 fa 01             	cmp    $0x1,%edx
  80026c:	7e 0e                	jle    80027c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 08             	lea    0x8(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	8b 52 04             	mov    0x4(%edx),%edx
  80027a:	eb 22                	jmp    80029e <getuint+0x38>
	else if (lflag)
  80027c:	85 d2                	test   %edx,%edx
  80027e:	74 10                	je     800290 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	eb 0e                	jmp    80029e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8002af:	73 0a                	jae    8002bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	88 02                	mov    %al,(%edx)
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 10             	pushl  0x10(%ebp)
  8002ca:	ff 75 0c             	pushl  0xc(%ebp)
  8002cd:	ff 75 08             	pushl  0x8(%ebp)
  8002d0:	e8 05 00 00 00       	call   8002da <vprintfmt>
	va_end(ap);
  8002d5:	83 c4 10             	add    $0x10,%esp
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
  8002e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ec:	eb 12                	jmp    800300 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	0f 84 8d 03 00 00    	je     800683 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	53                   	push   %ebx
  8002fa:	50                   	push   %eax
  8002fb:	ff d6                	call   *%esi
  8002fd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800300:	83 c7 01             	add    $0x1,%edi
  800303:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800307:	83 f8 25             	cmp    $0x25,%eax
  80030a:	75 e2                	jne    8002ee <vprintfmt+0x14>
  80030c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800310:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800317:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
  80032a:	eb 07                	jmp    800333 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8d 47 01             	lea    0x1(%edi),%eax
  800336:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800339:	0f b6 07             	movzbl (%edi),%eax
  80033c:	0f b6 c8             	movzbl %al,%ecx
  80033f:	83 e8 23             	sub    $0x23,%eax
  800342:	3c 55                	cmp    $0x55,%al
  800344:	0f 87 1e 03 00 00    	ja     800668 <vprintfmt+0x38e>
  80034a:	0f b6 c0             	movzbl %al,%eax
  80034d:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800357:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035b:	eb d6                	jmp    800333 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800360:	b8 00 00 00 00       	mov    $0x0,%eax
  800365:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800368:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800372:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800375:	83 fa 09             	cmp    $0x9,%edx
  800378:	77 38                	ja     8003b2 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037d:	eb e9                	jmp    800368 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 48 04             	lea    0x4(%eax),%ecx
  800385:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800388:	8b 00                	mov    (%eax),%eax
  80038a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800390:	eb 26                	jmp    8003b8 <vprintfmt+0xde>
  800392:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800395:	89 c8                	mov    %ecx,%eax
  800397:	c1 f8 1f             	sar    $0x1f,%eax
  80039a:	f7 d0                	not    %eax
  80039c:	21 c1                	and    %eax,%ecx
  80039e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a4:	eb 8d                	jmp    800333 <vprintfmt+0x59>
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b0:	eb 81                	jmp    800333 <vprintfmt+0x59>
  8003b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bc:	0f 89 71 ff ff ff    	jns    800333 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cf:	e9 5f ff ff ff       	jmp    800333 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003da:	e9 54 ff ff ff       	jmp    800333 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	53                   	push   %ebx
  8003ec:	ff 30                	pushl  (%eax)
  8003ee:	ff d6                	call   *%esi
			break;
  8003f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f6:	e9 05 ff ff ff       	jmp    800300 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	8b 00                	mov    (%eax),%eax
  800406:	99                   	cltd   
  800407:	31 d0                	xor    %edx,%eax
  800409:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 0f             	cmp    $0xf,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x141>
  800410:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800417:	85 d2                	test   %edx,%edx
  800419:	75 18                	jne    800433 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80041b:	50                   	push   %eax
  80041c:	68 b8 22 80 00       	push   $0x8022b8
  800421:	53                   	push   %ebx
  800422:	56                   	push   %esi
  800423:	e8 95 fe ff ff       	call   8002bd <printfmt>
  800428:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042e:	e9 cd fe ff ff       	jmp    800300 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800433:	52                   	push   %edx
  800434:	68 41 27 80 00       	push   $0x802741
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 7d fe ff ff       	call   8002bd <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800446:	e9 b5 fe ff ff       	jmp    800300 <vprintfmt+0x26>
  80044b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80044e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800451:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
  80045f:	85 ff                	test   %edi,%edi
  800461:	75 05                	jne    800468 <vprintfmt+0x18e>
				p = "(null)";
  800463:	bf b1 22 80 00       	mov    $0x8022b1,%edi
			if (width > 0 && padc != '-')
  800468:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046c:	0f 84 91 00 00 00    	je     800503 <vprintfmt+0x229>
  800472:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800476:	0f 8e 95 00 00 00    	jle    800511 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	51                   	push   %ecx
  800480:	57                   	push   %edi
  800481:	e8 85 02 00 00       	call   80070b <strnlen>
  800486:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1d4>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c5>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	89 c8                	mov    %ecx,%eax
  8004ba:	c1 f8 1f             	sar    $0x1f,%eax
  8004bd:	f7 d0                	not    %eax
  8004bf:	21 c8                	and    %ecx,%eax
  8004c1:	29 c1                	sub    %eax,%ecx
  8004c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cc:	89 cb                	mov    %ecx,%ebx
  8004ce:	eb 4d                	jmp    80051d <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d4:	74 1b                	je     8004f1 <vprintfmt+0x217>
  8004d6:	0f be c0             	movsbl %al,%eax
  8004d9:	83 e8 20             	sub    $0x20,%eax
  8004dc:	83 f8 5e             	cmp    $0x5e,%eax
  8004df:	76 10                	jbe    8004f1 <vprintfmt+0x217>
					putch('?', putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	6a 3f                	push   $0x3f
  8004e9:	ff 55 08             	call   *0x8(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	eb 0d                	jmp    8004fe <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	52                   	push   %edx
  8004f8:	ff 55 08             	call   *0x8(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	83 eb 01             	sub    $0x1,%ebx
  800501:	eb 1a                	jmp    80051d <vprintfmt+0x243>
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050f:	eb 0c                	jmp    80051d <vprintfmt+0x243>
  800511:	89 75 08             	mov    %esi,0x8(%ebp)
  800514:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800517:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051d:	83 c7 01             	add    $0x1,%edi
  800520:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800524:	0f be d0             	movsbl %al,%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	74 23                	je     80054e <vprintfmt+0x274>
  80052b:	85 f6                	test   %esi,%esi
  80052d:	78 a1                	js     8004d0 <vprintfmt+0x1f6>
  80052f:	83 ee 01             	sub    $0x1,%esi
  800532:	79 9c                	jns    8004d0 <vprintfmt+0x1f6>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x27c>
  80054e:	89 df                	mov    %ebx,%edi
  800550:	8b 75 08             	mov    0x8(%ebp),%esi
  800553:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800556:	85 ff                	test   %edi,%edi
  800558:	7f e4                	jg     80053e <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	e9 9e fd ff ff       	jmp    800300 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800562:	83 fa 01             	cmp    $0x1,%edx
  800565:	7e 16                	jle    80057d <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 08             	lea    0x8(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 50 04             	mov    0x4(%eax),%edx
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	eb 32                	jmp    8005af <vprintfmt+0x2d5>
	else if (lflag)
  80057d:	85 d2                	test   %edx,%edx
  80057f:	74 18                	je     800599 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 c1                	mov    %eax,%ecx
  800591:	c1 f9 1f             	sar    $0x1f,%ecx
  800594:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800597:	eb 16                	jmp    8005af <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 c1                	mov    %eax,%ecx
  8005a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	79 74                	jns    800634 <vprintfmt+0x35a>
				putch('-', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 2d                	push   $0x2d
  8005c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ce:	f7 d8                	neg    %eax
  8005d0:	83 d2 00             	adc    $0x0,%edx
  8005d3:	f7 da                	neg    %edx
  8005d5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005dd:	eb 55                	jmp    800634 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 7f fc ff ff       	call   800266 <getuint>
			base = 10;
  8005e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ec:	eb 46                	jmp    800634 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 70 fc ff ff       	call   800266 <getuint>
			base = 8;
  8005f6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fb:	eb 37                	jmp    800634 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 30                	push   $0x30
  800603:	ff d6                	call   *%esi
			putch('x', putdat);
  800605:	83 c4 08             	add    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 78                	push   $0x78
  80060b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800620:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800625:	eb 0d                	jmp    800634 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 37 fc ff ff       	call   800266 <getuint>
			base = 16;
  80062f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063b:	57                   	push   %edi
  80063c:	ff 75 e0             	pushl  -0x20(%ebp)
  80063f:	51                   	push   %ecx
  800640:	52                   	push   %edx
  800641:	50                   	push   %eax
  800642:	89 da                	mov    %ebx,%edx
  800644:	89 f0                	mov    %esi,%eax
  800646:	e8 71 fb ff ff       	call   8001bc <printnum>
			break;
  80064b:	83 c4 20             	add    $0x20,%esp
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800651:	e9 aa fc ff ff       	jmp    800300 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	51                   	push   %ecx
  80065b:	ff d6                	call   *%esi
			break;
  80065d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800663:	e9 98 fc ff ff       	jmp    800300 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 25                	push   $0x25
  80066e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb 03                	jmp    800678 <vprintfmt+0x39e>
  800675:	83 ef 01             	sub    $0x1,%edi
  800678:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067c:	75 f7                	jne    800675 <vprintfmt+0x39b>
  80067e:	e9 7d fc ff ff       	jmp    800300 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800686:	5b                   	pop    %ebx
  800687:	5e                   	pop    %esi
  800688:	5f                   	pop    %edi
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	83 ec 18             	sub    $0x18,%esp
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	74 26                	je     8006d2 <vsnprintf+0x47>
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	7e 22                	jle    8006d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b0:	ff 75 14             	pushl  0x14(%ebp)
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	68 a0 02 80 00       	push   $0x8002a0
  8006bf:	e8 16 fc ff ff       	call   8002da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	eb 05                	jmp    8006d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e2:	50                   	push   %eax
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	ff 75 08             	pushl  0x8(%ebp)
  8006ec:	e8 9a ff ff ff       	call   80068b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fe:	eb 03                	jmp    800703 <strlen+0x10>
		n++;
  800700:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800707:	75 f7                	jne    800700 <strlen+0xd>
		n++;
	return n;
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800714:	ba 00 00 00 00       	mov    $0x0,%edx
  800719:	eb 03                	jmp    80071e <strnlen+0x13>
		n++;
  80071b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	39 c2                	cmp    %eax,%edx
  800720:	74 08                	je     80072a <strnlen+0x1f>
  800722:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800726:	75 f3                	jne    80071b <strnlen+0x10>
  800728:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800736:	89 c2                	mov    %eax,%edx
  800738:	83 c2 01             	add    $0x1,%edx
  80073b:	83 c1 01             	add    $0x1,%ecx
  80073e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800742:	88 5a ff             	mov    %bl,-0x1(%edx)
  800745:	84 db                	test   %bl,%bl
  800747:	75 ef                	jne    800738 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800749:	5b                   	pop    %ebx
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800753:	53                   	push   %ebx
  800754:	e8 9a ff ff ff       	call   8006f3 <strlen>
  800759:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	01 d8                	add    %ebx,%eax
  800761:	50                   	push   %eax
  800762:	e8 c5 ff ff ff       	call   80072c <strcpy>
	return dst;
}
  800767:	89 d8                	mov    %ebx,%eax
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	56                   	push   %esi
  800772:	53                   	push   %ebx
  800773:	8b 75 08             	mov    0x8(%ebp),%esi
  800776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800779:	89 f3                	mov    %esi,%ebx
  80077b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	89 f2                	mov    %esi,%edx
  800780:	eb 0f                	jmp    800791 <strncpy+0x23>
		*dst++ = *src;
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	0f b6 01             	movzbl (%ecx),%eax
  800788:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078b:	80 39 01             	cmpb   $0x1,(%ecx)
  80078e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	39 da                	cmp    %ebx,%edx
  800793:	75 ed                	jne    800782 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800795:	89 f0                	mov    %esi,%eax
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 21                	je     8007d0 <strlcpy+0x35>
  8007af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b3:	89 f2                	mov    %esi,%edx
  8007b5:	eb 09                	jmp    8007c0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c0:	39 c2                	cmp    %eax,%edx
  8007c2:	74 09                	je     8007cd <strlcpy+0x32>
  8007c4:	0f b6 19             	movzbl (%ecx),%ebx
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ec                	jne    8007b7 <strlcpy+0x1c>
  8007cb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d0:	29 f0                	sub    %esi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007df:	eb 06                	jmp    8007e7 <strcmp+0x11>
		p++, q++;
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e7:	0f b6 01             	movzbl (%ecx),%eax
  8007ea:	84 c0                	test   %al,%al
  8007ec:	74 04                	je     8007f2 <strcmp+0x1c>
  8007ee:	3a 02                	cmp    (%edx),%al
  8007f0:	74 ef                	je     8007e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f2:	0f b6 c0             	movzbl %al,%eax
  8007f5:	0f b6 12             	movzbl (%edx),%edx
  8007f8:	29 d0                	sub    %edx,%eax
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 c3                	mov    %eax,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080b:	eb 06                	jmp    800813 <strncmp+0x17>
		n--, p++, q++;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800813:	39 d8                	cmp    %ebx,%eax
  800815:	74 15                	je     80082c <strncmp+0x30>
  800817:	0f b6 08             	movzbl (%eax),%ecx
  80081a:	84 c9                	test   %cl,%cl
  80081c:	74 04                	je     800822 <strncmp+0x26>
  80081e:	3a 0a                	cmp    (%edx),%cl
  800820:	74 eb                	je     80080d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 00             	movzbl (%eax),%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
  80082a:	eb 05                	jmp    800831 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083e:	eb 07                	jmp    800847 <strchr+0x13>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	74 0f                	je     800853 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800844:	83 c0 01             	add    $0x1,%eax
  800847:	0f b6 10             	movzbl (%eax),%edx
  80084a:	84 d2                	test   %dl,%dl
  80084c:	75 f2                	jne    800840 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	eb 03                	jmp    800864 <strfind+0xf>
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800867:	84 d2                	test   %dl,%dl
  800869:	74 04                	je     80086f <strfind+0x1a>
  80086b:	38 ca                	cmp    %cl,%dl
  80086d:	75 f2                	jne    800861 <strfind+0xc>
			break;
	return (char *) s;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 36                	je     8008b7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800881:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800887:	75 28                	jne    8008b1 <memset+0x40>
  800889:	f6 c1 03             	test   $0x3,%cl
  80088c:	75 23                	jne    8008b1 <memset+0x40>
		c &= 0xFF;
  80088e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800892:	89 d3                	mov    %edx,%ebx
  800894:	c1 e3 08             	shl    $0x8,%ebx
  800897:	89 d6                	mov    %edx,%esi
  800899:	c1 e6 18             	shl    $0x18,%esi
  80089c:	89 d0                	mov    %edx,%eax
  80089e:	c1 e0 10             	shl    $0x10,%eax
  8008a1:	09 f0                	or     %esi,%eax
  8008a3:	09 c2                	or     %eax,%edx
  8008a5:	89 d0                	mov    %edx,%eax
  8008a7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ac:	fc                   	cld    
  8008ad:	f3 ab                	rep stos %eax,%es:(%edi)
  8008af:	eb 06                	jmp    8008b7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	fc                   	cld    
  8008b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cc:	39 c6                	cmp    %eax,%esi
  8008ce:	73 35                	jae    800905 <memmove+0x47>
  8008d0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d3:	39 d0                	cmp    %edx,%eax
  8008d5:	73 2e                	jae    800905 <memmove+0x47>
		s += n;
		d += n;
  8008d7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e4:	75 13                	jne    8008f9 <memmove+0x3b>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0e                	jne    8008f9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008eb:	83 ef 04             	sub    $0x4,%edi
  8008ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 09                	jmp    800902 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f9:	83 ef 01             	sub    $0x1,%edi
  8008fc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ff:	fd                   	std    
  800900:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800902:	fc                   	cld    
  800903:	eb 1d                	jmp    800922 <memmove+0x64>
  800905:	89 f2                	mov    %esi,%edx
  800907:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800909:	f6 c2 03             	test   $0x3,%dl
  80090c:	75 0f                	jne    80091d <memmove+0x5f>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0a                	jne    80091d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800913:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 05                	jmp    800922 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 87 ff ff ff       	call   8008be <memmove>
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
  800944:	89 c6                	mov    %eax,%esi
  800946:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800949:	eb 1a                	jmp    800965 <memcmp+0x2c>
		if (*s1 != *s2)
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	0f b6 1a             	movzbl (%edx),%ebx
  800951:	38 d9                	cmp    %bl,%cl
  800953:	74 0a                	je     80095f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800955:	0f b6 c1             	movzbl %cl,%eax
  800958:	0f b6 db             	movzbl %bl,%ebx
  80095b:	29 d8                	sub    %ebx,%eax
  80095d:	eb 0f                	jmp    80096e <memcmp+0x35>
		s1++, s2++;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800965:	39 f0                	cmp    %esi,%eax
  800967:	75 e2                	jne    80094b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097b:	89 c2                	mov    %eax,%edx
  80097d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800980:	eb 07                	jmp    800989 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800982:	38 08                	cmp    %cl,(%eax)
  800984:	74 07                	je     80098d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	72 f5                	jb     800982 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099b:	eb 03                	jmp    8009a0 <strtol+0x11>
		s++;
  80099d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	0f b6 01             	movzbl (%ecx),%eax
  8009a3:	3c 09                	cmp    $0x9,%al
  8009a5:	74 f6                	je     80099d <strtol+0xe>
  8009a7:	3c 20                	cmp    $0x20,%al
  8009a9:	74 f2                	je     80099d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ab:	3c 2b                	cmp    $0x2b,%al
  8009ad:	75 0a                	jne    8009b9 <strtol+0x2a>
		s++;
  8009af:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 10                	jmp    8009c9 <strtol+0x3a>
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009be:	3c 2d                	cmp    $0x2d,%al
  8009c0:	75 07                	jne    8009c9 <strtol+0x3a>
		s++, neg = 1;
  8009c2:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009c5:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	0f 94 c0             	sete   %al
  8009ce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d4:	75 19                	jne    8009ef <strtol+0x60>
  8009d6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d9:	75 14                	jne    8009ef <strtol+0x60>
  8009db:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009df:	0f 85 8a 00 00 00    	jne    800a6f <strtol+0xe0>
		s += 2, base = 16;
  8009e5:	83 c1 02             	add    $0x2,%ecx
  8009e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ed:	eb 16                	jmp    800a05 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009ef:	84 c0                	test   %al,%al
  8009f1:	74 12                	je     800a05 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fb:	75 08                	jne    800a05 <strtol+0x76>
		s++, base = 8;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0d:	0f b6 11             	movzbl (%ecx),%edx
  800a10:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 09             	cmp    $0x9,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x93>
			dig = *s - '0';
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 30             	sub    $0x30,%edx
  800a20:	eb 22                	jmp    800a44 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 57             	sub    $0x57,%edx
  800a32:	eb 10                	jmp    800a44 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 16                	ja     800a54 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a3e:	0f be d2             	movsbl %dl,%edx
  800a41:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a44:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a47:	7d 0f                	jge    800a58 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a50:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a52:	eb b9                	jmp    800a0d <strtol+0x7e>
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	eb 02                	jmp    800a5a <strtol+0xcb>
  800a58:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5e:	74 05                	je     800a65 <strtol+0xd6>
		*endptr = (char *) s;
  800a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a63:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a65:	85 ff                	test   %edi,%edi
  800a67:	74 0c                	je     800a75 <strtol+0xe6>
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	f7 d8                	neg    %eax
  800a6d:	eb 06                	jmp    800a75 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6f:	84 c0                	test   %al,%al
  800a71:	75 8a                	jne    8009fd <strtol+0x6e>
  800a73:	eb 90                	jmp    800a05 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	89 c3                	mov    %eax,%ebx
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	89 c6                	mov    %eax,%esi
  800a91:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa3:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa8:	89 d1                	mov    %edx,%ecx
  800aaa:	89 d3                	mov    %edx,%ebx
  800aac:	89 d7                	mov    %edx,%edi
  800aae:	89 d6                	mov    %edx,%esi
  800ab0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aca:	8b 55 08             	mov    0x8(%ebp),%edx
  800acd:	89 cb                	mov    %ecx,%ebx
  800acf:	89 cf                	mov    %ecx,%edi
  800ad1:	89 ce                	mov    %ecx,%esi
  800ad3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	7e 17                	jle    800af0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	50                   	push   %eax
  800add:	6a 03                	push   $0x3
  800adf:	68 df 25 80 00       	push   $0x8025df
  800ae4:	6a 23                	push   $0x23
  800ae6:	68 fc 25 80 00       	push   $0x8025fc
  800aeb:	e8 1e 12 00 00       	call   801d0e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 02 00 00 00       	mov    $0x2,%eax
  800b08:	89 d1                	mov    %edx,%ecx
  800b0a:	89 d3                	mov    %edx,%ebx
  800b0c:	89 d7                	mov    %edx,%edi
  800b0e:	89 d6                	mov    %edx,%esi
  800b10:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_yield>:

void
sys_yield(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b27:	89 d1                	mov    %edx,%ecx
  800b29:	89 d3                	mov    %edx,%ebx
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	be 00 00 00 00       	mov    $0x0,%esi
  800b44:	b8 04 00 00 00       	mov    $0x4,%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b52:	89 f7                	mov    %esi,%edi
  800b54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	7e 17                	jle    800b71 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 04                	push   $0x4
  800b60:	68 df 25 80 00       	push   $0x8025df
  800b65:	6a 23                	push   $0x23
  800b67:	68 fc 25 80 00       	push   $0x8025fc
  800b6c:	e8 9d 11 00 00       	call   801d0e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 05 00 00 00       	mov    $0x5,%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b90:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b93:	8b 75 18             	mov    0x18(%ebp),%esi
  800b96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7e 17                	jle    800bb3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 05                	push   $0x5
  800ba2:	68 df 25 80 00       	push   $0x8025df
  800ba7:	6a 23                	push   $0x23
  800ba9:	68 fc 25 80 00       	push   $0x8025fc
  800bae:	e8 5b 11 00 00       	call   801d0e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	89 df                	mov    %ebx,%edi
  800bd6:	89 de                	mov    %ebx,%esi
  800bd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 06                	push   $0x6
  800be4:	68 df 25 80 00       	push   $0x8025df
  800be9:	6a 23                	push   $0x23
  800beb:	68 fc 25 80 00       	push   $0x8025fc
  800bf0:	e8 19 11 00 00       	call   801d0e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	89 de                	mov    %ebx,%esi
  800c1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 08                	push   $0x8
  800c26:	68 df 25 80 00       	push   $0x8025df
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 fc 25 80 00       	push   $0x8025fc
  800c32:	e8 d7 10 00 00       	call   801d0e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 09                	push   $0x9
  800c68:	68 df 25 80 00       	push   $0x8025df
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 fc 25 80 00       	push   $0x8025fc
  800c74:	e8 95 10 00 00       	call   801d0e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 0a                	push   $0xa
  800caa:	68 df 25 80 00       	push   $0x8025df
  800caf:	6a 23                	push   $0x23
  800cb1:	68 fc 25 80 00       	push   $0x8025fc
  800cb6:	e8 53 10 00 00       	call   801d0e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	be 00 00 00 00       	mov    $0x0,%esi
  800cce:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 cb                	mov    %ecx,%ebx
  800cfe:	89 cf                	mov    %ecx,%edi
  800d00:	89 ce                	mov    %ecx,%esi
  800d02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 0d                	push   $0xd
  800d0e:	68 df 25 80 00       	push   $0x8025df
  800d13:	6a 23                	push   $0x23
  800d15:	68 fc 25 80 00       	push   $0x8025fc
  800d1a:	e8 ef 0f 00 00       	call   801d0e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_gettime>:

int sys_gettime(void)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d32:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d37:	89 d1                	mov    %edx,%ecx
  800d39:	89 d3                	mov    %edx,%ebx
  800d3b:	89 d7                	mov    %edx,%edi
  800d3d:	89 d6                	mov    %edx,%esi
  800d3f:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800d50:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d52:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d56:	74 2e                	je     800d86 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	c1 ea 16             	shr    $0x16,%edx
  800d5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d64:	f6 c2 01             	test   $0x1,%dl
  800d67:	74 1d                	je     800d86 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	c1 ea 0c             	shr    $0xc,%edx
  800d6e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800d75:	f6 c1 01             	test   $0x1,%cl
  800d78:	74 0c                	je     800d86 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800d7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d81:	f6 c6 08             	test   $0x8,%dh
  800d84:	75 14                	jne    800d9a <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 0a 26 80 00       	push   $0x80260a
  800d8e:	6a 28                	push   $0x28
  800d90:	68 1c 26 80 00       	push   $0x80261c
  800d95:	e8 74 0f 00 00       	call   801d0e <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800d9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9f:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	6a 07                	push   $0x7
  800da6:	68 00 f0 7f 00       	push   $0x7ff000
  800dab:	6a 00                	push   $0x0
  800dad:	e8 84 fd ff ff       	call   800b36 <sys_page_alloc>
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	79 14                	jns    800dcd <pgfault+0x87>
		panic("sys_page_alloc");
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 27 26 80 00       	push   $0x802627
  800dc1:	6a 2c                	push   $0x2c
  800dc3:	68 1c 26 80 00       	push   $0x80261c
  800dc8:	e8 41 0f 00 00       	call   801d0e <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	68 00 10 00 00       	push   $0x1000
  800dd5:	53                   	push   %ebx
  800dd6:	68 00 f0 7f 00       	push   $0x7ff000
  800ddb:	e8 46 fb ff ff       	call   800926 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800de0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800de7:	53                   	push   %ebx
  800de8:	6a 00                	push   $0x0
  800dea:	68 00 f0 7f 00       	push   $0x7ff000
  800def:	6a 00                	push   $0x0
  800df1:	e8 83 fd ff ff       	call   800b79 <sys_page_map>
  800df6:	83 c4 20             	add    $0x20,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	79 14                	jns    800e11 <pgfault+0xcb>
		panic("sys_page_map");
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	68 36 26 80 00       	push   $0x802636
  800e05:	6a 2f                	push   $0x2f
  800e07:	68 1c 26 80 00       	push   $0x80261c
  800e0c:	e8 fd 0e 00 00       	call   801d0e <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e11:	83 ec 08             	sub    $0x8,%esp
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 9b fd ff ff       	call   800bbb <sys_page_unmap>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 14                	jns    800e3b <pgfault+0xf5>
		panic("sys_page_unmap");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 43 26 80 00       	push   $0x802643
  800e2f:	6a 31                	push   $0x31
  800e31:	68 1c 26 80 00       	push   $0x80261c
  800e36:	e8 d3 0e 00 00       	call   801d0e <_panic>
	return;
}
  800e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800e49:	68 46 0d 80 00       	push   $0x800d46
  800e4e:	e8 01 0f 00 00       	call   801d54 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e53:	b8 07 00 00 00       	mov    $0x7,%eax
  800e58:	cd 30                	int    $0x30
  800e5a:	89 c7                	mov    %eax,%edi
  800e5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	75 21                	jne    800e87 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e66:	e8 8d fc ff ff       	call   800af8 <sys_getenvid>
  800e6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e70:	6b c0 78             	imul   $0x78,%eax,%eax
  800e73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e78:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e82:	e9 80 01 00 00       	jmp    801007 <fork+0x1c7>
	}
	if (envid < 0)
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 12                	jns    800e9d <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800e8b:	50                   	push   %eax
  800e8c:	68 52 26 80 00       	push   $0x802652
  800e91:	6a 70                	push   $0x70
  800e93:	68 1c 26 80 00       	push   $0x80261c
  800e98:	e8 71 0e 00 00       	call   801d0e <_panic>
  800e9d:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800ea2:	89 d8                	mov    %ebx,%eax
  800ea4:	c1 e8 16             	shr    $0x16,%eax
  800ea7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eae:	a8 01                	test   $0x1,%al
  800eb0:	0f 84 de 00 00 00    	je     800f94 <fork+0x154>
  800eb6:	89 de                	mov    %ebx,%esi
  800eb8:	c1 ee 0c             	shr    $0xc,%esi
  800ebb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ec2:	a8 01                	test   $0x1,%al
  800ec4:	0f 84 ca 00 00 00    	je     800f94 <fork+0x154>
  800eca:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed1:	a8 04                	test   $0x4,%al
  800ed3:	0f 84 bb 00 00 00    	je     800f94 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800ed9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800ee0:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800ee3:	f6 c4 04             	test   $0x4,%ah
  800ee6:	74 34                	je     800f1c <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef0:	50                   	push   %eax
  800ef1:	56                   	push   %esi
  800ef2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef5:	56                   	push   %esi
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 7c fc ff ff       	call   800b79 <sys_page_map>
  800efd:	83 c4 20             	add    $0x20,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	0f 84 8c 00 00 00    	je     800f94 <fork+0x154>
        	panic("duppage share");
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 62 26 80 00       	push   $0x802662
  800f10:	6a 48                	push   $0x48
  800f12:	68 1c 26 80 00       	push   $0x80261c
  800f17:	e8 f2 0d 00 00       	call   801d0e <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f1c:	a9 02 08 00 00       	test   $0x802,%eax
  800f21:	74 5d                	je     800f80 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	68 05 08 00 00       	push   $0x805
  800f2b:	56                   	push   %esi
  800f2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2f:	56                   	push   %esi
  800f30:	6a 00                	push   $0x0
  800f32:	e8 42 fc ff ff       	call   800b79 <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 14                	jns    800f52 <fork+0x112>
			panic("error");
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	68 cd 22 80 00       	push   $0x8022cd
  800f46:	6a 4b                	push   $0x4b
  800f48:	68 1c 26 80 00       	push   $0x80261c
  800f4d:	e8 bc 0d 00 00       	call   801d0e <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	68 05 08 00 00       	push   $0x805
  800f5a:	56                   	push   %esi
  800f5b:	6a 00                	push   $0x0
  800f5d:	56                   	push   %esi
  800f5e:	6a 00                	push   $0x0
  800f60:	e8 14 fc ff ff       	call   800b79 <sys_page_map>
  800f65:	83 c4 20             	add    $0x20,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 28                	jns    800f94 <fork+0x154>
			panic("error");
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 cd 22 80 00       	push   $0x8022cd
  800f74:	6a 4d                	push   $0x4d
  800f76:	68 1c 26 80 00       	push   $0x80261c
  800f7b:	e8 8e 0d 00 00       	call   801d0e <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	6a 05                	push   $0x5
  800f85:	56                   	push   %esi
  800f86:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f89:	56                   	push   %esi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 e8 fb ff ff       	call   800b79 <sys_page_map>
  800f91:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9a:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  800fa0:	0f 85 fc fe ff ff    	jne    800ea2 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	68 00 f0 7f ee       	push   $0xee7ff000
  800fb0:	57                   	push   %edi
  800fb1:	e8 80 fb ff ff       	call   800b36 <sys_page_alloc>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 14                	jns    800fd1 <fork+0x191>
		panic("1");
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	68 70 26 80 00       	push   $0x802670
  800fc5:	6a 78                	push   $0x78
  800fc7:	68 1c 26 80 00       	push   $0x80261c
  800fcc:	e8 3d 0d 00 00       	call   801d0e <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fd1:	83 ec 08             	sub    $0x8,%esp
  800fd4:	68 c3 1d 80 00       	push   $0x801dc3
  800fd9:	57                   	push   %edi
  800fda:	e8 a2 fc ff ff       	call   800c81 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	6a 02                	push   $0x2
  800fe4:	57                   	push   %edi
  800fe5:	e8 13 fc ff ff       	call   800bfd <sys_env_set_status>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	79 14                	jns    801005 <fork+0x1c5>
		panic("sys_env_set_status");
  800ff1:	83 ec 04             	sub    $0x4,%esp
  800ff4:	68 72 26 80 00       	push   $0x802672
  800ff9:	6a 7d                	push   $0x7d
  800ffb:	68 1c 26 80 00       	push   $0x80261c
  801000:	e8 09 0d 00 00       	call   801d0e <_panic>

	return envid;
  801005:	89 f8                	mov    %edi,%eax
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sfork>:

// Challenge!
int
sfork(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801015:	68 85 26 80 00       	push   $0x802685
  80101a:	68 86 00 00 00       	push   $0x86
  80101f:	68 1c 26 80 00       	push   $0x80261c
  801024:	e8 e5 0c 00 00       	call   801d0e <_panic>

00801029 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	05 00 00 00 30       	add    $0x30000000,%eax
  801034:	c1 e8 0c             	shr    $0xc,%eax
}
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801049:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801056:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80105b:	89 c2                	mov    %eax,%edx
  80105d:	c1 ea 16             	shr    $0x16,%edx
  801060:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801067:	f6 c2 01             	test   $0x1,%dl
  80106a:	74 11                	je     80107d <fd_alloc+0x2d>
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	c1 ea 0c             	shr    $0xc,%edx
  801071:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801078:	f6 c2 01             	test   $0x1,%dl
  80107b:	75 09                	jne    801086 <fd_alloc+0x36>
			*fd_store = fd;
  80107d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
  801084:	eb 17                	jmp    80109d <fd_alloc+0x4d>
  801086:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80108b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801090:	75 c9                	jne    80105b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801092:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801098:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a5:	83 f8 1f             	cmp    $0x1f,%eax
  8010a8:	77 36                	ja     8010e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010aa:	c1 e0 0c             	shl    $0xc,%eax
  8010ad:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 ea 16             	shr    $0x16,%edx
  8010b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	74 24                	je     8010e7 <fd_lookup+0x48>
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	c1 ea 0c             	shr    $0xc,%edx
  8010c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cf:	f6 c2 01             	test   $0x1,%dl
  8010d2:	74 1a                	je     8010ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	eb 13                	jmp    8010f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e5:	eb 0c                	jmp    8010f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 05                	jmp    8010f3 <fd_lookup+0x54>
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	ba 18 27 80 00       	mov    $0x802718,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801103:	eb 13                	jmp    801118 <dev_lookup+0x23>
  801105:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801108:	39 08                	cmp    %ecx,(%eax)
  80110a:	75 0c                	jne    801118 <dev_lookup+0x23>
			*dev = devtab[i];
  80110c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801111:	b8 00 00 00 00       	mov    $0x0,%eax
  801116:	eb 2e                	jmp    801146 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801118:	8b 02                	mov    (%edx),%eax
  80111a:	85 c0                	test   %eax,%eax
  80111c:	75 e7                	jne    801105 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80111e:	a1 04 40 80 00       	mov    0x804004,%eax
  801123:	8b 40 48             	mov    0x48(%eax),%eax
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	51                   	push   %ecx
  80112a:	50                   	push   %eax
  80112b:	68 9c 26 80 00       	push   $0x80269c
  801130:	e8 73 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801135:	8b 45 0c             	mov    0xc(%ebp),%eax
  801138:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 10             	sub    $0x10,%esp
  801150:	8b 75 08             	mov    0x8(%ebp),%esi
  801153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801163:	50                   	push   %eax
  801164:	e8 36 ff ff ff       	call   80109f <fd_lookup>
  801169:	83 c4 08             	add    $0x8,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 05                	js     801175 <fd_close+0x2d>
	    || fd != fd2)
  801170:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801173:	74 0b                	je     801180 <fd_close+0x38>
		return (must_exist ? r : 0);
  801175:	80 fb 01             	cmp    $0x1,%bl
  801178:	19 d2                	sbb    %edx,%edx
  80117a:	f7 d2                	not    %edx
  80117c:	21 d0                	and    %edx,%eax
  80117e:	eb 41                	jmp    8011c1 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	ff 36                	pushl  (%esi)
  801189:	e8 67 ff ff ff       	call   8010f5 <dev_lookup>
  80118e:	89 c3                	mov    %eax,%ebx
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 1a                	js     8011b1 <fd_close+0x69>
		if (dev->dev_close)
  801197:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80119d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	74 0b                	je     8011b1 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	56                   	push   %esi
  8011aa:	ff d0                	call   *%eax
  8011ac:	89 c3                	mov    %eax,%ebx
  8011ae:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 ff f9 ff ff       	call   800bbb <sys_page_unmap>
	return r;
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	89 d8                	mov    %ebx,%eax
}
  8011c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	ff 75 08             	pushl  0x8(%ebp)
  8011d5:	e8 c5 fe ff ff       	call   80109f <fd_lookup>
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 d2                	test   %edx,%edx
  8011e1:	78 10                	js     8011f3 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	6a 01                	push   $0x1
  8011e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8011eb:	e8 58 ff ff ff       	call   801148 <fd_close>
  8011f0:	83 c4 10             	add    $0x10,%esp
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <close_all>:

void
close_all(void)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	53                   	push   %ebx
  801205:	e8 be ff ff ff       	call   8011c8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80120a:	83 c3 01             	add    $0x1,%ebx
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	83 fb 20             	cmp    $0x20,%ebx
  801213:	75 ec                	jne    801201 <close_all+0xc>
		close(i);
}
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 2c             	sub    $0x2c,%esp
  801223:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801226:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	ff 75 08             	pushl  0x8(%ebp)
  80122d:	e8 6d fe ff ff       	call   80109f <fd_lookup>
  801232:	89 c2                	mov    %eax,%edx
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	85 d2                	test   %edx,%edx
  801239:	0f 88 c1 00 00 00    	js     801300 <dup+0xe6>
		return r;
	close(newfdnum);
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	56                   	push   %esi
  801243:	e8 80 ff ff ff       	call   8011c8 <close>

	newfd = INDEX2FD(newfdnum);
  801248:	89 f3                	mov    %esi,%ebx
  80124a:	c1 e3 0c             	shl    $0xc,%ebx
  80124d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801253:	83 c4 04             	add    $0x4,%esp
  801256:	ff 75 e4             	pushl  -0x1c(%ebp)
  801259:	e8 db fd ff ff       	call   801039 <fd2data>
  80125e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801260:	89 1c 24             	mov    %ebx,(%esp)
  801263:	e8 d1 fd ff ff       	call   801039 <fd2data>
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80126e:	89 f8                	mov    %edi,%eax
  801270:	c1 e8 16             	shr    $0x16,%eax
  801273:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127a:	a8 01                	test   $0x1,%al
  80127c:	74 37                	je     8012b5 <dup+0x9b>
  80127e:	89 f8                	mov    %edi,%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
  801283:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	74 26                	je     8012b5 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80128f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	25 07 0e 00 00       	and    $0xe07,%eax
  80129e:	50                   	push   %eax
  80129f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012a2:	6a 00                	push   $0x0
  8012a4:	57                   	push   %edi
  8012a5:	6a 00                	push   $0x0
  8012a7:	e8 cd f8 ff ff       	call   800b79 <sys_page_map>
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	83 c4 20             	add    $0x20,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 2e                	js     8012e3 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012b8:	89 d0                	mov    %edx,%eax
  8012ba:	c1 e8 0c             	shr    $0xc,%eax
  8012bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cc:	50                   	push   %eax
  8012cd:	53                   	push   %ebx
  8012ce:	6a 00                	push   $0x0
  8012d0:	52                   	push   %edx
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 a1 f8 ff ff       	call   800b79 <sys_page_map>
  8012d8:	89 c7                	mov    %eax,%edi
  8012da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012df:	85 ff                	test   %edi,%edi
  8012e1:	79 1d                	jns    801300 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 cd f8 ff ff       	call   800bbb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012ee:	83 c4 08             	add    $0x8,%esp
  8012f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 c0 f8 ff ff       	call   800bbb <sys_page_unmap>
	return r;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	89 f8                	mov    %edi,%eax
}
  801300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 14             	sub    $0x14,%esp
  80130f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801312:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	53                   	push   %ebx
  801317:	e8 83 fd ff ff       	call   80109f <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	89 c2                	mov    %eax,%edx
  801321:	85 c0                	test   %eax,%eax
  801323:	78 6d                	js     801392 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	ff 30                	pushl  (%eax)
  801331:	e8 bf fd ff ff       	call   8010f5 <dev_lookup>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 4c                	js     801389 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80133d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801340:	8b 42 08             	mov    0x8(%edx),%eax
  801343:	83 e0 03             	and    $0x3,%eax
  801346:	83 f8 01             	cmp    $0x1,%eax
  801349:	75 21                	jne    80136c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80134b:	a1 04 40 80 00       	mov    0x804004,%eax
  801350:	8b 40 48             	mov    0x48(%eax),%eax
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	53                   	push   %ebx
  801357:	50                   	push   %eax
  801358:	68 dd 26 80 00       	push   $0x8026dd
  80135d:	e8 46 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136a:	eb 26                	jmp    801392 <read+0x8a>
	}
	if (!dev->dev_read)
  80136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136f:	8b 40 08             	mov    0x8(%eax),%eax
  801372:	85 c0                	test   %eax,%eax
  801374:	74 17                	je     80138d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801376:	83 ec 04             	sub    $0x4,%esp
  801379:	ff 75 10             	pushl  0x10(%ebp)
  80137c:	ff 75 0c             	pushl  0xc(%ebp)
  80137f:	52                   	push   %edx
  801380:	ff d0                	call   *%eax
  801382:	89 c2                	mov    %eax,%edx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	eb 09                	jmp    801392 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	89 c2                	mov    %eax,%edx
  80138b:	eb 05                	jmp    801392 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80138d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801392:	89 d0                	mov    %edx,%eax
  801394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	57                   	push   %edi
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ad:	eb 21                	jmp    8013d0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	89 f0                	mov    %esi,%eax
  8013b4:	29 d8                	sub    %ebx,%eax
  8013b6:	50                   	push   %eax
  8013b7:	89 d8                	mov    %ebx,%eax
  8013b9:	03 45 0c             	add    0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	57                   	push   %edi
  8013be:	e8 45 ff ff ff       	call   801308 <read>
		if (m < 0)
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 0c                	js     8013d6 <readn+0x3d>
			return m;
		if (m == 0)
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 06                	je     8013d4 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ce:	01 c3                	add    %eax,%ebx
  8013d0:	39 f3                	cmp    %esi,%ebx
  8013d2:	72 db                	jb     8013af <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8013d4:	89 d8                	mov    %ebx,%eax
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 14             	sub    $0x14,%esp
  8013e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	53                   	push   %ebx
  8013ed:	e8 ad fc ff ff       	call   80109f <fd_lookup>
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 68                	js     801463 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801405:	ff 30                	pushl  (%eax)
  801407:	e8 e9 fc ff ff       	call   8010f5 <dev_lookup>
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 47                	js     80145a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801413:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801416:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80141a:	75 21                	jne    80143d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80141c:	a1 04 40 80 00       	mov    0x804004,%eax
  801421:	8b 40 48             	mov    0x48(%eax),%eax
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	53                   	push   %ebx
  801428:	50                   	push   %eax
  801429:	68 f9 26 80 00       	push   $0x8026f9
  80142e:	e8 75 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143b:	eb 26                	jmp    801463 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80143d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801440:	8b 52 0c             	mov    0xc(%edx),%edx
  801443:	85 d2                	test   %edx,%edx
  801445:	74 17                	je     80145e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	ff 75 10             	pushl  0x10(%ebp)
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	50                   	push   %eax
  801451:	ff d2                	call   *%edx
  801453:	89 c2                	mov    %eax,%edx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	eb 09                	jmp    801463 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	eb 05                	jmp    801463 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80145e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801463:	89 d0                	mov    %edx,%eax
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <seek>:

int
seek(int fdnum, off_t offset)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801470:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 23 fc ff ff       	call   80109f <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 0e                	js     801491 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801483:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801486:	8b 55 0c             	mov    0xc(%ebp),%edx
  801489:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 14             	sub    $0x14,%esp
  80149a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	53                   	push   %ebx
  8014a2:	e8 f8 fb ff ff       	call   80109f <fd_lookup>
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 65                	js     801515 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ba:	ff 30                	pushl  (%eax)
  8014bc:	e8 34 fc ff ff       	call   8010f5 <dev_lookup>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 44                	js     80150c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014cf:	75 21                	jne    8014f2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d6:	8b 40 48             	mov    0x48(%eax),%eax
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	53                   	push   %ebx
  8014dd:	50                   	push   %eax
  8014de:	68 bc 26 80 00       	push   $0x8026bc
  8014e3:	e8 c0 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f0:	eb 23                	jmp    801515 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f5:	8b 52 18             	mov    0x18(%edx),%edx
  8014f8:	85 d2                	test   %edx,%edx
  8014fa:	74 14                	je     801510 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	ff 75 0c             	pushl  0xc(%ebp)
  801502:	50                   	push   %eax
  801503:	ff d2                	call   *%edx
  801505:	89 c2                	mov    %eax,%edx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 09                	jmp    801515 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	eb 05                	jmp    801515 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801510:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801515:	89 d0                	mov    %edx,%eax
  801517:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	53                   	push   %ebx
  801520:	83 ec 14             	sub    $0x14,%esp
  801523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801526:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	ff 75 08             	pushl  0x8(%ebp)
  80152d:	e8 6d fb ff ff       	call   80109f <fd_lookup>
  801532:	83 c4 08             	add    $0x8,%esp
  801535:	89 c2                	mov    %eax,%edx
  801537:	85 c0                	test   %eax,%eax
  801539:	78 58                	js     801593 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801545:	ff 30                	pushl  (%eax)
  801547:	e8 a9 fb ff ff       	call   8010f5 <dev_lookup>
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 37                	js     80158a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801553:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801556:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80155a:	74 32                	je     80158e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80155c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80155f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801566:	00 00 00 
	stat->st_isdir = 0;
  801569:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801570:	00 00 00 
	stat->st_dev = dev;
  801573:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	53                   	push   %ebx
  80157d:	ff 75 f0             	pushl  -0x10(%ebp)
  801580:	ff 50 14             	call   *0x14(%eax)
  801583:	89 c2                	mov    %eax,%edx
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	eb 09                	jmp    801593 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	eb 05                	jmp    801593 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80158e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801593:	89 d0                	mov    %edx,%eax
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	6a 00                	push   $0x0
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 e7 01 00 00       	call   801793 <open>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 db                	test   %ebx,%ebx
  8015b3:	78 1b                	js     8015d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	53                   	push   %ebx
  8015bc:	e8 5b ff ff ff       	call   80151c <fstat>
  8015c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c3:	89 1c 24             	mov    %ebx,(%esp)
  8015c6:	e8 fd fb ff ff       	call   8011c8 <close>
	return r;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	89 f0                	mov    %esi,%eax
}
  8015d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d3:	5b                   	pop    %ebx
  8015d4:	5e                   	pop    %esi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	89 c6                	mov    %eax,%esi
  8015de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e7:	75 12                	jne    8015fb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	6a 03                	push   $0x3
  8015ee:	e8 af 08 00 00       	call   801ea2 <ipc_find_env>
  8015f3:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015fb:	6a 07                	push   $0x7
  8015fd:	68 00 50 80 00       	push   $0x805000
  801602:	56                   	push   %esi
  801603:	ff 35 00 40 80 00    	pushl  0x804000
  801609:	e8 43 08 00 00       	call   801e51 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160e:	83 c4 0c             	add    $0xc,%esp
  801611:	6a 00                	push   $0x0
  801613:	53                   	push   %ebx
  801614:	6a 00                	push   $0x0
  801616:	e8 d0 07 00 00       	call   801deb <ipc_recv>
}
  80161b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161e:	5b                   	pop    %ebx
  80161f:	5e                   	pop    %esi
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	8b 40 0c             	mov    0xc(%eax),%eax
  80162e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801633:	8b 45 0c             	mov    0xc(%ebp),%eax
  801636:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 02 00 00 00       	mov    $0x2,%eax
  801645:	e8 8d ff ff ff       	call   8015d7 <fsipc>
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	8b 40 0c             	mov    0xc(%eax),%eax
  801658:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80165d:	ba 00 00 00 00       	mov    $0x0,%edx
  801662:	b8 06 00 00 00       	mov    $0x6,%eax
  801667:	e8 6b ff ff ff       	call   8015d7 <fsipc>
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
  801688:	b8 05 00 00 00       	mov    $0x5,%eax
  80168d:	e8 45 ff ff ff       	call   8015d7 <fsipc>
  801692:	89 c2                	mov    %eax,%edx
  801694:	85 d2                	test   %edx,%edx
  801696:	78 2c                	js     8016c4 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	68 00 50 80 00       	push   $0x805000
  8016a0:	53                   	push   %ebx
  8016a1:	e8 86 f0 ff ff       	call   80072c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8016b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8016d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d8:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8016de:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8016e3:	76 05                	jbe    8016ea <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8016e5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8016ea:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	68 08 50 80 00       	push   $0x805008
  8016fb:	e8 be f1 ff ff       	call   8008be <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	b8 04 00 00 00       	mov    $0x4,%eax
  80170a:	e8 c8 fe ff ff       	call   8015d7 <fsipc>
	return write;
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801724:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172a:	ba 00 00 00 00       	mov    $0x0,%edx
  80172f:	b8 03 00 00 00       	mov    $0x3,%eax
  801734:	e8 9e fe ff ff       	call   8015d7 <fsipc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 4b                	js     80178a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80173f:	39 c6                	cmp    %eax,%esi
  801741:	73 16                	jae    801759 <devfile_read+0x48>
  801743:	68 28 27 80 00       	push   $0x802728
  801748:	68 2f 27 80 00       	push   $0x80272f
  80174d:	6a 7c                	push   $0x7c
  80174f:	68 44 27 80 00       	push   $0x802744
  801754:	e8 b5 05 00 00       	call   801d0e <_panic>
	assert(r <= PGSIZE);
  801759:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80175e:	7e 16                	jle    801776 <devfile_read+0x65>
  801760:	68 4f 27 80 00       	push   $0x80274f
  801765:	68 2f 27 80 00       	push   $0x80272f
  80176a:	6a 7d                	push   $0x7d
  80176c:	68 44 27 80 00       	push   $0x802744
  801771:	e8 98 05 00 00       	call   801d0e <_panic>
	memmove(buf, &fsipcbuf, r);
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	50                   	push   %eax
  80177a:	68 00 50 80 00       	push   $0x805000
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	e8 37 f1 ff ff       	call   8008be <memmove>
	return r;
  801787:	83 c4 10             	add    $0x10,%esp
}
  80178a:	89 d8                	mov    %ebx,%eax
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 20             	sub    $0x20,%esp
  80179a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80179d:	53                   	push   %ebx
  80179e:	e8 50 ef ff ff       	call   8006f3 <strlen>
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ab:	7f 67                	jg     801814 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	e8 97 f8 ff ff       	call   801050 <fd_alloc>
  8017b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017bc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 57                	js     801819 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	53                   	push   %ebx
  8017c6:	68 00 50 80 00       	push   $0x805000
  8017cb:	e8 5c ef ff ff       	call   80072c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017db:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e0:	e8 f2 fd ff ff       	call   8015d7 <fsipc>
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	79 14                	jns    801802 <open+0x6f>
		fd_close(fd, 0);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	6a 00                	push   $0x0
  8017f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f6:	e8 4d f9 ff ff       	call   801148 <fd_close>
		return r;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	89 da                	mov    %ebx,%edx
  801800:	eb 17                	jmp    801819 <open+0x86>
	}

	return fd2num(fd);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 1c f8 ff ff       	call   801029 <fd2num>
  80180d:	89 c2                	mov    %eax,%edx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	eb 05                	jmp    801819 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801814:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801819:	89 d0                	mov    %edx,%eax
  80181b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 08 00 00 00       	mov    $0x8,%eax
  801830:	e8 a2 fd ff ff       	call   8015d7 <fsipc>
}
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80183f:	83 ec 0c             	sub    $0xc,%esp
  801842:	ff 75 08             	pushl  0x8(%ebp)
  801845:	e8 ef f7 ff ff       	call   801039 <fd2data>
  80184a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80184c:	83 c4 08             	add    $0x8,%esp
  80184f:	68 5b 27 80 00       	push   $0x80275b
  801854:	53                   	push   %ebx
  801855:	e8 d2 ee ff ff       	call   80072c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80185a:	8b 56 04             	mov    0x4(%esi),%edx
  80185d:	89 d0                	mov    %edx,%eax
  80185f:	2b 06                	sub    (%esi),%eax
  801861:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801867:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186e:	00 00 00 
	stat->st_dev = &devpipe;
  801871:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801878:	30 80 00 
	return 0;
}
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
  801880:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801883:	5b                   	pop    %ebx
  801884:	5e                   	pop    %esi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801891:	53                   	push   %ebx
  801892:	6a 00                	push   $0x0
  801894:	e8 22 f3 ff ff       	call   800bbb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801899:	89 1c 24             	mov    %ebx,(%esp)
  80189c:	e8 98 f7 ff ff       	call   801039 <fd2data>
  8018a1:	83 c4 08             	add    $0x8,%esp
  8018a4:	50                   	push   %eax
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 0f f3 ff ff       	call   800bbb <sys_page_unmap>
}
  8018ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 1c             	sub    $0x1c,%esp
  8018ba:	89 c7                	mov    %eax,%edi
  8018bc:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018be:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	57                   	push   %edi
  8018ca:	e8 0b 06 00 00       	call   801eda <pageref>
  8018cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018d2:	89 34 24             	mov    %esi,(%esp)
  8018d5:	e8 00 06 00 00       	call   801eda <pageref>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018e0:	0f 94 c0             	sete   %al
  8018e3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018e6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ef:	39 cb                	cmp    %ecx,%ebx
  8018f1:	74 15                	je     801908 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8018f3:	8b 52 58             	mov    0x58(%edx),%edx
  8018f6:	50                   	push   %eax
  8018f7:	52                   	push   %edx
  8018f8:	53                   	push   %ebx
  8018f9:	68 68 27 80 00       	push   $0x802768
  8018fe:	e8 a5 e8 ff ff       	call   8001a8 <cprintf>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	eb b6                	jmp    8018be <_pipeisclosed+0xd>
	}
}
  801908:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	57                   	push   %edi
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	83 ec 28             	sub    $0x28,%esp
  801919:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191c:	56                   	push   %esi
  80191d:	e8 17 f7 ff ff       	call   801039 <fd2data>
  801922:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	bf 00 00 00 00       	mov    $0x0,%edi
  80192c:	eb 4b                	jmp    801979 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192e:	89 da                	mov    %ebx,%edx
  801930:	89 f0                	mov    %esi,%eax
  801932:	e8 7a ff ff ff       	call   8018b1 <_pipeisclosed>
  801937:	85 c0                	test   %eax,%eax
  801939:	75 48                	jne    801983 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193b:	e8 d7 f1 ff ff       	call   800b17 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801940:	8b 43 04             	mov    0x4(%ebx),%eax
  801943:	8b 0b                	mov    (%ebx),%ecx
  801945:	8d 51 20             	lea    0x20(%ecx),%edx
  801948:	39 d0                	cmp    %edx,%eax
  80194a:	73 e2                	jae    80192e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801953:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801956:	89 c2                	mov    %eax,%edx
  801958:	c1 fa 1f             	sar    $0x1f,%edx
  80195b:	89 d1                	mov    %edx,%ecx
  80195d:	c1 e9 1b             	shr    $0x1b,%ecx
  801960:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801963:	83 e2 1f             	and    $0x1f,%edx
  801966:	29 ca                	sub    %ecx,%edx
  801968:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80196c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801970:	83 c0 01             	add    $0x1,%eax
  801973:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801976:	83 c7 01             	add    $0x1,%edi
  801979:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80197c:	75 c2                	jne    801940 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197e:	8b 45 10             	mov    0x10(%ebp),%eax
  801981:	eb 05                	jmp    801988 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801988:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5f                   	pop    %edi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	57                   	push   %edi
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	83 ec 18             	sub    $0x18,%esp
  801999:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199c:	57                   	push   %edi
  80199d:	e8 97 f6 ff ff       	call   801039 <fd2data>
  8019a2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ac:	eb 3d                	jmp    8019eb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ae:	85 db                	test   %ebx,%ebx
  8019b0:	74 04                	je     8019b6 <devpipe_read+0x26>
				return i;
  8019b2:	89 d8                	mov    %ebx,%eax
  8019b4:	eb 44                	jmp    8019fa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b6:	89 f2                	mov    %esi,%edx
  8019b8:	89 f8                	mov    %edi,%eax
  8019ba:	e8 f2 fe ff ff       	call   8018b1 <_pipeisclosed>
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	75 32                	jne    8019f5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c3:	e8 4f f1 ff ff       	call   800b17 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c8:	8b 06                	mov    (%esi),%eax
  8019ca:	3b 46 04             	cmp    0x4(%esi),%eax
  8019cd:	74 df                	je     8019ae <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019cf:	99                   	cltd   
  8019d0:	c1 ea 1b             	shr    $0x1b,%edx
  8019d3:	01 d0                	add    %edx,%eax
  8019d5:	83 e0 1f             	and    $0x1f,%eax
  8019d8:	29 d0                	sub    %edx,%eax
  8019da:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e8:	83 c3 01             	add    $0x1,%ebx
  8019eb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ee:	75 d8                	jne    8019c8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f3:	eb 05                	jmp    8019fa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5e                   	pop    %esi
  8019ff:	5f                   	pop    %edi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0d:	50                   	push   %eax
  801a0e:	e8 3d f6 ff ff       	call   801050 <fd_alloc>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	0f 88 2c 01 00 00    	js     801b4c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a20:	83 ec 04             	sub    $0x4,%esp
  801a23:	68 07 04 00 00       	push   $0x407
  801a28:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 04 f1 ff ff       	call   800b36 <sys_page_alloc>
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	89 c2                	mov    %eax,%edx
  801a37:	85 c0                	test   %eax,%eax
  801a39:	0f 88 0d 01 00 00    	js     801b4c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	e8 05 f6 ff ff       	call   801050 <fd_alloc>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	0f 88 e2 00 00 00    	js     801b3a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	68 07 04 00 00       	push   $0x407
  801a60:	ff 75 f0             	pushl  -0x10(%ebp)
  801a63:	6a 00                	push   $0x0
  801a65:	e8 cc f0 ff ff       	call   800b36 <sys_page_alloc>
  801a6a:	89 c3                	mov    %eax,%ebx
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	0f 88 c3 00 00 00    	js     801b3a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7d:	e8 b7 f5 ff ff       	call   801039 <fd2data>
  801a82:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a84:	83 c4 0c             	add    $0xc,%esp
  801a87:	68 07 04 00 00       	push   $0x407
  801a8c:	50                   	push   %eax
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 a2 f0 ff ff       	call   800b36 <sys_page_alloc>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	0f 88 89 00 00 00    	js     801b2a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa7:	e8 8d f5 ff ff       	call   801039 <fd2data>
  801aac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab3:	50                   	push   %eax
  801ab4:	6a 00                	push   $0x0
  801ab6:	56                   	push   %esi
  801ab7:	6a 00                	push   $0x0
  801ab9:	e8 bb f0 ff ff       	call   800b79 <sys_page_map>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	83 c4 20             	add    $0x20,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 55                	js     801b1c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801adc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	ff 75 f4             	pushl  -0xc(%ebp)
  801af7:	e8 2d f5 ff ff       	call   801029 <fd2num>
  801afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b01:	83 c4 04             	add    $0x4,%esp
  801b04:	ff 75 f0             	pushl  -0x10(%ebp)
  801b07:	e8 1d f5 ff ff       	call   801029 <fd2num>
  801b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1a:	eb 30                	jmp    801b4c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	56                   	push   %esi
  801b20:	6a 00                	push   $0x0
  801b22:	e8 94 f0 ff ff       	call   800bbb <sys_page_unmap>
  801b27:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2a:	83 ec 08             	sub    $0x8,%esp
  801b2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b30:	6a 00                	push   $0x0
  801b32:	e8 84 f0 ff ff       	call   800bbb <sys_page_unmap>
  801b37:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b40:	6a 00                	push   $0x0
  801b42:	e8 74 f0 ff ff       	call   800bbb <sys_page_unmap>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b4c:	89 d0                	mov    %edx,%eax
  801b4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	ff 75 08             	pushl  0x8(%ebp)
  801b62:	e8 38 f5 ff ff       	call   80109f <fd_lookup>
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 d2                	test   %edx,%edx
  801b6e:	78 18                	js     801b88 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	ff 75 f4             	pushl  -0xc(%ebp)
  801b76:	e8 be f4 ff ff       	call   801039 <fd2data>
	return _pipeisclosed(fd, p);
  801b7b:	89 c2                	mov    %eax,%edx
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	e8 2c fd ff ff       	call   8018b1 <_pipeisclosed>
  801b85:	83 c4 10             	add    $0x10,%esp
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9a:	68 99 27 80 00       	push   $0x802799
  801b9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ba2:	e8 85 eb ff ff       	call   80072c <strcpy>
	return 0;
}
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bba:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc5:	eb 2e                	jmp    801bf5 <devcons_write+0x47>
		m = n - tot;
  801bc7:	8b 55 10             	mov    0x10(%ebp),%edx
  801bca:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801bcc:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801bd1:	83 fa 7f             	cmp    $0x7f,%edx
  801bd4:	77 02                	ja     801bd8 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd6:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	56                   	push   %esi
  801bdc:	03 45 0c             	add    0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	57                   	push   %edi
  801be1:	e8 d8 ec ff ff       	call   8008be <memmove>
		sys_cputs(buf, m);
  801be6:	83 c4 08             	add    $0x8,%esp
  801be9:	56                   	push   %esi
  801bea:	57                   	push   %edi
  801beb:	e8 8a ee ff ff       	call   800a7a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf0:	01 f3                	add    %esi,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	89 d8                	mov    %ebx,%eax
  801bf7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bfa:	72 cb                	jb     801bc7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c13:	75 07                	jne    801c1c <devcons_read+0x18>
  801c15:	eb 28                	jmp    801c3f <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c17:	e8 fb ee ff ff       	call   800b17 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1c:	e8 77 ee ff ff       	call   800a98 <sys_cgetc>
  801c21:	85 c0                	test   %eax,%eax
  801c23:	74 f2                	je     801c17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 16                	js     801c3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c29:	83 f8 04             	cmp    $0x4,%eax
  801c2c:	74 0c                	je     801c3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c31:	88 02                	mov    %al,(%edx)
	return 1;
  801c33:	b8 01 00 00 00       	mov    $0x1,%eax
  801c38:	eb 05                	jmp    801c3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4d:	6a 01                	push   $0x1
  801c4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	e8 22 ee ff ff       	call   800a7a <sys_cputs>
  801c58:	83 c4 10             	add    $0x10,%esp
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <getchar>:

int
getchar(void)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c63:	6a 01                	push   $0x1
  801c65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c68:	50                   	push   %eax
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 98 f6 ff ff       	call   801308 <read>
	if (r < 0)
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 0f                	js     801c86 <getchar+0x29>
		return r;
	if (r < 1)
  801c77:	85 c0                	test   %eax,%eax
  801c79:	7e 06                	jle    801c81 <getchar+0x24>
		return -E_EOF;
	return c;
  801c7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7f:	eb 05                	jmp    801c86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c91:	50                   	push   %eax
  801c92:	ff 75 08             	pushl  0x8(%ebp)
  801c95:	e8 05 f4 ff ff       	call   80109f <fd_lookup>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 11                	js     801cb2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caa:	39 10                	cmp    %edx,(%eax)
  801cac:	0f 94 c0             	sete   %al
  801caf:	0f b6 c0             	movzbl %al,%eax
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <opencons>:

int
opencons(void)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbd:	50                   	push   %eax
  801cbe:	e8 8d f3 ff ff       	call   801050 <fd_alloc>
  801cc3:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 3e                	js     801d0a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccc:	83 ec 04             	sub    $0x4,%esp
  801ccf:	68 07 04 00 00       	push   $0x407
  801cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 58 ee ff ff       	call   800b36 <sys_page_alloc>
  801cde:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 23                	js     801d0a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	50                   	push   %eax
  801d00:	e8 24 f3 ff ff       	call   801029 <fd2num>
  801d05:	89 c2                	mov    %eax,%edx
  801d07:	83 c4 10             	add    $0x10,%esp
}
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d13:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d16:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d1c:	e8 d7 ed ff ff       	call   800af8 <sys_getenvid>
  801d21:	83 ec 0c             	sub    $0xc,%esp
  801d24:	ff 75 0c             	pushl  0xc(%ebp)
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	56                   	push   %esi
  801d2b:	50                   	push   %eax
  801d2c:	68 a8 27 80 00       	push   $0x8027a8
  801d31:	e8 72 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d36:	83 c4 18             	add    $0x18,%esp
  801d39:	53                   	push   %ebx
  801d3a:	ff 75 10             	pushl  0x10(%ebp)
  801d3d:	e8 15 e4 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d42:	c7 04 24 94 22 80 00 	movl   $0x802294,(%esp)
  801d49:	e8 5a e4 ff ff       	call   8001a8 <cprintf>
  801d4e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d51:	cc                   	int3   
  801d52:	eb fd                	jmp    801d51 <_panic+0x43>

00801d54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801d5a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d61:	75 2c                	jne    801d8f <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801d63:	83 ec 04             	sub    $0x4,%esp
  801d66:	6a 07                	push   $0x7
  801d68:	68 00 f0 7f ee       	push   $0xee7ff000
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 c2 ed ff ff       	call   800b36 <sys_page_alloc>
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	79 14                	jns    801d8f <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	68 cc 27 80 00       	push   $0x8027cc
  801d83:	6a 1f                	push   $0x1f
  801d85:	68 30 28 80 00       	push   $0x802830
  801d8a:	e8 7f ff ff ff       	call   801d0e <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801d97:	83 ec 08             	sub    $0x8,%esp
  801d9a:	68 c3 1d 80 00       	push   $0x801dc3
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 db ee ff ff       	call   800c81 <sys_env_set_pgfault_upcall>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	79 14                	jns    801dc1 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801dad:	83 ec 04             	sub    $0x4,%esp
  801db0:	68 f8 27 80 00       	push   $0x8027f8
  801db5:	6a 25                	push   $0x25
  801db7:	68 30 28 80 00       	push   $0x802830
  801dbc:	e8 4d ff ff ff       	call   801d0e <_panic>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dcb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801dce:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801dd0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801dd4:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801dd8:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801dd9:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801ddc:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801dde:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801de1:	83 c4 04             	add    $0x4,%esp
	popal 
  801de4:	61                   	popa   
	addl $4, %esp 
  801de5:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801de8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801de9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801dea:	c3                   	ret    

00801deb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	8b 75 08             	mov    0x8(%ebp),%esi
  801df3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801df9:	85 f6                	test   %esi,%esi
  801dfb:	74 06                	je     801e03 <ipc_recv+0x18>
  801dfd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e03:	85 db                	test   %ebx,%ebx
  801e05:	74 06                	je     801e0d <ipc_recv+0x22>
  801e07:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e0d:	83 f8 01             	cmp    $0x1,%eax
  801e10:	19 d2                	sbb    %edx,%edx
  801e12:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	50                   	push   %eax
  801e18:	e8 c9 ee ff ff       	call   800ce6 <sys_ipc_recv>
  801e1d:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 d2                	test   %edx,%edx
  801e24:	75 24                	jne    801e4a <ipc_recv+0x5f>
	if (from_env_store)
  801e26:	85 f6                	test   %esi,%esi
  801e28:	74 0a                	je     801e34 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2f:	8b 40 70             	mov    0x70(%eax),%eax
  801e32:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801e34:	85 db                	test   %ebx,%ebx
  801e36:	74 0a                	je     801e42 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801e38:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3d:	8b 40 74             	mov    0x74(%eax),%eax
  801e40:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801e42:	a1 04 40 80 00       	mov    0x804004,%eax
  801e47:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	57                   	push   %edi
  801e55:	56                   	push   %esi
  801e56:	53                   	push   %ebx
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801e63:	83 fb 01             	cmp    $0x1,%ebx
  801e66:	19 c0                	sbb    %eax,%eax
  801e68:	09 c3                	or     %eax,%ebx
  801e6a:	eb 1c                	jmp    801e88 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801e6c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e6f:	74 12                	je     801e83 <ipc_send+0x32>
  801e71:	50                   	push   %eax
  801e72:	68 3e 28 80 00       	push   $0x80283e
  801e77:	6a 36                	push   $0x36
  801e79:	68 55 28 80 00       	push   $0x802855
  801e7e:	e8 8b fe ff ff       	call   801d0e <_panic>
		sys_yield();
  801e83:	e8 8f ec ff ff       	call   800b17 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801e88:	ff 75 14             	pushl  0x14(%ebp)
  801e8b:	53                   	push   %ebx
  801e8c:	56                   	push   %esi
  801e8d:	57                   	push   %edi
  801e8e:	e8 30 ee ff ff       	call   800cc3 <sys_ipc_try_send>
		if (ret == 0) break;
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 d2                	jne    801e6c <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ead:	6b d0 78             	imul   $0x78,%eax,%edx
  801eb0:	83 c2 50             	add    $0x50,%edx
  801eb3:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801eb9:	39 ca                	cmp    %ecx,%edx
  801ebb:	75 0d                	jne    801eca <ipc_find_env+0x28>
			return envs[i].env_id;
  801ebd:	6b c0 78             	imul   $0x78,%eax,%eax
  801ec0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ec5:	8b 40 08             	mov    0x8(%eax),%eax
  801ec8:	eb 0e                	jmp    801ed8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eca:	83 c0 01             	add    $0x1,%eax
  801ecd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed2:	75 d9                	jne    801ead <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ed4:	66 b8 00 00          	mov    $0x0,%ax
}
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee0:	89 d0                	mov    %edx,%eax
  801ee2:	c1 e8 16             	shr    $0x16,%eax
  801ee5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef1:	f6 c1 01             	test   $0x1,%cl
  801ef4:	74 1d                	je     801f13 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef6:	c1 ea 0c             	shr    $0xc,%edx
  801ef9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f00:	f6 c2 01             	test   $0x1,%dl
  801f03:	74 0e                	je     801f13 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f05:	c1 ea 0c             	shr    $0xc,%edx
  801f08:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f0f:	ef 
  801f10:	0f b7 c0             	movzwl %ax,%eax
}
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    
  801f15:	66 90                	xchg   %ax,%ax
  801f17:	66 90                	xchg   %ax,%ax
  801f19:	66 90                	xchg   %ax,%ax
  801f1b:	66 90                	xchg   %ax,%ax
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

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
