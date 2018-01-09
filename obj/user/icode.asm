
obj/user/icode:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8024c0,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 24 80 00       	push   $0x8024c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 24 80 00       	push   $0x8024e8
  800068:	e8 08 15 00 00       	call   801575 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %i", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 24 80 00       	push   $0x8024ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 25 80 00       	push   $0x802504
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 25 80 00       	push   $0x802511
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 95 0a 00 00       	call   800b3f <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %i", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 2e 10 00 00       	call   8010ea <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 25 80 00       	push   $0x802524
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 d2 0e 00 00       	call   800faa <close>

	{
		int r;
		cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
		if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 25 80 00       	push   $0x80254c
  8000f0:	68 55 25 80 00       	push   $0x802555
  8000f5:	68 5f 25 80 00       	push   $0x80255f
  8000fa:	68 5e 25 80 00       	push   $0x80255e
  8000ff:	e8 6c 1a 00 00       	call   801b70 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
			panic("icode: spawn /init: %i", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 25 80 00       	push   $0x802564
  800111:	6a 1c                	push   $0x1c
  800113:	68 04 25 80 00       	push   $0x802504
  800118:	e8 77 00 00 00       	call   800194 <_panic>
	}

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 25 80 00       	push   $0x80257b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
  80012a:	83 c4 10             	add    $0x10,%esp
}
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80013f:	e8 79 0a 00 00       	call   800bbd <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 78             	imul   $0x78,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
  800170:	83 c4 10             	add    $0x10,%esp
