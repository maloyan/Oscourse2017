
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 80 1e 80 00       	push   $0x801e80
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 40 40 80 00 	cmpl   $0x0,0x804040(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 fb 1e 80 00       	push   $0x801efb
  80005b:	6a 11                	push   $0x11
  80005d:	68 18 1f 80 00       	push   $0x801f18
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 40 40 80 00 	mov    %eax,0x804040(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 40 40 80 00 	cmp    0x804040(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 a0 1e 80 00       	push   $0x801ea0
  80009b:	6a 16                	push   $0x16
  80009d:	68 18 1f 80 00       	push   $0x801f18
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 c8 1e 80 00       	push   $0x801ec8
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 40 50 c0 00 00 	movl   $0x0,0xc05040
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 27 1f 80 00       	push   $0x801f27
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 18 1f 80 00       	push   $0x801f18
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000e7:	e8 79 0a 00 00       	call   800b65 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 78             	imul   $0x78,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 40 40 c0 00       	mov    %eax,0xc04040

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
  800118:	83 c4 10             	add    $0x10,%esp
#endif
}
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 52 0e 00 00       	call   800f7f <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 ed 09 00 00       	call   800b24 <sys_env_destroy>
  800137:	83 c4 10             	add    $0x10,%esp
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 16 0a 00 00       	call   800b65 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 48 1f 80 00       	push   $0x801f48
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 16 1f 80 00 	movl   $0x801f16,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 35 09 00 00       	call   800ae7 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 4f 01 00 00       	call   800347 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 da 08 00 00       	call   800ae7 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 d1                	mov    %edx,%ecx
  80023e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800241:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800254:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800257:	72 05                	jb     80025e <printnum+0x35>
  800259:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025c:	77 3e                	ja     80029c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 18             	pushl  0x18(%ebp)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 53 19 00 00       	call   801bd0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 13                	jmp    8002a3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ed                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b6:	e8 45 1a 00 00       	call   801d00 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 6b 1f 80 00 	movsbl 0x801f6b(%eax),%eax
  8002c5:	50                   	push   %eax
  8002c6:	ff d7                	call   *%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
}
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d6:	83 fa 01             	cmp    $0x1,%edx
  8002d9:	7e 0e                	jle    8002e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	8b 52 04             	mov    0x4(%edx),%edx
  8002e7:	eb 22                	jmp    80030b <getuint+0x38>
	else if (lflag)
  8002e9:	85 d2                	test   %edx,%edx
  8002eb:	74 10                	je     8002fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fb:	eb 0e                	jmp    80030b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800313:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800317:	8b 10                	mov    (%eax),%edx
  800319:	3b 50 04             	cmp    0x4(%eax),%edx
  80031c:	73 0a                	jae    800328 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	88 02                	mov    %al,(%edx)
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800330:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800333:	50                   	push   %eax
  800334:	ff 75 10             	pushl  0x10(%ebp)
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	e8 05 00 00 00       	call   800347 <vprintfmt>
	va_end(ap);
  800342:	83 c4 10             	add    $0x10,%esp
}
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
  80034d:	83 ec 2c             	sub    $0x2c,%esp
  800350:	8b 75 08             	mov    0x8(%ebp),%esi
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 7d 10             	mov    0x10(%ebp),%edi
  800359:	eb 12                	jmp    80036d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035b:	85 c0                	test   %eax,%eax
  80035d:	0f 84 8d 03 00 00    	je     8006f0 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	53                   	push   %ebx
  800367:	50                   	push   %eax
  800368:	ff d6                	call   *%esi
  80036a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036d:	83 c7 01             	add    $0x1,%edi
  800370:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800374:	83 f8 25             	cmp    $0x25,%eax
  800377:	75 e2                	jne    80035b <vprintfmt+0x14>
  800379:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800384:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 07                	jmp    8003a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8d 47 01             	lea    0x1(%edi),%eax
  8003a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a6:	0f b6 07             	movzbl (%edi),%eax
  8003a9:	0f b6 c8             	movzbl %al,%ecx
  8003ac:	83 e8 23             	sub    $0x23,%eax
  8003af:	3c 55                	cmp    $0x55,%al
  8003b1:	0f 87 1e 03 00 00    	ja     8006d5 <vprintfmt+0x38e>
  8003b7:	0f b6 c0             	movzbl %al,%eax
  8003ba:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c8:	eb d6                	jmp    8003a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003dc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003df:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e2:	83 fa 09             	cmp    $0x9,%edx
  8003e5:	77 38                	ja     80041f <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ea:	eb e9                	jmp    8003d5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fd:	eb 26                	jmp    800425 <vprintfmt+0xde>
  8003ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800402:	89 c8                	mov    %ecx,%eax
  800404:	c1 f8 1f             	sar    $0x1f,%eax
  800407:	f7 d0                	not    %eax
  800409:	21 c1                	and    %eax,%ecx
  80040b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800411:	eb 8d                	jmp    8003a0 <vprintfmt+0x59>
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800416:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041d:	eb 81                	jmp    8003a0 <vprintfmt+0x59>
  80041f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800422:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800429:	0f 89 71 ff ff ff    	jns    8003a0 <vprintfmt+0x59>
				width = precision, precision = -1;
  80042f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043c:	e9 5f ff ff ff       	jmp    8003a0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800441:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800447:	e9 54 ff ff ff       	jmp    8003a0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	ff 30                	pushl  (%eax)
  80045b:	ff d6                	call   *%esi
			break;
  80045d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800463:	e9 05 ff ff ff       	jmp    80036d <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	99                   	cltd   
  800474:	31 d0                	xor    %edx,%eax
  800476:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800478:	83 f8 0f             	cmp    $0xf,%eax
  80047b:	7f 0b                	jg     800488 <vprintfmt+0x141>
  80047d:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800484:	85 d2                	test   %edx,%edx
  800486:	75 18                	jne    8004a0 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800488:	50                   	push   %eax
  800489:	68 83 1f 80 00       	push   $0x801f83
  80048e:	53                   	push   %ebx
  80048f:	56                   	push   %esi
  800490:	e8 95 fe ff ff       	call   80032a <printfmt>
  800495:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049b:	e9 cd fe ff ff       	jmp    80036d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a0:	52                   	push   %edx
  8004a1:	68 71 23 80 00       	push   $0x802371
  8004a6:	53                   	push   %ebx
  8004a7:	56                   	push   %esi
  8004a8:	e8 7d fe ff ff       	call   80032a <printfmt>
  8004ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	e9 b5 fe ff ff       	jmp    80036d <vprintfmt+0x26>
  8004b8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004be:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 38                	mov    (%eax),%edi
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	75 05                	jne    8004d5 <vprintfmt+0x18e>
				p = "(null)";
  8004d0:	bf 7c 1f 80 00       	mov    $0x801f7c,%edi
			if (width > 0 && padc != '-')
  8004d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d9:	0f 84 91 00 00 00    	je     800570 <vprintfmt+0x229>
  8004df:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004e3:	0f 8e 95 00 00 00    	jle    80057e <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	51                   	push   %ecx
  8004ed:	57                   	push   %edi
  8004ee:	e8 85 02 00 00       	call   800778 <strnlen>
  8004f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1d4>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c5>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	89 c8                	mov    %ecx,%eax
  800527:	c1 f8 1f             	sar    $0x1f,%eax
  80052a:	f7 d0                	not    %eax
  80052c:	21 c8                	and    %ecx,%eax
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	eb 4d                	jmp    80058a <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	74 1b                	je     80055e <vprintfmt+0x217>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 10                	jbe    80055e <vprintfmt+0x217>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 3f                	push   $0x3f
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	52                   	push   %edx
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x243>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	eb 0c                	jmp    80058a <vprintfmt+0x243>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 23                	je     8005bb <vprintfmt+0x274>
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 a1                	js     80053d <vprintfmt+0x1f6>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 9c                	jns    80053d <vprintfmt+0x1f6>
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	eb 18                	jmp    8005c3 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb 08                	jmp    8005c3 <vprintfmt+0x27c>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	7f e4                	jg     8005ab <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	e9 9e fd ff ff       	jmp    80036d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cf:	83 fa 01             	cmp    $0x1,%edx
  8005d2:	7e 16                	jle    8005ea <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 08             	lea    0x8(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	eb 32                	jmp    80061c <vprintfmt+0x2d5>
	else if (lflag)
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	74 18                	je     800606 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800604:	eb 16                	jmp    80061c <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 74                	jns    8006a1 <vprintfmt+0x35a>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 2d                	push   $0x2d
  800633:	ff d6                	call   *%esi
				num = -(long long) num;
  800635:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800638:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063b:	f7 d8                	neg    %eax
  80063d:	83 d2 00             	adc    $0x0,%edx
  800640:	f7 da                	neg    %edx
  800642:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064a:	eb 55                	jmp    8006a1 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 7f fc ff ff       	call   8002d3 <getuint>
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800659:	eb 46                	jmp    8006a1 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 70 fc ff ff       	call   8002d3 <getuint>
			base = 8;
  800663:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800668:	eb 37                	jmp    8006a1 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 30                	push   $0x30
  800670:	ff d6                	call   *%esi
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 78                	push   $0x78
  800678:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800692:	eb 0d                	jmp    8006a1 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	e8 37 fc ff ff       	call   8002d3 <getuint>
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a8:	57                   	push   %edi
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	50                   	push   %eax
  8006af:	89 da                	mov    %ebx,%edx
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	e8 71 fb ff ff       	call   800229 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006be:	e9 aa fc ff ff       	jmp    80036d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	51                   	push   %ecx
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d0:	e9 98 fc ff ff       	jmp    80036d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 25                	push   $0x25
  8006db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 03                	jmp    8006e5 <vprintfmt+0x39e>
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e9:	75 f7                	jne    8006e2 <vprintfmt+0x39b>
  8006eb:	e9 7d fc ff ff       	jmp    80036d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 18             	sub    $0x18,%esp
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800707:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800715:	85 c0                	test   %eax,%eax
  800717:	74 26                	je     80073f <vsnprintf+0x47>
  800719:	85 d2                	test   %edx,%edx
  80071b:	7e 22                	jle    80073f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071d:	ff 75 14             	pushl  0x14(%ebp)
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800726:	50                   	push   %eax
  800727:	68 0d 03 80 00       	push   $0x80030d
  80072c:	e8 16 fc ff ff       	call   800347 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800731:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800734:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 05                	jmp    800744 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074f:	50                   	push   %eax
  800750:	ff 75 10             	pushl  0x10(%ebp)
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	ff 75 08             	pushl  0x8(%ebp)
  800759:	e8 9a ff ff ff       	call   8006f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 c2                	cmp    %eax,%edx
  80078d:	74 08                	je     800797 <strnlen+0x1f>
  80078f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
  800795:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b2:	84 db                	test   %bl,%bl
  8007b4:	75 ef                	jne    8007a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c0:	53                   	push   %ebx
  8007c1:	e8 9a ff ff ff       	call   800760 <strlen>
  8007c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	01 d8                	add    %ebx,%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 c5 ff ff ff       	call   800799 <strcpy>
	return dst;
}
  8007d4:	89 d8                	mov    %ebx,%eax
  8007d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e6:	89 f3                	mov    %esi,%ebx
  8007e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	89 f2                	mov    %esi,%edx
  8007ed:	eb 0f                	jmp    8007fe <strncpy+0x23>
		*dst++ = *src;
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	39 da                	cmp    %ebx,%edx
  800800:	75 ed                	jne    8007ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800802:	89 f0                	mov    %esi,%eax
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 10             	mov    0x10(%ebp),%edx
  800816:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 21                	je     80083d <strlcpy+0x35>
  80081c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800820:	89 f2                	mov    %esi,%edx
  800822:	eb 09                	jmp    80082d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800824:	83 c2 01             	add    $0x1,%edx
  800827:	83 c1 01             	add    $0x1,%ecx
  80082a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 09                	je     80083a <strlcpy+0x32>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	75 ec                	jne    800824 <strlcpy+0x1c>
  800838:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083d:	29 f0                	sub    %esi,%eax
}
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strcmp+0x11>
		p++, q++;
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	74 04                	je     80085f <strcmp+0x1c>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	74 ef                	je     80084e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 c0             	movzbl %al,%eax
  800862:	0f b6 12             	movzbl (%edx),%edx
  800865:	29 d0                	sub    %edx,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 c3                	mov    %eax,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800878:	eb 06                	jmp    800880 <strncmp+0x17>
		n--, p++, q++;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800880:	39 d8                	cmp    %ebx,%eax
  800882:	74 15                	je     800899 <strncmp+0x30>
  800884:	0f b6 08             	movzbl (%eax),%ecx
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x26>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 eb                	je     80087a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 07                	jmp    8008b4 <strchr+0x13>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 0f                	je     8008c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	0f b6 10             	movzbl (%eax),%edx
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f2                	jne    8008ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 03                	jmp    8008d1 <strfind+0xf>
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	74 04                	je     8008dc <strfind+0x1a>
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	75 f2                	jne    8008ce <strfind+0xc>
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 36                	je     800924 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f4:	75 28                	jne    80091e <memset+0x40>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 23                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ff:	89 d3                	mov    %edx,%ebx
  800901:	c1 e3 08             	shl    $0x8,%ebx
  800904:	89 d6                	mov    %edx,%esi
  800906:	c1 e6 18             	shl    $0x18,%esi
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 10             	shl    $0x10,%eax
  80090e:	09 f0                	or     %esi,%eax
  800910:	09 c2                	or     %eax,%edx
  800912:	89 d0                	mov    %edx,%eax
  800914:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800916:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 06                	jmp    800924 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	fc                   	cld    
  800922:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800924:	89 f8                	mov    %edi,%eax
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800939:	39 c6                	cmp    %eax,%esi
  80093b:	73 35                	jae    800972 <memmove+0x47>
  80093d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800940:	39 d0                	cmp    %edx,%eax
  800942:	73 2e                	jae    800972 <memmove+0x47>
		s += n;
		d += n;
  800944:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800947:	89 d6                	mov    %edx,%esi
  800949:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800951:	75 13                	jne    800966 <memmove+0x3b>
  800953:	f6 c1 03             	test   $0x3,%cl
  800956:	75 0e                	jne    800966 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800958:	83 ef 04             	sub    $0x4,%edi
  80095b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800961:	fd                   	std    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 09                	jmp    80096f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1d                	jmp    80098f <memmove+0x64>
  800972:	89 f2                	mov    %esi,%edx
  800974:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0f                	jne    80098a <memmove+0x5f>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800980:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	ff 75 08             	pushl  0x8(%ebp)
  80099f:	e8 87 ff ff ff       	call   80092b <memmove>
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	eb 1a                	jmp    8009d2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	0f b6 1a             	movzbl (%edx),%ebx
  8009be:	38 d9                	cmp    %bl,%cl
  8009c0:	74 0a                	je     8009cc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c1             	movzbl %cl,%eax
  8009c5:	0f b6 db             	movzbl %bl,%ebx
  8009c8:	29 d8                	sub    %ebx,%eax
  8009ca:	eb 0f                	jmp    8009db <memcmp+0x35>
		s1++, s2++;
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	39 f0                	cmp    %esi,%eax
  8009d4:	75 e2                	jne    8009b8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ed:	eb 07                	jmp    8009f6 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	38 08                	cmp    %cl,(%eax)
  8009f1:	74 07                	je     8009fa <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	39 d0                	cmp    %edx,%eax
  8009f8:	72 f5                	jb     8009ef <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	eb 03                	jmp    800a0d <strtol+0x11>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	3c 09                	cmp    $0x9,%al
  800a12:	74 f6                	je     800a0a <strtol+0xe>
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f2                	je     800a0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a18:	3c 2b                	cmp    $0x2b,%al
  800a1a:	75 0a                	jne    800a26 <strtol+0x2a>
		s++;
  800a1c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a24:	eb 10                	jmp    800a36 <strtol+0x3a>
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2b:	3c 2d                	cmp    $0x2d,%al
  800a2d:	75 07                	jne    800a36 <strtol+0x3a>
		s++, neg = 1;
  800a2f:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a32:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	0f 94 c0             	sete   %al
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 19                	jne    800a5c <strtol+0x60>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 14                	jne    800a5c <strtol+0x60>
  800a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4c:	0f 85 8a 00 00 00    	jne    800adc <strtol+0xe0>
		s += 2, base = 16;
  800a52:	83 c1 02             	add    $0x2,%ecx
  800a55:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5a:	eb 16                	jmp    800a72 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5c:	84 c0                	test   %al,%al
  800a5e:	74 12                	je     800a72 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a60:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	75 08                	jne    800a72 <strtol+0x76>
		s++, base = 8;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7a:	0f b6 11             	movzbl (%ecx),%edx
  800a7d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 09             	cmp    $0x9,%bl
  800a85:	77 08                	ja     800a8f <strtol+0x93>
			dig = *s - '0';
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 30             	sub    $0x30,%edx
  800a8d:	eb 22                	jmp    800ab1 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a8f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 08                	ja     800aa1 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 57             	sub    $0x57,%edx
  800a9f:	eb 10                	jmp    800ab1 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800aa1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 19             	cmp    $0x19,%bl
  800aa9:	77 16                	ja     800ac1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab4:	7d 0f                	jge    800ac5 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abf:	eb b9                	jmp    800a7a <strtol+0x7e>
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	eb 02                	jmp    800ac7 <strtol+0xcb>
  800ac5:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acb:	74 05                	je     800ad2 <strtol+0xd6>
		*endptr = (char *) s;
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad2:	85 ff                	test   %edi,%edi
  800ad4:	74 0c                	je     800ae2 <strtol+0xe6>
  800ad6:	89 d0                	mov    %edx,%eax
  800ad8:	f7 d8                	neg    %eax
  800ada:	eb 06                	jmp    800ae2 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	84 c0                	test   %al,%al
  800ade:	75 8a                	jne    800a6a <strtol+0x6e>
  800ae0:	eb 90                	jmp    800a72 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	8b 55 08             	mov    0x8(%ebp),%edx
  800af8:	89 c3                	mov    %eax,%ebx
  800afa:	89 c7                	mov    %eax,%edi
  800afc:	89 c6                	mov    %eax,%esi
  800afe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 01 00 00 00       	mov    $0x1,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b32:	b8 03 00 00 00       	mov    $0x3,%eax
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	89 cb                	mov    %ecx,%ebx
  800b3c:	89 cf                	mov    %ecx,%edi
  800b3e:	89 ce                	mov    %ecx,%esi
  800b40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b42:	85 c0                	test   %eax,%eax
  800b44:	7e 17                	jle    800b5d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	50                   	push   %eax
  800b4a:	6a 03                	push   $0x3
  800b4c:	68 9f 22 80 00       	push   $0x80229f
  800b51:	6a 23                	push   $0x23
  800b53:	68 bc 22 80 00       	push   $0x8022bc
  800b58:	e8 df f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 02 00 00 00       	mov    $0x2,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_yield>:

void
sys_yield(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	be 00 00 00 00       	mov    $0x0,%esi
  800bb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	89 f7                	mov    %esi,%edi
  800bc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 17                	jle    800bde <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 04                	push   $0x4
  800bcd:	68 9f 22 80 00       	push   $0x80229f
  800bd2:	6a 23                	push   $0x23
  800bd4:	68 bc 22 80 00       	push   $0x8022bc
  800bd9:	e8 5e f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c00:	8b 75 18             	mov    0x18(%ebp),%esi
  800c03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 05                	push   $0x5
  800c0f:	68 9f 22 80 00       	push   $0x80229f
  800c14:	6a 23                	push   $0x23
  800c16:	68 bc 22 80 00       	push   $0x8022bc
  800c1b:	e8 1c f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 17                	jle    800c62 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 06                	push   $0x6
  800c51:	68 9f 22 80 00       	push   $0x80229f
  800c56:	6a 23                	push   $0x23
  800c58:	68 bc 22 80 00       	push   $0x8022bc
  800c5d:	e8 da f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 08                	push   $0x8
  800c93:	68 9f 22 80 00       	push   $0x80229f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 bc 22 80 00       	push   $0x8022bc
  800c9f:	e8 98 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 09                	push   $0x9
  800cd5:	68 9f 22 80 00       	push   $0x80229f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 bc 22 80 00       	push   $0x8022bc
  800ce1:	e8 56 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 0a                	push   $0xa
  800d17:	68 9f 22 80 00       	push   $0x80229f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 bc 22 80 00       	push   $0x8022bc
  800d23:	e8 14 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	be 00 00 00 00       	mov    $0x0,%esi
  800d3b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d61:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 cb                	mov    %ecx,%ebx
  800d6b:	89 cf                	mov    %ecx,%edi
  800d6d:	89 ce                	mov    %ecx,%esi
  800d6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 17                	jle    800d8c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 0d                	push   $0xd
  800d7b:	68 9f 22 80 00       	push   $0x80229f
  800d80:	6a 23                	push   $0x23
  800d82:	68 bc 22 80 00       	push   $0x8022bc
  800d87:	e8 b0 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_gettime>:

int sys_gettime(void)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da4:	89 d1                	mov    %edx,%ecx
  800da6:	89 d3                	mov    %edx,%ebx
  800da8:	89 d7                	mov    %edx,%edi
  800daa:	89 d6                	mov    %edx,%esi
  800dac:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbe:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800dce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dd3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 16             	shr    $0x16,%edx
  800dea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	74 11                	je     800e07 <fd_alloc+0x2d>
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 0c             	shr    $0xc,%edx
  800dfb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	75 09                	jne    800e10 <fd_alloc+0x36>
			*fd_store = fd;
  800e07:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0e:	eb 17                	jmp    800e27 <fd_alloc+0x4d>
  800e10:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e15:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e1a:	75 c9                	jne    800de5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e1c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e22:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e2f:	83 f8 1f             	cmp    $0x1f,%eax
  800e32:	77 36                	ja     800e6a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e34:	c1 e0 0c             	shl    $0xc,%eax
  800e37:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 24                	je     800e71 <fd_lookup+0x48>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	74 1a                	je     800e78 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	89 02                	mov    %eax,(%edx)
	return 0;
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	eb 13                	jmp    800e7d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6f:	eb 0c                	jmp    800e7d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e76:	eb 05                	jmp    800e7d <fd_lookup+0x54>
  800e78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e88:	ba 48 23 80 00       	mov    $0x802348,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e8d:	eb 13                	jmp    800ea2 <dev_lookup+0x23>
  800e8f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e92:	39 08                	cmp    %ecx,(%eax)
  800e94:	75 0c                	jne    800ea2 <dev_lookup+0x23>
			*dev = devtab[i];
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	eb 2e                	jmp    800ed0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ea2:	8b 02                	mov    (%edx),%eax
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	75 e7                	jne    800e8f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea8:	a1 40 40 c0 00       	mov    0xc04040,%eax
  800ead:	8b 40 48             	mov    0x48(%eax),%eax
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	51                   	push   %ecx
  800eb4:	50                   	push   %eax
  800eb5:	68 cc 22 80 00       	push   $0x8022cc
  800eba:	e8 56 f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	83 ec 10             	sub    $0x10,%esp
  800eda:	8b 75 08             	mov    0x8(%ebp),%esi
  800edd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee3:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eea:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eed:	50                   	push   %eax
  800eee:	e8 36 ff ff ff       	call   800e29 <fd_lookup>
  800ef3:	83 c4 08             	add    $0x8,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 05                	js     800eff <fd_close+0x2d>
	    || fd != fd2)
  800efa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800efd:	74 0b                	je     800f0a <fd_close+0x38>
		return (must_exist ? r : 0);
  800eff:	80 fb 01             	cmp    $0x1,%bl
  800f02:	19 d2                	sbb    %edx,%edx
  800f04:	f7 d2                	not    %edx
  800f06:	21 d0                	and    %edx,%eax
  800f08:	eb 41                	jmp    800f4b <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f0a:	83 ec 08             	sub    $0x8,%esp
  800f0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	ff 36                	pushl  (%esi)
  800f13:	e8 67 ff ff ff       	call   800e7f <dev_lookup>
  800f18:	89 c3                	mov    %eax,%ebx
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 1a                	js     800f3b <fd_close+0x69>
		if (dev->dev_close)
  800f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f24:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	74 0b                	je     800f3b <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	56                   	push   %esi
  800f34:	ff d0                	call   *%eax
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f3b:	83 ec 08             	sub    $0x8,%esp
  800f3e:	56                   	push   %esi
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 e2 fc ff ff       	call   800c28 <sys_page_unmap>
	return r;
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	89 d8                	mov    %ebx,%eax
}
  800f4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	ff 75 08             	pushl  0x8(%ebp)
  800f5f:	e8 c5 fe ff ff       	call   800e29 <fd_lookup>
  800f64:	89 c2                	mov    %eax,%edx
  800f66:	83 c4 08             	add    $0x8,%esp
  800f69:	85 d2                	test   %edx,%edx
  800f6b:	78 10                	js     800f7d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f6d:	83 ec 08             	sub    $0x8,%esp
  800f70:	6a 01                	push   $0x1
  800f72:	ff 75 f4             	pushl  -0xc(%ebp)
  800f75:	e8 58 ff ff ff       	call   800ed2 <fd_close>
  800f7a:	83 c4 10             	add    $0x10,%esp
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <close_all>:

void
close_all(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	53                   	push   %ebx
  800f83:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	53                   	push   %ebx
  800f8f:	e8 be ff ff ff       	call   800f52 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f94:	83 c3 01             	add    $0x1,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	83 fb 20             	cmp    $0x20,%ebx
  800f9d:	75 ec                	jne    800f8b <close_all+0xc>
		close(i);
}
  800f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 2c             	sub    $0x2c,%esp
  800fad:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 6d fe ff ff       	call   800e29 <fd_lookup>
  800fbc:	89 c2                	mov    %eax,%edx
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 d2                	test   %edx,%edx
  800fc3:	0f 88 c1 00 00 00    	js     80108a <dup+0xe6>
		return r;
	close(newfdnum);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	56                   	push   %esi
  800fcd:	e8 80 ff ff ff       	call   800f52 <close>

	newfd = INDEX2FD(newfdnum);
  800fd2:	89 f3                	mov    %esi,%ebx
  800fd4:	c1 e3 0c             	shl    $0xc,%ebx
  800fd7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fdd:	83 c4 04             	add    $0x4,%esp
  800fe0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe3:	e8 db fd ff ff       	call   800dc3 <fd2data>
  800fe8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fea:	89 1c 24             	mov    %ebx,(%esp)
  800fed:	e8 d1 fd ff ff       	call   800dc3 <fd2data>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ff8:	89 f8                	mov    %edi,%eax
  800ffa:	c1 e8 16             	shr    $0x16,%eax
  800ffd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801004:	a8 01                	test   $0x1,%al
  801006:	74 37                	je     80103f <dup+0x9b>
  801008:	89 f8                	mov    %edi,%eax
  80100a:	c1 e8 0c             	shr    $0xc,%eax
  80100d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801014:	f6 c2 01             	test   $0x1,%dl
  801017:	74 26                	je     80103f <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801019:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	25 07 0e 00 00       	and    $0xe07,%eax
  801028:	50                   	push   %eax
  801029:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102c:	6a 00                	push   $0x0
  80102e:	57                   	push   %edi
  80102f:	6a 00                	push   $0x0
  801031:	e8 b0 fb ff ff       	call   800be6 <sys_page_map>
  801036:	89 c7                	mov    %eax,%edi
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 2e                	js     80106d <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801042:	89 d0                	mov    %edx,%eax
  801044:	c1 e8 0c             	shr    $0xc,%eax
  801047:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	25 07 0e 00 00       	and    $0xe07,%eax
  801056:	50                   	push   %eax
  801057:	53                   	push   %ebx
  801058:	6a 00                	push   $0x0
  80105a:	52                   	push   %edx
  80105b:	6a 00                	push   $0x0
  80105d:	e8 84 fb ff ff       	call   800be6 <sys_page_map>
  801062:	89 c7                	mov    %eax,%edi
  801064:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801067:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801069:	85 ff                	test   %edi,%edi
  80106b:	79 1d                	jns    80108a <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	53                   	push   %ebx
  801071:	6a 00                	push   $0x0
  801073:	e8 b0 fb ff ff       	call   800c28 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801078:	83 c4 08             	add    $0x8,%esp
  80107b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107e:	6a 00                	push   $0x0
  801080:	e8 a3 fb ff ff       	call   800c28 <sys_page_unmap>
	return r;
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	89 f8                	mov    %edi,%eax
}
  80108a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	53                   	push   %ebx
  801096:	83 ec 14             	sub    $0x14,%esp
  801099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109f:	50                   	push   %eax
  8010a0:	53                   	push   %ebx
  8010a1:	e8 83 fd ff ff       	call   800e29 <fd_lookup>
  8010a6:	83 c4 08             	add    $0x8,%esp
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 6d                	js     80111c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b9:	ff 30                	pushl  (%eax)
  8010bb:	e8 bf fd ff ff       	call   800e7f <dev_lookup>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 4c                	js     801113 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ca:	8b 42 08             	mov    0x8(%edx),%eax
  8010cd:	83 e0 03             	and    $0x3,%eax
  8010d0:	83 f8 01             	cmp    $0x1,%eax
  8010d3:	75 21                	jne    8010f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d5:	a1 40 40 c0 00       	mov    0xc04040,%eax
  8010da:	8b 40 48             	mov    0x48(%eax),%eax
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	53                   	push   %ebx
  8010e1:	50                   	push   %eax
  8010e2:	68 0d 23 80 00       	push   $0x80230d
  8010e7:	e8 29 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010f4:	eb 26                	jmp    80111c <read+0x8a>
	}
	if (!dev->dev_read)
  8010f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f9:	8b 40 08             	mov    0x8(%eax),%eax
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	74 17                	je     801117 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	ff 75 10             	pushl  0x10(%ebp)
  801106:	ff 75 0c             	pushl  0xc(%ebp)
  801109:	52                   	push   %edx
  80110a:	ff d0                	call   *%eax
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	eb 09                	jmp    80111c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801113:	89 c2                	mov    %eax,%edx
  801115:	eb 05                	jmp    80111c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801117:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80111c:	89 d0                	mov    %edx,%eax
  80111e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801132:	bb 00 00 00 00       	mov    $0x0,%ebx
  801137:	eb 21                	jmp    80115a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	89 f0                	mov    %esi,%eax
  80113e:	29 d8                	sub    %ebx,%eax
  801140:	50                   	push   %eax
  801141:	89 d8                	mov    %ebx,%eax
  801143:	03 45 0c             	add    0xc(%ebp),%eax
  801146:	50                   	push   %eax
  801147:	57                   	push   %edi
  801148:	e8 45 ff ff ff       	call   801092 <read>
		if (m < 0)
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 0c                	js     801160 <readn+0x3d>
			return m;
		if (m == 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	74 06                	je     80115e <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801158:	01 c3                	add    %eax,%ebx
  80115a:	39 f3                	cmp    %esi,%ebx
  80115c:	72 db                	jb     801139 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80115e:	89 d8                	mov    %ebx,%eax
}
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	53                   	push   %ebx
  80116c:	83 ec 14             	sub    $0x14,%esp
  80116f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801172:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	53                   	push   %ebx
  801177:	e8 ad fc ff ff       	call   800e29 <fd_lookup>
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	89 c2                	mov    %eax,%edx
  801181:	85 c0                	test   %eax,%eax
  801183:	78 68                	js     8011ed <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118f:	ff 30                	pushl  (%eax)
  801191:	e8 e9 fc ff ff       	call   800e7f <dev_lookup>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 47                	js     8011e4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a4:	75 21                	jne    8011c7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a6:	a1 40 40 c0 00       	mov    0xc04040,%eax
  8011ab:	8b 40 48             	mov    0x48(%eax),%eax
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	53                   	push   %ebx
  8011b2:	50                   	push   %eax
  8011b3:	68 29 23 80 00       	push   $0x802329
  8011b8:	e8 58 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c5:	eb 26                	jmp    8011ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8011cd:	85 d2                	test   %edx,%edx
  8011cf:	74 17                	je     8011e8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	ff 75 10             	pushl  0x10(%ebp)
  8011d7:	ff 75 0c             	pushl  0xc(%ebp)
  8011da:	50                   	push   %eax
  8011db:	ff d2                	call   *%edx
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	eb 09                	jmp    8011ed <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	eb 05                	jmp    8011ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ed:	89 d0                	mov    %edx,%eax
  8011ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 08             	pushl  0x8(%ebp)
  801201:	e8 23 fc ff ff       	call   800e29 <fd_lookup>
  801206:	83 c4 08             	add    $0x8,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 0e                	js     80121b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80120d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801210:	8b 55 0c             	mov    0xc(%ebp),%edx
  801213:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	53                   	push   %ebx
  801221:	83 ec 14             	sub    $0x14,%esp
  801224:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801227:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	53                   	push   %ebx
  80122c:	e8 f8 fb ff ff       	call   800e29 <fd_lookup>
  801231:	83 c4 08             	add    $0x8,%esp
  801234:	89 c2                	mov    %eax,%edx
  801236:	85 c0                	test   %eax,%eax
  801238:	78 65                	js     80129f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	ff 30                	pushl  (%eax)
  801246:	e8 34 fc ff ff       	call   800e7f <dev_lookup>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 44                	js     801296 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801259:	75 21                	jne    80127c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80125b:	a1 40 40 c0 00       	mov    0xc04040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801260:	8b 40 48             	mov    0x48(%eax),%eax
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	53                   	push   %ebx
  801267:	50                   	push   %eax
  801268:	68 ec 22 80 00       	push   $0x8022ec
  80126d:	e8 a3 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80127a:	eb 23                	jmp    80129f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80127c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127f:	8b 52 18             	mov    0x18(%edx),%edx
  801282:	85 d2                	test   %edx,%edx
  801284:	74 14                	je     80129a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	50                   	push   %eax
  80128d:	ff d2                	call   *%edx
  80128f:	89 c2                	mov    %eax,%edx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	eb 09                	jmp    80129f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	89 c2                	mov    %eax,%edx
  801298:	eb 05                	jmp    80129f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80129a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80129f:	89 d0                	mov    %edx,%eax
  8012a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 14             	sub    $0x14,%esp
  8012ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 6d fb ff ff       	call   800e29 <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 58                	js     80131d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cf:	ff 30                	pushl  (%eax)
  8012d1:	e8 a9 fb ff ff       	call   800e7f <dev_lookup>
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 37                	js     801314 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012e4:	74 32                	je     801318 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f0:	00 00 00 
	stat->st_isdir = 0;
  8012f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012fa:	00 00 00 
	stat->st_dev = dev;
  8012fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	53                   	push   %ebx
  801307:	ff 75 f0             	pushl  -0x10(%ebp)
  80130a:	ff 50 14             	call   *0x14(%eax)
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 09                	jmp    80131d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	89 c2                	mov    %eax,%edx
  801316:	eb 05                	jmp    80131d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801318:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	6a 00                	push   $0x0
  80132e:	ff 75 08             	pushl  0x8(%ebp)
  801331:	e8 e7 01 00 00       	call   80151d <open>
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 db                	test   %ebx,%ebx
  80133d:	78 1b                	js     80135a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	ff 75 0c             	pushl  0xc(%ebp)
  801345:	53                   	push   %ebx
  801346:	e8 5b ff ff ff       	call   8012a6 <fstat>
  80134b:	89 c6                	mov    %eax,%esi
	close(fd);
  80134d:	89 1c 24             	mov    %ebx,(%esp)
  801350:	e8 fd fb ff ff       	call   800f52 <close>
	return r;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	89 f0                	mov    %esi,%eax
}
  80135a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	89 c6                	mov    %eax,%esi
  801368:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80136a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801371:	75 12                	jne    801385 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	6a 03                	push   $0x3
  801378:	e8 d2 07 00 00       	call   801b4f <ipc_find_env>
  80137d:	a3 00 40 80 00       	mov    %eax,0x804000
  801382:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801385:	6a 07                	push   $0x7
  801387:	68 00 50 c0 00       	push   $0xc05000
  80138c:	56                   	push   %esi
  80138d:	ff 35 00 40 80 00    	pushl  0x804000
  801393:	e8 66 07 00 00       	call   801afe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801398:	83 c4 0c             	add    $0xc,%esp
  80139b:	6a 00                	push   $0x0
  80139d:	53                   	push   %ebx
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 f3 06 00 00       	call   801a98 <ipc_recv>
}
  8013a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b8:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c0:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8013cf:	e8 8d ff ff ff       	call   801361 <fsipc>
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e2:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f1:	e8 6b ff ff ff       	call   801361 <fsipc>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 05 00 00 00       	mov    $0x5,%eax
  801417:	e8 45 ff ff ff       	call   801361 <fsipc>
  80141c:	89 c2                	mov    %eax,%edx
  80141e:	85 d2                	test   %edx,%edx
  801420:	78 2c                	js     80144e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	68 00 50 c0 00       	push   $0xc05000
  80142a:	53                   	push   %ebx
  80142b:	e8 69 f3 ff ff       	call   800799 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801430:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801435:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143b:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801440:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  80145c:	8b 55 08             	mov    0x8(%ebp),%edx
  80145f:	8b 52 0c             	mov    0xc(%edx),%edx
  801462:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801468:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  80146d:	76 05                	jbe    801474 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  80146f:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801474:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(req->req_buf, buf, movesize);
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	50                   	push   %eax
  80147d:	ff 75 0c             	pushl  0xc(%ebp)
  801480:	68 08 50 c0 00       	push   $0xc05008
  801485:	e8 a1 f4 ff ff       	call   80092b <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	b8 04 00 00 00       	mov    $0x4,%eax
  801494:	e8 c8 fe ff ff       	call   801361 <fsipc>
	return write;
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a9:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014ae:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8014be:	e8 9e fe ff ff       	call   801361 <fsipc>
  8014c3:	89 c3                	mov    %eax,%ebx
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 4b                	js     801514 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c9:	39 c6                	cmp    %eax,%esi
  8014cb:	73 16                	jae    8014e3 <devfile_read+0x48>
  8014cd:	68 58 23 80 00       	push   $0x802358
  8014d2:	68 5f 23 80 00       	push   $0x80235f
  8014d7:	6a 7c                	push   $0x7c
  8014d9:	68 74 23 80 00       	push   $0x802374
  8014de:	e8 59 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  8014e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e8:	7e 16                	jle    801500 <devfile_read+0x65>
  8014ea:	68 7f 23 80 00       	push   $0x80237f
  8014ef:	68 5f 23 80 00       	push   $0x80235f
  8014f4:	6a 7d                	push   $0x7d
  8014f6:	68 74 23 80 00       	push   $0x802374
  8014fb:	e8 3c ec ff ff       	call   80013c <_panic>
	memmove(buf, &fsipcbuf, r);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	50                   	push   %eax
  801504:	68 00 50 c0 00       	push   $0xc05000
  801509:	ff 75 0c             	pushl  0xc(%ebp)
  80150c:	e8 1a f4 ff ff       	call   80092b <memmove>
	return r;
  801511:	83 c4 10             	add    $0x10,%esp
}
  801514:	89 d8                	mov    %ebx,%eax
  801516:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 20             	sub    $0x20,%esp
  801524:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801527:	53                   	push   %ebx
  801528:	e8 33 f2 ff ff       	call   800760 <strlen>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801535:	7f 67                	jg     80159e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	e8 97 f8 ff ff       	call   800dda <fd_alloc>
  801543:	83 c4 10             	add    $0x10,%esp
		return r;
  801546:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 57                	js     8015a3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	68 00 50 c0 00       	push   $0xc05000
  801555:	e8 3f f2 ff ff       	call   800799 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155d:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	b8 01 00 00 00       	mov    $0x1,%eax
  80156a:	e8 f2 fd ff ff       	call   801361 <fsipc>
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	79 14                	jns    80158c <open+0x6f>
		fd_close(fd, 0);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	6a 00                	push   $0x0
  80157d:	ff 75 f4             	pushl  -0xc(%ebp)
  801580:	e8 4d f9 ff ff       	call   800ed2 <fd_close>
		return r;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	89 da                	mov    %ebx,%edx
  80158a:	eb 17                	jmp    8015a3 <open+0x86>
	}

	return fd2num(fd);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	ff 75 f4             	pushl  -0xc(%ebp)
  801592:	e8 1c f8 ff ff       	call   800db3 <fd2num>
  801597:	89 c2                	mov    %eax,%edx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	eb 05                	jmp    8015a3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80159e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a3:	89 d0                	mov    %edx,%eax
  8015a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ba:	e8 a2 fd ff ff       	call   801361 <fsipc>
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 ef f7 ff ff       	call   800dc3 <fd2data>
  8015d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015d6:	83 c4 08             	add    $0x8,%esp
  8015d9:	68 8b 23 80 00       	push   $0x80238b
  8015de:	53                   	push   %ebx
  8015df:	e8 b5 f1 ff ff       	call   800799 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015e4:	8b 56 04             	mov    0x4(%esi),%edx
  8015e7:	89 d0                	mov    %edx,%eax
  8015e9:	2b 06                	sub    (%esi),%eax
  8015eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f8:	00 00 00 
	stat->st_dev = &devpipe;
  8015fb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801602:	30 80 00 
	return 0;
}
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
  80160a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	53                   	push   %ebx
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80161b:	53                   	push   %ebx
  80161c:	6a 00                	push   $0x0
  80161e:	e8 05 f6 ff ff       	call   800c28 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801623:	89 1c 24             	mov    %ebx,(%esp)
  801626:	e8 98 f7 ff ff       	call   800dc3 <fd2data>
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	50                   	push   %eax
  80162f:	6a 00                	push   $0x0
  801631:	e8 f2 f5 ff ff       	call   800c28 <sys_page_unmap>
}
  801636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 1c             	sub    $0x1c,%esp
  801644:	89 c7                	mov    %eax,%edi
  801646:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801648:	a1 40 40 c0 00       	mov    0xc04040,%eax
  80164d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	57                   	push   %edi
  801654:	e8 2e 05 00 00       	call   801b87 <pageref>
  801659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80165c:	89 34 24             	mov    %esi,(%esp)
  80165f:	e8 23 05 00 00       	call   801b87 <pageref>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80166a:	0f 94 c0             	sete   %al
  80166d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801670:	8b 15 40 40 c0 00    	mov    0xc04040,%edx
  801676:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801679:	39 cb                	cmp    %ecx,%ebx
  80167b:	74 15                	je     801692 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  80167d:	8b 52 58             	mov    0x58(%edx),%edx
  801680:	50                   	push   %eax
  801681:	52                   	push   %edx
  801682:	53                   	push   %ebx
  801683:	68 98 23 80 00       	push   $0x802398
  801688:	e8 88 eb ff ff       	call   800215 <cprintf>
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb b6                	jmp    801648 <_pipeisclosed+0xd>
	}
}
  801692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 28             	sub    $0x28,%esp
  8016a3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016a6:	56                   	push   %esi
  8016a7:	e8 17 f7 ff ff       	call   800dc3 <fd2data>
  8016ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8016b6:	eb 4b                	jmp    801703 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016b8:	89 da                	mov    %ebx,%edx
  8016ba:	89 f0                	mov    %esi,%eax
  8016bc:	e8 7a ff ff ff       	call   80163b <_pipeisclosed>
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	75 48                	jne    80170d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016c5:	e8 ba f4 ff ff       	call   800b84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8016cd:	8b 0b                	mov    (%ebx),%ecx
  8016cf:	8d 51 20             	lea    0x20(%ecx),%edx
  8016d2:	39 d0                	cmp    %edx,%eax
  8016d4:	73 e2                	jae    8016b8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016dd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	c1 fa 1f             	sar    $0x1f,%edx
  8016e5:	89 d1                	mov    %edx,%ecx
  8016e7:	c1 e9 1b             	shr    $0x1b,%ecx
  8016ea:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016ed:	83 e2 1f             	and    $0x1f,%edx
  8016f0:	29 ca                	sub    %ecx,%edx
  8016f2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016fa:	83 c0 01             	add    $0x1,%eax
  8016fd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801700:	83 c7 01             	add    $0x1,%edi
  801703:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801706:	75 c2                	jne    8016ca <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801708:	8b 45 10             	mov    0x10(%ebp),%eax
  80170b:	eb 05                	jmp    801712 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5f                   	pop    %edi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	57                   	push   %edi
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	83 ec 18             	sub    $0x18,%esp
  801723:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801726:	57                   	push   %edi
  801727:	e8 97 f6 ff ff       	call   800dc3 <fd2data>
  80172c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	bb 00 00 00 00       	mov    $0x0,%ebx
  801736:	eb 3d                	jmp    801775 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801738:	85 db                	test   %ebx,%ebx
  80173a:	74 04                	je     801740 <devpipe_read+0x26>
				return i;
  80173c:	89 d8                	mov    %ebx,%eax
  80173e:	eb 44                	jmp    801784 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801740:	89 f2                	mov    %esi,%edx
  801742:	89 f8                	mov    %edi,%eax
  801744:	e8 f2 fe ff ff       	call   80163b <_pipeisclosed>
  801749:	85 c0                	test   %eax,%eax
  80174b:	75 32                	jne    80177f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80174d:	e8 32 f4 ff ff       	call   800b84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801752:	8b 06                	mov    (%esi),%eax
  801754:	3b 46 04             	cmp    0x4(%esi),%eax
  801757:	74 df                	je     801738 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801759:	99                   	cltd   
  80175a:	c1 ea 1b             	shr    $0x1b,%edx
  80175d:	01 d0                	add    %edx,%eax
  80175f:	83 e0 1f             	and    $0x1f,%eax
  801762:	29 d0                	sub    %edx,%eax
  801764:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80176f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801772:	83 c3 01             	add    $0x1,%ebx
  801775:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801778:	75 d8                	jne    801752 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80177a:	8b 45 10             	mov    0x10(%ebp),%eax
  80177d:	eb 05                	jmp    801784 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801784:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801794:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	e8 3d f6 ff ff       	call   800dda <fd_alloc>
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	89 c2                	mov    %eax,%edx
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	0f 88 2c 01 00 00    	js     8018d6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	68 07 04 00 00       	push   $0x407
  8017b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b5:	6a 00                	push   $0x0
  8017b7:	e8 e7 f3 ff ff       	call   800ba3 <sys_page_alloc>
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	0f 88 0d 01 00 00    	js     8018d6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cf:	50                   	push   %eax
  8017d0:	e8 05 f6 ff ff       	call   800dda <fd_alloc>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	0f 88 e2 00 00 00    	js     8018c4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	68 07 04 00 00       	push   $0x407
  8017ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 af f3 ff ff       	call   800ba3 <sys_page_alloc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	0f 88 c3 00 00 00    	js     8018c4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	ff 75 f4             	pushl  -0xc(%ebp)
  801807:	e8 b7 f5 ff ff       	call   800dc3 <fd2data>
  80180c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180e:	83 c4 0c             	add    $0xc,%esp
  801811:	68 07 04 00 00       	push   $0x407
  801816:	50                   	push   %eax
  801817:	6a 00                	push   $0x0
  801819:	e8 85 f3 ff ff       	call   800ba3 <sys_page_alloc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 88 89 00 00 00    	js     8018b4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	ff 75 f0             	pushl  -0x10(%ebp)
  801831:	e8 8d f5 ff ff       	call   800dc3 <fd2data>
  801836:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80183d:	50                   	push   %eax
  80183e:	6a 00                	push   $0x0
  801840:	56                   	push   %esi
  801841:	6a 00                	push   $0x0
  801843:	e8 9e f3 ff ff       	call   800be6 <sys_page_map>
  801848:	89 c3                	mov    %eax,%ebx
  80184a:	83 c4 20             	add    $0x20,%esp
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 55                	js     8018a6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801851:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801866:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80186c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801874:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	e8 2d f5 ff ff       	call   800db3 <fd2num>
  801886:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801889:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80188b:	83 c4 04             	add    $0x4,%esp
  80188e:	ff 75 f0             	pushl  -0x10(%ebp)
  801891:	e8 1d f5 ff ff       	call   800db3 <fd2num>
  801896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801899:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	eb 30                	jmp    8018d6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	56                   	push   %esi
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 77 f3 ff ff       	call   800c28 <sys_page_unmap>
  8018b1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ba:	6a 00                	push   $0x0
  8018bc:	e8 67 f3 ff ff       	call   800c28 <sys_page_unmap>
  8018c1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	6a 00                	push   $0x0
  8018cc:	e8 57 f3 ff ff       	call   800c28 <sys_page_unmap>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018d6:	89 d0                	mov    %edx,%eax
  8018d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	ff 75 08             	pushl  0x8(%ebp)
  8018ec:	e8 38 f5 ff ff       	call   800e29 <fd_lookup>
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	85 d2                	test   %edx,%edx
  8018f8:	78 18                	js     801912 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801900:	e8 be f4 ff ff       	call   800dc3 <fd2data>
	return _pipeisclosed(fd, p);
  801905:	89 c2                	mov    %eax,%edx
  801907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190a:	e8 2c fd ff ff       	call   80163b <_pipeisclosed>
  80190f:	83 c4 10             	add    $0x10,%esp
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801924:	68 cc 23 80 00       	push   $0x8023cc
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	e8 68 ee ff ff       	call   800799 <strcpy>
	return 0;
}
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801944:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801949:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194f:	eb 2e                	jmp    80197f <devcons_write+0x47>
		m = n - tot;
  801951:	8b 55 10             	mov    0x10(%ebp),%edx
  801954:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801956:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  80195b:	83 fa 7f             	cmp    $0x7f,%edx
  80195e:	77 02                	ja     801962 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801960:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	56                   	push   %esi
  801966:	03 45 0c             	add    0xc(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	57                   	push   %edi
  80196b:	e8 bb ef ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801970:	83 c4 08             	add    $0x8,%esp
  801973:	56                   	push   %esi
  801974:	57                   	push   %edi
  801975:	e8 6d f1 ff ff       	call   800ae7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80197a:	01 f3                	add    %esi,%ebx
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	89 d8                	mov    %ebx,%eax
  801981:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801984:	72 cb                	jb     801951 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5f                   	pop    %edi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801999:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80199d:	75 07                	jne    8019a6 <devcons_read+0x18>
  80199f:	eb 28                	jmp    8019c9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019a1:	e8 de f1 ff ff       	call   800b84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019a6:	e8 5a f1 ff ff       	call   800b05 <sys_cgetc>
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	74 f2                	je     8019a1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 16                	js     8019c9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019b3:	83 f8 04             	cmp    $0x4,%eax
  8019b6:	74 0c                	je     8019c4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019bb:	88 02                	mov    %al,(%edx)
	return 1;
  8019bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c2:	eb 05                	jmp    8019c9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019d7:	6a 01                	push   $0x1
  8019d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019dc:	50                   	push   %eax
  8019dd:	e8 05 f1 ff ff       	call   800ae7 <sys_cputs>
  8019e2:	83 c4 10             	add    $0x10,%esp
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <getchar>:

int
getchar(void)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019ed:	6a 01                	push   $0x1
  8019ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 98 f6 ff ff       	call   801092 <read>
	if (r < 0)
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 0f                	js     801a10 <getchar+0x29>
		return r;
	if (r < 1)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	7e 06                	jle    801a0b <getchar+0x24>
		return -E_EOF;
	return c;
  801a05:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a09:	eb 05                	jmp    801a10 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a0b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	e8 05 f4 ff ff       	call   800e29 <fd_lookup>
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 11                	js     801a3c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a34:	39 10                	cmp    %edx,(%eax)
  801a36:	0f 94 c0             	sete   %al
  801a39:	0f b6 c0             	movzbl %al,%eax
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <opencons>:

int
opencons(void)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a47:	50                   	push   %eax
  801a48:	e8 8d f3 ff ff       	call   800dda <fd_alloc>
  801a4d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a50:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 3e                	js     801a94 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a56:	83 ec 04             	sub    $0x4,%esp
  801a59:	68 07 04 00 00       	push   $0x407
  801a5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a61:	6a 00                	push   $0x0
  801a63:	e8 3b f1 ff ff       	call   800ba3 <sys_page_alloc>
  801a68:	83 c4 10             	add    $0x10,%esp
		return r;
  801a6b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 23                	js     801a94 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a71:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	50                   	push   %eax
  801a8a:	e8 24 f3 ff ff       	call   800db3 <fd2num>
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	83 c4 10             	add    $0x10,%esp
}
  801a94:	89 d0                	mov    %edx,%eax
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801aa6:	85 f6                	test   %esi,%esi
  801aa8:	74 06                	je     801ab0 <ipc_recv+0x18>
  801aaa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801ab0:	85 db                	test   %ebx,%ebx
  801ab2:	74 06                	je     801aba <ipc_recv+0x22>
  801ab4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801aba:	83 f8 01             	cmp    $0x1,%eax
  801abd:	19 d2                	sbb    %edx,%edx
  801abf:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	50                   	push   %eax
  801ac5:	e8 89 f2 ff ff       	call   800d53 <sys_ipc_recv>
  801aca:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 d2                	test   %edx,%edx
  801ad1:	75 24                	jne    801af7 <ipc_recv+0x5f>
	if (from_env_store)
  801ad3:	85 f6                	test   %esi,%esi
  801ad5:	74 0a                	je     801ae1 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801ad7:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801adc:	8b 40 70             	mov    0x70(%eax),%eax
  801adf:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801ae1:	85 db                	test   %ebx,%ebx
  801ae3:	74 0a                	je     801aef <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801ae5:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801aea:	8b 40 74             	mov    0x74(%eax),%eax
  801aed:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801aef:	a1 40 40 c0 00       	mov    0xc04040,%eax
  801af4:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b10:	83 fb 01             	cmp    $0x1,%ebx
  801b13:	19 c0                	sbb    %eax,%eax
  801b15:	09 c3                	or     %eax,%ebx
  801b17:	eb 1c                	jmp    801b35 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b19:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1c:	74 12                	je     801b30 <ipc_send+0x32>
  801b1e:	50                   	push   %eax
  801b1f:	68 d8 23 80 00       	push   $0x8023d8
  801b24:	6a 36                	push   $0x36
  801b26:	68 ef 23 80 00       	push   $0x8023ef
  801b2b:	e8 0c e6 ff ff       	call   80013c <_panic>
		sys_yield();
  801b30:	e8 4f f0 ff ff       	call   800b84 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b35:	ff 75 14             	pushl  0x14(%ebp)
  801b38:	53                   	push   %ebx
  801b39:	56                   	push   %esi
  801b3a:	57                   	push   %edi
  801b3b:	e8 f0 f1 ff ff       	call   800d30 <sys_ipc_try_send>
		if (ret == 0) break;
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	75 d2                	jne    801b19 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5e                   	pop    %esi
  801b4c:	5f                   	pop    %edi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b5a:	6b d0 78             	imul   $0x78,%eax,%edx
  801b5d:	83 c2 50             	add    $0x50,%edx
  801b60:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801b66:	39 ca                	cmp    %ecx,%edx
  801b68:	75 0d                	jne    801b77 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b6a:	6b c0 78             	imul   $0x78,%eax,%eax
  801b6d:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b72:	8b 40 08             	mov    0x8(%eax),%eax
  801b75:	eb 0e                	jmp    801b85 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b77:	83 c0 01             	add    $0x1,%eax
  801b7a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b7f:	75 d9                	jne    801b5a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b81:	66 b8 00 00          	mov    $0x0,%ax
}
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8d:	89 d0                	mov    %edx,%eax
  801b8f:	c1 e8 16             	shr    $0x16,%eax
  801b92:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9e:	f6 c1 01             	test   $0x1,%cl
  801ba1:	74 1d                	je     801bc0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba3:	c1 ea 0c             	shr    $0xc,%edx
  801ba6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bad:	f6 c2 01             	test   $0x1,%dl
  801bb0:	74 0e                	je     801bc0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb2:	c1 ea 0c             	shr    $0xc,%edx
  801bb5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bbc:	ef 
  801bbd:	0f b7 c0             	movzwl %ax,%eax
}
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
  801bc2:	66 90                	xchg   %ax,%ax
  801bc4:	66 90                	xchg   %ax,%ax
  801bc6:	66 90                	xchg   %ax,%ax
  801bc8:	66 90                	xchg   %ax,%ax
  801bca:	66 90                	xchg   %ax,%ax
  801bcc:	66 90                	xchg   %ax,%ax
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	83 ec 10             	sub    $0x10,%esp
  801bd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bda:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bde:	8b 74 24 24          	mov    0x24(%esp),%esi
  801be2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801be6:	85 d2                	test   %edx,%edx
  801be8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bec:	89 34 24             	mov    %esi,(%esp)
  801bef:	89 c8                	mov    %ecx,%eax
  801bf1:	75 35                	jne    801c28 <__udivdi3+0x58>
  801bf3:	39 f1                	cmp    %esi,%ecx
  801bf5:	0f 87 bd 00 00 00    	ja     801cb8 <__udivdi3+0xe8>
  801bfb:	85 c9                	test   %ecx,%ecx
  801bfd:	89 cd                	mov    %ecx,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f1                	div    %ecx
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 f0                	mov    %esi,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c6                	mov    %eax,%esi
  801c14:	89 f8                	mov    %edi,%eax
  801c16:	f7 f5                	div    %ebp
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    
  801c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c28:	3b 14 24             	cmp    (%esp),%edx
  801c2b:	77 7b                	ja     801ca8 <__udivdi3+0xd8>
  801c2d:	0f bd f2             	bsr    %edx,%esi
  801c30:	83 f6 1f             	xor    $0x1f,%esi
  801c33:	0f 84 97 00 00 00    	je     801cd0 <__udivdi3+0x100>
  801c39:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c3e:	89 d7                	mov    %edx,%edi
  801c40:	89 f1                	mov    %esi,%ecx
  801c42:	29 f5                	sub    %esi,%ebp
  801c44:	d3 e7                	shl    %cl,%edi
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	89 e9                	mov    %ebp,%ecx
  801c4a:	d3 ea                	shr    %cl,%edx
  801c4c:	89 f1                	mov    %esi,%ecx
  801c4e:	09 fa                	or     %edi,%edx
  801c50:	8b 3c 24             	mov    (%esp),%edi
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c59:	89 e9                	mov    %ebp,%ecx
  801c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c63:	89 fa                	mov    %edi,%edx
  801c65:	d3 ea                	shr    %cl,%edx
  801c67:	89 f1                	mov    %esi,%ecx
  801c69:	d3 e7                	shl    %cl,%edi
  801c6b:	89 e9                	mov    %ebp,%ecx
  801c6d:	d3 e8                	shr    %cl,%eax
  801c6f:	09 c7                	or     %eax,%edi
  801c71:	89 f8                	mov    %edi,%eax
  801c73:	f7 74 24 08          	divl   0x8(%esp)
  801c77:	89 d5                	mov    %edx,%ebp
  801c79:	89 c7                	mov    %eax,%edi
  801c7b:	f7 64 24 0c          	mull   0xc(%esp)
  801c7f:	39 d5                	cmp    %edx,%ebp
  801c81:	89 14 24             	mov    %edx,(%esp)
  801c84:	72 11                	jb     801c97 <__udivdi3+0xc7>
  801c86:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c8a:	89 f1                	mov    %esi,%ecx
  801c8c:	d3 e2                	shl    %cl,%edx
  801c8e:	39 c2                	cmp    %eax,%edx
  801c90:	73 5e                	jae    801cf0 <__udivdi3+0x120>
  801c92:	3b 2c 24             	cmp    (%esp),%ebp
  801c95:	75 59                	jne    801cf0 <__udivdi3+0x120>
  801c97:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c9a:	31 f6                	xor    %esi,%esi
  801c9c:	89 f2                	mov    %esi,%edx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	31 f6                	xor    %esi,%esi
  801caa:	31 c0                	xor    %eax,%eax
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	31 f6                	xor    %esi,%esi
  801cbc:	89 f8                	mov    %edi,%eax
  801cbe:	f7 f1                	div    %ecx
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801cd4:	76 0b                	jbe    801ce1 <__udivdi3+0x111>
  801cd6:	31 c0                	xor    %eax,%eax
  801cd8:	3b 14 24             	cmp    (%esp),%edx
  801cdb:	0f 83 37 ff ff ff    	jae    801c18 <__udivdi3+0x48>
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	e9 2d ff ff ff       	jmp    801c18 <__udivdi3+0x48>
  801ceb:	90                   	nop
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 f8                	mov    %edi,%eax
  801cf2:	31 f6                	xor    %esi,%esi
  801cf4:	e9 1f ff ff ff       	jmp    801c18 <__udivdi3+0x48>
  801cf9:	66 90                	xchg   %ax,%ax
  801cfb:	66 90                	xchg   %ax,%ax
  801cfd:	66 90                	xchg   %ax,%ax
  801cff:	90                   	nop

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	83 ec 20             	sub    $0x20,%esp
  801d06:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d12:	89 c6                	mov    %eax,%esi
  801d14:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d28:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	89 c2                	mov    %eax,%edx
  801d30:	75 1e                	jne    801d50 <__umoddi3+0x50>
  801d32:	39 f7                	cmp    %esi,%edi
  801d34:	76 52                	jbe    801d88 <__umoddi3+0x88>
  801d36:	89 c8                	mov    %ecx,%eax
  801d38:	89 f2                	mov    %esi,%edx
  801d3a:	f7 f7                	div    %edi
  801d3c:	89 d0                	mov    %edx,%eax
  801d3e:	31 d2                	xor    %edx,%edx
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    
  801d47:	89 f6                	mov    %esi,%esi
  801d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d50:	39 f0                	cmp    %esi,%eax
  801d52:	77 5c                	ja     801db0 <__umoddi3+0xb0>
  801d54:	0f bd e8             	bsr    %eax,%ebp
  801d57:	83 f5 1f             	xor    $0x1f,%ebp
  801d5a:	75 64                	jne    801dc0 <__umoddi3+0xc0>
  801d5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d64:	0f 86 f6 00 00 00    	jbe    801e60 <__umoddi3+0x160>
  801d6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d6e:	0f 82 ec 00 00 00    	jb     801e60 <__umoddi3+0x160>
  801d74:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d78:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d7c:	83 c4 20             	add    $0x20,%esp
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 fd                	mov    %edi,%ebp
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0x99>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d9d:	31 d2                	xor    %edx,%edx
  801d9f:	f7 f5                	div    %ebp
  801da1:	89 c8                	mov    %ecx,%eax
  801da3:	f7 f5                	div    %ebp
  801da5:	eb 95                	jmp    801d3c <__umoddi3+0x3c>
  801da7:	89 f6                	mov    %esi,%esi
  801da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 20             	add    $0x20,%esp
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc5:	89 e9                	mov    %ebp,%ecx
  801dc7:	29 e8                	sub    %ebp,%eax
  801dc9:	d3 e2                	shl    %cl,%edx
  801dcb:	89 c7                	mov    %eax,%edi
  801dcd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801dd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 c1                	mov    %eax,%ecx
  801ddb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ddf:	09 d1                	or     %edx,%ecx
  801de1:	89 fa                	mov    %edi,%edx
  801de3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801de7:	89 e9                	mov    %ebp,%ecx
  801de9:	d3 e0                	shl    %cl,%eax
  801deb:	89 f9                	mov    %edi,%ecx
  801ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	d3 e8                	shr    %cl,%eax
  801df5:	89 e9                	mov    %ebp,%ecx
  801df7:	89 c7                	mov    %eax,%edi
  801df9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dfd:	d3 e6                	shl    %cl,%esi
  801dff:	89 d1                	mov    %edx,%ecx
  801e01:	89 fa                	mov    %edi,%edx
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	09 f0                	or     %esi,%eax
  801e09:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e0d:	f7 74 24 10          	divl   0x10(%esp)
  801e11:	d3 e6                	shl    %cl,%esi
  801e13:	89 d1                	mov    %edx,%ecx
  801e15:	f7 64 24 0c          	mull   0xc(%esp)
  801e19:	39 d1                	cmp    %edx,%ecx
  801e1b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e1f:	89 d7                	mov    %edx,%edi
  801e21:	89 c6                	mov    %eax,%esi
  801e23:	72 0a                	jb     801e2f <__umoddi3+0x12f>
  801e25:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e29:	73 10                	jae    801e3b <__umoddi3+0x13b>
  801e2b:	39 d1                	cmp    %edx,%ecx
  801e2d:	75 0c                	jne    801e3b <__umoddi3+0x13b>
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e37:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e3b:	89 ca                	mov    %ecx,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e43:	29 f0                	sub    %esi,%eax
  801e45:	19 fa                	sbb    %edi,%edx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e4e:	89 d7                	mov    %edx,%edi
  801e50:	d3 e7                	shl    %cl,%edi
  801e52:	89 e9                	mov    %ebp,%ecx
  801e54:	09 f8                	or     %edi,%eax
  801e56:	d3 ea                	shr    %cl,%edx
  801e58:	83 c4 20             	add    $0x20,%esp
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    
  801e5f:	90                   	nop
  801e60:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e64:	29 f9                	sub    %edi,%ecx
  801e66:	19 c6                	sbb    %eax,%esi
  801e68:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e6c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e70:	e9 ff fe ff ff       	jmp    801d74 <__umoddi3+0x74>
