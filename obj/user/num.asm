
obj/user/num:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 40 20 80 00       	push   $0x802040
  800062:	e8 01 17 00 00       	call   801768 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 90 11 00 00       	call   801211 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %i", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 45 20 80 00       	push   $0x802045
  800095:	6a 13                	push   $0x13
  800097:	68 60 20 80 00       	push   $0x802060
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 7e 10 00 00       	call   80113b <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %i", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %i", s, (int) n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 6b 20 80 00       	push   $0x80206b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 60 20 80 00       	push   $0x802060
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 80 	movl   $0x802080,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 84 20 80 00       	push   $0x802084
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 92 14 00 00       	call   8015c6 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %i", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 8c 20 80 00       	push   $0x80208c
  80014b:	6a 27                	push   $0x27
  80014d:	68 60 20 80 00       	push   $0x802060
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 91 0e 00 00       	call   800ffb <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800190:	e8 79 0a 00 00       	call   800c0e <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 78             	imul   $0x78,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
  8001c1:	83 c4 10             	add    $0x10,%esp
#endif
}
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 52 0e 00 00       	call   801028 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 ed 09 00 00       	call   800bcd <sys_env_destroy>
  8001e0:	83 c4 10             	add    $0x10,%esp
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 16 0a 00 00       	call   800c0e <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 a8 20 80 00       	push   $0x8020a8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 35 09 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 4f 01 00 00       	call   8003f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 da 08 00 00       	call   800b90 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 d1                	mov    %edx,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002fd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800300:	72 05                	jb     800307 <printnum+0x35>
  800302:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800305:	77 3e                	ja     800345 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800307:	83 ec 0c             	sub    $0xc,%esp
  80030a:	ff 75 18             	pushl  0x18(%ebp)
  80030d:	83 eb 01             	sub    $0x1,%ebx
  800310:	53                   	push   %ebx
  800311:	50                   	push   %eax
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 5a 1a 00 00       	call   801d80 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 13                	jmp    80034c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800345:	83 eb 01             	sub    $0x1,%ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f ed                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	ff 75 e4             	pushl  -0x1c(%ebp)
  800356:	ff 75 e0             	pushl  -0x20(%ebp)
  800359:	ff 75 dc             	pushl  -0x24(%ebp)
  80035c:	ff 75 d8             	pushl  -0x28(%ebp)
  80035f:	e8 4c 1b 00 00       	call   801eb0 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 cb 20 80 00 	movsbl 0x8020cb(%eax),%eax
  80036e:	50                   	push   %eax
  80036f:	ff d7                	call   *%edi
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037f:	83 fa 01             	cmp    $0x1,%edx
  800382:	7e 0e                	jle    800392 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800384:	8b 10                	mov    (%eax),%edx
  800386:	8d 4a 08             	lea    0x8(%edx),%ecx
  800389:	89 08                	mov    %ecx,(%eax)
  80038b:	8b 02                	mov    (%edx),%eax
  80038d:	8b 52 04             	mov    0x4(%edx),%edx
  800390:	eb 22                	jmp    8003b4 <getuint+0x38>
	else if (lflag)
  800392:	85 d2                	test   %edx,%edx
  800394:	74 10                	je     8003a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a4:	eb 0e                	jmp    8003b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c5:	73 0a                	jae    8003d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	88 02                	mov    %al,(%edx)
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003dc:	50                   	push   %eax
  8003dd:	ff 75 10             	pushl  0x10(%ebp)
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	e8 05 00 00 00       	call   8003f0 <vprintfmt>
	va_end(ap);
  8003eb:	83 c4 10             	add    $0x10,%esp
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 2c             	sub    $0x2c,%esp
  8003f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  800402:	eb 12                	jmp    800416 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800404:	85 c0                	test   %eax,%eax
  800406:	0f 84 8d 03 00 00    	je     800799 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	53                   	push   %ebx
  800410:	50                   	push   %eax
  800411:	ff d6                	call   *%esi
  800413:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800416:	83 c7 01             	add    $0x1,%edi
  800419:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e2                	jne    800404 <vprintfmt+0x14>
  800422:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800426:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800434:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 07                	jmp    800449 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8d 47 01             	lea    0x1(%edi),%eax
  80044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044f:	0f b6 07             	movzbl (%edi),%eax
  800452:	0f b6 c8             	movzbl %al,%ecx
  800455:	83 e8 23             	sub    $0x23,%eax
  800458:	3c 55                	cmp    $0x55,%al
  80045a:	0f 87 1e 03 00 00    	ja     80077e <vprintfmt+0x38e>
  800460:	0f b6 c0             	movzbl %al,%eax
  800463:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800471:	eb d6                	jmp    800449 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800481:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800485:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800488:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80048b:	83 fa 09             	cmp    $0x9,%edx
  80048e:	77 38                	ja     8004c8 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800490:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800493:	eb e9                	jmp    80047e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 48 04             	lea    0x4(%eax),%ecx
  80049b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a6:	eb 26                	jmp    8004ce <vprintfmt+0xde>
  8004a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ab:	89 c8                	mov    %ecx,%eax
  8004ad:	c1 f8 1f             	sar    $0x1f,%eax
  8004b0:	f7 d0                	not    %eax
  8004b2:	21 c1                	and    %eax,%ecx
  8004b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ba:	eb 8d                	jmp    800449 <vprintfmt+0x59>
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c6:	eb 81                	jmp    800449 <vprintfmt+0x59>
  8004c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d2:	0f 89 71 ff ff ff    	jns    800449 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e5:	e9 5f ff ff ff       	jmp    800449 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f0:	e9 54 ff ff ff       	jmp    800449 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	ff 30                	pushl  (%eax)
  800504:	ff d6                	call   *%esi
			break;
  800506:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050c:	e9 05 ff ff ff       	jmp    800416 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	99                   	cltd   
  80051d:	31 d0                	xor    %edx,%eax
  80051f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800521:	83 f8 0f             	cmp    $0xf,%eax
  800524:	7f 0b                	jg     800531 <vprintfmt+0x141>
  800526:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  80052d:	85 d2                	test   %edx,%edx
  80052f:	75 18                	jne    800549 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800531:	50                   	push   %eax
  800532:	68 e3 20 80 00       	push   $0x8020e3
  800537:	53                   	push   %ebx
  800538:	56                   	push   %esi
  800539:	e8 95 fe ff ff       	call   8003d3 <printfmt>
  80053e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800544:	e9 cd fe ff ff       	jmp    800416 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800549:	52                   	push   %edx
  80054a:	68 b1 24 80 00       	push   $0x8024b1
  80054f:	53                   	push   %ebx
  800550:	56                   	push   %esi
  800551:	e8 7d fe ff ff       	call   8003d3 <printfmt>
  800556:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055c:	e9 b5 fe ff ff       	jmp    800416 <vprintfmt+0x26>
  800561:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800564:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800567:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 38                	mov    (%eax),%edi
  800575:	85 ff                	test   %edi,%edi
  800577:	75 05                	jne    80057e <vprintfmt+0x18e>
				p = "(null)";
  800579:	bf dc 20 80 00       	mov    $0x8020dc,%edi
			if (width > 0 && padc != '-')
  80057e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800582:	0f 84 91 00 00 00    	je     800619 <vprintfmt+0x229>
  800588:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80058c:	0f 8e 95 00 00 00    	jle    800627 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	51                   	push   %ecx
  800596:	57                   	push   %edi
  800597:	e8 85 02 00 00       	call   800821 <strnlen>
  80059c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c5>
  8005c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ce:	89 c8                	mov    %ecx,%eax
  8005d0:	c1 f8 1f             	sar    $0x1f,%eax
  8005d3:	f7 d0                	not    %eax
  8005d5:	21 c8                	and    %ecx,%eax
  8005d7:	29 c1                	sub    %eax,%ecx
  8005d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e2:	89 cb                	mov    %ecx,%ebx
  8005e4:	eb 4d                	jmp    800633 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ea:	74 1b                	je     800607 <vprintfmt+0x217>
  8005ec:	0f be c0             	movsbl %al,%eax
  8005ef:	83 e8 20             	sub    $0x20,%eax
  8005f2:	83 f8 5e             	cmp    $0x5e,%eax
  8005f5:	76 10                	jbe    800607 <vprintfmt+0x217>
					putch('?', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	ff 75 0c             	pushl  0xc(%ebp)
  8005fd:	6a 3f                	push   $0x3f
  8005ff:	ff 55 08             	call   *0x8(%ebp)
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb 0d                	jmp    800614 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	ff 75 0c             	pushl  0xc(%ebp)
  80060d:	52                   	push   %edx
  80060e:	ff 55 08             	call   *0x8(%ebp)
  800611:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	83 eb 01             	sub    $0x1,%ebx
  800617:	eb 1a                	jmp    800633 <vprintfmt+0x243>
  800619:	89 75 08             	mov    %esi,0x8(%ebp)
  80061c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800622:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800625:	eb 0c                	jmp    800633 <vprintfmt+0x243>
  800627:	89 75 08             	mov    %esi,0x8(%ebp)
  80062a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800630:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800633:	83 c7 01             	add    $0x1,%edi
  800636:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063a:	0f be d0             	movsbl %al,%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	74 23                	je     800664 <vprintfmt+0x274>
  800641:	85 f6                	test   %esi,%esi
  800643:	78 a1                	js     8005e6 <vprintfmt+0x1f6>
  800645:	83 ee 01             	sub    $0x1,%esi
  800648:	79 9c                	jns    8005e6 <vprintfmt+0x1f6>
  80064a:	89 df                	mov    %ebx,%edi
  80064c:	8b 75 08             	mov    0x8(%ebp),%esi
  80064f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800652:	eb 18                	jmp    80066c <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 20                	push   $0x20
  80065a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065c:	83 ef 01             	sub    $0x1,%edi
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	eb 08                	jmp    80066c <vprintfmt+0x27c>
  800664:	89 df                	mov    %ebx,%edi
  800666:	8b 75 08             	mov    0x8(%ebp),%esi
  800669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066c:	85 ff                	test   %edi,%edi
  80066e:	7f e4                	jg     800654 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800673:	e9 9e fd ff ff       	jmp    800416 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800678:	83 fa 01             	cmp    $0x1,%edx
  80067b:	7e 16                	jle    800693 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 08             	lea    0x8(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 50 04             	mov    0x4(%eax),%edx
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800691:	eb 32                	jmp    8006c5 <vprintfmt+0x2d5>
	else if (lflag)
  800693:	85 d2                	test   %edx,%edx
  800695:	74 18                	je     8006af <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a5:	89 c1                	mov    %eax,%ecx
  8006a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ad:	eb 16                	jmp    8006c5 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bd:	89 c1                	mov    %eax,%ecx
  8006bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d4:	79 74                	jns    80074a <vprintfmt+0x35a>
				putch('-', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 2d                	push   $0x2d
  8006dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8006de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e4:	f7 d8                	neg    %eax
  8006e6:	83 d2 00             	adc    $0x0,%edx
  8006e9:	f7 da                	neg    %edx
  8006eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f3:	eb 55                	jmp    80074a <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f8:	e8 7f fc ff ff       	call   80037c <getuint>
			base = 10;
  8006fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800702:	eb 46                	jmp    80074a <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 70 fc ff ff       	call   80037c <getuint>
			base = 8;
  80070c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800711:	eb 37                	jmp    80074a <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 30                	push   $0x30
  800719:	ff d6                	call   *%esi
			putch('x', putdat);
  80071b:	83 c4 08             	add    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 78                	push   $0x78
  800721:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 50 04             	lea    0x4(%eax),%edx
  800729:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072c:	8b 00                	mov    (%eax),%eax
  80072e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800733:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800736:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073b:	eb 0d                	jmp    80074a <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
  800740:	e8 37 fc ff ff       	call   80037c <getuint>
			base = 16;
  800745:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800751:	57                   	push   %edi
  800752:	ff 75 e0             	pushl  -0x20(%ebp)
  800755:	51                   	push   %ecx
  800756:	52                   	push   %edx
  800757:	50                   	push   %eax
  800758:	89 da                	mov    %ebx,%edx
  80075a:	89 f0                	mov    %esi,%eax
  80075c:	e8 71 fb ff ff       	call   8002d2 <printnum>
			break;
  800761:	83 c4 20             	add    $0x20,%esp
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800767:	e9 aa fc ff ff       	jmp    800416 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	51                   	push   %ecx
  800771:	ff d6                	call   *%esi
			break;
  800773:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800779:	e9 98 fc ff ff       	jmp    800416 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	6a 25                	push   $0x25
  800784:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb 03                	jmp    80078e <vprintfmt+0x39e>
  80078b:	83 ef 01             	sub    $0x1,%edi
  80078e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800792:	75 f7                	jne    80078b <vprintfmt+0x39b>
  800794:	e9 7d fc ff ff       	jmp    800416 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800799:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5f                   	pop    %edi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 18             	sub    $0x18,%esp
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	74 26                	je     8007e8 <vsnprintf+0x47>
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	7e 22                	jle    8007e8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c6:	ff 75 14             	pushl  0x14(%ebp)
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	68 b6 03 80 00       	push   $0x8003b6
  8007d5:	e8 16 fc ff ff       	call   8003f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007dd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	eb 05                	jmp    8007ed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f8:	50                   	push   %eax
  8007f9:	ff 75 10             	pushl  0x10(%ebp)
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	ff 75 08             	pushl  0x8(%ebp)
  800802:	e8 9a ff ff ff       	call   8007a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 03                	jmp    800819 <strlen+0x10>
		n++;
  800816:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800819:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081d:	75 f7                	jne    800816 <strlen+0xd>
		n++;
	return n;
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
  80082f:	eb 03                	jmp    800834 <strnlen+0x13>
		n++;
  800831:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800834:	39 c2                	cmp    %eax,%edx
  800836:	74 08                	je     800840 <strnlen+0x1f>
  800838:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083c:	75 f3                	jne    800831 <strnlen+0x10>
  80083e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800858:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ef                	jne    80084e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800869:	53                   	push   %ebx
  80086a:	e8 9a ff ff ff       	call   800809 <strlen>
  80086f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	01 d8                	add    %ebx,%eax
  800877:	50                   	push   %eax
  800878:	e8 c5 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	89 f3                	mov    %esi,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	89 f2                	mov    %esi,%edx
  800896:	eb 0f                	jmp    8008a7 <strncpy+0x23>
		*dst++ = *src;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a7:	39 da                	cmp    %ebx,%edx
  8008a9:	75 ed                	jne    800898 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008bf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	74 21                	je     8008e6 <strlcpy+0x35>
  8008c5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c9:	89 f2                	mov    %esi,%edx
  8008cb:	eb 09                	jmp    8008d6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cd:	83 c2 01             	add    $0x1,%edx
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d6:	39 c2                	cmp    %eax,%edx
  8008d8:	74 09                	je     8008e3 <strlcpy+0x32>
  8008da:	0f b6 19             	movzbl (%ecx),%ebx
  8008dd:	84 db                	test   %bl,%bl
  8008df:	75 ec                	jne    8008cd <strlcpy+0x1c>
  8008e1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e6:	29 f0                	sub    %esi,%eax
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f5:	eb 06                	jmp    8008fd <strcmp+0x11>
		p++, q++;
  8008f7:	83 c1 01             	add    $0x1,%ecx
  8008fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fd:	0f b6 01             	movzbl (%ecx),%eax
  800900:	84 c0                	test   %al,%al
  800902:	74 04                	je     800908 <strcmp+0x1c>
  800904:	3a 02                	cmp    (%edx),%al
  800906:	74 ef                	je     8008f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 c3                	mov    %eax,%ebx
  80091e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800921:	eb 06                	jmp    800929 <strncmp+0x17>
		n--, p++, q++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800929:	39 d8                	cmp    %ebx,%eax
  80092b:	74 15                	je     800942 <strncmp+0x30>
  80092d:	0f b6 08             	movzbl (%eax),%ecx
  800930:	84 c9                	test   %cl,%cl
  800932:	74 04                	je     800938 <strncmp+0x26>
  800934:	3a 0a                	cmp    (%edx),%cl
  800936:	74 eb                	je     800923 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 00             	movzbl (%eax),%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
  800940:	eb 05                	jmp    800947 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	eb 07                	jmp    80095d <strchr+0x13>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 0f                	je     800969 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f2                	jne    800956 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	eb 03                	jmp    80097a <strfind+0xf>
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097d:	84 d2                	test   %dl,%dl
  80097f:	74 04                	je     800985 <strfind+0x1a>
  800981:	38 ca                	cmp    %cl,%dl
  800983:	75 f2                	jne    800977 <strfind+0xc>
			break;
	return (char *) s;
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800993:	85 c9                	test   %ecx,%ecx
  800995:	74 36                	je     8009cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800997:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099d:	75 28                	jne    8009c7 <memset+0x40>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 23                	jne    8009c7 <memset+0x40>
		c &= 0xFF;
  8009a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a8:	89 d3                	mov    %edx,%ebx
  8009aa:	c1 e3 08             	shl    $0x8,%ebx
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	c1 e6 18             	shl    $0x18,%esi
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	c1 e0 10             	shl    $0x10,%eax
  8009b7:	09 f0                	or     %esi,%eax
  8009b9:	09 c2                	or     %eax,%edx
  8009bb:	89 d0                	mov    %edx,%eax
  8009bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c2:	fc                   	cld    
  8009c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c5:	eb 06                	jmp    8009cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 35                	jae    800a1b <memmove+0x47>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2e                	jae    800a1b <memmove+0x47>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009f0:	89 d6                	mov    %edx,%esi
  8009f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fa:	75 13                	jne    800a0f <memmove+0x3b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 0e                	jne    800a0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a01:	83 ef 04             	sub    $0x4,%edi
  800a04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb 09                	jmp    800a18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0f:	83 ef 01             	sub    $0x1,%edi
  800a12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a15:	fd                   	std    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a18:	fc                   	cld    
  800a19:	eb 1d                	jmp    800a38 <memmove+0x64>
  800a1b:	89 f2                	mov    %esi,%edx
  800a1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	f6 c2 03             	test   $0x3,%dl
  800a22:	75 0f                	jne    800a33 <memmove+0x5f>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	75 0a                	jne    800a33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 05                	jmp    800a38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	fc                   	cld    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3f:	ff 75 10             	pushl  0x10(%ebp)
  800a42:	ff 75 0c             	pushl  0xc(%ebp)
  800a45:	ff 75 08             	pushl  0x8(%ebp)
  800a48:	e8 87 ff ff ff       	call   8009d4 <memmove>
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5a:	89 c6                	mov    %eax,%esi
  800a5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5f:	eb 1a                	jmp    800a7b <memcmp+0x2c>
		if (*s1 != *s2)
  800a61:	0f b6 08             	movzbl (%eax),%ecx
  800a64:	0f b6 1a             	movzbl (%edx),%ebx
  800a67:	38 d9                	cmp    %bl,%cl
  800a69:	74 0a                	je     800a75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6b:	0f b6 c1             	movzbl %cl,%eax
  800a6e:	0f b6 db             	movzbl %bl,%ebx
  800a71:	29 d8                	sub    %ebx,%eax
  800a73:	eb 0f                	jmp    800a84 <memcmp+0x35>
		s1++, s2++;
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7b:	39 f0                	cmp    %esi,%eax
  800a7d:	75 e2                	jne    800a61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a96:	eb 07                	jmp    800a9f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a98:	38 08                	cmp    %cl,(%eax)
  800a9a:	74 07                	je     800aa3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	72 f5                	jb     800a98 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	eb 03                	jmp    800ab6 <strtol+0x11>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	3c 09                	cmp    $0x9,%al
  800abb:	74 f6                	je     800ab3 <strtol+0xe>
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f2                	je     800ab3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac1:	3c 2b                	cmp    $0x2b,%al
  800ac3:	75 0a                	jne    800acf <strtol+0x2a>
		s++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
  800acd:	eb 10                	jmp    800adf <strtol+0x3a>
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad4:	3c 2d                	cmp    $0x2d,%al
  800ad6:	75 07                	jne    800adf <strtol+0x3a>
		s++, neg = 1;
  800ad8:	8d 49 01             	lea    0x1(%ecx),%ecx
  800adb:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	0f 94 c0             	sete   %al
  800ae4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aea:	75 19                	jne    800b05 <strtol+0x60>
  800aec:	80 39 30             	cmpb   $0x30,(%ecx)
  800aef:	75 14                	jne    800b05 <strtol+0x60>
  800af1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af5:	0f 85 8a 00 00 00    	jne    800b85 <strtol+0xe0>
		s += 2, base = 16;
  800afb:	83 c1 02             	add    $0x2,%ecx
  800afe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b03:	eb 16                	jmp    800b1b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b05:	84 c0                	test   %al,%al
  800b07:	74 12                	je     800b1b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b11:	75 08                	jne    800b1b <strtol+0x76>
		s++, base = 8;
  800b13:	83 c1 01             	add    $0x1,%ecx
  800b16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b23:	0f b6 11             	movzbl (%ecx),%edx
  800b26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b29:	89 f3                	mov    %esi,%ebx
  800b2b:	80 fb 09             	cmp    $0x9,%bl
  800b2e:	77 08                	ja     800b38 <strtol+0x93>
			dig = *s - '0';
  800b30:	0f be d2             	movsbl %dl,%edx
  800b33:	83 ea 30             	sub    $0x30,%edx
  800b36:	eb 22                	jmp    800b5a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b38:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3b:	89 f3                	mov    %esi,%ebx
  800b3d:	80 fb 19             	cmp    $0x19,%bl
  800b40:	77 08                	ja     800b4a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b42:	0f be d2             	movsbl %dl,%edx
  800b45:	83 ea 57             	sub    $0x57,%edx
  800b48:	eb 10                	jmp    800b5a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	80 fb 19             	cmp    $0x19,%bl
  800b52:	77 16                	ja     800b6a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b54:	0f be d2             	movsbl %dl,%edx
  800b57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5d:	7d 0f                	jge    800b6e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b68:	eb b9                	jmp    800b23 <strtol+0x7e>
  800b6a:	89 c2                	mov    %eax,%edx
  800b6c:	eb 02                	jmp    800b70 <strtol+0xcb>
  800b6e:	89 c2                	mov    %eax,%edx

	if (endptr)
  800b70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b74:	74 05                	je     800b7b <strtol+0xd6>
		*endptr = (char *) s;
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	74 0c                	je     800b8b <strtol+0xe6>
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	f7 d8                	neg    %eax
  800b83:	eb 06                	jmp    800b8b <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	84 c0                	test   %al,%al
  800b87:	75 8a                	jne    800b13 <strtol+0x6e>
  800b89:	eb 90                	jmp    800b1b <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	89 cb                	mov    %ecx,%ebx
  800be5:	89 cf                	mov    %ecx,%edi
  800be7:	89 ce                	mov    %ecx,%esi
  800be9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 17                	jle    800c06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 03                	push   $0x3
  800bf5:	68 df 23 80 00       	push   $0x8023df
  800bfa:	6a 23                	push   $0x23
  800bfc:	68 fc 23 80 00       	push   $0x8023fc
  800c01:	e8 df f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_yield>:

void
sys_yield(void)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3d:	89 d1                	mov    %edx,%ecx
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	89 d7                	mov    %edx,%edi
  800c43:	89 d6                	mov    %edx,%esi
  800c45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	be 00 00 00 00       	mov    $0x0,%esi
  800c5a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	89 f7                	mov    %esi,%edi
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 04                	push   $0x4
  800c76:	68 df 23 80 00       	push   $0x8023df
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 fc 23 80 00       	push   $0x8023fc
  800c82:	e8 5e f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 05                	push   $0x5
  800cb8:	68 df 23 80 00       	push   $0x8023df
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 fc 23 80 00       	push   $0x8023fc
  800cc4:	e8 1c f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 06                	push   $0x6
  800cfa:	68 df 23 80 00       	push   $0x8023df
  800cff:	6a 23                	push   $0x23
  800d01:	68 fc 23 80 00       	push   $0x8023fc
  800d06:	e8 da f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 08 00 00 00       	mov    $0x8,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 08                	push   $0x8
  800d3c:	68 df 23 80 00       	push   $0x8023df
  800d41:	6a 23                	push   $0x23
  800d43:	68 fc 23 80 00       	push   $0x8023fc
  800d48:	e8 98 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 09 00 00 00       	mov    $0x9,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 09                	push   $0x9
  800d7e:	68 df 23 80 00       	push   $0x8023df
  800d83:	6a 23                	push   $0x23
  800d85:	68 fc 23 80 00       	push   $0x8023fc
  800d8a:	e8 56 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 0a                	push   $0xa
  800dc0:	68 df 23 80 00       	push   $0x8023df
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 fc 23 80 00       	push   $0x8023fc
  800dcc:	e8 14 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	be 00 00 00 00       	mov    $0x0,%esi
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	89 cb                	mov    %ecx,%ebx
  800e14:	89 cf                	mov    %ecx,%edi
  800e16:	89 ce                	mov    %ecx,%esi
  800e18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	7e 17                	jle    800e35 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	50                   	push   %eax
  800e22:	6a 0d                	push   $0xd
  800e24:	68 df 23 80 00       	push   $0x8023df
  800e29:	6a 23                	push   $0x23
  800e2b:	68 fc 23 80 00       	push   $0x8023fc
  800e30:	e8 b0 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_gettime>:

int sys_gettime(void)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 d3                	mov    %edx,%ebx
  800e51:	89 d7                	mov    %edx,%edi
  800e53:	89 d6                	mov    %edx,%esi
  800e55:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	05 00 00 00 30       	add    $0x30000000,%eax
  800e67:	c1 e8 0c             	shr    $0xc,%eax
}
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e7c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	c1 ea 16             	shr    $0x16,%edx
  800e93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9a:	f6 c2 01             	test   $0x1,%dl
  800e9d:	74 11                	je     800eb0 <fd_alloc+0x2d>
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	c1 ea 0c             	shr    $0xc,%edx
  800ea4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	75 09                	jne    800eb9 <fd_alloc+0x36>
			*fd_store = fd;
  800eb0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	eb 17                	jmp    800ed0 <fd_alloc+0x4d>
  800eb9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ebe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ec3:	75 c9                	jne    800e8e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ec5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ecb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed8:	83 f8 1f             	cmp    $0x1f,%eax
  800edb:	77 36                	ja     800f13 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800edd:	c1 e0 0c             	shl    $0xc,%eax
  800ee0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	c1 ea 16             	shr    $0x16,%edx
  800eea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	74 24                	je     800f1a <fd_lookup+0x48>
  800ef6:	89 c2                	mov    %eax,%edx
  800ef8:	c1 ea 0c             	shr    $0xc,%edx
  800efb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f02:	f6 c2 01             	test   $0x1,%dl
  800f05:	74 1a                	je     800f21 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	eb 13                	jmp    800f26 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f18:	eb 0c                	jmp    800f26 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1f:	eb 05                	jmp    800f26 <fd_lookup+0x54>
  800f21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 08             	sub    $0x8,%esp
  800f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f31:	ba 88 24 80 00       	mov    $0x802488,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f36:	eb 13                	jmp    800f4b <dev_lookup+0x23>
  800f38:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f3b:	39 08                	cmp    %ecx,(%eax)
  800f3d:	75 0c                	jne    800f4b <dev_lookup+0x23>
			*dev = devtab[i];
  800f3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f42:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	eb 2e                	jmp    800f79 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f4b:	8b 02                	mov    (%edx),%eax
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	75 e7                	jne    800f38 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f51:	a1 08 40 80 00       	mov    0x804008,%eax
  800f56:	8b 40 48             	mov    0x48(%eax),%eax
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	51                   	push   %ecx
  800f5d:	50                   	push   %eax
  800f5e:	68 0c 24 80 00       	push   $0x80240c
  800f63:	e8 56 f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 10             	sub    $0x10,%esp
  800f83:	8b 75 08             	mov    0x8(%ebp),%esi
  800f86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f8d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f93:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f96:	50                   	push   %eax
  800f97:	e8 36 ff ff ff       	call   800ed2 <fd_lookup>
  800f9c:	83 c4 08             	add    $0x8,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 05                	js     800fa8 <fd_close+0x2d>
	    || fd != fd2)
  800fa3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa6:	74 0b                	je     800fb3 <fd_close+0x38>
		return (must_exist ? r : 0);
  800fa8:	80 fb 01             	cmp    $0x1,%bl
  800fab:	19 d2                	sbb    %edx,%edx
  800fad:	f7 d2                	not    %edx
  800faf:	21 d0                	and    %edx,%eax
  800fb1:	eb 41                	jmp    800ff4 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	ff 36                	pushl  (%esi)
  800fbc:	e8 67 ff ff ff       	call   800f28 <dev_lookup>
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 1a                	js     800fe4 <fd_close+0x69>
		if (dev->dev_close)
  800fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fd0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	74 0b                	je     800fe4 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	56                   	push   %esi
  800fdd:	ff d0                	call   *%eax
  800fdf:	89 c3                	mov    %eax,%ebx
  800fe1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 e2 fc ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	89 d8                	mov    %ebx,%eax
}
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 c5 fe ff ff       	call   800ed2 <fd_lookup>
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	83 c4 08             	add    $0x8,%esp
  801012:	85 d2                	test   %edx,%edx
  801014:	78 10                	js     801026 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	6a 01                	push   $0x1
  80101b:	ff 75 f4             	pushl  -0xc(%ebp)
  80101e:	e8 58 ff ff ff       	call   800f7b <fd_close>
  801023:	83 c4 10             	add    $0x10,%esp
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <close_all>:

void
close_all(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	53                   	push   %ebx
  80102c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	53                   	push   %ebx
  801038:	e8 be ff ff ff       	call   800ffb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80103d:	83 c3 01             	add    $0x1,%ebx
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	83 fb 20             	cmp    $0x20,%ebx
  801046:	75 ec                	jne    801034 <close_all+0xc>
		close(i);
}
  801048:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 2c             	sub    $0x2c,%esp
  801056:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801059:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	e8 6d fe ff ff       	call   800ed2 <fd_lookup>
  801065:	89 c2                	mov    %eax,%edx
  801067:	83 c4 08             	add    $0x8,%esp
  80106a:	85 d2                	test   %edx,%edx
  80106c:	0f 88 c1 00 00 00    	js     801133 <dup+0xe6>
		return r;
	close(newfdnum);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	56                   	push   %esi
  801076:	e8 80 ff ff ff       	call   800ffb <close>

	newfd = INDEX2FD(newfdnum);
  80107b:	89 f3                	mov    %esi,%ebx
  80107d:	c1 e3 0c             	shl    $0xc,%ebx
  801080:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801086:	83 c4 04             	add    $0x4,%esp
  801089:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108c:	e8 db fd ff ff       	call   800e6c <fd2data>
  801091:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801093:	89 1c 24             	mov    %ebx,(%esp)
  801096:	e8 d1 fd ff ff       	call   800e6c <fd2data>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a1:	89 f8                	mov    %edi,%eax
  8010a3:	c1 e8 16             	shr    $0x16,%eax
  8010a6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ad:	a8 01                	test   $0x1,%al
  8010af:	74 37                	je     8010e8 <dup+0x9b>
  8010b1:	89 f8                	mov    %edi,%eax
  8010b3:	c1 e8 0c             	shr    $0xc,%eax
  8010b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bd:	f6 c2 01             	test   $0x1,%dl
  8010c0:	74 26                	je     8010e8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d1:	50                   	push   %eax
  8010d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d5:	6a 00                	push   $0x0
  8010d7:	57                   	push   %edi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 b0 fb ff ff       	call   800c8f <sys_page_map>
  8010df:	89 c7                	mov    %eax,%edi
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 2e                	js     801116 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010eb:	89 d0                	mov    %edx,%eax
  8010ed:	c1 e8 0c             	shr    $0xc,%eax
  8010f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ff:	50                   	push   %eax
  801100:	53                   	push   %ebx
  801101:	6a 00                	push   $0x0
  801103:	52                   	push   %edx
  801104:	6a 00                	push   $0x0
  801106:	e8 84 fb ff ff       	call   800c8f <sys_page_map>
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801110:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801112:	85 ff                	test   %edi,%edi
  801114:	79 1d                	jns    801133 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	53                   	push   %ebx
  80111a:	6a 00                	push   $0x0
  80111c:	e8 b0 fb ff ff       	call   800cd1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	ff 75 d4             	pushl  -0x2c(%ebp)
  801127:	6a 00                	push   $0x0
  801129:	e8 a3 fb ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	89 f8                	mov    %edi,%eax
}
  801133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	53                   	push   %ebx
  80113f:	83 ec 14             	sub    $0x14,%esp
  801142:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	53                   	push   %ebx
  80114a:	e8 83 fd ff ff       	call   800ed2 <fd_lookup>
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	89 c2                	mov    %eax,%edx
  801154:	85 c0                	test   %eax,%eax
  801156:	78 6d                	js     8011c5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115e:	50                   	push   %eax
  80115f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801162:	ff 30                	pushl  (%eax)
  801164:	e8 bf fd ff ff       	call   800f28 <dev_lookup>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 4c                	js     8011bc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801170:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801173:	8b 42 08             	mov    0x8(%edx),%eax
  801176:	83 e0 03             	and    $0x3,%eax
  801179:	83 f8 01             	cmp    $0x1,%eax
  80117c:	75 21                	jne    80119f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80117e:	a1 08 40 80 00       	mov    0x804008,%eax
  801183:	8b 40 48             	mov    0x48(%eax),%eax
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	53                   	push   %ebx
  80118a:	50                   	push   %eax
  80118b:	68 4d 24 80 00       	push   $0x80244d
  801190:	e8 29 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119d:	eb 26                	jmp    8011c5 <read+0x8a>
	}
	if (!dev->dev_read)
  80119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a2:	8b 40 08             	mov    0x8(%eax),%eax
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	74 17                	je     8011c0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	ff 75 10             	pushl  0x10(%ebp)
  8011af:	ff 75 0c             	pushl  0xc(%ebp)
  8011b2:	52                   	push   %edx
  8011b3:	ff d0                	call   *%eax
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 09                	jmp    8011c5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	eb 05                	jmp    8011c5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011c5:	89 d0                	mov    %edx,%eax
  8011c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e0:	eb 21                	jmp    801203 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	89 f0                	mov    %esi,%eax
  8011e7:	29 d8                	sub    %ebx,%eax
  8011e9:	50                   	push   %eax
  8011ea:	89 d8                	mov    %ebx,%eax
  8011ec:	03 45 0c             	add    0xc(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	57                   	push   %edi
  8011f1:	e8 45 ff ff ff       	call   80113b <read>
		if (m < 0)
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 0c                	js     801209 <readn+0x3d>
			return m;
		if (m == 0)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 06                	je     801207 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801201:	01 c3                	add    %eax,%ebx
  801203:	39 f3                	cmp    %esi,%ebx
  801205:	72 db                	jb     8011e2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801207:	89 d8                	mov    %ebx,%eax
}
  801209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	83 ec 14             	sub    $0x14,%esp
  801218:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	53                   	push   %ebx
  801220:	e8 ad fc ff ff       	call   800ed2 <fd_lookup>
  801225:	83 c4 08             	add    $0x8,%esp
  801228:	89 c2                	mov    %eax,%edx
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 68                	js     801296 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801238:	ff 30                	pushl  (%eax)
  80123a:	e8 e9 fc ff ff       	call   800f28 <dev_lookup>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 47                	js     80128d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801249:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124d:	75 21                	jne    801270 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124f:	a1 08 40 80 00       	mov    0x804008,%eax
  801254:	8b 40 48             	mov    0x48(%eax),%eax
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	53                   	push   %ebx
  80125b:	50                   	push   %eax
  80125c:	68 69 24 80 00       	push   $0x802469
  801261:	e8 58 f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126e:	eb 26                	jmp    801296 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801270:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801273:	8b 52 0c             	mov    0xc(%edx),%edx
  801276:	85 d2                	test   %edx,%edx
  801278:	74 17                	je     801291 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	ff 75 10             	pushl  0x10(%ebp)
  801280:	ff 75 0c             	pushl  0xc(%ebp)
  801283:	50                   	push   %eax
  801284:	ff d2                	call   *%edx
  801286:	89 c2                	mov    %eax,%edx
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	eb 09                	jmp    801296 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	eb 05                	jmp    801296 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801291:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801296:	89 d0                	mov    %edx,%eax
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <seek>:

int
seek(int fdnum, off_t offset)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	ff 75 08             	pushl  0x8(%ebp)
  8012aa:	e8 23 fc ff ff       	call   800ed2 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 0e                	js     8012c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 14             	sub    $0x14,%esp
  8012cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	53                   	push   %ebx
  8012d5:	e8 f8 fb ff ff       	call   800ed2 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 65                	js     801348 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	ff 30                	pushl  (%eax)
  8012ef:	e8 34 fc ff ff       	call   800f28 <dev_lookup>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 44                	js     80133f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801302:	75 21                	jne    801325 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801304:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801309:	8b 40 48             	mov    0x48(%eax),%eax
  80130c:	83 ec 04             	sub    $0x4,%esp
  80130f:	53                   	push   %ebx
  801310:	50                   	push   %eax
  801311:	68 2c 24 80 00       	push   $0x80242c
  801316:	e8 a3 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801323:	eb 23                	jmp    801348 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801325:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801328:	8b 52 18             	mov    0x18(%edx),%edx
  80132b:	85 d2                	test   %edx,%edx
  80132d:	74 14                	je     801343 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	ff 75 0c             	pushl  0xc(%ebp)
  801335:	50                   	push   %eax
  801336:	ff d2                	call   *%edx
  801338:	89 c2                	mov    %eax,%edx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	eb 09                	jmp    801348 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	89 c2                	mov    %eax,%edx
  801341:	eb 05                	jmp    801348 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801343:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801348:	89 d0                	mov    %edx,%eax
  80134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 14             	sub    $0x14,%esp
  801356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801359:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	ff 75 08             	pushl  0x8(%ebp)
  801360:	e8 6d fb ff ff       	call   800ed2 <fd_lookup>
  801365:	83 c4 08             	add    $0x8,%esp
  801368:	89 c2                	mov    %eax,%edx
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 58                	js     8013c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801374:	50                   	push   %eax
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	ff 30                	pushl  (%eax)
  80137a:	e8 a9 fb ff ff       	call   800f28 <dev_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 37                	js     8013bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801389:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80138d:	74 32                	je     8013c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80138f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801392:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801399:	00 00 00 
	stat->st_isdir = 0;
  80139c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a3:	00 00 00 
	stat->st_dev = dev;
  8013a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	53                   	push   %ebx
  8013b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b3:	ff 50 14             	call   *0x14(%eax)
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	eb 09                	jmp    8013c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	eb 05                	jmp    8013c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c6:	89 d0                	mov    %edx,%eax
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	6a 00                	push   $0x0
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 e7 01 00 00       	call   8015c6 <open>
  8013df:	89 c3                	mov    %eax,%ebx
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 db                	test   %ebx,%ebx
  8013e6:	78 1b                	js     801403 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	53                   	push   %ebx
  8013ef:	e8 5b ff ff ff       	call   80134f <fstat>
  8013f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f6:	89 1c 24             	mov    %ebx,(%esp)
  8013f9:	e8 fd fb ff ff       	call   800ffb <close>
	return r;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 f0                	mov    %esi,%eax
}
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801413:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80141a:	75 12                	jne    80142e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	6a 03                	push   $0x3
  801421:	e8 e6 08 00 00       	call   801d0c <ipc_find_env>
  801426:	a3 04 40 80 00       	mov    %eax,0x804004
  80142b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142e:	6a 07                	push   $0x7
  801430:	68 00 50 80 00       	push   $0x805000
  801435:	56                   	push   %esi
  801436:	ff 35 04 40 80 00    	pushl  0x804004
  80143c:	e8 7a 08 00 00       	call   801cbb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801441:	83 c4 0c             	add    $0xc,%esp
  801444:	6a 00                	push   $0x0
  801446:	53                   	push   %ebx
  801447:	6a 00                	push   $0x0
  801449:	e8 07 08 00 00       	call   801c55 <ipc_recv>
}
  80144e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	8b 40 0c             	mov    0xc(%eax),%eax
  801461:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801466:	8b 45 0c             	mov    0xc(%ebp),%eax
  801469:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146e:	ba 00 00 00 00       	mov    $0x0,%edx
  801473:	b8 02 00 00 00       	mov    $0x2,%eax
  801478:	e8 8d ff ff ff       	call   80140a <fsipc>
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
  801488:	8b 40 0c             	mov    0xc(%eax),%eax
  80148b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801490:	ba 00 00 00 00       	mov    $0x0,%edx
  801495:	b8 06 00 00 00       	mov    $0x6,%eax
  80149a:	e8 6b ff ff ff       	call   80140a <fsipc>
}
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    