#endif
}
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 52 0e 00 00       	call   800fd7 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 ed 09 00 00       	call   800b7c <sys_env_destroy>
  80018f:	83 c4 10             	add    $0x10,%esp
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 16 0a 00 00       	call   800bbd <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 25 80 00       	push   $0x802598
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 22 25 80 00 	movl   $0x802522,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 35 09 00 00       	call   800b3f <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 4f 01 00 00       	call   80039f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 da 08 00 00       	call   800b3f <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 d1                	mov    %edx,%ecx
  800296:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800299:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ac:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002af:	72 05                	jb     8002b6 <printnum+0x35>
  8002b1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002b4:	77 3e                	ja     8002f4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	ff 75 18             	pushl  0x18(%ebp)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	53                   	push   %ebx
  8002c0:	50                   	push   %eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 1b 1f 00 00       	call   8021f0 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 13                	jmp    8002fb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f4:	83 eb 01             	sub    $0x1,%ebx
  8002f7:	85 db                	test   %ebx,%ebx
  8002f9:	7f ed                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	83 ec 04             	sub    $0x4,%esp
  800302:	ff 75 e4             	pushl  -0x1c(%ebp)
  800305:	ff 75 e0             	pushl  -0x20(%ebp)
  800308:	ff 75 dc             	pushl  -0x24(%ebp)
  80030b:	ff 75 d8             	pushl  -0x28(%ebp)
  80030e:	e8 0d 20 00 00       	call   802320 <__umoddi3>
  800313:	83 c4 14             	add    $0x14,%esp
  800316:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  80031d:	50                   	push   %eax
  80031e:	ff d7                	call   *%edi
  800320:	83 c4 10             	add    $0x10,%esp
}
  800323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032e:	83 fa 01             	cmp    $0x1,%edx
  800331:	7e 0e                	jle    800341 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800333:	8b 10                	mov    (%eax),%edx
  800335:	8d 4a 08             	lea    0x8(%edx),%ecx
  800338:	89 08                	mov    %ecx,(%eax)
  80033a:	8b 02                	mov    (%edx),%eax
  80033c:	8b 52 04             	mov    0x4(%edx),%edx
  80033f:	eb 22                	jmp    800363 <getuint+0x38>
	else if (lflag)
  800341:	85 d2                	test   %edx,%edx
  800343:	74 10                	je     800355 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800345:	8b 10                	mov    (%eax),%edx
  800347:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034a:	89 08                	mov    %ecx,(%eax)
  80034c:	8b 02                	mov    (%edx),%eax
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	eb 0e                	jmp    800363 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	3b 50 04             	cmp    0x4(%eax),%edx
  800374:	73 0a                	jae    800380 <sprintputch+0x1b>
		*b->buf++ = ch;
  800376:	8d 4a 01             	lea    0x1(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	88 02                	mov    %al,(%edx)
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038b:	50                   	push   %eax
  80038c:	ff 75 10             	pushl  0x10(%ebp)
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	ff 75 08             	pushl  0x8(%ebp)
  800395:	e8 05 00 00 00       	call   80039f <vprintfmt>
	va_end(ap);
  80039a:	83 c4 10             	add    $0x10,%esp
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 2c             	sub    $0x2c,%esp
  8003a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b1:	eb 12                	jmp    8003c5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b3:	85 c0                	test   %eax,%eax
  8003b5:	0f 84 8d 03 00 00    	je     800748 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	53                   	push   %ebx
  8003bf:	50                   	push   %eax
  8003c0:	ff d6                	call   *%esi
  8003c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	83 c7 01             	add    $0x1,%edi
  8003c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003cc:	83 f8 25             	cmp    $0x25,%eax
  8003cf:	75 e2                	jne    8003b3 <vprintfmt+0x14>
  8003d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	eb 07                	jmp    8003f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8d 47 01             	lea    0x1(%edi),%eax
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fe:	0f b6 07             	movzbl (%edi),%eax
  800401:	0f b6 c8             	movzbl %al,%ecx
  800404:	83 e8 23             	sub    $0x23,%eax
  800407:	3c 55                	cmp    $0x55,%al
  800409:	0f 87 1e 03 00 00    	ja     80072d <vprintfmt+0x38e>
  80040f:	0f b6 c0             	movzbl %al,%eax
  800412:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800420:	eb d6                	jmp    8003f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800430:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800434:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800437:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043a:	83 fa 09             	cmp    $0x9,%edx
  80043d:	77 38                	ja     800477 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800442:	eb e9                	jmp    80042d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 48 04             	lea    0x4(%eax),%ecx
  80044a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800455:	eb 26                	jmp    80047d <vprintfmt+0xde>
  800457:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045a:	89 c8                	mov    %ecx,%eax
  80045c:	c1 f8 1f             	sar    $0x1f,%eax
  80045f:	f7 d0                	not    %eax
  800461:	21 c1                	and    %eax,%ecx
  800463:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	eb 8d                	jmp    8003f8 <vprintfmt+0x59>
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800475:	eb 81                	jmp    8003f8 <vprintfmt+0x59>
  800477:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800481:	0f 89 71 ff ff ff    	jns    8003f8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800487:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800494:	e9 5f ff ff ff       	jmp    8003f8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800499:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049f:	e9 54 ff ff ff       	jmp    8003f8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	ff 30                	pushl  (%eax)
  8004b3:	ff d6                	call   *%esi
			break;
  8004b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bb:	e9 05 ff ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	99                   	cltd   
  8004cc:	31 d0                	xor    %edx,%eax
  8004ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 0f             	cmp    $0xf,%eax
  8004d3:	7f 0b                	jg     8004e0 <vprintfmt+0x141>
  8004d5:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	75 18                	jne    8004f8 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	50                   	push   %eax
  8004e1:	68 d3 25 80 00       	push   $0x8025d3
  8004e6:	53                   	push   %ebx
  8004e7:	56                   	push   %esi
  8004e8:	e8 95 fe ff ff       	call   800382 <printfmt>
  8004ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 cd fe ff ff       	jmp    8003c5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	52                   	push   %edx
  8004f9:	68 b1 29 80 00       	push   $0x8029b1
  8004fe:	53                   	push   %ebx
  8004ff:	56                   	push   %esi
  800500:	e8 7d fe ff ff       	call   800382 <printfmt>
  800505:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050b:	e9 b5 fe ff ff       	jmp    8003c5 <vprintfmt+0x26>
  800510:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800516:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 38                	mov    (%eax),%edi
  800524:	85 ff                	test   %edi,%edi
  800526:	75 05                	jne    80052d <vprintfmt+0x18e>
				p = "(null)";
  800528:	bf cc 25 80 00       	mov    $0x8025cc,%edi
			if (width > 0 && padc != '-')
  80052d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800531:	0f 84 91 00 00 00    	je     8005c8 <vprintfmt+0x229>
  800537:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80053b:	0f 8e 95 00 00 00    	jle    8005d6 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	51                   	push   %ecx
  800545:	57                   	push   %edi
  800546:	e8 85 02 00 00       	call   8007d0 <strnlen>
  80054b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c5>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057d:	89 c8                	mov    %ecx,%eax
  80057f:	c1 f8 1f             	sar    $0x1f,%eax
  800582:	f7 d0                	not    %eax
  800584:	21 c8                	and    %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x217>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x217>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x243>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x243>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x274>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f6>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f6>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x27c>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 9e fd ff ff       	jmp    8003c5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d5>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800683:	79 74                	jns    8006f9 <vprintfmt+0x35a>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800690:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800693:	f7 d8                	neg    %eax
  800695:	83 d2 00             	adc    $0x0,%edx
  800698:	f7 da                	neg    %edx
  80069a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a2:	eb 55                	jmp    8006f9 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 7f fc ff ff       	call   80032b <getuint>
			base = 10;
  8006ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b1:	eb 46                	jmp    8006f9 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 70 fc ff ff       	call   80032b <getuint>
			base = 8;
  8006bb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c0:	eb 37                	jmp    8006f9 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 30                	push   $0x30
  8006c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 78                	push   $0x78
  8006d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ea:	eb 0d                	jmp    8006f9 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 37 fc ff ff       	call   80032b <getuint>
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800700:	57                   	push   %edi
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	51                   	push   %ecx
  800705:	52                   	push   %edx
  800706:	50                   	push   %eax
  800707:	89 da                	mov    %ebx,%edx
  800709:	89 f0                	mov    %esi,%eax
  80070b:	e8 71 fb ff ff       	call   800281 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800716:	e9 aa fc ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	51                   	push   %ecx
  800720:	ff d6                	call   *%esi
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 98 fc ff ff       	jmp    8003c5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 25                	push   $0x25
  800733:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 03                	jmp    80073d <vprintfmt+0x39e>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800741:	75 f7                	jne    80073a <vprintfmt+0x39b>
  800743:	e9 7d fc ff ff       	jmp    8003c5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 65 03 80 00       	push   $0x800365
  800784:	e8 16 fc ff ff       	call   80039f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 05                	jmp    80079c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 c2                	cmp    %eax,%edx
  8007e5:	74 08                	je     8007ef <strnlen+0x1f>
  8007e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
  8007ed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ef                	jne    8007fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800818:	53                   	push   %ebx
  800819:	e8 9a ff ff ff       	call   8007b8 <strlen>
  80081e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	50                   	push   %eax
  800827:	e8 c5 ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	89 f3                	mov    %esi,%ebx
  800840:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	89 f2                	mov    %esi,%edx
  800845:	eb 0f                	jmp    800856 <strncpy+0x23>
		*dst++ = *src;
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800850:	80 39 01             	cmpb   $0x1,(%ecx)
  800853:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	39 da                	cmp    %ebx,%edx
  800858:	75 ed                	jne    800847 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
  80086e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 d2                	test   %edx,%edx
  800872:	74 21                	je     800895 <strlcpy+0x35>
  800874:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800878:	89 f2                	mov    %esi,%edx
  80087a:	eb 09                	jmp    800885 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 09                	je     800892 <strlcpy+0x32>
  800889:	0f b6 19             	movzbl (%ecx),%ebx
  80088c:	84 db                	test   %bl,%bl
  80088e:	75 ec                	jne    80087c <strlcpy+0x1c>
  800890:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800895:	29 f0                	sub    %esi,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strcmp+0x11>
		p++, q++;
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	84 c0                	test   %al,%al
  8008b1:	74 04                	je     8008b7 <strcmp+0x1c>
  8008b3:	3a 02                	cmp    (%edx),%al
  8008b5:	74 ef                	je     8008a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 c0             	movzbl %al,%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strncmp+0x17>
		n--, p++, q++;
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	39 d8                	cmp    %ebx,%eax
  8008da:	74 15                	je     8008f1 <strncmp+0x30>
  8008dc:	0f b6 08             	movzbl (%eax),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 04                	je     8008e7 <strncmp+0x26>
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 eb                	je     8008d2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb 05                	jmp    8008f6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 07                	jmp    80090c <strchr+0x13>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 0f                	je     800918 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strfind+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092c:	84 d2                	test   %dl,%dl
  80092e:	74 04                	je     800934 <strfind+0x1a>
  800930:	38 ca                	cmp    %cl,%dl
  800932:	75 f2                	jne    800926 <strfind+0xc>
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 36                	je     80097c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800946:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094c:	75 28                	jne    800976 <memset+0x40>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 23                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800953:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800957:	89 d3                	mov    %edx,%ebx
  800959:	c1 e3 08             	shl    $0x8,%ebx
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	c1 e6 18             	shl    $0x18,%esi
  800961:	89 d0                	mov    %edx,%eax
  800963:	c1 e0 10             	shl    $0x10,%eax
  800966:	09 f0                	or     %esi,%eax
  800968:	09 c2                	or     %eax,%edx
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 06                	jmp    80097c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 35                	jae    8009ca <memmove+0x47>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2e                	jae    8009ca <memmove+0x47>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a9:	75 13                	jne    8009be <memmove+0x3b>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0e                	jne    8009be <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b0:	83 ef 04             	sub    $0x4,%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 1d                	jmp    8009e7 <memmove+0x64>
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0f                	jne    8009e2 <memmove+0x5f>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 0a                	jne    8009e2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 05                	jmp    8009e7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	ff 75 08             	pushl  0x8(%ebp)
  8009f7:	e8 87 ff ff ff       	call   800983 <memmove>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	89 c6                	mov    %eax,%esi
  800a0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	eb 1a                	jmp    800a2a <memcmp+0x2c>
		if (*s1 != *s2)
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	0f b6 1a             	movzbl (%edx),%ebx
  800a16:	38 d9                	cmp    %bl,%cl
  800a18:	74 0a                	je     800a24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c1             	movzbl %cl,%eax
  800a1d:	0f b6 db             	movzbl %bl,%ebx
  800a20:	29 d8                	sub    %ebx,%eax
  800a22:	eb 0f                	jmp    800a33 <memcmp+0x35>
		s1++, s2++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	39 f0                	cmp    %esi,%eax
  800a2c:	75 e2                	jne    800a10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a45:	eb 07                	jmp    800a4e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	38 08                	cmp    %cl,(%eax)
  800a49:	74 07                	je     800a52 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f5                	jb     800a47 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 03                	jmp    800a65 <strtol+0x11>
		s++;
  800a62:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a65:	0f b6 01             	movzbl (%ecx),%eax
  800a68:	3c 09                	cmp    $0x9,%al
  800a6a:	74 f6                	je     800a62 <strtol+0xe>
  800a6c:	3c 20                	cmp    $0x20,%al
  800a6e:	74 f2                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a70:	3c 2b                	cmp    $0x2b,%al
  800a72:	75 0a                	jne    800a7e <strtol+0x2a>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7c:	eb 10                	jmp    800a8e <strtol+0x3a>
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a83:	3c 2d                	cmp    $0x2d,%al
  800a85:	75 07                	jne    800a8e <strtol+0x3a>
		s++, neg = 1;
  800a87:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a8a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	0f 94 c0             	sete   %al
  800a93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a99:	75 19                	jne    800ab4 <strtol+0x60>
  800a9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9e:	75 14                	jne    800ab4 <strtol+0x60>
  800aa0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa4:	0f 85 8a 00 00 00    	jne    800b34 <strtol+0xe0>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb 16                	jmp    800aca <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab4:	84 c0                	test   %al,%al
  800ab6:	74 12                	je     800aca <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 08                	jne    800aca <strtol+0x76>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 08                	ja     800ae7 <strtol+0x93>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb 22                	jmp    800b09 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ae7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 57             	sub    $0x57,%edx
  800af7:	eb 10                	jmp    800b09 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800af9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 16                	ja     800b19 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b09:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b15:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b17:	eb b9                	jmp    800ad2 <strtol+0x7e>
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	eb 02                	jmp    800b1f <strtol+0xcb>
  800b1d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xd6>
		*endptr = (char *) s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	74 0c                	je     800b3a <strtol+0xe6>
  800b2e:	89 d0                	mov    %edx,%eax
  800b30:	f7 d8                	neg    %eax
  800b32:	eb 06                	jmp    800b3a <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b34:	84 c0                	test   %al,%al
  800b36:	75 8a                	jne    800ac2 <strtol+0x6e>
  800b38:	eb 90                	jmp    800aca <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	89 c6                	mov    %eax,%esi
  800b56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	89 cb                	mov    %ecx,%ebx
  800b94:	89 cf                	mov    %ecx,%edi
  800b96:	89 ce                	mov    %ecx,%esi
  800b98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 03                	push   $0x3
  800ba4:	68 df 28 80 00       	push   $0x8028df
  800ba9:	6a 23                	push   $0x23
  800bab:	68 fc 28 80 00       	push   $0x8028fc
  800bb0:	e8 df f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_yield>:

void
sys_yield(void)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bec:	89 d1                	mov    %edx,%ecx
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	89 d7                	mov    %edx,%edi
  800bf2:	89 d6                	mov    %edx,%esi
  800bf4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	be 00 00 00 00       	mov    $0x0,%esi
  800c09:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	89 f7                	mov    %esi,%edi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 04                	push   $0x4
  800c25:	68 df 28 80 00       	push   $0x8028df
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 fc 28 80 00       	push   $0x8028fc
  800c31:	e8 5e f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c58:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 05                	push   $0x5
  800c67:	68 df 28 80 00       	push   $0x8028df
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 fc 28 80 00       	push   $0x8028fc
  800c73:	e8 1c f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 06                	push   $0x6
  800ca9:	68 df 28 80 00       	push   $0x8028df
  800cae:	6a 23                	push   $0x23
  800cb0:	68 fc 28 80 00       	push   $0x8028fc
  800cb5:	e8 da f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 08                	push   $0x8
  800ceb:	68 df 28 80 00       	push   $0x8028df
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 fc 28 80 00       	push   $0x8028fc
  800cf7:	e8 98 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 09 00 00 00       	mov    $0x9,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 09                	push   $0x9
  800d2d:	68 df 28 80 00       	push   $0x8028df
  800d32:	6a 23                	push   $0x23
  800d34:	68 fc 28 80 00       	push   $0x8028fc
  800d39:	e8 56 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 df                	mov    %ebx,%edi
  800d61:	89 de                	mov    %ebx,%esi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 0a                	push   $0xa
  800d6f:	68 df 28 80 00       	push   $0x8028df
  800d74:	6a 23                	push   $0x23
  800d76:	68 fc 28 80 00       	push   $0x8028fc
  800d7b:	e8 14 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 cb                	mov    %ecx,%ebx
  800dc3:	89 cf                	mov    %ecx,%edi
  800dc5:	89 ce                	mov    %ecx,%esi
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 0d                	push   $0xd
  800dd3:	68 df 28 80 00       	push   $0x8028df
  800dd8:	6a 23                	push   $0x23
  800dda:	68 fc 28 80 00       	push   $0x8028fc
  800ddf:	e8 b0 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_gettime>:

int sys_gettime(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfc:	89 d1                	mov    %edx,%ecx
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	89 d7                	mov    %edx,%edi
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	05 00 00 00 30       	add    $0x30000000,%eax
  800e16:	c1 e8 0c             	shr    $0xc,%eax
}
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 ea 16             	shr    $0x16,%edx
  800e42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e49:	f6 c2 01             	test   $0x1,%dl
  800e4c:	74 11                	je     800e5f <fd_alloc+0x2d>
  800e4e:	89 c2                	mov    %eax,%edx
  800e50:	c1 ea 0c             	shr    $0xc,%edx
  800e53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5a:	f6 c2 01             	test   $0x1,%dl
  800e5d:	75 09                	jne    800e68 <fd_alloc+0x36>
			*fd_store = fd;
  800e5f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	eb 17                	jmp    800e7f <fd_alloc+0x4d>
  800e68:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e72:	75 c9                	jne    800e3d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e74:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e87:	83 f8 1f             	cmp    $0x1f,%eax
  800e8a:	77 36                	ja     800ec2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8c:	c1 e0 0c             	shl    $0xc,%eax
  800e8f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 16             	shr    $0x16,%edx
  800e99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	74 24                	je     800ec9 <fd_lookup+0x48>
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 0c             	shr    $0xc,%edx
  800eaa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	74 1a                	je     800ed0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb9:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	eb 13                	jmp    800ed5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec7:	eb 0c                	jmp    800ed5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ece:	eb 05                	jmp    800ed5 <fd_lookup+0x54>
  800ed0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee0:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee5:	eb 13                	jmp    800efa <dev_lookup+0x23>
  800ee7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eea:	39 08                	cmp    %ecx,(%eax)
  800eec:	75 0c                	jne    800efa <dev_lookup+0x23>
			*dev = devtab[i];
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef8:	eb 2e                	jmp    800f28 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efa:	8b 02                	mov    (%edx),%eax
  800efc:	85 c0                	test   %eax,%eax
  800efe:	75 e7                	jne    800ee7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f00:	a1 04 40 80 00       	mov    0x804004,%eax
  800f05:	8b 40 48             	mov    0x48(%eax),%eax
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	51                   	push   %ecx
  800f0c:	50                   	push   %eax
  800f0d:	68 0c 29 80 00       	push   $0x80290c
  800f12:	e8 56 f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 10             	sub    $0x10,%esp
  800f32:	8b 75 08             	mov    0x8(%ebp),%esi
  800f35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f42:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f45:	50                   	push   %eax
  800f46:	e8 36 ff ff ff       	call   800e81 <fd_lookup>
  800f4b:	83 c4 08             	add    $0x8,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 05                	js     800f57 <fd_close+0x2d>
	    || fd != fd2)
  800f52:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f55:	74 0b                	je     800f62 <fd_close+0x38>
		return (must_exist ? r : 0);
  800f57:	80 fb 01             	cmp    $0x1,%bl
  800f5a:	19 d2                	sbb    %edx,%edx
  800f5c:	f7 d2                	not    %edx
  800f5e:	21 d0                	and    %edx,%eax
  800f60:	eb 41                	jmp    800fa3 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f68:	50                   	push   %eax
  800f69:	ff 36                	pushl  (%esi)
  800f6b:	e8 67 ff ff ff       	call   800ed7 <dev_lookup>
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 1a                	js     800f93 <fd_close+0x69>
		if (dev->dev_close)
  800f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	74 0b                	je     800f93 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	56                   	push   %esi
  800f8c:	ff d0                	call   *%eax
  800f8e:	89 c3                	mov    %eax,%ebx
  800f90:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 e2 fc ff ff       	call   800c80 <sys_page_unmap>
	return r;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	89 d8                	mov    %ebx,%eax
}
  800fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 c5 fe ff ff       	call   800e81 <fd_lookup>
  800fbc:	89 c2                	mov    %eax,%edx
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 d2                	test   %edx,%edx
  800fc3:	78 10                	js     800fd5 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	6a 01                	push   $0x1
  800fca:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcd:	e8 58 ff ff ff       	call   800f2a <fd_close>
  800fd2:	83 c4 10             	add    $0x10,%esp
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <close_all>:

void
close_all(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	53                   	push   %ebx
  800fe7:	e8 be ff ff ff       	call   800faa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fec:	83 c3 01             	add    $0x1,%ebx
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	83 fb 20             	cmp    $0x20,%ebx
  800ff5:	75 ec                	jne    800fe3 <close_all+0xc>
		close(i);
}
  800ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 2c             	sub    $0x2c,%esp
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801008:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 6d fe ff ff       	call   800e81 <fd_lookup>
  801014:	89 c2                	mov    %eax,%edx
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	85 d2                	test   %edx,%edx
  80101b:	0f 88 c1 00 00 00    	js     8010e2 <dup+0xe6>
		return r;
	close(newfdnum);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	56                   	push   %esi
  801025:	e8 80 ff ff ff       	call   800faa <close>

	newfd = INDEX2FD(newfdnum);
  80102a:	89 f3                	mov    %esi,%ebx
  80102c:	c1 e3 0c             	shl    $0xc,%ebx
  80102f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801035:	83 c4 04             	add    $0x4,%esp
  801038:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103b:	e8 db fd ff ff       	call   800e1b <fd2data>
  801040:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801042:	89 1c 24             	mov    %ebx,(%esp)
  801045:	e8 d1 fd ff ff       	call   800e1b <fd2data>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801050:	89 f8                	mov    %edi,%eax
  801052:	c1 e8 16             	shr    $0x16,%eax
  801055:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105c:	a8 01                	test   $0x1,%al
  80105e:	74 37                	je     801097 <dup+0x9b>
  801060:	89 f8                	mov    %edi,%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106c:	f6 c2 01             	test   $0x1,%dl
  80106f:	74 26                	je     801097 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	25 07 0e 00 00       	and    $0xe07,%eax
  801080:	50                   	push   %eax
  801081:	ff 75 d4             	pushl  -0x2c(%ebp)
  801084:	6a 00                	push   $0x0
  801086:	57                   	push   %edi
  801087:	6a 00                	push   $0x0
  801089:	e8 b0 fb ff ff       	call   800c3e <sys_page_map>
  80108e:	89 c7                	mov    %eax,%edi
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 2e                	js     8010c5 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801097:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109a:	89 d0                	mov    %edx,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
  80109f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ae:	50                   	push   %eax
  8010af:	53                   	push   %ebx
  8010b0:	6a 00                	push   $0x0
  8010b2:	52                   	push   %edx
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 84 fb ff ff       	call   800c3e <sys_page_map>
  8010ba:	89 c7                	mov    %eax,%edi
  8010bc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010bf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c1:	85 ff                	test   %edi,%edi
  8010c3:	79 1d                	jns    8010e2 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	53                   	push   %ebx
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 b0 fb ff ff       	call   800c80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 a3 fb ff ff       	call   800c80 <sys_page_unmap>
	return r;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 f8                	mov    %edi,%eax
}
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 14             	sub    $0x14,%esp
  8010f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	53                   	push   %ebx
  8010f9:	e8 83 fd ff ff       	call   800e81 <fd_lookup>
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	89 c2                	mov    %eax,%edx
  801103:	85 c0                	test   %eax,%eax
  801105:	78 6d                	js     801174 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801111:	ff 30                	pushl  (%eax)
  801113:	e8 bf fd ff ff       	call   800ed7 <dev_lookup>
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 4c                	js     80116b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801122:	8b 42 08             	mov    0x8(%edx),%eax
  801125:	83 e0 03             	and    $0x3,%eax
  801128:	83 f8 01             	cmp    $0x1,%eax
  80112b:	75 21                	jne    80114e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112d:	a1 04 40 80 00       	mov    0x804004,%eax
  801132:	8b 40 48             	mov    0x48(%eax),%eax
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	53                   	push   %ebx
  801139:	50                   	push   %eax
  80113a:	68 4d 29 80 00       	push   $0x80294d
  80113f:	e8 29 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114c:	eb 26                	jmp    801174 <read+0x8a>
	}
	if (!dev->dev_read)
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	8b 40 08             	mov    0x8(%eax),%eax
  801154:	85 c0                	test   %eax,%eax
  801156:	74 17                	je     80116f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	ff 75 0c             	pushl  0xc(%ebp)
  801161:	52                   	push   %edx
  801162:	ff d0                	call   *%eax
  801164:	89 c2                	mov    %eax,%edx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 09                	jmp    801174 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	eb 05                	jmp    801174 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801174:	89 d0                	mov    %edx,%eax
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	8b 7d 08             	mov    0x8(%ebp),%edi
  801187:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	eb 21                	jmp    8011b2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	89 f0                	mov    %esi,%eax
  801196:	29 d8                	sub    %ebx,%eax
  801198:	50                   	push   %eax
  801199:	89 d8                	mov    %ebx,%eax
  80119b:	03 45 0c             	add    0xc(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	57                   	push   %edi
  8011a0:	e8 45 ff ff ff       	call   8010ea <read>
		if (m < 0)
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0c                	js     8011b8 <readn+0x3d>
			return m;
		if (m == 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 06                	je     8011b6 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b0:	01 c3                	add    %eax,%ebx
  8011b2:	39 f3                	cmp    %esi,%ebx
  8011b4:	72 db                	jb     801191 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011b6:	89 d8                	mov    %ebx,%eax
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 14             	sub    $0x14,%esp
  8011c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	53                   	push   %ebx
  8011cf:	e8 ad fc ff ff       	call   800e81 <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 68                	js     801245 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	ff 30                	pushl  (%eax)
  8011e9:	e8 e9 fc ff ff       	call   800ed7 <dev_lookup>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 47                	js     80123c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fc:	75 21                	jne    80121f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	53                   	push   %ebx
  80120a:	50                   	push   %eax
  80120b:	68 69 29 80 00       	push   $0x802969
  801210:	e8 58 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121d:	eb 26                	jmp    801245 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801222:	8b 52 0c             	mov    0xc(%edx),%edx
  801225:	85 d2                	test   %edx,%edx
  801227:	74 17                	je     801240 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	ff 75 10             	pushl  0x10(%ebp)
  80122f:	ff 75 0c             	pushl  0xc(%ebp)
  801232:	50                   	push   %eax
  801233:	ff d2                	call   *%edx
  801235:	89 c2                	mov    %eax,%edx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	eb 09                	jmp    801245 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	eb 05                	jmp    801245 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801240:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801245:	89 d0                	mov    %edx,%eax
  801247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <seek>:

int
seek(int fdnum, off_t offset)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801252:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	ff 75 08             	pushl  0x8(%ebp)
  801259:	e8 23 fc ff ff       	call   800e81 <fd_lookup>
  80125e:	83 c4 08             	add    $0x8,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 0e                	js     801273 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801265:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 14             	sub    $0x14,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	53                   	push   %ebx
  801284:	e8 f8 fb ff ff       	call   800e81 <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 65                	js     8012f7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	ff 30                	pushl  (%eax)
  80129e:	e8 34 fc ff ff       	call   800ed7 <dev_lookup>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 44                	js     8012ee <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b1:	75 21                	jne    8012d4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b8:	8b 40 48             	mov    0x48(%eax),%eax
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	53                   	push   %ebx
  8012bf:	50                   	push   %eax
  8012c0:	68 2c 29 80 00       	push   $0x80292c
  8012c5:	e8 a3 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d2:	eb 23                	jmp    8012f7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d7:	8b 52 18             	mov    0x18(%edx),%edx
  8012da:	85 d2                	test   %edx,%edx
  8012dc:	74 14                	je     8012f2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	ff 75 0c             	pushl  0xc(%ebp)
  8012e4:	50                   	push   %eax
  8012e5:	ff d2                	call   *%edx
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	eb 09                	jmp    8012f7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	eb 05                	jmp    8012f7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f7:	89 d0                	mov    %edx,%eax
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 6d fb ff ff       	call   800e81 <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	89 c2                	mov    %eax,%edx
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 58                	js     801375 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	ff 30                	pushl  (%eax)
  801329:	e8 a9 fb ff ff       	call   800ed7 <dev_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 37                	js     80136c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801338:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133c:	74 32                	je     801370 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801341:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801348:	00 00 00 
	stat->st_isdir = 0;
  80134b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801352:	00 00 00 
	stat->st_dev = dev;
  801355:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	53                   	push   %ebx
  80135f:	ff 75 f0             	pushl  -0x10(%ebp)
  801362:	ff 50 14             	call   *0x14(%eax)
  801365:	89 c2                	mov    %eax,%edx
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	eb 09                	jmp    801375 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	eb 05                	jmp    801375 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801370:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801375:	89 d0                	mov    %edx,%eax
  801377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	6a 00                	push   $0x0
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 e7 01 00 00       	call   801575 <open>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 db                	test   %ebx,%ebx
  801395:	78 1b                	js     8013b2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	ff 75 0c             	pushl  0xc(%ebp)
  80139d:	53                   	push   %ebx
  80139e:	e8 5b ff ff ff       	call   8012fe <fstat>
  8013a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a5:	89 1c 24             	mov    %ebx,(%esp)
  8013a8:	e8 fd fb ff ff       	call   800faa <close>
	return r;
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	89 f0                	mov    %esi,%eax
}
  8013b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	89 c6                	mov    %eax,%esi
  8013c0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c9:	75 12                	jne    8013dd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	6a 03                	push   $0x3
  8013d0:	e8 9c 0d 00 00       	call   802171 <ipc_find_env>
  8013d5:	a3 00 40 80 00       	mov    %eax,0x804000
  8013da:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013dd:	6a 07                	push   $0x7
  8013df:	68 00 50 80 00       	push   $0x805000
  8013e4:	56                   	push   %esi
  8013e5:	ff 35 00 40 80 00    	pushl  0x804000
  8013eb:	e8 30 0d 00 00       	call   802120 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f0:	83 c4 0c             	add    $0xc,%esp
  8013f3:	6a 00                	push   $0x0
  8013f5:	53                   	push   %ebx
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 bd 0c 00 00       	call   8020ba <ipc_recv>
}
  8013fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	8b 40 0c             	mov    0xc(%eax),%eax
  801410:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801415:	8b 45 0c             	mov    0xc(%ebp),%eax
  801418:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 02 00 00 00       	mov    $0x2,%eax
  801427:	e8 8d ff ff ff       	call   8013b9 <fsipc>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 06 00 00 00       	mov    $0x6,%eax
  801449:	e8 6b ff ff ff       	call   8013b9 <fsipc>
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	53                   	push   %ebx
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 05 00 00 00       	mov    $0x5,%eax
  80146f:	e8 45 ff ff ff       	call   8013b9 <fsipc>
  801474:	89 c2                	mov    %eax,%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	78 2c                	js     8014a6 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	68 00 50 80 00       	push   $0x805000
  801482:	53                   	push   %ebx
  801483:	e8 69 f3 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801488:	a1 80 50 80 00       	mov    0x805080,%eax
  80148d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801493:	a1 84 50 80 00       	mov    0x805084,%eax
  801498:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8014b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ba:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8014c0:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8014c5:	76 05                	jbe    8014cc <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8014c7:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8014cc:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 0c             	pushl  0xc(%ebp)
  8014d8:	68 08 50 80 00       	push   $0x805008
  8014dd:	e8 a1 f4 ff ff       	call   800983 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ec:	e8 c8 fe ff ff       	call   8013b9 <fsipc>
	return write;
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801501:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801506:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150c:	ba 00 00 00 00       	mov    $0x0,%edx
  801511:	b8 03 00 00 00       	mov    $0x3,%eax
  801516:	e8 9e fe ff ff       	call   8013b9 <fsipc>
  80151b:	89 c3                	mov    %eax,%ebx
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 4b                	js     80156c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801521:	39 c6                	cmp    %eax,%esi
  801523:	73 16                	jae    80153b <devfile_read+0x48>
  801525:	68 98 29 80 00       	push   $0x802998
  80152a:	68 9f 29 80 00       	push   $0x80299f
  80152f:	6a 7c                	push   $0x7c
  801531:	68 b4 29 80 00       	push   $0x8029b4
  801536:	e8 59 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80153b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801540:	7e 16                	jle    801558 <devfile_read+0x65>
  801542:	68 bf 29 80 00       	push   $0x8029bf
  801547:	68 9f 29 80 00       	push   $0x80299f
  80154c:	6a 7d                	push   $0x7d
  80154e:	68 b4 29 80 00       	push   $0x8029b4
  801553:	e8 3c ec ff ff       	call   800194 <_panic>
	memmove(buf, &fsipcbuf, r);
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	50                   	push   %eax
  80155c:	68 00 50 80 00       	push   $0x805000
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	e8 1a f4 ff ff       	call   800983 <memmove>
	return r;
  801569:	83 c4 10             	add    $0x10,%esp
}
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 20             	sub    $0x20,%esp
  80157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157f:	53                   	push   %ebx
  801580:	e8 33 f2 ff ff       	call   8007b8 <strlen>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158d:	7f 67                	jg     8015f6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	e8 97 f8 ff ff       	call   800e32 <fd_alloc>
  80159b:	83 c4 10             	add    $0x10,%esp
		return r;
  80159e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 57                	js     8015fb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	68 00 50 80 00       	push   $0x805000
  8015ad:	e8 3f f2 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c2:	e8 f2 fd ff ff       	call   8013b9 <fsipc>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	79 14                	jns    8015e4 <open+0x6f>
		fd_close(fd, 0);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d8:	e8 4d f9 ff ff       	call   800f2a <fd_close>
		return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	89 da                	mov    %ebx,%edx
  8015e2:	eb 17                	jmp    8015fb <open+0x86>
	}

	return fd2num(fd);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ea:	e8 1c f8 ff ff       	call   800e0b <fd2num>
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 05                	jmp    8015fb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fb:	89 d0                	mov    %edx,%eax
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 08 00 00 00       	mov    $0x8,%eax
  801612:	e8 a2 fd ff ff       	call   8013b9 <fsipc>
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	57                   	push   %edi
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801625:	6a 00                	push   $0x0
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 46 ff ff ff       	call   801575 <open>
  80162f:	89 c1                	mov    %eax,%ecx
  801631:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	0f 88 c6 04 00 00    	js     801b08 <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	68 00 02 00 00       	push   $0x200
  80164a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	51                   	push   %ecx
  801652:	e8 24 fb ff ff       	call   80117b <readn>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80165f:	75 0c                	jne    80166d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801661:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801668:	45 4c 46 
  80166b:	74 33                	je     8016a0 <spawn+0x87>
		close(fd);
  80166d:	83 ec 0c             	sub    $0xc,%esp
  801670:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801676:	e8 2f f9 ff ff       	call   800faa <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80167b:	83 c4 0c             	add    $0xc,%esp
  80167e:	68 7f 45 4c 46       	push   $0x464c457f
  801683:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801689:	68 cb 29 80 00       	push   $0x8029cb
  80168e:	e8 da eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80169b:	e9 c8 04 00 00       	jmp    801b68 <spawn+0x54f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016a0:	b8 07 00 00 00       	mov    $0x7,%eax
  8016a5:	cd 30                	int    $0x30
  8016a7:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016ad:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	0f 88 55 04 00 00    	js     801b10 <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016bb:	89 c6                	mov    %eax,%esi
  8016bd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016c3:	6b f6 78             	imul   $0x78,%esi,%esi
  8016c6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016cc:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016d2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016d9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016df:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016ea:	be 00 00 00 00       	mov    $0x0,%esi
  8016ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016f2:	eb 13                	jmp    801707 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	50                   	push   %eax
  8016f8:	e8 bb f0 ff ff       	call   8007b8 <strlen>
  8016fd:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801701:	83 c3 01             	add    $0x1,%ebx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80170e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801711:	85 c0                	test   %eax,%eax
  801713:	75 df                	jne    8016f4 <spawn+0xdb>
  801715:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80171b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801721:	bf 00 10 40 00       	mov    $0x401000,%edi
  801726:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801728:	89 fa                	mov    %edi,%edx
  80172a:	83 e2 fc             	and    $0xfffffffc,%edx
  80172d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801734:	29 c2                	sub    %eax,%edx
  801736:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80173c:	8d 42 f8             	lea    -0x8(%edx),%eax
  80173f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801744:	0f 86 d6 03 00 00    	jbe    801b20 <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	6a 07                	push   $0x7
  80174f:	68 00 00 40 00       	push   $0x400000
  801754:	6a 00                	push   $0x0
  801756:	e8 a0 f4 ff ff       	call   800bfb <sys_page_alloc>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	0f 88 02 04 00 00    	js     801b68 <spawn+0x54f>
  801766:	be 00 00 00 00       	mov    $0x0,%esi
  80176b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801774:	eb 30                	jmp    8017a6 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801776:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  80177c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801782:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80178b:	57                   	push   %edi
  80178c:	e8 60 f0 ff ff       	call   8007f1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801791:	83 c4 04             	add    $0x4,%esp
  801794:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801797:	e8 1c f0 ff ff       	call   8007b8 <strlen>
  80179c:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017a0:	83 c6 01             	add    $0x1,%esi
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  8017ac:	7c c8                	jl     801776 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017ae:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017b4:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017ba:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017c1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017c7:	74 19                	je     8017e2 <spawn+0x1c9>
  8017c9:	68 54 2a 80 00       	push   $0x802a54
  8017ce:	68 9f 29 80 00       	push   $0x80299f
  8017d3:	68 f1 00 00 00       	push   $0xf1
  8017d8:	68 e5 29 80 00       	push   $0x8029e5
  8017dd:	e8 b2 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017e2:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  8017ef:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017f2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017f8:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017fb:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  801801:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801807:	83 ec 0c             	sub    $0xc,%esp
  80180a:	6a 07                	push   $0x7
  80180c:	68 00 d0 7f ee       	push   $0xee7fd000
  801811:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801817:	68 00 00 40 00       	push   $0x400000
  80181c:	6a 00                	push   $0x0
  80181e:	e8 1b f4 ff ff       	call   800c3e <sys_page_map>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	83 c4 20             	add    $0x20,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	0f 88 24 03 00 00    	js     801b54 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	68 00 00 40 00       	push   $0x400000
  801838:	6a 00                	push   $0x0
  80183a:	e8 41 f4 ff ff       	call   800c80 <sys_page_unmap>
  80183f:	89 c3                	mov    %eax,%ebx
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	0f 88 08 03 00 00    	js     801b54 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80184c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801852:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801859:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80185f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801866:	00 00 00 
  801869:	e9 84 01 00 00       	jmp    8019f2 <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  80186e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801874:	83 38 01             	cmpl   $0x1,(%eax)
  801877:	0f 85 67 01 00 00    	jne    8019e4 <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80187d:	89 c1                	mov    %eax,%ecx
  80187f:	8b 40 18             	mov    0x18(%eax),%eax
  801882:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801888:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80188b:	83 f8 01             	cmp    $0x1,%eax
  80188e:	19 c0                	sbb    %eax,%eax
  801890:	83 e0 fe             	and    $0xfffffffe,%eax
  801893:	83 c0 07             	add    $0x7,%eax
  801896:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80189c:	89 c8                	mov    %ecx,%eax
  80189e:	8b 49 04             	mov    0x4(%ecx),%ecx
  8018a1:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8018a7:	8b 78 10             	mov    0x10(%eax),%edi
  8018aa:	8b 48 14             	mov    0x14(%eax),%ecx
  8018ad:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8018b3:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018b6:	89 f0                	mov    %esi,%eax
  8018b8:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018bd:	74 10                	je     8018cf <spawn+0x2b6>
		va -= i;
  8018bf:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018c1:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  8018c7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018c9:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d4:	e9 f9 00 00 00       	jmp    8019d2 <spawn+0x3b9>
		if (i >= filesz) {
  8018d9:	39 fb                	cmp    %edi,%ebx
  8018db:	72 27                	jb     801904 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018e6:	56                   	push   %esi
  8018e7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018ed:	e8 09 f3 ff ff       	call   800bfb <sys_page_alloc>
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	0f 89 c9 00 00 00    	jns    8019c6 <spawn+0x3ad>
  8018fd:	89 c7                	mov    %eax,%edi
  8018ff:	e9 2d 02 00 00       	jmp    801b31 <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	6a 07                	push   $0x7
  801909:	68 00 00 40 00       	push   $0x400000
  80190e:	6a 00                	push   $0x0
  801910:	e8 e6 f2 ff ff       	call   800bfb <sys_page_alloc>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	0f 88 07 02 00 00    	js     801b27 <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801929:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801936:	e8 11 f9 ff ff       	call   80124c <seek>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	0f 88 e5 01 00 00    	js     801b2b <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801946:	83 ec 04             	sub    $0x4,%esp
  801949:	89 fa                	mov    %edi,%edx
  80194b:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801951:	89 d0                	mov    %edx,%eax
  801953:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801959:	76 05                	jbe    801960 <spawn+0x347>
  80195b:	b8 00 10 00 00       	mov    $0x1000,%eax
  801960:	50                   	push   %eax
  801961:	68 00 00 40 00       	push   $0x400000
  801966:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80196c:	e8 0a f8 ff ff       	call   80117b <readn>
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	0f 88 b3 01 00 00    	js     801b2f <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801985:	56                   	push   %esi
  801986:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80198c:	68 00 00 40 00       	push   $0x400000
  801991:	6a 00                	push   $0x0
  801993:	e8 a6 f2 ff ff       	call   800c3e <sys_page_map>
  801998:	83 c4 20             	add    $0x20,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	79 15                	jns    8019b4 <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  80199f:	50                   	push   %eax
  8019a0:	68 f1 29 80 00       	push   $0x8029f1
  8019a5:	68 23 01 00 00       	push   $0x123
  8019aa:	68 e5 29 80 00       	push   $0x8029e5
  8019af:	e8 e0 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	68 00 00 40 00       	push   $0x400000
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 bd f2 ff ff       	call   800c80 <sys_page_unmap>
  8019c3:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019cc:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019d2:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019d8:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8019de:	0f 82 f5 fe ff ff    	jb     8018d9 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019e4:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019eb:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019f2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019f9:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019ff:	0f 8c 69 fe ff ff    	jl     80186e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a0e:	e8 97 f5 ff ff       	call   800faa <close>
  801a13:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a20:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  801a26:	89 d8                	mov    %ebx,%eax
  801a28:	c1 f8 0a             	sar    $0xa,%eax
  801a2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a32:	a8 01                	test   $0x1,%al
  801a34:	75 10                	jne    801a46 <spawn+0x42d>
  801a36:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  801a3c:	75 08                	jne    801a46 <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  801a3e:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801a44:	eb 54                	jmp    801a9a <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  801a46:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a4d:	a8 01                	test   $0x1,%al
  801a4f:	74 49                	je     801a9a <spawn+0x481>
  801a51:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a58:	f6 c4 04             	test   $0x4,%ah
  801a5b:	74 3d                	je     801a9a <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  801a5d:	89 da                	mov    %ebx,%edx
  801a5f:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  801a62:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a69:	83 ec 0c             	sub    $0xc,%esp
  801a6c:	25 07 0e 00 00       	and    $0xe07,%eax
  801a71:	50                   	push   %eax
  801a72:	52                   	push   %edx
  801a73:	56                   	push   %esi
  801a74:	52                   	push   %edx
  801a75:	6a 00                	push   $0x0
  801a77:	e8 c2 f1 ff ff       	call   800c3e <sys_page_map>
  801a7c:	83 c4 20             	add    $0x20,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	74 17                	je     801a9a <spawn+0x481>
                                panic("copy_shared_pages");
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	68 0e 2a 80 00       	push   $0x802a0e
  801a8b:	68 3c 01 00 00       	push   $0x13c
  801a90:	68 e5 29 80 00       	push   $0x8029e5
  801a95:	e8 fa e6 ff ff       	call   800194 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801a9a:	83 c3 01             	add    $0x1,%ebx
  801a9d:	89 da                	mov    %ebx,%edx
  801a9f:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  801aa5:	0f 86 7b ff ff ff    	jbe    801a26 <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ab4:	50                   	push   %eax
  801ab5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801abb:	e8 44 f2 ff ff       	call   800d04 <sys_env_set_trapframe>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	79 15                	jns    801adc <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  801ac7:	50                   	push   %eax
  801ac8:	68 20 2a 80 00       	push   $0x802a20
  801acd:	68 85 00 00 00       	push   $0x85
  801ad2:	68 e5 29 80 00       	push   $0x8029e5
  801ad7:	e8 b8 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	6a 02                	push   $0x2
  801ae1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ae7:	e8 d6 f1 ff ff       	call   800cc2 <sys_env_set_status>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	79 25                	jns    801b18 <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  801af3:	50                   	push   %eax
  801af4:	68 3a 2a 80 00       	push   $0x802a3a
  801af9:	68 88 00 00 00       	push   $0x88
  801afe:	68 e5 29 80 00       	push   $0x8029e5
  801b03:	e8 8c e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b08:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b0e:	eb 58                	jmp    801b68 <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b10:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b16:	eb 50                	jmp    801b68 <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  801b18:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b1e:	eb 48                	jmp    801b68 <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b20:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801b25:	eb 41                	jmp    801b68 <spawn+0x54f>
  801b27:	89 c7                	mov    %eax,%edi
  801b29:	eb 06                	jmp    801b31 <spawn+0x518>
  801b2b:	89 c7                	mov    %eax,%edi
  801b2d:	eb 02                	jmp    801b31 <spawn+0x518>
  801b2f:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b3a:	e8 3d f0 ff ff       	call   800b7c <sys_env_destroy>
	close(fd);
  801b3f:	83 c4 04             	add    $0x4,%esp
  801b42:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b48:	e8 5d f4 ff ff       	call   800faa <close>
	return r;
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	89 f8                	mov    %edi,%eax
  801b52:	eb 14                	jmp    801b68 <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b54:	83 ec 08             	sub    $0x8,%esp
  801b57:	68 00 00 40 00       	push   $0x400000
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 1d f1 ff ff       	call   800c80 <sys_page_unmap>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b75:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7d:	eb 03                	jmp    801b82 <spawnl+0x12>
		argc++;
  801b7f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b82:	83 c2 04             	add    $0x4,%edx
  801b85:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b89:	75 f4                	jne    801b7f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b8b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b92:	83 e2 f0             	and    $0xfffffff0,%edx
  801b95:	29 d4                	sub    %edx,%esp
  801b97:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b9b:	c1 ea 02             	shr    $0x2,%edx
  801b9e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ba5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801baa:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bb1:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bb8:	00 
  801bb9:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc0:	eb 0a                	jmp    801bcc <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bc2:	83 c0 01             	add    $0x1,%eax
  801bc5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bc9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bcc:	39 d0                	cmp    %edx,%eax
  801bce:	75 f2                	jne    801bc2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bd0:	83 ec 08             	sub    $0x8,%esp
  801bd3:	56                   	push   %esi
  801bd4:	ff 75 08             	pushl  0x8(%ebp)
  801bd7:	e8 3d fa ff ff       	call   801619 <spawn>
}
  801bdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    

