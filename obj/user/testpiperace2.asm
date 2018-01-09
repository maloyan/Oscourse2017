
obj/user/testpiperace2:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 00 23 80 00       	push   $0x802300
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 18 1b 00 00       	call   801b69 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %i", r);
  800058:	50                   	push   %eax
  800059:	68 4e 23 80 00       	push   $0x80234e
  80005e:	6a 0d                	push   $0xd
  800060:	68 57 23 80 00       	push   $0x802357
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 38 0f 00 00       	call   800fa7 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %i", r);
  800075:	50                   	push   %eax
  800076:	68 99 27 80 00       	push   $0x802799
  80007b:	6a 0f                	push   $0xf
  80007d:	68 57 23 80 00       	push   $0x802357
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 99 12 00 00       	call   80132f <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 6c 23 80 00       	push   $0x80236c
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 a9 12 00 00       	call   801381 <dup>
			sys_yield();
  8000d8:	e8 a1 0b 00 00       	call   800c7e <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 46 12 00 00       	call   80132f <close>
			sys_yield();
  8000e9:	e8 90 0b 00 00       	call   800c7e <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c c5 00 00 00 00 	lea    0x0(,%eax,8),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 9a 1b 00 00       	call   801cbc <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 25                	je     80014e <umain+0x11b>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 70 23 80 00       	push   $0x802370
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 e0 0a 00 00       	call   800c1e <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	83 c3 50             	add    $0x50,%ebx
  80014e:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 8c 23 80 00       	push   $0x80238c
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 4b 1b 00 00       	call   801cbc <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 24 23 80 00       	push   $0x802324
  800180:	6a 40                	push   $0x40
  800182:	68 57 23 80 00       	push   $0x802357
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 6b 10 00 00       	call   801206 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %i", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 a2 23 80 00       	push   $0x8023a2
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 57 23 80 00       	push   $0x802357
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 e1 0f 00 00       	call   8011a0 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 ba 23 80 00 	movl   $0x8023ba,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001e1:	e8 79 0a 00 00       	call   800c5f <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 78             	imul   $0x78,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
  800212:	83 c4 10             	add    $0x10,%esp