008014a1 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c0:	e8 45 ff ff ff       	call   80140a <fsipc>
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 d2                	test   %edx,%edx
  8014c9:	78 2c                	js     8014f7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	53                   	push   %ebx
  8014d4:	e8 69 f3 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801505:	8b 55 08             	mov    0x8(%ebp),%edx
  801508:	8b 52 0c             	mov    0xc(%edx),%edx
  80150b:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801511:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801516:	76 05                	jbe    80151d <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801518:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  80151d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801522:	83 ec 04             	sub    $0x4,%esp
  801525:	50                   	push   %eax
  801526:	ff 75 0c             	pushl  0xc(%ebp)
  801529:	68 08 50 80 00       	push   $0x805008
  80152e:	e8 a1 f4 ff ff       	call   8009d4 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801533:	ba 00 00 00 00       	mov    $0x0,%edx
  801538:	b8 04 00 00 00       	mov    $0x4,%eax
  80153d:	e8 c8 fe ff ff       	call   80140a <fsipc>
	return write;
}
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	8b 40 0c             	mov    0xc(%eax),%eax
  801552:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801557:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	b8 03 00 00 00       	mov    $0x3,%eax
  801567:	e8 9e fe ff ff       	call   80140a <fsipc>
  80156c:	89 c3                	mov    %eax,%ebx
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 4b                	js     8015bd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801572:	39 c6                	cmp    %eax,%esi
  801574:	73 16                	jae    80158c <devfile_read+0x48>
  801576:	68 98 24 80 00       	push   $0x802498
  80157b:	68 9f 24 80 00       	push   $0x80249f
  801580:	6a 7c                	push   $0x7c
  801582:	68 b4 24 80 00       	push   $0x8024b4
  801587:	e8 59 ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  80158c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801591:	7e 16                	jle    8015a9 <devfile_read+0x65>
  801593:	68 bf 24 80 00       	push   $0x8024bf
  801598:	68 9f 24 80 00       	push   $0x80249f
  80159d:	6a 7d                	push   $0x7d
  80159f:	68 b4 24 80 00       	push   $0x8024b4
  8015a4:	e8 3c ec ff ff       	call   8001e5 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	50                   	push   %eax
  8015ad:	68 00 50 80 00       	push   $0x805000
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	e8 1a f4 ff ff       	call   8009d4 <memmove>
	return r;
  8015ba:	83 c4 10             	add    $0x10,%esp
}
  8015bd:	89 d8                	mov    %ebx,%eax
  8015bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c2:	5b                   	pop    %ebx
  8015c3:	5e                   	pop    %esi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 20             	sub    $0x20,%esp
  8015cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d0:	53                   	push   %ebx
  8015d1:	e8 33 f2 ff ff       	call   800809 <strlen>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015de:	7f 67                	jg     801647 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	e8 97 f8 ff ff       	call   800e83 <fd_alloc>
  8015ec:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ef:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 57                	js     80164c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	68 00 50 80 00       	push   $0x805000
  8015fe:	e8 3f f2 ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801603:	8b 45 0c             	mov    0xc(%ebp),%eax
  801606:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160e:	b8 01 00 00 00       	mov    $0x1,%eax
  801613:	e8 f2 fd ff ff       	call   80140a <fsipc>
  801618:	89 c3                	mov    %eax,%ebx
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	79 14                	jns    801635 <open+0x6f>
		fd_close(fd, 0);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	6a 00                	push   $0x0
  801626:	ff 75 f4             	pushl  -0xc(%ebp)
  801629:	e8 4d f9 ff ff       	call   800f7b <fd_close>
		return r;
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	89 da                	mov    %ebx,%edx
  801633:	eb 17                	jmp    80164c <open+0x86>
	}

	return fd2num(fd);
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	ff 75 f4             	pushl  -0xc(%ebp)
  80163b:	e8 1c f8 ff ff       	call   800e5c <fd2num>
  801640:	89 c2                	mov    %eax,%edx
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	eb 05                	jmp    80164c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801647:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164c:	89 d0                	mov    %edx,%eax
  80164e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801659:	ba 00 00 00 00       	mov    $0x0,%edx
  80165e:	b8 08 00 00 00       	mov    $0x8,%eax
  801663:	e8 a2 fd ff ff       	call   80140a <fsipc>
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80166a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80166e:	7e 3a                	jle    8016aa <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	53                   	push   %ebx
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801679:	ff 70 04             	pushl  0x4(%eax)
  80167c:	8d 40 10             	lea    0x10(%eax),%eax
  80167f:	50                   	push   %eax
  801680:	ff 33                	pushl  (%ebx)
  801682:	e8 8a fb ff ff       	call   801211 <write>
		if (result > 0)
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	7e 03                	jle    801691 <writebuf+0x27>
			b->result += result;
  80168e:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801691:	39 43 04             	cmp    %eax,0x4(%ebx)
  801694:	74 10                	je     8016a6 <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  801696:	85 c0                	test   %eax,%eax
  801698:	0f 9f c2             	setg   %dl
  80169b:	0f b6 d2             	movzbl %dl,%edx
  80169e:	83 ea 01             	sub    $0x1,%edx
  8016a1:	21 d0                	and    %edx,%eax
  8016a3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	f3 c3                	repz ret 

