
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 e2 0a 00 00       	call   800b24 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 22 80 00       	push   $0x802200
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
  800067:	83 c4 10             	add    $0x10,%esp
}
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 9c 06 00 00       	call   80071f <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 11 22 80 00       	push   $0x802211
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 60 06 00 00       	call   800705 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 bf 0d 00 00       	call   800e6c <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 10 22 80 00       	push   $0x802210
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
  8000dc:	83 c4 10             	add    $0x10,%esp
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ec:	e8 33 0a 00 00       	call   800b24 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 78             	imul   $0x78,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
  80011d:	83 c4 10             	add    $0x10,%esp
#endif
}
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 ef 10 00 00       	call   801221 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 a7 09 00 00       	call   800ae3 <sys_env_destroy>
  80013c:	83 c4 10             	add    $0x10,%esp
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 35 09 00 00       	call   800aa6 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 4f 01 00 00       	call   800306 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 da 08 00 00       	call   800aa6 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 d1                	mov    %edx,%ecx
  8001fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800200:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800203:	8b 45 10             	mov    0x10(%ebp),%eax
  800206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800209:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800213:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800216:	72 05                	jb     80021d <printnum+0x35>
  800218:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80021b:	77 3e                	ja     80025b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	53                   	push   %ebx
  800227:	50                   	push   %eax
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 14 1d 00 00       	call   801f50 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 13                	jmp    800262 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	85 db                	test   %ebx,%ebx
  800260:	7f ed                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	83 ec 04             	sub    $0x4,%esp
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	ff 75 dc             	pushl  -0x24(%ebp)
  800272:	ff 75 d8             	pushl  -0x28(%ebp)
  800275:	e8 06 1e 00 00       	call   802080 <__umoddi3>
  80027a:	83 c4 14             	add    $0x14,%esp
  80027d:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  800284:	50                   	push   %eax
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	88 02                	mov    %al,(%edx)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 10             	pushl  0x10(%ebp)
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	e8 05 00 00 00       	call   800306 <vprintfmt>
	va_end(ap);
  800301:	83 c4 10             	add    $0x10,%esp
}
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 2c             	sub    $0x2c,%esp
  80030f:	8b 75 08             	mov    0x8(%ebp),%esi
  800312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800315:	8b 7d 10             	mov    0x10(%ebp),%edi
  800318:	eb 12                	jmp    80032c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 84 8d 03 00 00    	je     8006af <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	53                   	push   %ebx
  800326:	50                   	push   %eax
  800327:	ff d6                	call   *%esi
  800329:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032c:	83 c7 01             	add    $0x1,%edi
  80032f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800333:	83 f8 25             	cmp    $0x25,%eax
  800336:	75 e2                	jne    80031a <vprintfmt+0x14>
  800338:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 07                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8d 47 01             	lea    0x1(%edi),%eax
  800362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800365:	0f b6 07             	movzbl (%edi),%eax
  800368:	0f b6 c8             	movzbl %al,%ecx
  80036b:	83 e8 23             	sub    $0x23,%eax
  80036e:	3c 55                	cmp    $0x55,%al
  800370:	0f 87 1e 03 00 00    	ja     800694 <vprintfmt+0x38e>
  800376:	0f b6 c0             	movzbl %al,%eax
  800379:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800383:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800387:	eb d6                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80039b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a1:	83 fa 09             	cmp    $0x9,%edx
  8003a4:	77 38                	ja     8003de <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bc:	eb 26                	jmp    8003e4 <vprintfmt+0xde>
  8003be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c1:	89 c8                	mov    %ecx,%eax
  8003c3:	c1 f8 1f             	sar    $0x1f,%eax
  8003c6:	f7 d0                	not    %eax
  8003c8:	21 c1                	and    %eax,%ecx
  8003ca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d0:	eb 8d                	jmp    80035f <vprintfmt+0x59>
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003dc:	eb 81                	jmp    80035f <vprintfmt+0x59>
  8003de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e8:	0f 89 71 ff ff ff    	jns    80035f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fb:	e9 5f ff ff ff       	jmp    80035f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800400:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800406:	e9 54 ff ff ff       	jmp    80035f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	53                   	push   %ebx
  800418:	ff 30                	pushl  (%eax)
  80041a:	ff d6                	call   *%esi
			break;
  80041c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800422:	e9 05 ff ff ff       	jmp    80032c <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	99                   	cltd   
  800433:	31 d0                	xor    %edx,%eax
  800435:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800437:	83 f8 0f             	cmp    $0xf,%eax
  80043a:	7f 0b                	jg     800447 <vprintfmt+0x141>
  80043c:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800443:	85 d2                	test   %edx,%edx
  800445:	75 18                	jne    80045f <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 38 22 80 00       	push   $0x802238
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 95 fe ff ff       	call   8002e9 <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045a:	e9 cd fe ff ff       	jmp    80032c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045f:	52                   	push   %edx
  800460:	68 c1 26 80 00       	push   $0x8026c1
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 7d fe ff ff       	call   8002e9 <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800472:	e9 b5 fe ff ff       	jmp    80032c <vprintfmt+0x26>
  800477:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80047a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
  80048b:	85 ff                	test   %edi,%edi
  80048d:	75 05                	jne    800494 <vprintfmt+0x18e>
				p = "(null)";
  80048f:	bf 31 22 80 00       	mov    $0x802231,%edi
			if (width > 0 && padc != '-')
  800494:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800498:	0f 84 91 00 00 00    	je     80052f <vprintfmt+0x229>
  80049e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004a2:	0f 8e 95 00 00 00    	jle    80053d <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	51                   	push   %ecx
  8004ac:	57                   	push   %edi
  8004ad:	e8 85 02 00 00       	call   800737 <strnlen>
  8004b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1c5>
  8004de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	89 c8                	mov    %ecx,%eax
  8004e6:	c1 f8 1f             	sar    $0x1f,%eax
  8004e9:	f7 d0                	not    %eax
  8004eb:	21 c8                	and    %ecx,%eax
  8004ed:	29 c1                	sub    %eax,%ecx
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	89 cb                	mov    %ecx,%ebx
  8004fa:	eb 4d                	jmp    800549 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800500:	74 1b                	je     80051d <vprintfmt+0x217>
  800502:	0f be c0             	movsbl %al,%eax
  800505:	83 e8 20             	sub    $0x20,%eax
  800508:	83 f8 5e             	cmp    $0x5e,%eax
  80050b:	76 10                	jbe    80051d <vprintfmt+0x217>
					putch('?', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	6a 3f                	push   $0x3f
  800515:	ff 55 08             	call   *0x8(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb 0d                	jmp    80052a <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	ff 75 0c             	pushl  0xc(%ebp)
  800523:	52                   	push   %edx
  800524:	ff 55 08             	call   *0x8(%ebp)
  800527:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	83 eb 01             	sub    $0x1,%ebx
  80052d:	eb 1a                	jmp    800549 <vprintfmt+0x243>
  80052f:	89 75 08             	mov    %esi,0x8(%ebp)
  800532:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800538:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053b:	eb 0c                	jmp    800549 <vprintfmt+0x243>
  80053d:	89 75 08             	mov    %esi,0x8(%ebp)
  800540:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800546:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800549:	83 c7 01             	add    $0x1,%edi
  80054c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800550:	0f be d0             	movsbl %al,%edx
  800553:	85 d2                	test   %edx,%edx
  800555:	74 23                	je     80057a <vprintfmt+0x274>
  800557:	85 f6                	test   %esi,%esi
  800559:	78 a1                	js     8004fc <vprintfmt+0x1f6>
  80055b:	83 ee 01             	sub    $0x1,%esi
  80055e:	79 9c                	jns    8004fc <vprintfmt+0x1f6>
  800560:	89 df                	mov    %ebx,%edi
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800568:	eb 18                	jmp    800582 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 20                	push   $0x20
  800570:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb 08                	jmp    800582 <vprintfmt+0x27c>
  80057a:	89 df                	mov    %ebx,%edi
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	85 ff                	test   %edi,%edi
  800584:	7f e4                	jg     80056a <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	e9 9e fd ff ff       	jmp    80032c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058e:	83 fa 01             	cmp    $0x1,%edx
  800591:	7e 16                	jle    8005a9 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 08             	lea    0x8(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 50 04             	mov    0x4(%eax),%edx
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a7:	eb 32                	jmp    8005db <vprintfmt+0x2d5>
	else if (lflag)
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 18                	je     8005c5 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 c1                	mov    %eax,%ecx
  8005bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c3:	eb 16                	jmp    8005db <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 c1                	mov    %eax,%ecx
  8005d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005de:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ea:	79 74                	jns    800660 <vprintfmt+0x35a>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fa:	f7 d8                	neg    %eax
  8005fc:	83 d2 00             	adc    $0x0,%edx
  8005ff:	f7 da                	neg    %edx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800609:	eb 55                	jmp    800660 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 7f fc ff ff       	call   800292 <getuint>
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800618:	eb 46                	jmp    800660 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 70 fc ff ff       	call   800292 <getuint>
			base = 8;
  800622:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800627:	eb 37                	jmp    800660 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 30                	push   $0x30
  80062f:	ff d6                	call   *%esi
			putch('x', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 78                	push   $0x78
  800637:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800642:	8b 00                	mov    (%eax),%eax
  800644:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800649:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 37 fc ff ff       	call   800292 <getuint>
			base = 16;
  80065b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800667:	57                   	push   %edi
  800668:	ff 75 e0             	pushl  -0x20(%ebp)
  80066b:	51                   	push   %ecx
  80066c:	52                   	push   %edx
  80066d:	50                   	push   %eax
  80066e:	89 da                	mov    %ebx,%edx
  800670:	89 f0                	mov    %esi,%eax
  800672:	e8 71 fb ff ff       	call   8001e8 <printnum>
			break;
  800677:	83 c4 20             	add    $0x20,%esp
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067d:	e9 aa fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	51                   	push   %ecx
  800687:	ff d6                	call   *%esi
			break;
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068f:	e9 98 fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 25                	push   $0x25
  80069a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb 03                	jmp    8006a4 <vprintfmt+0x39e>
  8006a1:	83 ef 01             	sub    $0x1,%edi
  8006a4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a8:	75 f7                	jne    8006a1 <vprintfmt+0x39b>
  8006aa:	e9 7d fc ff ff       	jmp    80032c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b2:	5b                   	pop    %ebx
  8006b3:	5e                   	pop    %esi
  8006b4:	5f                   	pop    %edi
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 18             	sub    $0x18,%esp
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 26                	je     8006fe <vsnprintf+0x47>
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	7e 22                	jle    8006fe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dc:	ff 75 14             	pushl  0x14(%ebp)
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e5:	50                   	push   %eax
  8006e6:	68 cc 02 80 00       	push   $0x8002cc
  8006eb:	e8 16 fc ff ff       	call   800306 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	50                   	push   %eax
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 9a ff ff ff       	call   8006b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800725:	b8 00 00 00 00       	mov    $0x0,%eax
  80072a:	eb 03                	jmp    80072f <strlen+0x10>
		n++;
  80072c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800733:	75 f7                	jne    80072c <strlen+0xd>
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800740:	ba 00 00 00 00       	mov    $0x0,%edx
  800745:	eb 03                	jmp    80074a <strnlen+0x13>
		n++;
  800747:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074a:	39 c2                	cmp    %eax,%edx
  80074c:	74 08                	je     800756 <strnlen+0x1f>
  80074e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800752:	75 f3                	jne    800747 <strnlen+0x10>
  800754:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800762:	89 c2                	mov    %eax,%edx
  800764:	83 c2 01             	add    $0x1,%edx
  800767:	83 c1 01             	add    $0x1,%ecx
  80076a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800771:	84 db                	test   %bl,%bl
  800773:	75 ef                	jne    800764 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077f:	53                   	push   %ebx
  800780:	e8 9a ff ff ff       	call   80071f <strlen>
  800785:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	01 d8                	add    %ebx,%eax
  80078d:	50                   	push   %eax
  80078e:	e8 c5 ff ff ff       	call   800758 <strcpy>
	return dst;
}
  800793:	89 d8                	mov    %ebx,%eax
  800795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a5:	89 f3                	mov    %esi,%ebx
  8007a7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	89 f2                	mov    %esi,%edx
  8007ac:	eb 0f                	jmp    8007bd <strncpy+0x23>
		*dst++ = *src;
  8007ae:	83 c2 01             	add    $0x1,%edx
  8007b1:	0f b6 01             	movzbl (%ecx),%eax
  8007b4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ba:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	39 da                	cmp    %ebx,%edx
  8007bf:	75 ed                	jne    8007ae <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 21                	je     8007fc <strlcpy+0x35>
  8007db:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007df:	89 f2                	mov    %esi,%edx
  8007e1:	eb 09                	jmp    8007ec <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c1 01             	add    $0x1,%ecx
  8007e9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ec:	39 c2                	cmp    %eax,%edx
  8007ee:	74 09                	je     8007f9 <strlcpy+0x32>
  8007f0:	0f b6 19             	movzbl (%ecx),%ebx
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	75 ec                	jne    8007e3 <strlcpy+0x1c>
  8007f7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fc:	29 f0                	sub    %esi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080b:	eb 06                	jmp    800813 <strcmp+0x11>
		p++, q++;
  80080d:	83 c1 01             	add    $0x1,%ecx
  800810:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800813:	0f b6 01             	movzbl (%ecx),%eax
  800816:	84 c0                	test   %al,%al
  800818:	74 04                	je     80081e <strcmp+0x1c>
  80081a:	3a 02                	cmp    (%edx),%al
  80081c:	74 ef                	je     80080d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081e:	0f b6 c0             	movzbl %al,%eax
  800821:	0f b6 12             	movzbl (%edx),%edx
  800824:	29 d0                	sub    %edx,%eax
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	89 c3                	mov    %eax,%ebx
  800834:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800837:	eb 06                	jmp    80083f <strncmp+0x17>
		n--, p++, q++;
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083f:	39 d8                	cmp    %ebx,%eax
  800841:	74 15                	je     800858 <strncmp+0x30>
  800843:	0f b6 08             	movzbl (%eax),%ecx
  800846:	84 c9                	test   %cl,%cl
  800848:	74 04                	je     80084e <strncmp+0x26>
  80084a:	3a 0a                	cmp    (%edx),%cl
  80084c:	74 eb                	je     800839 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 00             	movzbl (%eax),%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
  800856:	eb 05                	jmp    80085d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085d:	5b                   	pop    %ebx
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 07                	jmp    800873 <strchr+0x13>
		if (*s == c)
  80086c:	38 ca                	cmp    %cl,%dl
  80086e:	74 0f                	je     80087f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	0f b6 10             	movzbl (%eax),%edx
  800876:	84 d2                	test   %dl,%dl
  800878:	75 f2                	jne    80086c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 03                	jmp    800890 <strfind+0xf>
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800893:	84 d2                	test   %dl,%dl
  800895:	74 04                	je     80089b <strfind+0x1a>
  800897:	38 ca                	cmp    %cl,%dl
  800899:	75 f2                	jne    80088d <strfind+0xc>
			break;
	return (char *) s;
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 36                	je     8008e3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 28                	jne    8008dd <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 23                	jne    8008dd <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008be:	89 d3                	mov    %edx,%ebx
  8008c0:	c1 e3 08             	shl    $0x8,%ebx
  8008c3:	89 d6                	mov    %edx,%esi
  8008c5:	c1 e6 18             	shl    $0x18,%esi
  8008c8:	89 d0                	mov    %edx,%eax
  8008ca:	c1 e0 10             	shl    $0x10,%eax
  8008cd:	09 f0                	or     %esi,%eax
  8008cf:	09 c2                	or     %eax,%edx
  8008d1:	89 d0                	mov    %edx,%eax
  8008d3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d8:	fc                   	cld    
  8008d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008db:	eb 06                	jmp    8008e3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	fc                   	cld    
  8008e1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e3:	89 f8                	mov    %edi,%eax
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f8:	39 c6                	cmp    %eax,%esi
  8008fa:	73 35                	jae    800931 <memmove+0x47>
  8008fc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ff:	39 d0                	cmp    %edx,%eax
  800901:	73 2e                	jae    800931 <memmove+0x47>
		s += n;
		d += n;
  800903:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800906:	89 d6                	mov    %edx,%esi
  800908:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800910:	75 13                	jne    800925 <memmove+0x3b>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0e                	jne    800925 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800917:	83 ef 04             	sub    $0x4,%edi
  80091a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800920:	fd                   	std    
  800921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800923:	eb 09                	jmp    80092e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800925:	83 ef 01             	sub    $0x1,%edi
  800928:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092b:	fd                   	std    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092e:	fc                   	cld    
  80092f:	eb 1d                	jmp    80094e <memmove+0x64>
  800931:	89 f2                	mov    %esi,%edx
  800933:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	f6 c2 03             	test   $0x3,%dl
  800938:	75 0f                	jne    800949 <memmove+0x5f>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0a                	jne    800949 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800947:	eb 05                	jmp    80094e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800955:	ff 75 10             	pushl  0x10(%ebp)
  800958:	ff 75 0c             	pushl  0xc(%ebp)
  80095b:	ff 75 08             	pushl  0x8(%ebp)
  80095e:	e8 87 ff ff ff       	call   8008ea <memmove>
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	89 c6                	mov    %eax,%esi
  800972:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800975:	eb 1a                	jmp    800991 <memcmp+0x2c>
		if (*s1 != *s2)
  800977:	0f b6 08             	movzbl (%eax),%ecx
  80097a:	0f b6 1a             	movzbl (%edx),%ebx
  80097d:	38 d9                	cmp    %bl,%cl
  80097f:	74 0a                	je     80098b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800981:	0f b6 c1             	movzbl %cl,%eax
  800984:	0f b6 db             	movzbl %bl,%ebx
  800987:	29 d8                	sub    %ebx,%eax
  800989:	eb 0f                	jmp    80099a <memcmp+0x35>
		s1++, s2++;
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800991:	39 f0                	cmp    %esi,%eax
  800993:	75 e2                	jne    800977 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ac:	eb 07                	jmp    8009b5 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	38 08                	cmp    %cl,(%eax)
  8009b0:	74 07                	je     8009b9 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	39 d0                	cmp    %edx,%eax
  8009b7:	72 f5                	jb     8009ae <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c7:	eb 03                	jmp    8009cc <strtol+0x11>
		s++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cc:	0f b6 01             	movzbl (%ecx),%eax
  8009cf:	3c 09                	cmp    $0x9,%al
  8009d1:	74 f6                	je     8009c9 <strtol+0xe>
  8009d3:	3c 20                	cmp    $0x20,%al
  8009d5:	74 f2                	je     8009c9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d7:	3c 2b                	cmp    $0x2b,%al
  8009d9:	75 0a                	jne    8009e5 <strtol+0x2a>
		s++;
  8009db:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009de:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e3:	eb 10                	jmp    8009f5 <strtol+0x3a>
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ea:	3c 2d                	cmp    $0x2d,%al
  8009ec:	75 07                	jne    8009f5 <strtol+0x3a>
		s++, neg = 1;
  8009ee:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009f1:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	0f 94 c0             	sete   %al
  8009fa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a00:	75 19                	jne    800a1b <strtol+0x60>
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	75 14                	jne    800a1b <strtol+0x60>
  800a07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0b:	0f 85 8a 00 00 00    	jne    800a9b <strtol+0xe0>
		s += 2, base = 16;
  800a11:	83 c1 02             	add    $0x2,%ecx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 16                	jmp    800a31 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a1b:	84 c0                	test   %al,%al
  800a1d:	74 12                	je     800a31 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	75 08                	jne    800a31 <strtol+0x76>
		s++, base = 8;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a39:	0f b6 11             	movzbl (%ecx),%edx
  800a3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 09             	cmp    $0x9,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x93>
			dig = *s - '0';
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 30             	sub    $0x30,%edx
  800a4c:	eb 22                	jmp    800a70 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a51:	89 f3                	mov    %esi,%ebx
  800a53:	80 fb 19             	cmp    $0x19,%bl
  800a56:	77 08                	ja     800a60 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a58:	0f be d2             	movsbl %dl,%edx
  800a5b:	83 ea 57             	sub    $0x57,%edx
  800a5e:	eb 10                	jmp    800a70 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a63:	89 f3                	mov    %esi,%ebx
  800a65:	80 fb 19             	cmp    $0x19,%bl
  800a68:	77 16                	ja     800a80 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a6a:	0f be d2             	movsbl %dl,%edx
  800a6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a73:	7d 0f                	jge    800a84 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7e:	eb b9                	jmp    800a39 <strtol+0x7e>
  800a80:	89 c2                	mov    %eax,%edx
  800a82:	eb 02                	jmp    800a86 <strtol+0xcb>
  800a84:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8a:	74 05                	je     800a91 <strtol+0xd6>
		*endptr = (char *) s;
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a91:	85 ff                	test   %edi,%edi
  800a93:	74 0c                	je     800aa1 <strtol+0xe6>
  800a95:	89 d0                	mov    %edx,%eax
  800a97:	f7 d8                	neg    %eax
  800a99:	eb 06                	jmp    800aa1 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9b:	84 c0                	test   %al,%al
  800a9d:	75 8a                	jne    800a29 <strtol+0x6e>
  800a9f:	eb 90                	jmp    800a31 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 c3                	mov    %eax,%ebx
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad4:	89 d1                	mov    %edx,%ecx
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 d7                	mov    %edx,%edi
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af1:	b8 03 00 00 00       	mov    $0x3,%eax
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	89 cb                	mov    %ecx,%ebx
  800afb:	89 cf                	mov    %ecx,%edi
  800afd:	89 ce                	mov    %ecx,%esi
  800aff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 03                	push   $0x3
  800b0b:	68 5f 25 80 00       	push   $0x80255f
  800b10:	6a 23                	push   $0x23
  800b12:	68 7c 25 80 00       	push   $0x80257c
  800b17:	e8 1e 12 00 00       	call   801d3a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_yield>:

void
sys_yield(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	be 00 00 00 00       	mov    $0x0,%esi
  800b70:	b8 04 00 00 00       	mov    $0x4,%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7e:	89 f7                	mov    %esi,%edi
  800b80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 04                	push   $0x4
  800b8c:	68 5f 25 80 00       	push   $0x80255f
  800b91:	6a 23                	push   $0x23
  800b93:	68 7c 25 80 00       	push   $0x80257c
  800b98:	e8 9d 11 00 00       	call   801d3a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 05                	push   $0x5
  800bce:	68 5f 25 80 00       	push   $0x80255f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 7c 25 80 00       	push   $0x80257c
  800bda:	e8 5b 11 00 00       	call   801d3a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 df                	mov    %ebx,%edi
  800c02:	89 de                	mov    %ebx,%esi
  800c04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 06                	push   $0x6
  800c10:	68 5f 25 80 00       	push   $0x80255f
  800c15:	6a 23                	push   $0x23
  800c17:	68 7c 25 80 00       	push   $0x80257c
  800c1c:	e8 19 11 00 00       	call   801d3a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 08                	push   $0x8
  800c52:	68 5f 25 80 00       	push   $0x80255f
  800c57:	6a 23                	push   $0x23
  800c59:	68 7c 25 80 00       	push   $0x80257c
  800c5e:	e8 d7 10 00 00       	call   801d3a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 09                	push   $0x9
  800c94:	68 5f 25 80 00       	push   $0x80255f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 7c 25 80 00       	push   $0x80257c
  800ca0:	e8 95 10 00 00       	call   801d3a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 0a                	push   $0xa
  800cd6:	68 5f 25 80 00       	push   $0x80255f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 7c 25 80 00       	push   $0x80257c
  800ce2:	e8 53 10 00 00       	call   801d3a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	be 00 00 00 00       	mov    $0x0,%esi
  800cfa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d20:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 cb                	mov    %ecx,%ebx
  800d2a:	89 cf                	mov    %ecx,%edi
  800d2c:	89 ce                	mov    %ecx,%esi
  800d2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 0d                	push   $0xd
  800d3a:	68 5f 25 80 00       	push   $0x80255f
  800d3f:	6a 23                	push   $0x23
  800d41:	68 7c 25 80 00       	push   $0x80257c
  800d46:	e8 ef 0f 00 00       	call   801d3a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_gettime>:

int sys_gettime(void)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d63:	89 d1                	mov    %edx,%ecx
  800d65:	89 d3                	mov    %edx,%ebx
  800d67:	89 d7                	mov    %edx,%edi
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800d7c:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d7e:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d82:	74 2e                	je     800db2 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	c1 ea 16             	shr    $0x16,%edx
  800d89:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800d90:	f6 c2 01             	test   $0x1,%dl
  800d93:	74 1d                	je     800db2 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	c1 ea 0c             	shr    $0xc,%edx
  800d9a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800da1:	f6 c1 01             	test   $0x1,%cl
  800da4:	74 0c                	je     800db2 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800da6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800dad:	f6 c6 08             	test   $0x8,%dh
  800db0:	75 14                	jne    800dc6 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	68 8a 25 80 00       	push   $0x80258a
  800dba:	6a 28                	push   $0x28
  800dbc:	68 9c 25 80 00       	push   $0x80259c
  800dc1:	e8 74 0f 00 00       	call   801d3a <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800dc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcb:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	6a 07                	push   $0x7
  800dd2:	68 00 f0 7f 00       	push   $0x7ff000
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 84 fd ff ff       	call   800b62 <sys_page_alloc>
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	79 14                	jns    800df9 <pgfault+0x87>
		panic("sys_page_alloc");
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 a7 25 80 00       	push   $0x8025a7
  800ded:	6a 2c                	push   $0x2c
  800def:	68 9c 25 80 00       	push   $0x80259c
  800df4:	e8 41 0f 00 00       	call   801d3a <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	68 00 10 00 00       	push   $0x1000
  800e01:	53                   	push   %ebx
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	e8 46 fb ff ff       	call   800952 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e0c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e13:	53                   	push   %ebx
  800e14:	6a 00                	push   $0x0
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 83 fd ff ff       	call   800ba5 <sys_page_map>
  800e22:	83 c4 20             	add    $0x20,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 14                	jns    800e3d <pgfault+0xcb>
		panic("sys_page_map");
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 b6 25 80 00       	push   $0x8025b6
  800e31:	6a 2f                	push   $0x2f
  800e33:	68 9c 25 80 00       	push   $0x80259c
  800e38:	e8 fd 0e 00 00       	call   801d3a <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	6a 00                	push   $0x0
  800e47:	e8 9b fd ff ff       	call   800be7 <sys_page_unmap>
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 14                	jns    800e67 <pgfault+0xf5>
		panic("sys_page_unmap");
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	68 c3 25 80 00       	push   $0x8025c3
  800e5b:	6a 31                	push   $0x31
  800e5d:	68 9c 25 80 00       	push   $0x80259c
  800e62:	e8 d3 0e 00 00       	call   801d3a <_panic>
	return;
}
  800e67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800e75:	68 72 0d 80 00       	push   $0x800d72
  800e7a:	e8 01 0f 00 00       	call   801d80 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e7f:	b8 07 00 00 00       	mov    $0x7,%eax
  800e84:	cd 30                	int    $0x30
  800e86:	89 c7                	mov    %eax,%edi
  800e88:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	75 21                	jne    800eb3 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e92:	e8 8d fc ff ff       	call   800b24 <sys_getenvid>
  800e97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e9c:	6b c0 78             	imul   $0x78,%eax,%eax
  800e9f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	e9 80 01 00 00       	jmp    801033 <fork+0x1c7>
	}
	if (envid < 0)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800eb7:	50                   	push   %eax
  800eb8:	68 d2 25 80 00       	push   $0x8025d2
  800ebd:	6a 70                	push   $0x70
  800ebf:	68 9c 25 80 00       	push   $0x80259c
  800ec4:	e8 71 0e 00 00       	call   801d3a <_panic>
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800ece:	89 d8                	mov    %ebx,%eax
  800ed0:	c1 e8 16             	shr    $0x16,%eax
  800ed3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eda:	a8 01                	test   $0x1,%al
  800edc:	0f 84 de 00 00 00    	je     800fc0 <fork+0x154>
  800ee2:	89 de                	mov    %ebx,%esi
  800ee4:	c1 ee 0c             	shr    $0xc,%esi
  800ee7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eee:	a8 01                	test   $0x1,%al
  800ef0:	0f 84 ca 00 00 00    	je     800fc0 <fork+0x154>
  800ef6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800efd:	a8 04                	test   $0x4,%al
  800eff:	0f 84 bb 00 00 00    	je     800fc0 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800f05:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800f0c:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800f0f:	f6 c4 04             	test   $0x4,%ah
  800f12:	74 34                	je     800f48 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	25 07 0e 00 00       	and    $0xe07,%eax
  800f1c:	50                   	push   %eax
  800f1d:	56                   	push   %esi
  800f1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f21:	56                   	push   %esi
  800f22:	6a 00                	push   $0x0
  800f24:	e8 7c fc ff ff       	call   800ba5 <sys_page_map>
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	0f 84 8c 00 00 00    	je     800fc0 <fork+0x154>
        	panic("duppage share");
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	68 e2 25 80 00       	push   $0x8025e2
  800f3c:	6a 48                	push   $0x48
  800f3e:	68 9c 25 80 00       	push   $0x80259c
  800f43:	e8 f2 0d 00 00       	call   801d3a <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f48:	a9 02 08 00 00       	test   $0x802,%eax
  800f4d:	74 5d                	je     800fac <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	68 05 08 00 00       	push   $0x805
  800f57:	56                   	push   %esi
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	56                   	push   %esi
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 42 fc ff ff       	call   800ba5 <sys_page_map>
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 14                	jns    800f7e <fork+0x112>
			panic("error");
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	68 4d 22 80 00       	push   $0x80224d
  800f72:	6a 4b                	push   $0x4b
  800f74:	68 9c 25 80 00       	push   $0x80259c
  800f79:	e8 bc 0d 00 00       	call   801d3a <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	68 05 08 00 00       	push   $0x805
  800f86:	56                   	push   %esi
  800f87:	6a 00                	push   $0x0
  800f89:	56                   	push   %esi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 14 fc ff ff       	call   800ba5 <sys_page_map>
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 28                	jns    800fc0 <fork+0x154>
			panic("error");
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	68 4d 22 80 00       	push   $0x80224d
  800fa0:	6a 4d                	push   $0x4d
  800fa2:	68 9c 25 80 00       	push   $0x80259c
  800fa7:	e8 8e 0d 00 00       	call   801d3a <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	6a 05                	push   $0x5
  800fb1:	56                   	push   %esi
  800fb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb5:	56                   	push   %esi
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 e8 fb ff ff       	call   800ba5 <sys_page_map>
  800fbd:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fc0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc6:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  800fcc:	0f 85 fc fe ff ff    	jne    800ece <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	6a 07                	push   $0x7
  800fd7:	68 00 f0 7f ee       	push   $0xee7ff000
  800fdc:	57                   	push   %edi
  800fdd:	e8 80 fb ff ff       	call   800b62 <sys_page_alloc>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	79 14                	jns    800ffd <fork+0x191>
		panic("1");
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	68 f0 25 80 00       	push   $0x8025f0
  800ff1:	6a 78                	push   $0x78
  800ff3:	68 9c 25 80 00       	push   $0x80259c
  800ff8:	e8 3d 0d 00 00       	call   801d3a <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	68 ef 1d 80 00       	push   $0x801def
  801005:	57                   	push   %edi
  801006:	e8 a2 fc ff ff       	call   800cad <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	6a 02                	push   $0x2
  801010:	57                   	push   %edi
  801011:	e8 13 fc ff ff       	call   800c29 <sys_env_set_status>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 14                	jns    801031 <fork+0x1c5>
		panic("sys_env_set_status");
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	68 f2 25 80 00       	push   $0x8025f2
  801025:	6a 7d                	push   $0x7d
  801027:	68 9c 25 80 00       	push   $0x80259c
  80102c:	e8 09 0d 00 00       	call   801d3a <_panic>

	return envid;
  801031:	89 f8                	mov    %edi,%eax
}
  801033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sfork>:

// Challenge!
int
sfork(void)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801041:	68 05 26 80 00       	push   $0x802605
  801046:	68 86 00 00 00       	push   $0x86
  80104b:	68 9c 25 80 00       	push   $0x80259c
  801050:	e8 e5 0c 00 00       	call   801d3a <_panic>

00801055 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
  80105b:	05 00 00 00 30       	add    $0x30000000,%eax
  801060:	c1 e8 0c             	shr    $0xc,%eax
}
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801070:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801075:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801087:	89 c2                	mov    %eax,%edx
  801089:	c1 ea 16             	shr    $0x16,%edx
  80108c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801093:	f6 c2 01             	test   $0x1,%dl
  801096:	74 11                	je     8010a9 <fd_alloc+0x2d>
  801098:	89 c2                	mov    %eax,%edx
  80109a:	c1 ea 0c             	shr    $0xc,%edx
  80109d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a4:	f6 c2 01             	test   $0x1,%dl
  8010a7:	75 09                	jne    8010b2 <fd_alloc+0x36>
			*fd_store = fd;
  8010a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b0:	eb 17                	jmp    8010c9 <fd_alloc+0x4d>
  8010b2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010bc:	75 c9                	jne    801087 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010be:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d1:	83 f8 1f             	cmp    $0x1f,%eax
  8010d4:	77 36                	ja     80110c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d6:	c1 e0 0c             	shl    $0xc,%eax
  8010d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 16             	shr    $0x16,%edx
  8010e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 24                	je     801113 <fd_lookup+0x48>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	c1 ea 0c             	shr    $0xc,%edx
  8010f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fb:	f6 c2 01             	test   $0x1,%dl
  8010fe:	74 1a                	je     80111a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801100:	8b 55 0c             	mov    0xc(%ebp),%edx
  801103:	89 02                	mov    %eax,(%edx)
	return 0;
  801105:	b8 00 00 00 00       	mov    $0x0,%eax
  80110a:	eb 13                	jmp    80111f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801111:	eb 0c                	jmp    80111f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801118:	eb 05                	jmp    80111f <fd_lookup+0x54>
  80111a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112a:	ba 98 26 80 00       	mov    $0x802698,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112f:	eb 13                	jmp    801144 <dev_lookup+0x23>
  801131:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801134:	39 08                	cmp    %ecx,(%eax)
  801136:	75 0c                	jne    801144 <dev_lookup+0x23>
			*dev = devtab[i];
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
  801142:	eb 2e                	jmp    801172 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801144:	8b 02                	mov    (%edx),%eax
  801146:	85 c0                	test   %eax,%eax
  801148:	75 e7                	jne    801131 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114a:	a1 04 40 80 00       	mov    0x804004,%eax
  80114f:	8b 40 48             	mov    0x48(%eax),%eax
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	51                   	push   %ecx
  801156:	50                   	push   %eax
  801157:	68 1c 26 80 00       	push   $0x80261c
  80115c:	e8 73 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801161:	8b 45 0c             	mov    0xc(%ebp),%eax
  801164:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 10             	sub    $0x10,%esp
  80117c:	8b 75 08             	mov    0x8(%ebp),%esi
  80117f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801185:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801186:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80118c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118f:	50                   	push   %eax
  801190:	e8 36 ff ff ff       	call   8010cb <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 05                	js     8011a1 <fd_close+0x2d>
	    || fd != fd2)
  80119c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119f:	74 0b                	je     8011ac <fd_close+0x38>
		return (must_exist ? r : 0);
  8011a1:	80 fb 01             	cmp    $0x1,%bl
  8011a4:	19 d2                	sbb    %edx,%edx
  8011a6:	f7 d2                	not    %edx
  8011a8:	21 d0                	and    %edx,%eax
  8011aa:	eb 41                	jmp    8011ed <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 36                	pushl  (%esi)
  8011b5:	e8 67 ff ff ff       	call   801121 <dev_lookup>
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 1a                	js     8011dd <fd_close+0x69>
		if (dev->dev_close)
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0b                	je     8011dd <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	56                   	push   %esi
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 ff f9 ff ff       	call   800be7 <sys_page_unmap>
	return r;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	89 d8                	mov    %ebx,%eax
}
  8011ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 08             	pushl  0x8(%ebp)
  801201:	e8 c5 fe ff ff       	call   8010cb <fd_lookup>
  801206:	89 c2                	mov    %eax,%edx
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	85 d2                	test   %edx,%edx
  80120d:	78 10                	js     80121f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	6a 01                	push   $0x1
  801214:	ff 75 f4             	pushl  -0xc(%ebp)
  801217:	e8 58 ff ff ff       	call   801174 <fd_close>
  80121c:	83 c4 10             	add    $0x10,%esp
}
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <close_all>:

void
close_all(void)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	53                   	push   %ebx
  801231:	e8 be ff ff ff       	call   8011f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801236:	83 c3 01             	add    $0x1,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	83 fb 20             	cmp    $0x20,%ebx
  80123f:	75 ec                	jne    80122d <close_all+0xc>
		close(i);
}
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	57                   	push   %edi
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	83 ec 2c             	sub    $0x2c,%esp
  80124f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801252:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	ff 75 08             	pushl  0x8(%ebp)
  801259:	e8 6d fe ff ff       	call   8010cb <fd_lookup>
  80125e:	89 c2                	mov    %eax,%edx
  801260:	83 c4 08             	add    $0x8,%esp
  801263:	85 d2                	test   %edx,%edx
  801265:	0f 88 c1 00 00 00    	js     80132c <dup+0xe6>
		return r;
	close(newfdnum);
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	56                   	push   %esi
  80126f:	e8 80 ff ff ff       	call   8011f4 <close>

	newfd = INDEX2FD(newfdnum);
  801274:	89 f3                	mov    %esi,%ebx
  801276:	c1 e3 0c             	shl    $0xc,%ebx
  801279:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80127f:	83 c4 04             	add    $0x4,%esp
  801282:	ff 75 e4             	pushl  -0x1c(%ebp)
  801285:	e8 db fd ff ff       	call   801065 <fd2data>
  80128a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80128c:	89 1c 24             	mov    %ebx,(%esp)
  80128f:	e8 d1 fd ff ff       	call   801065 <fd2data>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129a:	89 f8                	mov    %edi,%eax
  80129c:	c1 e8 16             	shr    $0x16,%eax
  80129f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a6:	a8 01                	test   $0x1,%al
  8012a8:	74 37                	je     8012e1 <dup+0x9b>
  8012aa:	89 f8                	mov    %edi,%eax
  8012ac:	c1 e8 0c             	shr    $0xc,%eax
  8012af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 26                	je     8012e1 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ca:	50                   	push   %eax
  8012cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ce:	6a 00                	push   $0x0
  8012d0:	57                   	push   %edi
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 cd f8 ff ff       	call   800ba5 <sys_page_map>
  8012d8:	89 c7                	mov    %eax,%edi
  8012da:	83 c4 20             	add    $0x20,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 2e                	js     80130f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e4:	89 d0                	mov    %edx,%eax
  8012e6:	c1 e8 0c             	shr    $0xc,%eax
  8012e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f8:	50                   	push   %eax
  8012f9:	53                   	push   %ebx
  8012fa:	6a 00                	push   $0x0
  8012fc:	52                   	push   %edx
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 a1 f8 ff ff       	call   800ba5 <sys_page_map>
  801304:	89 c7                	mov    %eax,%edi
  801306:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801309:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130b:	85 ff                	test   %edi,%edi
  80130d:	79 1d                	jns    80132c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	53                   	push   %ebx
  801313:	6a 00                	push   $0x0
  801315:	e8 cd f8 ff ff       	call   800be7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801320:	6a 00                	push   $0x0
  801322:	e8 c0 f8 ff ff       	call   800be7 <sys_page_unmap>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 f8                	mov    %edi,%eax
}
  80132c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 14             	sub    $0x14,%esp
  80133b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	53                   	push   %ebx
  801343:	e8 83 fd ff ff       	call   8010cb <fd_lookup>
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	89 c2                	mov    %eax,%edx
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 6d                	js     8013be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	ff 30                	pushl  (%eax)
  80135d:	e8 bf fd ff ff       	call   801121 <dev_lookup>
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 4c                	js     8013b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801369:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136c:	8b 42 08             	mov    0x8(%edx),%eax
  80136f:	83 e0 03             	and    $0x3,%eax
  801372:	83 f8 01             	cmp    $0x1,%eax
  801375:	75 21                	jne    801398 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801377:	a1 04 40 80 00       	mov    0x804004,%eax
  80137c:	8b 40 48             	mov    0x48(%eax),%eax
  80137f:	83 ec 04             	sub    $0x4,%esp
  801382:	53                   	push   %ebx
  801383:	50                   	push   %eax
  801384:	68 5d 26 80 00       	push   $0x80265d
  801389:	e8 46 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801396:	eb 26                	jmp    8013be <read+0x8a>
	}
	if (!dev->dev_read)
  801398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139b:	8b 40 08             	mov    0x8(%eax),%eax
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	74 17                	je     8013b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	ff 75 10             	pushl  0x10(%ebp)
  8013a8:	ff 75 0c             	pushl  0xc(%ebp)
  8013ab:	52                   	push   %edx
  8013ac:	ff d0                	call   *%eax
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb 09                	jmp    8013be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	eb 05                	jmp    8013be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d9:	eb 21                	jmp    8013fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	29 d8                	sub    %ebx,%eax
  8013e2:	50                   	push   %eax
  8013e3:	89 d8                	mov    %ebx,%eax
  8013e5:	03 45 0c             	add    0xc(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	57                   	push   %edi
  8013ea:	e8 45 ff ff ff       	call   801334 <read>
		if (m < 0)
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 0c                	js     801402 <readn+0x3d>
			return m;
		if (m == 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	74 06                	je     801400 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fa:	01 c3                	add    %eax,%ebx
  8013fc:	39 f3                	cmp    %esi,%ebx
  8013fe:	72 db                	jb     8013db <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801400:	89 d8                	mov    %ebx,%eax
}
  801402:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 14             	sub    $0x14,%esp
  801411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	53                   	push   %ebx
  801419:	e8 ad fc ff ff       	call   8010cb <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	89 c2                	mov    %eax,%edx
  801423:	85 c0                	test   %eax,%eax
  801425:	78 68                	js     80148f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	ff 30                	pushl  (%eax)
  801433:	e8 e9 fc ff ff       	call   801121 <dev_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 47                	js     801486 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801442:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801446:	75 21                	jne    801469 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801448:	a1 04 40 80 00       	mov    0x804004,%eax
  80144d:	8b 40 48             	mov    0x48(%eax),%eax
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	53                   	push   %ebx
  801454:	50                   	push   %eax
  801455:	68 79 26 80 00       	push   $0x802679
  80145a:	e8 75 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801467:	eb 26                	jmp    80148f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801469:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146c:	8b 52 0c             	mov    0xc(%edx),%edx
  80146f:	85 d2                	test   %edx,%edx
  801471:	74 17                	je     80148a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	ff 75 10             	pushl  0x10(%ebp)
  801479:	ff 75 0c             	pushl  0xc(%ebp)
  80147c:	50                   	push   %eax
  80147d:	ff d2                	call   *%edx
  80147f:	89 c2                	mov    %eax,%edx
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	eb 09                	jmp    80148f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801486:	89 c2                	mov    %eax,%edx
  801488:	eb 05                	jmp    80148f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148f:	89 d0                	mov    %edx,%eax
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <seek>:

int
seek(int fdnum, off_t offset)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	ff 75 08             	pushl  0x8(%ebp)
  8014a3:	e8 23 fc ff ff       	call   8010cb <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 0e                	js     8014bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 f8 fb ff ff       	call   8010cb <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 65                	js     801541 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	ff 30                	pushl  (%eax)
  8014e8:	e8 34 fc ff ff       	call   801121 <dev_lookup>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 44                	js     801538 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fb:	75 21                	jne    80151e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801502:	8b 40 48             	mov    0x48(%eax),%eax
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	53                   	push   %ebx
  801509:	50                   	push   %eax
  80150a:	68 3c 26 80 00       	push   $0x80263c
  80150f:	e8 c0 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151c:	eb 23                	jmp    801541 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 18             	mov    0x18(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 14                	je     80153c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	50                   	push   %eax
  80152f:	ff d2                	call   *%edx
  801531:	89 c2                	mov    %eax,%edx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb 09                	jmp    801541 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801538:	89 c2                	mov    %eax,%edx
  80153a:	eb 05                	jmp    801541 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80153c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	ff 75 08             	pushl  0x8(%ebp)
  801559:	e8 6d fb ff ff       	call   8010cb <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	89 c2                	mov    %eax,%edx
  801563:	85 c0                	test   %eax,%eax
  801565:	78 58                	js     8015bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	ff 30                	pushl  (%eax)
  801573:	e8 a9 fb ff ff       	call   801121 <dev_lookup>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 37                	js     8015b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801582:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801586:	74 32                	je     8015ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801588:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80158b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801592:	00 00 00 
	stat->st_isdir = 0;
  801595:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80159c:	00 00 00 
	stat->st_dev = dev;
  80159f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ac:	ff 50 14             	call   *0x14(%eax)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 09                	jmp    8015bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	eb 05                	jmp    8015bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 08             	pushl  0x8(%ebp)
  8015d3:	e8 e7 01 00 00       	call   8017bf <open>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 db                	test   %ebx,%ebx
  8015df:	78 1b                	js     8015fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	53                   	push   %ebx
  8015e8:	e8 5b ff ff ff       	call   801548 <fstat>
  8015ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 fd fb ff ff       	call   8011f4 <close>
	return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 f0                	mov    %esi,%eax
}
  8015fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
  801608:	89 c6                	mov    %eax,%esi
  80160a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80160c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801613:	75 12                	jne    801627 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	6a 03                	push   $0x3
  80161a:	e8 af 08 00 00       	call   801ece <ipc_find_env>
  80161f:	a3 00 40 80 00       	mov    %eax,0x804000
  801624:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801627:	6a 07                	push   $0x7
  801629:	68 00 50 80 00       	push   $0x805000
  80162e:	56                   	push   %esi
  80162f:	ff 35 00 40 80 00    	pushl  0x804000
  801635:	e8 43 08 00 00       	call   801e7d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163a:	83 c4 0c             	add    $0xc,%esp
  80163d:	6a 00                	push   $0x0
  80163f:	53                   	push   %ebx
  801640:	6a 00                	push   $0x0
  801642:	e8 d0 07 00 00       	call   801e17 <ipc_recv>
}
  801647:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801654:	8b 45 08             	mov    0x8(%ebp),%eax
  801657:	8b 40 0c             	mov    0xc(%eax),%eax
  80165a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801662:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 02 00 00 00       	mov    $0x2,%eax
  801671:	e8 8d ff ff ff       	call   801603 <fsipc>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	8b 40 0c             	mov    0xc(%eax),%eax
  801684:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 06 00 00 00       	mov    $0x6,%eax
  801693:	e8 6b ff ff ff       	call   801603 <fsipc>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b9:	e8 45 ff ff ff       	call   801603 <fsipc>
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	85 d2                	test   %edx,%edx
  8016c2:	78 2c                	js     8016f0 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	68 00 50 80 00       	push   $0x805000
  8016cc:	53                   	push   %ebx
  8016cd:	e8 86 f0 ff ff       	call   800758 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016dd:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8016fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801701:	8b 52 0c             	mov    0xc(%edx),%edx
  801704:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80170a:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80170f:	76 05                	jbe    801716 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801711:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801716:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	50                   	push   %eax
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	68 08 50 80 00       	push   $0x805008
  801727:	e8 be f1 ff ff       	call   8008ea <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 04 00 00 00       	mov    $0x4,%eax
  801736:	e8 c8 fe ff ff       	call   801603 <fsipc>
	return write;
}
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801750:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 03 00 00 00       	mov    $0x3,%eax
  801760:	e8 9e fe ff ff       	call   801603 <fsipc>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	85 c0                	test   %eax,%eax
  801769:	78 4b                	js     8017b6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80176b:	39 c6                	cmp    %eax,%esi
  80176d:	73 16                	jae    801785 <devfile_read+0x48>
  80176f:	68 a8 26 80 00       	push   $0x8026a8
  801774:	68 af 26 80 00       	push   $0x8026af
  801779:	6a 7c                	push   $0x7c
  80177b:	68 c4 26 80 00       	push   $0x8026c4
  801780:	e8 b5 05 00 00       	call   801d3a <_panic>
	assert(r <= PGSIZE);
  801785:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178a:	7e 16                	jle    8017a2 <devfile_read+0x65>
  80178c:	68 cf 26 80 00       	push   $0x8026cf
  801791:	68 af 26 80 00       	push   $0x8026af
  801796:	6a 7d                	push   $0x7d
  801798:	68 c4 26 80 00       	push   $0x8026c4
  80179d:	e8 98 05 00 00       	call   801d3a <_panic>
	memmove(buf, &fsipcbuf, r);
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	50                   	push   %eax
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	e8 37 f1 ff ff       	call   8008ea <memmove>
	return r;
  8017b3:	83 c4 10             	add    $0x10,%esp
}
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 20             	sub    $0x20,%esp
  8017c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c9:	53                   	push   %ebx
  8017ca:	e8 50 ef ff ff       	call   80071f <strlen>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d7:	7f 67                	jg     801840 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	e8 97 f8 ff ff       	call   80107c <fd_alloc>
  8017e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 57                	js     801845 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	53                   	push   %ebx
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	e8 5c ef ff ff       	call   800758 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801804:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801807:	b8 01 00 00 00       	mov    $0x1,%eax
  80180c:	e8 f2 fd ff ff       	call   801603 <fsipc>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	79 14                	jns    80182e <open+0x6f>
		fd_close(fd, 0);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	6a 00                	push   $0x0
  80181f:	ff 75 f4             	pushl  -0xc(%ebp)
  801822:	e8 4d f9 ff ff       	call   801174 <fd_close>
		return r;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	89 da                	mov    %ebx,%edx
  80182c:	eb 17                	jmp    801845 <open+0x86>
	}

	return fd2num(fd);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	ff 75 f4             	pushl  -0xc(%ebp)
  801834:	e8 1c f8 ff ff       	call   801055 <fd2num>
  801839:	89 c2                	mov    %eax,%edx
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	eb 05                	jmp    801845 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801840:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 08 00 00 00       	mov    $0x8,%eax
  80185c:	e8 a2 fd ff ff       	call   801603 <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80186b:	83 ec 0c             	sub    $0xc,%esp
  80186e:	ff 75 08             	pushl  0x8(%ebp)
  801871:	e8 ef f7 ff ff       	call   801065 <fd2data>
  801876:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801878:	83 c4 08             	add    $0x8,%esp
  80187b:	68 db 26 80 00       	push   $0x8026db
  801880:	53                   	push   %ebx
  801881:	e8 d2 ee ff ff       	call   800758 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801886:	8b 56 04             	mov    0x4(%esi),%edx
  801889:	89 d0                	mov    %edx,%eax
  80188b:	2b 06                	sub    (%esi),%eax
  80188d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801893:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189a:	00 00 00 
	stat->st_dev = &devpipe;
  80189d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a4:	30 80 00 
	return 0;
}
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018bd:	53                   	push   %ebx
  8018be:	6a 00                	push   $0x0
  8018c0:	e8 22 f3 ff ff       	call   800be7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c5:	89 1c 24             	mov    %ebx,(%esp)
  8018c8:	e8 98 f7 ff ff       	call   801065 <fd2data>
  8018cd:	83 c4 08             	add    $0x8,%esp
  8018d0:	50                   	push   %eax
  8018d1:	6a 00                	push   $0x0
  8018d3:	e8 0f f3 ff ff       	call   800be7 <sys_page_unmap>
}
  8018d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	57                   	push   %edi
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 1c             	sub    $0x1c,%esp
  8018e6:	89 c7                	mov    %eax,%edi
  8018e8:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	57                   	push   %edi
  8018f6:	e8 0b 06 00 00       	call   801f06 <pageref>
  8018fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018fe:	89 34 24             	mov    %esi,(%esp)
  801901:	e8 00 06 00 00       	call   801f06 <pageref>
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80190c:	0f 94 c0             	sete   %al
  80190f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801912:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801918:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80191b:	39 cb                	cmp    %ecx,%ebx
  80191d:	74 15                	je     801934 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  80191f:	8b 52 58             	mov    0x58(%edx),%edx
  801922:	50                   	push   %eax
  801923:	52                   	push   %edx
  801924:	53                   	push   %ebx
  801925:	68 e8 26 80 00       	push   $0x8026e8
  80192a:	e8 a5 e8 ff ff       	call   8001d4 <cprintf>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	eb b6                	jmp    8018ea <_pipeisclosed+0xd>
	}
}
  801934:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5f                   	pop    %edi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	57                   	push   %edi
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	83 ec 28             	sub    $0x28,%esp
  801945:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801948:	56                   	push   %esi
  801949:	e8 17 f7 ff ff       	call   801065 <fd2data>
  80194e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	bf 00 00 00 00       	mov    $0x0,%edi
  801958:	eb 4b                	jmp    8019a5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195a:	89 da                	mov    %ebx,%edx
  80195c:	89 f0                	mov    %esi,%eax
  80195e:	e8 7a ff ff ff       	call   8018dd <_pipeisclosed>
  801963:	85 c0                	test   %eax,%eax
  801965:	75 48                	jne    8019af <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801967:	e8 d7 f1 ff ff       	call   800b43 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196c:	8b 43 04             	mov    0x4(%ebx),%eax
  80196f:	8b 0b                	mov    (%ebx),%ecx
  801971:	8d 51 20             	lea    0x20(%ecx),%edx
  801974:	39 d0                	cmp    %edx,%eax
  801976:	73 e2                	jae    80195a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80197f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801982:	89 c2                	mov    %eax,%edx
  801984:	c1 fa 1f             	sar    $0x1f,%edx
  801987:	89 d1                	mov    %edx,%ecx
  801989:	c1 e9 1b             	shr    $0x1b,%ecx
  80198c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80198f:	83 e2 1f             	and    $0x1f,%edx
  801992:	29 ca                	sub    %ecx,%edx
  801994:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801998:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199c:	83 c0 01             	add    $0x1,%eax
  80199f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a2:	83 c7 01             	add    $0x1,%edi
  8019a5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019a8:	75 c2                	jne    80196c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ad:	eb 05                	jmp    8019b4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5f                   	pop    %edi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	57                   	push   %edi
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 18             	sub    $0x18,%esp
  8019c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019c8:	57                   	push   %edi
  8019c9:	e8 97 f6 ff ff       	call   801065 <fd2data>
  8019ce:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d8:	eb 3d                	jmp    801a17 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019da:	85 db                	test   %ebx,%ebx
  8019dc:	74 04                	je     8019e2 <devpipe_read+0x26>
				return i;
  8019de:	89 d8                	mov    %ebx,%eax
  8019e0:	eb 44                	jmp    801a26 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e2:	89 f2                	mov    %esi,%edx
  8019e4:	89 f8                	mov    %edi,%eax
  8019e6:	e8 f2 fe ff ff       	call   8018dd <_pipeisclosed>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	75 32                	jne    801a21 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ef:	e8 4f f1 ff ff       	call   800b43 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f4:	8b 06                	mov    (%esi),%eax
  8019f6:	3b 46 04             	cmp    0x4(%esi),%eax
  8019f9:	74 df                	je     8019da <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019fb:	99                   	cltd   
  8019fc:	c1 ea 1b             	shr    $0x1b,%edx
  8019ff:	01 d0                	add    %edx,%eax
  801a01:	83 e0 1f             	and    $0x1f,%eax
  801a04:	29 d0                	sub    %edx,%eax
  801a06:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a11:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a14:	83 c3 01             	add    $0x1,%ebx
  801a17:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1a:	75 d8                	jne    8019f4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1f:	eb 05                	jmp    801a26 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a21:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a39:	50                   	push   %eax
  801a3a:	e8 3d f6 ff ff       	call   80107c <fd_alloc>
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	85 c0                	test   %eax,%eax
  801a46:	0f 88 2c 01 00 00    	js     801b78 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4c:	83 ec 04             	sub    $0x4,%esp
  801a4f:	68 07 04 00 00       	push   $0x407
  801a54:	ff 75 f4             	pushl  -0xc(%ebp)
  801a57:	6a 00                	push   $0x0
  801a59:	e8 04 f1 ff ff       	call   800b62 <sys_page_alloc>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	89 c2                	mov    %eax,%edx
  801a63:	85 c0                	test   %eax,%eax
  801a65:	0f 88 0d 01 00 00    	js     801b78 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a71:	50                   	push   %eax
  801a72:	e8 05 f6 ff ff       	call   80107c <fd_alloc>
  801a77:	89 c3                	mov    %eax,%ebx
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	0f 88 e2 00 00 00    	js     801b66 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a84:	83 ec 04             	sub    $0x4,%esp
  801a87:	68 07 04 00 00       	push   $0x407
  801a8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 cc f0 ff ff       	call   800b62 <sys_page_alloc>
  801a96:	89 c3                	mov    %eax,%ebx
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	0f 88 c3 00 00 00    	js     801b66 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa9:	e8 b7 f5 ff ff       	call   801065 <fd2data>
  801aae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab0:	83 c4 0c             	add    $0xc,%esp
  801ab3:	68 07 04 00 00       	push   $0x407
  801ab8:	50                   	push   %eax
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 a2 f0 ff ff       	call   800b62 <sys_page_alloc>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	0f 88 89 00 00 00    	js     801b56 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad3:	e8 8d f5 ff ff       	call   801065 <fd2data>
  801ad8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801adf:	50                   	push   %eax
  801ae0:	6a 00                	push   $0x0
  801ae2:	56                   	push   %esi
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 bb f0 ff ff       	call   800ba5 <sys_page_map>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 20             	add    $0x20,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 55                	js     801b48 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b01:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b11:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	ff 75 f4             	pushl  -0xc(%ebp)
  801b23:	e8 2d f5 ff ff       	call   801055 <fd2num>
  801b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b2d:	83 c4 04             	add    $0x4,%esp
  801b30:	ff 75 f0             	pushl  -0x10(%ebp)
  801b33:	e8 1d f5 ff ff       	call   801055 <fd2num>
  801b38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	ba 00 00 00 00       	mov    $0x0,%edx
  801b46:	eb 30                	jmp    801b78 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	56                   	push   %esi
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 94 f0 ff ff       	call   800be7 <sys_page_unmap>
  801b53:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 84 f0 ff ff       	call   800be7 <sys_page_unmap>
  801b63:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 74 f0 ff ff       	call   800be7 <sys_page_unmap>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b78:	89 d0                	mov    %edx,%eax
  801b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8a:	50                   	push   %eax
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 38 f5 ff ff       	call   8010cb <fd_lookup>
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 d2                	test   %edx,%edx
  801b9a:	78 18                	js     801bb4 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 be f4 ff ff       	call   801065 <fd2data>
	return _pipeisclosed(fd, p);
  801ba7:	89 c2                	mov    %eax,%edx
  801ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bac:	e8 2c fd ff ff       	call   8018dd <_pipeisclosed>
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc6:	68 19 27 80 00       	push   $0x802719
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	e8 85 eb ff ff       	call   800758 <strcpy>
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801beb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	eb 2e                	jmp    801c21 <devcons_write+0x47>
		m = n - tot;
  801bf3:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf6:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801bf8:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801bfd:	83 fa 7f             	cmp    $0x7f,%edx
  801c00:	77 02                	ja     801c04 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c02:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	56                   	push   %esi
  801c08:	03 45 0c             	add    0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	57                   	push   %edi
  801c0d:	e8 d8 ec ff ff       	call   8008ea <memmove>
		sys_cputs(buf, m);
  801c12:	83 c4 08             	add    $0x8,%esp
  801c15:	56                   	push   %esi
  801c16:	57                   	push   %edi
  801c17:	e8 8a ee ff ff       	call   800aa6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1c:	01 f3                	add    %esi,%ebx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c26:	72 cb                	jb     801bf3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3f:	75 07                	jne    801c48 <devcons_read+0x18>
  801c41:	eb 28                	jmp    801c6b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c43:	e8 fb ee ff ff       	call   800b43 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c48:	e8 77 ee ff ff       	call   800ac4 <sys_cgetc>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 f2                	je     801c43 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 16                	js     801c6b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c55:	83 f8 04             	cmp    $0x4,%eax
  801c58:	74 0c                	je     801c66 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	88 02                	mov    %al,(%edx)
	return 1;
  801c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c64:	eb 05                	jmp    801c6b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c79:	6a 01                	push   $0x1
  801c7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 22 ee ff ff       	call   800aa6 <sys_cputs>
  801c84:	83 c4 10             	add    $0x10,%esp
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <getchar>:

int
getchar(void)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c8f:	6a 01                	push   $0x1
  801c91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 98 f6 ff ff       	call   801334 <read>
	if (r < 0)
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 0f                	js     801cb2 <getchar+0x29>
		return r;
	if (r < 1)
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	7e 06                	jle    801cad <getchar+0x24>
		return -E_EOF;
	return c;
  801ca7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cab:	eb 05                	jmp    801cb2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbd:	50                   	push   %eax
  801cbe:	ff 75 08             	pushl  0x8(%ebp)
  801cc1:	e8 05 f4 ff ff       	call   8010cb <fd_lookup>
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 11                	js     801cde <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd6:	39 10                	cmp    %edx,(%eax)
  801cd8:	0f 94 c0             	sete   %al
  801cdb:	0f b6 c0             	movzbl %al,%eax
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <opencons>:

int
opencons(void)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	e8 8d f3 ff ff       	call   80107c <fd_alloc>
  801cef:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 3e                	js     801d36 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	ff 75 f4             	pushl  -0xc(%ebp)
  801d03:	6a 00                	push   $0x0
  801d05:	e8 58 ee ff ff       	call   800b62 <sys_page_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 23                	js     801d36 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d13:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	50                   	push   %eax
  801d2c:	e8 24 f3 ff ff       	call   801055 <fd2num>
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	83 c4 10             	add    $0x10,%esp
}
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d3f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d42:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d48:	e8 d7 ed ff ff       	call   800b24 <sys_getenvid>
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff 75 0c             	pushl  0xc(%ebp)
  801d53:	ff 75 08             	pushl  0x8(%ebp)
  801d56:	56                   	push   %esi
  801d57:	50                   	push   %eax
  801d58:	68 28 27 80 00       	push   $0x802728
  801d5d:	e8 72 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d62:	83 c4 18             	add    $0x18,%esp
  801d65:	53                   	push   %ebx
  801d66:	ff 75 10             	pushl  0x10(%ebp)
  801d69:	e8 15 e4 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d6e:	c7 04 24 0f 22 80 00 	movl   $0x80220f,(%esp)
  801d75:	e8 5a e4 ff ff       	call   8001d4 <cprintf>
  801d7a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7d:	cc                   	int3   
  801d7e:	eb fd                	jmp    801d7d <_panic+0x43>

