
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 a4 0a 00 00       	call   800ae4 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 78 	cmpl   $0xeec00078,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 d4 0c 00 00       	call   800d32 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 40 1e 80 00       	push   $0x801e40
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
		}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c0 00 c0 ee       	mov    0xeec000c0,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 51 1e 80 00       	push   $0x801e51
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c0 00 c0 ee       	mov    0xeec000c0,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 fc 0c 00 00       	call   800d98 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ac:	e8 33 0a 00 00       	call   800ae4 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 78             	imul   $0x78,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
  8000dd:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 fb 0e 00 00       	call   800fed <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a7 09 00 00       	call   800aa3 <sys_env_destroy>
  8000fc:	83 c4 10             	add    $0x10,%esp
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 35 09 00 00       	call   800a66 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 4f 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 da 08 00 00       	call   800a66 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 d1                	mov    %edx,%ecx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d3:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001d6:	72 05                	jb     8001dd <printnum+0x35>
  8001d8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001db:	77 3e                	ja     80021b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	50                   	push   %eax
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 94 19 00 00       	call   801b90 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022c:	ff 75 e0             	pushl  -0x20(%ebp)
  80022f:	ff 75 dc             	pushl  -0x24(%ebp)
  800232:	ff 75 d8             	pushl  -0x28(%ebp)
  800235:	e8 86 1a 00 00       	call   801cc0 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 72 1e 80 00 	movsbl 0x801e72(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
  800247:	83 c4 10             	add    $0x10,%esp
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800255:	83 fa 01             	cmp    $0x1,%edx
  800258:	7e 0e                	jle    800268 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	8b 52 04             	mov    0x4(%edx),%edx
  800266:	eb 22                	jmp    80028a <getuint+0x38>
	else if (lflag)
  800268:	85 d2                	test   %edx,%edx
  80026a:	74 10                	je     80027c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	eb 0e                	jmp    80028a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800296:	8b 10                	mov    (%eax),%edx
  800298:	3b 50 04             	cmp    0x4(%eax),%edx
  80029b:	73 0a                	jae    8002a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	88 02                	mov    %al,(%edx)
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 10             	pushl  0x10(%ebp)
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	e8 05 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
  8002c1:	83 c4 10             	add    $0x10,%esp
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
  8002cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d8:	eb 12                	jmp    8002ec <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	0f 84 8d 03 00 00    	je     80066f <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	53                   	push   %ebx
  8002e6:	50                   	push   %eax
  8002e7:	ff d6                	call   *%esi
  8002e9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ec:	83 c7 01             	add    $0x1,%edi
  8002ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f3:	83 f8 25             	cmp    $0x25,%eax
  8002f6:	75 e2                	jne    8002da <vprintfmt+0x14>
  8002f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800303:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 07                	jmp    80031f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8d 47 01             	lea    0x1(%edi),%eax
  800322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800325:	0f b6 07             	movzbl (%edi),%eax
  800328:	0f b6 c8             	movzbl %al,%ecx
  80032b:	83 e8 23             	sub    $0x23,%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 1e 03 00 00    	ja     800654 <vprintfmt+0x38e>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800343:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800347:	eb d6                	jmp    80031f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034c:	b8 00 00 00 00       	mov    $0x0,%eax
  800351:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800354:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800357:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80035b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800361:	83 fa 09             	cmp    $0x9,%edx
  800364:	77 38                	ja     80039e <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800366:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800369:	eb e9                	jmp    800354 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036b:	8b 45 14             	mov    0x14(%ebp),%eax
  80036e:	8d 48 04             	lea    0x4(%eax),%ecx
  800371:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800374:	8b 00                	mov    (%eax),%eax
  800376:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037c:	eb 26                	jmp    8003a4 <vprintfmt+0xde>
  80037e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800381:	89 c8                	mov    %ecx,%eax
  800383:	c1 f8 1f             	sar    $0x1f,%eax
  800386:	f7 d0                	not    %eax
  800388:	21 c1                	and    %eax,%ecx
  80038a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800390:	eb 8d                	jmp    80031f <vprintfmt+0x59>
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800395:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039c:	eb 81                	jmp    80031f <vprintfmt+0x59>
  80039e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	0f 89 71 ff ff ff    	jns    80031f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003bb:	e9 5f ff ff ff       	jmp    80031f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c6:	e9 54 ff ff ff       	jmp    80031f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	53                   	push   %ebx
  8003d8:	ff 30                	pushl  (%eax)
  8003da:	ff d6                	call   *%esi
			break;
  8003dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e2:	e9 05 ff ff ff       	jmp    8002ec <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 50 04             	lea    0x4(%eax),%edx
  8003ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	99                   	cltd   
  8003f3:	31 d0                	xor    %edx,%eax
  8003f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f7:	83 f8 0f             	cmp    $0xf,%eax
  8003fa:	7f 0b                	jg     800407 <vprintfmt+0x141>
  8003fc:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800403:	85 d2                	test   %edx,%edx
  800405:	75 18                	jne    80041f <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800407:	50                   	push   %eax
  800408:	68 8a 1e 80 00       	push   $0x801e8a
  80040d:	53                   	push   %ebx
  80040e:	56                   	push   %esi
  80040f:	e8 95 fe ff ff       	call   8002a9 <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041a:	e9 cd fe ff ff       	jmp    8002ec <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041f:	52                   	push   %edx
  800420:	68 91 22 80 00       	push   $0x802291
  800425:	53                   	push   %ebx
  800426:	56                   	push   %esi
  800427:	e8 7d fe ff ff       	call   8002a9 <printfmt>
  80042c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800432:	e9 b5 fe ff ff       	jmp    8002ec <vprintfmt+0x26>
  800437:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80043a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
  80044b:	85 ff                	test   %edi,%edi
  80044d:	75 05                	jne    800454 <vprintfmt+0x18e>
				p = "(null)";
  80044f:	bf 83 1e 80 00       	mov    $0x801e83,%edi
			if (width > 0 && padc != '-')
  800454:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800458:	0f 84 91 00 00 00    	je     8004ef <vprintfmt+0x229>
  80045e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800462:	0f 8e 95 00 00 00    	jle    8004fd <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	51                   	push   %ecx
  80046c:	57                   	push   %edi
  80046d:	e8 85 02 00 00       	call   8006f7 <strnlen>
  800472:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1d4>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c5>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	89 c8                	mov    %ecx,%eax
  8004a6:	c1 f8 1f             	sar    $0x1f,%eax
  8004a9:	f7 d0                	not    %eax
  8004ab:	21 c8                	and    %ecx,%eax
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	89 cb                	mov    %ecx,%ebx
  8004ba:	eb 4d                	jmp    800509 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c0:	74 1b                	je     8004dd <vprintfmt+0x217>
  8004c2:	0f be c0             	movsbl %al,%eax
  8004c5:	83 e8 20             	sub    $0x20,%eax
  8004c8:	83 f8 5e             	cmp    $0x5e,%eax
  8004cb:	76 10                	jbe    8004dd <vprintfmt+0x217>
					putch('?', putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	6a 3f                	push   $0x3f
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	eb 0d                	jmp    8004ea <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	52                   	push   %edx
  8004e4:	ff 55 08             	call   *0x8(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	eb 1a                	jmp    800509 <vprintfmt+0x243>
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fb:	eb 0c                	jmp    800509 <vprintfmt+0x243>
  8004fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800506:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800509:	83 c7 01             	add    $0x1,%edi
  80050c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800510:	0f be d0             	movsbl %al,%edx
  800513:	85 d2                	test   %edx,%edx
  800515:	74 23                	je     80053a <vprintfmt+0x274>
  800517:	85 f6                	test   %esi,%esi
  800519:	78 a1                	js     8004bc <vprintfmt+0x1f6>
  80051b:	83 ee 01             	sub    $0x1,%esi
  80051e:	79 9c                	jns    8004bc <vprintfmt+0x1f6>
  800520:	89 df                	mov    %ebx,%edi
  800522:	8b 75 08             	mov    0x8(%ebp),%esi
  800525:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800528:	eb 18                	jmp    800542 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	6a 20                	push   $0x20
  800530:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800532:	83 ef 01             	sub    $0x1,%edi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 08                	jmp    800542 <vprintfmt+0x27c>
  80053a:	89 df                	mov    %ebx,%edi
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800542:	85 ff                	test   %edi,%edi
  800544:	7f e4                	jg     80052a <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800549:	e9 9e fd ff ff       	jmp    8002ec <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054e:	83 fa 01             	cmp    $0x1,%edx
  800551:	7e 16                	jle    800569 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 08             	lea    0x8(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	8b 50 04             	mov    0x4(%eax),%edx
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	eb 32                	jmp    80059b <vprintfmt+0x2d5>
	else if (lflag)
  800569:	85 d2                	test   %edx,%edx
  80056b:	74 18                	je     800585 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 c1                	mov    %eax,%ecx
  80057d:	c1 f9 1f             	sar    $0x1f,%ecx
  800580:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800583:	eb 16                	jmp    80059b <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 c1                	mov    %eax,%ecx
  800595:	c1 f9 1f             	sar    $0x1f,%ecx
  800598:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005aa:	79 74                	jns    800620 <vprintfmt+0x35a>
				putch('-', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 2d                	push   $0x2d
  8005b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ba:	f7 d8                	neg    %eax
  8005bc:	83 d2 00             	adc    $0x0,%edx
  8005bf:	f7 da                	neg    %edx
  8005c1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c9:	eb 55                	jmp    800620 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 7f fc ff ff       	call   800252 <getuint>
			base = 10;
  8005d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d8:	eb 46                	jmp    800620 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 70 fc ff ff       	call   800252 <getuint>
			base = 8;
  8005e2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e7:	eb 37                	jmp    800620 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 30                	push   $0x30
  8005ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 37 fc ff ff       	call   800252 <getuint>
			base = 16;
  80061b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800620:	83 ec 0c             	sub    $0xc,%esp
  800623:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800627:	57                   	push   %edi
  800628:	ff 75 e0             	pushl  -0x20(%ebp)
  80062b:	51                   	push   %ecx
  80062c:	52                   	push   %edx
  80062d:	50                   	push   %eax
  80062e:	89 da                	mov    %ebx,%edx
  800630:	89 f0                	mov    %esi,%eax
  800632:	e8 71 fb ff ff       	call   8001a8 <printnum>
			break;
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063d:	e9 aa fc ff ff       	jmp    8002ec <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	51                   	push   %ecx
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064f:	e9 98 fc ff ff       	jmp    8002ec <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 25                	push   $0x25
  80065a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 03                	jmp    800664 <vprintfmt+0x39e>
  800661:	83 ef 01             	sub    $0x1,%edi
  800664:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800668:	75 f7                	jne    800661 <vprintfmt+0x39b>
  80066a:	e9 7d fc ff ff       	jmp    8002ec <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 18             	sub    $0x18,%esp
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800694:	85 c0                	test   %eax,%eax
  800696:	74 26                	je     8006be <vsnprintf+0x47>
  800698:	85 d2                	test   %edx,%edx
  80069a:	7e 22                	jle    8006be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069c:	ff 75 14             	pushl  0x14(%ebp)
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	68 8c 02 80 00       	push   $0x80028c
  8006ab:	e8 16 fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 05                	jmp    8006c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	ff 75 08             	pushl  0x8(%ebp)
  8006d8:	e8 9a ff ff ff       	call   800677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	eb 03                	jmp    8006ef <strlen+0x10>
		n++;
  8006ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f3:	75 f7                	jne    8006ec <strlen+0xd>
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	ba 00 00 00 00       	mov    $0x0,%edx
  800705:	eb 03                	jmp    80070a <strnlen+0x13>
		n++;
  800707:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	39 c2                	cmp    %eax,%edx
  80070c:	74 08                	je     800716 <strnlen+0x1f>
  80070e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800712:	75 f3                	jne    800707 <strnlen+0x10>
  800714:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800722:	89 c2                	mov    %eax,%edx
  800724:	83 c2 01             	add    $0x1,%edx
  800727:	83 c1 01             	add    $0x1,%ecx
  80072a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800731:	84 db                	test   %bl,%bl
  800733:	75 ef                	jne    800724 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073f:	53                   	push   %ebx
  800740:	e8 9a ff ff ff       	call   8006df <strlen>
  800745:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	01 d8                	add    %ebx,%eax
  80074d:	50                   	push   %eax
  80074e:	e8 c5 ff ff ff       	call   800718 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800765:	89 f3                	mov    %esi,%ebx
  800767:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076a:	89 f2                	mov    %esi,%edx
  80076c:	eb 0f                	jmp    80077d <strncpy+0x23>
		*dst++ = *src;
  80076e:	83 c2 01             	add    $0x1,%edx
  800771:	0f b6 01             	movzbl (%ecx),%eax
  800774:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800777:	80 39 01             	cmpb   $0x1,(%ecx)
  80077a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077d:	39 da                	cmp    %ebx,%edx
  80077f:	75 ed                	jne    80076e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800781:	89 f0                	mov    %esi,%eax
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	8b 55 10             	mov    0x10(%ebp),%edx
  800795:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800797:	85 d2                	test   %edx,%edx
  800799:	74 21                	je     8007bc <strlcpy+0x35>
  80079b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079f:	89 f2                	mov    %esi,%edx
  8007a1:	eb 09                	jmp    8007ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 09                	je     8007b9 <strlcpy+0x32>
  8007b0:	0f b6 19             	movzbl (%ecx),%ebx
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ec                	jne    8007a3 <strlcpy+0x1c>
  8007b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 06                	jmp    8007d3 <strcmp+0x11>
		p++, q++;
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d3:	0f b6 01             	movzbl (%ecx),%eax
  8007d6:	84 c0                	test   %al,%al
  8007d8:	74 04                	je     8007de <strcmp+0x1c>
  8007da:	3a 02                	cmp    (%edx),%al
  8007dc:	74 ef                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007de:	0f b6 c0             	movzbl %al,%eax
  8007e1:	0f b6 12             	movzbl (%edx),%edx
  8007e4:	29 d0                	sub    %edx,%eax
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strncmp+0x17>
		n--, p++, q++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	74 15                	je     800818 <strncmp+0x30>
  800803:	0f b6 08             	movzbl (%eax),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 04                	je     80080e <strncmp+0x26>
  80080a:	3a 0a                	cmp    (%edx),%cl
  80080c:	74 eb                	je     8007f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 00             	movzbl (%eax),%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
  800816:	eb 05                	jmp    80081d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082a:	eb 07                	jmp    800833 <strchr+0x13>
		if (*s == c)
  80082c:	38 ca                	cmp    %cl,%dl
  80082e:	74 0f                	je     80083f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	0f b6 10             	movzbl (%eax),%edx
  800836:	84 d2                	test   %dl,%dl
  800838:	75 f2                	jne    80082c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 03                	jmp    800850 <strfind+0xf>
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800853:	84 d2                	test   %dl,%dl
  800855:	74 04                	je     80085b <strfind+0x1a>
  800857:	38 ca                	cmp    %cl,%dl
  800859:	75 f2                	jne    80084d <strfind+0xc>
			break;
	return (char *) s;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 36                	je     8008a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800873:	75 28                	jne    80089d <memset+0x40>
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 23                	jne    80089d <memset+0x40>
		c &= 0xFF;
  80087a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087e:	89 d3                	mov    %edx,%ebx
  800880:	c1 e3 08             	shl    $0x8,%ebx
  800883:	89 d6                	mov    %edx,%esi
  800885:	c1 e6 18             	shl    $0x18,%esi
  800888:	89 d0                	mov    %edx,%eax
  80088a:	c1 e0 10             	shl    $0x10,%eax
  80088d:	09 f0                	or     %esi,%eax
  80088f:	09 c2                	or     %eax,%edx
  800891:	89 d0                	mov    %edx,%eax
  800893:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800895:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800898:	fc                   	cld    
  800899:	f3 ab                	rep stos %eax,%es:(%edi)
  80089b:	eb 06                	jmp    8008a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	fc                   	cld    
  8008a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a3:	89 f8                	mov    %edi,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b8:	39 c6                	cmp    %eax,%esi
  8008ba:	73 35                	jae    8008f1 <memmove+0x47>
  8008bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	73 2e                	jae    8008f1 <memmove+0x47>
		s += n;
		d += n;
  8008c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 13                	jne    8008e5 <memmove+0x3b>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0e                	jne    8008e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d7:	83 ef 04             	sub    $0x4,%edi
  8008da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008e0:	fd                   	std    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 09                	jmp    8008ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e5:	83 ef 01             	sub    $0x1,%edi
  8008e8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008eb:	fd                   	std    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ee:	fc                   	cld    
  8008ef:	eb 1d                	jmp    80090e <memmove+0x64>
  8008f1:	89 f2                	mov    %esi,%edx
  8008f3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f5:	f6 c2 03             	test   $0x3,%dl
  8008f8:	75 0f                	jne    800909 <memmove+0x5f>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0a                	jne    800909 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 05                	jmp    80090e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800915:	ff 75 10             	pushl  0x10(%ebp)
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 87 ff ff ff       	call   8008aa <memmove>
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 c6                	mov    %eax,%esi
  800932:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800935:	eb 1a                	jmp    800951 <memcmp+0x2c>
		if (*s1 != *s2)
  800937:	0f b6 08             	movzbl (%eax),%ecx
  80093a:	0f b6 1a             	movzbl (%edx),%ebx
  80093d:	38 d9                	cmp    %bl,%cl
  80093f:	74 0a                	je     80094b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c1             	movzbl %cl,%eax
  800944:	0f b6 db             	movzbl %bl,%ebx
  800947:	29 d8                	sub    %ebx,%eax
  800949:	eb 0f                	jmp    80095a <memcmp+0x35>
		s1++, s2++;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800951:	39 f0                	cmp    %esi,%eax
  800953:	75 e2                	jne    800937 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800967:	89 c2                	mov    %eax,%edx
  800969:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096c:	eb 07                	jmp    800975 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	38 08                	cmp    %cl,(%eax)
  800970:	74 07                	je     800979 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	39 d0                	cmp    %edx,%eax
  800977:	72 f5                	jb     80096e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	eb 03                	jmp    80098c <strtol+0x11>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	3c 09                	cmp    $0x9,%al
  800991:	74 f6                	je     800989 <strtol+0xe>
  800993:	3c 20                	cmp    $0x20,%al
  800995:	74 f2                	je     800989 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800997:	3c 2b                	cmp    $0x2b,%al
  800999:	75 0a                	jne    8009a5 <strtol+0x2a>
		s++;
  80099b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 10                	jmp    8009b5 <strtol+0x3a>
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009aa:	3c 2d                	cmp    $0x2d,%al
  8009ac:	75 07                	jne    8009b5 <strtol+0x3a>
		s++, neg = 1;
  8009ae:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009b1:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b5:	85 db                	test   %ebx,%ebx
  8009b7:	0f 94 c0             	sete   %al
  8009ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c0:	75 19                	jne    8009db <strtol+0x60>
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 14                	jne    8009db <strtol+0x60>
  8009c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cb:	0f 85 8a 00 00 00    	jne    800a5b <strtol+0xe0>
		s += 2, base = 16;
  8009d1:	83 c1 02             	add    $0x2,%ecx
  8009d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d9:	eb 16                	jmp    8009f1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009db:	84 c0                	test   %al,%al
  8009dd:	74 12                	je     8009f1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009df:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e7:	75 08                	jne    8009f1 <strtol+0x76>
		s++, base = 8;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f9:	0f b6 11             	movzbl (%ecx),%edx
  8009fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 09             	cmp    $0x9,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x93>
			dig = *s - '0';
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 30             	sub    $0x30,%edx
  800a0c:	eb 22                	jmp    800a30 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 08                	ja     800a20 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 57             	sub    $0x57,%edx
  800a1e:	eb 10                	jmp    800a30 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a23:	89 f3                	mov    %esi,%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 16                	ja     800a40 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a33:	7d 0f                	jge    800a44 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb b9                	jmp    8009f9 <strtol+0x7e>
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	eb 02                	jmp    800a46 <strtol+0xcb>
  800a44:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4a:	74 05                	je     800a51 <strtol+0xd6>
		*endptr = (char *) s;
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a51:	85 ff                	test   %edi,%edi
  800a53:	74 0c                	je     800a61 <strtol+0xe6>
  800a55:	89 d0                	mov    %edx,%eax
  800a57:	f7 d8                	neg    %eax
  800a59:	eb 06                	jmp    800a61 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	84 c0                	test   %al,%al
  800a5d:	75 8a                	jne    8009e9 <strtol+0x6e>
  800a5f:	eb 90                	jmp    8009f1 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	89 c7                	mov    %eax,%edi
  800a7b:	89 c6                	mov    %eax,%esi
  800a7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800a94:	89 d1                	mov    %edx,%ecx
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	89 d7                	mov    %edx,%edi
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 cb                	mov    %ecx,%ebx
  800abb:	89 cf                	mov    %ecx,%edi
  800abd:	89 ce                	mov    %ecx,%esi
  800abf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	7e 17                	jle    800adc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	50                   	push   %eax
  800ac9:	6a 03                	push   $0x3
  800acb:	68 9f 21 80 00       	push   $0x80219f
  800ad0:	6a 23                	push   $0x23
  800ad2:	68 bc 21 80 00       	push   $0x8021bc
  800ad7:	e8 2a 10 00 00       	call   801b06 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 02 00 00 00       	mov    $0x2,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_yield>:

void
sys_yield(void)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b13:	89 d1                	mov    %edx,%ecx
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	be 00 00 00 00       	mov    $0x0,%esi
  800b30:	b8 04 00 00 00       	mov    $0x4,%eax
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3e:	89 f7                	mov    %esi,%edi
  800b40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b42:	85 c0                	test   %eax,%eax
  800b44:	7e 17                	jle    800b5d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	50                   	push   %eax
  800b4a:	6a 04                	push   $0x4
  800b4c:	68 9f 21 80 00       	push   $0x80219f
  800b51:	6a 23                	push   $0x23
  800b53:	68 bc 21 80 00       	push   $0x8021bc
  800b58:	e8 a9 0f 00 00       	call   801b06 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 05                	push   $0x5
  800b8e:	68 9f 21 80 00       	push   $0x80219f
  800b93:	6a 23                	push   $0x23
  800b95:	68 bc 21 80 00       	push   $0x8021bc
  800b9a:	e8 67 0f 00 00       	call   801b06 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	89 df                	mov    %ebx,%edi
  800bc2:	89 de                	mov    %ebx,%esi
  800bc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 06                	push   $0x6
  800bd0:	68 9f 21 80 00       	push   $0x80219f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 bc 21 80 00       	push   $0x8021bc
  800bdc:	e8 25 0f 00 00       	call   801b06 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	89 df                	mov    %ebx,%edi
  800c04:	89 de                	mov    %ebx,%esi
  800c06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 08                	push   $0x8
  800c12:	68 9f 21 80 00       	push   $0x80219f
  800c17:	6a 23                	push   $0x23
  800c19:	68 bc 21 80 00       	push   $0x8021bc
  800c1e:	e8 e3 0e 00 00       	call   801b06 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 09                	push   $0x9
  800c54:	68 9f 21 80 00       	push   $0x80219f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 bc 21 80 00       	push   $0x8021bc
  800c60:	e8 a1 0e 00 00       	call   801b06 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 0a                	push   $0xa
  800c96:	68 9f 21 80 00       	push   $0x80219f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 bc 21 80 00       	push   $0x8021bc
  800ca2:	e8 5f 0e 00 00       	call   801b06 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	be 00 00 00 00       	mov    $0x0,%esi
  800cba:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 cb                	mov    %ecx,%ebx
  800cea:	89 cf                	mov    %ecx,%edi
  800cec:	89 ce                	mov    %ecx,%esi
  800cee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 0d                	push   $0xd
  800cfa:	68 9f 21 80 00       	push   $0x80219f
  800cff:	6a 23                	push   $0x23
  800d01:	68 bc 21 80 00       	push   $0x8021bc
  800d06:	e8 fb 0d 00 00       	call   801b06 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_gettime>:

int sys_gettime(void)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	89 d7                	mov    %edx,%edi
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  800d40:	85 f6                	test   %esi,%esi
  800d42:	74 06                	je     800d4a <ipc_recv+0x18>
  800d44:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  800d4a:	85 db                	test   %ebx,%ebx
  800d4c:	74 06                	je     800d54 <ipc_recv+0x22>
  800d4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  800d54:	83 f8 01             	cmp    $0x1,%eax
  800d57:	19 d2                	sbb    %edx,%edx
  800d59:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	e8 6e ff ff ff       	call   800cd2 <sys_ipc_recv>
  800d64:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 d2                	test   %edx,%edx
  800d6b:	75 24                	jne    800d91 <ipc_recv+0x5f>
	if (from_env_store)
  800d6d:	85 f6                	test   %esi,%esi
  800d6f:	74 0a                	je     800d7b <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  800d71:	a1 04 40 80 00       	mov    0x804004,%eax
  800d76:	8b 40 70             	mov    0x70(%eax),%eax
  800d79:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  800d7b:	85 db                	test   %ebx,%ebx
  800d7d:	74 0a                	je     800d89 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  800d7f:	a1 04 40 80 00       	mov    0x804004,%eax
  800d84:	8b 40 74             	mov    0x74(%eax),%eax
  800d87:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  800d89:	a1 04 40 80 00       	mov    0x804004,%eax
  800d8e:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  800d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  800daa:	83 fb 01             	cmp    $0x1,%ebx
  800dad:	19 c0                	sbb    %eax,%eax
  800daf:	09 c3                	or     %eax,%ebx
  800db1:	eb 1c                	jmp    800dcf <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  800db3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800db6:	74 12                	je     800dca <ipc_send+0x32>
  800db8:	50                   	push   %eax
  800db9:	68 ca 21 80 00       	push   $0x8021ca
  800dbe:	6a 36                	push   $0x36
  800dc0:	68 e1 21 80 00       	push   $0x8021e1
  800dc5:	e8 3c 0d 00 00       	call   801b06 <_panic>
		sys_yield();
  800dca:	e8 34 fd ff ff       	call   800b03 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  800dcf:	ff 75 14             	pushl  0x14(%ebp)
  800dd2:	53                   	push   %ebx
  800dd3:	56                   	push   %esi
  800dd4:	57                   	push   %edi
  800dd5:	e8 d5 fe ff ff       	call   800caf <sys_ipc_try_send>
		if (ret == 0) break;
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	75 d2                	jne    800db3 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800def:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800df4:	6b d0 78             	imul   $0x78,%eax,%edx
  800df7:	83 c2 50             	add    $0x50,%edx
  800dfa:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  800e00:	39 ca                	cmp    %ecx,%edx
  800e02:	75 0d                	jne    800e11 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e04:	6b c0 78             	imul   $0x78,%eax,%eax
  800e07:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  800e0c:	8b 40 08             	mov    0x8(%eax),%eax
  800e0f:	eb 0e                	jmp    800e1f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e19:	75 d9                	jne    800df4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e1b:	66 b8 00 00          	mov    $0x0,%ax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e41:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 ea 16             	shr    $0x16,%edx
  800e58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	74 11                	je     800e75 <fd_alloc+0x2d>
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 0c             	shr    $0xc,%edx
  800e69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	75 09                	jne    800e7e <fd_alloc+0x36>
			*fd_store = fd;
  800e75:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	eb 17                	jmp    800e95 <fd_alloc+0x4d>
  800e7e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e83:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e88:	75 c9                	jne    800e53 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e90:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9d:	83 f8 1f             	cmp    $0x1f,%eax
  800ea0:	77 36                	ja     800ed8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea2:	c1 e0 0c             	shl    $0xc,%eax
  800ea5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	c1 ea 16             	shr    $0x16,%edx
  800eaf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb6:	f6 c2 01             	test   $0x1,%dl
  800eb9:	74 24                	je     800edf <fd_lookup+0x48>
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	c1 ea 0c             	shr    $0xc,%edx
  800ec0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	74 1a                	je     800ee6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	eb 13                	jmp    800eeb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edd:	eb 0c                	jmp    800eeb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee4:	eb 05                	jmp    800eeb <fd_lookup+0x54>
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	ba 68 22 80 00       	mov    $0x802268,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efb:	eb 13                	jmp    800f10 <dev_lookup+0x23>
  800efd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f00:	39 08                	cmp    %ecx,(%eax)
  800f02:	75 0c                	jne    800f10 <dev_lookup+0x23>
			*dev = devtab[i];
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	eb 2e                	jmp    800f3e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f10:	8b 02                	mov    (%edx),%eax
  800f12:	85 c0                	test   %eax,%eax
  800f14:	75 e7                	jne    800efd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f16:	a1 04 40 80 00       	mov    0x804004,%eax
  800f1b:	8b 40 48             	mov    0x48(%eax),%eax
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	51                   	push   %ecx
  800f22:	50                   	push   %eax
  800f23:	68 ec 21 80 00       	push   $0x8021ec
  800f28:	e8 67 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 10             	sub    $0x10,%esp
  800f48:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f51:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f52:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5b:	50                   	push   %eax
  800f5c:	e8 36 ff ff ff       	call   800e97 <fd_lookup>
  800f61:	83 c4 08             	add    $0x8,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 05                	js     800f6d <fd_close+0x2d>
	    || fd != fd2)
  800f68:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6b:	74 0b                	je     800f78 <fd_close+0x38>
		return (must_exist ? r : 0);
  800f6d:	80 fb 01             	cmp    $0x1,%bl
  800f70:	19 d2                	sbb    %edx,%edx
  800f72:	f7 d2                	not    %edx
  800f74:	21 d0                	and    %edx,%eax
  800f76:	eb 41                	jmp    800fb9 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f7e:	50                   	push   %eax
  800f7f:	ff 36                	pushl  (%esi)
  800f81:	e8 67 ff ff ff       	call   800eed <dev_lookup>
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 1a                	js     800fa9 <fd_close+0x69>
		if (dev->dev_close)
  800f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f92:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	74 0b                	je     800fa9 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	56                   	push   %esi
  800fa2:	ff d0                	call   *%eax
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 f3 fb ff ff       	call   800ba7 <sys_page_unmap>
	return r;
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	89 d8                	mov    %ebx,%eax
}
  800fb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	ff 75 08             	pushl  0x8(%ebp)
  800fcd:	e8 c5 fe ff ff       	call   800e97 <fd_lookup>
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	85 d2                	test   %edx,%edx
  800fd9:	78 10                	js     800feb <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	6a 01                	push   $0x1
  800fe0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe3:	e8 58 ff ff ff       	call   800f40 <fd_close>
  800fe8:	83 c4 10             	add    $0x10,%esp
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <close_all>:

void
close_all(void)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	53                   	push   %ebx
  800ffd:	e8 be ff ff ff       	call   800fc0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	83 c3 01             	add    $0x1,%ebx
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	83 fb 20             	cmp    $0x20,%ebx
  80100b:	75 ec                	jne    800ff9 <close_all+0xc>
		close(i);
}
  80100d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 2c             	sub    $0x2c,%esp
  80101b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80101e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801021:	50                   	push   %eax
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	e8 6d fe ff ff       	call   800e97 <fd_lookup>
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	85 d2                	test   %edx,%edx
  801031:	0f 88 c1 00 00 00    	js     8010f8 <dup+0xe6>
		return r;
	close(newfdnum);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	56                   	push   %esi
  80103b:	e8 80 ff ff ff       	call   800fc0 <close>

	newfd = INDEX2FD(newfdnum);
  801040:	89 f3                	mov    %esi,%ebx
  801042:	c1 e3 0c             	shl    $0xc,%ebx
  801045:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80104b:	83 c4 04             	add    $0x4,%esp
  80104e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801051:	e8 db fd ff ff       	call   800e31 <fd2data>
  801056:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801058:	89 1c 24             	mov    %ebx,(%esp)
  80105b:	e8 d1 fd ff ff       	call   800e31 <fd2data>
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801066:	89 f8                	mov    %edi,%eax
  801068:	c1 e8 16             	shr    $0x16,%eax
  80106b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801072:	a8 01                	test   $0x1,%al
  801074:	74 37                	je     8010ad <dup+0x9b>
  801076:	89 f8                	mov    %edi,%eax
  801078:	c1 e8 0c             	shr    $0xc,%eax
  80107b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801082:	f6 c2 01             	test   $0x1,%dl
  801085:	74 26                	je     8010ad <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	25 07 0e 00 00       	and    $0xe07,%eax
  801096:	50                   	push   %eax
  801097:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109a:	6a 00                	push   $0x0
  80109c:	57                   	push   %edi
  80109d:	6a 00                	push   $0x0
  80109f:	e8 c1 fa ff ff       	call   800b65 <sys_page_map>
  8010a4:	89 c7                	mov    %eax,%edi
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 2e                	js     8010db <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b0:	89 d0                	mov    %edx,%eax
  8010b2:	c1 e8 0c             	shr    $0xc,%eax
  8010b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c4:	50                   	push   %eax
  8010c5:	53                   	push   %ebx
  8010c6:	6a 00                	push   $0x0
  8010c8:	52                   	push   %edx
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 95 fa ff ff       	call   800b65 <sys_page_map>
  8010d0:	89 c7                	mov    %eax,%edi
  8010d2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d7:	85 ff                	test   %edi,%edi
  8010d9:	79 1d                	jns    8010f8 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	53                   	push   %ebx
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 c1 fa ff ff       	call   800ba7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e6:	83 c4 08             	add    $0x8,%esp
  8010e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 b4 fa ff ff       	call   800ba7 <sys_page_unmap>
	return r;
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	89 f8                	mov    %edi,%eax
}
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 14             	sub    $0x14,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	e8 83 fd ff ff       	call   800e97 <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	89 c2                	mov    %eax,%edx
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 6d                	js     80118a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801127:	ff 30                	pushl  (%eax)
  801129:	e8 bf fd ff ff       	call   800eed <dev_lookup>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 4c                	js     801181 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801135:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801138:	8b 42 08             	mov    0x8(%edx),%eax
  80113b:	83 e0 03             	and    $0x3,%eax
  80113e:	83 f8 01             	cmp    $0x1,%eax
  801141:	75 21                	jne    801164 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801143:	a1 04 40 80 00       	mov    0x804004,%eax
  801148:	8b 40 48             	mov    0x48(%eax),%eax
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	53                   	push   %ebx
  80114f:	50                   	push   %eax
  801150:	68 2d 22 80 00       	push   $0x80222d
  801155:	e8 3a f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801162:	eb 26                	jmp    80118a <read+0x8a>
	}
	if (!dev->dev_read)
  801164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801167:	8b 40 08             	mov    0x8(%eax),%eax
  80116a:	85 c0                	test   %eax,%eax
  80116c:	74 17                	je     801185 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	ff 75 10             	pushl  0x10(%ebp)
  801174:	ff 75 0c             	pushl  0xc(%ebp)
  801177:	52                   	push   %edx
  801178:	ff d0                	call   *%eax
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	eb 09                	jmp    80118a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	89 c2                	mov    %eax,%edx
  801183:	eb 05                	jmp    80118a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801185:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80118a:	89 d0                	mov    %edx,%eax
  80118c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a5:	eb 21                	jmp    8011c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	89 f0                	mov    %esi,%eax
  8011ac:	29 d8                	sub    %ebx,%eax
  8011ae:	50                   	push   %eax
  8011af:	89 d8                	mov    %ebx,%eax
  8011b1:	03 45 0c             	add    0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	57                   	push   %edi
  8011b6:	e8 45 ff ff ff       	call   801100 <read>
		if (m < 0)
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 0c                	js     8011ce <readn+0x3d>
			return m;
		if (m == 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	74 06                	je     8011cc <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c6:	01 c3                	add    %eax,%ebx
  8011c8:	39 f3                	cmp    %esi,%ebx
  8011ca:	72 db                	jb     8011a7 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011cc:	89 d8                	mov    %ebx,%eax
}
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 14             	sub    $0x14,%esp
  8011dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	53                   	push   %ebx
  8011e5:	e8 ad fc ff ff       	call   800e97 <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 68                	js     80125b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fd:	ff 30                	pushl  (%eax)
  8011ff:	e8 e9 fc ff ff       	call   800eed <dev_lookup>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 47                	js     801252 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801212:	75 21                	jne    801235 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801214:	a1 04 40 80 00       	mov    0x804004,%eax
  801219:	8b 40 48             	mov    0x48(%eax),%eax
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	53                   	push   %ebx
  801220:	50                   	push   %eax
  801221:	68 49 22 80 00       	push   $0x802249
  801226:	e8 69 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801233:	eb 26                	jmp    80125b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801235:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801238:	8b 52 0c             	mov    0xc(%edx),%edx
  80123b:	85 d2                	test   %edx,%edx
  80123d:	74 17                	je     801256 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	ff 75 10             	pushl  0x10(%ebp)
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	50                   	push   %eax
  801249:	ff d2                	call   *%edx
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	eb 09                	jmp    80125b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	89 c2                	mov    %eax,%edx
  801254:	eb 05                	jmp    80125b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801256:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80125b:	89 d0                	mov    %edx,%eax
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <seek>:

int
seek(int fdnum, off_t offset)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801268:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	ff 75 08             	pushl  0x8(%ebp)
  80126f:	e8 23 fc ff ff       	call   800e97 <fd_lookup>
  801274:	83 c4 08             	add    $0x8,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 0e                	js     801289 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80127b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80127e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801281:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	83 ec 14             	sub    $0x14,%esp
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	53                   	push   %ebx
  80129a:	e8 f8 fb ff ff       	call   800e97 <fd_lookup>
  80129f:	83 c4 08             	add    $0x8,%esp
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 65                	js     80130d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	ff 30                	pushl  (%eax)
  8012b4:	e8 34 fc ff ff       	call   800eed <dev_lookup>
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 44                	js     801304 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c7:	75 21                	jne    8012ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012c9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	68 0c 22 80 00       	push   $0x80220c
  8012db:	e8 b4 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012e8:	eb 23                	jmp    80130d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ed:	8b 52 18             	mov    0x18(%edx),%edx
  8012f0:	85 d2                	test   %edx,%edx
  8012f2:	74 14                	je     801308 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 0c             	pushl  0xc(%ebp)
  8012fa:	50                   	push   %eax
  8012fb:	ff d2                	call   *%edx
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	eb 09                	jmp    80130d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801304:	89 c2                	mov    %eax,%edx
  801306:	eb 05                	jmp    80130d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801308:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80130d:	89 d0                	mov    %edx,%eax
  80130f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	53                   	push   %ebx
  801318:	83 ec 14             	sub    $0x14,%esp
  80131b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 6d fb ff ff       	call   800e97 <fd_lookup>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 58                	js     80138b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 a9 fb ff ff       	call   800eed <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 37                	js     801382 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801352:	74 32                	je     801386 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801354:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801357:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80135e:	00 00 00 
	stat->st_isdir = 0;
  801361:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801368:	00 00 00 
	stat->st_dev = dev;
  80136b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	ff 75 f0             	pushl  -0x10(%ebp)
  801378:	ff 50 14             	call   *0x14(%eax)
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb 09                	jmp    80138b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801382:	89 c2                	mov    %eax,%edx
  801384:	eb 05                	jmp    80138b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801386:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	6a 00                	push   $0x0
  80139c:	ff 75 08             	pushl  0x8(%ebp)
  80139f:	e8 e7 01 00 00       	call   80158b <open>
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 db                	test   %ebx,%ebx
  8013ab:	78 1b                	js     8013c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	ff 75 0c             	pushl  0xc(%ebp)
  8013b3:	53                   	push   %ebx
  8013b4:	e8 5b ff ff ff       	call   801314 <fstat>
  8013b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013bb:	89 1c 24             	mov    %ebx,(%esp)
  8013be:	e8 fd fb ff ff       	call   800fc0 <close>
	return r;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 f0                	mov    %esi,%eax
}
  8013c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	89 c6                	mov    %eax,%esi
  8013d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013df:	75 12                	jne    8013f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	6a 03                	push   $0x3
  8013e6:	e8 fe f9 ff ff       	call   800de9 <ipc_find_env>
  8013eb:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f3:	6a 07                	push   $0x7
  8013f5:	68 00 50 80 00       	push   $0x805000
  8013fa:	56                   	push   %esi
  8013fb:	ff 35 00 40 80 00    	pushl  0x804000
  801401:	e8 92 f9 ff ff       	call   800d98 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801406:	83 c4 0c             	add    $0xc,%esp
  801409:	6a 00                	push   $0x0
  80140b:	53                   	push   %ebx
  80140c:	6a 00                	push   $0x0
  80140e:	e8 1f f9 ff ff       	call   800d32 <ipc_recv>
}
  801413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801416:	5b                   	pop    %ebx
  801417:	5e                   	pop    %esi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	8b 40 0c             	mov    0xc(%eax),%eax
  801426:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80142b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801433:	ba 00 00 00 00       	mov    $0x0,%edx
  801438:	b8 02 00 00 00       	mov    $0x2,%eax
  80143d:	e8 8d ff ff ff       	call   8013cf <fsipc>
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	8b 40 0c             	mov    0xc(%eax),%eax
  801450:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	b8 06 00 00 00       	mov    $0x6,%eax
  80145f:	e8 6b ff ff ff       	call   8013cf <fsipc>
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 04             	sub    $0x4,%esp
  80146d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801470:	8b 45 08             	mov    0x8(%ebp),%eax
  801473:	8b 40 0c             	mov    0xc(%eax),%eax
  801476:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147b:	ba 00 00 00 00       	mov    $0x0,%edx
  801480:	b8 05 00 00 00       	mov    $0x5,%eax
  801485:	e8 45 ff ff ff       	call   8013cf <fsipc>
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	85 d2                	test   %edx,%edx
  80148e:	78 2c                	js     8014bc <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	68 00 50 80 00       	push   $0x805000
  801498:	53                   	push   %ebx
  801499:	e8 7a f2 ff ff       	call   800718 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149e:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8014ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d0:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8014d6:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8014db:	76 05                	jbe    8014e2 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8014dd:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8014e2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	50                   	push   %eax
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	68 08 50 80 00       	push   $0x805008
  8014f3:	e8 b2 f3 ff ff       	call   8008aa <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801502:	e8 c8 fe ff ff       	call   8013cf <fsipc>
	return write;
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 03 00 00 00       	mov    $0x3,%eax
  80152c:	e8 9e fe ff ff       	call   8013cf <fsipc>
  801531:	89 c3                	mov    %eax,%ebx
  801533:	85 c0                	test   %eax,%eax
  801535:	78 4b                	js     801582 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801537:	39 c6                	cmp    %eax,%esi
  801539:	73 16                	jae    801551 <devfile_read+0x48>
  80153b:	68 78 22 80 00       	push   $0x802278
  801540:	68 7f 22 80 00       	push   $0x80227f
  801545:	6a 7c                	push   $0x7c
  801547:	68 94 22 80 00       	push   $0x802294
  80154c:	e8 b5 05 00 00       	call   801b06 <_panic>
	assert(r <= PGSIZE);
  801551:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801556:	7e 16                	jle    80156e <devfile_read+0x65>
  801558:	68 9f 22 80 00       	push   $0x80229f
  80155d:	68 7f 22 80 00       	push   $0x80227f
  801562:	6a 7d                	push   $0x7d
  801564:	68 94 22 80 00       	push   $0x802294
  801569:	e8 98 05 00 00       	call   801b06 <_panic>
	memmove(buf, &fsipcbuf, r);
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	50                   	push   %eax
  801572:	68 00 50 80 00       	push   $0x805000
  801577:	ff 75 0c             	pushl  0xc(%ebp)
  80157a:	e8 2b f3 ff ff       	call   8008aa <memmove>
	return r;
  80157f:	83 c4 10             	add    $0x10,%esp
}
  801582:	89 d8                	mov    %ebx,%eax
  801584:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 20             	sub    $0x20,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801595:	53                   	push   %ebx
  801596:	e8 44 f1 ff ff       	call   8006df <strlen>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a3:	7f 67                	jg     80160c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 97 f8 ff ff       	call   800e48 <fd_alloc>
  8015b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 57                	js     801611 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	53                   	push   %ebx
  8015be:	68 00 50 80 00       	push   $0x805000
  8015c3:	e8 50 f1 ff ff       	call   800718 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d8:	e8 f2 fd ff ff       	call   8013cf <fsipc>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	79 14                	jns    8015fa <open+0x6f>
		fd_close(fd, 0);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	6a 00                	push   $0x0
  8015eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ee:	e8 4d f9 ff ff       	call   800f40 <fd_close>
		return r;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	89 da                	mov    %ebx,%edx
  8015f8:	eb 17                	jmp    801611 <open+0x86>
	}

	return fd2num(fd);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801600:	e8 1c f8 ff ff       	call   800e21 <fd2num>
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 05                	jmp    801611 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801611:	89 d0                	mov    %edx,%eax
  801613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161e:	ba 00 00 00 00       	mov    $0x0,%edx
  801623:	b8 08 00 00 00       	mov    $0x8,%eax
  801628:	e8 a2 fd ff ff       	call   8013cf <fsipc>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	56                   	push   %esi
  801633:	53                   	push   %ebx
  801634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	ff 75 08             	pushl  0x8(%ebp)
  80163d:	e8 ef f7 ff ff       	call   800e31 <fd2data>
  801642:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	68 ab 22 80 00       	push   $0x8022ab
  80164c:	53                   	push   %ebx
  80164d:	e8 c6 f0 ff ff       	call   800718 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801652:	8b 56 04             	mov    0x4(%esi),%edx
  801655:	89 d0                	mov    %edx,%eax
  801657:	2b 06                	sub    (%esi),%eax
  801659:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80165f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801666:	00 00 00 
	stat->st_dev = &devpipe;
  801669:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801670:	30 80 00 
	return 0;
}
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801689:	53                   	push   %ebx
  80168a:	6a 00                	push   $0x0
  80168c:	e8 16 f5 ff ff       	call   800ba7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801691:	89 1c 24             	mov    %ebx,(%esp)
  801694:	e8 98 f7 ff ff       	call   800e31 <fd2data>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	50                   	push   %eax
  80169d:	6a 00                	push   $0x0
  80169f:	e8 03 f5 ff ff       	call   800ba7 <sys_page_unmap>
}
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	57                   	push   %edi
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 1c             	sub    $0x1c,%esp
  8016b2:	89 c7                	mov    %eax,%edi
  8016b4:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	57                   	push   %edi
  8016c2:	e8 85 04 00 00       	call   801b4c <pageref>
  8016c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ca:	89 34 24             	mov    %esi,(%esp)
  8016cd:	e8 7a 04 00 00       	call   801b4c <pageref>
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016d8:	0f 94 c0             	sete   %al
  8016db:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016de:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016e7:	39 cb                	cmp    %ecx,%ebx
  8016e9:	74 15                	je     801700 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8016eb:	8b 52 58             	mov    0x58(%edx),%edx
  8016ee:	50                   	push   %eax
  8016ef:	52                   	push   %edx
  8016f0:	53                   	push   %ebx
  8016f1:	68 b8 22 80 00       	push   $0x8022b8
  8016f6:	e8 99 ea ff ff       	call   800194 <cprintf>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	eb b6                	jmp    8016b6 <_pipeisclosed+0xd>
	}
}
  801700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	57                   	push   %edi
  80170c:	56                   	push   %esi
  80170d:	53                   	push   %ebx
  80170e:	83 ec 28             	sub    $0x28,%esp
  801711:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801714:	56                   	push   %esi
  801715:	e8 17 f7 ff ff       	call   800e31 <fd2data>
  80171a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	bf 00 00 00 00       	mov    $0x0,%edi
  801724:	eb 4b                	jmp    801771 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801726:	89 da                	mov    %ebx,%edx
  801728:	89 f0                	mov    %esi,%eax
  80172a:	e8 7a ff ff ff       	call   8016a9 <_pipeisclosed>
  80172f:	85 c0                	test   %eax,%eax
  801731:	75 48                	jne    80177b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801733:	e8 cb f3 ff ff       	call   800b03 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801738:	8b 43 04             	mov    0x4(%ebx),%eax
  80173b:	8b 0b                	mov    (%ebx),%ecx
  80173d:	8d 51 20             	lea    0x20(%ecx),%edx
  801740:	39 d0                	cmp    %edx,%eax
  801742:	73 e2                	jae    801726 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801747:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80174b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	c1 fa 1f             	sar    $0x1f,%edx
  801753:	89 d1                	mov    %edx,%ecx
  801755:	c1 e9 1b             	shr    $0x1b,%ecx
  801758:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80175b:	83 e2 1f             	and    $0x1f,%edx
  80175e:	29 ca                	sub    %ecx,%edx
  801760:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801764:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801768:	83 c0 01             	add    $0x1,%eax
  80176b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176e:	83 c7 01             	add    $0x1,%edi
  801771:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801774:	75 c2                	jne    801738 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801776:	8b 45 10             	mov    0x10(%ebp),%eax
  801779:	eb 05                	jmp    801780 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5f                   	pop    %edi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	57                   	push   %edi
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	83 ec 18             	sub    $0x18,%esp
  801791:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801794:	57                   	push   %edi
  801795:	e8 97 f6 ff ff       	call   800e31 <fd2data>
  80179a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a4:	eb 3d                	jmp    8017e3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017a6:	85 db                	test   %ebx,%ebx
  8017a8:	74 04                	je     8017ae <devpipe_read+0x26>
				return i;
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	eb 44                	jmp    8017f2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017ae:	89 f2                	mov    %esi,%edx
  8017b0:	89 f8                	mov    %edi,%eax
  8017b2:	e8 f2 fe ff ff       	call   8016a9 <_pipeisclosed>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	75 32                	jne    8017ed <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017bb:	e8 43 f3 ff ff       	call   800b03 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017c0:	8b 06                	mov    (%esi),%eax
  8017c2:	3b 46 04             	cmp    0x4(%esi),%eax
  8017c5:	74 df                	je     8017a6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017c7:	99                   	cltd   
  8017c8:	c1 ea 1b             	shr    $0x1b,%edx
  8017cb:	01 d0                	add    %edx,%eax
  8017cd:	83 e0 1f             	and    $0x1f,%eax
  8017d0:	29 d0                	sub    %edx,%eax
  8017d2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017da:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017dd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e0:	83 c3 01             	add    $0x1,%ebx
  8017e3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017e6:	75 d8                	jne    8017c0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017eb:	eb 05                	jmp    8017f2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ed:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	e8 3d f6 ff ff       	call   800e48 <fd_alloc>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	89 c2                	mov    %eax,%edx
  801810:	85 c0                	test   %eax,%eax
  801812:	0f 88 2c 01 00 00    	js     801944 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	68 07 04 00 00       	push   $0x407
  801820:	ff 75 f4             	pushl  -0xc(%ebp)
  801823:	6a 00                	push   $0x0
  801825:	e8 f8 f2 ff ff       	call   800b22 <sys_page_alloc>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	85 c0                	test   %eax,%eax
  801831:	0f 88 0d 01 00 00    	js     801944 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	e8 05 f6 ff ff       	call   800e48 <fd_alloc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 e2 00 00 00    	js     801932 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	68 07 04 00 00       	push   $0x407
  801858:	ff 75 f0             	pushl  -0x10(%ebp)
  80185b:	6a 00                	push   $0x0
  80185d:	e8 c0 f2 ff ff       	call   800b22 <sys_page_alloc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 c3 00 00 00    	js     801932 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	ff 75 f4             	pushl  -0xc(%ebp)
  801875:	e8 b7 f5 ff ff       	call   800e31 <fd2data>
  80187a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187c:	83 c4 0c             	add    $0xc,%esp
  80187f:	68 07 04 00 00       	push   $0x407
  801884:	50                   	push   %eax
  801885:	6a 00                	push   $0x0
  801887:	e8 96 f2 ff ff       	call   800b22 <sys_page_alloc>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 c0                	test   %eax,%eax
  801893:	0f 88 89 00 00 00    	js     801922 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	ff 75 f0             	pushl  -0x10(%ebp)
  80189f:	e8 8d f5 ff ff       	call   800e31 <fd2data>
  8018a4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ab:	50                   	push   %eax
  8018ac:	6a 00                	push   $0x0
  8018ae:	56                   	push   %esi
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 af f2 ff ff       	call   800b65 <sys_page_map>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	83 c4 20             	add    $0x20,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 55                	js     801914 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018bf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018d4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ef:	e8 2d f5 ff ff       	call   800e21 <fd2num>
  8018f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018f9:	83 c4 04             	add    $0x4,%esp
  8018fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ff:	e8 1d f5 ff ff       	call   800e21 <fd2num>
  801904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801907:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	eb 30                	jmp    801944 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	56                   	push   %esi
  801918:	6a 00                	push   $0x0
  80191a:	e8 88 f2 ff ff       	call   800ba7 <sys_page_unmap>
  80191f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	ff 75 f0             	pushl  -0x10(%ebp)
  801928:	6a 00                	push   $0x0
  80192a:	e8 78 f2 ff ff       	call   800ba7 <sys_page_unmap>
  80192f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	ff 75 f4             	pushl  -0xc(%ebp)
  801938:	6a 00                	push   $0x0
  80193a:	e8 68 f2 ff ff       	call   800ba7 <sys_page_unmap>
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801944:	89 d0                	mov    %edx,%eax
  801946:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 38 f5 ff ff       	call   800e97 <fd_lookup>
  80195f:	89 c2                	mov    %eax,%edx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 d2                	test   %edx,%edx
  801966:	78 18                	js     801980 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 75 f4             	pushl  -0xc(%ebp)
  80196e:	e8 be f4 ff ff       	call   800e31 <fd2data>
	return _pipeisclosed(fd, p);
  801973:	89 c2                	mov    %eax,%edx
  801975:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801978:	e8 2c fd ff ff       	call   8016a9 <_pipeisclosed>
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801992:	68 e9 22 80 00       	push   $0x8022e9
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	e8 79 ed ff ff       	call   800718 <strcpy>
	return 0;
}
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	57                   	push   %edi
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bd:	eb 2e                	jmp    8019ed <devcons_write+0x47>
		m = n - tot;
  8019bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8019c2:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  8019c4:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  8019c9:	83 fa 7f             	cmp    $0x7f,%edx
  8019cc:	77 02                	ja     8019d0 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ce:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	56                   	push   %esi
  8019d4:	03 45 0c             	add    0xc(%ebp),%eax
  8019d7:	50                   	push   %eax
  8019d8:	57                   	push   %edi
  8019d9:	e8 cc ee ff ff       	call   8008aa <memmove>
		sys_cputs(buf, m);
  8019de:	83 c4 08             	add    $0x8,%esp
  8019e1:	56                   	push   %esi
  8019e2:	57                   	push   %edi
  8019e3:	e8 7e f0 ff ff       	call   800a66 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e8:	01 f3                	add    %esi,%ebx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	89 d8                	mov    %ebx,%eax
  8019ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f2:	72 cb                	jb     8019bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f7:	5b                   	pop    %ebx
  8019f8:	5e                   	pop    %esi
  8019f9:	5f                   	pop    %edi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a02:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a0b:	75 07                	jne    801a14 <devcons_read+0x18>
  801a0d:	eb 28                	jmp    801a37 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a0f:	e8 ef f0 ff ff       	call   800b03 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a14:	e8 6b f0 ff ff       	call   800a84 <sys_cgetc>
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	74 f2                	je     801a0f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 16                	js     801a37 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a21:	83 f8 04             	cmp    $0x4,%eax
  801a24:	74 0c                	je     801a32 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a29:	88 02                	mov    %al,(%edx)
	return 1;
  801a2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a30:	eb 05                	jmp    801a37 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a32:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a45:	6a 01                	push   $0x1
  801a47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4a:	50                   	push   %eax
  801a4b:	e8 16 f0 ff ff       	call   800a66 <sys_cputs>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <getchar>:

int
getchar(void)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a5b:	6a 01                	push   $0x1
  801a5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a60:	50                   	push   %eax
  801a61:	6a 00                	push   $0x0
  801a63:	e8 98 f6 ff ff       	call   801100 <read>
	if (r < 0)
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 0f                	js     801a7e <getchar+0x29>
		return r;
	if (r < 1)
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	7e 06                	jle    801a79 <getchar+0x24>
		return -E_EOF;
	return c;
  801a73:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a77:	eb 05                	jmp    801a7e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a79:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a89:	50                   	push   %eax
  801a8a:	ff 75 08             	pushl  0x8(%ebp)
  801a8d:	e8 05 f4 ff ff       	call   800e97 <fd_lookup>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 11                	js     801aaa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa2:	39 10                	cmp    %edx,(%eax)
  801aa4:	0f 94 c0             	sete   %al
  801aa7:	0f b6 c0             	movzbl %al,%eax
}
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <opencons>:

int
opencons(void)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab5:	50                   	push   %eax
  801ab6:	e8 8d f3 ff ff       	call   800e48 <fd_alloc>
  801abb:	83 c4 10             	add    $0x10,%esp
		return r;
  801abe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 3e                	js     801b02 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac4:	83 ec 04             	sub    $0x4,%esp
  801ac7:	68 07 04 00 00       	push   $0x407
  801acc:	ff 75 f4             	pushl  -0xc(%ebp)
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 4c f0 ff ff       	call   800b22 <sys_page_alloc>
  801ad6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 23                	js     801b02 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801adf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	50                   	push   %eax
  801af8:	e8 24 f3 ff ff       	call   800e21 <fd2num>
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	83 c4 10             	add    $0x10,%esp
}
  801b02:	89 d0                	mov    %edx,%eax
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b0b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b0e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b14:	e8 cb ef ff ff       	call   800ae4 <sys_getenvid>
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	ff 75 0c             	pushl  0xc(%ebp)
  801b1f:	ff 75 08             	pushl  0x8(%ebp)
  801b22:	56                   	push   %esi
  801b23:	50                   	push   %eax
  801b24:	68 f8 22 80 00       	push   $0x8022f8
  801b29:	e8 66 e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b2e:	83 c4 18             	add    $0x18,%esp
  801b31:	53                   	push   %ebx
  801b32:	ff 75 10             	pushl  0x10(%ebp)
  801b35:	e8 09 e6 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b3a:	c7 04 24 47 22 80 00 	movl   $0x802247,(%esp)
  801b41:	e8 4e e6 ff ff       	call   800194 <cprintf>
  801b46:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b49:	cc                   	int3   
  801b4a:	eb fd                	jmp    801b49 <_panic+0x43>

