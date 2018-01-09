
obj/user/testpteshare:     file format elf32-i386


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
  80002c:	e8 4b 01 00 00       	call   80017c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 f0 07 00 00       	call   800839 <strcpy>
	exit();
  800049:	e8 74 01 00 00       	call   8001c2 <exit>
  80004e:	83 c4 10             	add    $0x10,%esp
}
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 ca 0b 00 00       	call   800c43 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %i", r);
  800080:	50                   	push   %eax
  800081:	68 cc 28 80 00       	push   $0x8028cc
  800086:	6a 13                	push   $0x13
  800088:	68 df 28 80 00       	push   $0x8028df
  80008d:	e8 4a 01 00 00       	call   8001dc <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 b6 0e 00 00       	call   800f4d <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %i", r);
  80009d:	50                   	push   %eax
  80009e:	68 59 2d 80 00       	push   $0x802d59
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 df 28 80 00       	push   $0x8028df
  8000aa:	e8 2d 01 00 00       	call   8001dc <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 73 07 00 00       	call   800839 <strcpy>
		exit();
  8000c6:	e8 f7 00 00 00       	call   8001c2 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 8a 21 00 00       	call   802261 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f9 07 00 00       	call   8008e3 <strcmp>
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	ba c0 28 80 00       	mov    $0x8028c0,%edx
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	74 05                	je     8000fb <umain+0xa8>
  8000f6:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	52                   	push   %edx
  8000ff:	68 f3 28 80 00       	push   $0x8028f3
  800104:	e8 ac 01 00 00       	call   8002b5 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800109:	6a 00                	push   $0x0
  80010b:	68 0e 29 80 00       	push   $0x80290e
  800110:	68 13 29 80 00       	push   $0x802913
  800115:	68 12 29 80 00       	push   $0x802912
  80011a:	e8 7c 1d 00 00       	call   801e9b <spawnl>
  80011f:	83 c4 20             	add    $0x20,%esp
  800122:	85 c0                	test   %eax,%eax
  800124:	79 12                	jns    800138 <umain+0xe5>
		panic("spawn: %i", r);
  800126:	50                   	push   %eax
  800127:	68 20 29 80 00       	push   $0x802920
  80012c:	6a 21                	push   $0x21
  80012e:	68 df 28 80 00       	push   $0x8028df
  800133:	e8 a4 00 00 00       	call   8001dc <_panic>
	wait(r);
  800138:	83 ec 0c             	sub    $0xc,%esp
  80013b:	50                   	push   %eax
  80013c:	e8 20 21 00 00       	call   802261 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	ff 35 00 30 80 00    	pushl  0x803000
  80014a:	68 00 00 00 a0       	push   $0xa0000000
  80014f:	e8 8f 07 00 00       	call   8008e3 <strcmp>
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	ba c0 28 80 00       	mov    $0x8028c0,%edx
  80015c:	85 c0                	test   %eax,%eax
  80015e:	74 05                	je     800165 <umain+0x112>
  800160:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	52                   	push   %edx
  800169:	68 2a 29 80 00       	push   $0x80292a
  80016e:	e8 42 01 00 00       	call   8002b5 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800173:	cc                   	int3   
  800174:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  800177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
  800181:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800184:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800187:	e8 79 0a 00 00       	call   800c05 <sys_getenvid>
  80018c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800191:	6b c0 78             	imul   $0x78,%eax,%eax
  800194:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800199:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019e:	85 db                	test   %ebx,%ebx
  8001a0:	7e 07                	jle    8001a9 <libmain+0x2d>
		binaryname = argv[0];
  8001a2:	8b 06                	mov    (%esi),%eax
  8001a4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	e8 a0 fe ff ff       	call   800053 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8001b3:	e8 0a 00 00 00       	call   8001c2 <exit>
  8001b8:	83 c4 10             	add    $0x10,%esp
#endif
}
  8001bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c8:	e8 35 11 00 00       	call   801302 <close_all>
	sys_env_destroy(0);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	6a 00                	push   $0x0
  8001d2:	e8 ed 09 00 00       	call   800bc4 <sys_env_destroy>
  8001d7:	83 c4 10             	add    $0x10,%esp
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e4:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001ea:	e8 16 0a 00 00       	call   800c05 <sys_getenvid>
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	56                   	push   %esi
  8001f9:	50                   	push   %eax
  8001fa:	68 70 29 80 00       	push   $0x802970
  8001ff:	e8 b1 00 00 00       	call   8002b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	83 c4 18             	add    $0x18,%esp
  800207:	53                   	push   %ebx
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	e8 54 00 00 00       	call   800264 <vcprintf>
	cprintf("\n");
  800210:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  800217:	e8 99 00 00 00       	call   8002b5 <cprintf>
  80021c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x43>

