
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 5d 10 00 00       	call   8010a9 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80004e:	83 c4 08             	add    $0x8,%esp
  800051:	50                   	push   %eax
  800052:	68 00 22 80 00       	push   $0x802200
  800057:	e8 cc 01 00 00       	call   800228 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80005c:	e8 5f 0e 00 00       	call   800ec0 <fork>
  800061:	89 c7                	mov    %eax,%edi
  800063:	83 c4 10             	add    $0x10,%esp
  800066:	85 c0                	test   %eax,%eax
  800068:	79 12                	jns    80007c <primeproc+0x49>
		panic("fork: %i", id);
  80006a:	50                   	push   %eax
  80006b:	68 d9 25 80 00       	push   $0x8025d9
  800070:	6a 1a                	push   $0x1a
  800072:	68 04 22 80 00       	push   $0x802204
  800077:	e8 d3 00 00 00       	call   80014f <_panic>
	if (id == 0)
  80007c:	85 c0                	test   %eax,%eax
  80007e:	74 bf                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800080:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800083:	83 ec 04             	sub    $0x4,%esp
  800086:	6a 00                	push   $0x0
  800088:	6a 00                	push   $0x0
  80008a:	56                   	push   %esi
  80008b:	e8 19 10 00 00       	call   8010a9 <ipc_recv>
  800090:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800092:	99                   	cltd   
  800093:	f7 fb                	idiv   %ebx
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 d2                	test   %edx,%edx
  80009a:	74 e7                	je     800083 <primeproc+0x50>
			ipc_send(id, i, 0, 0);
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	51                   	push   %ecx
  8000a1:	57                   	push   %edi
  8000a2:	e8 68 10 00 00       	call   80110f <ipc_send>
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	eb d7                	jmp    800083 <primeproc+0x50>

008000ac <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000b1:	e8 0a 0e 00 00       	call   800ec0 <fork>
  8000b6:	89 c6                	mov    %eax,%esi
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	79 12                	jns    8000ce <umain+0x22>
		panic("fork: %i", id);
  8000bc:	50                   	push   %eax
  8000bd:	68 d9 25 80 00       	push   $0x8025d9
  8000c2:	6a 2d                	push   $0x2d
  8000c4:	68 04 22 80 00       	push   $0x802204
  8000c9:	e8 81 00 00 00       	call   80014f <_panic>
  8000ce:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 05                	jne    8000dc <umain+0x30>
		primeproc();
  8000d7:	e8 57 ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	53                   	push   %ebx
  8000e1:	56                   	push   %esi
  8000e2:	e8 28 10 00 00       	call   80110f <ipc_send>
		panic("fork: %i", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000e7:	83 c3 01             	add    $0x1,%ebx
		ipc_send(id, i, 0, 0);
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	eb ed                	jmp    8000dc <umain+0x30>

008000ef <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000fa:	e8 79 0a 00 00       	call   800b78 <sys_getenvid>
  8000ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  800104:	6b c0 78             	imul   $0x78,%eax,%eax
  800107:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800111:	85 db                	test   %ebx,%ebx
  800113:	7e 07                	jle    80011c <libmain+0x2d>
		binaryname = argv[0];
  800115:	8b 06                	mov    (%esi),%eax
  800117:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	e8 86 ff ff ff       	call   8000ac <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800126:	e8 0a 00 00 00       	call   800135 <exit>
  80012b:	83 c4 10             	add    $0x10,%esp
#endif
}
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013b:	e8 24 12 00 00       	call   801364 <close_all>
	sys_env_destroy(0);
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	6a 00                	push   $0x0
  800145:	e8 ed 09 00 00       	call   800b37 <sys_env_destroy>
  80014a:	83 c4 10             	add    $0x10,%esp
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800154:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800157:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015d:	e8 16 0a 00 00       	call   800b78 <sys_getenvid>
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	ff 75 0c             	pushl  0xc(%ebp)
  800168:	ff 75 08             	pushl  0x8(%ebp)
  80016b:	56                   	push   %esi
  80016c:	50                   	push   %eax
  80016d:	68 1c 22 80 00       	push   $0x80221c
  800172:	e8 b1 00 00 00       	call   800228 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800177:	83 c4 18             	add    $0x18,%esp
  80017a:	53                   	push   %ebx
  80017b:	ff 75 10             	pushl  0x10(%ebp)
  80017e:	e8 54 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 97 26 80 00 	movl   $0x802697,(%esp)
  80018a:	e8 99 00 00 00       	call   800228 <cprintf>
  80018f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800192:	cc                   	int3   
  800193:	eb fd                	jmp    800192 <_panic+0x43>