#endif
}
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 35 11 00 00       	call   80135c <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 ed 09 00 00       	call   800c1e <sys_env_destroy>
  800231:	83 c4 10             	add    $0x10,%esp
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 16 0a 00 00       	call   800c5f <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 d8 23 80 00       	push   $0x8023d8
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 8a 23 80 00 	movl   $0x80238a,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 35 09 00 00       	call   800be1 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 4f 01 00 00       	call   800441 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 da 08 00 00       	call   800be1 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 d1                	mov    %edx,%ecx
  800338:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033e:	8b 45 10             	mov    0x10(%ebp),%eax
  800341:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800344:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800347:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800351:	72 05                	jb     800358 <printnum+0x35>
  800353:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800356:	77 3e                	ja     800396 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	83 eb 01             	sub    $0x1,%ebx
  800361:	53                   	push   %ebx
  800362:	50                   	push   %eax
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 c9 1c 00 00       	call   802040 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 13                	jmp    80039d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800396:	83 eb 01             	sub    $0x1,%ebx
  800399:	85 db                	test   %ebx,%ebx
  80039b:	7f ed                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	56                   	push   %esi
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b0:	e8 bb 1d 00 00       	call   802170 <__umoddi3>
  8003b5:	83 c4 14             	add    $0x14,%esp
  8003b8:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8003bf:	50                   	push   %eax
  8003c0:	ff d7                	call   *%edi
  8003c2:	83 c4 10             	add    $0x10,%esp
}
  8003c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c8:	5b                   	pop    %ebx
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d0:	83 fa 01             	cmp    $0x1,%edx
  8003d3:	7e 0e                	jle    8003e3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	8b 52 04             	mov    0x4(%edx),%edx
  8003e1:	eb 22                	jmp    800405 <getuint+0x38>
	else if (lflag)
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	74 10                	je     8003f7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ec:	89 08                	mov    %ecx,(%eax)
  8003ee:	8b 02                	mov    (%edx),%eax
  8003f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f5:	eb 0e                	jmp    800405 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f7:	8b 10                	mov    (%eax),%edx
  8003f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fc:	89 08                	mov    %ecx,(%eax)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800411:	8b 10                	mov    (%eax),%edx
  800413:	3b 50 04             	cmp    0x4(%eax),%edx
  800416:	73 0a                	jae    800422 <sprintputch+0x1b>
		*b->buf++ = ch;
  800418:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	88 02                	mov    %al,(%edx)
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042d:	50                   	push   %eax
  80042e:	ff 75 10             	pushl  0x10(%ebp)
  800431:	ff 75 0c             	pushl  0xc(%ebp)
  800434:	ff 75 08             	pushl  0x8(%ebp)
  800437:	e8 05 00 00 00       	call   800441 <vprintfmt>
	va_end(ap);
  80043c:	83 c4 10             	add    $0x10,%esp
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 2c             	sub    $0x2c,%esp
  80044a:	8b 75 08             	mov    0x8(%ebp),%esi
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800450:	8b 7d 10             	mov    0x10(%ebp),%edi
  800453:	eb 12                	jmp    800467 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800455:	85 c0                	test   %eax,%eax
  800457:	0f 84 8d 03 00 00    	je     8007ea <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	50                   	push   %eax
  800462:	ff d6                	call   *%esi
  800464:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800467:	83 c7 01             	add    $0x1,%edi
  80046a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046e:	83 f8 25             	cmp    $0x25,%eax
  800471:	75 e2                	jne    800455 <vprintfmt+0x14>
  800473:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800477:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80048c:	ba 00 00 00 00       	mov    $0x0,%edx
  800491:	eb 07                	jmp    80049a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800496:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8d 47 01             	lea    0x1(%edi),%eax
  80049d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a0:	0f b6 07             	movzbl (%edi),%eax
  8004a3:	0f b6 c8             	movzbl %al,%ecx
  8004a6:	83 e8 23             	sub    $0x23,%eax
  8004a9:	3c 55                	cmp    $0x55,%al
  8004ab:	0f 87 1e 03 00 00    	ja     8007cf <vprintfmt+0x38e>
  8004b1:	0f b6 c0             	movzbl %al,%eax
  8004b4:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c2:	eb d6                	jmp    80049a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004dc:	83 fa 09             	cmp    $0x9,%edx
  8004df:	77 38                	ja     800519 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e4:	eb e9                	jmp    8004cf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f7:	eb 26                	jmp    80051f <vprintfmt+0xde>
  8004f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fc:	89 c8                	mov    %ecx,%eax
  8004fe:	c1 f8 1f             	sar    $0x1f,%eax
  800501:	f7 d0                	not    %eax
  800503:	21 c1                	and    %eax,%ecx
  800505:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050b:	eb 8d                	jmp    80049a <vprintfmt+0x59>
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800510:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800517:	eb 81                	jmp    80049a <vprintfmt+0x59>
  800519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800523:	0f 89 71 ff ff ff    	jns    80049a <vprintfmt+0x59>
				width = precision, precision = -1;
  800529:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800536:	e9 5f ff ff ff       	jmp    80049a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800541:	e9 54 ff ff ff       	jmp    80049a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	ff 30                	pushl  (%eax)
  800555:	ff d6                	call   *%esi
			break;
  800557:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055d:	e9 05 ff ff ff       	jmp    800467 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	99                   	cltd   
  80056e:	31 d0                	xor    %edx,%eax
  800570:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800572:	83 f8 0f             	cmp    $0xf,%eax
  800575:	7f 0b                	jg     800582 <vprintfmt+0x141>
  800577:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	75 18                	jne    80059a <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800582:	50                   	push   %eax
  800583:	68 13 24 80 00       	push   $0x802413
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 95 fe ff ff       	call   800424 <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800595:	e9 cd fe ff ff       	jmp    800467 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80059a:	52                   	push   %edx
  80059b:	68 81 28 80 00       	push   $0x802881
  8005a0:	53                   	push   %ebx
  8005a1:	56                   	push   %esi
  8005a2:	e8 7d fe ff ff       	call   800424 <printfmt>
  8005a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 b5 fe ff ff       	jmp    800467 <vprintfmt+0x26>
  8005b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 38                	mov    (%eax),%edi
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	75 05                	jne    8005cf <vprintfmt+0x18e>
				p = "(null)";
  8005ca:	bf 0c 24 80 00       	mov    $0x80240c,%edi
			if (width > 0 && padc != '-')
  8005cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d3:	0f 84 91 00 00 00    	je     80066a <vprintfmt+0x229>
  8005d9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005dd:	0f 8e 95 00 00 00    	jle    800678 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	51                   	push   %ecx
  8005e7:	57                   	push   %edi
  8005e8:	e8 85 02 00 00       	call   800872 <strnlen>
  8005ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c5>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	89 c8                	mov    %ecx,%eax
  800621:	c1 f8 1f             	sar    $0x1f,%eax
  800624:	f7 d0                	not    %eax
  800626:	21 c8                	and    %ecx,%eax
  800628:	29 c1                	sub    %eax,%ecx
  80062a:	89 75 08             	mov    %esi,0x8(%ebp)
  80062d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800630:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800633:	89 cb                	mov    %ecx,%ebx
  800635:	eb 4d                	jmp    800684 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800637:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063b:	74 1b                	je     800658 <vprintfmt+0x217>
  80063d:	0f be c0             	movsbl %al,%eax
  800640:	83 e8 20             	sub    $0x20,%eax
  800643:	83 f8 5e             	cmp    $0x5e,%eax
  800646:	76 10                	jbe    800658 <vprintfmt+0x217>
					putch('?', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	ff 75 0c             	pushl  0xc(%ebp)
  80064e:	6a 3f                	push   $0x3f
  800650:	ff 55 08             	call   *0x8(%ebp)
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 0d                	jmp    800665 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	52                   	push   %edx
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	83 eb 01             	sub    $0x1,%ebx
  800668:	eb 1a                	jmp    800684 <vprintfmt+0x243>
  80066a:	89 75 08             	mov    %esi,0x8(%ebp)
  80066d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800670:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800673:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800676:	eb 0c                	jmp    800684 <vprintfmt+0x243>
  800678:	89 75 08             	mov    %esi,0x8(%ebp)
  80067b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800681:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800684:	83 c7 01             	add    $0x1,%edi
  800687:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068b:	0f be d0             	movsbl %al,%edx
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 23                	je     8006b5 <vprintfmt+0x274>
  800692:	85 f6                	test   %esi,%esi
  800694:	78 a1                	js     800637 <vprintfmt+0x1f6>
  800696:	83 ee 01             	sub    $0x1,%esi
  800699:	79 9c                	jns    800637 <vprintfmt+0x1f6>
  80069b:	89 df                	mov    %ebx,%edi
  80069d:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a3:	eb 18                	jmp    8006bd <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 20                	push   $0x20
  8006ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ad:	83 ef 01             	sub    $0x1,%edi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb 08                	jmp    8006bd <vprintfmt+0x27c>
  8006b5:	89 df                	mov    %ebx,%edi
  8006b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	7f e4                	jg     8006a5 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c4:	e9 9e fd ff ff       	jmp    800467 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c9:	83 fa 01             	cmp    $0x1,%edx
  8006cc:	7e 16                	jle    8006e4 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 08             	lea    0x8(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d7:	8b 50 04             	mov    0x4(%eax),%edx
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e2:	eb 32                	jmp    800716 <vprintfmt+0x2d5>
	else if (lflag)
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	74 18                	je     800700 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 c1                	mov    %eax,%ecx
  8006f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fe:	eb 16                	jmp    800716 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 04             	lea    0x4(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070e:	89 c1                	mov    %eax,%ecx
  800710:	c1 f9 1f             	sar    $0x1f,%ecx
  800713:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800716:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800719:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800721:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800725:	79 74                	jns    80079b <vprintfmt+0x35a>
				putch('-', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 2d                	push   $0x2d
  80072d:	ff d6                	call   *%esi
				num = -(long long) num;
  80072f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800732:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800735:	f7 d8                	neg    %eax
  800737:	83 d2 00             	adc    $0x0,%edx
  80073a:	f7 da                	neg    %edx
  80073c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80073f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800744:	eb 55                	jmp    80079b <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 7f fc ff ff       	call   8003cd <getuint>
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800753:	eb 46                	jmp    80079b <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 70 fc ff ff       	call   8003cd <getuint>
			base = 8;
  80075d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800762:	eb 37                	jmp    80079b <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 30                	push   $0x30
  80076a:	ff d6                	call   *%esi
			putch('x', putdat);
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 78                	push   $0x78
  800772:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800784:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800787:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078c:	eb 0d                	jmp    80079b <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 37 fc ff ff       	call   8003cd <getuint>
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079b:	83 ec 0c             	sub    $0xc,%esp
  80079e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a2:	57                   	push   %edi
  8007a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a6:	51                   	push   %ecx
  8007a7:	52                   	push   %edx
  8007a8:	50                   	push   %eax
  8007a9:	89 da                	mov    %ebx,%edx
  8007ab:	89 f0                	mov    %esi,%eax
  8007ad:	e8 71 fb ff ff       	call   800323 <printnum>
			break;
  8007b2:	83 c4 20             	add    $0x20,%esp
  8007b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b8:	e9 aa fc ff ff       	jmp    800467 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	53                   	push   %ebx
  8007c1:	51                   	push   %ecx
  8007c2:	ff d6                	call   *%esi
			break;
  8007c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ca:	e9 98 fc ff ff       	jmp    800467 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 25                	push   $0x25
  8007d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 03                	jmp    8007df <vprintfmt+0x39e>
  8007dc:	83 ef 01             	sub    $0x1,%edi
  8007df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e3:	75 f7                	jne    8007dc <vprintfmt+0x39b>
  8007e5:	e9 7d fc ff ff       	jmp    800467 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5f                   	pop    %edi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 18             	sub    $0x18,%esp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800801:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800805:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080f:	85 c0                	test   %eax,%eax
  800811:	74 26                	je     800839 <vsnprintf+0x47>
  800813:	85 d2                	test   %edx,%edx
  800815:	7e 22                	jle    800839 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800817:	ff 75 14             	pushl  0x14(%ebp)
  80081a:	ff 75 10             	pushl  0x10(%ebp)
  80081d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	68 07 04 80 00       	push   $0x800407
  800826:	e8 16 fc ff ff       	call   800441 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800834:	83 c4 10             	add    $0x10,%esp
  800837:	eb 05                	jmp    80083e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800849:	50                   	push   %eax
  80084a:	ff 75 10             	pushl  0x10(%ebp)
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 9a ff ff ff       	call   8007f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	eb 03                	jmp    80086a <strlen+0x10>
		n++;
  800867:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086e:	75 f7                	jne    800867 <strlen+0xd>
		n++;
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	ba 00 00 00 00       	mov    $0x0,%edx
  800880:	eb 03                	jmp    800885 <strnlen+0x13>
		n++;
  800882:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 08                	je     800891 <strnlen+0x1f>
  800889:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088d:	75 f3                	jne    800882 <strnlen+0x10>
  80088f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	83 c2 01             	add    $0x1,%edx
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ef                	jne    80089f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ba:	53                   	push   %ebx
  8008bb:	e8 9a ff ff ff       	call   80085a <strlen>
  8008c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c3:	ff 75 0c             	pushl  0xc(%ebp)
  8008c6:	01 d8                	add    %ebx,%eax
  8008c8:	50                   	push   %eax
  8008c9:	e8 c5 ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	89 f3                	mov    %esi,%ebx
  8008e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	89 f2                	mov    %esi,%edx
  8008e7:	eb 0f                	jmp    8008f8 <strncpy+0x23>
		*dst++ = *src;
  8008e9:	83 c2 01             	add    $0x1,%edx
  8008ec:	0f b6 01             	movzbl (%ecx),%eax
  8008ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f8:	39 da                	cmp    %ebx,%edx
  8008fa:	75 ed                	jne    8008e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fc:	89 f0                	mov    %esi,%eax
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	8b 55 10             	mov    0x10(%ebp),%edx
  800910:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800912:	85 d2                	test   %edx,%edx
  800914:	74 21                	je     800937 <strlcpy+0x35>
  800916:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091a:	89 f2                	mov    %esi,%edx
  80091c:	eb 09                	jmp    800927 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091e:	83 c2 01             	add    $0x1,%edx
  800921:	83 c1 01             	add    $0x1,%ecx
  800924:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800927:	39 c2                	cmp    %eax,%edx
  800929:	74 09                	je     800934 <strlcpy+0x32>
  80092b:	0f b6 19             	movzbl (%ecx),%ebx
  80092e:	84 db                	test   %bl,%bl
  800930:	75 ec                	jne    80091e <strlcpy+0x1c>
  800932:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800934:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800937:	29 f0                	sub    %esi,%eax
}
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800946:	eb 06                	jmp    80094e <strcmp+0x11>
		p++, q++;
  800948:	83 c1 01             	add    $0x1,%ecx
  80094b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	84 c0                	test   %al,%al
  800953:	74 04                	je     800959 <strcmp+0x1c>
  800955:	3a 02                	cmp    (%edx),%al
  800957:	74 ef                	je     800948 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 c0             	movzbl %al,%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 c3                	mov    %eax,%ebx
  80096f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800972:	eb 06                	jmp    80097a <strncmp+0x17>
		n--, p++, q++;
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097a:	39 d8                	cmp    %ebx,%eax
  80097c:	74 15                	je     800993 <strncmp+0x30>
  80097e:	0f b6 08             	movzbl (%eax),%ecx
  800981:	84 c9                	test   %cl,%cl
  800983:	74 04                	je     800989 <strncmp+0x26>
  800985:	3a 0a                	cmp    (%edx),%cl
  800987:	74 eb                	je     800974 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800989:	0f b6 00             	movzbl (%eax),%eax
  80098c:	0f b6 12             	movzbl (%edx),%edx
  80098f:	29 d0                	sub    %edx,%eax
  800991:	eb 05                	jmp    800998 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strchr+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0f                	je     8009ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c6:	eb 03                	jmp    8009cb <strfind+0xf>
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ce:	84 d2                	test   %dl,%dl
  8009d0:	74 04                	je     8009d6 <strfind+0x1a>
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	75 f2                	jne    8009c8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 36                	je     800a1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ee:	75 28                	jne    800a18 <memset+0x40>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 23                	jne    800a18 <memset+0x40>
		c &= 0xFF;
  8009f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f9:	89 d3                	mov    %edx,%ebx
  8009fb:	c1 e3 08             	shl    $0x8,%ebx
  8009fe:	89 d6                	mov    %edx,%esi
  800a00:	c1 e6 18             	shl    $0x18,%esi
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	c1 e0 10             	shl    $0x10,%eax
  800a08:	09 f0                	or     %esi,%eax
  800a0a:	09 c2                	or     %eax,%edx
  800a0c:	89 d0                	mov    %edx,%eax
  800a0e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a10:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a13:	fc                   	cld    
  800a14:	f3 ab                	rep stos %eax,%es:(%edi)
  800a16:	eb 06                	jmp    800a1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	fc                   	cld    
  800a1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1e:	89 f8                	mov    %edi,%eax
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5f                   	pop    %edi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a33:	39 c6                	cmp    %eax,%esi
  800a35:	73 35                	jae    800a6c <memmove+0x47>
  800a37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	73 2e                	jae    800a6c <memmove+0x47>
		s += n;
		d += n;
  800a3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4b:	75 13                	jne    800a60 <memmove+0x3b>
  800a4d:	f6 c1 03             	test   $0x3,%cl
  800a50:	75 0e                	jne    800a60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a52:	83 ef 04             	sub    $0x4,%edi
  800a55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a58:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5b:	fd                   	std    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 09                	jmp    800a69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	fd                   	std    
  800a67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a69:	fc                   	cld    
  800a6a:	eb 1d                	jmp    800a89 <memmove+0x64>
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	f6 c2 03             	test   $0x3,%dl
  800a73:	75 0f                	jne    800a84 <memmove+0x5f>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0a                	jne    800a84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 05                	jmp    800a89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	fc                   	cld    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a90:	ff 75 10             	pushl  0x10(%ebp)
  800a93:	ff 75 0c             	pushl  0xc(%ebp)
  800a96:	ff 75 08             	pushl  0x8(%ebp)
  800a99:	e8 87 ff ff ff       	call   800a25 <memmove>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aab:	89 c6                	mov    %eax,%esi
  800aad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab0:	eb 1a                	jmp    800acc <memcmp+0x2c>
		if (*s1 != *s2)
  800ab2:	0f b6 08             	movzbl (%eax),%ecx
  800ab5:	0f b6 1a             	movzbl (%edx),%ebx
  800ab8:	38 d9                	cmp    %bl,%cl
  800aba:	74 0a                	je     800ac6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abc:	0f b6 c1             	movzbl %cl,%eax
  800abf:	0f b6 db             	movzbl %bl,%ebx
  800ac2:	29 d8                	sub    %ebx,%eax
  800ac4:	eb 0f                	jmp    800ad5 <memcmp+0x35>
		s1++, s2++;
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 f0                	cmp    %esi,%eax
  800ace:	75 e2                	jne    800ab2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	eb 07                	jmp    800af0 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	38 08                	cmp    %cl,(%eax)
  800aeb:	74 07                	je     800af4 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	72 f5                	jb     800ae9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 03                	jmp    800b07 <strtol+0x11>
		s++;
  800b04:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	3c 09                	cmp    $0x9,%al
  800b0c:	74 f6                	je     800b04 <strtol+0xe>
  800b0e:	3c 20                	cmp    $0x20,%al
  800b10:	74 f2                	je     800b04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b12:	3c 2b                	cmp    $0x2b,%al
  800b14:	75 0a                	jne    800b20 <strtol+0x2a>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 10                	jmp    800b30 <strtol+0x3a>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b25:	3c 2d                	cmp    $0x2d,%al
  800b27:	75 07                	jne    800b30 <strtol+0x3a>
		s++, neg = 1;
  800b29:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b2c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	0f 94 c0             	sete   %al
  800b35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3b:	75 19                	jne    800b56 <strtol+0x60>
  800b3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b40:	75 14                	jne    800b56 <strtol+0x60>
  800b42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b46:	0f 85 8a 00 00 00    	jne    800bd6 <strtol+0xe0>
		s += 2, base = 16;
  800b4c:	83 c1 02             	add    $0x2,%ecx
  800b4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b54:	eb 16                	jmp    800b6c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b56:	84 c0                	test   %al,%al
  800b58:	74 12                	je     800b6c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b62:	75 08                	jne    800b6c <strtol+0x76>
		s++, base = 8;
  800b64:	83 c1 01             	add    $0x1,%ecx
  800b67:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b74:	0f b6 11             	movzbl (%ecx),%edx
  800b77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 09             	cmp    $0x9,%bl
  800b7f:	77 08                	ja     800b89 <strtol+0x93>
			dig = *s - '0';
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 30             	sub    $0x30,%edx
  800b87:	eb 22                	jmp    800bab <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b89:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 08                	ja     800b9b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 57             	sub    $0x57,%edx
  800b99:	eb 10                	jmp    800bab <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 16                	ja     800bbb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba5:	0f be d2             	movsbl %dl,%edx
  800ba8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bae:	7d 0f                	jge    800bbf <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb9:	eb b9                	jmp    800b74 <strtol+0x7e>
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	eb 02                	jmp    800bc1 <strtol+0xcb>
  800bbf:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc5:	74 05                	je     800bcc <strtol+0xd6>
		*endptr = (char *) s;
  800bc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bca:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bcc:	85 ff                	test   %edi,%edi
  800bce:	74 0c                	je     800bdc <strtol+0xe6>
  800bd0:	89 d0                	mov    %edx,%eax
  800bd2:	f7 d8                	neg    %eax
  800bd4:	eb 06                	jmp    800bdc <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd6:	84 c0                	test   %al,%al
  800bd8:	75 8a                	jne    800b64 <strtol+0x6e>
  800bda:	eb 90                	jmp    800b6c <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 c3                	mov    %eax,%ebx
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_cgetc>:

int
sys_cgetc(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 cb                	mov    %ecx,%ebx
  800c36:	89 cf                	mov    %ecx,%edi
  800c38:	89 ce                	mov    %ecx,%esi
  800c3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 03                	push   $0x3
  800c46:	68 1f 27 80 00       	push   $0x80271f
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 3c 27 80 00       	push   $0x80273c
  800c52:	e8 df f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6f:	89 d1                	mov    %edx,%ecx
  800c71:	89 d3                	mov    %edx,%ebx
  800c73:	89 d7                	mov    %edx,%edi
  800c75:	89 d6                	mov    %edx,%esi
  800c77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_yield>:

void
sys_yield(void)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ca6:	be 00 00 00 00       	mov    $0x0,%esi
  800cab:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb9:	89 f7                	mov    %esi,%edi
  800cbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 04                	push   $0x4
  800cc7:	68 1f 27 80 00       	push   $0x80271f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 3c 27 80 00       	push   $0x80273c
  800cd3:	e8 5e f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 05                	push   $0x5
  800d09:	68 1f 27 80 00       	push   $0x80271f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 3c 27 80 00       	push   $0x80273c
  800d15:	e8 1c f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 06 00 00 00       	mov    $0x6,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 06                	push   $0x6
  800d4b:	68 1f 27 80 00       	push   $0x80271f
  800d50:	6a 23                	push   $0x23
  800d52:	68 3c 27 80 00       	push   $0x80273c
  800d57:	e8 da f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 08 00 00 00       	mov    $0x8,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 08                	push   $0x8
  800d8d:	68 1f 27 80 00       	push   $0x80271f
  800d92:	6a 23                	push   $0x23
  800d94:	68 3c 27 80 00       	push   $0x80273c
  800d99:	e8 98 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 09 00 00 00       	mov    $0x9,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 09                	push   $0x9
  800dcf:	68 1f 27 80 00       	push   $0x80271f
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 3c 27 80 00       	push   $0x80273c
  800ddb:	e8 56 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0a                	push   $0xa
  800e11:	68 1f 27 80 00       	push   $0x80271f
  800e16:	6a 23                	push   $0x23
  800e18:	68 3c 27 80 00       	push   $0x80273c
  800e1d:	e8 14 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 cb                	mov    %ecx,%ebx
  800e65:	89 cf                	mov    %ecx,%edi
  800e67:	89 ce                	mov    %ecx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 0d                	push   $0xd
  800e75:	68 1f 27 80 00       	push   $0x80271f
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 3c 27 80 00       	push   $0x80273c
  800e81:	e8 b0 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_gettime>:

int sys_gettime(void)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e94:	ba 00 00 00 00       	mov    $0x0,%edx
  800e99:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9e:	89 d1                	mov    %edx,%ecx
  800ea0:	89 d3                	mov    %edx,%ebx
  800ea2:	89 d7                	mov    %edx,%edi
  800ea4:	89 d6                	mov    %edx,%esi
  800ea6:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800eb7:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800eb9:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ebd:	74 2e                	je     800eed <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 16             	shr    $0x16,%edx
  800ec4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 1d                	je     800eed <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 0c             	shr    $0xc,%edx
  800ed5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800edc:	f6 c1 01             	test   $0x1,%cl
  800edf:	74 0c                	je     800eed <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800ee1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800ee8:	f6 c6 08             	test   $0x8,%dh
  800eeb:	75 14                	jne    800f01 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	68 4a 27 80 00       	push   $0x80274a
  800ef5:	6a 28                	push   $0x28
  800ef7:	68 5c 27 80 00       	push   $0x80275c
  800efc:	e8 35 f3 ff ff       	call   800236 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800f01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f06:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	6a 07                	push   $0x7
  800f0d:	68 00 f0 7f 00       	push   $0x7ff000
  800f12:	6a 00                	push   $0x0
  800f14:	e8 84 fd ff ff       	call   800c9d <sys_page_alloc>
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	79 14                	jns    800f34 <pgfault+0x87>
		panic("sys_page_alloc");
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	68 67 27 80 00       	push   $0x802767
  800f28:	6a 2c                	push   $0x2c
  800f2a:	68 5c 27 80 00       	push   $0x80275c
  800f2f:	e8 02 f3 ff ff       	call   800236 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	68 00 10 00 00       	push   $0x1000
  800f3c:	53                   	push   %ebx
  800f3d:	68 00 f0 7f 00       	push   $0x7ff000
  800f42:	e8 46 fb ff ff       	call   800a8d <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f47:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4e:	53                   	push   %ebx
  800f4f:	6a 00                	push   $0x0
  800f51:	68 00 f0 7f 00       	push   $0x7ff000
  800f56:	6a 00                	push   $0x0
  800f58:	e8 83 fd ff ff       	call   800ce0 <sys_page_map>
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 14                	jns    800f78 <pgfault+0xcb>
		panic("sys_page_map");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 76 27 80 00       	push   $0x802776
  800f6c:	6a 2f                	push   $0x2f
  800f6e:	68 5c 27 80 00       	push   $0x80275c
  800f73:	e8 be f2 ff ff       	call   800236 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	6a 00                	push   $0x0
  800f82:	e8 9b fd ff ff       	call   800d22 <sys_page_unmap>
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 14                	jns    800fa2 <pgfault+0xf5>
		panic("sys_page_unmap");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 83 27 80 00       	push   $0x802783
  800f96:	6a 31                	push   $0x31
  800f98:	68 5c 27 80 00       	push   $0x80275c
  800f9d:	e8 94 f2 ff ff       	call   800236 <_panic>
	return;
}
  800fa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  800fb0:	68 ad 0e 80 00       	push   $0x800ead
  800fb5:	e8 bb 0e 00 00       	call   801e75 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fba:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbf:	cd 30                	int    $0x30
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	75 21                	jne    800fee <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcd:	e8 8d fc ff ff       	call   800c5f <sys_getenvid>
  800fd2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd7:	6b c0 78             	imul   $0x78,%eax,%eax
  800fda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdf:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	e9 80 01 00 00       	jmp    80116e <fork+0x1c7>
	}
	if (envid < 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 12                	jns    801004 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  800ff2:	50                   	push   %eax
  800ff3:	68 92 27 80 00       	push   $0x802792
  800ff8:	6a 70                	push   $0x70
  800ffa:	68 5c 27 80 00       	push   $0x80275c
  800fff:	e8 32 f2 ff ff       	call   800236 <_panic>
  801004:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  801009:	89 d8                	mov    %ebx,%eax
  80100b:	c1 e8 16             	shr    $0x16,%eax
  80100e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801015:	a8 01                	test   $0x1,%al
  801017:	0f 84 de 00 00 00    	je     8010fb <fork+0x154>
  80101d:	89 de                	mov    %ebx,%esi
  80101f:	c1 ee 0c             	shr    $0xc,%esi
  801022:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801029:	a8 01                	test   $0x1,%al
  80102b:	0f 84 ca 00 00 00    	je     8010fb <fork+0x154>
  801031:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801038:	a8 04                	test   $0x4,%al
  80103a:	0f 84 bb 00 00 00    	je     8010fb <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  801040:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  801047:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  80104a:	f6 c4 04             	test   $0x4,%ah
  80104d:	74 34                	je     801083 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	25 07 0e 00 00       	and    $0xe07,%eax
  801057:	50                   	push   %eax
  801058:	56                   	push   %esi
  801059:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105c:	56                   	push   %esi
  80105d:	6a 00                	push   $0x0
  80105f:	e8 7c fc ff ff       	call   800ce0 <sys_page_map>
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	0f 84 8c 00 00 00    	je     8010fb <fork+0x154>
        	panic("duppage share");
  80106f:	83 ec 04             	sub    $0x4,%esp
  801072:	68 a2 27 80 00       	push   $0x8027a2
  801077:	6a 48                	push   $0x48
  801079:	68 5c 27 80 00       	push   $0x80275c
  80107e:	e8 b3 f1 ff ff       	call   800236 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801083:	a9 02 08 00 00       	test   $0x802,%eax
  801088:	74 5d                	je     8010e7 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	68 05 08 00 00       	push   $0x805
  801092:	56                   	push   %esi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 42 fc ff ff       	call   800ce0 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 14                	jns    8010b9 <fork+0x112>
			panic("error");
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 28 24 80 00       	push   $0x802428
  8010ad:	6a 4b                	push   $0x4b
  8010af:	68 5c 27 80 00       	push   $0x80275c
  8010b4:	e8 7d f1 ff ff       	call   800236 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	68 05 08 00 00       	push   $0x805
  8010c1:	56                   	push   %esi
  8010c2:	6a 00                	push   $0x0
  8010c4:	56                   	push   %esi
  8010c5:	6a 00                	push   $0x0
  8010c7:	e8 14 fc ff ff       	call   800ce0 <sys_page_map>
  8010cc:	83 c4 20             	add    $0x20,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 28                	jns    8010fb <fork+0x154>
			panic("error");
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	68 28 24 80 00       	push   $0x802428
  8010db:	6a 4d                	push   $0x4d
  8010dd:	68 5c 27 80 00       	push   $0x80275c
  8010e2:	e8 4f f1 ff ff       	call   800236 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	6a 05                	push   $0x5
  8010ec:	56                   	push   %esi
  8010ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f0:	56                   	push   %esi
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 e8 fb ff ff       	call   800ce0 <sys_page_map>
  8010f8:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801101:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  801107:	0f 85 fc fe ff ff    	jne    801009 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	6a 07                	push   $0x7
  801112:	68 00 f0 7f ee       	push   $0xee7ff000
  801117:	57                   	push   %edi
  801118:	e8 80 fb ff ff       	call   800c9d <sys_page_alloc>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	79 14                	jns    801138 <fork+0x191>
		panic("1");
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	68 b0 27 80 00       	push   $0x8027b0
  80112c:	6a 78                	push   $0x78
  80112e:	68 5c 27 80 00       	push   $0x80275c
  801133:	e8 fe f0 ff ff       	call   800236 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	68 e4 1e 80 00       	push   $0x801ee4
  801140:	57                   	push   %edi
  801141:	e8 a2 fc ff ff       	call   800de8 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801146:	83 c4 08             	add    $0x8,%esp
  801149:	6a 02                	push   $0x2
  80114b:	57                   	push   %edi
  80114c:	e8 13 fc ff ff       	call   800d64 <sys_env_set_status>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	79 14                	jns    80116c <fork+0x1c5>
		panic("sys_env_set_status");
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	68 b2 27 80 00       	push   $0x8027b2
  801160:	6a 7d                	push   $0x7d
  801162:	68 5c 27 80 00       	push   $0x80275c
  801167:	e8 ca f0 ff ff       	call   800236 <_panic>

	return envid;
  80116c:	89 f8                	mov    %edi,%eax
}
  80116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <sfork>:

// Challenge!
int
sfork(void)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80117c:	68 c5 27 80 00       	push   $0x8027c5
  801181:	68 86 00 00 00       	push   $0x86
  801186:	68 5c 27 80 00       	push   $0x80275c
  80118b:	e8 a6 f0 ff ff       	call   800236 <_panic>

00801190 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	05 00 00 00 30       	add    $0x30000000,%eax
  80119b:	c1 e8 0c             	shr    $0xc,%eax
}
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8011ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 16             	shr    $0x16,%edx
  8011c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 11                	je     8011e4 <fd_alloc+0x2d>
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	c1 ea 0c             	shr    $0xc,%edx
  8011d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	75 09                	jne    8011ed <fd_alloc+0x36>
			*fd_store = fd;
  8011e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 17                	jmp    801204 <fd_alloc+0x4d>
  8011ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f7:	75 c9                	jne    8011c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120c:	83 f8 1f             	cmp    $0x1f,%eax
  80120f:	77 36                	ja     801247 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801211:	c1 e0 0c             	shl    $0xc,%eax
  801214:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801219:	89 c2                	mov    %eax,%edx
  80121b:	c1 ea 16             	shr    $0x16,%edx
  80121e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	74 24                	je     80124e <fd_lookup+0x48>
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	c1 ea 0c             	shr    $0xc,%edx
  80122f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	74 1a                	je     801255 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123e:	89 02                	mov    %eax,(%edx)
	return 0;
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	eb 13                	jmp    80125a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb 0c                	jmp    80125a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801253:	eb 05                	jmp    80125a <fd_lookup+0x54>
  801255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801265:	ba 58 28 80 00       	mov    $0x802858,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126a:	eb 13                	jmp    80127f <dev_lookup+0x23>
  80126c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126f:	39 08                	cmp    %ecx,(%eax)
  801271:	75 0c                	jne    80127f <dev_lookup+0x23>
			*dev = devtab[i];
  801273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801276:	89 01                	mov    %eax,(%ecx)
			return 0;
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	eb 2e                	jmp    8012ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127f:	8b 02                	mov    (%edx),%eax
  801281:	85 c0                	test   %eax,%eax
  801283:	75 e7                	jne    80126c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801285:	a1 04 40 80 00       	mov    0x804004,%eax
  80128a:	8b 40 48             	mov    0x48(%eax),%eax
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	51                   	push   %ecx
  801291:	50                   	push   %eax
  801292:	68 dc 27 80 00       	push   $0x8027dc
  801297:	e8 73 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80129c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 10             	sub    $0x10,%esp
  8012b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c7:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ca:	50                   	push   %eax
  8012cb:	e8 36 ff ff ff       	call   801206 <fd_lookup>
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 05                	js     8012dc <fd_close+0x2d>
	    || fd != fd2)
  8012d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012da:	74 0b                	je     8012e7 <fd_close+0x38>
		return (must_exist ? r : 0);
  8012dc:	80 fb 01             	cmp    $0x1,%bl
  8012df:	19 d2                	sbb    %edx,%edx
  8012e1:	f7 d2                	not    %edx
  8012e3:	21 d0                	and    %edx,%eax
  8012e5:	eb 41                	jmp    801328 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 36                	pushl  (%esi)
  8012f0:	e8 67 ff ff ff       	call   80125c <dev_lookup>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 1a                	js     801318 <fd_close+0x69>
		if (dev->dev_close)
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801309:	85 c0                	test   %eax,%eax
  80130b:	74 0b                	je     801318 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	56                   	push   %esi
  801311:	ff d0                	call   *%eax
  801313:	89 c3                	mov    %eax,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 ff f9 ff ff       	call   800d22 <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 d8                	mov    %ebx,%eax
}
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 c5 fe ff ff       	call   801206 <fd_lookup>
  801341:	89 c2                	mov    %eax,%edx
  801343:	83 c4 08             	add    $0x8,%esp
  801346:	85 d2                	test   %edx,%edx
  801348:	78 10                	js     80135a <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	6a 01                	push   $0x1
  80134f:	ff 75 f4             	pushl  -0xc(%ebp)
  801352:	e8 58 ff ff ff       	call   8012af <fd_close>
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <close_all>:

void
close_all(void)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	53                   	push   %ebx
  80136c:	e8 be ff ff ff       	call   80132f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801371:	83 c3 01             	add    $0x1,%ebx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	83 fb 20             	cmp    $0x20,%ebx
  80137a:	75 ec                	jne    801368 <close_all+0xc>
		close(i);
}
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	57                   	push   %edi
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	83 ec 2c             	sub    $0x2c,%esp
  80138a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 75 08             	pushl  0x8(%ebp)
  801394:	e8 6d fe ff ff       	call   801206 <fd_lookup>
  801399:	89 c2                	mov    %eax,%edx
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	85 d2                	test   %edx,%edx
  8013a0:	0f 88 c1 00 00 00    	js     801467 <dup+0xe6>
		return r;
	close(newfdnum);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	56                   	push   %esi
  8013aa:	e8 80 ff ff ff       	call   80132f <close>

	newfd = INDEX2FD(newfdnum);
  8013af:	89 f3                	mov    %esi,%ebx
  8013b1:	c1 e3 0c             	shl    $0xc,%ebx
  8013b4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013ba:	83 c4 04             	add    $0x4,%esp
  8013bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c0:	e8 db fd ff ff       	call   8011a0 <fd2data>
  8013c5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c7:	89 1c 24             	mov    %ebx,(%esp)
  8013ca:	e8 d1 fd ff ff       	call   8011a0 <fd2data>
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	c1 e8 16             	shr    $0x16,%eax
  8013da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e1:	a8 01                	test   $0x1,%al
  8013e3:	74 37                	je     80141c <dup+0x9b>
  8013e5:	89 f8                	mov    %edi,%eax
  8013e7:	c1 e8 0c             	shr    $0xc,%eax
  8013ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f1:	f6 c2 01             	test   $0x1,%dl
  8013f4:	74 26                	je     80141c <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	25 07 0e 00 00       	and    $0xe07,%eax
  801405:	50                   	push   %eax
  801406:	ff 75 d4             	pushl  -0x2c(%ebp)
  801409:	6a 00                	push   $0x0
  80140b:	57                   	push   %edi
  80140c:	6a 00                	push   $0x0
  80140e:	e8 cd f8 ff ff       	call   800ce0 <sys_page_map>
  801413:	89 c7                	mov    %eax,%edi
  801415:	83 c4 20             	add    $0x20,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 2e                	js     80144a <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141f:	89 d0                	mov    %edx,%eax
  801421:	c1 e8 0c             	shr    $0xc,%eax
  801424:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	25 07 0e 00 00       	and    $0xe07,%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	52                   	push   %edx
  801438:	6a 00                	push   $0x0
  80143a:	e8 a1 f8 ff ff       	call   800ce0 <sys_page_map>
  80143f:	89 c7                	mov    %eax,%edi
  801441:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801444:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801446:	85 ff                	test   %edi,%edi
  801448:	79 1d                	jns    801467 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 cd f8 ff ff       	call   800d22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145b:	6a 00                	push   $0x0
  80145d:	e8 c0 f8 ff ff       	call   800d22 <sys_page_unmap>
	return r;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	89 f8                	mov    %edi,%eax
}
  801467:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801479:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	53                   	push   %ebx
  80147e:	e8 83 fd ff ff       	call   801206 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	89 c2                	mov    %eax,%edx
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 6d                	js     8014f9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	ff 30                	pushl  (%eax)
  801498:	e8 bf fd ff ff       	call   80125c <dev_lookup>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 4c                	js     8014f0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a7:	8b 42 08             	mov    0x8(%edx),%eax
  8014aa:	83 e0 03             	and    $0x3,%eax
  8014ad:	83 f8 01             	cmp    $0x1,%eax
  8014b0:	75 21                	jne    8014d3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	53                   	push   %ebx
  8014be:	50                   	push   %eax
  8014bf:	68 1d 28 80 00       	push   $0x80281d
  8014c4:	e8 46 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d1:	eb 26                	jmp    8014f9 <read+0x8a>
	}
	if (!dev->dev_read)
  8014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d6:	8b 40 08             	mov    0x8(%eax),%eax
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	74 17                	je     8014f4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	ff 75 10             	pushl  0x10(%ebp)
  8014e3:	ff 75 0c             	pushl  0xc(%ebp)
  8014e6:	52                   	push   %edx
  8014e7:	ff d0                	call   *%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb 09                	jmp    8014f9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	eb 05                	jmp    8014f9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f9:	89 d0                	mov    %edx,%eax
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801514:	eb 21                	jmp    801537 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	89 f0                	mov    %esi,%eax
  80151b:	29 d8                	sub    %ebx,%eax
  80151d:	50                   	push   %eax
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	03 45 0c             	add    0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	57                   	push   %edi
  801525:	e8 45 ff ff ff       	call   80146f <read>
		if (m < 0)
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 0c                	js     80153d <readn+0x3d>
			return m;
		if (m == 0)
  801531:	85 c0                	test   %eax,%eax
  801533:	74 06                	je     80153b <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801535:	01 c3                	add    %eax,%ebx
  801537:	39 f3                	cmp    %esi,%ebx
  801539:	72 db                	jb     801516 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80153b:	89 d8                	mov    %ebx,%eax
}
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	53                   	push   %ebx
  801554:	e8 ad fc ff ff       	call   801206 <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 68                	js     8015ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	ff 30                	pushl  (%eax)
  80156e:	e8 e9 fc ff ff       	call   80125c <dev_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 47                	js     8015c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801581:	75 21                	jne    8015a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 04 40 80 00       	mov    0x804004,%eax
  801588:	8b 40 48             	mov    0x48(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 39 28 80 00       	push   $0x802839
  801595:	e8 75 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a2:	eb 26                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	74 17                	je     8015c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	ff 75 10             	pushl  0x10(%ebp)
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	50                   	push   %eax
  8015b8:	ff d2                	call   *%edx
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 09                	jmp    8015ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	eb 05                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 23 fc ff ff       	call   801206 <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 0e                	js     8015f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 14             	sub    $0x14,%esp
  801601:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	53                   	push   %ebx
  801609:	e8 f8 fb ff ff       	call   801206 <fd_lookup>
  80160e:	83 c4 08             	add    $0x8,%esp
  801611:	89 c2                	mov    %eax,%edx
  801613:	85 c0                	test   %eax,%eax
  801615:	78 65                	js     80167c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 34 fc ff ff       	call   80125c <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 44                	js     801673 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801636:	75 21                	jne    801659 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801638:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163d:	8b 40 48             	mov    0x48(%eax),%eax
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	53                   	push   %ebx
  801644:	50                   	push   %eax
  801645:	68 fc 27 80 00       	push   $0x8027fc
  80164a:	e8 c0 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801657:	eb 23                	jmp    80167c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	8b 52 18             	mov    0x18(%edx),%edx
  80165f:	85 d2                	test   %edx,%edx
  801661:	74 14                	je     801677 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 09                	jmp    80167c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	89 c2                	mov    %eax,%edx
  801675:	eb 05                	jmp    80167c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801677:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167c:	89 d0                	mov    %edx,%eax
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 6d fb ff ff       	call   801206 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 58                	js     8016fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 a9 fb ff ff       	call   80125c <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 37                	js     8016f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c1:	74 32                	je     8016f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cd:	00 00 00 
	stat->st_isdir = 0;
  8016d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d7:	00 00 00 
	stat->st_dev = dev;
  8016da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	53                   	push   %ebx
  8016e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e7:	ff 50 14             	call   *0x14(%eax)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb 09                	jmp    8016fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	eb 05                	jmp    8016fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fa:	89 d0                	mov    %edx,%eax
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	6a 00                	push   $0x0
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	e8 e7 01 00 00       	call   8018fa <open>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 db                	test   %ebx,%ebx
  80171a:	78 1b                	js     801737 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	53                   	push   %ebx
  801723:	e8 5b ff ff ff       	call   801683 <fstat>
  801728:	89 c6                	mov    %eax,%esi
	close(fd);
  80172a:	89 1c 24             	mov    %ebx,(%esp)
  80172d:	e8 fd fb ff ff       	call   80132f <close>
	return r;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	89 f0                	mov    %esi,%eax
}
  801737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	89 c6                	mov    %eax,%esi
  801745:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801747:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80174e:	75 12                	jne    801762 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	6a 03                	push   $0x3
  801755:	e8 69 08 00 00       	call   801fc3 <ipc_find_env>
  80175a:	a3 00 40 80 00       	mov    %eax,0x804000
  80175f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801762:	6a 07                	push   $0x7
  801764:	68 00 50 80 00       	push   $0x805000
  801769:	56                   	push   %esi
  80176a:	ff 35 00 40 80 00    	pushl  0x804000
  801770:	e8 fd 07 00 00       	call   801f72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801775:	83 c4 0c             	add    $0xc,%esp
  801778:	6a 00                	push   $0x0
  80177a:	53                   	push   %ebx
  80177b:	6a 00                	push   $0x0
  80177d:	e8 8a 07 00 00       	call   801f0c <ipc_recv>
}
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	8b 40 0c             	mov    0xc(%eax),%eax
  801795:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ac:	e8 8d ff ff ff       	call   80173e <fsipc>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ce:	e8 6b ff ff ff       	call   80173e <fsipc>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f4:	e8 45 ff ff ff       	call   80173e <fsipc>
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	78 2c                	js     80182b <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	68 00 50 80 00       	push   $0x805000
  801807:	53                   	push   %ebx
  801808:	e8 86 f0 ff ff       	call   800893 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180d:	a1 80 50 80 00       	mov    0x805080,%eax
  801812:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801818:	a1 84 50 80 00       	mov    0x805084,%eax
  80181d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801839:	8b 55 08             	mov    0x8(%ebp),%edx
  80183c:	8b 52 0c             	mov    0xc(%edx),%edx
  80183f:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801845:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80184a:	76 05                	jbe    801851 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80184c:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801851:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	50                   	push   %eax
  80185a:	ff 75 0c             	pushl  0xc(%ebp)
  80185d:	68 08 50 80 00       	push   $0x805008
  801862:	e8 be f1 ff ff       	call   800a25 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801867:	ba 00 00 00 00       	mov    $0x0,%edx
  80186c:	b8 04 00 00 00       	mov    $0x4,%eax
  801871:	e8 c8 fe ff ff       	call   80173e <fsipc>
	return write;
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	8b 40 0c             	mov    0xc(%eax),%eax
  801886:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80188b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801891:	ba 00 00 00 00       	mov    $0x0,%edx
  801896:	b8 03 00 00 00       	mov    $0x3,%eax
  80189b:	e8 9e fe ff ff       	call   80173e <fsipc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 4b                	js     8018f1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a6:	39 c6                	cmp    %eax,%esi
  8018a8:	73 16                	jae    8018c0 <devfile_read+0x48>
  8018aa:	68 68 28 80 00       	push   $0x802868
  8018af:	68 6f 28 80 00       	push   $0x80286f
  8018b4:	6a 7c                	push   $0x7c
  8018b6:	68 84 28 80 00       	push   $0x802884
  8018bb:	e8 76 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018c0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c5:	7e 16                	jle    8018dd <devfile_read+0x65>
  8018c7:	68 8f 28 80 00       	push   $0x80288f
  8018cc:	68 6f 28 80 00       	push   $0x80286f
  8018d1:	6a 7d                	push   $0x7d
  8018d3:	68 84 28 80 00       	push   $0x802884
  8018d8:	e8 59 e9 ff ff       	call   800236 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	50                   	push   %eax
  8018e1:	68 00 50 80 00       	push   $0x805000
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	e8 37 f1 ff ff       	call   800a25 <memmove>
	return r;
  8018ee:	83 c4 10             	add    $0x10,%esp
}
  8018f1:	89 d8                	mov    %ebx,%eax
  8018f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 20             	sub    $0x20,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801904:	53                   	push   %ebx
  801905:	e8 50 ef ff ff       	call   80085a <strlen>
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801912:	7f 67                	jg     80197b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	e8 97 f8 ff ff       	call   8011b7 <fd_alloc>
  801920:	83 c4 10             	add    $0x10,%esp
		return r;
  801923:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801925:	85 c0                	test   %eax,%eax
  801927:	78 57                	js     801980 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	53                   	push   %ebx
  80192d:	68 00 50 80 00       	push   $0x805000
  801932:	e8 5c ef ff ff       	call   800893 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801942:	b8 01 00 00 00       	mov    $0x1,%eax
  801947:	e8 f2 fd ff ff       	call   80173e <fsipc>
  80194c:	89 c3                	mov    %eax,%ebx
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	79 14                	jns    801969 <open+0x6f>
		fd_close(fd, 0);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	6a 00                	push   $0x0
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	e8 4d f9 ff ff       	call   8012af <fd_close>
		return r;
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	89 da                	mov    %ebx,%edx
  801967:	eb 17                	jmp    801980 <open+0x86>
	}

	return fd2num(fd);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	e8 1c f8 ff ff       	call   801190 <fd2num>
  801974:	89 c2                	mov    %eax,%edx
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	eb 05                	jmp    801980 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801980:	89 d0                	mov    %edx,%eax
  801982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 08 00 00 00       	mov    $0x8,%eax
  801997:	e8 a2 fd ff ff       	call   80173e <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	ff 75 08             	pushl  0x8(%ebp)
  8019ac:	e8 ef f7 ff ff       	call   8011a0 <fd2data>
  8019b1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b3:	83 c4 08             	add    $0x8,%esp
  8019b6:	68 9b 28 80 00       	push   $0x80289b
  8019bb:	53                   	push   %ebx
  8019bc:	e8 d2 ee ff ff       	call   800893 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c1:	8b 56 04             	mov    0x4(%esi),%edx
  8019c4:	89 d0                	mov    %edx,%eax
  8019c6:	2b 06                	sub    (%esi),%eax
  8019c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d5:	00 00 00 
	stat->st_dev = &devpipe;
  8019d8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019df:	30 80 00 
	return 0;
}
  8019e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f8:	53                   	push   %ebx
  8019f9:	6a 00                	push   $0x0
  8019fb:	e8 22 f3 ff ff       	call   800d22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a00:	89 1c 24             	mov    %ebx,(%esp)
  801a03:	e8 98 f7 ff ff       	call   8011a0 <fd2data>
  801a08:	83 c4 08             	add    $0x8,%esp
  801a0b:	50                   	push   %eax
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 0f f3 ff ff       	call   800d22 <sys_page_unmap>
}
  801a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	57                   	push   %edi
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 1c             	sub    $0x1c,%esp
  801a21:	89 c7                	mov    %eax,%edi
  801a23:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a25:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	57                   	push   %edi
  801a31:	e8 c5 05 00 00       	call   801ffb <pageref>
  801a36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a39:	89 34 24             	mov    %esi,(%esp)
  801a3c:	e8 ba 05 00 00       	call   801ffb <pageref>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a47:	0f 94 c0             	sete   %al
  801a4a:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a4d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a53:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a56:	39 cb                	cmp    %ecx,%ebx
  801a58:	74 15                	je     801a6f <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801a5a:	8b 52 58             	mov    0x58(%edx),%edx
  801a5d:	50                   	push   %eax
  801a5e:	52                   	push   %edx
  801a5f:	53                   	push   %ebx
  801a60:	68 a8 28 80 00       	push   $0x8028a8
  801a65:	e8 a5 e8 ff ff       	call   80030f <cprintf>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	eb b6                	jmp    801a25 <_pipeisclosed+0xd>
	}
}
  801a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 28             	sub    $0x28,%esp
  801a80:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a83:	56                   	push   %esi
  801a84:	e8 17 f7 ff ff       	call   8011a0 <fd2data>
  801a89:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  801a93:	eb 4b                	jmp    801ae0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a95:	89 da                	mov    %ebx,%edx
  801a97:	89 f0                	mov    %esi,%eax
  801a99:	e8 7a ff ff ff       	call   801a18 <_pipeisclosed>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 48                	jne    801aea <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa2:	e8 d7 f1 ff ff       	call   800c7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aaa:	8b 0b                	mov    (%ebx),%ecx
  801aac:	8d 51 20             	lea    0x20(%ecx),%edx
  801aaf:	39 d0                	cmp    %edx,%eax
  801ab1:	73 e2                	jae    801a95 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aba:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	c1 fa 1f             	sar    $0x1f,%edx
  801ac2:	89 d1                	mov    %edx,%ecx
  801ac4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aca:	83 e2 1f             	and    $0x1f,%edx
  801acd:	29 ca                	sub    %ecx,%edx
  801acf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad7:	83 c0 01             	add    $0x1,%eax
  801ada:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801add:	83 c7 01             	add    $0x1,%edi
  801ae0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae3:	75 c2                	jne    801aa7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	eb 05                	jmp    801aef <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 18             	sub    $0x18,%esp
  801b00:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b03:	57                   	push   %edi
  801b04:	e8 97 f6 ff ff       	call   8011a0 <fd2data>
  801b09:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b13:	eb 3d                	jmp    801b52 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b15:	85 db                	test   %ebx,%ebx
  801b17:	74 04                	je     801b1d <devpipe_read+0x26>
				return i;
  801b19:	89 d8                	mov    %ebx,%eax
  801b1b:	eb 44                	jmp    801b61 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1d:	89 f2                	mov    %esi,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	e8 f2 fe ff ff       	call   801a18 <_pipeisclosed>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	75 32                	jne    801b5c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2a:	e8 4f f1 ff ff       	call   800c7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2f:	8b 06                	mov    (%esi),%eax
  801b31:	3b 46 04             	cmp    0x4(%esi),%eax
  801b34:	74 df                	je     801b15 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b36:	99                   	cltd   
  801b37:	c1 ea 1b             	shr    $0x1b,%edx
  801b3a:	01 d0                	add    %edx,%eax
  801b3c:	83 e0 1f             	and    $0x1f,%eax
  801b3f:	29 d0                	sub    %edx,%eax
  801b41:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b49:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b4c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4f:	83 c3 01             	add    $0x1,%ebx
  801b52:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b55:	75 d8                	jne    801b2f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b57:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5a:	eb 05                	jmp    801b61 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b74:	50                   	push   %eax
  801b75:	e8 3d f6 ff ff       	call   8011b7 <fd_alloc>
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 88 2c 01 00 00    	js     801cb3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	68 07 04 00 00       	push   $0x407
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	6a 00                	push   $0x0
  801b94:	e8 04 f1 ff ff       	call   800c9d <sys_page_alloc>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 0d 01 00 00    	js     801cb3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	e8 05 f6 ff ff       	call   8011b7 <fd_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 e2 00 00 00    	js     801ca1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbf:	83 ec 04             	sub    $0x4,%esp
  801bc2:	68 07 04 00 00       	push   $0x407
  801bc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 cc f0 ff ff       	call   800c9d <sys_page_alloc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 c3 00 00 00    	js     801ca1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	ff 75 f4             	pushl  -0xc(%ebp)
  801be4:	e8 b7 f5 ff ff       	call   8011a0 <fd2data>
  801be9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801beb:	83 c4 0c             	add    $0xc,%esp
  801bee:	68 07 04 00 00       	push   $0x407
  801bf3:	50                   	push   %eax
  801bf4:	6a 00                	push   $0x0
  801bf6:	e8 a2 f0 ff ff       	call   800c9d <sys_page_alloc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 89 00 00 00    	js     801c91 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c08:	83 ec 0c             	sub    $0xc,%esp
  801c0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0e:	e8 8d f5 ff ff       	call   8011a0 <fd2data>
  801c13:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1a:	50                   	push   %eax
  801c1b:	6a 00                	push   $0x0
  801c1d:	56                   	push   %esi
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 bb f0 ff ff       	call   800ce0 <sys_page_map>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 55                	js     801c83 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	e8 2d f5 ff ff       	call   801190 <fd2num>
  801c63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c66:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c68:	83 c4 04             	add    $0x4,%esp
  801c6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6e:	e8 1d f5 ff ff       	call   801190 <fd2num>
  801c73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c76:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c81:	eb 30                	jmp    801cb3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	56                   	push   %esi
  801c87:	6a 00                	push   $0x0
  801c89:	e8 94 f0 ff ff       	call   800d22 <sys_page_unmap>
  801c8e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c91:	83 ec 08             	sub    $0x8,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	6a 00                	push   $0x0
  801c99:	e8 84 f0 ff ff       	call   800d22 <sys_page_unmap>
  801c9e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 74 f0 ff ff       	call   800d22 <sys_page_unmap>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb3:	89 d0                	mov    %edx,%eax
  801cb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	ff 75 08             	pushl  0x8(%ebp)
  801cc9:	e8 38 f5 ff ff       	call   801206 <fd_lookup>
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	85 d2                	test   %edx,%edx
  801cd5:	78 18                	js     801cef <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdd:	e8 be f4 ff ff       	call   8011a0 <fd2data>
	return _pipeisclosed(fd, p);
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	e8 2c fd ff ff       	call   801a18 <_pipeisclosed>
  801cec:	83 c4 10             	add    $0x10,%esp
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d01:	68 d9 28 80 00       	push   $0x8028d9
  801d06:	ff 75 0c             	pushl  0xc(%ebp)
  801d09:	e8 85 eb ff ff       	call   800893 <strcpy>
	return 0;
}
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d21:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2c:	eb 2e                	jmp    801d5c <devcons_write+0x47>
		m = n - tot;
  801d2e:	8b 55 10             	mov    0x10(%ebp),%edx
  801d31:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801d33:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801d38:	83 fa 7f             	cmp    $0x7f,%edx
  801d3b:	77 02                	ja     801d3f <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d3d:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	56                   	push   %esi
  801d43:	03 45 0c             	add    0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	57                   	push   %edi
  801d48:	e8 d8 ec ff ff       	call   800a25 <memmove>
		sys_cputs(buf, m);
  801d4d:	83 c4 08             	add    $0x8,%esp
  801d50:	56                   	push   %esi
  801d51:	57                   	push   %edi
  801d52:	e8 8a ee ff ff       	call   800be1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d57:	01 f3                	add    %esi,%ebx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d61:	72 cb                	jb     801d2e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7a:	75 07                	jne    801d83 <devcons_read+0x18>
  801d7c:	eb 28                	jmp    801da6 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7e:	e8 fb ee ff ff       	call   800c7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d83:	e8 77 ee ff ff       	call   800bff <sys_cgetc>
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	74 f2                	je     801d7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 16                	js     801da6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d90:	83 f8 04             	cmp    $0x4,%eax
  801d93:	74 0c                	je     801da1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d98:	88 02                	mov    %al,(%edx)
	return 1;
  801d9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9f:	eb 05                	jmp    801da6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db4:	6a 01                	push   $0x1
  801db6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	e8 22 ee ff ff       	call   800be1 <sys_cputs>
  801dbf:	83 c4 10             	add    $0x10,%esp
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <getchar>:

int
getchar(void)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dca:	6a 01                	push   $0x1
  801dcc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 98 f6 ff ff       	call   80146f <read>
	if (r < 0)
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 0f                	js     801ded <getchar+0x29>
		return r;
	if (r < 1)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	7e 06                	jle    801de8 <getchar+0x24>
		return -E_EOF;
	return c;
  801de2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de6:	eb 05                	jmp    801ded <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df8:	50                   	push   %eax
  801df9:	ff 75 08             	pushl  0x8(%ebp)
  801dfc:	e8 05 f4 ff ff       	call   801206 <fd_lookup>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 11                	js     801e19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e11:	39 10                	cmp    %edx,(%eax)
  801e13:	0f 94 c0             	sete   %al
  801e16:	0f b6 c0             	movzbl %al,%eax
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <opencons>:

int
opencons(void)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	e8 8d f3 ff ff       	call   8011b7 <fd_alloc>
  801e2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 3e                	js     801e71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	68 07 04 00 00       	push   $0x407
  801e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 58 ee ff ff       	call   800c9d <sys_page_alloc>
  801e45:	83 c4 10             	add    $0x10,%esp
		return r;
  801e48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	78 23                	js     801e71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	50                   	push   %eax
  801e67:	e8 24 f3 ff ff       	call   801190 <fd2num>
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	83 c4 10             	add    $0x10,%esp
}
  801e71:	89 d0                	mov    %edx,%eax
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801e7b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e82:	75 2c                	jne    801eb0 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	6a 07                	push   $0x7
  801e89:	68 00 f0 7f ee       	push   $0xee7ff000
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 08 ee ff ff       	call   800c9d <sys_page_alloc>
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	79 14                	jns    801eb0 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801e9c:	83 ec 04             	sub    $0x4,%esp
  801e9f:	68 e8 28 80 00       	push   $0x8028e8
  801ea4:	6a 1f                	push   $0x1f
  801ea6:	68 4c 29 80 00       	push   $0x80294c
  801eab:	e8 86 e3 ff ff       	call   800236 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801eb8:	83 ec 08             	sub    $0x8,%esp
  801ebb:	68 e4 1e 80 00       	push   $0x801ee4
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 21 ef ff ff       	call   800de8 <sys_env_set_pgfault_upcall>
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	79 14                	jns    801ee2 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ece:	83 ec 04             	sub    $0x4,%esp
  801ed1:	68 14 29 80 00       	push   $0x802914
  801ed6:	6a 25                	push   $0x25
  801ed8:	68 4c 29 80 00       	push   $0x80294c
  801edd:	e8 54 e3 ff ff       	call   800236 <_panic>
}
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ee4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ee5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801eea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801eef:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801ef1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801ef5:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801ef9:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801efa:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801efd:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801eff:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801f02:	83 c4 04             	add    $0x4,%esp
	popal 
  801f05:	61                   	popa   
	addl $4, %esp 
  801f06:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801f09:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801f0a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801f0b:	c3                   	ret    