00800222 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	53                   	push   %ebx
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022c:	8b 13                	mov    (%ebx),%edx
  80022e:	8d 42 01             	lea    0x1(%edx),%eax
  800231:	89 03                	mov    %eax,(%ebx)
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023f:	75 1a                	jne    80025b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	68 ff 00 00 00       	push   $0xff
  800249:	8d 43 08             	lea    0x8(%ebx),%eax
  80024c:	50                   	push   %eax
  80024d:	e8 35 09 00 00       	call   800b87 <sys_cputs>
		b->idx = 0;
  800252:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800258:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80026d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800274:	00 00 00 
	b.cnt = 0;
  800277:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028d:	50                   	push   %eax
  80028e:	68 22 02 80 00       	push   $0x800222
  800293:	e8 4f 01 00 00       	call   8003e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800298:	83 c4 08             	add    $0x8,%esp
  80029b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a7:	50                   	push   %eax
  8002a8:	e8 da 08 00 00       	call   800b87 <sys_cputs>

	return b.cnt;
}
  8002ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002be:	50                   	push   %eax
  8002bf:	ff 75 08             	pushl  0x8(%ebp)
  8002c2:	e8 9d ff ff ff       	call   800264 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 1c             	sub    $0x1c,%esp
  8002d2:	89 c7                	mov    %eax,%edi
  8002d4:	89 d6                	mov    %edx,%esi
  8002d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dc:	89 d1                	mov    %edx,%ecx
  8002de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002f4:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8002f7:	72 05                	jb     8002fe <printnum+0x35>
  8002f9:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002fc:	77 3e                	ja     80033c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fe:	83 ec 0c             	sub    $0xc,%esp
  800301:	ff 75 18             	pushl  0x18(%ebp)
  800304:	83 eb 01             	sub    $0x1,%ebx
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030f:	ff 75 e0             	pushl  -0x20(%ebp)
  800312:	ff 75 dc             	pushl  -0x24(%ebp)
  800315:	ff 75 d8             	pushl  -0x28(%ebp)
  800318:	e8 e3 22 00 00       	call   802600 <__udivdi3>
  80031d:	83 c4 18             	add    $0x18,%esp
  800320:	52                   	push   %edx
  800321:	50                   	push   %eax
  800322:	89 f2                	mov    %esi,%edx
  800324:	89 f8                	mov    %edi,%eax
  800326:	e8 9e ff ff ff       	call   8002c9 <printnum>
  80032b:	83 c4 20             	add    $0x20,%esp
  80032e:	eb 13                	jmp    800343 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800330:	83 ec 08             	sub    $0x8,%esp
  800333:	56                   	push   %esi
  800334:	ff 75 18             	pushl  0x18(%ebp)
  800337:	ff d7                	call   *%edi
  800339:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033c:	83 eb 01             	sub    $0x1,%ebx
  80033f:	85 db                	test   %ebx,%ebx
  800341:	7f ed                	jg     800330 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	56                   	push   %esi
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034d:	ff 75 e0             	pushl  -0x20(%ebp)
  800350:	ff 75 dc             	pushl  -0x24(%ebp)
  800353:	ff 75 d8             	pushl  -0x28(%ebp)
  800356:	e8 d5 23 00 00       	call   802730 <__umoddi3>
  80035b:	83 c4 14             	add    $0x14,%esp
  80035e:	0f be 80 93 29 80 00 	movsbl 0x802993(%eax),%eax
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
  800368:	83 c4 10             	add    $0x10,%esp
}
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800376:	83 fa 01             	cmp    $0x1,%edx
  800379:	7e 0e                	jle    800389 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	8b 52 04             	mov    0x4(%edx),%edx
  800387:	eb 22                	jmp    8003ab <getuint+0x38>
	else if (lflag)
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 10                	je     80039d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 0e                	jmp    8003ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	88 02                	mov    %al,(%edx)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d3:	50                   	push   %eax
  8003d4:	ff 75 10             	pushl  0x10(%ebp)
  8003d7:	ff 75 0c             	pushl  0xc(%ebp)
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	e8 05 00 00 00       	call   8003e7 <vprintfmt>
	va_end(ap);
  8003e2:	83 c4 10             	add    $0x10,%esp
}
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 2c             	sub    $0x2c,%esp
  8003f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f9:	eb 12                	jmp    80040d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	0f 84 8d 03 00 00    	je     800790 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	53                   	push   %ebx
  800407:	50                   	push   %eax
  800408:	ff d6                	call   *%esi
  80040a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	83 c7 01             	add    $0x1,%edi
  800410:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800414:	83 f8 25             	cmp    $0x25,%eax
  800417:	75 e2                	jne    8003fb <vprintfmt+0x14>
  800419:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800424:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800432:	ba 00 00 00 00       	mov    $0x0,%edx
  800437:	eb 07                	jmp    800440 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8d 47 01             	lea    0x1(%edi),%eax
  800443:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800446:	0f b6 07             	movzbl (%edi),%eax
  800449:	0f b6 c8             	movzbl %al,%ecx
  80044c:	83 e8 23             	sub    $0x23,%eax
  80044f:	3c 55                	cmp    $0x55,%al
  800451:	0f 87 1e 03 00 00    	ja     800775 <vprintfmt+0x38e>
  800457:	0f b6 c0             	movzbl %al,%eax
  80045a:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800464:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800468:	eb d6                	jmp    800440 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800475:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800478:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800482:	83 fa 09             	cmp    $0x9,%edx
  800485:	77 38                	ja     8004bf <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800487:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048a:	eb e9                	jmp    800475 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 48 04             	lea    0x4(%eax),%ecx
  800492:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049d:	eb 26                	jmp    8004c5 <vprintfmt+0xde>
  80049f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a2:	89 c8                	mov    %ecx,%eax
  8004a4:	c1 f8 1f             	sar    $0x1f,%eax
  8004a7:	f7 d0                	not    %eax
  8004a9:	21 c1                	and    %eax,%ecx
  8004ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b1:	eb 8d                	jmp    800440 <vprintfmt+0x59>
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bd:	eb 81                	jmp    800440 <vprintfmt+0x59>
  8004bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	0f 89 71 ff ff ff    	jns    800440 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004dc:	e9 5f ff ff ff       	jmp    800440 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e7:	e9 54 ff ff ff       	jmp    800440 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	ff 30                	pushl  (%eax)
  8004fb:	ff d6                	call   *%esi
			break;
  8004fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800503:	e9 05 ff ff ff       	jmp    80040d <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	99                   	cltd   
  800514:	31 d0                	xor    %edx,%eax
  800516:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800518:	83 f8 0f             	cmp    $0xf,%eax
  80051b:	7f 0b                	jg     800528 <vprintfmt+0x141>
  80051d:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  800524:	85 d2                	test   %edx,%edx
  800526:	75 18                	jne    800540 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800528:	50                   	push   %eax
  800529:	68 ab 29 80 00       	push   $0x8029ab
  80052e:	53                   	push   %ebx
  80052f:	56                   	push   %esi
  800530:	e8 95 fe ff ff       	call   8003ca <printfmt>
  800535:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053b:	e9 cd fe ff ff       	jmp    80040d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800540:	52                   	push   %edx
  800541:	68 41 2e 80 00       	push   $0x802e41
  800546:	53                   	push   %ebx
  800547:	56                   	push   %esi
  800548:	e8 7d fe ff ff       	call   8003ca <printfmt>
  80054d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	e9 b5 fe ff ff       	jmp    80040d <vprintfmt+0x26>
  800558:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055e:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 38                	mov    (%eax),%edi
  80056c:	85 ff                	test   %edi,%edi
  80056e:	75 05                	jne    800575 <vprintfmt+0x18e>
				p = "(null)";
  800570:	bf a4 29 80 00       	mov    $0x8029a4,%edi
			if (width > 0 && padc != '-')
  800575:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800579:	0f 84 91 00 00 00    	je     800610 <vprintfmt+0x229>
  80057f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800583:	0f 8e 95 00 00 00    	jle    80061e <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	51                   	push   %ecx
  80058d:	57                   	push   %edi
  80058e:	e8 85 02 00 00       	call   800818 <strnlen>
  800593:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800596:	29 c1                	sub    %eax,%ecx
  800598:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005aa:	eb 0f                	jmp    8005bb <vprintfmt+0x1d4>
					putch(padc, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	83 ef 01             	sub    $0x1,%edi
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	7f ed                	jg     8005ac <vprintfmt+0x1c5>
  8005bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c5:	89 c8                	mov    %ecx,%eax
  8005c7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ca:	f7 d0                	not    %eax
  8005cc:	21 c8                	and    %ecx,%eax
  8005ce:	29 c1                	sub    %eax,%ecx
  8005d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d9:	89 cb                	mov    %ecx,%ebx
  8005db:	eb 4d                	jmp    80062a <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x217>
  8005e3:	0f be c0             	movsbl %al,%eax
  8005e6:	83 e8 20             	sub    $0x20,%eax
  8005e9:	83 f8 5e             	cmp    $0x5e,%eax
  8005ec:	76 10                	jbe    8005fe <vprintfmt+0x217>
					putch('?', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb 0d                	jmp    80060b <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	52                   	push   %edx
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	eb 1a                	jmp    80062a <vprintfmt+0x243>
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800619:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061c:	eb 0c                	jmp    80062a <vprintfmt+0x243>
  80061e:	89 75 08             	mov    %esi,0x8(%ebp)
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800624:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800627:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	0f be d0             	movsbl %al,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 23                	je     80065b <vprintfmt+0x274>
  800638:	85 f6                	test   %esi,%esi
  80063a:	78 a1                	js     8005dd <vprintfmt+0x1f6>
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	79 9c                	jns    8005dd <vprintfmt+0x1f6>
  800641:	89 df                	mov    %ebx,%edi
  800643:	8b 75 08             	mov    0x8(%ebp),%esi
  800646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800649:	eb 18                	jmp    800663 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 20                	push   $0x20
  800651:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 08                	jmp    800663 <vprintfmt+0x27c>
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800663:	85 ff                	test   %edi,%edi
  800665:	7f e4                	jg     80064b <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 9e fd ff ff       	jmp    80040d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 fa 01             	cmp    $0x1,%edx
  800672:	7e 16                	jle    80068a <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 08             	lea    0x8(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 50 04             	mov    0x4(%eax),%edx
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800688:	eb 32                	jmp    8006bc <vprintfmt+0x2d5>
	else if (lflag)
  80068a:	85 d2                	test   %edx,%edx
  80068c:	74 18                	je     8006a6 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 c1                	mov    %eax,%ecx
  80069e:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a4:	eb 16                	jmp    8006bc <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 c1                	mov    %eax,%ecx
  8006b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006cb:	79 74                	jns    800741 <vprintfmt+0x35a>
				putch('-', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 2d                	push   $0x2d
  8006d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006db:	f7 d8                	neg    %eax
  8006dd:	83 d2 00             	adc    $0x0,%edx
  8006e0:	f7 da                	neg    %edx
  8006e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ea:	eb 55                	jmp    800741 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 7f fc ff ff       	call   800373 <getuint>
			base = 10;
  8006f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f9:	eb 46                	jmp    800741 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 70 fc ff ff       	call   800373 <getuint>
			base = 8;
  800703:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800708:	eb 37                	jmp    800741 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 30                	push   $0x30
  800710:	ff d6                	call   *%esi
			putch('x', putdat);
  800712:	83 c4 08             	add    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 78                	push   $0x78
  800718:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800723:	8b 00                	mov    (%eax),%eax
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800732:	eb 0d                	jmp    800741 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800734:	8d 45 14             	lea    0x14(%ebp),%eax
  800737:	e8 37 fc ff ff       	call   800373 <getuint>
			base = 16;
  80073c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800748:	57                   	push   %edi
  800749:	ff 75 e0             	pushl  -0x20(%ebp)
  80074c:	51                   	push   %ecx
  80074d:	52                   	push   %edx
  80074e:	50                   	push   %eax
  80074f:	89 da                	mov    %ebx,%edx
  800751:	89 f0                	mov    %esi,%eax
  800753:	e8 71 fb ff ff       	call   8002c9 <printnum>
			break;
  800758:	83 c4 20             	add    $0x20,%esp
  80075b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075e:	e9 aa fc ff ff       	jmp    80040d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	51                   	push   %ecx
  800768:	ff d6                	call   *%esi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800770:	e9 98 fc ff ff       	jmp    80040d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 25                	push   $0x25
  80077b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 03                	jmp    800785 <vprintfmt+0x39e>
  800782:	83 ef 01             	sub    $0x1,%edi
  800785:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800789:	75 f7                	jne    800782 <vprintfmt+0x39b>
  80078b:	e9 7d fc ff ff       	jmp    80040d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 18             	sub    $0x18,%esp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	74 26                	je     8007df <vsnprintf+0x47>
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	7e 22                	jle    8007df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bd:	ff 75 14             	pushl  0x14(%ebp)
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c6:	50                   	push   %eax
  8007c7:	68 ad 03 80 00       	push   $0x8003ad
  8007cc:	e8 16 fc ff ff       	call   8003e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 05                	jmp    8007e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	ff 75 08             	pushl  0x8(%ebp)
  8007f9:	e8 9a ff ff ff       	call   800798 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strlen+0x10>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	75 f7                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	eb 03                	jmp    80082b <strnlen+0x13>
		n++;
  800828:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 08                	je     800837 <strnlen+0x1f>
  80082f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800833:	75 f3                	jne    800828 <strnlen+0x10>
  800835:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800852:	84 db                	test   %bl,%bl
  800854:	75 ef                	jne    800845 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800856:	5b                   	pop    %ebx
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800860:	53                   	push   %ebx
  800861:	e8 9a ff ff ff       	call   800800 <strlen>
  800866:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	01 d8                	add    %ebx,%eax
  80086e:	50                   	push   %eax
  80086f:	e8 c5 ff ff ff       	call   800839 <strcpy>
	return dst;
}
  800874:	89 d8                	mov    %ebx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 75 08             	mov    0x8(%ebp),%esi
  800883:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800886:	89 f3                	mov    %esi,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088b:	89 f2                	mov    %esi,%edx
  80088d:	eb 0f                	jmp    80089e <strncpy+0x23>
		*dst++ = *src;
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800898:	80 39 01             	cmpb   $0x1,(%ecx)
  80089b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089e:	39 da                	cmp    %ebx,%edx
  8008a0:	75 ed                	jne    80088f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	74 21                	je     8008dd <strlcpy+0x35>
  8008bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c0:	89 f2                	mov    %esi,%edx
  8008c2:	eb 09                	jmp    8008cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cd:	39 c2                	cmp    %eax,%edx
  8008cf:	74 09                	je     8008da <strlcpy+0x32>
  8008d1:	0f b6 19             	movzbl (%ecx),%ebx
  8008d4:	84 db                	test   %bl,%bl
  8008d6:	75 ec                	jne    8008c4 <strlcpy+0x1c>
  8008d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008dd:	29 f0                	sub    %esi,%eax
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ec:	eb 06                	jmp    8008f4 <strcmp+0x11>
		p++, q++;
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f4:	0f b6 01             	movzbl (%ecx),%eax
  8008f7:	84 c0                	test   %al,%al
  8008f9:	74 04                	je     8008ff <strcmp+0x1c>
  8008fb:	3a 02                	cmp    (%edx),%al
  8008fd:	74 ef                	je     8008ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 c0             	movzbl %al,%eax
  800902:	0f b6 12             	movzbl (%edx),%edx
  800905:	29 d0                	sub    %edx,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
  800913:	89 c3                	mov    %eax,%ebx
  800915:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800918:	eb 06                	jmp    800920 <strncmp+0x17>
		n--, p++, q++;
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800920:	39 d8                	cmp    %ebx,%eax
  800922:	74 15                	je     800939 <strncmp+0x30>
  800924:	0f b6 08             	movzbl (%eax),%ecx
  800927:	84 c9                	test   %cl,%cl
  800929:	74 04                	je     80092f <strncmp+0x26>
  80092b:	3a 0a                	cmp    (%edx),%cl
  80092d:	74 eb                	je     80091a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092f:	0f b6 00             	movzbl (%eax),%eax
  800932:	0f b6 12             	movzbl (%edx),%edx
  800935:	29 d0                	sub    %edx,%eax
  800937:	eb 05                	jmp    80093e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094b:	eb 07                	jmp    800954 <strchr+0x13>
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 0f                	je     800960 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	0f b6 10             	movzbl (%eax),%edx
  800957:	84 d2                	test   %dl,%dl
  800959:	75 f2                	jne    80094d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096c:	eb 03                	jmp    800971 <strfind+0xf>
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800974:	84 d2                	test   %dl,%dl
  800976:	74 04                	je     80097c <strfind+0x1a>
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	75 f2                	jne    80096e <strfind+0xc>
			break;
	return (char *) s;
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 7d 08             	mov    0x8(%ebp),%edi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 36                	je     8009c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800994:	75 28                	jne    8009be <memset+0x40>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 23                	jne    8009be <memset+0x40>
		c &= 0xFF;
  80099b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099f:	89 d3                	mov    %edx,%ebx
  8009a1:	c1 e3 08             	shl    $0x8,%ebx
  8009a4:	89 d6                	mov    %edx,%esi
  8009a6:	c1 e6 18             	shl    $0x18,%esi
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	c1 e0 10             	shl    $0x10,%eax
  8009ae:	09 f0                	or     %esi,%eax
  8009b0:	09 c2                	or     %eax,%edx
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b9:	fc                   	cld    
  8009ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bc:	eb 06                	jmp    8009c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c1:	fc                   	cld    
  8009c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d9:	39 c6                	cmp    %eax,%esi
  8009db:	73 35                	jae    800a12 <memmove+0x47>
  8009dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	73 2e                	jae    800a12 <memmove+0x47>
		s += n;
		d += n;
  8009e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e7:	89 d6                	mov    %edx,%esi
  8009e9:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f1:	75 13                	jne    800a06 <memmove+0x3b>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0e                	jne    800a06 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f8:	83 ef 04             	sub    $0x4,%edi
  8009fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a01:	fd                   	std    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb 09                	jmp    800a0f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a06:	83 ef 01             	sub    $0x1,%edi
  800a09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0f:	fc                   	cld    
  800a10:	eb 1d                	jmp    800a2f <memmove+0x64>
  800a12:	89 f2                	mov    %esi,%edx
  800a14:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f6 c2 03             	test   $0x3,%dl
  800a19:	75 0f                	jne    800a2a <memmove+0x5f>
  800a1b:	f6 c1 03             	test   $0x3,%cl
  800a1e:	75 0a                	jne    800a2a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a20:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a28:	eb 05                	jmp    800a2f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a36:	ff 75 10             	pushl  0x10(%ebp)
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	ff 75 08             	pushl  0x8(%ebp)
  800a3f:	e8 87 ff ff ff       	call   8009cb <memmove>
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	89 c6                	mov    %eax,%esi
  800a53:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a56:	eb 1a                	jmp    800a72 <memcmp+0x2c>
		if (*s1 != *s2)
  800a58:	0f b6 08             	movzbl (%eax),%ecx
  800a5b:	0f b6 1a             	movzbl (%edx),%ebx
  800a5e:	38 d9                	cmp    %bl,%cl
  800a60:	74 0a                	je     800a6c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a62:	0f b6 c1             	movzbl %cl,%eax
  800a65:	0f b6 db             	movzbl %bl,%ebx
  800a68:	29 d8                	sub    %ebx,%eax
  800a6a:	eb 0f                	jmp    800a7b <memcmp+0x35>
		s1++, s2++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a72:	39 f0                	cmp    %esi,%eax
  800a74:	75 e2                	jne    800a58 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a88:	89 c2                	mov    %eax,%edx
  800a8a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8d:	eb 07                	jmp    800a96 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8f:	38 08                	cmp    %cl,(%eax)
  800a91:	74 07                	je     800a9a <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	39 d0                	cmp    %edx,%eax
  800a98:	72 f5                	jb     800a8f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa8:	eb 03                	jmp    800aad <strtol+0x11>
		s++;
  800aaa:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	0f b6 01             	movzbl (%ecx),%eax
  800ab0:	3c 09                	cmp    $0x9,%al
  800ab2:	74 f6                	je     800aaa <strtol+0xe>
  800ab4:	3c 20                	cmp    $0x20,%al
  800ab6:	74 f2                	je     800aaa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab8:	3c 2b                	cmp    $0x2b,%al
  800aba:	75 0a                	jne    800ac6 <strtol+0x2a>
		s++;
  800abc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac4:	eb 10                	jmp    800ad6 <strtol+0x3a>
  800ac6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acb:	3c 2d                	cmp    $0x2d,%al
  800acd:	75 07                	jne    800ad6 <strtol+0x3a>
		s++, neg = 1;
  800acf:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ad2:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	0f 94 c0             	sete   %al
  800adb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae1:	75 19                	jne    800afc <strtol+0x60>
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	75 14                	jne    800afc <strtol+0x60>
  800ae8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aec:	0f 85 8a 00 00 00    	jne    800b7c <strtol+0xe0>
		s += 2, base = 16;
  800af2:	83 c1 02             	add    $0x2,%ecx
  800af5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800afa:	eb 16                	jmp    800b12 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afc:	84 c0                	test   %al,%al
  800afe:	74 12                	je     800b12 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b00:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b05:	80 39 30             	cmpb   $0x30,(%ecx)
  800b08:	75 08                	jne    800b12 <strtol+0x76>
		s++, base = 8;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1a:	0f b6 11             	movzbl (%ecx),%edx
  800b1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b20:	89 f3                	mov    %esi,%ebx
  800b22:	80 fb 09             	cmp    $0x9,%bl
  800b25:	77 08                	ja     800b2f <strtol+0x93>
			dig = *s - '0';
  800b27:	0f be d2             	movsbl %dl,%edx
  800b2a:	83 ea 30             	sub    $0x30,%edx
  800b2d:	eb 22                	jmp    800b51 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b32:	89 f3                	mov    %esi,%ebx
  800b34:	80 fb 19             	cmp    $0x19,%bl
  800b37:	77 08                	ja     800b41 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b39:	0f be d2             	movsbl %dl,%edx
  800b3c:	83 ea 57             	sub    $0x57,%edx
  800b3f:	eb 10                	jmp    800b51 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b44:	89 f3                	mov    %esi,%ebx
  800b46:	80 fb 19             	cmp    $0x19,%bl
  800b49:	77 16                	ja     800b61 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b4b:	0f be d2             	movsbl %dl,%edx
  800b4e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b54:	7d 0f                	jge    800b65 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b56:	83 c1 01             	add    $0x1,%ecx
  800b59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5f:	eb b9                	jmp    800b1a <strtol+0x7e>
  800b61:	89 c2                	mov    %eax,%edx
  800b63:	eb 02                	jmp    800b67 <strtol+0xcb>
  800b65:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6b:	74 05                	je     800b72 <strtol+0xd6>
		*endptr = (char *) s;
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b70:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b72:	85 ff                	test   %edi,%edi
  800b74:	74 0c                	je     800b82 <strtol+0xe6>
  800b76:	89 d0                	mov    %edx,%eax
  800b78:	f7 d8                	neg    %eax
  800b7a:	eb 06                	jmp    800b82 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	84 c0                	test   %al,%al
  800b7e:	75 8a                	jne    800b0a <strtol+0x6e>
  800b80:	eb 90                	jmp    800b12 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	89 c3                	mov    %eax,%ebx
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	89 c6                	mov    %eax,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800bcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 cb                	mov    %ecx,%ebx
  800bdc:	89 cf                	mov    %ecx,%edi
  800bde:	89 ce                	mov    %ecx,%esi
  800be0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 03                	push   $0x3
  800bec:	68 df 2c 80 00       	push   $0x802cdf
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 fc 2c 80 00       	push   $0x802cfc
  800bf8:	e8 df f5 ff ff       	call   8001dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 02 00 00 00       	mov    $0x2,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_yield>:

void
sys_yield(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	89 f7                	mov    %esi,%edi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 df 2c 80 00       	push   $0x802cdf
  800c72:	6a 23                	push   $0x23
  800c74:	68 fc 2c 80 00       	push   $0x802cfc
  800c79:	e8 5e f5 ff ff       	call   8001dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 05                	push   $0x5
  800caf:	68 df 2c 80 00       	push   $0x802cdf
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 fc 2c 80 00       	push   $0x802cfc
  800cbb:	e8 1c f5 ff ff       	call   8001dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 06                	push   $0x6
  800cf1:	68 df 2c 80 00       	push   $0x802cdf
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 fc 2c 80 00       	push   $0x802cfc
  800cfd:	e8 da f4 ff ff       	call   8001dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 08                	push   $0x8
  800d33:	68 df 2c 80 00       	push   $0x802cdf
  800d38:	6a 23                	push   $0x23
  800d3a:	68 fc 2c 80 00       	push   $0x802cfc
  800d3f:	e8 98 f4 ff ff       	call   8001dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 09                	push   $0x9
  800d75:	68 df 2c 80 00       	push   $0x802cdf
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 fc 2c 80 00       	push   $0x802cfc
  800d81:	e8 56 f4 ff ff       	call   8001dc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 0a                	push   $0xa
  800db7:	68 df 2c 80 00       	push   $0x802cdf
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 fc 2c 80 00       	push   $0x802cfc
  800dc3:	e8 14 f4 ff ff       	call   8001dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 cb                	mov    %ecx,%ebx
  800e0b:	89 cf                	mov    %ecx,%edi
  800e0d:	89 ce                	mov    %ecx,%esi
  800e0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7e 17                	jle    800e2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 0d                	push   $0xd
  800e1b:	68 df 2c 80 00       	push   $0x802cdf
  800e20:	6a 23                	push   $0x23
  800e22:	68 fc 2c 80 00       	push   $0x802cfc
  800e27:	e8 b0 f3 ff ff       	call   8001dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_gettime>:

int sys_gettime(void)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e44:	89 d1                	mov    %edx,%ecx
  800e46:	89 d3                	mov    %edx,%ebx
  800e48:	89 d7                	mov    %edx,%edi
  800e4a:	89 d6                	mov    %edx,%esi
  800e4c:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800e5d:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800e5f:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e63:	74 2e                	je     800e93 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 16             	shr    $0x16,%edx
  800e6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 1d                	je     800e93 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 0c             	shr    $0xc,%edx
  800e7b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800e82:	f6 c1 01             	test   $0x1,%cl
  800e85:	74 0c                	je     800e93 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800e87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800e8e:	f6 c6 08             	test   $0x8,%dh
  800e91:	75 14                	jne    800ea7 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 0a 2d 80 00       	push   $0x802d0a
  800e9b:	6a 28                	push   $0x28
  800e9d:	68 1c 2d 80 00       	push   $0x802d1c
  800ea2:	e8 35 f3 ff ff       	call   8001dc <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800ea7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eac:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	6a 07                	push   $0x7
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 84 fd ff ff       	call   800c43 <sys_page_alloc>
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 14                	jns    800eda <pgfault+0x87>
		panic("sys_page_alloc");
  800ec6:	83 ec 04             	sub    $0x4,%esp
  800ec9:	68 27 2d 80 00       	push   $0x802d27
  800ece:	6a 2c                	push   $0x2c
  800ed0:	68 1c 2d 80 00       	push   $0x802d1c
  800ed5:	e8 02 f3 ff ff       	call   8001dc <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	68 00 10 00 00       	push   $0x1000
  800ee2:	53                   	push   %ebx
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	e8 46 fb ff ff       	call   800a33 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800eed:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef4:	53                   	push   %ebx
  800ef5:	6a 00                	push   $0x0
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	6a 00                	push   $0x0
  800efe:	e8 83 fd ff ff       	call   800c86 <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 14                	jns    800f1e <pgfault+0xcb>
		panic("sys_page_map");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 36 2d 80 00       	push   $0x802d36
  800f12:	6a 2f                	push   $0x2f
  800f14:	68 1c 2d 80 00       	push   $0x802d1c
  800f19:	e8 be f2 ff ff       	call   8001dc <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f1e:	83 ec 08             	sub    $0x8,%esp
  800f21:	68 00 f0 7f 00       	push   $0x7ff000
  800f26:	6a 00                	push   $0x0
  800f28:	e8 9b fd ff ff       	call   800cc8 <sys_page_unmap>
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	79 14                	jns    800f48 <pgfault+0xf5>
		panic("sys_page_unmap");
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	68 43 2d 80 00       	push   $0x802d43
  800f3c:	6a 31                	push   $0x31
  800f3e:	68 1c 2d 80 00       	push   $0x802d1c
  800f43:	e8 94 f2 ff ff       	call   8001dc <_panic>
	return;
}
  800f48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800f56:	68 53 0e 80 00       	push   $0x800e53
  800f5b:	e8 df 14 00 00       	call   80243f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f60:	b8 07 00 00 00       	mov    $0x7,%eax
  800f65:	cd 30                	int    $0x30
  800f67:	89 c7                	mov    %eax,%edi
  800f69:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	75 21                	jne    800f94 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f73:	e8 8d fc ff ff       	call   800c05 <sys_getenvid>
  800f78:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7d:	6b c0 78             	imul   $0x78,%eax,%eax
  800f80:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f85:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	e9 80 01 00 00       	jmp    801114 <fork+0x1c7>
	}
	if (envid < 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 12                	jns    800faa <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800f98:	50                   	push   %eax
  800f99:	68 52 2d 80 00       	push   $0x802d52
  800f9e:	6a 70                	push   $0x70
  800fa0:	68 1c 2d 80 00       	push   $0x802d1c
  800fa5:	e8 32 f2 ff ff       	call   8001dc <_panic>
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800faf:	89 d8                	mov    %ebx,%eax
  800fb1:	c1 e8 16             	shr    $0x16,%eax
  800fb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbb:	a8 01                	test   $0x1,%al
  800fbd:	0f 84 de 00 00 00    	je     8010a1 <fork+0x154>
  800fc3:	89 de                	mov    %ebx,%esi
  800fc5:	c1 ee 0c             	shr    $0xc,%esi
  800fc8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fcf:	a8 01                	test   $0x1,%al
  800fd1:	0f 84 ca 00 00 00    	je     8010a1 <fork+0x154>
  800fd7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fde:	a8 04                	test   $0x4,%al
  800fe0:	0f 84 bb 00 00 00    	je     8010a1 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  800fe6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  800fed:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  800ff0:	f6 c4 04             	test   $0x4,%ah
  800ff3:	74 34                	je     801029 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	50                   	push   %eax
  800ffe:	56                   	push   %esi
  800fff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	e8 7c fc ff ff       	call   800c86 <sys_page_map>
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	0f 84 8c 00 00 00    	je     8010a1 <fork+0x154>
        	panic("duppage share");
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 62 2d 80 00       	push   $0x802d62
  80101d:	6a 48                	push   $0x48
  80101f:	68 1c 2d 80 00       	push   $0x802d1c
  801024:	e8 b3 f1 ff ff       	call   8001dc <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801029:	a9 02 08 00 00       	test   $0x802,%eax
  80102e:	74 5d                	je     80108d <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	68 05 08 00 00       	push   $0x805
  801038:	56                   	push   %esi
  801039:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 42 fc ff ff       	call   800c86 <sys_page_map>
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 14                	jns    80105f <fork+0x112>
			panic("error");
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 c0 29 80 00       	push   $0x8029c0
  801053:	6a 4b                	push   $0x4b
  801055:	68 1c 2d 80 00       	push   $0x802d1c
  80105a:	e8 7d f1 ff ff       	call   8001dc <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	68 05 08 00 00       	push   $0x805
  801067:	56                   	push   %esi
  801068:	6a 00                	push   $0x0
  80106a:	56                   	push   %esi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 14 fc ff ff       	call   800c86 <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	79 28                	jns    8010a1 <fork+0x154>
			panic("error");
  801079:	83 ec 04             	sub    $0x4,%esp
  80107c:	68 c0 29 80 00       	push   $0x8029c0
  801081:	6a 4d                	push   $0x4d
  801083:	68 1c 2d 80 00       	push   $0x802d1c
  801088:	e8 4f f1 ff ff       	call   8001dc <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	6a 05                	push   $0x5
  801092:	56                   	push   %esi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 e8 fb ff ff       	call   800c86 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a7:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8010ad:	0f 85 fc fe ff ff    	jne    800faf <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	6a 07                	push   $0x7
  8010b8:	68 00 f0 7f ee       	push   $0xee7ff000
  8010bd:	57                   	push   %edi
  8010be:	e8 80 fb ff ff       	call   800c43 <sys_page_alloc>
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 14                	jns    8010de <fork+0x191>
		panic("1");
  8010ca:	83 ec 04             	sub    $0x4,%esp
  8010cd:	68 70 2d 80 00       	push   $0x802d70
  8010d2:	6a 78                	push   $0x78
  8010d4:	68 1c 2d 80 00       	push   $0x802d1c
  8010d9:	e8 fe f0 ff ff       	call   8001dc <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	68 ae 24 80 00       	push   $0x8024ae
  8010e6:	57                   	push   %edi
  8010e7:	e8 a2 fc ff ff       	call   800d8e <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	6a 02                	push   $0x2
  8010f1:	57                   	push   %edi
  8010f2:	e8 13 fc ff ff       	call   800d0a <sys_env_set_status>
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 14                	jns    801112 <fork+0x1c5>
		panic("sys_env_set_status");
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	68 72 2d 80 00       	push   $0x802d72
  801106:	6a 7d                	push   $0x7d
  801108:	68 1c 2d 80 00       	push   $0x802d1c
  80110d:	e8 ca f0 ff ff       	call   8001dc <_panic>

	return envid;
  801112:	89 f8                	mov    %edi,%eax
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sfork>:

// Challenge!
int
sfork(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801122:	68 85 2d 80 00       	push   $0x802d85
  801127:	68 86 00 00 00       	push   $0x86
  80112c:	68 1c 2d 80 00       	push   $0x802d1c
  801131:	e8 a6 f0 ff ff       	call   8001dc <_panic>

00801136 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	05 00 00 00 30       	add    $0x30000000,%eax
  801141:	c1 e8 0c             	shr    $0xc,%eax
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801151:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801156:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801168:	89 c2                	mov    %eax,%edx
  80116a:	c1 ea 16             	shr    $0x16,%edx
  80116d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	74 11                	je     80118a <fd_alloc+0x2d>
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 ea 0c             	shr    $0xc,%edx
  80117e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801185:	f6 c2 01             	test   $0x1,%dl
  801188:	75 09                	jne    801193 <fd_alloc+0x36>
			*fd_store = fd;
  80118a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 17                	jmp    8011aa <fd_alloc+0x4d>
  801193:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801198:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119d:	75 c9                	jne    801168 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b2:	83 f8 1f             	cmp    $0x1f,%eax
  8011b5:	77 36                	ja     8011ed <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b7:	c1 e0 0c             	shl    $0xc,%eax
  8011ba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 16             	shr    $0x16,%edx
  8011c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 24                	je     8011f4 <fd_lookup+0x48>
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	c1 ea 0c             	shr    $0xc,%edx
  8011d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	74 1a                	je     8011fb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e4:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 13                	jmp    801200 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 0c                	jmp    801200 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 05                	jmp    801200 <fd_lookup+0x54>
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120b:	ba 18 2e 80 00       	mov    $0x802e18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801210:	eb 13                	jmp    801225 <dev_lookup+0x23>
  801212:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801215:	39 08                	cmp    %ecx,(%eax)
  801217:	75 0c                	jne    801225 <dev_lookup+0x23>
			*dev = devtab[i];
  801219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 2e                	jmp    801253 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	75 e7                	jne    801212 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122b:	a1 04 40 80 00       	mov    0x804004,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	51                   	push   %ecx
  801237:	50                   	push   %eax
  801238:	68 9c 2d 80 00       	push   $0x802d9c
  80123d:	e8 73 f0 ff ff       	call   8002b5 <cprintf>
	*dev = 0;
  801242:	8b 45 0c             	mov    0xc(%ebp),%eax
  801245:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 10             	sub    $0x10,%esp
  80125d:	8b 75 08             	mov    0x8(%ebp),%esi
  801260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801267:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801270:	50                   	push   %eax
  801271:	e8 36 ff ff ff       	call   8011ac <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 05                	js     801282 <fd_close+0x2d>
	    || fd != fd2)
  80127d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801280:	74 0b                	je     80128d <fd_close+0x38>
		return (must_exist ? r : 0);
  801282:	80 fb 01             	cmp    $0x1,%bl
  801285:	19 d2                	sbb    %edx,%edx
  801287:	f7 d2                	not    %edx
  801289:	21 d0                	and    %edx,%eax
  80128b:	eb 41                	jmp    8012ce <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	ff 36                	pushl  (%esi)
  801296:	e8 67 ff ff ff       	call   801202 <dev_lookup>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 1a                	js     8012be <fd_close+0x69>
		if (dev->dev_close)
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	74 0b                	je     8012be <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	56                   	push   %esi
  8012b7:	ff d0                	call   *%eax
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	56                   	push   %esi
  8012c2:	6a 00                	push   $0x0
  8012c4:	e8 ff f9 ff ff       	call   800cc8 <sys_page_unmap>
	return r;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	89 d8                	mov    %ebx,%eax
}
  8012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 c5 fe ff ff       	call   8011ac <fd_lookup>
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	85 d2                	test   %edx,%edx
  8012ee:	78 10                	js     801300 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	6a 01                	push   $0x1
  8012f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f8:	e8 58 ff ff ff       	call   801255 <fd_close>
  8012fd:	83 c4 10             	add    $0x10,%esp
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <close_all>:

void
close_all(void)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	53                   	push   %ebx
  801312:	e8 be ff ff ff       	call   8012d5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801317:	83 c3 01             	add    $0x1,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	83 fb 20             	cmp    $0x20,%ebx
  801320:	75 ec                	jne    80130e <close_all+0xc>
		close(i);
}
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	57                   	push   %edi
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 2c             	sub    $0x2c,%esp
  801330:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801333:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 6d fe ff ff       	call   8011ac <fd_lookup>
  80133f:	89 c2                	mov    %eax,%edx
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	85 d2                	test   %edx,%edx
  801346:	0f 88 c1 00 00 00    	js     80140d <dup+0xe6>
		return r;
	close(newfdnum);
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	56                   	push   %esi
  801350:	e8 80 ff ff ff       	call   8012d5 <close>

	newfd = INDEX2FD(newfdnum);
  801355:	89 f3                	mov    %esi,%ebx
  801357:	c1 e3 0c             	shl    $0xc,%ebx
  80135a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801360:	83 c4 04             	add    $0x4,%esp
  801363:	ff 75 e4             	pushl  -0x1c(%ebp)
  801366:	e8 db fd ff ff       	call   801146 <fd2data>
  80136b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136d:	89 1c 24             	mov    %ebx,(%esp)
  801370:	e8 d1 fd ff ff       	call   801146 <fd2data>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137b:	89 f8                	mov    %edi,%eax
  80137d:	c1 e8 16             	shr    $0x16,%eax
  801380:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801387:	a8 01                	test   $0x1,%al
  801389:	74 37                	je     8013c2 <dup+0x9b>
  80138b:	89 f8                	mov    %edi,%eax
  80138d:	c1 e8 0c             	shr    $0xc,%eax
  801390:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801397:	f6 c2 01             	test   $0x1,%dl
  80139a:	74 26                	je     8013c2 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ab:	50                   	push   %eax
  8013ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013af:	6a 00                	push   $0x0
  8013b1:	57                   	push   %edi
  8013b2:	6a 00                	push   $0x0
  8013b4:	e8 cd f8 ff ff       	call   800c86 <sys_page_map>
  8013b9:	89 c7                	mov    %eax,%edi
  8013bb:	83 c4 20             	add    $0x20,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 2e                	js     8013f0 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c5:	89 d0                	mov    %edx,%eax
  8013c7:	c1 e8 0c             	shr    $0xc,%eax
  8013ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d9:	50                   	push   %eax
  8013da:	53                   	push   %ebx
  8013db:	6a 00                	push   $0x0
  8013dd:	52                   	push   %edx
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 a1 f8 ff ff       	call   800c86 <sys_page_map>
  8013e5:	89 c7                	mov    %eax,%edi
  8013e7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ea:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ec:	85 ff                	test   %edi,%edi
  8013ee:	79 1d                	jns    80140d <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	53                   	push   %ebx
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 cd f8 ff ff       	call   800cc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801401:	6a 00                	push   $0x0
  801403:	e8 c0 f8 ff ff       	call   800cc8 <sys_page_unmap>
	return r;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	89 f8                	mov    %edi,%eax
}
  80140d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	53                   	push   %ebx
  801419:	83 ec 14             	sub    $0x14,%esp
  80141c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	53                   	push   %ebx
  801424:	e8 83 fd ff ff       	call   8011ac <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	89 c2                	mov    %eax,%edx
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 6d                	js     80149f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	ff 30                	pushl  (%eax)
  80143e:	e8 bf fd ff ff       	call   801202 <dev_lookup>
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 4c                	js     801496 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144d:	8b 42 08             	mov    0x8(%edx),%eax
  801450:	83 e0 03             	and    $0x3,%eax
  801453:	83 f8 01             	cmp    $0x1,%eax
  801456:	75 21                	jne    801479 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801458:	a1 04 40 80 00       	mov    0x804004,%eax
  80145d:	8b 40 48             	mov    0x48(%eax),%eax
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	53                   	push   %ebx
  801464:	50                   	push   %eax
  801465:	68 dd 2d 80 00       	push   $0x802ddd
  80146a:	e8 46 ee ff ff       	call   8002b5 <cprintf>
		return -E_INVAL;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801477:	eb 26                	jmp    80149f <read+0x8a>
	}
	if (!dev->dev_read)
  801479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147c:	8b 40 08             	mov    0x8(%eax),%eax
  80147f:	85 c0                	test   %eax,%eax
  801481:	74 17                	je     80149a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	ff 75 10             	pushl  0x10(%ebp)
  801489:	ff 75 0c             	pushl  0xc(%ebp)
  80148c:	52                   	push   %edx
  80148d:	ff d0                	call   *%eax
  80148f:	89 c2                	mov    %eax,%edx
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	eb 09                	jmp    80149f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801496:	89 c2                	mov    %eax,%edx
  801498:	eb 05                	jmp    80149f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149f:	89 d0                	mov    %edx,%eax
  8014a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	57                   	push   %edi
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ba:	eb 21                	jmp    8014dd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	89 f0                	mov    %esi,%eax
  8014c1:	29 d8                	sub    %ebx,%eax
  8014c3:	50                   	push   %eax
  8014c4:	89 d8                	mov    %ebx,%eax
  8014c6:	03 45 0c             	add    0xc(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	57                   	push   %edi
  8014cb:	e8 45 ff ff ff       	call   801415 <read>
		if (m < 0)
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 0c                	js     8014e3 <readn+0x3d>
			return m;
		if (m == 0)
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	74 06                	je     8014e1 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014db:	01 c3                	add    %eax,%ebx
  8014dd:	39 f3                	cmp    %esi,%ebx
  8014df:	72 db                	jb     8014bc <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8014e1:	89 d8                	mov    %ebx,%eax
}
  8014e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 14             	sub    $0x14,%esp
  8014f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f8:	50                   	push   %eax
  8014f9:	53                   	push   %ebx
  8014fa:	e8 ad fc ff ff       	call   8011ac <fd_lookup>
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	89 c2                	mov    %eax,%edx
  801504:	85 c0                	test   %eax,%eax
  801506:	78 68                	js     801570 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	ff 30                	pushl  (%eax)
  801514:	e8 e9 fc ff ff       	call   801202 <dev_lookup>
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 47                	js     801567 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801527:	75 21                	jne    80154a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801529:	a1 04 40 80 00       	mov    0x804004,%eax
  80152e:	8b 40 48             	mov    0x48(%eax),%eax
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	53                   	push   %ebx
  801535:	50                   	push   %eax
  801536:	68 f9 2d 80 00       	push   $0x802df9
  80153b:	e8 75 ed ff ff       	call   8002b5 <cprintf>
		return -E_INVAL;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801548:	eb 26                	jmp    801570 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154d:	8b 52 0c             	mov    0xc(%edx),%edx
  801550:	85 d2                	test   %edx,%edx
  801552:	74 17                	je     80156b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	50                   	push   %eax
  80155e:	ff d2                	call   *%edx
  801560:	89 c2                	mov    %eax,%edx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb 09                	jmp    801570 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	89 c2                	mov    %eax,%edx
  801569:	eb 05                	jmp    801570 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801570:	89 d0                	mov    %edx,%eax
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <seek>:

int
seek(int fdnum, off_t offset)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	ff 75 08             	pushl  0x8(%ebp)
  801584:	e8 23 fc ff ff       	call   8011ac <fd_lookup>
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 0e                	js     80159e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801590:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 14             	sub    $0x14,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	53                   	push   %ebx
  8015af:	e8 f8 fb ff ff       	call   8011ac <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 65                	js     801622 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	ff 30                	pushl  (%eax)
  8015c9:	e8 34 fc ff ff       	call   801202 <dev_lookup>
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 44                	js     801619 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dc:	75 21                	jne    8015ff <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015de:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e3:	8b 40 48             	mov    0x48(%eax),%eax
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	50                   	push   %eax
  8015eb:	68 bc 2d 80 00       	push   $0x802dbc
  8015f0:	e8 c0 ec ff ff       	call   8002b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fd:	eb 23                	jmp    801622 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801602:	8b 52 18             	mov    0x18(%edx),%edx
  801605:	85 d2                	test   %edx,%edx
  801607:	74 14                	je     80161d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	ff 75 0c             	pushl  0xc(%ebp)
  80160f:	50                   	push   %eax
  801610:	ff d2                	call   *%edx
  801612:	89 c2                	mov    %eax,%edx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 09                	jmp    801622 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	89 c2                	mov    %eax,%edx
  80161b:	eb 05                	jmp    801622 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801622:	89 d0                	mov    %edx,%eax
  801624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 14             	sub    $0x14,%esp
  801630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	ff 75 08             	pushl  0x8(%ebp)
  80163a:	e8 6d fb ff ff       	call   8011ac <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 58                	js     8016a0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 a9 fb ff ff       	call   801202 <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 37                	js     801697 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801667:	74 32                	je     80169b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801669:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801673:	00 00 00 
	stat->st_isdir = 0;
  801676:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167d:	00 00 00 
	stat->st_dev = dev;
  801680:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	53                   	push   %ebx
  80168a:	ff 75 f0             	pushl  -0x10(%ebp)
  80168d:	ff 50 14             	call   *0x14(%eax)
  801690:	89 c2                	mov    %eax,%edx
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	eb 09                	jmp    8016a0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	89 c2                	mov    %eax,%edx
  801699:	eb 05                	jmp    8016a0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a0:	89 d0                	mov    %edx,%eax
  8016a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	6a 00                	push   $0x0
  8016b1:	ff 75 08             	pushl  0x8(%ebp)
  8016b4:	e8 e7 01 00 00       	call   8018a0 <open>
  8016b9:	89 c3                	mov    %eax,%ebx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 db                	test   %ebx,%ebx
  8016c0:	78 1b                	js     8016dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	53                   	push   %ebx
  8016c9:	e8 5b ff ff ff       	call   801629 <fstat>
  8016ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d0:	89 1c 24             	mov    %ebx,(%esp)
  8016d3:	e8 fd fb ff ff       	call   8012d5 <close>
	return r;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	89 f0                	mov    %esi,%eax
}
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	89 c6                	mov    %eax,%esi
  8016eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f4:	75 12                	jne    801708 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	6a 03                	push   $0x3
  8016fb:	e8 8d 0e 00 00       	call   80258d <ipc_find_env>
  801700:	a3 00 40 80 00       	mov    %eax,0x804000
  801705:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801708:	6a 07                	push   $0x7
  80170a:	68 00 50 80 00       	push   $0x805000
  80170f:	56                   	push   %esi
  801710:	ff 35 00 40 80 00    	pushl  0x804000
  801716:	e8 21 0e 00 00       	call   80253c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171b:	83 c4 0c             	add    $0xc,%esp
  80171e:	6a 00                	push   $0x0
  801720:	53                   	push   %ebx
  801721:	6a 00                	push   $0x0
  801723:	e8 ae 0d 00 00       	call   8024d6 <ipc_recv>
}
  801728:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	8b 40 0c             	mov    0xc(%eax),%eax
  80173b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801740:	8b 45 0c             	mov    0xc(%ebp),%eax
  801743:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 02 00 00 00       	mov    $0x2,%eax
  801752:	e8 8d ff ff ff       	call   8016e4 <fsipc>
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	8b 40 0c             	mov    0xc(%eax),%eax
  801765:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176a:	ba 00 00 00 00       	mov    $0x0,%edx
  80176f:	b8 06 00 00 00       	mov    $0x6,%eax
  801774:	e8 6b ff ff ff       	call   8016e4 <fsipc>
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 05 00 00 00       	mov    $0x5,%eax
  80179a:	e8 45 ff ff ff       	call   8016e4 <fsipc>
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	85 d2                	test   %edx,%edx
  8017a3:	78 2c                	js     8017d1 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	53                   	push   %ebx
  8017ae:	e8 86 f0 ff ff       	call   800839 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017be:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8017df:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e5:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8017eb:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8017f0:	76 05                	jbe    8017f7 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8017f2:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8017f7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	50                   	push   %eax
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	68 08 50 80 00       	push   $0x805008
  801808:	e8 be f1 ff ff       	call   8009cb <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 04 00 00 00       	mov    $0x4,%eax
  801817:	e8 c8 fe ff ff       	call   8016e4 <fsipc>
	return write;
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
  801823:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	8b 40 0c             	mov    0xc(%eax),%eax
  80182c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801831:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 03 00 00 00       	mov    $0x3,%eax
  801841:	e8 9e fe ff ff       	call   8016e4 <fsipc>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 4b                	js     801897 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184c:	39 c6                	cmp    %eax,%esi
  80184e:	73 16                	jae    801866 <devfile_read+0x48>
  801850:	68 28 2e 80 00       	push   $0x802e28
  801855:	68 2f 2e 80 00       	push   $0x802e2f
  80185a:	6a 7c                	push   $0x7c
  80185c:	68 44 2e 80 00       	push   $0x802e44
  801861:	e8 76 e9 ff ff       	call   8001dc <_panic>
	assert(r <= PGSIZE);
  801866:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186b:	7e 16                	jle    801883 <devfile_read+0x65>
  80186d:	68 4f 2e 80 00       	push   $0x802e4f
  801872:	68 2f 2e 80 00       	push   $0x802e2f
  801877:	6a 7d                	push   $0x7d
  801879:	68 44 2e 80 00       	push   $0x802e44
  80187e:	e8 59 e9 ff ff       	call   8001dc <_panic>
	memmove(buf, &fsipcbuf, r);
  801883:	83 ec 04             	sub    $0x4,%esp
  801886:	50                   	push   %eax
  801887:	68 00 50 80 00       	push   $0x805000
  80188c:	ff 75 0c             	pushl  0xc(%ebp)
  80188f:	e8 37 f1 ff ff       	call   8009cb <memmove>
	return r;
  801894:	83 c4 10             	add    $0x10,%esp
}
  801897:	89 d8                	mov    %ebx,%eax
  801899:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189c:	5b                   	pop    %ebx
  80189d:	5e                   	pop    %esi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 20             	sub    $0x20,%esp
  8018a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018aa:	53                   	push   %ebx
  8018ab:	e8 50 ef ff ff       	call   800800 <strlen>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b8:	7f 67                	jg     801921 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	e8 97 f8 ff ff       	call   80115d <fd_alloc>
  8018c6:	83 c4 10             	add    $0x10,%esp
		return r;
  8018c9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 57                	js     801926 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	68 00 50 80 00       	push   $0x805000
  8018d8:	e8 5c ef ff ff       	call   800839 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ed:	e8 f2 fd ff ff       	call   8016e4 <fsipc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	79 14                	jns    80190f <open+0x6f>
		fd_close(fd, 0);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	6a 00                	push   $0x0
  801900:	ff 75 f4             	pushl  -0xc(%ebp)
  801903:	e8 4d f9 ff ff       	call   801255 <fd_close>
		return r;
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	89 da                	mov    %ebx,%edx
  80190d:	eb 17                	jmp    801926 <open+0x86>
	}

	return fd2num(fd);
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	ff 75 f4             	pushl  -0xc(%ebp)
  801915:	e8 1c f8 ff ff       	call   801136 <fd2num>
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	eb 05                	jmp    801926 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801921:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801926:	89 d0                	mov    %edx,%eax
  801928:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 08 00 00 00       	mov    $0x8,%eax
  80193d:	e8 a2 fd ff ff       	call   8016e4 <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801950:	6a 00                	push   $0x0
  801952:	ff 75 08             	pushl  0x8(%ebp)
  801955:	e8 46 ff ff ff       	call   8018a0 <open>
  80195a:	89 c1                	mov    %eax,%ecx
  80195c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	0f 88 c6 04 00 00    	js     801e33 <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	68 00 02 00 00       	push   $0x200
  801975:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	51                   	push   %ecx
  80197d:	e8 24 fb ff ff       	call   8014a6 <readn>
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	3d 00 02 00 00       	cmp    $0x200,%eax
  80198a:	75 0c                	jne    801998 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80198c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801993:	45 4c 46 
  801996:	74 33                	je     8019cb <spawn+0x87>
		close(fd);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019a1:	e8 2f f9 ff ff       	call   8012d5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019a6:	83 c4 0c             	add    $0xc,%esp
  8019a9:	68 7f 45 4c 46       	push   $0x464c457f
  8019ae:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019b4:	68 5b 2e 80 00       	push   $0x802e5b
  8019b9:	e8 f7 e8 ff ff       	call   8002b5 <cprintf>
		return -E_NOT_EXEC;
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  8019c6:	e9 c8 04 00 00       	jmp    801e93 <spawn+0x54f>
  8019cb:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d0:	cd 30                	int    $0x30
  8019d2:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019d8:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	0f 88 55 04 00 00    	js     801e3b <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019e6:	89 c6                	mov    %eax,%esi
  8019e8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019ee:	6b f6 78             	imul   $0x78,%esi,%esi
  8019f1:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019f7:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019fd:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a04:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a0a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a10:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a15:	be 00 00 00 00       	mov    $0x0,%esi
  801a1a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a1d:	eb 13                	jmp    801a32 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	50                   	push   %eax
  801a23:	e8 d8 ed ff ff       	call   800800 <strlen>
  801a28:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a2c:	83 c3 01             	add    $0x1,%ebx
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a39:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	75 df                	jne    801a1f <spawn+0xdb>
  801a40:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a46:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a4c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a51:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a53:	89 fa                	mov    %edi,%edx
  801a55:	83 e2 fc             	and    $0xfffffffc,%edx
  801a58:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a5f:	29 c2                	sub    %eax,%edx
  801a61:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a67:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a6a:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a6f:	0f 86 d6 03 00 00    	jbe    801e4b <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a75:	83 ec 04             	sub    $0x4,%esp
  801a78:	6a 07                	push   $0x7
  801a7a:	68 00 00 40 00       	push   $0x400000
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 bd f1 ff ff       	call   800c43 <sys_page_alloc>
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	0f 88 02 04 00 00    	js     801e93 <spawn+0x54f>
  801a91:	be 00 00 00 00       	mov    $0x0,%esi
  801a96:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a9f:	eb 30                	jmp    801ad1 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801aa1:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  801aa7:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801aad:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ab6:	57                   	push   %edi
  801ab7:	e8 7d ed ff ff       	call   800839 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801abc:	83 c4 04             	add    $0x4,%esp
  801abf:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ac2:	e8 39 ed ff ff       	call   800800 <strlen>
  801ac7:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801acb:	83 c6 01             	add    $0x1,%esi
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801ad7:	7c c8                	jl     801aa1 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ad9:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801adf:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ae5:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aec:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801af2:	74 19                	je     801b0d <spawn+0x1c9>
  801af4:	68 e4 2e 80 00       	push   $0x802ee4
  801af9:	68 2f 2e 80 00       	push   $0x802e2f
  801afe:	68 f1 00 00 00       	push   $0xf1
  801b03:	68 75 2e 80 00       	push   $0x802e75
  801b08:	e8 cf e6 ff ff       	call   8001dc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b0d:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b13:	89 f8                	mov    %edi,%eax
  801b15:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  801b1a:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b1d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b23:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b26:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  801b2c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	6a 07                	push   $0x7
  801b37:	68 00 d0 7f ee       	push   $0xee7fd000
  801b3c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b42:	68 00 00 40 00       	push   $0x400000
  801b47:	6a 00                	push   $0x0
  801b49:	e8 38 f1 ff ff       	call   800c86 <sys_page_map>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 20             	add    $0x20,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 24 03 00 00    	js     801e7f <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	68 00 00 40 00       	push   $0x400000
  801b63:	6a 00                	push   $0x0
  801b65:	e8 5e f1 ff ff       	call   800cc8 <sys_page_unmap>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 08 03 00 00    	js     801e7f <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b77:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b7d:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b84:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b8a:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b91:	00 00 00 
  801b94:	e9 84 01 00 00       	jmp    801d1d <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  801b99:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b9f:	83 38 01             	cmpl   $0x1,(%eax)
  801ba2:	0f 85 67 01 00 00    	jne    801d0f <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ba8:	89 c1                	mov    %eax,%ecx
  801baa:	8b 40 18             	mov    0x18(%eax),%eax
  801bad:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bb3:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bb6:	83 f8 01             	cmp    $0x1,%eax
  801bb9:	19 c0                	sbb    %eax,%eax
  801bbb:	83 e0 fe             	and    $0xfffffffe,%eax
  801bbe:	83 c0 07             	add    $0x7,%eax
  801bc1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bc7:	89 c8                	mov    %ecx,%eax
  801bc9:	8b 49 04             	mov    0x4(%ecx),%ecx
  801bcc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801bd2:	8b 78 10             	mov    0x10(%eax),%edi
  801bd5:	8b 48 14             	mov    0x14(%eax),%ecx
  801bd8:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801bde:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801be1:	89 f0                	mov    %esi,%eax
  801be3:	25 ff 0f 00 00       	and    $0xfff,%eax
  801be8:	74 10                	je     801bfa <spawn+0x2b6>
		va -= i;
  801bea:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bec:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801bf2:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bf4:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bff:	e9 f9 00 00 00       	jmp    801cfd <spawn+0x3b9>
		if (i >= filesz) {
  801c04:	39 fb                	cmp    %edi,%ebx
  801c06:	72 27                	jb     801c2f <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c08:	83 ec 04             	sub    $0x4,%esp
  801c0b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c11:	56                   	push   %esi
  801c12:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c18:	e8 26 f0 ff ff       	call   800c43 <sys_page_alloc>
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 89 c9 00 00 00    	jns    801cf1 <spawn+0x3ad>
  801c28:	89 c7                	mov    %eax,%edi
  801c2a:	e9 2d 02 00 00       	jmp    801e5c <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c2f:	83 ec 04             	sub    $0x4,%esp
  801c32:	6a 07                	push   $0x7
  801c34:	68 00 00 40 00       	push   $0x400000
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 03 f0 ff ff       	call   800c43 <sys_page_alloc>
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	0f 88 07 02 00 00    	js     801e52 <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c54:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c61:	e8 11 f9 ff ff       	call   801577 <seek>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 e5 01 00 00    	js     801e56 <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c71:	83 ec 04             	sub    $0x4,%esp
  801c74:	89 fa                	mov    %edi,%edx
  801c76:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801c7c:	89 d0                	mov    %edx,%eax
  801c7e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801c84:	76 05                	jbe    801c8b <spawn+0x347>
  801c86:	b8 00 10 00 00       	mov    $0x1000,%eax
  801c8b:	50                   	push   %eax
  801c8c:	68 00 00 40 00       	push   $0x400000
  801c91:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c97:	e8 0a f8 ff ff       	call   8014a6 <readn>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 b3 01 00 00    	js     801e5a <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cb0:	56                   	push   %esi
  801cb1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cb7:	68 00 00 40 00       	push   $0x400000
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 c3 ef ff ff       	call   800c86 <sys_page_map>
  801cc3:	83 c4 20             	add    $0x20,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	79 15                	jns    801cdf <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  801cca:	50                   	push   %eax
  801ccb:	68 81 2e 80 00       	push   $0x802e81
  801cd0:	68 23 01 00 00       	push   $0x123
  801cd5:	68 75 2e 80 00       	push   $0x802e75
  801cda:	e8 fd e4 ff ff       	call   8001dc <_panic>
			sys_page_unmap(0, UTEMP);
  801cdf:	83 ec 08             	sub    $0x8,%esp
  801ce2:	68 00 00 40 00       	push   $0x400000
  801ce7:	6a 00                	push   $0x0
  801ce9:	e8 da ef ff ff       	call   800cc8 <sys_page_unmap>
  801cee:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cf1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cf7:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cfd:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d03:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d09:	0f 82 f5 fe ff ff    	jb     801c04 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d0f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d16:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d1d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d24:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d2a:	0f 8c 69 fe ff ff    	jl     801b99 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d39:	e8 97 f5 ff ff       	call   8012d5 <close>
  801d3e:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801d41:	ba 00 00 00 00       	mov    $0x0,%edx
  801d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  801d51:	89 d8                	mov    %ebx,%eax
  801d53:	c1 f8 0a             	sar    $0xa,%eax
  801d56:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d5d:	a8 01                	test   $0x1,%al
  801d5f:	75 10                	jne    801d71 <spawn+0x42d>
  801d61:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  801d67:	75 08                	jne    801d71 <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  801d69:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801d6f:	eb 54                	jmp    801dc5 <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  801d71:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801d78:	a8 01                	test   $0x1,%al
  801d7a:	74 49                	je     801dc5 <spawn+0x481>
  801d7c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801d83:	f6 c4 04             	test   $0x4,%ah
  801d86:	74 3d                	je     801dc5 <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  801d88:	89 da                	mov    %ebx,%edx
  801d8a:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  801d8d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	25 07 0e 00 00       	and    $0xe07,%eax
  801d9c:	50                   	push   %eax
  801d9d:	52                   	push   %edx
  801d9e:	56                   	push   %esi
  801d9f:	52                   	push   %edx
  801da0:	6a 00                	push   $0x0
  801da2:	e8 df ee ff ff       	call   800c86 <sys_page_map>
  801da7:	83 c4 20             	add    $0x20,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	74 17                	je     801dc5 <spawn+0x481>
                                panic("copy_shared_pages");
  801dae:	83 ec 04             	sub    $0x4,%esp
  801db1:	68 9e 2e 80 00       	push   $0x802e9e
  801db6:	68 3c 01 00 00       	push   $0x13c
  801dbb:	68 75 2e 80 00       	push   $0x802e75
  801dc0:	e8 17 e4 ff ff       	call   8001dc <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801dc5:	83 c3 01             	add    $0x1,%ebx
  801dc8:	89 da                	mov    %ebx,%edx
  801dca:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  801dd0:	0f 86 7b ff ff ff    	jbe    801d51 <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801de6:	e8 61 ef ff ff       	call   800d4c <sys_env_set_trapframe>
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	85 c0                	test   %eax,%eax
  801df0:	79 15                	jns    801e07 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  801df2:	50                   	push   %eax
  801df3:	68 b0 2e 80 00       	push   $0x802eb0
  801df8:	68 85 00 00 00       	push   $0x85
  801dfd:	68 75 2e 80 00       	push   $0x802e75
  801e02:	e8 d5 e3 ff ff       	call   8001dc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	6a 02                	push   $0x2
  801e0c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e12:	e8 f3 ee ff ff       	call   800d0a <sys_env_set_status>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	79 25                	jns    801e43 <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  801e1e:	50                   	push   %eax
  801e1f:	68 ca 2e 80 00       	push   $0x802eca
  801e24:	68 88 00 00 00       	push   $0x88
  801e29:	68 75 2e 80 00       	push   $0x802e75
  801e2e:	e8 a9 e3 ff ff       	call   8001dc <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e33:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801e39:	eb 58                	jmp    801e93 <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e3b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e41:	eb 50                	jmp    801e93 <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  801e43:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e49:	eb 48                	jmp    801e93 <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e4b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801e50:	eb 41                	jmp    801e93 <spawn+0x54f>
  801e52:	89 c7                	mov    %eax,%edi
  801e54:	eb 06                	jmp    801e5c <spawn+0x518>
  801e56:	89 c7                	mov    %eax,%edi
  801e58:	eb 02                	jmp    801e5c <spawn+0x518>
  801e5a:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e65:	e8 5a ed ff ff       	call   800bc4 <sys_env_destroy>
	close(fd);
  801e6a:	83 c4 04             	add    $0x4,%esp
  801e6d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e73:	e8 5d f4 ff ff       	call   8012d5 <close>
	return r;
  801e78:	83 c4 10             	add    $0x10,%esp
  801e7b:	89 f8                	mov    %edi,%eax
  801e7d:	eb 14                	jmp    801e93 <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e7f:	83 ec 08             	sub    $0x8,%esp
  801e82:	68 00 00 40 00       	push   $0x400000
  801e87:	6a 00                	push   $0x0
  801e89:	e8 3a ee ff ff       	call   800cc8 <sys_page_unmap>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea0:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea8:	eb 03                	jmp    801ead <spawnl+0x12>
		argc++;
  801eaa:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ead:	83 c2 04             	add    $0x4,%edx
  801eb0:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801eb4:	75 f4                	jne    801eaa <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801eb6:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ebd:	83 e2 f0             	and    $0xfffffff0,%edx
  801ec0:	29 d4                	sub    %edx,%esp
  801ec2:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ec6:	c1 ea 02             	shr    $0x2,%edx
  801ec9:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ed0:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed5:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801edc:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ee3:	00 
  801ee4:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eeb:	eb 0a                	jmp    801ef7 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801eed:	83 c0 01             	add    $0x1,%eax
  801ef0:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ef4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef7:	39 d0                	cmp    %edx,%eax
  801ef9:	75 f2                	jne    801eed <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801efb:	83 ec 08             	sub    $0x8,%esp
  801efe:	56                   	push   %esi
  801eff:	ff 75 08             	pushl  0x8(%ebp)
  801f02:	e8 3d fa ff ff       	call   801944 <spawn>
}
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	ff 75 08             	pushl  0x8(%ebp)
  801f1c:	e8 25 f2 ff ff       	call   801146 <fd2data>
  801f21:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f23:	83 c4 08             	add    $0x8,%esp
  801f26:	68 0a 2f 80 00       	push   $0x802f0a
  801f2b:	53                   	push   %ebx
  801f2c:	e8 08 e9 ff ff       	call   800839 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f31:	8b 56 04             	mov    0x4(%esi),%edx
  801f34:	89 d0                	mov    %edx,%eax
  801f36:	2b 06                	sub    (%esi),%eax
  801f38:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f3e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f45:	00 00 00 
	stat->st_dev = &devpipe;
  801f48:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f4f:	30 80 00 
	return 0;
}
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
  801f57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	53                   	push   %ebx
  801f62:	83 ec 0c             	sub    $0xc,%esp
  801f65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f68:	53                   	push   %ebx
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 58 ed ff ff       	call   800cc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f70:	89 1c 24             	mov    %ebx,(%esp)
  801f73:	e8 ce f1 ff ff       	call   801146 <fd2data>
  801f78:	83 c4 08             	add    $0x8,%esp
  801f7b:	50                   	push   %eax
  801f7c:	6a 00                	push   $0x0
  801f7e:	e8 45 ed ff ff       	call   800cc8 <sys_page_unmap>
}
  801f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	57                   	push   %edi
  801f8c:	56                   	push   %esi
  801f8d:	53                   	push   %ebx
  801f8e:	83 ec 1c             	sub    $0x1c,%esp
  801f91:	89 c7                	mov    %eax,%edi
  801f93:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f95:	a1 04 40 80 00       	mov    0x804004,%eax
  801f9a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f9d:	83 ec 0c             	sub    $0xc,%esp
  801fa0:	57                   	push   %edi
  801fa1:	e8 1f 06 00 00       	call   8025c5 <pageref>
  801fa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fa9:	89 34 24             	mov    %esi,(%esp)
  801fac:	e8 14 06 00 00       	call   8025c5 <pageref>
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fb7:	0f 94 c0             	sete   %al
  801fba:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801fbd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fc3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fc6:	39 cb                	cmp    %ecx,%ebx
  801fc8:	74 15                	je     801fdf <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801fca:	8b 52 58             	mov    0x58(%edx),%edx
  801fcd:	50                   	push   %eax
  801fce:	52                   	push   %edx
  801fcf:	53                   	push   %ebx
  801fd0:	68 18 2f 80 00       	push   $0x802f18
  801fd5:	e8 db e2 ff ff       	call   8002b5 <cprintf>
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	eb b6                	jmp    801f95 <_pipeisclosed+0xd>
	}
}
  801fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe2:	5b                   	pop    %ebx
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	57                   	push   %edi
  801feb:	56                   	push   %esi
  801fec:	53                   	push   %ebx
  801fed:	83 ec 28             	sub    $0x28,%esp
  801ff0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ff3:	56                   	push   %esi
  801ff4:	e8 4d f1 ff ff       	call   801146 <fd2data>
  801ff9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	bf 00 00 00 00       	mov    $0x0,%edi
  802003:	eb 4b                	jmp    802050 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802005:	89 da                	mov    %ebx,%edx
  802007:	89 f0                	mov    %esi,%eax
  802009:	e8 7a ff ff ff       	call   801f88 <_pipeisclosed>
  80200e:	85 c0                	test   %eax,%eax
  802010:	75 48                	jne    80205a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802012:	e8 0d ec ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802017:	8b 43 04             	mov    0x4(%ebx),%eax
  80201a:	8b 0b                	mov    (%ebx),%ecx
  80201c:	8d 51 20             	lea    0x20(%ecx),%edx
  80201f:	39 d0                	cmp    %edx,%eax
  802021:	73 e2                	jae    802005 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802026:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80202a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80202d:	89 c2                	mov    %eax,%edx
  80202f:	c1 fa 1f             	sar    $0x1f,%edx
  802032:	89 d1                	mov    %edx,%ecx
  802034:	c1 e9 1b             	shr    $0x1b,%ecx
  802037:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80203a:	83 e2 1f             	and    $0x1f,%edx
  80203d:	29 ca                	sub    %ecx,%edx
  80203f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802043:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802047:	83 c0 01             	add    $0x1,%eax
  80204a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204d:	83 c7 01             	add    $0x1,%edi
  802050:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802053:	75 c2                	jne    802017 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802055:	8b 45 10             	mov    0x10(%ebp),%eax
  802058:	eb 05                	jmp    80205f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80205f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802062:	5b                   	pop    %ebx
  802063:	5e                   	pop    %esi
  802064:	5f                   	pop    %edi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	57                   	push   %edi
  80206b:	56                   	push   %esi
  80206c:	53                   	push   %ebx
  80206d:	83 ec 18             	sub    $0x18,%esp
  802070:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802073:	57                   	push   %edi
  802074:	e8 cd f0 ff ff       	call   801146 <fd2data>
  802079:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802083:	eb 3d                	jmp    8020c2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802085:	85 db                	test   %ebx,%ebx
  802087:	74 04                	je     80208d <devpipe_read+0x26>
				return i;
  802089:	89 d8                	mov    %ebx,%eax
  80208b:	eb 44                	jmp    8020d1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80208d:	89 f2                	mov    %esi,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	e8 f2 fe ff ff       	call   801f88 <_pipeisclosed>
  802096:	85 c0                	test   %eax,%eax
  802098:	75 32                	jne    8020cc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80209a:	e8 85 eb ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80209f:	8b 06                	mov    (%esi),%eax
  8020a1:	3b 46 04             	cmp    0x4(%esi),%eax
  8020a4:	74 df                	je     802085 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020a6:	99                   	cltd   
  8020a7:	c1 ea 1b             	shr    $0x1b,%edx
  8020aa:	01 d0                	add    %edx,%eax
  8020ac:	83 e0 1f             	and    $0x1f,%eax
  8020af:	29 d0                	sub    %edx,%eax
  8020b1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020bc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020bf:	83 c3 01             	add    $0x1,%ebx
  8020c2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020c5:	75 d8                	jne    80209f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ca:	eb 05                	jmp    8020d1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    