00801b4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b52:	89 d0                	mov    %edx,%eax
  801b54:	c1 e8 16             	shr    $0x16,%eax
  801b57:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b63:	f6 c1 01             	test   $0x1,%cl
  801b66:	74 1d                	je     801b85 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b68:	c1 ea 0c             	shr    $0xc,%edx
  801b6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b72:	f6 c2 01             	test   $0x1,%dl
  801b75:	74 0e                	je     801b85 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b77:	c1 ea 0c             	shr    $0xc,%edx
  801b7a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b81:	ef 
  801b82:	0f b7 c0             	movzwl %ax,%eax
}
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    
  801b87:	66 90                	xchg   %ax,%ax
  801b89:	66 90                	xchg   %ax,%ax
  801b8b:	66 90                	xchg   %ax,%ax
  801b8d:	66 90                	xchg   %ax,%ax
  801b8f:	90                   	nop

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	83 ec 10             	sub    $0x10,%esp
  801b96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801ba2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801ba6:	85 d2                	test   %edx,%edx
  801ba8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bac:	89 34 24             	mov    %esi,(%esp)
  801baf:	89 c8                	mov    %ecx,%eax
  801bb1:	75 35                	jne    801be8 <__udivdi3+0x58>
  801bb3:	39 f1                	cmp    %esi,%ecx
  801bb5:	0f 87 bd 00 00 00    	ja     801c78 <__udivdi3+0xe8>
  801bbb:	85 c9                	test   %ecx,%ecx
  801bbd:	89 cd                	mov    %ecx,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 f0                	mov    %esi,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c6                	mov    %eax,%esi
  801bd4:	89 f8                	mov    %edi,%eax
  801bd6:	f7 f5                	div    %ebp
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    
  801be1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be8:	3b 14 24             	cmp    (%esp),%edx
  801beb:	77 7b                	ja     801c68 <__udivdi3+0xd8>
  801bed:	0f bd f2             	bsr    %edx,%esi
  801bf0:	83 f6 1f             	xor    $0x1f,%esi
  801bf3:	0f 84 97 00 00 00    	je     801c90 <__udivdi3+0x100>
  801bf9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bfe:	89 d7                	mov    %edx,%edi
  801c00:	89 f1                	mov    %esi,%ecx
  801c02:	29 f5                	sub    %esi,%ebp
  801c04:	d3 e7                	shl    %cl,%edi
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	89 e9                	mov    %ebp,%ecx
  801c0a:	d3 ea                	shr    %cl,%edx
  801c0c:	89 f1                	mov    %esi,%ecx
  801c0e:	09 fa                	or     %edi,%edx
  801c10:	8b 3c 24             	mov    (%esp),%edi
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c19:	89 e9                	mov    %ebp,%ecx
  801c1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c23:	89 fa                	mov    %edi,%edx
  801c25:	d3 ea                	shr    %cl,%edx
  801c27:	89 f1                	mov    %esi,%ecx
  801c29:	d3 e7                	shl    %cl,%edi
  801c2b:	89 e9                	mov    %ebp,%ecx
  801c2d:	d3 e8                	shr    %cl,%eax
  801c2f:	09 c7                	or     %eax,%edi
  801c31:	89 f8                	mov    %edi,%eax
  801c33:	f7 74 24 08          	divl   0x8(%esp)
  801c37:	89 d5                	mov    %edx,%ebp
  801c39:	89 c7                	mov    %eax,%edi
  801c3b:	f7 64 24 0c          	mull   0xc(%esp)
  801c3f:	39 d5                	cmp    %edx,%ebp
  801c41:	89 14 24             	mov    %edx,(%esp)
  801c44:	72 11                	jb     801c57 <__udivdi3+0xc7>
  801c46:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c4a:	89 f1                	mov    %esi,%ecx
  801c4c:	d3 e2                	shl    %cl,%edx
  801c4e:	39 c2                	cmp    %eax,%edx
  801c50:	73 5e                	jae    801cb0 <__udivdi3+0x120>
  801c52:	3b 2c 24             	cmp    (%esp),%ebp
  801c55:	75 59                	jne    801cb0 <__udivdi3+0x120>
  801c57:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c5a:	31 f6                	xor    %esi,%esi
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	31 f6                	xor    %esi,%esi
  801c6a:	31 c0                	xor    %eax,%eax
  801c6c:	89 f2                	mov    %esi,%edx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	89 f2                	mov    %esi,%edx
  801c7a:	31 f6                	xor    %esi,%esi
  801c7c:	89 f8                	mov    %edi,%eax
  801c7e:	f7 f1                	div    %ecx
  801c80:	89 f2                	mov    %esi,%edx
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c94:	76 0b                	jbe    801ca1 <__udivdi3+0x111>
  801c96:	31 c0                	xor    %eax,%eax
  801c98:	3b 14 24             	cmp    (%esp),%edx
  801c9b:	0f 83 37 ff ff ff    	jae    801bd8 <__udivdi3+0x48>
  801ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca6:	e9 2d ff ff ff       	jmp    801bd8 <__udivdi3+0x48>
  801cab:	90                   	nop
  801cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 f8                	mov    %edi,%eax
  801cb2:	31 f6                	xor    %esi,%esi
  801cb4:	e9 1f ff ff ff       	jmp    801bd8 <__udivdi3+0x48>
  801cb9:	66 90                	xchg   %ax,%ax
  801cbb:	66 90                	xchg   %ax,%ax
  801cbd:	66 90                	xchg   %ax,%ax
  801cbf:	90                   	nop

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	83 ec 20             	sub    $0x20,%esp
  801cc6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801cca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd2:	89 c6                	mov    %eax,%esi
  801cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cd8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cdc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ce0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ce4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ce8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cec:	85 c0                	test   %eax,%eax
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	75 1e                	jne    801d10 <__umoddi3+0x50>
  801cf2:	39 f7                	cmp    %esi,%edi
  801cf4:	76 52                	jbe    801d48 <__umoddi3+0x88>
  801cf6:	89 c8                	mov    %ecx,%eax
  801cf8:	89 f2                	mov    %esi,%edx
  801cfa:	f7 f7                	div    %edi
  801cfc:	89 d0                	mov    %edx,%eax
  801cfe:	31 d2                	xor    %edx,%edx
  801d00:	83 c4 20             	add    $0x20,%esp
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    
  801d07:	89 f6                	mov    %esi,%esi
  801d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d10:	39 f0                	cmp    %esi,%eax
  801d12:	77 5c                	ja     801d70 <__umoddi3+0xb0>
  801d14:	0f bd e8             	bsr    %eax,%ebp
  801d17:	83 f5 1f             	xor    $0x1f,%ebp
  801d1a:	75 64                	jne    801d80 <__umoddi3+0xc0>
  801d1c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d20:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d24:	0f 86 f6 00 00 00    	jbe    801e20 <__umoddi3+0x160>
  801d2a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d2e:	0f 82 ec 00 00 00    	jb     801e20 <__umoddi3+0x160>
  801d34:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d38:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d3c:	83 c4 20             	add    $0x20,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
  801d43:	90                   	nop
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	85 ff                	test   %edi,%edi
  801d4a:	89 fd                	mov    %edi,%ebp
  801d4c:	75 0b                	jne    801d59 <__umoddi3+0x99>
  801d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f7                	div    %edi
  801d57:	89 c5                	mov    %eax,%ebp
  801d59:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d5d:	31 d2                	xor    %edx,%edx
  801d5f:	f7 f5                	div    %ebp
  801d61:	89 c8                	mov    %ecx,%eax
  801d63:	f7 f5                	div    %ebp
  801d65:	eb 95                	jmp    801cfc <__umoddi3+0x3c>
  801d67:	89 f6                	mov    %esi,%esi
  801d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 20             	add    $0x20,%esp
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    
  801d7b:	90                   	nop
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	b8 20 00 00 00       	mov    $0x20,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	29 e8                	sub    %ebp,%eax
  801d89:	d3 e2                	shl    %cl,%edx
  801d8b:	89 c7                	mov    %eax,%edi
  801d8d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 c1                	mov    %eax,%ecx
  801d9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d9f:	09 d1                	or     %edx,%ecx
  801da1:	89 fa                	mov    %edi,%edx
  801da3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801da7:	89 e9                	mov    %ebp,%ecx
  801da9:	d3 e0                	shl    %cl,%eax
  801dab:	89 f9                	mov    %edi,%ecx
  801dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	d3 e8                	shr    %cl,%eax
  801db5:	89 e9                	mov    %ebp,%ecx
  801db7:	89 c7                	mov    %eax,%edi
  801db9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dbd:	d3 e6                	shl    %cl,%esi
  801dbf:	89 d1                	mov    %edx,%ecx
  801dc1:	89 fa                	mov    %edi,%edx
  801dc3:	d3 e8                	shr    %cl,%eax
  801dc5:	89 e9                	mov    %ebp,%ecx
  801dc7:	09 f0                	or     %esi,%eax
  801dc9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801dcd:	f7 74 24 10          	divl   0x10(%esp)
  801dd1:	d3 e6                	shl    %cl,%esi
  801dd3:	89 d1                	mov    %edx,%ecx
  801dd5:	f7 64 24 0c          	mull   0xc(%esp)
  801dd9:	39 d1                	cmp    %edx,%ecx
  801ddb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801ddf:	89 d7                	mov    %edx,%edi
  801de1:	89 c6                	mov    %eax,%esi
  801de3:	72 0a                	jb     801def <__umoddi3+0x12f>
  801de5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801de9:	73 10                	jae    801dfb <__umoddi3+0x13b>
  801deb:	39 d1                	cmp    %edx,%ecx
  801ded:	75 0c                	jne    801dfb <__umoddi3+0x13b>
  801def:	89 d7                	mov    %edx,%edi
  801df1:	89 c6                	mov    %eax,%esi
  801df3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801df7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dfb:	89 ca                	mov    %ecx,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e03:	29 f0                	sub    %esi,%eax
  801e05:	19 fa                	sbb    %edi,%edx
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e0e:	89 d7                	mov    %edx,%edi
  801e10:	d3 e7                	shl    %cl,%edi
  801e12:	89 e9                	mov    %ebp,%ecx
  801e14:	09 f8                	or     %edi,%eax
  801e16:	d3 ea                	shr    %cl,%edx
  801e18:	83 c4 20             	add    $0x20,%esp
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    
  801e1f:	90                   	nop
  801e20:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e24:	29 f9                	sub    %edi,%ecx
  801e26:	19 c6                	sbb    %eax,%esi
  801e28:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e2c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e30:	e9 ff fe ff ff       	jmp    801d34 <__umoddi3+0x74>
