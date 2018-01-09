
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", (uint32_t)addr);
  80003f:	53                   	push   %ebx
  800040:	68 00 1f 80 00       	push   $0x801f00
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 33 0b 00 00       	call   800b91 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %i", (uint32_t)addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 1f 80 00       	push   $0x801f20
  80006f:	6a 0e                	push   $0xe
  800071:	68 0a 1f 80 00       	push   $0x801f0a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", (uint32_t)addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 1f 80 00       	push   $0x801f4c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ab 06 00 00       	call   800734 <snprintf>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 00 0d 00 00       	call   800da1 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 1c 1f 80 00       	push   $0x801f1c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 1c 1f 80 00       	push   $0x801f1c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
}
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d5:	e8 79 0a 00 00       	call   800b53 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 78             	imul   $0x78,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
  800106:	83 c4 10             	add    $0x10,%esp
#endif
}
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 e9 0e 00 00       	call   801004 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 ed 09 00 00       	call   800b12 <sys_env_destroy>
  800125:	83 c4 10             	add    $0x10,%esp
}
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 16 0a 00 00       	call   800b53 <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 78 1f 80 00       	push   $0x801f78
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 35 09 00 00       	call   800ad5 <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 4f 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 da 08 00 00       	call   800ad5 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 d1                	mov    %edx,%ecx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800242:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800245:	72 05                	jb     80024c <printnum+0x35>
  800247:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024a:	77 3e                	ja     80028a <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	53                   	push   %ebx
  800256:	50                   	push   %eax
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 e5 19 00 00       	call   801c50 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 13                	jmp    800291 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	7f ed                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	83 ec 04             	sub    $0x4,%esp
  800298:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029b:	ff 75 e0             	pushl  -0x20(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 d7 1a 00 00       	call   801d80 <__umoddi3>
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  8002b3:	50                   	push   %eax
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
}
  8002b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5e                   	pop    %esi
  8002be:	5f                   	pop    %edi
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c4:	83 fa 01             	cmp    $0x1,%edx
  8002c7:	7e 0e                	jle    8002d7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	8b 52 04             	mov    0x4(%edx),%edx
  8002d5:	eb 22                	jmp    8002f9 <getuint+0x38>
	else if (lflag)
  8002d7:	85 d2                	test   %edx,%edx
  8002d9:	74 10                	je     8002eb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e9:	eb 0e                	jmp    8002f9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800301:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800305:	8b 10                	mov    (%eax),%edx
  800307:	3b 50 04             	cmp    0x4(%eax),%edx
  80030a:	73 0a                	jae    800316 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	88 02                	mov    %al,(%edx)
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 05 00 00 00       	call   800335 <vprintfmt>
	va_end(ap);
  800330:	83 c4 10             	add    $0x10,%esp
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 2c             	sub    $0x2c,%esp
  80033e:	8b 75 08             	mov    0x8(%ebp),%esi
  800341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800344:	8b 7d 10             	mov    0x10(%ebp),%edi
  800347:	eb 12                	jmp    80035b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800349:	85 c0                	test   %eax,%eax
  80034b:	0f 84 8d 03 00 00    	je     8006de <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	53                   	push   %ebx
  800355:	50                   	push   %eax
  800356:	ff d6                	call   *%esi
  800358:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035b:	83 c7 01             	add    $0x1,%edi
  80035e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800362:	83 f8 25             	cmp    $0x25,%eax
  800365:	75 e2                	jne    800349 <vprintfmt+0x14>
  800367:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800372:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800379:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	eb 07                	jmp    80038e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8d 47 01             	lea    0x1(%edi),%eax
  800391:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800394:	0f b6 07             	movzbl (%edi),%eax
  800397:	0f b6 c8             	movzbl %al,%ecx
  80039a:	83 e8 23             	sub    $0x23,%eax
  80039d:	3c 55                	cmp    $0x55,%al
  80039f:	0f 87 1e 03 00 00    	ja     8006c3 <vprintfmt+0x38e>
  8003a5:	0f b6 c0             	movzbl %al,%eax
  8003a8:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b6:	eb d6                	jmp    80038e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ca:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d0:	83 fa 09             	cmp    $0x9,%edx
  8003d3:	77 38                	ja     80040d <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d8:	eb e9                	jmp    8003c3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003eb:	eb 26                	jmp    800413 <vprintfmt+0xde>
  8003ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f0:	89 c8                	mov    %ecx,%eax
  8003f2:	c1 f8 1f             	sar    $0x1f,%eax
  8003f5:	f7 d0                	not    %eax
  8003f7:	21 c1                	and    %eax,%ecx
  8003f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ff:	eb 8d                	jmp    80038e <vprintfmt+0x59>
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800404:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040b:	eb 81                	jmp    80038e <vprintfmt+0x59>
  80040d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800410:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 89 71 ff ff ff    	jns    80038e <vprintfmt+0x59>
				width = precision, precision = -1;
  80041d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042a:	e9 5f ff ff ff       	jmp    80038e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 54 ff ff ff       	jmp    80038e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	ff 30                	pushl  (%eax)
  800449:	ff d6                	call   *%esi
			break;
  80044b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 05 ff ff ff       	jmp    80035b <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	99                   	cltd   
  800462:	31 d0                	xor    %edx,%eax
  800464:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800466:	83 f8 0f             	cmp    $0xf,%eax
  800469:	7f 0b                	jg     800476 <vprintfmt+0x141>
  80046b:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	75 18                	jne    80048e <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800476:	50                   	push   %eax
  800477:	68 b3 1f 80 00       	push   $0x801fb3
  80047c:	53                   	push   %ebx
  80047d:	56                   	push   %esi
  80047e:	e8 95 fe ff ff       	call   800318 <printfmt>
  800483:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 cd fe ff ff       	jmp    80035b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	52                   	push   %edx
  80048f:	68 21 24 80 00       	push   $0x802421
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 7d fe ff ff       	call   800318 <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a1:	e9 b5 fe ff ff       	jmp    80035b <vprintfmt+0x26>
  8004a6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 38                	mov    (%eax),%edi
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	75 05                	jne    8004c3 <vprintfmt+0x18e>
				p = "(null)";
  8004be:	bf ac 1f 80 00       	mov    $0x801fac,%edi
			if (width > 0 && padc != '-')
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 91 00 00 00    	je     80055e <vprintfmt+0x229>
  8004cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d1:	0f 8e 95 00 00 00    	jle    80056c <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	51                   	push   %ecx
  8004db:	57                   	push   %edi
  8004dc:	e8 85 02 00 00       	call   800766 <strnlen>
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c5>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800513:	89 c8                	mov    %ecx,%eax
  800515:	c1 f8 1f             	sar    $0x1f,%eax
  800518:	f7 d0                	not    %eax
  80051a:	21 c8                	and    %ecx,%eax
  80051c:	29 c1                	sub    %eax,%ecx
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	89 cb                	mov    %ecx,%ebx
  800529:	eb 4d                	jmp    800578 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052f:	74 1b                	je     80054c <vprintfmt+0x217>
  800531:	0f be c0             	movsbl %al,%eax
  800534:	83 e8 20             	sub    $0x20,%eax
  800537:	83 f8 5e             	cmp    $0x5e,%eax
  80053a:	76 10                	jbe    80054c <vprintfmt+0x217>
					putch('?', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	6a 3f                	push   $0x3f
  800544:	ff 55 08             	call   *0x8(%ebp)
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	eb 0d                	jmp    800559 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	52                   	push   %edx
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	83 eb 01             	sub    $0x1,%ebx
  80055c:	eb 1a                	jmp    800578 <vprintfmt+0x243>
  80055e:	89 75 08             	mov    %esi,0x8(%ebp)
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800564:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800567:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056a:	eb 0c                	jmp    800578 <vprintfmt+0x243>
  80056c:	89 75 08             	mov    %esi,0x8(%ebp)
  80056f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800572:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800575:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800578:	83 c7 01             	add    $0x1,%edi
  80057b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057f:	0f be d0             	movsbl %al,%edx
  800582:	85 d2                	test   %edx,%edx
  800584:	74 23                	je     8005a9 <vprintfmt+0x274>
  800586:	85 f6                	test   %esi,%esi
  800588:	78 a1                	js     80052b <vprintfmt+0x1f6>
  80058a:	83 ee 01             	sub    $0x1,%esi
  80058d:	79 9c                	jns    80052b <vprintfmt+0x1f6>
  80058f:	89 df                	mov    %ebx,%edi
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800597:	eb 18                	jmp    8005b1 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	6a 20                	push   $0x20
  80059f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a1:	83 ef 01             	sub    $0x1,%edi
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 08                	jmp    8005b1 <vprintfmt+0x27c>
  8005a9:	89 df                	mov    %ebx,%edi
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	7f e4                	jg     800599 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 9e fd ff ff       	jmp    80035b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bd:	83 fa 01             	cmp    $0x1,%edx
  8005c0:	7e 16                	jle    8005d8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 08             	lea    0x8(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	eb 32                	jmp    80060a <vprintfmt+0x2d5>
	else if (lflag)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 18                	je     8005f4 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f2:	eb 16                	jmp    80060a <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800610:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800615:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800619:	79 74                	jns    80068f <vprintfmt+0x35a>
				putch('-', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 2d                	push   $0x2d
  800621:	ff d6                	call   *%esi
				num = -(long long) num;
  800623:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800626:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800629:	f7 d8                	neg    %eax
  80062b:	83 d2 00             	adc    $0x0,%edx
  80062e:	f7 da                	neg    %edx
  800630:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800638:	eb 55                	jmp    80068f <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 7f fc ff ff       	call   8002c1 <getuint>
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800647:	eb 46                	jmp    80068f <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 70 fc ff ff       	call   8002c1 <getuint>
			base = 8;
  800651:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800656:	eb 37                	jmp    80068f <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 30                	push   $0x30
  80065e:	ff d6                	call   *%esi
			putch('x', putdat);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 78                	push   $0x78
  800666:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800680:	eb 0d                	jmp    80068f <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 37 fc ff ff       	call   8002c1 <getuint>
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800696:	57                   	push   %edi
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	51                   	push   %ecx
  80069b:	52                   	push   %edx
  80069c:	50                   	push   %eax
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 71 fb ff ff       	call   800217 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ac:	e9 aa fc ff ff       	jmp    80035b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	51                   	push   %ecx
  8006b6:	ff d6                	call   *%esi
			break;
  8006b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006be:	e9 98 fc ff ff       	jmp    80035b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 25                	push   $0x25
  8006c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 03                	jmp    8006d3 <vprintfmt+0x39e>
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d7:	75 f7                	jne    8006d0 <vprintfmt+0x39b>
  8006d9:	e9 7d fc ff ff       	jmp    80035b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5f                   	pop    %edi
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 18             	sub    $0x18,%esp
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 26                	je     80072d <vsnprintf+0x47>
  800707:	85 d2                	test   %edx,%edx
  800709:	7e 22                	jle    80072d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070b:	ff 75 14             	pushl  0x14(%ebp)
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800714:	50                   	push   %eax
  800715:	68 fb 02 80 00       	push   $0x8002fb
  80071a:	e8 16 fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800722:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 05                	jmp    800732 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	ff 75 08             	pushl  0x8(%ebp)
  800747:	e8 9a ff ff ff       	call   8006e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 03                	jmp    80075e <strlen+0x10>
		n++;
  80075b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	75 f7                	jne    80075b <strlen+0xd>
		n++;
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
  800774:	eb 03                	jmp    800779 <strnlen+0x13>
		n++;
  800776:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	39 c2                	cmp    %eax,%edx
  80077b:	74 08                	je     800785 <strnlen+0x1f>
  80077d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800781:	75 f3                	jne    800776 <strnlen+0x10>
  800783:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	75 ef                	jne    800793 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 9a ff ff ff       	call   80074e <strlen>
  8007b4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 c5 ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d4:	89 f3                	mov    %esi,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	89 f2                	mov    %esi,%edx
  8007db:	eb 0f                	jmp    8007ec <strncpy+0x23>
		*dst++ = *src;
  8007dd:	83 c2 01             	add    $0x1,%edx
  8007e0:	0f b6 01             	movzbl (%ecx),%eax
  8007e3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	39 da                	cmp    %ebx,%edx
  8007ee:	75 ed                	jne    8007dd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
  800804:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	85 d2                	test   %edx,%edx
  800808:	74 21                	je     80082b <strlcpy+0x35>
  80080a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080e:	89 f2                	mov    %esi,%edx
  800810:	eb 09                	jmp    80081b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081b:	39 c2                	cmp    %eax,%edx
  80081d:	74 09                	je     800828 <strlcpy+0x32>
  80081f:	0f b6 19             	movzbl (%ecx),%ebx
  800822:	84 db                	test   %bl,%bl
  800824:	75 ec                	jne    800812 <strlcpy+0x1c>
  800826:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800828:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082b:	29 f0                	sub    %esi,%eax
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083a:	eb 06                	jmp    800842 <strcmp+0x11>
		p++, q++;
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	84 c0                	test   %al,%al
  800847:	74 04                	je     80084d <strcmp+0x1c>
  800849:	3a 02                	cmp    (%edx),%al
  80084b:	74 ef                	je     80083c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 c3                	mov    %eax,%ebx
  800863:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800866:	eb 06                	jmp    80086e <strncmp+0x17>
		n--, p++, q++;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086e:	39 d8                	cmp    %ebx,%eax
  800870:	74 15                	je     800887 <strncmp+0x30>
  800872:	0f b6 08             	movzbl (%eax),%ecx
  800875:	84 c9                	test   %cl,%cl
  800877:	74 04                	je     80087d <strncmp+0x26>
  800879:	3a 0a                	cmp    (%edx),%cl
  80087b:	74 eb                	je     800868 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 00             	movzbl (%eax),%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
  800885:	eb 05                	jmp    80088c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800899:	eb 07                	jmp    8008a2 <strchr+0x13>
		if (*s == c)
  80089b:	38 ca                	cmp    %cl,%dl
  80089d:	74 0f                	je     8008ae <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f2                	jne    80089b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	eb 03                	jmp    8008bf <strfind+0xf>
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	74 04                	je     8008ca <strfind+0x1a>
  8008c6:	38 ca                	cmp    %cl,%dl
  8008c8:	75 f2                	jne    8008bc <strfind+0xc>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 36                	je     800912 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 28                	jne    80090c <memset+0x40>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 23                	jne    80090c <memset+0x40>
		c &= 0xFF;
  8008e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 08             	shl    $0x8,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 18             	shl    $0x18,%esi
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 10             	shl    $0x10,%eax
  8008fc:	09 f0                	or     %esi,%eax
  8008fe:	09 c2                	or     %eax,%edx
  800900:	89 d0                	mov    %edx,%eax
  800902:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800904:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800907:	fc                   	cld    
  800908:	f3 ab                	rep stos %eax,%es:(%edi)
  80090a:	eb 06                	jmp    800912 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	fc                   	cld    
  800910:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800912:	89 f8                	mov    %edi,%eax
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 75 0c             	mov    0xc(%ebp),%esi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800927:	39 c6                	cmp    %eax,%esi
  800929:	73 35                	jae    800960 <memmove+0x47>
  80092b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092e:	39 d0                	cmp    %edx,%eax
  800930:	73 2e                	jae    800960 <memmove+0x47>
		s += n;
		d += n;
  800932:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800935:	89 d6                	mov    %edx,%esi
  800937:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093f:	75 13                	jne    800954 <memmove+0x3b>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0e                	jne    800954 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 09                	jmp    80095d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 1d                	jmp    80097d <memmove+0x64>
  800960:	89 f2                	mov    %esi,%edx
  800962:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	f6 c2 03             	test   $0x3,%dl
  800967:	75 0f                	jne    800978 <memmove+0x5f>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0a                	jne    800978 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 87 ff ff ff       	call   800919 <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 c6                	mov    %eax,%esi
  8009a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	eb 1a                	jmp    8009c0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	74 0a                	je     8009ba <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b0:	0f b6 c1             	movzbl %cl,%eax
  8009b3:	0f b6 db             	movzbl %bl,%ebx
  8009b6:	29 d8                	sub    %ebx,%eax
  8009b8:	eb 0f                	jmp    8009c9 <memcmp+0x35>
		s1++, s2++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	39 f0                	cmp    %esi,%eax
  8009c2:	75 e2                	jne    8009a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009db:	eb 07                	jmp    8009e4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	38 08                	cmp    %cl,(%eax)
  8009df:	74 07                	je     8009e8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	72 f5                	jb     8009dd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	eb 03                	jmp    8009fb <strtol+0x11>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f6                	je     8009f8 <strtol+0xe>
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f2                	je     8009f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a06:	3c 2b                	cmp    $0x2b,%al
  800a08:	75 0a                	jne    800a14 <strtol+0x2a>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a12:	eb 10                	jmp    800a24 <strtol+0x3a>
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	75 07                	jne    800a24 <strtol+0x3a>
		s++, neg = 1;
  800a1d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a20:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	85 db                	test   %ebx,%ebx
  800a26:	0f 94 c0             	sete   %al
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 19                	jne    800a4a <strtol+0x60>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 14                	jne    800a4a <strtol+0x60>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	0f 85 8a 00 00 00    	jne    800aca <strtol+0xe0>
		s += 2, base = 16;
  800a40:	83 c1 02             	add    $0x2,%ecx
  800a43:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a48:	eb 16                	jmp    800a60 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4a:	84 c0                	test   %al,%al
  800a4c:	74 12                	je     800a60 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	75 08                	jne    800a60 <strtol+0x76>
		s++, base = 8;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a68:	0f b6 11             	movzbl (%ecx),%edx
  800a6b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 09             	cmp    $0x9,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x93>
			dig = *s - '0';
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 30             	sub    $0x30,%edx
  800a7b:	eb 22                	jmp    800a9f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 08                	ja     800a8f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 57             	sub    $0x57,%edx
  800a8d:	eb 10                	jmp    800a9f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 16                	ja     800aaf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa2:	7d 0f                	jge    800ab3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aab:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aad:	eb b9                	jmp    800a68 <strtol+0x7e>
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	eb 02                	jmp    800ab5 <strtol+0xcb>
  800ab3:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 05                	je     800ac0 <strtol+0xd6>
		*endptr = (char *) s;
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	74 0c                	je     800ad0 <strtol+0xe6>
  800ac4:	89 d0                	mov    %edx,%eax
  800ac6:	f7 d8                	neg    %eax
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	84 c0                	test   %al,%al
  800acc:	75 8a                	jne    800a58 <strtol+0x6e>
  800ace:	eb 90                	jmp    800a60 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	89 c7                	mov    %eax,%edi
  800aea:	89 c6                	mov    %eax,%esi
  800aec:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 01 00 00 00       	mov    $0x1,%eax
  800b03:	89 d1                	mov    %edx,%ecx
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	89 d7                	mov    %edx,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b20:	b8 03 00 00 00       	mov    $0x3,%eax
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	89 cb                	mov    %ecx,%ebx
  800b2a:	89 cf                	mov    %ecx,%edi
  800b2c:	89 ce                	mov    %ecx,%esi
  800b2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b30:	85 c0                	test   %eax,%eax
  800b32:	7e 17                	jle    800b4b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	50                   	push   %eax
  800b38:	6a 03                	push   $0x3
  800b3a:	68 df 22 80 00       	push   $0x8022df
  800b3f:	6a 23                	push   $0x23
  800b41:	68 fc 22 80 00       	push   $0x8022fc
  800b46:	e8 df f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_yield>:

void
sys_yield(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	be 00 00 00 00       	mov    $0x0,%esi
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bad:	89 f7                	mov    %esi,%edi
  800baf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 04                	push   $0x4
  800bbb:	68 df 22 80 00       	push   $0x8022df
  800bc0:	6a 23                	push   $0x23
  800bc2:	68 fc 22 80 00       	push   $0x8022fc
  800bc7:	e8 5e f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	b8 05 00 00 00       	mov    $0x5,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800beb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bee:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 05                	push   $0x5
  800bfd:	68 df 22 80 00       	push   $0x8022df
  800c02:	6a 23                	push   $0x23
  800c04:	68 fc 22 80 00       	push   $0x8022fc
  800c09:	e8 1c f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c24:	b8 06 00 00 00       	mov    $0x6,%eax
  800c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	89 df                	mov    %ebx,%edi
  800c31:	89 de                	mov    %ebx,%esi
  800c33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 06                	push   $0x6
  800c3f:	68 df 22 80 00       	push   $0x8022df
  800c44:	6a 23                	push   $0x23
  800c46:	68 fc 22 80 00       	push   $0x8022fc
  800c4b:	e8 da f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c66:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 df                	mov    %ebx,%edi
  800c73:	89 de                	mov    %ebx,%esi
  800c75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 08                	push   $0x8
  800c81:	68 df 22 80 00       	push   $0x8022df
  800c86:	6a 23                	push   $0x23
  800c88:	68 fc 22 80 00       	push   $0x8022fc
  800c8d:	e8 98 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 09                	push   $0x9
  800cc3:	68 df 22 80 00       	push   $0x8022df
  800cc8:	6a 23                	push   $0x23
  800cca:	68 fc 22 80 00       	push   $0x8022fc
  800ccf:	e8 56 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 0a                	push   $0xa
  800d05:	68 df 22 80 00       	push   $0x8022df
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 fc 22 80 00       	push   $0x8022fc
  800d11:	e8 14 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	89 ce                	mov    %ecx,%esi
  800d5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0d                	push   $0xd
  800d69:	68 df 22 80 00       	push   $0x8022df
  800d6e:	6a 23                	push   $0x23
  800d70:	68 fc 22 80 00       	push   $0x8022fc
  800d75:	e8 b0 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_gettime>:

int sys_gettime(void)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 d3                	mov    %edx,%ebx
  800d96:	89 d7                	mov    %edx,%edi
  800d98:	89 d6                	mov    %edx,%esi
  800d9a:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800da7:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dae:	75 2c                	jne    800ddc <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	6a 07                	push   $0x7
  800db5:	68 00 f0 7f ee       	push   $0xee7ff000
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 d0 fd ff ff       	call   800b91 <sys_page_alloc>
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	79 14                	jns    800ddc <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	68 0c 23 80 00       	push   $0x80230c
  800dd0:	6a 1f                	push   $0x1f
  800dd2:	68 6e 23 80 00       	push   $0x80236e
  800dd7:	e8 4e f3 ff ff       	call   80012a <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	68 10 0e 80 00       	push   $0x800e10
  800dec:	6a 00                	push   $0x0
  800dee:	e8 e9 fe ff ff       	call   800cdc <sys_env_set_pgfault_upcall>
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	79 14                	jns    800e0e <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	68 38 23 80 00       	push   $0x802338
  800e02:	6a 25                	push   $0x25
  800e04:	68 6e 23 80 00       	push   $0x80236e
  800e09:	e8 1c f3 ff ff       	call   80012a <_panic>
}
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e10:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e11:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e16:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e18:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  800e1b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  800e1d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  800e21:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  800e25:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  800e26:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  800e29:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  800e2b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  800e2e:	83 c4 04             	add    $0x4,%esp
	popal 
  800e31:	61                   	popa   
	addl $4, %esp 
  800e32:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  800e35:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  800e36:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  800e37:	c3                   	ret    

00800e38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e43:	c1 e8 0c             	shr    $0xc,%eax
}
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e58:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e65:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6a:	89 c2                	mov    %eax,%edx
  800e6c:	c1 ea 16             	shr    $0x16,%edx
  800e6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e76:	f6 c2 01             	test   $0x1,%dl
  800e79:	74 11                	je     800e8c <fd_alloc+0x2d>
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	c1 ea 0c             	shr    $0xc,%edx
  800e80:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e87:	f6 c2 01             	test   $0x1,%dl
  800e8a:	75 09                	jne    800e95 <fd_alloc+0x36>
			*fd_store = fd;
  800e8c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	eb 17                	jmp    800eac <fd_alloc+0x4d>
  800e95:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e9a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9f:	75 c9                	jne    800e6a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb4:	83 f8 1f             	cmp    $0x1f,%eax
  800eb7:	77 36                	ja     800eef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb9:	c1 e0 0c             	shl    $0xc,%eax
  800ebc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	c1 ea 16             	shr    $0x16,%edx
  800ec6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecd:	f6 c2 01             	test   $0x1,%dl
  800ed0:	74 24                	je     800ef6 <fd_lookup+0x48>
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	c1 ea 0c             	shr    $0xc,%edx
  800ed7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ede:	f6 c2 01             	test   $0x1,%dl
  800ee1:	74 1a                	je     800efd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee6:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	eb 13                	jmp    800f02 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef4:	eb 0c                	jmp    800f02 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efb:	eb 05                	jmp    800f02 <fd_lookup+0x54>
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0d:	ba f8 23 80 00       	mov    $0x8023f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f12:	eb 13                	jmp    800f27 <dev_lookup+0x23>
  800f14:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f17:	39 08                	cmp    %ecx,(%eax)
  800f19:	75 0c                	jne    800f27 <dev_lookup+0x23>
			*dev = devtab[i];
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	eb 2e                	jmp    800f55 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f27:	8b 02                	mov    (%edx),%eax
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	75 e7                	jne    800f14 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f32:	8b 40 48             	mov    0x48(%eax),%eax
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	51                   	push   %ecx
  800f39:	50                   	push   %eax
  800f3a:	68 7c 23 80 00       	push   $0x80237c
  800f3f:	e8 bf f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 10             	sub    $0x10,%esp
  800f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f68:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f69:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f6f:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f72:	50                   	push   %eax
  800f73:	e8 36 ff ff ff       	call   800eae <fd_lookup>
  800f78:	83 c4 08             	add    $0x8,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 05                	js     800f84 <fd_close+0x2d>
	    || fd != fd2)
  800f7f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f82:	74 0b                	je     800f8f <fd_close+0x38>
		return (must_exist ? r : 0);
  800f84:	80 fb 01             	cmp    $0x1,%bl
  800f87:	19 d2                	sbb    %edx,%edx
  800f89:	f7 d2                	not    %edx
  800f8b:	21 d0                	and    %edx,%eax
  800f8d:	eb 41                	jmp    800fd0 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	ff 36                	pushl  (%esi)
  800f98:	e8 67 ff ff ff       	call   800f04 <dev_lookup>
  800f9d:	89 c3                	mov    %eax,%ebx
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	78 1a                	js     800fc0 <fd_close+0x69>
		if (dev->dev_close)
  800fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	74 0b                	je     800fc0 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	56                   	push   %esi
  800fb9:	ff d0                	call   *%eax
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	56                   	push   %esi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 4b fc ff ff       	call   800c16 <sys_page_unmap>
	return r;
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	89 d8                	mov    %ebx,%eax
}
  800fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 75 08             	pushl  0x8(%ebp)
  800fe4:	e8 c5 fe ff ff       	call   800eae <fd_lookup>
  800fe9:	89 c2                	mov    %eax,%edx
  800feb:	83 c4 08             	add    $0x8,%esp
  800fee:	85 d2                	test   %edx,%edx
  800ff0:	78 10                	js     801002 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	6a 01                	push   $0x1
  800ff7:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffa:	e8 58 ff ff ff       	call   800f57 <fd_close>
  800fff:	83 c4 10             	add    $0x10,%esp
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <close_all>:

void
close_all(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	53                   	push   %ebx
  801008:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80100b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	53                   	push   %ebx
  801014:	e8 be ff ff ff       	call   800fd7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801019:	83 c3 01             	add    $0x1,%ebx
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	83 fb 20             	cmp    $0x20,%ebx
  801022:	75 ec                	jne    801010 <close_all+0xc>
		close(i);
}
  801024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	57                   	push   %edi
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 2c             	sub    $0x2c,%esp
  801032:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	ff 75 08             	pushl  0x8(%ebp)
  80103c:	e8 6d fe ff ff       	call   800eae <fd_lookup>
  801041:	89 c2                	mov    %eax,%edx
  801043:	83 c4 08             	add    $0x8,%esp
  801046:	85 d2                	test   %edx,%edx
  801048:	0f 88 c1 00 00 00    	js     80110f <dup+0xe6>
		return r;
	close(newfdnum);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	56                   	push   %esi
  801052:	e8 80 ff ff ff       	call   800fd7 <close>

	newfd = INDEX2FD(newfdnum);
  801057:	89 f3                	mov    %esi,%ebx
  801059:	c1 e3 0c             	shl    $0xc,%ebx
  80105c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801062:	83 c4 04             	add    $0x4,%esp
  801065:	ff 75 e4             	pushl  -0x1c(%ebp)
  801068:	e8 db fd ff ff       	call   800e48 <fd2data>
  80106d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80106f:	89 1c 24             	mov    %ebx,(%esp)
  801072:	e8 d1 fd ff ff       	call   800e48 <fd2data>
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107d:	89 f8                	mov    %edi,%eax
  80107f:	c1 e8 16             	shr    $0x16,%eax
  801082:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801089:	a8 01                	test   $0x1,%al
  80108b:	74 37                	je     8010c4 <dup+0x9b>
  80108d:	89 f8                	mov    %edi,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
  801092:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801099:	f6 c2 01             	test   $0x1,%dl
  80109c:	74 26                	je     8010c4 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ad:	50                   	push   %eax
  8010ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b1:	6a 00                	push   $0x0
  8010b3:	57                   	push   %edi
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 19 fb ff ff       	call   800bd4 <sys_page_map>
  8010bb:	89 c7                	mov    %eax,%edi
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 2e                	js     8010f2 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c7:	89 d0                	mov    %edx,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010db:	50                   	push   %eax
  8010dc:	53                   	push   %ebx
  8010dd:	6a 00                	push   $0x0
  8010df:	52                   	push   %edx
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 ed fa ff ff       	call   800bd4 <sys_page_map>
  8010e7:	89 c7                	mov    %eax,%edi
  8010e9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ec:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ee:	85 ff                	test   %edi,%edi
  8010f0:	79 1d                	jns    80110f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	53                   	push   %ebx
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 19 fb ff ff       	call   800c16 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	ff 75 d4             	pushl  -0x2c(%ebp)
  801103:	6a 00                	push   $0x0
  801105:	e8 0c fb ff ff       	call   800c16 <sys_page_unmap>
	return r;
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	89 f8                	mov    %edi,%eax
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	53                   	push   %ebx
  80111b:	83 ec 14             	sub    $0x14,%esp
  80111e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801121:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	53                   	push   %ebx
  801126:	e8 83 fd ff ff       	call   800eae <fd_lookup>
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	89 c2                	mov    %eax,%edx
  801130:	85 c0                	test   %eax,%eax
  801132:	78 6d                	js     8011a1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	ff 30                	pushl  (%eax)
  801140:	e8 bf fd ff ff       	call   800f04 <dev_lookup>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 4c                	js     801198 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114f:	8b 42 08             	mov    0x8(%edx),%eax
  801152:	83 e0 03             	and    $0x3,%eax
  801155:	83 f8 01             	cmp    $0x1,%eax
  801158:	75 21                	jne    80117b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115a:	a1 04 40 80 00       	mov    0x804004,%eax
  80115f:	8b 40 48             	mov    0x48(%eax),%eax
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	53                   	push   %ebx
  801166:	50                   	push   %eax
  801167:	68 bd 23 80 00       	push   $0x8023bd
  80116c:	e8 92 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801179:	eb 26                	jmp    8011a1 <read+0x8a>
	}
	if (!dev->dev_read)
  80117b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117e:	8b 40 08             	mov    0x8(%eax),%eax
  801181:	85 c0                	test   %eax,%eax
  801183:	74 17                	je     80119c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	ff 75 10             	pushl  0x10(%ebp)
  80118b:	ff 75 0c             	pushl  0xc(%ebp)
  80118e:	52                   	push   %edx
  80118f:	ff d0                	call   *%eax
  801191:	89 c2                	mov    %eax,%edx
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	eb 09                	jmp    8011a1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801198:	89 c2                	mov    %eax,%edx
  80119a:	eb 05                	jmp    8011a1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80119c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011a1:	89 d0                	mov    %edx,%eax
  8011a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bc:	eb 21                	jmp    8011df <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	89 f0                	mov    %esi,%eax
  8011c3:	29 d8                	sub    %ebx,%eax
  8011c5:	50                   	push   %eax
  8011c6:	89 d8                	mov    %ebx,%eax
  8011c8:	03 45 0c             	add    0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	57                   	push   %edi
  8011cd:	e8 45 ff ff ff       	call   801117 <read>
		if (m < 0)
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 0c                	js     8011e5 <readn+0x3d>
			return m;
		if (m == 0)
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	74 06                	je     8011e3 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011dd:	01 c3                	add    %eax,%ebx
  8011df:	39 f3                	cmp    %esi,%ebx
  8011e1:	72 db                	jb     8011be <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011e3:	89 d8                	mov    %ebx,%eax
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 14             	sub    $0x14,%esp
  8011f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	53                   	push   %ebx
  8011fc:	e8 ad fc ff ff       	call   800eae <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	89 c2                	mov    %eax,%edx
  801206:	85 c0                	test   %eax,%eax
  801208:	78 68                	js     801272 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	ff 30                	pushl  (%eax)
  801216:	e8 e9 fc ff ff       	call   800f04 <dev_lookup>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 47                	js     801269 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801222:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801225:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801229:	75 21                	jne    80124c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 04 40 80 00       	mov    0x804004,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 d9 23 80 00       	push   $0x8023d9
  80123d:	e8 c1 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124a:	eb 26                	jmp    801272 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124f:	8b 52 0c             	mov    0xc(%edx),%edx
  801252:	85 d2                	test   %edx,%edx
  801254:	74 17                	je     80126d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	50                   	push   %eax
  801260:	ff d2                	call   *%edx
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <seek>:

int
seek(int fdnum, off_t offset)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 23 fc ff ff       	call   800eae <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 0e                	js     8012a0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801292:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
  801298:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 14             	sub    $0x14,%esp
  8012a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	53                   	push   %ebx
  8012b1:	e8 f8 fb ff ff       	call   800eae <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 65                	js     801324 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 34 fc ff ff       	call   800f04 <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 44                	js     80131b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012de:	75 21                	jne    801301 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e5:	8b 40 48             	mov    0x48(%eax),%eax
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	50                   	push   %eax
  8012ed:	68 9c 23 80 00       	push   $0x80239c
  8012f2:	e8 0c ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ff:	eb 23                	jmp    801324 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801301:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801304:	8b 52 18             	mov    0x18(%edx),%edx
  801307:	85 d2                	test   %edx,%edx
  801309:	74 14                	je     80131f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	ff 75 0c             	pushl  0xc(%ebp)
  801311:	50                   	push   %eax
  801312:	ff d2                	call   *%edx
  801314:	89 c2                	mov    %eax,%edx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	eb 09                	jmp    801324 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	eb 05                	jmp    801324 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801324:	89 d0                	mov    %edx,%eax
  801326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 14             	sub    $0x14,%esp
  801332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 6d fb ff ff       	call   800eae <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	89 c2                	mov    %eax,%edx
  801346:	85 c0                	test   %eax,%eax
  801348:	78 58                	js     8013a2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	ff 30                	pushl  (%eax)
  801356:	e8 a9 fb ff ff       	call   800f04 <dev_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 37                	js     801399 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801369:	74 32                	je     80139d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80136b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80136e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801375:	00 00 00 
	stat->st_isdir = 0;
  801378:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80137f:	00 00 00 
	stat->st_dev = dev;
  801382:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	ff 75 f0             	pushl  -0x10(%ebp)
  80138f:	ff 50 14             	call   *0x14(%eax)
  801392:	89 c2                	mov    %eax,%edx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	eb 09                	jmp    8013a2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801399:	89 c2                	mov    %eax,%edx
  80139b:	eb 05                	jmp    8013a2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80139d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a2:	89 d0                	mov    %edx,%eax
  8013a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	56                   	push   %esi
  8013ad:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	6a 00                	push   $0x0
  8013b3:	ff 75 08             	pushl  0x8(%ebp)
  8013b6:	e8 e7 01 00 00       	call   8015a2 <open>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 db                	test   %ebx,%ebx
  8013c2:	78 1b                	js     8013df <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	53                   	push   %ebx
  8013cb:	e8 5b ff ff ff       	call   80132b <fstat>
  8013d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d2:	89 1c 24             	mov    %ebx,(%esp)
  8013d5:	e8 fd fb ff ff       	call   800fd7 <close>
	return r;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	89 f0                	mov    %esi,%eax
}
  8013df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5e                   	pop    %esi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	89 c6                	mov    %eax,%esi
  8013ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f6:	75 12                	jne    80140a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	6a 03                	push   $0x3
  8013fd:	e8 d2 07 00 00       	call   801bd4 <ipc_find_env>
  801402:	a3 00 40 80 00       	mov    %eax,0x804000
  801407:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80140a:	6a 07                	push   $0x7
  80140c:	68 00 50 80 00       	push   $0x805000
  801411:	56                   	push   %esi
  801412:	ff 35 00 40 80 00    	pushl  0x804000
  801418:	e8 66 07 00 00       	call   801b83 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80141d:	83 c4 0c             	add    $0xc,%esp
  801420:	6a 00                	push   $0x0
  801422:	53                   	push   %ebx
  801423:	6a 00                	push   $0x0
  801425:	e8 f3 06 00 00       	call   801b1d <ipc_recv>
}
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801442:	8b 45 0c             	mov    0xc(%ebp),%eax
  801445:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 02 00 00 00       	mov    $0x2,%eax
  801454:	e8 8d ff ff ff       	call   8013e6 <fsipc>
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 06 00 00 00       	mov    $0x6,%eax
  801476:	e8 6b ff ff ff       	call   8013e6 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 05 00 00 00       	mov    $0x5,%eax
  80149c:	e8 45 ff ff ff       	call   8013e6 <fsipc>
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	85 d2                	test   %edx,%edx
  8014a5:	78 2c                	js     8014d3 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	53                   	push   %ebx
  8014b0:	e8 d2 f2 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8014e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e7:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8014ed:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8014f2:	76 05                	jbe    8014f9 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8014f4:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8014f9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	50                   	push   %eax
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	68 08 50 80 00       	push   $0x805008
  80150a:	e8 0a f4 ff ff       	call   800919 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 04 00 00 00       	mov    $0x4,%eax
  801519:	e8 c8 fe ff ff       	call   8013e6 <fsipc>
	return write;
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	8b 40 0c             	mov    0xc(%eax),%eax
  80152e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801533:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 03 00 00 00       	mov    $0x3,%eax
  801543:	e8 9e fe ff ff       	call   8013e6 <fsipc>
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 4b                	js     801599 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154e:	39 c6                	cmp    %eax,%esi
  801550:	73 16                	jae    801568 <devfile_read+0x48>
  801552:	68 08 24 80 00       	push   $0x802408
  801557:	68 0f 24 80 00       	push   $0x80240f
  80155c:	6a 7c                	push   $0x7c
  80155e:	68 24 24 80 00       	push   $0x802424
  801563:	e8 c2 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801568:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156d:	7e 16                	jle    801585 <devfile_read+0x65>
  80156f:	68 2f 24 80 00       	push   $0x80242f
  801574:	68 0f 24 80 00       	push   $0x80240f
  801579:	6a 7d                	push   $0x7d
  80157b:	68 24 24 80 00       	push   $0x802424
  801580:	e8 a5 eb ff ff       	call   80012a <_panic>
	memmove(buf, &fsipcbuf, r);
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	50                   	push   %eax
  801589:	68 00 50 80 00       	push   $0x805000
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	e8 83 f3 ff ff       	call   800919 <memmove>
	return r;
  801596:	83 c4 10             	add    $0x10,%esp
}
  801599:	89 d8                	mov    %ebx,%eax
  80159b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 20             	sub    $0x20,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ac:	53                   	push   %ebx
  8015ad:	e8 9c f1 ff ff       	call   80074e <strlen>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ba:	7f 67                	jg     801623 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	e8 97 f8 ff ff       	call   800e5f <fd_alloc>
  8015c8:	83 c4 10             	add    $0x10,%esp
		return r;
  8015cb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 57                	js     801628 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	68 00 50 80 00       	push   $0x805000
  8015da:	e8 a8 f1 ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ef:	e8 f2 fd ff ff       	call   8013e6 <fsipc>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	79 14                	jns    801611 <open+0x6f>
		fd_close(fd, 0);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	6a 00                	push   $0x0
  801602:	ff 75 f4             	pushl  -0xc(%ebp)
  801605:	e8 4d f9 ff ff       	call   800f57 <fd_close>
		return r;
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	89 da                	mov    %ebx,%edx
  80160f:	eb 17                	jmp    801628 <open+0x86>
	}

	return fd2num(fd);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	ff 75 f4             	pushl  -0xc(%ebp)
  801617:	e8 1c f8 ff ff       	call   800e38 <fd2num>
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	eb 05                	jmp    801628 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801623:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801628:	89 d0                	mov    %edx,%eax
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	b8 08 00 00 00       	mov    $0x8,%eax
  80163f:	e8 a2 fd ff ff       	call   8013e6 <fsipc>
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 ef f7 ff ff       	call   800e48 <fd2data>
  801659:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	68 3b 24 80 00       	push   $0x80243b
  801663:	53                   	push   %ebx
  801664:	e8 1e f1 ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801669:	8b 56 04             	mov    0x4(%esi),%edx
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	2b 06                	sub    (%esi),%eax
  801670:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801676:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167d:	00 00 00 
	stat->st_dev = &devpipe;
  801680:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801687:	30 80 00 
	return 0;
}
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
  80168f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a0:	53                   	push   %ebx
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 6e f5 ff ff       	call   800c16 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a8:	89 1c 24             	mov    %ebx,(%esp)
  8016ab:	e8 98 f7 ff ff       	call   800e48 <fd2data>
  8016b0:	83 c4 08             	add    $0x8,%esp
  8016b3:	50                   	push   %eax
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 5b f5 ff ff       	call   800c16 <sys_page_unmap>
}
  8016bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 1c             	sub    $0x1c,%esp
  8016c9:	89 c7                	mov    %eax,%edi
  8016cb:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	57                   	push   %edi
  8016d9:	e8 2e 05 00 00       	call   801c0c <pageref>
  8016de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e1:	89 34 24             	mov    %esi,(%esp)
  8016e4:	e8 23 05 00 00       	call   801c0c <pageref>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ef:	0f 94 c0             	sete   %al
  8016f2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016f5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016fb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016fe:	39 cb                	cmp    %ecx,%ebx
  801700:	74 15                	je     801717 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801702:	8b 52 58             	mov    0x58(%edx),%edx
  801705:	50                   	push   %eax
  801706:	52                   	push   %edx
  801707:	53                   	push   %ebx
  801708:	68 48 24 80 00       	push   $0x802448
  80170d:	e8 f1 ea ff ff       	call   800203 <cprintf>
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb b6                	jmp    8016cd <_pipeisclosed+0xd>
	}
}
  801717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5f                   	pop    %edi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	57                   	push   %edi
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 28             	sub    $0x28,%esp
  801728:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80172b:	56                   	push   %esi
  80172c:	e8 17 f7 ff ff       	call   800e48 <fd2data>
  801731:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	bf 00 00 00 00       	mov    $0x0,%edi
  80173b:	eb 4b                	jmp    801788 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80173d:	89 da                	mov    %ebx,%edx
  80173f:	89 f0                	mov    %esi,%eax
  801741:	e8 7a ff ff ff       	call   8016c0 <_pipeisclosed>
  801746:	85 c0                	test   %eax,%eax
  801748:	75 48                	jne    801792 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80174a:	e8 23 f4 ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80174f:	8b 43 04             	mov    0x4(%ebx),%eax
  801752:	8b 0b                	mov    (%ebx),%ecx
  801754:	8d 51 20             	lea    0x20(%ecx),%edx
  801757:	39 d0                	cmp    %edx,%eax
  801759:	73 e2                	jae    80173d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801762:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801765:	89 c2                	mov    %eax,%edx
  801767:	c1 fa 1f             	sar    $0x1f,%edx
  80176a:	89 d1                	mov    %edx,%ecx
  80176c:	c1 e9 1b             	shr    $0x1b,%ecx
  80176f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801772:	83 e2 1f             	and    $0x1f,%edx
  801775:	29 ca                	sub    %ecx,%edx
  801777:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80177b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80177f:	83 c0 01             	add    $0x1,%eax
  801782:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801785:	83 c7 01             	add    $0x1,%edi
  801788:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80178b:	75 c2                	jne    80174f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80178d:	8b 45 10             	mov    0x10(%ebp),%eax
  801790:	eb 05                	jmp    801797 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5f                   	pop    %edi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	57                   	push   %edi
  8017a3:	56                   	push   %esi
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 18             	sub    $0x18,%esp
  8017a8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ab:	57                   	push   %edi
  8017ac:	e8 97 f6 ff ff       	call   800e48 <fd2data>
  8017b1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bb:	eb 3d                	jmp    8017fa <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017bd:	85 db                	test   %ebx,%ebx
  8017bf:	74 04                	je     8017c5 <devpipe_read+0x26>
				return i;
  8017c1:	89 d8                	mov    %ebx,%eax
  8017c3:	eb 44                	jmp    801809 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c5:	89 f2                	mov    %esi,%edx
  8017c7:	89 f8                	mov    %edi,%eax
  8017c9:	e8 f2 fe ff ff       	call   8016c0 <_pipeisclosed>
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	75 32                	jne    801804 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017d2:	e8 9b f3 ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d7:	8b 06                	mov    (%esi),%eax
  8017d9:	3b 46 04             	cmp    0x4(%esi),%eax
  8017dc:	74 df                	je     8017bd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017de:	99                   	cltd   
  8017df:	c1 ea 1b             	shr    $0x1b,%edx
  8017e2:	01 d0                	add    %edx,%eax
  8017e4:	83 e0 1f             	and    $0x1f,%eax
  8017e7:	29 d0                	sub    %edx,%eax
  8017e9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017f4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f7:	83 c3 01             	add    $0x1,%ebx
  8017fa:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017fd:	75 d8                	jne    8017d7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801802:	eb 05                	jmp    801809 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801809:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5f                   	pop    %edi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	e8 3d f6 ff ff       	call   800e5f <fd_alloc>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 c0                	test   %eax,%eax
  801829:	0f 88 2c 01 00 00    	js     80195b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182f:	83 ec 04             	sub    $0x4,%esp
  801832:	68 07 04 00 00       	push   $0x407
  801837:	ff 75 f4             	pushl  -0xc(%ebp)
  80183a:	6a 00                	push   $0x0
  80183c:	e8 50 f3 ff ff       	call   800b91 <sys_page_alloc>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	89 c2                	mov    %eax,%edx
  801846:	85 c0                	test   %eax,%eax
  801848:	0f 88 0d 01 00 00    	js     80195b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801854:	50                   	push   %eax
  801855:	e8 05 f6 ff ff       	call   800e5f <fd_alloc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	0f 88 e2 00 00 00    	js     801949 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801867:	83 ec 04             	sub    $0x4,%esp
  80186a:	68 07 04 00 00       	push   $0x407
  80186f:	ff 75 f0             	pushl  -0x10(%ebp)
  801872:	6a 00                	push   $0x0
  801874:	e8 18 f3 ff ff       	call   800b91 <sys_page_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	0f 88 c3 00 00 00    	js     801949 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	ff 75 f4             	pushl  -0xc(%ebp)
  80188c:	e8 b7 f5 ff ff       	call   800e48 <fd2data>
  801891:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801893:	83 c4 0c             	add    $0xc,%esp
  801896:	68 07 04 00 00       	push   $0x407
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	e8 ee f2 ff ff       	call   800b91 <sys_page_alloc>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	0f 88 89 00 00 00    	js     801939 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b0:	83 ec 0c             	sub    $0xc,%esp
  8018b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b6:	e8 8d f5 ff ff       	call   800e48 <fd2data>
  8018bb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018c2:	50                   	push   %eax
  8018c3:	6a 00                	push   $0x0
  8018c5:	56                   	push   %esi
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 07 f3 ff ff       	call   800bd4 <sys_page_map>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	83 c4 20             	add    $0x20,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 55                	js     80192b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018df:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018eb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 2d f5 ff ff       	call   800e38 <fd2num>
  80190b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80190e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801910:	83 c4 04             	add    $0x4,%esp
  801913:	ff 75 f0             	pushl  -0x10(%ebp)
  801916:	e8 1d f5 ff ff       	call   800e38 <fd2num>
  80191b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	eb 30                	jmp    80195b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	56                   	push   %esi
  80192f:	6a 00                	push   $0x0
  801931:	e8 e0 f2 ff ff       	call   800c16 <sys_page_unmap>
  801936:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801939:	83 ec 08             	sub    $0x8,%esp
  80193c:	ff 75 f0             	pushl  -0x10(%ebp)
  80193f:	6a 00                	push   $0x0
  801941:	e8 d0 f2 ff ff       	call   800c16 <sys_page_unmap>
  801946:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	ff 75 f4             	pushl  -0xc(%ebp)
  80194f:	6a 00                	push   $0x0
  801951:	e8 c0 f2 ff ff       	call   800c16 <sys_page_unmap>
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80195b:	89 d0                	mov    %edx,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	ff 75 08             	pushl  0x8(%ebp)
  801971:	e8 38 f5 ff ff       	call   800eae <fd_lookup>
  801976:	89 c2                	mov    %eax,%edx
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 d2                	test   %edx,%edx
  80197d:	78 18                	js     801997 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	ff 75 f4             	pushl  -0xc(%ebp)
  801985:	e8 be f4 ff ff       	call   800e48 <fd2data>
	return _pipeisclosed(fd, p);
  80198a:	89 c2                	mov    %eax,%edx
  80198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198f:	e8 2c fd ff ff       	call   8016c0 <_pipeisclosed>
  801994:	83 c4 10             	add    $0x10,%esp
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a9:	68 7c 24 80 00       	push   $0x80247c
  8019ae:	ff 75 0c             	pushl  0xc(%ebp)
  8019b1:	e8 d1 ed ff ff       	call   800787 <strcpy>
	return 0;
}
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ce:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d4:	eb 2e                	jmp    801a04 <devcons_write+0x47>
		m = n - tot;
  8019d6:	8b 55 10             	mov    0x10(%ebp),%edx
  8019d9:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  8019db:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  8019e0:	83 fa 7f             	cmp    $0x7f,%edx
  8019e3:	77 02                	ja     8019e7 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019e5:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	56                   	push   %esi
  8019eb:	03 45 0c             	add    0xc(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	57                   	push   %edi
  8019f0:	e8 24 ef ff ff       	call   800919 <memmove>
		sys_cputs(buf, m);
  8019f5:	83 c4 08             	add    $0x8,%esp
  8019f8:	56                   	push   %esi
  8019f9:	57                   	push   %edi
  8019fa:	e8 d6 f0 ff ff       	call   800ad5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ff:	01 f3                	add    %esi,%ebx
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	89 d8                	mov    %ebx,%eax
  801a06:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a09:	72 cb                	jb     8019d6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a19:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a22:	75 07                	jne    801a2b <devcons_read+0x18>
  801a24:	eb 28                	jmp    801a4e <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a26:	e8 47 f1 ff ff       	call   800b72 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a2b:	e8 c3 f0 ff ff       	call   800af3 <sys_cgetc>
  801a30:	85 c0                	test   %eax,%eax
  801a32:	74 f2                	je     801a26 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 16                	js     801a4e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a38:	83 f8 04             	cmp    $0x4,%eax
  801a3b:	74 0c                	je     801a49 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a40:	88 02                	mov    %al,(%edx)
	return 1;
  801a42:	b8 01 00 00 00       	mov    $0x1,%eax
  801a47:	eb 05                	jmp    801a4e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a5c:	6a 01                	push   $0x1
  801a5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	e8 6e f0 ff ff       	call   800ad5 <sys_cputs>
  801a67:	83 c4 10             	add    $0x10,%esp
}
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <getchar>:

int
getchar(void)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a72:	6a 01                	push   $0x1
  801a74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 98 f6 ff ff       	call   801117 <read>
	if (r < 0)
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 0f                	js     801a95 <getchar+0x29>
		return r;
	if (r < 1)
  801a86:	85 c0                	test   %eax,%eax
  801a88:	7e 06                	jle    801a90 <getchar+0x24>
		return -E_EOF;
	return c;
  801a8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a8e:	eb 05                	jmp    801a95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	ff 75 08             	pushl  0x8(%ebp)
  801aa4:	e8 05 f4 ff ff       	call   800eae <fd_lookup>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 11                	js     801ac1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab9:	39 10                	cmp    %edx,(%eax)
  801abb:	0f 94 c0             	sete   %al
  801abe:	0f b6 c0             	movzbl %al,%eax
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <opencons>:

int
opencons(void)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	e8 8d f3 ff ff       	call   800e5f <fd_alloc>
  801ad2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 3e                	js     801b19 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	68 07 04 00 00       	push   $0x407
  801ae3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 a4 f0 ff ff       	call   800b91 <sys_page_alloc>
  801aed:	83 c4 10             	add    $0x10,%esp
		return r;
  801af0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 23                	js     801b19 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	50                   	push   %eax
  801b0f:	e8 24 f3 ff ff       	call   800e38 <fd2num>
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	83 c4 10             	add    $0x10,%esp
}
  801b19:	89 d0                	mov    %edx,%eax
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	8b 75 08             	mov    0x8(%ebp),%esi
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801b2b:	85 f6                	test   %esi,%esi
  801b2d:	74 06                	je     801b35 <ipc_recv+0x18>
  801b2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801b35:	85 db                	test   %ebx,%ebx
  801b37:	74 06                	je     801b3f <ipc_recv+0x22>
  801b39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801b3f:	83 f8 01             	cmp    $0x1,%eax
  801b42:	19 d2                	sbb    %edx,%edx
  801b44:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	50                   	push   %eax
  801b4a:	e8 f2 f1 ff ff       	call   800d41 <sys_ipc_recv>
  801b4f:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	85 d2                	test   %edx,%edx
  801b56:	75 24                	jne    801b7c <ipc_recv+0x5f>
	if (from_env_store)
  801b58:	85 f6                	test   %esi,%esi
  801b5a:	74 0a                	je     801b66 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801b5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b61:	8b 40 70             	mov    0x70(%eax),%eax
  801b64:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b66:	85 db                	test   %ebx,%ebx
  801b68:	74 0a                	je     801b74 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801b6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6f:	8b 40 74             	mov    0x74(%eax),%eax
  801b72:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b74:	a1 04 40 80 00       	mov    0x804004,%eax
  801b79:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801b7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	57                   	push   %edi
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b95:	83 fb 01             	cmp    $0x1,%ebx
  801b98:	19 c0                	sbb    %eax,%eax
  801b9a:	09 c3                	or     %eax,%ebx
  801b9c:	eb 1c                	jmp    801bba <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba1:	74 12                	je     801bb5 <ipc_send+0x32>
  801ba3:	50                   	push   %eax
  801ba4:	68 88 24 80 00       	push   $0x802488
  801ba9:	6a 36                	push   $0x36
  801bab:	68 9f 24 80 00       	push   $0x80249f
  801bb0:	e8 75 e5 ff ff       	call   80012a <_panic>
		sys_yield();
  801bb5:	e8 b8 ef ff ff       	call   800b72 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801bba:	ff 75 14             	pushl  0x14(%ebp)
  801bbd:	53                   	push   %ebx
  801bbe:	56                   	push   %esi
  801bbf:	57                   	push   %edi
  801bc0:	e8 59 f1 ff ff       	call   800d1e <sys_ipc_try_send>
		if (ret == 0) break;
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	75 d2                	jne    801b9e <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5f                   	pop    %edi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bdf:	6b d0 78             	imul   $0x78,%eax,%edx
  801be2:	83 c2 50             	add    $0x50,%edx
  801be5:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801beb:	39 ca                	cmp    %ecx,%edx
  801bed:	75 0d                	jne    801bfc <ipc_find_env+0x28>
			return envs[i].env_id;
  801bef:	6b c0 78             	imul   $0x78,%eax,%eax
  801bf2:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801bf7:	8b 40 08             	mov    0x8(%eax),%eax
  801bfa:	eb 0e                	jmp    801c0a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfc:	83 c0 01             	add    $0x1,%eax
  801bff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c04:	75 d9                	jne    801bdf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c06:	66 b8 00 00          	mov    $0x0,%ax
}
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c12:	89 d0                	mov    %edx,%eax
  801c14:	c1 e8 16             	shr    $0x16,%eax
  801c17:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c23:	f6 c1 01             	test   $0x1,%cl
  801c26:	74 1d                	je     801c45 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c28:	c1 ea 0c             	shr    $0xc,%edx
  801c2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c32:	f6 c2 01             	test   $0x1,%dl
  801c35:	74 0e                	je     801c45 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c37:	c1 ea 0c             	shr    $0xc,%edx
  801c3a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c41:	ef 
  801c42:	0f b7 c0             	movzwl %ax,%eax
}
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    
  801c47:	66 90                	xchg   %ax,%ax
  801c49:	66 90                	xchg   %ax,%ax
  801c4b:	66 90                	xchg   %ax,%ax
  801c4d:	66 90                	xchg   %ax,%ax
  801c4f:	90                   	nop

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	83 ec 10             	sub    $0x10,%esp
  801c56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c66:	85 d2                	test   %edx,%edx
  801c68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c6c:	89 34 24             	mov    %esi,(%esp)
  801c6f:	89 c8                	mov    %ecx,%eax
  801c71:	75 35                	jne    801ca8 <__udivdi3+0x58>
  801c73:	39 f1                	cmp    %esi,%ecx
  801c75:	0f 87 bd 00 00 00    	ja     801d38 <__udivdi3+0xe8>
  801c7b:	85 c9                	test   %ecx,%ecx
  801c7d:	89 cd                	mov    %ecx,%ebp
  801c7f:	75 0b                	jne    801c8c <__udivdi3+0x3c>
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	31 d2                	xor    %edx,%edx
  801c88:	f7 f1                	div    %ecx
  801c8a:	89 c5                	mov    %eax,%ebp
  801c8c:	89 f0                	mov    %esi,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	f7 f5                	div    %ebp
  801c92:	89 c6                	mov    %eax,%esi
  801c94:	89 f8                	mov    %edi,%eax
  801c96:	f7 f5                	div    %ebp
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    
  801ca1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	3b 14 24             	cmp    (%esp),%edx
  801cab:	77 7b                	ja     801d28 <__udivdi3+0xd8>
  801cad:	0f bd f2             	bsr    %edx,%esi
  801cb0:	83 f6 1f             	xor    $0x1f,%esi
  801cb3:	0f 84 97 00 00 00    	je     801d50 <__udivdi3+0x100>
  801cb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cbe:	89 d7                	mov    %edx,%edi
  801cc0:	89 f1                	mov    %esi,%ecx
  801cc2:	29 f5                	sub    %esi,%ebp
  801cc4:	d3 e7                	shl    %cl,%edi
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	89 e9                	mov    %ebp,%ecx
  801cca:	d3 ea                	shr    %cl,%edx
  801ccc:	89 f1                	mov    %esi,%ecx
  801cce:	09 fa                	or     %edi,%edx
  801cd0:	8b 3c 24             	mov    (%esp),%edi
  801cd3:	d3 e0                	shl    %cl,%eax
  801cd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cd9:	89 e9                	mov    %ebp,%ecx
  801cdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ce3:	89 fa                	mov    %edi,%edx
  801ce5:	d3 ea                	shr    %cl,%edx
  801ce7:	89 f1                	mov    %esi,%ecx
  801ce9:	d3 e7                	shl    %cl,%edi
  801ceb:	89 e9                	mov    %ebp,%ecx
  801ced:	d3 e8                	shr    %cl,%eax
  801cef:	09 c7                	or     %eax,%edi
  801cf1:	89 f8                	mov    %edi,%eax
  801cf3:	f7 74 24 08          	divl   0x8(%esp)
  801cf7:	89 d5                	mov    %edx,%ebp
  801cf9:	89 c7                	mov    %eax,%edi
  801cfb:	f7 64 24 0c          	mull   0xc(%esp)
  801cff:	39 d5                	cmp    %edx,%ebp
  801d01:	89 14 24             	mov    %edx,(%esp)
  801d04:	72 11                	jb     801d17 <__udivdi3+0xc7>
  801d06:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d0a:	89 f1                	mov    %esi,%ecx
  801d0c:	d3 e2                	shl    %cl,%edx
  801d0e:	39 c2                	cmp    %eax,%edx
  801d10:	73 5e                	jae    801d70 <__udivdi3+0x120>
  801d12:	3b 2c 24             	cmp    (%esp),%ebp
  801d15:	75 59                	jne    801d70 <__udivdi3+0x120>
  801d17:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d1a:	31 f6                	xor    %esi,%esi
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	31 f6                	xor    %esi,%esi
  801d2a:	31 c0                	xor    %eax,%eax
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi
  801d38:	89 f2                	mov    %esi,%edx
  801d3a:	31 f6                	xor    %esi,%esi
  801d3c:	89 f8                	mov    %edi,%eax
  801d3e:	f7 f1                	div    %ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d54:	76 0b                	jbe    801d61 <__udivdi3+0x111>
  801d56:	31 c0                	xor    %eax,%eax
  801d58:	3b 14 24             	cmp    (%esp),%edx
  801d5b:	0f 83 37 ff ff ff    	jae    801c98 <__udivdi3+0x48>
  801d61:	b8 01 00 00 00       	mov    $0x1,%eax
  801d66:	e9 2d ff ff ff       	jmp    801c98 <__udivdi3+0x48>
  801d6b:	90                   	nop
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 f8                	mov    %edi,%eax
  801d72:	31 f6                	xor    %esi,%esi
  801d74:	e9 1f ff ff ff       	jmp    801c98 <__udivdi3+0x48>
  801d79:	66 90                	xchg   %ax,%ax
  801d7b:	66 90                	xchg   %ax,%ax
  801d7d:	66 90                	xchg   %ax,%ax
  801d7f:	90                   	nop

