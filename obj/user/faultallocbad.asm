
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 1e 0b 00 00       	call   800b7c <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %i", (uint32_t)addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 1f 80 00       	push   $0x801f20
  80006f:	6a 0f                	push   $0xf
  800071:	68 0a 1f 80 00       	push   $0x801f0a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", (uint32_t)addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 1f 80 00       	push   $0x801f4c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 96 06 00 00       	call   80071f <snprintf>
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
  80009c:	e8 eb 0c 00 00       	call   800d8c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 10 0a 00 00       	call   800ac0 <sys_cputs>
  8000b0:	83 c4 10             	add    $0x10,%esp
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 79 0a 00 00       	call   800b3e <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 78             	imul   $0x78,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
  8000f1:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 e9 0e 00 00       	call   800fef <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 ed 09 00 00       	call   800afd <sys_env_destroy>
  800110:	83 c4 10             	add    $0x10,%esp
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 16 0a 00 00       	call   800b3e <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 78 1f 80 00       	push   $0x801f78
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 35 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 4f 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 da 08 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 d1                	mov    %edx,%ecx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80021d:	8b 45 10             	mov    0x10(%ebp),%eax
  800220:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800226:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80022d:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800230:	72 05                	jb     800237 <printnum+0x35>
  800232:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800235:	77 3e                	ja     800275 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	53                   	push   %ebx
  800241:	50                   	push   %eax
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 ea 19 00 00       	call   801c40 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 13                	jmp    80027c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f ed                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 dc 1a 00 00       	call   801d70 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
  8002a1:	83 c4 10             	add    $0x10,%esp
}
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
  80031b:	83 c4 10             	add    $0x10,%esp
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	eb 12                	jmp    800346 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800334:	85 c0                	test   %eax,%eax
  800336:	0f 84 8d 03 00 00    	je     8006c9 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	53                   	push   %ebx
  800340:	50                   	push   %eax
  800341:	ff d6                	call   *%esi
  800343:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800346:	83 c7 01             	add    $0x1,%edi
  800349:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e2                	jne    800334 <vprintfmt+0x14>
  800352:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800356:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 07                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800375:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8d 47 01             	lea    0x1(%edi),%eax
  80037c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037f:	0f b6 07             	movzbl (%edi),%eax
  800382:	0f b6 c8             	movzbl %al,%ecx
  800385:	83 e8 23             	sub    $0x23,%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 1e 03 00 00    	ja     8006ae <vprintfmt+0x38e>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a1:	eb d6                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 38                	ja     8003f8 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c3:	eb e9                	jmp    8003ae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 26                	jmp    8003fe <vprintfmt+0xde>
  8003d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003db:	89 c8                	mov    %ecx,%eax
  8003dd:	c1 f8 1f             	sar    $0x1f,%eax
  8003e0:	f7 d0                	not    %eax
  8003e2:	21 c1                	and    %eax,%ecx
  8003e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	eb 8d                	jmp    800379 <vprintfmt+0x59>
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ef:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f6:	eb 81                	jmp    800379 <vprintfmt+0x59>
  8003f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003fb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	0f 89 71 ff ff ff    	jns    800379 <vprintfmt+0x59>
				width = precision, precision = -1;
  800408:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800415:	e9 5f ff ff ff       	jmp    800379 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800420:	e9 54 ff ff ff       	jmp    800379 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	53                   	push   %ebx
  800432:	ff 30                	pushl  (%eax)
  800434:	ff d6                	call   *%esi
			break;
  800436:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043c:	e9 05 ff ff ff       	jmp    800346 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	99                   	cltd   
  80044d:	31 d0                	xor    %edx,%eax
  80044f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800451:	83 f8 0f             	cmp    $0xf,%eax
  800454:	7f 0b                	jg     800461 <vprintfmt+0x141>
  800456:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  80045d:	85 d2                	test   %edx,%edx
  80045f:	75 18                	jne    800479 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800461:	50                   	push   %eax
  800462:	68 b3 1f 80 00       	push   $0x801fb3
  800467:	53                   	push   %ebx
  800468:	56                   	push   %esi
  800469:	e8 95 fe ff ff       	call   800303 <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800474:	e9 cd fe ff ff       	jmp    800346 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800479:	52                   	push   %edx
  80047a:	68 21 24 80 00       	push   $0x802421
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 7d fe ff ff       	call   800303 <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048c:	e9 b5 fe ff ff       	jmp    800346 <vprintfmt+0x26>
  800491:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800494:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800497:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	75 05                	jne    8004ae <vprintfmt+0x18e>
				p = "(null)";
  8004a9:	bf ac 1f 80 00       	mov    $0x801fac,%edi
			if (width > 0 && padc != '-')
  8004ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b2:	0f 84 91 00 00 00    	je     800549 <vprintfmt+0x229>
  8004b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004bc:	0f 8e 95 00 00 00    	jle    800557 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	51                   	push   %ecx
  8004c6:	57                   	push   %edi
  8004c7:	e8 85 02 00 00       	call   800751 <strnlen>
  8004cc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c5>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	89 c8                	mov    %ecx,%eax
  800500:	c1 f8 1f             	sar    $0x1f,%eax
  800503:	f7 d0                	not    %eax
  800505:	21 c8                	and    %ecx,%eax
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 75 08             	mov    %esi,0x8(%ebp)
  80050c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	eb 4d                	jmp    800563 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800516:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051a:	74 1b                	je     800537 <vprintfmt+0x217>
  80051c:	0f be c0             	movsbl %al,%eax
  80051f:	83 e8 20             	sub    $0x20,%eax
  800522:	83 f8 5e             	cmp    $0x5e,%eax
  800525:	76 10                	jbe    800537 <vprintfmt+0x217>
					putch('?', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 3f                	push   $0x3f
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb 0d                	jmp    800544 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	52                   	push   %edx
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800544:	83 eb 01             	sub    $0x1,%ebx
  800547:	eb 1a                	jmp    800563 <vprintfmt+0x243>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 0c                	jmp    800563 <vprintfmt+0x243>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	83 c7 01             	add    $0x1,%edi
  800566:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056a:	0f be d0             	movsbl %al,%edx
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 23                	je     800594 <vprintfmt+0x274>
  800571:	85 f6                	test   %esi,%esi
  800573:	78 a1                	js     800516 <vprintfmt+0x1f6>
  800575:	83 ee 01             	sub    $0x1,%esi
  800578:	79 9c                	jns    800516 <vprintfmt+0x1f6>
  80057a:	89 df                	mov    %ebx,%edi
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	eb 18                	jmp    80059c <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 20                	push   $0x20
  80058a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	eb 08                	jmp    80059c <vprintfmt+0x27c>
  800594:	89 df                	mov    %ebx,%edi
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f e4                	jg     800584 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	e9 9e fd ff ff       	jmp    800346 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a8:	83 fa 01             	cmp    $0x1,%edx
  8005ab:	7e 16                	jle    8005c3 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 08             	lea    0x8(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 50 04             	mov    0x4(%eax),%edx
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c1:	eb 32                	jmp    8005f5 <vprintfmt+0x2d5>
	else if (lflag)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	74 18                	je     8005df <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dd:	eb 16                	jmp    8005f5 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800600:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800604:	79 74                	jns    80067a <vprintfmt+0x35a>
				putch('-', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 2d                	push   $0x2d
  80060c:	ff d6                	call   *%esi
				num = -(long long) num;
  80060e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800611:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800614:	f7 d8                	neg    %eax
  800616:	83 d2 00             	adc    $0x0,%edx
  800619:	f7 da                	neg    %edx
  80061b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800623:	eb 55                	jmp    80067a <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 7f fc ff ff       	call   8002ac <getuint>
			base = 10;
  80062d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800632:	eb 46                	jmp    80067a <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 70 fc ff ff       	call   8002ac <getuint>
			base = 8;
  80063c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800641:	eb 37                	jmp    80067a <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 30                	push   $0x30
  800649:	ff d6                	call   *%esi
			putch('x', putdat);
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 78                	push   $0x78
  800651:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800663:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800666:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066b:	eb 0d                	jmp    80067a <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 37 fc ff ff       	call   8002ac <getuint>
			base = 16;
  800675:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800681:	57                   	push   %edi
  800682:	ff 75 e0             	pushl  -0x20(%ebp)
  800685:	51                   	push   %ecx
  800686:	52                   	push   %edx
  800687:	50                   	push   %eax
  800688:	89 da                	mov    %ebx,%edx
  80068a:	89 f0                	mov    %esi,%eax
  80068c:	e8 71 fb ff ff       	call   800202 <printnum>
			break;
  800691:	83 c4 20             	add    $0x20,%esp
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800697:	e9 aa fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	51                   	push   %ecx
  8006a1:	ff d6                	call   *%esi
			break;
  8006a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a9:	e9 98 fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 25                	push   $0x25
  8006b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 03                	jmp    8006be <vprintfmt+0x39e>
  8006bb:	83 ef 01             	sub    $0x1,%edi
  8006be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c2:	75 f7                	jne    8006bb <vprintfmt+0x39b>
  8006c4:	e9 7d fc ff ff       	jmp    800346 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5e                   	pop    %esi
  8006ce:	5f                   	pop    %edi
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 18             	sub    $0x18,%esp
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	74 26                	je     800718 <vsnprintf+0x47>
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	7e 22                	jle    800718 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f6:	ff 75 14             	pushl  0x14(%ebp)
  8006f9:	ff 75 10             	pushl  0x10(%ebp)
  8006fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ff:	50                   	push   %eax
  800700:	68 e6 02 80 00       	push   $0x8002e6
  800705:	e8 16 fc ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800710:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 05                	jmp    80071d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800718:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 9a ff ff ff       	call   8006d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 03                	jmp    800749 <strlen+0x10>
		n++;
  800746:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800749:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074d:	75 f7                	jne    800746 <strlen+0xd>
		n++;
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800757:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	ba 00 00 00 00       	mov    $0x0,%edx
  80075f:	eb 03                	jmp    800764 <strnlen+0x13>
		n++;
  800761:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800764:	39 c2                	cmp    %eax,%edx
  800766:	74 08                	je     800770 <strnlen+0x1f>
  800768:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076c:	75 f3                	jne    800761 <strnlen+0x10>
  80076e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077c:	89 c2                	mov    %eax,%edx
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	83 c1 01             	add    $0x1,%ecx
  800784:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800788:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ef                	jne    80077e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800799:	53                   	push   %ebx
  80079a:	e8 9a ff ff ff       	call   800739 <strlen>
  80079f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	01 d8                	add    %ebx,%eax
  8007a7:	50                   	push   %eax
  8007a8:	e8 c5 ff ff ff       	call   800772 <strcpy>
	return dst;
}
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 0f                	jmp    8007d7 <strncpy+0x23>
		*dst++ = *src;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	0f b6 01             	movzbl (%ecx),%eax
  8007ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	39 da                	cmp    %ebx,%edx
  8007d9:	75 ed                	jne    8007c8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 21                	je     800816 <strlcpy+0x35>
  8007f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f9:	89 f2                	mov    %esi,%edx
  8007fb:	eb 09                	jmp    800806 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800806:	39 c2                	cmp    %eax,%edx
  800808:	74 09                	je     800813 <strlcpy+0x32>
  80080a:	0f b6 19             	movzbl (%ecx),%ebx
  80080d:	84 db                	test   %bl,%bl
  80080f:	75 ec                	jne    8007fd <strlcpy+0x1c>
  800811:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800813:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800816:	29 f0                	sub    %esi,%eax
}
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800825:	eb 06                	jmp    80082d <strcmp+0x11>
		p++, q++;
  800827:	83 c1 01             	add    $0x1,%ecx
  80082a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	84 c0                	test   %al,%al
  800832:	74 04                	je     800838 <strcmp+0x1c>
  800834:	3a 02                	cmp    (%edx),%al
  800836:	74 ef                	je     800827 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800838:	0f b6 c0             	movzbl %al,%eax
  80083b:	0f b6 12             	movzbl (%edx),%edx
  80083e:	29 d0                	sub    %edx,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 c3                	mov    %eax,%ebx
  80084e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800851:	eb 06                	jmp    800859 <strncmp+0x17>
		n--, p++, q++;
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800859:	39 d8                	cmp    %ebx,%eax
  80085b:	74 15                	je     800872 <strncmp+0x30>
  80085d:	0f b6 08             	movzbl (%eax),%ecx
  800860:	84 c9                	test   %cl,%cl
  800862:	74 04                	je     800868 <strncmp+0x26>
  800864:	3a 0a                	cmp    (%edx),%cl
  800866:	74 eb                	je     800853 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 00             	movzbl (%eax),%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
  800870:	eb 05                	jmp    800877 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	eb 07                	jmp    80088d <strchr+0x13>
		if (*s == c)
  800886:	38 ca                	cmp    %cl,%dl
  800888:	74 0f                	je     800899 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	0f b6 10             	movzbl (%eax),%edx
  800890:	84 d2                	test   %dl,%dl
  800892:	75 f2                	jne    800886 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	eb 03                	jmp    8008aa <strfind+0xf>
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	74 04                	je     8008b5 <strfind+0x1a>
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	75 f2                	jne    8008a7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	74 36                	je     8008fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cd:	75 28                	jne    8008f7 <memset+0x40>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 23                	jne    8008f7 <memset+0x40>
		c &= 0xFF;
  8008d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d8:	89 d3                	mov    %edx,%ebx
  8008da:	c1 e3 08             	shl    $0x8,%ebx
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	c1 e6 18             	shl    $0x18,%esi
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	c1 e0 10             	shl    $0x10,%eax
  8008e7:	09 f0                	or     %esi,%eax
  8008e9:	09 c2                	or     %eax,%edx
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f2:	fc                   	cld    
  8008f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f5:	eb 06                	jmp    8008fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	fc                   	cld    
  8008fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800912:	39 c6                	cmp    %eax,%esi
  800914:	73 35                	jae    80094b <memmove+0x47>
  800916:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800919:	39 d0                	cmp    %edx,%eax
  80091b:	73 2e                	jae    80094b <memmove+0x47>
		s += n;
		d += n;
  80091d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800920:	89 d6                	mov    %edx,%esi
  800922:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092a:	75 13                	jne    80093f <memmove+0x3b>
  80092c:	f6 c1 03             	test   $0x3,%cl
  80092f:	75 0e                	jne    80093f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800931:	83 ef 04             	sub    $0x4,%edi
  800934:	8d 72 fc             	lea    -0x4(%edx),%esi
  800937:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093a:	fd                   	std    
  80093b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093d:	eb 09                	jmp    800948 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093f:	83 ef 01             	sub    $0x1,%edi
  800942:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800945:	fd                   	std    
  800946:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800948:	fc                   	cld    
  800949:	eb 1d                	jmp    800968 <memmove+0x64>
  80094b:	89 f2                	mov    %esi,%edx
  80094d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	f6 c2 03             	test   $0x3,%dl
  800952:	75 0f                	jne    800963 <memmove+0x5f>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0a                	jne    800963 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800959:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095c:	89 c7                	mov    %eax,%edi
  80095e:	fc                   	cld    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 05                	jmp    800968 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096f:	ff 75 10             	pushl  0x10(%ebp)
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 87 ff ff ff       	call   800904 <memmove>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	89 c6                	mov    %eax,%esi
  80098c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098f:	eb 1a                	jmp    8009ab <memcmp+0x2c>
		if (*s1 != *s2)
  800991:	0f b6 08             	movzbl (%eax),%ecx
  800994:	0f b6 1a             	movzbl (%edx),%ebx
  800997:	38 d9                	cmp    %bl,%cl
  800999:	74 0a                	je     8009a5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099b:	0f b6 c1             	movzbl %cl,%eax
  80099e:	0f b6 db             	movzbl %bl,%ebx
  8009a1:	29 d8                	sub    %ebx,%eax
  8009a3:	eb 0f                	jmp    8009b4 <memcmp+0x35>
		s1++, s2++;
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ab:	39 f0                	cmp    %esi,%eax
  8009ad:	75 e2                	jne    800991 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c6:	eb 07                	jmp    8009cf <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	38 08                	cmp    %cl,(%eax)
  8009ca:	74 07                	je     8009d3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	39 d0                	cmp    %edx,%eax
  8009d1:	72 f5                	jb     8009c8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e1:	eb 03                	jmp    8009e6 <strtol+0x11>
		s++;
  8009e3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e6:	0f b6 01             	movzbl (%ecx),%eax
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f6                	je     8009e3 <strtol+0xe>
  8009ed:	3c 20                	cmp    $0x20,%al
  8009ef:	74 f2                	je     8009e3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f1:	3c 2b                	cmp    $0x2b,%al
  8009f3:	75 0a                	jne    8009ff <strtol+0x2a>
		s++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fd:	eb 10                	jmp    800a0f <strtol+0x3a>
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a04:	3c 2d                	cmp    $0x2d,%al
  800a06:	75 07                	jne    800a0f <strtol+0x3a>
		s++, neg = 1;
  800a08:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a0b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0f:	85 db                	test   %ebx,%ebx
  800a11:	0f 94 c0             	sete   %al
  800a14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1a:	75 19                	jne    800a35 <strtol+0x60>
  800a1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1f:	75 14                	jne    800a35 <strtol+0x60>
  800a21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a25:	0f 85 8a 00 00 00    	jne    800ab5 <strtol+0xe0>
		s += 2, base = 16;
  800a2b:	83 c1 02             	add    $0x2,%ecx
  800a2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a33:	eb 16                	jmp    800a4b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a35:	84 c0                	test   %al,%al
  800a37:	74 12                	je     800a4b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a39:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	75 08                	jne    800a4b <strtol+0x76>
		s++, base = 8;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a53:	0f b6 11             	movzbl (%ecx),%edx
  800a56:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a59:	89 f3                	mov    %esi,%ebx
  800a5b:	80 fb 09             	cmp    $0x9,%bl
  800a5e:	77 08                	ja     800a68 <strtol+0x93>
			dig = *s - '0';
  800a60:	0f be d2             	movsbl %dl,%edx
  800a63:	83 ea 30             	sub    $0x30,%edx
  800a66:	eb 22                	jmp    800a8a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6b:	89 f3                	mov    %esi,%ebx
  800a6d:	80 fb 19             	cmp    $0x19,%bl
  800a70:	77 08                	ja     800a7a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a72:	0f be d2             	movsbl %dl,%edx
  800a75:	83 ea 57             	sub    $0x57,%edx
  800a78:	eb 10                	jmp    800a8a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 19             	cmp    $0x19,%bl
  800a82:	77 16                	ja     800a9a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8d:	7d 0f                	jge    800a9e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a96:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a98:	eb b9                	jmp    800a53 <strtol+0x7e>
  800a9a:	89 c2                	mov    %eax,%edx
  800a9c:	eb 02                	jmp    800aa0 <strtol+0xcb>
  800a9e:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa4:	74 05                	je     800aab <strtol+0xd6>
		*endptr = (char *) s;
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aab:	85 ff                	test   %edi,%edi
  800aad:	74 0c                	je     800abb <strtol+0xe6>
  800aaf:	89 d0                	mov    %edx,%eax
  800ab1:	f7 d8                	neg    %eax
  800ab3:	eb 06                	jmp    800abb <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab5:	84 c0                	test   %al,%al
  800ab7:	75 8a                	jne    800a43 <strtol+0x6e>
  800ab9:	eb 90                	jmp    800a4b <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 03                	push   $0x3
  800b25:	68 df 22 80 00       	push   $0x8022df
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 fc 22 80 00       	push   $0x8022fc
  800b31:	e8 df f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
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
  800b68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b85:	be 00 00 00 00       	mov    $0x0,%esi
  800b8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	89 f7                	mov    %esi,%edi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 04                	push   $0x4
  800ba6:	68 df 22 80 00       	push   $0x8022df
  800bab:	6a 23                	push   $0x23
  800bad:	68 fc 22 80 00       	push   $0x8022fc
  800bb2:	e8 5e f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 05                	push   $0x5
  800be8:	68 df 22 80 00       	push   $0x8022df
  800bed:	6a 23                	push   $0x23
  800bef:	68 fc 22 80 00       	push   $0x8022fc
  800bf4:	e8 1c f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 06                	push   $0x6
  800c2a:	68 df 22 80 00       	push   $0x8022df
  800c2f:	6a 23                	push   $0x23
  800c31:	68 fc 22 80 00       	push   $0x8022fc
  800c36:	e8 da f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 08 00 00 00       	mov    $0x8,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 08                	push   $0x8
  800c6c:	68 df 22 80 00       	push   $0x8022df
  800c71:	6a 23                	push   $0x23
  800c73:	68 fc 22 80 00       	push   $0x8022fc
  800c78:	e8 98 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 09 00 00 00       	mov    $0x9,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 09                	push   $0x9
  800cae:	68 df 22 80 00       	push   $0x8022df
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 fc 22 80 00       	push   $0x8022fc
  800cba:	e8 56 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 0a                	push   $0xa
  800cf0:	68 df 22 80 00       	push   $0x8022df
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 fc 22 80 00       	push   $0x8022fc
  800cfc:	e8 14 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 0d                	push   $0xd
  800d54:	68 df 22 80 00       	push   $0x8022df
  800d59:	6a 23                	push   $0x23
  800d5b:	68 fc 22 80 00       	push   $0x8022fc
  800d60:	e8 b0 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_gettime>:

int sys_gettime(void)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	ba 00 00 00 00       	mov    $0x0,%edx
  800d78:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7d:	89 d1                	mov    %edx,%ecx
  800d7f:	89 d3                	mov    %edx,%ebx
  800d81:	89 d7                	mov    %edx,%edi
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800d92:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d99:	75 2c                	jne    800dc7 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	6a 07                	push   $0x7
  800da0:	68 00 f0 7f ee       	push   $0xee7ff000
  800da5:	6a 00                	push   $0x0
  800da7:	e8 d0 fd ff ff       	call   800b7c <sys_page_alloc>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	79 14                	jns    800dc7 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 0c 23 80 00       	push   $0x80230c
  800dbb:	6a 1f                	push   $0x1f
  800dbd:	68 6e 23 80 00       	push   $0x80236e
  800dc2:	e8 4e f3 ff ff       	call   800115 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	a3 08 40 80 00       	mov    %eax,0x804008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	68 fb 0d 80 00       	push   $0x800dfb
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 e9 fe ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	79 14                	jns    800df9 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 38 23 80 00       	push   $0x802338
  800ded:	6a 25                	push   $0x25
  800def:	68 6e 23 80 00       	push   $0x80236e
  800df4:	e8 1c f3 ff ff       	call   800115 <_panic>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dfb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dfc:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e01:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e03:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  800e06:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  800e08:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  800e0c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  800e10:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  800e11:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  800e14:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  800e16:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  800e19:	83 c4 04             	add    $0x4,%esp
	popal 
  800e1c:	61                   	popa   
	addl $4, %esp 
  800e1d:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  800e20:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  800e21:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  800e22:	c3                   	ret    

00800e23 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e43:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e55:	89 c2                	mov    %eax,%edx
  800e57:	c1 ea 16             	shr    $0x16,%edx
  800e5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e61:	f6 c2 01             	test   $0x1,%dl
  800e64:	74 11                	je     800e77 <fd_alloc+0x2d>
  800e66:	89 c2                	mov    %eax,%edx
  800e68:	c1 ea 0c             	shr    $0xc,%edx
  800e6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e72:	f6 c2 01             	test   $0x1,%dl
  800e75:	75 09                	jne    800e80 <fd_alloc+0x36>
			*fd_store = fd;
  800e77:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	eb 17                	jmp    800e97 <fd_alloc+0x4d>
  800e80:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e85:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8a:	75 c9                	jne    800e55 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e92:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9f:	83 f8 1f             	cmp    $0x1f,%eax
  800ea2:	77 36                	ja     800eda <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea4:	c1 e0 0c             	shl    $0xc,%eax
  800ea7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	c1 ea 16             	shr    $0x16,%edx
  800eb1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb8:	f6 c2 01             	test   $0x1,%dl
  800ebb:	74 24                	je     800ee1 <fd_lookup+0x48>
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 0c             	shr    $0xc,%edx
  800ec2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 1a                	je     800ee8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed1:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	eb 13                	jmp    800eed <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edf:	eb 0c                	jmp    800eed <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee6:	eb 05                	jmp    800eed <fd_lookup+0x54>
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef8:	ba f8 23 80 00       	mov    $0x8023f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efd:	eb 13                	jmp    800f12 <dev_lookup+0x23>
  800eff:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f02:	39 08                	cmp    %ecx,(%eax)
  800f04:	75 0c                	jne    800f12 <dev_lookup+0x23>
			*dev = devtab[i];
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f10:	eb 2e                	jmp    800f40 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f12:	8b 02                	mov    (%edx),%eax
  800f14:	85 c0                	test   %eax,%eax
  800f16:	75 e7                	jne    800eff <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f18:	a1 04 40 80 00       	mov    0x804004,%eax
  800f1d:	8b 40 48             	mov    0x48(%eax),%eax
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	51                   	push   %ecx
  800f24:	50                   	push   %eax
  800f25:	68 7c 23 80 00       	push   $0x80237c
  800f2a:	e8 bf f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 10             	sub    $0x10,%esp
  800f4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f53:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f54:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5a:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5d:	50                   	push   %eax
  800f5e:	e8 36 ff ff ff       	call   800e99 <fd_lookup>
  800f63:	83 c4 08             	add    $0x8,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 05                	js     800f6f <fd_close+0x2d>
	    || fd != fd2)
  800f6a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6d:	74 0b                	je     800f7a <fd_close+0x38>
		return (must_exist ? r : 0);
  800f6f:	80 fb 01             	cmp    $0x1,%bl
  800f72:	19 d2                	sbb    %edx,%edx
  800f74:	f7 d2                	not    %edx
  800f76:	21 d0                	and    %edx,%eax
  800f78:	eb 41                	jmp    800fbb <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 36                	pushl  (%esi)
  800f83:	e8 67 ff ff ff       	call   800eef <dev_lookup>
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 1a                	js     800fab <fd_close+0x69>
		if (dev->dev_close)
  800f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f94:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f97:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 0b                	je     800fab <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	56                   	push   %esi
  800fa4:	ff d0                	call   *%eax
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 4b fc ff ff       	call   800c01 <sys_page_unmap>
	return r;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	89 d8                	mov    %ebx,%eax
}
  800fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 75 08             	pushl  0x8(%ebp)
  800fcf:	e8 c5 fe ff ff       	call   800e99 <fd_lookup>
  800fd4:	89 c2                	mov    %eax,%edx
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	85 d2                	test   %edx,%edx
  800fdb:	78 10                	js     800fed <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fdd:	83 ec 08             	sub    $0x8,%esp
  800fe0:	6a 01                	push   $0x1
  800fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe5:	e8 58 ff ff ff       	call   800f42 <fd_close>
  800fea:	83 c4 10             	add    $0x10,%esp
}
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <close_all>:

void
close_all(void)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	53                   	push   %ebx
  800fff:	e8 be ff ff ff       	call   800fc2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801004:	83 c3 01             	add    $0x1,%ebx
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	83 fb 20             	cmp    $0x20,%ebx
  80100d:	75 ec                	jne    800ffb <close_all+0xc>
		close(i);
}
  80100f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 2c             	sub    $0x2c,%esp
  80101d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	ff 75 08             	pushl  0x8(%ebp)
  801027:	e8 6d fe ff ff       	call   800e99 <fd_lookup>
  80102c:	89 c2                	mov    %eax,%edx
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	85 d2                	test   %edx,%edx
  801033:	0f 88 c1 00 00 00    	js     8010fa <dup+0xe6>
		return r;
	close(newfdnum);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	56                   	push   %esi
  80103d:	e8 80 ff ff ff       	call   800fc2 <close>

	newfd = INDEX2FD(newfdnum);
  801042:	89 f3                	mov    %esi,%ebx
  801044:	c1 e3 0c             	shl    $0xc,%ebx
  801047:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80104d:	83 c4 04             	add    $0x4,%esp
  801050:	ff 75 e4             	pushl  -0x1c(%ebp)
  801053:	e8 db fd ff ff       	call   800e33 <fd2data>
  801058:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80105a:	89 1c 24             	mov    %ebx,(%esp)
  80105d:	e8 d1 fd ff ff       	call   800e33 <fd2data>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801068:	89 f8                	mov    %edi,%eax
  80106a:	c1 e8 16             	shr    $0x16,%eax
  80106d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801074:	a8 01                	test   $0x1,%al
  801076:	74 37                	je     8010af <dup+0x9b>
  801078:	89 f8                	mov    %edi,%eax
  80107a:	c1 e8 0c             	shr    $0xc,%eax
  80107d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801084:	f6 c2 01             	test   $0x1,%dl
  801087:	74 26                	je     8010af <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	50                   	push   %eax
  801099:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109c:	6a 00                	push   $0x0
  80109e:	57                   	push   %edi
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 19 fb ff ff       	call   800bbf <sys_page_map>
  8010a6:	89 c7                	mov    %eax,%edi
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 2e                	js     8010dd <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	c1 e8 0c             	shr    $0xc,%eax
  8010b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c6:	50                   	push   %eax
  8010c7:	53                   	push   %ebx
  8010c8:	6a 00                	push   $0x0
  8010ca:	52                   	push   %edx
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 ed fa ff ff       	call   800bbf <sys_page_map>
  8010d2:	89 c7                	mov    %eax,%edi
  8010d4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d9:	85 ff                	test   %edi,%edi
  8010db:	79 1d                	jns    8010fa <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	53                   	push   %ebx
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 19 fb ff ff       	call   800c01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e8:	83 c4 08             	add    $0x8,%esp
  8010eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 0c fb ff ff       	call   800c01 <sys_page_unmap>
	return r;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	89 f8                	mov    %edi,%eax
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	53                   	push   %ebx
  801106:	83 ec 14             	sub    $0x14,%esp
  801109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	53                   	push   %ebx
  801111:	e8 83 fd ff ff       	call   800e99 <fd_lookup>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	89 c2                	mov    %eax,%edx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 6d                	js     80118c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801129:	ff 30                	pushl  (%eax)
  80112b:	e8 bf fd ff ff       	call   800eef <dev_lookup>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 4c                	js     801183 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801137:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80113a:	8b 42 08             	mov    0x8(%edx),%eax
  80113d:	83 e0 03             	and    $0x3,%eax
  801140:	83 f8 01             	cmp    $0x1,%eax
  801143:	75 21                	jne    801166 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801145:	a1 04 40 80 00       	mov    0x804004,%eax
  80114a:	8b 40 48             	mov    0x48(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	53                   	push   %ebx
  801151:	50                   	push   %eax
  801152:	68 bd 23 80 00       	push   $0x8023bd
  801157:	e8 92 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801164:	eb 26                	jmp    80118c <read+0x8a>
	}
	if (!dev->dev_read)
  801166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801169:	8b 40 08             	mov    0x8(%eax),%eax
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 17                	je     801187 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	ff 75 10             	pushl  0x10(%ebp)
  801176:	ff 75 0c             	pushl  0xc(%ebp)
  801179:	52                   	push   %edx
  80117a:	ff d0                	call   *%eax
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	eb 09                	jmp    80118c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	89 c2                	mov    %eax,%edx
  801185:	eb 05                	jmp    80118c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801187:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80118c:	89 d0                	mov    %edx,%eax
  80118e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a7:	eb 21                	jmp    8011ca <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	89 f0                	mov    %esi,%eax
  8011ae:	29 d8                	sub    %ebx,%eax
  8011b0:	50                   	push   %eax
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	03 45 0c             	add    0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	57                   	push   %edi
  8011b8:	e8 45 ff ff ff       	call   801102 <read>
		if (m < 0)
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 0c                	js     8011d0 <readn+0x3d>
			return m;
		if (m == 0)
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 06                	je     8011ce <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c8:	01 c3                	add    %eax,%ebx
  8011ca:	39 f3                	cmp    %esi,%ebx
  8011cc:	72 db                	jb     8011a9 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011ce:	89 d8                	mov    %ebx,%eax
}
  8011d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 14             	sub    $0x14,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	53                   	push   %ebx
  8011e7:	e8 ad fc ff ff       	call   800e99 <fd_lookup>
  8011ec:	83 c4 08             	add    $0x8,%esp
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 68                	js     80125d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	ff 30                	pushl  (%eax)
  801201:	e8 e9 fc ff ff       	call   800eef <dev_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 47                	js     801254 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801210:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801214:	75 21                	jne    801237 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801216:	a1 04 40 80 00       	mov    0x804004,%eax
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	53                   	push   %ebx
  801222:	50                   	push   %eax
  801223:	68 d9 23 80 00       	push   $0x8023d9
  801228:	e8 c1 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801235:	eb 26                	jmp    80125d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 0c             	mov    0xc(%edx),%edx
  80123d:	85 d2                	test   %edx,%edx
  80123f:	74 17                	je     801258 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	ff 75 10             	pushl  0x10(%ebp)
  801247:	ff 75 0c             	pushl  0xc(%ebp)
  80124a:	50                   	push   %eax
  80124b:	ff d2                	call   *%edx
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	eb 09                	jmp    80125d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801254:	89 c2                	mov    %eax,%edx
  801256:	eb 05                	jmp    80125d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801258:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80125d:	89 d0                	mov    %edx,%eax
  80125f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <seek>:

int
seek(int fdnum, off_t offset)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 75 08             	pushl  0x8(%ebp)
  801271:	e8 23 fc ff ff       	call   800e99 <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 0e                	js     80128b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80127d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801280:	8b 55 0c             	mov    0xc(%ebp),%edx
  801283:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	53                   	push   %ebx
  801291:	83 ec 14             	sub    $0x14,%esp
  801294:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	53                   	push   %ebx
  80129c:	e8 f8 fb ff ff       	call   800e99 <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 65                	js     80130f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	ff 30                	pushl  (%eax)
  8012b6:	e8 34 fc ff ff       	call   800eef <dev_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 44                	js     801306 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c9:	75 21                	jne    8012ec <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012cb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d0:	8b 40 48             	mov    0x48(%eax),%eax
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	53                   	push   %ebx
  8012d7:	50                   	push   %eax
  8012d8:	68 9c 23 80 00       	push   $0x80239c
  8012dd:	e8 0c ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ea:	eb 23                	jmp    80130f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ef:	8b 52 18             	mov    0x18(%edx),%edx
  8012f2:	85 d2                	test   %edx,%edx
  8012f4:	74 14                	je     80130a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	50                   	push   %eax
  8012fd:	ff d2                	call   *%edx
  8012ff:	89 c2                	mov    %eax,%edx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	eb 09                	jmp    80130f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	89 c2                	mov    %eax,%edx
  801308:	eb 05                	jmp    80130f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80130f:	89 d0                	mov    %edx,%eax
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 6d fb ff ff       	call   800e99 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	89 c2                	mov    %eax,%edx
  801331:	85 c0                	test   %eax,%eax
  801333:	78 58                	js     80138d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133f:	ff 30                	pushl  (%eax)
  801341:	e8 a9 fb ff ff       	call   800eef <dev_lookup>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 37                	js     801384 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801354:	74 32                	je     801388 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801356:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801359:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801360:	00 00 00 
	stat->st_isdir = 0;
  801363:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136a:	00 00 00 
	stat->st_dev = dev;
  80136d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	53                   	push   %ebx
  801377:	ff 75 f0             	pushl  -0x10(%ebp)
  80137a:	ff 50 14             	call   *0x14(%eax)
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 09                	jmp    80138d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801384:	89 c2                	mov    %eax,%edx
  801386:	eb 05                	jmp    80138d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801388:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80138d:	89 d0                	mov    %edx,%eax
  80138f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	6a 00                	push   $0x0
  80139e:	ff 75 08             	pushl  0x8(%ebp)
  8013a1:	e8 e7 01 00 00       	call   80158d <open>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 db                	test   %ebx,%ebx
  8013ad:	78 1b                	js     8013ca <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	ff 75 0c             	pushl  0xc(%ebp)
  8013b5:	53                   	push   %ebx
  8013b6:	e8 5b ff ff ff       	call   801316 <fstat>
  8013bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013bd:	89 1c 24             	mov    %ebx,(%esp)
  8013c0:	e8 fd fb ff ff       	call   800fc2 <close>
	return r;
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	89 f0                	mov    %esi,%eax
}
  8013ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	89 c6                	mov    %eax,%esi
  8013d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e1:	75 12                	jne    8013f5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	6a 03                	push   $0x3
  8013e8:	e8 d2 07 00 00       	call   801bbf <ipc_find_env>
  8013ed:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f5:	6a 07                	push   $0x7
  8013f7:	68 00 50 80 00       	push   $0x805000
  8013fc:	56                   	push   %esi
  8013fd:	ff 35 00 40 80 00    	pushl  0x804000
  801403:	e8 66 07 00 00       	call   801b6e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801408:	83 c4 0c             	add    $0xc,%esp
  80140b:	6a 00                	push   $0x0
  80140d:	53                   	push   %ebx
  80140e:	6a 00                	push   $0x0
  801410:	e8 f3 06 00 00       	call   801b08 <ipc_recv>
}
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801435:	ba 00 00 00 00       	mov    $0x0,%edx
  80143a:	b8 02 00 00 00       	mov    $0x2,%eax
  80143f:	e8 8d ff ff ff       	call   8013d1 <fsipc>
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 06 00 00 00       	mov    $0x6,%eax
  801461:	e8 6b ff ff ff       	call   8013d1 <fsipc>
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801472:	8b 45 08             	mov    0x8(%ebp),%eax
  801475:	8b 40 0c             	mov    0xc(%eax),%eax
  801478:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147d:	ba 00 00 00 00       	mov    $0x0,%edx
  801482:	b8 05 00 00 00       	mov    $0x5,%eax
  801487:	e8 45 ff ff ff       	call   8013d1 <fsipc>
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	85 d2                	test   %edx,%edx
  801490:	78 2c                	js     8014be <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	68 00 50 80 00       	push   $0x805000
  80149a:	53                   	push   %ebx
  80149b:	e8 d2 f2 ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8014cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d2:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8014d8:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8014dd:	76 05                	jbe    8014e4 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8014df:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8014e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	68 08 50 80 00       	push   $0x805008
  8014f5:	e8 0a f4 ff ff       	call   800904 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801504:	e8 c8 fe ff ff       	call   8013d1 <fsipc>
	return write;
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 03 00 00 00       	mov    $0x3,%eax
  80152e:	e8 9e fe ff ff       	call   8013d1 <fsipc>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 4b                	js     801584 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801539:	39 c6                	cmp    %eax,%esi
  80153b:	73 16                	jae    801553 <devfile_read+0x48>
  80153d:	68 08 24 80 00       	push   $0x802408
  801542:	68 0f 24 80 00       	push   $0x80240f
  801547:	6a 7c                	push   $0x7c
  801549:	68 24 24 80 00       	push   $0x802424
  80154e:	e8 c2 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801558:	7e 16                	jle    801570 <devfile_read+0x65>
  80155a:	68 2f 24 80 00       	push   $0x80242f
  80155f:	68 0f 24 80 00       	push   $0x80240f
  801564:	6a 7d                	push   $0x7d
  801566:	68 24 24 80 00       	push   $0x802424
  80156b:	e8 a5 eb ff ff       	call   800115 <_panic>
	memmove(buf, &fsipcbuf, r);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	50                   	push   %eax
  801574:	68 00 50 80 00       	push   $0x805000
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	e8 83 f3 ff ff       	call   800904 <memmove>
	return r;
  801581:	83 c4 10             	add    $0x10,%esp
}
  801584:	89 d8                	mov    %ebx,%eax
  801586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	53                   	push   %ebx
  801591:	83 ec 20             	sub    $0x20,%esp
  801594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801597:	53                   	push   %ebx
  801598:	e8 9c f1 ff ff       	call   800739 <strlen>
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a5:	7f 67                	jg     80160e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	e8 97 f8 ff ff       	call   800e4a <fd_alloc>
  8015b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 57                	js     801613 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	68 00 50 80 00       	push   $0x805000
  8015c5:	e8 a8 f1 ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015da:	e8 f2 fd ff ff       	call   8013d1 <fsipc>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	79 14                	jns    8015fc <open+0x6f>
		fd_close(fd, 0);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 00                	push   $0x0
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 4d f9 ff ff       	call   800f42 <fd_close>
		return r;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	89 da                	mov    %ebx,%edx
  8015fa:	eb 17                	jmp    801613 <open+0x86>
	}

	return fd2num(fd);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801602:	e8 1c f8 ff ff       	call   800e23 <fd2num>
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 05                	jmp    801613 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801613:	89 d0                	mov    %edx,%eax
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	b8 08 00 00 00       	mov    $0x8,%eax
  80162a:	e8 a2 fd ff ff       	call   8013d1 <fsipc>
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 ef f7 ff ff       	call   800e33 <fd2data>
  801644:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801646:	83 c4 08             	add    $0x8,%esp
  801649:	68 3b 24 80 00       	push   $0x80243b
  80164e:	53                   	push   %ebx
  80164f:	e8 1e f1 ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801654:	8b 56 04             	mov    0x4(%esi),%edx
  801657:	89 d0                	mov    %edx,%eax
  801659:	2b 06                	sub    (%esi),%eax
  80165b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801661:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801668:	00 00 00 
	stat->st_dev = &devpipe;
  80166b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801672:	30 80 00 
	return 0;
}
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168b:	53                   	push   %ebx
  80168c:	6a 00                	push   $0x0
  80168e:	e8 6e f5 ff ff       	call   800c01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	e8 98 f7 ff ff       	call   800e33 <fd2data>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	50                   	push   %eax
  80169f:	6a 00                	push   $0x0
  8016a1:	e8 5b f5 ff ff       	call   800c01 <sys_page_unmap>
}
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 1c             	sub    $0x1c,%esp
  8016b4:	89 c7                	mov    %eax,%edi
  8016b6:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	57                   	push   %edi
  8016c4:	e8 2e 05 00 00       	call   801bf7 <pageref>
  8016c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016cc:	89 34 24             	mov    %esi,(%esp)
  8016cf:	e8 23 05 00 00       	call   801bf7 <pageref>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016da:	0f 94 c0             	sete   %al
  8016dd:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016e0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016e6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016e9:	39 cb                	cmp    %ecx,%ebx
  8016eb:	74 15                	je     801702 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8016ed:	8b 52 58             	mov    0x58(%edx),%edx
  8016f0:	50                   	push   %eax
  8016f1:	52                   	push   %edx
  8016f2:	53                   	push   %ebx
  8016f3:	68 48 24 80 00       	push   $0x802448
  8016f8:	e8 f1 ea ff ff       	call   8001ee <cprintf>
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb b6                	jmp    8016b8 <_pipeisclosed+0xd>
	}
}
  801702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	5f                   	pop    %edi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	57                   	push   %edi
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	83 ec 28             	sub    $0x28,%esp
  801713:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801716:	56                   	push   %esi
  801717:	e8 17 f7 ff ff       	call   800e33 <fd2data>
  80171c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	bf 00 00 00 00       	mov    $0x0,%edi
  801726:	eb 4b                	jmp    801773 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801728:	89 da                	mov    %ebx,%edx
  80172a:	89 f0                	mov    %esi,%eax
  80172c:	e8 7a ff ff ff       	call   8016ab <_pipeisclosed>
  801731:	85 c0                	test   %eax,%eax
  801733:	75 48                	jne    80177d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801735:	e8 23 f4 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80173a:	8b 43 04             	mov    0x4(%ebx),%eax
  80173d:	8b 0b                	mov    (%ebx),%ecx
  80173f:	8d 51 20             	lea    0x20(%ecx),%edx
  801742:	39 d0                	cmp    %edx,%eax
  801744:	73 e2                	jae    801728 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80174d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801750:	89 c2                	mov    %eax,%edx
  801752:	c1 fa 1f             	sar    $0x1f,%edx
  801755:	89 d1                	mov    %edx,%ecx
  801757:	c1 e9 1b             	shr    $0x1b,%ecx
  80175a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80175d:	83 e2 1f             	and    $0x1f,%edx
  801760:	29 ca                	sub    %ecx,%edx
  801762:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801766:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80176a:	83 c0 01             	add    $0x1,%eax
  80176d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801770:	83 c7 01             	add    $0x1,%edi
  801773:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801776:	75 c2                	jne    80173a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801778:	8b 45 10             	mov    0x10(%ebp),%eax
  80177b:	eb 05                	jmp    801782 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801782:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 18             	sub    $0x18,%esp
  801793:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801796:	57                   	push   %edi
  801797:	e8 97 f6 ff ff       	call   800e33 <fd2data>
  80179c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a6:	eb 3d                	jmp    8017e5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017a8:	85 db                	test   %ebx,%ebx
  8017aa:	74 04                	je     8017b0 <devpipe_read+0x26>
				return i;
  8017ac:	89 d8                	mov    %ebx,%eax
  8017ae:	eb 44                	jmp    8017f4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017b0:	89 f2                	mov    %esi,%edx
  8017b2:	89 f8                	mov    %edi,%eax
  8017b4:	e8 f2 fe ff ff       	call   8016ab <_pipeisclosed>
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	75 32                	jne    8017ef <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017bd:	e8 9b f3 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017c2:	8b 06                	mov    (%esi),%eax
  8017c4:	3b 46 04             	cmp    0x4(%esi),%eax
  8017c7:	74 df                	je     8017a8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017c9:	99                   	cltd   
  8017ca:	c1 ea 1b             	shr    $0x1b,%edx
  8017cd:	01 d0                	add    %edx,%eax
  8017cf:	83 e0 1f             	and    $0x1f,%eax
  8017d2:	29 d0                	sub    %edx,%eax
  8017d4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017dc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017df:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e2:	83 c3 01             	add    $0x1,%ebx
  8017e5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017e8:	75 d8                	jne    8017c2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ed:	eb 05                	jmp    8017f4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5f                   	pop    %edi
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	e8 3d f6 ff ff       	call   800e4a <fd_alloc>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	89 c2                	mov    %eax,%edx
  801812:	85 c0                	test   %eax,%eax
  801814:	0f 88 2c 01 00 00    	js     801946 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	68 07 04 00 00       	push   $0x407
  801822:	ff 75 f4             	pushl  -0xc(%ebp)
  801825:	6a 00                	push   $0x0
  801827:	e8 50 f3 ff ff       	call   800b7c <sys_page_alloc>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	89 c2                	mov    %eax,%edx
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 0d 01 00 00    	js     801946 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	e8 05 f6 ff ff       	call   800e4a <fd_alloc>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	0f 88 e2 00 00 00    	js     801934 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	68 07 04 00 00       	push   $0x407
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	6a 00                	push   $0x0
  80185f:	e8 18 f3 ff ff       	call   800b7c <sys_page_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 c3 00 00 00    	js     801934 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	e8 b7 f5 ff ff       	call   800e33 <fd2data>
  80187c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187e:	83 c4 0c             	add    $0xc,%esp
  801881:	68 07 04 00 00       	push   $0x407
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	e8 ee f2 ff ff       	call   800b7c <sys_page_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 89 00 00 00    	js     801924 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a1:	e8 8d f5 ff ff       	call   800e33 <fd2data>
  8018a6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ad:	50                   	push   %eax
  8018ae:	6a 00                	push   $0x0
  8018b0:	56                   	push   %esi
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 07 f3 ff ff       	call   800bbf <sys_page_map>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	83 c4 20             	add    $0x20,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 55                	js     801916 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018c1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018d6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018df:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f1:	e8 2d f5 ff ff       	call   800e23 <fd2num>
  8018f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018fb:	83 c4 04             	add    $0x4,%esp
  8018fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801901:	e8 1d f5 ff ff       	call   800e23 <fd2num>
  801906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801909:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	eb 30                	jmp    801946 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	56                   	push   %esi
  80191a:	6a 00                	push   $0x0
  80191c:	e8 e0 f2 ff ff       	call   800c01 <sys_page_unmap>
  801921:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	ff 75 f0             	pushl  -0x10(%ebp)
  80192a:	6a 00                	push   $0x0
  80192c:	e8 d0 f2 ff ff       	call   800c01 <sys_page_unmap>
  801931:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 f4             	pushl  -0xc(%ebp)
  80193a:	6a 00                	push   $0x0
  80193c:	e8 c0 f2 ff ff       	call   800c01 <sys_page_unmap>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801946:	89 d0                	mov    %edx,%eax
  801948:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194b:	5b                   	pop    %ebx
  80194c:	5e                   	pop    %esi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    