008016ac <putch>:

static void
putch(int ch, void *thunk)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016b6:	8b 53 04             	mov    0x4(%ebx),%edx
  8016b9:	8d 42 01             	lea    0x1(%edx),%eax
  8016bc:	89 43 04             	mov    %eax,0x4(%ebx)
  8016bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c2:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016c6:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016cb:	75 0e                	jne    8016db <putch+0x2f>
		writebuf(b);
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	e8 96 ff ff ff       	call   80166a <writebuf>
		b->idx = 0;
  8016d4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016db:	83 c4 04             	add    $0x4,%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016f3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016fa:	00 00 00 
	b.result = 0;
  8016fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801704:	00 00 00 
	b.error = 1;
  801707:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80170e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801711:	ff 75 10             	pushl  0x10(%ebp)
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	68 ac 16 80 00       	push   $0x8016ac
  801723:	e8 c8 ec ff ff       	call   8003f0 <vprintfmt>
	if (b.idx > 0)
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801732:	7e 0b                	jle    80173f <vfprintf+0x5e>
		writebuf(&b);
  801734:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173a:	e8 2b ff ff ff       	call   80166a <writebuf>

	return (b.result ? b.result : b.error);
  80173f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801745:	85 c0                	test   %eax,%eax
  801747:	75 06                	jne    80174f <vfprintf+0x6e>
  801749:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801757:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80175a:	50                   	push   %eax
  80175b:	ff 75 0c             	pushl  0xc(%ebp)
  80175e:	ff 75 08             	pushl  0x8(%ebp)
  801761:	e8 7b ff ff ff       	call   8016e1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <printf>:

int
printf(const char *fmt, ...)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80176e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801771:	50                   	push   %eax
  801772:	ff 75 08             	pushl  0x8(%ebp)
  801775:	6a 01                	push   $0x1
  801777:	e8 65 ff ff ff       	call   8016e1 <vfprintf>
	va_end(ap);

	return cnt;
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	ff 75 08             	pushl  0x8(%ebp)
  80178c:	e8 db f6 ff ff       	call   800e6c <fd2data>
  801791:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801793:	83 c4 08             	add    $0x8,%esp
  801796:	68 cb 24 80 00       	push   $0x8024cb
  80179b:	53                   	push   %ebx
  80179c:	e8 a1 f0 ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a1:	8b 56 04             	mov    0x4(%esi),%edx
  8017a4:	89 d0                	mov    %edx,%eax
  8017a6:	2b 06                	sub    (%esi),%eax
  8017a8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b5:	00 00 00 
	stat->st_dev = &devpipe;
  8017b8:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017bf:	30 80 00 
	return 0;
}
  8017c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d8:	53                   	push   %ebx
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 f1 f4 ff ff       	call   800cd1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 84 f6 ff ff       	call   800e6c <fd2data>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	50                   	push   %eax
  8017ec:	6a 00                	push   $0x0
  8017ee:	e8 de f4 ff ff       	call   800cd1 <sys_page_unmap>
}
  8017f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	57                   	push   %edi
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 1c             	sub    $0x1c,%esp
  801801:	89 c7                	mov    %eax,%edi
  801803:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801805:	a1 08 40 80 00       	mov    0x804008,%eax
  80180a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	57                   	push   %edi
  801811:	e8 2e 05 00 00       	call   801d44 <pageref>
  801816:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801819:	89 34 24             	mov    %esi,(%esp)
  80181c:	e8 23 05 00 00       	call   801d44 <pageref>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801827:	0f 94 c0             	sete   %al
  80182a:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80182d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801833:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801836:	39 cb                	cmp    %ecx,%ebx
  801838:	74 15                	je     80184f <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  80183a:	8b 52 58             	mov    0x58(%edx),%edx
  80183d:	50                   	push   %eax
  80183e:	52                   	push   %edx
  80183f:	53                   	push   %ebx
  801840:	68 d8 24 80 00       	push   $0x8024d8
  801845:	e8 74 ea ff ff       	call   8002be <cprintf>
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	eb b6                	jmp    801805 <_pipeisclosed+0xd>
	}
}
  80184f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	57                   	push   %edi
  80185b:	56                   	push   %esi
  80185c:	53                   	push   %ebx
  80185d:	83 ec 28             	sub    $0x28,%esp
  801860:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801863:	56                   	push   %esi
  801864:	e8 03 f6 ff ff       	call   800e6c <fd2data>
  801869:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	bf 00 00 00 00       	mov    $0x0,%edi
  801873:	eb 4b                	jmp    8018c0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801875:	89 da                	mov    %ebx,%edx
  801877:	89 f0                	mov    %esi,%eax
  801879:	e8 7a ff ff ff       	call   8017f8 <_pipeisclosed>
  80187e:	85 c0                	test   %eax,%eax
  801880:	75 48                	jne    8018ca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801882:	e8 a6 f3 ff ff       	call   800c2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801887:	8b 43 04             	mov    0x4(%ebx),%eax
  80188a:	8b 0b                	mov    (%ebx),%ecx
  80188c:	8d 51 20             	lea    0x20(%ecx),%edx
  80188f:	39 d0                	cmp    %edx,%eax
  801891:	73 e2                	jae    801875 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801896:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80189a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	c1 fa 1f             	sar    $0x1f,%edx
  8018a2:	89 d1                	mov    %edx,%ecx
  8018a4:	c1 e9 1b             	shr    $0x1b,%ecx
  8018a7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018aa:	83 e2 1f             	and    $0x1f,%edx
  8018ad:	29 ca                	sub    %ecx,%edx
  8018af:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b7:	83 c0 01             	add    $0x1,%eax
  8018ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018bd:	83 c7 01             	add    $0x1,%edi
  8018c0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018c3:	75 c2                	jne    801887 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c8:	eb 05                	jmp    8018cf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 18             	sub    $0x18,%esp
  8018e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018e3:	57                   	push   %edi
  8018e4:	e8 83 f5 ff ff       	call   800e6c <fd2data>
  8018e9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f3:	eb 3d                	jmp    801932 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018f5:	85 db                	test   %ebx,%ebx
  8018f7:	74 04                	je     8018fd <devpipe_read+0x26>
				return i;
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	eb 44                	jmp    801941 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018fd:	89 f2                	mov    %esi,%edx
  8018ff:	89 f8                	mov    %edi,%eax
  801901:	e8 f2 fe ff ff       	call   8017f8 <_pipeisclosed>
  801906:	85 c0                	test   %eax,%eax
  801908:	75 32                	jne    80193c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80190a:	e8 1e f3 ff ff       	call   800c2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80190f:	8b 06                	mov    (%esi),%eax
  801911:	3b 46 04             	cmp    0x4(%esi),%eax
  801914:	74 df                	je     8018f5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801916:	99                   	cltd   
  801917:	c1 ea 1b             	shr    $0x1b,%edx
  80191a:	01 d0                	add    %edx,%eax
  80191c:	83 e0 1f             	and    $0x1f,%eax
  80191f:	29 d0                	sub    %edx,%eax
  801921:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801929:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80192c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192f:	83 c3 01             	add    $0x1,%ebx
  801932:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801935:	75 d8                	jne    80190f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
  80193a:	eb 05                	jmp    801941 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80193c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801941:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5f                   	pop    %edi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	e8 29 f5 ff ff       	call   800e83 <fd_alloc>
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	85 c0                	test   %eax,%eax
  801961:	0f 88 2c 01 00 00    	js     801a93 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801967:	83 ec 04             	sub    $0x4,%esp
  80196a:	68 07 04 00 00       	push   $0x407
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	6a 00                	push   $0x0
  801974:	e8 d3 f2 ff ff       	call   800c4c <sys_page_alloc>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	85 c0                	test   %eax,%eax
  801980:	0f 88 0d 01 00 00    	js     801a93 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	e8 f1 f4 ff ff       	call   800e83 <fd_alloc>
  801992:	89 c3                	mov    %eax,%ebx
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	85 c0                	test   %eax,%eax
  801999:	0f 88 e2 00 00 00    	js     801a81 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	68 07 04 00 00       	push   $0x407
  8019a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 9b f2 ff ff       	call   800c4c <sys_page_alloc>
  8019b1:	89 c3                	mov    %eax,%ebx
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	0f 88 c3 00 00 00    	js     801a81 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c4:	e8 a3 f4 ff ff       	call   800e6c <fd2data>
  8019c9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019cb:	83 c4 0c             	add    $0xc,%esp
  8019ce:	68 07 04 00 00       	push   $0x407
  8019d3:	50                   	push   %eax
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 71 f2 ff ff       	call   800c4c <sys_page_alloc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	0f 88 89 00 00 00    	js     801a71 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ee:	e8 79 f4 ff ff       	call   800e6c <fd2data>
  8019f3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019fa:	50                   	push   %eax
  8019fb:	6a 00                	push   $0x0
  8019fd:	56                   	push   %esi
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 8a f2 ff ff       	call   800c8f <sys_page_map>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	83 c4 20             	add    $0x20,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 55                	js     801a63 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a0e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a23:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a31:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3e:	e8 19 f4 ff ff       	call   800e5c <fd2num>
  801a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a46:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a48:	83 c4 04             	add    $0x4,%esp
  801a4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4e:	e8 09 f4 ff ff       	call   800e5c <fd2num>
  801a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a56:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a61:	eb 30                	jmp    801a93 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	56                   	push   %esi
  801a67:	6a 00                	push   $0x0
  801a69:	e8 63 f2 ff ff       	call   800cd1 <sys_page_unmap>
  801a6e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	ff 75 f0             	pushl  -0x10(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 53 f2 ff ff       	call   800cd1 <sys_page_unmap>
  801a7e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	ff 75 f4             	pushl  -0xc(%ebp)
  801a87:	6a 00                	push   $0x0
  801a89:	e8 43 f2 ff ff       	call   800cd1 <sys_page_unmap>
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a93:	89 d0                	mov    %edx,%eax
  801a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa5:	50                   	push   %eax
  801aa6:	ff 75 08             	pushl  0x8(%ebp)
  801aa9:	e8 24 f4 ff ff       	call   800ed2 <fd_lookup>
  801aae:	89 c2                	mov    %eax,%edx
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 d2                	test   %edx,%edx
  801ab5:	78 18                	js     801acf <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	ff 75 f4             	pushl  -0xc(%ebp)
  801abd:	e8 aa f3 ff ff       	call   800e6c <fd2data>
	return _pipeisclosed(fd, p);
  801ac2:	89 c2                	mov    %eax,%edx
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	e8 2c fd ff ff       	call   8017f8 <_pipeisclosed>
  801acc:	83 c4 10             	add    $0x10,%esp
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ae1:	68 0c 25 80 00       	push   $0x80250c
  801ae6:	ff 75 0c             	pushl  0xc(%ebp)
  801ae9:	e8 54 ed ff ff       	call   800842 <strcpy>
	return 0;
}
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	57                   	push   %edi
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b01:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b06:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0c:	eb 2e                	jmp    801b3c <devcons_write+0x47>
		m = n - tot;
  801b0e:	8b 55 10             	mov    0x10(%ebp),%edx
  801b11:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801b13:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801b18:	83 fa 7f             	cmp    $0x7f,%edx
  801b1b:	77 02                	ja     801b1f <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b1d:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b1f:	83 ec 04             	sub    $0x4,%esp
  801b22:	56                   	push   %esi
  801b23:	03 45 0c             	add    0xc(%ebp),%eax
  801b26:	50                   	push   %eax
  801b27:	57                   	push   %edi
  801b28:	e8 a7 ee ff ff       	call   8009d4 <memmove>
		sys_cputs(buf, m);
  801b2d:	83 c4 08             	add    $0x8,%esp
  801b30:	56                   	push   %esi
  801b31:	57                   	push   %edi
  801b32:	e8 59 f0 ff ff       	call   800b90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b37:	01 f3                	add    %esi,%ebx
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	89 d8                	mov    %ebx,%eax
  801b3e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b41:	72 cb                	jb     801b0e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801b56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5a:	75 07                	jne    801b63 <devcons_read+0x18>
  801b5c:	eb 28                	jmp    801b86 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b5e:	e8 ca f0 ff ff       	call   800c2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b63:	e8 46 f0 ff ff       	call   800bae <sys_cgetc>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	74 f2                	je     801b5e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 16                	js     801b86 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b70:	83 f8 04             	cmp    $0x4,%eax
  801b73:	74 0c                	je     801b81 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b78:	88 02                	mov    %al,(%edx)
	return 1;
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	eb 05                	jmp    801b86 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b94:	6a 01                	push   $0x1
  801b96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b99:	50                   	push   %eax
  801b9a:	e8 f1 ef ff ff       	call   800b90 <sys_cputs>
  801b9f:	83 c4 10             	add    $0x10,%esp
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <getchar>:

int
getchar(void)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801baa:	6a 01                	push   $0x1
  801bac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801baf:	50                   	push   %eax
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 84 f5 ff ff       	call   80113b <read>
	if (r < 0)
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 0f                	js     801bcd <getchar+0x29>
		return r;
	if (r < 1)
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	7e 06                	jle    801bc8 <getchar+0x24>
		return -E_EOF;
	return c;
  801bc2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bc6:	eb 05                	jmp    801bcd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bc8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd8:	50                   	push   %eax
  801bd9:	ff 75 08             	pushl  0x8(%ebp)
  801bdc:	e8 f1 f2 ff ff       	call   800ed2 <fd_lookup>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 11                	js     801bf9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bf1:	39 10                	cmp    %edx,(%eax)
  801bf3:	0f 94 c0             	sete   %al
  801bf6:	0f b6 c0             	movzbl %al,%eax
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <opencons>:

int
opencons(void)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c04:	50                   	push   %eax
  801c05:	e8 79 f2 ff ff       	call   800e83 <fd_alloc>
  801c0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c0d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 3e                	js     801c51 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	68 07 04 00 00       	push   $0x407
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 27 f0 ff ff       	call   800c4c <sys_page_alloc>
  801c25:	83 c4 10             	add    $0x10,%esp
		return r;
  801c28:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 23                	js     801c51 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c2e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	50                   	push   %eax
  801c47:	e8 10 f2 ff ff       	call   800e5c <fd2num>
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	83 c4 10             	add    $0x10,%esp
}
  801c51:	89 d0                	mov    %edx,%eax
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	56                   	push   %esi
  801c59:	53                   	push   %ebx
  801c5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801c63:	85 f6                	test   %esi,%esi
  801c65:	74 06                	je     801c6d <ipc_recv+0x18>
  801c67:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801c6d:	85 db                	test   %ebx,%ebx
  801c6f:	74 06                	je     801c77 <ipc_recv+0x22>
  801c71:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801c77:	83 f8 01             	cmp    $0x1,%eax
  801c7a:	19 d2                	sbb    %edx,%edx
  801c7c:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	50                   	push   %eax
  801c82:	e8 75 f1 ff ff       	call   800dfc <sys_ipc_recv>
  801c87:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 d2                	test   %edx,%edx
  801c8e:	75 24                	jne    801cb4 <ipc_recv+0x5f>
	if (from_env_store)
  801c90:	85 f6                	test   %esi,%esi
  801c92:	74 0a                	je     801c9e <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801c94:	a1 08 40 80 00       	mov    0x804008,%eax
  801c99:	8b 40 70             	mov    0x70(%eax),%eax
  801c9c:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801c9e:	85 db                	test   %ebx,%ebx
  801ca0:	74 0a                	je     801cac <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801ca2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ca7:	8b 40 74             	mov    0x74(%eax),%eax
  801caa:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801cac:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb1:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	57                   	push   %edi
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801ccd:	83 fb 01             	cmp    $0x1,%ebx
  801cd0:	19 c0                	sbb    %eax,%eax
  801cd2:	09 c3                	or     %eax,%ebx
  801cd4:	eb 1c                	jmp    801cf2 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801cd6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cd9:	74 12                	je     801ced <ipc_send+0x32>
  801cdb:	50                   	push   %eax
  801cdc:	68 18 25 80 00       	push   $0x802518
  801ce1:	6a 36                	push   $0x36
  801ce3:	68 2f 25 80 00       	push   $0x80252f
  801ce8:	e8 f8 e4 ff ff       	call   8001e5 <_panic>
		sys_yield();
  801ced:	e8 3b ef ff ff       	call   800c2d <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801cf2:	ff 75 14             	pushl  0x14(%ebp)
  801cf5:	53                   	push   %ebx
  801cf6:	56                   	push   %esi
  801cf7:	57                   	push   %edi
  801cf8:	e8 dc f0 ff ff       	call   800dd9 <sys_ipc_try_send>
		if (ret == 0) break;
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	75 d2                	jne    801cd6 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d17:	6b d0 78             	imul   $0x78,%eax,%edx
  801d1a:	83 c2 50             	add    $0x50,%edx
  801d1d:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801d23:	39 ca                	cmp    %ecx,%edx
  801d25:	75 0d                	jne    801d34 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d27:	6b c0 78             	imul   $0x78,%eax,%eax
  801d2a:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801d2f:	8b 40 08             	mov    0x8(%eax),%eax
  801d32:	eb 0e                	jmp    801d42 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d34:	83 c0 01             	add    $0x1,%eax
  801d37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d3c:	75 d9                	jne    801d17 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d3e:	66 b8 00 00          	mov    $0x0,%ax
}
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	c1 e8 16             	shr    $0x16,%eax
  801d4f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d5b:	f6 c1 01             	test   $0x1,%cl
  801d5e:	74 1d                	je     801d7d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d60:	c1 ea 0c             	shr    $0xc,%edx
  801d63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d6a:	f6 c2 01             	test   $0x1,%dl
  801d6d:	74 0e                	je     801d7d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d6f:	c1 ea 0c             	shr    $0xc,%edx
  801d72:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d79:	ef 
  801d7a:	0f b7 c0             	movzwl %ax,%eax
}
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    
  801d7f:	90                   	nop