00801d80 <__umoddi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	83 ec 20             	sub    $0x20,%esp
  801d86:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d92:	89 c6                	mov    %eax,%esi
  801d94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801da0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801da4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801da8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801dac:	85 c0                	test   %eax,%eax
  801dae:	89 c2                	mov    %eax,%edx
  801db0:	75 1e                	jne    801dd0 <__umoddi3+0x50>
  801db2:	39 f7                	cmp    %esi,%edi
  801db4:	76 52                	jbe    801e08 <__umoddi3+0x88>
  801db6:	89 c8                	mov    %ecx,%eax
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	f7 f7                	div    %edi
  801dbc:	89 d0                	mov    %edx,%eax
  801dbe:	31 d2                	xor    %edx,%edx
  801dc0:	83 c4 20             	add    $0x20,%esp
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    
  801dc7:	89 f6                	mov    %esi,%esi
  801dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dd0:	39 f0                	cmp    %esi,%eax
  801dd2:	77 5c                	ja     801e30 <__umoddi3+0xb0>
  801dd4:	0f bd e8             	bsr    %eax,%ebp
  801dd7:	83 f5 1f             	xor    $0x1f,%ebp
  801dda:	75 64                	jne    801e40 <__umoddi3+0xc0>
  801ddc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801de0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801de4:	0f 86 f6 00 00 00    	jbe    801ee0 <__umoddi3+0x160>
  801dea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dee:	0f 82 ec 00 00 00    	jb     801ee0 <__umoddi3+0x160>
  801df4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801df8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801dfc:	83 c4 20             	add    $0x20,%esp
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
  801e03:	90                   	nop
  801e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e08:	85 ff                	test   %edi,%edi
  801e0a:	89 fd                	mov    %edi,%ebp
  801e0c:	75 0b                	jne    801e19 <__umoddi3+0x99>
  801e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f7                	div    %edi
  801e17:	89 c5                	mov    %eax,%ebp
  801e19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e1d:	31 d2                	xor    %edx,%edx
  801e1f:	f7 f5                	div    %ebp
  801e21:	89 c8                	mov    %ecx,%eax
  801e23:	f7 f5                	div    %ebp
  801e25:	eb 95                	jmp    801dbc <__umoddi3+0x3c>
  801e27:	89 f6                	mov    %esi,%esi
  801e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	83 c4 20             	add    $0x20,%esp
  801e37:	5e                   	pop    %esi
  801e38:	5f                   	pop    %edi
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    
  801e3b:	90                   	nop
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	b8 20 00 00 00       	mov    $0x20,%eax
  801e45:	89 e9                	mov    %ebp,%ecx
  801e47:	29 e8                	sub    %ebp,%eax
  801e49:	d3 e2                	shl    %cl,%edx
  801e4b:	89 c7                	mov    %eax,%edi
  801e4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 c1                	mov    %eax,%ecx
  801e5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e5f:	09 d1                	or     %edx,%ecx
  801e61:	89 fa                	mov    %edi,%edx
  801e63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e67:	89 e9                	mov    %ebp,%ecx
  801e69:	d3 e0                	shl    %cl,%eax
  801e6b:	89 f9                	mov    %edi,%ecx
  801e6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e71:	89 f0                	mov    %esi,%eax
  801e73:	d3 e8                	shr    %cl,%eax
  801e75:	89 e9                	mov    %ebp,%ecx
  801e77:	89 c7                	mov    %eax,%edi
  801e79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e7d:	d3 e6                	shl    %cl,%esi
  801e7f:	89 d1                	mov    %edx,%ecx
  801e81:	89 fa                	mov    %edi,%edx
  801e83:	d3 e8                	shr    %cl,%eax
  801e85:	89 e9                	mov    %ebp,%ecx
  801e87:	09 f0                	or     %esi,%eax
  801e89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e8d:	f7 74 24 10          	divl   0x10(%esp)
  801e91:	d3 e6                	shl    %cl,%esi
  801e93:	89 d1                	mov    %edx,%ecx
  801e95:	f7 64 24 0c          	mull   0xc(%esp)
  801e99:	39 d1                	cmp    %edx,%ecx
  801e9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e9f:	89 d7                	mov    %edx,%edi
  801ea1:	89 c6                	mov    %eax,%esi
  801ea3:	72 0a                	jb     801eaf <__umoddi3+0x12f>
  801ea5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801ea9:	73 10                	jae    801ebb <__umoddi3+0x13b>
  801eab:	39 d1                	cmp    %edx,%ecx
  801ead:	75 0c                	jne    801ebb <__umoddi3+0x13b>
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	89 c6                	mov    %eax,%esi
  801eb3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801eb7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801ebb:	89 ca                	mov    %ecx,%edx
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ec3:	29 f0                	sub    %esi,%eax
  801ec5:	19 fa                	sbb    %edi,%edx
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801ece:	89 d7                	mov    %edx,%edi
  801ed0:	d3 e7                	shl    %cl,%edi
  801ed2:	89 e9                	mov    %ebp,%ecx
  801ed4:	09 f8                	or     %edi,%eax
  801ed6:	d3 ea                	shr    %cl,%edx
  801ed8:	83 c4 20             	add    $0x20,%esp
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
  801edf:	90                   	nop
  801ee0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ee4:	29 f9                	sub    %edi,%ecx
  801ee6:	19 c6                	sbb    %eax,%esi
  801ee8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801eec:	89 74 24 18          	mov    %esi,0x18(%esp)
  801ef0:	e9 ff fe ff ff       	jmp    801df4 <__umoddi3+0x74>
