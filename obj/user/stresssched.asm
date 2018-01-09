
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 9c 00 00 00       	call   8000cd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	envid_t parent = sys_getenvid();
  800038:	e8 19 0b 00 00       	call   800b56 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 55 0e 00 00       	call   800e9e <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
{
	int i, j;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0b                	jne    800067 <umain+0x34>
		sys_yield();
  80005c:	e8 14 0b 00 00       	call   800b75 <sys_yield>
		return;
  800061:	eb 63                	jmp    8000c6 <umain+0x93>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800063:	f3 90                	pause  
  800065:	eb 0c                	jmp    800073 <umain+0x40>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800067:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80006d:	6b d6 78             	imul   $0x78,%esi,%edx
  800070:	83 c2 50             	add    $0x50,%edx
  800073:	8b 82 04 00 c0 ee    	mov    -0x113ffffc(%edx),%eax
  800079:	85 c0                	test   %eax,%eax
  80007b:	75 e6                	jne    800063 <umain+0x30>
  80007d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800082:	e8 ee 0a 00 00       	call   800b75 <sys_yield>
  800087:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008c:	a1 04 40 80 00       	mov    0x804004,%eax
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  800099:	83 ea 01             	sub    $0x1,%edx
  80009c:	75 ee                	jne    80008c <umain+0x59>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  80009e:	83 eb 01             	sub    $0x1,%ebx
  8000a1:	75 df                	jne    800082 <umain+0x4f>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a8:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ad:	74 17                	je     8000c6 <umain+0x93>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000af:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b4:	50                   	push   %eax
  8000b5:	68 00 22 80 00       	push   $0x802200
  8000ba:	6a 20                	push   $0x20
  8000bc:	68 28 22 80 00       	push   $0x802228
  8000c1:	e8 67 00 00 00       	call   80012d <_panic>

	// Check that we see environments running on different CPUs
	//cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);

}
  8000c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
  8000d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d8:	e8 79 0a 00 00       	call   800b56 <sys_getenvid>
  8000dd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e2:	6b c0 78             	imul   $0x78,%eax,%eax
  8000e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ea:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	85 db                	test   %ebx,%ebx
  8000f1:	7e 07                	jle    8000fa <libmain+0x2d>
		binaryname = argv[0];
  8000f3:	8b 06                	mov    (%esi),%eax
  8000f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	e8 2f ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800104:	e8 0a 00 00 00       	call   800113 <exit>
  800109:	83 c4 10             	add    $0x10,%esp
