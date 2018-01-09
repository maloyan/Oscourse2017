
obj/user/testpipe:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 40 	movl   $0x802440,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 f7 1b 00 00       	call   801c45 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %i", i);
  800057:	50                   	push   %eax
  800058:	68 4c 24 80 00       	push   $0x80244c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 55 24 80 00       	push   $0x802455
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 15 10 00 00       	call   801083 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %i", i);
  800074:	56                   	push   %esi
  800075:	68 59 29 80 00       	push   $0x802959
  80007a:	6a 11                	push   $0x11
  80007c:	68 55 24 80 00       	push   $0x802455
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 65 24 80 00       	push   $0x802465
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 59 13 00 00       	call   80140b <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 82 24 80 00       	push   $0x802482
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 00 15 00 00       	call   8015dc <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %i", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 9f 24 80 00       	push   $0x80249f
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 55 24 80 00       	push   $0x802455
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0b 09 00 00       	call   800a19 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 a8 24 80 00       	push   $0x8024a8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 c4 24 80 00       	push   $0x8024c4
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 65 24 80 00       	push   $0x802465
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 a1 12 00 00       	call   80140b <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 d7 24 80 00       	push   $0x8024d7
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a5 07 00 00       	call   800936 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 7e 14 00 00       	call   801621 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 83 07 00 00       	call   800936 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %i", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 f4 24 80 00       	push   $0x8024f4
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 55 24 80 00       	push   $0x802455
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 34 12 00 00       	call   80140b <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 ea 1b 00 00       	call   801dcd <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 fe 	movl   $0x8024fe,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 4d 1a 00 00       	call   801c45 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %i", i);
  800201:	50                   	push   %eax
  800202:	68 4c 24 80 00       	push   $0x80244c
  800207:	6a 2c                	push   $0x2c
  800209:	68 55 24 80 00       	push   $0x802455
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 6b 0e 00 00       	call   801083 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %i", i);
  80021e:	56                   	push   %esi
  80021f:	68 59 29 80 00       	push   $0x802959
  800224:	6a 2f                	push   $0x2f
  800226:	68 55 24 80 00       	push   $0x802455
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 cc 11 00 00       	call   80140b <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 0b 25 80 00       	push   $0x80250b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 0d 25 80 00       	push   $0x80250d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 c0 13 00 00       	call   801621 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 0f 25 80 00       	push   $0x80250f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 82 11 00 00       	call   80140b <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 77 11 00 00       	call   80140b <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 31 1b 00 00       	call   801dcd <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
  8002a8:	83 c4 10             	add    $0x10,%esp
}
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8002bd:	e8 79 0a 00 00       	call   800d3b <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 78             	imul   $0x78,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
  8002ee:	83 c4 10             	add    $0x10,%esp