008020d9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	56                   	push   %esi
  8020dd:	53                   	push   %ebx
  8020de:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	e8 73 f0 ff ff       	call   80115d <fd_alloc>
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	89 c2                	mov    %eax,%edx
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	0f 88 2c 01 00 00    	js     802223 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f7:	83 ec 04             	sub    $0x4,%esp
  8020fa:	68 07 04 00 00       	push   $0x407
  8020ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802102:	6a 00                	push   $0x0
  802104:	e8 3a eb ff ff       	call   800c43 <sys_page_alloc>
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	89 c2                	mov    %eax,%edx
  80210e:	85 c0                	test   %eax,%eax
  802110:	0f 88 0d 01 00 00    	js     802223 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802116:	83 ec 0c             	sub    $0xc,%esp
  802119:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80211c:	50                   	push   %eax
  80211d:	e8 3b f0 ff ff       	call   80115d <fd_alloc>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	0f 88 e2 00 00 00    	js     802211 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212f:	83 ec 04             	sub    $0x4,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	ff 75 f0             	pushl  -0x10(%ebp)
  80213a:	6a 00                	push   $0x0
  80213c:	e8 02 eb ff ff       	call   800c43 <sys_page_alloc>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	85 c0                	test   %eax,%eax
  802148:	0f 88 c3 00 00 00    	js     802211 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80214e:	83 ec 0c             	sub    $0xc,%esp
  802151:	ff 75 f4             	pushl  -0xc(%ebp)
  802154:	e8 ed ef ff ff       	call   801146 <fd2data>
  802159:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215b:	83 c4 0c             	add    $0xc,%esp
  80215e:	68 07 04 00 00       	push   $0x407
  802163:	50                   	push   %eax
  802164:	6a 00                	push   $0x0
  802166:	e8 d8 ea ff ff       	call   800c43 <sys_page_alloc>
  80216b:	89 c3                	mov    %eax,%ebx
  80216d:	83 c4 10             	add    $0x10,%esp
  802170:	85 c0                	test   %eax,%eax
  802172:	0f 88 89 00 00 00    	js     802201 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802178:	83 ec 0c             	sub    $0xc,%esp
  80217b:	ff 75 f0             	pushl  -0x10(%ebp)
  80217e:	e8 c3 ef ff ff       	call   801146 <fd2data>
  802183:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80218a:	50                   	push   %eax
  80218b:	6a 00                	push   $0x0
  80218d:	56                   	push   %esi
  80218e:	6a 00                	push   $0x0
  802190:	e8 f1 ea ff ff       	call   800c86 <sys_page_map>
  802195:	89 c3                	mov    %eax,%ebx
  802197:	83 c4 20             	add    $0x20,%esp
  80219a:	85 c0                	test   %eax,%eax
  80219c:	78 55                	js     8021f3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80219e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021b3:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021bc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021c8:	83 ec 0c             	sub    $0xc,%esp
  8021cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ce:	e8 63 ef ff ff       	call   801136 <fd2num>
  8021d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021d8:	83 c4 04             	add    $0x4,%esp
  8021db:	ff 75 f0             	pushl  -0x10(%ebp)
  8021de:	e8 53 ef ff ff       	call   801136 <fd2num>
  8021e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021e6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f1:	eb 30                	jmp    802223 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	56                   	push   %esi
  8021f7:	6a 00                	push   $0x0
  8021f9:	e8 ca ea ff ff       	call   800cc8 <sys_page_unmap>
  8021fe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802201:	83 ec 08             	sub    $0x8,%esp
  802204:	ff 75 f0             	pushl  -0x10(%ebp)
  802207:	6a 00                	push   $0x0
  802209:	e8 ba ea ff ff       	call   800cc8 <sys_page_unmap>
  80220e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802211:	83 ec 08             	sub    $0x8,%esp
  802214:	ff 75 f4             	pushl  -0xc(%ebp)
  802217:	6a 00                	push   $0x0
  802219:	e8 aa ea ff ff       	call   800cc8 <sys_page_unmap>
  80221e:	83 c4 10             	add    $0x10,%esp
  802221:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802223:	89 d0                	mov    %edx,%eax
  802225:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    