00801d80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801d86:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8d:	75 2c                	jne    801dbb <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	6a 07                	push   $0x7
  801d94:	68 00 f0 7f ee       	push   $0xee7ff000
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 c2 ed ff ff       	call   800b62 <sys_page_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	79 14                	jns    801dbb <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	68 4c 27 80 00       	push   $0x80274c
  801daf:	6a 1f                	push   $0x1f
  801db1:	68 b0 27 80 00       	push   $0x8027b0
  801db6:	e8 7f ff ff ff       	call   801d3a <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	68 ef 1d 80 00       	push   $0x801def
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 db ee ff ff       	call   800cad <sys_env_set_pgfault_upcall>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	79 14                	jns    801ded <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 78 27 80 00       	push   $0x802778
  801de1:	6a 25                	push   $0x25
  801de3:	68 b0 27 80 00       	push   $0x8027b0
  801de8:	e8 4d ff ff ff       	call   801d3a <_panic>
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801def:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801df7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801dfa:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801dfc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801e00:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801e04:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801e05:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801e08:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801e0a:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801e0d:	83 c4 04             	add    $0x4,%esp
	popal 
  801e10:	61                   	popa   
	addl $4, %esp 
  801e11:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801e14:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801e15:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801e16:	c3                   	ret    

00801e17 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801e25:	85 f6                	test   %esi,%esi
  801e27:	74 06                	je     801e2f <ipc_recv+0x18>
  801e29:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e2f:	85 db                	test   %ebx,%ebx
  801e31:	74 06                	je     801e39 <ipc_recv+0x22>
  801e33:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e39:	83 f8 01             	cmp    $0x1,%eax
  801e3c:	19 d2                	sbb    %edx,%edx
  801e3e:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	50                   	push   %eax
  801e44:	e8 c9 ee ff ff       	call   800d12 <sys_ipc_recv>
  801e49:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	85 d2                	test   %edx,%edx
  801e50:	75 24                	jne    801e76 <ipc_recv+0x5f>
	if (from_env_store)
  801e52:	85 f6                	test   %esi,%esi
  801e54:	74 0a                	je     801e60 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801e56:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5b:	8b 40 70             	mov    0x70(%eax),%eax
  801e5e:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801e60:	85 db                	test   %ebx,%ebx
  801e62:	74 0a                	je     801e6e <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801e64:	a1 04 40 80 00       	mov    0x804004,%eax
  801e69:	8b 40 74             	mov    0x74(%eax),%eax
  801e6c:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801e6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e73:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801e76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	57                   	push   %edi
  801e81:	56                   	push   %esi
  801e82:	53                   	push   %ebx
  801e83:	83 ec 0c             	sub    $0xc,%esp
  801e86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801e8f:	83 fb 01             	cmp    $0x1,%ebx
  801e92:	19 c0                	sbb    %eax,%eax
  801e94:	09 c3                	or     %eax,%ebx
  801e96:	eb 1c                	jmp    801eb4 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801e98:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9b:	74 12                	je     801eaf <ipc_send+0x32>
  801e9d:	50                   	push   %eax
  801e9e:	68 be 27 80 00       	push   $0x8027be
  801ea3:	6a 36                	push   $0x36
  801ea5:	68 d5 27 80 00       	push   $0x8027d5
  801eaa:	e8 8b fe ff ff       	call   801d3a <_panic>
		sys_yield();
  801eaf:	e8 8f ec ff ff       	call   800b43 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801eb4:	ff 75 14             	pushl  0x14(%ebp)
  801eb7:	53                   	push   %ebx
  801eb8:	56                   	push   %esi
  801eb9:	57                   	push   %edi
  801eba:	e8 30 ee ff ff       	call   800cef <sys_ipc_try_send>
		if (ret == 0) break;
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	75 d2                	jne    801e98 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec9:	5b                   	pop    %ebx
  801eca:	5e                   	pop    %esi
  801ecb:	5f                   	pop    %edi
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ed4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ed9:	6b d0 78             	imul   $0x78,%eax,%edx
  801edc:	83 c2 50             	add    $0x50,%edx
  801edf:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ee5:	39 ca                	cmp    %ecx,%edx
  801ee7:	75 0d                	jne    801ef6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ee9:	6b c0 78             	imul   $0x78,%eax,%eax
  801eec:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ef1:	8b 40 08             	mov    0x8(%eax),%eax
  801ef4:	eb 0e                	jmp    801f04 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef6:	83 c0 01             	add    $0x1,%eax
  801ef9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801efe:	75 d9                	jne    801ed9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f00:	66 b8 00 00          	mov    $0x0,%ax
}
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    