#endif
}
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 35 11 00 00       	call   801438 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 ed 09 00 00       	call   800cfa <sys_env_destroy>
  80030d:	83 c4 10             	add    $0x10,%esp
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 16 0a 00 00       	call   800d3b <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 90 25 80 00       	push   $0x802590
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 35 09 00 00       	call   800cbd <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 4f 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 da 08 00 00       	call   800cbd <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 d1                	mov    %edx,%ecx
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80041a:	8b 45 10             	mov    0x10(%ebp),%eax
  80041d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80042d:	72 05                	jb     800434 <printnum+0x35>
  80042f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800432:	77 3e                	ja     800472 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	83 ec 0c             	sub    $0xc,%esp
  800437:	ff 75 18             	pushl  0x18(%ebp)
  80043a:	83 eb 01             	sub    $0x1,%ebx
  80043d:	53                   	push   %ebx
  80043e:	50                   	push   %eax
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 1d 1d 00 00       	call   802170 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 13                	jmp    800479 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f ed                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	e8 0f 1e 00 00       	call   8022a0 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 b3 25 80 00 	movsbl 0x8025b3(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
  80049e:	83 c4 10             	add    $0x10,%esp
}
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ac:	83 fa 01             	cmp    $0x1,%edx
  8004af:	7e 0e                	jle    8004bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 02                	mov    (%edx),%eax
  8004ba:	8b 52 04             	mov    0x4(%edx),%edx
  8004bd:	eb 22                	jmp    8004e1 <getuint+0x38>
	else if (lflag)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 10                	je     8004d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	eb 0e                	jmp    8004e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800509:	50                   	push   %eax
  80050a:	ff 75 10             	pushl  0x10(%ebp)
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 05 00 00 00       	call   80051d <vprintfmt>
	va_end(ap);
  800518:	83 c4 10             	add    $0x10,%esp
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052f:	eb 12                	jmp    800543 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 84 8d 03 00 00    	je     8008c6 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	50                   	push   %eax
  80053e:	ff d6                	call   *%esi
  800540:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800543:	83 c7 01             	add    $0x1,%edi
  800546:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054a:	83 f8 25             	cmp    $0x25,%eax
  80054d:	75 e2                	jne    800531 <vprintfmt+0x14>
  80054f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800553:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800561:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800568:	ba 00 00 00 00       	mov    $0x0,%edx
  80056d:	eb 07                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800572:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8d 47 01             	lea    0x1(%edi),%eax
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	0f b6 07             	movzbl (%edi),%eax
  80057f:	0f b6 c8             	movzbl %al,%ecx
  800582:	83 e8 23             	sub    $0x23,%eax
  800585:	3c 55                	cmp    $0x55,%al
  800587:	0f 87 1e 03 00 00    	ja     8008ab <vprintfmt+0x38e>
  80058d:	0f b6 c0             	movzbl %al,%eax
  800590:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059e:	eb d6                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 38                	ja     8005f5 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c0:	eb e9                	jmp    8005ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d3:	eb 26                	jmp    8005fb <vprintfmt+0xde>
  8005d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d8:	89 c8                	mov    %ecx,%eax
  8005da:	c1 f8 1f             	sar    $0x1f,%eax
  8005dd:	f7 d0                	not    %eax
  8005df:	21 c1                	and    %eax,%ecx
  8005e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	eb 8d                	jmp    800576 <vprintfmt+0x59>
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f3:	eb 81                	jmp    800576 <vprintfmt+0x59>
  8005f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ff:	0f 89 71 ff ff ff    	jns    800576 <vprintfmt+0x59>
				width = precision, precision = -1;
  800605:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800608:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800612:	e9 5f ff ff ff       	jmp    800576 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800617:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061d:	e9 54 ff ff ff       	jmp    800576 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	ff 30                	pushl  (%eax)
  800631:	ff d6                	call   *%esi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800639:	e9 05 ff ff ff       	jmp    800543 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	99                   	cltd   
  80064a:	31 d0                	xor    %edx,%eax
  80064c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064e:	83 f8 0f             	cmp    $0xf,%eax
  800651:	7f 0b                	jg     80065e <vprintfmt+0x141>
  800653:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80065a:	85 d2                	test   %edx,%edx
  80065c:	75 18                	jne    800676 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80065e:	50                   	push   %eax
  80065f:	68 cb 25 80 00       	push   $0x8025cb
  800664:	53                   	push   %ebx
  800665:	56                   	push   %esi
  800666:	e8 95 fe ff ff       	call   800500 <printfmt>
  80066b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800671:	e9 cd fe ff ff       	jmp    800543 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800676:	52                   	push   %edx
  800677:	68 41 2a 80 00       	push   $0x802a41
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 7d fe ff ff       	call   800500 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800689:	e9 b5 fe ff ff       	jmp    800543 <vprintfmt+0x26>
  80068e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800691:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800694:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 38                	mov    (%eax),%edi
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	75 05                	jne    8006ab <vprintfmt+0x18e>
				p = "(null)";
  8006a6:	bf c4 25 80 00       	mov    $0x8025c4,%edi
			if (width > 0 && padc != '-')
  8006ab:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006af:	0f 84 91 00 00 00    	je     800746 <vprintfmt+0x229>
  8006b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006b9:	0f 8e 95 00 00 00    	jle    800754 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	51                   	push   %ecx
  8006c3:	57                   	push   %edi
  8006c4:	e8 85 02 00 00       	call   80094e <strnlen>
  8006c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c5>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	89 c8                	mov    %ecx,%eax
  8006fd:	c1 f8 1f             	sar    $0x1f,%eax
  800700:	f7 d0                	not    %eax
  800702:	21 c8                	and    %ecx,%eax
  800704:	29 c1                	sub    %eax,%ecx
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070f:	89 cb                	mov    %ecx,%ebx
  800711:	eb 4d                	jmp    800760 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800713:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800717:	74 1b                	je     800734 <vprintfmt+0x217>
  800719:	0f be c0             	movsbl %al,%eax
  80071c:	83 e8 20             	sub    $0x20,%eax
  80071f:	83 f8 5e             	cmp    $0x5e,%eax
  800722:	76 10                	jbe    800734 <vprintfmt+0x217>
					putch('?', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	6a 3f                	push   $0x3f
  80072c:	ff 55 08             	call   *0x8(%ebp)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb 0d                	jmp    800741 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	52                   	push   %edx
  80073b:	ff 55 08             	call   *0x8(%ebp)
  80073e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800741:	83 eb 01             	sub    $0x1,%ebx
  800744:	eb 1a                	jmp    800760 <vprintfmt+0x243>
  800746:	89 75 08             	mov    %esi,0x8(%ebp)
  800749:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800752:	eb 0c                	jmp    800760 <vprintfmt+0x243>
  800754:	89 75 08             	mov    %esi,0x8(%ebp)
  800757:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800760:	83 c7 01             	add    $0x1,%edi
  800763:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800767:	0f be d0             	movsbl %al,%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 23                	je     800791 <vprintfmt+0x274>
  80076e:	85 f6                	test   %esi,%esi
  800770:	78 a1                	js     800713 <vprintfmt+0x1f6>
  800772:	83 ee 01             	sub    $0x1,%esi
  800775:	79 9c                	jns    800713 <vprintfmt+0x1f6>
  800777:	89 df                	mov    %ebx,%edi
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077f:	eb 18                	jmp    800799 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 20                	push   $0x20
  800787:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800789:	83 ef 01             	sub    $0x1,%edi
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 08                	jmp    800799 <vprintfmt+0x27c>
  800791:	89 df                	mov    %ebx,%edi
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800799:	85 ff                	test   %edi,%edi
  80079b:	7f e4                	jg     800781 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a0:	e9 9e fd ff ff       	jmp    800543 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a5:	83 fa 01             	cmp    $0x1,%edx
  8007a8:	7e 16                	jle    8007c0 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 08             	lea    0x8(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 50 04             	mov    0x4(%eax),%edx
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007be:	eb 32                	jmp    8007f2 <vprintfmt+0x2d5>
	else if (lflag)
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 18                	je     8007dc <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 c1                	mov    %eax,%ecx
  8007d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007da:	eb 16                	jmp    8007f2 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 00                	mov    (%eax),%eax
  8007e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ea:	89 c1                	mov    %eax,%ecx
  8007ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800801:	79 74                	jns    800877 <vprintfmt+0x35a>
				putch('-', putdat);
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 2d                	push   $0x2d
  800809:	ff d6                	call   *%esi
				num = -(long long) num;
  80080b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800811:	f7 d8                	neg    %eax
  800813:	83 d2 00             	adc    $0x0,%edx
  800816:	f7 da                	neg    %edx
  800818:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800820:	eb 55                	jmp    800877 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800822:	8d 45 14             	lea    0x14(%ebp),%eax
  800825:	e8 7f fc ff ff       	call   8004a9 <getuint>
			base = 10;
  80082a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082f:	eb 46                	jmp    800877 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	e8 70 fc ff ff       	call   8004a9 <getuint>
			base = 8;
  800839:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083e:	eb 37                	jmp    800877 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	53                   	push   %ebx
  800844:	6a 30                	push   $0x30
  800846:	ff d6                	call   *%esi
			putch('x', putdat);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	53                   	push   %ebx
  80084c:	6a 78                	push   $0x78
  80084e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800859:	8b 00                	mov    (%eax),%eax
  80085b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800860:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800863:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800868:	eb 0d                	jmp    800877 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
  80086d:	e8 37 fc ff ff       	call   8004a9 <getuint>
			base = 16;
  800872:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800877:	83 ec 0c             	sub    $0xc,%esp
  80087a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087e:	57                   	push   %edi
  80087f:	ff 75 e0             	pushl  -0x20(%ebp)
  800882:	51                   	push   %ecx
  800883:	52                   	push   %edx
  800884:	50                   	push   %eax
  800885:	89 da                	mov    %ebx,%edx
  800887:	89 f0                	mov    %esi,%eax
  800889:	e8 71 fb ff ff       	call   8003ff <printnum>
			break;
  80088e:	83 c4 20             	add    $0x20,%esp
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800894:	e9 aa fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	51                   	push   %ecx
  80089e:	ff d6                	call   *%esi
			break;
  8008a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a6:	e9 98 fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 25                	push   $0x25
  8008b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	eb 03                	jmp    8008bb <vprintfmt+0x39e>
  8008b8:	83 ef 01             	sub    $0x1,%edi
  8008bb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008bf:	75 f7                	jne    8008b8 <vprintfmt+0x39b>
  8008c1:	e9 7d fc ff ff       	jmp    800543 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 18             	sub    $0x18,%esp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	74 26                	je     800915 <vsnprintf+0x47>
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	7e 22                	jle    800915 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f3:	ff 75 14             	pushl  0x14(%ebp)
  8008f6:	ff 75 10             	pushl  0x10(%ebp)
  8008f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fc:	50                   	push   %eax
  8008fd:	68 e3 04 80 00       	push   $0x8004e3
  800902:	e8 16 fc ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800907:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	eb 05                	jmp    80091a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800915:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800925:	50                   	push   %eax
  800926:	ff 75 10             	pushl  0x10(%ebp)
  800929:	ff 75 0c             	pushl  0xc(%ebp)
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 9a ff ff ff       	call   8008ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	eb 03                	jmp    800946 <strlen+0x10>
		n++;
  800943:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800946:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094a:	75 f7                	jne    800943 <strlen+0xd>
		n++;
	return n;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800957:	ba 00 00 00 00       	mov    $0x0,%edx
  80095c:	eb 03                	jmp    800961 <strnlen+0x13>
		n++;
  80095e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800961:	39 c2                	cmp    %eax,%edx
  800963:	74 08                	je     80096d <strnlen+0x1f>
  800965:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800969:	75 f3                	jne    80095e <strnlen+0x10>
  80096b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	89 c2                	mov    %eax,%edx
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	83 c1 01             	add    $0x1,%ecx
  800981:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800985:	88 5a ff             	mov    %bl,-0x1(%edx)
  800988:	84 db                	test   %bl,%bl
  80098a:	75 ef                	jne    80097b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098c:	5b                   	pop    %ebx
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800996:	53                   	push   %ebx
  800997:	e8 9a ff ff ff       	call   800936 <strlen>
  80099c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	01 d8                	add    %ebx,%eax
  8009a4:	50                   	push   %eax
  8009a5:	e8 c5 ff ff ff       	call   80096f <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c1:	89 f2                	mov    %esi,%edx
  8009c3:	eb 0f                	jmp    8009d4 <strncpy+0x23>
		*dst++ = *src;
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ce:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	39 da                	cmp    %ebx,%edx
  8009d6:	75 ed                	jne    8009c5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d8:	89 f0                	mov    %esi,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ee:	85 d2                	test   %edx,%edx
  8009f0:	74 21                	je     800a13 <strlcpy+0x35>
  8009f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f6:	89 f2                	mov    %esi,%edx
  8009f8:	eb 09                	jmp    800a03 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fa:	83 c2 01             	add    $0x1,%edx
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a03:	39 c2                	cmp    %eax,%edx
  800a05:	74 09                	je     800a10 <strlcpy+0x32>
  800a07:	0f b6 19             	movzbl (%ecx),%ebx
  800a0a:	84 db                	test   %bl,%bl
  800a0c:	75 ec                	jne    8009fa <strlcpy+0x1c>
  800a0e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a10:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a13:	29 f0                	sub    %esi,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a22:	eb 06                	jmp    800a2a <strcmp+0x11>
		p++, q++;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2a:	0f b6 01             	movzbl (%ecx),%eax
  800a2d:	84 c0                	test   %al,%al
  800a2f:	74 04                	je     800a35 <strcmp+0x1c>
  800a31:	3a 02                	cmp    (%edx),%al
  800a33:	74 ef                	je     800a24 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 12             	movzbl (%edx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4e:	eb 06                	jmp    800a56 <strncmp+0x17>
		n--, p++, q++;
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a56:	39 d8                	cmp    %ebx,%eax
  800a58:	74 15                	je     800a6f <strncmp+0x30>
  800a5a:	0f b6 08             	movzbl (%eax),%ecx
  800a5d:	84 c9                	test   %cl,%cl
  800a5f:	74 04                	je     800a65 <strncmp+0x26>
  800a61:	3a 0a                	cmp    (%edx),%cl
  800a63:	74 eb                	je     800a50 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a65:	0f b6 00             	movzbl (%eax),%eax
  800a68:	0f b6 12             	movzbl (%edx),%edx
  800a6b:	29 d0                	sub    %edx,%eax
  800a6d:	eb 05                	jmp    800a74 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a81:	eb 07                	jmp    800a8a <strchr+0x13>
		if (*s == c)
  800a83:	38 ca                	cmp    %cl,%dl
  800a85:	74 0f                	je     800a96 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	0f b6 10             	movzbl (%eax),%edx
  800a8d:	84 d2                	test   %dl,%dl
  800a8f:	75 f2                	jne    800a83 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa2:	eb 03                	jmp    800aa7 <strfind+0xf>
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aaa:	84 d2                	test   %dl,%dl
  800aac:	74 04                	je     800ab2 <strfind+0x1a>
  800aae:	38 ca                	cmp    %cl,%dl
  800ab0:	75 f2                	jne    800aa4 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 36                	je     800afa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 28                	jne    800af4 <memset+0x40>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 23                	jne    800af4 <memset+0x40>
		c &= 0xFF;
  800ad1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	c1 e3 08             	shl    $0x8,%ebx
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	c1 e6 18             	shl    $0x18,%esi
  800adf:	89 d0                	mov    %edx,%eax
  800ae1:	c1 e0 10             	shl    $0x10,%eax
  800ae4:	09 f0                	or     %esi,%eax
  800ae6:	09 c2                	or     %eax,%edx
  800ae8:	89 d0                	mov    %edx,%eax
  800aea:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aec:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aef:	fc                   	cld    
  800af0:	f3 ab                	rep stos %eax,%es:(%edi)
  800af2:	eb 06                	jmp    800afa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	fc                   	cld    
  800af8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afa:	89 f8                	mov    %edi,%eax
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0f:	39 c6                	cmp    %eax,%esi
  800b11:	73 35                	jae    800b48 <memmove+0x47>
  800b13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b16:	39 d0                	cmp    %edx,%eax
  800b18:	73 2e                	jae    800b48 <memmove+0x47>
		s += n;
		d += n;
  800b1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b27:	75 13                	jne    800b3c <memmove+0x3b>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 0e                	jne    800b3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b2e:	83 ef 04             	sub    $0x4,%edi
  800b31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b34:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b37:	fd                   	std    
  800b38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3a:	eb 09                	jmp    800b45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3c:	83 ef 01             	sub    $0x1,%edi
  800b3f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b42:	fd                   	std    
  800b43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b45:	fc                   	cld    
  800b46:	eb 1d                	jmp    800b65 <memmove+0x64>
  800b48:	89 f2                	mov    %esi,%edx
  800b4a:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4c:	f6 c2 03             	test   $0x3,%dl
  800b4f:	75 0f                	jne    800b60 <memmove+0x5f>
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 0a                	jne    800b60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b56:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	fc                   	cld    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 05                	jmp    800b65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b60:	89 c7                	mov    %eax,%edi
  800b62:	fc                   	cld    
  800b63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6c:	ff 75 10             	pushl  0x10(%ebp)
  800b6f:	ff 75 0c             	pushl  0xc(%ebp)
  800b72:	ff 75 08             	pushl  0x8(%ebp)
  800b75:	e8 87 ff ff ff       	call   800b01 <memmove>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b87:	89 c6                	mov    %eax,%esi
  800b89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	eb 1a                	jmp    800ba8 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8e:	0f b6 08             	movzbl (%eax),%ecx
  800b91:	0f b6 1a             	movzbl (%edx),%ebx
  800b94:	38 d9                	cmp    %bl,%cl
  800b96:	74 0a                	je     800ba2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b98:	0f b6 c1             	movzbl %cl,%eax
  800b9b:	0f b6 db             	movzbl %bl,%ebx
  800b9e:	29 d8                	sub    %ebx,%eax
  800ba0:	eb 0f                	jmp    800bb1 <memcmp+0x35>
		s1++, s2++;
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	75 e2                	jne    800b8e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc3:	eb 07                	jmp    800bcc <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc5:	38 08                	cmp    %cl,(%eax)
  800bc7:	74 07                	je     800bd0 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	39 d0                	cmp    %edx,%eax
  800bce:	72 f5                	jb     800bc5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bde:	eb 03                	jmp    800be3 <strtol+0x11>
		s++;
  800be0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be3:	0f b6 01             	movzbl (%ecx),%eax
  800be6:	3c 09                	cmp    $0x9,%al
  800be8:	74 f6                	je     800be0 <strtol+0xe>
  800bea:	3c 20                	cmp    $0x20,%al
  800bec:	74 f2                	je     800be0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bee:	3c 2b                	cmp    $0x2b,%al
  800bf0:	75 0a                	jne    800bfc <strtol+0x2a>
		s++;
  800bf2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfa:	eb 10                	jmp    800c0c <strtol+0x3a>
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c01:	3c 2d                	cmp    $0x2d,%al
  800c03:	75 07                	jne    800c0c <strtol+0x3a>
		s++, neg = 1;
  800c05:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c08:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0c:	85 db                	test   %ebx,%ebx
  800c0e:	0f 94 c0             	sete   %al
  800c11:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c17:	75 19                	jne    800c32 <strtol+0x60>
  800c19:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1c:	75 14                	jne    800c32 <strtol+0x60>
  800c1e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c22:	0f 85 8a 00 00 00    	jne    800cb2 <strtol+0xe0>
		s += 2, base = 16;
  800c28:	83 c1 02             	add    $0x2,%ecx
  800c2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c30:	eb 16                	jmp    800c48 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c32:	84 c0                	test   %al,%al
  800c34:	74 12                	je     800c48 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c36:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3e:	75 08                	jne    800c48 <strtol+0x76>
		s++, base = 8;
  800c40:	83 c1 01             	add    $0x1,%ecx
  800c43:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c48:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c50:	0f b6 11             	movzbl (%ecx),%edx
  800c53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c56:	89 f3                	mov    %esi,%ebx
  800c58:	80 fb 09             	cmp    $0x9,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0x93>
			dig = *s - '0';
  800c5d:	0f be d2             	movsbl %dl,%edx
  800c60:	83 ea 30             	sub    $0x30,%edx
  800c63:	eb 22                	jmp    800c87 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c65:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c68:	89 f3                	mov    %esi,%ebx
  800c6a:	80 fb 19             	cmp    $0x19,%bl
  800c6d:	77 08                	ja     800c77 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c6f:	0f be d2             	movsbl %dl,%edx
  800c72:	83 ea 57             	sub    $0x57,%edx
  800c75:	eb 10                	jmp    800c87 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c77:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7a:	89 f3                	mov    %esi,%ebx
  800c7c:	80 fb 19             	cmp    $0x19,%bl
  800c7f:	77 16                	ja     800c97 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c81:	0f be d2             	movsbl %dl,%edx
  800c84:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c87:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8a:	7d 0f                	jge    800c9b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c8c:	83 c1 01             	add    $0x1,%ecx
  800c8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c93:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c95:	eb b9                	jmp    800c50 <strtol+0x7e>
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	eb 02                	jmp    800c9d <strtol+0xcb>
  800c9b:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca1:	74 05                	je     800ca8 <strtol+0xd6>
		*endptr = (char *) s;
  800ca3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	74 0c                	je     800cb8 <strtol+0xe6>
  800cac:	89 d0                	mov    %edx,%eax
  800cae:	f7 d8                	neg    %eax
  800cb0:	eb 06                	jmp    800cb8 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb2:	84 c0                	test   %al,%al
  800cb4:	75 8a                	jne    800c40 <strtol+0x6e>
  800cb6:	eb 90                	jmp    800c48 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	89 c3                	mov    %eax,%ebx
  800cd0:	89 c7                	mov    %eax,%edi
  800cd2:	89 c6                	mov    %eax,%esi
  800cd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	89 d3                	mov    %edx,%ebx
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	89 d6                	mov    %edx,%esi
  800cf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d08:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 cb                	mov    %ecx,%ebx
  800d12:	89 cf                	mov    %ecx,%edi
  800d14:	89 ce                	mov    %ecx,%esi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 03                	push   $0x3
  800d22:	68 df 28 80 00       	push   $0x8028df
  800d27:	6a 23                	push   $0x23
  800d29:	68 fc 28 80 00       	push   $0x8028fc
  800d2e:	e8 df f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	ba 00 00 00 00       	mov    $0x0,%edx
  800d46:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4b:	89 d1                	mov    %edx,%ecx
  800d4d:	89 d3                	mov    %edx,%ebx
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 d6                	mov    %edx,%esi
  800d53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_yield>:

void
sys_yield(void)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	ba 00 00 00 00       	mov    $0x0,%edx
  800d65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6a:	89 d1                	mov    %edx,%ecx
  800d6c:	89 d3                	mov    %edx,%ebx
  800d6e:	89 d7                	mov    %edx,%edi
  800d70:	89 d6                	mov    %edx,%esi
  800d72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	be 00 00 00 00       	mov    $0x0,%esi
  800d87:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d95:	89 f7                	mov    %esi,%edi
  800d97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 17                	jle    800db4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	50                   	push   %eax
  800da1:	6a 04                	push   $0x4
  800da3:	68 df 28 80 00       	push   $0x8028df
  800da8:	6a 23                	push   $0x23
  800daa:	68 fc 28 80 00       	push   $0x8028fc
  800daf:	e8 5e f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7e 17                	jle    800df6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	50                   	push   %eax
  800de3:	6a 05                	push   $0x5
  800de5:	68 df 28 80 00       	push   $0x8028df
  800dea:	6a 23                	push   $0x23
  800dec:	68 fc 28 80 00       	push   $0x8028fc
  800df1:	e8 1c f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	89 df                	mov    %ebx,%edi
  800e19:	89 de                	mov    %ebx,%esi
  800e1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 17                	jle    800e38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	83 ec 0c             	sub    $0xc,%esp
  800e24:	50                   	push   %eax
  800e25:	6a 06                	push   $0x6
  800e27:	68 df 28 80 00       	push   $0x8028df
  800e2c:	6a 23                	push   $0x23
  800e2e:	68 fc 28 80 00       	push   $0x8028fc
  800e33:	e8 da f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 df                	mov    %ebx,%edi
  800e5b:	89 de                	mov    %ebx,%esi
  800e5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 17                	jle    800e7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	50                   	push   %eax
  800e67:	6a 08                	push   $0x8
  800e69:	68 df 28 80 00       	push   $0x8028df
  800e6e:	6a 23                	push   $0x23
  800e70:	68 fc 28 80 00       	push   $0x8028fc
  800e75:	e8 98 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e90:	b8 09 00 00 00       	mov    $0x9,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 df                	mov    %ebx,%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 17                	jle    800ebc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	83 ec 0c             	sub    $0xc,%esp
  800ea8:	50                   	push   %eax
  800ea9:	6a 09                	push   $0x9
  800eab:	68 df 28 80 00       	push   $0x8028df
  800eb0:	6a 23                	push   $0x23
  800eb2:	68 fc 28 80 00       	push   $0x8028fc
  800eb7:	e8 56 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 df                	mov    %ebx,%edi
  800edf:	89 de                	mov    %ebx,%esi
  800ee1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 17                	jle    800efe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	50                   	push   %eax
  800eeb:	6a 0a                	push   $0xa
  800eed:	68 df 28 80 00       	push   $0x8028df
  800ef2:	6a 23                	push   $0x23
  800ef4:	68 fc 28 80 00       	push   $0x8028fc
  800ef9:	e8 14 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	be 00 00 00 00       	mov    $0x0,%esi
  800f11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3f:	89 cb                	mov    %ecx,%ebx
  800f41:	89 cf                	mov    %ecx,%edi
  800f43:	89 ce                	mov    %ecx,%esi
  800f45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	7e 17                	jle    800f62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	50                   	push   %eax
  800f4f:	6a 0d                	push   $0xd
  800f51:	68 df 28 80 00       	push   $0x8028df
  800f56:	6a 23                	push   $0x23
  800f58:	68 fc 28 80 00       	push   $0x8028fc
  800f5d:	e8 b0 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_gettime>:

int sys_gettime(void)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f70:	ba 00 00 00 00       	mov    $0x0,%edx
  800f75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f7a:	89 d1                	mov    %edx,%ecx
  800f7c:	89 d3                	mov    %edx,%ebx
  800f7e:	89 d7                	mov    %edx,%edi
  800f80:	89 d6                	mov    %edx,%esi
  800f82:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800f93:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f95:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f99:	74 2e                	je     800fc9 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800f9b:	89 c2                	mov    %eax,%edx
  800f9d:	c1 ea 16             	shr    $0x16,%edx
  800fa0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800fa7:	f6 c2 01             	test   $0x1,%dl
  800faa:	74 1d                	je     800fc9 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800fac:	89 c2                	mov    %eax,%edx
  800fae:	c1 ea 0c             	shr    $0xc,%edx
  800fb1:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800fb8:	f6 c1 01             	test   $0x1,%cl
  800fbb:	74 0c                	je     800fc9 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800fbd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800fc4:	f6 c6 08             	test   $0x8,%dh
  800fc7:	75 14                	jne    800fdd <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	68 0a 29 80 00       	push   $0x80290a
  800fd1:	6a 28                	push   $0x28
  800fd3:	68 1c 29 80 00       	push   $0x80291c
  800fd8:	e8 35 f3 ff ff       	call   800312 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800fdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fe2:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	6a 07                	push   $0x7
  800fe9:	68 00 f0 7f 00       	push   $0x7ff000
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 84 fd ff ff       	call   800d79 <sys_page_alloc>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 14                	jns    801010 <pgfault+0x87>
		panic("sys_page_alloc");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 27 29 80 00       	push   $0x802927
  801004:	6a 2c                	push   $0x2c
  801006:	68 1c 29 80 00       	push   $0x80291c
  80100b:	e8 02 f3 ff ff       	call   800312 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	68 00 10 00 00       	push   $0x1000
  801018:	53                   	push   %ebx
  801019:	68 00 f0 7f 00       	push   $0x7ff000
  80101e:	e8 46 fb ff ff       	call   800b69 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801023:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102a:	53                   	push   %ebx
  80102b:	6a 00                	push   $0x0
  80102d:	68 00 f0 7f 00       	push   $0x7ff000
  801032:	6a 00                	push   $0x0
  801034:	e8 83 fd ff ff       	call   800dbc <sys_page_map>
  801039:	83 c4 20             	add    $0x20,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	79 14                	jns    801054 <pgfault+0xcb>
		panic("sys_page_map");
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	68 36 29 80 00       	push   $0x802936
  801048:	6a 2f                	push   $0x2f
  80104a:	68 1c 29 80 00       	push   $0x80291c
  80104f:	e8 be f2 ff ff       	call   800312 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	68 00 f0 7f 00       	push   $0x7ff000
  80105c:	6a 00                	push   $0x0
  80105e:	e8 9b fd ff ff       	call   800dfe <sys_page_unmap>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	79 14                	jns    80107e <pgfault+0xf5>
		panic("sys_page_unmap");
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	68 43 29 80 00       	push   $0x802943
  801072:	6a 31                	push   $0x31
  801074:	68 1c 29 80 00       	push   $0x80291c
  801079:	e8 94 f2 ff ff       	call   800312 <_panic>
	return;
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  80108c:	68 89 0f 80 00       	push   $0x800f89
  801091:	e8 15 0f 00 00       	call   801fab <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801096:	b8 07 00 00 00       	mov    $0x7,%eax
  80109b:	cd 30                	int    $0x30
  80109d:	89 c7                	mov    %eax,%edi
  80109f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	75 21                	jne    8010ca <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010a9:	e8 8d fc ff ff       	call   800d3b <sys_getenvid>
  8010ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010b3:	6b c0 78             	imul   $0x78,%eax,%eax
  8010b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010bb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c5:	e9 80 01 00 00       	jmp    80124a <fork+0x1c7>
	}
	if (envid < 0)
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 12                	jns    8010e0 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  8010ce:	50                   	push   %eax
  8010cf:	68 52 29 80 00       	push   $0x802952
  8010d4:	6a 70                	push   $0x70
  8010d6:	68 1c 29 80 00       	push   $0x80291c
  8010db:	e8 32 f2 ff ff       	call   800312 <_panic>
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	c1 e8 16             	shr    $0x16,%eax
  8010ea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f1:	a8 01                	test   $0x1,%al
  8010f3:	0f 84 de 00 00 00    	je     8011d7 <fork+0x154>
  8010f9:	89 de                	mov    %ebx,%esi
  8010fb:	c1 ee 0c             	shr    $0xc,%esi
  8010fe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801105:	a8 01                	test   $0x1,%al
  801107:	0f 84 ca 00 00 00    	je     8011d7 <fork+0x154>
  80110d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801114:	a8 04                	test   $0x4,%al
  801116:	0f 84 bb 00 00 00    	je     8011d7 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  80111c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  801123:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  801126:	f6 c4 04             	test   $0x4,%ah
  801129:	74 34                	je     80115f <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	56                   	push   %esi
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	56                   	push   %esi
  801139:	6a 00                	push   $0x0
  80113b:	e8 7c fc ff ff       	call   800dbc <sys_page_map>
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	0f 84 8c 00 00 00    	je     8011d7 <fork+0x154>
        	panic("duppage share");
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	68 62 29 80 00       	push   $0x802962
  801153:	6a 48                	push   $0x48
  801155:	68 1c 29 80 00       	push   $0x80291c
  80115a:	e8 b3 f1 ff ff       	call   800312 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  80115f:	a9 02 08 00 00       	test   $0x802,%eax
  801164:	74 5d                	je     8011c3 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	68 05 08 00 00       	push   $0x805
  80116e:	56                   	push   %esi
  80116f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 42 fc ff ff       	call   800dbc <sys_page_map>
  80117a:	83 c4 20             	add    $0x20,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 14                	jns    801195 <fork+0x112>
			panic("error");
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	68 e0 25 80 00       	push   $0x8025e0
  801189:	6a 4b                	push   $0x4b
  80118b:	68 1c 29 80 00       	push   $0x80291c
  801190:	e8 7d f1 ff ff       	call   800312 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	68 05 08 00 00       	push   $0x805
  80119d:	56                   	push   %esi
  80119e:	6a 00                	push   $0x0
  8011a0:	56                   	push   %esi
  8011a1:	6a 00                	push   $0x0
  8011a3:	e8 14 fc ff ff       	call   800dbc <sys_page_map>
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 28                	jns    8011d7 <fork+0x154>
			panic("error");
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	68 e0 25 80 00       	push   $0x8025e0
  8011b7:	6a 4d                	push   $0x4d
  8011b9:	68 1c 29 80 00       	push   $0x80291c
  8011be:	e8 4f f1 ff ff       	call   800312 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	6a 05                	push   $0x5
  8011c8:	56                   	push   %esi
  8011c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cc:	56                   	push   %esi
  8011cd:	6a 00                	push   $0x0
  8011cf:	e8 e8 fb ff ff       	call   800dbc <sys_page_map>
  8011d4:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8011d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011dd:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8011e3:	0f 85 fc fe ff ff    	jne    8010e5 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	6a 07                	push   $0x7
  8011ee:	68 00 f0 7f ee       	push   $0xee7ff000
  8011f3:	57                   	push   %edi
  8011f4:	e8 80 fb ff ff       	call   800d79 <sys_page_alloc>
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	79 14                	jns    801214 <fork+0x191>
		panic("1");
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	68 70 29 80 00       	push   $0x802970
  801208:	6a 78                	push   $0x78
  80120a:	68 1c 29 80 00       	push   $0x80291c
  80120f:	e8 fe f0 ff ff       	call   800312 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	68 1a 20 80 00       	push   $0x80201a
  80121c:	57                   	push   %edi
  80121d:	e8 a2 fc ff ff       	call   800ec4 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801222:	83 c4 08             	add    $0x8,%esp
  801225:	6a 02                	push   $0x2
  801227:	57                   	push   %edi
  801228:	e8 13 fc ff ff       	call   800e40 <sys_env_set_status>
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	79 14                	jns    801248 <fork+0x1c5>
		panic("sys_env_set_status");
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	68 72 29 80 00       	push   $0x802972
  80123c:	6a 7d                	push   $0x7d
  80123e:	68 1c 29 80 00       	push   $0x80291c
  801243:	e8 ca f0 ff ff       	call   800312 <_panic>

	return envid;
  801248:	89 f8                	mov    %edi,%eax
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sfork>:

// Challenge!
int
sfork(void)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801258:	68 85 29 80 00       	push   $0x802985
  80125d:	68 86 00 00 00       	push   $0x86
  801262:	68 1c 29 80 00       	push   $0x80291c
  801267:	e8 a6 f0 ff ff       	call   800312 <_panic>

0080126c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	05 00 00 00 30       	add    $0x30000000,%eax
  801277:	c1 e8 0c             	shr    $0xc,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801287:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801299:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	c1 ea 16             	shr    $0x16,%edx
  8012a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012aa:	f6 c2 01             	test   $0x1,%dl
  8012ad:	74 11                	je     8012c0 <fd_alloc+0x2d>
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	c1 ea 0c             	shr    $0xc,%edx
  8012b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	75 09                	jne    8012c9 <fd_alloc+0x36>
			*fd_store = fd;
  8012c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 17                	jmp    8012e0 <fd_alloc+0x4d>
  8012c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d3:	75 c9                	jne    80129e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e8:	83 f8 1f             	cmp    $0x1f,%eax
  8012eb:	77 36                	ja     801323 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ed:	c1 e0 0c             	shl    $0xc,%eax
  8012f0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	c1 ea 16             	shr    $0x16,%edx
  8012fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801301:	f6 c2 01             	test   $0x1,%dl
  801304:	74 24                	je     80132a <fd_lookup+0x48>
  801306:	89 c2                	mov    %eax,%edx
  801308:	c1 ea 0c             	shr    $0xc,%edx
  80130b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801312:	f6 c2 01             	test   $0x1,%dl
  801315:	74 1a                	je     801331 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	89 02                	mov    %eax,(%edx)
	return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	eb 13                	jmp    801336 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 0c                	jmp    801336 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132f:	eb 05                	jmp    801336 <fd_lookup+0x54>
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801341:	ba 18 2a 80 00       	mov    $0x802a18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801346:	eb 13                	jmp    80135b <dev_lookup+0x23>
  801348:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80134b:	39 08                	cmp    %ecx,(%eax)
  80134d:	75 0c                	jne    80135b <dev_lookup+0x23>
			*dev = devtab[i];
  80134f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801352:	89 01                	mov    %eax,(%ecx)
			return 0;
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
  801359:	eb 2e                	jmp    801389 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135b:	8b 02                	mov    (%edx),%eax
  80135d:	85 c0                	test   %eax,%eax
  80135f:	75 e7                	jne    801348 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801361:	a1 04 40 80 00       	mov    0x804004,%eax
  801366:	8b 40 48             	mov    0x48(%eax),%eax
  801369:	83 ec 04             	sub    $0x4,%esp
  80136c:	51                   	push   %ecx
  80136d:	50                   	push   %eax
  80136e:	68 9c 29 80 00       	push   $0x80299c
  801373:	e8 73 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 10             	sub    $0x10,%esp
  801393:	8b 75 08             	mov    0x8(%ebp),%esi
  801396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801399:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80139d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a3:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a6:	50                   	push   %eax
  8013a7:	e8 36 ff ff ff       	call   8012e2 <fd_lookup>
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 05                	js     8013b8 <fd_close+0x2d>
	    || fd != fd2)
  8013b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b6:	74 0b                	je     8013c3 <fd_close+0x38>
		return (must_exist ? r : 0);
  8013b8:	80 fb 01             	cmp    $0x1,%bl
  8013bb:	19 d2                	sbb    %edx,%edx
  8013bd:	f7 d2                	not    %edx
  8013bf:	21 d0                	and    %edx,%eax
  8013c1:	eb 41                	jmp    801404 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	ff 36                	pushl  (%esi)
  8013cc:	e8 67 ff ff ff       	call   801338 <dev_lookup>
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 1a                	js     8013f4 <fd_close+0x69>
		if (dev->dev_close)
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	74 0b                	je     8013f4 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8013e9:	83 ec 0c             	sub    $0xc,%esp
  8013ec:	56                   	push   %esi
  8013ed:	ff d0                	call   *%eax
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	56                   	push   %esi
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 ff f9 ff ff       	call   800dfe <sys_page_unmap>
	return r;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 d8                	mov    %ebx,%eax
}
  801404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801411:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 75 08             	pushl  0x8(%ebp)
  801418:	e8 c5 fe ff ff       	call   8012e2 <fd_lookup>
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	85 d2                	test   %edx,%edx
  801424:	78 10                	js     801436 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	6a 01                	push   $0x1
  80142b:	ff 75 f4             	pushl  -0xc(%ebp)
  80142e:	e8 58 ff ff ff       	call   80138b <fd_close>
  801433:	83 c4 10             	add    $0x10,%esp
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <close_all>:

void
close_all(void)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	53                   	push   %ebx
  801448:	e8 be ff ff ff       	call   80140b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144d:	83 c3 01             	add    $0x1,%ebx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	83 fb 20             	cmp    $0x20,%ebx
  801456:	75 ec                	jne    801444 <close_all+0xc>
		close(i);
}
  801458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	57                   	push   %edi
  801461:	56                   	push   %esi
  801462:	53                   	push   %ebx
  801463:	83 ec 2c             	sub    $0x2c,%esp
  801466:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801469:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	e8 6d fe ff ff       	call   8012e2 <fd_lookup>
  801475:	89 c2                	mov    %eax,%edx
  801477:	83 c4 08             	add    $0x8,%esp
  80147a:	85 d2                	test   %edx,%edx
  80147c:	0f 88 c1 00 00 00    	js     801543 <dup+0xe6>
		return r;
	close(newfdnum);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	56                   	push   %esi
  801486:	e8 80 ff ff ff       	call   80140b <close>

	newfd = INDEX2FD(newfdnum);
  80148b:	89 f3                	mov    %esi,%ebx
  80148d:	c1 e3 0c             	shl    $0xc,%ebx
  801490:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801496:	83 c4 04             	add    $0x4,%esp
  801499:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149c:	e8 db fd ff ff       	call   80127c <fd2data>
  8014a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a3:	89 1c 24             	mov    %ebx,(%esp)
  8014a6:	e8 d1 fd ff ff       	call   80127c <fd2data>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b1:	89 f8                	mov    %edi,%eax
  8014b3:	c1 e8 16             	shr    $0x16,%eax
  8014b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bd:	a8 01                	test   $0x1,%al
  8014bf:	74 37                	je     8014f8 <dup+0x9b>
  8014c1:	89 f8                	mov    %edi,%eax
  8014c3:	c1 e8 0c             	shr    $0xc,%eax
  8014c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 26                	je     8014f8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e1:	50                   	push   %eax
  8014e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e5:	6a 00                	push   $0x0
  8014e7:	57                   	push   %edi
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 cd f8 ff ff       	call   800dbc <sys_page_map>
  8014ef:	89 c7                	mov    %eax,%edi
  8014f1:	83 c4 20             	add    $0x20,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 2e                	js     801526 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	c1 e8 0c             	shr    $0xc,%eax
  801500:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	25 07 0e 00 00       	and    $0xe07,%eax
  80150f:	50                   	push   %eax
  801510:	53                   	push   %ebx
  801511:	6a 00                	push   $0x0
  801513:	52                   	push   %edx
  801514:	6a 00                	push   $0x0
  801516:	e8 a1 f8 ff ff       	call   800dbc <sys_page_map>
  80151b:	89 c7                	mov    %eax,%edi
  80151d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801520:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801522:	85 ff                	test   %edi,%edi
  801524:	79 1d                	jns    801543 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	53                   	push   %ebx
  80152a:	6a 00                	push   $0x0
  80152c:	e8 cd f8 ff ff       	call   800dfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	ff 75 d4             	pushl  -0x2c(%ebp)
  801537:	6a 00                	push   $0x0
  801539:	e8 c0 f8 ff ff       	call   800dfe <sys_page_unmap>
	return r;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	89 f8                	mov    %edi,%eax
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 14             	sub    $0x14,%esp
  801552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	53                   	push   %ebx
  80155a:	e8 83 fd ff ff       	call   8012e2 <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	89 c2                	mov    %eax,%edx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 6d                	js     8015d5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	ff 30                	pushl  (%eax)
  801574:	e8 bf fd ff ff       	call   801338 <dev_lookup>
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 4c                	js     8015cc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801580:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801583:	8b 42 08             	mov    0x8(%edx),%eax
  801586:	83 e0 03             	and    $0x3,%eax
  801589:	83 f8 01             	cmp    $0x1,%eax
  80158c:	75 21                	jne    8015af <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158e:	a1 04 40 80 00       	mov    0x804004,%eax
  801593:	8b 40 48             	mov    0x48(%eax),%eax
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	53                   	push   %ebx
  80159a:	50                   	push   %eax
  80159b:	68 dd 29 80 00       	push   $0x8029dd
  8015a0:	e8 46 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ad:	eb 26                	jmp    8015d5 <read+0x8a>
	}
	if (!dev->dev_read)
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	8b 40 08             	mov    0x8(%eax),%eax
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	74 17                	je     8015d0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	ff 75 10             	pushl  0x10(%ebp)
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	52                   	push   %edx
  8015c3:	ff d0                	call   *%eax
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f0:	eb 21                	jmp    801613 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	89 f0                	mov    %esi,%eax
  8015f7:	29 d8                	sub    %ebx,%eax
  8015f9:	50                   	push   %eax
  8015fa:	89 d8                	mov    %ebx,%eax
  8015fc:	03 45 0c             	add    0xc(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	57                   	push   %edi
  801601:	e8 45 ff ff ff       	call   80154b <read>
		if (m < 0)
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 0c                	js     801619 <readn+0x3d>
			return m;
		if (m == 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	74 06                	je     801617 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801611:	01 c3                	add    %eax,%ebx
  801613:	39 f3                	cmp    %esi,%ebx
  801615:	72 db                	jb     8015f2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801617:	89 d8                	mov    %ebx,%eax
}
  801619:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161c:	5b                   	pop    %ebx
  80161d:	5e                   	pop    %esi
  80161e:	5f                   	pop    %edi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	53                   	push   %ebx
  801625:	83 ec 14             	sub    $0x14,%esp
  801628:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	53                   	push   %ebx
  801630:	e8 ad fc ff ff       	call   8012e2 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	89 c2                	mov    %eax,%edx
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 68                	js     8016a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801648:	ff 30                	pushl  (%eax)
  80164a:	e8 e9 fc ff ff       	call   801338 <dev_lookup>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 47                	js     80169d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165d:	75 21                	jne    801680 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165f:	a1 04 40 80 00       	mov    0x804004,%eax
  801664:	8b 40 48             	mov    0x48(%eax),%eax
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	53                   	push   %ebx
  80166b:	50                   	push   %eax
  80166c:	68 f9 29 80 00       	push   $0x8029f9
  801671:	e8 75 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167e:	eb 26                	jmp    8016a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	8b 52 0c             	mov    0xc(%edx),%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	74 17                	je     8016a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168a:	83 ec 04             	sub    $0x4,%esp
  80168d:	ff 75 10             	pushl  0x10(%ebp)
  801690:	ff 75 0c             	pushl  0xc(%ebp)
  801693:	50                   	push   %eax
  801694:	ff d2                	call   *%edx
  801696:	89 c2                	mov    %eax,%edx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	eb 09                	jmp    8016a6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	eb 05                	jmp    8016a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016a6:	89 d0                	mov    %edx,%eax
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	ff 75 08             	pushl  0x8(%ebp)
  8016ba:	e8 23 fc ff ff       	call   8012e2 <fd_lookup>
  8016bf:	83 c4 08             	add    $0x8,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 0e                	js     8016d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 14             	sub    $0x14,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	53                   	push   %ebx
  8016e5:	e8 f8 fb ff ff       	call   8012e2 <fd_lookup>
  8016ea:	83 c4 08             	add    $0x8,%esp
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 65                	js     801758 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	ff 30                	pushl  (%eax)
  8016ff:	e8 34 fc ff ff       	call   801338 <dev_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 44                	js     80174f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801712:	75 21                	jne    801735 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801714:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801719:	8b 40 48             	mov    0x48(%eax),%eax
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	53                   	push   %ebx
  801720:	50                   	push   %eax
  801721:	68 bc 29 80 00       	push   $0x8029bc
  801726:	e8 c0 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801733:	eb 23                	jmp    801758 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801735:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801738:	8b 52 18             	mov    0x18(%edx),%edx
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 14                	je     801753 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	ff 75 0c             	pushl  0xc(%ebp)
  801745:	50                   	push   %eax
  801746:	ff d2                	call   *%edx
  801748:	89 c2                	mov    %eax,%edx
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	eb 09                	jmp    801758 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174f:	89 c2                	mov    %eax,%edx
  801751:	eb 05                	jmp    801758 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801753:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801758:	89 d0                	mov    %edx,%eax
  80175a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 14             	sub    $0x14,%esp
  801766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801769:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	ff 75 08             	pushl  0x8(%ebp)
  801770:	e8 6d fb ff ff       	call   8012e2 <fd_lookup>
  801775:	83 c4 08             	add    $0x8,%esp
  801778:	89 c2                	mov    %eax,%edx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 58                	js     8017d6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177e:	83 ec 08             	sub    $0x8,%esp
  801781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801784:	50                   	push   %eax
  801785:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801788:	ff 30                	pushl  (%eax)
  80178a:	e8 a9 fb ff ff       	call   801338 <dev_lookup>
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 37                	js     8017cd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801799:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179d:	74 32                	je     8017d1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80179f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a9:	00 00 00 
	stat->st_isdir = 0;
  8017ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b3:	00 00 00 
	stat->st_dev = dev;
  8017b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017bc:	83 ec 08             	sub    $0x8,%esp
  8017bf:	53                   	push   %ebx
  8017c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c3:	ff 50 14             	call   *0x14(%eax)
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb 09                	jmp    8017d6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	eb 05                	jmp    8017d6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d6:	89 d0                	mov    %edx,%eax
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	6a 00                	push   $0x0
  8017e7:	ff 75 08             	pushl  0x8(%ebp)
  8017ea:	e8 e7 01 00 00       	call   8019d6 <open>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 db                	test   %ebx,%ebx
  8017f6:	78 1b                	js     801813 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	ff 75 0c             	pushl  0xc(%ebp)
  8017fe:	53                   	push   %ebx
  8017ff:	e8 5b ff ff ff       	call   80175f <fstat>
  801804:	89 c6                	mov    %eax,%esi
	close(fd);
  801806:	89 1c 24             	mov    %ebx,(%esp)
  801809:	e8 fd fb ff ff       	call   80140b <close>
	return r;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	89 f0                	mov    %esi,%eax
}
  801813:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	89 c6                	mov    %eax,%esi
  801821:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801823:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182a:	75 12                	jne    80183e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	6a 03                	push   $0x3
  801831:	e8 c3 08 00 00       	call   8020f9 <ipc_find_env>
  801836:	a3 00 40 80 00       	mov    %eax,0x804000
  80183b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80183e:	6a 07                	push   $0x7
  801840:	68 00 50 80 00       	push   $0x805000
  801845:	56                   	push   %esi
  801846:	ff 35 00 40 80 00    	pushl  0x804000
  80184c:	e8 57 08 00 00       	call   8020a8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801851:	83 c4 0c             	add    $0xc,%esp
  801854:	6a 00                	push   $0x0
  801856:	53                   	push   %ebx
  801857:	6a 00                	push   $0x0
  801859:	e8 e4 07 00 00       	call   802042 <ipc_recv>
}
  80185e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801861:	5b                   	pop    %ebx
  801862:	5e                   	pop    %esi
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 40 0c             	mov    0xc(%eax),%eax
  801871:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801876:	8b 45 0c             	mov    0xc(%ebp),%eax
  801879:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 02 00 00 00       	mov    $0x2,%eax
  801888:	e8 8d ff ff ff       	call   80181a <fsipc>
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801895:	8b 45 08             	mov    0x8(%ebp),%eax
  801898:	8b 40 0c             	mov    0xc(%eax),%eax
  80189b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018aa:	e8 6b ff ff ff       	call   80181a <fsipc>
}
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d0:	e8 45 ff ff ff       	call   80181a <fsipc>
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	85 d2                	test   %edx,%edx
  8018d9:	78 2c                	js     801907 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	68 00 50 80 00       	push   $0x805000
  8018e3:	53                   	push   %ebx
  8018e4:	e8 86 f0 ff ff       	call   80096f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801915:	8b 55 08             	mov    0x8(%ebp),%edx
  801918:	8b 52 0c             	mov    0xc(%edx),%edx
  80191b:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801921:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801926:	76 05                	jbe    80192d <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801928:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  80192d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801932:	83 ec 04             	sub    $0x4,%esp
  801935:	50                   	push   %eax
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	68 08 50 80 00       	push   $0x805008
  80193e:	e8 be f1 ff ff       	call   800b01 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801943:	ba 00 00 00 00       	mov    $0x0,%edx
  801948:	b8 04 00 00 00       	mov    $0x4,%eax
  80194d:	e8 c8 fe ff ff       	call   80181a <fsipc>
	return write;
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801967:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 03 00 00 00       	mov    $0x3,%eax
  801977:	e8 9e fe ff ff       	call   80181a <fsipc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 4b                	js     8019cd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801982:	39 c6                	cmp    %eax,%esi
  801984:	73 16                	jae    80199c <devfile_read+0x48>
  801986:	68 28 2a 80 00       	push   $0x802a28
  80198b:	68 2f 2a 80 00       	push   $0x802a2f
  801990:	6a 7c                	push   $0x7c
  801992:	68 44 2a 80 00       	push   $0x802a44
  801997:	e8 76 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  80199c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a1:	7e 16                	jle    8019b9 <devfile_read+0x65>
  8019a3:	68 4f 2a 80 00       	push   $0x802a4f
  8019a8:	68 2f 2a 80 00       	push   $0x802a2f
  8019ad:	6a 7d                	push   $0x7d
  8019af:	68 44 2a 80 00       	push   $0x802a44
  8019b4:	e8 59 e9 ff ff       	call   800312 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019b9:	83 ec 04             	sub    $0x4,%esp
  8019bc:	50                   	push   %eax
  8019bd:	68 00 50 80 00       	push   $0x805000
  8019c2:	ff 75 0c             	pushl  0xc(%ebp)
  8019c5:	e8 37 f1 ff ff       	call   800b01 <memmove>
	return r;
  8019ca:	83 c4 10             	add    $0x10,%esp
}
  8019cd:	89 d8                	mov    %ebx,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 20             	sub    $0x20,%esp
  8019dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e0:	53                   	push   %ebx
  8019e1:	e8 50 ef ff ff       	call   800936 <strlen>
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ee:	7f 67                	jg     801a57 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	50                   	push   %eax
  8019f7:	e8 97 f8 ff ff       	call   801293 <fd_alloc>
  8019fc:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ff:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 57                	js     801a5c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	53                   	push   %ebx
  801a09:	68 00 50 80 00       	push   $0x805000
  801a0e:	e8 5c ef ff ff       	call   80096f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a23:	e8 f2 fd ff ff       	call   80181a <fsipc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	79 14                	jns    801a45 <open+0x6f>
		fd_close(fd, 0);
  801a31:	83 ec 08             	sub    $0x8,%esp
  801a34:	6a 00                	push   $0x0
  801a36:	ff 75 f4             	pushl  -0xc(%ebp)
  801a39:	e8 4d f9 ff ff       	call   80138b <fd_close>
		return r;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	89 da                	mov    %ebx,%edx
  801a43:	eb 17                	jmp    801a5c <open+0x86>
	}

	return fd2num(fd);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4b:	e8 1c f8 ff ff       	call   80126c <fd2num>
  801a50:	89 c2                	mov    %eax,%edx
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	eb 05                	jmp    801a5c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a57:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a5c:	89 d0                	mov    %edx,%eax
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a73:	e8 a2 fd ff ff       	call   80181a <fsipc>
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 08             	pushl  0x8(%ebp)
  801a88:	e8 ef f7 ff ff       	call   80127c <fd2data>
  801a8d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a8f:	83 c4 08             	add    $0x8,%esp
  801a92:	68 5b 2a 80 00       	push   $0x802a5b
  801a97:	53                   	push   %ebx
  801a98:	e8 d2 ee ff ff       	call   80096f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a9d:	8b 56 04             	mov    0x4(%esi),%edx
  801aa0:	89 d0                	mov    %edx,%eax
  801aa2:	2b 06                	sub    (%esi),%eax
  801aa4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aaa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab1:	00 00 00 
	stat->st_dev = &devpipe;
  801ab4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801abb:	30 80 00 
	return 0;
}
  801abe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ad4:	53                   	push   %ebx
  801ad5:	6a 00                	push   $0x0
  801ad7:	e8 22 f3 ff ff       	call   800dfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801adc:	89 1c 24             	mov    %ebx,(%esp)
  801adf:	e8 98 f7 ff ff       	call   80127c <fd2data>
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	50                   	push   %eax
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 0f f3 ff ff       	call   800dfe <sys_page_unmap>
}
  801aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	83 ec 1c             	sub    $0x1c,%esp
  801afd:	89 c7                	mov    %eax,%edi
  801aff:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b01:	a1 04 40 80 00       	mov    0x804004,%eax
  801b06:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b09:	83 ec 0c             	sub    $0xc,%esp
  801b0c:	57                   	push   %edi
  801b0d:	e8 1f 06 00 00       	call   802131 <pageref>
  801b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b15:	89 34 24             	mov    %esi,(%esp)
  801b18:	e8 14 06 00 00       	call   802131 <pageref>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b23:	0f 94 c0             	sete   %al
  801b26:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b29:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b2f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b32:	39 cb                	cmp    %ecx,%ebx
  801b34:	74 15                	je     801b4b <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801b36:	8b 52 58             	mov    0x58(%edx),%edx
  801b39:	50                   	push   %eax
  801b3a:	52                   	push   %edx
  801b3b:	53                   	push   %ebx
  801b3c:	68 68 2a 80 00       	push   $0x802a68
  801b41:	e8 a5 e8 ff ff       	call   8003eb <cprintf>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	eb b6                	jmp    801b01 <_pipeisclosed+0xd>
	}
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	57                   	push   %edi
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 28             	sub    $0x28,%esp
  801b5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b5f:	56                   	push   %esi
  801b60:	e8 17 f7 ff ff       	call   80127c <fd2data>
  801b65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b6f:	eb 4b                	jmp    801bbc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b71:	89 da                	mov    %ebx,%edx
  801b73:	89 f0                	mov    %esi,%eax
  801b75:	e8 7a ff ff ff       	call   801af4 <_pipeisclosed>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 48                	jne    801bc6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b7e:	e8 d7 f1 ff ff       	call   800d5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b83:	8b 43 04             	mov    0x4(%ebx),%eax
  801b86:	8b 0b                	mov    (%ebx),%ecx
  801b88:	8d 51 20             	lea    0x20(%ecx),%edx
  801b8b:	39 d0                	cmp    %edx,%eax
  801b8d:	73 e2                	jae    801b71 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b92:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b96:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	c1 fa 1f             	sar    $0x1f,%edx
  801b9e:	89 d1                	mov    %edx,%ecx
  801ba0:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba6:	83 e2 1f             	and    $0x1f,%edx
  801ba9:	29 ca                	sub    %ecx,%edx
  801bab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801baf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb3:	83 c0 01             	add    $0x1,%eax
  801bb6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb9:	83 c7 01             	add    $0x1,%edi
  801bbc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bbf:	75 c2                	jne    801b83 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc4:	eb 05                	jmp    801bcb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 18             	sub    $0x18,%esp
  801bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bdf:	57                   	push   %edi
  801be0:	e8 97 f6 ff ff       	call   80127c <fd2data>
  801be5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bef:	eb 3d                	jmp    801c2e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf1:	85 db                	test   %ebx,%ebx
  801bf3:	74 04                	je     801bf9 <devpipe_read+0x26>
				return i;
  801bf5:	89 d8                	mov    %ebx,%eax
  801bf7:	eb 44                	jmp    801c3d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf9:	89 f2                	mov    %esi,%edx
  801bfb:	89 f8                	mov    %edi,%eax
  801bfd:	e8 f2 fe ff ff       	call   801af4 <_pipeisclosed>
  801c02:	85 c0                	test   %eax,%eax
  801c04:	75 32                	jne    801c38 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c06:	e8 4f f1 ff ff       	call   800d5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0b:	8b 06                	mov    (%esi),%eax
  801c0d:	3b 46 04             	cmp    0x4(%esi),%eax
  801c10:	74 df                	je     801bf1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c12:	99                   	cltd   
  801c13:	c1 ea 1b             	shr    $0x1b,%edx
  801c16:	01 d0                	add    %edx,%eax
  801c18:	83 e0 1f             	and    $0x1f,%eax
  801c1b:	29 d0                	sub    %edx,%eax
  801c1d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c25:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c28:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2b:	83 c3 01             	add    $0x1,%ebx
  801c2e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c31:	75 d8                	jne    801c0b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c33:	8b 45 10             	mov    0x10(%ebp),%eax
  801c36:	eb 05                	jmp    801c3d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 3d f6 ff ff       	call   801293 <fd_alloc>
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 2c 01 00 00    	js     801d8f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c63:	83 ec 04             	sub    $0x4,%esp
  801c66:	68 07 04 00 00       	push   $0x407
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 04 f1 ff ff       	call   800d79 <sys_page_alloc>
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	89 c2                	mov    %eax,%edx
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	0f 88 0d 01 00 00    	js     801d8f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c88:	50                   	push   %eax
  801c89:	e8 05 f6 ff ff       	call   801293 <fd_alloc>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	0f 88 e2 00 00 00    	js     801d7d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 cc f0 ff ff       	call   800d79 <sys_page_alloc>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	0f 88 c3 00 00 00    	js     801d7d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc0:	e8 b7 f5 ff ff       	call   80127c <fd2data>
  801cc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc7:	83 c4 0c             	add    $0xc,%esp
  801cca:	68 07 04 00 00       	push   $0x407
  801ccf:	50                   	push   %eax
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 a2 f0 ff ff       	call   800d79 <sys_page_alloc>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	0f 88 89 00 00 00    	js     801d6d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cea:	e8 8d f5 ff ff       	call   80127c <fd2data>
  801cef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf6:	50                   	push   %eax
  801cf7:	6a 00                	push   $0x0
  801cf9:	56                   	push   %esi
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 bb f0 ff ff       	call   800dbc <sys_page_map>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	83 c4 20             	add    $0x20,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 55                	js     801d5f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3a:	e8 2d f5 ff ff       	call   80126c <fd2num>
  801d3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d44:	83 c4 04             	add    $0x4,%esp
  801d47:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4a:	e8 1d f5 ff ff       	call   80126c <fd2num>
  801d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d52:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5d:	eb 30                	jmp    801d8f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	56                   	push   %esi
  801d63:	6a 00                	push   $0x0
  801d65:	e8 94 f0 ff ff       	call   800dfe <sys_page_unmap>
  801d6a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	ff 75 f0             	pushl  -0x10(%ebp)
  801d73:	6a 00                	push   $0x0
  801d75:	e8 84 f0 ff ff       	call   800dfe <sys_page_unmap>
  801d7a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	ff 75 f4             	pushl  -0xc(%ebp)
  801d83:	6a 00                	push   $0x0
  801d85:	e8 74 f0 ff ff       	call   800dfe <sys_page_unmap>
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d8f:	89 d0                	mov    %edx,%eax
  801d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	ff 75 08             	pushl  0x8(%ebp)
  801da5:	e8 38 f5 ff ff       	call   8012e2 <fd_lookup>
  801daa:	89 c2                	mov    %eax,%edx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 d2                	test   %edx,%edx
  801db1:	78 18                	js     801dcb <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f4             	pushl  -0xc(%ebp)
  801db9:	e8 be f4 ff ff       	call   80127c <fd2data>
	return _pipeisclosed(fd, p);
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	e8 2c fd ff ff       	call   801af4 <_pipeisclosed>
  801dc8:	83 c4 10             	add    $0x10,%esp
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801dd9:	85 f6                	test   %esi,%esi
  801ddb:	75 16                	jne    801df3 <wait+0x26>
  801ddd:	68 99 2a 80 00       	push   $0x802a99
  801de2:	68 2f 2a 80 00       	push   $0x802a2f
  801de7:	6a 09                	push   $0x9
  801de9:	68 a4 2a 80 00       	push   $0x802aa4
  801dee:	e8 1f e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801df3:	89 f3                	mov    %esi,%ebx
  801df5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dfb:	6b db 78             	imul   $0x78,%ebx,%ebx
  801dfe:	8d 7b 40             	lea    0x40(%ebx),%edi
  801e01:	83 c3 50             	add    $0x50,%ebx
  801e04:	eb 05                	jmp    801e0b <wait+0x3e>
		sys_yield();
  801e06:	e8 4f ef ff ff       	call   800d5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e0b:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  801e11:	39 f0                	cmp    %esi,%eax
  801e13:	75 0a                	jne    801e1f <wait+0x52>
  801e15:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	75 e7                	jne    801e06 <wait+0x39>
		sys_yield();
}
  801e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e22:	5b                   	pop    %ebx
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e37:	68 af 2a 80 00       	push   $0x802aaf
  801e3c:	ff 75 0c             	pushl  0xc(%ebp)
  801e3f:	e8 2b eb ff ff       	call   80096f <strcpy>
	return 0;
}
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	57                   	push   %edi
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e57:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e62:	eb 2e                	jmp    801e92 <devcons_write+0x47>
		m = n - tot;
  801e64:	8b 55 10             	mov    0x10(%ebp),%edx
  801e67:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801e69:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801e6e:	83 fa 7f             	cmp    $0x7f,%edx
  801e71:	77 02                	ja     801e75 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e73:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e75:	83 ec 04             	sub    $0x4,%esp
  801e78:	56                   	push   %esi
  801e79:	03 45 0c             	add    0xc(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	57                   	push   %edi
  801e7e:	e8 7e ec ff ff       	call   800b01 <memmove>
		sys_cputs(buf, m);
  801e83:	83 c4 08             	add    $0x8,%esp
  801e86:	56                   	push   %esi
  801e87:	57                   	push   %edi
  801e88:	e8 30 ee ff ff       	call   800cbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8d:	01 f3                	add    %esi,%ebx
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	89 d8                	mov    %ebx,%eax
  801e94:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e97:	72 cb                	jb     801e64 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801eac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb0:	75 07                	jne    801eb9 <devcons_read+0x18>
  801eb2:	eb 28                	jmp    801edc <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb4:	e8 a1 ee ff ff       	call   800d5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb9:	e8 1d ee ff ff       	call   800cdb <sys_cgetc>
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	74 f2                	je     801eb4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 16                	js     801edc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec6:	83 f8 04             	cmp    $0x4,%eax
  801ec9:	74 0c                	je     801ed7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ece:	88 02                	mov    %al,(%edx)
	return 1;
  801ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed5:	eb 05                	jmp    801edc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eea:	6a 01                	push   $0x1
  801eec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	e8 c8 ed ff ff       	call   800cbd <sys_cputs>
  801ef5:	83 c4 10             	add    $0x10,%esp
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <getchar>:

int
getchar(void)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f00:	6a 01                	push   $0x1
  801f02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	6a 00                	push   $0x0
  801f08:	e8 3e f6 ff ff       	call   80154b <read>
	if (r < 0)
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 0f                	js     801f23 <getchar+0x29>
		return r;
	if (r < 1)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	7e 06                	jle    801f1e <getchar+0x24>
		return -E_EOF;
	return c;
  801f18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1c:	eb 05                	jmp    801f23 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f1e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    

00801f25 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2e:	50                   	push   %eax
  801f2f:	ff 75 08             	pushl  0x8(%ebp)
  801f32:	e8 ab f3 ff ff       	call   8012e2 <fd_lookup>
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 11                	js     801f4f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f47:	39 10                	cmp    %edx,(%eax)
  801f49:	0f 94 c0             	sete   %al
  801f4c:	0f b6 c0             	movzbl %al,%eax
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <opencons>:

int
opencons(void)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5a:	50                   	push   %eax
  801f5b:	e8 33 f3 ff ff       	call   801293 <fd_alloc>
  801f60:	83 c4 10             	add    $0x10,%esp
		return r;
  801f63:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 3e                	js     801fa7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f69:	83 ec 04             	sub    $0x4,%esp
  801f6c:	68 07 04 00 00       	push   $0x407
  801f71:	ff 75 f4             	pushl  -0xc(%ebp)
  801f74:	6a 00                	push   $0x0
  801f76:	e8 fe ed ff ff       	call   800d79 <sys_page_alloc>
  801f7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 23                	js     801fa7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f84:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	50                   	push   %eax
  801f9d:	e8 ca f2 ff ff       	call   80126c <fd2num>
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	83 c4 10             	add    $0x10,%esp
}
  801fa7:	89 d0                	mov    %edx,%eax
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fb1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb8:	75 2c                	jne    801fe6 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801fba:	83 ec 04             	sub    $0x4,%esp
  801fbd:	6a 07                	push   $0x7
  801fbf:	68 00 f0 7f ee       	push   $0xee7ff000
  801fc4:	6a 00                	push   $0x0
  801fc6:	e8 ae ed ff ff       	call   800d79 <sys_page_alloc>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	79 14                	jns    801fe6 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	68 bc 2a 80 00       	push   $0x802abc
  801fda:	6a 1f                	push   $0x1f
  801fdc:	68 20 2b 80 00       	push   $0x802b20
  801fe1:	e8 2c e3 ff ff       	call   800312 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	68 1a 20 80 00       	push   $0x80201a
  801ff6:	6a 00                	push   $0x0
  801ff8:	e8 c7 ee ff ff       	call   800ec4 <sys_env_set_pgfault_upcall>
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	79 14                	jns    802018 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802004:	83 ec 04             	sub    $0x4,%esp
  802007:	68 e8 2a 80 00       	push   $0x802ae8
  80200c:	6a 25                	push   $0x25
  80200e:	68 20 2b 80 00       	push   $0x802b20
  802013:	e8 fa e2 ff ff       	call   800312 <_panic>
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80201a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80201b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802020:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802022:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  802025:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  802027:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  80202b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  80202f:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  802030:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  802033:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  802035:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  802038:	83 c4 04             	add    $0x4,%esp
	popal 
  80203b:	61                   	popa   
	addl $4, %esp 
  80203c:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  80203f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  802040:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  802041:	c3                   	ret    