00801d80 <__udivdi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	83 ec 10             	sub    $0x10,%esp
  801d86:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801d8a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d8e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801d92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d96:	85 d2                	test   %edx,%edx
  801d98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d9c:	89 34 24             	mov    %esi,(%esp)
  801d9f:	89 c8                	mov    %ecx,%eax
  801da1:	75 35                	jne    801dd8 <__udivdi3+0x58>
  801da3:	39 f1                	cmp    %esi,%ecx
  801da5:	0f 87 bd 00 00 00    	ja     801e68 <__udivdi3+0xe8>
  801dab:	85 c9                	test   %ecx,%ecx
  801dad:	89 cd                	mov    %ecx,%ebp
  801daf:	75 0b                	jne    801dbc <__udivdi3+0x3c>
  801db1:	b8 01 00 00 00       	mov    $0x1,%eax
  801db6:	31 d2                	xor    %edx,%edx
  801db8:	f7 f1                	div    %ecx
  801dba:	89 c5                	mov    %eax,%ebp
  801dbc:	89 f0                	mov    %esi,%eax
  801dbe:	31 d2                	xor    %edx,%edx
  801dc0:	f7 f5                	div    %ebp
  801dc2:	89 c6                	mov    %eax,%esi
  801dc4:	89 f8                	mov    %edi,%eax
  801dc6:	f7 f5                	div    %ebp
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    
  801dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	3b 14 24             	cmp    (%esp),%edx
  801ddb:	77 7b                	ja     801e58 <__udivdi3+0xd8>
  801ddd:	0f bd f2             	bsr    %edx,%esi
  801de0:	83 f6 1f             	xor    $0x1f,%esi
  801de3:	0f 84 97 00 00 00    	je     801e80 <__udivdi3+0x100>
  801de9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801dee:	89 d7                	mov    %edx,%edi
  801df0:	89 f1                	mov    %esi,%ecx
  801df2:	29 f5                	sub    %esi,%ebp
  801df4:	d3 e7                	shl    %cl,%edi
  801df6:	89 c2                	mov    %eax,%edx
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	d3 ea                	shr    %cl,%edx
  801dfc:	89 f1                	mov    %esi,%ecx
  801dfe:	09 fa                	or     %edi,%edx
  801e00:	8b 3c 24             	mov    (%esp),%edi
  801e03:	d3 e0                	shl    %cl,%eax
  801e05:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e13:	89 fa                	mov    %edi,%edx
  801e15:	d3 ea                	shr    %cl,%edx
  801e17:	89 f1                	mov    %esi,%ecx
  801e19:	d3 e7                	shl    %cl,%edi
  801e1b:	89 e9                	mov    %ebp,%ecx
  801e1d:	d3 e8                	shr    %cl,%eax
  801e1f:	09 c7                	or     %eax,%edi
  801e21:	89 f8                	mov    %edi,%eax
  801e23:	f7 74 24 08          	divl   0x8(%esp)
  801e27:	89 d5                	mov    %edx,%ebp
  801e29:	89 c7                	mov    %eax,%edi
  801e2b:	f7 64 24 0c          	mull   0xc(%esp)
  801e2f:	39 d5                	cmp    %edx,%ebp
  801e31:	89 14 24             	mov    %edx,(%esp)
  801e34:	72 11                	jb     801e47 <__udivdi3+0xc7>
  801e36:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e3a:	89 f1                	mov    %esi,%ecx
  801e3c:	d3 e2                	shl    %cl,%edx
  801e3e:	39 c2                	cmp    %eax,%edx
  801e40:	73 5e                	jae    801ea0 <__udivdi3+0x120>
  801e42:	3b 2c 24             	cmp    (%esp),%ebp
  801e45:	75 59                	jne    801ea0 <__udivdi3+0x120>
  801e47:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e4a:	31 f6                	xor    %esi,%esi
  801e4c:	89 f2                	mov    %esi,%edx
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
  801e58:	31 f6                	xor    %esi,%esi
  801e5a:	31 c0                	xor    %eax,%eax
  801e5c:	89 f2                	mov    %esi,%edx
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	5e                   	pop    %esi
  801e62:	5f                   	pop    %edi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    
  801e65:	8d 76 00             	lea    0x0(%esi),%esi
  801e68:	89 f2                	mov    %esi,%edx
  801e6a:	31 f6                	xor    %esi,%esi
  801e6c:	89 f8                	mov    %edi,%eax
  801e6e:	f7 f1                	div    %ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e84:	76 0b                	jbe    801e91 <__udivdi3+0x111>
  801e86:	31 c0                	xor    %eax,%eax
  801e88:	3b 14 24             	cmp    (%esp),%edx
  801e8b:	0f 83 37 ff ff ff    	jae    801dc8 <__udivdi3+0x48>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	e9 2d ff ff ff       	jmp    801dc8 <__udivdi3+0x48>
  801e9b:	90                   	nop
  801e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	89 f8                	mov    %edi,%eax
  801ea2:	31 f6                	xor    %esi,%esi
  801ea4:	e9 1f ff ff ff       	jmp    801dc8 <__udivdi3+0x48>
  801ea9:	66 90                	xchg   %ax,%ax
  801eab:	66 90                	xchg   %ax,%ax
  801ead:	66 90                	xchg   %ax,%ax
  801eaf:	90                   	nop

00801eb0 <__umoddi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	83 ec 20             	sub    $0x20,%esp
  801eb6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801eba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ebe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec2:	89 c6                	mov    %eax,%esi
  801ec4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ec8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ecc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ed0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ed4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ed8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801edc:	85 c0                	test   %eax,%eax
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	75 1e                	jne    801f00 <__umoddi3+0x50>
  801ee2:	39 f7                	cmp    %esi,%edi
  801ee4:	76 52                	jbe    801f38 <__umoddi3+0x88>
  801ee6:	89 c8                	mov    %ecx,%eax
  801ee8:	89 f2                	mov    %esi,%edx
  801eea:	f7 f7                	div    %edi
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	83 c4 20             	add    $0x20,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
  801ef7:	89 f6                	mov    %esi,%esi
  801ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f00:	39 f0                	cmp    %esi,%eax
  801f02:	77 5c                	ja     801f60 <__umoddi3+0xb0>
  801f04:	0f bd e8             	bsr    %eax,%ebp
  801f07:	83 f5 1f             	xor    $0x1f,%ebp
  801f0a:	75 64                	jne    801f70 <__umoddi3+0xc0>
  801f0c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801f10:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801f14:	0f 86 f6 00 00 00    	jbe    802010 <__umoddi3+0x160>
  801f1a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801f1e:	0f 82 ec 00 00 00    	jb     802010 <__umoddi3+0x160>
  801f24:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f28:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f2c:	83 c4 20             	add    $0x20,%esp
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
  801f33:	90                   	nop
  801f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f38:	85 ff                	test   %edi,%edi
  801f3a:	89 fd                	mov    %edi,%ebp
  801f3c:	75 0b                	jne    801f49 <__umoddi3+0x99>
  801f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f43:	31 d2                	xor    %edx,%edx
  801f45:	f7 f7                	div    %edi
  801f47:	89 c5                	mov    %eax,%ebp
  801f49:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	f7 f5                	div    %ebp
  801f51:	89 c8                	mov    %ecx,%eax
  801f53:	f7 f5                	div    %ebp
  801f55:	eb 95                	jmp    801eec <__umoddi3+0x3c>
  801f57:	89 f6                	mov    %esi,%esi
  801f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 f2                	mov    %esi,%edx
  801f64:	83 c4 20             	add    $0x20,%esp
  801f67:	5e                   	pop    %esi
  801f68:	5f                   	pop    %edi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	90                   	nop
  801f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f70:	b8 20 00 00 00       	mov    $0x20,%eax
  801f75:	89 e9                	mov    %ebp,%ecx
  801f77:	29 e8                	sub    %ebp,%eax
  801f79:	d3 e2                	shl    %cl,%edx
  801f7b:	89 c7                	mov    %eax,%edi
  801f7d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f81:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	d3 e8                	shr    %cl,%eax
  801f89:	89 c1                	mov    %eax,%ecx
  801f8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f8f:	09 d1                	or     %edx,%ecx
  801f91:	89 fa                	mov    %edi,%edx
  801f93:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f97:	89 e9                	mov    %ebp,%ecx
  801f99:	d3 e0                	shl    %cl,%eax
  801f9b:	89 f9                	mov    %edi,%ecx
  801f9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa1:	89 f0                	mov    %esi,%eax
  801fa3:	d3 e8                	shr    %cl,%eax
  801fa5:	89 e9                	mov    %ebp,%ecx
  801fa7:	89 c7                	mov    %eax,%edi
  801fa9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fad:	d3 e6                	shl    %cl,%esi
  801faf:	89 d1                	mov    %edx,%ecx
  801fb1:	89 fa                	mov    %edi,%edx
  801fb3:	d3 e8                	shr    %cl,%eax
  801fb5:	89 e9                	mov    %ebp,%ecx
  801fb7:	09 f0                	or     %esi,%eax
  801fb9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801fbd:	f7 74 24 10          	divl   0x10(%esp)
  801fc1:	d3 e6                	shl    %cl,%esi
  801fc3:	89 d1                	mov    %edx,%ecx
  801fc5:	f7 64 24 0c          	mull   0xc(%esp)
  801fc9:	39 d1                	cmp    %edx,%ecx
  801fcb:	89 74 24 14          	mov    %esi,0x14(%esp)
  801fcf:	89 d7                	mov    %edx,%edi
  801fd1:	89 c6                	mov    %eax,%esi
  801fd3:	72 0a                	jb     801fdf <__umoddi3+0x12f>
  801fd5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801fd9:	73 10                	jae    801feb <__umoddi3+0x13b>
  801fdb:	39 d1                	cmp    %edx,%ecx
  801fdd:	75 0c                	jne    801feb <__umoddi3+0x13b>
  801fdf:	89 d7                	mov    %edx,%edi
  801fe1:	89 c6                	mov    %eax,%esi
  801fe3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801fe7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801feb:	89 ca                	mov    %ecx,%edx
  801fed:	89 e9                	mov    %ebp,%ecx
  801fef:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ff3:	29 f0                	sub    %esi,%eax
  801ff5:	19 fa                	sbb    %edi,%edx
  801ff7:	d3 e8                	shr    %cl,%eax
  801ff9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801ffe:	89 d7                	mov    %edx,%edi
  802000:	d3 e7                	shl    %cl,%edi
  802002:	89 e9                	mov    %ebp,%ecx
  802004:	09 f8                	or     %edi,%eax
  802006:	d3 ea                	shr    %cl,%edx
  802008:	83 c4 20             	add    $0x20,%esp
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
  80200f:	90                   	nop
  802010:	8b 74 24 10          	mov    0x10(%esp),%esi
  802014:	29 f9                	sub    %edi,%ecx
  802016:	19 c6                	sbb    %eax,%esi
  802018:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80201c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802020:	e9 ff fe ff ff       	jmp    801f24 <__umoddi3+0x74>