00801f06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0c:	89 d0                	mov    %edx,%eax
  801f0e:	c1 e8 16             	shr    $0x16,%eax
  801f11:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f18:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1d:	f6 c1 01             	test   $0x1,%cl
  801f20:	74 1d                	je     801f3f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f22:	c1 ea 0c             	shr    $0xc,%edx
  801f25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f2c:	f6 c2 01             	test   $0x1,%dl
  801f2f:	74 0e                	je     801f3f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f31:	c1 ea 0c             	shr    $0xc,%edx
  801f34:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3b:	ef 
  801f3c:	0f b7 c0             	movzwl %ax,%eax
}
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    
  801f41:	66 90                	xchg   %ax,%ax
  801f43:	66 90                	xchg   %ax,%ax
  801f45:	66 90                	xchg   %ax,%ax
  801f47:	66 90                	xchg   %ax,%ax
  801f49:	66 90                	xchg   %ax,%ax
  801f4b:	66 90                	xchg   %ax,%ax
  801f4d:	66 90                	xchg   %ax,%ax
  801f4f:	90                   	nop

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	83 ec 10             	sub    $0x10,%esp
  801f56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f66:	85 d2                	test   %edx,%edx
  801f68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f6c:	89 34 24             	mov    %esi,(%esp)
  801f6f:	89 c8                	mov    %ecx,%eax
  801f71:	75 35                	jne    801fa8 <__udivdi3+0x58>
  801f73:	39 f1                	cmp    %esi,%ecx
  801f75:	0f 87 bd 00 00 00    	ja     802038 <__udivdi3+0xe8>
  801f7b:	85 c9                	test   %ecx,%ecx
  801f7d:	89 cd                	mov    %ecx,%ebp
  801f7f:	75 0b                	jne    801f8c <__udivdi3+0x3c>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	31 d2                	xor    %edx,%edx
  801f88:	f7 f1                	div    %ecx
  801f8a:	89 c5                	mov    %eax,%ebp
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f5                	div    %ebp
  801f92:	89 c6                	mov    %eax,%esi
  801f94:	89 f8                	mov    %edi,%eax
  801f96:	f7 f5                	div    %ebp
  801f98:	89 f2                	mov    %esi,%edx
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    
  801fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	3b 14 24             	cmp    (%esp),%edx
  801fab:	77 7b                	ja     802028 <__udivdi3+0xd8>
  801fad:	0f bd f2             	bsr    %edx,%esi
  801fb0:	83 f6 1f             	xor    $0x1f,%esi
  801fb3:	0f 84 97 00 00 00    	je     802050 <__udivdi3+0x100>
  801fb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801fbe:	89 d7                	mov    %edx,%edi
  801fc0:	89 f1                	mov    %esi,%ecx
  801fc2:	29 f5                	sub    %esi,%ebp
  801fc4:	d3 e7                	shl    %cl,%edi
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	d3 ea                	shr    %cl,%edx
  801fcc:	89 f1                	mov    %esi,%ecx
  801fce:	09 fa                	or     %edi,%edx
  801fd0:	8b 3c 24             	mov    (%esp),%edi
  801fd3:	d3 e0                	shl    %cl,%eax
  801fd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fd9:	89 e9                	mov    %ebp,%ecx
  801fdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fe3:	89 fa                	mov    %edi,%edx
  801fe5:	d3 ea                	shr    %cl,%edx
  801fe7:	89 f1                	mov    %esi,%ecx
  801fe9:	d3 e7                	shl    %cl,%edi
  801feb:	89 e9                	mov    %ebp,%ecx
  801fed:	d3 e8                	shr    %cl,%eax
  801fef:	09 c7                	or     %eax,%edi
  801ff1:	89 f8                	mov    %edi,%eax
  801ff3:	f7 74 24 08          	divl   0x8(%esp)
  801ff7:	89 d5                	mov    %edx,%ebp
  801ff9:	89 c7                	mov    %eax,%edi
  801ffb:	f7 64 24 0c          	mull   0xc(%esp)
  801fff:	39 d5                	cmp    %edx,%ebp
  802001:	89 14 24             	mov    %edx,(%esp)
  802004:	72 11                	jb     802017 <__udivdi3+0xc7>
  802006:	8b 54 24 04          	mov    0x4(%esp),%edx
  80200a:	89 f1                	mov    %esi,%ecx
  80200c:	d3 e2                	shl    %cl,%edx
  80200e:	39 c2                	cmp    %eax,%edx
  802010:	73 5e                	jae    802070 <__udivdi3+0x120>
  802012:	3b 2c 24             	cmp    (%esp),%ebp
  802015:	75 59                	jne    802070 <__udivdi3+0x120>
  802017:	8d 47 ff             	lea    -0x1(%edi),%eax
  80201a:	31 f6                	xor    %esi,%esi
  80201c:	89 f2                	mov    %esi,%edx
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	31 f6                	xor    %esi,%esi
  80202a:	31 c0                	xor    %eax,%eax
  80202c:	89 f2                	mov    %esi,%edx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	89 f2                	mov    %esi,%edx
  80203a:	31 f6                	xor    %esi,%esi
  80203c:	89 f8                	mov    %edi,%eax
  80203e:	f7 f1                	div    %ecx
  802040:	89 f2                	mov    %esi,%edx
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802054:	76 0b                	jbe    802061 <__udivdi3+0x111>
  802056:	31 c0                	xor    %eax,%eax
  802058:	3b 14 24             	cmp    (%esp),%edx
  80205b:	0f 83 37 ff ff ff    	jae    801f98 <__udivdi3+0x48>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	e9 2d ff ff ff       	jmp    801f98 <__udivdi3+0x48>
  80206b:	90                   	nop
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 f8                	mov    %edi,%eax
  802072:	31 f6                	xor    %esi,%esi
  802074:	e9 1f ff ff ff       	jmp    801f98 <__udivdi3+0x48>
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	83 ec 20             	sub    $0x20,%esp
  802086:	8b 44 24 34          	mov    0x34(%esp),%eax
  80208a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80208e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802092:	89 c6                	mov    %eax,%esi
  802094:	89 44 24 10          	mov    %eax,0x10(%esp)
  802098:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80209c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8020a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	89 c2                	mov    %eax,%edx
  8020b0:	75 1e                	jne    8020d0 <__umoddi3+0x50>
  8020b2:	39 f7                	cmp    %esi,%edi
  8020b4:	76 52                	jbe    802108 <__umoddi3+0x88>
  8020b6:	89 c8                	mov    %ecx,%eax
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	f7 f7                	div    %edi
  8020bc:	89 d0                	mov    %edx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	83 c4 20             	add    $0x20,%esp
  8020c3:	5e                   	pop    %esi
  8020c4:	5f                   	pop    %edi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    
  8020c7:	89 f6                	mov    %esi,%esi
  8020c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020d0:	39 f0                	cmp    %esi,%eax
  8020d2:	77 5c                	ja     802130 <__umoddi3+0xb0>
  8020d4:	0f bd e8             	bsr    %eax,%ebp
  8020d7:	83 f5 1f             	xor    $0x1f,%ebp
  8020da:	75 64                	jne    802140 <__umoddi3+0xc0>
  8020dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8020e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8020e4:	0f 86 f6 00 00 00    	jbe    8021e0 <__umoddi3+0x160>
  8020ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8020ee:	0f 82 ec 00 00 00    	jb     8021e0 <__umoddi3+0x160>
  8020f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8020fc:	83 c4 20             	add    $0x20,%esp
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
  802103:	90                   	nop
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	85 ff                	test   %edi,%edi
  80210a:	89 fd                	mov    %edi,%ebp
  80210c:	75 0b                	jne    802119 <__umoddi3+0x99>
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f7                	div    %edi
  802117:	89 c5                	mov    %eax,%ebp
  802119:	8b 44 24 10          	mov    0x10(%esp),%eax
  80211d:	31 d2                	xor    %edx,%edx
  80211f:	f7 f5                	div    %ebp
  802121:	89 c8                	mov    %ecx,%eax
  802123:	f7 f5                	div    %ebp
  802125:	eb 95                	jmp    8020bc <__umoddi3+0x3c>
  802127:	89 f6                	mov    %esi,%esi
  802129:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 20             	add    $0x20,%esp
  802137:	5e                   	pop    %esi
  802138:	5f                   	pop    %edi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    
  80213b:	90                   	nop
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	b8 20 00 00 00       	mov    $0x20,%eax
  802145:	89 e9                	mov    %ebp,%ecx
  802147:	29 e8                	sub    %ebp,%eax
  802149:	d3 e2                	shl    %cl,%edx
  80214b:	89 c7                	mov    %eax,%edi
  80214d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802151:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 c1                	mov    %eax,%ecx
  80215b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80215f:	09 d1                	or     %edx,%ecx
  802161:	89 fa                	mov    %edi,%edx
  802163:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802167:	89 e9                	mov    %ebp,%ecx
  802169:	d3 e0                	shl    %cl,%eax
  80216b:	89 f9                	mov    %edi,%ecx
  80216d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802171:	89 f0                	mov    %esi,%eax
  802173:	d3 e8                	shr    %cl,%eax
  802175:	89 e9                	mov    %ebp,%ecx
  802177:	89 c7                	mov    %eax,%edi
  802179:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80217d:	d3 e6                	shl    %cl,%esi
  80217f:	89 d1                	mov    %edx,%ecx
  802181:	89 fa                	mov    %edi,%edx
  802183:	d3 e8                	shr    %cl,%eax
  802185:	89 e9                	mov    %ebp,%ecx
  802187:	09 f0                	or     %esi,%eax
  802189:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80218d:	f7 74 24 10          	divl   0x10(%esp)
  802191:	d3 e6                	shl    %cl,%esi
  802193:	89 d1                	mov    %edx,%ecx
  802195:	f7 64 24 0c          	mull   0xc(%esp)
  802199:	39 d1                	cmp    %edx,%ecx
  80219b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80219f:	89 d7                	mov    %edx,%edi
  8021a1:	89 c6                	mov    %eax,%esi
  8021a3:	72 0a                	jb     8021af <__umoddi3+0x12f>
  8021a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8021a9:	73 10                	jae    8021bb <__umoddi3+0x13b>
  8021ab:	39 d1                	cmp    %edx,%ecx
  8021ad:	75 0c                	jne    8021bb <__umoddi3+0x13b>
  8021af:	89 d7                	mov    %edx,%edi
  8021b1:	89 c6                	mov    %eax,%esi
  8021b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8021b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8021bb:	89 ca                	mov    %ecx,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021c3:	29 f0                	sub    %esi,%eax
  8021c5:	19 fa                	sbb    %edi,%edx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021ce:	89 d7                	mov    %edx,%edi
  8021d0:	d3 e7                	shl    %cl,%edi
  8021d2:	89 e9                	mov    %ebp,%ecx
  8021d4:	09 f8                	or     %edi,%eax
  8021d6:	d3 ea                	shr    %cl,%edx
  8021d8:	83 c4 20             	add    $0x20,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
  8021df:	90                   	nop
  8021e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021e4:	29 f9                	sub    %edi,%ecx
  8021e6:	19 c6                	sbb    %eax,%esi
  8021e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021f0:	e9 ff fe ff ff       	jmp    8020f4 <__umoddi3+0x74>
