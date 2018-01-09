
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 40 1e 80 00       	push   $0x801e40
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 a2 0a 00 00       	call   800afc <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 60 1e 80 00       	push   $0x801e60
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 8c 1e 80 00       	push   $0x801e8c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
  800092:	83 c4 10             	add    $0x10,%esp
}
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a5:	e8 33 0a 00 00       	call   800add <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 78             	imul   $0x78,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
  8000d6:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 0c 0e 00 00       	call   800ef7 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a7 09 00 00       	call   800a9c <sys_env_destroy>
  8000f5:	83 c4 10             	add    $0x10,%esp
}
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 35 09 00 00       	call   800a5f <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 4f 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 da 08 00 00       	call   800a5f <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 d1                	mov    %edx,%ecx
  8001b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cc:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001cf:	72 05                	jb     8001d6 <printnum+0x35>
  8001d1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001d4:	77 3e                	ja     800214 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	ff 75 18             	pushl  0x18(%ebp)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	53                   	push   %ebx
  8001e0:	50                   	push   %eax
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 8b 19 00 00       	call   801b80 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 13                	jmp    80021b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	85 db                	test   %ebx,%ebx
  800219:	7f ed                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	83 ec 04             	sub    $0x4,%esp
  800222:	ff 75 e4             	pushl  -0x1c(%ebp)
  800225:	ff 75 e0             	pushl  -0x20(%ebp)
  800228:	ff 75 dc             	pushl  -0x24(%ebp)
  80022b:	ff 75 d8             	pushl  -0x28(%ebp)
  80022e:	e8 7d 1a 00 00       	call   801cb0 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 80 b5 1e 80 00 	movsbl 0x801eb5(%eax),%eax
  80023d:	50                   	push   %eax
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
}
  800243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024e:	83 fa 01             	cmp    $0x1,%edx
  800251:	7e 0e                	jle    800261 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800253:	8b 10                	mov    (%eax),%edx
  800255:	8d 4a 08             	lea    0x8(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 02                	mov    (%edx),%eax
  80025c:	8b 52 04             	mov    0x4(%edx),%edx
  80025f:	eb 22                	jmp    800283 <getuint+0x38>
	else if (lflag)
  800261:	85 d2                	test   %edx,%edx
  800263:	74 10                	je     800275 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	eb 0e                	jmp    800283 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800275:	8b 10                	mov    (%eax),%edx
  800277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027a:	89 08                	mov    %ecx,(%eax)
  80027c:	8b 02                	mov    (%edx),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	50                   	push   %eax
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 05 00 00 00       	call   8002bf <vprintfmt>
	va_end(ap);
  8002ba:	83 c4 10             	add    $0x10,%esp
}
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 2c             	sub    $0x2c,%esp
  8002c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d1:	eb 12                	jmp    8002e5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	0f 84 8d 03 00 00    	je     800668 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	53                   	push   %ebx
  8002df:	50                   	push   %eax
  8002e0:	ff d6                	call   *%esi
  8002e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	83 c7 01             	add    $0x1,%edi
  8002e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ec:	83 f8 25             	cmp    $0x25,%eax
  8002ef:	75 e2                	jne    8002d3 <vprintfmt+0x14>
  8002f1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800303:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 07                	jmp    800318 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800314:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8d 47 01             	lea    0x1(%edi),%eax
  80031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031e:	0f b6 07             	movzbl (%edi),%eax
  800321:	0f b6 c8             	movzbl %al,%ecx
  800324:	83 e8 23             	sub    $0x23,%eax
  800327:	3c 55                	cmp    $0x55,%al
  800329:	0f 87 1e 03 00 00    	ja     80064d <vprintfmt+0x38e>
  80032f:	0f b6 c0             	movzbl %al,%eax
  800332:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800340:	eb d6                	jmp    800318 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	b8 00 00 00 00       	mov    $0x0,%eax
  80034a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800350:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800354:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800357:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035a:	83 fa 09             	cmp    $0x9,%edx
  80035d:	77 38                	ja     800397 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800362:	eb e9                	jmp    80034d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 48 04             	lea    0x4(%eax),%ecx
  80036a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800375:	eb 26                	jmp    80039d <vprintfmt+0xde>
  800377:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80037a:	89 c8                	mov    %ecx,%eax
  80037c:	c1 f8 1f             	sar    $0x1f,%eax
  80037f:	f7 d0                	not    %eax
  800381:	21 c1                	and    %eax,%ecx
  800383:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	eb 8d                	jmp    800318 <vprintfmt+0x59>
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800395:	eb 81                	jmp    800318 <vprintfmt+0x59>
  800397:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a1:	0f 89 71 ff ff ff    	jns    800318 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b4:	e9 5f ff ff ff       	jmp    800318 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bf:	e9 54 ff ff ff       	jmp    800318 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	53                   	push   %ebx
  8003d1:	ff 30                	pushl  (%eax)
  8003d3:	ff d6                	call   *%esi
			break;
  8003d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003db:	e9 05 ff ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	99                   	cltd   
  8003ec:	31 d0                	xor    %edx,%eax
  8003ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f0:	83 f8 0f             	cmp    $0xf,%eax
  8003f3:	7f 0b                	jg     800400 <vprintfmt+0x141>
  8003f5:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8003fc:	85 d2                	test   %edx,%edx
  8003fe:	75 18                	jne    800418 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800400:	50                   	push   %eax
  800401:	68 cd 1e 80 00       	push   $0x801ecd
  800406:	53                   	push   %ebx
  800407:	56                   	push   %esi
  800408:	e8 95 fe ff ff       	call   8002a2 <printfmt>
  80040d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 cd fe ff ff       	jmp    8002e5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	52                   	push   %edx
  800419:	68 b1 22 80 00       	push   $0x8022b1
  80041e:	53                   	push   %ebx
  80041f:	56                   	push   %esi
  800420:	e8 7d fe ff ff       	call   8002a2 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	e9 b5 fe ff ff       	jmp    8002e5 <vprintfmt+0x26>
  800430:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800436:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 38                	mov    (%eax),%edi
  800444:	85 ff                	test   %edi,%edi
  800446:	75 05                	jne    80044d <vprintfmt+0x18e>
				p = "(null)";
  800448:	bf c6 1e 80 00       	mov    $0x801ec6,%edi
			if (width > 0 && padc != '-')
  80044d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800451:	0f 84 91 00 00 00    	je     8004e8 <vprintfmt+0x229>
  800457:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80045b:	0f 8e 95 00 00 00    	jle    8004f6 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	51                   	push   %ecx
  800465:	57                   	push   %edi
  800466:	e8 85 02 00 00       	call   8006f0 <strnlen>
  80046b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c5>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	89 c8                	mov    %ecx,%eax
  80049f:	c1 f8 1f             	sar    $0x1f,%eax
  8004a2:	f7 d0                	not    %eax
  8004a4:	21 c8                	and    %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 4d                	jmp    800502 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	74 1b                	je     8004d6 <vprintfmt+0x217>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 10                	jbe    8004d6 <vprintfmt+0x217>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	eb 0d                	jmp    8004e3 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	52                   	push   %edx
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	eb 1a                	jmp    800502 <vprintfmt+0x243>
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f4:	eb 0c                	jmp    800502 <vprintfmt+0x243>
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 23                	je     800533 <vprintfmt+0x274>
  800510:	85 f6                	test   %esi,%esi
  800512:	78 a1                	js     8004b5 <vprintfmt+0x1f6>
  800514:	83 ee 01             	sub    $0x1,%esi
  800517:	79 9c                	jns    8004b5 <vprintfmt+0x1f6>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	eb 18                	jmp    80053b <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 20                	push   $0x20
  800529:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 08                	jmp    80053b <vprintfmt+0x27c>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f e4                	jg     800523 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 9e fd ff ff       	jmp    8002e5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 fa 01             	cmp    $0x1,%edx
  80054a:	7e 16                	jle    800562 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 50 04             	mov    0x4(%eax),%edx
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	eb 32                	jmp    800594 <vprintfmt+0x2d5>
	else if (lflag)
  800562:	85 d2                	test   %edx,%edx
  800564:	74 18                	je     80057e <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057c:	eb 16                	jmp    800594 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a3:	79 74                	jns    800619 <vprintfmt+0x35a>
				putch('-', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 2d                	push   $0x2d
  8005ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b3:	f7 d8                	neg    %eax
  8005b5:	83 d2 00             	adc    $0x0,%edx
  8005b8:	f7 da                	neg    %edx
  8005ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c2:	eb 55                	jmp    800619 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 7f fc ff ff       	call   80024b <getuint>
			base = 10;
  8005cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d1:	eb 46                	jmp    800619 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 70 fc ff ff       	call   80024b <getuint>
			base = 8;
  8005db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e0:	eb 37                	jmp    800619 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	6a 30                	push   $0x30
  8005e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 78                	push   $0x78
  8005f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800602:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800605:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060a:	eb 0d                	jmp    800619 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 37 fc ff ff       	call   80024b <getuint>
			base = 16;
  800614:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800619:	83 ec 0c             	sub    $0xc,%esp
  80061c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800620:	57                   	push   %edi
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	51                   	push   %ecx
  800625:	52                   	push   %edx
  800626:	50                   	push   %eax
  800627:	89 da                	mov    %ebx,%edx
  800629:	89 f0                	mov    %esi,%eax
  80062b:	e8 71 fb ff ff       	call   8001a1 <printnum>
			break;
  800630:	83 c4 20             	add    $0x20,%esp
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800636:	e9 aa fc ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	51                   	push   %ecx
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800648:	e9 98 fc ff ff       	jmp    8002e5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 25                	push   $0x25
  800653:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb 03                	jmp    80065d <vprintfmt+0x39e>
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800661:	75 f7                	jne    80065a <vprintfmt+0x39b>
  800663:	e9 7d fc ff ff       	jmp    8002e5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 18             	sub    $0x18,%esp
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800683:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800686:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 26                	je     8006b7 <vsnprintf+0x47>
  800691:	85 d2                	test   %edx,%edx
  800693:	7e 22                	jle    8006b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800695:	ff 75 14             	pushl  0x14(%ebp)
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	68 85 02 80 00       	push   $0x800285
  8006a4:	e8 16 fc ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb 05                	jmp    8006bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c7:	50                   	push   %eax
  8006c8:	ff 75 10             	pushl  0x10(%ebp)
  8006cb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ce:	ff 75 08             	pushl  0x8(%ebp)
  8006d1:	e8 9a ff ff ff       	call   800670 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	eb 03                	jmp    8006e8 <strlen+0x10>
		n++;
  8006e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ec:	75 f7                	jne    8006e5 <strlen+0xd>
		n++;
	return n;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fe:	eb 03                	jmp    800703 <strnlen+0x13>
		n++;
  800700:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 c2                	cmp    %eax,%edx
  800705:	74 08                	je     80070f <strnlen+0x1f>
  800707:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070b:	75 f3                	jne    800700 <strnlen+0x10>
  80070d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071b:	89 c2                	mov    %eax,%edx
  80071d:	83 c2 01             	add    $0x1,%edx
  800720:	83 c1 01             	add    $0x1,%ecx
  800723:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800727:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072a:	84 db                	test   %bl,%bl
  80072c:	75 ef                	jne    80071d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072e:	5b                   	pop    %ebx
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	53                   	push   %ebx
  800735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800738:	53                   	push   %ebx
  800739:	e8 9a ff ff ff       	call   8006d8 <strlen>
  80073e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	01 d8                	add    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	e8 c5 ff ff ff       	call   800711 <strcpy>
	return dst;
}
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075e:	89 f3                	mov    %esi,%ebx
  800760:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800763:	89 f2                	mov    %esi,%edx
  800765:	eb 0f                	jmp    800776 <strncpy+0x23>
		*dst++ = *src;
  800767:	83 c2 01             	add    $0x1,%edx
  80076a:	0f b6 01             	movzbl (%ecx),%eax
  80076d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800770:	80 39 01             	cmpb   $0x1,(%ecx)
  800773:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800776:	39 da                	cmp    %ebx,%edx
  800778:	75 ed                	jne    800767 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077a:	89 f0                	mov    %esi,%eax
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
  80078e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	85 d2                	test   %edx,%edx
  800792:	74 21                	je     8007b5 <strlcpy+0x35>
  800794:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800798:	89 f2                	mov    %esi,%edx
  80079a:	eb 09                	jmp    8007a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079c:	83 c2 01             	add    $0x1,%edx
  80079f:	83 c1 01             	add    $0x1,%ecx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a5:	39 c2                	cmp    %eax,%edx
  8007a7:	74 09                	je     8007b2 <strlcpy+0x32>
  8007a9:	0f b6 19             	movzbl (%ecx),%ebx
  8007ac:	84 db                	test   %bl,%bl
  8007ae:	75 ec                	jne    80079c <strlcpy+0x1c>
  8007b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b5:	29 f0                	sub    %esi,%eax
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5e                   	pop    %esi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c4:	eb 06                	jmp    8007cc <strcmp+0x11>
		p++, q++;
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	84 c0                	test   %al,%al
  8007d1:	74 04                	je     8007d7 <strcmp+0x1c>
  8007d3:	3a 02                	cmp    (%edx),%al
  8007d5:	74 ef                	je     8007c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d7:	0f b6 c0             	movzbl %al,%eax
  8007da:	0f b6 12             	movzbl (%edx),%edx
  8007dd:	29 d0                	sub    %edx,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007eb:	89 c3                	mov    %eax,%ebx
  8007ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strncmp+0x17>
		n--, p++, q++;
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f8:	39 d8                	cmp    %ebx,%eax
  8007fa:	74 15                	je     800811 <strncmp+0x30>
  8007fc:	0f b6 08             	movzbl (%eax),%ecx
  8007ff:	84 c9                	test   %cl,%cl
  800801:	74 04                	je     800807 <strncmp+0x26>
  800803:	3a 0a                	cmp    (%edx),%cl
  800805:	74 eb                	je     8007f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	0f b6 12             	movzbl (%edx),%edx
  80080d:	29 d0                	sub    %edx,%eax
  80080f:	eb 05                	jmp    800816 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800823:	eb 07                	jmp    80082c <strchr+0x13>
		if (*s == c)
  800825:	38 ca                	cmp    %cl,%dl
  800827:	74 0f                	je     800838 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	0f b6 10             	movzbl (%eax),%edx
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f2                	jne    800825 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800844:	eb 03                	jmp    800849 <strfind+0xf>
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084c:	84 d2                	test   %dl,%dl
  80084e:	74 04                	je     800854 <strfind+0x1a>
  800850:	38 ca                	cmp    %cl,%dl
  800852:	75 f2                	jne    800846 <strfind+0xc>
			break;
	return (char *) s;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800862:	85 c9                	test   %ecx,%ecx
  800864:	74 36                	je     80089c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800866:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086c:	75 28                	jne    800896 <memset+0x40>
  80086e:	f6 c1 03             	test   $0x3,%cl
  800871:	75 23                	jne    800896 <memset+0x40>
		c &= 0xFF;
  800873:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800877:	89 d3                	mov    %edx,%ebx
  800879:	c1 e3 08             	shl    $0x8,%ebx
  80087c:	89 d6                	mov    %edx,%esi
  80087e:	c1 e6 18             	shl    $0x18,%esi
  800881:	89 d0                	mov    %edx,%eax
  800883:	c1 e0 10             	shl    $0x10,%eax
  800886:	09 f0                	or     %esi,%eax
  800888:	09 c2                	or     %eax,%edx
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80088e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800891:	fc                   	cld    
  800892:	f3 ab                	rep stos %eax,%es:(%edi)
  800894:	eb 06                	jmp    80089c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	fc                   	cld    
  80089a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b1:	39 c6                	cmp    %eax,%esi
  8008b3:	73 35                	jae    8008ea <memmove+0x47>
  8008b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	73 2e                	jae    8008ea <memmove+0x47>
		s += n;
		d += n;
  8008bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c9:	75 13                	jne    8008de <memmove+0x3b>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 0e                	jne    8008de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d0:	83 ef 04             	sub    $0x4,%edi
  8008d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008d9:	fd                   	std    
  8008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dc:	eb 09                	jmp    8008e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008de:	83 ef 01             	sub    $0x1,%edi
  8008e1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e4:	fd                   	std    
  8008e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e7:	fc                   	cld    
  8008e8:	eb 1d                	jmp    800907 <memmove+0x64>
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	f6 c2 03             	test   $0x3,%dl
  8008f1:	75 0f                	jne    800902 <memmove+0x5f>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0a                	jne    800902 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fb:	89 c7                	mov    %eax,%edi
  8008fd:	fc                   	cld    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 05                	jmp    800907 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 87 ff ff ff       	call   8008a3 <memmove>
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	eb 1a                	jmp    80094a <memcmp+0x2c>
		if (*s1 != *s2)
  800930:	0f b6 08             	movzbl (%eax),%ecx
  800933:	0f b6 1a             	movzbl (%edx),%ebx
  800936:	38 d9                	cmp    %bl,%cl
  800938:	74 0a                	je     800944 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093a:	0f b6 c1             	movzbl %cl,%eax
  80093d:	0f b6 db             	movzbl %bl,%ebx
  800940:	29 d8                	sub    %ebx,%eax
  800942:	eb 0f                	jmp    800953 <memcmp+0x35>
		s1++, s2++;
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	39 f0                	cmp    %esi,%eax
  80094c:	75 e2                	jne    800930 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800960:	89 c2                	mov    %eax,%edx
  800962:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800965:	eb 07                	jmp    80096e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800967:	38 08                	cmp    %cl,(%eax)
  800969:	74 07                	je     800972 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	39 d0                	cmp    %edx,%eax
  800970:	72 f5                	jb     800967 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	eb 03                	jmp    800985 <strtol+0x11>
		s++;
  800982:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	3c 09                	cmp    $0x9,%al
  80098a:	74 f6                	je     800982 <strtol+0xe>
  80098c:	3c 20                	cmp    $0x20,%al
  80098e:	74 f2                	je     800982 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800990:	3c 2b                	cmp    $0x2b,%al
  800992:	75 0a                	jne    80099e <strtol+0x2a>
		s++;
  800994:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
  80099c:	eb 10                	jmp    8009ae <strtol+0x3a>
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a3:	3c 2d                	cmp    $0x2d,%al
  8009a5:	75 07                	jne    8009ae <strtol+0x3a>
		s++, neg = 1;
  8009a7:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009aa:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ae:	85 db                	test   %ebx,%ebx
  8009b0:	0f 94 c0             	sete   %al
  8009b3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b9:	75 19                	jne    8009d4 <strtol+0x60>
  8009bb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009be:	75 14                	jne    8009d4 <strtol+0x60>
  8009c0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c4:	0f 85 8a 00 00 00    	jne    800a54 <strtol+0xe0>
		s += 2, base = 16;
  8009ca:	83 c1 02             	add    $0x2,%ecx
  8009cd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d2:	eb 16                	jmp    8009ea <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 12                	je     8009ea <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009dd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e0:	75 08                	jne    8009ea <strtol+0x76>
		s++, base = 8;
  8009e2:	83 c1 01             	add    $0x1,%ecx
  8009e5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f2:	0f b6 11             	movzbl (%ecx),%edx
  8009f5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f8:	89 f3                	mov    %esi,%ebx
  8009fa:	80 fb 09             	cmp    $0x9,%bl
  8009fd:	77 08                	ja     800a07 <strtol+0x93>
			dig = *s - '0';
  8009ff:	0f be d2             	movsbl %dl,%edx
  800a02:	83 ea 30             	sub    $0x30,%edx
  800a05:	eb 22                	jmp    800a29 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0a:	89 f3                	mov    %esi,%ebx
  800a0c:	80 fb 19             	cmp    $0x19,%bl
  800a0f:	77 08                	ja     800a19 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 57             	sub    $0x57,%edx
  800a17:	eb 10                	jmp    800a29 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 19             	cmp    $0x19,%bl
  800a21:	77 16                	ja     800a39 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2c:	7d 0f                	jge    800a3d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a37:	eb b9                	jmp    8009f2 <strtol+0x7e>
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	eb 02                	jmp    800a3f <strtol+0xcb>
  800a3d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a43:	74 05                	je     800a4a <strtol+0xd6>
		*endptr = (char *) s;
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a4a:	85 ff                	test   %edi,%edi
  800a4c:	74 0c                	je     800a5a <strtol+0xe6>
  800a4e:	89 d0                	mov    %edx,%eax
  800a50:	f7 d8                	neg    %eax
  800a52:	eb 06                	jmp    800a5a <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a54:	84 c0                	test   %al,%al
  800a56:	75 8a                	jne    8009e2 <strtol+0x6e>
  800a58:	eb 90                	jmp    8009ea <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 c3                	mov    %eax,%ebx
  800a72:	89 c7                	mov    %eax,%edi
  800a74:	89 c6                	mov    %eax,%esi
  800a76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8d:	89 d1                	mov    %edx,%ecx
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	89 d7                	mov    %edx,%edi
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	89 cb                	mov    %ecx,%ebx
  800ab4:	89 cf                	mov    %ecx,%edi
  800ab6:	89 ce                	mov    %ecx,%esi
  800ab8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	7e 17                	jle    800ad5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abe:	83 ec 0c             	sub    $0xc,%esp
  800ac1:	50                   	push   %eax
  800ac2:	6a 03                	push   $0x3
  800ac4:	68 df 21 80 00       	push   $0x8021df
  800ac9:	6a 23                	push   $0x23
  800acb:	68 fc 21 80 00       	push   $0x8021fc
  800ad0:	e8 3b 0f 00 00       	call   801a10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	89 d7                	mov    %edx,%edi
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_yield>:

void
sys_yield(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	be 00 00 00 00       	mov    $0x0,%esi
  800b29:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	89 f7                	mov    %esi,%edi
  800b39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 04                	push   $0x4
  800b45:	68 df 21 80 00       	push   $0x8021df
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 fc 21 80 00       	push   $0x8021fc
  800b51:	e8 ba 0e 00 00       	call   801a10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b78:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 05                	push   $0x5
  800b87:	68 df 21 80 00       	push   $0x8021df
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 fc 21 80 00       	push   $0x8021fc
  800b93:	e8 78 0e 00 00       	call   801a10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 06                	push   $0x6
  800bc9:	68 df 21 80 00       	push   $0x8021df
  800bce:	6a 23                	push   $0x23
  800bd0:	68 fc 21 80 00       	push   $0x8021fc
  800bd5:	e8 36 0e 00 00       	call   801a10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 08                	push   $0x8
  800c0b:	68 df 21 80 00       	push   $0x8021df
  800c10:	6a 23                	push   $0x23
  800c12:	68 fc 21 80 00       	push   $0x8021fc
  800c17:	e8 f4 0d 00 00       	call   801a10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 09 00 00 00       	mov    $0x9,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 09                	push   $0x9
  800c4d:	68 df 21 80 00       	push   $0x8021df
  800c52:	6a 23                	push   $0x23
  800c54:	68 fc 21 80 00       	push   $0x8021fc
  800c59:	e8 b2 0d 00 00       	call   801a10 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 0a                	push   $0xa
  800c8f:	68 df 21 80 00       	push   $0x8021df
  800c94:	6a 23                	push   $0x23
  800c96:	68 fc 21 80 00       	push   $0x8021fc
  800c9b:	e8 70 0d 00 00       	call   801a10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 cb                	mov    %ecx,%ebx
  800ce3:	89 cf                	mov    %ecx,%edi
  800ce5:	89 ce                	mov    %ecx,%esi
  800ce7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 0d                	push   $0xd
  800cf3:	68 df 21 80 00       	push   $0x8021df
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 fc 21 80 00       	push   $0x8021fc
  800cff:	e8 0c 0d 00 00       	call   801a10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_gettime>:

int sys_gettime(void)
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
  800d12:	ba 00 00 00 00       	mov    $0x0,%edx
  800d17:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1c:	89 d1                	mov    %edx,%ecx
  800d1e:	89 d3                	mov    %edx,%ebx
  800d20:	89 d7                	mov    %edx,%edi
  800d22:	89 d6                	mov    %edx,%esi
  800d24:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	05 00 00 00 30       	add    $0x30000000,%eax
  800d36:	c1 e8 0c             	shr    $0xc,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	c1 ea 16             	shr    $0x16,%edx
  800d62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d69:	f6 c2 01             	test   $0x1,%dl
  800d6c:	74 11                	je     800d7f <fd_alloc+0x2d>
  800d6e:	89 c2                	mov    %eax,%edx
  800d70:	c1 ea 0c             	shr    $0xc,%edx
  800d73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7a:	f6 c2 01             	test   $0x1,%dl
  800d7d:	75 09                	jne    800d88 <fd_alloc+0x36>
			*fd_store = fd;
  800d7f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	eb 17                	jmp    800d9f <fd_alloc+0x4d>
  800d88:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d8d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d92:	75 c9                	jne    800d5d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d94:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d9a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da7:	83 f8 1f             	cmp    $0x1f,%eax
  800daa:	77 36                	ja     800de2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dac:	c1 e0 0c             	shl    $0xc,%eax
  800daf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	c1 ea 16             	shr    $0x16,%edx
  800db9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc0:	f6 c2 01             	test   $0x1,%dl
  800dc3:	74 24                	je     800de9 <fd_lookup+0x48>
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	c1 ea 0c             	shr    $0xc,%edx
  800dca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd1:	f6 c2 01             	test   $0x1,%dl
  800dd4:	74 1a                	je     800df0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd9:	89 02                	mov    %eax,(%edx)
	return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  800de0:	eb 13                	jmp    800df5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de7:	eb 0c                	jmp    800df5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dee:	eb 05                	jmp    800df5 <fd_lookup+0x54>
  800df0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e00:	ba 88 22 80 00       	mov    $0x802288,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e05:	eb 13                	jmp    800e1a <dev_lookup+0x23>
  800e07:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e0a:	39 08                	cmp    %ecx,(%eax)
  800e0c:	75 0c                	jne    800e1a <dev_lookup+0x23>
			*dev = devtab[i];
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	eb 2e                	jmp    800e48 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1a:	8b 02                	mov    (%edx),%eax
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	75 e7                	jne    800e07 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e20:	a1 04 40 80 00       	mov    0x804004,%eax
  800e25:	8b 40 48             	mov    0x48(%eax),%eax
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	51                   	push   %ecx
  800e2c:	50                   	push   %eax
  800e2d:	68 0c 22 80 00       	push   $0x80220c
  800e32:	e8 56 f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 10             	sub    $0x10,%esp
  800e52:	8b 75 08             	mov    0x8(%ebp),%esi
  800e55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e62:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e65:	50                   	push   %eax
  800e66:	e8 36 ff ff ff       	call   800da1 <fd_lookup>
  800e6b:	83 c4 08             	add    $0x8,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 05                	js     800e77 <fd_close+0x2d>
	    || fd != fd2)
  800e72:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e75:	74 0b                	je     800e82 <fd_close+0x38>
		return (must_exist ? r : 0);
  800e77:	80 fb 01             	cmp    $0x1,%bl
  800e7a:	19 d2                	sbb    %edx,%edx
  800e7c:	f7 d2                	not    %edx
  800e7e:	21 d0                	and    %edx,%eax
  800e80:	eb 41                	jmp    800ec3 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	ff 36                	pushl  (%esi)
  800e8b:	e8 67 ff ff ff       	call   800df7 <dev_lookup>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 1a                	js     800eb3 <fd_close+0x69>
		if (dev->dev_close)
  800e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 0b                	je     800eb3 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	56                   	push   %esi
  800eac:	ff d0                	call   *%eax
  800eae:	89 c3                	mov    %eax,%ebx
  800eb0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb3:	83 ec 08             	sub    $0x8,%esp
  800eb6:	56                   	push   %esi
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 e2 fc ff ff       	call   800ba0 <sys_page_unmap>
	return r;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	89 d8                	mov    %ebx,%eax
}
  800ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 75 08             	pushl  0x8(%ebp)
  800ed7:	e8 c5 fe ff ff       	call   800da1 <fd_lookup>
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	83 c4 08             	add    $0x8,%esp
  800ee1:	85 d2                	test   %edx,%edx
  800ee3:	78 10                	js     800ef5 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	6a 01                	push   $0x1
  800eea:	ff 75 f4             	pushl  -0xc(%ebp)
  800eed:	e8 58 ff ff ff       	call   800e4a <fd_close>
  800ef2:	83 c4 10             	add    $0x10,%esp
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <close_all>:

void
close_all(void)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	53                   	push   %ebx
  800f07:	e8 be ff ff ff       	call   800eca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0c:	83 c3 01             	add    $0x1,%ebx
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	83 fb 20             	cmp    $0x20,%ebx
  800f15:	75 ec                	jne    800f03 <close_all+0xc>
		close(i);
}
  800f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 2c             	sub    $0x2c,%esp
  800f25:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	ff 75 08             	pushl  0x8(%ebp)
  800f2f:	e8 6d fe ff ff       	call   800da1 <fd_lookup>
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	85 d2                	test   %edx,%edx
  800f3b:	0f 88 c1 00 00 00    	js     801002 <dup+0xe6>
		return r;
	close(newfdnum);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	56                   	push   %esi
  800f45:	e8 80 ff ff ff       	call   800eca <close>

	newfd = INDEX2FD(newfdnum);
  800f4a:	89 f3                	mov    %esi,%ebx
  800f4c:	c1 e3 0c             	shl    $0xc,%ebx
  800f4f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f55:	83 c4 04             	add    $0x4,%esp
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 db fd ff ff       	call   800d3b <fd2data>
  800f60:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f62:	89 1c 24             	mov    %ebx,(%esp)
  800f65:	e8 d1 fd ff ff       	call   800d3b <fd2data>
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	c1 e8 16             	shr    $0x16,%eax
  800f75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7c:	a8 01                	test   $0x1,%al
  800f7e:	74 37                	je     800fb7 <dup+0x9b>
  800f80:	89 f8                	mov    %edi,%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
  800f85:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8c:	f6 c2 01             	test   $0x1,%dl
  800f8f:	74 26                	je     800fb7 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f91:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa0:	50                   	push   %eax
  800fa1:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa4:	6a 00                	push   $0x0
  800fa6:	57                   	push   %edi
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 b0 fb ff ff       	call   800b5e <sys_page_map>
  800fae:	89 c7                	mov    %eax,%edi
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 2e                	js     800fe5 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	c1 e8 0c             	shr    $0xc,%eax
  800fbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fce:	50                   	push   %eax
  800fcf:	53                   	push   %ebx
  800fd0:	6a 00                	push   $0x0
  800fd2:	52                   	push   %edx
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 84 fb ff ff       	call   800b5e <sys_page_map>
  800fda:	89 c7                	mov    %eax,%edi
  800fdc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fdf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe1:	85 ff                	test   %edi,%edi
  800fe3:	79 1d                	jns    801002 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	53                   	push   %ebx
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 b0 fb ff ff       	call   800ba0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 a3 fb ff ff       	call   800ba0 <sys_page_unmap>
	return r;
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	89 f8                	mov    %edi,%eax
}
  801002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	83 ec 14             	sub    $0x14,%esp
  801011:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801014:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	53                   	push   %ebx
  801019:	e8 83 fd ff ff       	call   800da1 <fd_lookup>
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	89 c2                	mov    %eax,%edx
  801023:	85 c0                	test   %eax,%eax
  801025:	78 6d                	js     801094 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801031:	ff 30                	pushl  (%eax)
  801033:	e8 bf fd ff ff       	call   800df7 <dev_lookup>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 4c                	js     80108b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801042:	8b 42 08             	mov    0x8(%edx),%eax
  801045:	83 e0 03             	and    $0x3,%eax
  801048:	83 f8 01             	cmp    $0x1,%eax
  80104b:	75 21                	jne    80106e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 48             	mov    0x48(%eax),%eax
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	53                   	push   %ebx
  801059:	50                   	push   %eax
  80105a:	68 4d 22 80 00       	push   $0x80224d
  80105f:	e8 29 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80106c:	eb 26                	jmp    801094 <read+0x8a>
	}
	if (!dev->dev_read)
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	8b 40 08             	mov    0x8(%eax),%eax
  801074:	85 c0                	test   %eax,%eax
  801076:	74 17                	je     80108f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	ff 75 10             	pushl  0x10(%ebp)
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	52                   	push   %edx
  801082:	ff d0                	call   *%eax
  801084:	89 c2                	mov    %eax,%edx
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	eb 09                	jmp    801094 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	eb 05                	jmp    801094 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801094:	89 d0                	mov    %edx,%eax
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010af:	eb 21                	jmp    8010d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	89 f0                	mov    %esi,%eax
  8010b6:	29 d8                	sub    %ebx,%eax
  8010b8:	50                   	push   %eax
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	03 45 0c             	add    0xc(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	57                   	push   %edi
  8010c0:	e8 45 ff ff ff       	call   80100a <read>
		if (m < 0)
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 0c                	js     8010d8 <readn+0x3d>
			return m;
		if (m == 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	74 06                	je     8010d6 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d0:	01 c3                	add    %eax,%ebx
  8010d2:	39 f3                	cmp    %esi,%ebx
  8010d4:	72 db                	jb     8010b1 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8010d6:	89 d8                	mov    %ebx,%eax
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 14             	sub    $0x14,%esp
  8010e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	53                   	push   %ebx
  8010ef:	e8 ad fc ff ff       	call   800da1 <fd_lookup>
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 68                	js     801165 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801107:	ff 30                	pushl  (%eax)
  801109:	e8 e9 fc ff ff       	call   800df7 <dev_lookup>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 47                	js     80115c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801115:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801118:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111c:	75 21                	jne    80113f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111e:	a1 04 40 80 00       	mov    0x804004,%eax
  801123:	8b 40 48             	mov    0x48(%eax),%eax
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	53                   	push   %ebx
  80112a:	50                   	push   %eax
  80112b:	68 69 22 80 00       	push   $0x802269
  801130:	e8 58 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113d:	eb 26                	jmp    801165 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801142:	8b 52 0c             	mov    0xc(%edx),%edx
  801145:	85 d2                	test   %edx,%edx
  801147:	74 17                	je     801160 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	ff 75 10             	pushl  0x10(%ebp)
  80114f:	ff 75 0c             	pushl  0xc(%ebp)
  801152:	50                   	push   %eax
  801153:	ff d2                	call   *%edx
  801155:	89 c2                	mov    %eax,%edx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb 09                	jmp    801165 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	eb 05                	jmp    801165 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801160:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801165:	89 d0                	mov    %edx,%eax
  801167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <seek>:

int
seek(int fdnum, off_t offset)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801172:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	ff 75 08             	pushl  0x8(%ebp)
  801179:	e8 23 fc ff ff       	call   800da1 <fd_lookup>
  80117e:	83 c4 08             	add    $0x8,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	78 0e                	js     801193 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801185:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	53                   	push   %ebx
  801199:	83 ec 14             	sub    $0x14,%esp
  80119c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	53                   	push   %ebx
  8011a4:	e8 f8 fb ff ff       	call   800da1 <fd_lookup>
  8011a9:	83 c4 08             	add    $0x8,%esp
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 65                	js     801217 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bc:	ff 30                	pushl  (%eax)
  8011be:	e8 34 fc ff ff       	call   800df7 <dev_lookup>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 44                	js     80120e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d1:	75 21                	jne    8011f4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d8:	8b 40 48             	mov    0x48(%eax),%eax
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	68 2c 22 80 00       	push   $0x80222c
  8011e5:	e8 a3 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f2:	eb 23                	jmp    801217 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f7:	8b 52 18             	mov    0x18(%edx),%edx
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	74 14                	je     801212 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	ff 75 0c             	pushl  0xc(%ebp)
  801204:	50                   	push   %eax
  801205:	ff d2                	call   *%edx
  801207:	89 c2                	mov    %eax,%edx
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	eb 09                	jmp    801217 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120e:	89 c2                	mov    %eax,%edx
  801210:	eb 05                	jmp    801217 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801212:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801217:	89 d0                	mov    %edx,%eax
  801219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	53                   	push   %ebx
  801222:	83 ec 14             	sub    $0x14,%esp
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801228:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	e8 6d fb ff ff       	call   800da1 <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	89 c2                	mov    %eax,%edx
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 58                	js     801295 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801247:	ff 30                	pushl  (%eax)
  801249:	e8 a9 fb ff ff       	call   800df7 <dev_lookup>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 37                	js     80128c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125c:	74 32                	je     801290 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801261:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801268:	00 00 00 
	stat->st_isdir = 0;
  80126b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801272:	00 00 00 
	stat->st_dev = dev;
  801275:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	53                   	push   %ebx
  80127f:	ff 75 f0             	pushl  -0x10(%ebp)
  801282:	ff 50 14             	call   *0x14(%eax)
  801285:	89 c2                	mov    %eax,%edx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	eb 09                	jmp    801295 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	eb 05                	jmp    801295 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801290:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801295:	89 d0                	mov    %edx,%eax
  801297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	6a 00                	push   $0x0
  8012a6:	ff 75 08             	pushl  0x8(%ebp)
  8012a9:	e8 e7 01 00 00       	call   801495 <open>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 db                	test   %ebx,%ebx
  8012b5:	78 1b                	js     8012d2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	ff 75 0c             	pushl  0xc(%ebp)
  8012bd:	53                   	push   %ebx
  8012be:	e8 5b ff ff ff       	call   80121e <fstat>
  8012c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c5:	89 1c 24             	mov    %ebx,(%esp)
  8012c8:	e8 fd fb ff ff       	call   800eca <close>
	return r;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	89 f0                	mov    %esi,%eax
}
  8012d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	89 c6                	mov    %eax,%esi
  8012e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e9:	75 12                	jne    8012fd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	6a 03                	push   $0x3
  8012f0:	e8 18 08 00 00       	call   801b0d <ipc_find_env>
  8012f5:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012fd:	6a 07                	push   $0x7
  8012ff:	68 00 50 80 00       	push   $0x805000
  801304:	56                   	push   %esi
  801305:	ff 35 00 40 80 00    	pushl  0x804000
  80130b:	e8 ac 07 00 00       	call   801abc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801310:	83 c4 0c             	add    $0xc,%esp
  801313:	6a 00                	push   $0x0
  801315:	53                   	push   %ebx
  801316:	6a 00                	push   $0x0
  801318:	e8 39 07 00 00       	call   801a56 <ipc_recv>
}
  80131d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	8b 40 0c             	mov    0xc(%eax),%eax
  801330:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
  801338:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80133d:	ba 00 00 00 00       	mov    $0x0,%edx
  801342:	b8 02 00 00 00       	mov    $0x2,%eax
  801347:	e8 8d ff ff ff       	call   8012d9 <fsipc>
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	8b 40 0c             	mov    0xc(%eax),%eax
  80135a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 06 00 00 00       	mov    $0x6,%eax
  801369:	e8 6b ff ff ff       	call   8012d9 <fsipc>
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	53                   	push   %ebx
  801374:	83 ec 04             	sub    $0x4,%esp
  801377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	8b 40 0c             	mov    0xc(%eax),%eax
  801380:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801385:	ba 00 00 00 00       	mov    $0x0,%edx
  80138a:	b8 05 00 00 00       	mov    $0x5,%eax
  80138f:	e8 45 ff ff ff       	call   8012d9 <fsipc>
  801394:	89 c2                	mov    %eax,%edx
  801396:	85 d2                	test   %edx,%edx
  801398:	78 2c                	js     8013c6 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	68 00 50 80 00       	push   $0x805000
  8013a2:	53                   	push   %ebx
  8013a3:	e8 69 f3 ff ff       	call   800711 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8013d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8013da:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8013e0:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8013e5:	76 05                	jbe    8013ec <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8013e7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8013ec:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8013f1:	83 ec 04             	sub    $0x4,%esp
  8013f4:	50                   	push   %eax
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	68 08 50 80 00       	push   $0x805008
  8013fd:	e8 a1 f4 ff ff       	call   8008a3 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 04 00 00 00       	mov    $0x4,%eax
  80140c:	e8 c8 fe ff ff       	call   8012d9 <fsipc>
	return write;
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	8b 40 0c             	mov    0xc(%eax),%eax
  801421:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801426:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 03 00 00 00       	mov    $0x3,%eax
  801436:	e8 9e fe ff ff       	call   8012d9 <fsipc>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 4b                	js     80148c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801441:	39 c6                	cmp    %eax,%esi
  801443:	73 16                	jae    80145b <devfile_read+0x48>
  801445:	68 98 22 80 00       	push   $0x802298
  80144a:	68 9f 22 80 00       	push   $0x80229f
  80144f:	6a 7c                	push   $0x7c
  801451:	68 b4 22 80 00       	push   $0x8022b4
  801456:	e8 b5 05 00 00       	call   801a10 <_panic>
	assert(r <= PGSIZE);
  80145b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801460:	7e 16                	jle    801478 <devfile_read+0x65>
  801462:	68 bf 22 80 00       	push   $0x8022bf
  801467:	68 9f 22 80 00       	push   $0x80229f
  80146c:	6a 7d                	push   $0x7d
  80146e:	68 b4 22 80 00       	push   $0x8022b4
  801473:	e8 98 05 00 00       	call   801a10 <_panic>
	memmove(buf, &fsipcbuf, r);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	50                   	push   %eax
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	ff 75 0c             	pushl  0xc(%ebp)
  801484:	e8 1a f4 ff ff       	call   8008a3 <memmove>
	return r;
  801489:	83 c4 10             	add    $0x10,%esp
}
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	53                   	push   %ebx
  801499:	83 ec 20             	sub    $0x20,%esp
  80149c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80149f:	53                   	push   %ebx
  8014a0:	e8 33 f2 ff ff       	call   8006d8 <strlen>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ad:	7f 67                	jg     801516 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	e8 97 f8 ff ff       	call   800d52 <fd_alloc>
  8014bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014be:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 57                	js     80151b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	68 00 50 80 00       	push   $0x805000
  8014cd:	e8 3f f2 ff ff       	call   800711 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e2:	e8 f2 fd ff ff       	call   8012d9 <fsipc>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	79 14                	jns    801504 <open+0x6f>
		fd_close(fd, 0);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	6a 00                	push   $0x0
  8014f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f8:	e8 4d f9 ff ff       	call   800e4a <fd_close>
		return r;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	89 da                	mov    %ebx,%edx
  801502:	eb 17                	jmp    80151b <open+0x86>
	}

	return fd2num(fd);
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	ff 75 f4             	pushl  -0xc(%ebp)
  80150a:	e8 1c f8 ff ff       	call   800d2b <fd2num>
  80150f:	89 c2                	mov    %eax,%edx
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	eb 05                	jmp    80151b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801516:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 08 00 00 00       	mov    $0x8,%eax
  801532:	e8 a2 fd ff ff       	call   8012d9 <fsipc>
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 ef f7 ff ff       	call   800d3b <fd2data>
  80154c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80154e:	83 c4 08             	add    $0x8,%esp
  801551:	68 cb 22 80 00       	push   $0x8022cb
  801556:	53                   	push   %ebx
  801557:	e8 b5 f1 ff ff       	call   800711 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80155c:	8b 56 04             	mov    0x4(%esi),%edx
  80155f:	89 d0                	mov    %edx,%eax
  801561:	2b 06                	sub    (%esi),%eax
  801563:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801569:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801570:	00 00 00 
	stat->st_dev = &devpipe;
  801573:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80157a:	30 80 00 
	return 0;
}
  80157d:	b8 00 00 00 00       	mov    $0x0,%eax
  801582:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801585:	5b                   	pop    %ebx
  801586:	5e                   	pop    %esi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801593:	53                   	push   %ebx
  801594:	6a 00                	push   $0x0
  801596:	e8 05 f6 ff ff       	call   800ba0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80159b:	89 1c 24             	mov    %ebx,(%esp)
  80159e:	e8 98 f7 ff ff       	call   800d3b <fd2data>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	50                   	push   %eax
  8015a7:	6a 00                	push   $0x0
  8015a9:	e8 f2 f5 ff ff       	call   800ba0 <sys_page_unmap>
}
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	57                   	push   %edi
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 1c             	sub    $0x1c,%esp
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	57                   	push   %edi
  8015cc:	e8 74 05 00 00       	call   801b45 <pageref>
  8015d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d4:	89 34 24             	mov    %esi,(%esp)
  8015d7:	e8 69 05 00 00       	call   801b45 <pageref>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015e2:	0f 94 c0             	sete   %al
  8015e5:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8015e8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015ee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015f1:	39 cb                	cmp    %ecx,%ebx
  8015f3:	74 15                	je     80160a <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8015f5:	8b 52 58             	mov    0x58(%edx),%edx
  8015f8:	50                   	push   %eax
  8015f9:	52                   	push   %edx
  8015fa:	53                   	push   %ebx
  8015fb:	68 d8 22 80 00       	push   $0x8022d8
  801600:	e8 88 eb ff ff       	call   80018d <cprintf>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb b6                	jmp    8015c0 <_pipeisclosed+0xd>
	}
}
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	57                   	push   %edi
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 28             	sub    $0x28,%esp
  80161b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80161e:	56                   	push   %esi
  80161f:	e8 17 f7 ff ff       	call   800d3b <fd2data>
  801624:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	bf 00 00 00 00       	mov    $0x0,%edi
  80162e:	eb 4b                	jmp    80167b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801630:	89 da                	mov    %ebx,%edx
  801632:	89 f0                	mov    %esi,%eax
  801634:	e8 7a ff ff ff       	call   8015b3 <_pipeisclosed>
  801639:	85 c0                	test   %eax,%eax
  80163b:	75 48                	jne    801685 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80163d:	e8 ba f4 ff ff       	call   800afc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801642:	8b 43 04             	mov    0x4(%ebx),%eax
  801645:	8b 0b                	mov    (%ebx),%ecx
  801647:	8d 51 20             	lea    0x20(%ecx),%edx
  80164a:	39 d0                	cmp    %edx,%eax
  80164c:	73 e2                	jae    801630 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80164e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801651:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801655:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801658:	89 c2                	mov    %eax,%edx
  80165a:	c1 fa 1f             	sar    $0x1f,%edx
  80165d:	89 d1                	mov    %edx,%ecx
  80165f:	c1 e9 1b             	shr    $0x1b,%ecx
  801662:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801665:	83 e2 1f             	and    $0x1f,%edx
  801668:	29 ca                	sub    %ecx,%edx
  80166a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80166e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801672:	83 c0 01             	add    $0x1,%eax
  801675:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801678:	83 c7 01             	add    $0x1,%edi
  80167b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80167e:	75 c2                	jne    801642 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801680:	8b 45 10             	mov    0x10(%ebp),%eax
  801683:	eb 05                	jmp    80168a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 18             	sub    $0x18,%esp
  80169b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80169e:	57                   	push   %edi
  80169f:	e8 97 f6 ff ff       	call   800d3b <fd2data>
  8016a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ae:	eb 3d                	jmp    8016ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b0:	85 db                	test   %ebx,%ebx
  8016b2:	74 04                	je     8016b8 <devpipe_read+0x26>
				return i;
  8016b4:	89 d8                	mov    %ebx,%eax
  8016b6:	eb 44                	jmp    8016fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016b8:	89 f2                	mov    %esi,%edx
  8016ba:	89 f8                	mov    %edi,%eax
  8016bc:	e8 f2 fe ff ff       	call   8015b3 <_pipeisclosed>
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	75 32                	jne    8016f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c5:	e8 32 f4 ff ff       	call   800afc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016ca:	8b 06                	mov    (%esi),%eax
  8016cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8016cf:	74 df                	je     8016b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d1:	99                   	cltd   
  8016d2:	c1 ea 1b             	shr    $0x1b,%edx
  8016d5:	01 d0                	add    %edx,%eax
  8016d7:	83 e0 1f             	and    $0x1f,%eax
  8016da:	29 d0                	sub    %edx,%eax
  8016dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ea:	83 c3 01             	add    $0x1,%ebx
  8016ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f0:	75 d8                	jne    8016ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f5:	eb 05                	jmp    8016fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5f                   	pop    %edi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80170c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	e8 3d f6 ff ff       	call   800d52 <fd_alloc>
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	89 c2                	mov    %eax,%edx
  80171a:	85 c0                	test   %eax,%eax
  80171c:	0f 88 2c 01 00 00    	js     80184e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801722:	83 ec 04             	sub    $0x4,%esp
  801725:	68 07 04 00 00       	push   $0x407
  80172a:	ff 75 f4             	pushl  -0xc(%ebp)
  80172d:	6a 00                	push   $0x0
  80172f:	e8 e7 f3 ff ff       	call   800b1b <sys_page_alloc>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	89 c2                	mov    %eax,%edx
  801739:	85 c0                	test   %eax,%eax
  80173b:	0f 88 0d 01 00 00    	js     80184e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	e8 05 f6 ff ff       	call   800d52 <fd_alloc>
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	0f 88 e2 00 00 00    	js     80183c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	68 07 04 00 00       	push   $0x407
  801762:	ff 75 f0             	pushl  -0x10(%ebp)
  801765:	6a 00                	push   $0x0
  801767:	e8 af f3 ff ff       	call   800b1b <sys_page_alloc>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	0f 88 c3 00 00 00    	js     80183c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	ff 75 f4             	pushl  -0xc(%ebp)
  80177f:	e8 b7 f5 ff ff       	call   800d3b <fd2data>
  801784:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801786:	83 c4 0c             	add    $0xc,%esp
  801789:	68 07 04 00 00       	push   $0x407
  80178e:	50                   	push   %eax
  80178f:	6a 00                	push   $0x0
  801791:	e8 85 f3 ff ff       	call   800b1b <sys_page_alloc>
  801796:	89 c3                	mov    %eax,%ebx
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	0f 88 89 00 00 00    	js     80182c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a9:	e8 8d f5 ff ff       	call   800d3b <fd2data>
  8017ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b5:	50                   	push   %eax
  8017b6:	6a 00                	push   $0x0
  8017b8:	56                   	push   %esi
  8017b9:	6a 00                	push   $0x0
  8017bb:	e8 9e f3 ff ff       	call   800b5e <sys_page_map>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 20             	add    $0x20,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 55                	js     80181e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017c9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	e8 2d f5 ff ff       	call   800d2b <fd2num>
  8017fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801801:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801803:	83 c4 04             	add    $0x4,%esp
  801806:	ff 75 f0             	pushl  -0x10(%ebp)
  801809:	e8 1d f5 ff ff       	call   800d2b <fd2num>
  80180e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801811:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	eb 30                	jmp    80184e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	56                   	push   %esi
  801822:	6a 00                	push   $0x0
  801824:	e8 77 f3 ff ff       	call   800ba0 <sys_page_unmap>
  801829:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	ff 75 f0             	pushl  -0x10(%ebp)
  801832:	6a 00                	push   $0x0
  801834:	e8 67 f3 ff ff       	call   800ba0 <sys_page_unmap>
  801839:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	ff 75 f4             	pushl  -0xc(%ebp)
  801842:	6a 00                	push   $0x0
  801844:	e8 57 f3 ff ff       	call   800ba0 <sys_page_unmap>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80184e:	89 d0                	mov    %edx,%eax
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	e8 38 f5 ff ff       	call   800da1 <fd_lookup>
  801869:	89 c2                	mov    %eax,%edx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 d2                	test   %edx,%edx
  801870:	78 18                	js     80188a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 f4             	pushl  -0xc(%ebp)
  801878:	e8 be f4 ff ff       	call   800d3b <fd2data>
	return _pipeisclosed(fd, p);
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	e8 2c fd ff ff       	call   8015b3 <_pipeisclosed>
  801887:	83 c4 10             	add    $0x10,%esp
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189c:	68 09 23 80 00       	push   $0x802309
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	e8 68 ee ff ff       	call   800711 <strcpy>
	return 0;
}
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c7:	eb 2e                	jmp    8018f7 <devcons_write+0x47>
		m = n - tot;
  8018c9:	8b 55 10             	mov    0x10(%ebp),%edx
  8018cc:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  8018ce:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  8018d3:	83 fa 7f             	cmp    $0x7f,%edx
  8018d6:	77 02                	ja     8018da <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d8:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	56                   	push   %esi
  8018de:	03 45 0c             	add    0xc(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	57                   	push   %edi
  8018e3:	e8 bb ef ff ff       	call   8008a3 <memmove>
		sys_cputs(buf, m);
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	56                   	push   %esi
  8018ec:	57                   	push   %edi
  8018ed:	e8 6d f1 ff ff       	call   800a5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f2:	01 f3                	add    %esi,%ebx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	89 d8                	mov    %ebx,%eax
  8018f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018fc:	72 cb                	jb     8018c9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5f                   	pop    %edi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801911:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801915:	75 07                	jne    80191e <devcons_read+0x18>
  801917:	eb 28                	jmp    801941 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801919:	e8 de f1 ff ff       	call   800afc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80191e:	e8 5a f1 ff ff       	call   800a7d <sys_cgetc>
  801923:	85 c0                	test   %eax,%eax
  801925:	74 f2                	je     801919 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801927:	85 c0                	test   %eax,%eax
  801929:	78 16                	js     801941 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80192b:	83 f8 04             	cmp    $0x4,%eax
  80192e:	74 0c                	je     80193c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801930:	8b 55 0c             	mov    0xc(%ebp),%edx
  801933:	88 02                	mov    %al,(%edx)
	return 1;
  801935:	b8 01 00 00 00       	mov    $0x1,%eax
  80193a:	eb 05                	jmp    801941 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80193c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80194f:	6a 01                	push   $0x1
  801951:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	e8 05 f1 ff ff       	call   800a5f <sys_cputs>
  80195a:	83 c4 10             	add    $0x10,%esp
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <getchar>:

int
getchar(void)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801965:	6a 01                	push   $0x1
  801967:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	6a 00                	push   $0x0
  80196d:	e8 98 f6 ff ff       	call   80100a <read>
	if (r < 0)
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	78 0f                	js     801988 <getchar+0x29>
		return r;
	if (r < 1)
  801979:	85 c0                	test   %eax,%eax
  80197b:	7e 06                	jle    801983 <getchar+0x24>
		return -E_EOF;
	return c;
  80197d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801981:	eb 05                	jmp    801988 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801983:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 05 f4 ff ff       	call   800da1 <fd_lookup>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 11                	js     8019b4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ac:	39 10                	cmp    %edx,(%eax)
  8019ae:	0f 94 c0             	sete   %al
  8019b1:	0f b6 c0             	movzbl %al,%eax
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <opencons>:

int
opencons(void)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	e8 8d f3 ff ff       	call   800d52 <fd_alloc>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 3e                	js     801a0c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	68 07 04 00 00       	push   $0x407
  8019d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 3b f1 ff ff       	call   800b1b <sys_page_alloc>
  8019e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 23                	js     801a0c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019e9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	50                   	push   %eax
  801a02:	e8 24 f3 ff ff       	call   800d2b <fd2num>
  801a07:	89 c2                	mov    %eax,%edx
  801a09:	83 c4 10             	add    $0x10,%esp
}
  801a0c:	89 d0                	mov    %edx,%eax
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a15:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a18:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a1e:	e8 ba f0 ff ff       	call   800add <sys_getenvid>
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	56                   	push   %esi
  801a2d:	50                   	push   %eax
  801a2e:	68 18 23 80 00       	push   $0x802318
  801a33:	e8 55 e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a38:	83 c4 18             	add    $0x18,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	ff 75 10             	pushl  0x10(%ebp)
  801a3f:	e8 f8 e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a44:	c7 04 24 67 22 80 00 	movl   $0x802267,(%esp)
  801a4b:	e8 3d e7 ff ff       	call   80018d <cprintf>
  801a50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a53:	cc                   	int3   
  801a54:	eb fd                	jmp    801a53 <_panic+0x43>