00802042 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	8b 75 08             	mov    0x8(%ebp),%esi
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  802050:	85 f6                	test   %esi,%esi
  802052:	74 06                	je     80205a <ipc_recv+0x18>
  802054:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80205a:	85 db                	test   %ebx,%ebx
  80205c:	74 06                	je     802064 <ipc_recv+0x22>
  80205e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802064:	83 f8 01             	cmp    $0x1,%eax
  802067:	19 d2                	sbb    %edx,%edx
  802069:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  80206b:	83 ec 0c             	sub    $0xc,%esp
  80206e:	50                   	push   %eax
  80206f:	e8 b5 ee ff ff       	call   800f29 <sys_ipc_recv>
  802074:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 d2                	test   %edx,%edx
  80207b:	75 24                	jne    8020a1 <ipc_recv+0x5f>
	if (from_env_store)
  80207d:	85 f6                	test   %esi,%esi
  80207f:	74 0a                	je     80208b <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  802081:	a1 04 40 80 00       	mov    0x804004,%eax
  802086:	8b 40 70             	mov    0x70(%eax),%eax
  802089:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80208b:	85 db                	test   %ebx,%ebx
  80208d:	74 0a                	je     802099 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  80208f:	a1 04 40 80 00       	mov    0x804004,%eax
  802094:	8b 40 74             	mov    0x74(%eax),%eax
  802097:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802099:	a1 04 40 80 00       	mov    0x804004,%eax
  80209e:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  8020a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	57                   	push   %edi
  8020ac:	56                   	push   %esi
  8020ad:	53                   	push   %ebx
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  8020ba:	83 fb 01             	cmp    $0x1,%ebx
  8020bd:	19 c0                	sbb    %eax,%eax
  8020bf:	09 c3                	or     %eax,%ebx
  8020c1:	eb 1c                	jmp    8020df <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  8020c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c6:	74 12                	je     8020da <ipc_send+0x32>
  8020c8:	50                   	push   %eax
  8020c9:	68 2e 2b 80 00       	push   $0x802b2e
  8020ce:	6a 36                	push   $0x36
  8020d0:	68 45 2b 80 00       	push   $0x802b45
  8020d5:	e8 38 e2 ff ff       	call   800312 <_panic>
		sys_yield();
  8020da:	e8 7b ec ff ff       	call   800d5a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8020df:	ff 75 14             	pushl  0x14(%ebp)
  8020e2:	53                   	push   %ebx
  8020e3:	56                   	push   %esi
  8020e4:	57                   	push   %edi
  8020e5:	e8 1c ee ff ff       	call   800f06 <sys_ipc_try_send>
		if (ret == 0) break;
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	75 d2                	jne    8020c3 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  8020f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    