0080194f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	ff 75 08             	pushl  0x8(%ebp)
  80195c:	e8 38 f5 ff ff       	call   800e99 <fd_lookup>
  801961:	89 c2                	mov    %eax,%edx
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 d2                	test   %edx,%edx
  801968:	78 18                	js     801982 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	ff 75 f4             	pushl  -0xc(%ebp)
  801970:	e8 be f4 ff ff       	call   800e33 <fd2data>
	return _pipeisclosed(fd, p);
  801975:	89 c2                	mov    %eax,%edx
  801977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197a:	e8 2c fd ff ff       	call   8016ab <_pipeisclosed>
  80197f:	83 c4 10             	add    $0x10,%esp
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801994:	68 7c 24 80 00       	push   $0x80247c
  801999:	ff 75 0c             	pushl  0xc(%ebp)
  80199c:	e8 d1 ed ff ff       	call   800772 <strcpy>
	return 0;
}
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	57                   	push   %edi
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019b9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bf:	eb 2e                	jmp    8019ef <devcons_write+0x47>
		m = n - tot;
  8019c1:	8b 55 10             	mov    0x10(%ebp),%edx
  8019c4:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  8019c6:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  8019cb:	83 fa 7f             	cmp    $0x7f,%edx
  8019ce:	77 02                	ja     8019d2 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d0:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d2:	83 ec 04             	sub    $0x4,%esp
  8019d5:	56                   	push   %esi
  8019d6:	03 45 0c             	add    0xc(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	57                   	push   %edi
  8019db:	e8 24 ef ff ff       	call   800904 <memmove>
		sys_cputs(buf, m);
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	56                   	push   %esi
  8019e4:	57                   	push   %edi
  8019e5:	e8 d6 f0 ff ff       	call   800ac0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ea:	01 f3                	add    %esi,%ebx
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f4:	72 cb                	jb     8019c1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5f                   	pop    %edi
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a04:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a0d:	75 07                	jne    801a16 <devcons_read+0x18>
  801a0f:	eb 28                	jmp    801a39 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a11:	e8 47 f1 ff ff       	call   800b5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a16:	e8 c3 f0 ff ff       	call   800ade <sys_cgetc>
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	74 f2                	je     801a11 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 16                	js     801a39 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a23:	83 f8 04             	cmp    $0x4,%eax
  801a26:	74 0c                	je     801a34 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a2b:	88 02                	mov    %al,(%edx)
	return 1;
  801a2d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a32:	eb 05                	jmp    801a39 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a47:	6a 01                	push   $0x1
  801a49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4c:	50                   	push   %eax
  801a4d:	e8 6e f0 ff ff       	call   800ac0 <sys_cputs>
  801a52:	83 c4 10             	add    $0x10,%esp
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <getchar>:

int
getchar(void)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a5d:	6a 01                	push   $0x1
  801a5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a62:	50                   	push   %eax
  801a63:	6a 00                	push   $0x0
  801a65:	e8 98 f6 ff ff       	call   801102 <read>
	if (r < 0)
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 0f                	js     801a80 <getchar+0x29>
		return r;
	if (r < 1)
  801a71:	85 c0                	test   %eax,%eax
  801a73:	7e 06                	jle    801a7b <getchar+0x24>
		return -E_EOF;
	return c;
  801a75:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a79:	eb 05                	jmp    801a80 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a7b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	ff 75 08             	pushl  0x8(%ebp)
  801a8f:	e8 05 f4 ff ff       	call   800e99 <fd_lookup>
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	85 c0                	test   %eax,%eax
  801a99:	78 11                	js     801aac <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa4:	39 10                	cmp    %edx,(%eax)
  801aa6:	0f 94 c0             	sete   %al
  801aa9:	0f b6 c0             	movzbl %al,%eax
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <opencons>:

int
opencons(void)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	e8 8d f3 ff ff       	call   800e4a <fd_alloc>
  801abd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 3e                	js     801b04 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	68 07 04 00 00       	push   $0x407
  801ace:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad1:	6a 00                	push   $0x0
  801ad3:	e8 a4 f0 ff ff       	call   800b7c <sys_page_alloc>
  801ad8:	83 c4 10             	add    $0x10,%esp
		return r;
  801adb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 23                	js     801b04 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	50                   	push   %eax
  801afa:	e8 24 f3 ff ff       	call   800e23 <fd2num>
  801aff:	89 c2                	mov    %eax,%edx
  801b01:	83 c4 10             	add    $0x10,%esp
}
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801b16:	85 f6                	test   %esi,%esi
  801b18:	74 06                	je     801b20 <ipc_recv+0x18>
  801b1a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	74 06                	je     801b2a <ipc_recv+0x22>
  801b24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801b2a:	83 f8 01             	cmp    $0x1,%eax
  801b2d:	19 d2                	sbb    %edx,%edx
  801b2f:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	50                   	push   %eax
  801b35:	e8 f2 f1 ff ff       	call   800d2c <sys_ipc_recv>
  801b3a:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	85 d2                	test   %edx,%edx
  801b41:	75 24                	jne    801b67 <ipc_recv+0x5f>
	if (from_env_store)
  801b43:	85 f6                	test   %esi,%esi
  801b45:	74 0a                	je     801b51 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801b47:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4c:	8b 40 70             	mov    0x70(%eax),%eax
  801b4f:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b51:	85 db                	test   %ebx,%ebx
  801b53:	74 0a                	je     801b5f <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801b55:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5a:	8b 40 74             	mov    0x74(%eax),%eax
  801b5d:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801b67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b80:	83 fb 01             	cmp    $0x1,%ebx
  801b83:	19 c0                	sbb    %eax,%eax
  801b85:	09 c3                	or     %eax,%ebx
  801b87:	eb 1c                	jmp    801ba5 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b8c:	74 12                	je     801ba0 <ipc_send+0x32>
  801b8e:	50                   	push   %eax
  801b8f:	68 88 24 80 00       	push   $0x802488
  801b94:	6a 36                	push   $0x36
  801b96:	68 9f 24 80 00       	push   $0x80249f
  801b9b:	e8 75 e5 ff ff       	call   800115 <_panic>
		sys_yield();
  801ba0:	e8 b8 ef ff ff       	call   800b5d <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ba5:	ff 75 14             	pushl  0x14(%ebp)
  801ba8:	53                   	push   %ebx
  801ba9:	56                   	push   %esi
  801baa:	57                   	push   %edi
  801bab:	e8 59 f1 ff ff       	call   800d09 <sys_ipc_try_send>
		if (ret == 0) break;
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 d2                	jne    801b89 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bca:	6b d0 78             	imul   $0x78,%eax,%edx
  801bcd:	83 c2 50             	add    $0x50,%edx
  801bd0:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801bd6:	39 ca                	cmp    %ecx,%edx
  801bd8:	75 0d                	jne    801be7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bda:	6b c0 78             	imul   $0x78,%eax,%eax
  801bdd:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801be2:	8b 40 08             	mov    0x8(%eax),%eax
  801be5:	eb 0e                	jmp    801bf5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be7:	83 c0 01             	add    $0x1,%eax
  801bea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bef:	75 d9                	jne    801bca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bf1:	66 b8 00 00          	mov    $0x0,%ax
}
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    

