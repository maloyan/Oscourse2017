
obj/user/lsfd:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 40 21 80 00       	push   $0x802140
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
  800048:	83 c4 10             	add    $0x10,%esp
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 32 0d 00 00       	call   800d9e <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 38 0d 00 00       	call   800dce <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 33 13 00 00       	call   8013e5 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 54 21 80 00       	push   $0x802154
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 0d 17 00 00       	call   8017e7 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 54 21 80 00       	push   $0x802154
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800118:	e8 33 0a 00 00       	call   800b50 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 78             	imul   $0x78,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
  800149:	83 c4 10             	add    $0x10,%esp
#endif
}
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 60 0f 00 00       	call   8010be <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 a7 09 00 00       	call   800b0f <sys_env_destroy>
  800168:	83 c4 10             	add    $0x10,%esp
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 35 09 00 00       	call   800ad2 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 4f 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 da 08 00 00       	call   800ad2 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 d1                	mov    %edx,%ecx
  800229:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022f:	8b 45 10             	mov    0x10(%ebp),%eax
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800238:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800242:	72 05                	jb     800249 <printnum+0x35>
  800244:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800247:	77 3e                	ja     800287 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	83 eb 01             	sub    $0x1,%ebx
  800252:	53                   	push   %ebx
  800253:	50                   	push   %eax
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 f8 1b 00 00       	call   801e60 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 13                	jmp    80028e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f ed                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 ea 1c 00 00       	call   801f90 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 86 21 80 00 	movsbl 0x802186(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
  8002b3:	83 c4 10             	add    $0x10,%esp
}
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
  80032d:	83 c4 10             	add    $0x10,%esp
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 12                	jmp    800358 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 8d 03 00 00    	je     8006db <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	53                   	push   %ebx
  800352:	50                   	push   %eax
  800353:	ff d6                	call   *%esi
  800355:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800358:	83 c7 01             	add    $0x1,%edi
  80035b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e2                	jne    800346 <vprintfmt+0x14>
  800364:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800368:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 07                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 07             	movzbl (%edi),%eax
  800394:	0f b6 c8             	movzbl %al,%ecx
  800397:	83 e8 23             	sub    $0x23,%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 1e 03 00 00    	ja     8006c0 <vprintfmt+0x38e>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b3:	eb d6                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cd:	83 fa 09             	cmp    $0x9,%edx
  8003d0:	77 38                	ja     80040a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 26                	jmp    800410 <vprintfmt+0xde>
  8003ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ed:	89 c8                	mov    %ecx,%eax
  8003ef:	c1 f8 1f             	sar    $0x1f,%eax
  8003f2:	f7 d0                	not    %eax
  8003f4:	21 c1                	and    %eax,%ecx
  8003f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	eb 8d                	jmp    80038b <vprintfmt+0x59>
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800401:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800408:	eb 81                	jmp    80038b <vprintfmt+0x59>
  80040a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800410:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800414:	0f 89 71 ff ff ff    	jns    80038b <vprintfmt+0x59>
				width = precision, precision = -1;
  80041a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800420:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800427:	e9 5f ff ff ff       	jmp    80038b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800432:	e9 54 ff ff ff       	jmp    80038b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044e:	e9 05 ff ff ff       	jmp    800358 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	99                   	cltd   
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x141>
  800468:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 18                	jne    80048b <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800473:	50                   	push   %eax
  800474:	68 9e 21 80 00       	push   $0x80219e
  800479:	53                   	push   %ebx
  80047a:	56                   	push   %esi
  80047b:	e8 95 fe ff ff       	call   800315 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800486:	e9 cd fe ff ff       	jmp    800358 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048b:	52                   	push   %edx
  80048c:	68 71 25 80 00       	push   $0x802571
  800491:	53                   	push   %ebx
  800492:	56                   	push   %esi
  800493:	e8 7d fe ff ff       	call   800315 <printfmt>
  800498:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049e:	e9 b5 fe ff ff       	jmp    800358 <vprintfmt+0x26>
  8004a3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	75 05                	jne    8004c0 <vprintfmt+0x18e>
				p = "(null)";
  8004bb:	bf 97 21 80 00       	mov    $0x802197,%edi
			if (width > 0 && padc != '-')
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 91 00 00 00    	je     80055b <vprintfmt+0x229>
  8004ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004ce:	0f 8e 95 00 00 00    	jle    800569 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	51                   	push   %ecx
  8004d8:	57                   	push   %edi
  8004d9:	e8 85 02 00 00       	call   800763 <strnlen>
  8004de:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1c5>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	89 c8                	mov    %ecx,%eax
  800512:	c1 f8 1f             	sar    $0x1f,%eax
  800515:	f7 d0                	not    %eax
  800517:	21 c8                	and    %ecx,%eax
  800519:	29 c1                	sub    %eax,%ecx
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	89 cb                	mov    %ecx,%ebx
  800526:	eb 4d                	jmp    800575 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800528:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052c:	74 1b                	je     800549 <vprintfmt+0x217>
  80052e:	0f be c0             	movsbl %al,%eax
  800531:	83 e8 20             	sub    $0x20,%eax
  800534:	83 f8 5e             	cmp    $0x5e,%eax
  800537:	76 10                	jbe    800549 <vprintfmt+0x217>
					putch('?', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	ff 75 0c             	pushl  0xc(%ebp)
  80053f:	6a 3f                	push   $0x3f
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	eb 0d                	jmp    800556 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 0c             	pushl  0xc(%ebp)
  80054f:	52                   	push   %edx
  800550:	ff 55 08             	call   *0x8(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	83 eb 01             	sub    $0x1,%ebx
  800559:	eb 1a                	jmp    800575 <vprintfmt+0x243>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	eb 0c                	jmp    800575 <vprintfmt+0x243>
  800569:	89 75 08             	mov    %esi,0x8(%ebp)
  80056c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800572:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800575:	83 c7 01             	add    $0x1,%edi
  800578:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057c:	0f be d0             	movsbl %al,%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	74 23                	je     8005a6 <vprintfmt+0x274>
  800583:	85 f6                	test   %esi,%esi
  800585:	78 a1                	js     800528 <vprintfmt+0x1f6>
  800587:	83 ee 01             	sub    $0x1,%esi
  80058a:	79 9c                	jns    800528 <vprintfmt+0x1f6>
  80058c:	89 df                	mov    %ebx,%edi
  80058e:	8b 75 08             	mov    0x8(%ebp),%esi
  800591:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800594:	eb 18                	jmp    8005ae <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 20                	push   $0x20
  80059c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059e:	83 ef 01             	sub    $0x1,%edi
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	eb 08                	jmp    8005ae <vprintfmt+0x27c>
  8005a6:	89 df                	mov    %ebx,%edi
  8005a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ae:	85 ff                	test   %edi,%edi
  8005b0:	7f e4                	jg     800596 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	e9 9e fd ff ff       	jmp    800358 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ba:	83 fa 01             	cmp    $0x1,%edx
  8005bd:	7e 16                	jle    8005d5 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 08             	lea    0x8(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 50 04             	mov    0x4(%eax),%edx
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d3:	eb 32                	jmp    800607 <vprintfmt+0x2d5>
	else if (lflag)
  8005d5:	85 d2                	test   %edx,%edx
  8005d7:	74 18                	je     8005f1 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	eb 16                	jmp    800607 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 c1                	mov    %eax,%ecx
  800601:	c1 f9 1f             	sar    $0x1f,%ecx
  800604:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800607:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	79 74                	jns    80068c <vprintfmt+0x35a>
				putch('-', putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 2d                	push   $0x2d
  80061e:	ff d6                	call   *%esi
				num = -(long long) num;
  800620:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800623:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800626:	f7 d8                	neg    %eax
  800628:	83 d2 00             	adc    $0x0,%edx
  80062b:	f7 da                	neg    %edx
  80062d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800630:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800635:	eb 55                	jmp    80068c <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 7f fc ff ff       	call   8002be <getuint>
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800644:	eb 46                	jmp    80068c <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 70 fc ff ff       	call   8002be <getuint>
			base = 8;
  80064e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800653:	eb 37                	jmp    80068c <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 30                	push   $0x30
  80065b:	ff d6                	call   *%esi
			putch('x', putdat);
  80065d:	83 c4 08             	add    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 78                	push   $0x78
  800663:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800675:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800678:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067d:	eb 0d                	jmp    80068c <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 37 fc ff ff       	call   8002be <getuint>
			base = 16;
  800687:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800693:	57                   	push   %edi
  800694:	ff 75 e0             	pushl  -0x20(%ebp)
  800697:	51                   	push   %ecx
  800698:	52                   	push   %edx
  800699:	50                   	push   %eax
  80069a:	89 da                	mov    %ebx,%edx
  80069c:	89 f0                	mov    %esi,%eax
  80069e:	e8 71 fb ff ff       	call   800214 <printnum>
			break;
  8006a3:	83 c4 20             	add    $0x20,%esp
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 aa fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	51                   	push   %ecx
  8006b3:	ff d6                	call   *%esi
			break;
  8006b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bb:	e9 98 fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 25                	push   $0x25
  8006c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb 03                	jmp    8006d0 <vprintfmt+0x39e>
  8006cd:	83 ef 01             	sub    $0x1,%edi
  8006d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d4:	75 f7                	jne    8006cd <vprintfmt+0x39b>
  8006d6:	e9 7d fc ff ff       	jmp    800358 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006de:	5b                   	pop    %ebx
  8006df:	5e                   	pop    %esi
  8006e0:	5f                   	pop    %edi
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 18             	sub    $0x18,%esp
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800700:	85 c0                	test   %eax,%eax
  800702:	74 26                	je     80072a <vsnprintf+0x47>
  800704:	85 d2                	test   %edx,%edx
  800706:	7e 22                	jle    80072a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800708:	ff 75 14             	pushl  0x14(%ebp)
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	68 f8 02 80 00       	push   $0x8002f8
  800717:	e8 16 fc ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 05                	jmp    80072f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800737:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073a:	50                   	push   %eax
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	ff 75 08             	pushl  0x8(%ebp)
  800744:	e8 9a ff ff ff       	call   8006e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	eb 03                	jmp    80075b <strlen+0x10>
		n++;
  800758:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075f:	75 f7                	jne    800758 <strlen+0xd>
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	ba 00 00 00 00       	mov    $0x0,%edx
  800771:	eb 03                	jmp    800776 <strnlen+0x13>
		n++;
  800773:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800776:	39 c2                	cmp    %eax,%edx
  800778:	74 08                	je     800782 <strnlen+0x1f>
  80077a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077e:	75 f3                	jne    800773 <strnlen+0x10>
  800780:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078e:	89 c2                	mov    %eax,%edx
  800790:	83 c2 01             	add    $0x1,%edx
  800793:	83 c1 01             	add    $0x1,%ecx
  800796:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079d:	84 db                	test   %bl,%bl
  80079f:	75 ef                	jne    800790 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ab:	53                   	push   %ebx
  8007ac:	e8 9a ff ff ff       	call   80074b <strlen>
  8007b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	01 d8                	add    %ebx,%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 c5 ff ff ff       	call   800784 <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	89 f3                	mov    %esi,%ebx
  8007d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d6:	89 f2                	mov    %esi,%edx
  8007d8:	eb 0f                	jmp    8007e9 <strncpy+0x23>
		*dst++ = *src;
  8007da:	83 c2 01             	add    $0x1,%edx
  8007dd:	0f b6 01             	movzbl (%ecx),%eax
  8007e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	39 da                	cmp    %ebx,%edx
  8007eb:	75 ed                	jne    8007da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fe:	8b 55 10             	mov    0x10(%ebp),%edx
  800801:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800803:	85 d2                	test   %edx,%edx
  800805:	74 21                	je     800828 <strlcpy+0x35>
  800807:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080b:	89 f2                	mov    %esi,%edx
  80080d:	eb 09                	jmp    800818 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	83 c1 01             	add    $0x1,%ecx
  800815:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800818:	39 c2                	cmp    %eax,%edx
  80081a:	74 09                	je     800825 <strlcpy+0x32>
  80081c:	0f b6 19             	movzbl (%ecx),%ebx
  80081f:	84 db                	test   %bl,%bl
  800821:	75 ec                	jne    80080f <strlcpy+0x1c>
  800823:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800825:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800828:	29 f0                	sub    %esi,%eax
}
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800837:	eb 06                	jmp    80083f <strcmp+0x11>
		p++, q++;
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083f:	0f b6 01             	movzbl (%ecx),%eax
  800842:	84 c0                	test   %al,%al
  800844:	74 04                	je     80084a <strcmp+0x1c>
  800846:	3a 02                	cmp    (%edx),%al
  800848:	74 ef                	je     800839 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 c0             	movzbl %al,%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
}
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 c3                	mov    %eax,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800863:	eb 06                	jmp    80086b <strncmp+0x17>
		n--, p++, q++;
  800865:	83 c0 01             	add    $0x1,%eax
  800868:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086b:	39 d8                	cmp    %ebx,%eax
  80086d:	74 15                	je     800884 <strncmp+0x30>
  80086f:	0f b6 08             	movzbl (%eax),%ecx
  800872:	84 c9                	test   %cl,%cl
  800874:	74 04                	je     80087a <strncmp+0x26>
  800876:	3a 0a                	cmp    (%edx),%cl
  800878:	74 eb                	je     800865 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087a:	0f b6 00             	movzbl (%eax),%eax
  80087d:	0f b6 12             	movzbl (%edx),%edx
  800880:	29 d0                	sub    %edx,%eax
  800882:	eb 05                	jmp    800889 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800896:	eb 07                	jmp    80089f <strchr+0x13>
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 0f                	je     8008ab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089c:	83 c0 01             	add    $0x1,%eax
  80089f:	0f b6 10             	movzbl (%eax),%edx
  8008a2:	84 d2                	test   %dl,%dl
  8008a4:	75 f2                	jne    800898 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b7:	eb 03                	jmp    8008bc <strfind+0xf>
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	74 04                	je     8008c7 <strfind+0x1a>
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	75 f2                	jne    8008b9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	74 36                	je     80090f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008df:	75 28                	jne    800909 <memset+0x40>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 23                	jne    800909 <memset+0x40>
		c &= 0xFF;
  8008e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ea:	89 d3                	mov    %edx,%ebx
  8008ec:	c1 e3 08             	shl    $0x8,%ebx
  8008ef:	89 d6                	mov    %edx,%esi
  8008f1:	c1 e6 18             	shl    $0x18,%esi
  8008f4:	89 d0                	mov    %edx,%eax
  8008f6:	c1 e0 10             	shl    $0x10,%eax
  8008f9:	09 f0                	or     %esi,%eax
  8008fb:	09 c2                	or     %eax,%edx
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800901:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800904:	fc                   	cld    
  800905:	f3 ab                	rep stos %eax,%es:(%edi)
  800907:	eb 06                	jmp    80090f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800909:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090c:	fc                   	cld    
  80090d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090f:	89 f8                	mov    %edi,%eax
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800924:	39 c6                	cmp    %eax,%esi
  800926:	73 35                	jae    80095d <memmove+0x47>
  800928:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092b:	39 d0                	cmp    %edx,%eax
  80092d:	73 2e                	jae    80095d <memmove+0x47>
		s += n;
		d += n;
  80092f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800932:	89 d6                	mov    %edx,%esi
  800934:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093c:	75 13                	jne    800951 <memmove+0x3b>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 0e                	jne    800951 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800943:	83 ef 04             	sub    $0x4,%edi
  800946:	8d 72 fc             	lea    -0x4(%edx),%esi
  800949:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094c:	fd                   	std    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 09                	jmp    80095a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800951:	83 ef 01             	sub    $0x1,%edi
  800954:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800957:	fd                   	std    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095a:	fc                   	cld    
  80095b:	eb 1d                	jmp    80097a <memmove+0x64>
  80095d:	89 f2                	mov    %esi,%edx
  80095f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	f6 c2 03             	test   $0x3,%dl
  800964:	75 0f                	jne    800975 <memmove+0x5f>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0a                	jne    800975 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 05                	jmp    80097a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800975:	89 c7                	mov    %eax,%edi
  800977:	fc                   	cld    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800981:	ff 75 10             	pushl  0x10(%ebp)
  800984:	ff 75 0c             	pushl  0xc(%ebp)
  800987:	ff 75 08             	pushl  0x8(%ebp)
  80098a:	e8 87 ff ff ff       	call   800916 <memmove>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c6                	mov    %eax,%esi
  80099e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a1:	eb 1a                	jmp    8009bd <memcmp+0x2c>
		if (*s1 != *s2)
  8009a3:	0f b6 08             	movzbl (%eax),%ecx
  8009a6:	0f b6 1a             	movzbl (%edx),%ebx
  8009a9:	38 d9                	cmp    %bl,%cl
  8009ab:	74 0a                	je     8009b7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ad:	0f b6 c1             	movzbl %cl,%eax
  8009b0:	0f b6 db             	movzbl %bl,%ebx
  8009b3:	29 d8                	sub    %ebx,%eax
  8009b5:	eb 0f                	jmp    8009c6 <memcmp+0x35>
		s1++, s2++;
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bd:	39 f0                	cmp    %esi,%eax
  8009bf:	75 e2                	jne    8009a3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d8:	eb 07                	jmp    8009e1 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	38 08                	cmp    %cl,(%eax)
  8009dc:	74 07                	je     8009e5 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	72 f5                	jb     8009da <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	eb 03                	jmp    8009f8 <strtol+0x11>
		s++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	0f b6 01             	movzbl (%ecx),%eax
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	74 f6                	je     8009f5 <strtol+0xe>
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f2                	je     8009f5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a03:	3c 2b                	cmp    $0x2b,%al
  800a05:	75 0a                	jne    800a11 <strtol+0x2a>
		s++;
  800a07:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0f:	eb 10                	jmp    800a21 <strtol+0x3a>
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a16:	3c 2d                	cmp    $0x2d,%al
  800a18:	75 07                	jne    800a21 <strtol+0x3a>
		s++, neg = 1;
  800a1a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	0f 94 c0             	sete   %al
  800a26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2c:	75 19                	jne    800a47 <strtol+0x60>
  800a2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a31:	75 14                	jne    800a47 <strtol+0x60>
  800a33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a37:	0f 85 8a 00 00 00    	jne    800ac7 <strtol+0xe0>
		s += 2, base = 16;
  800a3d:	83 c1 02             	add    $0x2,%ecx
  800a40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a45:	eb 16                	jmp    800a5d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a47:	84 c0                	test   %al,%al
  800a49:	74 12                	je     800a5d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a50:	80 39 30             	cmpb   $0x30,(%ecx)
  800a53:	75 08                	jne    800a5d <strtol+0x76>
		s++, base = 8;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a62:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a65:	0f b6 11             	movzbl (%ecx),%edx
  800a68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6b:	89 f3                	mov    %esi,%ebx
  800a6d:	80 fb 09             	cmp    $0x9,%bl
  800a70:	77 08                	ja     800a7a <strtol+0x93>
			dig = *s - '0';
  800a72:	0f be d2             	movsbl %dl,%edx
  800a75:	83 ea 30             	sub    $0x30,%edx
  800a78:	eb 22                	jmp    800a9c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 19             	cmp    $0x19,%bl
  800a82:	77 08                	ja     800a8c <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 57             	sub    $0x57,%edx
  800a8a:	eb 10                	jmp    800a9c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 16                	ja     800aac <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9f:	7d 0f                	jge    800ab0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aaa:	eb b9                	jmp    800a65 <strtol+0x7e>
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	eb 02                	jmp    800ab2 <strtol+0xcb>
  800ab0:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 05                	je     800abd <strtol+0xd6>
		*endptr = (char *) s;
  800ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800abd:	85 ff                	test   %edi,%edi
  800abf:	74 0c                	je     800acd <strtol+0xe6>
  800ac1:	89 d0                	mov    %edx,%eax
  800ac3:	f7 d8                	neg    %eax
  800ac5:	eb 06                	jmp    800acd <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	84 c0                	test   %al,%al
  800ac9:	75 8a                	jne    800a55 <strtol+0x6e>
  800acb:	eb 90                	jmp    800a5d <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
  800add:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	89 c6                	mov    %eax,%esi
  800ae9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	89 d1                	mov    %edx,%ecx
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	89 d7                	mov    %edx,%edi
  800b06:	89 d6                	mov    %edx,%esi
  800b08:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 cb                	mov    %ecx,%ebx
  800b27:	89 cf                	mov    %ecx,%edi
  800b29:	89 ce                	mov    %ecx,%esi
  800b2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 17                	jle    800b48 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	50                   	push   %eax
  800b35:	6a 03                	push   $0x3
  800b37:	68 9f 24 80 00       	push   $0x80249f
  800b3c:	6a 23                	push   $0x23
  800b3e:	68 bc 24 80 00       	push   $0x8024bc
  800b43:	e8 a3 11 00 00       	call   801ceb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	89 d3                	mov    %edx,%ebx
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_yield>:

void
sys_yield(void)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7f:	89 d1                	mov    %edx,%ecx
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b97:	be 00 00 00 00       	mov    $0x0,%esi
  800b9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baa:	89 f7                	mov    %esi,%edi
  800bac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7e 17                	jle    800bc9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	50                   	push   %eax
  800bb6:	6a 04                	push   $0x4
  800bb8:	68 9f 24 80 00       	push   $0x80249f
  800bbd:	6a 23                	push   $0x23
  800bbf:	68 bc 24 80 00       	push   $0x8024bc
  800bc4:	e8 22 11 00 00       	call   801ceb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800beb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 17                	jle    800c0b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 05                	push   $0x5
  800bfa:	68 9f 24 80 00       	push   $0x80249f
  800bff:	6a 23                	push   $0x23
  800c01:	68 bc 24 80 00       	push   $0x8024bc
  800c06:	e8 e0 10 00 00       	call   801ceb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c21:	b8 06 00 00 00       	mov    $0x6,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	89 df                	mov    %ebx,%edi
  800c2e:	89 de                	mov    %ebx,%esi
  800c30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 06                	push   $0x6
  800c3c:	68 9f 24 80 00       	push   $0x80249f
  800c41:	6a 23                	push   $0x23
  800c43:	68 bc 24 80 00       	push   $0x8024bc
  800c48:	e8 9e 10 00 00       	call   801ceb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	b8 08 00 00 00       	mov    $0x8,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 08                	push   $0x8
  800c7e:	68 9f 24 80 00       	push   $0x80249f
  800c83:	6a 23                	push   $0x23
  800c85:	68 bc 24 80 00       	push   $0x8024bc
  800c8a:	e8 5c 10 00 00       	call   801ceb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 09 00 00 00       	mov    $0x9,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 09                	push   $0x9
  800cc0:	68 9f 24 80 00       	push   $0x80249f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 bc 24 80 00       	push   $0x8024bc
  800ccc:	e8 1a 10 00 00       	call   801ceb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 0a                	push   $0xa
  800d02:	68 9f 24 80 00       	push   $0x80249f
  800d07:	6a 23                	push   $0x23
  800d09:	68 bc 24 80 00       	push   $0x8024bc
  800d0e:	e8 d8 0f 00 00       	call   801ceb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	be 00 00 00 00       	mov    $0x0,%esi
  800d26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d37:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 cb                	mov    %ecx,%ebx
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	89 ce                	mov    %ecx,%esi
  800d5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 0d                	push   $0xd
  800d66:	68 9f 24 80 00       	push   $0x80249f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 bc 24 80 00       	push   $0x8024bc
  800d72:	e8 74 0f 00 00       	call   801ceb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_gettime>:

int sys_gettime(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 d7                	mov    %edx,%edi
  800d95:	89 d6                	mov    %edx,%esi
  800d97:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800daa:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800dac:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800daf:	83 3a 01             	cmpl   $0x1,(%edx)
  800db2:	7e 09                	jle    800dbd <argstart+0x1f>
  800db4:	ba 51 21 80 00       	mov    $0x802151,%edx
  800db9:	85 c9                	test   %ecx,%ecx
  800dbb:	75 05                	jne    800dc2 <argstart+0x24>
  800dbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc2:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dc5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <argnext>:

int
argnext(struct Argstate *args)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dd8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800ddf:	8b 43 08             	mov    0x8(%ebx),%eax
  800de2:	85 c0                	test   %eax,%eax
  800de4:	74 6f                	je     800e55 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800de6:	80 38 00             	cmpb   $0x0,(%eax)
  800de9:	75 4e                	jne    800e39 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800deb:	8b 0b                	mov    (%ebx),%ecx
  800ded:	83 39 01             	cmpl   $0x1,(%ecx)
  800df0:	74 55                	je     800e47 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800df2:	8b 53 04             	mov    0x4(%ebx),%edx
  800df5:	8b 42 04             	mov    0x4(%edx),%eax
  800df8:	80 38 2d             	cmpb   $0x2d,(%eax)
  800dfb:	75 4a                	jne    800e47 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800dfd:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e01:	74 44                	je     800e47 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	8b 01                	mov    (%ecx),%eax
  800e0e:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e15:	50                   	push   %eax
  800e16:	8d 42 08             	lea    0x8(%edx),%eax
  800e19:	50                   	push   %eax
  800e1a:	83 c2 04             	add    $0x4,%edx
  800e1d:	52                   	push   %edx
  800e1e:	e8 f3 fa ff ff       	call   800916 <memmove>
		(*args->argc)--;
  800e23:	8b 03                	mov    (%ebx),%eax
  800e25:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e28:	8b 43 08             	mov    0x8(%ebx),%eax
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e31:	75 06                	jne    800e39 <argnext+0x6b>
  800e33:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e37:	74 0e                	je     800e47 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e39:	8b 53 08             	mov    0x8(%ebx),%edx
  800e3c:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e3f:	83 c2 01             	add    $0x1,%edx
  800e42:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e45:	eb 13                	jmp    800e5a <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e47:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e53:	eb 05                	jmp    800e5a <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5d:	c9                   	leave  
  800e5e:	c3                   	ret    

00800e5f <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	53                   	push   %ebx
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e69:	8b 43 08             	mov    0x8(%ebx),%eax
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	74 58                	je     800ec8 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e70:	80 38 00             	cmpb   $0x0,(%eax)
  800e73:	74 0c                	je     800e81 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e75:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e78:	c7 43 08 51 21 80 00 	movl   $0x802151,0x8(%ebx)
  800e7f:	eb 42                	jmp    800ec3 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e81:	8b 13                	mov    (%ebx),%edx
  800e83:	83 3a 01             	cmpl   $0x1,(%edx)
  800e86:	7e 2d                	jle    800eb5 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e88:	8b 43 04             	mov    0x4(%ebx),%eax
  800e8b:	8b 48 04             	mov    0x4(%eax),%ecx
  800e8e:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	8b 12                	mov    (%edx),%edx
  800e96:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e9d:	52                   	push   %edx
  800e9e:	8d 50 08             	lea    0x8(%eax),%edx
  800ea1:	52                   	push   %edx
  800ea2:	83 c0 04             	add    $0x4,%eax
  800ea5:	50                   	push   %eax
  800ea6:	e8 6b fa ff ff       	call   800916 <memmove>
		(*args->argc)--;
  800eab:	8b 03                	mov    (%ebx),%eax
  800ead:	83 28 01             	subl   $0x1,(%eax)
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	eb 0e                	jmp    800ec3 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800eb5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ebc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ec3:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ec6:	eb 05                	jmp    800ecd <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800edb:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ede:	89 d0                	mov    %edx,%eax
  800ee0:	85 d2                	test   %edx,%edx
  800ee2:	75 0c                	jne    800ef0 <argvalue+0x1e>
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	51                   	push   %ecx
  800ee8:	e8 72 ff ff ff       	call   800e5f <argnextvalue>
  800eed:	83 c4 10             	add    $0x10,%esp
}
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	05 00 00 00 30       	add    $0x30000000,%eax
  800efd:	c1 e8 0c             	shr    $0xc,%eax
}
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800f0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f12:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 16             	shr    $0x16,%edx
  800f29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 11                	je     800f46 <fd_alloc+0x2d>
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 0c             	shr    $0xc,%edx
  800f3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	75 09                	jne    800f4f <fd_alloc+0x36>
			*fd_store = fd;
  800f46:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4d:	eb 17                	jmp    800f66 <fd_alloc+0x4d>
  800f4f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f54:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f59:	75 c9                	jne    800f24 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f5b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f61:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f6e:	83 f8 1f             	cmp    $0x1f,%eax
  800f71:	77 36                	ja     800fa9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f73:	c1 e0 0c             	shl    $0xc,%eax
  800f76:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f7b:	89 c2                	mov    %eax,%edx
  800f7d:	c1 ea 16             	shr    $0x16,%edx
  800f80:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f87:	f6 c2 01             	test   $0x1,%dl
  800f8a:	74 24                	je     800fb0 <fd_lookup+0x48>
  800f8c:	89 c2                	mov    %eax,%edx
  800f8e:	c1 ea 0c             	shr    $0xc,%edx
  800f91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f98:	f6 c2 01             	test   $0x1,%dl
  800f9b:	74 1a                	je     800fb7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa0:	89 02                	mov    %eax,(%edx)
	return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	eb 13                	jmp    800fbc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fae:	eb 0c                	jmp    800fbc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb5:	eb 05                	jmp    800fbc <fd_lookup+0x54>
  800fb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc7:	ba 48 25 80 00       	mov    $0x802548,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fcc:	eb 13                	jmp    800fe1 <dev_lookup+0x23>
  800fce:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fd1:	39 08                	cmp    %ecx,(%eax)
  800fd3:	75 0c                	jne    800fe1 <dev_lookup+0x23>
			*dev = devtab[i];
  800fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	eb 2e                	jmp    80100f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe1:	8b 02                	mov    (%edx),%eax
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	75 e7                	jne    800fce <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fe7:	a1 04 40 80 00       	mov    0x804004,%eax
  800fec:	8b 40 48             	mov    0x48(%eax),%eax
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	51                   	push   %ecx
  800ff3:	50                   	push   %eax
  800ff4:	68 cc 24 80 00       	push   $0x8024cc
  800ff9:	e8 02 f2 ff ff       	call   800200 <cprintf>
	*dev = 0;
  800ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801001:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 10             	sub    $0x10,%esp
  801019:	8b 75 08             	mov    0x8(%ebp),%esi
  80101c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801022:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801029:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80102c:	50                   	push   %eax
  80102d:	e8 36 ff ff ff       	call   800f68 <fd_lookup>
  801032:	83 c4 08             	add    $0x8,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	78 05                	js     80103e <fd_close+0x2d>
	    || fd != fd2)
  801039:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80103c:	74 0b                	je     801049 <fd_close+0x38>
		return (must_exist ? r : 0);
  80103e:	80 fb 01             	cmp    $0x1,%bl
  801041:	19 d2                	sbb    %edx,%edx
  801043:	f7 d2                	not    %edx
  801045:	21 d0                	and    %edx,%eax
  801047:	eb 41                	jmp    80108a <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104f:	50                   	push   %eax
  801050:	ff 36                	pushl  (%esi)
  801052:	e8 67 ff ff ff       	call   800fbe <dev_lookup>
  801057:	89 c3                	mov    %eax,%ebx
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 1a                	js     80107a <fd_close+0x69>
		if (dev->dev_close)
  801060:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801063:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 0b                	je     80107a <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	56                   	push   %esi
  801073:	ff d0                	call   *%eax
  801075:	89 c3                	mov    %eax,%ebx
  801077:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	56                   	push   %esi
  80107e:	6a 00                	push   $0x0
  801080:	e8 8e fb ff ff       	call   800c13 <sys_page_unmap>
	return r;
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	89 d8                	mov    %ebx,%eax
}
  80108a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801097:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	ff 75 08             	pushl  0x8(%ebp)
  80109e:	e8 c5 fe ff ff       	call   800f68 <fd_lookup>
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	83 c4 08             	add    $0x8,%esp
  8010a8:	85 d2                	test   %edx,%edx
  8010aa:	78 10                	js     8010bc <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	6a 01                	push   $0x1
  8010b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b4:	e8 58 ff ff ff       	call   801011 <fd_close>
  8010b9:	83 c4 10             	add    $0x10,%esp
}
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <close_all>:

void
close_all(void)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	53                   	push   %ebx
  8010ce:	e8 be ff ff ff       	call   801091 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d3:	83 c3 01             	add    $0x1,%ebx
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	83 fb 20             	cmp    $0x20,%ebx
  8010dc:	75 ec                	jne    8010ca <close_all+0xc>
		close(i);
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
  8010ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	e8 6d fe ff ff       	call   800f68 <fd_lookup>
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	85 d2                	test   %edx,%edx
  801102:	0f 88 c1 00 00 00    	js     8011c9 <dup+0xe6>
		return r;
	close(newfdnum);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	56                   	push   %esi
  80110c:	e8 80 ff ff ff       	call   801091 <close>

	newfd = INDEX2FD(newfdnum);
  801111:	89 f3                	mov    %esi,%ebx
  801113:	c1 e3 0c             	shl    $0xc,%ebx
  801116:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80111c:	83 c4 04             	add    $0x4,%esp
  80111f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801122:	e8 db fd ff ff       	call   800f02 <fd2data>
  801127:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801129:	89 1c 24             	mov    %ebx,(%esp)
  80112c:	e8 d1 fd ff ff       	call   800f02 <fd2data>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801137:	89 f8                	mov    %edi,%eax
  801139:	c1 e8 16             	shr    $0x16,%eax
  80113c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801143:	a8 01                	test   $0x1,%al
  801145:	74 37                	je     80117e <dup+0x9b>
  801147:	89 f8                	mov    %edi,%eax
  801149:	c1 e8 0c             	shr    $0xc,%eax
  80114c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801153:	f6 c2 01             	test   $0x1,%dl
  801156:	74 26                	je     80117e <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801158:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	25 07 0e 00 00       	and    $0xe07,%eax
  801167:	50                   	push   %eax
  801168:	ff 75 d4             	pushl  -0x2c(%ebp)
  80116b:	6a 00                	push   $0x0
  80116d:	57                   	push   %edi
  80116e:	6a 00                	push   $0x0
  801170:	e8 5c fa ff ff       	call   800bd1 <sys_page_map>
  801175:	89 c7                	mov    %eax,%edi
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 2e                	js     8011ac <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801181:	89 d0                	mov    %edx,%eax
  801183:	c1 e8 0c             	shr    $0xc,%eax
  801186:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	25 07 0e 00 00       	and    $0xe07,%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	6a 00                	push   $0x0
  801199:	52                   	push   %edx
  80119a:	6a 00                	push   $0x0
  80119c:	e8 30 fa ff ff       	call   800bd1 <sys_page_map>
  8011a1:	89 c7                	mov    %eax,%edi
  8011a3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011a6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a8:	85 ff                	test   %edi,%edi
  8011aa:	79 1d                	jns    8011c9 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	53                   	push   %ebx
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 5c fa ff ff       	call   800c13 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011bd:	6a 00                	push   $0x0
  8011bf:	e8 4f fa ff ff       	call   800c13 <sys_page_unmap>
	return r;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	89 f8                	mov    %edi,%eax
}
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 14             	sub    $0x14,%esp
  8011d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	53                   	push   %ebx
  8011e0:	e8 83 fd ff ff       	call   800f68 <fd_lookup>
  8011e5:	83 c4 08             	add    $0x8,%esp
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 6d                	js     80125b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	ff 30                	pushl  (%eax)
  8011fa:	e8 bf fd ff ff       	call   800fbe <dev_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 4c                	js     801252 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801206:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801209:	8b 42 08             	mov    0x8(%edx),%eax
  80120c:	83 e0 03             	and    $0x3,%eax
  80120f:	83 f8 01             	cmp    $0x1,%eax
  801212:	75 21                	jne    801235 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801214:	a1 04 40 80 00       	mov    0x804004,%eax
  801219:	8b 40 48             	mov    0x48(%eax),%eax
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	53                   	push   %ebx
  801220:	50                   	push   %eax
  801221:	68 0d 25 80 00       	push   $0x80250d
  801226:	e8 d5 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801233:	eb 26                	jmp    80125b <read+0x8a>
	}
	if (!dev->dev_read)
  801235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801238:	8b 40 08             	mov    0x8(%eax),%eax
  80123b:	85 c0                	test   %eax,%eax
  80123d:	74 17                	je     801256 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	ff 75 10             	pushl  0x10(%ebp)
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	52                   	push   %edx
  801249:	ff d0                	call   *%eax
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	eb 09                	jmp    80125b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	89 c2                	mov    %eax,%edx
  801254:	eb 05                	jmp    80125b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801256:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80125b:	89 d0                	mov    %edx,%eax
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801271:	bb 00 00 00 00       	mov    $0x0,%ebx
  801276:	eb 21                	jmp    801299 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	89 f0                	mov    %esi,%eax
  80127d:	29 d8                	sub    %ebx,%eax
  80127f:	50                   	push   %eax
  801280:	89 d8                	mov    %ebx,%eax
  801282:	03 45 0c             	add    0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	57                   	push   %edi
  801287:	e8 45 ff ff ff       	call   8011d1 <read>
		if (m < 0)
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 0c                	js     80129f <readn+0x3d>
			return m;
		if (m == 0)
  801293:	85 c0                	test   %eax,%eax
  801295:	74 06                	je     80129d <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801297:	01 c3                	add    %eax,%ebx
  801299:	39 f3                	cmp    %esi,%ebx
  80129b:	72 db                	jb     801278 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80129d:	89 d8                	mov    %ebx,%eax
}
  80129f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a2:	5b                   	pop    %ebx
  8012a3:	5e                   	pop    %esi
  8012a4:	5f                   	pop    %edi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 14             	sub    $0x14,%esp
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	53                   	push   %ebx
  8012b6:	e8 ad fc ff ff       	call   800f68 <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 68                	js     80132c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	ff 30                	pushl  (%eax)
  8012d0:	e8 e9 fc ff ff       	call   800fbe <dev_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 47                	js     801323 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e3:	75 21                	jne    801306 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	50                   	push   %eax
  8012f2:	68 29 25 80 00       	push   $0x802529
  8012f7:	e8 04 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801304:	eb 26                	jmp    80132c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801306:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801309:	8b 52 0c             	mov    0xc(%edx),%edx
  80130c:	85 d2                	test   %edx,%edx
  80130e:	74 17                	je     801327 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	ff 75 10             	pushl  0x10(%ebp)
  801316:	ff 75 0c             	pushl  0xc(%ebp)
  801319:	50                   	push   %eax
  80131a:	ff d2                	call   *%edx
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	eb 09                	jmp    80132c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801323:	89 c2                	mov    %eax,%edx
  801325:	eb 05                	jmp    80132c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801327:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <seek>:

int
seek(int fdnum, off_t offset)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801339:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	ff 75 08             	pushl  0x8(%ebp)
  801340:	e8 23 fc ff ff       	call   800f68 <fd_lookup>
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 0e                	js     80135a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80134c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80134f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801352:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 14             	sub    $0x14,%esp
  801363:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801366:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	53                   	push   %ebx
  80136b:	e8 f8 fb ff ff       	call   800f68 <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	89 c2                	mov    %eax,%edx
  801375:	85 c0                	test   %eax,%eax
  801377:	78 65                	js     8013de <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	ff 30                	pushl  (%eax)
  801385:	e8 34 fc ff ff       	call   800fbe <dev_lookup>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 44                	js     8013d5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801394:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801398:	75 21                	jne    8013bb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80139a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80139f:	8b 40 48             	mov    0x48(%eax),%eax
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	50                   	push   %eax
  8013a7:	68 ec 24 80 00       	push   $0x8024ec
  8013ac:	e8 4f ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b9:	eb 23                	jmp    8013de <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013be:	8b 52 18             	mov    0x18(%edx),%edx
  8013c1:	85 d2                	test   %edx,%edx
  8013c3:	74 14                	je     8013d9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	50                   	push   %eax
  8013cc:	ff d2                	call   *%edx
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	eb 09                	jmp    8013de <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	eb 05                	jmp    8013de <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013de:	89 d0                	mov    %edx,%eax
  8013e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
  8013ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	ff 75 08             	pushl  0x8(%ebp)
  8013f6:	e8 6d fb ff ff       	call   800f68 <fd_lookup>
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	85 c0                	test   %eax,%eax
  801402:	78 58                	js     80145c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	ff 30                	pushl  (%eax)
  801410:	e8 a9 fb ff ff       	call   800fbe <dev_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 37                	js     801453 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80141c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801423:	74 32                	je     801457 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801425:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801428:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80142f:	00 00 00 
	stat->st_isdir = 0;
  801432:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801439:	00 00 00 
	stat->st_dev = dev;
  80143c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	53                   	push   %ebx
  801446:	ff 75 f0             	pushl  -0x10(%ebp)
  801449:	ff 50 14             	call   *0x14(%eax)
  80144c:	89 c2                	mov    %eax,%edx
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	eb 09                	jmp    80145c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801453:	89 c2                	mov    %eax,%edx
  801455:	eb 05                	jmp    80145c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801457:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80145c:	89 d0                	mov    %edx,%eax
  80145e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	6a 00                	push   $0x0
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	e8 e7 01 00 00       	call   80165c <open>
  801475:	89 c3                	mov    %eax,%ebx
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 db                	test   %ebx,%ebx
  80147c:	78 1b                	js     801499 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	ff 75 0c             	pushl  0xc(%ebp)
  801484:	53                   	push   %ebx
  801485:	e8 5b ff ff ff       	call   8013e5 <fstat>
  80148a:	89 c6                	mov    %eax,%esi
	close(fd);
  80148c:	89 1c 24             	mov    %ebx,(%esp)
  80148f:	e8 fd fb ff ff       	call   801091 <close>
	return r;
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	89 f0                	mov    %esi,%eax
}
  801499:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149c:	5b                   	pop    %ebx
  80149d:	5e                   	pop    %esi
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	89 c6                	mov    %eax,%esi
  8014a7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014a9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014b0:	75 12                	jne    8014c4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	6a 03                	push   $0x3
  8014b7:	e8 2c 09 00 00       	call   801de8 <ipc_find_env>
  8014bc:	a3 00 40 80 00       	mov    %eax,0x804000
  8014c1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014c4:	6a 07                	push   $0x7
  8014c6:	68 00 50 80 00       	push   $0x805000
  8014cb:	56                   	push   %esi
  8014cc:	ff 35 00 40 80 00    	pushl  0x804000
  8014d2:	e8 c0 08 00 00       	call   801d97 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014d7:	83 c4 0c             	add    $0xc,%esp
  8014da:	6a 00                	push   $0x0
  8014dc:	53                   	push   %ebx
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 4d 08 00 00       	call   801d31 <ipc_recv>
}
  8014e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5e                   	pop    %esi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 02 00 00 00       	mov    $0x2,%eax
  80150e:	e8 8d ff ff ff       	call   8014a0 <fsipc>
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 40 0c             	mov    0xc(%eax),%eax
  801521:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 06 00 00 00       	mov    $0x6,%eax
  801530:	e8 6b ff ff ff       	call   8014a0 <fsipc>
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	53                   	push   %ebx
  80153b:	83 ec 04             	sub    $0x4,%esp
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	8b 40 0c             	mov    0xc(%eax),%eax
  801547:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	b8 05 00 00 00       	mov    $0x5,%eax
  801556:	e8 45 ff ff ff       	call   8014a0 <fsipc>
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	85 d2                	test   %edx,%edx
  80155f:	78 2c                	js     80158d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	68 00 50 80 00       	push   $0x805000
  801569:	53                   	push   %ebx
  80156a:	e8 15 f2 ff ff       	call   800784 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80156f:	a1 80 50 80 00       	mov    0x805080,%eax
  801574:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80157a:	a1 84 50 80 00       	mov    0x805084,%eax
  80157f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  80159b:	8b 55 08             	mov    0x8(%ebp),%edx
  80159e:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a1:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8015a7:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8015ac:	76 05                	jbe    8015b3 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8015ae:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8015b3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	50                   	push   %eax
  8015bc:	ff 75 0c             	pushl  0xc(%ebp)
  8015bf:	68 08 50 80 00       	push   $0x805008
  8015c4:	e8 4d f3 ff ff       	call   800916 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 04 00 00 00       	mov    $0x4,%eax
  8015d3:	e8 c8 fe ff ff       	call   8014a0 <fsipc>
	return write;
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015ed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015fd:	e8 9e fe ff ff       	call   8014a0 <fsipc>
  801602:	89 c3                	mov    %eax,%ebx
  801604:	85 c0                	test   %eax,%eax
  801606:	78 4b                	js     801653 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801608:	39 c6                	cmp    %eax,%esi
  80160a:	73 16                	jae    801622 <devfile_read+0x48>
  80160c:	68 58 25 80 00       	push   $0x802558
  801611:	68 5f 25 80 00       	push   $0x80255f
  801616:	6a 7c                	push   $0x7c
  801618:	68 74 25 80 00       	push   $0x802574
  80161d:	e8 c9 06 00 00       	call   801ceb <_panic>
	assert(r <= PGSIZE);
  801622:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801627:	7e 16                	jle    80163f <devfile_read+0x65>
  801629:	68 7f 25 80 00       	push   $0x80257f
  80162e:	68 5f 25 80 00       	push   $0x80255f
  801633:	6a 7d                	push   $0x7d
  801635:	68 74 25 80 00       	push   $0x802574
  80163a:	e8 ac 06 00 00       	call   801ceb <_panic>
	memmove(buf, &fsipcbuf, r);
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	50                   	push   %eax
  801643:	68 00 50 80 00       	push   $0x805000
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	e8 c6 f2 ff ff       	call   800916 <memmove>
	return r;
  801650:	83 c4 10             	add    $0x10,%esp
}
  801653:	89 d8                	mov    %ebx,%eax
  801655:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801658:	5b                   	pop    %ebx
  801659:	5e                   	pop    %esi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 20             	sub    $0x20,%esp
  801663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801666:	53                   	push   %ebx
  801667:	e8 df f0 ff ff       	call   80074b <strlen>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801674:	7f 67                	jg     8016dd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	e8 97 f8 ff ff       	call   800f19 <fd_alloc>
  801682:	83 c4 10             	add    $0x10,%esp
		return r;
  801685:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801687:	85 c0                	test   %eax,%eax
  801689:	78 57                	js     8016e2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	53                   	push   %ebx
  80168f:	68 00 50 80 00       	push   $0x805000
  801694:	e8 eb f0 ff ff       	call   800784 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016a9:	e8 f2 fd ff ff       	call   8014a0 <fsipc>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	79 14                	jns    8016cb <open+0x6f>
		fd_close(fd, 0);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	6a 00                	push   $0x0
  8016bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bf:	e8 4d f9 ff ff       	call   801011 <fd_close>
		return r;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	89 da                	mov    %ebx,%edx
  8016c9:	eb 17                	jmp    8016e2 <open+0x86>
	}

	return fd2num(fd);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d1:	e8 1c f8 ff ff       	call   800ef2 <fd2num>
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	eb 05                	jmp    8016e2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016dd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e2:	89 d0                	mov    %edx,%eax
  8016e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f9:	e8 a2 fd ff ff       	call   8014a0 <fsipc>
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801700:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801704:	7e 3a                	jle    801740 <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80170f:	ff 70 04             	pushl  0x4(%eax)
  801712:	8d 40 10             	lea    0x10(%eax),%eax
  801715:	50                   	push   %eax
  801716:	ff 33                	pushl  (%ebx)
  801718:	e8 8a fb ff ff       	call   8012a7 <write>
		if (result > 0)
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	7e 03                	jle    801727 <writebuf+0x27>
			b->result += result;
  801724:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801727:	39 43 04             	cmp    %eax,0x4(%ebx)
  80172a:	74 10                	je     80173c <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  80172c:	85 c0                	test   %eax,%eax
  80172e:	0f 9f c2             	setg   %dl
  801731:	0f b6 d2             	movzbl %dl,%edx
  801734:	83 ea 01             	sub    $0x1,%edx
  801737:	21 d0                	and    %edx,%eax
  801739:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	f3 c3                	repz ret 