00801be3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	ff 75 08             	pushl  0x8(%ebp)
  801bf1:	e8 25 f2 ff ff       	call   800e1b <fd2data>
  801bf6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bf8:	83 c4 08             	add    $0x8,%esp
  801bfb:	68 7a 2a 80 00       	push   $0x802a7a
  801c00:	53                   	push   %ebx
  801c01:	e8 eb eb ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c06:	8b 56 04             	mov    0x4(%esi),%edx
  801c09:	89 d0                	mov    %edx,%eax
  801c0b:	2b 06                	sub    (%esi),%eax
  801c0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c1a:	00 00 00 
	stat->st_dev = &devpipe;
  801c1d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c24:	30 80 00 
	return 0;
}
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c3d:	53                   	push   %ebx
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 3b f0 ff ff       	call   800c80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 ce f1 ff ff       	call   800e1b <fd2data>
  801c4d:	83 c4 08             	add    $0x8,%esp
  801c50:	50                   	push   %eax
  801c51:	6a 00                	push   $0x0
  801c53:	e8 28 f0 ff ff       	call   800c80 <sys_page_unmap>
}
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 1c             	sub    $0x1c,%esp
  801c66:	89 c7                	mov    %eax,%edi
  801c68:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c72:	83 ec 0c             	sub    $0xc,%esp
  801c75:	57                   	push   %edi
  801c76:	e8 2e 05 00 00       	call   8021a9 <pageref>
  801c7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c7e:	89 34 24             	mov    %esi,(%esp)
  801c81:	e8 23 05 00 00       	call   8021a9 <pageref>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c8c:	0f 94 c0             	sete   %al
  801c8f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c92:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9b:	39 cb                	cmp    %ecx,%ebx
  801c9d:	74 15                	je     801cb4 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801c9f:	8b 52 58             	mov    0x58(%edx),%edx
  801ca2:	50                   	push   %eax
  801ca3:	52                   	push   %edx
  801ca4:	53                   	push   %ebx
  801ca5:	68 88 2a 80 00       	push   $0x802a88
  801caa:	e8 be e5 ff ff       	call   80026d <cprintf>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	eb b6                	jmp    801c6a <_pipeisclosed+0xd>
	}
}
  801cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	57                   	push   %edi
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
  801cc2:	83 ec 28             	sub    $0x28,%esp
  801cc5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cc8:	56                   	push   %esi
  801cc9:	e8 4d f1 ff ff       	call   800e1b <fd2data>
  801cce:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd8:	eb 4b                	jmp    801d25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cda:	89 da                	mov    %ebx,%edx
  801cdc:	89 f0                	mov    %esi,%eax
  801cde:	e8 7a ff ff ff       	call   801c5d <_pipeisclosed>
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	75 48                	jne    801d2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ce7:	e8 f0 ee ff ff       	call   800bdc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cec:	8b 43 04             	mov    0x4(%ebx),%eax
  801cef:	8b 0b                	mov    (%ebx),%ecx
  801cf1:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf4:	39 d0                	cmp    %edx,%eax
  801cf6:	73 e2                	jae    801cda <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	c1 fa 1f             	sar    $0x1f,%edx
  801d07:	89 d1                	mov    %edx,%ecx
  801d09:	c1 e9 1b             	shr    $0x1b,%ecx
  801d0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d0f:	83 e2 1f             	and    $0x1f,%edx
  801d12:	29 ca                	sub    %ecx,%edx
  801d14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d1c:	83 c0 01             	add    $0x1,%eax
  801d1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	83 c7 01             	add    $0x1,%edi
  801d25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d28:	75 c2                	jne    801cec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2d:	eb 05                	jmp    801d34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	83 ec 18             	sub    $0x18,%esp
  801d45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d48:	57                   	push   %edi
  801d49:	e8 cd f0 ff ff       	call   800e1b <fd2data>
  801d4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d58:	eb 3d                	jmp    801d97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d5a:	85 db                	test   %ebx,%ebx
  801d5c:	74 04                	je     801d62 <devpipe_read+0x26>
				return i;
  801d5e:	89 d8                	mov    %ebx,%eax
  801d60:	eb 44                	jmp    801da6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	89 f8                	mov    %edi,%eax
  801d66:	e8 f2 fe ff ff       	call   801c5d <_pipeisclosed>
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	75 32                	jne    801da1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d6f:	e8 68 ee ff ff       	call   800bdc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d74:	8b 06                	mov    (%esi),%eax
  801d76:	3b 46 04             	cmp    0x4(%esi),%eax
  801d79:	74 df                	je     801d5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7b:	99                   	cltd   
  801d7c:	c1 ea 1b             	shr    $0x1b,%edx
  801d7f:	01 d0                	add    %edx,%eax
  801d81:	83 e0 1f             	and    $0x1f,%eax
  801d84:	29 d0                	sub    %edx,%eax
  801d86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d94:	83 c3 01             	add    $0x1,%ebx
  801d97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d9a:	75 d8                	jne    801d74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9f:	eb 05                	jmp    801da6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5f                   	pop    %edi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	e8 73 f0 ff ff       	call   800e32 <fd_alloc>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	89 c2                	mov    %eax,%edx
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 2c 01 00 00    	js     801ef8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	68 07 04 00 00       	push   $0x407
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 1d ee ff ff       	call   800bfb <sys_page_alloc>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	89 c2                	mov    %eax,%edx
  801de3:	85 c0                	test   %eax,%eax
  801de5:	0f 88 0d 01 00 00    	js     801ef8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801df1:	50                   	push   %eax
  801df2:	e8 3b f0 ff ff       	call   800e32 <fd_alloc>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 e2 00 00 00    	js     801ee6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	68 07 04 00 00       	push   $0x407
  801e0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 e5 ed ff ff       	call   800bfb <sys_page_alloc>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	0f 88 c3 00 00 00    	js     801ee6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	ff 75 f4             	pushl  -0xc(%ebp)
  801e29:	e8 ed ef ff ff       	call   800e1b <fd2data>
  801e2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e30:	83 c4 0c             	add    $0xc,%esp
  801e33:	68 07 04 00 00       	push   $0x407
  801e38:	50                   	push   %eax
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 bb ed ff ff       	call   800bfb <sys_page_alloc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	0f 88 89 00 00 00    	js     801ed6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	ff 75 f0             	pushl  -0x10(%ebp)
  801e53:	e8 c3 ef ff ff       	call   800e1b <fd2data>
  801e58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	56                   	push   %esi
  801e63:	6a 00                	push   $0x0
  801e65:	e8 d4 ed ff ff       	call   800c3e <sys_page_map>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 20             	add    $0x20,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 55                	js     801ec8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea3:	e8 63 ef ff ff       	call   800e0b <fd2num>
  801ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ead:	83 c4 04             	add    $0x4,%esp
  801eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb3:	e8 53 ef ff ff       	call   800e0b <fd2num>
  801eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec6:	eb 30                	jmp    801ef8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ec8:	83 ec 08             	sub    $0x8,%esp
  801ecb:	56                   	push   %esi
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 ad ed ff ff       	call   800c80 <sys_page_unmap>
  801ed3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	ff 75 f0             	pushl  -0x10(%ebp)
  801edc:	6a 00                	push   $0x0
  801ede:	e8 9d ed ff ff       	call   800c80 <sys_page_unmap>
  801ee3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eec:	6a 00                	push   $0x0
  801eee:	e8 8d ed ff ff       	call   800c80 <sys_page_unmap>
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0a:	50                   	push   %eax
  801f0b:	ff 75 08             	pushl  0x8(%ebp)
  801f0e:	e8 6e ef ff ff       	call   800e81 <fd_lookup>
  801f13:	89 c2                	mov    %eax,%edx
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	85 d2                	test   %edx,%edx
  801f1a:	78 18                	js     801f34 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f22:	e8 f4 ee ff ff       	call   800e1b <fd2data>
	return _pipeisclosed(fd, p);
  801f27:	89 c2                	mov    %eax,%edx
  801f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2c:	e8 2c fd ff ff       	call   801c5d <_pipeisclosed>
  801f31:	83 c4 10             	add    $0x10,%esp
}
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f46:	68 bc 2a 80 00       	push   $0x802abc
  801f4b:	ff 75 0c             	pushl  0xc(%ebp)
  801f4e:	e8 9e e8 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f66:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f71:	eb 2e                	jmp    801fa1 <devcons_write+0x47>
		m = n - tot;
  801f73:	8b 55 10             	mov    0x10(%ebp),%edx
  801f76:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801f78:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801f7d:	83 fa 7f             	cmp    $0x7f,%edx
  801f80:	77 02                	ja     801f84 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f82:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	56                   	push   %esi
  801f88:	03 45 0c             	add    0xc(%ebp),%eax
  801f8b:	50                   	push   %eax
  801f8c:	57                   	push   %edi
  801f8d:	e8 f1 e9 ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  801f92:	83 c4 08             	add    $0x8,%esp
  801f95:	56                   	push   %esi
  801f96:	57                   	push   %edi
  801f97:	e8 a3 eb ff ff       	call   800b3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9c:	01 f3                	add    %esi,%ebx
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fa6:	72 cb                	jb     801f73 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fab:	5b                   	pop    %ebx
  801fac:	5e                   	pop    %esi
  801fad:	5f                   	pop    %edi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801fb6:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801fbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fbf:	75 07                	jne    801fc8 <devcons_read+0x18>
  801fc1:	eb 28                	jmp    801feb <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fc3:	e8 14 ec ff ff       	call   800bdc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fc8:	e8 90 eb ff ff       	call   800b5d <sys_cgetc>
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	74 f2                	je     801fc3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 16                	js     801feb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fd5:	83 f8 04             	cmp    $0x4,%eax
  801fd8:	74 0c                	je     801fe6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fdd:	88 02                	mov    %al,(%edx)
	return 1;
  801fdf:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe4:	eb 05                	jmp    801feb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fe6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801feb:	c9                   	leave  
  801fec:	c3                   	ret    

