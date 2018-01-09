
obj/user/cat:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 40 40 80 00       	push   $0x804040
  800046:	6a 01                	push   $0x1
  800048:	e8 72 11 00 00       	call   8011bf <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 d8                	cmp    %ebx,%eax
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %i", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 00 20 80 00       	push   $0x802000
  800060:	6a 0d                	push   $0xd
  800062:	68 1b 20 80 00       	push   $0x80201b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 40 40 80 00       	push   $0x804040
  800079:	56                   	push   %esi
  80007a:	e8 6a 10 00 00       	call   8010e9 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %i", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %i", s, (int) n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 26 20 80 00       	push   $0x802026
  800098:	6a 0f                	push   $0xf
  80009a:	68 1b 20 80 00       	push   $0x80201b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 3b 	movl   $0x80203b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 3f 20 80 00       	push   $0x80203f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 87 14 00 00       	call   801574 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %i\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 47 20 80 00       	push   $0x802047
  800102:	e8 0f 16 00 00       	call   801716 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 89 0e 00 00       	call   800fa9 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80013e:	e8 79 0a 00 00       	call   800bbc <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 78             	imul   $0x78,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 40 60 80 00       	mov    %eax,0x806040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
  80016f:	83 c4 10             	add    $0x10,%esp
#endif
}
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 52 0e 00 00       	call   800fd6 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 ed 09 00 00       	call   800b7b <sys_env_destroy>
  80018e:	83 c4 10             	add    $0x10,%esp
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 16 0a 00 00       	call   800bbc <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 64 20 80 00       	push   $0x802064
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 27 24 80 00 	movl   $0x802427,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 35 09 00 00       	call   800b3e <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 4f 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 da 08 00 00       	call   800b3e <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 d1                	mov    %edx,%ecx
  800295:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800298:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029b:	8b 45 10             	mov    0x10(%ebp),%eax
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ab:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002ae:	72 05                	jb     8002b5 <printnum+0x35>
  8002b0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002b3:	77 3e                	ja     8002f3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	ff 75 18             	pushl  0x18(%ebp)
  8002bb:	83 eb 01             	sub    $0x1,%ebx
  8002be:	53                   	push   %ebx
  8002bf:	50                   	push   %eax
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 5c 1a 00 00       	call   801d30 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 13                	jmp    8002fa <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f3:	83 eb 01             	sub    $0x1,%ebx
  8002f6:	85 db                	test   %ebx,%ebx
  8002f8:	7f ed                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	56                   	push   %esi
  8002fe:	83 ec 04             	sub    $0x4,%esp
  800301:	ff 75 e4             	pushl  -0x1c(%ebp)
  800304:	ff 75 e0             	pushl  -0x20(%ebp)
  800307:	ff 75 dc             	pushl  -0x24(%ebp)
  80030a:	ff 75 d8             	pushl  -0x28(%ebp)
  80030d:	e8 4e 1b 00 00       	call   801e60 <__umoddi3>
  800312:	83 c4 14             	add    $0x14,%esp
  800315:	0f be 80 87 20 80 00 	movsbl 0x802087(%eax),%eax
  80031c:	50                   	push   %eax
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
}
  800322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	3b 50 04             	cmp    0x4(%eax),%edx
  800373:	73 0a                	jae    80037f <sprintputch+0x1b>
		*b->buf++ = ch;
  800375:	8d 4a 01             	lea    0x1(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	88 02                	mov    %al,(%edx)
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038a:	50                   	push   %eax
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	ff 75 0c             	pushl  0xc(%ebp)
  800391:	ff 75 08             	pushl  0x8(%ebp)
  800394:	e8 05 00 00 00       	call   80039e <vprintfmt>
	va_end(ap);
  800399:	83 c4 10             	add    $0x10,%esp
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 2c             	sub    $0x2c,%esp
  8003a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ad:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b0:	eb 12                	jmp    8003c4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	0f 84 8d 03 00 00    	je     800747 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	53                   	push   %ebx
  8003be:	50                   	push   %eax
  8003bf:	ff d6                	call   *%esi
  8003c1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c4:	83 c7 01             	add    $0x1,%edi
  8003c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003cb:	83 f8 25             	cmp    $0x25,%eax
  8003ce:	75 e2                	jne    8003b2 <vprintfmt+0x14>
  8003d0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 07                	jmp    8003f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8d 47 01             	lea    0x1(%edi),%eax
  8003fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fd:	0f b6 07             	movzbl (%edi),%eax
  800400:	0f b6 c8             	movzbl %al,%ecx
  800403:	83 e8 23             	sub    $0x23,%eax
  800406:	3c 55                	cmp    $0x55,%al
  800408:	0f 87 1e 03 00 00    	ja     80072c <vprintfmt+0x38e>
  80040e:	0f b6 c0             	movzbl %al,%eax
  800411:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041f:	eb d6                	jmp    8003f7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800433:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800436:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800439:	83 fa 09             	cmp    $0x9,%edx
  80043c:	77 38                	ja     800476 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800441:	eb e9                	jmp    80042c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 48 04             	lea    0x4(%eax),%ecx
  800449:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800454:	eb 26                	jmp    80047c <vprintfmt+0xde>
  800456:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800459:	89 c8                	mov    %ecx,%eax
  80045b:	c1 f8 1f             	sar    $0x1f,%eax
  80045e:	f7 d0                	not    %eax
  800460:	21 c1                	and    %eax,%ecx
  800462:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800468:	eb 8d                	jmp    8003f7 <vprintfmt+0x59>
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800474:	eb 81                	jmp    8003f7 <vprintfmt+0x59>
  800476:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800479:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800480:	0f 89 71 ff ff ff    	jns    8003f7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800486:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800489:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800493:	e9 5f ff ff ff       	jmp    8003f7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800498:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049e:	e9 54 ff ff ff       	jmp    8003f7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 50 04             	lea    0x4(%eax),%edx
  8004a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	53                   	push   %ebx
  8004b0:	ff 30                	pushl  (%eax)
  8004b2:	ff d6                	call   *%esi
			break;
  8004b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ba:	e9 05 ff ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 50 04             	lea    0x4(%eax),%edx
  8004c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c8:	8b 00                	mov    (%eax),%eax
  8004ca:	99                   	cltd   
  8004cb:	31 d0                	xor    %edx,%eax
  8004cd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cf:	83 f8 0f             	cmp    $0xf,%eax
  8004d2:	7f 0b                	jg     8004df <vprintfmt+0x141>
  8004d4:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	75 18                	jne    8004f7 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8004df:	50                   	push   %eax
  8004e0:	68 9f 20 80 00       	push   $0x80209f
  8004e5:	53                   	push   %ebx
  8004e6:	56                   	push   %esi
  8004e7:	e8 95 fe ff ff       	call   800381 <printfmt>
  8004ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f2:	e9 cd fe ff ff       	jmp    8003c4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f7:	52                   	push   %edx
  8004f8:	68 71 24 80 00       	push   $0x802471
  8004fd:	53                   	push   %ebx
  8004fe:	56                   	push   %esi
  8004ff:	e8 7d fe ff ff       	call   800381 <printfmt>
  800504:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050a:	e9 b5 fe ff ff       	jmp    8003c4 <vprintfmt+0x26>
  80050f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800512:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800515:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 04             	lea    0x4(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 38                	mov    (%eax),%edi
  800523:	85 ff                	test   %edi,%edi
  800525:	75 05                	jne    80052c <vprintfmt+0x18e>
				p = "(null)";
  800527:	bf 98 20 80 00       	mov    $0x802098,%edi
			if (width > 0 && padc != '-')
  80052c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800530:	0f 84 91 00 00 00    	je     8005c7 <vprintfmt+0x229>
  800536:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80053a:	0f 8e 95 00 00 00    	jle    8005d5 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	51                   	push   %ecx
  800544:	57                   	push   %edi
  800545:	e8 85 02 00 00       	call   8007cf <strnlen>
  80054a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c5>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057c:	89 c8                	mov    %ecx,%eax
  80057e:	c1 f8 1f             	sar    $0x1f,%eax
  800581:	f7 d0                	not    %eax
  800583:	21 c8                	and    %ecx,%eax
  800585:	29 c1                	sub    %eax,%ecx
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	89 cb                	mov    %ecx,%ebx
  800592:	eb 4d                	jmp    8005e1 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800594:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800598:	74 1b                	je     8005b5 <vprintfmt+0x217>
  80059a:	0f be c0             	movsbl %al,%eax
  80059d:	83 e8 20             	sub    $0x20,%eax
  8005a0:	83 f8 5e             	cmp    $0x5e,%eax
  8005a3:	76 10                	jbe    8005b5 <vprintfmt+0x217>
					putch('?', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 0c             	pushl  0xc(%ebp)
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff 55 08             	call   *0x8(%ebp)
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	eb 0d                	jmp    8005c2 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	52                   	push   %edx
  8005bc:	ff 55 08             	call   *0x8(%ebp)
  8005bf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	83 eb 01             	sub    $0x1,%ebx
  8005c5:	eb 1a                	jmp    8005e1 <vprintfmt+0x243>
  8005c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d3:	eb 0c                	jmp    8005e1 <vprintfmt+0x243>
  8005d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e1:	83 c7 01             	add    $0x1,%edi
  8005e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e8:	0f be d0             	movsbl %al,%edx
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 23                	je     800612 <vprintfmt+0x274>
  8005ef:	85 f6                	test   %esi,%esi
  8005f1:	78 a1                	js     800594 <vprintfmt+0x1f6>
  8005f3:	83 ee 01             	sub    $0x1,%esi
  8005f6:	79 9c                	jns    800594 <vprintfmt+0x1f6>
  8005f8:	89 df                	mov    %ebx,%edi
  8005fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800600:	eb 18                	jmp    80061a <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 20                	push   $0x20
  800608:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060a:	83 ef 01             	sub    $0x1,%edi
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	eb 08                	jmp    80061a <vprintfmt+0x27c>
  800612:	89 df                	mov    %ebx,%edi
  800614:	8b 75 08             	mov    0x8(%ebp),%esi
  800617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061a:	85 ff                	test   %edi,%edi
  80061c:	7f e4                	jg     800602 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800621:	e9 9e fd ff ff       	jmp    8003c4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800626:	83 fa 01             	cmp    $0x1,%edx
  800629:	7e 16                	jle    800641 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 08             	lea    0x8(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 50 04             	mov    0x4(%eax),%edx
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063f:	eb 32                	jmp    800673 <vprintfmt+0x2d5>
	else if (lflag)
  800641:	85 d2                	test   %edx,%edx
  800643:	74 18                	je     80065d <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 50 04             	lea    0x4(%eax),%edx
  80064b:	89 55 14             	mov    %edx,0x14(%ebp)
  80064e:	8b 00                	mov    (%eax),%eax
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 c1                	mov    %eax,%ecx
  800655:	c1 f9 1f             	sar    $0x1f,%ecx
  800658:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065b:	eb 16                	jmp    800673 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	8b 00                	mov    (%eax),%eax
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 c1                	mov    %eax,%ecx
  80066d:	c1 f9 1f             	sar    $0x1f,%ecx
  800670:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800673:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800676:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800682:	79 74                	jns    8006f8 <vprintfmt+0x35a>
				putch('-', putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 2d                	push   $0x2d
  80068a:	ff d6                	call   *%esi
				num = -(long long) num;
  80068c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80068f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800692:	f7 d8                	neg    %eax
  800694:	83 d2 00             	adc    $0x0,%edx
  800697:	f7 da                	neg    %edx
  800699:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a1:	eb 55                	jmp    8006f8 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 7f fc ff ff       	call   80032a <getuint>
			base = 10;
  8006ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b0:	eb 46                	jmp    8006f8 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 70 fc ff ff       	call   80032a <getuint>
			base = 8;
  8006ba:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006bf:	eb 37                	jmp    8006f8 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 30                	push   $0x30
  8006c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c9:	83 c4 08             	add    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 78                	push   $0x78
  8006cf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e9:	eb 0d                	jmp    8006f8 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 37 fc ff ff       	call   80032a <getuint>
			base = 16;
  8006f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ff:	57                   	push   %edi
  800700:	ff 75 e0             	pushl  -0x20(%ebp)
  800703:	51                   	push   %ecx
  800704:	52                   	push   %edx
  800705:	50                   	push   %eax
  800706:	89 da                	mov    %ebx,%edx
  800708:	89 f0                	mov    %esi,%eax
  80070a:	e8 71 fb ff ff       	call   800280 <printnum>
			break;
  80070f:	83 c4 20             	add    $0x20,%esp
  800712:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800715:	e9 aa fc ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	51                   	push   %ecx
  80071f:	ff d6                	call   *%esi
			break;
  800721:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800727:	e9 98 fc ff ff       	jmp    8003c4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 25                	push   $0x25
  800732:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 03                	jmp    80073c <vprintfmt+0x39e>
  800739:	83 ef 01             	sub    $0x1,%edi
  80073c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800740:	75 f7                	jne    800739 <vprintfmt+0x39b>
  800742:	e9 7d fc ff ff       	jmp    8003c4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800762:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800765:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	74 26                	je     800796 <vsnprintf+0x47>
  800770:	85 d2                	test   %edx,%edx
  800772:	7e 22                	jle    800796 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800774:	ff 75 14             	pushl  0x14(%ebp)
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	68 64 03 80 00       	push   $0x800364
  800783:	e8 16 fc ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 05                	jmp    80079b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	ff 75 08             	pushl  0x8(%ebp)
  8007b0:	e8 9a ff ff ff       	call   80074f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	eb 03                	jmp    8007c7 <strlen+0x10>
		n++;
  8007c4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cb:	75 f7                	jne    8007c4 <strlen+0xd>
		n++;
	return n;
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007dd:	eb 03                	jmp    8007e2 <strnlen+0x13>
		n++;
  8007df:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e2:	39 c2                	cmp    %eax,%edx
  8007e4:	74 08                	je     8007ee <strnlen+0x1f>
  8007e6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ea:	75 f3                	jne    8007df <strnlen+0x10>
  8007ec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	83 c1 01             	add    $0x1,%ecx
  800802:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
  800809:	84 db                	test   %bl,%bl
  80080b:	75 ef                	jne    8007fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800817:	53                   	push   %ebx
  800818:	e8 9a ff ff ff       	call   8007b7 <strlen>
  80081d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	01 d8                	add    %ebx,%eax
  800825:	50                   	push   %eax
  800826:	e8 c5 ff ff ff       	call   8007f0 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086a:	8b 55 10             	mov    0x10(%ebp),%edx
  80086d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086f:	85 d2                	test   %edx,%edx
  800871:	74 21                	je     800894 <strlcpy+0x35>
  800873:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 09                	jmp    800884 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800884:	39 c2                	cmp    %eax,%edx
  800886:	74 09                	je     800891 <strlcpy+0x32>
  800888:	0f b6 19             	movzbl (%ecx),%ebx
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ec                	jne    80087b <strlcpy+0x1c>
  80088f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800891:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800894:	29 f0                	sub    %esi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a3:	eb 06                	jmp    8008ab <strcmp+0x11>
		p++, q++;
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 04                	je     8008b6 <strcmp+0x1c>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	74 ef                	je     8008a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 c0             	movzbl %al,%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cf:	eb 06                	jmp    8008d7 <strncmp+0x17>
		n--, p++, q++;
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d7:	39 d8                	cmp    %ebx,%eax
  8008d9:	74 15                	je     8008f0 <strncmp+0x30>
  8008db:	0f b6 08             	movzbl (%eax),%ecx
  8008de:	84 c9                	test   %cl,%cl
  8008e0:	74 04                	je     8008e6 <strncmp+0x26>
  8008e2:	3a 0a                	cmp    (%edx),%cl
  8008e4:	74 eb                	je     8008d1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 00             	movzbl (%eax),%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
  8008ee:	eb 05                	jmp    8008f5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800902:	eb 07                	jmp    80090b <strchr+0x13>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0f                	je     800917 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	0f b6 10             	movzbl (%eax),%edx
  80090e:	84 d2                	test   %dl,%dl
  800910:	75 f2                	jne    800904 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 03                	jmp    800928 <strfind+0xf>
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 04                	je     800933 <strfind+0x1a>
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	75 f2                	jne    800925 <strfind+0xc>
			break;
	return (char *) s;
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 36                	je     80097b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 28                	jne    800975 <memset+0x40>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 23                	jne    800975 <memset+0x40>
		c &= 0xFF;
  800952:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800956:	89 d3                	mov    %edx,%ebx
  800958:	c1 e3 08             	shl    $0x8,%ebx
  80095b:	89 d6                	mov    %edx,%esi
  80095d:	c1 e6 18             	shl    $0x18,%esi
  800960:	89 d0                	mov    %edx,%eax
  800962:	c1 e0 10             	shl    $0x10,%eax
  800965:	09 f0                	or     %esi,%eax
  800967:	09 c2                	or     %eax,%edx
  800969:	89 d0                	mov    %edx,%eax
  80096b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800970:	fc                   	cld    
  800971:	f3 ab                	rep stos %eax,%es:(%edi)
  800973:	eb 06                	jmp    80097b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	fc                   	cld    
  800979:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097b:	89 f8                	mov    %edi,%eax
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800990:	39 c6                	cmp    %eax,%esi
  800992:	73 35                	jae    8009c9 <memmove+0x47>
  800994:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800997:	39 d0                	cmp    %edx,%eax
  800999:	73 2e                	jae    8009c9 <memmove+0x47>
		s += n;
		d += n;
  80099b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a8:	75 13                	jne    8009bd <memmove+0x3b>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	75 0e                	jne    8009bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009af:	83 ef 04             	sub    $0x4,%edi
  8009b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b8:	fd                   	std    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 09                	jmp    8009c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bd:	83 ef 01             	sub    $0x1,%edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 1d                	jmp    8009e6 <memmove+0x64>
  8009c9:	89 f2                	mov    %esi,%edx
  8009cb:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	f6 c2 03             	test   $0x3,%dl
  8009d0:	75 0f                	jne    8009e1 <memmove+0x5f>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ed:	ff 75 10             	pushl  0x10(%ebp)
  8009f0:	ff 75 0c             	pushl  0xc(%ebp)
  8009f3:	ff 75 08             	pushl  0x8(%ebp)
  8009f6:	e8 87 ff ff ff       	call   800982 <memmove>
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a08:	89 c6                	mov    %eax,%esi
  800a0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	eb 1a                	jmp    800a29 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0f:	0f b6 08             	movzbl (%eax),%ecx
  800a12:	0f b6 1a             	movzbl (%edx),%ebx
  800a15:	38 d9                	cmp    %bl,%cl
  800a17:	74 0a                	je     800a23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c1             	movzbl %cl,%eax
  800a1c:	0f b6 db             	movzbl %bl,%ebx
  800a1f:	29 d8                	sub    %ebx,%eax
  800a21:	eb 0f                	jmp    800a32 <memcmp+0x35>
		s1++, s2++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 f0                	cmp    %esi,%eax
  800a2b:	75 e2                	jne    800a0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3f:	89 c2                	mov    %eax,%edx
  800a41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a44:	eb 07                	jmp    800a4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 07                	je     800a51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	39 d0                	cmp    %edx,%eax
  800a4f:	72 f5                	jb     800a46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x11>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	3c 09                	cmp    $0x9,%al
  800a69:	74 f6                	je     800a61 <strtol+0xe>
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f2                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	75 0a                	jne    800a7d <strtol+0x2a>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 10                	jmp    800a8d <strtol+0x3a>
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 07                	jne    800a8d <strtol+0x3a>
		s++, neg = 1;
  800a86:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a89:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	0f 94 c0             	sete   %al
  800a92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a98:	75 19                	jne    800ab3 <strtol+0x60>
  800a9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9d:	75 14                	jne    800ab3 <strtol+0x60>
  800a9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa3:	0f 85 8a 00 00 00    	jne    800b33 <strtol+0xe0>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab3:	84 c0                	test   %al,%al
  800ab5:	74 12                	je     800ac9 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x76>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x93>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0f                	jge    800b1c <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x7e>
  800b18:	89 c2                	mov    %eax,%edx
  800b1a:	eb 02                	jmp    800b1e <strtol+0xcb>
  800b1c:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 05                	je     800b29 <strtol+0xd6>
		*endptr = (char *) s;
  800b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b27:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	74 0c                	je     800b39 <strtol+0xe6>
  800b2d:	89 d0                	mov    %edx,%eax
  800b2f:	f7 d8                	neg    %eax
  800b31:	eb 06                	jmp    800b39 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	84 c0                	test   %al,%al
  800b35:	75 8a                	jne    800ac1 <strtol+0x6e>
  800b37:	eb 90                	jmp    800ac9 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 c3                	mov    %eax,%ebx
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 cb                	mov    %ecx,%ebx
  800b93:	89 cf                	mov    %ecx,%edi
  800b95:	89 ce                	mov    %ecx,%esi
  800b97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 03                	push   $0x3
  800ba3:	68 9f 23 80 00       	push   $0x80239f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 bc 23 80 00       	push   $0x8023bc
  800baf:	e8 df f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_yield>:

void
sys_yield(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	be 00 00 00 00       	mov    $0x0,%esi
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	89 f7                	mov    %esi,%edi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 04                	push   $0x4
  800c24:	68 9f 23 80 00       	push   $0x80239f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 bc 23 80 00       	push   $0x8023bc
  800c30:	e8 5e f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 05                	push   $0x5
  800c66:	68 9f 23 80 00       	push   $0x80239f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 bc 23 80 00       	push   $0x8023bc
  800c72:	e8 1c f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 06                	push   $0x6
  800ca8:	68 9f 23 80 00       	push   $0x80239f
  800cad:	6a 23                	push   $0x23
  800caf:	68 bc 23 80 00       	push   $0x8023bc
  800cb4:	e8 da f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 08                	push   $0x8
  800cea:	68 9f 23 80 00       	push   $0x80239f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 bc 23 80 00       	push   $0x8023bc
  800cf6:	e8 98 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 09 00 00 00       	mov    $0x9,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 09                	push   $0x9
  800d2c:	68 9f 23 80 00       	push   $0x80239f
  800d31:	6a 23                	push   $0x23
  800d33:	68 bc 23 80 00       	push   $0x8023bc
  800d38:	e8 56 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 17                	jle    800d7f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	50                   	push   %eax
  800d6c:	6a 0a                	push   $0xa
  800d6e:	68 9f 23 80 00       	push   $0x80239f
  800d73:	6a 23                	push   $0x23
  800d75:	68 bc 23 80 00       	push   $0x8023bc
  800d7a:	e8 14 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	be 00 00 00 00       	mov    $0x0,%esi
  800d92:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 0d                	push   $0xd
  800dd2:	68 9f 23 80 00       	push   $0x80239f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 bc 23 80 00       	push   $0x8023bc
  800dde:	e8 b0 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_gettime>:

int sys_gettime(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	05 00 00 00 30       	add    $0x30000000,%eax
  800e15:	c1 e8 0c             	shr    $0xc,%eax
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 11                	je     800e5e <fd_alloc+0x2d>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	75 09                	jne    800e67 <fd_alloc+0x36>
			*fd_store = fd;
  800e5e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	eb 17                	jmp    800e7e <fd_alloc+0x4d>
  800e67:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e71:	75 c9                	jne    800e3c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e73:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e79:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e86:	83 f8 1f             	cmp    $0x1f,%eax
  800e89:	77 36                	ja     800ec1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8b:	c1 e0 0c             	shl    $0xc,%eax
  800e8e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 16             	shr    $0x16,%edx
  800e98:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	74 24                	je     800ec8 <fd_lookup+0x48>
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	c1 ea 0c             	shr    $0xc,%edx
  800ea9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb0:	f6 c2 01             	test   $0x1,%dl
  800eb3:	74 1a                	je     800ecf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 13                	jmp    800ed4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec6:	eb 0c                	jmp    800ed4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb 05                	jmp    800ed4 <fd_lookup+0x54>
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edf:	ba 48 24 80 00       	mov    $0x802448,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee4:	eb 13                	jmp    800ef9 <dev_lookup+0x23>
  800ee6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee9:	39 08                	cmp    %ecx,(%eax)
  800eeb:	75 0c                	jne    800ef9 <dev_lookup+0x23>
			*dev = devtab[i];
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	eb 2e                	jmp    800f27 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef9:	8b 02                	mov    (%edx),%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 e7                	jne    800ee6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eff:	a1 40 60 80 00       	mov    0x806040,%eax
  800f04:	8b 40 48             	mov    0x48(%eax),%eax
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	51                   	push   %ecx
  800f0b:	50                   	push   %eax
  800f0c:	68 cc 23 80 00       	push   $0x8023cc
  800f11:	e8 56 f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 10             	sub    $0x10,%esp
  800f31:	8b 75 08             	mov    0x8(%ebp),%esi
  800f34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3a:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f41:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f44:	50                   	push   %eax
  800f45:	e8 36 ff ff ff       	call   800e80 <fd_lookup>
  800f4a:	83 c4 08             	add    $0x8,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 05                	js     800f56 <fd_close+0x2d>
	    || fd != fd2)
  800f51:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f54:	74 0b                	je     800f61 <fd_close+0x38>
		return (must_exist ? r : 0);
  800f56:	80 fb 01             	cmp    $0x1,%bl
  800f59:	19 d2                	sbb    %edx,%edx
  800f5b:	f7 d2                	not    %edx
  800f5d:	21 d0                	and    %edx,%eax
  800f5f:	eb 41                	jmp    800fa2 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	ff 36                	pushl  (%esi)
  800f6a:	e8 67 ff ff ff       	call   800ed6 <dev_lookup>
  800f6f:	89 c3                	mov    %eax,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 1a                	js     800f92 <fd_close+0x69>
		if (dev->dev_close)
  800f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	74 0b                	je     800f92 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	56                   	push   %esi
  800f8b:	ff d0                	call   *%eax
  800f8d:	89 c3                	mov    %eax,%ebx
  800f8f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f92:	83 ec 08             	sub    $0x8,%esp
  800f95:	56                   	push   %esi
  800f96:	6a 00                	push   $0x0
  800f98:	e8 e2 fc ff ff       	call   800c7f <sys_page_unmap>
	return r;
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	89 d8                	mov    %ebx,%eax
}
  800fa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	ff 75 08             	pushl  0x8(%ebp)
  800fb6:	e8 c5 fe ff ff       	call   800e80 <fd_lookup>
  800fbb:	89 c2                	mov    %eax,%edx
  800fbd:	83 c4 08             	add    $0x8,%esp
  800fc0:	85 d2                	test   %edx,%edx
  800fc2:	78 10                	js     800fd4 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fc4:	83 ec 08             	sub    $0x8,%esp
  800fc7:	6a 01                	push   $0x1
  800fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcc:	e8 58 ff ff ff       	call   800f29 <fd_close>
  800fd1:	83 c4 10             	add    $0x10,%esp
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <close_all>:

void
close_all(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	53                   	push   %ebx
  800fe6:	e8 be ff ff ff       	call   800fa9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800feb:	83 c3 01             	add    $0x1,%ebx
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	83 fb 20             	cmp    $0x20,%ebx
  800ff4:	75 ec                	jne    800fe2 <close_all+0xc>
		close(i);
}
  800ff6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	83 ec 2c             	sub    $0x2c,%esp
  801004:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801007:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 6d fe ff ff       	call   800e80 <fd_lookup>
  801013:	89 c2                	mov    %eax,%edx
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 d2                	test   %edx,%edx
  80101a:	0f 88 c1 00 00 00    	js     8010e1 <dup+0xe6>
		return r;
	close(newfdnum);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	56                   	push   %esi
  801024:	e8 80 ff ff ff       	call   800fa9 <close>

	newfd = INDEX2FD(newfdnum);
  801029:	89 f3                	mov    %esi,%ebx
  80102b:	c1 e3 0c             	shl    $0xc,%ebx
  80102e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801034:	83 c4 04             	add    $0x4,%esp
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	e8 db fd ff ff       	call   800e1a <fd2data>
  80103f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801041:	89 1c 24             	mov    %ebx,(%esp)
  801044:	e8 d1 fd ff ff       	call   800e1a <fd2data>
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104f:	89 f8                	mov    %edi,%eax
  801051:	c1 e8 16             	shr    $0x16,%eax
  801054:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105b:	a8 01                	test   $0x1,%al
  80105d:	74 37                	je     801096 <dup+0x9b>
  80105f:	89 f8                	mov    %edi,%eax
  801061:	c1 e8 0c             	shr    $0xc,%eax
  801064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106b:	f6 c2 01             	test   $0x1,%dl
  80106e:	74 26                	je     801096 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	25 07 0e 00 00       	and    $0xe07,%eax
  80107f:	50                   	push   %eax
  801080:	ff 75 d4             	pushl  -0x2c(%ebp)
  801083:	6a 00                	push   $0x0
  801085:	57                   	push   %edi
  801086:	6a 00                	push   $0x0
  801088:	e8 b0 fb ff ff       	call   800c3d <sys_page_map>
  80108d:	89 c7                	mov    %eax,%edi
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 2e                	js     8010c4 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801096:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801099:	89 d0                	mov    %edx,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
  80109e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ad:	50                   	push   %eax
  8010ae:	53                   	push   %ebx
  8010af:	6a 00                	push   $0x0
  8010b1:	52                   	push   %edx
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 84 fb ff ff       	call   800c3d <sys_page_map>
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c0:	85 ff                	test   %edi,%edi
  8010c2:	79 1d                	jns    8010e1 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	53                   	push   %ebx
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 b0 fb ff ff       	call   800c7f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 a3 fb ff ff       	call   800c7f <sys_page_unmap>
	return r;
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	89 f8                	mov    %edi,%eax
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 14             	sub    $0x14,%esp
  8010f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	e8 83 fd ff ff       	call   800e80 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	89 c2                	mov    %eax,%edx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 6d                	js     801173 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	ff 30                	pushl  (%eax)
  801112:	e8 bf fd ff ff       	call   800ed6 <dev_lookup>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 4c                	js     80116a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801121:	8b 42 08             	mov    0x8(%edx),%eax
  801124:	83 e0 03             	and    $0x3,%eax
  801127:	83 f8 01             	cmp    $0x1,%eax
  80112a:	75 21                	jne    80114d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112c:	a1 40 60 80 00       	mov    0x806040,%eax
  801131:	8b 40 48             	mov    0x48(%eax),%eax
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	53                   	push   %ebx
  801138:	50                   	push   %eax
  801139:	68 0d 24 80 00       	push   $0x80240d
  80113e:	e8 29 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114b:	eb 26                	jmp    801173 <read+0x8a>
	}
	if (!dev->dev_read)
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	8b 40 08             	mov    0x8(%eax),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	74 17                	je     80116e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	52                   	push   %edx
  801161:	ff d0                	call   *%eax
  801163:	89 c2                	mov    %eax,%edx
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	eb 09                	jmp    801173 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	eb 05                	jmp    801173 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801173:	89 d0                	mov    %edx,%eax
  801175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	8b 7d 08             	mov    0x8(%ebp),%edi
  801186:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	eb 21                	jmp    8011b1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	89 f0                	mov    %esi,%eax
  801195:	29 d8                	sub    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	03 45 0c             	add    0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	57                   	push   %edi
  80119f:	e8 45 ff ff ff       	call   8010e9 <read>
		if (m < 0)
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 0c                	js     8011b7 <readn+0x3d>
			return m;
		if (m == 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 06                	je     8011b5 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	01 c3                	add    %eax,%ebx
  8011b1:	39 f3                	cmp    %esi,%ebx
  8011b3:	72 db                	jb     801190 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011b5:	89 d8                	mov    %ebx,%eax
}
  8011b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5f                   	pop    %edi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 14             	sub    $0x14,%esp
  8011c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	53                   	push   %ebx
  8011ce:	e8 ad fc ff ff       	call   800e80 <fd_lookup>
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 68                	js     801244 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e6:	ff 30                	pushl  (%eax)
  8011e8:	e8 e9 fc ff ff       	call   800ed6 <dev_lookup>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 47                	js     80123b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fb:	75 21                	jne    80121e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fd:	a1 40 60 80 00       	mov    0x806040,%eax
  801202:	8b 40 48             	mov    0x48(%eax),%eax
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	53                   	push   %ebx
  801209:	50                   	push   %eax
  80120a:	68 29 24 80 00       	push   $0x802429
  80120f:	e8 58 f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121c:	eb 26                	jmp    801244 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801221:	8b 52 0c             	mov    0xc(%edx),%edx
  801224:	85 d2                	test   %edx,%edx
  801226:	74 17                	je     80123f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	ff 75 10             	pushl  0x10(%ebp)
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	50                   	push   %eax
  801232:	ff d2                	call   *%edx
  801234:	89 c2                	mov    %eax,%edx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	eb 09                	jmp    801244 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	eb 05                	jmp    801244 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801244:	89 d0                	mov    %edx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <seek>:

int
seek(int fdnum, off_t offset)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801251:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	ff 75 08             	pushl  0x8(%ebp)
  801258:	e8 23 fc ff ff       	call   800e80 <fd_lookup>
  80125d:	83 c4 08             	add    $0x8,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 0e                	js     801272 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801264:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	53                   	push   %ebx
  801278:	83 ec 14             	sub    $0x14,%esp
  80127b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801281:	50                   	push   %eax
  801282:	53                   	push   %ebx
  801283:	e8 f8 fb ff ff       	call   800e80 <fd_lookup>
  801288:	83 c4 08             	add    $0x8,%esp
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 65                	js     8012f6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801291:	83 ec 08             	sub    $0x8,%esp
  801294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129b:	ff 30                	pushl  (%eax)
  80129d:	e8 34 fc ff ff       	call   800ed6 <dev_lookup>
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 44                	js     8012ed <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b0:	75 21                	jne    8012d3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b2:	a1 40 60 80 00       	mov    0x806040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	53                   	push   %ebx
  8012be:	50                   	push   %eax
  8012bf:	68 ec 23 80 00       	push   $0x8023ec
  8012c4:	e8 a3 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d1:	eb 23                	jmp    8012f6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d6:	8b 52 18             	mov    0x18(%edx),%edx
  8012d9:	85 d2                	test   %edx,%edx
  8012db:	74 14                	je     8012f1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	50                   	push   %eax
  8012e4:	ff d2                	call   *%edx
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	eb 09                	jmp    8012f6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	eb 05                	jmp    8012f6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f6:	89 d0                	mov    %edx,%eax
  8012f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 14             	sub    $0x14,%esp
  801304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 08             	pushl  0x8(%ebp)
  80130e:	e8 6d fb ff ff       	call   800e80 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	89 c2                	mov    %eax,%edx
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 58                	js     801374 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801326:	ff 30                	pushl  (%eax)
  801328:	e8 a9 fb ff ff       	call   800ed6 <dev_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 37                	js     80136b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133b:	74 32                	je     80136f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801340:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801347:	00 00 00 
	stat->st_isdir = 0;
  80134a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801351:	00 00 00 
	stat->st_dev = dev;
  801354:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	53                   	push   %ebx
  80135e:	ff 75 f0             	pushl  -0x10(%ebp)
  801361:	ff 50 14             	call   *0x14(%eax)
  801364:	89 c2                	mov    %eax,%edx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	eb 09                	jmp    801374 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	eb 05                	jmp    801374 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801374:	89 d0                	mov    %edx,%eax
  801376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	56                   	push   %esi
  80137f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	6a 00                	push   $0x0
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 e7 01 00 00       	call   801574 <open>
  80138d:	89 c3                	mov    %eax,%ebx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 db                	test   %ebx,%ebx
  801394:	78 1b                	js     8013b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	ff 75 0c             	pushl  0xc(%ebp)
  80139c:	53                   	push   %ebx
  80139d:	e8 5b ff ff ff       	call   8012fd <fstat>
  8013a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a4:	89 1c 24             	mov    %ebx,(%esp)
  8013a7:	e8 fd fb ff ff       	call   800fa9 <close>
	return r;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	89 f0                	mov    %esi,%eax
}
  8013b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	89 c6                	mov    %eax,%esi
  8013bf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c8:	75 12                	jne    8013dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	6a 03                	push   $0x3
  8013cf:	e8 e6 08 00 00       	call   801cba <ipc_find_env>
  8013d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013dc:	6a 07                	push   $0x7
  8013de:	68 00 70 80 00       	push   $0x807000
  8013e3:	56                   	push   %esi
  8013e4:	ff 35 00 40 80 00    	pushl  0x804000
  8013ea:	e8 7a 08 00 00       	call   801c69 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ef:	83 c4 0c             	add    $0xc,%esp
  8013f2:	6a 00                	push   $0x0
  8013f4:	53                   	push   %ebx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 07 08 00 00       	call   801c03 <ipc_recv>
}
  8013fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	8b 40 0c             	mov    0xc(%eax),%eax
  80140f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801414:	8b 45 0c             	mov    0xc(%ebp),%eax
  801417:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 02 00 00 00       	mov    $0x2,%eax
  801426:	e8 8d ff ff ff       	call   8013b8 <fsipc>
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	8b 40 0c             	mov    0xc(%eax),%eax
  801439:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80143e:	ba 00 00 00 00       	mov    $0x0,%edx
  801443:	b8 06 00 00 00       	mov    $0x6,%eax
  801448:	e8 6b ff ff ff       	call   8013b8 <fsipc>
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 05 00 00 00       	mov    $0x5,%eax
  80146e:	e8 45 ff ff ff       	call   8013b8 <fsipc>
  801473:	89 c2                	mov    %eax,%edx
  801475:	85 d2                	test   %edx,%edx
  801477:	78 2c                	js     8014a5 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	68 00 70 80 00       	push   $0x807000
  801481:	53                   	push   %ebx
  801482:	e8 69 f3 ff ff       	call   8007f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801487:	a1 80 70 80 00       	mov    0x807080,%eax
  80148c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801492:	a1 84 70 80 00       	mov    0x807084,%eax
  801497:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8014b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b9:	89 15 00 70 80 00    	mov    %edx,0x807000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8014bf:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8014c4:	76 05                	jbe    8014cb <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8014c6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8014cb:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(req->req_buf, buf, movesize);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	68 08 70 80 00       	push   $0x807008
  8014dc:	e8 a1 f4 ff ff       	call   800982 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014eb:	e8 c8 fe ff ff       	call   8013b8 <fsipc>
	return write;
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801505:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 03 00 00 00       	mov    $0x3,%eax
  801515:	e8 9e fe ff ff       	call   8013b8 <fsipc>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 4b                	js     80156b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801520:	39 c6                	cmp    %eax,%esi
  801522:	73 16                	jae    80153a <devfile_read+0x48>
  801524:	68 58 24 80 00       	push   $0x802458
  801529:	68 5f 24 80 00       	push   $0x80245f
  80152e:	6a 7c                	push   $0x7c
  801530:	68 74 24 80 00       	push   $0x802474
  801535:	e8 59 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  80153a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153f:	7e 16                	jle    801557 <devfile_read+0x65>
  801541:	68 7f 24 80 00       	push   $0x80247f
  801546:	68 5f 24 80 00       	push   $0x80245f
  80154b:	6a 7d                	push   $0x7d
  80154d:	68 74 24 80 00       	push   $0x802474
  801552:	e8 3c ec ff ff       	call   800193 <_panic>
	memmove(buf, &fsipcbuf, r);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	50                   	push   %eax
  80155b:	68 00 70 80 00       	push   $0x807000
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	e8 1a f4 ff ff       	call   800982 <memmove>
	return r;
  801568:	83 c4 10             	add    $0x10,%esp
}
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 20             	sub    $0x20,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157e:	53                   	push   %ebx
  80157f:	e8 33 f2 ff ff       	call   8007b7 <strlen>
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158c:	7f 67                	jg     8015f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	e8 97 f8 ff ff       	call   800e31 <fd_alloc>
  80159a:	83 c4 10             	add    $0x10,%esp
		return r;
  80159d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 57                	js     8015fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	68 00 70 80 00       	push   $0x807000
  8015ac:	e8 3f f2 ff ff       	call   8007f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c1:	e8 f2 fd ff ff       	call   8013b8 <fsipc>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 14                	jns    8015e3 <open+0x6f>
		fd_close(fd, 0);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	6a 00                	push   $0x0
  8015d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d7:	e8 4d f9 ff ff       	call   800f29 <fd_close>
		return r;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	89 da                	mov    %ebx,%edx
  8015e1:	eb 17                	jmp    8015fa <open+0x86>
	}

	return fd2num(fd);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e9:	e8 1c f8 ff ff       	call   800e0a <fd2num>
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 05                	jmp    8015fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fa:	89 d0                	mov    %edx,%eax
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 08 00 00 00       	mov    $0x8,%eax
  801611:	e8 a2 fd ff ff       	call   8013b8 <fsipc>
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801618:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80161c:	7e 3a                	jle    801658 <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801627:	ff 70 04             	pushl  0x4(%eax)
  80162a:	8d 40 10             	lea    0x10(%eax),%eax
  80162d:	50                   	push   %eax
  80162e:	ff 33                	pushl  (%ebx)
  801630:	e8 8a fb ff ff       	call   8011bf <write>
		if (result > 0)
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	7e 03                	jle    80163f <writebuf+0x27>
			b->result += result;
  80163c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80163f:	39 43 04             	cmp    %eax,0x4(%ebx)
  801642:	74 10                	je     801654 <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  801644:	85 c0                	test   %eax,%eax
  801646:	0f 9f c2             	setg   %dl
  801649:	0f b6 d2             	movzbl %dl,%edx
  80164c:	83 ea 01             	sub    $0x1,%edx
  80164f:	21 d0                	and    %edx,%eax
  801651:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	f3 c3                	repz ret 