00801a56 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a64:	85 f6                	test   %esi,%esi
  801a66:	74 06                	je     801a6e <ipc_recv+0x18>
  801a68:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a6e:	85 db                	test   %ebx,%ebx
  801a70:	74 06                	je     801a78 <ipc_recv+0x22>
  801a72:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a78:	83 f8 01             	cmp    $0x1,%eax
  801a7b:	19 d2                	sbb    %edx,%edx
  801a7d:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 43 f2 ff ff       	call   800ccb <sys_ipc_recv>
  801a88:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 d2                	test   %edx,%edx
  801a8f:	75 24                	jne    801ab5 <ipc_recv+0x5f>
	if (from_env_store)
  801a91:	85 f6                	test   %esi,%esi
  801a93:	74 0a                	je     801a9f <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a95:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9a:	8b 40 70             	mov    0x70(%eax),%eax
  801a9d:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	74 0a                	je     801aad <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801aa3:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa8:	8b 40 74             	mov    0x74(%eax),%eax
  801aab:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801aad:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab2:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801ab5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801ace:	83 fb 01             	cmp    $0x1,%ebx
  801ad1:	19 c0                	sbb    %eax,%eax
  801ad3:	09 c3                	or     %eax,%ebx
  801ad5:	eb 1c                	jmp    801af3 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801ad7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ada:	74 12                	je     801aee <ipc_send+0x32>
  801adc:	50                   	push   %eax
  801add:	68 3c 23 80 00       	push   $0x80233c
  801ae2:	6a 36                	push   $0x36
  801ae4:	68 53 23 80 00       	push   $0x802353
  801ae9:	e8 22 ff ff ff       	call   801a10 <_panic>
		sys_yield();
  801aee:	e8 09 f0 ff ff       	call   800afc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801af3:	ff 75 14             	pushl  0x14(%ebp)
  801af6:	53                   	push   %ebx
  801af7:	56                   	push   %esi
  801af8:	57                   	push   %edi
  801af9:	e8 aa f1 ff ff       	call   800ca8 <sys_ipc_try_send>
		if (ret == 0) break;
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	75 d2                	jne    801ad7 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801b05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5f                   	pop    %edi
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    