008020f9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802104:	6b d0 78             	imul   $0x78,%eax,%edx
  802107:	83 c2 50             	add    $0x50,%edx
  80210a:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802110:	39 ca                	cmp    %ecx,%edx
  802112:	75 0d                	jne    802121 <ipc_find_env+0x28>
			return envs[i].env_id;
  802114:	6b c0 78             	imul   $0x78,%eax,%eax
  802117:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80211c:	8b 40 08             	mov    0x8(%eax),%eax
  80211f:	eb 0e                	jmp    80212f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802121:	83 c0 01             	add    $0x1,%eax
  802124:	3d 00 04 00 00       	cmp    $0x400,%eax
  802129:	75 d9                	jne    802104 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80212b:	66 b8 00 00          	mov    $0x0,%ax
}
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    

00802131 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802137:	89 d0                	mov    %edx,%eax
  802139:	c1 e8 16             	shr    $0x16,%eax
  80213c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802148:	f6 c1 01             	test   $0x1,%cl
  80214b:	74 1d                	je     80216a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214d:	c1 ea 0c             	shr    $0xc,%edx
  802150:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802157:	f6 c2 01             	test   $0x1,%dl
  80215a:	74 0e                	je     80216a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215c:	c1 ea 0c             	shr    $0xc,%edx
  80215f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802166:	ef 
  802167:	0f b7 c0             	movzwl %ax,%eax
}
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	83 ec 10             	sub    $0x10,%esp
  802176:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80217a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80217e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802182:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802186:	85 d2                	test   %edx,%edx
  802188:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80218c:	89 34 24             	mov    %esi,(%esp)
  80218f:	89 c8                	mov    %ecx,%eax
  802191:	75 35                	jne    8021c8 <__udivdi3+0x58>
  802193:	39 f1                	cmp    %esi,%ecx
  802195:	0f 87 bd 00 00 00    	ja     802258 <__udivdi3+0xe8>
  80219b:	85 c9                	test   %ecx,%ecx
  80219d:	89 cd                	mov    %ecx,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f1                	div    %ecx
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 f0                	mov    %esi,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c6                	mov    %eax,%esi
  8021b4:	89 f8                	mov    %edi,%eax
  8021b6:	f7 f5                	div    %ebp
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	83 c4 10             	add    $0x10,%esp
  8021bd:	5e                   	pop    %esi
  8021be:	5f                   	pop    %edi
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    
  8021c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	3b 14 24             	cmp    (%esp),%edx
  8021cb:	77 7b                	ja     802248 <__udivdi3+0xd8>
  8021cd:	0f bd f2             	bsr    %edx,%esi
  8021d0:	83 f6 1f             	xor    $0x1f,%esi
  8021d3:	0f 84 97 00 00 00    	je     802270 <__udivdi3+0x100>
  8021d9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8021de:	89 d7                	mov    %edx,%edi
  8021e0:	89 f1                	mov    %esi,%ecx
  8021e2:	29 f5                	sub    %esi,%ebp
  8021e4:	d3 e7                	shl    %cl,%edi
  8021e6:	89 c2                	mov    %eax,%edx
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	d3 ea                	shr    %cl,%edx
  8021ec:	89 f1                	mov    %esi,%ecx
  8021ee:	09 fa                	or     %edi,%edx
  8021f0:	8b 3c 24             	mov    (%esp),%edi
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802203:	89 fa                	mov    %edi,%edx
  802205:	d3 ea                	shr    %cl,%edx
  802207:	89 f1                	mov    %esi,%ecx
  802209:	d3 e7                	shl    %cl,%edi
  80220b:	89 e9                	mov    %ebp,%ecx
  80220d:	d3 e8                	shr    %cl,%eax
  80220f:	09 c7                	or     %eax,%edi
  802211:	89 f8                	mov    %edi,%eax
  802213:	f7 74 24 08          	divl   0x8(%esp)
  802217:	89 d5                	mov    %edx,%ebp
  802219:	89 c7                	mov    %eax,%edi
  80221b:	f7 64 24 0c          	mull   0xc(%esp)
  80221f:	39 d5                	cmp    %edx,%ebp
  802221:	89 14 24             	mov    %edx,(%esp)
  802224:	72 11                	jb     802237 <__udivdi3+0xc7>
  802226:	8b 54 24 04          	mov    0x4(%esp),%edx
  80222a:	89 f1                	mov    %esi,%ecx
  80222c:	d3 e2                	shl    %cl,%edx
  80222e:	39 c2                	cmp    %eax,%edx
  802230:	73 5e                	jae    802290 <__udivdi3+0x120>
  802232:	3b 2c 24             	cmp    (%esp),%ebp
  802235:	75 59                	jne    802290 <__udivdi3+0x120>
  802237:	8d 47 ff             	lea    -0x1(%edi),%eax
  80223a:	31 f6                	xor    %esi,%esi
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	31 f6                	xor    %esi,%esi
  80224a:	31 c0                	xor    %eax,%eax
  80224c:	89 f2                	mov    %esi,%edx
  80224e:	83 c4 10             	add    $0x10,%esp
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	89 f2                	mov    %esi,%edx
  80225a:	31 f6                	xor    %esi,%esi
  80225c:	89 f8                	mov    %edi,%eax
  80225e:	f7 f1                	div    %ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802274:	76 0b                	jbe    802281 <__udivdi3+0x111>
  802276:	31 c0                	xor    %eax,%eax
  802278:	3b 14 24             	cmp    (%esp),%edx
  80227b:	0f 83 37 ff ff ff    	jae    8021b8 <__udivdi3+0x48>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	e9 2d ff ff ff       	jmp    8021b8 <__udivdi3+0x48>
  80228b:	90                   	nop
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 f8                	mov    %edi,%eax
  802292:	31 f6                	xor    %esi,%esi
  802294:	e9 1f ff ff ff       	jmp    8021b8 <__udivdi3+0x48>
  802299:	66 90                	xchg   %ax,%ax
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	83 ec 20             	sub    $0x20,%esp
  8022a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8022aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b2:	89 c6                	mov    %eax,%esi
  8022b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8022c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	89 c2                	mov    %eax,%edx
  8022d0:	75 1e                	jne    8022f0 <__umoddi3+0x50>
  8022d2:	39 f7                	cmp    %esi,%edi
  8022d4:	76 52                	jbe    802328 <__umoddi3+0x88>
  8022d6:	89 c8                	mov    %ecx,%eax
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	f7 f7                	div    %edi
  8022dc:	89 d0                	mov    %edx,%eax
  8022de:	31 d2                	xor    %edx,%edx
  8022e0:	83 c4 20             	add    $0x20,%esp
  8022e3:	5e                   	pop    %esi
  8022e4:	5f                   	pop    %edi
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    
  8022e7:	89 f6                	mov    %esi,%esi
  8022e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022f0:	39 f0                	cmp    %esi,%eax
  8022f2:	77 5c                	ja     802350 <__umoddi3+0xb0>
  8022f4:	0f bd e8             	bsr    %eax,%ebp
  8022f7:	83 f5 1f             	xor    $0x1f,%ebp
  8022fa:	75 64                	jne    802360 <__umoddi3+0xc0>
  8022fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802300:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802304:	0f 86 f6 00 00 00    	jbe    802400 <__umoddi3+0x160>
  80230a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80230e:	0f 82 ec 00 00 00    	jb     802400 <__umoddi3+0x160>
  802314:	8b 44 24 14          	mov    0x14(%esp),%eax
  802318:	8b 54 24 18          	mov    0x18(%esp),%edx
  80231c:	83 c4 20             	add    $0x20,%esp
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
  802323:	90                   	nop
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	85 ff                	test   %edi,%edi
  80232a:	89 fd                	mov    %edi,%ebp
  80232c:	75 0b                	jne    802339 <__umoddi3+0x99>
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f7                	div    %edi
  802337:	89 c5                	mov    %eax,%ebp
  802339:	8b 44 24 10          	mov    0x10(%esp),%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	f7 f5                	div    %ebp
  802341:	89 c8                	mov    %ecx,%eax
  802343:	f7 f5                	div    %ebp
  802345:	eb 95                	jmp    8022dc <__umoddi3+0x3c>
  802347:	89 f6                	mov    %esi,%esi
  802349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 20             	add    $0x20,%esp
  802357:	5e                   	pop    %esi
  802358:	5f                   	pop    %edi
  802359:	5d                   	pop    %ebp
  80235a:	c3                   	ret    
  80235b:	90                   	nop
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	b8 20 00 00 00       	mov    $0x20,%eax
  802365:	89 e9                	mov    %ebp,%ecx
  802367:	29 e8                	sub    %ebp,%eax
  802369:	d3 e2                	shl    %cl,%edx
  80236b:	89 c7                	mov    %eax,%edi
  80236d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802371:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 c1                	mov    %eax,%ecx
  80237b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80237f:	09 d1                	or     %edx,%ecx
  802381:	89 fa                	mov    %edi,%edx
  802383:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802387:	89 e9                	mov    %ebp,%ecx
  802389:	d3 e0                	shl    %cl,%eax
  80238b:	89 f9                	mov    %edi,%ecx
  80238d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802391:	89 f0                	mov    %esi,%eax
  802393:	d3 e8                	shr    %cl,%eax
  802395:	89 e9                	mov    %ebp,%ecx
  802397:	89 c7                	mov    %eax,%edi
  802399:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	89 d1                	mov    %edx,%ecx
  8023a1:	89 fa                	mov    %edi,%edx
  8023a3:	d3 e8                	shr    %cl,%eax
  8023a5:	89 e9                	mov    %ebp,%ecx
  8023a7:	09 f0                	or     %esi,%eax
  8023a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8023ad:	f7 74 24 10          	divl   0x10(%esp)
  8023b1:	d3 e6                	shl    %cl,%esi
  8023b3:	89 d1                	mov    %edx,%ecx
  8023b5:	f7 64 24 0c          	mull   0xc(%esp)
  8023b9:	39 d1                	cmp    %edx,%ecx
  8023bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	89 c6                	mov    %eax,%esi
  8023c3:	72 0a                	jb     8023cf <__umoddi3+0x12f>
  8023c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8023c9:	73 10                	jae    8023db <__umoddi3+0x13b>
  8023cb:	39 d1                	cmp    %edx,%ecx
  8023cd:	75 0c                	jne    8023db <__umoddi3+0x13b>
  8023cf:	89 d7                	mov    %edx,%edi
  8023d1:	89 c6                	mov    %eax,%esi
  8023d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8023d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8023db:	89 ca                	mov    %ecx,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e3:	29 f0                	sub    %esi,%eax
  8023e5:	19 fa                	sbb    %edi,%edx
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8023ee:	89 d7                	mov    %edx,%edi
  8023f0:	d3 e7                	shl    %cl,%edi
  8023f2:	89 e9                	mov    %ebp,%ecx
  8023f4:	09 f8                	or     %edi,%eax
  8023f6:	d3 ea                	shr    %cl,%edx
  8023f8:	83 c4 20             	add    $0x20,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
  802400:	8b 74 24 10          	mov    0x10(%esp),%esi
  802404:	29 f9                	sub    %edi,%ecx
  802406:	19 c6                	sbb    %eax,%esi
  802408:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80240c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802410:	e9 ff fe ff ff       	jmp    802314 <__umoddi3+0x74>