00801742 <putch>:

static void
putch(int ch, void *thunk)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80174c:	8b 53 04             	mov    0x4(%ebx),%edx
  80174f:	8d 42 01             	lea    0x1(%edx),%eax
  801752:	89 43 04             	mov    %eax,0x4(%ebx)
  801755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801758:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80175c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801761:	75 0e                	jne    801771 <putch+0x2f>
		writebuf(b);
  801763:	89 d8                	mov    %ebx,%eax
  801765:	e8 96 ff ff ff       	call   801700 <writebuf>
		b->idx = 0;
  80176a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801771:	83 c4 04             	add    $0x4,%esp
  801774:	5b                   	pop    %ebx
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801789:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801790:	00 00 00 
	b.result = 0;
  801793:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80179a:	00 00 00 
	b.error = 1;
  80179d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017a4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017a7:	ff 75 10             	pushl  0x10(%ebp)
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	68 42 17 80 00       	push   $0x801742
  8017b9:	e8 74 eb ff ff       	call   800332 <vprintfmt>
	if (b.idx > 0)
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017c8:	7e 0b                	jle    8017d5 <vfprintf+0x5e>
		writebuf(&b);
  8017ca:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d0:	e8 2b ff ff ff       	call   801700 <writebuf>

	return (b.result ? b.result : b.error);
  8017d5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	75 06                	jne    8017e5 <vfprintf+0x6e>
  8017df:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ed:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017f0:	50                   	push   %eax
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 7b ff ff ff       	call   801777 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <printf>:

int
printf(const char *fmt, ...)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801804:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	6a 01                	push   $0x1
  80180d:	e8 65 ff ff ff       	call   801777 <vfprintf>
	va_end(ap);

	return cnt;
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80181c:	83 ec 0c             	sub    $0xc,%esp
  80181f:	ff 75 08             	pushl  0x8(%ebp)
  801822:	e8 db f6 ff ff       	call   800f02 <fd2data>
  801827:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801829:	83 c4 08             	add    $0x8,%esp
  80182c:	68 8b 25 80 00       	push   $0x80258b
  801831:	53                   	push   %ebx
  801832:	e8 4d ef ff ff       	call   800784 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801837:	8b 56 04             	mov    0x4(%esi),%edx
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	2b 06                	sub    (%esi),%eax
  80183e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801844:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184b:	00 00 00 
	stat->st_dev = &devpipe;
  80184e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801855:	30 80 00 
	return 0;
}
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80186e:	53                   	push   %ebx
  80186f:	6a 00                	push   $0x0
  801871:	e8 9d f3 ff ff       	call   800c13 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801876:	89 1c 24             	mov    %ebx,(%esp)
  801879:	e8 84 f6 ff ff       	call   800f02 <fd2data>
  80187e:	83 c4 08             	add    $0x8,%esp
  801881:	50                   	push   %eax
  801882:	6a 00                	push   $0x0
  801884:	e8 8a f3 ff ff       	call   800c13 <sys_page_unmap>
}
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	83 ec 1c             	sub    $0x1c,%esp
  801897:	89 c7                	mov    %eax,%edi
  801899:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80189b:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	57                   	push   %edi
  8018a7:	e8 74 05 00 00       	call   801e20 <pageref>
  8018ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018af:	89 34 24             	mov    %esi,(%esp)
  8018b2:	e8 69 05 00 00       	call   801e20 <pageref>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018bd:	0f 94 c0             	sete   %al
  8018c0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018c3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018c9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018cc:	39 cb                	cmp    %ecx,%ebx
  8018ce:	74 15                	je     8018e5 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8018d0:	8b 52 58             	mov    0x58(%edx),%edx
  8018d3:	50                   	push   %eax
  8018d4:	52                   	push   %edx
  8018d5:	53                   	push   %ebx
  8018d6:	68 98 25 80 00       	push   $0x802598
  8018db:	e8 20 e9 ff ff       	call   800200 <cprintf>
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	eb b6                	jmp    80189b <_pipeisclosed+0xd>
	}
}
  8018e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5f                   	pop    %edi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	57                   	push   %edi
  8018f1:	56                   	push   %esi
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 28             	sub    $0x28,%esp
  8018f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f9:	56                   	push   %esi
  8018fa:	e8 03 f6 ff ff       	call   800f02 <fd2data>
  8018ff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	bf 00 00 00 00       	mov    $0x0,%edi
  801909:	eb 4b                	jmp    801956 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80190b:	89 da                	mov    %ebx,%edx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	e8 7a ff ff ff       	call   80188e <_pipeisclosed>
  801914:	85 c0                	test   %eax,%eax
  801916:	75 48                	jne    801960 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801918:	e8 52 f2 ff ff       	call   800b6f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191d:	8b 43 04             	mov    0x4(%ebx),%eax
  801920:	8b 0b                	mov    (%ebx),%ecx
  801922:	8d 51 20             	lea    0x20(%ecx),%edx
  801925:	39 d0                	cmp    %edx,%eax
  801927:	73 e2                	jae    80190b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801929:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801930:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801933:	89 c2                	mov    %eax,%edx
  801935:	c1 fa 1f             	sar    $0x1f,%edx
  801938:	89 d1                	mov    %edx,%ecx
  80193a:	c1 e9 1b             	shr    $0x1b,%ecx
  80193d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801940:	83 e2 1f             	and    $0x1f,%edx
  801943:	29 ca                	sub    %ecx,%edx
  801945:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801949:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80194d:	83 c0 01             	add    $0x1,%eax
  801950:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801953:	83 c7 01             	add    $0x1,%edi
  801956:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801959:	75 c2                	jne    80191d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80195b:	8b 45 10             	mov    0x10(%ebp),%eax
  80195e:	eb 05                	jmp    801965 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801965:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5f                   	pop    %edi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 18             	sub    $0x18,%esp
  801976:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801979:	57                   	push   %edi
  80197a:	e8 83 f5 ff ff       	call   800f02 <fd2data>
  80197f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	bb 00 00 00 00       	mov    $0x0,%ebx
  801989:	eb 3d                	jmp    8019c8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80198b:	85 db                	test   %ebx,%ebx
  80198d:	74 04                	je     801993 <devpipe_read+0x26>
				return i;
  80198f:	89 d8                	mov    %ebx,%eax
  801991:	eb 44                	jmp    8019d7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801993:	89 f2                	mov    %esi,%edx
  801995:	89 f8                	mov    %edi,%eax
  801997:	e8 f2 fe ff ff       	call   80188e <_pipeisclosed>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	75 32                	jne    8019d2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019a0:	e8 ca f1 ff ff       	call   800b6f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a5:	8b 06                	mov    (%esi),%eax
  8019a7:	3b 46 04             	cmp    0x4(%esi),%eax
  8019aa:	74 df                	je     80198b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ac:	99                   	cltd   
  8019ad:	c1 ea 1b             	shr    $0x1b,%edx
  8019b0:	01 d0                	add    %edx,%eax
  8019b2:	83 e0 1f             	and    $0x1f,%eax
  8019b5:	29 d0                	sub    %edx,%eax
  8019b7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019c2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c5:	83 c3 01             	add    $0x1,%ebx
  8019c8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019cb:	75 d8                	jne    8019a5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d0:	eb 05                	jmp    8019d7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5f                   	pop    %edi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	e8 29 f5 ff ff       	call   800f19 <fd_alloc>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 2c 01 00 00    	js     801b29 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	68 07 04 00 00       	push   $0x407
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 7f f1 ff ff       	call   800b8e <sys_page_alloc>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 0d 01 00 00    	js     801b29 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	e8 f1 f4 ff ff       	call   800f19 <fd_alloc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	0f 88 e2 00 00 00    	js     801b17 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	68 07 04 00 00       	push   $0x407
  801a3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a40:	6a 00                	push   $0x0
  801a42:	e8 47 f1 ff ff       	call   800b8e <sys_page_alloc>
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	0f 88 c3 00 00 00    	js     801b17 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5a:	e8 a3 f4 ff ff       	call   800f02 <fd2data>
  801a5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 c4 0c             	add    $0xc,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 1d f1 ff ff       	call   800b8e <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 89 00 00 00    	js     801b07 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f0             	pushl  -0x10(%ebp)
  801a84:	e8 79 f4 ff ff       	call   800f02 <fd2data>
  801a89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	56                   	push   %esi
  801a94:	6a 00                	push   $0x0
  801a96:	e8 36 f1 ff ff       	call   800bd1 <sys_page_map>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 55                	js     801af9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aa4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ab9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad4:	e8 19 f4 ff ff       	call   800ef2 <fd2num>
  801ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801adc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ade:	83 c4 04             	add    $0x4,%esp
  801ae1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae4:	e8 09 f4 ff ff       	call   800ef2 <fd2num>
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
  801af7:	eb 30                	jmp    801b29 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	56                   	push   %esi
  801afd:	6a 00                	push   $0x0
  801aff:	e8 0f f1 ff ff       	call   800c13 <sys_page_unmap>
  801b04:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b07:	83 ec 08             	sub    $0x8,%esp
  801b0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 ff f0 ff ff       	call   800c13 <sys_page_unmap>
  801b14:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	6a 00                	push   $0x0
  801b1f:	e8 ef f0 ff ff       	call   800c13 <sys_page_unmap>
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b29:	89 d0                	mov    %edx,%eax
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3b:	50                   	push   %eax
  801b3c:	ff 75 08             	pushl  0x8(%ebp)
  801b3f:	e8 24 f4 ff ff       	call   800f68 <fd_lookup>
  801b44:	89 c2                	mov    %eax,%edx
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 d2                	test   %edx,%edx
  801b4b:	78 18                	js     801b65 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	ff 75 f4             	pushl  -0xc(%ebp)
  801b53:	e8 aa f3 ff ff       	call   800f02 <fd2data>
	return _pipeisclosed(fd, p);
  801b58:	89 c2                	mov    %eax,%edx
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	e8 2c fd ff ff       	call   80188e <_pipeisclosed>
  801b62:	83 c4 10             	add    $0x10,%esp
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b77:	68 c9 25 80 00       	push   $0x8025c9
  801b7c:	ff 75 0c             	pushl  0xc(%ebp)
  801b7f:	e8 00 ec ff ff       	call   800784 <strcpy>
	return 0;
}
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b97:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b9c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba2:	eb 2e                	jmp    801bd2 <devcons_write+0x47>
		m = n - tot;
  801ba4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ba7:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801ba9:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801bae:	83 fa 7f             	cmp    $0x7f,%edx
  801bb1:	77 02                	ja     801bb5 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bb3:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	56                   	push   %esi
  801bb9:	03 45 0c             	add    0xc(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	57                   	push   %edi
  801bbe:	e8 53 ed ff ff       	call   800916 <memmove>
		sys_cputs(buf, m);
  801bc3:	83 c4 08             	add    $0x8,%esp
  801bc6:	56                   	push   %esi
  801bc7:	57                   	push   %edi
  801bc8:	e8 05 ef ff ff       	call   800ad2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bcd:	01 f3                	add    %esi,%ebx
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd7:	72 cb                	jb     801ba4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5f                   	pop    %edi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801bec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf0:	75 07                	jne    801bf9 <devcons_read+0x18>
  801bf2:	eb 28                	jmp    801c1c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bf4:	e8 76 ef ff ff       	call   800b6f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bf9:	e8 f2 ee ff ff       	call   800af0 <sys_cgetc>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	74 f2                	je     801bf4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 16                	js     801c1c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c06:	83 f8 04             	cmp    $0x4,%eax
  801c09:	74 0c                	je     801c17 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0e:	88 02                	mov    %al,(%edx)
	return 1;
  801c10:	b8 01 00 00 00       	mov    $0x1,%eax
  801c15:	eb 05                	jmp    801c1c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c2a:	6a 01                	push   $0x1
  801c2c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c2f:	50                   	push   %eax
  801c30:	e8 9d ee ff ff       	call   800ad2 <sys_cputs>
  801c35:	83 c4 10             	add    $0x10,%esp
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <getchar>:

int
getchar(void)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c40:	6a 01                	push   $0x1
  801c42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c45:	50                   	push   %eax
  801c46:	6a 00                	push   $0x0
  801c48:	e8 84 f5 ff ff       	call   8011d1 <read>
	if (r < 0)
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 0f                	js     801c63 <getchar+0x29>
		return r;
	if (r < 1)
  801c54:	85 c0                	test   %eax,%eax
  801c56:	7e 06                	jle    801c5e <getchar+0x24>
		return -E_EOF;
	return c;
  801c58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c5c:	eb 05                	jmp    801c63 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    

00801c65 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	ff 75 08             	pushl  0x8(%ebp)
  801c72:	e8 f1 f2 ff ff       	call   800f68 <fd_lookup>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	78 11                	js     801c8f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c87:	39 10                	cmp    %edx,(%eax)
  801c89:	0f 94 c0             	sete   %al
  801c8c:	0f b6 c0             	movzbl %al,%eax
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <opencons>:

int
opencons(void)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9a:	50                   	push   %eax
  801c9b:	e8 79 f2 ff ff       	call   800f19 <fd_alloc>
  801ca0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ca3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 3e                	js     801ce7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ca9:	83 ec 04             	sub    $0x4,%esp
  801cac:	68 07 04 00 00       	push   $0x407
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 d3 ee ff ff       	call   800b8e <sys_page_alloc>
  801cbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801cbe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 23                	js     801ce7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	50                   	push   %eax
  801cdd:	e8 10 f2 ff ff       	call   800ef2 <fd2num>
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	83 c4 10             	add    $0x10,%esp
}
  801ce7:	89 d0                	mov    %edx,%eax
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cf0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cf3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cf9:	e8 52 ee ff ff       	call   800b50 <sys_getenvid>
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 0c             	pushl  0xc(%ebp)
  801d04:	ff 75 08             	pushl  0x8(%ebp)
  801d07:	56                   	push   %esi
  801d08:	50                   	push   %eax
  801d09:	68 d8 25 80 00       	push   $0x8025d8
  801d0e:	e8 ed e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d13:	83 c4 18             	add    $0x18,%esp
  801d16:	53                   	push   %ebx
  801d17:	ff 75 10             	pushl  0x10(%ebp)
  801d1a:	e8 90 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d1f:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
  801d26:	e8 d5 e4 ff ff       	call   800200 <cprintf>
  801d2b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d2e:	cc                   	int3   
  801d2f:	eb fd                	jmp    801d2e <_panic+0x43>