0080222c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802235:	50                   	push   %eax
  802236:	ff 75 08             	pushl  0x8(%ebp)
  802239:	e8 6e ef ff ff       	call   8011ac <fd_lookup>
  80223e:	89 c2                	mov    %eax,%edx
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	85 d2                	test   %edx,%edx
  802245:	78 18                	js     80225f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	ff 75 f4             	pushl  -0xc(%ebp)
  80224d:	e8 f4 ee ff ff       	call   801146 <fd2data>
	return _pipeisclosed(fd, p);
  802252:	89 c2                	mov    %eax,%edx
  802254:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802257:	e8 2c fd ff ff       	call   801f88 <_pipeisclosed>
  80225c:	83 c4 10             	add    $0x10,%esp
}
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	57                   	push   %edi
  802265:	56                   	push   %esi
  802266:	53                   	push   %ebx
  802267:	83 ec 0c             	sub    $0xc,%esp
  80226a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80226d:	85 f6                	test   %esi,%esi
  80226f:	75 16                	jne    802287 <wait+0x26>
  802271:	68 49 2f 80 00       	push   $0x802f49
  802276:	68 2f 2e 80 00       	push   $0x802e2f
  80227b:	6a 09                	push   $0x9
  80227d:	68 54 2f 80 00       	push   $0x802f54
  802282:	e8 55 df ff ff       	call   8001dc <_panic>
	e = &envs[ENVX(envid)];
  802287:	89 f3                	mov    %esi,%ebx
  802289:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80228f:	6b db 78             	imul   $0x78,%ebx,%ebx
  802292:	8d 7b 40             	lea    0x40(%ebx),%edi
  802295:	83 c3 50             	add    $0x50,%ebx
  802298:	eb 05                	jmp    80229f <wait+0x3e>
		sys_yield();
  80229a:	e8 85 e9 ff ff       	call   800c24 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80229f:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  8022a5:	39 f0                	cmp    %esi,%eax
  8022a7:	75 0a                	jne    8022b3 <wait+0x52>
  8022a9:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	75 e7                	jne    80229a <wait+0x39>
		sys_yield();
}
  8022b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022b6:	5b                   	pop    %ebx
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022be:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022cb:	68 5f 2f 80 00       	push   $0x802f5f
  8022d0:	ff 75 0c             	pushl  0xc(%ebp)
  8022d3:	e8 61 e5 ff ff       	call   800839 <strcpy>
	return 0;
}
  8022d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022dd:	c9                   	leave  
  8022de:	c3                   	ret    