00801f0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	8b 75 08             	mov    0x8(%ebp),%esi
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f1a:	85 f6                	test   %esi,%esi
  801f1c:	74 06                	je     801f24 <ipc_recv+0x18>
  801f1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801f24:	85 db                	test   %ebx,%ebx
  801f26:	74 06                	je     801f2e <ipc_recv+0x22>
  801f28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801f2e:	83 f8 01             	cmp    $0x1,%eax
  801f31:	19 d2                	sbb    %edx,%edx
  801f33:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	50                   	push   %eax
  801f39:	e8 0f ef ff ff       	call   800e4d <sys_ipc_recv>
  801f3e:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	85 d2                	test   %edx,%edx
  801f45:	75 24                	jne    801f6b <ipc_recv+0x5f>
	if (from_env_store)
  801f47:	85 f6                	test   %esi,%esi
  801f49:	74 0a                	je     801f55 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801f4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801f50:	8b 40 70             	mov    0x70(%eax),%eax
  801f53:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801f55:	85 db                	test   %ebx,%ebx
  801f57:	74 0a                	je     801f63 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801f59:	a1 04 40 80 00       	mov    0x804004,%eax
  801f5e:	8b 40 74             	mov    0x74(%eax),%eax
  801f61:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801f63:	a1 04 40 80 00       	mov    0x804004,%eax
  801f68:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6e:	5b                   	pop    %ebx
  801f6f:	5e                   	pop    %esi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 0c             	sub    $0xc,%esp
  801f7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801f84:	83 fb 01             	cmp    $0x1,%ebx
  801f87:	19 c0                	sbb    %eax,%eax
  801f89:	09 c3                	or     %eax,%ebx
  801f8b:	eb 1c                	jmp    801fa9 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801f8d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f90:	74 12                	je     801fa4 <ipc_send+0x32>
  801f92:	50                   	push   %eax
  801f93:	68 5a 29 80 00       	push   $0x80295a
  801f98:	6a 36                	push   $0x36
  801f9a:	68 71 29 80 00       	push   $0x802971
  801f9f:	e8 92 e2 ff ff       	call   800236 <_panic>
		sys_yield();
  801fa4:	e8 d5 ec ff ff       	call   800c7e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fa9:	ff 75 14             	pushl  0x14(%ebp)
  801fac:	53                   	push   %ebx
  801fad:	56                   	push   %esi
  801fae:	57                   	push   %edi
  801faf:	e8 76 ee ff ff       	call   800e2a <sys_ipc_try_send>
		if (ret == 0) break;
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	75 d2                	jne    801f8d <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801fbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbe:	5b                   	pop    %ebx
  801fbf:	5e                   	pop    %esi
  801fc0:	5f                   	pop    %edi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fce:	6b d0 78             	imul   $0x78,%eax,%edx
  801fd1:	83 c2 50             	add    $0x50,%edx
  801fd4:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801fda:	39 ca                	cmp    %ecx,%edx
  801fdc:	75 0d                	jne    801feb <ipc_find_env+0x28>
			return envs[i].env_id;
  801fde:	6b c0 78             	imul   $0x78,%eax,%eax
  801fe1:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801fe6:	8b 40 08             	mov    0x8(%eax),%eax
  801fe9:	eb 0e                	jmp    801ff9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801feb:	83 c0 01             	add    $0x1,%eax
  801fee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff3:	75 d9                	jne    801fce <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ff5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802001:	89 d0                	mov    %edx,%eax
  802003:	c1 e8 16             	shr    $0x16,%eax
  802006:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802012:	f6 c1 01             	test   $0x1,%cl
  802015:	74 1d                	je     802034 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802021:	f6 c2 01             	test   $0x1,%dl
  802024:	74 0e                	je     802034 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802026:	c1 ea 0c             	shr    $0xc,%edx
  802029:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802030:	ef 
  802031:	0f b7 c0             	movzwl %ax,%eax
}
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	83 ec 10             	sub    $0x10,%esp
  802046:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80204a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80204e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802052:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802056:	85 d2                	test   %edx,%edx
  802058:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80205c:	89 34 24             	mov    %esi,(%esp)
  80205f:	89 c8                	mov    %ecx,%eax
  802061:	75 35                	jne    802098 <__udivdi3+0x58>
  802063:	39 f1                	cmp    %esi,%ecx
  802065:	0f 87 bd 00 00 00    	ja     802128 <__udivdi3+0xe8>
  80206b:	85 c9                	test   %ecx,%ecx
  80206d:	89 cd                	mov    %ecx,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f1                	div    %ecx
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 f0                	mov    %esi,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c6                	mov    %eax,%esi
  802084:	89 f8                	mov    %edi,%eax
  802086:	f7 f5                	div    %ebp
  802088:	89 f2                	mov    %esi,%edx
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	5e                   	pop    %esi
  80208e:	5f                   	pop    %edi
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    
  802091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802098:	3b 14 24             	cmp    (%esp),%edx
  80209b:	77 7b                	ja     802118 <__udivdi3+0xd8>
  80209d:	0f bd f2             	bsr    %edx,%esi
  8020a0:	83 f6 1f             	xor    $0x1f,%esi
  8020a3:	0f 84 97 00 00 00    	je     802140 <__udivdi3+0x100>
  8020a9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ae:	89 d7                	mov    %edx,%edi
  8020b0:	89 f1                	mov    %esi,%ecx
  8020b2:	29 f5                	sub    %esi,%ebp
  8020b4:	d3 e7                	shl    %cl,%edi
  8020b6:	89 c2                	mov    %eax,%edx
  8020b8:	89 e9                	mov    %ebp,%ecx
  8020ba:	d3 ea                	shr    %cl,%edx
  8020bc:	89 f1                	mov    %esi,%ecx
  8020be:	09 fa                	or     %edi,%edx
  8020c0:	8b 3c 24             	mov    (%esp),%edi
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020d3:	89 fa                	mov    %edi,%edx
  8020d5:	d3 ea                	shr    %cl,%edx
  8020d7:	89 f1                	mov    %esi,%ecx
  8020d9:	d3 e7                	shl    %cl,%edi
  8020db:	89 e9                	mov    %ebp,%ecx
  8020dd:	d3 e8                	shr    %cl,%eax
  8020df:	09 c7                	or     %eax,%edi
  8020e1:	89 f8                	mov    %edi,%eax
  8020e3:	f7 74 24 08          	divl   0x8(%esp)
  8020e7:	89 d5                	mov    %edx,%ebp
  8020e9:	89 c7                	mov    %eax,%edi
  8020eb:	f7 64 24 0c          	mull   0xc(%esp)
  8020ef:	39 d5                	cmp    %edx,%ebp
  8020f1:	89 14 24             	mov    %edx,(%esp)
  8020f4:	72 11                	jb     802107 <__udivdi3+0xc7>
  8020f6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020fa:	89 f1                	mov    %esi,%ecx
  8020fc:	d3 e2                	shl    %cl,%edx
  8020fe:	39 c2                	cmp    %eax,%edx
  802100:	73 5e                	jae    802160 <__udivdi3+0x120>
  802102:	3b 2c 24             	cmp    (%esp),%ebp
  802105:	75 59                	jne    802160 <__udivdi3+0x120>
  802107:	8d 47 ff             	lea    -0x1(%edi),%eax
  80210a:	31 f6                	xor    %esi,%esi
  80210c:	89 f2                	mov    %esi,%edx
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    
  802115:	8d 76 00             	lea    0x0(%esi),%esi
  802118:	31 f6                	xor    %esi,%esi
  80211a:	31 c0                	xor    %eax,%eax
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	89 f2                	mov    %esi,%edx
  80212a:	31 f6                	xor    %esi,%esi
  80212c:	89 f8                	mov    %edi,%eax
  80212e:	f7 f1                	div    %ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802144:	76 0b                	jbe    802151 <__udivdi3+0x111>
  802146:	31 c0                	xor    %eax,%eax
  802148:	3b 14 24             	cmp    (%esp),%edx
  80214b:	0f 83 37 ff ff ff    	jae    802088 <__udivdi3+0x48>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	e9 2d ff ff ff       	jmp    802088 <__udivdi3+0x48>
  80215b:	90                   	nop
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 f8                	mov    %edi,%eax
  802162:	31 f6                	xor    %esi,%esi
  802164:	e9 1f ff ff ff       	jmp    802088 <__udivdi3+0x48>
  802169:	66 90                	xchg   %ax,%ax
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	83 ec 20             	sub    $0x20,%esp
  802176:	8b 44 24 34          	mov    0x34(%esp),%eax
  80217a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802182:	89 c6                	mov    %eax,%esi
  802184:	89 44 24 10          	mov    %eax,0x10(%esp)
  802188:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80218c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802190:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802194:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802198:	89 74 24 18          	mov    %esi,0x18(%esp)
  80219c:	85 c0                	test   %eax,%eax
  80219e:	89 c2                	mov    %eax,%edx
  8021a0:	75 1e                	jne    8021c0 <__umoddi3+0x50>
  8021a2:	39 f7                	cmp    %esi,%edi
  8021a4:	76 52                	jbe    8021f8 <__umoddi3+0x88>
  8021a6:	89 c8                	mov    %ecx,%eax
  8021a8:	89 f2                	mov    %esi,%edx
  8021aa:	f7 f7                	div    %edi
  8021ac:	89 d0                	mov    %edx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	83 c4 20             	add    $0x20,%esp
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    
  8021b7:	89 f6                	mov    %esi,%esi
  8021b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021c0:	39 f0                	cmp    %esi,%eax
  8021c2:	77 5c                	ja     802220 <__umoddi3+0xb0>
  8021c4:	0f bd e8             	bsr    %eax,%ebp
  8021c7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ca:	75 64                	jne    802230 <__umoddi3+0xc0>
  8021cc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021d0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021d4:	0f 86 f6 00 00 00    	jbe    8022d0 <__umoddi3+0x160>
  8021da:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021de:	0f 82 ec 00 00 00    	jb     8022d0 <__umoddi3+0x160>
  8021e4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021e8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8021ec:	83 c4 20             	add    $0x20,%esp
  8021ef:	5e                   	pop    %esi
  8021f0:	5f                   	pop    %edi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
  8021f3:	90                   	nop
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	85 ff                	test   %edi,%edi
  8021fa:	89 fd                	mov    %edi,%ebp
  8021fc:	75 0b                	jne    802209 <__umoddi3+0x99>
  8021fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f7                	div    %edi
  802207:	89 c5                	mov    %eax,%ebp
  802209:	8b 44 24 10          	mov    0x10(%esp),%eax
  80220d:	31 d2                	xor    %edx,%edx
  80220f:	f7 f5                	div    %ebp
  802211:	89 c8                	mov    %ecx,%eax
  802213:	f7 f5                	div    %ebp
  802215:	eb 95                	jmp    8021ac <__umoddi3+0x3c>
  802217:	89 f6                	mov    %esi,%esi
  802219:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 20             	add    $0x20,%esp
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    
  80222b:	90                   	nop
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	b8 20 00 00 00       	mov    $0x20,%eax
  802235:	89 e9                	mov    %ebp,%ecx
  802237:	29 e8                	sub    %ebp,%eax
  802239:	d3 e2                	shl    %cl,%edx
  80223b:	89 c7                	mov    %eax,%edi
  80223d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802241:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 c1                	mov    %eax,%ecx
  80224b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80224f:	09 d1                	or     %edx,%ecx
  802251:	89 fa                	mov    %edi,%edx
  802253:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802257:	89 e9                	mov    %ebp,%ecx
  802259:	d3 e0                	shl    %cl,%eax
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802261:	89 f0                	mov    %esi,%eax
  802263:	d3 e8                	shr    %cl,%eax
  802265:	89 e9                	mov    %ebp,%ecx
  802267:	89 c7                	mov    %eax,%edi
  802269:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80226d:	d3 e6                	shl    %cl,%esi
  80226f:	89 d1                	mov    %edx,%ecx
  802271:	89 fa                	mov    %edi,%edx
  802273:	d3 e8                	shr    %cl,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	09 f0                	or     %esi,%eax
  802279:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80227d:	f7 74 24 10          	divl   0x10(%esp)
  802281:	d3 e6                	shl    %cl,%esi
  802283:	89 d1                	mov    %edx,%ecx
  802285:	f7 64 24 0c          	mull   0xc(%esp)
  802289:	39 d1                	cmp    %edx,%ecx
  80228b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80228f:	89 d7                	mov    %edx,%edi
  802291:	89 c6                	mov    %eax,%esi
  802293:	72 0a                	jb     80229f <__umoddi3+0x12f>
  802295:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802299:	73 10                	jae    8022ab <__umoddi3+0x13b>
  80229b:	39 d1                	cmp    %edx,%ecx
  80229d:	75 0c                	jne    8022ab <__umoddi3+0x13b>
  80229f:	89 d7                	mov    %edx,%edi
  8022a1:	89 c6                	mov    %eax,%esi
  8022a3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022a7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022ab:	89 ca                	mov    %ecx,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022b3:	29 f0                	sub    %esi,%eax
  8022b5:	19 fa                	sbb    %edi,%edx
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022be:	89 d7                	mov    %edx,%edi
  8022c0:	d3 e7                	shl    %cl,%edi
  8022c2:	89 e9                	mov    %ebp,%ecx
  8022c4:	09 f8                	or     %edi,%eax
  8022c6:	d3 ea                	shr    %cl,%edx
  8022c8:	83 c4 20             	add    $0x20,%esp
  8022cb:	5e                   	pop    %esi
  8022cc:	5f                   	pop    %edi
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    
  8022cf:	90                   	nop
  8022d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022d4:	29 f9                	sub    %edi,%ecx
  8022d6:	19 c6                	sbb    %eax,%esi
  8022d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022dc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022e0:	e9 ff fe ff ff       	jmp    8021e4 <__umoddi3+0x74>
