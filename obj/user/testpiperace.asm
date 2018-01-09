
obj/user/testpiperace:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 51 1c 00 00       	call   801ca1 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %i", r);
  800057:	50                   	push   %eax
  800058:	68 19 23 80 00       	push   $0x802319
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 23 80 00       	push   $0x802322
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 47 0f 00 00       	call   800fb5 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %i", r);
  800074:	50                   	push   %eax
  800075:	68 d9 27 80 00       	push   $0x8027d9
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 23 80 00       	push   $0x802322
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 97 13 00 00       	call   80142c <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 4c 1d 00 00       	call   801df4 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 36 23 80 00       	push   $0x802336
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 c3 0b 00 00       	call   800c8c <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 c2 10 00 00       	call   80119e <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 51 23 80 00       	push   $0x802351
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 78             	imul   $0x78,%esi,%eax
  8000f9:	c1 f8 03             	sar    $0x3,%eax
  8000fc:	69 c0 ef ee ee ee    	imul   $0xeeeeeeef,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 5c 23 80 00       	push   $0x80235c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 64 13 00 00       	call   80147e <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 78             	imul   $0x78,%esi,%ebx
  800120:	83 c3 50             	add    $0x50,%ebx
  800123:	eb 10                	jmp    800135 <umain+0x102>
		dup(p[0], 10);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	6a 0a                	push   $0xa
  80012a:	ff 75 f0             	pushl  -0x10(%ebp)
  80012d:	e8 4c 13 00 00       	call   80147e <dup>
  800132:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800135:	8b 93 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e5                	je     800125 <umain+0xf2>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 67 23 80 00       	push   $0x802367
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 9c 1c 00 00       	call   801df4 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 ac 23 80 00       	push   $0x8023ac
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 23 80 00       	push   $0x802322
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 81 11 00 00       	call   801303 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %i", r);
  800189:	50                   	push   %eax
  80018a:	68 7d 23 80 00       	push   $0x80237d
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 23 80 00       	push   $0x802322
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 f7 10 00 00       	call   80129d <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 ed 18 00 00       	call   801a9b <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 95 23 80 00       	push   $0x802395
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen (number of tests: %d)\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 d8 23 80 00       	push   $0x8023d8
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001ef:	e8 79 0a 00 00       	call   800c6d <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 78             	imul   $0x78,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
  800220:	83 c4 10             	add    $0x10,%esp