#endif
}
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800119:	e8 35 11 00 00       	call   801253 <close_all>
	sys_env_destroy(0);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	6a 00                	push   $0x0
  800123:	e8 ed 09 00 00       	call   800b15 <sys_env_destroy>
  800128:	83 c4 10             	add    $0x10,%esp
}
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800132:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800135:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80013b:	e8 16 0a 00 00       	call   800b56 <sys_getenvid>
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	56                   	push   %esi
  80014a:	50                   	push   %eax
  80014b:	68 48 22 80 00       	push   $0x802248
  800150:	e8 b1 00 00 00       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800155:	83 c4 18             	add    $0x18,%esp
  800158:	53                   	push   %ebx
  800159:	ff 75 10             	pushl  0x10(%ebp)
  80015c:	e8 54 00 00 00       	call   8001b5 <vcprintf>
	cprintf("\n");
  800161:	c7 04 24 b7 26 80 00 	movl   $0x8026b7,(%esp)
  800168:	e8 99 00 00 00       	call   800206 <cprintf>
  80016d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800170:	cc                   	int3   
  800171:	eb fd                	jmp    800170 <_panic+0x43>

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 13                	mov    (%ebx),%edx
  80017f:	8d 42 01             	lea    0x1(%edx),%eax
  800182:	89 03                	mov    %eax,(%ebx)
  800184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800187:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	75 1a                	jne    8001ac <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	68 ff 00 00 00       	push   $0xff
  80019a:	8d 43 08             	lea    0x8(%ebx),%eax
  80019d:	50                   	push   %eax
  80019e:	e8 35 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  8001a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c5:	00 00 00 
	b.cnt = 0;
  8001c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d2:	ff 75 0c             	pushl  0xc(%ebp)
  8001d5:	ff 75 08             	pushl  0x8(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	68 73 01 80 00       	push   $0x800173
  8001e4:	e8 4f 01 00 00       	call   800338 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	83 c4 08             	add    $0x8,%esp
  8001ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 da 08 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  8001fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020f:	50                   	push   %eax
  800210:	ff 75 08             	pushl  0x8(%ebp)
  800213:	e8 9d ff ff ff       	call   8001b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
  800223:	89 c7                	mov    %eax,%edi
  800225:	89 d6                	mov    %edx,%esi
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 d1                	mov    %edx,%ecx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800235:	8b 45 10             	mov    0x10(%ebp),%eax
  800238:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800245:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800248:	72 05                	jb     80024f <printnum+0x35>
  80024a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024d:	77 3e                	ja     80028d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	83 eb 01             	sub    $0x1,%ebx
  800258:	53                   	push   %ebx
  800259:	50                   	push   %eax
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800260:	ff 75 e0             	pushl  -0x20(%ebp)
  800263:	ff 75 dc             	pushl  -0x24(%ebp)
  800266:	ff 75 d8             	pushl  -0x28(%ebp)
  800269:	e8 c2 1c 00 00       	call   801f30 <__udivdi3>
  80026e:	83 c4 18             	add    $0x18,%esp
  800271:	52                   	push   %edx
  800272:	50                   	push   %eax
  800273:	89 f2                	mov    %esi,%edx
  800275:	89 f8                	mov    %edi,%eax
  800277:	e8 9e ff ff ff       	call   80021a <printnum>
  80027c:	83 c4 20             	add    $0x20,%esp
  80027f:	eb 13                	jmp    800294 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	ff 75 18             	pushl  0x18(%ebp)
  800288:	ff d7                	call   *%edi
  80028a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028d:	83 eb 01             	sub    $0x1,%ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f ed                	jg     800281 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029e:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a7:	e8 b4 1d 00 00       	call   802060 <__umoddi3>
  8002ac:	83 c4 14             	add    $0x14,%esp
  8002af:	0f be 80 6b 22 80 00 	movsbl 0x80226b(%eax),%eax
  8002b6:	50                   	push   %eax
  8002b7:	ff d7                	call   *%edi
  8002b9:	83 c4 10             	add    $0x10,%esp
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c7:	83 fa 01             	cmp    $0x1,%edx
  8002ca:	7e 0e                	jle    8002da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	8b 52 04             	mov    0x4(%edx),%edx
  8002d8:	eb 22                	jmp    8002fc <getuint+0x38>
	else if (lflag)
  8002da:	85 d2                	test   %edx,%edx
  8002dc:	74 10                	je     8002ee <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	eb 0e                	jmp    8002fc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800304:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	3b 50 04             	cmp    0x4(%eax),%edx
  80030d:	73 0a                	jae    800319 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	88 02                	mov    %al,(%edx)
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800324:	50                   	push   %eax
  800325:	ff 75 10             	pushl  0x10(%ebp)
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	e8 05 00 00 00       	call   800338 <vprintfmt>
	va_end(ap);
  800333:	83 c4 10             	add    $0x10,%esp
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 2c             	sub    $0x2c,%esp
  800341:	8b 75 08             	mov    0x8(%ebp),%esi
  800344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800347:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034a:	eb 12                	jmp    80035e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034c:	85 c0                	test   %eax,%eax
  80034e:	0f 84 8d 03 00 00    	je     8006e1 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	53                   	push   %ebx
  800358:	50                   	push   %eax
  800359:	ff d6                	call   *%esi
  80035b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035e:	83 c7 01             	add    $0x1,%edi
  800361:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800365:	83 f8 25             	cmp    $0x25,%eax
  800368:	75 e2                	jne    80034c <vprintfmt+0x14>
  80036a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800375:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800383:	ba 00 00 00 00       	mov    $0x0,%edx
  800388:	eb 07                	jmp    800391 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8d 47 01             	lea    0x1(%edi),%eax
  800394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800397:	0f b6 07             	movzbl (%edi),%eax
  80039a:	0f b6 c8             	movzbl %al,%ecx
  80039d:	83 e8 23             	sub    $0x23,%eax
  8003a0:	3c 55                	cmp    $0x55,%al
  8003a2:	0f 87 1e 03 00 00    	ja     8006c6 <vprintfmt+0x38e>
  8003a8:	0f b6 c0             	movzbl %al,%eax
  8003ab:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b9:	eb d6                	jmp    800391 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d3:	83 fa 09             	cmp    $0x9,%edx
  8003d6:	77 38                	ja     800410 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003db:	eb e9                	jmp    8003c6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0xde>
  8003f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f3:	89 c8                	mov    %ecx,%eax
  8003f5:	c1 f8 1f             	sar    $0x1f,%eax
  8003f8:	f7 d0                	not    %eax
  8003fa:	21 c1                	and    %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8d                	jmp    800391 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040e:	eb 81                	jmp    800391 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 71 ff ff ff    	jns    800391 <vprintfmt+0x59>
				width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	e9 5f ff ff ff       	jmp    800391 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800438:	e9 54 ff ff ff       	jmp    800391 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 05 ff ff ff       	jmp    80035e <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x141>
  80046e:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 83 22 80 00       	push   $0x802283
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 95 fe ff ff       	call   80031b <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cd fe ff ff       	jmp    80035e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 01 27 80 00       	push   $0x802701
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7d fe ff ff       	call   80031b <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b5 fe ff ff       	jmp    80035e <vprintfmt+0x26>
  8004a9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004af:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 38                	mov    (%eax),%edi
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	75 05                	jne    8004c6 <vprintfmt+0x18e>
				p = "(null)";
  8004c1:	bf 7c 22 80 00       	mov    $0x80227c,%edi
			if (width > 0 && padc != '-')
  8004c6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ca:	0f 84 91 00 00 00    	je     800561 <vprintfmt+0x229>
  8004d0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d4:	0f 8e 95 00 00 00    	jle    80056f <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	51                   	push   %ecx
  8004de:	57                   	push   %edi
  8004df:	e8 85 02 00 00       	call   800769 <strnlen>
  8004e4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e7:	29 c1                	sub    %eax,%ecx
  8004e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	eb 0f                	jmp    80050c <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 75 e0             	pushl  -0x20(%ebp)
  800504:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 ff                	test   %edi,%edi
  80050e:	7f ed                	jg     8004fd <vprintfmt+0x1c5>
  800510:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800513:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800516:	89 c8                	mov    %ecx,%eax
  800518:	c1 f8 1f             	sar    $0x1f,%eax
  80051b:	f7 d0                	not    %eax
  80051d:	21 c8                	and    %ecx,%eax
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	89 cb                	mov    %ecx,%ebx
  80052c:	eb 4d                	jmp    80057b <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	74 1b                	je     80054f <vprintfmt+0x217>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 10                	jbe    80054f <vprintfmt+0x217>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	6a 3f                	push   $0x3f
  800547:	ff 55 08             	call   *0x8(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 0d                	jmp    80055c <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	52                   	push   %edx
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	eb 1a                	jmp    80057b <vprintfmt+0x243>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	eb 0c                	jmp    80057b <vprintfmt+0x243>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	83 c7 01             	add    $0x1,%edi
  80057e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800582:	0f be d0             	movsbl %al,%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	74 23                	je     8005ac <vprintfmt+0x274>
  800589:	85 f6                	test   %esi,%esi
  80058b:	78 a1                	js     80052e <vprintfmt+0x1f6>
  80058d:	83 ee 01             	sub    $0x1,%esi
  800590:	79 9c                	jns    80052e <vprintfmt+0x1f6>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	eb 18                	jmp    8005b4 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 20                	push   $0x20
  8005a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 ef 01             	sub    $0x1,%edi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x27c>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f e4                	jg     80059c <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 9e fd ff ff       	jmp    80035e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 fa 01             	cmp    $0x1,%edx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x2d5>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800610:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800618:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061c:	79 74                	jns    800692 <vprintfmt+0x35a>
				putch('-', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 2d                	push   $0x2d
  800624:	ff d6                	call   *%esi
				num = -(long long) num;
  800626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800629:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062c:	f7 d8                	neg    %eax
  80062e:	83 d2 00             	adc    $0x0,%edx
  800631:	f7 da                	neg    %edx
  800633:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800636:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063b:	eb 55                	jmp    800692 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063d:	8d 45 14             	lea    0x14(%ebp),%eax
  800640:	e8 7f fc ff ff       	call   8002c4 <getuint>
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064a:	eb 46                	jmp    800692 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 70 fc ff ff       	call   8002c4 <getuint>
			base = 8;
  800654:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800659:	eb 37                	jmp    800692 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 30                	push   $0x30
  800661:	ff d6                	call   *%esi
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 78                	push   $0x78
  800669:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800683:	eb 0d                	jmp    800692 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 37 fc ff ff       	call   8002c4 <getuint>
			base = 16;
  80068d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800699:	57                   	push   %edi
  80069a:	ff 75 e0             	pushl  -0x20(%ebp)
  80069d:	51                   	push   %ecx
  80069e:	52                   	push   %edx
  80069f:	50                   	push   %eax
  8006a0:	89 da                	mov    %ebx,%edx
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	e8 71 fb ff ff       	call   80021a <printnum>
			break;
  8006a9:	83 c4 20             	add    $0x20,%esp
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 aa fc ff ff       	jmp    80035e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	51                   	push   %ecx
  8006b9:	ff d6                	call   *%esi
			break;
  8006bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c1:	e9 98 fc ff ff       	jmp    80035e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 25                	push   $0x25
  8006cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 03                	jmp    8006d6 <vprintfmt+0x39e>
  8006d3:	83 ef 01             	sub    $0x1,%edi
  8006d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006da:	75 f7                	jne    8006d3 <vprintfmt+0x39b>
  8006dc:	e9 7d fc ff ff       	jmp    80035e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 26                	je     800730 <vsnprintf+0x47>
  80070a:	85 d2                	test   %edx,%edx
  80070c:	7e 22                	jle    800730 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070e:	ff 75 14             	pushl  0x14(%ebp)
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	68 fe 02 80 00       	push   $0x8002fe
  80071d:	e8 16 fc ff ff       	call   800338 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800725:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 05                	jmp    800735 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800740:	50                   	push   %eax
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	ff 75 0c             	pushl  0xc(%ebp)
  800747:	ff 75 08             	pushl  0x8(%ebp)
  80074a:	e8 9a ff ff ff       	call   8006e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 03                	jmp    800761 <strlen+0x10>
		n++;
  80075e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800765:	75 f7                	jne    80075e <strlen+0xd>
		n++;
	return n;
}
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	ba 00 00 00 00       	mov    $0x0,%edx
  800777:	eb 03                	jmp    80077c <strnlen+0x13>
		n++;
  800779:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	39 c2                	cmp    %eax,%edx
  80077e:	74 08                	je     800788 <strnlen+0x1f>
  800780:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800784:	75 f3                	jne    800779 <strnlen+0x10>
  800786:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800794:	89 c2                	mov    %eax,%edx
  800796:	83 c2 01             	add    $0x1,%edx
  800799:	83 c1 01             	add    $0x1,%ecx
  80079c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ef                	jne    800796 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a7:	5b                   	pop    %ebx
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b1:	53                   	push   %ebx
  8007b2:	e8 9a ff ff ff       	call   800751 <strlen>
  8007b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	01 d8                	add    %ebx,%eax
  8007bf:	50                   	push   %eax
  8007c0:	e8 c5 ff ff ff       	call   80078a <strcpy>
	return dst;
}
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	89 f3                	mov    %esi,%ebx
  8007d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	89 f2                	mov    %esi,%edx
  8007de:	eb 0f                	jmp    8007ef <strncpy+0x23>
		*dst++ = *src;
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	0f b6 01             	movzbl (%ecx),%eax
  8007e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ef:	39 da                	cmp    %ebx,%edx
  8007f1:	75 ed                	jne    8007e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	5b                   	pop    %ebx
  8007f6:	5e                   	pop    %esi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	8b 55 10             	mov    0x10(%ebp),%edx
  800807:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 21                	je     80082e <strlcpy+0x35>
  80080d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800811:	89 f2                	mov    %esi,%edx
  800813:	eb 09                	jmp    80081e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	83 c1 01             	add    $0x1,%ecx
  80081b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081e:	39 c2                	cmp    %eax,%edx
  800820:	74 09                	je     80082b <strlcpy+0x32>
  800822:	0f b6 19             	movzbl (%ecx),%ebx
  800825:	84 db                	test   %bl,%bl
  800827:	75 ec                	jne    800815 <strlcpy+0x1c>
  800829:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082e:	29 f0                	sub    %esi,%eax
}
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083d:	eb 06                	jmp    800845 <strcmp+0x11>
		p++, q++;
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800845:	0f b6 01             	movzbl (%ecx),%eax
  800848:	84 c0                	test   %al,%al
  80084a:	74 04                	je     800850 <strcmp+0x1c>
  80084c:	3a 02                	cmp    (%edx),%al
  80084e:	74 ef                	je     80083f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 c0             	movzbl %al,%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
  800864:	89 c3                	mov    %eax,%ebx
  800866:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800869:	eb 06                	jmp    800871 <strncmp+0x17>
		n--, p++, q++;
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800871:	39 d8                	cmp    %ebx,%eax
  800873:	74 15                	je     80088a <strncmp+0x30>
  800875:	0f b6 08             	movzbl (%eax),%ecx
  800878:	84 c9                	test   %cl,%cl
  80087a:	74 04                	je     800880 <strncmp+0x26>
  80087c:	3a 0a                	cmp    (%edx),%cl
  80087e:	74 eb                	je     80086b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800880:	0f b6 00             	movzbl (%eax),%eax
  800883:	0f b6 12             	movzbl (%edx),%edx
  800886:	29 d0                	sub    %edx,%eax
  800888:	eb 05                	jmp    80088f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089c:	eb 07                	jmp    8008a5 <strchr+0x13>
		if (*s == c)
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 0f                	je     8008b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 10             	movzbl (%eax),%edx
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	75 f2                	jne    80089e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 03                	jmp    8008c2 <strfind+0xf>
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 04                	je     8008cd <strfind+0x1a>
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	75 f2                	jne    8008bf <strfind+0xc>
			break;
	return (char *) s;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008db:	85 c9                	test   %ecx,%ecx
  8008dd:	74 36                	je     800915 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e5:	75 28                	jne    80090f <memset+0x40>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 23                	jne    80090f <memset+0x40>
		c &= 0xFF;
  8008ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	c1 e3 08             	shl    $0x8,%ebx
  8008f5:	89 d6                	mov    %edx,%esi
  8008f7:	c1 e6 18             	shl    $0x18,%esi
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	c1 e0 10             	shl    $0x10,%eax
  8008ff:	09 f0                	or     %esi,%eax
  800901:	09 c2                	or     %eax,%edx
  800903:	89 d0                	mov    %edx,%eax
  800905:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800907:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090a:	fc                   	cld    
  80090b:	f3 ab                	rep stos %eax,%es:(%edi)
  80090d:	eb 06                	jmp    800915 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	fc                   	cld    
  800913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800915:	89 f8                	mov    %edi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 75 0c             	mov    0xc(%ebp),%esi
  800927:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092a:	39 c6                	cmp    %eax,%esi
  80092c:	73 35                	jae    800963 <memmove+0x47>
  80092e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800931:	39 d0                	cmp    %edx,%eax
  800933:	73 2e                	jae    800963 <memmove+0x47>
		s += n;
		d += n;
  800935:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800938:	89 d6                	mov    %edx,%esi
  80093a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800942:	75 13                	jne    800957 <memmove+0x3b>
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 0e                	jne    800957 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800949:	83 ef 04             	sub    $0x4,%edi
  80094c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800952:	fd                   	std    
  800953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800955:	eb 09                	jmp    800960 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800957:	83 ef 01             	sub    $0x1,%edi
  80095a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095d:	fd                   	std    
  80095e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800960:	fc                   	cld    
  800961:	eb 1d                	jmp    800980 <memmove+0x64>
  800963:	89 f2                	mov    %esi,%edx
  800965:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	f6 c2 03             	test   $0x3,%dl
  80096a:	75 0f                	jne    80097b <memmove+0x5f>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 0a                	jne    80097b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800971:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800979:	eb 05                	jmp    800980 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800987:	ff 75 10             	pushl  0x10(%ebp)
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	ff 75 08             	pushl  0x8(%ebp)
  800990:	e8 87 ff ff ff       	call   80091c <memmove>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	89 c6                	mov    %eax,%esi
  8009a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	eb 1a                	jmp    8009c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a9:	0f b6 08             	movzbl (%eax),%ecx
  8009ac:	0f b6 1a             	movzbl (%edx),%ebx
  8009af:	38 d9                	cmp    %bl,%cl
  8009b1:	74 0a                	je     8009bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b3:	0f b6 c1             	movzbl %cl,%eax
  8009b6:	0f b6 db             	movzbl %bl,%ebx
  8009b9:	29 d8                	sub    %ebx,%eax
  8009bb:	eb 0f                	jmp    8009cc <memcmp+0x35>
		s1++, s2++;
  8009bd:	83 c0 01             	add    $0x1,%eax
  8009c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	39 f0                	cmp    %esi,%eax
  8009c5:	75 e2                	jne    8009a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d9:	89 c2                	mov    %eax,%edx
  8009db:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009de:	eb 07                	jmp    8009e7 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	38 08                	cmp    %cl,(%eax)
  8009e2:	74 07                	je     8009eb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 d0                	cmp    %edx,%eax
  8009e9:	72 f5                	jb     8009e0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f9:	eb 03                	jmp    8009fe <strtol+0x11>
		s++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f6                	je     8009fb <strtol+0xe>
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f2                	je     8009fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a09:	3c 2b                	cmp    $0x2b,%al
  800a0b:	75 0a                	jne    800a17 <strtol+0x2a>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
  800a15:	eb 10                	jmp    800a27 <strtol+0x3a>
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1c:	3c 2d                	cmp    $0x2d,%al
  800a1e:	75 07                	jne    800a27 <strtol+0x3a>
		s++, neg = 1;
  800a20:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a23:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	0f 94 c0             	sete   %al
  800a2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a32:	75 19                	jne    800a4d <strtol+0x60>
  800a34:	80 39 30             	cmpb   $0x30,(%ecx)
  800a37:	75 14                	jne    800a4d <strtol+0x60>
  800a39:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3d:	0f 85 8a 00 00 00    	jne    800acd <strtol+0xe0>
		s += 2, base = 16;
  800a43:	83 c1 02             	add    $0x2,%ecx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb 16                	jmp    800a63 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4d:	84 c0                	test   %al,%al
  800a4f:	74 12                	je     800a63 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	80 39 30             	cmpb   $0x30,(%ecx)
  800a59:	75 08                	jne    800a63 <strtol+0x76>
		s++, base = 8;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6b:	0f b6 11             	movzbl (%ecx),%edx
  800a6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 09             	cmp    $0x9,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x93>
			dig = *s - '0';
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 30             	sub    $0x30,%edx
  800a7e:	eb 22                	jmp    800aa2 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 57             	sub    $0x57,%edx
  800a90:	eb 10                	jmp    800aa2 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 16                	ja     800ab2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa5:	7d 0f                	jge    800ab6 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab0:	eb b9                	jmp    800a6b <strtol+0x7e>
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	eb 02                	jmp    800ab8 <strtol+0xcb>
  800ab6:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 05                	je     800ac3 <strtol+0xd6>
		*endptr = (char *) s;
  800abe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac3:	85 ff                	test   %edi,%edi
  800ac5:	74 0c                	je     800ad3 <strtol+0xe6>
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	f7 d8                	neg    %eax
  800acb:	eb 06                	jmp    800ad3 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	84 c0                	test   %al,%al
  800acf:	75 8a                	jne    800a5b <strtol+0x6e>
  800ad1:	eb 90                	jmp    800a63 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 03                	push   $0x3
  800b3d:	68 9f 25 80 00       	push   $0x80259f
  800b42:	6a 23                	push   $0x23
  800b44:	68 bc 25 80 00       	push   $0x8025bc
  800b49:	e8 df f5 ff ff       	call   80012d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 02 00 00 00       	mov    $0x2,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_yield>:

void
sys_yield(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb0:	89 f7                	mov    %esi,%edi
  800bb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 04                	push   $0x4
  800bbe:	68 9f 25 80 00       	push   $0x80259f
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 bc 25 80 00       	push   $0x8025bc
  800bca:	e8 5e f5 ff ff       	call   80012d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 05                	push   $0x5
  800c00:	68 9f 25 80 00       	push   $0x80259f
  800c05:	6a 23                	push   $0x23
  800c07:	68 bc 25 80 00       	push   $0x8025bc
  800c0c:	e8 1c f5 ff ff       	call   80012d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	89 df                	mov    %ebx,%edi
  800c34:	89 de                	mov    %ebx,%esi
  800c36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 06                	push   $0x6
  800c42:	68 9f 25 80 00       	push   $0x80259f
  800c47:	6a 23                	push   $0x23
  800c49:	68 bc 25 80 00       	push   $0x8025bc
  800c4e:	e8 da f4 ff ff       	call   80012d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 08                	push   $0x8
  800c84:	68 9f 25 80 00       	push   $0x80259f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 bc 25 80 00       	push   $0x8025bc
  800c90:	e8 98 f4 ff ff       	call   80012d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 09                	push   $0x9
  800cc6:	68 9f 25 80 00       	push   $0x80259f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 bc 25 80 00       	push   $0x8025bc
  800cd2:	e8 56 f4 ff ff       	call   80012d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0a                	push   $0xa
  800d08:	68 9f 25 80 00       	push   $0x80259f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 25 80 00       	push   $0x8025bc
  800d14:	e8 14 f4 ff ff       	call   80012d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d52:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 cb                	mov    %ecx,%ebx
  800d5c:	89 cf                	mov    %ecx,%edi
  800d5e:	89 ce                	mov    %ecx,%esi
  800d60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0d                	push   $0xd
  800d6c:	68 9f 25 80 00       	push   $0x80259f
  800d71:	6a 23                	push   $0x23
  800d73:	68 bc 25 80 00       	push   $0x8025bc
  800d78:	e8 b0 f3 ff ff       	call   80012d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_gettime>:

int sys_gettime(void)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800dae:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800db0:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800db4:	74 2e                	je     800de4 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 16             	shr    $0x16,%edx
  800dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	74 1d                	je     800de4 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	c1 ea 0c             	shr    $0xc,%edx
  800dcc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800dd3:	f6 c1 01             	test   $0x1,%cl
  800dd6:	74 0c                	je     800de4 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800dd8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ddf:	f6 c6 08             	test   $0x8,%dh
  800de2:	75 14                	jne    800df8 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	68 ca 25 80 00       	push   $0x8025ca
  800dec:	6a 28                	push   $0x28
  800dee:	68 dc 25 80 00       	push   $0x8025dc
  800df3:	e8 35 f3 ff ff       	call   80012d <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800df8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfd:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	6a 07                	push   $0x7
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 84 fd ff ff       	call   800b94 <sys_page_alloc>
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 14                	jns    800e2b <pgfault+0x87>
		panic("sys_page_alloc");
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 e7 25 80 00       	push   $0x8025e7
  800e1f:	6a 2c                	push   $0x2c
  800e21:	68 dc 25 80 00       	push   $0x8025dc
  800e26:	e8 02 f3 ff ff       	call   80012d <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	68 00 10 00 00       	push   $0x1000
  800e33:	53                   	push   %ebx
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	e8 46 fb ff ff       	call   800984 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e3e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e45:	53                   	push   %ebx
  800e46:	6a 00                	push   $0x0
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 83 fd ff ff       	call   800bd7 <sys_page_map>
  800e54:	83 c4 20             	add    $0x20,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	79 14                	jns    800e6f <pgfault+0xcb>
		panic("sys_page_map");
  800e5b:	83 ec 04             	sub    $0x4,%esp
  800e5e:	68 f6 25 80 00       	push   $0x8025f6
  800e63:	6a 2f                	push   $0x2f
  800e65:	68 dc 25 80 00       	push   $0x8025dc
  800e6a:	e8 be f2 ff ff       	call   80012d <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	68 00 f0 7f 00       	push   $0x7ff000
  800e77:	6a 00                	push   $0x0
  800e79:	e8 9b fd ff ff       	call   800c19 <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	79 14                	jns    800e99 <pgfault+0xf5>
		panic("sys_page_unmap");
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	68 03 26 80 00       	push   $0x802603
  800e8d:	6a 31                	push   $0x31
  800e8f:	68 dc 25 80 00       	push   $0x8025dc
  800e94:	e8 94 f2 ff ff       	call   80012d <_panic>
	return;
}
  800e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800ea7:	68 a4 0d 80 00       	push   $0x800da4
  800eac:	e8 bb 0e 00 00       	call   801d6c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eb1:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb6:	cd 30                	int    $0x30
  800eb8:	89 c7                	mov    %eax,%edi
  800eba:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	75 21                	jne    800ee5 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec4:	e8 8d fc ff ff       	call   800b56 <sys_getenvid>
  800ec9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ece:	6b c0 78             	imul   $0x78,%eax,%eax
  800ed1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ed6:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	e9 80 01 00 00       	jmp    801065 <fork+0x1c7>
	}
	if (envid < 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	79 12                	jns    800efb <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800ee9:	50                   	push   %eax
  800eea:	68 12 26 80 00       	push   $0x802612
  800eef:	6a 70                	push   $0x70
  800ef1:	68 dc 25 80 00       	push   $0x8025dc
  800ef6:	e8 32 f2 ff ff       	call   80012d <_panic>
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	c1 e8 16             	shr    $0x16,%eax
  800f05:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f0c:	a8 01                	test   $0x1,%al
  800f0e:	0f 84 de 00 00 00    	je     800ff2 <fork+0x154>
  800f14:	89 de                	mov    %ebx,%esi
  800f16:	c1 ee 0c             	shr    $0xc,%esi
  800f19:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f20:	a8 01                	test   $0x1,%al
  800f22:	0f 84 ca 00 00 00    	je     800ff2 <fork+0x154>
  800f28:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2f:	a8 04                	test   $0x4,%al
  800f31:	0f 84 bb 00 00 00    	je     800ff2 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800f37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800f3e:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800f41:	f6 c4 04             	test   $0x4,%ah
  800f44:	74 34                	je     800f7a <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4e:	50                   	push   %eax
  800f4f:	56                   	push   %esi
  800f50:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 7c fc ff ff       	call   800bd7 <sys_page_map>
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	0f 84 8c 00 00 00    	je     800ff2 <fork+0x154>
        	panic("duppage share");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 22 26 80 00       	push   $0x802622
  800f6e:	6a 48                	push   $0x48
  800f70:	68 dc 25 80 00       	push   $0x8025dc
  800f75:	e8 b3 f1 ff ff       	call   80012d <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  800f7a:	a9 02 08 00 00       	test   $0x802,%eax
  800f7f:	74 5d                	je     800fde <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	68 05 08 00 00       	push   $0x805
  800f89:	56                   	push   %esi
  800f8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8d:	56                   	push   %esi
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 42 fc ff ff       	call   800bd7 <sys_page_map>
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 14                	jns    800fb0 <fork+0x112>
			panic("error");
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 98 22 80 00       	push   $0x802298
  800fa4:	6a 4b                	push   $0x4b
  800fa6:	68 dc 25 80 00       	push   $0x8025dc
  800fab:	e8 7d f1 ff ff       	call   80012d <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	68 05 08 00 00       	push   $0x805
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 14 fc ff ff       	call   800bd7 <sys_page_map>
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 28                	jns    800ff2 <fork+0x154>
			panic("error");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 98 22 80 00       	push   $0x802298
  800fd2:	6a 4d                	push   $0x4d
  800fd4:	68 dc 25 80 00       	push   $0x8025dc
  800fd9:	e8 4f f1 ff ff       	call   80012d <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	6a 05                	push   $0x5
  800fe3:	56                   	push   %esi
  800fe4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 e8 fb ff ff       	call   800bd7 <sys_page_map>
  800fef:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800ff2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff8:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  800ffe:	0f 85 fc fe ff ff    	jne    800f00 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	6a 07                	push   $0x7
  801009:	68 00 f0 7f ee       	push   $0xee7ff000
  80100e:	57                   	push   %edi
  80100f:	e8 80 fb ff ff       	call   800b94 <sys_page_alloc>
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	79 14                	jns    80102f <fork+0x191>
		panic("1");
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	68 30 26 80 00       	push   $0x802630
  801023:	6a 78                	push   $0x78
  801025:	68 dc 25 80 00       	push   $0x8025dc
  80102a:	e8 fe f0 ff ff       	call   80012d <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	68 db 1d 80 00       	push   $0x801ddb
  801037:	57                   	push   %edi
  801038:	e8 a2 fc ff ff       	call   800cdf <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	6a 02                	push   $0x2
  801042:	57                   	push   %edi
  801043:	e8 13 fc ff ff       	call   800c5b <sys_env_set_status>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	79 14                	jns    801063 <fork+0x1c5>
		panic("sys_env_set_status");
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	68 32 26 80 00       	push   $0x802632
  801057:	6a 7d                	push   $0x7d
  801059:	68 dc 25 80 00       	push   $0x8025dc
  80105e:	e8 ca f0 ff ff       	call   80012d <_panic>

	return envid;
  801063:	89 f8                	mov    %edi,%eax
}
  801065:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sfork>:

// Challenge!
int
sfork(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801073:	68 45 26 80 00       	push   $0x802645
  801078:	68 86 00 00 00       	push   $0x86
  80107d:	68 dc 25 80 00       	push   $0x8025dc
  801082:	e8 a6 f0 ff ff       	call   80012d <_panic>

00801087 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	05 00 00 00 30       	add    $0x30000000,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
  80109d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8010a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 11                	je     8010db <fd_alloc+0x2d>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	75 09                	jne    8010e4 <fd_alloc+0x36>
			*fd_store = fd;
  8010db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e2:	eb 17                	jmp    8010fb <fd_alloc+0x4d>
  8010e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ee:	75 c9                	jne    8010b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801103:	83 f8 1f             	cmp    $0x1f,%eax
  801106:	77 36                	ja     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801108:	c1 e0 0c             	shl    $0xc,%eax
  80110b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 16             	shr    $0x16,%edx
  801115:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 24                	je     801145 <fd_lookup+0x48>
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 0c             	shr    $0xc,%edx
  801126:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 1a                	je     80114c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 02                	mov    %eax,(%edx)
	return 0;
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	eb 13                	jmp    801151 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801143:	eb 0c                	jmp    801151 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801145:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114a:	eb 05                	jmp    801151 <fd_lookup+0x54>
  80114c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115c:	ba d8 26 80 00       	mov    $0x8026d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801161:	eb 13                	jmp    801176 <dev_lookup+0x23>
  801163:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801166:	39 08                	cmp    %ecx,(%eax)
  801168:	75 0c                	jne    801176 <dev_lookup+0x23>
			*dev = devtab[i];
  80116a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
  801174:	eb 2e                	jmp    8011a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801176:	8b 02                	mov    (%edx),%eax
  801178:	85 c0                	test   %eax,%eax
  80117a:	75 e7                	jne    801163 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80117c:	a1 08 40 80 00       	mov    0x804008,%eax
  801181:	8b 40 48             	mov    0x48(%eax),%eax
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	51                   	push   %ecx
  801188:	50                   	push   %eax
  801189:	68 5c 26 80 00       	push   $0x80265c
  80118e:	e8 73 f0 ff ff       	call   800206 <cprintf>
	*dev = 0;
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
  801196:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 10             	sub    $0x10,%esp
  8011ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011be:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c1:	50                   	push   %eax
  8011c2:	e8 36 ff ff ff       	call   8010fd <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 05                	js     8011d3 <fd_close+0x2d>
	    || fd != fd2)
  8011ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011d1:	74 0b                	je     8011de <fd_close+0x38>
		return (must_exist ? r : 0);
  8011d3:	80 fb 01             	cmp    $0x1,%bl
  8011d6:	19 d2                	sbb    %edx,%edx
  8011d8:	f7 d2                	not    %edx
  8011da:	21 d0                	and    %edx,%eax
  8011dc:	eb 41                	jmp    80121f <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	ff 36                	pushl  (%esi)
  8011e7:	e8 67 ff ff ff       	call   801153 <dev_lookup>
  8011ec:	89 c3                	mov    %eax,%ebx
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 1a                	js     80120f <fd_close+0x69>
		if (dev->dev_close)
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801200:	85 c0                	test   %eax,%eax
  801202:	74 0b                	je     80120f <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	56                   	push   %esi
  801208:	ff d0                	call   *%eax
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	56                   	push   %esi
  801213:	6a 00                	push   $0x0
  801215:	e8 ff f9 ff ff       	call   800c19 <sys_page_unmap>
	return r;
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	89 d8                	mov    %ebx,%eax
}
  80121f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 c5 fe ff ff       	call   8010fd <fd_lookup>
  801238:	89 c2                	mov    %eax,%edx
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	85 d2                	test   %edx,%edx
  80123f:	78 10                	js     801251 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	6a 01                	push   $0x1
  801246:	ff 75 f4             	pushl  -0xc(%ebp)
  801249:	e8 58 ff ff ff       	call   8011a6 <fd_close>
  80124e:	83 c4 10             	add    $0x10,%esp
}
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <close_all>:

void
close_all(void)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	53                   	push   %ebx
  801263:	e8 be ff ff ff       	call   801226 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801268:	83 c3 01             	add    $0x1,%ebx
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	83 fb 20             	cmp    $0x20,%ebx
  801271:	75 ec                	jne    80125f <close_all+0xc>
		close(i);
}
  801273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 2c             	sub    $0x2c,%esp
  801281:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801284:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 6d fe ff ff       	call   8010fd <fd_lookup>
  801290:	89 c2                	mov    %eax,%edx
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	85 d2                	test   %edx,%edx
  801297:	0f 88 c1 00 00 00    	js     80135e <dup+0xe6>
		return r;
	close(newfdnum);
  80129d:	83 ec 0c             	sub    $0xc,%esp
  8012a0:	56                   	push   %esi
  8012a1:	e8 80 ff ff ff       	call   801226 <close>

	newfd = INDEX2FD(newfdnum);
  8012a6:	89 f3                	mov    %esi,%ebx
  8012a8:	c1 e3 0c             	shl    $0xc,%ebx
  8012ab:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b1:	83 c4 04             	add    $0x4,%esp
  8012b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b7:	e8 db fd ff ff       	call   801097 <fd2data>
  8012bc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012be:	89 1c 24             	mov    %ebx,(%esp)
  8012c1:	e8 d1 fd ff ff       	call   801097 <fd2data>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012cc:	89 f8                	mov    %edi,%eax
  8012ce:	c1 e8 16             	shr    $0x16,%eax
  8012d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d8:	a8 01                	test   $0x1,%al
  8012da:	74 37                	je     801313 <dup+0x9b>
  8012dc:	89 f8                	mov    %edi,%eax
  8012de:	c1 e8 0c             	shr    $0xc,%eax
  8012e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	74 26                	je     801313 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f4:	83 ec 0c             	sub    $0xc,%esp
  8012f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fc:	50                   	push   %eax
  8012fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	57                   	push   %edi
  801303:	6a 00                	push   $0x0
  801305:	e8 cd f8 ff ff       	call   800bd7 <sys_page_map>
  80130a:	89 c7                	mov    %eax,%edi
  80130c:	83 c4 20             	add    $0x20,%esp
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 2e                	js     801341 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801313:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801316:	89 d0                	mov    %edx,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	53                   	push   %ebx
  80132c:	6a 00                	push   $0x0
  80132e:	52                   	push   %edx
  80132f:	6a 00                	push   $0x0
  801331:	e8 a1 f8 ff ff       	call   800bd7 <sys_page_map>
  801336:	89 c7                	mov    %eax,%edi
  801338:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80133b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133d:	85 ff                	test   %edi,%edi
  80133f:	79 1d                	jns    80135e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	53                   	push   %ebx
  801345:	6a 00                	push   $0x0
  801347:	e8 cd f8 ff ff       	call   800c19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801352:	6a 00                	push   $0x0
  801354:	e8 c0 f8 ff ff       	call   800c19 <sys_page_unmap>
	return r;
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	89 f8                	mov    %edi,%eax
}
  80135e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	53                   	push   %ebx
  80136a:	83 ec 14             	sub    $0x14,%esp
  80136d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801370:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	53                   	push   %ebx
  801375:	e8 83 fd ff ff       	call   8010fd <fd_lookup>
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 6d                	js     8013f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138d:	ff 30                	pushl  (%eax)
  80138f:	e8 bf fd ff ff       	call   801153 <dev_lookup>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 4c                	js     8013e7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139e:	8b 42 08             	mov    0x8(%edx),%eax
  8013a1:	83 e0 03             	and    $0x3,%eax
  8013a4:	83 f8 01             	cmp    $0x1,%eax
  8013a7:	75 21                	jne    8013ca <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ae:	8b 40 48             	mov    0x48(%eax),%eax
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	50                   	push   %eax
  8013b6:	68 9d 26 80 00       	push   $0x80269d
  8013bb:	e8 46 ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c8:	eb 26                	jmp    8013f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cd:	8b 40 08             	mov    0x8(%eax),%eax
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	74 17                	je     8013eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	ff 75 10             	pushl  0x10(%ebp)
  8013da:	ff 75 0c             	pushl  0xc(%ebp)
  8013dd:	52                   	push   %edx
  8013de:	ff d0                	call   *%eax
  8013e0:	89 c2                	mov    %eax,%edx
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	eb 09                	jmp    8013f0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	eb 05                	jmp    8013f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013f0:	89 d0                	mov    %edx,%eax
  8013f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	8b 7d 08             	mov    0x8(%ebp),%edi
  801403:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140b:	eb 21                	jmp    80142e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	89 f0                	mov    %esi,%eax
  801412:	29 d8                	sub    %ebx,%eax
  801414:	50                   	push   %eax
  801415:	89 d8                	mov    %ebx,%eax
  801417:	03 45 0c             	add    0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	57                   	push   %edi
  80141c:	e8 45 ff ff ff       	call   801366 <read>
		if (m < 0)
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 0c                	js     801434 <readn+0x3d>
			return m;
		if (m == 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	74 06                	je     801432 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142c:	01 c3                	add    %eax,%ebx
  80142e:	39 f3                	cmp    %esi,%ebx
  801430:	72 db                	jb     80140d <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801432:	89 d8                	mov    %ebx,%eax
}
  801434:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 14             	sub    $0x14,%esp
  801443:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	53                   	push   %ebx
  80144b:	e8 ad fc ff ff       	call   8010fd <fd_lookup>
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	89 c2                	mov    %eax,%edx
  801455:	85 c0                	test   %eax,%eax
  801457:	78 68                	js     8014c1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801463:	ff 30                	pushl  (%eax)
  801465:	e8 e9 fc ff ff       	call   801153 <dev_lookup>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 47                	js     8014b8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801471:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801474:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801478:	75 21                	jne    80149b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80147a:	a1 08 40 80 00       	mov    0x804008,%eax
  80147f:	8b 40 48             	mov    0x48(%eax),%eax
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	53                   	push   %ebx
  801486:	50                   	push   %eax
  801487:	68 b9 26 80 00       	push   $0x8026b9
  80148c:	e8 75 ed ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801499:	eb 26                	jmp    8014c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80149b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149e:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a1:	85 d2                	test   %edx,%edx
  8014a3:	74 17                	je     8014bc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	ff 75 10             	pushl  0x10(%ebp)
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	50                   	push   %eax
  8014af:	ff d2                	call   *%edx
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	eb 09                	jmp    8014c1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	eb 05                	jmp    8014c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014c1:	89 d0                	mov    %edx,%eax
  8014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	ff 75 08             	pushl  0x8(%ebp)
  8014d5:	e8 23 fc ff ff       	call   8010fd <fd_lookup>
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 0e                	js     8014ef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 14             	sub    $0x14,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	53                   	push   %ebx
  801500:	e8 f8 fb ff ff       	call   8010fd <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	89 c2                	mov    %eax,%edx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 65                	js     801573 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	ff 30                	pushl  (%eax)
  80151a:	e8 34 fc ff ff       	call   801153 <dev_lookup>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 44                	js     80156a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152d:	75 21                	jne    801550 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80152f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801534:	8b 40 48             	mov    0x48(%eax),%eax
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	53                   	push   %ebx
  80153b:	50                   	push   %eax
  80153c:	68 7c 26 80 00       	push   $0x80267c
  801541:	e8 c0 ec ff ff       	call   800206 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154e:	eb 23                	jmp    801573 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801550:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801553:	8b 52 18             	mov    0x18(%edx),%edx
  801556:	85 d2                	test   %edx,%edx
  801558:	74 14                	je     80156e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	50                   	push   %eax
  801561:	ff d2                	call   *%edx
  801563:	89 c2                	mov    %eax,%edx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	eb 09                	jmp    801573 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	eb 05                	jmp    801573 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801573:	89 d0                	mov    %edx,%eax
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 14             	sub    $0x14,%esp
  801581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801584:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	e8 6d fb ff ff       	call   8010fd <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	89 c2                	mov    %eax,%edx
  801595:	85 c0                	test   %eax,%eax
  801597:	78 58                	js     8015f1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a3:	ff 30                	pushl  (%eax)
  8015a5:	e8 a9 fb ff ff       	call   801153 <dev_lookup>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 37                	js     8015e8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b8:	74 32                	je     8015ec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c4:	00 00 00 
	stat->st_isdir = 0;
  8015c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ce:	00 00 00 
	stat->st_dev = dev;
  8015d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	ff 75 f0             	pushl  -0x10(%ebp)
  8015de:	ff 50 14             	call   *0x14(%eax)
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 09                	jmp    8015f1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	eb 05                	jmp    8015f1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	6a 00                	push   $0x0
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 e7 01 00 00       	call   8017f1 <open>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 db                	test   %ebx,%ebx
  801611:	78 1b                	js     80162e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	ff 75 0c             	pushl  0xc(%ebp)
  801619:	53                   	push   %ebx
  80161a:	e8 5b ff ff ff       	call   80157a <fstat>
  80161f:	89 c6                	mov    %eax,%esi
	close(fd);
  801621:	89 1c 24             	mov    %ebx,(%esp)
  801624:	e8 fd fb ff ff       	call   801226 <close>
	return r;
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	89 f0                	mov    %esi,%eax
}
  80162e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
  80163a:	89 c6                	mov    %eax,%esi
  80163c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801645:	75 12                	jne    801659 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	6a 03                	push   $0x3
  80164c:	e8 69 08 00 00       	call   801eba <ipc_find_env>
  801651:	a3 00 40 80 00       	mov    %eax,0x804000
  801656:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801659:	6a 07                	push   $0x7
  80165b:	68 00 50 80 00       	push   $0x805000
  801660:	56                   	push   %esi
  801661:	ff 35 00 40 80 00    	pushl  0x804000
  801667:	e8 fd 07 00 00       	call   801e69 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166c:	83 c4 0c             	add    $0xc,%esp
  80166f:	6a 00                	push   $0x0
  801671:	53                   	push   %ebx
  801672:	6a 00                	push   $0x0
  801674:	e8 8a 07 00 00       	call   801e03 <ipc_recv>
}
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 40 0c             	mov    0xc(%eax),%eax
  80168c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801691:	8b 45 0c             	mov    0xc(%ebp),%eax
  801694:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a3:	e8 8d ff ff ff       	call   801635 <fsipc>
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c5:	e8 6b ff ff ff       	call   801635 <fsipc>
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016eb:	e8 45 ff ff ff       	call   801635 <fsipc>
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	85 d2                	test   %edx,%edx
  8016f4:	78 2c                	js     801722 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f6:	83 ec 08             	sub    $0x8,%esp
  8016f9:	68 00 50 80 00       	push   $0x805000
  8016fe:	53                   	push   %ebx
  8016ff:	e8 86 f0 ff ff       	call   80078a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801704:	a1 80 50 80 00       	mov    0x805080,%eax
  801709:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170f:	a1 84 50 80 00       	mov    0x805084,%eax
  801714:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801730:	8b 55 08             	mov    0x8(%ebp),%edx
  801733:	8b 52 0c             	mov    0xc(%edx),%edx
  801736:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80173c:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801741:	76 05                	jbe    801748 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801743:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801748:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  80174d:	83 ec 04             	sub    $0x4,%esp
  801750:	50                   	push   %eax
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	68 08 50 80 00       	push   $0x805008
  801759:	e8 be f1 ff ff       	call   80091c <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 04 00 00 00       	mov    $0x4,%eax
  801768:	e8 c8 fe ff ff       	call   801635 <fsipc>
	return write;
}
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801782:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	b8 03 00 00 00       	mov    $0x3,%eax
  801792:	e8 9e fe ff ff       	call   801635 <fsipc>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 4b                	js     8017e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80179d:	39 c6                	cmp    %eax,%esi
  80179f:	73 16                	jae    8017b7 <devfile_read+0x48>
  8017a1:	68 e8 26 80 00       	push   $0x8026e8
  8017a6:	68 ef 26 80 00       	push   $0x8026ef
  8017ab:	6a 7c                	push   $0x7c
  8017ad:	68 04 27 80 00       	push   $0x802704
  8017b2:	e8 76 e9 ff ff       	call   80012d <_panic>
	assert(r <= PGSIZE);
  8017b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017bc:	7e 16                	jle    8017d4 <devfile_read+0x65>
  8017be:	68 0f 27 80 00       	push   $0x80270f
  8017c3:	68 ef 26 80 00       	push   $0x8026ef
  8017c8:	6a 7d                	push   $0x7d
  8017ca:	68 04 27 80 00       	push   $0x802704
  8017cf:	e8 59 e9 ff ff       	call   80012d <_panic>
	memmove(buf, &fsipcbuf, r);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	50                   	push   %eax
  8017d8:	68 00 50 80 00       	push   $0x805000
  8017dd:	ff 75 0c             	pushl  0xc(%ebp)
  8017e0:	e8 37 f1 ff ff       	call   80091c <memmove>
	return r;
  8017e5:	83 c4 10             	add    $0x10,%esp
}
  8017e8:	89 d8                	mov    %ebx,%eax
  8017ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 20             	sub    $0x20,%esp
  8017f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017fb:	53                   	push   %ebx
  8017fc:	e8 50 ef ff ff       	call   800751 <strlen>
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801809:	7f 67                	jg     801872 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	e8 97 f8 ff ff       	call   8010ae <fd_alloc>
  801817:	83 c4 10             	add    $0x10,%esp
		return r;
  80181a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 57                	js     801877 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	53                   	push   %ebx
  801824:	68 00 50 80 00       	push   $0x805000
  801829:	e8 5c ef ff ff       	call   80078a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801836:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801839:	b8 01 00 00 00       	mov    $0x1,%eax
  80183e:	e8 f2 fd ff ff       	call   801635 <fsipc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	79 14                	jns    801860 <open+0x6f>
		fd_close(fd, 0);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	6a 00                	push   $0x0
  801851:	ff 75 f4             	pushl  -0xc(%ebp)
  801854:	e8 4d f9 ff ff       	call   8011a6 <fd_close>
		return r;
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 da                	mov    %ebx,%edx
  80185e:	eb 17                	jmp    801877 <open+0x86>
	}

	return fd2num(fd);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	ff 75 f4             	pushl  -0xc(%ebp)
  801866:	e8 1c f8 ff ff       	call   801087 <fd2num>
  80186b:	89 c2                	mov    %eax,%edx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	eb 05                	jmp    801877 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801872:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801877:	89 d0                	mov    %edx,%eax
  801879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 08 00 00 00       	mov    $0x8,%eax
  80188e:	e8 a2 fd ff ff       	call   801635 <fsipc>
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 ef f7 ff ff       	call   801097 <fd2data>
  8018a8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018aa:	83 c4 08             	add    $0x8,%esp
  8018ad:	68 1b 27 80 00       	push   $0x80271b
  8018b2:	53                   	push   %ebx
  8018b3:	e8 d2 ee ff ff       	call   80078a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018b8:	8b 56 04             	mov    0x4(%esi),%edx
  8018bb:	89 d0                	mov    %edx,%eax
  8018bd:	2b 06                	sub    (%esi),%eax
  8018bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018cc:	00 00 00 
	stat->st_dev = &devpipe;
  8018cf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018d6:	30 80 00 
	return 0;
}
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e1:	5b                   	pop    %ebx
  8018e2:	5e                   	pop    %esi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018ef:	53                   	push   %ebx
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 22 f3 ff ff       	call   800c19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018f7:	89 1c 24             	mov    %ebx,(%esp)
  8018fa:	e8 98 f7 ff ff       	call   801097 <fd2data>
  8018ff:	83 c4 08             	add    $0x8,%esp
  801902:	50                   	push   %eax
  801903:	6a 00                	push   $0x0
  801905:	e8 0f f3 ff ff       	call   800c19 <sys_page_unmap>
}
  80190a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	57                   	push   %edi
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 1c             	sub    $0x1c,%esp
  801918:	89 c7                	mov    %eax,%edi
  80191a:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80191c:	a1 08 40 80 00       	mov    0x804008,%eax
  801921:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	57                   	push   %edi
  801928:	e8 c5 05 00 00       	call   801ef2 <pageref>
  80192d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801930:	89 34 24             	mov    %esi,(%esp)
  801933:	e8 ba 05 00 00       	call   801ef2 <pageref>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80193e:	0f 94 c0             	sete   %al
  801941:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801944:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80194a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80194d:	39 cb                	cmp    %ecx,%ebx
  80194f:	74 15                	je     801966 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801951:	8b 52 58             	mov    0x58(%edx),%edx
  801954:	50                   	push   %eax
  801955:	52                   	push   %edx
  801956:	53                   	push   %ebx
  801957:	68 28 27 80 00       	push   $0x802728
  80195c:	e8 a5 e8 ff ff       	call   800206 <cprintf>
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	eb b6                	jmp    80191c <_pipeisclosed+0xd>
	}
}
  801966:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801969:	5b                   	pop    %ebx
  80196a:	5e                   	pop    %esi
  80196b:	5f                   	pop    %edi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	83 ec 28             	sub    $0x28,%esp
  801977:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80197a:	56                   	push   %esi
  80197b:	e8 17 f7 ff ff       	call   801097 <fd2data>
  801980:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	bf 00 00 00 00       	mov    $0x0,%edi
  80198a:	eb 4b                	jmp    8019d7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	89 f0                	mov    %esi,%eax
  801990:	e8 7a ff ff ff       	call   80190f <_pipeisclosed>
  801995:	85 c0                	test   %eax,%eax
  801997:	75 48                	jne    8019e1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801999:	e8 d7 f1 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80199e:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a1:	8b 0b                	mov    (%ebx),%ecx
  8019a3:	8d 51 20             	lea    0x20(%ecx),%edx
  8019a6:	39 d0                	cmp    %edx,%eax
  8019a8:	73 e2                	jae    80198c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019b1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	c1 fa 1f             	sar    $0x1f,%edx
  8019b9:	89 d1                	mov    %edx,%ecx
  8019bb:	c1 e9 1b             	shr    $0x1b,%ecx
  8019be:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019c1:	83 e2 1f             	and    $0x1f,%edx
  8019c4:	29 ca                	sub    %ecx,%edx
  8019c6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ce:	83 c0 01             	add    $0x1,%eax
  8019d1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d4:	83 c7 01             	add    $0x1,%edi
  8019d7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019da:	75 c2                	jne    80199e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019df:	eb 05                	jmp    8019e6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 18             	sub    $0x18,%esp
  8019f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019fa:	57                   	push   %edi
  8019fb:	e8 97 f6 ff ff       	call   801097 <fd2data>
  801a00:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a0a:	eb 3d                	jmp    801a49 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a0c:	85 db                	test   %ebx,%ebx
  801a0e:	74 04                	je     801a14 <devpipe_read+0x26>
				return i;
  801a10:	89 d8                	mov    %ebx,%eax
  801a12:	eb 44                	jmp    801a58 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a14:	89 f2                	mov    %esi,%edx
  801a16:	89 f8                	mov    %edi,%eax
  801a18:	e8 f2 fe ff ff       	call   80190f <_pipeisclosed>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	75 32                	jne    801a53 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a21:	e8 4f f1 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a26:	8b 06                	mov    (%esi),%eax
  801a28:	3b 46 04             	cmp    0x4(%esi),%eax
  801a2b:	74 df                	je     801a0c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a2d:	99                   	cltd   
  801a2e:	c1 ea 1b             	shr    $0x1b,%edx
  801a31:	01 d0                	add    %edx,%eax
  801a33:	83 e0 1f             	and    $0x1f,%eax
  801a36:	29 d0                	sub    %edx,%eax
  801a38:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a40:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a43:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a46:	83 c3 01             	add    $0x1,%ebx
  801a49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a4c:	75 d8                	jne    801a26 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a51:	eb 05                	jmp    801a58 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5f                   	pop    %edi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	e8 3d f6 ff ff       	call   8010ae <fd_alloc>
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 2c 01 00 00    	js     801baa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	68 07 04 00 00       	push   $0x407
  801a86:	ff 75 f4             	pushl  -0xc(%ebp)
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 04 f1 ff ff       	call   800b94 <sys_page_alloc>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	89 c2                	mov    %eax,%edx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	0f 88 0d 01 00 00    	js     801baa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	e8 05 f6 ff ff       	call   8010ae <fd_alloc>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 e2 00 00 00    	js     801b98 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab6:	83 ec 04             	sub    $0x4,%esp
  801ab9:	68 07 04 00 00       	push   $0x407
  801abe:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 cc f0 ff ff       	call   800b94 <sys_page_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	0f 88 c3 00 00 00    	js     801b98 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	e8 b7 f5 ff ff       	call   801097 <fd2data>
  801ae0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	83 c4 0c             	add    $0xc,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	50                   	push   %eax
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 a2 f0 ff ff       	call   800b94 <sys_page_alloc>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 89 00 00 00    	js     801b88 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 f0             	pushl  -0x10(%ebp)
  801b05:	e8 8d f5 ff ff       	call   801097 <fd2data>
  801b0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b11:	50                   	push   %eax
  801b12:	6a 00                	push   $0x0
  801b14:	56                   	push   %esi
  801b15:	6a 00                	push   $0x0
  801b17:	e8 bb f0 ff ff       	call   800bd7 <sys_page_map>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	83 c4 20             	add    $0x20,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 55                	js     801b7a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 f4             	pushl  -0xc(%ebp)
  801b55:	e8 2d f5 ff ff       	call   801087 <fd2num>
  801b5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b5f:	83 c4 04             	add    $0x4,%esp
  801b62:	ff 75 f0             	pushl  -0x10(%ebp)
  801b65:	e8 1d f5 ff ff       	call   801087 <fd2num>
  801b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	eb 30                	jmp    801baa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	56                   	push   %esi
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 94 f0 ff ff       	call   800c19 <sys_page_unmap>
  801b85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 84 f0 ff ff       	call   800c19 <sys_page_unmap>
  801b95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 74 f0 ff ff       	call   800c19 <sys_page_unmap>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	ff 75 08             	pushl  0x8(%ebp)
  801bc0:	e8 38 f5 ff ff       	call   8010fd <fd_lookup>
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 d2                	test   %edx,%edx
  801bcc:	78 18                	js     801be6 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bce:	83 ec 0c             	sub    $0xc,%esp
  801bd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd4:	e8 be f4 ff ff       	call   801097 <fd2data>
	return _pipeisclosed(fd, p);
  801bd9:	89 c2                	mov    %eax,%edx
  801bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bde:	e8 2c fd ff ff       	call   80190f <_pipeisclosed>
  801be3:	83 c4 10             	add    $0x10,%esp
}
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bf8:	68 59 27 80 00       	push   $0x802759
  801bfd:	ff 75 0c             	pushl  0xc(%ebp)
  801c00:	e8 85 eb ff ff       	call   80078a <strcpy>
	return 0;
}
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c18:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c23:	eb 2e                	jmp    801c53 <devcons_write+0x47>
		m = n - tot;
  801c25:	8b 55 10             	mov    0x10(%ebp),%edx
  801c28:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801c2a:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801c2f:	83 fa 7f             	cmp    $0x7f,%edx
  801c32:	77 02                	ja     801c36 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c34:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c36:	83 ec 04             	sub    $0x4,%esp
  801c39:	56                   	push   %esi
  801c3a:	03 45 0c             	add    0xc(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	57                   	push   %edi
  801c3f:	e8 d8 ec ff ff       	call   80091c <memmove>
		sys_cputs(buf, m);
  801c44:	83 c4 08             	add    $0x8,%esp
  801c47:	56                   	push   %esi
  801c48:	57                   	push   %edi
  801c49:	e8 8a ee ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4e:	01 f3                	add    %esi,%ebx
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	89 d8                	mov    %ebx,%eax
  801c55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c58:	72 cb                	jb     801c25 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c71:	75 07                	jne    801c7a <devcons_read+0x18>
  801c73:	eb 28                	jmp    801c9d <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c75:	e8 fb ee ff ff       	call   800b75 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c7a:	e8 77 ee ff ff       	call   800af6 <sys_cgetc>
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	74 f2                	je     801c75 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 16                	js     801c9d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c87:	83 f8 04             	cmp    $0x4,%eax
  801c8a:	74 0c                	je     801c98 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8f:	88 02                	mov    %al,(%edx)
	return 1;
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	eb 05                	jmp    801c9d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cab:	6a 01                	push   $0x1
  801cad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 22 ee ff ff       	call   800ad8 <sys_cputs>
  801cb6:	83 c4 10             	add    $0x10,%esp
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <getchar>:

int
getchar(void)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cc1:	6a 01                	push   $0x1
  801cc3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc6:	50                   	push   %eax
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 98 f6 ff ff       	call   801366 <read>
	if (r < 0)
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 0f                	js     801ce4 <getchar+0x29>
		return r;
	if (r < 1)
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	7e 06                	jle    801cdf <getchar+0x24>
		return -E_EOF;
	return c;
  801cd9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cdd:	eb 05                	jmp    801ce4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cdf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	ff 75 08             	pushl  0x8(%ebp)
  801cf3:	e8 05 f4 ff ff       	call   8010fd <fd_lookup>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 11                	js     801d10 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d08:	39 10                	cmp    %edx,(%eax)
  801d0a:	0f 94 c0             	sete   %al
  801d0d:	0f b6 c0             	movzbl %al,%eax
}
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <opencons>:

int
opencons(void)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1b:	50                   	push   %eax
  801d1c:	e8 8d f3 ff ff       	call   8010ae <fd_alloc>
  801d21:	83 c4 10             	add    $0x10,%esp
		return r;
  801d24:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 3e                	js     801d68 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d2a:	83 ec 04             	sub    $0x4,%esp
  801d2d:	68 07 04 00 00       	push   $0x407
  801d32:	ff 75 f4             	pushl  -0xc(%ebp)
  801d35:	6a 00                	push   $0x0
  801d37:	e8 58 ee ff ff       	call   800b94 <sys_page_alloc>
  801d3c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d3f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 23                	js     801d68 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d45:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	50                   	push   %eax
  801d5e:	e8 24 f3 ff ff       	call   801087 <fd2num>
  801d63:	89 c2                	mov    %eax,%edx
  801d65:	83 c4 10             	add    $0x10,%esp
}
  801d68:	89 d0                	mov    %edx,%eax
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801d72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d79:	75 2c                	jne    801da7 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	6a 07                	push   $0x7
  801d80:	68 00 f0 7f ee       	push   $0xee7ff000
  801d85:	6a 00                	push   $0x0
  801d87:	e8 08 ee ff ff       	call   800b94 <sys_page_alloc>
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	79 14                	jns    801da7 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	68 68 27 80 00       	push   $0x802768
  801d9b:	6a 1f                	push   $0x1f
  801d9d:	68 cc 27 80 00       	push   $0x8027cc
  801da2:	e8 86 e3 ff ff       	call   80012d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	68 db 1d 80 00       	push   $0x801ddb
  801db7:	6a 00                	push   $0x0
  801db9:	e8 21 ef ff ff       	call   800cdf <sys_env_set_pgfault_upcall>
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	79 14                	jns    801dd9 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801dc5:	83 ec 04             	sub    $0x4,%esp
  801dc8:	68 94 27 80 00       	push   $0x802794
  801dcd:	6a 25                	push   $0x25
  801dcf:	68 cc 27 80 00       	push   $0x8027cc
  801dd4:	e8 54 e3 ff ff       	call   80012d <_panic>
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ddb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ddc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801de1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801de3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801de6:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801de8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801dec:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801df0:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801df1:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801df4:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801df6:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801df9:	83 c4 04             	add    $0x4,%esp
	popal 
  801dfc:	61                   	popa   
	addl $4, %esp 
  801dfd:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801e00:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801e01:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801e02:	c3                   	ret    