008022df <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	57                   	push   %edi
  8022e3:	56                   	push   %esi
  8022e4:	53                   	push   %ebx
  8022e5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f6:	eb 2e                	jmp    802326 <devcons_write+0x47>
		m = n - tot;
  8022f8:	8b 55 10             	mov    0x10(%ebp),%edx
  8022fb:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  8022fd:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  802302:	83 fa 7f             	cmp    $0x7f,%edx
  802305:	77 02                	ja     802309 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802307:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802309:	83 ec 04             	sub    $0x4,%esp
  80230c:	56                   	push   %esi
  80230d:	03 45 0c             	add    0xc(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	57                   	push   %edi
  802312:	e8 b4 e6 ff ff       	call   8009cb <memmove>
		sys_cputs(buf, m);
  802317:	83 c4 08             	add    $0x8,%esp
  80231a:	56                   	push   %esi
  80231b:	57                   	push   %edi
  80231c:	e8 66 e8 ff ff       	call   800b87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802321:	01 f3                	add    %esi,%ebx
  802323:	83 c4 10             	add    $0x10,%esp
  802326:	89 d8                	mov    %ebx,%eax
  802328:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80232b:	72 cb                	jb     8022f8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80232d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802330:	5b                   	pop    %ebx
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    

00802335 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80233b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802340:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802344:	75 07                	jne    80234d <devcons_read+0x18>
  802346:	eb 28                	jmp    802370 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802348:	e8 d7 e8 ff ff       	call   800c24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80234d:	e8 53 e8 ff ff       	call   800ba5 <sys_cgetc>
  802352:	85 c0                	test   %eax,%eax
  802354:	74 f2                	je     802348 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802356:	85 c0                	test   %eax,%eax
  802358:	78 16                	js     802370 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80235a:	83 f8 04             	cmp    $0x4,%eax
  80235d:	74 0c                	je     80236b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80235f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802362:	88 02                	mov    %al,(%edx)
	return 1;
  802364:	b8 01 00 00 00       	mov    $0x1,%eax
  802369:	eb 05                	jmp    802370 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80236b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802370:	c9                   	leave  
  802371:	c3                   	ret    

00802372 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802378:	8b 45 08             	mov    0x8(%ebp),%eax
  80237b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80237e:	6a 01                	push   $0x1
  802380:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802383:	50                   	push   %eax
  802384:	e8 fe e7 ff ff       	call   800b87 <sys_cputs>
  802389:	83 c4 10             	add    $0x10,%esp
}
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <getchar>:

int
getchar(void)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802394:	6a 01                	push   $0x1
  802396:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802399:	50                   	push   %eax
  80239a:	6a 00                	push   $0x0
  80239c:	e8 74 f0 ff ff       	call   801415 <read>
	if (r < 0)
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 0f                	js     8023b7 <getchar+0x29>
		return r;
	if (r < 1)
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	7e 06                	jle    8023b2 <getchar+0x24>
		return -E_EOF;
	return c;
  8023ac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023b0:	eb 05                	jmp    8023b7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023b2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023b7:	c9                   	leave  
  8023b8:	c3                   	ret    

008023b9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023b9:	55                   	push   %ebp
  8023ba:	89 e5                	mov    %esp,%ebp
  8023bc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c2:	50                   	push   %eax
  8023c3:	ff 75 08             	pushl  0x8(%ebp)
  8023c6:	e8 e1 ed ff ff       	call   8011ac <fd_lookup>
  8023cb:	83 c4 10             	add    $0x10,%esp
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	78 11                	js     8023e3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d5:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023db:	39 10                	cmp    %edx,(%eax)
  8023dd:	0f 94 c0             	sete   %al
  8023e0:	0f b6 c0             	movzbl %al,%eax
}
  8023e3:	c9                   	leave  
  8023e4:	c3                   	ret    

008023e5 <opencons>:

int
opencons(void)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ee:	50                   	push   %eax
  8023ef:	e8 69 ed ff ff       	call   80115d <fd_alloc>
  8023f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 3e                	js     80243b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023fd:	83 ec 04             	sub    $0x4,%esp
  802400:	68 07 04 00 00       	push   $0x407
  802405:	ff 75 f4             	pushl  -0xc(%ebp)
  802408:	6a 00                	push   $0x0
  80240a:	e8 34 e8 ff ff       	call   800c43 <sys_page_alloc>
  80240f:	83 c4 10             	add    $0x10,%esp
		return r;
  802412:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802414:	85 c0                	test   %eax,%eax
  802416:	78 23                	js     80243b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802418:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80241e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802421:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802423:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802426:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80242d:	83 ec 0c             	sub    $0xc,%esp
  802430:	50                   	push   %eax
  802431:	e8 00 ed ff ff       	call   801136 <fd2num>
  802436:	89 c2                	mov    %eax,%edx
  802438:	83 c4 10             	add    $0x10,%esp
}
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	c9                   	leave  
  80243e:	c3                   	ret    

0080243f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802445:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80244c:	75 2c                	jne    80247a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80244e:	83 ec 04             	sub    $0x4,%esp
  802451:	6a 07                	push   $0x7
  802453:	68 00 f0 7f ee       	push   $0xee7ff000
  802458:	6a 00                	push   $0x0
  80245a:	e8 e4 e7 ff ff       	call   800c43 <sys_page_alloc>
  80245f:	83 c4 10             	add    $0x10,%esp
  802462:	85 c0                	test   %eax,%eax
  802464:	79 14                	jns    80247a <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802466:	83 ec 04             	sub    $0x4,%esp
  802469:	68 6c 2f 80 00       	push   $0x802f6c
  80246e:	6a 1f                	push   $0x1f
  802470:	68 d0 2f 80 00       	push   $0x802fd0
  802475:	e8 62 dd ff ff       	call   8001dc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80247a:	8b 45 08             	mov    0x8(%ebp),%eax
  80247d:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802482:	83 ec 08             	sub    $0x8,%esp
  802485:	68 ae 24 80 00       	push   $0x8024ae
  80248a:	6a 00                	push   $0x0
  80248c:	e8 fd e8 ff ff       	call   800d8e <sys_env_set_pgfault_upcall>
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	85 c0                	test   %eax,%eax
  802496:	79 14                	jns    8024ac <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802498:	83 ec 04             	sub    $0x4,%esp
  80249b:	68 98 2f 80 00       	push   $0x802f98
  8024a0:	6a 25                	push   $0x25
  8024a2:	68 d0 2f 80 00       	push   $0x802fd0
  8024a7:	e8 30 dd ff ff       	call   8001dc <_panic>
}
  8024ac:	c9                   	leave  
  8024ad:	c3                   	ret    

008024ae <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024ae:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024af:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024b4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024b6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  8024b9:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  8024bb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  8024bf:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  8024c3:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  8024c4:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  8024c7:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  8024c9:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  8024cc:	83 c4 04             	add    $0x4,%esp
	popal 
  8024cf:	61                   	popa   
	addl $4, %esp 
  8024d0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  8024d3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  8024d4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  8024d5:	c3                   	ret    

008024d6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024d6:	55                   	push   %ebp
  8024d7:	89 e5                	mov    %esp,%ebp
  8024d9:	56                   	push   %esi
  8024da:	53                   	push   %ebx
  8024db:	8b 75 08             	mov    0x8(%ebp),%esi
  8024de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  8024e4:	85 f6                	test   %esi,%esi
  8024e6:	74 06                	je     8024ee <ipc_recv+0x18>
  8024e8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8024ee:	85 db                	test   %ebx,%ebx
  8024f0:	74 06                	je     8024f8 <ipc_recv+0x22>
  8024f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8024f8:	83 f8 01             	cmp    $0x1,%eax
  8024fb:	19 d2                	sbb    %edx,%edx
  8024fd:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  8024ff:	83 ec 0c             	sub    $0xc,%esp
  802502:	50                   	push   %eax
  802503:	e8 eb e8 ff ff       	call   800df3 <sys_ipc_recv>
  802508:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  80250a:	83 c4 10             	add    $0x10,%esp
  80250d:	85 d2                	test   %edx,%edx
  80250f:	75 24                	jne    802535 <ipc_recv+0x5f>
	if (from_env_store)
  802511:	85 f6                	test   %esi,%esi
  802513:	74 0a                	je     80251f <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  802515:	a1 04 40 80 00       	mov    0x804004,%eax
  80251a:	8b 40 70             	mov    0x70(%eax),%eax
  80251d:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80251f:	85 db                	test   %ebx,%ebx
  802521:	74 0a                	je     80252d <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802523:	a1 04 40 80 00       	mov    0x804004,%eax
  802528:	8b 40 74             	mov    0x74(%eax),%eax
  80252b:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80252d:	a1 04 40 80 00       	mov    0x804004,%eax
  802532:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802535:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802538:	5b                   	pop    %ebx
  802539:	5e                   	pop    %esi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    