00801b0d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b18:	6b d0 78             	imul   $0x78,%eax,%edx
  801b1b:	83 c2 50             	add    $0x50,%edx
  801b1e:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801b24:	39 ca                	cmp    %ecx,%edx
  801b26:	75 0d                	jne    801b35 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b28:	6b c0 78             	imul   $0x78,%eax,%eax
  801b2b:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b30:	8b 40 08             	mov    0x8(%eax),%eax
  801b33:	eb 0e                	jmp    801b43 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b35:	83 c0 01             	add    $0x1,%eax
  801b38:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3d:	75 d9                	jne    801b18 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b3f:	66 b8 00 00          	mov    $0x0,%ax
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4b:	89 d0                	mov    %edx,%eax
  801b4d:	c1 e8 16             	shr    $0x16,%eax
  801b50:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5c:	f6 c1 01             	test   $0x1,%cl
  801b5f:	74 1d                	je     801b7e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b61:	c1 ea 0c             	shr    $0xc,%edx
  801b64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b6b:	f6 c2 01             	test   $0x1,%dl
  801b6e:	74 0e                	je     801b7e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b70:	c1 ea 0c             	shr    $0xc,%edx
  801b73:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b7a:	ef 
  801b7b:	0f b7 c0             	movzwl %ax,%eax
}
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	83 ec 10             	sub    $0x10,%esp
  801b86:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b8a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b8e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b96:	85 d2                	test   %edx,%edx
  801b98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b9c:	89 34 24             	mov    %esi,(%esp)
  801b9f:	89 c8                	mov    %ecx,%eax
  801ba1:	75 35                	jne    801bd8 <__udivdi3+0x58>
  801ba3:	39 f1                	cmp    %esi,%ecx
  801ba5:	0f 87 bd 00 00 00    	ja     801c68 <__udivdi3+0xe8>
  801bab:	85 c9                	test   %ecx,%ecx
  801bad:	89 cd                	mov    %ecx,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f1                	div    %ecx
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c6                	mov    %eax,%esi
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	f7 f5                	div    %ebp
  801bc8:	89 f2                	mov    %esi,%edx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    
  801bd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd8:	3b 14 24             	cmp    (%esp),%edx
  801bdb:	77 7b                	ja     801c58 <__udivdi3+0xd8>
  801bdd:	0f bd f2             	bsr    %edx,%esi
  801be0:	83 f6 1f             	xor    $0x1f,%esi
  801be3:	0f 84 97 00 00 00    	je     801c80 <__udivdi3+0x100>
  801be9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bee:	89 d7                	mov    %edx,%edi
  801bf0:	89 f1                	mov    %esi,%ecx
  801bf2:	29 f5                	sub    %esi,%ebp
  801bf4:	d3 e7                	shl    %cl,%edi
  801bf6:	89 c2                	mov    %eax,%edx
  801bf8:	89 e9                	mov    %ebp,%ecx
  801bfa:	d3 ea                	shr    %cl,%edx
  801bfc:	89 f1                	mov    %esi,%ecx
  801bfe:	09 fa                	or     %edi,%edx
  801c00:	8b 3c 24             	mov    (%esp),%edi
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c09:	89 e9                	mov    %ebp,%ecx
  801c0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c13:	89 fa                	mov    %edi,%edx
  801c15:	d3 ea                	shr    %cl,%edx
  801c17:	89 f1                	mov    %esi,%ecx
  801c19:	d3 e7                	shl    %cl,%edi
  801c1b:	89 e9                	mov    %ebp,%ecx
  801c1d:	d3 e8                	shr    %cl,%eax
  801c1f:	09 c7                	or     %eax,%edi
  801c21:	89 f8                	mov    %edi,%eax
  801c23:	f7 74 24 08          	divl   0x8(%esp)
  801c27:	89 d5                	mov    %edx,%ebp
  801c29:	89 c7                	mov    %eax,%edi
  801c2b:	f7 64 24 0c          	mull   0xc(%esp)
  801c2f:	39 d5                	cmp    %edx,%ebp
  801c31:	89 14 24             	mov    %edx,(%esp)
  801c34:	72 11                	jb     801c47 <__udivdi3+0xc7>
  801c36:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c3a:	89 f1                	mov    %esi,%ecx
  801c3c:	d3 e2                	shl    %cl,%edx
  801c3e:	39 c2                	cmp    %eax,%edx
  801c40:	73 5e                	jae    801ca0 <__udivdi3+0x120>
  801c42:	3b 2c 24             	cmp    (%esp),%ebp
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x120>
  801c47:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c4a:	31 f6                	xor    %esi,%esi
  801c4c:	89 f2                	mov    %esi,%edx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    
  801c55:	8d 76 00             	lea    0x0(%esi),%esi
  801c58:	31 f6                	xor    %esi,%esi
  801c5a:	31 c0                	xor    %eax,%eax
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	89 f2                	mov    %esi,%edx
  801c6a:	31 f6                	xor    %esi,%esi
  801c6c:	89 f8                	mov    %edi,%eax
  801c6e:	f7 f1                	div    %ecx
  801c70:	89 f2                	mov    %esi,%edx
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c84:	76 0b                	jbe    801c91 <__udivdi3+0x111>
  801c86:	31 c0                	xor    %eax,%eax
  801c88:	3b 14 24             	cmp    (%esp),%edx
  801c8b:	0f 83 37 ff ff ff    	jae    801bc8 <__udivdi3+0x48>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	e9 2d ff ff ff       	jmp    801bc8 <__udivdi3+0x48>
  801c9b:	90                   	nop
  801c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 f8                	mov    %edi,%eax
  801ca2:	31 f6                	xor    %esi,%esi
  801ca4:	e9 1f ff ff ff       	jmp    801bc8 <__udivdi3+0x48>
  801ca9:	66 90                	xchg   %ax,%ax
  801cab:	66 90                	xchg   %ax,%ax
  801cad:	66 90                	xchg   %ax,%ax
  801caf:	90                   	nop

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	83 ec 20             	sub    $0x20,%esp
  801cb6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801cba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc2:	89 c6                	mov    %eax,%esi
  801cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cc8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ccc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cd0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cd4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cd8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	75 1e                	jne    801d00 <__umoddi3+0x50>
  801ce2:	39 f7                	cmp    %esi,%edi
  801ce4:	76 52                	jbe    801d38 <__umoddi3+0x88>
  801ce6:	89 c8                	mov    %ecx,%eax
  801ce8:	89 f2                	mov    %esi,%edx
  801cea:	f7 f7                	div    %edi
  801cec:	89 d0                	mov    %edx,%eax
  801cee:	31 d2                	xor    %edx,%edx
  801cf0:	83 c4 20             	add    $0x20,%esp
  801cf3:	5e                   	pop    %esi
  801cf4:	5f                   	pop    %edi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    
  801cf7:	89 f6                	mov    %esi,%esi
  801cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d00:	39 f0                	cmp    %esi,%eax
  801d02:	77 5c                	ja     801d60 <__umoddi3+0xb0>
  801d04:	0f bd e8             	bsr    %eax,%ebp
  801d07:	83 f5 1f             	xor    $0x1f,%ebp
  801d0a:	75 64                	jne    801d70 <__umoddi3+0xc0>
  801d0c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d10:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d14:	0f 86 f6 00 00 00    	jbe    801e10 <__umoddi3+0x160>
  801d1a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d1e:	0f 82 ec 00 00 00    	jb     801e10 <__umoddi3+0x160>
  801d24:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d28:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d2c:	83 c4 20             	add    $0x20,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
  801d33:	90                   	nop
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	85 ff                	test   %edi,%edi
  801d3a:	89 fd                	mov    %edi,%ebp
  801d3c:	75 0b                	jne    801d49 <__umoddi3+0x99>
  801d3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f7                	div    %edi
  801d47:	89 c5                	mov    %eax,%ebp
  801d49:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	f7 f5                	div    %ebp
  801d51:	89 c8                	mov    %ecx,%eax
  801d53:	f7 f5                	div    %ebp
  801d55:	eb 95                	jmp    801cec <__umoddi3+0x3c>
  801d57:	89 f6                	mov    %esi,%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    
  801d6b:	90                   	nop
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	b8 20 00 00 00       	mov    $0x20,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	29 e8                	sub    %ebp,%eax
  801d79:	d3 e2                	shl    %cl,%edx
  801d7b:	89 c7                	mov    %eax,%edi
  801d7d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d81:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d85:	89 f9                	mov    %edi,%ecx
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 c1                	mov    %eax,%ecx
  801d8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d8f:	09 d1                	or     %edx,%ecx
  801d91:	89 fa                	mov    %edi,%edx
  801d93:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d97:	89 e9                	mov    %ebp,%ecx
  801d99:	d3 e0                	shl    %cl,%eax
  801d9b:	89 f9                	mov    %edi,%ecx
  801d9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	d3 e8                	shr    %cl,%eax
  801da5:	89 e9                	mov    %ebp,%ecx
  801da7:	89 c7                	mov    %eax,%edi
  801da9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dad:	d3 e6                	shl    %cl,%esi
  801daf:	89 d1                	mov    %edx,%ecx
  801db1:	89 fa                	mov    %edi,%edx
  801db3:	d3 e8                	shr    %cl,%eax
  801db5:	89 e9                	mov    %ebp,%ecx
  801db7:	09 f0                	or     %esi,%eax
  801db9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801dbd:	f7 74 24 10          	divl   0x10(%esp)
  801dc1:	d3 e6                	shl    %cl,%esi
  801dc3:	89 d1                	mov    %edx,%ecx
  801dc5:	f7 64 24 0c          	mull   0xc(%esp)
  801dc9:	39 d1                	cmp    %edx,%ecx
  801dcb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801dcf:	89 d7                	mov    %edx,%edi
  801dd1:	89 c6                	mov    %eax,%esi
  801dd3:	72 0a                	jb     801ddf <__umoddi3+0x12f>
  801dd5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801dd9:	73 10                	jae    801deb <__umoddi3+0x13b>
  801ddb:	39 d1                	cmp    %edx,%ecx
  801ddd:	75 0c                	jne    801deb <__umoddi3+0x13b>
  801ddf:	89 d7                	mov    %edx,%edi
  801de1:	89 c6                	mov    %eax,%esi
  801de3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801de7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801deb:	89 ca                	mov    %ecx,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	8b 44 24 14          	mov    0x14(%esp),%eax
  801df3:	29 f0                	sub    %esi,%eax
  801df5:	19 fa                	sbb    %edi,%edx
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dfe:	89 d7                	mov    %edx,%edi
  801e00:	d3 e7                	shl    %cl,%edi
  801e02:	89 e9                	mov    %ebp,%ecx
  801e04:	09 f8                	or     %edi,%eax
  801e06:	d3 ea                	shr    %cl,%edx
  801e08:	83 c4 20             	add    $0x20,%esp
  801e0b:	5e                   	pop    %esi
  801e0c:	5f                   	pop    %edi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    
  801e0f:	90                   	nop
  801e10:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e14:	29 f9                	sub    %edi,%ecx
  801e16:	19 c6                	sbb    %eax,%esi
  801e18:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e1c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e20:	e9 ff fe ff ff       	jmp    801d24 <__umoddi3+0x74>