00801d31 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	8b 75 08             	mov    0x8(%ebp),%esi
  801d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801d3f:	85 f6                	test   %esi,%esi
  801d41:	74 06                	je     801d49 <ipc_recv+0x18>
  801d43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801d49:	85 db                	test   %ebx,%ebx
  801d4b:	74 06                	je     801d53 <ipc_recv+0x22>
  801d4d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801d53:	83 f8 01             	cmp    $0x1,%eax
  801d56:	19 d2                	sbb    %edx,%edx
  801d58:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	50                   	push   %eax
  801d5e:	e8 db ef ff ff       	call   800d3e <sys_ipc_recv>
  801d63:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 d2                	test   %edx,%edx
  801d6a:	75 24                	jne    801d90 <ipc_recv+0x5f>
	if (from_env_store)
  801d6c:	85 f6                	test   %esi,%esi
  801d6e:	74 0a                	je     801d7a <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801d70:	a1 04 40 80 00       	mov    0x804004,%eax
  801d75:	8b 40 70             	mov    0x70(%eax),%eax
  801d78:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801d7a:	85 db                	test   %ebx,%ebx
  801d7c:	74 0a                	je     801d88 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801d7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801d83:	8b 40 74             	mov    0x74(%eax),%eax
  801d86:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801d88:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8d:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801d90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	57                   	push   %edi
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801da3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801da9:	83 fb 01             	cmp    $0x1,%ebx
  801dac:	19 c0                	sbb    %eax,%eax
  801dae:	09 c3                	or     %eax,%ebx
  801db0:	eb 1c                	jmp    801dce <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801db2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801db5:	74 12                	je     801dc9 <ipc_send+0x32>
  801db7:	50                   	push   %eax
  801db8:	68 fc 25 80 00       	push   $0x8025fc
  801dbd:	6a 36                	push   $0x36
  801dbf:	68 13 26 80 00       	push   $0x802613
  801dc4:	e8 22 ff ff ff       	call   801ceb <_panic>
		sys_yield();
  801dc9:	e8 a1 ed ff ff       	call   800b6f <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801dce:	ff 75 14             	pushl  0x14(%ebp)
  801dd1:	53                   	push   %ebx
  801dd2:	56                   	push   %esi
  801dd3:	57                   	push   %edi
  801dd4:	e8 42 ef ff ff       	call   800d1b <sys_ipc_try_send>
		if (ret == 0) break;
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	75 d2                	jne    801db2 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801df3:	6b d0 78             	imul   $0x78,%eax,%edx
  801df6:	83 c2 50             	add    $0x50,%edx
  801df9:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801dff:	39 ca                	cmp    %ecx,%edx
  801e01:	75 0d                	jne    801e10 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e03:	6b c0 78             	imul   $0x78,%eax,%eax
  801e06:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801e0b:	8b 40 08             	mov    0x8(%eax),%eax
  801e0e:	eb 0e                	jmp    801e1e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e10:	83 c0 01             	add    $0x1,%eax
  801e13:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e18:	75 d9                	jne    801df3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e1a:	66 b8 00 00          	mov    $0x0,%ax
}
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e26:	89 d0                	mov    %edx,%eax
  801e28:	c1 e8 16             	shr    $0x16,%eax
  801e2b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e37:	f6 c1 01             	test   $0x1,%cl
  801e3a:	74 1d                	je     801e59 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e3c:	c1 ea 0c             	shr    $0xc,%edx
  801e3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e46:	f6 c2 01             	test   $0x1,%dl
  801e49:	74 0e                	je     801e59 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e4b:	c1 ea 0c             	shr    $0xc,%edx
  801e4e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e55:	ef 
  801e56:	0f b7 c0             	movzwl %ax,%eax
}
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    
  801e5b:	66 90                	xchg   %ax,%ax
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 10             	sub    $0x10,%esp
  801e66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801e6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801e6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801e72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e76:	85 d2                	test   %edx,%edx
  801e78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e7c:	89 34 24             	mov    %esi,(%esp)
  801e7f:	89 c8                	mov    %ecx,%eax
  801e81:	75 35                	jne    801eb8 <__udivdi3+0x58>
  801e83:	39 f1                	cmp    %esi,%ecx
  801e85:	0f 87 bd 00 00 00    	ja     801f48 <__udivdi3+0xe8>
  801e8b:	85 c9                	test   %ecx,%ecx
  801e8d:	89 cd                	mov    %ecx,%ebp
  801e8f:	75 0b                	jne    801e9c <__udivdi3+0x3c>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	31 d2                	xor    %edx,%edx
  801e98:	f7 f1                	div    %ecx
  801e9a:	89 c5                	mov    %eax,%ebp
  801e9c:	89 f0                	mov    %esi,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	f7 f5                	div    %ebp
  801ea2:	89 c6                	mov    %eax,%esi
  801ea4:	89 f8                	mov    %edi,%eax
  801ea6:	f7 f5                	div    %ebp
  801ea8:	89 f2                	mov    %esi,%edx
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    
  801eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	3b 14 24             	cmp    (%esp),%edx
  801ebb:	77 7b                	ja     801f38 <__udivdi3+0xd8>
  801ebd:	0f bd f2             	bsr    %edx,%esi
  801ec0:	83 f6 1f             	xor    $0x1f,%esi
  801ec3:	0f 84 97 00 00 00    	je     801f60 <__udivdi3+0x100>
  801ec9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801ece:	89 d7                	mov    %edx,%edi
  801ed0:	89 f1                	mov    %esi,%ecx
  801ed2:	29 f5                	sub    %esi,%ebp
  801ed4:	d3 e7                	shl    %cl,%edi
  801ed6:	89 c2                	mov    %eax,%edx
  801ed8:	89 e9                	mov    %ebp,%ecx
  801eda:	d3 ea                	shr    %cl,%edx
  801edc:	89 f1                	mov    %esi,%ecx
  801ede:	09 fa                	or     %edi,%edx
  801ee0:	8b 3c 24             	mov    (%esp),%edi
  801ee3:	d3 e0                	shl    %cl,%eax
  801ee5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ef3:	89 fa                	mov    %edi,%edx
  801ef5:	d3 ea                	shr    %cl,%edx
  801ef7:	89 f1                	mov    %esi,%ecx
  801ef9:	d3 e7                	shl    %cl,%edi
  801efb:	89 e9                	mov    %ebp,%ecx
  801efd:	d3 e8                	shr    %cl,%eax
  801eff:	09 c7                	or     %eax,%edi
  801f01:	89 f8                	mov    %edi,%eax
  801f03:	f7 74 24 08          	divl   0x8(%esp)
  801f07:	89 d5                	mov    %edx,%ebp
  801f09:	89 c7                	mov    %eax,%edi
  801f0b:	f7 64 24 0c          	mull   0xc(%esp)
  801f0f:	39 d5                	cmp    %edx,%ebp
  801f11:	89 14 24             	mov    %edx,(%esp)
  801f14:	72 11                	jb     801f27 <__udivdi3+0xc7>
  801f16:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f1a:	89 f1                	mov    %esi,%ecx
  801f1c:	d3 e2                	shl    %cl,%edx
  801f1e:	39 c2                	cmp    %eax,%edx
  801f20:	73 5e                	jae    801f80 <__udivdi3+0x120>
  801f22:	3b 2c 24             	cmp    (%esp),%ebp
  801f25:	75 59                	jne    801f80 <__udivdi3+0x120>
  801f27:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f2a:	31 f6                	xor    %esi,%esi
  801f2c:	89 f2                	mov    %esi,%edx
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	5e                   	pop    %esi
  801f32:	5f                   	pop    %edi
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    
  801f35:	8d 76 00             	lea    0x0(%esi),%esi
  801f38:	31 f6                	xor    %esi,%esi
  801f3a:	31 c0                	xor    %eax,%eax
  801f3c:	89 f2                	mov    %esi,%edx
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    
  801f45:	8d 76 00             	lea    0x0(%esi),%esi
  801f48:	89 f2                	mov    %esi,%edx
  801f4a:	31 f6                	xor    %esi,%esi
  801f4c:	89 f8                	mov    %edi,%eax
  801f4e:	f7 f1                	div    %ecx
  801f50:	89 f2                	mov    %esi,%edx
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f64:	76 0b                	jbe    801f71 <__udivdi3+0x111>
  801f66:	31 c0                	xor    %eax,%eax
  801f68:	3b 14 24             	cmp    (%esp),%edx
  801f6b:	0f 83 37 ff ff ff    	jae    801ea8 <__udivdi3+0x48>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	e9 2d ff ff ff       	jmp    801ea8 <__udivdi3+0x48>
  801f7b:	90                   	nop
  801f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f80:	89 f8                	mov    %edi,%eax
  801f82:	31 f6                	xor    %esi,%esi
  801f84:	e9 1f ff ff ff       	jmp    801ea8 <__udivdi3+0x48>
  801f89:	66 90                	xchg   %ax,%ax
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	83 ec 20             	sub    $0x20,%esp
  801f96:	8b 44 24 34          	mov    0x34(%esp),%eax
  801f9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa2:	89 c6                	mov    %eax,%esi
  801fa4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fa8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801fb0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fb4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801fb8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	75 1e                	jne    801fe0 <__umoddi3+0x50>
  801fc2:	39 f7                	cmp    %esi,%edi
  801fc4:	76 52                	jbe    802018 <__umoddi3+0x88>
  801fc6:	89 c8                	mov    %ecx,%eax
  801fc8:	89 f2                	mov    %esi,%edx
  801fca:	f7 f7                	div    %edi
  801fcc:	89 d0                	mov    %edx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	83 c4 20             	add    $0x20,%esp
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	89 f6                	mov    %esi,%esi
  801fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801fe0:	39 f0                	cmp    %esi,%eax
  801fe2:	77 5c                	ja     802040 <__umoddi3+0xb0>
  801fe4:	0f bd e8             	bsr    %eax,%ebp
  801fe7:	83 f5 1f             	xor    $0x1f,%ebp
  801fea:	75 64                	jne    802050 <__umoddi3+0xc0>
  801fec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ff0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ff4:	0f 86 f6 00 00 00    	jbe    8020f0 <__umoddi3+0x160>
  801ffa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801ffe:	0f 82 ec 00 00 00    	jb     8020f0 <__umoddi3+0x160>
  802004:	8b 44 24 14          	mov    0x14(%esp),%eax
  802008:	8b 54 24 18          	mov    0x18(%esp),%edx
  80200c:	83 c4 20             	add    $0x20,%esp
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
  802013:	90                   	nop
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	85 ff                	test   %edi,%edi
  80201a:	89 fd                	mov    %edi,%ebp
  80201c:	75 0b                	jne    802029 <__umoddi3+0x99>
  80201e:	b8 01 00 00 00       	mov    $0x1,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f7                	div    %edi
  802027:	89 c5                	mov    %eax,%ebp
  802029:	8b 44 24 10          	mov    0x10(%esp),%eax
  80202d:	31 d2                	xor    %edx,%edx
  80202f:	f7 f5                	div    %ebp
  802031:	89 c8                	mov    %ecx,%eax
  802033:	f7 f5                	div    %ebp
  802035:	eb 95                	jmp    801fcc <__umoddi3+0x3c>
  802037:	89 f6                	mov    %esi,%esi
  802039:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	83 c4 20             	add    $0x20,%esp
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    
  80204b:	90                   	nop
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	b8 20 00 00 00       	mov    $0x20,%eax
  802055:	89 e9                	mov    %ebp,%ecx
  802057:	29 e8                	sub    %ebp,%eax
  802059:	d3 e2                	shl    %cl,%edx
  80205b:	89 c7                	mov    %eax,%edi
  80205d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802061:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e8                	shr    %cl,%eax
  802069:	89 c1                	mov    %eax,%ecx
  80206b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80206f:	09 d1                	or     %edx,%ecx
  802071:	89 fa                	mov    %edi,%edx
  802073:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802077:	89 e9                	mov    %ebp,%ecx
  802079:	d3 e0                	shl    %cl,%eax
  80207b:	89 f9                	mov    %edi,%ecx
  80207d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802081:	89 f0                	mov    %esi,%eax
  802083:	d3 e8                	shr    %cl,%eax
  802085:	89 e9                	mov    %ebp,%ecx
  802087:	89 c7                	mov    %eax,%edi
  802089:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80208d:	d3 e6                	shl    %cl,%esi
  80208f:	89 d1                	mov    %edx,%ecx
  802091:	89 fa                	mov    %edi,%edx
  802093:	d3 e8                	shr    %cl,%eax
  802095:	89 e9                	mov    %ebp,%ecx
  802097:	09 f0                	or     %esi,%eax
  802099:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80209d:	f7 74 24 10          	divl   0x10(%esp)
  8020a1:	d3 e6                	shl    %cl,%esi
  8020a3:	89 d1                	mov    %edx,%ecx
  8020a5:	f7 64 24 0c          	mull   0xc(%esp)
  8020a9:	39 d1                	cmp    %edx,%ecx
  8020ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8020af:	89 d7                	mov    %edx,%edi
  8020b1:	89 c6                	mov    %eax,%esi
  8020b3:	72 0a                	jb     8020bf <__umoddi3+0x12f>
  8020b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8020b9:	73 10                	jae    8020cb <__umoddi3+0x13b>
  8020bb:	39 d1                	cmp    %edx,%ecx
  8020bd:	75 0c                	jne    8020cb <__umoddi3+0x13b>
  8020bf:	89 d7                	mov    %edx,%edi
  8020c1:	89 c6                	mov    %eax,%esi
  8020c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8020c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8020cb:	89 ca                	mov    %ecx,%edx
  8020cd:	89 e9                	mov    %ebp,%ecx
  8020cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020d3:	29 f0                	sub    %esi,%eax
  8020d5:	19 fa                	sbb    %edi,%edx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8020de:	89 d7                	mov    %edx,%edi
  8020e0:	d3 e7                	shl    %cl,%edi
  8020e2:	89 e9                	mov    %ebp,%ecx
  8020e4:	09 f8                	or     %edi,%eax
  8020e6:	d3 ea                	shr    %cl,%edx
  8020e8:	83 c4 20             	add    $0x20,%esp
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    
  8020ef:	90                   	nop
  8020f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020f4:	29 f9                	sub    %edi,%ecx
  8020f6:	19 c6                	sbb    %eax,%esi
  8020f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802100:	e9 ff fe ff ff       	jmp    802004 <__umoddi3+0x74>