0080253c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	57                   	push   %edi
  802540:	56                   	push   %esi
  802541:	53                   	push   %ebx
  802542:	83 ec 0c             	sub    $0xc,%esp
  802545:	8b 7d 08             	mov    0x8(%ebp),%edi
  802548:	8b 75 0c             	mov    0xc(%ebp),%esi
  80254b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  80254e:	83 fb 01             	cmp    $0x1,%ebx
  802551:	19 c0                	sbb    %eax,%eax
  802553:	09 c3                	or     %eax,%ebx
  802555:	eb 1c                	jmp    802573 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  802557:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80255a:	74 12                	je     80256e <ipc_send+0x32>
  80255c:	50                   	push   %eax
  80255d:	68 de 2f 80 00       	push   $0x802fde
  802562:	6a 36                	push   $0x36
  802564:	68 f5 2f 80 00       	push   $0x802ff5
  802569:	e8 6e dc ff ff       	call   8001dc <_panic>
		sys_yield();
  80256e:	e8 b1 e6 ff ff       	call   800c24 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802573:	ff 75 14             	pushl  0x14(%ebp)
  802576:	53                   	push   %ebx
  802577:	56                   	push   %esi
  802578:	57                   	push   %edi
  802579:	e8 52 e8 ff ff       	call   800dd0 <sys_ipc_try_send>
		if (ret == 0) break;
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	85 c0                	test   %eax,%eax
  802583:	75 d2                	jne    802557 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802585:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802598:	6b d0 78             	imul   $0x78,%eax,%edx
  80259b:	83 c2 50             	add    $0x50,%edx
  80259e:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  8025a4:	39 ca                	cmp    %ecx,%edx
  8025a6:	75 0d                	jne    8025b5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025a8:	6b c0 78             	imul   $0x78,%eax,%eax
  8025ab:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8025b0:	8b 40 08             	mov    0x8(%eax),%eax
  8025b3:	eb 0e                	jmp    8025c3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025b5:	83 c0 01             	add    $0x1,%eax
  8025b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025bd:	75 d9                	jne    802598 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025bf:	66 b8 00 00          	mov    $0x0,%ax
}
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	c1 e8 16             	shr    $0x16,%eax
  8025d0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025dc:	f6 c1 01             	test   $0x1,%cl
  8025df:	74 1d                	je     8025fe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025e1:	c1 ea 0c             	shr    $0xc,%edx
  8025e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025eb:	f6 c2 01             	test   $0x1,%dl
  8025ee:	74 0e                	je     8025fe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025f0:	c1 ea 0c             	shr    $0xc,%edx
  8025f3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025fa:	ef 
  8025fb:	0f b7 c0             	movzwl %ax,%eax
}
  8025fe:	5d                   	pop    %ebp
  8025ff:	c3                   	ret    

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	83 ec 10             	sub    $0x10,%esp
  802606:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80260a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80260e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802612:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802616:	85 d2                	test   %edx,%edx
  802618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80261c:	89 34 24             	mov    %esi,(%esp)
  80261f:	89 c8                	mov    %ecx,%eax
  802621:	75 35                	jne    802658 <__udivdi3+0x58>
  802623:	39 f1                	cmp    %esi,%ecx
  802625:	0f 87 bd 00 00 00    	ja     8026e8 <__udivdi3+0xe8>
  80262b:	85 c9                	test   %ecx,%ecx
  80262d:	89 cd                	mov    %ecx,%ebp
  80262f:	75 0b                	jne    80263c <__udivdi3+0x3c>
  802631:	b8 01 00 00 00       	mov    $0x1,%eax
  802636:	31 d2                	xor    %edx,%edx
  802638:	f7 f1                	div    %ecx
  80263a:	89 c5                	mov    %eax,%ebp
  80263c:	89 f0                	mov    %esi,%eax
  80263e:	31 d2                	xor    %edx,%edx
  802640:	f7 f5                	div    %ebp
  802642:	89 c6                	mov    %eax,%esi
  802644:	89 f8                	mov    %edi,%eax
  802646:	f7 f5                	div    %ebp
  802648:	89 f2                	mov    %esi,%edx
  80264a:	83 c4 10             	add    $0x10,%esp
  80264d:	5e                   	pop    %esi
  80264e:	5f                   	pop    %edi
  80264f:	5d                   	pop    %ebp
  802650:	c3                   	ret    
  802651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802658:	3b 14 24             	cmp    (%esp),%edx
  80265b:	77 7b                	ja     8026d8 <__udivdi3+0xd8>
  80265d:	0f bd f2             	bsr    %edx,%esi
  802660:	83 f6 1f             	xor    $0x1f,%esi
  802663:	0f 84 97 00 00 00    	je     802700 <__udivdi3+0x100>
  802669:	bd 20 00 00 00       	mov    $0x20,%ebp
  80266e:	89 d7                	mov    %edx,%edi
  802670:	89 f1                	mov    %esi,%ecx
  802672:	29 f5                	sub    %esi,%ebp
  802674:	d3 e7                	shl    %cl,%edi
  802676:	89 c2                	mov    %eax,%edx
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	d3 ea                	shr    %cl,%edx
  80267c:	89 f1                	mov    %esi,%ecx
  80267e:	09 fa                	or     %edi,%edx
  802680:	8b 3c 24             	mov    (%esp),%edi
  802683:	d3 e0                	shl    %cl,%eax
  802685:	89 54 24 08          	mov    %edx,0x8(%esp)
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80268f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802693:	89 fa                	mov    %edi,%edx
  802695:	d3 ea                	shr    %cl,%edx
  802697:	89 f1                	mov    %esi,%ecx
  802699:	d3 e7                	shl    %cl,%edi
  80269b:	89 e9                	mov    %ebp,%ecx
  80269d:	d3 e8                	shr    %cl,%eax
  80269f:	09 c7                	or     %eax,%edi
  8026a1:	89 f8                	mov    %edi,%eax
  8026a3:	f7 74 24 08          	divl   0x8(%esp)
  8026a7:	89 d5                	mov    %edx,%ebp
  8026a9:	89 c7                	mov    %eax,%edi
  8026ab:	f7 64 24 0c          	mull   0xc(%esp)
  8026af:	39 d5                	cmp    %edx,%ebp
  8026b1:	89 14 24             	mov    %edx,(%esp)
  8026b4:	72 11                	jb     8026c7 <__udivdi3+0xc7>
  8026b6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026ba:	89 f1                	mov    %esi,%ecx
  8026bc:	d3 e2                	shl    %cl,%edx
  8026be:	39 c2                	cmp    %eax,%edx
  8026c0:	73 5e                	jae    802720 <__udivdi3+0x120>
  8026c2:	3b 2c 24             	cmp    (%esp),%ebp
  8026c5:	75 59                	jne    802720 <__udivdi3+0x120>
  8026c7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8026ca:	31 f6                	xor    %esi,%esi
  8026cc:	89 f2                	mov    %esi,%edx
  8026ce:	83 c4 10             	add    $0x10,%esp
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi
  8026d8:	31 f6                	xor    %esi,%esi
  8026da:	31 c0                	xor    %eax,%eax
  8026dc:	89 f2                	mov    %esi,%edx
  8026de:	83 c4 10             	add    $0x10,%esp
  8026e1:	5e                   	pop    %esi
  8026e2:	5f                   	pop    %edi
  8026e3:	5d                   	pop    %ebp
  8026e4:	c3                   	ret    
  8026e5:	8d 76 00             	lea    0x0(%esi),%esi
  8026e8:	89 f2                	mov    %esi,%edx
  8026ea:	31 f6                	xor    %esi,%esi
  8026ec:	89 f8                	mov    %edi,%eax
  8026ee:	f7 f1                	div    %ecx
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	83 c4 10             	add    $0x10,%esp
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802704:	76 0b                	jbe    802711 <__udivdi3+0x111>
  802706:	31 c0                	xor    %eax,%eax
  802708:	3b 14 24             	cmp    (%esp),%edx
  80270b:	0f 83 37 ff ff ff    	jae    802648 <__udivdi3+0x48>
  802711:	b8 01 00 00 00       	mov    $0x1,%eax
  802716:	e9 2d ff ff ff       	jmp    802648 <__udivdi3+0x48>
  80271b:	90                   	nop
  80271c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802720:	89 f8                	mov    %edi,%eax
  802722:	31 f6                	xor    %esi,%esi
  802724:	e9 1f ff ff ff       	jmp    802648 <__udivdi3+0x48>
  802729:	66 90                	xchg   %ax,%ax
  80272b:	66 90                	xchg   %ax,%ax
  80272d:	66 90                	xchg   %ax,%ax
  80272f:	90                   	nop

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	83 ec 20             	sub    $0x20,%esp
  802736:	8b 44 24 34          	mov    0x34(%esp),%eax
  80273a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80273e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802742:	89 c6                	mov    %eax,%esi
  802744:	89 44 24 10          	mov    %eax,0x10(%esp)
  802748:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80274c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802750:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802754:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802758:	89 74 24 18          	mov    %esi,0x18(%esp)
  80275c:	85 c0                	test   %eax,%eax
  80275e:	89 c2                	mov    %eax,%edx
  802760:	75 1e                	jne    802780 <__umoddi3+0x50>
  802762:	39 f7                	cmp    %esi,%edi
  802764:	76 52                	jbe    8027b8 <__umoddi3+0x88>
  802766:	89 c8                	mov    %ecx,%eax
  802768:	89 f2                	mov    %esi,%edx
  80276a:	f7 f7                	div    %edi
  80276c:	89 d0                	mov    %edx,%eax
  80276e:	31 d2                	xor    %edx,%edx
  802770:	83 c4 20             	add    $0x20,%esp
  802773:	5e                   	pop    %esi
  802774:	5f                   	pop    %edi
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
  802777:	89 f6                	mov    %esi,%esi
  802779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802780:	39 f0                	cmp    %esi,%eax
  802782:	77 5c                	ja     8027e0 <__umoddi3+0xb0>
  802784:	0f bd e8             	bsr    %eax,%ebp
  802787:	83 f5 1f             	xor    $0x1f,%ebp
  80278a:	75 64                	jne    8027f0 <__umoddi3+0xc0>
  80278c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802790:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802794:	0f 86 f6 00 00 00    	jbe    802890 <__umoddi3+0x160>
  80279a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80279e:	0f 82 ec 00 00 00    	jb     802890 <__umoddi3+0x160>
  8027a4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027a8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8027ac:	83 c4 20             	add    $0x20,%esp
  8027af:	5e                   	pop    %esi
  8027b0:	5f                   	pop    %edi
  8027b1:	5d                   	pop    %ebp
  8027b2:	c3                   	ret    
  8027b3:	90                   	nop
  8027b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	85 ff                	test   %edi,%edi
  8027ba:	89 fd                	mov    %edi,%ebp
  8027bc:	75 0b                	jne    8027c9 <__umoddi3+0x99>
  8027be:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f7                	div    %edi
  8027c7:	89 c5                	mov    %eax,%ebp
  8027c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8027cd:	31 d2                	xor    %edx,%edx
  8027cf:	f7 f5                	div    %ebp
  8027d1:	89 c8                	mov    %ecx,%eax
  8027d3:	f7 f5                	div    %ebp
  8027d5:	eb 95                	jmp    80276c <__umoddi3+0x3c>
  8027d7:	89 f6                	mov    %esi,%esi
  8027d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027e0:	89 c8                	mov    %ecx,%eax
  8027e2:	89 f2                	mov    %esi,%edx
  8027e4:	83 c4 20             	add    $0x20,%esp
  8027e7:	5e                   	pop    %esi
  8027e8:	5f                   	pop    %edi
  8027e9:	5d                   	pop    %ebp
  8027ea:	c3                   	ret    
  8027eb:	90                   	nop
  8027ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8027f5:	89 e9                	mov    %ebp,%ecx
  8027f7:	29 e8                	sub    %ebp,%eax
  8027f9:	d3 e2                	shl    %cl,%edx
  8027fb:	89 c7                	mov    %eax,%edi
  8027fd:	89 44 24 18          	mov    %eax,0x18(%esp)
  802801:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802805:	89 f9                	mov    %edi,%ecx
  802807:	d3 e8                	shr    %cl,%eax
  802809:	89 c1                	mov    %eax,%ecx
  80280b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80280f:	09 d1                	or     %edx,%ecx
  802811:	89 fa                	mov    %edi,%edx
  802813:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802817:	89 e9                	mov    %ebp,%ecx
  802819:	d3 e0                	shl    %cl,%eax
  80281b:	89 f9                	mov    %edi,%ecx
  80281d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802821:	89 f0                	mov    %esi,%eax
  802823:	d3 e8                	shr    %cl,%eax
  802825:	89 e9                	mov    %ebp,%ecx
  802827:	89 c7                	mov    %eax,%edi
  802829:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80282d:	d3 e6                	shl    %cl,%esi
  80282f:	89 d1                	mov    %edx,%ecx
  802831:	89 fa                	mov    %edi,%edx
  802833:	d3 e8                	shr    %cl,%eax
  802835:	89 e9                	mov    %ebp,%ecx
  802837:	09 f0                	or     %esi,%eax
  802839:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80283d:	f7 74 24 10          	divl   0x10(%esp)
  802841:	d3 e6                	shl    %cl,%esi
  802843:	89 d1                	mov    %edx,%ecx
  802845:	f7 64 24 0c          	mull   0xc(%esp)
  802849:	39 d1                	cmp    %edx,%ecx
  80284b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80284f:	89 d7                	mov    %edx,%edi
  802851:	89 c6                	mov    %eax,%esi
  802853:	72 0a                	jb     80285f <__umoddi3+0x12f>
  802855:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802859:	73 10                	jae    80286b <__umoddi3+0x13b>
  80285b:	39 d1                	cmp    %edx,%ecx
  80285d:	75 0c                	jne    80286b <__umoddi3+0x13b>
  80285f:	89 d7                	mov    %edx,%edi
  802861:	89 c6                	mov    %eax,%esi
  802863:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802867:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80286b:	89 ca                	mov    %ecx,%edx
  80286d:	89 e9                	mov    %ebp,%ecx
  80286f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802873:	29 f0                	sub    %esi,%eax
  802875:	19 fa                	sbb    %edi,%edx
  802877:	d3 e8                	shr    %cl,%eax
  802879:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80287e:	89 d7                	mov    %edx,%edi
  802880:	d3 e7                	shl    %cl,%edi
  802882:	89 e9                	mov    %ebp,%ecx
  802884:	09 f8                	or     %edi,%eax
  802886:	d3 ea                	shr    %cl,%edx
  802888:	83 c4 20             	add    $0x20,%esp
  80288b:	5e                   	pop    %esi
  80288c:	5f                   	pop    %edi
  80288d:	5d                   	pop    %ebp
  80288e:	c3                   	ret    
  80288f:	90                   	nop
  802890:	8b 74 24 10          	mov    0x10(%esp),%esi
  802894:	29 f9                	sub    %edi,%ecx
  802896:	19 c6                	sbb    %eax,%esi
  802898:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80289c:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028a0:	e9 ff fe ff ff       	jmp    8027a4 <__umoddi3+0x74>