00801e03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801e11:	85 f6                	test   %esi,%esi
  801e13:	74 06                	je     801e1b <ipc_recv+0x18>
  801e15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801e1b:	85 db                	test   %ebx,%ebx
  801e1d:	74 06                	je     801e25 <ipc_recv+0x22>
  801e1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801e25:	83 f8 01             	cmp    $0x1,%eax
  801e28:	19 d2                	sbb    %edx,%edx
  801e2a:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	50                   	push   %eax
  801e30:	e8 0f ef ff ff       	call   800d44 <sys_ipc_recv>
  801e35:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 d2                	test   %edx,%edx
  801e3c:	75 24                	jne    801e62 <ipc_recv+0x5f>
	if (from_env_store)
  801e3e:	85 f6                	test   %esi,%esi
  801e40:	74 0a                	je     801e4c <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801e42:	a1 08 40 80 00       	mov    0x804008,%eax
  801e47:	8b 40 70             	mov    0x70(%eax),%eax
  801e4a:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801e4c:	85 db                	test   %ebx,%ebx
  801e4e:	74 0a                	je     801e5a <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801e50:	a1 08 40 80 00       	mov    0x804008,%eax
  801e55:	8b 40 74             	mov    0x74(%eax),%eax
  801e58:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801e5a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e5f:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801e62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	57                   	push   %edi
  801e6d:	56                   	push   %esi
  801e6e:	53                   	push   %ebx
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801e7b:	83 fb 01             	cmp    $0x1,%ebx
  801e7e:	19 c0                	sbb    %eax,%eax
  801e80:	09 c3                	or     %eax,%ebx
  801e82:	eb 1c                	jmp    801ea0 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801e84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e87:	74 12                	je     801e9b <ipc_send+0x32>
  801e89:	50                   	push   %eax
  801e8a:	68 da 27 80 00       	push   $0x8027da
  801e8f:	6a 36                	push   $0x36
  801e91:	68 f1 27 80 00       	push   $0x8027f1
  801e96:	e8 92 e2 ff ff       	call   80012d <_panic>
		sys_yield();
  801e9b:	e8 d5 ec ff ff       	call   800b75 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ea0:	ff 75 14             	pushl  0x14(%ebp)
  801ea3:	53                   	push   %ebx
  801ea4:	56                   	push   %esi
  801ea5:	57                   	push   %edi
  801ea6:	e8 76 ee ff ff       	call   800d21 <sys_ipc_try_send>
		if (ret == 0) break;
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	75 d2                	jne    801e84 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec5:	6b d0 78             	imul   $0x78,%eax,%edx
  801ec8:	83 c2 50             	add    $0x50,%edx
  801ecb:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ed1:	39 ca                	cmp    %ecx,%edx
  801ed3:	75 0d                	jne    801ee2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ed5:	6b c0 78             	imul   $0x78,%eax,%eax
  801ed8:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801edd:	8b 40 08             	mov    0x8(%eax),%eax
  801ee0:	eb 0e                	jmp    801ef0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee2:	83 c0 01             	add    $0x1,%eax
  801ee5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eea:	75 d9                	jne    801ec5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eec:	66 b8 00 00          	mov    $0x0,%ax
}
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	c1 e8 16             	shr    $0x16,%eax
  801efd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f09:	f6 c1 01             	test   $0x1,%cl
  801f0c:	74 1d                	je     801f2b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0e:	c1 ea 0c             	shr    $0xc,%edx
  801f11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f18:	f6 c2 01             	test   $0x1,%dl
  801f1b:	74 0e                	je     801f2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1d:	c1 ea 0c             	shr    $0xc,%edx
  801f20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f27:	ef 
  801f28:	0f b7 c0             	movzwl %ax,%eax
}
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	83 ec 10             	sub    $0x10,%esp
  801f36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801f3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801f3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801f42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f46:	85 d2                	test   %edx,%edx
  801f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4c:	89 34 24             	mov    %esi,(%esp)
  801f4f:	89 c8                	mov    %ecx,%eax
  801f51:	75 35                	jne    801f88 <__udivdi3+0x58>
  801f53:	39 f1                	cmp    %esi,%ecx
  801f55:	0f 87 bd 00 00 00    	ja     802018 <__udivdi3+0xe8>
  801f5b:	85 c9                	test   %ecx,%ecx
  801f5d:	89 cd                	mov    %ecx,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f1                	div    %ecx
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 f0                	mov    %esi,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c6                	mov    %eax,%esi
  801f74:	89 f8                	mov    %edi,%eax
  801f76:	f7 f5                	div    %ebp
  801f78:	89 f2                	mov    %esi,%edx
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	5e                   	pop    %esi
  801f7e:	5f                   	pop    %edi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    
  801f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f88:	3b 14 24             	cmp    (%esp),%edx
  801f8b:	77 7b                	ja     802008 <__udivdi3+0xd8>
  801f8d:	0f bd f2             	bsr    %edx,%esi
  801f90:	83 f6 1f             	xor    $0x1f,%esi
  801f93:	0f 84 97 00 00 00    	je     802030 <__udivdi3+0x100>
  801f99:	bd 20 00 00 00       	mov    $0x20,%ebp
  801f9e:	89 d7                	mov    %edx,%edi
  801fa0:	89 f1                	mov    %esi,%ecx
  801fa2:	29 f5                	sub    %esi,%ebp
  801fa4:	d3 e7                	shl    %cl,%edi
  801fa6:	89 c2                	mov    %eax,%edx
  801fa8:	89 e9                	mov    %ebp,%ecx
  801faa:	d3 ea                	shr    %cl,%edx
  801fac:	89 f1                	mov    %esi,%ecx
  801fae:	09 fa                	or     %edi,%edx
  801fb0:	8b 3c 24             	mov    (%esp),%edi
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fb9:	89 e9                	mov    %ebp,%ecx
  801fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fc3:	89 fa                	mov    %edi,%edx
  801fc5:	d3 ea                	shr    %cl,%edx
  801fc7:	89 f1                	mov    %esi,%ecx
  801fc9:	d3 e7                	shl    %cl,%edi
  801fcb:	89 e9                	mov    %ebp,%ecx
  801fcd:	d3 e8                	shr    %cl,%eax
  801fcf:	09 c7                	or     %eax,%edi
  801fd1:	89 f8                	mov    %edi,%eax
  801fd3:	f7 74 24 08          	divl   0x8(%esp)
  801fd7:	89 d5                	mov    %edx,%ebp
  801fd9:	89 c7                	mov    %eax,%edi
  801fdb:	f7 64 24 0c          	mull   0xc(%esp)
  801fdf:	39 d5                	cmp    %edx,%ebp
  801fe1:	89 14 24             	mov    %edx,(%esp)
  801fe4:	72 11                	jb     801ff7 <__udivdi3+0xc7>
  801fe6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fea:	89 f1                	mov    %esi,%ecx
  801fec:	d3 e2                	shl    %cl,%edx
  801fee:	39 c2                	cmp    %eax,%edx
  801ff0:	73 5e                	jae    802050 <__udivdi3+0x120>
  801ff2:	3b 2c 24             	cmp    (%esp),%ebp
  801ff5:	75 59                	jne    802050 <__udivdi3+0x120>
  801ff7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ffa:	31 f6                	xor    %esi,%esi
  801ffc:	89 f2                	mov    %esi,%edx
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    
  802005:	8d 76 00             	lea    0x0(%esi),%esi
  802008:	31 f6                	xor    %esi,%esi
  80200a:	31 c0                	xor    %eax,%eax
  80200c:	89 f2                	mov    %esi,%edx
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	89 f2                	mov    %esi,%edx
  80201a:	31 f6                	xor    %esi,%esi
  80201c:	89 f8                	mov    %edi,%eax
  80201e:	f7 f1                	div    %ecx
  802020:	89 f2                	mov    %esi,%edx
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802034:	76 0b                	jbe    802041 <__udivdi3+0x111>
  802036:	31 c0                	xor    %eax,%eax
  802038:	3b 14 24             	cmp    (%esp),%edx
  80203b:	0f 83 37 ff ff ff    	jae    801f78 <__udivdi3+0x48>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	e9 2d ff ff ff       	jmp    801f78 <__udivdi3+0x48>
  80204b:	90                   	nop
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 f8                	mov    %edi,%eax
  802052:	31 f6                	xor    %esi,%esi
  802054:	e9 1f ff ff ff       	jmp    801f78 <__udivdi3+0x48>
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 20             	sub    $0x20,%esp
  802066:	8b 44 24 34          	mov    0x34(%esp),%eax
  80206a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802072:	89 c6                	mov    %eax,%esi
  802074:	89 44 24 10          	mov    %eax,0x10(%esp)
  802078:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80207c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802080:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802084:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802088:	89 74 24 18          	mov    %esi,0x18(%esp)
  80208c:	85 c0                	test   %eax,%eax
  80208e:	89 c2                	mov    %eax,%edx
  802090:	75 1e                	jne    8020b0 <__umoddi3+0x50>
  802092:	39 f7                	cmp    %esi,%edi
  802094:	76 52                	jbe    8020e8 <__umoddi3+0x88>
  802096:	89 c8                	mov    %ecx,%eax
  802098:	89 f2                	mov    %esi,%edx
  80209a:	f7 f7                	div    %edi
  80209c:	89 d0                	mov    %edx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	83 c4 20             	add    $0x20,%esp
  8020a3:	5e                   	pop    %esi
  8020a4:	5f                   	pop    %edi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    
  8020a7:	89 f6                	mov    %esi,%esi
  8020a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020b0:	39 f0                	cmp    %esi,%eax
  8020b2:	77 5c                	ja     802110 <__umoddi3+0xb0>
  8020b4:	0f bd e8             	bsr    %eax,%ebp
  8020b7:	83 f5 1f             	xor    $0x1f,%ebp
  8020ba:	75 64                	jne    802120 <__umoddi3+0xc0>
  8020bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8020c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8020c4:	0f 86 f6 00 00 00    	jbe    8021c0 <__umoddi3+0x160>
  8020ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8020ce:	0f 82 ec 00 00 00    	jb     8021c0 <__umoddi3+0x160>
  8020d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8020dc:	83 c4 20             	add    $0x20,%esp
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    
  8020e3:	90                   	nop
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	85 ff                	test   %edi,%edi
  8020ea:	89 fd                	mov    %edi,%ebp
  8020ec:	75 0b                	jne    8020f9 <__umoddi3+0x99>
  8020ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f7                	div    %edi
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8020fd:	31 d2                	xor    %edx,%edx
  8020ff:	f7 f5                	div    %ebp
  802101:	89 c8                	mov    %ecx,%eax
  802103:	f7 f5                	div    %ebp
  802105:	eb 95                	jmp    80209c <__umoddi3+0x3c>
  802107:	89 f6                	mov    %esi,%esi
  802109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 20             	add    $0x20,%esp
  802117:	5e                   	pop    %esi
  802118:	5f                   	pop    %edi
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    
  80211b:	90                   	nop
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	b8 20 00 00 00       	mov    $0x20,%eax
  802125:	89 e9                	mov    %ebp,%ecx
  802127:	29 e8                	sub    %ebp,%eax
  802129:	d3 e2                	shl    %cl,%edx
  80212b:	89 c7                	mov    %eax,%edi
  80212d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802131:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 c1                	mov    %eax,%ecx
  80213b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80213f:	09 d1                	or     %edx,%ecx
  802141:	89 fa                	mov    %edi,%edx
  802143:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802147:	89 e9                	mov    %ebp,%ecx
  802149:	d3 e0                	shl    %cl,%eax
  80214b:	89 f9                	mov    %edi,%ecx
  80214d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802151:	89 f0                	mov    %esi,%eax
  802153:	d3 e8                	shr    %cl,%eax
  802155:	89 e9                	mov    %ebp,%ecx
  802157:	89 c7                	mov    %eax,%edi
  802159:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80215d:	d3 e6                	shl    %cl,%esi
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	89 fa                	mov    %edi,%edx
  802163:	d3 e8                	shr    %cl,%eax
  802165:	89 e9                	mov    %ebp,%ecx
  802167:	09 f0                	or     %esi,%eax
  802169:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80216d:	f7 74 24 10          	divl   0x10(%esp)
  802171:	d3 e6                	shl    %cl,%esi
  802173:	89 d1                	mov    %edx,%ecx
  802175:	f7 64 24 0c          	mull   0xc(%esp)
  802179:	39 d1                	cmp    %edx,%ecx
  80217b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80217f:	89 d7                	mov    %edx,%edi
  802181:	89 c6                	mov    %eax,%esi
  802183:	72 0a                	jb     80218f <__umoddi3+0x12f>
  802185:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802189:	73 10                	jae    80219b <__umoddi3+0x13b>
  80218b:	39 d1                	cmp    %edx,%ecx
  80218d:	75 0c                	jne    80219b <__umoddi3+0x13b>
  80218f:	89 d7                	mov    %edx,%edi
  802191:	89 c6                	mov    %eax,%esi
  802193:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802197:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80219b:	89 ca                	mov    %ecx,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021a3:	29 f0                	sub    %esi,%eax
  8021a5:	19 fa                	sbb    %edi,%edx
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8021ae:	89 d7                	mov    %edx,%edi
  8021b0:	d3 e7                	shl    %cl,%edi
  8021b2:	89 e9                	mov    %ebp,%ecx
  8021b4:	09 f8                	or     %edi,%eax
  8021b6:	d3 ea                	shr    %cl,%edx
  8021b8:	83 c4 20             	add    $0x20,%esp
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    
  8021bf:	90                   	nop
  8021c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021c4:	29 f9                	sub    %edi,%ecx
  8021c6:	19 c6                	sbb    %eax,%esi
  8021c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021d0:	e9 ff fe ff ff       	jmp    8020d4 <__umoddi3+0x74>
