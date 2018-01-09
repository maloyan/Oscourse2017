
obj/user/testfdsharing:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 40 23 80 00       	push   $0x802340
  800043:	e8 94 18 00 00       	call   8018dc <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %i", fd);
  800051:	50                   	push   %eax
  800052:	68 45 23 80 00       	push   $0x802345
  800057:	6a 0c                	push   $0xc
  800059:	68 53 23 80 00       	push   $0x802353
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 45 15 00 00       	call   8015b3 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 40 42 80 00       	push   $0x804240
  80007b:	53                   	push   %ebx
  80007c:	e8 61 14 00 00       	call   8014e2 <readn>
  800081:	89 c7                	mov    %eax,%edi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %i", n);
  80008a:	50                   	push   %eax
  80008b:	68 68 23 80 00       	push   $0x802368
  800090:	6a 0f                	push   $0xf
  800092:	68 53 23 80 00       	push   $0x802353
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 e8 0e 00 00       	call   800f89 <fork>
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %i", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 59 28 80 00       	push   $0x802859
  8000ad:	6a 12                	push   $0x12
  8000af:	68 53 23 80 00       	push   $0x802353
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 e7 14 00 00       	call   8015b3 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 40 40 80 00       	push   $0x804040
  8000e5:	53                   	push   %ebx
  8000e6:	e8 f7 13 00 00       	call   8014e2 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 f8                	cmp    %edi,%eax
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	57                   	push   %edi
  8000f7:	68 ec 23 80 00       	push   $0x8023ec
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 53 23 80 00       	push   $0x802353
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	50                   	push   %eax
  80010c:	68 40 40 80 00       	push   $0x804040
  800111:	68 40 42 80 00       	push   $0x804240
  800116:	e8 67 09 00 00       	call   800a82 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 18 24 80 00       	push   $0x802418
  80012a:	6a 19                	push   $0x19
  80012c:	68 53 23 80 00       	push   $0x802353
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 72 23 80 00       	push   $0x802372
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 65 14 00 00       	call   8015b3 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 bb 11 00 00       	call   801311 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	56                   	push   %esi
  800162:	e8 6c 1b 00 00       	call   801cd3 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 40 40 80 00       	push   $0x804040
  800174:	53                   	push   %ebx
  800175:	e8 68 13 00 00       	call   8014e2 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 f8                	cmp    %edi,%eax
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	57                   	push   %edi
  800186:	68 50 24 80 00       	push   $0x802450
  80018b:	6a 21                	push   $0x21
  80018d:	68 53 23 80 00       	push   $0x802353
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 8b 23 80 00       	push   $0x80238b
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 65 11 00 00       	call   801311 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   
  8001ad:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001c3:	e8 79 0a 00 00       	call   800c41 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 78             	imul   $0x78,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 40 44 80 00       	mov    %eax,0x804440

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
  8001f4:	83 c4 10             	add    $0x10,%esp