00801fed <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ff9:	6a 01                	push   $0x1
  801ffb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	e8 3b eb ff ff       	call   800b3f <sys_cputs>
  802004:	83 c4 10             	add    $0x10,%esp
}
  802007:	c9                   	leave  
  802008:	c3                   	ret    

00802009 <getchar>:

int
getchar(void)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80200f:	6a 01                	push   $0x1
  802011:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	6a 00                	push   $0x0
  802017:	e8 ce f0 ff ff       	call   8010ea <read>
	if (r < 0)
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	78 0f                	js     802032 <getchar+0x29>
		return r;
	if (r < 1)
  802023:	85 c0                	test   %eax,%eax
  802025:	7e 06                	jle    80202d <getchar+0x24>
		return -E_EOF;
	return c;
  802027:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80202b:	eb 05                	jmp    802032 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80202d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802032:	c9                   	leave  
  802033:	c3                   	ret    

00802034 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	ff 75 08             	pushl  0x8(%ebp)
  802041:	e8 3b ee ff ff       	call   800e81 <fd_lookup>
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 11                	js     80205e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80204d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802050:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802056:	39 10                	cmp    %edx,(%eax)
  802058:	0f 94 c0             	sete   %al
  80205b:	0f b6 c0             	movzbl %al,%eax
}
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <opencons>:

int
opencons(void)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	e8 c3 ed ff ff       	call   800e32 <fd_alloc>
  80206f:	83 c4 10             	add    $0x10,%esp
		return r;
  802072:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802074:	85 c0                	test   %eax,%eax
  802076:	78 3e                	js     8020b6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802078:	83 ec 04             	sub    $0x4,%esp
  80207b:	68 07 04 00 00       	push   $0x407
  802080:	ff 75 f4             	pushl  -0xc(%ebp)
  802083:	6a 00                	push   $0x0
  802085:	e8 71 eb ff ff       	call   800bfb <sys_page_alloc>
  80208a:	83 c4 10             	add    $0x10,%esp
		return r;
  80208d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80208f:	85 c0                	test   %eax,%eax
  802091:	78 23                	js     8020b6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802093:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80209e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	50                   	push   %eax
  8020ac:	e8 5a ed ff ff       	call   800e0b <fd2num>
  8020b1:	89 c2                	mov    %eax,%edx
  8020b3:	83 c4 10             	add    $0x10,%esp
}
  8020b6:	89 d0                	mov    %edx,%eax
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	56                   	push   %esi
  8020be:	53                   	push   %ebx
  8020bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  8020c8:	85 f6                	test   %esi,%esi
  8020ca:	74 06                	je     8020d2 <ipc_recv+0x18>
  8020cc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8020d2:	85 db                	test   %ebx,%ebx
  8020d4:	74 06                	je     8020dc <ipc_recv+0x22>
  8020d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8020dc:	83 f8 01             	cmp    $0x1,%eax
  8020df:	19 d2                	sbb    %edx,%edx
  8020e1:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	50                   	push   %eax
  8020e7:	e8 bf ec ff ff       	call   800dab <sys_ipc_recv>
  8020ec:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	85 d2                	test   %edx,%edx
  8020f3:	75 24                	jne    802119 <ipc_recv+0x5f>
	if (from_env_store)
  8020f5:	85 f6                	test   %esi,%esi
  8020f7:	74 0a                	je     802103 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  8020f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fe:	8b 40 70             	mov    0x70(%eax),%eax
  802101:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802103:	85 db                	test   %ebx,%ebx
  802105:	74 0a                	je     802111 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802107:	a1 04 40 80 00       	mov    0x804004,%eax
  80210c:	8b 40 74             	mov    0x74(%eax),%eax
  80210f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802111:	a1 04 40 80 00       	mov    0x804004,%eax
  802116:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802119:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	53                   	push   %ebx
  802126:	83 ec 0c             	sub    $0xc,%esp
  802129:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80212f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  802132:	83 fb 01             	cmp    $0x1,%ebx
  802135:	19 c0                	sbb    %eax,%eax
  802137:	09 c3                	or     %eax,%ebx
  802139:	eb 1c                	jmp    802157 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80213b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213e:	74 12                	je     802152 <ipc_send+0x32>
  802140:	50                   	push   %eax
  802141:	68 c8 2a 80 00       	push   $0x802ac8
  802146:	6a 36                	push   $0x36
  802148:	68 df 2a 80 00       	push   $0x802adf
  80214d:	e8 42 e0 ff ff       	call   800194 <_panic>
		sys_yield();
  802152:	e8 85 ea ff ff       	call   800bdc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802157:	ff 75 14             	pushl  0x14(%ebp)
  80215a:	53                   	push   %ebx
  80215b:	56                   	push   %esi
  80215c:	57                   	push   %edi
  80215d:	e8 26 ec ff ff       	call   800d88 <sys_ipc_try_send>
		if (ret == 0) break;
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	75 d2                	jne    80213b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216c:	5b                   	pop    %ebx
  80216d:	5e                   	pop    %esi
  80216e:	5f                   	pop    %edi
  80216f:	5d                   	pop    %ebp
  802170:	c3                   	ret    