0080165a <putch>:

static void
putch(int ch, void *thunk)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801664:	8b 53 04             	mov    0x4(%ebx),%edx
  801667:	8d 42 01             	lea    0x1(%edx),%eax
  80166a:	89 43 04             	mov    %eax,0x4(%ebx)
  80166d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801670:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801674:	3d 00 01 00 00       	cmp    $0x100,%eax
  801679:	75 0e                	jne    801689 <putch+0x2f>
		writebuf(b);
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	e8 96 ff ff ff       	call   801618 <writebuf>
		b->idx = 0;
  801682:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801689:	83 c4 04             	add    $0x4,%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016a1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016a8:	00 00 00 
	b.result = 0;
  8016ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016b2:	00 00 00 
	b.error = 1;
  8016b5:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016bc:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016bf:	ff 75 10             	pushl  0x10(%ebp)
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	68 5a 16 80 00       	push   $0x80165a
  8016d1:	e8 c8 ec ff ff       	call   80039e <vprintfmt>
	if (b.idx > 0)
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016e0:	7e 0b                	jle    8016ed <vfprintf+0x5e>
		writebuf(&b);
  8016e2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016e8:	e8 2b ff ff ff       	call   801618 <writebuf>

	return (b.result ? b.result : b.error);
  8016ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	75 06                	jne    8016fd <vfprintf+0x6e>
  8016f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801705:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801708:	50                   	push   %eax
  801709:	ff 75 0c             	pushl  0xc(%ebp)
  80170c:	ff 75 08             	pushl  0x8(%ebp)
  80170f:	e8 7b ff ff ff       	call   80168f <vfprintf>
	va_end(ap);

	return cnt;
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <printf>:

int
printf(const char *fmt, ...)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80171c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80171f:	50                   	push   %eax
  801720:	ff 75 08             	pushl  0x8(%ebp)
  801723:	6a 01                	push   $0x1
  801725:	e8 65 ff ff ff       	call   80168f <vfprintf>
	va_end(ap);

	return cnt;
}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801734:	83 ec 0c             	sub    $0xc,%esp
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	e8 db f6 ff ff       	call   800e1a <fd2data>
  80173f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801741:	83 c4 08             	add    $0x8,%esp
  801744:	68 8b 24 80 00       	push   $0x80248b
  801749:	53                   	push   %ebx
  80174a:	e8 a1 f0 ff ff       	call   8007f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80174f:	8b 56 04             	mov    0x4(%esi),%edx
  801752:	89 d0                	mov    %edx,%eax
  801754:	2b 06                	sub    (%esi),%eax
  801756:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80175c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801763:	00 00 00 
	stat->st_dev = &devpipe;
  801766:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80176d:	30 80 00 
	return 0;
}
  801770:	b8 00 00 00 00       	mov    $0x0,%eax
  801775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801786:	53                   	push   %ebx
  801787:	6a 00                	push   $0x0
  801789:	e8 f1 f4 ff ff       	call   800c7f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80178e:	89 1c 24             	mov    %ebx,(%esp)
  801791:	e8 84 f6 ff ff       	call   800e1a <fd2data>
  801796:	83 c4 08             	add    $0x8,%esp
  801799:	50                   	push   %eax
  80179a:	6a 00                	push   $0x0
  80179c:	e8 de f4 ff ff       	call   800c7f <sys_page_unmap>
}
  8017a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	57                   	push   %edi
  8017aa:	56                   	push   %esi
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 1c             	sub    $0x1c,%esp
  8017af:	89 c7                	mov    %eax,%edi
  8017b1:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017b3:	a1 40 60 80 00       	mov    0x806040,%eax
  8017b8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	57                   	push   %edi
  8017bf:	e8 2e 05 00 00       	call   801cf2 <pageref>
  8017c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017c7:	89 34 24             	mov    %esi,(%esp)
  8017ca:	e8 23 05 00 00       	call   801cf2 <pageref>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017d5:	0f 94 c0             	sete   %al
  8017d8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017db:	8b 15 40 60 80 00    	mov    0x806040,%edx
  8017e1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017e4:	39 cb                	cmp    %ecx,%ebx
  8017e6:	74 15                	je     8017fd <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8017e8:	8b 52 58             	mov    0x58(%edx),%edx
  8017eb:	50                   	push   %eax
  8017ec:	52                   	push   %edx
  8017ed:	53                   	push   %ebx
  8017ee:	68 98 24 80 00       	push   $0x802498
  8017f3:	e8 74 ea ff ff       	call   80026c <cprintf>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	eb b6                	jmp    8017b3 <_pipeisclosed+0xd>
	}
}
  8017fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5f                   	pop    %edi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	57                   	push   %edi
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	83 ec 28             	sub    $0x28,%esp
  80180e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801811:	56                   	push   %esi
  801812:	e8 03 f6 ff ff       	call   800e1a <fd2data>
  801817:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	bf 00 00 00 00       	mov    $0x0,%edi
  801821:	eb 4b                	jmp    80186e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801823:	89 da                	mov    %ebx,%edx
  801825:	89 f0                	mov    %esi,%eax
  801827:	e8 7a ff ff ff       	call   8017a6 <_pipeisclosed>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	75 48                	jne    801878 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801830:	e8 a6 f3 ff ff       	call   800bdb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801835:	8b 43 04             	mov    0x4(%ebx),%eax
  801838:	8b 0b                	mov    (%ebx),%ecx
  80183a:	8d 51 20             	lea    0x20(%ecx),%edx
  80183d:	39 d0                	cmp    %edx,%eax
  80183f:	73 e2                	jae    801823 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801844:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801848:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	c1 fa 1f             	sar    $0x1f,%edx
  801850:	89 d1                	mov    %edx,%ecx
  801852:	c1 e9 1b             	shr    $0x1b,%ecx
  801855:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801858:	83 e2 1f             	and    $0x1f,%edx
  80185b:	29 ca                	sub    %ecx,%edx
  80185d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801861:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801865:	83 c0 01             	add    $0x1,%eax
  801868:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186b:	83 c7 01             	add    $0x1,%edi
  80186e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801871:	75 c2                	jne    801835 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801873:	8b 45 10             	mov    0x10(%ebp),%eax
  801876:	eb 05                	jmp    80187d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801878:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80187d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	57                   	push   %edi
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	83 ec 18             	sub    $0x18,%esp
  80188e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801891:	57                   	push   %edi
  801892:	e8 83 f5 ff ff       	call   800e1a <fd2data>
  801897:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a1:	eb 3d                	jmp    8018e0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018a3:	85 db                	test   %ebx,%ebx
  8018a5:	74 04                	je     8018ab <devpipe_read+0x26>
				return i;
  8018a7:	89 d8                	mov    %ebx,%eax
  8018a9:	eb 44                	jmp    8018ef <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018ab:	89 f2                	mov    %esi,%edx
  8018ad:	89 f8                	mov    %edi,%eax
  8018af:	e8 f2 fe ff ff       	call   8017a6 <_pipeisclosed>
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	75 32                	jne    8018ea <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018b8:	e8 1e f3 ff ff       	call   800bdb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018bd:	8b 06                	mov    (%esi),%eax
  8018bf:	3b 46 04             	cmp    0x4(%esi),%eax
  8018c2:	74 df                	je     8018a3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018c4:	99                   	cltd   
  8018c5:	c1 ea 1b             	shr    $0x1b,%edx
  8018c8:	01 d0                	add    %edx,%eax
  8018ca:	83 e0 1f             	and    $0x1f,%eax
  8018cd:	29 d0                	sub    %edx,%eax
  8018cf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018da:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018dd:	83 c3 01             	add    $0x1,%ebx
  8018e0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018e3:	75 d8                	jne    8018bd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e8:	eb 05                	jmp    8018ef <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5f                   	pop    %edi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	e8 29 f5 ff ff       	call   800e31 <fd_alloc>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	85 c0                	test   %eax,%eax
  80190f:	0f 88 2c 01 00 00    	js     801a41 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	68 07 04 00 00       	push   $0x407
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	6a 00                	push   $0x0
  801922:	e8 d3 f2 ff ff       	call   800bfa <sys_page_alloc>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	85 c0                	test   %eax,%eax
  80192e:	0f 88 0d 01 00 00    	js     801a41 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193a:	50                   	push   %eax
  80193b:	e8 f1 f4 ff ff       	call   800e31 <fd_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	0f 88 e2 00 00 00    	js     801a2f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194d:	83 ec 04             	sub    $0x4,%esp
  801950:	68 07 04 00 00       	push   $0x407
  801955:	ff 75 f0             	pushl  -0x10(%ebp)
  801958:	6a 00                	push   $0x0
  80195a:	e8 9b f2 ff ff       	call   800bfa <sys_page_alloc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 88 c3 00 00 00    	js     801a2f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	e8 a3 f4 ff ff       	call   800e1a <fd2data>
  801977:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801979:	83 c4 0c             	add    $0xc,%esp
  80197c:	68 07 04 00 00       	push   $0x407
  801981:	50                   	push   %eax
  801982:	6a 00                	push   $0x0
  801984:	e8 71 f2 ff ff       	call   800bfa <sys_page_alloc>
  801989:	89 c3                	mov    %eax,%ebx
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	0f 88 89 00 00 00    	js     801a1f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff 75 f0             	pushl  -0x10(%ebp)
  80199c:	e8 79 f4 ff ff       	call   800e1a <fd2data>
  8019a1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a8:	50                   	push   %eax
  8019a9:	6a 00                	push   $0x0
  8019ab:	56                   	push   %esi
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 8a f2 ff ff       	call   800c3d <sys_page_map>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 20             	add    $0x20,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 55                	js     801a11 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019bc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019da:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019df:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ec:	e8 19 f4 ff ff       	call   800e0a <fd2num>
  8019f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019f6:	83 c4 04             	add    $0x4,%esp
  8019f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fc:	e8 09 f4 ff ff       	call   800e0a <fd2num>
  801a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a04:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0f:	eb 30                	jmp    801a41 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	56                   	push   %esi
  801a15:	6a 00                	push   $0x0
  801a17:	e8 63 f2 ff ff       	call   800c7f <sys_page_unmap>
  801a1c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	ff 75 f0             	pushl  -0x10(%ebp)
  801a25:	6a 00                	push   $0x0
  801a27:	e8 53 f2 ff ff       	call   800c7f <sys_page_unmap>
  801a2c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	ff 75 f4             	pushl  -0xc(%ebp)
  801a35:	6a 00                	push   $0x0
  801a37:	e8 43 f2 ff ff       	call   800c7f <sys_page_unmap>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a41:	89 d0                	mov    %edx,%eax
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	e8 24 f4 ff ff       	call   800e80 <fd_lookup>
  801a5c:	89 c2                	mov    %eax,%edx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 d2                	test   %edx,%edx
  801a63:	78 18                	js     801a7d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6b:	e8 aa f3 ff ff       	call   800e1a <fd2data>
	return _pipeisclosed(fd, p);
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a75:	e8 2c fd ff ff       	call   8017a6 <_pipeisclosed>
  801a7a:	83 c4 10             	add    $0x10,%esp
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a82:	b8 00 00 00 00       	mov    $0x0,%eax
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a8f:	68 cc 24 80 00       	push   $0x8024cc
  801a94:	ff 75 0c             	pushl  0xc(%ebp)
  801a97:	e8 54 ed ff ff       	call   8007f0 <strcpy>
	return 0;
}
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aaf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ab4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aba:	eb 2e                	jmp    801aea <devcons_write+0x47>
		m = n - tot;
  801abc:	8b 55 10             	mov    0x10(%ebp),%edx
  801abf:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801ac1:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801ac6:	83 fa 7f             	cmp    $0x7f,%edx
  801ac9:	77 02                	ja     801acd <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801acb:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	56                   	push   %esi
  801ad1:	03 45 0c             	add    0xc(%ebp),%eax
  801ad4:	50                   	push   %eax
  801ad5:	57                   	push   %edi
  801ad6:	e8 a7 ee ff ff       	call   800982 <memmove>
		sys_cputs(buf, m);
  801adb:	83 c4 08             	add    $0x8,%esp
  801ade:	56                   	push   %esi
  801adf:	57                   	push   %edi
  801ae0:	e8 59 f0 ff ff       	call   800b3e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ae5:	01 f3                	add    %esi,%ebx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	89 d8                	mov    %ebx,%eax
  801aec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aef:	72 cb                	jb     801abc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5f                   	pop    %edi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801b04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b08:	75 07                	jne    801b11 <devcons_read+0x18>
  801b0a:	eb 28                	jmp    801b34 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b0c:	e8 ca f0 ff ff       	call   800bdb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b11:	e8 46 f0 ff ff       	call   800b5c <sys_cgetc>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	74 f2                	je     801b0c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 16                	js     801b34 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b1e:	83 f8 04             	cmp    $0x4,%eax
  801b21:	74 0c                	je     801b2f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b26:	88 02                	mov    %al,(%edx)
	return 1;
  801b28:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2d:	eb 05                	jmp    801b34 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b42:	6a 01                	push   $0x1
  801b44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	e8 f1 ef ff ff       	call   800b3e <sys_cputs>
  801b4d:	83 c4 10             	add    $0x10,%esp
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <getchar>:

int
getchar(void)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b58:	6a 01                	push   $0x1
  801b5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 84 f5 ff ff       	call   8010e9 <read>
	if (r < 0)
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 0f                	js     801b7b <getchar+0x29>
		return r;
	if (r < 1)
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	7e 06                	jle    801b76 <getchar+0x24>
		return -E_EOF;
	return c;
  801b70:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b74:	eb 05                	jmp    801b7b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b76:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b86:	50                   	push   %eax
  801b87:	ff 75 08             	pushl  0x8(%ebp)
  801b8a:	e8 f1 f2 ff ff       	call   800e80 <fd_lookup>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	78 11                	js     801ba7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b99:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b9f:	39 10                	cmp    %edx,(%eax)
  801ba1:	0f 94 c0             	sete   %al
  801ba4:	0f b6 c0             	movzbl %al,%eax
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <opencons>:

int
opencons(void)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801baf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb2:	50                   	push   %eax
  801bb3:	e8 79 f2 ff ff       	call   800e31 <fd_alloc>
  801bb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801bbb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 3e                	js     801bff <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	68 07 04 00 00       	push   $0x407
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 27 f0 ff ff       	call   800bfa <sys_page_alloc>
  801bd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 23                	js     801bff <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bdc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	50                   	push   %eax
  801bf5:	e8 10 f2 ff ff       	call   800e0a <fd2num>
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	83 c4 10             	add    $0x10,%esp
}
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801c11:	85 f6                	test   %esi,%esi
  801c13:	74 06                	je     801c1b <ipc_recv+0x18>
  801c15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801c1b:	85 db                	test   %ebx,%ebx
  801c1d:	74 06                	je     801c25 <ipc_recv+0x22>
  801c1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801c25:	83 f8 01             	cmp    $0x1,%eax
  801c28:	19 d2                	sbb    %edx,%edx
  801c2a:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801c2c:	83 ec 0c             	sub    $0xc,%esp
  801c2f:	50                   	push   %eax
  801c30:	e8 75 f1 ff ff       	call   800daa <sys_ipc_recv>
  801c35:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 d2                	test   %edx,%edx
  801c3c:	75 24                	jne    801c62 <ipc_recv+0x5f>
	if (from_env_store)
  801c3e:	85 f6                	test   %esi,%esi
  801c40:	74 0a                	je     801c4c <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801c42:	a1 40 60 80 00       	mov    0x806040,%eax
  801c47:	8b 40 70             	mov    0x70(%eax),%eax
  801c4a:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801c4c:	85 db                	test   %ebx,%ebx
  801c4e:	74 0a                	je     801c5a <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801c50:	a1 40 60 80 00       	mov    0x806040,%eax
  801c55:	8b 40 74             	mov    0x74(%eax),%eax
  801c58:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801c5a:	a1 40 60 80 00       	mov    0x806040,%eax
  801c5f:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801c62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	57                   	push   %edi
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801c7b:	83 fb 01             	cmp    $0x1,%ebx
  801c7e:	19 c0                	sbb    %eax,%eax
  801c80:	09 c3                	or     %eax,%ebx
  801c82:	eb 1c                	jmp    801ca0 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801c84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c87:	74 12                	je     801c9b <ipc_send+0x32>
  801c89:	50                   	push   %eax
  801c8a:	68 d8 24 80 00       	push   $0x8024d8
  801c8f:	6a 36                	push   $0x36
  801c91:	68 ef 24 80 00       	push   $0x8024ef
  801c96:	e8 f8 e4 ff ff       	call   800193 <_panic>
		sys_yield();
  801c9b:	e8 3b ef ff ff       	call   800bdb <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ca0:	ff 75 14             	pushl  0x14(%ebp)
  801ca3:	53                   	push   %ebx
  801ca4:	56                   	push   %esi
  801ca5:	57                   	push   %edi
  801ca6:	e8 dc f0 ff ff       	call   800d87 <sys_ipc_try_send>
		if (ret == 0) break;
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	75 d2                	jne    801c84 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc5:	6b d0 78             	imul   $0x78,%eax,%edx
  801cc8:	83 c2 50             	add    $0x50,%edx
  801ccb:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801cd1:	39 ca                	cmp    %ecx,%edx
  801cd3:	75 0d                	jne    801ce2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cd5:	6b c0 78             	imul   $0x78,%eax,%eax
  801cd8:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801cdd:	8b 40 08             	mov    0x8(%eax),%eax
  801ce0:	eb 0e                	jmp    801cf0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ce2:	83 c0 01             	add    $0x1,%eax
  801ce5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cea:	75 d9                	jne    801cc5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cec:	66 b8 00 00          	mov    $0x0,%ax
}
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cf8:	89 d0                	mov    %edx,%eax
  801cfa:	c1 e8 16             	shr    $0x16,%eax
  801cfd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d09:	f6 c1 01             	test   $0x1,%cl
  801d0c:	74 1d                	je     801d2b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d0e:	c1 ea 0c             	shr    $0xc,%edx
  801d11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d18:	f6 c2 01             	test   $0x1,%dl
  801d1b:	74 0e                	je     801d2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d1d:	c1 ea 0c             	shr    $0xc,%edx
  801d20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d27:	ef 
  801d28:	0f b7 c0             	movzwl %ax,%eax
}
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    
  801d2d:	66 90                	xchg   %ax,%ax
  801d2f:	90                   	nop