00800195 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	53                   	push   %ebx
  800199:	83 ec 04             	sub    $0x4,%esp
  80019c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019f:	8b 13                	mov    (%ebx),%edx
  8001a1:	8d 42 01             	lea    0x1(%edx),%eax
  8001a4:	89 03                	mov    %eax,(%ebx)
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b2:	75 1a                	jne    8001ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	68 ff 00 00 00       	push   $0xff
  8001bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 35 09 00 00       	call   800afa <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	ff 75 08             	pushl  0x8(%ebp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	68 95 01 80 00       	push   $0x800195
  800206:	e8 4f 01 00 00       	call   80035a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020b:	83 c4 08             	add    $0x8,%esp
  80020e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800214:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021a:	50                   	push   %eax
  80021b:	e8 da 08 00 00       	call   800afa <sys_cputs>

	return b.cnt;
}
  800220:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800231:	50                   	push   %eax
  800232:	ff 75 08             	pushl  0x8(%ebp)
  800235:	e8 9d ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 1c             	sub    $0x1c,%esp
  800245:	89 c7                	mov    %eax,%edi
  800247:	89 d6                	mov    %edx,%esi
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024f:	89 d1                	mov    %edx,%ecx
  800251:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800254:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800257:	8b 45 10             	mov    0x10(%ebp),%eax
  80025a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800260:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800267:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80026a:	72 05                	jb     800271 <printnum+0x35>
  80026c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80026f:	77 3e                	ja     8002af <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	83 eb 01             	sub    $0x1,%ebx
  80027a:	53                   	push   %ebx
  80027b:	50                   	push   %eax
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800282:	ff 75 e0             	pushl  -0x20(%ebp)
  800285:	ff 75 dc             	pushl  -0x24(%ebp)
  800288:	ff 75 d8             	pushl  -0x28(%ebp)
  80028b:	e8 c0 1c 00 00       	call   801f50 <__udivdi3>
  800290:	83 c4 18             	add    $0x18,%esp
  800293:	52                   	push   %edx
  800294:	50                   	push   %eax
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 9e ff ff ff       	call   80023c <printnum>
  80029e:	83 c4 20             	add    $0x20,%esp
  8002a1:	eb 13                	jmp    8002b6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	ff d7                	call   *%edi
  8002ac:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	85 db                	test   %ebx,%ebx
  8002b4:	7f ed                	jg     8002a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	83 ec 04             	sub    $0x4,%esp
  8002bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c9:	e8 b2 1d 00 00       	call   802080 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 3f 22 80 00 	movsbl 0x80223f(%eax),%eax
  8002d8:	50                   	push   %eax
  8002d9:	ff d7                	call   *%edi
  8002db:	83 c4 10             	add    $0x10,%esp
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	3b 50 04             	cmp    0x4(%eax),%edx
  80032f:	73 0a                	jae    80033b <sprintputch+0x1b>
		*b->buf++ = ch;
  800331:	8d 4a 01             	lea    0x1(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	88 02                	mov    %al,(%edx)
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800343:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800346:	50                   	push   %eax
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	ff 75 0c             	pushl  0xc(%ebp)
  80034d:	ff 75 08             	pushl  0x8(%ebp)
  800350:	e8 05 00 00 00       	call   80035a <vprintfmt>
	va_end(ap);
  800355:	83 c4 10             	add    $0x10,%esp
}
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
  800360:	83 ec 2c             	sub    $0x2c,%esp
  800363:	8b 75 08             	mov    0x8(%ebp),%esi
  800366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800369:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036c:	eb 12                	jmp    800380 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036e:	85 c0                	test   %eax,%eax
  800370:	0f 84 8d 03 00 00    	je     800703 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	53                   	push   %ebx
  80037a:	50                   	push   %eax
  80037b:	ff d6                	call   *%esi
  80037d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800380:	83 c7 01             	add    $0x1,%edi
  800383:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800387:	83 f8 25             	cmp    $0x25,%eax
  80038a:	75 e2                	jne    80036e <vprintfmt+0x14>
  80038c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800390:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	eb 07                	jmp    8003b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003af:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8d 47 01             	lea    0x1(%edi),%eax
  8003b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b9:	0f b6 07             	movzbl (%edi),%eax
  8003bc:	0f b6 c8             	movzbl %al,%ecx
  8003bf:	83 e8 23             	sub    $0x23,%eax
  8003c2:	3c 55                	cmp    $0x55,%al
  8003c4:	0f 87 1e 03 00 00    	ja     8006e8 <vprintfmt+0x38e>
  8003ca:	0f b6 c0             	movzbl %al,%eax
  8003cd:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003db:	eb d6                	jmp    8003b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003eb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ef:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f5:	83 fa 09             	cmp    $0x9,%edx
  8003f8:	77 38                	ja     800432 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fd:	eb e9                	jmp    8003e8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 48 04             	lea    0x4(%eax),%ecx
  800405:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800410:	eb 26                	jmp    800438 <vprintfmt+0xde>
  800412:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800415:	89 c8                	mov    %ecx,%eax
  800417:	c1 f8 1f             	sar    $0x1f,%eax
  80041a:	f7 d0                	not    %eax
  80041c:	21 c1                	and    %eax,%ecx
  80041e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	eb 8d                	jmp    8003b3 <vprintfmt+0x59>
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800429:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800430:	eb 81                	jmp    8003b3 <vprintfmt+0x59>
  800432:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800435:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 89 71 ff ff ff    	jns    8003b3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800442:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800448:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044f:	e9 5f ff ff ff       	jmp    8003b3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800454:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045a:	e9 54 ff ff ff       	jmp    8003b3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	53                   	push   %ebx
  80046c:	ff 30                	pushl  (%eax)
  80046e:	ff d6                	call   *%esi
			break;
  800470:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800476:	e9 05 ff ff ff       	jmp    800380 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 0f             	cmp    $0xf,%eax
  80048e:	7f 0b                	jg     80049b <vprintfmt+0x141>
  800490:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	75 18                	jne    8004b3 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80049b:	50                   	push   %eax
  80049c:	68 57 22 80 00       	push   $0x802257
  8004a1:	53                   	push   %ebx
  8004a2:	56                   	push   %esi
  8004a3:	e8 95 fe ff ff       	call   80033d <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ae:	e9 cd fe ff ff       	jmp    800380 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b3:	52                   	push   %edx
  8004b4:	68 e1 26 80 00       	push   $0x8026e1
  8004b9:	53                   	push   %ebx
  8004ba:	56                   	push   %esi
  8004bb:	e8 7d fe ff ff       	call   80033d <printfmt>
  8004c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c6:	e9 b5 fe ff ff       	jmp    800380 <vprintfmt+0x26>
  8004cb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 38                	mov    (%eax),%edi
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	75 05                	jne    8004e8 <vprintfmt+0x18e>
				p = "(null)";
  8004e3:	bf 50 22 80 00       	mov    $0x802250,%edi
			if (width > 0 && padc != '-')
  8004e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ec:	0f 84 91 00 00 00    	je     800583 <vprintfmt+0x229>
  8004f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004f6:	0f 8e 95 00 00 00    	jle    800591 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	51                   	push   %ecx
  800500:	57                   	push   %edi
  800501:	e8 85 02 00 00       	call   80078b <strnlen>
  800506:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800509:	29 c1                	sub    %eax,%ecx
  80050b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800511:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800515:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800518:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	eb 0f                	jmp    80052e <vprintfmt+0x1d4>
					putch(padc, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	ff 75 e0             	pushl  -0x20(%ebp)
  800526:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	83 ef 01             	sub    $0x1,%edi
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	85 ff                	test   %edi,%edi
  800530:	7f ed                	jg     80051f <vprintfmt+0x1c5>
  800532:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800535:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800538:	89 c8                	mov    %ecx,%eax
  80053a:	c1 f8 1f             	sar    $0x1f,%eax
  80053d:	f7 d0                	not    %eax
  80053f:	21 c8                	and    %ecx,%eax
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	89 cb                	mov    %ecx,%ebx
  80054e:	eb 4d                	jmp    80059d <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800550:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800554:	74 1b                	je     800571 <vprintfmt+0x217>
  800556:	0f be c0             	movsbl %al,%eax
  800559:	83 e8 20             	sub    $0x20,%eax
  80055c:	83 f8 5e             	cmp    $0x5e,%eax
  80055f:	76 10                	jbe    800571 <vprintfmt+0x217>
					putch('?', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0d                	jmp    80057e <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	52                   	push   %edx
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	eb 1a                	jmp    80059d <vprintfmt+0x243>
  800583:	89 75 08             	mov    %esi,0x8(%ebp)
  800586:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800589:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058f:	eb 0c                	jmp    80059d <vprintfmt+0x243>
  800591:	89 75 08             	mov    %esi,0x8(%ebp)
  800594:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059d:	83 c7 01             	add    $0x1,%edi
  8005a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a4:	0f be d0             	movsbl %al,%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	74 23                	je     8005ce <vprintfmt+0x274>
  8005ab:	85 f6                	test   %esi,%esi
  8005ad:	78 a1                	js     800550 <vprintfmt+0x1f6>
  8005af:	83 ee 01             	sub    $0x1,%esi
  8005b2:	79 9c                	jns    800550 <vprintfmt+0x1f6>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 20                	push   $0x20
  8005c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c6:	83 ef 01             	sub    $0x1,%edi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x27c>
  8005ce:	89 df                	mov    %ebx,%edi
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	e9 9e fd ff ff       	jmp    800380 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e2:	83 fa 01             	cmp    $0x1,%edx
  8005e5:	7e 16                	jle    8005fd <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 08             	lea    0x8(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fb:	eb 32                	jmp    80062f <vprintfmt+0x2d5>
	else if (lflag)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	74 18                	je     800619 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	c1 f9 1f             	sar    $0x1f,%ecx
  800614:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800617:	eb 16                	jmp    80062f <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 c1                	mov    %eax,%ecx
  800629:	c1 f9 1f             	sar    $0x1f,%ecx
  80062c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800632:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	79 74                	jns    8006b4 <vprintfmt+0x35a>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 2d                	push   $0x2d
  800646:	ff d6                	call   *%esi
				num = -(long long) num;
  800648:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064e:	f7 d8                	neg    %eax
  800650:	83 d2 00             	adc    $0x0,%edx
  800653:	f7 da                	neg    %edx
  800655:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800658:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065d:	eb 55                	jmp    8006b4 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 7f fc ff ff       	call   8002e6 <getuint>
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066c:	eb 46                	jmp    8006b4 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 70 fc ff ff       	call   8002e6 <getuint>
			base = 8;
  800676:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067b:	eb 37                	jmp    8006b4 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 30                	push   $0x30
  800683:	ff d6                	call   *%esi
			putch('x', putdat);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 78                	push   $0x78
  80068b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800696:	8b 00                	mov    (%eax),%eax
  800698:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a5:	eb 0d                	jmp    8006b4 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 37 fc ff ff       	call   8002e6 <getuint>
			base = 16;
  8006af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	51                   	push   %ecx
  8006c0:	52                   	push   %edx
  8006c1:	50                   	push   %eax
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 71 fb ff ff       	call   80023c <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	e9 aa fc ff ff       	jmp    800380 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	51                   	push   %ecx
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e3:	e9 98 fc ff ff       	jmp    800380 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x39e>
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x39b>
  8006fe:	e9 7d fc ff ff       	jmp    800380 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 22                	jle    800752 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 20 03 80 00       	push   $0x800320
  80073f:	e8 16 fc ff ff       	call   80035a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 05                	jmp    800757 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 9a ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c5:	84 db                	test   %bl,%bl
  8007c7:	75 ef                	jne    8007b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c5 ff ff ff       	call   8007ac <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	89 f3                	mov    %esi,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 0f                	jmp    800811 <strncpy+0x23>
		*dst++ = *src;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	0f b6 01             	movzbl (%ecx),%eax
  800808:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080b:	80 39 01             	cmpb   $0x1,(%ecx)
  80080e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	39 da                	cmp    %ebx,%edx
  800813:	75 ed                	jne    800802 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	89 f0                	mov    %esi,%eax
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x35>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 09                	jmp    800840 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 c2                	cmp    %eax,%edx
  800842:	74 09                	je     80084d <strlcpy+0x32>
  800844:	0f b6 19             	movzbl (%ecx),%ebx
  800847:	84 db                	test   %bl,%bl
  800849:	75 ec                	jne    800837 <strlcpy+0x1c>
  80084b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strcmp+0x11>
		p++, q++;
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x1c>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 ef                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x17>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 15                	je     8008ac <strncmp+0x30>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x26>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
  8008aa:	eb 05                	jmp    8008b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strchr+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0f                	je     8008d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 03                	jmp    8008e4 <strfind+0xf>
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	74 04                	je     8008ef <strfind+0x1a>
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 36                	je     800937 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 28                	jne    800931 <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 23                	jne    800931 <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800912:	89 d3                	mov    %edx,%ebx
  800914:	c1 e3 08             	shl    $0x8,%ebx
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 18             	shl    $0x18,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 10             	shl    $0x10,%eax
  800921:	09 f0                	or     %esi,%eax
  800923:	09 c2                	or     %eax,%edx
  800925:	89 d0                	mov    %edx,%eax
  800927:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800929:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80092c:	fc                   	cld    
  80092d:	f3 ab                	rep stos %eax,%es:(%edi)
  80092f:	eb 06                	jmp    800937 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	fc                   	cld    
  800935:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800937:	89 f8                	mov    %edi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094c:	39 c6                	cmp    %eax,%esi
  80094e:	73 35                	jae    800985 <memmove+0x47>
  800950:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800953:	39 d0                	cmp    %edx,%eax
  800955:	73 2e                	jae    800985 <memmove+0x47>
		s += n;
		d += n;
  800957:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x3b>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800979:	83 ef 01             	sub    $0x1,%edi
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1d                	jmp    8009a2 <memmove+0x64>
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	f6 c2 03             	test   $0x3,%dl
  80098c:	75 0f                	jne    80099d <memmove+0x5f>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0a                	jne    80099d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800993:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	ff 75 0c             	pushl  0xc(%ebp)
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 87 ff ff ff       	call   80093e <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 1a                	jmp    8009e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	74 0a                	je     8009df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 0f                	jmp    8009ee <memcmp+0x35>
		s1++, s2++;
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	75 e2                	jne    8009cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a00:	eb 07                	jmp    800a09 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a02:	38 08                	cmp    %cl,(%eax)
  800a04:	74 07                	je     800a0d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	72 f5                	jb     800a02 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	eb 03                	jmp    800a20 <strtol+0x11>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	0f b6 01             	movzbl (%ecx),%eax
  800a23:	3c 09                	cmp    $0x9,%al
  800a25:	74 f6                	je     800a1d <strtol+0xe>
  800a27:	3c 20                	cmp    $0x20,%al
  800a29:	74 f2                	je     800a1d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2b:	3c 2b                	cmp    $0x2b,%al
  800a2d:	75 0a                	jne    800a39 <strtol+0x2a>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
  800a37:	eb 10                	jmp    800a49 <strtol+0x3a>
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3e:	3c 2d                	cmp    $0x2d,%al
  800a40:	75 07                	jne    800a49 <strtol+0x3a>
		s++, neg = 1;
  800a42:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a45:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	0f 94 c0             	sete   %al
  800a4e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a54:	75 19                	jne    800a6f <strtol+0x60>
  800a56:	80 39 30             	cmpb   $0x30,(%ecx)
  800a59:	75 14                	jne    800a6f <strtol+0x60>
  800a5b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5f:	0f 85 8a 00 00 00    	jne    800aef <strtol+0xe0>
		s += 2, base = 16;
  800a65:	83 c1 02             	add    $0x2,%ecx
  800a68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6d:	eb 16                	jmp    800a85 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a6f:	84 c0                	test   %al,%al
  800a71:	74 12                	je     800a85 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a73:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7b:	75 08                	jne    800a85 <strtol+0x76>
		s++, base = 8;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8d:	0f b6 11             	movzbl (%ecx),%edx
  800a90:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a93:	89 f3                	mov    %esi,%ebx
  800a95:	80 fb 09             	cmp    $0x9,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0x93>
			dig = *s - '0';
  800a9a:	0f be d2             	movsbl %dl,%edx
  800a9d:	83 ea 30             	sub    $0x30,%edx
  800aa0:	eb 22                	jmp    800ac4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800aa2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 57             	sub    $0x57,%edx
  800ab2:	eb 10                	jmp    800ac4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 16                	ja     800ad4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 0f                	jge    800ad8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad2:	eb b9                	jmp    800a8d <strtol+0x7e>
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	eb 02                	jmp    800ada <strtol+0xcb>
  800ad8:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ade:	74 05                	je     800ae5 <strtol+0xd6>
		*endptr = (char *) s;
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	74 0c                	je     800af5 <strtol+0xe6>
  800ae9:	89 d0                	mov    %edx,%eax
  800aeb:	f7 d8                	neg    %eax
  800aed:	eb 06                	jmp    800af5 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aef:	84 c0                	test   %al,%al
  800af1:	75 8a                	jne    800a7d <strtol+0x6e>
  800af3:	eb 90                	jmp    800a85 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 01 00 00 00       	mov    $0x1,%eax
  800b28:	89 d1                	mov    %edx,%ecx
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	89 d7                	mov    %edx,%edi
  800b2e:	89 d6                	mov    %edx,%esi
  800b30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b45:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 cb                	mov    %ecx,%ebx
  800b4f:	89 cf                	mov    %ecx,%edi
  800b51:	89 ce                	mov    %ecx,%esi
  800b53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 17                	jle    800b70 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 5f 25 80 00       	push   $0x80255f
  800b64:	6a 23                	push   $0x23
  800b66:	68 7c 25 80 00       	push   $0x80257c
  800b6b:	e8 df f5 ff ff       	call   80014f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 02 00 00 00       	mov    $0x2,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_yield>:

void
sys_yield(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	be 00 00 00 00       	mov    $0x0,%esi
  800bc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	89 f7                	mov    %esi,%edi
  800bd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 5f 25 80 00       	push   $0x80255f
  800be5:	6a 23                	push   $0x23
  800be7:	68 7c 25 80 00       	push   $0x80257c
  800bec:	e8 5e f5 ff ff       	call   80014f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c13:	8b 75 18             	mov    0x18(%ebp),%esi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 5f 25 80 00       	push   $0x80255f
  800c27:	6a 23                	push   $0x23
  800c29:	68 7c 25 80 00       	push   $0x80257c
  800c2e:	e8 1c f5 ff ff       	call   80014f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 5f 25 80 00       	push   $0x80255f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 7c 25 80 00       	push   $0x80257c
  800c70:	e8 da f4 ff ff       	call   80014f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 5f 25 80 00       	push   $0x80255f
  800cab:	6a 23                	push   $0x23
  800cad:	68 7c 25 80 00       	push   $0x80257c
  800cb2:	e8 98 f4 ff ff       	call   80014f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 5f 25 80 00       	push   $0x80255f
  800ced:	6a 23                	push   $0x23
  800cef:	68 7c 25 80 00       	push   $0x80257c
  800cf4:	e8 56 f4 ff ff       	call   80014f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 5f 25 80 00       	push   $0x80255f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 7c 25 80 00       	push   $0x80257c
  800d36:	e8 14 f4 ff ff       	call   80014f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	be 00 00 00 00       	mov    $0x0,%esi
  800d4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d74:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 cb                	mov    %ecx,%ebx
  800d7e:	89 cf                	mov    %ecx,%edi
  800d80:	89 ce                	mov    %ecx,%esi
  800d82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 5f 25 80 00       	push   $0x80255f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 25 80 00       	push   $0x80257c
  800d9a:	e8 b0 f3 ff ff       	call   80014f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_gettime>:

int sys_gettime(void)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	ba 00 00 00 00       	mov    $0x0,%edx
  800db2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db7:	89 d1                	mov    %edx,%ecx
  800db9:	89 d3                	mov    %edx,%ebx
  800dbb:	89 d7                	mov    %edx,%edi
  800dbd:	89 d6                	mov    %edx,%esi
  800dbf:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800dd0:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800dd2:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dd6:	74 2e                	je     800e06 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800dd8:	89 c2                	mov    %eax,%edx
  800dda:	c1 ea 16             	shr    $0x16,%edx
  800ddd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800de4:	f6 c2 01             	test   $0x1,%dl
  800de7:	74 1d                	je     800e06 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	c1 ea 0c             	shr    $0xc,%edx
  800dee:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800df5:	f6 c1 01             	test   $0x1,%cl
  800df8:	74 0c                	je     800e06 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800dfa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800e01:	f6 c6 08             	test   $0x8,%dh
  800e04:	75 14                	jne    800e1a <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	68 8a 25 80 00       	push   $0x80258a
  800e0e:	6a 28                	push   $0x28
  800e10:	68 9c 25 80 00       	push   $0x80259c
  800e15:	e8 35 f3 ff ff       	call   80014f <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800e1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1f:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	6a 07                	push   $0x7
  800e26:	68 00 f0 7f 00       	push   $0x7ff000
  800e2b:	6a 00                	push   $0x0
  800e2d:	e8 84 fd ff ff       	call   800bb6 <sys_page_alloc>
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	79 14                	jns    800e4d <pgfault+0x87>
		panic("sys_page_alloc");
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 a7 25 80 00       	push   $0x8025a7
  800e41:	6a 2c                	push   $0x2c
  800e43:	68 9c 25 80 00       	push   $0x80259c
  800e48:	e8 02 f3 ff ff       	call   80014f <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 00 10 00 00       	push   $0x1000
  800e55:	53                   	push   %ebx
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	e8 46 fb ff ff       	call   8009a6 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e60:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e67:	53                   	push   %ebx
  800e68:	6a 00                	push   $0x0
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	6a 00                	push   $0x0
  800e71:	e8 83 fd ff ff       	call   800bf9 <sys_page_map>
  800e76:	83 c4 20             	add    $0x20,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	79 14                	jns    800e91 <pgfault+0xcb>
		panic("sys_page_map");
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	68 b6 25 80 00       	push   $0x8025b6
  800e85:	6a 2f                	push   $0x2f
  800e87:	68 9c 25 80 00       	push   $0x80259c
  800e8c:	e8 be f2 ff ff       	call   80014f <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 9b fd ff ff       	call   800c3b <sys_page_unmap>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 14                	jns    800ebb <pgfault+0xf5>
		panic("sys_page_unmap");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 c3 25 80 00       	push   $0x8025c3
  800eaf:	6a 31                	push   $0x31
  800eb1:	68 9c 25 80 00       	push   $0x80259c
  800eb6:	e8 94 f2 ff ff       	call   80014f <_panic>
	return;
}
  800ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800ec9:	68 c6 0d 80 00       	push   $0x800dc6
  800ece:	e8 aa 0f 00 00       	call   801e7d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ed3:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed8:	cd 30                	int    $0x30
  800eda:	89 c7                	mov    %eax,%edi
  800edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	75 21                	jne    800f07 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee6:	e8 8d fc ff ff       	call   800b78 <sys_getenvid>
  800eeb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef0:	6b c0 78             	imul   $0x78,%eax,%eax
  800ef3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	e9 80 01 00 00       	jmp    801087 <fork+0x1c7>
	}
	if (envid < 0)
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 12                	jns    800f1d <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800f0b:	50                   	push   %eax
  800f0c:	68 d2 25 80 00       	push   $0x8025d2
  800f11:	6a 70                	push   $0x70
  800f13:	68 9c 25 80 00       	push   $0x80259c
  800f18:	e8 32 f2 ff ff       	call   80014f <_panic>
  800f1d:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f22:	89 d8                	mov    %ebx,%eax
  800f24:	c1 e8 16             	shr    $0x16,%eax
  800f27:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2e:	a8 01                	test   $0x1,%al
  800f30:	0f 84 de 00 00 00    	je     801014 <fork+0x154>
  800f36:	89 de                	mov    %ebx,%esi
  800f38:	c1 ee 0c             	shr    $0xc,%esi
  800f3b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f42:	a8 01                	test   $0x1,%al
  800f44:	0f 84 ca 00 00 00    	je     801014 <fork+0x154>
  800f4a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f51:	a8 04                	test   $0x4,%al
  800f53:	0f 84 bb 00 00 00    	je     801014 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800f59:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800f60:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800f63:	f6 c4 04             	test   $0x4,%ah
  800f66:	74 34                	je     800f9c <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f70:	50                   	push   %eax
  800f71:	56                   	push   %esi
  800f72:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f75:	56                   	push   %esi
  800f76:	6a 00                	push   $0x0
  800f78:	e8 7c fc ff ff       	call   800bf9 <sys_page_map>
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	0f 84 8c 00 00 00    	je     801014 <fork+0x154>
        	panic("duppage share");
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 e2 25 80 00       	push   $0x8025e2
  800f90:	6a 48                	push   $0x48
  800f92:	68 9c 25 80 00       	push   $0x80259c
  800f97:	e8 b3 f1 ff ff       	call   80014f <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f9c:	a9 02 08 00 00       	test   $0x802,%eax
  800fa1:	74 5d                	je     801000 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	68 05 08 00 00       	push   $0x805
  800fab:	56                   	push   %esi
  800fac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800faf:	56                   	push   %esi
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 42 fc ff ff       	call   800bf9 <sys_page_map>
  800fb7:	83 c4 20             	add    $0x20,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 14                	jns    800fd2 <fork+0x112>
			panic("error");
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	68 6c 22 80 00       	push   $0x80226c
  800fc6:	6a 4b                	push   $0x4b
  800fc8:	68 9c 25 80 00       	push   $0x80259c
  800fcd:	e8 7d f1 ff ff       	call   80014f <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	68 05 08 00 00       	push   $0x805
  800fda:	56                   	push   %esi
  800fdb:	6a 00                	push   $0x0
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 14 fc ff ff       	call   800bf9 <sys_page_map>
  800fe5:	83 c4 20             	add    $0x20,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	79 28                	jns    801014 <fork+0x154>
			panic("error");
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 6c 22 80 00       	push   $0x80226c
  800ff4:	6a 4d                	push   $0x4d
  800ff6:	68 9c 25 80 00       	push   $0x80259c
  800ffb:	e8 4f f1 ff ff       	call   80014f <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	6a 05                	push   $0x5
  801005:	56                   	push   %esi
  801006:	ff 75 e4             	pushl  -0x1c(%ebp)
  801009:	56                   	push   %esi
  80100a:	6a 00                	push   $0x0
  80100c:	e8 e8 fb ff ff       	call   800bf9 <sys_page_map>
  801011:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801014:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101a:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  801020:	0f 85 fc fe ff ff    	jne    800f22 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	6a 07                	push   $0x7
  80102b:	68 00 f0 7f ee       	push   $0xee7ff000
  801030:	57                   	push   %edi
  801031:	e8 80 fb ff ff       	call   800bb6 <sys_page_alloc>
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 14                	jns    801051 <fork+0x191>
		panic("1");
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	68 f0 25 80 00       	push   $0x8025f0
  801045:	6a 78                	push   $0x78
  801047:	68 9c 25 80 00       	push   $0x80259c
  80104c:	e8 fe f0 ff ff       	call   80014f <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	68 ec 1e 80 00       	push   $0x801eec
  801059:	57                   	push   %edi
  80105a:	e8 a2 fc ff ff       	call   800d01 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80105f:	83 c4 08             	add    $0x8,%esp
  801062:	6a 02                	push   $0x2
  801064:	57                   	push   %edi
  801065:	e8 13 fc ff ff       	call   800c7d <sys_env_set_status>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 14                	jns    801085 <fork+0x1c5>
		panic("sys_env_set_status");
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	68 f2 25 80 00       	push   $0x8025f2
  801079:	6a 7d                	push   $0x7d
  80107b:	68 9c 25 80 00       	push   $0x80259c
  801080:	e8 ca f0 ff ff       	call   80014f <_panic>

	return envid;
  801085:	89 f8                	mov    %edi,%eax
}
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <sfork>:

// Challenge!
int
sfork(void)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801095:	68 05 26 80 00       	push   $0x802605
  80109a:	68 86 00 00 00       	push   $0x86
  80109f:	68 9c 25 80 00       	push   $0x80259c
  8010a4:	e8 a6 f0 ff ff       	call   80014f <_panic>

008010a9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  8010b7:	85 f6                	test   %esi,%esi
  8010b9:	74 06                	je     8010c1 <ipc_recv+0x18>
  8010bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8010c1:	85 db                	test   %ebx,%ebx
  8010c3:	74 06                	je     8010cb <ipc_recv+0x22>
  8010c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8010cb:	83 f8 01             	cmp    $0x1,%eax
  8010ce:	19 d2                	sbb    %edx,%edx
  8010d0:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	50                   	push   %eax
  8010d6:	e8 8b fc ff ff       	call   800d66 <sys_ipc_recv>
  8010db:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	85 d2                	test   %edx,%edx
  8010e2:	75 24                	jne    801108 <ipc_recv+0x5f>
	if (from_env_store)
  8010e4:	85 f6                	test   %esi,%esi
  8010e6:	74 0a                	je     8010f2 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  8010e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ed:	8b 40 70             	mov    0x70(%eax),%eax
  8010f0:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8010f2:	85 db                	test   %ebx,%ebx
  8010f4:	74 0a                	je     801100 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  8010f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fb:	8b 40 74             	mov    0x74(%eax),%eax
  8010fe:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801100:	a1 04 40 80 00       	mov    0x804004,%eax
  801105:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801108:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	8b 7d 08             	mov    0x8(%ebp),%edi
  80111b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80111e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801121:	83 fb 01             	cmp    $0x1,%ebx
  801124:	19 c0                	sbb    %eax,%eax
  801126:	09 c3                	or     %eax,%ebx
  801128:	eb 1c                	jmp    801146 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80112a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80112d:	74 12                	je     801141 <ipc_send+0x32>
  80112f:	50                   	push   %eax
  801130:	68 1b 26 80 00       	push   $0x80261b
  801135:	6a 36                	push   $0x36
  801137:	68 32 26 80 00       	push   $0x802632
  80113c:	e8 0e f0 ff ff       	call   80014f <_panic>
		sys_yield();
  801141:	e8 51 fa ff ff       	call   800b97 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801146:	ff 75 14             	pushl  0x14(%ebp)
  801149:	53                   	push   %ebx
  80114a:	56                   	push   %esi
  80114b:	57                   	push   %edi
  80114c:	e8 f2 fb ff ff       	call   800d43 <sys_ipc_try_send>
		if (ret == 0) break;
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	75 d2                	jne    80112a <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80116b:	6b d0 78             	imul   $0x78,%eax,%edx
  80116e:	83 c2 50             	add    $0x50,%edx
  801171:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801177:	39 ca                	cmp    %ecx,%edx
  801179:	75 0d                	jne    801188 <ipc_find_env+0x28>
			return envs[i].env_id;
  80117b:	6b c0 78             	imul   $0x78,%eax,%eax
  80117e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801183:	8b 40 08             	mov    0x8(%eax),%eax
  801186:	eb 0e                	jmp    801196 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801188:	83 c0 01             	add    $0x1,%eax
  80118b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801190:	75 d9                	jne    80116b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801192:	66 b8 00 00          	mov    $0x0,%ax
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ae:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	c1 ea 16             	shr    $0x16,%edx
  8011cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 11                	je     8011ec <fd_alloc+0x2d>
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 0c             	shr    $0xc,%edx
  8011e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	75 09                	jne    8011f5 <fd_alloc+0x36>
			*fd_store = fd;
  8011ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f3:	eb 17                	jmp    80120c <fd_alloc+0x4d>
  8011f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ff:	75 c9                	jne    8011ca <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801201:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801207:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801214:	83 f8 1f             	cmp    $0x1f,%eax
  801217:	77 36                	ja     80124f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801219:	c1 e0 0c             	shl    $0xc,%eax
  80121c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801221:	89 c2                	mov    %eax,%edx
  801223:	c1 ea 16             	shr    $0x16,%edx
  801226:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	74 24                	je     801256 <fd_lookup+0x48>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 1a                	je     80125d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801243:	8b 55 0c             	mov    0xc(%ebp),%edx
  801246:	89 02                	mov    %eax,(%edx)
	return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb 13                	jmp    801262 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801254:	eb 0c                	jmp    801262 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125b:	eb 05                	jmp    801262 <fd_lookup+0x54>
  80125d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	ba b8 26 80 00       	mov    $0x8026b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801272:	eb 13                	jmp    801287 <dev_lookup+0x23>
  801274:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801277:	39 08                	cmp    %ecx,(%eax)
  801279:	75 0c                	jne    801287 <dev_lookup+0x23>
			*dev = devtab[i];
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	eb 2e                	jmp    8012b5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801287:	8b 02                	mov    (%edx),%eax
  801289:	85 c0                	test   %eax,%eax
  80128b:	75 e7                	jne    801274 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128d:	a1 04 40 80 00       	mov    0x804004,%eax
  801292:	8b 40 48             	mov    0x48(%eax),%eax
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	51                   	push   %ecx
  801299:	50                   	push   %eax
  80129a:	68 3c 26 80 00       	push   $0x80263c
  80129f:	e8 84 ef ff ff       	call   800228 <cprintf>
	*dev = 0;
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	56                   	push   %esi
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 10             	sub    $0x10,%esp
  8012bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cf:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d2:	50                   	push   %eax
  8012d3:	e8 36 ff ff ff       	call   80120e <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 05                	js     8012e4 <fd_close+0x2d>
	    || fd != fd2)
  8012df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e2:	74 0b                	je     8012ef <fd_close+0x38>
		return (must_exist ? r : 0);
  8012e4:	80 fb 01             	cmp    $0x1,%bl
  8012e7:	19 d2                	sbb    %edx,%edx
  8012e9:	f7 d2                	not    %edx
  8012eb:	21 d0                	and    %edx,%eax
  8012ed:	eb 41                	jmp    801330 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	ff 36                	pushl  (%esi)
  8012f8:	e8 67 ff ff ff       	call   801264 <dev_lookup>
  8012fd:	89 c3                	mov    %eax,%ebx
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 1a                	js     801320 <fd_close+0x69>
		if (dev->dev_close)
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801311:	85 c0                	test   %eax,%eax
  801313:	74 0b                	je     801320 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	56                   	push   %esi
  801319:	ff d0                	call   *%eax
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	56                   	push   %esi
  801324:	6a 00                	push   $0x0
  801326:	e8 10 f9 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	89 d8                	mov    %ebx,%eax
}
  801330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 c5 fe ff ff       	call   80120e <fd_lookup>
  801349:	89 c2                	mov    %eax,%edx
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	85 d2                	test   %edx,%edx
  801350:	78 10                	js     801362 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	6a 01                	push   $0x1
  801357:	ff 75 f4             	pushl  -0xc(%ebp)
  80135a:	e8 58 ff ff ff       	call   8012b7 <fd_close>
  80135f:	83 c4 10             	add    $0x10,%esp
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <close_all>:

void
close_all(void)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	53                   	push   %ebx
  801374:	e8 be ff ff ff       	call   801337 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801379:	83 c3 01             	add    $0x1,%ebx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	83 fb 20             	cmp    $0x20,%ebx
  801382:	75 ec                	jne    801370 <close_all+0xc>
		close(i);
}
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	57                   	push   %edi
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	83 ec 2c             	sub    $0x2c,%esp
  801392:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801395:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 6d fe ff ff       	call   80120e <fd_lookup>
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	83 c4 08             	add    $0x8,%esp
  8013a6:	85 d2                	test   %edx,%edx
  8013a8:	0f 88 c1 00 00 00    	js     80146f <dup+0xe6>
		return r;
	close(newfdnum);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	56                   	push   %esi
  8013b2:	e8 80 ff ff ff       	call   801337 <close>

	newfd = INDEX2FD(newfdnum);
  8013b7:	89 f3                	mov    %esi,%ebx
  8013b9:	c1 e3 0c             	shl    $0xc,%ebx
  8013bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c2:	83 c4 04             	add    $0x4,%esp
  8013c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c8:	e8 db fd ff ff       	call   8011a8 <fd2data>
  8013cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013cf:	89 1c 24             	mov    %ebx,(%esp)
  8013d2:	e8 d1 fd ff ff       	call   8011a8 <fd2data>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013dd:	89 f8                	mov    %edi,%eax
  8013df:	c1 e8 16             	shr    $0x16,%eax
  8013e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e9:	a8 01                	test   $0x1,%al
  8013eb:	74 37                	je     801424 <dup+0x9b>
  8013ed:	89 f8                	mov    %edi,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f9:	f6 c2 01             	test   $0x1,%dl
  8013fc:	74 26                	je     801424 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	25 07 0e 00 00       	and    $0xe07,%eax
  80140d:	50                   	push   %eax
  80140e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801411:	6a 00                	push   $0x0
  801413:	57                   	push   %edi
  801414:	6a 00                	push   $0x0
  801416:	e8 de f7 ff ff       	call   800bf9 <sys_page_map>
  80141b:	89 c7                	mov    %eax,%edi
  80141d:	83 c4 20             	add    $0x20,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	78 2e                	js     801452 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801427:	89 d0                	mov    %edx,%eax
  801429:	c1 e8 0c             	shr    $0xc,%eax
  80142c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	25 07 0e 00 00       	and    $0xe07,%eax
  80143b:	50                   	push   %eax
  80143c:	53                   	push   %ebx
  80143d:	6a 00                	push   $0x0
  80143f:	52                   	push   %edx
  801440:	6a 00                	push   $0x0
  801442:	e8 b2 f7 ff ff       	call   800bf9 <sys_page_map>
  801447:	89 c7                	mov    %eax,%edi
  801449:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80144c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144e:	85 ff                	test   %edi,%edi
  801450:	79 1d                	jns    80146f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	53                   	push   %ebx
  801456:	6a 00                	push   $0x0
  801458:	e8 de f7 ff ff       	call   800c3b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	ff 75 d4             	pushl  -0x2c(%ebp)
  801463:	6a 00                	push   $0x0
  801465:	e8 d1 f7 ff ff       	call   800c3b <sys_page_unmap>
	return r;
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	89 f8                	mov    %edi,%eax
}
  80146f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 14             	sub    $0x14,%esp
  80147e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801481:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	53                   	push   %ebx
  801486:	e8 83 fd ff ff       	call   80120e <fd_lookup>
  80148b:	83 c4 08             	add    $0x8,%esp
  80148e:	89 c2                	mov    %eax,%edx
  801490:	85 c0                	test   %eax,%eax
  801492:	78 6d                	js     801501 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149e:	ff 30                	pushl  (%eax)
  8014a0:	e8 bf fd ff ff       	call   801264 <dev_lookup>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 4c                	js     8014f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014af:	8b 42 08             	mov    0x8(%edx),%eax
  8014b2:	83 e0 03             	and    $0x3,%eax
  8014b5:	83 f8 01             	cmp    $0x1,%eax
  8014b8:	75 21                	jne    8014db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bf:	8b 40 48             	mov    0x48(%eax),%eax
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	50                   	push   %eax
  8014c7:	68 7d 26 80 00       	push   $0x80267d
  8014cc:	e8 57 ed ff ff       	call   800228 <cprintf>
		return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d9:	eb 26                	jmp    801501 <read+0x8a>
	}
	if (!dev->dev_read)
  8014db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014de:	8b 40 08             	mov    0x8(%eax),%eax
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	74 17                	je     8014fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	ff 75 10             	pushl  0x10(%ebp)
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	52                   	push   %edx
  8014ef:	ff d0                	call   *%eax
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	eb 09                	jmp    801501 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	eb 05                	jmp    801501 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801501:	89 d0                	mov    %edx,%eax
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	8b 7d 08             	mov    0x8(%ebp),%edi
  801514:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801517:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151c:	eb 21                	jmp    80153f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	89 f0                	mov    %esi,%eax
  801523:	29 d8                	sub    %ebx,%eax
  801525:	50                   	push   %eax
  801526:	89 d8                	mov    %ebx,%eax
  801528:	03 45 0c             	add    0xc(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	57                   	push   %edi
  80152d:	e8 45 ff ff ff       	call   801477 <read>
		if (m < 0)
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 0c                	js     801545 <readn+0x3d>
			return m;
		if (m == 0)
  801539:	85 c0                	test   %eax,%eax
  80153b:	74 06                	je     801543 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153d:	01 c3                	add    %eax,%ebx
  80153f:	39 f3                	cmp    %esi,%ebx
  801541:	72 db                	jb     80151e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801543:	89 d8                	mov    %ebx,%eax
}
  801545:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 14             	sub    $0x14,%esp
  801554:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	53                   	push   %ebx
  80155c:	e8 ad fc ff ff       	call   80120e <fd_lookup>
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	89 c2                	mov    %eax,%edx
  801566:	85 c0                	test   %eax,%eax
  801568:	78 68                	js     8015d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	ff 30                	pushl  (%eax)
  801576:	e8 e9 fc ff ff       	call   801264 <dev_lookup>
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 47                	js     8015c9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801589:	75 21                	jne    8015ac <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158b:	a1 04 40 80 00       	mov    0x804004,%eax
  801590:	8b 40 48             	mov    0x48(%eax),%eax
  801593:	83 ec 04             	sub    $0x4,%esp
  801596:	53                   	push   %ebx
  801597:	50                   	push   %eax
  801598:	68 99 26 80 00       	push   $0x802699
  80159d:	e8 86 ec ff ff       	call   800228 <cprintf>
		return -E_INVAL;
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015aa:	eb 26                	jmp    8015d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015af:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b2:	85 d2                	test   %edx,%edx
  8015b4:	74 17                	je     8015cd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b6:	83 ec 04             	sub    $0x4,%esp
  8015b9:	ff 75 10             	pushl  0x10(%ebp)
  8015bc:	ff 75 0c             	pushl  0xc(%ebp)
  8015bf:	50                   	push   %eax
  8015c0:	ff d2                	call   *%edx
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	eb 09                	jmp    8015d2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	89 c2                	mov    %eax,%edx
  8015cb:	eb 05                	jmp    8015d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d2:	89 d0                	mov    %edx,%eax
  8015d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	e8 23 fc ff ff       	call   80120e <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 0e                	js     801600 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 14             	sub    $0x14,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	53                   	push   %ebx
  801611:	e8 f8 fb ff ff       	call   80120e <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	89 c2                	mov    %eax,%edx
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 65                	js     801684 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	ff 30                	pushl  (%eax)
  80162b:	e8 34 fc ff ff       	call   801264 <dev_lookup>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 44                	js     80167b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163e:	75 21                	jne    801661 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801640:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801645:	8b 40 48             	mov    0x48(%eax),%eax
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	53                   	push   %ebx
  80164c:	50                   	push   %eax
  80164d:	68 5c 26 80 00       	push   $0x80265c
  801652:	e8 d1 eb ff ff       	call   800228 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165f:	eb 23                	jmp    801684 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801664:	8b 52 18             	mov    0x18(%edx),%edx
  801667:	85 d2                	test   %edx,%edx
  801669:	74 14                	je     80167f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	50                   	push   %eax
  801672:	ff d2                	call   *%edx
  801674:	89 c2                	mov    %eax,%edx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	eb 09                	jmp    801684 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	eb 05                	jmp    801684 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801684:	89 d0                	mov    %edx,%eax
  801686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
  801692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801695:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	ff 75 08             	pushl  0x8(%ebp)
  80169c:	e8 6d fb ff ff       	call   80120e <fd_lookup>
  8016a1:	83 c4 08             	add    $0x8,%esp
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 58                	js     801702 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b4:	ff 30                	pushl  (%eax)
  8016b6:	e8 a9 fb ff ff       	call   801264 <dev_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 37                	js     8016f9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c9:	74 32                	je     8016fd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d5:	00 00 00 
	stat->st_isdir = 0;
  8016d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016df:	00 00 00 
	stat->st_dev = dev;
  8016e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ef:	ff 50 14             	call   *0x14(%eax)
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb 09                	jmp    801702 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	eb 05                	jmp    801702 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801702:	89 d0                	mov    %edx,%eax
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	56                   	push   %esi
  80170d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	6a 00                	push   $0x0
  801713:	ff 75 08             	pushl  0x8(%ebp)
  801716:	e8 e7 01 00 00       	call   801902 <open>
  80171b:	89 c3                	mov    %eax,%ebx
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 db                	test   %ebx,%ebx
  801722:	78 1b                	js     80173f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	53                   	push   %ebx
  80172b:	e8 5b ff ff ff       	call   80168b <fstat>
  801730:	89 c6                	mov    %eax,%esi
	close(fd);
  801732:	89 1c 24             	mov    %ebx,(%esp)
  801735:	e8 fd fb ff ff       	call   801337 <close>
	return r;
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	89 f0                	mov    %esi,%eax
}
  80173f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	89 c6                	mov    %eax,%esi
  80174d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801756:	75 12                	jne    80176a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	6a 03                	push   $0x3
  80175d:	e8 fe f9 ff ff       	call   801160 <ipc_find_env>
  801762:	a3 00 40 80 00       	mov    %eax,0x804000
  801767:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176a:	6a 07                	push   $0x7
  80176c:	68 00 50 80 00       	push   $0x805000
  801771:	56                   	push   %esi
  801772:	ff 35 00 40 80 00    	pushl  0x804000
  801778:	e8 92 f9 ff ff       	call   80110f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177d:	83 c4 0c             	add    $0xc,%esp
  801780:	6a 00                	push   $0x0
  801782:	53                   	push   %ebx
  801783:	6a 00                	push   $0x0
  801785:	e8 1f f9 ff ff       	call   8010a9 <ipc_recv>
}
  80178a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b4:	e8 8d ff ff ff       	call   801746 <fsipc>
}
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d6:	e8 6b ff ff ff       	call   801746 <fsipc>
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 04             	sub    $0x4,%esp
  8017e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fc:	e8 45 ff ff ff       	call   801746 <fsipc>
  801801:	89 c2                	mov    %eax,%edx
  801803:	85 d2                	test   %edx,%edx
  801805:	78 2c                	js     801833 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	53                   	push   %ebx
  801810:	e8 97 ef ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801815:	a1 80 50 80 00       	mov    0x805080,%eax
  80181a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801820:	a1 84 50 80 00       	mov    0x805084,%eax
  801825:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801841:	8b 55 08             	mov    0x8(%ebp),%edx
  801844:	8b 52 0c             	mov    0xc(%edx),%edx
  801847:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80184d:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801852:	76 05                	jbe    801859 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801854:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801859:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	50                   	push   %eax
  801862:	ff 75 0c             	pushl  0xc(%ebp)
  801865:	68 08 50 80 00       	push   $0x805008
  80186a:	e8 cf f0 ff ff       	call   80093e <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 04 00 00 00       	mov    $0x4,%eax
  801879:	e8 c8 fe ff ff       	call   801746 <fsipc>
	return write;
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 40 0c             	mov    0xc(%eax),%eax
  80188e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801893:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a3:	e8 9e fe ff ff       	call   801746 <fsipc>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 4b                	js     8018f9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ae:	39 c6                	cmp    %eax,%esi
  8018b0:	73 16                	jae    8018c8 <devfile_read+0x48>
  8018b2:	68 c8 26 80 00       	push   $0x8026c8
  8018b7:	68 cf 26 80 00       	push   $0x8026cf
  8018bc:	6a 7c                	push   $0x7c
  8018be:	68 e4 26 80 00       	push   $0x8026e4
  8018c3:	e8 87 e8 ff ff       	call   80014f <_panic>
	assert(r <= PGSIZE);
  8018c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cd:	7e 16                	jle    8018e5 <devfile_read+0x65>
  8018cf:	68 ef 26 80 00       	push   $0x8026ef
  8018d4:	68 cf 26 80 00       	push   $0x8026cf
  8018d9:	6a 7d                	push   $0x7d
  8018db:	68 e4 26 80 00       	push   $0x8026e4
  8018e0:	e8 6a e8 ff ff       	call   80014f <_panic>
	memmove(buf, &fsipcbuf, r);
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	50                   	push   %eax
  8018e9:	68 00 50 80 00       	push   $0x805000
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	e8 48 f0 ff ff       	call   80093e <memmove>
	return r;
  8018f6:	83 c4 10             	add    $0x10,%esp
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 20             	sub    $0x20,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190c:	53                   	push   %ebx
  80190d:	e8 61 ee ff ff       	call   800773 <strlen>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191a:	7f 67                	jg     801983 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	e8 97 f8 ff ff       	call   8011bf <fd_alloc>
  801928:	83 c4 10             	add    $0x10,%esp
		return r;
  80192b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 57                	js     801988 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	e8 6d ee ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801942:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194a:	b8 01 00 00 00       	mov    $0x1,%eax
  80194f:	e8 f2 fd ff ff       	call   801746 <fsipc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	79 14                	jns    801971 <open+0x6f>
		fd_close(fd, 0);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	6a 00                	push   $0x0
  801962:	ff 75 f4             	pushl  -0xc(%ebp)
  801965:	e8 4d f9 ff ff       	call   8012b7 <fd_close>
		return r;
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	89 da                	mov    %ebx,%edx
  80196f:	eb 17                	jmp    801988 <open+0x86>
	}

	return fd2num(fd);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	e8 1c f8 ff ff       	call   801198 <fd2num>
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb 05                	jmp    801988 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801983:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801988:	89 d0                	mov    %edx,%eax
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	b8 08 00 00 00       	mov    $0x8,%eax
  80199f:	e8 a2 fd ff ff       	call   801746 <fsipc>
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 08             	pushl  0x8(%ebp)
  8019b4:	e8 ef f7 ff ff       	call   8011a8 <fd2data>
  8019b9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bb:	83 c4 08             	add    $0x8,%esp
  8019be:	68 fb 26 80 00       	push   $0x8026fb
  8019c3:	53                   	push   %ebx
  8019c4:	e8 e3 ed ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c9:	8b 56 04             	mov    0x4(%esi),%edx
  8019cc:	89 d0                	mov    %edx,%eax
  8019ce:	2b 06                	sub    (%esi),%eax
  8019d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019dd:	00 00 00 
	stat->st_dev = &devpipe;
  8019e0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e7:	30 80 00 
	return 0;
}
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a00:	53                   	push   %ebx
  801a01:	6a 00                	push   $0x0
  801a03:	e8 33 f2 ff ff       	call   800c3b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 98 f7 ff ff       	call   8011a8 <fd2data>
  801a10:	83 c4 08             	add    $0x8,%esp
  801a13:	50                   	push   %eax
  801a14:	6a 00                	push   $0x0
  801a16:	e8 20 f2 ff ff       	call   800c3b <sys_page_unmap>
}
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	57                   	push   %edi
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	83 ec 1c             	sub    $0x1c,%esp
  801a29:	89 c7                	mov    %eax,%edi
  801a2b:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a32:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	57                   	push   %edi
  801a39:	e8 d6 04 00 00       	call   801f14 <pageref>
  801a3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a41:	89 34 24             	mov    %esi,(%esp)
  801a44:	e8 cb 04 00 00       	call   801f14 <pageref>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a4f:	0f 94 c0             	sete   %al
  801a52:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a55:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a5e:	39 cb                	cmp    %ecx,%ebx
  801a60:	74 15                	je     801a77 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801a62:	8b 52 58             	mov    0x58(%edx),%edx
  801a65:	50                   	push   %eax
  801a66:	52                   	push   %edx
  801a67:	53                   	push   %ebx
  801a68:	68 08 27 80 00       	push   $0x802708
  801a6d:	e8 b6 e7 ff ff       	call   800228 <cprintf>
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	eb b6                	jmp    801a2d <_pipeisclosed+0xd>
	}
}
  801a77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5f                   	pop    %edi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	57                   	push   %edi
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 28             	sub    $0x28,%esp
  801a88:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a8b:	56                   	push   %esi
  801a8c:	e8 17 f7 ff ff       	call   8011a8 <fd2data>
  801a91:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	bf 00 00 00 00       	mov    $0x0,%edi
  801a9b:	eb 4b                	jmp    801ae8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a9d:	89 da                	mov    %ebx,%edx
  801a9f:	89 f0                	mov    %esi,%eax
  801aa1:	e8 7a ff ff ff       	call   801a20 <_pipeisclosed>
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	75 48                	jne    801af2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aaa:	e8 e8 f0 ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aaf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab2:	8b 0b                	mov    (%ebx),%ecx
  801ab4:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab7:	39 d0                	cmp    %edx,%eax
  801ab9:	73 e2                	jae    801a9d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ac2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	c1 fa 1f             	sar    $0x1f,%edx
  801aca:	89 d1                	mov    %edx,%ecx
  801acc:	c1 e9 1b             	shr    $0x1b,%ecx
  801acf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ad2:	83 e2 1f             	and    $0x1f,%edx
  801ad5:	29 ca                	sub    %ecx,%edx
  801ad7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801adb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801adf:	83 c0 01             	add    $0x1,%eax
  801ae2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae5:	83 c7 01             	add    $0x1,%edi
  801ae8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aeb:	75 c2                	jne    801aaf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aed:	8b 45 10             	mov    0x10(%ebp),%eax
  801af0:	eb 05                	jmp    801af7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	57                   	push   %edi
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 18             	sub    $0x18,%esp
  801b08:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b0b:	57                   	push   %edi
  801b0c:	e8 97 f6 ff ff       	call   8011a8 <fd2data>
  801b11:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1b:	eb 3d                	jmp    801b5a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1d:	85 db                	test   %ebx,%ebx
  801b1f:	74 04                	je     801b25 <devpipe_read+0x26>
				return i;
  801b21:	89 d8                	mov    %ebx,%eax
  801b23:	eb 44                	jmp    801b69 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b25:	89 f2                	mov    %esi,%edx
  801b27:	89 f8                	mov    %edi,%eax
  801b29:	e8 f2 fe ff ff       	call   801a20 <_pipeisclosed>
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	75 32                	jne    801b64 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b32:	e8 60 f0 ff ff       	call   800b97 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b37:	8b 06                	mov    (%esi),%eax
  801b39:	3b 46 04             	cmp    0x4(%esi),%eax
  801b3c:	74 df                	je     801b1d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3e:	99                   	cltd   
  801b3f:	c1 ea 1b             	shr    $0x1b,%edx
  801b42:	01 d0                	add    %edx,%eax
  801b44:	83 e0 1f             	and    $0x1f,%eax
  801b47:	29 d0                	sub    %edx,%eax
  801b49:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b51:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b54:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b57:	83 c3 01             	add    $0x1,%ebx
  801b5a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b5d:	75 d8                	jne    801b37 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b62:	eb 05                	jmp    801b69 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5f                   	pop    %edi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7c:	50                   	push   %eax
  801b7d:	e8 3d f6 ff ff       	call   8011bf <fd_alloc>
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	89 c2                	mov    %eax,%edx
  801b87:	85 c0                	test   %eax,%eax
  801b89:	0f 88 2c 01 00 00    	js     801cbb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8f:	83 ec 04             	sub    $0x4,%esp
  801b92:	68 07 04 00 00       	push   $0x407
  801b97:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 15 f0 ff ff       	call   800bb6 <sys_page_alloc>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	0f 88 0d 01 00 00    	js     801cbb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	e8 05 f6 ff ff       	call   8011bf <fd_alloc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 e2 00 00 00    	js     801ca9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc7:	83 ec 04             	sub    $0x4,%esp
  801bca:	68 07 04 00 00       	push   $0x407
  801bcf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 dd ef ff ff       	call   800bb6 <sys_page_alloc>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	0f 88 c3 00 00 00    	js     801ca9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bec:	e8 b7 f5 ff ff       	call   8011a8 <fd2data>
  801bf1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf3:	83 c4 0c             	add    $0xc,%esp
  801bf6:	68 07 04 00 00       	push   $0x407
  801bfb:	50                   	push   %eax
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 b3 ef ff ff       	call   800bb6 <sys_page_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 89 00 00 00    	js     801c99 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 f0             	pushl  -0x10(%ebp)
  801c16:	e8 8d f5 ff ff       	call   8011a8 <fd2data>
  801c1b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c22:	50                   	push   %eax
  801c23:	6a 00                	push   $0x0
  801c25:	56                   	push   %esi
  801c26:	6a 00                	push   $0x0
  801c28:	e8 cc ef ff ff       	call   800bf9 <sys_page_map>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 20             	add    $0x20,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	78 55                	js     801c8b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c36:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c44:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c4b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c54:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c59:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c60:	83 ec 0c             	sub    $0xc,%esp
  801c63:	ff 75 f4             	pushl  -0xc(%ebp)
  801c66:	e8 2d f5 ff ff       	call   801198 <fd2num>
  801c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c70:	83 c4 04             	add    $0x4,%esp
  801c73:	ff 75 f0             	pushl  -0x10(%ebp)
  801c76:	e8 1d f5 ff ff       	call   801198 <fd2num>
  801c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	ba 00 00 00 00       	mov    $0x0,%edx
  801c89:	eb 30                	jmp    801cbb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c8b:	83 ec 08             	sub    $0x8,%esp
  801c8e:	56                   	push   %esi
  801c8f:	6a 00                	push   $0x0
  801c91:	e8 a5 ef ff ff       	call   800c3b <sys_page_unmap>
  801c96:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c99:	83 ec 08             	sub    $0x8,%esp
  801c9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9f:	6a 00                	push   $0x0
  801ca1:	e8 95 ef ff ff       	call   800c3b <sys_page_unmap>
  801ca6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca9:	83 ec 08             	sub    $0x8,%esp
  801cac:	ff 75 f4             	pushl  -0xc(%ebp)
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 85 ef ff ff       	call   800c3b <sys_page_unmap>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccd:	50                   	push   %eax
  801cce:	ff 75 08             	pushl  0x8(%ebp)
  801cd1:	e8 38 f5 ff ff       	call   80120e <fd_lookup>
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	85 d2                	test   %edx,%edx
  801cdd:	78 18                	js     801cf7 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce5:	e8 be f4 ff ff       	call   8011a8 <fd2data>
	return _pipeisclosed(fd, p);
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	e8 2c fd ff ff       	call   801a20 <_pipeisclosed>
  801cf4:	83 c4 10             	add    $0x10,%esp
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d09:	68 39 27 80 00       	push   $0x802739
  801d0e:	ff 75 0c             	pushl  0xc(%ebp)
  801d11:	e8 96 ea ff ff       	call   8007ac <strcpy>
	return 0;
}
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d29:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d2e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d34:	eb 2e                	jmp    801d64 <devcons_write+0x47>
		m = n - tot;
  801d36:	8b 55 10             	mov    0x10(%ebp),%edx
  801d39:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801d3b:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801d40:	83 fa 7f             	cmp    $0x7f,%edx
  801d43:	77 02                	ja     801d47 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d45:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	56                   	push   %esi
  801d4b:	03 45 0c             	add    0xc(%ebp),%eax
  801d4e:	50                   	push   %eax
  801d4f:	57                   	push   %edi
  801d50:	e8 e9 eb ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  801d55:	83 c4 08             	add    $0x8,%esp
  801d58:	56                   	push   %esi
  801d59:	57                   	push   %edi
  801d5a:	e8 9b ed ff ff       	call   800afa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5f:	01 f3                	add    %esi,%ebx
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d69:	72 cb                	jb     801d36 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5e                   	pop    %esi
  801d70:	5f                   	pop    %edi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d82:	75 07                	jne    801d8b <devcons_read+0x18>
  801d84:	eb 28                	jmp    801dae <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d86:	e8 0c ee ff ff       	call   800b97 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d8b:	e8 88 ed ff ff       	call   800b18 <sys_cgetc>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	74 f2                	je     801d86 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 16                	js     801dae <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d98:	83 f8 04             	cmp    $0x4,%eax
  801d9b:	74 0c                	je     801da9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da0:	88 02                	mov    %al,(%edx)
	return 1;
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
  801da7:	eb 05                	jmp    801dae <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dbc:	6a 01                	push   $0x1
  801dbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	e8 33 ed ff ff       	call   800afa <sys_cputs>
  801dc7:	83 c4 10             	add    $0x10,%esp
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <getchar>:

int
getchar(void)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd2:	6a 01                	push   $0x1
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 98 f6 ff ff       	call   801477 <read>
	if (r < 0)
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	78 0f                	js     801df5 <getchar+0x29>
		return r;
	if (r < 1)
  801de6:	85 c0                	test   %eax,%eax
  801de8:	7e 06                	jle    801df0 <getchar+0x24>
		return -E_EOF;
	return c;
  801dea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dee:	eb 05                	jmp    801df5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e00:	50                   	push   %eax
  801e01:	ff 75 08             	pushl  0x8(%ebp)
  801e04:	e8 05 f4 ff ff       	call   80120e <fd_lookup>
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 11                	js     801e21 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e13:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e19:	39 10                	cmp    %edx,(%eax)
  801e1b:	0f 94 c0             	sete   %al
  801e1e:	0f b6 c0             	movzbl %al,%eax
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <opencons>:

int
opencons(void)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	e8 8d f3 ff ff       	call   8011bf <fd_alloc>
  801e32:	83 c4 10             	add    $0x10,%esp
		return r;
  801e35:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 3e                	js     801e79 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3b:	83 ec 04             	sub    $0x4,%esp
  801e3e:	68 07 04 00 00       	push   $0x407
  801e43:	ff 75 f4             	pushl  -0xc(%ebp)
  801e46:	6a 00                	push   $0x0
  801e48:	e8 69 ed ff ff       	call   800bb6 <sys_page_alloc>
  801e4d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e50:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 23                	js     801e79 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e56:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e64:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	50                   	push   %eax
  801e6f:	e8 24 f3 ff ff       	call   801198 <fd2num>
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	83 c4 10             	add    $0x10,%esp
}
  801e79:	89 d0                	mov    %edx,%eax
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801e83:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e8a:	75 2c                	jne    801eb8 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	6a 07                	push   $0x7
  801e91:	68 00 f0 7f ee       	push   $0xee7ff000
  801e96:	6a 00                	push   $0x0
  801e98:	e8 19 ed ff ff       	call   800bb6 <sys_page_alloc>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	79 14                	jns    801eb8 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	68 48 27 80 00       	push   $0x802748
  801eac:	6a 1f                	push   $0x1f
  801eae:	68 ac 27 80 00       	push   $0x8027ac
  801eb3:	e8 97 e2 ff ff       	call   80014f <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebb:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ec0:	83 ec 08             	sub    $0x8,%esp
  801ec3:	68 ec 1e 80 00       	push   $0x801eec
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 32 ee ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	79 14                	jns    801eea <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ed6:	83 ec 04             	sub    $0x4,%esp
  801ed9:	68 74 27 80 00       	push   $0x802774
  801ede:	6a 25                	push   $0x25
  801ee0:	68 ac 27 80 00       	push   $0x8027ac
  801ee5:	e8 65 e2 ff ff       	call   80014f <_panic>
}
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ef4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801ef7:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801ef9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801efd:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801f01:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801f02:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801f05:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801f07:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801f0a:	83 c4 04             	add    $0x4,%esp
	popal 
  801f0d:	61                   	popa   
	addl $4, %esp 
  801f0e:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801f11:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801f12:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801f13:	c3                   	ret    

00801f14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	c1 e8 16             	shr    $0x16,%eax
  801f1f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f26:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2b:	f6 c1 01             	test   $0x1,%cl
  801f2e:	74 1d                	je     801f4d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f30:	c1 ea 0c             	shr    $0xc,%edx
  801f33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f3a:	f6 c2 01             	test   $0x1,%dl
  801f3d:	74 0e                	je     801f4d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f3f:	c1 ea 0c             	shr    $0xc,%edx
  801f42:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f49:	ef 
  801f4a:	0f b7 c0             	movzwl %ax,%eax
}
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    
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