00802171 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80217c:	6b d0 78             	imul   $0x78,%eax,%edx
  80217f:	83 c2 50             	add    $0x50,%edx
  802182:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802188:	39 ca                	cmp    %ecx,%edx
  80218a:	75 0d                	jne    802199 <ipc_find_env+0x28>
			return envs[i].env_id;
  80218c:	6b c0 78             	imul   $0x78,%eax,%eax
  80218f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802194:	8b 40 08             	mov    0x8(%eax),%eax
  802197:	eb 0e                	jmp    8021a7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802199:	83 c0 01             	add    $0x1,%eax
  80219c:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a1:	75 d9                	jne    80217c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a3:	66 b8 00 00          	mov    $0x0,%ax
}
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    

008021a9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	c1 e8 16             	shr    $0x16,%eax
  8021b4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021bb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c0:	f6 c1 01             	test   $0x1,%cl
  8021c3:	74 1d                	je     8021e2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c5:	c1 ea 0c             	shr    $0xc,%edx
  8021c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021cf:	f6 c2 01             	test   $0x1,%dl
  8021d2:	74 0e                	je     8021e2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d4:	c1 ea 0c             	shr    $0xc,%edx
  8021d7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021de:	ef 
  8021df:	0f b7 c0             	movzwl %ax,%eax
}
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	83 ec 10             	sub    $0x10,%esp
  8021f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8021fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8021fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802202:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802206:	85 d2                	test   %edx,%edx
  802208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80220c:	89 34 24             	mov    %esi,(%esp)
  80220f:	89 c8                	mov    %ecx,%eax
  802211:	75 35                	jne    802248 <__udivdi3+0x58>
  802213:	39 f1                	cmp    %esi,%ecx
  802215:	0f 87 bd 00 00 00    	ja     8022d8 <__udivdi3+0xe8>
  80221b:	85 c9                	test   %ecx,%ecx
  80221d:	89 cd                	mov    %ecx,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f1                	div    %ecx
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 f8                	mov    %edi,%eax
  802236:	f7 f5                	div    %ebp
  802238:	89 f2                	mov    %esi,%edx
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	3b 14 24             	cmp    (%esp),%edx
  80224b:	77 7b                	ja     8022c8 <__udivdi3+0xd8>
  80224d:	0f bd f2             	bsr    %edx,%esi
  802250:	83 f6 1f             	xor    $0x1f,%esi
  802253:	0f 84 97 00 00 00    	je     8022f0 <__udivdi3+0x100>
  802259:	bd 20 00 00 00       	mov    $0x20,%ebp
  80225e:	89 d7                	mov    %edx,%edi
  802260:	89 f1                	mov    %esi,%ecx
  802262:	29 f5                	sub    %esi,%ebp
  802264:	d3 e7                	shl    %cl,%edi
  802266:	89 c2                	mov    %eax,%edx
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	d3 ea                	shr    %cl,%edx
  80226c:	89 f1                	mov    %esi,%ecx
  80226e:	09 fa                	or     %edi,%edx
  802270:	8b 3c 24             	mov    (%esp),%edi
  802273:	d3 e0                	shl    %cl,%eax
  802275:	89 54 24 08          	mov    %edx,0x8(%esp)
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802283:	89 fa                	mov    %edi,%edx
  802285:	d3 ea                	shr    %cl,%edx
  802287:	89 f1                	mov    %esi,%ecx
  802289:	d3 e7                	shl    %cl,%edi
  80228b:	89 e9                	mov    %ebp,%ecx
  80228d:	d3 e8                	shr    %cl,%eax
  80228f:	09 c7                	or     %eax,%edi
  802291:	89 f8                	mov    %edi,%eax
  802293:	f7 74 24 08          	divl   0x8(%esp)
  802297:	89 d5                	mov    %edx,%ebp
  802299:	89 c7                	mov    %eax,%edi
  80229b:	f7 64 24 0c          	mull   0xc(%esp)
  80229f:	39 d5                	cmp    %edx,%ebp
  8022a1:	89 14 24             	mov    %edx,(%esp)
  8022a4:	72 11                	jb     8022b7 <__udivdi3+0xc7>
  8022a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022aa:	89 f1                	mov    %esi,%ecx
  8022ac:	d3 e2                	shl    %cl,%edx
  8022ae:	39 c2                	cmp    %eax,%edx
  8022b0:	73 5e                	jae    802310 <__udivdi3+0x120>
  8022b2:	3b 2c 24             	cmp    (%esp),%ebp
  8022b5:	75 59                	jne    802310 <__udivdi3+0x120>
  8022b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8022ba:	31 f6                	xor    %esi,%esi
  8022bc:	89 f2                	mov    %esi,%edx
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	31 f6                	xor    %esi,%esi
  8022ca:	31 c0                	xor    %eax,%eax
  8022cc:	89 f2                	mov    %esi,%edx
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	31 f6                	xor    %esi,%esi
  8022dc:	89 f8                	mov    %edi,%eax
  8022de:	f7 f1                	div    %ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	83 c4 10             	add    $0x10,%esp
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f4:	76 0b                	jbe    802301 <__udivdi3+0x111>
  8022f6:	31 c0                	xor    %eax,%eax
  8022f8:	3b 14 24             	cmp    (%esp),%edx
  8022fb:	0f 83 37 ff ff ff    	jae    802238 <__udivdi3+0x48>
  802301:	b8 01 00 00 00       	mov    $0x1,%eax
  802306:	e9 2d ff ff ff       	jmp    802238 <__udivdi3+0x48>
  80230b:	90                   	nop
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 f8                	mov    %edi,%eax
  802312:	31 f6                	xor    %esi,%esi
  802314:	e9 1f ff ff ff       	jmp    802238 <__udivdi3+0x48>
  802319:	66 90                	xchg   %ax,%ax
  80231b:	66 90                	xchg   %ax,%ax
  80231d:	66 90                	xchg   %ax,%ax
  80231f:	90                   	nop

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	83 ec 20             	sub    $0x20,%esp
  802326:	8b 44 24 34          	mov    0x34(%esp),%eax
  80232a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802332:	89 c6                	mov    %eax,%esi
  802334:	89 44 24 10          	mov    %eax,0x10(%esp)
  802338:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80233c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802340:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802344:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802348:	89 74 24 18          	mov    %esi,0x18(%esp)
  80234c:	85 c0                	test   %eax,%eax
  80234e:	89 c2                	mov    %eax,%edx
  802350:	75 1e                	jne    802370 <__umoddi3+0x50>
  802352:	39 f7                	cmp    %esi,%edi
  802354:	76 52                	jbe    8023a8 <__umoddi3+0x88>
  802356:	89 c8                	mov    %ecx,%eax
  802358:	89 f2                	mov    %esi,%edx
  80235a:	f7 f7                	div    %edi
  80235c:	89 d0                	mov    %edx,%eax
  80235e:	31 d2                	xor    %edx,%edx
  802360:	83 c4 20             	add    $0x20,%esp
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
  802367:	89 f6                	mov    %esi,%esi
  802369:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802370:	39 f0                	cmp    %esi,%eax
  802372:	77 5c                	ja     8023d0 <__umoddi3+0xb0>
  802374:	0f bd e8             	bsr    %eax,%ebp
  802377:	83 f5 1f             	xor    $0x1f,%ebp
  80237a:	75 64                	jne    8023e0 <__umoddi3+0xc0>
  80237c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802380:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802384:	0f 86 f6 00 00 00    	jbe    802480 <__umoddi3+0x160>
  80238a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80238e:	0f 82 ec 00 00 00    	jb     802480 <__umoddi3+0x160>
  802394:	8b 44 24 14          	mov    0x14(%esp),%eax
  802398:	8b 54 24 18          	mov    0x18(%esp),%edx
  80239c:	83 c4 20             	add    $0x20,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	89 fd                	mov    %edi,%ebp
  8023ac:	75 0b                	jne    8023b9 <__umoddi3+0x99>
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f7                	div    %edi
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	f7 f5                	div    %ebp
  8023c1:	89 c8                	mov    %ecx,%eax
  8023c3:	f7 f5                	div    %ebp
  8023c5:	eb 95                	jmp    80235c <__umoddi3+0x3c>
  8023c7:	89 f6                	mov    %esi,%esi
  8023c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 20             	add    $0x20,%esp
  8023d7:	5e                   	pop    %esi
  8023d8:	5f                   	pop    %edi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
  8023db:	90                   	nop
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e5:	89 e9                	mov    %ebp,%ecx
  8023e7:	29 e8                	sub    %ebp,%eax
  8023e9:	d3 e2                	shl    %cl,%edx
  8023eb:	89 c7                	mov    %eax,%edi
  8023ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 c1                	mov    %eax,%ecx
  8023fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ff:	09 d1                	or     %edx,%ecx
  802401:	89 fa                	mov    %edi,%edx
  802403:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802407:	89 e9                	mov    %ebp,%ecx
  802409:	d3 e0                	shl    %cl,%eax
  80240b:	89 f9                	mov    %edi,%ecx
  80240d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802411:	89 f0                	mov    %esi,%eax
  802413:	d3 e8                	shr    %cl,%eax
  802415:	89 e9                	mov    %ebp,%ecx
  802417:	89 c7                	mov    %eax,%edi
  802419:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80241d:	d3 e6                	shl    %cl,%esi
  80241f:	89 d1                	mov    %edx,%ecx
  802421:	89 fa                	mov    %edi,%edx
  802423:	d3 e8                	shr    %cl,%eax
  802425:	89 e9                	mov    %ebp,%ecx
  802427:	09 f0                	or     %esi,%eax
  802429:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80242d:	f7 74 24 10          	divl   0x10(%esp)
  802431:	d3 e6                	shl    %cl,%esi
  802433:	89 d1                	mov    %edx,%ecx
  802435:	f7 64 24 0c          	mull   0xc(%esp)
  802439:	39 d1                	cmp    %edx,%ecx
  80243b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80243f:	89 d7                	mov    %edx,%edi
  802441:	89 c6                	mov    %eax,%esi
  802443:	72 0a                	jb     80244f <__umoddi3+0x12f>
  802445:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802449:	73 10                	jae    80245b <__umoddi3+0x13b>
  80244b:	39 d1                	cmp    %edx,%ecx
  80244d:	75 0c                	jne    80245b <__umoddi3+0x13b>
  80244f:	89 d7                	mov    %edx,%edi
  802451:	89 c6                	mov    %eax,%esi
  802453:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802457:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80245b:	89 ca                	mov    %ecx,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802463:	29 f0                	sub    %esi,%eax
  802465:	19 fa                	sbb    %edi,%edx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80246e:	89 d7                	mov    %edx,%edi
  802470:	d3 e7                	shl    %cl,%edi
  802472:	89 e9                	mov    %ebp,%ecx
  802474:	09 f8                	or     %edi,%eax
  802476:	d3 ea                	shr    %cl,%edx
  802478:	83 c4 20             	add    $0x20,%esp
  80247b:	5e                   	pop    %esi
  80247c:	5f                   	pop    %edi
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    
  80247f:	90                   	nop
  802480:	8b 74 24 10          	mov    0x10(%esp),%esi
  802484:	29 f9                	sub    %edi,%ecx
  802486:	19 c6                	sbb    %eax,%esi
  802488:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80248c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802490:	e9 ff fe ff ff       	jmp    802394 <__umoddi3+0x74>