#endif
}
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 35 11 00 00       	call   80133e <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 ed 09 00 00       	call   800c00 <sys_env_destroy>
  800213:	83 c4 10             	add    $0x10,%esp
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 16 0a 00 00       	call   800c41 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 80 24 80 00       	push   $0x802480
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 89 23 80 00 	movl   $0x802389,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 35 09 00 00       	call   800bc3 <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 4f 01 00 00       	call   800423 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 da 08 00 00       	call   800bc3 <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 d1                	mov    %edx,%ecx
  80031a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800326:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800333:	72 05                	jb     80033a <printnum+0x35>
  800335:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800338:	77 3e                	ja     800378 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	53                   	push   %ebx
  800344:	50                   	push   %eax
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 27 1d 00 00       	call   802080 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 13                	jmp    80037f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800378:	83 eb 01             	sub    $0x1,%ebx
  80037b:	85 db                	test   %ebx,%ebx
  80037d:	7f ed                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	56                   	push   %esi
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff 75 e4             	pushl  -0x1c(%ebp)
  800389:	ff 75 e0             	pushl  -0x20(%ebp)
  80038c:	ff 75 dc             	pushl  -0x24(%ebp)
  80038f:	ff 75 d8             	pushl  -0x28(%ebp)
  800392:	e8 19 1e 00 00       	call   8021b0 <__umoddi3>
  800397:	83 c4 14             	add    $0x14,%esp
  80039a:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  8003a1:	50                   	push   %eax
  8003a2:	ff d7                	call   *%edi
  8003a4:	83 c4 10             	add    $0x10,%esp
}
  8003a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	50                   	push   %eax
  800410:	ff 75 10             	pushl  0x10(%ebp)
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 05 00 00 00       	call   800423 <vprintfmt>
	va_end(ap);
  80041e:	83 c4 10             	add    $0x10,%esp
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	57                   	push   %edi
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 2c             	sub    $0x2c,%esp
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 7d 10             	mov    0x10(%ebp),%edi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 8d 03 00 00    	je     8007cc <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	53                   	push   %ebx
  800443:	50                   	push   %eax
  800444:	ff d6                	call   *%esi
  800446:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	83 c7 01             	add    $0x1,%edi
  80044c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800450:	83 f8 25             	cmp    $0x25,%eax
  800453:	75 e2                	jne    800437 <vprintfmt+0x14>
  800455:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800459:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	eb 07                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8d 47 01             	lea    0x1(%edi),%eax
  80047f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800482:	0f b6 07             	movzbl (%edi),%eax
  800485:	0f b6 c8             	movzbl %al,%ecx
  800488:	83 e8 23             	sub    $0x23,%eax
  80048b:	3c 55                	cmp    $0x55,%al
  80048d:	0f 87 1e 03 00 00    	ja     8007b1 <vprintfmt+0x38e>
  800493:	0f b6 c0             	movzbl %al,%eax
  800496:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a4:	eb d6                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004be:	83 fa 09             	cmp    $0x9,%edx
  8004c1:	77 38                	ja     8004fb <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb e9                	jmp    8004b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d9:	eb 26                	jmp    800501 <vprintfmt+0xde>
  8004db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004de:	89 c8                	mov    %ecx,%eax
  8004e0:	c1 f8 1f             	sar    $0x1f,%eax
  8004e3:	f7 d0                	not    %eax
  8004e5:	21 c1                	and    %eax,%ecx
  8004e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ed:	eb 8d                	jmp    80047c <vprintfmt+0x59>
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f9:	eb 81                	jmp    80047c <vprintfmt+0x59>
  8004fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800501:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800505:	0f 89 71 ff ff ff    	jns    80047c <vprintfmt+0x59>
				width = precision, precision = -1;
  80050b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800511:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800518:	e9 5f ff ff ff       	jmp    80047c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800523:	e9 54 ff ff ff       	jmp    80047c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	ff 30                	pushl  (%eax)
  800537:	ff d6                	call   *%esi
			break;
  800539:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053f:	e9 05 ff ff ff       	jmp    800449 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	99                   	cltd   
  800550:	31 d0                	xor    %edx,%eax
  800552:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800554:	83 f8 0f             	cmp    $0xf,%eax
  800557:	7f 0b                	jg     800564 <vprintfmt+0x141>
  800559:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	75 18                	jne    80057c <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800564:	50                   	push   %eax
  800565:	68 bb 24 80 00       	push   $0x8024bb
  80056a:	53                   	push   %ebx
  80056b:	56                   	push   %esi
  80056c:	e8 95 fe ff ff       	call   800406 <printfmt>
  800571:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800577:	e9 cd fe ff ff       	jmp    800449 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057c:	52                   	push   %edx
  80057d:	68 41 29 80 00       	push   $0x802941
  800582:	53                   	push   %ebx
  800583:	56                   	push   %esi
  800584:	e8 7d fe ff ff       	call   800406 <printfmt>
  800589:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058f:	e9 b5 fe ff ff       	jmp    800449 <vprintfmt+0x26>
  800594:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800597:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 38                	mov    (%eax),%edi
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	75 05                	jne    8005b1 <vprintfmt+0x18e>
				p = "(null)";
  8005ac:	bf b4 24 80 00       	mov    $0x8024b4,%edi
			if (width > 0 && padc != '-')
  8005b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b5:	0f 84 91 00 00 00    	je     80064c <vprintfmt+0x229>
  8005bb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005bf:	0f 8e 95 00 00 00    	jle    80065a <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	51                   	push   %ecx
  8005c9:	57                   	push   %edi
  8005ca:	e8 85 02 00 00       	call   800854 <strnlen>
  8005cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c5>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	89 c8                	mov    %ecx,%eax
  800603:	c1 f8 1f             	sar    $0x1f,%eax
  800606:	f7 d0                	not    %eax
  800608:	21 c8                	and    %ecx,%eax
  80060a:	29 c1                	sub    %eax,%ecx
  80060c:	89 75 08             	mov    %esi,0x8(%ebp)
  80060f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800612:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800615:	89 cb                	mov    %ecx,%ebx
  800617:	eb 4d                	jmp    800666 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061d:	74 1b                	je     80063a <vprintfmt+0x217>
  80061f:	0f be c0             	movsbl %al,%eax
  800622:	83 e8 20             	sub    $0x20,%eax
  800625:	83 f8 5e             	cmp    $0x5e,%eax
  800628:	76 10                	jbe    80063a <vprintfmt+0x217>
					putch('?', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	ff 75 0c             	pushl  0xc(%ebp)
  800630:	6a 3f                	push   $0x3f
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	eb 0d                	jmp    800647 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	ff 75 0c             	pushl  0xc(%ebp)
  800640:	52                   	push   %edx
  800641:	ff 55 08             	call   *0x8(%ebp)
  800644:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800647:	83 eb 01             	sub    $0x1,%ebx
  80064a:	eb 1a                	jmp    800666 <vprintfmt+0x243>
  80064c:	89 75 08             	mov    %esi,0x8(%ebp)
  80064f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800652:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800655:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800658:	eb 0c                	jmp    800666 <vprintfmt+0x243>
  80065a:	89 75 08             	mov    %esi,0x8(%ebp)
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800666:	83 c7 01             	add    $0x1,%edi
  800669:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066d:	0f be d0             	movsbl %al,%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	74 23                	je     800697 <vprintfmt+0x274>
  800674:	85 f6                	test   %esi,%esi
  800676:	78 a1                	js     800619 <vprintfmt+0x1f6>
  800678:	83 ee 01             	sub    $0x1,%esi
  80067b:	79 9c                	jns    800619 <vprintfmt+0x1f6>
  80067d:	89 df                	mov    %ebx,%edi
  80067f:	8b 75 08             	mov    0x8(%ebp),%esi
  800682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800685:	eb 18                	jmp    80069f <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 20                	push   $0x20
  80068d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068f:	83 ef 01             	sub    $0x1,%edi
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	eb 08                	jmp    80069f <vprintfmt+0x27c>
  800697:	89 df                	mov    %ebx,%edi
  800699:	8b 75 08             	mov    0x8(%ebp),%esi
  80069c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	7f e4                	jg     800687 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a6:	e9 9e fd ff ff       	jmp    800449 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ab:	83 fa 01             	cmp    $0x1,%edx
  8006ae:	7e 16                	jle    8006c6 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 08             	lea    0x8(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 50 04             	mov    0x4(%eax),%edx
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c4:	eb 32                	jmp    8006f8 <vprintfmt+0x2d5>
	else if (lflag)
  8006c6:	85 d2                	test   %edx,%edx
  8006c8:	74 18                	je     8006e2 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 c1                	mov    %eax,%ecx
  8006da:	c1 f9 1f             	sar    $0x1f,%ecx
  8006dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e0:	eb 16                	jmp    8006f8 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 c1                	mov    %eax,%ecx
  8006f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800703:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800707:	79 74                	jns    80077d <vprintfmt+0x35a>
				putch('-', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 2d                	push   $0x2d
  80070f:	ff d6                	call   *%esi
				num = -(long long) num;
  800711:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800714:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800717:	f7 d8                	neg    %eax
  800719:	83 d2 00             	adc    $0x0,%edx
  80071c:	f7 da                	neg    %edx
  80071e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800721:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800726:	eb 55                	jmp    80077d <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
  80072b:	e8 7f fc ff ff       	call   8003af <getuint>
			base = 10;
  800730:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800735:	eb 46                	jmp    80077d <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800737:	8d 45 14             	lea    0x14(%ebp),%eax
  80073a:	e8 70 fc ff ff       	call   8003af <getuint>
			base = 8;
  80073f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800744:	eb 37                	jmp    80077d <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	53                   	push   %ebx
  80074a:	6a 30                	push   $0x30
  80074c:	ff d6                	call   *%esi
			putch('x', putdat);
  80074e:	83 c4 08             	add    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 78                	push   $0x78
  800754:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 04             	lea    0x4(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800766:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800769:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076e:	eb 0d                	jmp    80077d <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
  800773:	e8 37 fc ff ff       	call   8003af <getuint>
			base = 16;
  800778:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800784:	57                   	push   %edi
  800785:	ff 75 e0             	pushl  -0x20(%ebp)
  800788:	51                   	push   %ecx
  800789:	52                   	push   %edx
  80078a:	50                   	push   %eax
  80078b:	89 da                	mov    %ebx,%edx
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	e8 71 fb ff ff       	call   800305 <printnum>
			break;
  800794:	83 c4 20             	add    $0x20,%esp
  800797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079a:	e9 aa fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	51                   	push   %ecx
  8007a4:	ff d6                	call   *%esi
			break;
  8007a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ac:	e9 98 fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	6a 25                	push   $0x25
  8007b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 03                	jmp    8007c1 <vprintfmt+0x39e>
  8007be:	83 ef 01             	sub    $0x1,%edi
  8007c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c5:	75 f7                	jne    8007be <vprintfmt+0x39b>
  8007c7:	e9 7d fc ff ff       	jmp    800449 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5f                   	pop    %edi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 18             	sub    $0x18,%esp
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	74 26                	je     80081b <vsnprintf+0x47>
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	7e 22                	jle    80081b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f9:	ff 75 14             	pushl  0x14(%ebp)
  8007fc:	ff 75 10             	pushl  0x10(%ebp)
  8007ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800802:	50                   	push   %eax
  800803:	68 e9 03 80 00       	push   $0x8003e9
  800808:	e8 16 fc ff ff       	call   800423 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800810:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800813:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	eb 05                	jmp    800820 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800828:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082b:	50                   	push   %eax
  80082c:	ff 75 10             	pushl  0x10(%ebp)
  80082f:	ff 75 0c             	pushl  0xc(%ebp)
  800832:	ff 75 08             	pushl  0x8(%ebp)
  800835:	e8 9a ff ff ff       	call   8007d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	eb 03                	jmp    80084c <strlen+0x10>
		n++;
  800849:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800850:	75 f7                	jne    800849 <strlen+0xd>
		n++;
	return n;
}
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
  800862:	eb 03                	jmp    800867 <strnlen+0x13>
		n++;
  800864:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 08                	je     800873 <strnlen+0x1f>
  80086b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80086f:	75 f3                	jne    800864 <strnlen+0x10>
  800871:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087f:	89 c2                	mov    %eax,%edx
  800881:	83 c2 01             	add    $0x1,%edx
  800884:	83 c1 01             	add    $0x1,%ecx
  800887:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088e:	84 db                	test   %bl,%bl
  800890:	75 ef                	jne    800881 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800892:	5b                   	pop    %ebx
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089c:	53                   	push   %ebx
  80089d:	e8 9a ff ff ff       	call   80083c <strlen>
  8008a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a5:	ff 75 0c             	pushl  0xc(%ebp)
  8008a8:	01 d8                	add    %ebx,%eax
  8008aa:	50                   	push   %eax
  8008ab:	e8 c5 ff ff ff       	call   800875 <strcpy>
	return dst;
}
  8008b0:	89 d8                	mov    %ebx,%eax
  8008b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	89 f3                	mov    %esi,%ebx
  8008c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c7:	89 f2                	mov    %esi,%edx
  8008c9:	eb 0f                	jmp    8008da <strncpy+0x23>
		*dst++ = *src;
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008da:	39 da                	cmp    %ebx,%edx
  8008dc:	75 ed                	jne    8008cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	74 21                	je     800919 <strlcpy+0x35>
  8008f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fc:	89 f2                	mov    %esi,%edx
  8008fe:	eb 09                	jmp    800909 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	83 c1 01             	add    $0x1,%ecx
  800906:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800909:	39 c2                	cmp    %eax,%edx
  80090b:	74 09                	je     800916 <strlcpy+0x32>
  80090d:	0f b6 19             	movzbl (%ecx),%ebx
  800910:	84 db                	test   %bl,%bl
  800912:	75 ec                	jne    800900 <strlcpy+0x1c>
  800914:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800916:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800919:	29 f0                	sub    %esi,%eax
}
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800928:	eb 06                	jmp    800930 <strcmp+0x11>
		p++, q++;
  80092a:	83 c1 01             	add    $0x1,%ecx
  80092d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800930:	0f b6 01             	movzbl (%ecx),%eax
  800933:	84 c0                	test   %al,%al
  800935:	74 04                	je     80093b <strcmp+0x1c>
  800937:	3a 02                	cmp    (%edx),%al
  800939:	74 ef                	je     80092a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 c0             	movzbl %al,%eax
  80093e:	0f b6 12             	movzbl (%edx),%edx
  800941:	29 d0                	sub    %edx,%eax
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	89 c3                	mov    %eax,%ebx
  800951:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800954:	eb 06                	jmp    80095c <strncmp+0x17>
		n--, p++, q++;
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095c:	39 d8                	cmp    %ebx,%eax
  80095e:	74 15                	je     800975 <strncmp+0x30>
  800960:	0f b6 08             	movzbl (%eax),%ecx
  800963:	84 c9                	test   %cl,%cl
  800965:	74 04                	je     80096b <strncmp+0x26>
  800967:	3a 0a                	cmp    (%edx),%cl
  800969:	74 eb                	je     800956 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096b:	0f b6 00             	movzbl (%eax),%eax
  80096e:	0f b6 12             	movzbl (%edx),%edx
  800971:	29 d0                	sub    %edx,%eax
  800973:	eb 05                	jmp    80097a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097a:	5b                   	pop    %ebx
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800987:	eb 07                	jmp    800990 <strchr+0x13>
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 0f                	je     80099c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	0f b6 10             	movzbl (%eax),%edx
  800993:	84 d2                	test   %dl,%dl
  800995:	75 f2                	jne    800989 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	eb 03                	jmp    8009ad <strfind+0xf>
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	74 04                	je     8009b8 <strfind+0x1a>
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	75 f2                	jne    8009aa <strfind+0xc>
			break;
	return (char *) s;
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8009c6:	85 c9                	test   %ecx,%ecx
  8009c8:	74 36                	je     800a00 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d0:	75 28                	jne    8009fa <memset+0x40>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 23                	jne    8009fa <memset+0x40>
		c &= 0xFF;
  8009d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009db:	89 d3                	mov    %edx,%ebx
  8009dd:	c1 e3 08             	shl    $0x8,%ebx
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	c1 e6 18             	shl    $0x18,%esi
  8009e5:	89 d0                	mov    %edx,%eax
  8009e7:	c1 e0 10             	shl    $0x10,%eax
  8009ea:	09 f0                	or     %esi,%eax
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	89 d0                	mov    %edx,%eax
  8009f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f5:	fc                   	cld    
  8009f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f8:	eb 06                	jmp    800a00 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	fc                   	cld    
  8009fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a00:	89 f8                	mov    %edi,%eax
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a15:	39 c6                	cmp    %eax,%esi
  800a17:	73 35                	jae    800a4e <memmove+0x47>
  800a19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	73 2e                	jae    800a4e <memmove+0x47>
		s += n;
		d += n;
  800a20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a23:	89 d6                	mov    %edx,%esi
  800a25:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2d:	75 13                	jne    800a42 <memmove+0x3b>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 0e                	jne    800a42 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a34:	83 ef 04             	sub    $0x4,%edi
  800a37:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3d:	fd                   	std    
  800a3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a40:	eb 09                	jmp    800a4b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a42:	83 ef 01             	sub    $0x1,%edi
  800a45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a48:	fd                   	std    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4b:	fc                   	cld    
  800a4c:	eb 1d                	jmp    800a6b <memmove+0x64>
  800a4e:	89 f2                	mov    %esi,%edx
  800a50:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f6 c2 03             	test   $0x3,%dl
  800a55:	75 0f                	jne    800a66 <memmove+0x5f>
  800a57:	f6 c1 03             	test   $0x3,%cl
  800a5a:	75 0a                	jne    800a66 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5f:	89 c7                	mov    %eax,%edi
  800a61:	fc                   	cld    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 05                	jmp    800a6b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a72:	ff 75 10             	pushl  0x10(%ebp)
  800a75:	ff 75 0c             	pushl  0xc(%ebp)
  800a78:	ff 75 08             	pushl  0x8(%ebp)
  800a7b:	e8 87 ff ff ff       	call   800a07 <memmove>
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 c6                	mov    %eax,%esi
  800a8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a92:	eb 1a                	jmp    800aae <memcmp+0x2c>
		if (*s1 != *s2)
  800a94:	0f b6 08             	movzbl (%eax),%ecx
  800a97:	0f b6 1a             	movzbl (%edx),%ebx
  800a9a:	38 d9                	cmp    %bl,%cl
  800a9c:	74 0a                	je     800aa8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c1             	movzbl %cl,%eax
  800aa1:	0f b6 db             	movzbl %bl,%ebx
  800aa4:	29 d8                	sub    %ebx,%eax
  800aa6:	eb 0f                	jmp    800ab7 <memcmp+0x35>
		s1++, s2++;
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	39 f0                	cmp    %esi,%eax
  800ab0:	75 e2                	jne    800a94 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac9:	eb 07                	jmp    800ad2 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800acb:	38 08                	cmp    %cl,(%eax)
  800acd:	74 07                	je     800ad6 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	39 d0                	cmp    %edx,%eax
  800ad4:	72 f5                	jb     800acb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae4:	eb 03                	jmp    800ae9 <strtol+0x11>
		s++;
  800ae6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae9:	0f b6 01             	movzbl (%ecx),%eax
  800aec:	3c 09                	cmp    $0x9,%al
  800aee:	74 f6                	je     800ae6 <strtol+0xe>
  800af0:	3c 20                	cmp    $0x20,%al
  800af2:	74 f2                	je     800ae6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af4:	3c 2b                	cmp    $0x2b,%al
  800af6:	75 0a                	jne    800b02 <strtol+0x2a>
		s++;
  800af8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afb:	bf 00 00 00 00       	mov    $0x0,%edi
  800b00:	eb 10                	jmp    800b12 <strtol+0x3a>
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b07:	3c 2d                	cmp    $0x2d,%al
  800b09:	75 07                	jne    800b12 <strtol+0x3a>
		s++, neg = 1;
  800b0b:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b0e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b12:	85 db                	test   %ebx,%ebx
  800b14:	0f 94 c0             	sete   %al
  800b17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1d:	75 19                	jne    800b38 <strtol+0x60>
  800b1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b22:	75 14                	jne    800b38 <strtol+0x60>
  800b24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b28:	0f 85 8a 00 00 00    	jne    800bb8 <strtol+0xe0>
		s += 2, base = 16;
  800b2e:	83 c1 02             	add    $0x2,%ecx
  800b31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b36:	eb 16                	jmp    800b4e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b38:	84 c0                	test   %al,%al
  800b3a:	74 12                	je     800b4e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b41:	80 39 30             	cmpb   $0x30,(%ecx)
  800b44:	75 08                	jne    800b4e <strtol+0x76>
		s++, base = 8;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b56:	0f b6 11             	movzbl (%ecx),%edx
  800b59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5c:	89 f3                	mov    %esi,%ebx
  800b5e:	80 fb 09             	cmp    $0x9,%bl
  800b61:	77 08                	ja     800b6b <strtol+0x93>
			dig = *s - '0';
  800b63:	0f be d2             	movsbl %dl,%edx
  800b66:	83 ea 30             	sub    $0x30,%edx
  800b69:	eb 22                	jmp    800b8d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6e:	89 f3                	mov    %esi,%ebx
  800b70:	80 fb 19             	cmp    $0x19,%bl
  800b73:	77 08                	ja     800b7d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b75:	0f be d2             	movsbl %dl,%edx
  800b78:	83 ea 57             	sub    $0x57,%edx
  800b7b:	eb 10                	jmp    800b8d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b80:	89 f3                	mov    %esi,%ebx
  800b82:	80 fb 19             	cmp    $0x19,%bl
  800b85:	77 16                	ja     800b9d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b87:	0f be d2             	movsbl %dl,%edx
  800b8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b90:	7d 0f                	jge    800ba1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9b:	eb b9                	jmp    800b56 <strtol+0x7e>
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 02                	jmp    800ba3 <strtol+0xcb>
  800ba1:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ba3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba7:	74 05                	je     800bae <strtol+0xd6>
		*endptr = (char *) s;
  800ba9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bac:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bae:	85 ff                	test   %edi,%edi
  800bb0:	74 0c                	je     800bbe <strtol+0xe6>
  800bb2:	89 d0                	mov    %edx,%eax
  800bb4:	f7 d8                	neg    %eax
  800bb6:	eb 06                	jmp    800bbe <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb8:	84 c0                	test   %al,%al
  800bba:	75 8a                	jne    800b46 <strtol+0x6e>
  800bbc:	eb 90                	jmp    800b4e <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	89 c3                	mov    %eax,%ebx
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	89 c6                	mov    %eax,%esi
  800bda:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 cb                	mov    %ecx,%ebx
  800c18:	89 cf                	mov    %ecx,%edi
  800c1a:	89 ce                	mov    %ecx,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 03                	push   $0x3
  800c28:	68 df 27 80 00       	push   $0x8027df
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 fc 27 80 00       	push   $0x8027fc
  800c34:	e8 df f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_yield>:

void
sys_yield(void)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c88:	be 00 00 00 00       	mov    $0x0,%esi
  800c8d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 04                	push   $0x4
  800ca9:	68 df 27 80 00       	push   $0x8027df
  800cae:	6a 23                	push   $0x23
  800cb0:	68 fc 27 80 00       	push   $0x8027fc
  800cb5:	e8 5e f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ccb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdc:	8b 75 18             	mov    0x18(%ebp),%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 05                	push   $0x5
  800ceb:	68 df 27 80 00       	push   $0x8027df
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 fc 27 80 00       	push   $0x8027fc
  800cf7:	e8 1c f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d12:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800d25:	7e 17                	jle    800d3e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 06                	push   $0x6
  800d2d:	68 df 27 80 00       	push   $0x8027df
  800d32:	6a 23                	push   $0x23
  800d34:	68 fc 27 80 00       	push   $0x8027fc
  800d39:	e8 da f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d54:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800d67:	7e 17                	jle    800d80 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 08                	push   $0x8
  800d6f:	68 df 27 80 00       	push   $0x8027df
  800d74:	6a 23                	push   $0x23
  800d76:	68 fc 27 80 00       	push   $0x8027fc
  800d7b:	e8 98 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 09                	push   $0x9
  800db1:	68 df 27 80 00       	push   $0x8027df
  800db6:	6a 23                	push   $0x23
  800db8:	68 fc 27 80 00       	push   $0x8027fc
  800dbd:	e8 56 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 17                	jle    800e04 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 0a                	push   $0xa
  800df3:	68 df 27 80 00       	push   $0x8027df
  800df8:	6a 23                	push   $0x23
  800dfa:	68 fc 27 80 00       	push   $0x8027fc
  800dff:	e8 14 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	be 00 00 00 00       	mov    $0x0,%esi
  800e17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e28:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 cb                	mov    %ecx,%ebx
  800e47:	89 cf                	mov    %ecx,%edi
  800e49:	89 ce                	mov    %ecx,%esi
  800e4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 17                	jle    800e68 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	50                   	push   %eax
  800e55:	6a 0d                	push   $0xd
  800e57:	68 df 27 80 00       	push   $0x8027df
  800e5c:	6a 23                	push   $0x23
  800e5e:	68 fc 27 80 00       	push   $0x8027fc
  800e63:	e8 b0 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_gettime>:

int sys_gettime(void)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e80:	89 d1                	mov    %edx,%ecx
  800e82:	89 d3                	mov    %edx,%ebx
  800e84:	89 d7                	mov    %edx,%edi
  800e86:	89 d6                	mov    %edx,%esi
  800e88:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	53                   	push   %ebx
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800e99:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800e9b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e9f:	74 2e                	je     800ecf <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800ea1:	89 c2                	mov    %eax,%edx
  800ea3:	c1 ea 16             	shr    $0x16,%edx
  800ea6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ead:	f6 c2 01             	test   $0x1,%dl
  800eb0:	74 1d                	je     800ecf <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	c1 ea 0c             	shr    $0xc,%edx
  800eb7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800ebe:	f6 c1 01             	test   $0x1,%cl
  800ec1:	74 0c                	je     800ecf <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800ec3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800eca:	f6 c6 08             	test   $0x8,%dh
  800ecd:	75 14                	jne    800ee3 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 0a 28 80 00       	push   $0x80280a
  800ed7:	6a 28                	push   $0x28
  800ed9:	68 1c 28 80 00       	push   $0x80281c
  800ede:	e8 35 f3 ff ff       	call   800218 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800ee3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee8:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	6a 07                	push   $0x7
  800eef:	68 00 f0 7f 00       	push   $0x7ff000
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 84 fd ff ff       	call   800c7f <sys_page_alloc>
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	79 14                	jns    800f16 <pgfault+0x87>
		panic("sys_page_alloc");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 27 28 80 00       	push   $0x802827
  800f0a:	6a 2c                	push   $0x2c
  800f0c:	68 1c 28 80 00       	push   $0x80281c
  800f11:	e8 02 f3 ff ff       	call   800218 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	68 00 10 00 00       	push   $0x1000
  800f1e:	53                   	push   %ebx
  800f1f:	68 00 f0 7f 00       	push   $0x7ff000
  800f24:	e8 46 fb ff ff       	call   800a6f <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f29:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f30:	53                   	push   %ebx
  800f31:	6a 00                	push   $0x0
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 83 fd ff ff       	call   800cc2 <sys_page_map>
  800f3f:	83 c4 20             	add    $0x20,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	79 14                	jns    800f5a <pgfault+0xcb>
		panic("sys_page_map");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 36 28 80 00       	push   $0x802836
  800f4e:	6a 2f                	push   $0x2f
  800f50:	68 1c 28 80 00       	push   $0x80281c
  800f55:	e8 be f2 ff ff       	call   800218 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	68 00 f0 7f 00       	push   $0x7ff000
  800f62:	6a 00                	push   $0x0
  800f64:	e8 9b fd ff ff       	call   800d04 <sys_page_unmap>
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 14                	jns    800f84 <pgfault+0xf5>
		panic("sys_page_unmap");
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	68 43 28 80 00       	push   $0x802843
  800f78:	6a 31                	push   $0x31
  800f7a:	68 1c 28 80 00       	push   $0x80281c
  800f7f:	e8 94 f2 ff ff       	call   800218 <_panic>
	return;
}
  800f84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800f92:	68 8f 0e 80 00       	push   $0x800e8f
  800f97:	e8 15 0f 00 00       	call   801eb1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f9c:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa1:	cd 30                	int    $0x30
  800fa3:	89 c7                	mov    %eax,%edi
  800fa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	75 21                	jne    800fd0 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800faf:	e8 8d fc ff ff       	call   800c41 <sys_getenvid>
  800fb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb9:	6b c0 78             	imul   $0x78,%eax,%eax
  800fbc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc1:	a3 40 44 80 00       	mov    %eax,0x804440
		return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	e9 80 01 00 00       	jmp    801150 <fork+0x1c7>
	}
	if (envid < 0)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 12                	jns    800fe6 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800fd4:	50                   	push   %eax
  800fd5:	68 52 28 80 00       	push   $0x802852
  800fda:	6a 70                	push   $0x70
  800fdc:	68 1c 28 80 00       	push   $0x80281c
  800fe1:	e8 32 f2 ff ff       	call   800218 <_panic>
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800feb:	89 d8                	mov    %ebx,%eax
  800fed:	c1 e8 16             	shr    $0x16,%eax
  800ff0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff7:	a8 01                	test   $0x1,%al
  800ff9:	0f 84 de 00 00 00    	je     8010dd <fork+0x154>
  800fff:	89 de                	mov    %ebx,%esi
  801001:	c1 ee 0c             	shr    $0xc,%esi
  801004:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100b:	a8 01                	test   $0x1,%al
  80100d:	0f 84 ca 00 00 00    	je     8010dd <fork+0x154>
  801013:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101a:	a8 04                	test   $0x4,%al
  80101c:	0f 84 bb 00 00 00    	je     8010dd <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  801022:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  801029:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  80102c:	f6 c4 04             	test   $0x4,%ah
  80102f:	74 34                	je     801065 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	25 07 0e 00 00       	and    $0xe07,%eax
  801039:	50                   	push   %eax
  80103a:	56                   	push   %esi
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 7c fc ff ff       	call   800cc2 <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	0f 84 8c 00 00 00    	je     8010dd <fork+0x154>
        	panic("duppage share");
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	68 62 28 80 00       	push   $0x802862
  801059:	6a 48                	push   $0x48
  80105b:	68 1c 28 80 00       	push   $0x80281c
  801060:	e8 b3 f1 ff ff       	call   800218 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801065:	a9 02 08 00 00       	test   $0x802,%eax
  80106a:	74 5d                	je     8010c9 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	68 05 08 00 00       	push   $0x805
  801074:	56                   	push   %esi
  801075:	ff 75 e4             	pushl  -0x1c(%ebp)
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 42 fc ff ff       	call   800cc2 <sys_page_map>
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 14                	jns    80109b <fork+0x112>
			panic("error");
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	68 d0 24 80 00       	push   $0x8024d0
  80108f:	6a 4b                	push   $0x4b
  801091:	68 1c 28 80 00       	push   $0x80281c
  801096:	e8 7d f1 ff ff       	call   800218 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	68 05 08 00 00       	push   $0x805
  8010a3:	56                   	push   %esi
  8010a4:	6a 00                	push   $0x0
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 14 fc ff ff       	call   800cc2 <sys_page_map>
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	79 28                	jns    8010dd <fork+0x154>
			panic("error");
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	68 d0 24 80 00       	push   $0x8024d0
  8010bd:	6a 4d                	push   $0x4d
  8010bf:	68 1c 28 80 00       	push   $0x80281c
  8010c4:	e8 4f f1 ff ff       	call   800218 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	6a 05                	push   $0x5
  8010ce:	56                   	push   %esi
  8010cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 e8 fb ff ff       	call   800cc2 <sys_page_map>
  8010da:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e3:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8010e9:	0f 85 fc fe ff ff    	jne    800feb <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	6a 07                	push   $0x7
  8010f4:	68 00 f0 7f ee       	push   $0xee7ff000
  8010f9:	57                   	push   %edi
  8010fa:	e8 80 fb ff ff       	call   800c7f <sys_page_alloc>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	79 14                	jns    80111a <fork+0x191>
		panic("1");
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	68 70 28 80 00       	push   $0x802870
  80110e:	6a 78                	push   $0x78
  801110:	68 1c 28 80 00       	push   $0x80281c
  801115:	e8 fe f0 ff ff       	call   800218 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80111a:	83 ec 08             	sub    $0x8,%esp
  80111d:	68 20 1f 80 00       	push   $0x801f20
  801122:	57                   	push   %edi
  801123:	e8 a2 fc ff ff       	call   800dca <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	6a 02                	push   $0x2
  80112d:	57                   	push   %edi
  80112e:	e8 13 fc ff ff       	call   800d46 <sys_env_set_status>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	79 14                	jns    80114e <fork+0x1c5>
		panic("sys_env_set_status");
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	68 72 28 80 00       	push   $0x802872
  801142:	6a 7d                	push   $0x7d
  801144:	68 1c 28 80 00       	push   $0x80281c
  801149:	e8 ca f0 ff ff       	call   800218 <_panic>

	return envid;
  80114e:	89 f8                	mov    %edi,%eax
}
  801150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <sfork>:

// Challenge!
int
sfork(void)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115e:	68 85 28 80 00       	push   $0x802885
  801163:	68 86 00 00 00       	push   $0x86
  801168:	68 1c 28 80 00       	push   $0x80281c
  80116d:	e8 a6 f0 ff ff       	call   800218 <_panic>

00801172 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	05 00 00 00 30       	add    $0x30000000,%eax
  80117d:	c1 e8 0c             	shr    $0xc,%eax
}
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
  801188:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80118d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801192:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 16             	shr    $0x16,%edx
  8011a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 11                	je     8011c6 <fd_alloc+0x2d>
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	75 09                	jne    8011cf <fd_alloc+0x36>
			*fd_store = fd;
  8011c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cd:	eb 17                	jmp    8011e6 <fd_alloc+0x4d>
  8011cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d9:	75 c9                	jne    8011a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ee:	83 f8 1f             	cmp    $0x1f,%eax
  8011f1:	77 36                	ja     801229 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f3:	c1 e0 0c             	shl    $0xc,%eax
  8011f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	c1 ea 16             	shr    $0x16,%edx
  801200:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801207:	f6 c2 01             	test   $0x1,%dl
  80120a:	74 24                	je     801230 <fd_lookup+0x48>
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 0c             	shr    $0xc,%edx
  801211:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 1a                	je     801237 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801220:	89 02                	mov    %eax,(%edx)
	return 0;
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	eb 13                	jmp    80123c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801229:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122e:	eb 0c                	jmp    80123c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801230:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801235:	eb 05                	jmp    80123c <fd_lookup+0x54>
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801247:	ba 18 29 80 00       	mov    $0x802918,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124c:	eb 13                	jmp    801261 <dev_lookup+0x23>
  80124e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801251:	39 08                	cmp    %ecx,(%eax)
  801253:	75 0c                	jne    801261 <dev_lookup+0x23>
			*dev = devtab[i];
  801255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801258:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 2e                	jmp    80128f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801261:	8b 02                	mov    (%edx),%eax
  801263:	85 c0                	test   %eax,%eax
  801265:	75 e7                	jne    80124e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801267:	a1 40 44 80 00       	mov    0x804440,%eax
  80126c:	8b 40 48             	mov    0x48(%eax),%eax
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	51                   	push   %ecx
  801273:	50                   	push   %eax
  801274:	68 9c 28 80 00       	push   $0x80289c
  801279:	e8 73 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 10             	sub    $0x10,%esp
  801299:	8b 75 08             	mov    0x8(%ebp),%esi
  80129c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a2:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a9:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ac:	50                   	push   %eax
  8012ad:	e8 36 ff ff ff       	call   8011e8 <fd_lookup>
  8012b2:	83 c4 08             	add    $0x8,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 05                	js     8012be <fd_close+0x2d>
	    || fd != fd2)
  8012b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012bc:	74 0b                	je     8012c9 <fd_close+0x38>
		return (must_exist ? r : 0);
  8012be:	80 fb 01             	cmp    $0x1,%bl
  8012c1:	19 d2                	sbb    %edx,%edx
  8012c3:	f7 d2                	not    %edx
  8012c5:	21 d0                	and    %edx,%eax
  8012c7:	eb 41                	jmp    80130a <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	ff 36                	pushl  (%esi)
  8012d2:	e8 67 ff ff ff       	call   80123e <dev_lookup>
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 1a                	js     8012fa <fd_close+0x69>
		if (dev->dev_close)
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	74 0b                	je     8012fa <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	56                   	push   %esi
  8012f3:	ff d0                	call   *%eax
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	56                   	push   %esi
  8012fe:	6a 00                	push   $0x0
  801300:	e8 ff f9 ff ff       	call   800d04 <sys_page_unmap>
	return r;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 d8                	mov    %ebx,%eax
}
  80130a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 75 08             	pushl  0x8(%ebp)
  80131e:	e8 c5 fe ff ff       	call   8011e8 <fd_lookup>
  801323:	89 c2                	mov    %eax,%edx
  801325:	83 c4 08             	add    $0x8,%esp
  801328:	85 d2                	test   %edx,%edx
  80132a:	78 10                	js     80133c <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	6a 01                	push   $0x1
  801331:	ff 75 f4             	pushl  -0xc(%ebp)
  801334:	e8 58 ff ff ff       	call   801291 <fd_close>
  801339:	83 c4 10             	add    $0x10,%esp
}
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <close_all>:

void
close_all(void)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801345:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	53                   	push   %ebx
  80134e:	e8 be ff ff ff       	call   801311 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801353:	83 c3 01             	add    $0x1,%ebx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	83 fb 20             	cmp    $0x20,%ebx
  80135c:	75 ec                	jne    80134a <close_all+0xc>
		close(i);
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 2c             	sub    $0x2c,%esp
  80136c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 6d fe ff ff       	call   8011e8 <fd_lookup>
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	83 c4 08             	add    $0x8,%esp
  801380:	85 d2                	test   %edx,%edx
  801382:	0f 88 c1 00 00 00    	js     801449 <dup+0xe6>
		return r;
	close(newfdnum);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	56                   	push   %esi
  80138c:	e8 80 ff ff ff       	call   801311 <close>

	newfd = INDEX2FD(newfdnum);
  801391:	89 f3                	mov    %esi,%ebx
  801393:	c1 e3 0c             	shl    $0xc,%ebx
  801396:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80139c:	83 c4 04             	add    $0x4,%esp
  80139f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a2:	e8 db fd ff ff       	call   801182 <fd2data>
  8013a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a9:	89 1c 24             	mov    %ebx,(%esp)
  8013ac:	e8 d1 fd ff ff       	call   801182 <fd2data>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b7:	89 f8                	mov    %edi,%eax
  8013b9:	c1 e8 16             	shr    $0x16,%eax
  8013bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c3:	a8 01                	test   $0x1,%al
  8013c5:	74 37                	je     8013fe <dup+0x9b>
  8013c7:	89 f8                	mov    %edi,%eax
  8013c9:	c1 e8 0c             	shr    $0xc,%eax
  8013cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d3:	f6 c2 01             	test   $0x1,%dl
  8013d6:	74 26                	je     8013fe <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e7:	50                   	push   %eax
  8013e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013eb:	6a 00                	push   $0x0
  8013ed:	57                   	push   %edi
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 cd f8 ff ff       	call   800cc2 <sys_page_map>
  8013f5:	89 c7                	mov    %eax,%edi
  8013f7:	83 c4 20             	add    $0x20,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 2e                	js     80142c <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801401:	89 d0                	mov    %edx,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
  801406:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	25 07 0e 00 00       	and    $0xe07,%eax
  801415:	50                   	push   %eax
  801416:	53                   	push   %ebx
  801417:	6a 00                	push   $0x0
  801419:	52                   	push   %edx
  80141a:	6a 00                	push   $0x0
  80141c:	e8 a1 f8 ff ff       	call   800cc2 <sys_page_map>
  801421:	89 c7                	mov    %eax,%edi
  801423:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801426:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801428:	85 ff                	test   %edi,%edi
  80142a:	79 1d                	jns    801449 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	53                   	push   %ebx
  801430:	6a 00                	push   $0x0
  801432:	e8 cd f8 ff ff       	call   800d04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801437:	83 c4 08             	add    $0x8,%esp
  80143a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80143d:	6a 00                	push   $0x0
  80143f:	e8 c0 f8 ff ff       	call   800d04 <sys_page_unmap>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 f8                	mov    %edi,%eax
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 14             	sub    $0x14,%esp
  801458:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	e8 83 fd ff ff       	call   8011e8 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	89 c2                	mov    %eax,%edx
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 6d                	js     8014db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	ff 30                	pushl  (%eax)
  80147a:	e8 bf fd ff ff       	call   80123e <dev_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 4c                	js     8014d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801486:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801489:	8b 42 08             	mov    0x8(%edx),%eax
  80148c:	83 e0 03             	and    $0x3,%eax
  80148f:	83 f8 01             	cmp    $0x1,%eax
  801492:	75 21                	jne    8014b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801494:	a1 40 44 80 00       	mov    0x804440,%eax
  801499:	8b 40 48             	mov    0x48(%eax),%eax
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	53                   	push   %ebx
  8014a0:	50                   	push   %eax
  8014a1:	68 dd 28 80 00       	push   $0x8028dd
  8014a6:	e8 46 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b3:	eb 26                	jmp    8014db <read+0x8a>
	}
	if (!dev->dev_read)
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	8b 40 08             	mov    0x8(%eax),%eax
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	74 17                	je     8014d6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	ff 75 10             	pushl  0x10(%ebp)
  8014c5:	ff 75 0c             	pushl  0xc(%ebp)
  8014c8:	52                   	push   %edx
  8014c9:	ff d0                	call   *%eax
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	eb 09                	jmp    8014db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	eb 05                	jmp    8014db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f6:	eb 21                	jmp    801519 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	89 f0                	mov    %esi,%eax
  8014fd:	29 d8                	sub    %ebx,%eax
  8014ff:	50                   	push   %eax
  801500:	89 d8                	mov    %ebx,%eax
  801502:	03 45 0c             	add    0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	57                   	push   %edi
  801507:	e8 45 ff ff ff       	call   801451 <read>
		if (m < 0)
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 0c                	js     80151f <readn+0x3d>
			return m;
		if (m == 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	74 06                	je     80151d <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801517:	01 c3                	add    %eax,%ebx
  801519:	39 f3                	cmp    %esi,%ebx
  80151b:	72 db                	jb     8014f8 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80151d:	89 d8                	mov    %ebx,%eax
}
  80151f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	53                   	push   %ebx
  80152b:	83 ec 14             	sub    $0x14,%esp
  80152e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	53                   	push   %ebx
  801536:	e8 ad fc ff ff       	call   8011e8 <fd_lookup>
  80153b:	83 c4 08             	add    $0x8,%esp
  80153e:	89 c2                	mov    %eax,%edx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 68                	js     8015ac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	ff 30                	pushl  (%eax)
  801550:	e8 e9 fc ff ff       	call   80123e <dev_lookup>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 47                	js     8015a3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801563:	75 21                	jne    801586 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801565:	a1 40 44 80 00       	mov    0x804440,%eax
  80156a:	8b 40 48             	mov    0x48(%eax),%eax
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	53                   	push   %ebx
  801571:	50                   	push   %eax
  801572:	68 f9 28 80 00       	push   $0x8028f9
  801577:	e8 75 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801584:	eb 26                	jmp    8015ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801586:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801589:	8b 52 0c             	mov    0xc(%edx),%edx
  80158c:	85 d2                	test   %edx,%edx
  80158e:	74 17                	je     8015a7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	ff 75 10             	pushl  0x10(%ebp)
  801596:	ff 75 0c             	pushl  0xc(%ebp)
  801599:	50                   	push   %eax
  80159a:	ff d2                	call   *%edx
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb 09                	jmp    8015ac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	eb 05                	jmp    8015ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	ff 75 08             	pushl  0x8(%ebp)
  8015c0:	e8 23 fc ff ff       	call   8011e8 <fd_lookup>
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 0e                	js     8015da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	53                   	push   %ebx
  8015eb:	e8 f8 fb ff ff       	call   8011e8 <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 65                	js     80165e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	ff 30                	pushl  (%eax)
  801605:	e8 34 fc ff ff       	call   80123e <dev_lookup>
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 44                	js     801655 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801614:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801618:	75 21                	jne    80163b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80161a:	a1 40 44 80 00       	mov    0x804440,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161f:	8b 40 48             	mov    0x48(%eax),%eax
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	53                   	push   %ebx
  801626:	50                   	push   %eax
  801627:	68 bc 28 80 00       	push   $0x8028bc
  80162c:	e8 c0 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801639:	eb 23                	jmp    80165e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	8b 52 18             	mov    0x18(%edx),%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	74 14                	je     801659 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	ff d2                	call   *%edx
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 09                	jmp    80165e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	89 c2                	mov    %eax,%edx
  801657:	eb 05                	jmp    80165e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801659:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165e:	89 d0                	mov    %edx,%eax
  801660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 14             	sub    $0x14,%esp
  80166c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	ff 75 08             	pushl  0x8(%ebp)
  801676:	e8 6d fb ff ff       	call   8011e8 <fd_lookup>
  80167b:	83 c4 08             	add    $0x8,%esp
  80167e:	89 c2                	mov    %eax,%edx
  801680:	85 c0                	test   %eax,%eax
  801682:	78 58                	js     8016dc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168e:	ff 30                	pushl  (%eax)
  801690:	e8 a9 fb ff ff       	call   80123e <dev_lookup>
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 37                	js     8016d3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a3:	74 32                	je     8016d7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016af:	00 00 00 
	stat->st_isdir = 0;
  8016b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b9:	00 00 00 
	stat->st_dev = dev;
  8016bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	53                   	push   %ebx
  8016c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c9:	ff 50 14             	call   *0x14(%eax)
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	eb 09                	jmp    8016dc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	eb 05                	jmp    8016dc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016dc:	89 d0                	mov    %edx,%eax
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	6a 00                	push   $0x0
  8016ed:	ff 75 08             	pushl  0x8(%ebp)
  8016f0:	e8 e7 01 00 00       	call   8018dc <open>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 db                	test   %ebx,%ebx
  8016fc:	78 1b                	js     801719 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	ff 75 0c             	pushl  0xc(%ebp)
  801704:	53                   	push   %ebx
  801705:	e8 5b ff ff ff       	call   801665 <fstat>
  80170a:	89 c6                	mov    %eax,%esi
	close(fd);
  80170c:	89 1c 24             	mov    %ebx,(%esp)
  80170f:	e8 fd fb ff ff       	call   801311 <close>
	return r;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	89 f0                	mov    %esi,%eax
}
  801719:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	89 c6                	mov    %eax,%esi
  801727:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801729:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801730:	75 12                	jne    801744 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	6a 03                	push   $0x3
  801737:	e8 c3 08 00 00       	call   801fff <ipc_find_env>
  80173c:	a3 00 40 80 00       	mov    %eax,0x804000
  801741:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801744:	6a 07                	push   $0x7
  801746:	68 00 50 80 00       	push   $0x805000
  80174b:	56                   	push   %esi
  80174c:	ff 35 00 40 80 00    	pushl  0x804000
  801752:	e8 57 08 00 00       	call   801fae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801757:	83 c4 0c             	add    $0xc,%esp
  80175a:	6a 00                	push   $0x0
  80175c:	53                   	push   %ebx
  80175d:	6a 00                	push   $0x0
  80175f:	e8 e4 07 00 00       	call   801f48 <ipc_recv>
}
  801764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 02 00 00 00       	mov    $0x2,%eax
  80178e:	e8 8d ff ff ff       	call   801720 <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b0:	e8 6b ff ff ff       	call   801720 <fsipc>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d6:	e8 45 ff ff ff       	call   801720 <fsipc>
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	85 d2                	test   %edx,%edx
  8017df:	78 2c                	js     80180d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	68 00 50 80 00       	push   $0x805000
  8017e9:	53                   	push   %ebx
  8017ea:	e8 86 f0 ff ff       	call   800875 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  80181b:	8b 55 08             	mov    0x8(%ebp),%edx
  80181e:	8b 52 0c             	mov    0xc(%edx),%edx
  801821:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801827:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80182c:	76 05                	jbe    801833 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80182e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801833:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	50                   	push   %eax
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	68 08 50 80 00       	push   $0x805008
  801844:	e8 be f1 ff ff       	call   800a07 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	b8 04 00 00 00       	mov    $0x4,%eax
  801853:	e8 c8 fe ff ff       	call   801720 <fsipc>
	return write;
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80186d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801873:	ba 00 00 00 00       	mov    $0x0,%edx
  801878:	b8 03 00 00 00       	mov    $0x3,%eax
  80187d:	e8 9e fe ff ff       	call   801720 <fsipc>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	85 c0                	test   %eax,%eax
  801886:	78 4b                	js     8018d3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801888:	39 c6                	cmp    %eax,%esi
  80188a:	73 16                	jae    8018a2 <devfile_read+0x48>
  80188c:	68 28 29 80 00       	push   $0x802928
  801891:	68 2f 29 80 00       	push   $0x80292f
  801896:	6a 7c                	push   $0x7c
  801898:	68 44 29 80 00       	push   $0x802944
  80189d:	e8 76 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a7:	7e 16                	jle    8018bf <devfile_read+0x65>
  8018a9:	68 4f 29 80 00       	push   $0x80294f
  8018ae:	68 2f 29 80 00       	push   $0x80292f
  8018b3:	6a 7d                	push   $0x7d
  8018b5:	68 44 29 80 00       	push   $0x802944
  8018ba:	e8 59 e9 ff ff       	call   800218 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018bf:	83 ec 04             	sub    $0x4,%esp
  8018c2:	50                   	push   %eax
  8018c3:	68 00 50 80 00       	push   $0x805000
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	e8 37 f1 ff ff       	call   800a07 <memmove>
	return r;
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	89 d8                	mov    %ebx,%eax
  8018d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 20             	sub    $0x20,%esp
  8018e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e6:	53                   	push   %ebx
  8018e7:	e8 50 ef ff ff       	call   80083c <strlen>
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f4:	7f 67                	jg     80195d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	e8 97 f8 ff ff       	call   801199 <fd_alloc>
  801902:	83 c4 10             	add    $0x10,%esp
		return r;
  801905:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801907:	85 c0                	test   %eax,%eax
  801909:	78 57                	js     801962 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	53                   	push   %ebx
  80190f:	68 00 50 80 00       	push   $0x805000
  801914:	e8 5c ef ff ff       	call   800875 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801921:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801924:	b8 01 00 00 00       	mov    $0x1,%eax
  801929:	e8 f2 fd ff ff       	call   801720 <fsipc>
  80192e:	89 c3                	mov    %eax,%ebx
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	79 14                	jns    80194b <open+0x6f>
		fd_close(fd, 0);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	6a 00                	push   $0x0
  80193c:	ff 75 f4             	pushl  -0xc(%ebp)
  80193f:	e8 4d f9 ff ff       	call   801291 <fd_close>
		return r;
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	89 da                	mov    %ebx,%edx
  801949:	eb 17                	jmp    801962 <open+0x86>
	}

	return fd2num(fd);
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	ff 75 f4             	pushl  -0xc(%ebp)
  801951:	e8 1c f8 ff ff       	call   801172 <fd2num>
  801956:	89 c2                	mov    %eax,%edx
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	eb 05                	jmp    801962 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801962:	89 d0                	mov    %edx,%eax
  801964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196f:	ba 00 00 00 00       	mov    $0x0,%edx
  801974:	b8 08 00 00 00       	mov    $0x8,%eax
  801979:	e8 a2 fd ff ff       	call   801720 <fsipc>
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801988:	83 ec 0c             	sub    $0xc,%esp
  80198b:	ff 75 08             	pushl  0x8(%ebp)
  80198e:	e8 ef f7 ff ff       	call   801182 <fd2data>
  801993:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801995:	83 c4 08             	add    $0x8,%esp
  801998:	68 5b 29 80 00       	push   $0x80295b
  80199d:	53                   	push   %ebx
  80199e:	e8 d2 ee ff ff       	call   800875 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a3:	8b 56 04             	mov    0x4(%esi),%edx
  8019a6:	89 d0                	mov    %edx,%eax
  8019a8:	2b 06                	sub    (%esi),%eax
  8019aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b7:	00 00 00 
	stat->st_dev = &devpipe;
  8019ba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c1:	30 80 00 
	return 0;
}
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019da:	53                   	push   %ebx
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 22 f3 ff ff       	call   800d04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e2:	89 1c 24             	mov    %ebx,(%esp)
  8019e5:	e8 98 f7 ff ff       	call   801182 <fd2data>
  8019ea:	83 c4 08             	add    $0x8,%esp
  8019ed:	50                   	push   %eax
  8019ee:	6a 00                	push   $0x0
  8019f0:	e8 0f f3 ff ff       	call   800d04 <sys_page_unmap>
}
  8019f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	57                   	push   %edi
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 1c             	sub    $0x1c,%esp
  801a03:	89 c7                	mov    %eax,%edi
  801a05:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a07:	a1 40 44 80 00       	mov    0x804440,%eax
  801a0c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	57                   	push   %edi
  801a13:	e8 1f 06 00 00       	call   802037 <pageref>
  801a18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a1b:	89 34 24             	mov    %esi,(%esp)
  801a1e:	e8 14 06 00 00       	call   802037 <pageref>
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a29:	0f 94 c0             	sete   %al
  801a2c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a2f:	8b 15 40 44 80 00    	mov    0x804440,%edx
  801a35:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a38:	39 cb                	cmp    %ecx,%ebx
  801a3a:	74 15                	je     801a51 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801a3c:	8b 52 58             	mov    0x58(%edx),%edx
  801a3f:	50                   	push   %eax
  801a40:	52                   	push   %edx
  801a41:	53                   	push   %ebx
  801a42:	68 68 29 80 00       	push   $0x802968
  801a47:	e8 a5 e8 ff ff       	call   8002f1 <cprintf>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	eb b6                	jmp    801a07 <_pipeisclosed+0xd>
	}
}
  801a51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5f                   	pop    %edi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	57                   	push   %edi
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 28             	sub    $0x28,%esp
  801a62:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a65:	56                   	push   %esi
  801a66:	e8 17 f7 ff ff       	call   801182 <fd2data>
  801a6b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	bf 00 00 00 00       	mov    $0x0,%edi
  801a75:	eb 4b                	jmp    801ac2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a77:	89 da                	mov    %ebx,%edx
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	e8 7a ff ff ff       	call   8019fa <_pipeisclosed>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	75 48                	jne    801acc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a84:	e8 d7 f1 ff ff       	call   800c60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a89:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8c:	8b 0b                	mov    (%ebx),%ecx
  801a8e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a91:	39 d0                	cmp    %edx,%eax
  801a93:	73 e2                	jae    801a77 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a98:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a9c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a9f:	89 c2                	mov    %eax,%edx
  801aa1:	c1 fa 1f             	sar    $0x1f,%edx
  801aa4:	89 d1                	mov    %edx,%ecx
  801aa6:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aac:	83 e2 1f             	and    $0x1f,%edx
  801aaf:	29 ca                	sub    %ecx,%edx
  801ab1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab9:	83 c0 01             	add    $0x1,%eax
  801abc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abf:	83 c7 01             	add    $0x1,%edi
  801ac2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac5:	75 c2                	jne    801a89 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aca:	eb 05                	jmp    801ad1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5f                   	pop    %edi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	57                   	push   %edi
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	83 ec 18             	sub    $0x18,%esp
  801ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae5:	57                   	push   %edi
  801ae6:	e8 97 f6 ff ff       	call   801182 <fd2data>
  801aeb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af5:	eb 3d                	jmp    801b34 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af7:	85 db                	test   %ebx,%ebx
  801af9:	74 04                	je     801aff <devpipe_read+0x26>
				return i;
  801afb:	89 d8                	mov    %ebx,%eax
  801afd:	eb 44                	jmp    801b43 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aff:	89 f2                	mov    %esi,%edx
  801b01:	89 f8                	mov    %edi,%eax
  801b03:	e8 f2 fe ff ff       	call   8019fa <_pipeisclosed>
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	75 32                	jne    801b3e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b0c:	e8 4f f1 ff ff       	call   800c60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b11:	8b 06                	mov    (%esi),%eax
  801b13:	3b 46 04             	cmp    0x4(%esi),%eax
  801b16:	74 df                	je     801af7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b18:	99                   	cltd   
  801b19:	c1 ea 1b             	shr    $0x1b,%edx
  801b1c:	01 d0                	add    %edx,%eax
  801b1e:	83 e0 1f             	and    $0x1f,%eax
  801b21:	29 d0                	sub    %edx,%eax
  801b23:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b2e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b31:	83 c3 01             	add    $0x1,%ebx
  801b34:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b37:	75 d8                	jne    801b11 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b39:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3c:	eb 05                	jmp    801b43 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	56                   	push   %esi
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	e8 3d f6 ff ff       	call   801199 <fd_alloc>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	89 c2                	mov    %eax,%edx
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 88 2c 01 00 00    	js     801c95 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	68 07 04 00 00       	push   $0x407
  801b71:	ff 75 f4             	pushl  -0xc(%ebp)
  801b74:	6a 00                	push   $0x0
  801b76:	e8 04 f1 ff ff       	call   800c7f <sys_page_alloc>
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	89 c2                	mov    %eax,%edx
  801b80:	85 c0                	test   %eax,%eax
  801b82:	0f 88 0d 01 00 00    	js     801c95 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8e:	50                   	push   %eax
  801b8f:	e8 05 f6 ff ff       	call   801199 <fd_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 88 e2 00 00 00    	js     801c83 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	68 07 04 00 00       	push   $0x407
  801ba9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bac:	6a 00                	push   $0x0
  801bae:	e8 cc f0 ff ff       	call   800c7f <sys_page_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 c3 00 00 00    	js     801c83 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	e8 b7 f5 ff ff       	call   801182 <fd2data>
  801bcb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcd:	83 c4 0c             	add    $0xc,%esp
  801bd0:	68 07 04 00 00       	push   $0x407
  801bd5:	50                   	push   %eax
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 a2 f0 ff ff       	call   800c7f <sys_page_alloc>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	0f 88 89 00 00 00    	js     801c73 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf0:	e8 8d f5 ff ff       	call   801182 <fd2data>
  801bf5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bfc:	50                   	push   %eax
  801bfd:	6a 00                	push   $0x0
  801bff:	56                   	push   %esi
  801c00:	6a 00                	push   $0x0
  801c02:	e8 bb f0 ff ff       	call   800cc2 <sys_page_map>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 20             	add    $0x20,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 55                	js     801c65 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c19:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c33:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	e8 2d f5 ff ff       	call   801172 <fd2num>
  801c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c48:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c4a:	83 c4 04             	add    $0x4,%esp
  801c4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c50:	e8 1d f5 ff ff       	call   801172 <fd2num>
  801c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c58:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c63:	eb 30                	jmp    801c95 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c65:	83 ec 08             	sub    $0x8,%esp
  801c68:	56                   	push   %esi
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 94 f0 ff ff       	call   800d04 <sys_page_unmap>
  801c70:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	ff 75 f0             	pushl  -0x10(%ebp)
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 84 f0 ff ff       	call   800d04 <sys_page_unmap>
  801c80:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	ff 75 f4             	pushl  -0xc(%ebp)
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 74 f0 ff ff       	call   800d04 <sys_page_unmap>
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c95:	89 d0                	mov    %edx,%eax
  801c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca7:	50                   	push   %eax
  801ca8:	ff 75 08             	pushl  0x8(%ebp)
  801cab:	e8 38 f5 ff ff       	call   8011e8 <fd_lookup>
  801cb0:	89 c2                	mov    %eax,%edx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 d2                	test   %edx,%edx
  801cb7:	78 18                	js     801cd1 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbf:	e8 be f4 ff ff       	call   801182 <fd2data>
	return _pipeisclosed(fd, p);
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	e8 2c fd ff ff       	call   8019fa <_pipeisclosed>
  801cce:	83 c4 10             	add    $0x10,%esp
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cdf:	85 f6                	test   %esi,%esi
  801ce1:	75 16                	jne    801cf9 <wait+0x26>
  801ce3:	68 99 29 80 00       	push   $0x802999
  801ce8:	68 2f 29 80 00       	push   $0x80292f
  801ced:	6a 09                	push   $0x9
  801cef:	68 a4 29 80 00       	push   $0x8029a4
  801cf4:	e8 1f e5 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801cf9:	89 f3                	mov    %esi,%ebx
  801cfb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d01:	6b db 78             	imul   $0x78,%ebx,%ebx
  801d04:	8d 7b 40             	lea    0x40(%ebx),%edi
  801d07:	83 c3 50             	add    $0x50,%ebx
  801d0a:	eb 05                	jmp    801d11 <wait+0x3e>
		sys_yield();
  801d0c:	e8 4f ef ff ff       	call   800c60 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d11:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  801d17:	39 f0                	cmp    %esi,%eax
  801d19:	75 0a                	jne    801d25 <wait+0x52>
  801d1b:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  801d21:	85 c0                	test   %eax,%eax
  801d23:	75 e7                	jne    801d0c <wait+0x39>
		sys_yield();
}
  801d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5f                   	pop    %edi
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d30:	b8 00 00 00 00       	mov    $0x0,%eax
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d3d:	68 af 29 80 00       	push   $0x8029af
  801d42:	ff 75 0c             	pushl  0xc(%ebp)
  801d45:	e8 2b eb ff ff       	call   800875 <strcpy>
	return 0;
}
  801d4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	57                   	push   %edi
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d62:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d68:	eb 2e                	jmp    801d98 <devcons_write+0x47>
		m = n - tot;
  801d6a:	8b 55 10             	mov    0x10(%ebp),%edx
  801d6d:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801d6f:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801d74:	83 fa 7f             	cmp    $0x7f,%edx
  801d77:	77 02                	ja     801d7b <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d79:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	56                   	push   %esi
  801d7f:	03 45 0c             	add    0xc(%ebp),%eax
  801d82:	50                   	push   %eax
  801d83:	57                   	push   %edi
  801d84:	e8 7e ec ff ff       	call   800a07 <memmove>
		sys_cputs(buf, m);
  801d89:	83 c4 08             	add    $0x8,%esp
  801d8c:	56                   	push   %esi
  801d8d:	57                   	push   %edi
  801d8e:	e8 30 ee ff ff       	call   800bc3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	01 f3                	add    %esi,%ebx
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d9d:	72 cb                	jb     801d6a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801db2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db6:	75 07                	jne    801dbf <devcons_read+0x18>
  801db8:	eb 28                	jmp    801de2 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dba:	e8 a1 ee ff ff       	call   800c60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dbf:	e8 1d ee ff ff       	call   800be1 <sys_cgetc>
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	74 f2                	je     801dba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 16                	js     801de2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dcc:	83 f8 04             	cmp    $0x4,%eax
  801dcf:	74 0c                	je     801ddd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	88 02                	mov    %al,(%edx)
	return 1;
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	eb 05                	jmp    801de2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ded:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df0:	6a 01                	push   $0x1
  801df2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	e8 c8 ed ff ff       	call   800bc3 <sys_cputs>
  801dfb:	83 c4 10             	add    $0x10,%esp
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <getchar>:

int
getchar(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e06:	6a 01                	push   $0x1
  801e08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 3e f6 ff ff       	call   801451 <read>
	if (r < 0)
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 0f                	js     801e29 <getchar+0x29>
		return r;
	if (r < 1)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	7e 06                	jle    801e24 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e22:	eb 05                	jmp    801e29 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e24:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 ab f3 ff ff       	call   8011e8 <fd_lookup>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 11                	js     801e55 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e47:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e4d:	39 10                	cmp    %edx,(%eax)
  801e4f:	0f 94 c0             	sete   %al
  801e52:	0f b6 c0             	movzbl %al,%eax
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <opencons>:

int
opencons(void)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	e8 33 f3 ff ff       	call   801199 <fd_alloc>
  801e66:	83 c4 10             	add    $0x10,%esp
		return r;
  801e69:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 3e                	js     801ead <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	68 07 04 00 00       	push   $0x407
  801e77:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 fe ed ff ff       	call   800c7f <sys_page_alloc>
  801e81:	83 c4 10             	add    $0x10,%esp
		return r;
  801e84:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 23                	js     801ead <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e93:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	50                   	push   %eax
  801ea3:	e8 ca f2 ff ff       	call   801172 <fd2num>
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	83 c4 10             	add    $0x10,%esp
}
  801ead:	89 d0                	mov    %edx,%eax
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801eb7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ebe:	75 2c                	jne    801eec <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	6a 07                	push   $0x7
  801ec5:	68 00 f0 7f ee       	push   $0xee7ff000
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 ae ed ff ff       	call   800c7f <sys_page_alloc>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	79 14                	jns    801eec <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	68 bc 29 80 00       	push   $0x8029bc
  801ee0:	6a 1f                	push   $0x1f
  801ee2:	68 20 2a 80 00       	push   $0x802a20
  801ee7:	e8 2c e3 ff ff       	call   800218 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ef4:	83 ec 08             	sub    $0x8,%esp
  801ef7:	68 20 1f 80 00       	push   $0x801f20
  801efc:	6a 00                	push   $0x0
  801efe:	e8 c7 ee ff ff       	call   800dca <sys_env_set_pgfault_upcall>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	79 14                	jns    801f1e <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	68 e8 29 80 00       	push   $0x8029e8
  801f12:	6a 25                	push   $0x25
  801f14:	68 20 2a 80 00       	push   $0x802a20
  801f19:	e8 fa e2 ff ff       	call   800218 <_panic>
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f21:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f28:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801f2b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801f2d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801f31:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801f35:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801f36:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801f39:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801f3b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801f3e:	83 c4 04             	add    $0x4,%esp
	popal 
  801f41:	61                   	popa   
	addl $4, %esp 
  801f42:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801f45:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801f46:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801f47:	c3                   	ret    