00801bf7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfd:	89 d0                	mov    %edx,%eax
  801bff:	c1 e8 16             	shr    $0x16,%eax
  801c02:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0e:	f6 c1 01             	test   $0x1,%cl
  801c11:	74 1d                	je     801c30 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c13:	c1 ea 0c             	shr    $0xc,%edx
  801c16:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c1d:	f6 c2 01             	test   $0x1,%dl
  801c20:	74 0e                	je     801c30 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c22:	c1 ea 0c             	shr    $0xc,%edx
  801c25:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c2c:	ef 
  801c2d:	0f b7 c0             	movzwl %ax,%eax
}
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	83 ec 10             	sub    $0x10,%esp
  801c46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c56:	85 d2                	test   %edx,%edx
  801c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c5c:	89 34 24             	mov    %esi,(%esp)
  801c5f:	89 c8                	mov    %ecx,%eax
  801c61:	75 35                	jne    801c98 <__udivdi3+0x58>
  801c63:	39 f1                	cmp    %esi,%ecx
  801c65:	0f 87 bd 00 00 00    	ja     801d28 <__udivdi3+0xe8>
  801c6b:	85 c9                	test   %ecx,%ecx
  801c6d:	89 cd                	mov    %ecx,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f1                	div    %ecx
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c6                	mov    %eax,%esi
  801c84:	89 f8                	mov    %edi,%eax
  801c86:	f7 f5                	div    %ebp
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    
  801c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c98:	3b 14 24             	cmp    (%esp),%edx
  801c9b:	77 7b                	ja     801d18 <__udivdi3+0xd8>
  801c9d:	0f bd f2             	bsr    %edx,%esi
  801ca0:	83 f6 1f             	xor    $0x1f,%esi
  801ca3:	0f 84 97 00 00 00    	je     801d40 <__udivdi3+0x100>
  801ca9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801cae:	89 d7                	mov    %edx,%edi
  801cb0:	89 f1                	mov    %esi,%ecx
  801cb2:	29 f5                	sub    %esi,%ebp
  801cb4:	d3 e7                	shl    %cl,%edi
  801cb6:	89 c2                	mov    %eax,%edx
  801cb8:	89 e9                	mov    %ebp,%ecx
  801cba:	d3 ea                	shr    %cl,%edx
  801cbc:	89 f1                	mov    %esi,%ecx
  801cbe:	09 fa                	or     %edi,%edx
  801cc0:	8b 3c 24             	mov    (%esp),%edi
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cc9:	89 e9                	mov    %ebp,%ecx
  801ccb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cd3:	89 fa                	mov    %edi,%edx
  801cd5:	d3 ea                	shr    %cl,%edx
  801cd7:	89 f1                	mov    %esi,%ecx
  801cd9:	d3 e7                	shl    %cl,%edi
  801cdb:	89 e9                	mov    %ebp,%ecx
  801cdd:	d3 e8                	shr    %cl,%eax
  801cdf:	09 c7                	or     %eax,%edi
  801ce1:	89 f8                	mov    %edi,%eax
  801ce3:	f7 74 24 08          	divl   0x8(%esp)
  801ce7:	89 d5                	mov    %edx,%ebp
  801ce9:	89 c7                	mov    %eax,%edi
  801ceb:	f7 64 24 0c          	mull   0xc(%esp)
  801cef:	39 d5                	cmp    %edx,%ebp
  801cf1:	89 14 24             	mov    %edx,(%esp)
  801cf4:	72 11                	jb     801d07 <__udivdi3+0xc7>
  801cf6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cfa:	89 f1                	mov    %esi,%ecx
  801cfc:	d3 e2                	shl    %cl,%edx
  801cfe:	39 c2                	cmp    %eax,%edx
  801d00:	73 5e                	jae    801d60 <__udivdi3+0x120>
  801d02:	3b 2c 24             	cmp    (%esp),%ebp
  801d05:	75 59                	jne    801d60 <__udivdi3+0x120>
  801d07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d0a:	31 f6                	xor    %esi,%esi
  801d0c:	89 f2                	mov    %esi,%edx
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    
  801d15:	8d 76 00             	lea    0x0(%esi),%esi
  801d18:	31 f6                	xor    %esi,%esi
  801d1a:	31 c0                	xor    %eax,%eax
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	89 f2                	mov    %esi,%edx
  801d2a:	31 f6                	xor    %esi,%esi
  801d2c:	89 f8                	mov    %edi,%eax
  801d2e:	f7 f1                	div    %ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d44:	76 0b                	jbe    801d51 <__udivdi3+0x111>
  801d46:	31 c0                	xor    %eax,%eax
  801d48:	3b 14 24             	cmp    (%esp),%edx
  801d4b:	0f 83 37 ff ff ff    	jae    801c88 <__udivdi3+0x48>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	e9 2d ff ff ff       	jmp    801c88 <__udivdi3+0x48>
  801d5b:	90                   	nop
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 f8                	mov    %edi,%eax
  801d62:	31 f6                	xor    %esi,%esi
  801d64:	e9 1f ff ff ff       	jmp    801c88 <__udivdi3+0x48>
  801d69:	66 90                	xchg   %ax,%ax
  801d6b:	66 90                	xchg   %ax,%ax
  801d6d:	66 90                	xchg   %ax,%ax
  801d6f:	90                   	nop

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	83 ec 20             	sub    $0x20,%esp
  801d76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d82:	89 c6                	mov    %eax,%esi
  801d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	75 1e                	jne    801dc0 <__umoddi3+0x50>
  801da2:	39 f7                	cmp    %esi,%edi
  801da4:	76 52                	jbe    801df8 <__umoddi3+0x88>
  801da6:	89 c8                	mov    %ecx,%eax
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	f7 f7                	div    %edi
  801dac:	89 d0                	mov    %edx,%eax
  801dae:	31 d2                	xor    %edx,%edx
  801db0:	83 c4 20             	add    $0x20,%esp
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	39 f0                	cmp    %esi,%eax
  801dc2:	77 5c                	ja     801e20 <__umoddi3+0xb0>
  801dc4:	0f bd e8             	bsr    %eax,%ebp
  801dc7:	83 f5 1f             	xor    $0x1f,%ebp
  801dca:	75 64                	jne    801e30 <__umoddi3+0xc0>
  801dcc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801dd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801dd4:	0f 86 f6 00 00 00    	jbe    801ed0 <__umoddi3+0x160>
  801dda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dde:	0f 82 ec 00 00 00    	jb     801ed0 <__umoddi3+0x160>
  801de4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801de8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801dec:	83 c4 20             	add    $0x20,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
  801df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df8:	85 ff                	test   %edi,%edi
  801dfa:	89 fd                	mov    %edi,%ebp
  801dfc:	75 0b                	jne    801e09 <__umoddi3+0x99>
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f7                	div    %edi
  801e07:	89 c5                	mov    %eax,%ebp
  801e09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	f7 f5                	div    %ebp
  801e11:	89 c8                	mov    %ecx,%eax
  801e13:	f7 f5                	div    %ebp
  801e15:	eb 95                	jmp    801dac <__umoddi3+0x3c>
  801e17:	89 f6                	mov    %esi,%esi
  801e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 20             	add    $0x20,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	b8 20 00 00 00       	mov    $0x20,%eax
  801e35:	89 e9                	mov    %ebp,%ecx
  801e37:	29 e8                	sub    %ebp,%eax
  801e39:	d3 e2                	shl    %cl,%edx
  801e3b:	89 c7                	mov    %eax,%edi
  801e3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 c1                	mov    %eax,%ecx
  801e4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4f:	09 d1                	or     %edx,%ecx
  801e51:	89 fa                	mov    %edi,%edx
  801e53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e57:	89 e9                	mov    %ebp,%ecx
  801e59:	d3 e0                	shl    %cl,%eax
  801e5b:	89 f9                	mov    %edi,%ecx
  801e5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	d3 e8                	shr    %cl,%eax
  801e65:	89 e9                	mov    %ebp,%ecx
  801e67:	89 c7                	mov    %eax,%edi
  801e69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e6d:	d3 e6                	shl    %cl,%esi
  801e6f:	89 d1                	mov    %edx,%ecx
  801e71:	89 fa                	mov    %edi,%edx
  801e73:	d3 e8                	shr    %cl,%eax
  801e75:	89 e9                	mov    %ebp,%ecx
  801e77:	09 f0                	or     %esi,%eax
  801e79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e7d:	f7 74 24 10          	divl   0x10(%esp)
  801e81:	d3 e6                	shl    %cl,%esi
  801e83:	89 d1                	mov    %edx,%ecx
  801e85:	f7 64 24 0c          	mull   0xc(%esp)
  801e89:	39 d1                	cmp    %edx,%ecx
  801e8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e8f:	89 d7                	mov    %edx,%edi
  801e91:	89 c6                	mov    %eax,%esi
  801e93:	72 0a                	jb     801e9f <__umoddi3+0x12f>
  801e95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e99:	73 10                	jae    801eab <__umoddi3+0x13b>
  801e9b:	39 d1                	cmp    %edx,%ecx
  801e9d:	75 0c                	jne    801eab <__umoddi3+0x13b>
  801e9f:	89 d7                	mov    %edx,%edi
  801ea1:	89 c6                	mov    %eax,%esi
  801ea3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801ea7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801eab:	89 ca                	mov    %ecx,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eb3:	29 f0                	sub    %esi,%eax
  801eb5:	19 fa                	sbb    %edi,%edx
  801eb7:	d3 e8                	shr    %cl,%eax
  801eb9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801ebe:	89 d7                	mov    %edx,%edi
  801ec0:	d3 e7                	shl    %cl,%edi
  801ec2:	89 e9                	mov    %ebp,%ecx
  801ec4:	09 f8                	or     %edi,%eax
  801ec6:	d3 ea                	shr    %cl,%edx
  801ec8:	83 c4 20             	add    $0x20,%esp
  801ecb:	5e                   	pop    %esi
  801ecc:	5f                   	pop    %edi
  801ecd:	5d                   	pop    %ebp
  801ece:	c3                   	ret    
  801ecf:	90                   	nop
  801ed0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ed4:	29 f9                	sub    %edi,%ecx
  801ed6:	19 c6                	sbb    %eax,%esi
  801ed8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801edc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801ee0:	e9 ff fe ff ff       	jmp    801de4 <__umoddi3+0x74>