#endif
}
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 24 12 00 00       	call   801459 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 ed 09 00 00       	call   800c2c <sys_env_destroy>
  80023f:	83 c4 10             	add    $0x10,%esp
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 16 0a 00 00       	call   800c6d <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 10 24 80 00       	push   $0x802410
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 35 09 00 00       	call   800bef <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 4f 01 00 00       	call   80044f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 da 08 00 00       	call   800bef <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 d1                	mov    %edx,%ecx
  800346:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800349:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80034c:	8b 45 10             	mov    0x10(%ebp),%eax
  80034f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800352:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800355:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80035f:	72 05                	jb     800366 <printnum+0x35>
  800361:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800364:	77 3e                	ja     8003a4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800366:	83 ec 0c             	sub    $0xc,%esp
  800369:	ff 75 18             	pushl  0x18(%ebp)
  80036c:	83 eb 01             	sub    $0x1,%ebx
  80036f:	53                   	push   %ebx
  800370:	50                   	push   %eax
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 cb 1c 00 00       	call   802050 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 13                	jmp    8003ab <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a4:	83 eb 01             	sub    $0x1,%ebx
  8003a7:	85 db                	test   %ebx,%ebx
  8003a9:	7f ed                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	56                   	push   %esi
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003be:	e8 bd 1d 00 00       	call   802180 <__umoddi3>
  8003c3:	83 c4 14             	add    $0x14,%esp
  8003c6:	0f be 80 33 24 80 00 	movsbl 0x802433(%eax),%eax
  8003cd:	50                   	push   %eax
  8003ce:	ff d7                	call   *%edi
  8003d0:	83 c4 10             	add    $0x10,%esp
}
  8003d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d6:	5b                   	pop    %ebx
  8003d7:	5e                   	pop    %esi
  8003d8:	5f                   	pop    %edi
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003de:	83 fa 01             	cmp    $0x1,%edx
  8003e1:	7e 0e                	jle    8003f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e3:	8b 10                	mov    (%eax),%edx
  8003e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e8:	89 08                	mov    %ecx,(%eax)
  8003ea:	8b 02                	mov    (%edx),%eax
  8003ec:	8b 52 04             	mov    0x4(%edx),%edx
  8003ef:	eb 22                	jmp    800413 <getuint+0x38>
	else if (lflag)
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	74 10                	je     800405 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800403:	eb 0e                	jmp    800413 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800405:	8b 10                	mov    (%eax),%edx
  800407:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 02                	mov    (%edx),%eax
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	3b 50 04             	cmp    0x4(%eax),%edx
  800424:	73 0a                	jae    800430 <sprintputch+0x1b>
		*b->buf++ = ch;
  800426:	8d 4a 01             	lea    0x1(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	88 02                	mov    %al,(%edx)
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800438:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043b:	50                   	push   %eax
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	ff 75 0c             	pushl  0xc(%ebp)
  800442:	ff 75 08             	pushl  0x8(%ebp)
  800445:	e8 05 00 00 00       	call   80044f <vprintfmt>
	va_end(ap);
  80044a:	83 c4 10             	add    $0x10,%esp
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	57                   	push   %edi
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 2c             	sub    $0x2c,%esp
  800458:	8b 75 08             	mov    0x8(%ebp),%esi
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800461:	eb 12                	jmp    800475 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800463:	85 c0                	test   %eax,%eax
  800465:	0f 84 8d 03 00 00    	je     8007f8 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	50                   	push   %eax
  800470:	ff d6                	call   *%esi
  800472:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800475:	83 c7 01             	add    $0x1,%edi
  800478:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047c:	83 f8 25             	cmp    $0x25,%eax
  80047f:	75 e2                	jne    800463 <vprintfmt+0x14>
  800481:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800485:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800493:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049a:	ba 00 00 00 00       	mov    $0x0,%edx
  80049f:	eb 07                	jmp    8004a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8d 47 01             	lea    0x1(%edi),%eax
  8004ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ae:	0f b6 07             	movzbl (%edi),%eax
  8004b1:	0f b6 c8             	movzbl %al,%ecx
  8004b4:	83 e8 23             	sub    $0x23,%eax
  8004b7:	3c 55                	cmp    $0x55,%al
  8004b9:	0f 87 1e 03 00 00    	ja     8007dd <vprintfmt+0x38e>
  8004bf:	0f b6 c0             	movzbl %al,%eax
  8004c2:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d0:	eb d6                	jmp    8004a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ea:	83 fa 09             	cmp    $0x9,%edx
  8004ed:	77 38                	ja     800527 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f2:	eb e9                	jmp    8004dd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800505:	eb 26                	jmp    80052d <vprintfmt+0xde>
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	89 c8                	mov    %ecx,%eax
  80050c:	c1 f8 1f             	sar    $0x1f,%eax
  80050f:	f7 d0                	not    %eax
  800511:	21 c1                	and    %eax,%ecx
  800513:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	eb 8d                	jmp    8004a8 <vprintfmt+0x59>
  80051b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800525:	eb 81                	jmp    8004a8 <vprintfmt+0x59>
  800527:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800531:	0f 89 71 ff ff ff    	jns    8004a8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800537:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80053a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800544:	e9 5f ff ff ff       	jmp    8004a8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800549:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054f:	e9 54 ff ff ff       	jmp    8004a8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	ff 30                	pushl  (%eax)
  800563:	ff d6                	call   *%esi
			break;
  800565:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056b:	e9 05 ff ff ff       	jmp    800475 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	99                   	cltd   
  80057c:	31 d0                	xor    %edx,%eax
  80057e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 f8 0f             	cmp    $0xf,%eax
  800583:	7f 0b                	jg     800590 <vprintfmt+0x141>
  800585:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	75 18                	jne    8005a8 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800590:	50                   	push   %eax
  800591:	68 4b 24 80 00       	push   $0x80244b
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 95 fe ff ff       	call   800432 <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a3:	e9 cd fe ff ff       	jmp    800475 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a8:	52                   	push   %edx
  8005a9:	68 e1 28 80 00       	push   $0x8028e1
  8005ae:	53                   	push   %ebx
  8005af:	56                   	push   %esi
  8005b0:	e8 7d fe ff ff       	call   800432 <printfmt>
  8005b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 b5 fe ff ff       	jmp    800475 <vprintfmt+0x26>
  8005c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 38                	mov    (%eax),%edi
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	75 05                	jne    8005dd <vprintfmt+0x18e>
				p = "(null)";
  8005d8:	bf 44 24 80 00       	mov    $0x802444,%edi
			if (width > 0 && padc != '-')
  8005dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e1:	0f 84 91 00 00 00    	je     800678 <vprintfmt+0x229>
  8005e7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005eb:	0f 8e 95 00 00 00    	jle    800686 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	51                   	push   %ecx
  8005f5:	57                   	push   %edi
  8005f6:	e8 85 02 00 00       	call   800880 <strnlen>
  8005fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c5>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	89 c8                	mov    %ecx,%eax
  80062f:	c1 f8 1f             	sar    $0x1f,%eax
  800632:	f7 d0                	not    %eax
  800634:	21 c8                	and    %ecx,%eax
  800636:	29 c1                	sub    %eax,%ecx
  800638:	89 75 08             	mov    %esi,0x8(%ebp)
  80063b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800641:	89 cb                	mov    %ecx,%ebx
  800643:	eb 4d                	jmp    800692 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800645:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800649:	74 1b                	je     800666 <vprintfmt+0x217>
  80064b:	0f be c0             	movsbl %al,%eax
  80064e:	83 e8 20             	sub    $0x20,%eax
  800651:	83 f8 5e             	cmp    $0x5e,%eax
  800654:	76 10                	jbe    800666 <vprintfmt+0x217>
					putch('?', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	ff 75 0c             	pushl  0xc(%ebp)
  80065c:	6a 3f                	push   $0x3f
  80065e:	ff 55 08             	call   *0x8(%ebp)
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb 0d                	jmp    800673 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	ff 75 0c             	pushl  0xc(%ebp)
  80066c:	52                   	push   %edx
  80066d:	ff 55 08             	call   *0x8(%ebp)
  800670:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800673:	83 eb 01             	sub    $0x1,%ebx
  800676:	eb 1a                	jmp    800692 <vprintfmt+0x243>
  800678:	89 75 08             	mov    %esi,0x8(%ebp)
  80067b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800681:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800684:	eb 0c                	jmp    800692 <vprintfmt+0x243>
  800686:	89 75 08             	mov    %esi,0x8(%ebp)
  800689:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800692:	83 c7 01             	add    $0x1,%edi
  800695:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800699:	0f be d0             	movsbl %al,%edx
  80069c:	85 d2                	test   %edx,%edx
  80069e:	74 23                	je     8006c3 <vprintfmt+0x274>
  8006a0:	85 f6                	test   %esi,%esi
  8006a2:	78 a1                	js     800645 <vprintfmt+0x1f6>
  8006a4:	83 ee 01             	sub    $0x1,%esi
  8006a7:	79 9c                	jns    800645 <vprintfmt+0x1f6>
  8006a9:	89 df                	mov    %ebx,%edi
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b1:	eb 18                	jmp    8006cb <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 20                	push   $0x20
  8006b9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bb:	83 ef 01             	sub    $0x1,%edi
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 08                	jmp    8006cb <vprintfmt+0x27c>
  8006c3:	89 df                	mov    %ebx,%edi
  8006c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cb:	85 ff                	test   %edi,%edi
  8006cd:	7f e4                	jg     8006b3 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d2:	e9 9e fd ff ff       	jmp    800475 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d7:	83 fa 01             	cmp    $0x1,%edx
  8006da:	7e 16                	jle    8006f2 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 08             	lea    0x8(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 50 04             	mov    0x4(%eax),%edx
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f0:	eb 32                	jmp    800724 <vprintfmt+0x2d5>
	else if (lflag)
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	74 18                	je     80070e <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800704:	89 c1                	mov    %eax,%ecx
  800706:	c1 f9 1f             	sar    $0x1f,%ecx
  800709:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070c:	eb 16                	jmp    800724 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)
  800717:	8b 00                	mov    (%eax),%eax
  800719:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071c:	89 c1                	mov    %eax,%ecx
  80071e:	c1 f9 1f             	sar    $0x1f,%ecx
  800721:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800724:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800727:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800733:	79 74                	jns    8007a9 <vprintfmt+0x35a>
				putch('-', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	6a 2d                	push   $0x2d
  80073b:	ff d6                	call   *%esi
				num = -(long long) num;
  80073d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800740:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800743:	f7 d8                	neg    %eax
  800745:	83 d2 00             	adc    $0x0,%edx
  800748:	f7 da                	neg    %edx
  80074a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800752:	eb 55                	jmp    8007a9 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 7f fc ff ff       	call   8003db <getuint>
			base = 10;
  80075c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800761:	eb 46                	jmp    8007a9 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 70 fc ff ff       	call   8003db <getuint>
			base = 8;
  80076b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800770:	eb 37                	jmp    8007a9 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 30                	push   $0x30
  800778:	ff d6                	call   *%esi
			putch('x', putdat);
  80077a:	83 c4 08             	add    $0x8,%esp
  80077d:	53                   	push   %ebx
  80077e:	6a 78                	push   $0x78
  800780:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800792:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800795:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079a:	eb 0d                	jmp    8007a9 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
  80079f:	e8 37 fc ff ff       	call   8003db <getuint>
			base = 16;
  8007a4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a9:	83 ec 0c             	sub    $0xc,%esp
  8007ac:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b0:	57                   	push   %edi
  8007b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b4:	51                   	push   %ecx
  8007b5:	52                   	push   %edx
  8007b6:	50                   	push   %eax
  8007b7:	89 da                	mov    %ebx,%edx
  8007b9:	89 f0                	mov    %esi,%eax
  8007bb:	e8 71 fb ff ff       	call   800331 <printnum>
			break;
  8007c0:	83 c4 20             	add    $0x20,%esp
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c6:	e9 aa fc ff ff       	jmp    800475 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	51                   	push   %ecx
  8007d0:	ff d6                	call   *%esi
			break;
  8007d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d8:	e9 98 fc ff ff       	jmp    800475 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 25                	push   $0x25
  8007e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <vprintfmt+0x39e>
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f1:	75 f7                	jne    8007ea <vprintfmt+0x39b>
  8007f3:	e9 7d fc ff ff       	jmp    800475 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 26                	je     800847 <vsnprintf+0x47>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 22                	jle    800847 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	pushl  0x14(%ebp)
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	68 15 04 80 00       	push   $0x800415
  800834:	e8 16 fc ff ff       	call   80044f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800839:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	eb 05                	jmp    80084c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800857:	50                   	push   %eax
  800858:	ff 75 10             	pushl  0x10(%ebp)
  80085b:	ff 75 0c             	pushl  0xc(%ebp)
  80085e:	ff 75 08             	pushl  0x8(%ebp)
  800861:	e8 9a ff ff ff       	call   800800 <vsnprintf>
	va_end(ap);

	return rc;
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	eb 03                	jmp    800878 <strlen+0x10>
		n++;
  800875:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800878:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087c:	75 f7                	jne    800875 <strlen+0xd>
		n++;
	return n;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
  80088e:	eb 03                	jmp    800893 <strnlen+0x13>
		n++;
  800890:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 08                	je     80089f <strnlen+0x1f>
  800897:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089b:	75 f3                	jne    800890 <strnlen+0x10>
  80089d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ba:	84 db                	test   %bl,%bl
  8008bc:	75 ef                	jne    8008ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c8:	53                   	push   %ebx
  8008c9:	e8 9a ff ff ff       	call   800868 <strlen>
  8008ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	50                   	push   %eax
  8008d7:	e8 c5 ff ff ff       	call   8008a1 <strcpy>
	return dst;
}
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	89 f3                	mov    %esi,%ebx
  8008f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f3:	89 f2                	mov    %esi,%edx
  8008f5:	eb 0f                	jmp    800906 <strncpy+0x23>
		*dst++ = *src;
  8008f7:	83 c2 01             	add    $0x1,%edx
  8008fa:	0f b6 01             	movzbl (%ecx),%eax
  8008fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800900:	80 39 01             	cmpb   $0x1,(%ecx)
  800903:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800906:	39 da                	cmp    %ebx,%edx
  800908:	75 ed                	jne    8008f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090a:	89 f0                	mov    %esi,%eax
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 75 08             	mov    0x8(%ebp),%esi
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	8b 55 10             	mov    0x10(%ebp),%edx
  80091e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800920:	85 d2                	test   %edx,%edx
  800922:	74 21                	je     800945 <strlcpy+0x35>
  800924:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800928:	89 f2                	mov    %esi,%edx
  80092a:	eb 09                	jmp    800935 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800935:	39 c2                	cmp    %eax,%edx
  800937:	74 09                	je     800942 <strlcpy+0x32>
  800939:	0f b6 19             	movzbl (%ecx),%ebx
  80093c:	84 db                	test   %bl,%bl
  80093e:	75 ec                	jne    80092c <strlcpy+0x1c>
  800940:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800942:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800945:	29 f0                	sub    %esi,%eax
}
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800954:	eb 06                	jmp    80095c <strcmp+0x11>
		p++, q++;
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	84 c0                	test   %al,%al
  800961:	74 04                	je     800967 <strcmp+0x1c>
  800963:	3a 02                	cmp    (%edx),%al
  800965:	74 ef                	je     800956 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800967:	0f b6 c0             	movzbl %al,%eax
  80096a:	0f b6 12             	movzbl (%edx),%edx
  80096d:	29 d0                	sub    %edx,%eax
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 c3                	mov    %eax,%ebx
  80097d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800980:	eb 06                	jmp    800988 <strncmp+0x17>
		n--, p++, q++;
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800988:	39 d8                	cmp    %ebx,%eax
  80098a:	74 15                	je     8009a1 <strncmp+0x30>
  80098c:	0f b6 08             	movzbl (%eax),%ecx
  80098f:	84 c9                	test   %cl,%cl
  800991:	74 04                	je     800997 <strncmp+0x26>
  800993:	3a 0a                	cmp    (%edx),%cl
  800995:	74 eb                	je     800982 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	0f b6 00             	movzbl (%eax),%eax
  80099a:	0f b6 12             	movzbl (%edx),%edx
  80099d:	29 d0                	sub    %edx,%eax
  80099f:	eb 05                	jmp    8009a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b3:	eb 07                	jmp    8009bc <strchr+0x13>
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 0f                	je     8009c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	0f b6 10             	movzbl (%eax),%edx
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	75 f2                	jne    8009b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 03                	jmp    8009d9 <strfind+0xf>
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 04                	je     8009e4 <strfind+0x1a>
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	75 f2                	jne    8009d6 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8009f2:	85 c9                	test   %ecx,%ecx
  8009f4:	74 36                	je     800a2c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fc:	75 28                	jne    800a26 <memset+0x40>
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 23                	jne    800a26 <memset+0x40>
		c &= 0xFF;
  800a03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a07:	89 d3                	mov    %edx,%ebx
  800a09:	c1 e3 08             	shl    $0x8,%ebx
  800a0c:	89 d6                	mov    %edx,%esi
  800a0e:	c1 e6 18             	shl    $0x18,%esi
  800a11:	89 d0                	mov    %edx,%eax
  800a13:	c1 e0 10             	shl    $0x10,%eax
  800a16:	09 f0                	or     %esi,%eax
  800a18:	09 c2                	or     %eax,%edx
  800a1a:	89 d0                	mov    %edx,%eax
  800a1c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a21:	fc                   	cld    
  800a22:	f3 ab                	rep stos %eax,%es:(%edi)
  800a24:	eb 06                	jmp    800a2c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a29:	fc                   	cld    
  800a2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2c:	89 f8                	mov    %edi,%eax
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a41:	39 c6                	cmp    %eax,%esi
  800a43:	73 35                	jae    800a7a <memmove+0x47>
  800a45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	73 2e                	jae    800a7a <memmove+0x47>
		s += n;
		d += n;
  800a4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a59:	75 13                	jne    800a6e <memmove+0x3b>
  800a5b:	f6 c1 03             	test   $0x3,%cl
  800a5e:	75 0e                	jne    800a6e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a60:	83 ef 04             	sub    $0x4,%edi
  800a63:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a66:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a69:	fd                   	std    
  800a6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6c:	eb 09                	jmp    800a77 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6e:	83 ef 01             	sub    $0x1,%edi
  800a71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a74:	fd                   	std    
  800a75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a77:	fc                   	cld    
  800a78:	eb 1d                	jmp    800a97 <memmove+0x64>
  800a7a:	89 f2                	mov    %esi,%edx
  800a7c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7e:	f6 c2 03             	test   $0x3,%dl
  800a81:	75 0f                	jne    800a92 <memmove+0x5f>
  800a83:	f6 c1 03             	test   $0x3,%cl
  800a86:	75 0a                	jne    800a92 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a88:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	fc                   	cld    
  800a8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a90:	eb 05                	jmp    800a97 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a92:	89 c7                	mov    %eax,%edi
  800a94:	fc                   	cld    
  800a95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9e:	ff 75 10             	pushl  0x10(%ebp)
  800aa1:	ff 75 0c             	pushl  0xc(%ebp)
  800aa4:	ff 75 08             	pushl  0x8(%ebp)
  800aa7:	e8 87 ff ff ff       	call   800a33 <memmove>
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abe:	eb 1a                	jmp    800ada <memcmp+0x2c>
		if (*s1 != *s2)
  800ac0:	0f b6 08             	movzbl (%eax),%ecx
  800ac3:	0f b6 1a             	movzbl (%edx),%ebx
  800ac6:	38 d9                	cmp    %bl,%cl
  800ac8:	74 0a                	je     800ad4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aca:	0f b6 c1             	movzbl %cl,%eax
  800acd:	0f b6 db             	movzbl %bl,%ebx
  800ad0:	29 d8                	sub    %ebx,%eax
  800ad2:	eb 0f                	jmp    800ae3 <memcmp+0x35>
		s1++, s2++;
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ada:	39 f0                	cmp    %esi,%eax
  800adc:	75 e2                	jne    800ac0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af5:	eb 07                	jmp    800afe <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af7:	38 08                	cmp    %cl,(%eax)
  800af9:	74 07                	je     800b02 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	39 d0                	cmp    %edx,%eax
  800b00:	72 f5                	jb     800af7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b10:	eb 03                	jmp    800b15 <strtol+0x11>
		s++;
  800b12:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b15:	0f b6 01             	movzbl (%ecx),%eax
  800b18:	3c 09                	cmp    $0x9,%al
  800b1a:	74 f6                	je     800b12 <strtol+0xe>
  800b1c:	3c 20                	cmp    $0x20,%al
  800b1e:	74 f2                	je     800b12 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b20:	3c 2b                	cmp    $0x2b,%al
  800b22:	75 0a                	jne    800b2e <strtol+0x2a>
		s++;
  800b24:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2c:	eb 10                	jmp    800b3e <strtol+0x3a>
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b33:	3c 2d                	cmp    $0x2d,%al
  800b35:	75 07                	jne    800b3e <strtol+0x3a>
		s++, neg = 1;
  800b37:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b3a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	0f 94 c0             	sete   %al
  800b43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b49:	75 19                	jne    800b64 <strtol+0x60>
  800b4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4e:	75 14                	jne    800b64 <strtol+0x60>
  800b50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b54:	0f 85 8a 00 00 00    	jne    800be4 <strtol+0xe0>
		s += 2, base = 16;
  800b5a:	83 c1 02             	add    $0x2,%ecx
  800b5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b62:	eb 16                	jmp    800b7a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b64:	84 c0                	test   %al,%al
  800b66:	74 12                	je     800b7a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	75 08                	jne    800b7a <strtol+0x76>
		s++, base = 8;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b82:	0f b6 11             	movzbl (%ecx),%edx
  800b85:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 09             	cmp    $0x9,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0x93>
			dig = *s - '0';
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 30             	sub    $0x30,%edx
  800b95:	eb 22                	jmp    800bb9 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 57             	sub    $0x57,%edx
  800ba7:	eb 10                	jmp    800bb9 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ba9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 16                	ja     800bc9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 0f                	jge    800bcd <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc7:	eb b9                	jmp    800b82 <strtol+0x7e>
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	eb 02                	jmp    800bcf <strtol+0xcb>
  800bcd:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xd6>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bda:	85 ff                	test   %edi,%edi
  800bdc:	74 0c                	je     800bea <strtol+0xe6>
  800bde:	89 d0                	mov    %edx,%eax
  800be0:	f7 d8                	neg    %eax
  800be2:	eb 06                	jmp    800bea <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be4:	84 c0                	test   %al,%al
  800be6:	75 8a                	jne    800b72 <strtol+0x6e>
  800be8:	eb 90                	jmp    800b7a <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 c3                	mov    %eax,%ebx
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	89 c6                	mov    %eax,%esi
  800c06:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 cb                	mov    %ecx,%ebx
  800c44:	89 cf                	mov    %ecx,%edi
  800c46:	89 ce                	mov    %ecx,%esi
  800c48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 03                	push   $0x3
  800c54:	68 5f 27 80 00       	push   $0x80275f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 7c 27 80 00       	push   $0x80277c
  800c60:	e8 df f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
  800c78:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7d:	89 d1                	mov    %edx,%ecx
  800c7f:	89 d3                	mov    %edx,%ebx
  800c81:	89 d7                	mov    %edx,%edi
  800c83:	89 d6                	mov    %edx,%esi
  800c85:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_yield>:

void
sys_yield(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9c:	89 d1                	mov    %edx,%ecx
  800c9e:	89 d3                	mov    %edx,%ebx
  800ca0:	89 d7                	mov    %edx,%edi
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	be 00 00 00 00       	mov    $0x0,%esi
  800cb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc7:	89 f7                	mov    %esi,%edi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 04                	push   $0x4
  800cd5:	68 5f 27 80 00       	push   $0x80275f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 7c 27 80 00       	push   $0x80277c
  800ce1:	e8 5e f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d08:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 05                	push   $0x5
  800d17:	68 5f 27 80 00       	push   $0x80275f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 7c 27 80 00       	push   $0x80277c
  800d23:	e8 1c f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 06                	push   $0x6
  800d59:	68 5f 27 80 00       	push   $0x80275f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 7c 27 80 00       	push   $0x80277c
  800d65:	e8 da f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	b8 08 00 00 00       	mov    $0x8,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 08                	push   $0x8
  800d9b:	68 5f 27 80 00       	push   $0x80275f
  800da0:	6a 23                	push   $0x23
  800da2:	68 7c 27 80 00       	push   $0x80277c
  800da7:	e8 98 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 09                	push   $0x9
  800ddd:	68 5f 27 80 00       	push   $0x80275f
  800de2:	6a 23                	push   $0x23
  800de4:	68 7c 27 80 00       	push   $0x80277c
  800de9:	e8 56 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 df                	mov    %ebx,%edi
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 17                	jle    800e30 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 0a                	push   $0xa
  800e1f:	68 5f 27 80 00       	push   $0x80275f
  800e24:	6a 23                	push   $0x23
  800e26:	68 7c 27 80 00       	push   $0x80277c
  800e2b:	e8 14 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	be 00 00 00 00       	mov    $0x0,%esi
  800e43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e54:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e69:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	89 cb                	mov    %ecx,%ebx
  800e73:	89 cf                	mov    %ecx,%edi
  800e75:	89 ce                	mov    %ecx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 17                	jle    800e94 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	50                   	push   %eax
  800e81:	6a 0d                	push   $0xd
  800e83:	68 5f 27 80 00       	push   $0x80275f
  800e88:	6a 23                	push   $0x23
  800e8a:	68 7c 27 80 00       	push   $0x80277c
  800e8f:	e8 b0 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_gettime>:

int sys_gettime(void)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eac:	89 d1                	mov    %edx,%ecx
  800eae:	89 d3                	mov    %edx,%ebx
  800eb0:	89 d7                	mov    %edx,%edi
  800eb2:	89 d6                	mov    %edx,%esi
  800eb4:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800ec5:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ec7:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ecb:	74 2e                	je     800efb <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 ea 16             	shr    $0x16,%edx
  800ed2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ed9:	f6 c2 01             	test   $0x1,%dl
  800edc:	74 1d                	je     800efb <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 0c             	shr    $0xc,%edx
  800ee3:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800eea:	f6 c1 01             	test   $0x1,%cl
  800eed:	74 0c                	je     800efb <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800eef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ef6:	f6 c6 08             	test   $0x8,%dh
  800ef9:	75 14                	jne    800f0f <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	68 8a 27 80 00       	push   $0x80278a
  800f03:	6a 28                	push   $0x28
  800f05:	68 9c 27 80 00       	push   $0x80279c
  800f0a:	e8 35 f3 ff ff       	call   800244 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800f0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f14:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	6a 07                	push   $0x7
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	6a 00                	push   $0x0
  800f22:	e8 84 fd ff ff       	call   800cab <sys_page_alloc>
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 14                	jns    800f42 <pgfault+0x87>
		panic("sys_page_alloc");
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	68 a7 27 80 00       	push   $0x8027a7
  800f36:	6a 2c                	push   $0x2c
  800f38:	68 9c 27 80 00       	push   $0x80279c
  800f3d:	e8 02 f3 ff ff       	call   800244 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 00 10 00 00       	push   $0x1000
  800f4a:	53                   	push   %ebx
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	e8 46 fb ff ff       	call   800a9b <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f55:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5c:	53                   	push   %ebx
  800f5d:	6a 00                	push   $0x0
  800f5f:	68 00 f0 7f 00       	push   $0x7ff000
  800f64:	6a 00                	push   $0x0
  800f66:	e8 83 fd ff ff       	call   800cee <sys_page_map>
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 14                	jns    800f86 <pgfault+0xcb>
		panic("sys_page_map");
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	68 b6 27 80 00       	push   $0x8027b6
  800f7a:	6a 2f                	push   $0x2f
  800f7c:	68 9c 27 80 00       	push   $0x80279c
  800f81:	e8 be f2 ff ff       	call   800244 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 9b fd ff ff       	call   800d30 <sys_page_unmap>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 14                	jns    800fb0 <pgfault+0xf5>
		panic("sys_page_unmap");
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 c3 27 80 00       	push   $0x8027c3
  800fa4:	6a 31                	push   $0x31
  800fa6:	68 9c 27 80 00       	push   $0x80279c
  800fab:	e8 94 f2 ff ff       	call   800244 <_panic>
	return;
}
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800fbe:	68 bb 0e 80 00       	push   $0x800ebb
  800fc3:	e8 e5 0f 00 00       	call   801fad <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcd:	cd 30                	int    $0x30
  800fcf:	89 c7                	mov    %eax,%edi
  800fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	75 21                	jne    800ffc <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fdb:	e8 8d fc ff ff       	call   800c6d <sys_getenvid>
  800fe0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe5:	6b c0 78             	imul   $0x78,%eax,%eax
  800fe8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fed:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff7:	e9 80 01 00 00       	jmp    80117c <fork+0x1c7>
	}
	if (envid < 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 12                	jns    801012 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  801000:	50                   	push   %eax
  801001:	68 d2 27 80 00       	push   $0x8027d2
  801006:	6a 70                	push   $0x70
  801008:	68 9c 27 80 00       	push   $0x80279c
  80100d:	e8 32 f2 ff ff       	call   800244 <_panic>
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  801017:	89 d8                	mov    %ebx,%eax
  801019:	c1 e8 16             	shr    $0x16,%eax
  80101c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801023:	a8 01                	test   $0x1,%al
  801025:	0f 84 de 00 00 00    	je     801109 <fork+0x154>
  80102b:	89 de                	mov    %ebx,%esi
  80102d:	c1 ee 0c             	shr    $0xc,%esi
  801030:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801037:	a8 01                	test   $0x1,%al
  801039:	0f 84 ca 00 00 00    	je     801109 <fork+0x154>
  80103f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801046:	a8 04                	test   $0x4,%al
  801048:	0f 84 bb 00 00 00    	je     801109 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  80104e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  801055:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  801058:	f6 c4 04             	test   $0x4,%ah
  80105b:	74 34                	je     801091 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	25 07 0e 00 00       	and    $0xe07,%eax
  801065:	50                   	push   %eax
  801066:	56                   	push   %esi
  801067:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106a:	56                   	push   %esi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 7c fc ff ff       	call   800cee <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	0f 84 8c 00 00 00    	je     801109 <fork+0x154>
        	panic("duppage share");
  80107d:	83 ec 04             	sub    $0x4,%esp
  801080:	68 e2 27 80 00       	push   $0x8027e2
  801085:	6a 48                	push   $0x48
  801087:	68 9c 27 80 00       	push   $0x80279c
  80108c:	e8 b3 f1 ff ff       	call   800244 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801091:	a9 02 08 00 00       	test   $0x802,%eax
  801096:	74 5d                	je     8010f5 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	68 05 08 00 00       	push   $0x805
  8010a0:	56                   	push   %esi
  8010a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 42 fc ff ff       	call   800cee <sys_page_map>
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 14                	jns    8010c7 <fork+0x112>
			panic("error");
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	68 60 24 80 00       	push   $0x802460
  8010bb:	6a 4b                	push   $0x4b
  8010bd:	68 9c 27 80 00       	push   $0x80279c
  8010c2:	e8 7d f1 ff ff       	call   800244 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	68 05 08 00 00       	push   $0x805
  8010cf:	56                   	push   %esi
  8010d0:	6a 00                	push   $0x0
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 14 fc ff ff       	call   800cee <sys_page_map>
  8010da:	83 c4 20             	add    $0x20,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 28                	jns    801109 <fork+0x154>
			panic("error");
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	68 60 24 80 00       	push   $0x802460
  8010e9:	6a 4d                	push   $0x4d
  8010eb:	68 9c 27 80 00       	push   $0x80279c
  8010f0:	e8 4f f1 ff ff       	call   800244 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	6a 05                	push   $0x5
  8010fa:	56                   	push   %esi
  8010fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fe:	56                   	push   %esi
  8010ff:	6a 00                	push   $0x0
  801101:	e8 e8 fb ff ff       	call   800cee <sys_page_map>
  801106:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801109:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80110f:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  801115:	0f 85 fc fe ff ff    	jne    801017 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	6a 07                	push   $0x7
  801120:	68 00 f0 7f ee       	push   $0xee7ff000
  801125:	57                   	push   %edi
  801126:	e8 80 fb ff ff       	call   800cab <sys_page_alloc>
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 14                	jns    801146 <fork+0x191>
		panic("1");
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	68 f0 27 80 00       	push   $0x8027f0
  80113a:	6a 78                	push   $0x78
  80113c:	68 9c 27 80 00       	push   $0x80279c
  801141:	e8 fe f0 ff ff       	call   800244 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	68 1c 20 80 00       	push   $0x80201c
  80114e:	57                   	push   %edi
  80114f:	e8 a2 fc ff ff       	call   800df6 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	6a 02                	push   $0x2
  801159:	57                   	push   %edi
  80115a:	e8 13 fc ff ff       	call   800d72 <sys_env_set_status>
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	79 14                	jns    80117a <fork+0x1c5>
		panic("sys_env_set_status");
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	68 f2 27 80 00       	push   $0x8027f2
  80116e:	6a 7d                	push   $0x7d
  801170:	68 9c 27 80 00       	push   $0x80279c
  801175:	e8 ca f0 ff ff       	call   800244 <_panic>

	return envid;
  80117a:	89 f8                	mov    %edi,%eax
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sfork>:

// Challenge!
int
sfork(void)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118a:	68 05 28 80 00       	push   $0x802805
  80118f:	68 86 00 00 00       	push   $0x86
  801194:	68 9c 27 80 00       	push   $0x80279c
  801199:	e8 a6 f0 ff ff       	call   800244 <_panic>

0080119e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  8011ac:	85 f6                	test   %esi,%esi
  8011ae:	74 06                	je     8011b6 <ipc_recv+0x18>
  8011b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8011b6:	85 db                	test   %ebx,%ebx
  8011b8:	74 06                	je     8011c0 <ipc_recv+0x22>
  8011ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8011c0:	83 f8 01             	cmp    $0x1,%eax
  8011c3:	19 d2                	sbb    %edx,%edx
  8011c5:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	50                   	push   %eax
  8011cb:	e8 8b fc ff ff       	call   800e5b <sys_ipc_recv>
  8011d0:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 d2                	test   %edx,%edx
  8011d7:	75 24                	jne    8011fd <ipc_recv+0x5f>
	if (from_env_store)
  8011d9:	85 f6                	test   %esi,%esi
  8011db:	74 0a                	je     8011e7 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  8011dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e2:	8b 40 70             	mov    0x70(%eax),%eax
  8011e5:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8011e7:	85 db                	test   %ebx,%ebx
  8011e9:	74 0a                	je     8011f5 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  8011eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f0:	8b 40 74             	mov    0x74(%eax),%eax
  8011f3:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8011f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fa:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  8011fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801210:	8b 75 0c             	mov    0xc(%ebp),%esi
  801213:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801216:	83 fb 01             	cmp    $0x1,%ebx
  801219:	19 c0                	sbb    %eax,%eax
  80121b:	09 c3                	or     %eax,%ebx
  80121d:	eb 1c                	jmp    80123b <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80121f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801222:	74 12                	je     801236 <ipc_send+0x32>
  801224:	50                   	push   %eax
  801225:	68 1b 28 80 00       	push   $0x80281b
  80122a:	6a 36                	push   $0x36
  80122c:	68 32 28 80 00       	push   $0x802832
  801231:	e8 0e f0 ff ff       	call   800244 <_panic>
		sys_yield();
  801236:	e8 51 fa ff ff       	call   800c8c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80123b:	ff 75 14             	pushl  0x14(%ebp)
  80123e:	53                   	push   %ebx
  80123f:	56                   	push   %esi
  801240:	57                   	push   %edi
  801241:	e8 f2 fb ff ff       	call   800e38 <sys_ipc_try_send>
		if (ret == 0) break;
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	75 d2                	jne    80121f <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  80124d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80125b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801260:	6b d0 78             	imul   $0x78,%eax,%edx
  801263:	83 c2 50             	add    $0x50,%edx
  801266:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  80126c:	39 ca                	cmp    %ecx,%edx
  80126e:	75 0d                	jne    80127d <ipc_find_env+0x28>
			return envs[i].env_id;
  801270:	6b c0 78             	imul   $0x78,%eax,%eax
  801273:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801278:	8b 40 08             	mov    0x8(%eax),%eax
  80127b:	eb 0e                	jmp    80128b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80127d:	83 c0 01             	add    $0x1,%eax
  801280:	3d 00 04 00 00       	cmp    $0x400,%eax
  801285:	75 d9                	jne    801260 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801287:	66 b8 00 00          	mov    $0x0,%ax
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	05 00 00 00 30       	add    $0x30000000,%eax
  801298:	c1 e8 0c             	shr    $0xc,%eax
}
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ad:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	c1 ea 16             	shr    $0x16,%edx
  8012c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012cb:	f6 c2 01             	test   $0x1,%dl
  8012ce:	74 11                	je     8012e1 <fd_alloc+0x2d>
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	c1 ea 0c             	shr    $0xc,%edx
  8012d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012dc:	f6 c2 01             	test   $0x1,%dl
  8012df:	75 09                	jne    8012ea <fd_alloc+0x36>
			*fd_store = fd;
  8012e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e8:	eb 17                	jmp    801301 <fd_alloc+0x4d>
  8012ea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f4:	75 c9                	jne    8012bf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012fc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801309:	83 f8 1f             	cmp    $0x1f,%eax
  80130c:	77 36                	ja     801344 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80130e:	c1 e0 0c             	shl    $0xc,%eax
  801311:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801316:	89 c2                	mov    %eax,%edx
  801318:	c1 ea 16             	shr    $0x16,%edx
  80131b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801322:	f6 c2 01             	test   $0x1,%dl
  801325:	74 24                	je     80134b <fd_lookup+0x48>
  801327:	89 c2                	mov    %eax,%edx
  801329:	c1 ea 0c             	shr    $0xc,%edx
  80132c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801333:	f6 c2 01             	test   $0x1,%dl
  801336:	74 1a                	je     801352 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133b:	89 02                	mov    %eax,(%edx)
	return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	eb 13                	jmp    801357 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801349:	eb 0c                	jmp    801357 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801350:	eb 05                	jmp    801357 <fd_lookup+0x54>
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801362:	ba b8 28 80 00       	mov    $0x8028b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801367:	eb 13                	jmp    80137c <dev_lookup+0x23>
  801369:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80136c:	39 08                	cmp    %ecx,(%eax)
  80136e:	75 0c                	jne    80137c <dev_lookup+0x23>
			*dev = devtab[i];
  801370:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801373:	89 01                	mov    %eax,(%ecx)
			return 0;
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
  80137a:	eb 2e                	jmp    8013aa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80137c:	8b 02                	mov    (%edx),%eax
  80137e:	85 c0                	test   %eax,%eax
  801380:	75 e7                	jne    801369 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801382:	a1 04 40 80 00       	mov    0x804004,%eax
  801387:	8b 40 48             	mov    0x48(%eax),%eax
  80138a:	83 ec 04             	sub    $0x4,%esp
  80138d:	51                   	push   %ecx
  80138e:	50                   	push   %eax
  80138f:	68 3c 28 80 00       	push   $0x80283c
  801394:	e8 84 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 10             	sub    $0x10,%esp
  8013b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013be:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c4:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c7:	50                   	push   %eax
  8013c8:	e8 36 ff ff ff       	call   801303 <fd_lookup>
  8013cd:	83 c4 08             	add    $0x8,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 05                	js     8013d9 <fd_close+0x2d>
	    || fd != fd2)
  8013d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d7:	74 0b                	je     8013e4 <fd_close+0x38>
		return (must_exist ? r : 0);
  8013d9:	80 fb 01             	cmp    $0x1,%bl
  8013dc:	19 d2                	sbb    %edx,%edx
  8013de:	f7 d2                	not    %edx
  8013e0:	21 d0                	and    %edx,%eax
  8013e2:	eb 41                	jmp    801425 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	ff 36                	pushl  (%esi)
  8013ed:	e8 67 ff ff ff       	call   801359 <dev_lookup>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 1a                	js     801415 <fd_close+0x69>
		if (dev->dev_close)
  8013fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801401:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801406:	85 c0                	test   %eax,%eax
  801408:	74 0b                	je     801415 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	56                   	push   %esi
  80140e:	ff d0                	call   *%eax
  801410:	89 c3                	mov    %eax,%ebx
  801412:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	56                   	push   %esi
  801419:	6a 00                	push   $0x0
  80141b:	e8 10 f9 ff ff       	call   800d30 <sys_page_unmap>
	return r;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	89 d8                	mov    %ebx,%eax
}
  801425:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	ff 75 08             	pushl  0x8(%ebp)
  801439:	e8 c5 fe ff ff       	call   801303 <fd_lookup>
  80143e:	89 c2                	mov    %eax,%edx
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	85 d2                	test   %edx,%edx
  801445:	78 10                	js     801457 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	6a 01                	push   $0x1
  80144c:	ff 75 f4             	pushl  -0xc(%ebp)
  80144f:	e8 58 ff ff ff       	call   8013ac <fd_close>
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <close_all>:

void
close_all(void)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801460:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	53                   	push   %ebx
  801469:	e8 be ff ff ff       	call   80142c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80146e:	83 c3 01             	add    $0x1,%ebx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	83 fb 20             	cmp    $0x20,%ebx
  801477:	75 ec                	jne    801465 <close_all+0xc>
		close(i);
}
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	83 ec 2c             	sub    $0x2c,%esp
  801487:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	ff 75 08             	pushl  0x8(%ebp)
  801491:	e8 6d fe ff ff       	call   801303 <fd_lookup>
  801496:	89 c2                	mov    %eax,%edx
  801498:	83 c4 08             	add    $0x8,%esp
  80149b:	85 d2                	test   %edx,%edx
  80149d:	0f 88 c1 00 00 00    	js     801564 <dup+0xe6>
		return r;
	close(newfdnum);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	56                   	push   %esi
  8014a7:	e8 80 ff ff ff       	call   80142c <close>

	newfd = INDEX2FD(newfdnum);
  8014ac:	89 f3                	mov    %esi,%ebx
  8014ae:	c1 e3 0c             	shl    $0xc,%ebx
  8014b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b7:	83 c4 04             	add    $0x4,%esp
  8014ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bd:	e8 db fd ff ff       	call   80129d <fd2data>
  8014c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014c4:	89 1c 24             	mov    %ebx,(%esp)
  8014c7:	e8 d1 fd ff ff       	call   80129d <fd2data>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d2:	89 f8                	mov    %edi,%eax
  8014d4:	c1 e8 16             	shr    $0x16,%eax
  8014d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014de:	a8 01                	test   $0x1,%al
  8014e0:	74 37                	je     801519 <dup+0x9b>
  8014e2:	89 f8                	mov    %edi,%eax
  8014e4:	c1 e8 0c             	shr    $0xc,%eax
  8014e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ee:	f6 c2 01             	test   $0x1,%dl
  8014f1:	74 26                	je     801519 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801502:	50                   	push   %eax
  801503:	ff 75 d4             	pushl  -0x2c(%ebp)
  801506:	6a 00                	push   $0x0
  801508:	57                   	push   %edi
  801509:	6a 00                	push   $0x0
  80150b:	e8 de f7 ff ff       	call   800cee <sys_page_map>
  801510:	89 c7                	mov    %eax,%edi
  801512:	83 c4 20             	add    $0x20,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 2e                	js     801547 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	c1 e8 0c             	shr    $0xc,%eax
  801521:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	25 07 0e 00 00       	and    $0xe07,%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	6a 00                	push   $0x0
  801534:	52                   	push   %edx
  801535:	6a 00                	push   $0x0
  801537:	e8 b2 f7 ff ff       	call   800cee <sys_page_map>
  80153c:	89 c7                	mov    %eax,%edi
  80153e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801541:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801543:	85 ff                	test   %edi,%edi
  801545:	79 1d                	jns    801564 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	6a 00                	push   $0x0
  80154d:	e8 de f7 ff ff       	call   800d30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	ff 75 d4             	pushl  -0x2c(%ebp)
  801558:	6a 00                	push   $0x0
  80155a:	e8 d1 f7 ff ff       	call   800d30 <sys_page_unmap>
	return r;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	89 f8                	mov    %edi,%eax
}
  801564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 83 fd ff ff       	call   801303 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 6d                	js     8015f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 bf fd ff ff       	call   801359 <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 4c                	js     8015ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a4:	8b 42 08             	mov    0x8(%edx),%eax
  8015a7:	83 e0 03             	and    $0x3,%eax
  8015aa:	83 f8 01             	cmp    $0x1,%eax
  8015ad:	75 21                	jne    8015d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015af:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b4:	8b 40 48             	mov    0x48(%eax),%eax
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	50                   	push   %eax
  8015bc:	68 7d 28 80 00       	push   $0x80287d
  8015c1:	e8 57 ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ce:	eb 26                	jmp    8015f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d3:	8b 40 08             	mov    0x8(%eax),%eax
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	74 17                	je     8015f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	ff 75 10             	pushl  0x10(%ebp)
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	52                   	push   %edx
  8015e4:	ff d0                	call   *%eax
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 09                	jmp    8015f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	eb 05                	jmp    8015f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8b 7d 08             	mov    0x8(%ebp),%edi
  801609:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801611:	eb 21                	jmp    801634 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	89 f0                	mov    %esi,%eax
  801618:	29 d8                	sub    %ebx,%eax
  80161a:	50                   	push   %eax
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	03 45 0c             	add    0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	57                   	push   %edi
  801622:	e8 45 ff ff ff       	call   80156c <read>
		if (m < 0)
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 0c                	js     80163a <readn+0x3d>
			return m;
		if (m == 0)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 06                	je     801638 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801632:	01 c3                	add    %eax,%ebx
  801634:	39 f3                	cmp    %esi,%ebx
  801636:	72 db                	jb     801613 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801638:	89 d8                	mov    %ebx,%eax
}
  80163a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5e                   	pop    %esi
  80163f:	5f                   	pop    %edi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	83 ec 14             	sub    $0x14,%esp
  801649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	53                   	push   %ebx
  801651:	e8 ad fc ff ff       	call   801303 <fd_lookup>
  801656:	83 c4 08             	add    $0x8,%esp
  801659:	89 c2                	mov    %eax,%edx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 68                	js     8016c7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	ff 30                	pushl  (%eax)
  80166b:	e8 e9 fc ff ff       	call   801359 <dev_lookup>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 47                	js     8016be <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167e:	75 21                	jne    8016a1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801680:	a1 04 40 80 00       	mov    0x804004,%eax
  801685:	8b 40 48             	mov    0x48(%eax),%eax
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	53                   	push   %ebx
  80168c:	50                   	push   %eax
  80168d:	68 99 28 80 00       	push   $0x802899
  801692:	e8 86 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169f:	eb 26                	jmp    8016c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a7:	85 d2                	test   %edx,%edx
  8016a9:	74 17                	je     8016c2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	ff 75 10             	pushl  0x10(%ebp)
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	ff d2                	call   *%edx
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 09                	jmp    8016c7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	eb 05                	jmp    8016c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016c7:	89 d0                	mov    %edx,%eax
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 08             	pushl  0x8(%ebp)
  8016db:	e8 23 fc ff ff       	call   801303 <fd_lookup>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 0e                	js     8016f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 14             	sub    $0x14,%esp
  8016fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801701:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	53                   	push   %ebx
  801706:	e8 f8 fb ff ff       	call   801303 <fd_lookup>
  80170b:	83 c4 08             	add    $0x8,%esp
  80170e:	89 c2                	mov    %eax,%edx
  801710:	85 c0                	test   %eax,%eax
  801712:	78 65                	js     801779 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171e:	ff 30                	pushl  (%eax)
  801720:	e8 34 fc ff ff       	call   801359 <dev_lookup>
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 44                	js     801770 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801733:	75 21                	jne    801756 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801735:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80173a:	8b 40 48             	mov    0x48(%eax),%eax
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	53                   	push   %ebx
  801741:	50                   	push   %eax
  801742:	68 5c 28 80 00       	push   $0x80285c
  801747:	e8 d1 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801754:	eb 23                	jmp    801779 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801756:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801759:	8b 52 18             	mov    0x18(%edx),%edx
  80175c:	85 d2                	test   %edx,%edx
  80175e:	74 14                	je     801774 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	50                   	push   %eax
  801767:	ff d2                	call   *%edx
  801769:	89 c2                	mov    %eax,%edx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	eb 09                	jmp    801779 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	89 c2                	mov    %eax,%edx
  801772:	eb 05                	jmp    801779 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801774:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801779:	89 d0                	mov    %edx,%eax
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 14             	sub    $0x14,%esp
  801787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	ff 75 08             	pushl  0x8(%ebp)
  801791:	e8 6d fb ff ff       	call   801303 <fd_lookup>
  801796:	83 c4 08             	add    $0x8,%esp
  801799:	89 c2                	mov    %eax,%edx
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 58                	js     8017f7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a9:	ff 30                	pushl  (%eax)
  8017ab:	e8 a9 fb ff ff       	call   801359 <dev_lookup>
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 37                	js     8017ee <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017be:	74 32                	je     8017f2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ca:	00 00 00 
	stat->st_isdir = 0;
  8017cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d4:	00 00 00 
	stat->st_dev = dev;
  8017d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	53                   	push   %ebx
  8017e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e4:	ff 50 14             	call   *0x14(%eax)
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	eb 09                	jmp    8017f7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ee:	89 c2                	mov    %eax,%edx
  8017f0:	eb 05                	jmp    8017f7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017f7:	89 d0                	mov    %edx,%eax
  8017f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	6a 00                	push   $0x0
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 e7 01 00 00       	call   8019f7 <open>
  801810:	89 c3                	mov    %eax,%ebx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	85 db                	test   %ebx,%ebx
  801817:	78 1b                	js     801834 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	ff 75 0c             	pushl  0xc(%ebp)
  80181f:	53                   	push   %ebx
  801820:	e8 5b ff ff ff       	call   801780 <fstat>
  801825:	89 c6                	mov    %eax,%esi
	close(fd);
  801827:	89 1c 24             	mov    %ebx,(%esp)
  80182a:	e8 fd fb ff ff       	call   80142c <close>
	return r;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	89 f0                	mov    %esi,%eax
}
  801834:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	56                   	push   %esi
  80183f:	53                   	push   %ebx
  801840:	89 c6                	mov    %eax,%esi
  801842:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801844:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80184b:	75 12                	jne    80185f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	6a 03                	push   $0x3
  801852:	e8 fe f9 ff ff       	call   801255 <ipc_find_env>
  801857:	a3 00 40 80 00       	mov    %eax,0x804000
  80185c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80185f:	6a 07                	push   $0x7
  801861:	68 00 50 80 00       	push   $0x805000
  801866:	56                   	push   %esi
  801867:	ff 35 00 40 80 00    	pushl  0x804000
  80186d:	e8 92 f9 ff ff       	call   801204 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801872:	83 c4 0c             	add    $0xc,%esp
  801875:	6a 00                	push   $0x0
  801877:	53                   	push   %ebx
  801878:	6a 00                	push   $0x0
  80187a:	e8 1f f9 ff ff       	call   80119e <ipc_recv>
}
  80187f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a9:	e8 8d ff ff ff       	call   80183b <fsipc>
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cb:	e8 6b ff ff ff       	call   80183b <fsipc>
}
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f1:	e8 45 ff ff ff       	call   80183b <fsipc>
  8018f6:	89 c2                	mov    %eax,%edx
  8018f8:	85 d2                	test   %edx,%edx
  8018fa:	78 2c                	js     801928 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	68 00 50 80 00       	push   $0x805000
  801904:	53                   	push   %ebx
  801905:	e8 97 ef ff ff       	call   8008a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190a:	a1 80 50 80 00       	mov    0x805080,%eax
  80190f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801915:	a1 84 50 80 00       	mov    0x805084,%eax
  80191a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801928:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801936:	8b 55 08             	mov    0x8(%ebp),%edx
  801939:	8b 52 0c             	mov    0xc(%edx),%edx
  80193c:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801942:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801947:	76 05                	jbe    80194e <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801949:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  80194e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	50                   	push   %eax
  801957:	ff 75 0c             	pushl  0xc(%ebp)
  80195a:	68 08 50 80 00       	push   $0x805008
  80195f:	e8 cf f0 ff ff       	call   800a33 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801964:	ba 00 00 00 00       	mov    $0x0,%edx
  801969:	b8 04 00 00 00       	mov    $0x4,%eax
  80196e:	e8 c8 fe ff ff       	call   80183b <fsipc>
	return write;
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	8b 40 0c             	mov    0xc(%eax),%eax
  801983:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801988:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 03 00 00 00       	mov    $0x3,%eax
  801998:	e8 9e fe ff ff       	call   80183b <fsipc>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 4b                	js     8019ee <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019a3:	39 c6                	cmp    %eax,%esi
  8019a5:	73 16                	jae    8019bd <devfile_read+0x48>
  8019a7:	68 c8 28 80 00       	push   $0x8028c8
  8019ac:	68 cf 28 80 00       	push   $0x8028cf
  8019b1:	6a 7c                	push   $0x7c
  8019b3:	68 e4 28 80 00       	push   $0x8028e4
  8019b8:	e8 87 e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c2:	7e 16                	jle    8019da <devfile_read+0x65>
  8019c4:	68 ef 28 80 00       	push   $0x8028ef
  8019c9:	68 cf 28 80 00       	push   $0x8028cf
  8019ce:	6a 7d                	push   $0x7d
  8019d0:	68 e4 28 80 00       	push   $0x8028e4
  8019d5:	e8 6a e8 ff ff       	call   800244 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019da:	83 ec 04             	sub    $0x4,%esp
  8019dd:	50                   	push   %eax
  8019de:	68 00 50 80 00       	push   $0x805000
  8019e3:	ff 75 0c             	pushl  0xc(%ebp)
  8019e6:	e8 48 f0 ff ff       	call   800a33 <memmove>
	return r;
  8019eb:	83 c4 10             	add    $0x10,%esp
}
  8019ee:	89 d8                	mov    %ebx,%eax
  8019f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 20             	sub    $0x20,%esp
  8019fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a01:	53                   	push   %ebx
  801a02:	e8 61 ee ff ff       	call   800868 <strlen>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0f:	7f 67                	jg     801a78 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a17:	50                   	push   %eax
  801a18:	e8 97 f8 ff ff       	call   8012b4 <fd_alloc>
  801a1d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a20:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 57                	js     801a7d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	53                   	push   %ebx
  801a2a:	68 00 50 80 00       	push   $0x805000
  801a2f:	e8 6d ee ff ff       	call   8008a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a44:	e8 f2 fd ff ff       	call   80183b <fsipc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	79 14                	jns    801a66 <open+0x6f>
		fd_close(fd, 0);
  801a52:	83 ec 08             	sub    $0x8,%esp
  801a55:	6a 00                	push   $0x0
  801a57:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5a:	e8 4d f9 ff ff       	call   8013ac <fd_close>
		return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	89 da                	mov    %ebx,%edx
  801a64:	eb 17                	jmp    801a7d <open+0x86>
	}

	return fd2num(fd);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	e8 1c f8 ff ff       	call   80128d <fd2num>
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	eb 05                	jmp    801a7d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a78:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a7d:	89 d0                	mov    %edx,%eax
  801a7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a94:	e8 a2 fd ff ff       	call   80183b <fsipc>
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aa1:	89 d0                	mov    %edx,%eax
  801aa3:	c1 e8 16             	shr    $0x16,%eax
  801aa6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab2:	f6 c1 01             	test   $0x1,%cl
  801ab5:	74 1d                	je     801ad4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ab7:	c1 ea 0c             	shr    $0xc,%edx
  801aba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ac1:	f6 c2 01             	test   $0x1,%dl
  801ac4:	74 0e                	je     801ad4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ac6:	c1 ea 0c             	shr    $0xc,%edx
  801ac9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ad0:	ef 
  801ad1:	0f b7 c0             	movzwl %ax,%eax
}
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	ff 75 08             	pushl  0x8(%ebp)
  801ae4:	e8 b4 f7 ff ff       	call   80129d <fd2data>
  801ae9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aeb:	83 c4 08             	add    $0x8,%esp
  801aee:	68 fb 28 80 00       	push   $0x8028fb
  801af3:	53                   	push   %ebx
  801af4:	e8 a8 ed ff ff       	call   8008a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801af9:	8b 56 04             	mov    0x4(%esi),%edx
  801afc:	89 d0                	mov    %edx,%eax
  801afe:	2b 06                	sub    (%esi),%eax
  801b00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0d:	00 00 00 
	stat->st_dev = &devpipe;
  801b10:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b17:	30 80 00 
	return 0;
}
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b30:	53                   	push   %ebx
  801b31:	6a 00                	push   $0x0
  801b33:	e8 f8 f1 ff ff       	call   800d30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b38:	89 1c 24             	mov    %ebx,(%esp)
  801b3b:	e8 5d f7 ff ff       	call   80129d <fd2data>
  801b40:	83 c4 08             	add    $0x8,%esp
  801b43:	50                   	push   %eax
  801b44:	6a 00                	push   $0x0
  801b46:	e8 e5 f1 ff ff       	call   800d30 <sys_page_unmap>
}
  801b4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 1c             	sub    $0x1c,%esp
  801b59:	89 c7                	mov    %eax,%edi
  801b5b:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b5d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b62:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	57                   	push   %edi
  801b69:	e8 2d ff ff ff       	call   801a9b <pageref>
  801b6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b71:	89 34 24             	mov    %esi,(%esp)
  801b74:	e8 22 ff ff ff       	call   801a9b <pageref>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b7f:	0f 94 c0             	sete   %al
  801b82:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b85:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b8b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b8e:	39 cb                	cmp    %ecx,%ebx
  801b90:	74 15                	je     801ba7 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801b92:	8b 52 58             	mov    0x58(%edx),%edx
  801b95:	50                   	push   %eax
  801b96:	52                   	push   %edx
  801b97:	53                   	push   %ebx
  801b98:	68 08 29 80 00       	push   $0x802908
  801b9d:	e8 7b e7 ff ff       	call   80031d <cprintf>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	eb b6                	jmp    801b5d <_pipeisclosed+0xd>
	}
}
  801ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	57                   	push   %edi
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 28             	sub    $0x28,%esp
  801bb8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bbb:	56                   	push   %esi
  801bbc:	e8 dc f6 ff ff       	call   80129d <fd2data>
  801bc1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	bf 00 00 00 00       	mov    $0x0,%edi
  801bcb:	eb 4b                	jmp    801c18 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bcd:	89 da                	mov    %ebx,%edx
  801bcf:	89 f0                	mov    %esi,%eax
  801bd1:	e8 7a ff ff ff       	call   801b50 <_pipeisclosed>
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	75 48                	jne    801c22 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bda:	e8 ad f0 ff ff       	call   800c8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bdf:	8b 43 04             	mov    0x4(%ebx),%eax
  801be2:	8b 0b                	mov    (%ebx),%ecx
  801be4:	8d 51 20             	lea    0x20(%ecx),%edx
  801be7:	39 d0                	cmp    %edx,%eax
  801be9:	73 e2                	jae    801bcd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bf2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf5:	89 c2                	mov    %eax,%edx
  801bf7:	c1 fa 1f             	sar    $0x1f,%edx
  801bfa:	89 d1                	mov    %edx,%ecx
  801bfc:	c1 e9 1b             	shr    $0x1b,%ecx
  801bff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c02:	83 e2 1f             	and    $0x1f,%edx
  801c05:	29 ca                	sub    %ecx,%edx
  801c07:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c0b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c0f:	83 c0 01             	add    $0x1,%eax
  801c12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c15:	83 c7 01             	add    $0x1,%edi
  801c18:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1b:	75 c2                	jne    801bdf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c20:	eb 05                	jmp    801c27 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5f                   	pop    %edi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 18             	sub    $0x18,%esp
  801c38:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c3b:	57                   	push   %edi
  801c3c:	e8 5c f6 ff ff       	call   80129d <fd2data>
  801c41:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4b:	eb 3d                	jmp    801c8a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c4d:	85 db                	test   %ebx,%ebx
  801c4f:	74 04                	je     801c55 <devpipe_read+0x26>
				return i;
  801c51:	89 d8                	mov    %ebx,%eax
  801c53:	eb 44                	jmp    801c99 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c55:	89 f2                	mov    %esi,%edx
  801c57:	89 f8                	mov    %edi,%eax
  801c59:	e8 f2 fe ff ff       	call   801b50 <_pipeisclosed>
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	75 32                	jne    801c94 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c62:	e8 25 f0 ff ff       	call   800c8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c67:	8b 06                	mov    (%esi),%eax
  801c69:	3b 46 04             	cmp    0x4(%esi),%eax
  801c6c:	74 df                	je     801c4d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c6e:	99                   	cltd   
  801c6f:	c1 ea 1b             	shr    $0x1b,%edx
  801c72:	01 d0                	add    %edx,%eax
  801c74:	83 e0 1f             	and    $0x1f,%eax
  801c77:	29 d0                	sub    %edx,%eax
  801c79:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c81:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c84:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c87:	83 c3 01             	add    $0x1,%ebx
  801c8a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c8d:	75 d8                	jne    801c67 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c92:	eb 05                	jmp    801c99 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cac:	50                   	push   %eax
  801cad:	e8 02 f6 ff ff       	call   8012b4 <fd_alloc>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 2c 01 00 00    	js     801deb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbf:	83 ec 04             	sub    $0x4,%esp
  801cc2:	68 07 04 00 00       	push   $0x407
  801cc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 da ef ff ff       	call   800cab <sys_page_alloc>
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	89 c2                	mov    %eax,%edx
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	0f 88 0d 01 00 00    	js     801deb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	e8 ca f5 ff ff       	call   8012b4 <fd_alloc>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	0f 88 e2 00 00 00    	js     801dd9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	68 07 04 00 00       	push   $0x407
  801cff:	ff 75 f0             	pushl  -0x10(%ebp)
  801d02:	6a 00                	push   $0x0
  801d04:	e8 a2 ef ff ff       	call   800cab <sys_page_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	0f 88 c3 00 00 00    	js     801dd9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1c:	e8 7c f5 ff ff       	call   80129d <fd2data>
  801d21:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d23:	83 c4 0c             	add    $0xc,%esp
  801d26:	68 07 04 00 00       	push   $0x407
  801d2b:	50                   	push   %eax
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 78 ef ff ff       	call   800cab <sys_page_alloc>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 89 00 00 00    	js     801dc9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	ff 75 f0             	pushl  -0x10(%ebp)
  801d46:	e8 52 f5 ff ff       	call   80129d <fd2data>
  801d4b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d52:	50                   	push   %eax
  801d53:	6a 00                	push   $0x0
  801d55:	56                   	push   %esi
  801d56:	6a 00                	push   $0x0
  801d58:	e8 91 ef ff ff       	call   800cee <sys_page_map>
  801d5d:	89 c3                	mov    %eax,%ebx
  801d5f:	83 c4 20             	add    $0x20,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 55                	js     801dbb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d74:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d7b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d84:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d89:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	e8 f2 f4 ff ff       	call   80128d <fd2num>
  801d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d9e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801da0:	83 c4 04             	add    $0x4,%esp
  801da3:	ff 75 f0             	pushl  -0x10(%ebp)
  801da6:	e8 e2 f4 ff ff       	call   80128d <fd2num>
  801dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	ba 00 00 00 00       	mov    $0x0,%edx
  801db9:	eb 30                	jmp    801deb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	56                   	push   %esi
  801dbf:	6a 00                	push   $0x0
  801dc1:	e8 6a ef ff ff       	call   800d30 <sys_page_unmap>
  801dc6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 5a ef ff ff       	call   800d30 <sys_page_unmap>
  801dd6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 4a ef ff ff       	call   800d30 <sys_page_unmap>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801deb:	89 d0                	mov    %edx,%eax
  801ded:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfd:	50                   	push   %eax
  801dfe:	ff 75 08             	pushl  0x8(%ebp)
  801e01:	e8 fd f4 ff ff       	call   801303 <fd_lookup>
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 d2                	test   %edx,%edx
  801e0d:	78 18                	js     801e27 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e0f:	83 ec 0c             	sub    $0xc,%esp
  801e12:	ff 75 f4             	pushl  -0xc(%ebp)
  801e15:	e8 83 f4 ff ff       	call   80129d <fd2data>
	return _pipeisclosed(fd, p);
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1f:	e8 2c fd ff ff       	call   801b50 <_pipeisclosed>
  801e24:	83 c4 10             	add    $0x10,%esp
}
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e39:	68 39 29 80 00       	push   $0x802939
  801e3e:	ff 75 0c             	pushl  0xc(%ebp)
  801e41:	e8 5b ea ff ff       	call   8008a1 <strcpy>
	return 0;
}
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	57                   	push   %edi
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e59:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e64:	eb 2e                	jmp    801e94 <devcons_write+0x47>
		m = n - tot;
  801e66:	8b 55 10             	mov    0x10(%ebp),%edx
  801e69:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801e6b:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801e70:	83 fa 7f             	cmp    $0x7f,%edx
  801e73:	77 02                	ja     801e77 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e75:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e77:	83 ec 04             	sub    $0x4,%esp
  801e7a:	56                   	push   %esi
  801e7b:	03 45 0c             	add    0xc(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	57                   	push   %edi
  801e80:	e8 ae eb ff ff       	call   800a33 <memmove>
		sys_cputs(buf, m);
  801e85:	83 c4 08             	add    $0x8,%esp
  801e88:	56                   	push   %esi
  801e89:	57                   	push   %edi
  801e8a:	e8 60 ed ff ff       	call   800bef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8f:	01 f3                	add    %esi,%ebx
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	89 d8                	mov    %ebx,%eax
  801e96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e99:	72 cb                	jb     801e66 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5f                   	pop    %edi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    

00801ea3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ea9:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801eae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb2:	75 07                	jne    801ebb <devcons_read+0x18>
  801eb4:	eb 28                	jmp    801ede <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb6:	e8 d1 ed ff ff       	call   800c8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ebb:	e8 4d ed ff ff       	call   800c0d <sys_cgetc>
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	74 f2                	je     801eb6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 16                	js     801ede <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec8:	83 f8 04             	cmp    $0x4,%eax
  801ecb:	74 0c                	je     801ed9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ecd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed0:	88 02                	mov    %al,(%edx)
	return 1;
  801ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed7:	eb 05                	jmp    801ede <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eec:	6a 01                	push   $0x1
  801eee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef1:	50                   	push   %eax
  801ef2:	e8 f8 ec ff ff       	call   800bef <sys_cputs>
  801ef7:	83 c4 10             	add    $0x10,%esp
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <getchar>:

int
getchar(void)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f02:	6a 01                	push   $0x1
  801f04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f07:	50                   	push   %eax
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 5d f6 ff ff       	call   80156c <read>
	if (r < 0)
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 0f                	js     801f25 <getchar+0x29>
		return r;
	if (r < 1)
  801f16:	85 c0                	test   %eax,%eax
  801f18:	7e 06                	jle    801f20 <getchar+0x24>
		return -E_EOF;
	return c;
  801f1a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1e:	eb 05                	jmp    801f25 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f20:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f30:	50                   	push   %eax
  801f31:	ff 75 08             	pushl  0x8(%ebp)
  801f34:	e8 ca f3 ff ff       	call   801303 <fd_lookup>
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 11                	js     801f51 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f49:	39 10                	cmp    %edx,(%eax)
  801f4b:	0f 94 c0             	sete   %al
  801f4e:	0f b6 c0             	movzbl %al,%eax
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <opencons>:

int
opencons(void)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5c:	50                   	push   %eax
  801f5d:	e8 52 f3 ff ff       	call   8012b4 <fd_alloc>
  801f62:	83 c4 10             	add    $0x10,%esp
		return r;
  801f65:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 3e                	js     801fa9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6b:	83 ec 04             	sub    $0x4,%esp
  801f6e:	68 07 04 00 00       	push   $0x407
  801f73:	ff 75 f4             	pushl  -0xc(%ebp)
  801f76:	6a 00                	push   $0x0
  801f78:	e8 2e ed ff ff       	call   800cab <sys_page_alloc>
  801f7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f80:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 23                	js     801fa9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	50                   	push   %eax
  801f9f:	e8 e9 f2 ff ff       	call   80128d <fd2num>
  801fa4:	89 c2                	mov    %eax,%edx
  801fa6:	83 c4 10             	add    $0x10,%esp
}
  801fa9:	89 d0                	mov    %edx,%eax
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fb3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fba:	75 2c                	jne    801fe8 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	6a 07                	push   $0x7
  801fc1:	68 00 f0 7f ee       	push   $0xee7ff000
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 de ec ff ff       	call   800cab <sys_page_alloc>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	79 14                	jns    801fe8 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801fd4:	83 ec 04             	sub    $0x4,%esp
  801fd7:	68 48 29 80 00       	push   $0x802948
  801fdc:	6a 1f                	push   $0x1f
  801fde:	68 ac 29 80 00       	push   $0x8029ac
  801fe3:	e8 5c e2 ff ff       	call   800244 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801ff0:	83 ec 08             	sub    $0x8,%esp
  801ff3:	68 1c 20 80 00       	push   $0x80201c
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 f7 ed ff ff       	call   800df6 <sys_env_set_pgfault_upcall>
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	79 14                	jns    80201a <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	68 74 29 80 00       	push   $0x802974
  80200e:	6a 25                	push   $0x25
  802010:	68 ac 29 80 00       	push   $0x8029ac
  802015:	e8 2a e2 ff ff       	call   800244 <_panic>
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80201c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80201d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802022:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802024:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  802027:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  802029:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  80202d:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  802031:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  802032:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  802035:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  802037:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  80203a:	83 c4 04             	add    $0x4,%esp
	popal 
  80203d:	61                   	popa   
	addl $4, %esp 
  80203e:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  802041:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  802042:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  802043:	c3                   	ret    
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	83 ec 10             	sub    $0x10,%esp
  802056:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80205a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80205e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802062:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802066:	85 d2                	test   %edx,%edx
  802068:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80206c:	89 34 24             	mov    %esi,(%esp)
  80206f:	89 c8                	mov    %ecx,%eax
  802071:	75 35                	jne    8020a8 <__udivdi3+0x58>
  802073:	39 f1                	cmp    %esi,%ecx
  802075:	0f 87 bd 00 00 00    	ja     802138 <__udivdi3+0xe8>
  80207b:	85 c9                	test   %ecx,%ecx
  80207d:	89 cd                	mov    %ecx,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f1                	div    %ecx
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c6                	mov    %eax,%esi
  802094:	89 f8                	mov    %edi,%eax
  802096:	f7 f5                	div    %ebp
  802098:	89 f2                	mov    %esi,%edx
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	5e                   	pop    %esi
  80209e:	5f                   	pop    %edi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    
  8020a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	3b 14 24             	cmp    (%esp),%edx
  8020ab:	77 7b                	ja     802128 <__udivdi3+0xd8>
  8020ad:	0f bd f2             	bsr    %edx,%esi
  8020b0:	83 f6 1f             	xor    $0x1f,%esi
  8020b3:	0f 84 97 00 00 00    	je     802150 <__udivdi3+0x100>
  8020b9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020be:	89 d7                	mov    %edx,%edi
  8020c0:	89 f1                	mov    %esi,%ecx
  8020c2:	29 f5                	sub    %esi,%ebp
  8020c4:	d3 e7                	shl    %cl,%edi
  8020c6:	89 c2                	mov    %eax,%edx
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	d3 ea                	shr    %cl,%edx
  8020cc:	89 f1                	mov    %esi,%ecx
  8020ce:	09 fa                	or     %edi,%edx
  8020d0:	8b 3c 24             	mov    (%esp),%edi
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020df:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020e3:	89 fa                	mov    %edi,%edx
  8020e5:	d3 ea                	shr    %cl,%edx
  8020e7:	89 f1                	mov    %esi,%ecx
  8020e9:	d3 e7                	shl    %cl,%edi
  8020eb:	89 e9                	mov    %ebp,%ecx
  8020ed:	d3 e8                	shr    %cl,%eax
  8020ef:	09 c7                	or     %eax,%edi
  8020f1:	89 f8                	mov    %edi,%eax
  8020f3:	f7 74 24 08          	divl   0x8(%esp)
  8020f7:	89 d5                	mov    %edx,%ebp
  8020f9:	89 c7                	mov    %eax,%edi
  8020fb:	f7 64 24 0c          	mull   0xc(%esp)
  8020ff:	39 d5                	cmp    %edx,%ebp
  802101:	89 14 24             	mov    %edx,(%esp)
  802104:	72 11                	jb     802117 <__udivdi3+0xc7>
  802106:	8b 54 24 04          	mov    0x4(%esp),%edx
  80210a:	89 f1                	mov    %esi,%ecx
  80210c:	d3 e2                	shl    %cl,%edx
  80210e:	39 c2                	cmp    %eax,%edx
  802110:	73 5e                	jae    802170 <__udivdi3+0x120>
  802112:	3b 2c 24             	cmp    (%esp),%ebp
  802115:	75 59                	jne    802170 <__udivdi3+0x120>
  802117:	8d 47 ff             	lea    -0x1(%edi),%eax
  80211a:	31 f6                	xor    %esi,%esi
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	31 f6                	xor    %esi,%esi
  80212a:	31 c0                	xor    %eax,%eax
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 f2                	mov    %esi,%edx
  80213a:	31 f6                	xor    %esi,%esi
  80213c:	89 f8                	mov    %edi,%eax
  80213e:	f7 f1                	div    %ecx
  802140:	89 f2                	mov    %esi,%edx
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802154:	76 0b                	jbe    802161 <__udivdi3+0x111>
  802156:	31 c0                	xor    %eax,%eax
  802158:	3b 14 24             	cmp    (%esp),%edx
  80215b:	0f 83 37 ff ff ff    	jae    802098 <__udivdi3+0x48>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	e9 2d ff ff ff       	jmp    802098 <__udivdi3+0x48>
  80216b:	90                   	nop
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 f8                	mov    %edi,%eax
  802172:	31 f6                	xor    %esi,%esi
  802174:	e9 1f ff ff ff       	jmp    802098 <__udivdi3+0x48>
  802179:	66 90                	xchg   %ax,%ax
  80217b:	66 90                	xchg   %ax,%ax
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	83 ec 20             	sub    $0x20,%esp
  802186:	8b 44 24 34          	mov    0x34(%esp),%eax
  80218a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802192:	89 c6                	mov    %eax,%esi
  802194:	89 44 24 10          	mov    %eax,0x10(%esp)
  802198:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80219c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021ac:	85 c0                	test   %eax,%eax
  8021ae:	89 c2                	mov    %eax,%edx
  8021b0:	75 1e                	jne    8021d0 <__umoddi3+0x50>
  8021b2:	39 f7                	cmp    %esi,%edi
  8021b4:	76 52                	jbe    802208 <__umoddi3+0x88>
  8021b6:	89 c8                	mov    %ecx,%eax
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	f7 f7                	div    %edi
  8021bc:	89 d0                	mov    %edx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	83 c4 20             	add    $0x20,%esp
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    
  8021c7:	89 f6                	mov    %esi,%esi
  8021c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021d0:	39 f0                	cmp    %esi,%eax
  8021d2:	77 5c                	ja     802230 <__umoddi3+0xb0>
  8021d4:	0f bd e8             	bsr    %eax,%ebp
  8021d7:	83 f5 1f             	xor    $0x1f,%ebp
  8021da:	75 64                	jne    802240 <__umoddi3+0xc0>
  8021dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021e4:	0f 86 f6 00 00 00    	jbe    8022e0 <__umoddi3+0x160>
  8021ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021ee:	0f 82 ec 00 00 00    	jb     8022e0 <__umoddi3+0x160>
  8021f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8021fc:	83 c4 20             	add    $0x20,%esp
  8021ff:	5e                   	pop    %esi
  802200:	5f                   	pop    %edi
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    
  802203:	90                   	nop
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	85 ff                	test   %edi,%edi
  80220a:	89 fd                	mov    %edi,%ebp
  80220c:	75 0b                	jne    802219 <__umoddi3+0x99>
  80220e:	b8 01 00 00 00       	mov    $0x1,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f7                	div    %edi
  802217:	89 c5                	mov    %eax,%ebp
  802219:	8b 44 24 10          	mov    0x10(%esp),%eax
  80221d:	31 d2                	xor    %edx,%edx
  80221f:	f7 f5                	div    %ebp
  802221:	89 c8                	mov    %ecx,%eax
  802223:	f7 f5                	div    %ebp
  802225:	eb 95                	jmp    8021bc <__umoddi3+0x3c>
  802227:	89 f6                	mov    %esi,%esi
  802229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 20             	add    $0x20,%esp
  802237:	5e                   	pop    %esi
  802238:	5f                   	pop    %edi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
  80223b:	90                   	nop
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	b8 20 00 00 00       	mov    $0x20,%eax
  802245:	89 e9                	mov    %ebp,%ecx
  802247:	29 e8                	sub    %ebp,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 c7                	mov    %eax,%edi
  80224d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802251:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 c1                	mov    %eax,%ecx
  80225b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80225f:	09 d1                	or     %edx,%ecx
  802261:	89 fa                	mov    %edi,%edx
  802263:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802267:	89 e9                	mov    %ebp,%ecx
  802269:	d3 e0                	shl    %cl,%eax
  80226b:	89 f9                	mov    %edi,%ecx
  80226d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802271:	89 f0                	mov    %esi,%eax
  802273:	d3 e8                	shr    %cl,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	89 c7                	mov    %eax,%edi
  802279:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80227d:	d3 e6                	shl    %cl,%esi
  80227f:	89 d1                	mov    %edx,%ecx
  802281:	89 fa                	mov    %edi,%edx
  802283:	d3 e8                	shr    %cl,%eax
  802285:	89 e9                	mov    %ebp,%ecx
  802287:	09 f0                	or     %esi,%eax
  802289:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80228d:	f7 74 24 10          	divl   0x10(%esp)
  802291:	d3 e6                	shl    %cl,%esi
  802293:	89 d1                	mov    %edx,%ecx
  802295:	f7 64 24 0c          	mull   0xc(%esp)
  802299:	39 d1                	cmp    %edx,%ecx
  80229b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80229f:	89 d7                	mov    %edx,%edi
  8022a1:	89 c6                	mov    %eax,%esi
  8022a3:	72 0a                	jb     8022af <__umoddi3+0x12f>
  8022a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022a9:	73 10                	jae    8022bb <__umoddi3+0x13b>
  8022ab:	39 d1                	cmp    %edx,%ecx
  8022ad:	75 0c                	jne    8022bb <__umoddi3+0x13b>
  8022af:	89 d7                	mov    %edx,%edi
  8022b1:	89 c6                	mov    %eax,%esi
  8022b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022bb:	89 ca                	mov    %ecx,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022c3:	29 f0                	sub    %esi,%eax
  8022c5:	19 fa                	sbb    %edi,%edx
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022ce:	89 d7                	mov    %edx,%edi
  8022d0:	d3 e7                	shl    %cl,%edi
  8022d2:	89 e9                	mov    %ebp,%ecx
  8022d4:	09 f8                	or     %edi,%eax
  8022d6:	d3 ea                	shr    %cl,%edx
  8022d8:	83 c4 20             	add    $0x20,%esp
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    
  8022df:	90                   	nop
  8022e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022e4:	29 f9                	sub    %edi,%ecx
  8022e6:	19 c6                	sbb    %eax,%esi
  8022e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022f0:	e9 ff fe ff ff       	jmp    8021f4 <__umoddi3+0x74>