00801f48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f56:	85 f6                	test   %esi,%esi
  801f58:	74 06                	je     801f60 <ipc_recv+0x18>
  801f5a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 06                	je     801f6a <ipc_recv+0x22>
  801f64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801f6a:	83 f8 01             	cmp    $0x1,%eax
  801f6d:	19 d2                	sbb    %edx,%edx
  801f6f:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801f71:	83 ec 0c             	sub    $0xc,%esp
  801f74:	50                   	push   %eax
  801f75:	e8 b5 ee ff ff       	call   800e2f <sys_ipc_recv>
  801f7a:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 d2                	test   %edx,%edx
  801f81:	75 24                	jne    801fa7 <ipc_recv+0x5f>
	if (from_env_store)
  801f83:	85 f6                	test   %esi,%esi
  801f85:	74 0a                	je     801f91 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801f87:	a1 40 44 80 00       	mov    0x804440,%eax
  801f8c:	8b 40 70             	mov    0x70(%eax),%eax
  801f8f:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801f91:	85 db                	test   %ebx,%ebx
  801f93:	74 0a                	je     801f9f <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801f95:	a1 40 44 80 00       	mov    0x804440,%eax
  801f9a:	8b 40 74             	mov    0x74(%eax),%eax
  801f9d:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801f9f:	a1 40 44 80 00       	mov    0x804440,%eax
  801fa4:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801fa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801faa:	5b                   	pop    %ebx
  801fab:	5e                   	pop    %esi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 0c             	sub    $0xc,%esp
  801fb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801fc0:	83 fb 01             	cmp    $0x1,%ebx
  801fc3:	19 c0                	sbb    %eax,%eax
  801fc5:	09 c3                	or     %eax,%ebx
  801fc7:	eb 1c                	jmp    801fe5 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801fc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcc:	74 12                	je     801fe0 <ipc_send+0x32>
  801fce:	50                   	push   %eax
  801fcf:	68 2e 2a 80 00       	push   $0x802a2e
  801fd4:	6a 36                	push   $0x36
  801fd6:	68 45 2a 80 00       	push   $0x802a45
  801fdb:	e8 38 e2 ff ff       	call   800218 <_panic>
		sys_yield();
  801fe0:	e8 7b ec ff ff       	call   800c60 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fe5:	ff 75 14             	pushl  0x14(%ebp)
  801fe8:	53                   	push   %ebx
  801fe9:	56                   	push   %esi
  801fea:	57                   	push   %edi
  801feb:	e8 1c ee ff ff       	call   800e0c <sys_ipc_try_send>
		if (ret == 0) break;
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	75 d2                	jne    801fc9 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5e                   	pop    %esi
  801ffc:	5f                   	pop    %edi
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80200a:	6b d0 78             	imul   $0x78,%eax,%edx
  80200d:	83 c2 50             	add    $0x50,%edx
  802010:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802016:	39 ca                	cmp    %ecx,%edx
  802018:	75 0d                	jne    802027 <ipc_find_env+0x28>
			return envs[i].env_id;
  80201a:	6b c0 78             	imul   $0x78,%eax,%eax
  80201d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802022:	8b 40 08             	mov    0x8(%eax),%eax
  802025:	eb 0e                	jmp    802035 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802027:	83 c0 01             	add    $0x1,%eax
  80202a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202f:	75 d9                	jne    80200a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802031:	66 b8 00 00          	mov    $0x0,%ax
}
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203d:	89 d0                	mov    %edx,%eax
  80203f:	c1 e8 16             	shr    $0x16,%eax
  802042:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802049:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204e:	f6 c1 01             	test   $0x1,%cl
  802051:	74 1d                	je     802070 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802053:	c1 ea 0c             	shr    $0xc,%edx
  802056:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205d:	f6 c2 01             	test   $0x1,%dl
  802060:	74 0e                	je     802070 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802062:	c1 ea 0c             	shr    $0xc,%edx
  802065:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80206c:	ef 
  80206d:	0f b7 c0             	movzwl %ax,%eax
}
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	83 ec 10             	sub    $0x10,%esp
  802086:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80208a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80208e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802092:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802096:	85 d2                	test   %edx,%edx
  802098:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209c:	89 34 24             	mov    %esi,(%esp)
  80209f:	89 c8                	mov    %ecx,%eax
  8020a1:	75 35                	jne    8020d8 <__udivdi3+0x58>
  8020a3:	39 f1                	cmp    %esi,%ecx
  8020a5:	0f 87 bd 00 00 00    	ja     802168 <__udivdi3+0xe8>
  8020ab:	85 c9                	test   %ecx,%ecx
  8020ad:	89 cd                	mov    %ecx,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f1                	div    %ecx
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c6                	mov    %eax,%esi
  8020c4:	89 f8                	mov    %edi,%eax
  8020c6:	f7 f5                	div    %ebp
  8020c8:	89 f2                	mov    %esi,%edx
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    
  8020d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	3b 14 24             	cmp    (%esp),%edx
  8020db:	77 7b                	ja     802158 <__udivdi3+0xd8>
  8020dd:	0f bd f2             	bsr    %edx,%esi
  8020e0:	83 f6 1f             	xor    $0x1f,%esi
  8020e3:	0f 84 97 00 00 00    	je     802180 <__udivdi3+0x100>
  8020e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ee:	89 d7                	mov    %edx,%edi
  8020f0:	89 f1                	mov    %esi,%ecx
  8020f2:	29 f5                	sub    %esi,%ebp
  8020f4:	d3 e7                	shl    %cl,%edi
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	d3 ea                	shr    %cl,%edx
  8020fc:	89 f1                	mov    %esi,%ecx
  8020fe:	09 fa                	or     %edi,%edx
  802100:	8b 3c 24             	mov    (%esp),%edi
  802103:	d3 e0                	shl    %cl,%eax
  802105:	89 54 24 08          	mov    %edx,0x8(%esp)
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802113:	89 fa                	mov    %edi,%edx
  802115:	d3 ea                	shr    %cl,%edx
  802117:	89 f1                	mov    %esi,%ecx
  802119:	d3 e7                	shl    %cl,%edi
  80211b:	89 e9                	mov    %ebp,%ecx
  80211d:	d3 e8                	shr    %cl,%eax
  80211f:	09 c7                	or     %eax,%edi
  802121:	89 f8                	mov    %edi,%eax
  802123:	f7 74 24 08          	divl   0x8(%esp)
  802127:	89 d5                	mov    %edx,%ebp
  802129:	89 c7                	mov    %eax,%edi
  80212b:	f7 64 24 0c          	mull   0xc(%esp)
  80212f:	39 d5                	cmp    %edx,%ebp
  802131:	89 14 24             	mov    %edx,(%esp)
  802134:	72 11                	jb     802147 <__udivdi3+0xc7>
  802136:	8b 54 24 04          	mov    0x4(%esp),%edx
  80213a:	89 f1                	mov    %esi,%ecx
  80213c:	d3 e2                	shl    %cl,%edx
  80213e:	39 c2                	cmp    %eax,%edx
  802140:	73 5e                	jae    8021a0 <__udivdi3+0x120>
  802142:	3b 2c 24             	cmp    (%esp),%ebp
  802145:	75 59                	jne    8021a0 <__udivdi3+0x120>
  802147:	8d 47 ff             	lea    -0x1(%edi),%eax
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	31 f6                	xor    %esi,%esi
  80215a:	31 c0                	xor    %eax,%eax
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	89 f2                	mov    %esi,%edx
  80216a:	31 f6                	xor    %esi,%esi
  80216c:	89 f8                	mov    %edi,%eax
  80216e:	f7 f1                	div    %ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802184:	76 0b                	jbe    802191 <__udivdi3+0x111>
  802186:	31 c0                	xor    %eax,%eax
  802188:	3b 14 24             	cmp    (%esp),%edx
  80218b:	0f 83 37 ff ff ff    	jae    8020c8 <__udivdi3+0x48>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	e9 2d ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  80219b:	90                   	nop
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	31 f6                	xor    %esi,%esi
  8021a4:	e9 1f ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  8021a9:	66 90                	xchg   %ax,%ax
  8021ab:	66 90                	xchg   %ax,%ax
  8021ad:	66 90                	xchg   %ax,%ax
  8021af:	90                   	nop

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	83 ec 20             	sub    $0x20,%esp
  8021b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c2:	89 c6                	mov    %eax,%esi
  8021c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	75 1e                	jne    802200 <__umoddi3+0x50>
  8021e2:	39 f7                	cmp    %esi,%edi
  8021e4:	76 52                	jbe    802238 <__umoddi3+0x88>
  8021e6:	89 c8                	mov    %ecx,%eax
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	f7 f7                	div    %edi
  8021ec:	89 d0                	mov    %edx,%eax
  8021ee:	31 d2                	xor    %edx,%edx
  8021f0:	83 c4 20             	add    $0x20,%esp
  8021f3:	5e                   	pop    %esi
  8021f4:	5f                   	pop    %edi
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    
  8021f7:	89 f6                	mov    %esi,%esi
  8021f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802200:	39 f0                	cmp    %esi,%eax
  802202:	77 5c                	ja     802260 <__umoddi3+0xb0>
  802204:	0f bd e8             	bsr    %eax,%ebp
  802207:	83 f5 1f             	xor    $0x1f,%ebp
  80220a:	75 64                	jne    802270 <__umoddi3+0xc0>
  80220c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802210:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802214:	0f 86 f6 00 00 00    	jbe    802310 <__umoddi3+0x160>
  80221a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80221e:	0f 82 ec 00 00 00    	jb     802310 <__umoddi3+0x160>
  802224:	8b 44 24 14          	mov    0x14(%esp),%eax
  802228:	8b 54 24 18          	mov    0x18(%esp),%edx
  80222c:	83 c4 20             	add    $0x20,%esp
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    
  802233:	90                   	nop
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	85 ff                	test   %edi,%edi
  80223a:	89 fd                	mov    %edi,%ebp
  80223c:	75 0b                	jne    802249 <__umoddi3+0x99>
  80223e:	b8 01 00 00 00       	mov    $0x1,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f7                	div    %edi
  802247:	89 c5                	mov    %eax,%ebp
  802249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	f7 f5                	div    %ebp
  802251:	89 c8                	mov    %ecx,%eax
  802253:	f7 f5                	div    %ebp
  802255:	eb 95                	jmp    8021ec <__umoddi3+0x3c>
  802257:	89 f6                	mov    %esi,%esi
  802259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 20             	add    $0x20,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	b8 20 00 00 00       	mov    $0x20,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	29 e8                	sub    %ebp,%eax
  802279:	d3 e2                	shl    %cl,%edx
  80227b:	89 c7                	mov    %eax,%edi
  80227d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 c1                	mov    %eax,%ecx
  80228b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80228f:	09 d1                	or     %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802297:	89 e9                	mov    %ebp,%ecx
  802299:	d3 e0                	shl    %cl,%eax
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	89 c7                	mov    %eax,%edi
  8022a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022ad:	d3 e6                	shl    %cl,%esi
  8022af:	89 d1                	mov    %edx,%ecx
  8022b1:	89 fa                	mov    %edi,%edx
  8022b3:	d3 e8                	shr    %cl,%eax
  8022b5:	89 e9                	mov    %ebp,%ecx
  8022b7:	09 f0                	or     %esi,%eax
  8022b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022bd:	f7 74 24 10          	divl   0x10(%esp)
  8022c1:	d3 e6                	shl    %cl,%esi
  8022c3:	89 d1                	mov    %edx,%ecx
  8022c5:	f7 64 24 0c          	mull   0xc(%esp)
  8022c9:	39 d1                	cmp    %edx,%ecx
  8022cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022cf:	89 d7                	mov    %edx,%edi
  8022d1:	89 c6                	mov    %eax,%esi
  8022d3:	72 0a                	jb     8022df <__umoddi3+0x12f>
  8022d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022d9:	73 10                	jae    8022eb <__umoddi3+0x13b>
  8022db:	39 d1                	cmp    %edx,%ecx
  8022dd:	75 0c                	jne    8022eb <__umoddi3+0x13b>
  8022df:	89 d7                	mov    %edx,%edi
  8022e1:	89 c6                	mov    %eax,%esi
  8022e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022eb:	89 ca                	mov    %ecx,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022f3:	29 f0                	sub    %esi,%eax
  8022f5:	19 fa                	sbb    %edi,%edx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022fe:	89 d7                	mov    %edx,%edi
  802300:	d3 e7                	shl    %cl,%edi
  802302:	89 e9                	mov    %ebp,%ecx
  802304:	09 f8                	or     %edi,%eax
  802306:	d3 ea                	shr    %cl,%edx
  802308:	83 c4 20             	add    $0x20,%esp
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    
  80230f:	90                   	nop
  802310:	8b 74 24 10          	mov    0x10(%esp),%esi
  802314:	29 f9                	sub    %edi,%ecx
  802316:	19 c6                	sbb    %eax,%esi
  802318:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80231c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802320:	e9 ff fe ff ff       	jmp    802224 <__umoddi3+0x74>