00801d30 <__udivdi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	83 ec 10             	sub    $0x10,%esp
  801d36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801d3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801d42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d46:	85 d2                	test   %edx,%edx
  801d48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d4c:	89 34 24             	mov    %esi,(%esp)
  801d4f:	89 c8                	mov    %ecx,%eax
  801d51:	75 35                	jne    801d88 <__udivdi3+0x58>
  801d53:	39 f1                	cmp    %esi,%ecx
  801d55:	0f 87 bd 00 00 00    	ja     801e18 <__udivdi3+0xe8>
  801d5b:	85 c9                	test   %ecx,%ecx
  801d5d:	89 cd                	mov    %ecx,%ebp
  801d5f:	75 0b                	jne    801d6c <__udivdi3+0x3c>
  801d61:	b8 01 00 00 00       	mov    $0x1,%eax
  801d66:	31 d2                	xor    %edx,%edx
  801d68:	f7 f1                	div    %ecx
  801d6a:	89 c5                	mov    %eax,%ebp
  801d6c:	89 f0                	mov    %esi,%eax
  801d6e:	31 d2                	xor    %edx,%edx
  801d70:	f7 f5                	div    %ebp
  801d72:	89 c6                	mov    %eax,%esi
  801d74:	89 f8                	mov    %edi,%eax
  801d76:	f7 f5                	div    %ebp
  801d78:	89 f2                	mov    %esi,%edx
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    
  801d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d88:	3b 14 24             	cmp    (%esp),%edx
  801d8b:	77 7b                	ja     801e08 <__udivdi3+0xd8>
  801d8d:	0f bd f2             	bsr    %edx,%esi
  801d90:	83 f6 1f             	xor    $0x1f,%esi
  801d93:	0f 84 97 00 00 00    	je     801e30 <__udivdi3+0x100>
  801d99:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d9e:	89 d7                	mov    %edx,%edi
  801da0:	89 f1                	mov    %esi,%ecx
  801da2:	29 f5                	sub    %esi,%ebp
  801da4:	d3 e7                	shl    %cl,%edi
  801da6:	89 c2                	mov    %eax,%edx
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	d3 ea                	shr    %cl,%edx
  801dac:	89 f1                	mov    %esi,%ecx
  801dae:	09 fa                	or     %edi,%edx
  801db0:	8b 3c 24             	mov    (%esp),%edi
  801db3:	d3 e0                	shl    %cl,%eax
  801db5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dc3:	89 fa                	mov    %edi,%edx
  801dc5:	d3 ea                	shr    %cl,%edx
  801dc7:	89 f1                	mov    %esi,%ecx
  801dc9:	d3 e7                	shl    %cl,%edi
  801dcb:	89 e9                	mov    %ebp,%ecx
  801dcd:	d3 e8                	shr    %cl,%eax
  801dcf:	09 c7                	or     %eax,%edi
  801dd1:	89 f8                	mov    %edi,%eax
  801dd3:	f7 74 24 08          	divl   0x8(%esp)
  801dd7:	89 d5                	mov    %edx,%ebp
  801dd9:	89 c7                	mov    %eax,%edi
  801ddb:	f7 64 24 0c          	mull   0xc(%esp)
  801ddf:	39 d5                	cmp    %edx,%ebp
  801de1:	89 14 24             	mov    %edx,(%esp)
  801de4:	72 11                	jb     801df7 <__udivdi3+0xc7>
  801de6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dea:	89 f1                	mov    %esi,%ecx
  801dec:	d3 e2                	shl    %cl,%edx
  801dee:	39 c2                	cmp    %eax,%edx
  801df0:	73 5e                	jae    801e50 <__udivdi3+0x120>
  801df2:	3b 2c 24             	cmp    (%esp),%ebp
  801df5:	75 59                	jne    801e50 <__udivdi3+0x120>
  801df7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801dfa:	31 f6                	xor    %esi,%esi
  801dfc:	89 f2                	mov    %esi,%edx
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	5e                   	pop    %esi
  801e02:	5f                   	pop    %edi
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    
  801e05:	8d 76 00             	lea    0x0(%esi),%esi
  801e08:	31 f6                	xor    %esi,%esi
  801e0a:	31 c0                	xor    %eax,%eax
  801e0c:	89 f2                	mov    %esi,%edx
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	5e                   	pop    %esi
  801e12:	5f                   	pop    %edi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    
  801e15:	8d 76 00             	lea    0x0(%esi),%esi
  801e18:	89 f2                	mov    %esi,%edx
  801e1a:	31 f6                	xor    %esi,%esi
  801e1c:	89 f8                	mov    %edi,%eax
  801e1e:	f7 f1                	div    %ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e34:	76 0b                	jbe    801e41 <__udivdi3+0x111>
  801e36:	31 c0                	xor    %eax,%eax
  801e38:	3b 14 24             	cmp    (%esp),%edx
  801e3b:	0f 83 37 ff ff ff    	jae    801d78 <__udivdi3+0x48>
  801e41:	b8 01 00 00 00       	mov    $0x1,%eax
  801e46:	e9 2d ff ff ff       	jmp    801d78 <__udivdi3+0x48>
  801e4b:	90                   	nop
  801e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e50:	89 f8                	mov    %edi,%eax
  801e52:	31 f6                	xor    %esi,%esi
  801e54:	e9 1f ff ff ff       	jmp    801d78 <__udivdi3+0x48>
  801e59:	66 90                	xchg   %ax,%ax
  801e5b:	66 90                	xchg   %ax,%ax
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 20             	sub    $0x20,%esp
  801e66:	8b 44 24 34          	mov    0x34(%esp),%eax
  801e6a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e6e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e72:	89 c6                	mov    %eax,%esi
  801e74:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e7c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801e80:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e84:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e88:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	89 c2                	mov    %eax,%edx
  801e90:	75 1e                	jne    801eb0 <__umoddi3+0x50>
  801e92:	39 f7                	cmp    %esi,%edi
  801e94:	76 52                	jbe    801ee8 <__umoddi3+0x88>
  801e96:	89 c8                	mov    %ecx,%eax
  801e98:	89 f2                	mov    %esi,%edx
  801e9a:	f7 f7                	div    %edi
  801e9c:	89 d0                	mov    %edx,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	83 c4 20             	add    $0x20,%esp
  801ea3:	5e                   	pop    %esi
  801ea4:	5f                   	pop    %edi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    
  801ea7:	89 f6                	mov    %esi,%esi
  801ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801eb0:	39 f0                	cmp    %esi,%eax
  801eb2:	77 5c                	ja     801f10 <__umoddi3+0xb0>
  801eb4:	0f bd e8             	bsr    %eax,%ebp
  801eb7:	83 f5 1f             	xor    $0x1f,%ebp
  801eba:	75 64                	jne    801f20 <__umoddi3+0xc0>
  801ebc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ec0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ec4:	0f 86 f6 00 00 00    	jbe    801fc0 <__umoddi3+0x160>
  801eca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801ece:	0f 82 ec 00 00 00    	jb     801fc0 <__umoddi3+0x160>
  801ed4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801edc:	83 c4 20             	add    $0x20,%esp
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
  801ee3:	90                   	nop
  801ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	85 ff                	test   %edi,%edi
  801eea:	89 fd                	mov    %edi,%ebp
  801eec:	75 0b                	jne    801ef9 <__umoddi3+0x99>
  801eee:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef3:	31 d2                	xor    %edx,%edx
  801ef5:	f7 f7                	div    %edi
  801ef7:	89 c5                	mov    %eax,%ebp
  801ef9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801efd:	31 d2                	xor    %edx,%edx
  801eff:	f7 f5                	div    %ebp
  801f01:	89 c8                	mov    %ecx,%eax
  801f03:	f7 f5                	div    %ebp
  801f05:	eb 95                	jmp    801e9c <__umoddi3+0x3c>
  801f07:	89 f6                	mov    %esi,%esi
  801f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 f2                	mov    %esi,%edx
  801f14:	83 c4 20             	add    $0x20,%esp
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    
  801f1b:	90                   	nop
  801f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f20:	b8 20 00 00 00       	mov    $0x20,%eax
  801f25:	89 e9                	mov    %ebp,%ecx
  801f27:	29 e8                	sub    %ebp,%eax
  801f29:	d3 e2                	shl    %cl,%edx
  801f2b:	89 c7                	mov    %eax,%edi
  801f2d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 c1                	mov    %eax,%ecx
  801f3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f3f:	09 d1                	or     %edx,%ecx
  801f41:	89 fa                	mov    %edi,%edx
  801f43:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f47:	89 e9                	mov    %ebp,%ecx
  801f49:	d3 e0                	shl    %cl,%eax
  801f4b:	89 f9                	mov    %edi,%ecx
  801f4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	d3 e8                	shr    %cl,%eax
  801f55:	89 e9                	mov    %ebp,%ecx
  801f57:	89 c7                	mov    %eax,%edi
  801f59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f5d:	d3 e6                	shl    %cl,%esi
  801f5f:	89 d1                	mov    %edx,%ecx
  801f61:	89 fa                	mov    %edi,%edx
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	89 e9                	mov    %ebp,%ecx
  801f67:	09 f0                	or     %esi,%eax
  801f69:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801f6d:	f7 74 24 10          	divl   0x10(%esp)
  801f71:	d3 e6                	shl    %cl,%esi
  801f73:	89 d1                	mov    %edx,%ecx
  801f75:	f7 64 24 0c          	mull   0xc(%esp)
  801f79:	39 d1                	cmp    %edx,%ecx
  801f7b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801f7f:	89 d7                	mov    %edx,%edi
  801f81:	89 c6                	mov    %eax,%esi
  801f83:	72 0a                	jb     801f8f <__umoddi3+0x12f>
  801f85:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801f89:	73 10                	jae    801f9b <__umoddi3+0x13b>
  801f8b:	39 d1                	cmp    %edx,%ecx
  801f8d:	75 0c                	jne    801f9b <__umoddi3+0x13b>
  801f8f:	89 d7                	mov    %edx,%edi
  801f91:	89 c6                	mov    %eax,%esi
  801f93:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801f97:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801f9b:	89 ca                	mov    %ecx,%edx
  801f9d:	89 e9                	mov    %ebp,%ecx
  801f9f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fa3:	29 f0                	sub    %esi,%eax
  801fa5:	19 fa                	sbb    %edi,%edx
  801fa7:	d3 e8                	shr    %cl,%eax
  801fa9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801fae:	89 d7                	mov    %edx,%edi
  801fb0:	d3 e7                	shl    %cl,%edi
  801fb2:	89 e9                	mov    %ebp,%ecx
  801fb4:	09 f8                	or     %edi,%eax
  801fb6:	d3 ea                	shr    %cl,%edx
  801fb8:	83 c4 20             	add    $0x20,%esp
  801fbb:	5e                   	pop    %esi
  801fbc:	5f                   	pop    %edi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop
  801fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801fc4:	29 f9                	sub    %edi,%ecx
  801fc6:	19 c6                	sbb    %eax,%esi
  801fc8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801fcc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801fd0:	e9 ff fe ff ff       	jmp    801ed4 <__umoddi3+0x74>
