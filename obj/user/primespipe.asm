
obj/user/primespipe:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %i", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 1d 15 00 00       	call   80156e <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 23                	je     80007c <primeproc+0x49>
		panic("primeproc could not read initial prime: %d, %i", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	0f 9f c2             	setg   %dl
  800061:	0f b6 d2             	movzbl %dl,%edx
  800064:	83 ea 01             	sub    $0x1,%edx
  800067:	21 c2                	and    %eax,%edx
  800069:	52                   	push   %edx
  80006a:	50                   	push   %eax
  80006b:	68 80 23 80 00       	push   $0x802380
  800070:	6a 15                	push   $0x15
  800072:	68 af 23 80 00       	push   $0x8023af
  800077:	e8 28 02 00 00       	call   8002a4 <_panic>

	cprintf("%d\n", p);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	ff 75 e0             	pushl  -0x20(%ebp)
  800082:	68 c1 23 80 00       	push   $0x8023c1
  800087:	e8 f1 02 00 00       	call   80037d <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80008c:	89 3c 24             	mov    %edi,(%esp)
  80008f:	e8 43 1b 00 00       	call   801bd7 <pipe>
  800094:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <primeproc+0x7d>
		panic("pipe: %i", i);
  80009e:	50                   	push   %eax
  80009f:	68 c5 23 80 00       	push   $0x8023c5
  8000a4:	6a 1b                	push   $0x1b
  8000a6:	68 af 23 80 00       	push   $0x8023af
  8000ab:	e8 f4 01 00 00       	call   8002a4 <_panic>
	if ((id = fork()) < 0)
  8000b0:	e8 60 0f 00 00       	call   801015 <fork>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 12                	jns    8000cb <primeproc+0x98>
		panic("fork: %i", id);
  8000b9:	50                   	push   %eax
  8000ba:	68 19 28 80 00       	push   $0x802819
  8000bf:	6a 1d                	push   $0x1d
  8000c1:	68 af 23 80 00       	push   $0x8023af
  8000c6:	e8 d9 01 00 00       	call   8002a4 <_panic>
	if (id == 0) {
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	75 1f                	jne    8000ee <primeproc+0xbb>
		close(fd);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	53                   	push   %ebx
  8000d3:	e8 c5 12 00 00       	call   80139d <close>
		close(pfd[1]);
  8000d8:	83 c4 04             	add    $0x4,%esp
  8000db:	ff 75 dc             	pushl  -0x24(%ebp)
  8000de:	e8 ba 12 00 00       	call   80139d <close>
		fd = pfd[0];
  8000e3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	e9 57 ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f4:	e8 a4 12 00 00       	call   80139d <close>
	wfd = pfd[1];
  8000f9:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000fc:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000ff:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800102:	83 ec 04             	sub    $0x4,%esp
  800105:	6a 04                	push   $0x4
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	e8 60 14 00 00       	call   80156e <readn>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	83 f8 04             	cmp    $0x4,%eax
  800114:	74 27                	je     80013d <primeproc+0x10a>
			panic("primeproc %d readn %d %d %i", p, fd, r, r >= 0 ? 0 : r);
  800116:	83 ec 04             	sub    $0x4,%esp
  800119:	85 c0                	test   %eax,%eax
  80011b:	0f 9f c2             	setg   %dl
  80011e:	0f b6 d2             	movzbl %dl,%edx
  800121:	83 ea 01             	sub    $0x1,%edx
  800124:	21 c2                	and    %eax,%edx
  800126:	52                   	push   %edx
  800127:	50                   	push   %eax
  800128:	53                   	push   %ebx
  800129:	ff 75 e0             	pushl  -0x20(%ebp)
  80012c:	68 ce 23 80 00       	push   $0x8023ce
  800131:	6a 2b                	push   $0x2b
  800133:	68 af 23 80 00       	push   $0x8023af
  800138:	e8 67 01 00 00       	call   8002a4 <_panic>
		if (i%p)
  80013d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800140:	99                   	cltd   
  800141:	f7 7d e0             	idivl  -0x20(%ebp)
  800144:	85 d2                	test   %edx,%edx
  800146:	74 ba                	je     800102 <primeproc+0xcf>
			if ((r=write(wfd, &i, 4)) != 4)
  800148:	83 ec 04             	sub    $0x4,%esp
  80014b:	6a 04                	push   $0x4
  80014d:	56                   	push   %esi
  80014e:	57                   	push   %edi
  80014f:	e8 5f 14 00 00       	call   8015b3 <write>
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	83 f8 04             	cmp    $0x4,%eax
  80015a:	74 a6                	je     800102 <primeproc+0xcf>
				panic("primeproc %d write: %d %i", p, r, r >= 0 ? 0 : r);
  80015c:	83 ec 08             	sub    $0x8,%esp
  80015f:	85 c0                	test   %eax,%eax
  800161:	0f 9f c2             	setg   %dl
  800164:	0f b6 d2             	movzbl %dl,%edx
  800167:	83 ea 01             	sub    $0x1,%edx
  80016a:	21 c2                	and    %eax,%edx
  80016c:	52                   	push   %edx
  80016d:	50                   	push   %eax
  80016e:	ff 75 e0             	pushl  -0x20(%ebp)
  800171:	68 ea 23 80 00       	push   $0x8023ea
  800176:	6a 2e                	push   $0x2e
  800178:	68 af 23 80 00       	push   $0x8023af
  80017d:	e8 22 01 00 00       	call   8002a4 <_panic>

00800182 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800189:	c7 05 00 30 80 00 04 	movl   $0x802404,0x803000
  800190:	24 80 00 

	if ((i=pipe(p)) < 0)
  800193:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 3b 1a 00 00       	call   801bd7 <pipe>
  80019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	79 12                	jns    8001b8 <umain+0x36>
		panic("pipe: %i", i);
  8001a6:	50                   	push   %eax
  8001a7:	68 c5 23 80 00       	push   $0x8023c5
  8001ac:	6a 3a                	push   $0x3a
  8001ae:	68 af 23 80 00       	push   $0x8023af
  8001b3:	e8 ec 00 00 00       	call   8002a4 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001b8:	e8 58 0e 00 00       	call   801015 <fork>
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x51>
		panic("fork: %i", id);
  8001c1:	50                   	push   %eax
  8001c2:	68 19 28 80 00       	push   $0x802819
  8001c7:	6a 3e                	push   $0x3e
  8001c9:	68 af 23 80 00       	push   $0x8023af
  8001ce:	e8 d1 00 00 00       	call   8002a4 <_panic>

	if (id == 0) {
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	75 16                	jne    8001ed <umain+0x6b>
		close(p[1]);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	ff 75 f0             	pushl  -0x10(%ebp)
  8001dd:	e8 bb 11 00 00       	call   80139d <close>
		primeproc(p[0]);
  8001e2:	83 c4 04             	add    $0x4,%esp
  8001e5:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e8:	e8 46 fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 ec             	pushl  -0x14(%ebp)
  8001f3:	e8 a5 11 00 00       	call   80139d <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f8:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001ff:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  800202:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	6a 04                	push   $0x4
  80020a:	53                   	push   %ebx
  80020b:	ff 75 f0             	pushl  -0x10(%ebp)
  80020e:	e8 a0 13 00 00       	call   8015b3 <write>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	83 f8 04             	cmp    $0x4,%eax
  800219:	74 23                	je     80023e <umain+0xbc>
			panic("generator write: %d, %i", r, r >= 0 ? 0 : r);
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	85 c0                	test   %eax,%eax
  800220:	0f 9f c2             	setg   %dl
  800223:	0f b6 d2             	movzbl %dl,%edx
  800226:	83 ea 01             	sub    $0x1,%edx
  800229:	21 c2                	and    %eax,%edx
  80022b:	52                   	push   %edx
  80022c:	50                   	push   %eax
  80022d:	68 0f 24 80 00       	push   $0x80240f
  800232:	6a 4a                	push   $0x4a
  800234:	68 af 23 80 00       	push   $0x8023af
  800239:	e8 66 00 00 00       	call   8002a4 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  80023e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %i", r, r >= 0 ? 0 : r);
}
  800242:	eb c1                	jmp    800205 <umain+0x83>

00800244 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80024c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80024f:	e8 79 0a 00 00       	call   800ccd <sys_getenvid>
  800254:	25 ff 03 00 00       	and    $0x3ff,%eax
  800259:	6b c0 78             	imul   $0x78,%eax,%eax
  80025c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800261:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800266:	85 db                	test   %ebx,%ebx
  800268:	7e 07                	jle    800271 <libmain+0x2d>
		binaryname = argv[0];
  80026a:	8b 06                	mov    (%esi),%eax
  80026c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	e8 07 ff ff ff       	call   800182 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80027b:	e8 0a 00 00 00       	call   80028a <exit>
  800280:	83 c4 10             	add    $0x10,%esp
#endif
}
  800283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800290:	e8 35 11 00 00       	call   8013ca <close_all>
	sys_env_destroy(0);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	6a 00                	push   $0x0
  80029a:	e8 ed 09 00 00       	call   800c8c <sys_env_destroy>
  80029f:	83 c4 10             	add    $0x10,%esp
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ac:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b2:	e8 16 0a 00 00       	call   800ccd <sys_getenvid>
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	ff 75 08             	pushl  0x8(%ebp)
  8002c0:	56                   	push   %esi
  8002c1:	50                   	push   %eax
  8002c2:	68 34 24 80 00       	push   $0x802434
  8002c7:	e8 b1 00 00 00       	call   80037d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cc:	83 c4 18             	add    $0x18,%esp
  8002cf:	53                   	push   %ebx
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	e8 54 00 00 00       	call   80032c <vcprintf>
	cprintf("\n");
  8002d8:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  8002df:	e8 99 00 00 00       	call   80037d <cprintf>
  8002e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e7:	cc                   	int3   
  8002e8:	eb fd                	jmp    8002e7 <_panic+0x43>

008002ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 04             	sub    $0x4,%esp
  8002f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f4:	8b 13                	mov    (%ebx),%edx
  8002f6:	8d 42 01             	lea    0x1(%edx),%eax
  8002f9:	89 03                	mov    %eax,(%ebx)
  8002fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800302:	3d ff 00 00 00       	cmp    $0xff,%eax
  800307:	75 1a                	jne    800323 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	68 ff 00 00 00       	push   $0xff
  800311:	8d 43 08             	lea    0x8(%ebx),%eax
  800314:	50                   	push   %eax
  800315:	e8 35 09 00 00       	call   800c4f <sys_cputs>
		b->idx = 0;
  80031a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800320:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800323:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800335:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033c:	00 00 00 
	b.cnt = 0;
  80033f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800346:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800349:	ff 75 0c             	pushl  0xc(%ebp)
  80034c:	ff 75 08             	pushl  0x8(%ebp)
  80034f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	68 ea 02 80 00       	push   $0x8002ea
  80035b:	e8 4f 01 00 00       	call   8004af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800360:	83 c4 08             	add    $0x8,%esp
  800363:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800369:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036f:	50                   	push   %eax
  800370:	e8 da 08 00 00       	call   800c4f <sys_cputs>

	return b.cnt;
}
  800375:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    

0080037d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800383:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800386:	50                   	push   %eax
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 9d ff ff ff       	call   80032c <vcprintf>
	va_end(ap);

	return cnt;
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 1c             	sub    $0x1c,%esp
  80039a:	89 c7                	mov    %eax,%edi
  80039c:	89 d6                	mov    %edx,%esi
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a4:	89 d1                	mov    %edx,%ecx
  8003a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8003af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003bc:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8003bf:	72 05                	jb     8003c6 <printnum+0x35>
  8003c1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003c4:	77 3e                	ja     800404 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c6:	83 ec 0c             	sub    $0xc,%esp
  8003c9:	ff 75 18             	pushl  0x18(%ebp)
  8003cc:	83 eb 01             	sub    $0x1,%ebx
  8003cf:	53                   	push   %ebx
  8003d0:	50                   	push   %eax
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003da:	ff 75 dc             	pushl  -0x24(%ebp)
  8003dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e0:	e8 cb 1c 00 00       	call   8020b0 <__udivdi3>
  8003e5:	83 c4 18             	add    $0x18,%esp
  8003e8:	52                   	push   %edx
  8003e9:	50                   	push   %eax
  8003ea:	89 f2                	mov    %esi,%edx
  8003ec:	89 f8                	mov    %edi,%eax
  8003ee:	e8 9e ff ff ff       	call   800391 <printnum>
  8003f3:	83 c4 20             	add    $0x20,%esp
  8003f6:	eb 13                	jmp    80040b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	56                   	push   %esi
  8003fc:	ff 75 18             	pushl  0x18(%ebp)
  8003ff:	ff d7                	call   *%edi
  800401:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800404:	83 eb 01             	sub    $0x1,%ebx
  800407:	85 db                	test   %ebx,%ebx
  800409:	7f ed                	jg     8003f8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	56                   	push   %esi
  80040f:	83 ec 04             	sub    $0x4,%esp
  800412:	ff 75 e4             	pushl  -0x1c(%ebp)
  800415:	ff 75 e0             	pushl  -0x20(%ebp)
  800418:	ff 75 dc             	pushl  -0x24(%ebp)
  80041b:	ff 75 d8             	pushl  -0x28(%ebp)
  80041e:	e8 bd 1d 00 00       	call   8021e0 <__umoddi3>
  800423:	83 c4 14             	add    $0x14,%esp
  800426:	0f be 80 57 24 80 00 	movsbl 0x802457(%eax),%eax
  80042d:	50                   	push   %eax
  80042e:	ff d7                	call   *%edi
  800430:	83 c4 10             	add    $0x10,%esp
}
  800433:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800436:	5b                   	pop    %ebx
  800437:	5e                   	pop    %esi
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043e:	83 fa 01             	cmp    $0x1,%edx
  800441:	7e 0e                	jle    800451 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800443:	8b 10                	mov    (%eax),%edx
  800445:	8d 4a 08             	lea    0x8(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	8b 52 04             	mov    0x4(%edx),%edx
  80044f:	eb 22                	jmp    800473 <getuint+0x38>
	else if (lflag)
  800451:	85 d2                	test   %edx,%edx
  800453:	74 10                	je     800465 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800455:	8b 10                	mov    (%eax),%edx
  800457:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045a:	89 08                	mov    %ecx,(%eax)
  80045c:	8b 02                	mov    (%edx),%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	eb 0e                	jmp    800473 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800465:	8b 10                	mov    (%eax),%edx
  800467:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 02                	mov    (%edx),%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80047b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80047f:	8b 10                	mov    (%eax),%edx
  800481:	3b 50 04             	cmp    0x4(%eax),%edx
  800484:	73 0a                	jae    800490 <sprintputch+0x1b>
		*b->buf++ = ch;
  800486:	8d 4a 01             	lea    0x1(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	88 02                	mov    %al,(%edx)
}
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    

00800492 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800498:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049b:	50                   	push   %eax
  80049c:	ff 75 10             	pushl  0x10(%ebp)
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 08             	pushl  0x8(%ebp)
  8004a5:	e8 05 00 00 00       	call   8004af <vprintfmt>
	va_end(ap);
  8004aa:	83 c4 10             	add    $0x10,%esp
}
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	57                   	push   %edi
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 2c             	sub    $0x2c,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004c1:	eb 12                	jmp    8004d5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	0f 84 8d 03 00 00    	je     800858 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	50                   	push   %eax
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	83 f8 25             	cmp    $0x25,%eax
  8004df:	75 e2                	jne    8004c3 <vprintfmt+0x14>
  8004e1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ff:	eb 07                	jmp    800508 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800504:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8d 47 01             	lea    0x1(%edi),%eax
  80050b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050e:	0f b6 07             	movzbl (%edi),%eax
  800511:	0f b6 c8             	movzbl %al,%ecx
  800514:	83 e8 23             	sub    $0x23,%eax
  800517:	3c 55                	cmp    $0x55,%al
  800519:	0f 87 1e 03 00 00    	ja     80083d <vprintfmt+0x38e>
  80051f:	0f b6 c0             	movzbl %al,%eax
  800522:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80052c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800530:	eb d6                	jmp    800508 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800540:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800544:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800547:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80054a:	83 fa 09             	cmp    $0x9,%edx
  80054d:	77 38                	ja     800587 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80054f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb e9                	jmp    80053d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 48 04             	lea    0x4(%eax),%ecx
  80055a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800565:	eb 26                	jmp    80058d <vprintfmt+0xde>
  800567:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056a:	89 c8                	mov    %ecx,%eax
  80056c:	c1 f8 1f             	sar    $0x1f,%eax
  80056f:	f7 d0                	not    %eax
  800571:	21 c1                	and    %eax,%ecx
  800573:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800579:	eb 8d                	jmp    800508 <vprintfmt+0x59>
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80057e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800585:	eb 81                	jmp    800508 <vprintfmt+0x59>
  800587:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	0f 89 71 ff ff ff    	jns    800508 <vprintfmt+0x59>
				width = precision, precision = -1;
  800597:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80059a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a4:	e9 5f ff ff ff       	jmp    800508 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005af:	e9 54 ff ff ff       	jmp    800508 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	ff 30                	pushl  (%eax)
  8005c3:	ff d6                	call   *%esi
			break;
  8005c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005cb:	e9 05 ff ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	99                   	cltd   
  8005dc:	31 d0                	xor    %edx,%eax
  8005de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e0:	83 f8 0f             	cmp    $0xf,%eax
  8005e3:	7f 0b                	jg     8005f0 <vprintfmt+0x141>
  8005e5:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	75 18                	jne    800608 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8005f0:	50                   	push   %eax
  8005f1:	68 6f 24 80 00       	push   $0x80246f
  8005f6:	53                   	push   %ebx
  8005f7:	56                   	push   %esi
  8005f8:	e8 95 fe ff ff       	call   800492 <printfmt>
  8005fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800603:	e9 cd fe ff ff       	jmp    8004d5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800608:	52                   	push   %edx
  800609:	68 01 29 80 00       	push   $0x802901
  80060e:	53                   	push   %ebx
  80060f:	56                   	push   %esi
  800610:	e8 7d fe ff ff       	call   800492 <printfmt>
  800615:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 b5 fe ff ff       	jmp    8004d5 <vprintfmt+0x26>
  800620:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800626:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 38                	mov    (%eax),%edi
  800634:	85 ff                	test   %edi,%edi
  800636:	75 05                	jne    80063d <vprintfmt+0x18e>
				p = "(null)";
  800638:	bf 68 24 80 00       	mov    $0x802468,%edi
			if (width > 0 && padc != '-')
  80063d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800641:	0f 84 91 00 00 00    	je     8006d8 <vprintfmt+0x229>
  800647:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80064b:	0f 8e 95 00 00 00    	jle    8006e6 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	51                   	push   %ecx
  800655:	57                   	push   %edi
  800656:	e8 85 02 00 00       	call   8008e0 <strnlen>
  80065b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80065e:	29 c1                	sub    %eax,%ecx
  800660:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800666:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80066a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800670:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800672:	eb 0f                	jmp    800683 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	ff 75 e0             	pushl  -0x20(%ebp)
  80067b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067d:	83 ef 01             	sub    $0x1,%edi
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 ff                	test   %edi,%edi
  800685:	7f ed                	jg     800674 <vprintfmt+0x1c5>
  800687:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80068a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80068d:	89 c8                	mov    %ecx,%eax
  80068f:	c1 f8 1f             	sar    $0x1f,%eax
  800692:	f7 d0                	not    %eax
  800694:	21 c8                	and    %ecx,%eax
  800696:	29 c1                	sub    %eax,%ecx
  800698:	89 75 08             	mov    %esi,0x8(%ebp)
  80069b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a1:	89 cb                	mov    %ecx,%ebx
  8006a3:	eb 4d                	jmp    8006f2 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a9:	74 1b                	je     8006c6 <vprintfmt+0x217>
  8006ab:	0f be c0             	movsbl %al,%eax
  8006ae:	83 e8 20             	sub    $0x20,%eax
  8006b1:	83 f8 5e             	cmp    $0x5e,%eax
  8006b4:	76 10                	jbe    8006c6 <vprintfmt+0x217>
					putch('?', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	ff 75 0c             	pushl  0xc(%ebp)
  8006bc:	6a 3f                	push   $0x3f
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 0d                	jmp    8006d3 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	52                   	push   %edx
  8006cd:	ff 55 08             	call   *0x8(%ebp)
  8006d0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d3:	83 eb 01             	sub    $0x1,%ebx
  8006d6:	eb 1a                	jmp    8006f2 <vprintfmt+0x243>
  8006d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e4:	eb 0c                	jmp    8006f2 <vprintfmt+0x243>
  8006e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006f2:	83 c7 01             	add    $0x1,%edi
  8006f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f9:	0f be d0             	movsbl %al,%edx
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	74 23                	je     800723 <vprintfmt+0x274>
  800700:	85 f6                	test   %esi,%esi
  800702:	78 a1                	js     8006a5 <vprintfmt+0x1f6>
  800704:	83 ee 01             	sub    $0x1,%esi
  800707:	79 9c                	jns    8006a5 <vprintfmt+0x1f6>
  800709:	89 df                	mov    %ebx,%edi
  80070b:	8b 75 08             	mov    0x8(%ebp),%esi
  80070e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800711:	eb 18                	jmp    80072b <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 20                	push   $0x20
  800719:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071b:	83 ef 01             	sub    $0x1,%edi
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 08                	jmp    80072b <vprintfmt+0x27c>
  800723:	89 df                	mov    %ebx,%edi
  800725:	8b 75 08             	mov    0x8(%ebp),%esi
  800728:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072b:	85 ff                	test   %edi,%edi
  80072d:	7f e4                	jg     800713 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800732:	e9 9e fd ff ff       	jmp    8004d5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800737:	83 fa 01             	cmp    $0x1,%edx
  80073a:	7e 16                	jle    800752 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8d 50 08             	lea    0x8(%eax),%edx
  800742:	89 55 14             	mov    %edx,0x14(%ebp)
  800745:	8b 50 04             	mov    0x4(%eax),%edx
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800750:	eb 32                	jmp    800784 <vprintfmt+0x2d5>
	else if (lflag)
  800752:	85 d2                	test   %edx,%edx
  800754:	74 18                	je     80076e <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 04             	lea    0x4(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800764:	89 c1                	mov    %eax,%ecx
  800766:	c1 f9 1f             	sar    $0x1f,%ecx
  800769:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076c:	eb 16                	jmp    800784 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8d 50 04             	lea    0x4(%eax),%edx
  800774:	89 55 14             	mov    %edx,0x14(%ebp)
  800777:	8b 00                	mov    (%eax),%eax
  800779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077c:	89 c1                	mov    %eax,%ecx
  80077e:	c1 f9 1f             	sar    $0x1f,%ecx
  800781:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800784:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800787:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800793:	79 74                	jns    800809 <vprintfmt+0x35a>
				putch('-', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	53                   	push   %ebx
  800799:	6a 2d                	push   $0x2d
  80079b:	ff d6                	call   *%esi
				num = -(long long) num;
  80079d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007a3:	f7 d8                	neg    %eax
  8007a5:	83 d2 00             	adc    $0x0,%edx
  8007a8:	f7 da                	neg    %edx
  8007aa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007b2:	eb 55                	jmp    800809 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b7:	e8 7f fc ff ff       	call   80043b <getuint>
			base = 10;
  8007bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007c1:	eb 46                	jmp    800809 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 70 fc ff ff       	call   80043b <getuint>
			base = 8;
  8007cb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007d0:	eb 37                	jmp    800809 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	6a 30                	push   $0x30
  8007d8:	ff d6                	call   *%esi
			putch('x', putdat);
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	53                   	push   %ebx
  8007de:	6a 78                	push   $0x78
  8007e0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007fa:	eb 0d                	jmp    800809 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ff:	e8 37 fc ff ff       	call   80043b <getuint>
			base = 16;
  800804:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800809:	83 ec 0c             	sub    $0xc,%esp
  80080c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800810:	57                   	push   %edi
  800811:	ff 75 e0             	pushl  -0x20(%ebp)
  800814:	51                   	push   %ecx
  800815:	52                   	push   %edx
  800816:	50                   	push   %eax
  800817:	89 da                	mov    %ebx,%edx
  800819:	89 f0                	mov    %esi,%eax
  80081b:	e8 71 fb ff ff       	call   800391 <printnum>
			break;
  800820:	83 c4 20             	add    $0x20,%esp
  800823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800826:	e9 aa fc ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	53                   	push   %ebx
  80082f:	51                   	push   %ecx
  800830:	ff d6                	call   *%esi
			break;
  800832:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800838:	e9 98 fc ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	6a 25                	push   $0x25
  800843:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 03                	jmp    80084d <vprintfmt+0x39e>
  80084a:	83 ef 01             	sub    $0x1,%edi
  80084d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800851:	75 f7                	jne    80084a <vprintfmt+0x39b>
  800853:	e9 7d fc ff ff       	jmp    8004d5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800858:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5f                   	pop    %edi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 18             	sub    $0x18,%esp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800873:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800876:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 26                	je     8008a7 <vsnprintf+0x47>
  800881:	85 d2                	test   %edx,%edx
  800883:	7e 22                	jle    8008a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800885:	ff 75 14             	pushl  0x14(%ebp)
  800888:	ff 75 10             	pushl  0x10(%ebp)
  80088b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088e:	50                   	push   %eax
  80088f:	68 75 04 80 00       	push   $0x800475
  800894:	e8 16 fc ff ff       	call   8004af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800899:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	eb 05                	jmp    8008ac <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b7:	50                   	push   %eax
  8008b8:	ff 75 10             	pushl  0x10(%ebp)
  8008bb:	ff 75 0c             	pushl  0xc(%ebp)
  8008be:	ff 75 08             	pushl  0x8(%ebp)
  8008c1:	e8 9a ff ff ff       	call   800860 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	eb 03                	jmp    8008d8 <strlen+0x10>
		n++;
  8008d5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008dc:	75 f7                	jne    8008d5 <strlen+0xd>
		n++;
	return n;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ee:	eb 03                	jmp    8008f3 <strnlen+0x13>
		n++;
  8008f0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f3:	39 c2                	cmp    %eax,%edx
  8008f5:	74 08                	je     8008ff <strnlen+0x1f>
  8008f7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008fb:	75 f3                	jne    8008f0 <strnlen+0x10>
  8008fd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	83 c2 01             	add    $0x1,%edx
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800917:	88 5a ff             	mov    %bl,-0x1(%edx)
  80091a:	84 db                	test   %bl,%bl
  80091c:	75 ef                	jne    80090d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800928:	53                   	push   %ebx
  800929:	e8 9a ff ff ff       	call   8008c8 <strlen>
  80092e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800931:	ff 75 0c             	pushl  0xc(%ebp)
  800934:	01 d8                	add    %ebx,%eax
  800936:	50                   	push   %eax
  800937:	e8 c5 ff ff ff       	call   800901 <strcpy>
	return dst;
}
  80093c:	89 d8                	mov    %ebx,%eax
  80093e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 75 08             	mov    0x8(%ebp),%esi
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094e:	89 f3                	mov    %esi,%ebx
  800950:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800953:	89 f2                	mov    %esi,%edx
  800955:	eb 0f                	jmp    800966 <strncpy+0x23>
		*dst++ = *src;
  800957:	83 c2 01             	add    $0x1,%edx
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800960:	80 39 01             	cmpb   $0x1,(%ecx)
  800963:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800966:	39 da                	cmp    %ebx,%edx
  800968:	75 ed                	jne    800957 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80096a:	89 f0                	mov    %esi,%eax
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 75 08             	mov    0x8(%ebp),%esi
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097b:	8b 55 10             	mov    0x10(%ebp),%edx
  80097e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800980:	85 d2                	test   %edx,%edx
  800982:	74 21                	je     8009a5 <strlcpy+0x35>
  800984:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800988:	89 f2                	mov    %esi,%edx
  80098a:	eb 09                	jmp    800995 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800995:	39 c2                	cmp    %eax,%edx
  800997:	74 09                	je     8009a2 <strlcpy+0x32>
  800999:	0f b6 19             	movzbl (%ecx),%ebx
  80099c:	84 db                	test   %bl,%bl
  80099e:	75 ec                	jne    80098c <strlcpy+0x1c>
  8009a0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a5:	29 f0                	sub    %esi,%eax
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b4:	eb 06                	jmp    8009bc <strcmp+0x11>
		p++, q++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	84 c0                	test   %al,%al
  8009c1:	74 04                	je     8009c7 <strcmp+0x1c>
  8009c3:	3a 02                	cmp    (%edx),%al
  8009c5:	74 ef                	je     8009b6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c7:	0f b6 c0             	movzbl %al,%eax
  8009ca:	0f b6 12             	movzbl (%edx),%edx
  8009cd:	29 d0                	sub    %edx,%eax
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 c3                	mov    %eax,%ebx
  8009dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e0:	eb 06                	jmp    8009e8 <strncmp+0x17>
		n--, p++, q++;
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e8:	39 d8                	cmp    %ebx,%eax
  8009ea:	74 15                	je     800a01 <strncmp+0x30>
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	84 c9                	test   %cl,%cl
  8009f1:	74 04                	je     8009f7 <strncmp+0x26>
  8009f3:	3a 0a                	cmp    (%edx),%cl
  8009f5:	74 eb                	je     8009e2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f7:	0f b6 00             	movzbl (%eax),%eax
  8009fa:	0f b6 12             	movzbl (%edx),%edx
  8009fd:	29 d0                	sub    %edx,%eax
  8009ff:	eb 05                	jmp    800a06 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a06:	5b                   	pop    %ebx
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a13:	eb 07                	jmp    800a1c <strchr+0x13>
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 0f                	je     800a28 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	0f b6 10             	movzbl (%eax),%edx
  800a1f:	84 d2                	test   %dl,%dl
  800a21:	75 f2                	jne    800a15 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	eb 03                	jmp    800a39 <strfind+0xf>
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3c:	84 d2                	test   %dl,%dl
  800a3e:	74 04                	je     800a44 <strfind+0x1a>
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	75 f2                	jne    800a36 <strfind+0xc>
			break;
	return (char *) s;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800a52:	85 c9                	test   %ecx,%ecx
  800a54:	74 36                	je     800a8c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a56:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5c:	75 28                	jne    800a86 <memset+0x40>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 23                	jne    800a86 <memset+0x40>
		c &= 0xFF;
  800a63:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a67:	89 d3                	mov    %edx,%ebx
  800a69:	c1 e3 08             	shl    $0x8,%ebx
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	c1 e6 18             	shl    $0x18,%esi
  800a71:	89 d0                	mov    %edx,%eax
  800a73:	c1 e0 10             	shl    $0x10,%eax
  800a76:	09 f0                	or     %esi,%eax
  800a78:	09 c2                	or     %eax,%edx
  800a7a:	89 d0                	mov    %edx,%eax
  800a7c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a7e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a81:	fc                   	cld    
  800a82:	f3 ab                	rep stos %eax,%es:(%edi)
  800a84:	eb 06                	jmp    800a8c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	fc                   	cld    
  800a8a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8c:	89 f8                	mov    %edi,%eax
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 35                	jae    800ada <memmove+0x47>
  800aa5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa8:	39 d0                	cmp    %edx,%eax
  800aaa:	73 2e                	jae    800ada <memmove+0x47>
		s += n;
		d += n;
  800aac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aaf:	89 d6                	mov    %edx,%esi
  800ab1:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab9:	75 13                	jne    800ace <memmove+0x3b>
  800abb:	f6 c1 03             	test   $0x3,%cl
  800abe:	75 0e                	jne    800ace <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac0:	83 ef 04             	sub    $0x4,%edi
  800ac3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ac9:	fd                   	std    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb 09                	jmp    800ad7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ace:	83 ef 01             	sub    $0x1,%edi
  800ad1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad4:	fd                   	std    
  800ad5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad7:	fc                   	cld    
  800ad8:	eb 1d                	jmp    800af7 <memmove+0x64>
  800ada:	89 f2                	mov    %esi,%edx
  800adc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ade:	f6 c2 03             	test   $0x3,%dl
  800ae1:	75 0f                	jne    800af2 <memmove+0x5f>
  800ae3:	f6 c1 03             	test   $0x3,%cl
  800ae6:	75 0a                	jne    800af2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	fc                   	cld    
  800aee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af0:	eb 05                	jmp    800af7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	fc                   	cld    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afe:	ff 75 10             	pushl  0x10(%ebp)
  800b01:	ff 75 0c             	pushl  0xc(%ebp)
  800b04:	ff 75 08             	pushl  0x8(%ebp)
  800b07:	e8 87 ff ff ff       	call   800a93 <memmove>
}
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1e:	eb 1a                	jmp    800b3a <memcmp+0x2c>
		if (*s1 != *s2)
  800b20:	0f b6 08             	movzbl (%eax),%ecx
  800b23:	0f b6 1a             	movzbl (%edx),%ebx
  800b26:	38 d9                	cmp    %bl,%cl
  800b28:	74 0a                	je     800b34 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b2a:	0f b6 c1             	movzbl %cl,%eax
  800b2d:	0f b6 db             	movzbl %bl,%ebx
  800b30:	29 d8                	sub    %ebx,%eax
  800b32:	eb 0f                	jmp    800b43 <memcmp+0x35>
		s1++, s2++;
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	39 f0                	cmp    %esi,%eax
  800b3c:	75 e2                	jne    800b20 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b55:	eb 07                	jmp    800b5e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b57:	38 08                	cmp    %cl,(%eax)
  800b59:	74 07                	je     800b62 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5b:	83 c0 01             	add    $0x1,%eax
  800b5e:	39 d0                	cmp    %edx,%eax
  800b60:	72 f5                	jb     800b57 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	eb 03                	jmp    800b75 <strtol+0x11>
		s++;
  800b72:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	0f b6 01             	movzbl (%ecx),%eax
  800b78:	3c 09                	cmp    $0x9,%al
  800b7a:	74 f6                	je     800b72 <strtol+0xe>
  800b7c:	3c 20                	cmp    $0x20,%al
  800b7e:	74 f2                	je     800b72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b80:	3c 2b                	cmp    $0x2b,%al
  800b82:	75 0a                	jne    800b8e <strtol+0x2a>
		s++;
  800b84:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b87:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8c:	eb 10                	jmp    800b9e <strtol+0x3a>
  800b8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b93:	3c 2d                	cmp    $0x2d,%al
  800b95:	75 07                	jne    800b9e <strtol+0x3a>
		s++, neg = 1;
  800b97:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b9a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9e:	85 db                	test   %ebx,%ebx
  800ba0:	0f 94 c0             	sete   %al
  800ba3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba9:	75 19                	jne    800bc4 <strtol+0x60>
  800bab:	80 39 30             	cmpb   $0x30,(%ecx)
  800bae:	75 14                	jne    800bc4 <strtol+0x60>
  800bb0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb4:	0f 85 8a 00 00 00    	jne    800c44 <strtol+0xe0>
		s += 2, base = 16;
  800bba:	83 c1 02             	add    $0x2,%ecx
  800bbd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc2:	eb 16                	jmp    800bda <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc4:	84 c0                	test   %al,%al
  800bc6:	74 12                	je     800bda <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	75 08                	jne    800bda <strtol+0x76>
		s++, base = 8;
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be2:	0f b6 11             	movzbl (%ecx),%edx
  800be5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be8:	89 f3                	mov    %esi,%ebx
  800bea:	80 fb 09             	cmp    $0x9,%bl
  800bed:	77 08                	ja     800bf7 <strtol+0x93>
			dig = *s - '0';
  800bef:	0f be d2             	movsbl %dl,%edx
  800bf2:	83 ea 30             	sub    $0x30,%edx
  800bf5:	eb 22                	jmp    800c19 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800bf7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bfa:	89 f3                	mov    %esi,%ebx
  800bfc:	80 fb 19             	cmp    $0x19,%bl
  800bff:	77 08                	ja     800c09 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c01:	0f be d2             	movsbl %dl,%edx
  800c04:	83 ea 57             	sub    $0x57,%edx
  800c07:	eb 10                	jmp    800c19 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c0c:	89 f3                	mov    %esi,%ebx
  800c0e:	80 fb 19             	cmp    $0x19,%bl
  800c11:	77 16                	ja     800c29 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c13:	0f be d2             	movsbl %dl,%edx
  800c16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1c:	7d 0f                	jge    800c2d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c27:	eb b9                	jmp    800be2 <strtol+0x7e>
  800c29:	89 c2                	mov    %eax,%edx
  800c2b:	eb 02                	jmp    800c2f <strtol+0xcb>
  800c2d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c33:	74 05                	je     800c3a <strtol+0xd6>
		*endptr = (char *) s;
  800c35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c38:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	74 0c                	je     800c4a <strtol+0xe6>
  800c3e:	89 d0                	mov    %edx,%eax
  800c40:	f7 d8                	neg    %eax
  800c42:	eb 06                	jmp    800c4a <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c44:	84 c0                	test   %al,%al
  800c46:	75 8a                	jne    800bd2 <strtol+0x6e>
  800c48:	eb 90                	jmp    800bda <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 c6                	mov    %eax,%esi
  800c66:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_cgetc>:

int
sys_cgetc(void)
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
  800c78:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7d:	89 d1                	mov    %edx,%ecx
  800c7f:	89 d3                	mov    %edx,%ebx
  800c81:	89 d7                	mov    %edx,%edi
  800c83:	89 d6                	mov    %edx,%esi
  800c85:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 cb                	mov    %ecx,%ebx
  800ca4:	89 cf                	mov    %ecx,%edi
  800ca6:	89 ce                	mov    %ecx,%esi
  800ca8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 17                	jle    800cc5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 03                	push   $0x3
  800cb4:	68 9f 27 80 00       	push   $0x80279f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 bc 27 80 00       	push   $0x8027bc
  800cc0:	e8 df f5 ff ff       	call   8002a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 02 00 00 00       	mov    $0x2,%eax
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	89 d3                	mov    %edx,%ebx
  800ce1:	89 d7                	mov    %edx,%edi
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_yield>:

void
sys_yield(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	be 00 00 00 00       	mov    $0x0,%esi
  800d19:	b8 04 00 00 00       	mov    $0x4,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d27:	89 f7                	mov    %esi,%edi
  800d29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 04                	push   $0x4
  800d35:	68 9f 27 80 00       	push   $0x80279f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 bc 27 80 00       	push   $0x8027bc
  800d41:	e8 5e f5 ff ff       	call   8002a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d65:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d68:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 17                	jle    800d88 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	50                   	push   %eax
  800d75:	6a 05                	push   $0x5
  800d77:	68 9f 27 80 00       	push   $0x80279f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 bc 27 80 00       	push   $0x8027bc
  800d83:	e8 1c f5 ff ff       	call   8002a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 17                	jle    800dca <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 06                	push   $0x6
  800db9:	68 9f 27 80 00       	push   $0x80279f
  800dbe:	6a 23                	push   $0x23
  800dc0:	68 bc 27 80 00       	push   $0x8027bc
  800dc5:	e8 da f4 ff ff       	call   8002a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de0:	b8 08 00 00 00       	mov    $0x8,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 df                	mov    %ebx,%edi
  800ded:	89 de                	mov    %ebx,%esi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 17                	jle    800e0c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 08                	push   $0x8
  800dfb:	68 9f 27 80 00       	push   $0x80279f
  800e00:	6a 23                	push   $0x23
  800e02:	68 bc 27 80 00       	push   $0x8027bc
  800e07:	e8 98 f4 ff ff       	call   8002a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	b8 09 00 00 00       	mov    $0x9,%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 df                	mov    %ebx,%edi
  800e2f:	89 de                	mov    %ebx,%esi
  800e31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 17                	jle    800e4e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	50                   	push   %eax
  800e3b:	6a 09                	push   $0x9
  800e3d:	68 9f 27 80 00       	push   $0x80279f
  800e42:	6a 23                	push   $0x23
  800e44:	68 bc 27 80 00       	push   $0x8027bc
  800e49:	e8 56 f4 ff ff       	call   8002a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 17                	jle    800e90 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 0a                	push   $0xa
  800e7f:	68 9f 27 80 00       	push   $0x80279f
  800e84:	6a 23                	push   $0x23
  800e86:	68 bc 27 80 00       	push   $0x8027bc
  800e8b:	e8 14 f4 ff ff       	call   8002a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ea3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed1:	89 cb                	mov    %ecx,%ebx
  800ed3:	89 cf                	mov    %ecx,%edi
  800ed5:	89 ce                	mov    %ecx,%esi
  800ed7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 17                	jle    800ef4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	50                   	push   %eax
  800ee1:	6a 0d                	push   $0xd
  800ee3:	68 9f 27 80 00       	push   $0x80279f
  800ee8:	6a 23                	push   $0x23
  800eea:	68 bc 27 80 00       	push   $0x8027bc
  800eef:	e8 b0 f3 ff ff       	call   8002a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_gettime>:

int sys_gettime(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	ba 00 00 00 00       	mov    $0x0,%edx
  800f07:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f0c:	89 d1                	mov    %edx,%ecx
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	89 d7                	mov    %edx,%edi
  800f12:	89 d6                	mov    %edx,%esi
  800f14:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800f25:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f27:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f2b:	74 2e                	je     800f5b <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 1d                	je     800f5b <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800f4a:	f6 c1 01             	test   $0x1,%cl
  800f4d:	74 0c                	je     800f5b <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f56:	f6 c6 08             	test   $0x8,%dh
  800f59:	75 14                	jne    800f6f <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	68 ca 27 80 00       	push   $0x8027ca
  800f63:	6a 28                	push   $0x28
  800f65:	68 dc 27 80 00       	push   $0x8027dc
  800f6a:	e8 35 f3 ff ff       	call   8002a4 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800f6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f74:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	6a 07                	push   $0x7
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	6a 00                	push   $0x0
  800f82:	e8 84 fd ff ff       	call   800d0b <sys_page_alloc>
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 14                	jns    800fa2 <pgfault+0x87>
		panic("sys_page_alloc");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 e7 27 80 00       	push   $0x8027e7
  800f96:	6a 2c                	push   $0x2c
  800f98:	68 dc 27 80 00       	push   $0x8027dc
  800f9d:	e8 02 f3 ff ff       	call   8002a4 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	68 00 10 00 00       	push   $0x1000
  800faa:	53                   	push   %ebx
  800fab:	68 00 f0 7f 00       	push   $0x7ff000
  800fb0:	e8 46 fb ff ff       	call   800afb <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800fb5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fbc:	53                   	push   %ebx
  800fbd:	6a 00                	push   $0x0
  800fbf:	68 00 f0 7f 00       	push   $0x7ff000
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 83 fd ff ff       	call   800d4e <sys_page_map>
  800fcb:	83 c4 20             	add    $0x20,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	79 14                	jns    800fe6 <pgfault+0xcb>
		panic("sys_page_map");
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	68 f6 27 80 00       	push   $0x8027f6
  800fda:	6a 2f                	push   $0x2f
  800fdc:	68 dc 27 80 00       	push   $0x8027dc
  800fe1:	e8 be f2 ff ff       	call   8002a4 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	68 00 f0 7f 00       	push   $0x7ff000
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 9b fd ff ff       	call   800d90 <sys_page_unmap>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 14                	jns    801010 <pgfault+0xf5>
		panic("sys_page_unmap");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 03 28 80 00       	push   $0x802803
  801004:	6a 31                	push   $0x31
  801006:	68 dc 27 80 00       	push   $0x8027dc
  80100b:	e8 94 f2 ff ff       	call   8002a4 <_panic>
	return;
}
  801010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  80101e:	68 1b 0f 80 00       	push   $0x800f1b
  801023:	e8 bb 0e 00 00       	call   801ee3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801028:	b8 07 00 00 00       	mov    $0x7,%eax
  80102d:	cd 30                	int    $0x30
  80102f:	89 c7                	mov    %eax,%edi
  801031:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	75 21                	jne    80105c <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  80103b:	e8 8d fc ff ff       	call   800ccd <sys_getenvid>
  801040:	25 ff 03 00 00       	and    $0x3ff,%eax
  801045:	6b c0 78             	imul   $0x78,%eax,%eax
  801048:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
  801057:	e9 80 01 00 00       	jmp    8011dc <fork+0x1c7>
	}
	if (envid < 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 12                	jns    801072 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  801060:	50                   	push   %eax
  801061:	68 12 28 80 00       	push   $0x802812
  801066:	6a 70                	push   $0x70
  801068:	68 dc 27 80 00       	push   $0x8027dc
  80106d:	e8 32 f2 ff ff       	call   8002a4 <_panic>
  801072:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e8 16             	shr    $0x16,%eax
  80107c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	0f 84 de 00 00 00    	je     801169 <fork+0x154>
  80108b:	89 de                	mov    %ebx,%esi
  80108d:	c1 ee 0c             	shr    $0xc,%esi
  801090:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801097:	a8 01                	test   $0x1,%al
  801099:	0f 84 ca 00 00 00    	je     801169 <fork+0x154>
  80109f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a6:	a8 04                	test   $0x4,%al
  8010a8:	0f 84 bb 00 00 00    	je     801169 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  8010ae:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  8010b5:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  8010b8:	f6 c4 04             	test   $0x4,%ah
  8010bb:	74 34                	je     8010f1 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c5:	50                   	push   %eax
  8010c6:	56                   	push   %esi
  8010c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 7c fc ff ff       	call   800d4e <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	0f 84 8c 00 00 00    	je     801169 <fork+0x154>
        	panic("duppage share");
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	68 22 28 80 00       	push   $0x802822
  8010e5:	6a 48                	push   $0x48
  8010e7:	68 dc 27 80 00       	push   $0x8027dc
  8010ec:	e8 b3 f1 ff ff       	call   8002a4 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  8010f1:	a9 02 08 00 00       	test   $0x802,%eax
  8010f6:	74 5d                	je     801155 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	68 05 08 00 00       	push   $0x805
  801100:	56                   	push   %esi
  801101:	ff 75 e4             	pushl  -0x1c(%ebp)
  801104:	56                   	push   %esi
  801105:	6a 00                	push   $0x0
  801107:	e8 42 fc ff ff       	call   800d4e <sys_page_map>
  80110c:	83 c4 20             	add    $0x20,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 14                	jns    801127 <fork+0x112>
			panic("error");
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 84 24 80 00       	push   $0x802484
  80111b:	6a 4b                	push   $0x4b
  80111d:	68 dc 27 80 00       	push   $0x8027dc
  801122:	e8 7d f1 ff ff       	call   8002a4 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	68 05 08 00 00       	push   $0x805
  80112f:	56                   	push   %esi
  801130:	6a 00                	push   $0x0
  801132:	56                   	push   %esi
  801133:	6a 00                	push   $0x0
  801135:	e8 14 fc ff ff       	call   800d4e <sys_page_map>
  80113a:	83 c4 20             	add    $0x20,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 28                	jns    801169 <fork+0x154>
			panic("error");
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	68 84 24 80 00       	push   $0x802484
  801149:	6a 4d                	push   $0x4d
  80114b:	68 dc 27 80 00       	push   $0x8027dc
  801150:	e8 4f f1 ff ff       	call   8002a4 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	6a 05                	push   $0x5
  80115a:	56                   	push   %esi
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	56                   	push   %esi
  80115f:	6a 00                	push   $0x0
  801161:	e8 e8 fb ff ff       	call   800d4e <sys_page_map>
  801166:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801169:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80116f:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  801175:	0f 85 fc fe ff ff    	jne    801077 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	6a 07                	push   $0x7
  801180:	68 00 f0 7f ee       	push   $0xee7ff000
  801185:	57                   	push   %edi
  801186:	e8 80 fb ff ff       	call   800d0b <sys_page_alloc>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 14                	jns    8011a6 <fork+0x191>
		panic("1");
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	68 30 28 80 00       	push   $0x802830
  80119a:	6a 78                	push   $0x78
  80119c:	68 dc 27 80 00       	push   $0x8027dc
  8011a1:	e8 fe f0 ff ff       	call   8002a4 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	68 52 1f 80 00       	push   $0x801f52
  8011ae:	57                   	push   %edi
  8011af:	e8 a2 fc ff ff       	call   800e56 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	6a 02                	push   $0x2
  8011b9:	57                   	push   %edi
  8011ba:	e8 13 fc ff ff       	call   800dd2 <sys_env_set_status>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	79 14                	jns    8011da <fork+0x1c5>
		panic("sys_env_set_status");
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	68 32 28 80 00       	push   $0x802832
  8011ce:	6a 7d                	push   $0x7d
  8011d0:	68 dc 27 80 00       	push   $0x8027dc
  8011d5:	e8 ca f0 ff ff       	call   8002a4 <_panic>

	return envid;
  8011da:	89 f8                	mov    %edi,%eax
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ea:	68 45 28 80 00       	push   $0x802845
  8011ef:	68 86 00 00 00       	push   $0x86
  8011f4:	68 dc 27 80 00       	push   $0x8027dc
  8011f9:	e8 a6 f0 ff ff       	call   8002a4 <_panic>

008011fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
  801204:	05 00 00 00 30       	add    $0x30000000,%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801211:	8b 45 08             	mov    0x8(%ebp),%eax
  801214:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801219:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801230:	89 c2                	mov    %eax,%edx
  801232:	c1 ea 16             	shr    $0x16,%edx
  801235:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123c:	f6 c2 01             	test   $0x1,%dl
  80123f:	74 11                	je     801252 <fd_alloc+0x2d>
  801241:	89 c2                	mov    %eax,%edx
  801243:	c1 ea 0c             	shr    $0xc,%edx
  801246:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124d:	f6 c2 01             	test   $0x1,%dl
  801250:	75 09                	jne    80125b <fd_alloc+0x36>
			*fd_store = fd;
  801252:	89 01                	mov    %eax,(%ecx)
			return 0;
  801254:	b8 00 00 00 00       	mov    $0x0,%eax
  801259:	eb 17                	jmp    801272 <fd_alloc+0x4d>
  80125b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801260:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801265:	75 c9                	jne    801230 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801267:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80126d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80127a:	83 f8 1f             	cmp    $0x1f,%eax
  80127d:	77 36                	ja     8012b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127f:	c1 e0 0c             	shl    $0xc,%eax
  801282:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801293:	f6 c2 01             	test   $0x1,%dl
  801296:	74 24                	je     8012bc <fd_lookup+0x48>
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 ea 0c             	shr    $0xc,%edx
  80129d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	74 1a                	je     8012c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	eb 13                	jmp    8012c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ba:	eb 0c                	jmp    8012c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c1:	eb 05                	jmp    8012c8 <fd_lookup+0x54>
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d3:	ba d8 28 80 00       	mov    $0x8028d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d8:	eb 13                	jmp    8012ed <dev_lookup+0x23>
  8012da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012dd:	39 08                	cmp    %ecx,(%eax)
  8012df:	75 0c                	jne    8012ed <dev_lookup+0x23>
			*dev = devtab[i];
  8012e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb 2e                	jmp    80131b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ed:	8b 02                	mov    (%edx),%eax
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	75 e7                	jne    8012da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f8:	8b 40 48             	mov    0x48(%eax),%eax
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	51                   	push   %ecx
  8012ff:	50                   	push   %eax
  801300:	68 5c 28 80 00       	push   $0x80285c
  801305:	e8 73 f0 ff ff       	call   80037d <cprintf>
	*dev = 0;
  80130a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 10             	sub    $0x10,%esp
  801325:	8b 75 08             	mov    0x8(%ebp),%esi
  801328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80132f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801335:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801338:	50                   	push   %eax
  801339:	e8 36 ff ff ff       	call   801274 <fd_lookup>
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 05                	js     80134a <fd_close+0x2d>
	    || fd != fd2)
  801345:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801348:	74 0b                	je     801355 <fd_close+0x38>
		return (must_exist ? r : 0);
  80134a:	80 fb 01             	cmp    $0x1,%bl
  80134d:	19 d2                	sbb    %edx,%edx
  80134f:	f7 d2                	not    %edx
  801351:	21 d0                	and    %edx,%eax
  801353:	eb 41                	jmp    801396 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 36                	pushl  (%esi)
  80135e:	e8 67 ff ff ff       	call   8012ca <dev_lookup>
  801363:	89 c3                	mov    %eax,%ebx
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 1a                	js     801386 <fd_close+0x69>
		if (dev->dev_close)
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801377:	85 c0                	test   %eax,%eax
  801379:	74 0b                	je     801386 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	56                   	push   %esi
  80137f:	ff d0                	call   *%eax
  801381:	89 c3                	mov    %eax,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	56                   	push   %esi
  80138a:	6a 00                	push   $0x0
  80138c:	e8 ff f9 ff ff       	call   800d90 <sys_page_unmap>
	return r;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 d8                	mov    %ebx,%eax
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	ff 75 08             	pushl  0x8(%ebp)
  8013aa:	e8 c5 fe ff ff       	call   801274 <fd_lookup>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 d2                	test   %edx,%edx
  8013b6:	78 10                	js     8013c8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	6a 01                	push   $0x1
  8013bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c0:	e8 58 ff ff ff       	call   80131d <fd_close>
  8013c5:	83 c4 10             	add    $0x10,%esp
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <close_all>:

void
close_all(void)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	53                   	push   %ebx
  8013da:	e8 be ff ff ff       	call   80139d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	83 c3 01             	add    $0x1,%ebx
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	83 fb 20             	cmp    $0x20,%ebx
  8013e8:	75 ec                	jne    8013d6 <close_all+0xc>
		close(i);
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	57                   	push   %edi
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 2c             	sub    $0x2c,%esp
  8013f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 6d fe ff ff       	call   801274 <fd_lookup>
  801407:	89 c2                	mov    %eax,%edx
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	85 d2                	test   %edx,%edx
  80140e:	0f 88 c1 00 00 00    	js     8014d5 <dup+0xe6>
		return r;
	close(newfdnum);
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	56                   	push   %esi
  801418:	e8 80 ff ff ff       	call   80139d <close>

	newfd = INDEX2FD(newfdnum);
  80141d:	89 f3                	mov    %esi,%ebx
  80141f:	c1 e3 0c             	shl    $0xc,%ebx
  801422:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801428:	83 c4 04             	add    $0x4,%esp
  80142b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142e:	e8 db fd ff ff       	call   80120e <fd2data>
  801433:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801435:	89 1c 24             	mov    %ebx,(%esp)
  801438:	e8 d1 fd ff ff       	call   80120e <fd2data>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801443:	89 f8                	mov    %edi,%eax
  801445:	c1 e8 16             	shr    $0x16,%eax
  801448:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144f:	a8 01                	test   $0x1,%al
  801451:	74 37                	je     80148a <dup+0x9b>
  801453:	89 f8                	mov    %edi,%eax
  801455:	c1 e8 0c             	shr    $0xc,%eax
  801458:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145f:	f6 c2 01             	test   $0x1,%dl
  801462:	74 26                	je     80148a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801464:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	25 07 0e 00 00       	and    $0xe07,%eax
  801473:	50                   	push   %eax
  801474:	ff 75 d4             	pushl  -0x2c(%ebp)
  801477:	6a 00                	push   $0x0
  801479:	57                   	push   %edi
  80147a:	6a 00                	push   $0x0
  80147c:	e8 cd f8 ff ff       	call   800d4e <sys_page_map>
  801481:	89 c7                	mov    %eax,%edi
  801483:	83 c4 20             	add    $0x20,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 2e                	js     8014b8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80148d:	89 d0                	mov    %edx,%eax
  80148f:	c1 e8 0c             	shr    $0xc,%eax
  801492:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a1:	50                   	push   %eax
  8014a2:	53                   	push   %ebx
  8014a3:	6a 00                	push   $0x0
  8014a5:	52                   	push   %edx
  8014a6:	6a 00                	push   $0x0
  8014a8:	e8 a1 f8 ff ff       	call   800d4e <sys_page_map>
  8014ad:	89 c7                	mov    %eax,%edi
  8014af:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014b2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b4:	85 ff                	test   %edi,%edi
  8014b6:	79 1d                	jns    8014d5 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	6a 00                	push   $0x0
  8014be:	e8 cd f8 ff ff       	call   800d90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c9:	6a 00                	push   $0x0
  8014cb:	e8 c0 f8 ff ff       	call   800d90 <sys_page_unmap>
	return r;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	89 f8                	mov    %edi,%eax
}
  8014d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 14             	sub    $0x14,%esp
  8014e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	53                   	push   %ebx
  8014ec:	e8 83 fd ff ff       	call   801274 <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 6d                	js     801567 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	ff 30                	pushl  (%eax)
  801506:	e8 bf fd ff ff       	call   8012ca <dev_lookup>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 4c                	js     80155e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801512:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801515:	8b 42 08             	mov    0x8(%edx),%eax
  801518:	83 e0 03             	and    $0x3,%eax
  80151b:	83 f8 01             	cmp    $0x1,%eax
  80151e:	75 21                	jne    801541 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801520:	a1 04 40 80 00       	mov    0x804004,%eax
  801525:	8b 40 48             	mov    0x48(%eax),%eax
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	53                   	push   %ebx
  80152c:	50                   	push   %eax
  80152d:	68 9d 28 80 00       	push   $0x80289d
  801532:	e8 46 ee ff ff       	call   80037d <cprintf>
		return -E_INVAL;
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153f:	eb 26                	jmp    801567 <read+0x8a>
	}
	if (!dev->dev_read)
  801541:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801544:	8b 40 08             	mov    0x8(%eax),%eax
  801547:	85 c0                	test   %eax,%eax
  801549:	74 17                	je     801562 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	ff 75 10             	pushl  0x10(%ebp)
  801551:	ff 75 0c             	pushl  0xc(%ebp)
  801554:	52                   	push   %edx
  801555:	ff d0                	call   *%eax
  801557:	89 c2                	mov    %eax,%edx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	eb 09                	jmp    801567 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155e:	89 c2                	mov    %eax,%edx
  801560:	eb 05                	jmp    801567 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801562:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801567:	89 d0                	mov    %edx,%eax
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	57                   	push   %edi
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	8b 7d 08             	mov    0x8(%ebp),%edi
  80157a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801582:	eb 21                	jmp    8015a5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	89 f0                	mov    %esi,%eax
  801589:	29 d8                	sub    %ebx,%eax
  80158b:	50                   	push   %eax
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	03 45 0c             	add    0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	57                   	push   %edi
  801593:	e8 45 ff ff ff       	call   8014dd <read>
		if (m < 0)
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 0c                	js     8015ab <readn+0x3d>
			return m;
		if (m == 0)
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	74 06                	je     8015a9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a3:	01 c3                	add    %eax,%ebx
  8015a5:	39 f3                	cmp    %esi,%ebx
  8015a7:	72 db                	jb     801584 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015a9:	89 d8                	mov    %ebx,%eax
}
  8015ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 14             	sub    $0x14,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	e8 ad fc ff ff       	call   801274 <fd_lookup>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 68                	js     801638 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	ff 30                	pushl  (%eax)
  8015dc:	e8 e9 fc ff ff       	call   8012ca <dev_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 47                	js     80162f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ef:	75 21                	jne    801612 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f6:	8b 40 48             	mov    0x48(%eax),%eax
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	53                   	push   %ebx
  8015fd:	50                   	push   %eax
  8015fe:	68 b9 28 80 00       	push   $0x8028b9
  801603:	e8 75 ed ff ff       	call   80037d <cprintf>
		return -E_INVAL;
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801610:	eb 26                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	8b 52 0c             	mov    0xc(%edx),%edx
  801618:	85 d2                	test   %edx,%edx
  80161a:	74 17                	je     801633 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	ff 75 10             	pushl  0x10(%ebp)
  801622:	ff 75 0c             	pushl  0xc(%ebp)
  801625:	50                   	push   %eax
  801626:	ff d2                	call   *%edx
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 09                	jmp    801638 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	89 c2                	mov    %eax,%edx
  801631:	eb 05                	jmp    801638 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801633:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <seek>:

int
seek(int fdnum, off_t offset)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801645:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 23 fc ff ff       	call   801274 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 0e                	js     801666 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801658:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	53                   	push   %ebx
  80166c:	83 ec 14             	sub    $0x14,%esp
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801672:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	53                   	push   %ebx
  801677:	e8 f8 fb ff ff       	call   801274 <fd_lookup>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	89 c2                	mov    %eax,%edx
  801681:	85 c0                	test   %eax,%eax
  801683:	78 65                	js     8016ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168f:	ff 30                	pushl  (%eax)
  801691:	e8 34 fc ff ff       	call   8012ca <dev_lookup>
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 44                	js     8016e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a4:	75 21                	jne    8016c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ab:	8b 40 48             	mov    0x48(%eax),%eax
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	50                   	push   %eax
  8016b3:	68 7c 28 80 00       	push   $0x80287c
  8016b8:	e8 c0 ec ff ff       	call   80037d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c5:	eb 23                	jmp    8016ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ca:	8b 52 18             	mov    0x18(%edx),%edx
  8016cd:	85 d2                	test   %edx,%edx
  8016cf:	74 14                	je     8016e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	ff d2                	call   *%edx
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	eb 09                	jmp    8016ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	eb 05                	jmp    8016ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ea:	89 d0                	mov    %edx,%eax
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 14             	sub    $0x14,%esp
  8016f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 6d fb ff ff       	call   801274 <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 58                	js     801768 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 a9 fb ff ff       	call   8012ca <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 37                	js     80175f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172f:	74 32                	je     801763 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801731:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801734:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173b:	00 00 00 
	stat->st_isdir = 0;
  80173e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801745:	00 00 00 
	stat->st_dev = dev;
  801748:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174e:	83 ec 08             	sub    $0x8,%esp
  801751:	53                   	push   %ebx
  801752:	ff 75 f0             	pushl  -0x10(%ebp)
  801755:	ff 50 14             	call   *0x14(%eax)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	6a 00                	push   $0x0
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 e7 01 00 00       	call   801968 <open>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 db                	test   %ebx,%ebx
  801788:	78 1b                	js     8017a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	53                   	push   %ebx
  801791:	e8 5b ff ff ff       	call   8016f1 <fstat>
  801796:	89 c6                	mov    %eax,%esi
	close(fd);
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 fd fb ff ff       	call   80139d <close>
	return r;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	89 f0                	mov    %esi,%eax
}
  8017a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	89 c6                	mov    %eax,%esi
  8017b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017bc:	75 12                	jne    8017d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	6a 03                	push   $0x3
  8017c3:	e8 69 08 00 00       	call   802031 <ipc_find_env>
  8017c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d0:	6a 07                	push   $0x7
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	56                   	push   %esi
  8017d8:	ff 35 00 40 80 00    	pushl  0x804000
  8017de:	e8 fd 07 00 00       	call   801fe0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	83 c4 0c             	add    $0xc,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	53                   	push   %ebx
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 8a 07 00 00       	call   801f7a <ipc_recv>
}
  8017f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801808:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 02 00 00 00       	mov    $0x2,%eax
  80181a:	e8 8d ff ff ff       	call   8017ac <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	b8 06 00 00 00       	mov    $0x6,%eax
  80183c:	e8 6b ff ff ff       	call   8017ac <fsipc>
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 05 00 00 00       	mov    $0x5,%eax
  801862:	e8 45 ff ff ff       	call   8017ac <fsipc>
  801867:	89 c2                	mov    %eax,%edx
  801869:	85 d2                	test   %edx,%edx
  80186b:	78 2c                	js     801899 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	68 00 50 80 00       	push   $0x805000
  801875:	53                   	push   %ebx
  801876:	e8 86 f0 ff ff       	call   800901 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80187b:	a1 80 50 80 00       	mov    0x805080,%eax
  801880:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801886:	a1 84 50 80 00       	mov    0x805084,%eax
  80188b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8018a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8018aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ad:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8018b3:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8018b8:	76 05                	jbe    8018bf <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8018ba:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8018bf:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	50                   	push   %eax
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	68 08 50 80 00       	push   $0x805008
  8018d0:	e8 be f1 ff ff       	call   800a93 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 04 00 00 00       	mov    $0x4,%eax
  8018df:	e8 c8 fe ff ff       	call   8017ac <fsipc>
	return write;
}
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
  8018eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 03 00 00 00       	mov    $0x3,%eax
  801909:	e8 9e fe ff ff       	call   8017ac <fsipc>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	85 c0                	test   %eax,%eax
  801912:	78 4b                	js     80195f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801914:	39 c6                	cmp    %eax,%esi
  801916:	73 16                	jae    80192e <devfile_read+0x48>
  801918:	68 e8 28 80 00       	push   $0x8028e8
  80191d:	68 ef 28 80 00       	push   $0x8028ef
  801922:	6a 7c                	push   $0x7c
  801924:	68 04 29 80 00       	push   $0x802904
  801929:	e8 76 e9 ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  80192e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801933:	7e 16                	jle    80194b <devfile_read+0x65>
  801935:	68 0f 29 80 00       	push   $0x80290f
  80193a:	68 ef 28 80 00       	push   $0x8028ef
  80193f:	6a 7d                	push   $0x7d
  801941:	68 04 29 80 00       	push   $0x802904
  801946:	e8 59 e9 ff ff       	call   8002a4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	50                   	push   %eax
  80194f:	68 00 50 80 00       	push   $0x805000
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	e8 37 f1 ff ff       	call   800a93 <memmove>
	return r;
  80195c:	83 c4 10             	add    $0x10,%esp
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 20             	sub    $0x20,%esp
  80196f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801972:	53                   	push   %ebx
  801973:	e8 50 ef ff ff       	call   8008c8 <strlen>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801980:	7f 67                	jg     8019e9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801988:	50                   	push   %eax
  801989:	e8 97 f8 ff ff       	call   801225 <fd_alloc>
  80198e:	83 c4 10             	add    $0x10,%esp
		return r;
  801991:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801993:	85 c0                	test   %eax,%eax
  801995:	78 57                	js     8019ee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	53                   	push   %ebx
  80199b:	68 00 50 80 00       	push   $0x805000
  8019a0:	e8 5c ef ff ff       	call   800901 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b5:	e8 f2 fd ff ff       	call   8017ac <fsipc>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	79 14                	jns    8019d7 <open+0x6f>
		fd_close(fd, 0);
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	6a 00                	push   $0x0
  8019c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cb:	e8 4d f9 ff ff       	call   80131d <fd_close>
		return r;
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	89 da                	mov    %ebx,%edx
  8019d5:	eb 17                	jmp    8019ee <open+0x86>
	}

	return fd2num(fd);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 1c f8 ff ff       	call   8011fe <fd2num>
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	eb 05                	jmp    8019ee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ee:	89 d0                	mov    %edx,%eax
  8019f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 08 00 00 00       	mov    $0x8,%eax
  801a05:	e8 a2 fd ff ff       	call   8017ac <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	ff 75 08             	pushl  0x8(%ebp)
  801a1a:	e8 ef f7 ff ff       	call   80120e <fd2data>
  801a1f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a21:	83 c4 08             	add    $0x8,%esp
  801a24:	68 1b 29 80 00       	push   $0x80291b
  801a29:	53                   	push   %ebx
  801a2a:	e8 d2 ee ff ff       	call   800901 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2f:	8b 56 04             	mov    0x4(%esi),%edx
  801a32:	89 d0                	mov    %edx,%eax
  801a34:	2b 06                	sub    (%esi),%eax
  801a36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a43:	00 00 00 
	stat->st_dev = &devpipe;
  801a46:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a4d:	30 80 00 
	return 0;
}
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
  801a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a66:	53                   	push   %ebx
  801a67:	6a 00                	push   $0x0
  801a69:	e8 22 f3 ff ff       	call   800d90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6e:	89 1c 24             	mov    %ebx,(%esp)
  801a71:	e8 98 f7 ff ff       	call   80120e <fd2data>
  801a76:	83 c4 08             	add    $0x8,%esp
  801a79:	50                   	push   %eax
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 0f f3 ff ff       	call   800d90 <sys_page_unmap>
}
  801a81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 1c             	sub    $0x1c,%esp
  801a8f:	89 c7                	mov    %eax,%edi
  801a91:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a93:	a1 04 40 80 00       	mov    0x804004,%eax
  801a98:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	57                   	push   %edi
  801a9f:	e8 c5 05 00 00       	call   802069 <pageref>
  801aa4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa7:	89 34 24             	mov    %esi,(%esp)
  801aaa:	e8 ba 05 00 00       	call   802069 <pageref>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ab5:	0f 94 c0             	sete   %al
  801ab8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801abb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ac1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ac4:	39 cb                	cmp    %ecx,%ebx
  801ac6:	74 15                	je     801add <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801ac8:	8b 52 58             	mov    0x58(%edx),%edx
  801acb:	50                   	push   %eax
  801acc:	52                   	push   %edx
  801acd:	53                   	push   %ebx
  801ace:	68 24 29 80 00       	push   $0x802924
  801ad3:	e8 a5 e8 ff ff       	call   80037d <cprintf>
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	eb b6                	jmp    801a93 <_pipeisclosed+0xd>
	}
}
  801add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5f                   	pop    %edi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 28             	sub    $0x28,%esp
  801aee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af1:	56                   	push   %esi
  801af2:	e8 17 f7 ff ff       	call   80120e <fd2data>
  801af7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	bf 00 00 00 00       	mov    $0x0,%edi
  801b01:	eb 4b                	jmp    801b4e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b03:	89 da                	mov    %ebx,%edx
  801b05:	89 f0                	mov    %esi,%eax
  801b07:	e8 7a ff ff ff       	call   801a86 <_pipeisclosed>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	75 48                	jne    801b58 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b10:	e8 d7 f1 ff ff       	call   800cec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b15:	8b 43 04             	mov    0x4(%ebx),%eax
  801b18:	8b 0b                	mov    (%ebx),%ecx
  801b1a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1d:	39 d0                	cmp    %edx,%eax
  801b1f:	73 e2                	jae    801b03 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b24:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b28:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2b:	89 c2                	mov    %eax,%edx
  801b2d:	c1 fa 1f             	sar    $0x1f,%edx
  801b30:	89 d1                	mov    %edx,%ecx
  801b32:	c1 e9 1b             	shr    $0x1b,%ecx
  801b35:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b38:	83 e2 1f             	and    $0x1f,%edx
  801b3b:	29 ca                	sub    %ecx,%edx
  801b3d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4b:	83 c7 01             	add    $0x1,%edi
  801b4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b51:	75 c2                	jne    801b15 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b53:	8b 45 10             	mov    0x10(%ebp),%eax
  801b56:	eb 05                	jmp    801b5d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	57                   	push   %edi
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 18             	sub    $0x18,%esp
  801b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b71:	57                   	push   %edi
  801b72:	e8 97 f6 ff ff       	call   80120e <fd2data>
  801b77:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b81:	eb 3d                	jmp    801bc0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b83:	85 db                	test   %ebx,%ebx
  801b85:	74 04                	je     801b8b <devpipe_read+0x26>
				return i;
  801b87:	89 d8                	mov    %ebx,%eax
  801b89:	eb 44                	jmp    801bcf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8b:	89 f2                	mov    %esi,%edx
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	e8 f2 fe ff ff       	call   801a86 <_pipeisclosed>
  801b94:	85 c0                	test   %eax,%eax
  801b96:	75 32                	jne    801bca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b98:	e8 4f f1 ff ff       	call   800cec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b9d:	8b 06                	mov    (%esi),%eax
  801b9f:	3b 46 04             	cmp    0x4(%esi),%eax
  801ba2:	74 df                	je     801b83 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba4:	99                   	cltd   
  801ba5:	c1 ea 1b             	shr    $0x1b,%edx
  801ba8:	01 d0                	add    %edx,%eax
  801baa:	83 e0 1f             	and    $0x1f,%eax
  801bad:	29 d0                	sub    %edx,%eax
  801baf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbd:	83 c3 01             	add    $0x1,%ebx
  801bc0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc3:	75 d8                	jne    801b9d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc8:	eb 05                	jmp    801bcf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 3d f6 ff ff       	call   801225 <fd_alloc>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	89 c2                	mov    %eax,%edx
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 2c 01 00 00    	js     801d21 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf5:	83 ec 04             	sub    $0x4,%esp
  801bf8:	68 07 04 00 00       	push   $0x407
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 04 f1 ff ff       	call   800d0b <sys_page_alloc>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 0d 01 00 00    	js     801d21 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	e8 05 f6 ff ff       	call   801225 <fd_alloc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	0f 88 e2 00 00 00    	js     801d0f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	68 07 04 00 00       	push   $0x407
  801c35:	ff 75 f0             	pushl  -0x10(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 cc f0 ff ff       	call   800d0b <sys_page_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 c3 00 00 00    	js     801d0f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	e8 b7 f5 ff ff       	call   80120e <fd2data>
  801c57:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 c4 0c             	add    $0xc,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	50                   	push   %eax
  801c62:	6a 00                	push   $0x0
  801c64:	e8 a2 f0 ff ff       	call   800d0b <sys_page_alloc>
  801c69:	89 c3                	mov    %eax,%ebx
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 89 00 00 00    	js     801cff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7c:	e8 8d f5 ff ff       	call   80120e <fd2data>
  801c81:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c88:	50                   	push   %eax
  801c89:	6a 00                	push   $0x0
  801c8b:	56                   	push   %esi
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 bb f0 ff ff       	call   800d4e <sys_page_map>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 20             	add    $0x20,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 55                	js     801cf1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccc:	e8 2d f5 ff ff       	call   8011fe <fd2num>
  801cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd6:	83 c4 04             	add    $0x4,%esp
  801cd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdc:	e8 1d f5 ff ff       	call   8011fe <fd2num>
  801ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	ba 00 00 00 00       	mov    $0x0,%edx
  801cef:	eb 30                	jmp    801d21 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf1:	83 ec 08             	sub    $0x8,%esp
  801cf4:	56                   	push   %esi
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 94 f0 ff ff       	call   800d90 <sys_page_unmap>
  801cfc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	ff 75 f0             	pushl  -0x10(%ebp)
  801d05:	6a 00                	push   $0x0
  801d07:	e8 84 f0 ff ff       	call   800d90 <sys_page_unmap>
  801d0c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	ff 75 f4             	pushl  -0xc(%ebp)
  801d15:	6a 00                	push   $0x0
  801d17:	e8 74 f0 ff ff       	call   800d90 <sys_page_unmap>
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d21:	89 d0                	mov    %edx,%eax
  801d23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d33:	50                   	push   %eax
  801d34:	ff 75 08             	pushl  0x8(%ebp)
  801d37:	e8 38 f5 ff ff       	call   801274 <fd_lookup>
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 d2                	test   %edx,%edx
  801d43:	78 18                	js     801d5d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4b:	e8 be f4 ff ff       	call   80120e <fd2data>
	return _pipeisclosed(fd, p);
  801d50:	89 c2                	mov    %eax,%edx
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	e8 2c fd ff ff       	call   801a86 <_pipeisclosed>
  801d5a:	83 c4 10             	add    $0x10,%esp
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d6f:	68 55 29 80 00       	push   $0x802955
  801d74:	ff 75 0c             	pushl  0xc(%ebp)
  801d77:	e8 85 eb ff ff       	call   800901 <strcpy>
	return 0;
}
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	57                   	push   %edi
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d94:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9a:	eb 2e                	jmp    801dca <devcons_write+0x47>
		m = n - tot;
  801d9c:	8b 55 10             	mov    0x10(%ebp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801da1:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801da6:	83 fa 7f             	cmp    $0x7f,%edx
  801da9:	77 02                	ja     801dad <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dab:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dad:	83 ec 04             	sub    $0x4,%esp
  801db0:	56                   	push   %esi
  801db1:	03 45 0c             	add    0xc(%ebp),%eax
  801db4:	50                   	push   %eax
  801db5:	57                   	push   %edi
  801db6:	e8 d8 ec ff ff       	call   800a93 <memmove>
		sys_cputs(buf, m);
  801dbb:	83 c4 08             	add    $0x8,%esp
  801dbe:	56                   	push   %esi
  801dbf:	57                   	push   %edi
  801dc0:	e8 8a ee ff ff       	call   800c4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc5:	01 f3                	add    %esi,%ebx
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	89 d8                	mov    %ebx,%eax
  801dcc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dcf:	72 cb                	jb     801d9c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ddf:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801de4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de8:	75 07                	jne    801df1 <devcons_read+0x18>
  801dea:	eb 28                	jmp    801e14 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dec:	e8 fb ee ff ff       	call   800cec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df1:	e8 77 ee ff ff       	call   800c6d <sys_cgetc>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	74 f2                	je     801dec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 16                	js     801e14 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfe:	83 f8 04             	cmp    $0x4,%eax
  801e01:	74 0c                	je     801e0f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e06:	88 02                	mov    %al,(%edx)
	return 1;
  801e08:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0d:	eb 05                	jmp    801e14 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e22:	6a 01                	push   $0x1
  801e24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	e8 22 ee ff ff       	call   800c4f <sys_cputs>
  801e2d:	83 c4 10             	add    $0x10,%esp
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <getchar>:

int
getchar(void)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e38:	6a 01                	push   $0x1
  801e3a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3d:	50                   	push   %eax
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 98 f6 ff ff       	call   8014dd <read>
	if (r < 0)
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 0f                	js     801e5b <getchar+0x29>
		return r;
	if (r < 1)
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	7e 06                	jle    801e56 <getchar+0x24>
		return -E_EOF;
	return c;
  801e50:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e54:	eb 05                	jmp    801e5b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e56:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	ff 75 08             	pushl  0x8(%ebp)
  801e6a:	e8 05 f4 ff ff       	call   801274 <fd_lookup>
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 11                	js     801e87 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7f:	39 10                	cmp    %edx,(%eax)
  801e81:	0f 94 c0             	sete   %al
  801e84:	0f b6 c0             	movzbl %al,%eax
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <opencons>:

int
opencons(void)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	e8 8d f3 ff ff       	call   801225 <fd_alloc>
  801e98:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 3e                	js     801edf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	68 07 04 00 00       	push   $0x407
  801ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eac:	6a 00                	push   $0x0
  801eae:	e8 58 ee ff ff       	call   800d0b <sys_page_alloc>
  801eb3:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 23                	js     801edf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ebc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed1:	83 ec 0c             	sub    $0xc,%esp
  801ed4:	50                   	push   %eax
  801ed5:	e8 24 f3 ff ff       	call   8011fe <fd2num>
  801eda:	89 c2                	mov    %eax,%edx
  801edc:	83 c4 10             	add    $0x10,%esp
}
  801edf:	89 d0                	mov    %edx,%eax
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801ee9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ef0:	75 2c                	jne    801f1e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	6a 07                	push   $0x7
  801ef7:	68 00 f0 7f ee       	push   $0xee7ff000
  801efc:	6a 00                	push   $0x0
  801efe:	e8 08 ee ff ff       	call   800d0b <sys_page_alloc>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	79 14                	jns    801f1e <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	68 64 29 80 00       	push   $0x802964
  801f12:	6a 1f                	push   $0x1f
  801f14:	68 c8 29 80 00       	push   $0x8029c8
  801f19:	e8 86 e3 ff ff       	call   8002a4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f26:	83 ec 08             	sub    $0x8,%esp
  801f29:	68 52 1f 80 00       	push   $0x801f52
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 21 ef ff ff       	call   800e56 <sys_env_set_pgfault_upcall>
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 14                	jns    801f50 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f3c:	83 ec 04             	sub    $0x4,%esp
  801f3f:	68 90 29 80 00       	push   $0x802990
  801f44:	6a 25                	push   $0x25
  801f46:	68 c8 29 80 00       	push   $0x8029c8
  801f4b:	e8 54 e3 ff ff       	call   8002a4 <_panic>
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f52:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f53:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f58:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f5a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801f5d:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801f5f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801f63:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801f67:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801f68:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801f6b:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801f6d:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801f70:	83 c4 04             	add    $0x4,%esp
	popal 
  801f73:	61                   	popa   
	addl $4, %esp 
  801f74:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801f77:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801f78:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801f79:	c3                   	ret    

00801f7a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f88:	85 f6                	test   %esi,%esi
  801f8a:	74 06                	je     801f92 <ipc_recv+0x18>
  801f8c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801f92:	85 db                	test   %ebx,%ebx
  801f94:	74 06                	je     801f9c <ipc_recv+0x22>
  801f96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801f9c:	83 f8 01             	cmp    $0x1,%eax
  801f9f:	19 d2                	sbb    %edx,%edx
  801fa1:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801fa3:	83 ec 0c             	sub    $0xc,%esp
  801fa6:	50                   	push   %eax
  801fa7:	e8 0f ef ff ff       	call   800ebb <sys_ipc_recv>
  801fac:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 d2                	test   %edx,%edx
  801fb3:	75 24                	jne    801fd9 <ipc_recv+0x5f>
	if (from_env_store)
  801fb5:	85 f6                	test   %esi,%esi
  801fb7:	74 0a                	je     801fc3 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801fb9:	a1 04 40 80 00       	mov    0x804004,%eax
  801fbe:	8b 40 70             	mov    0x70(%eax),%eax
  801fc1:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801fc3:	85 db                	test   %ebx,%ebx
  801fc5:	74 0a                	je     801fd1 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801fc7:	a1 04 40 80 00       	mov    0x804004,%eax
  801fcc:	8b 40 74             	mov    0x74(%eax),%eax
  801fcf:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801fd1:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd6:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801fd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fec:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801ff2:	83 fb 01             	cmp    $0x1,%ebx
  801ff5:	19 c0                	sbb    %eax,%eax
  801ff7:	09 c3                	or     %eax,%ebx
  801ff9:	eb 1c                	jmp    802017 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801ffb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ffe:	74 12                	je     802012 <ipc_send+0x32>
  802000:	50                   	push   %eax
  802001:	68 d6 29 80 00       	push   $0x8029d6
  802006:	6a 36                	push   $0x36
  802008:	68 ed 29 80 00       	push   $0x8029ed
  80200d:	e8 92 e2 ff ff       	call   8002a4 <_panic>
		sys_yield();
  802012:	e8 d5 ec ff ff       	call   800cec <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802017:	ff 75 14             	pushl  0x14(%ebp)
  80201a:	53                   	push   %ebx
  80201b:	56                   	push   %esi
  80201c:	57                   	push   %edi
  80201d:	e8 76 ee ff ff       	call   800e98 <sys_ipc_try_send>
		if (ret == 0) break;
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 c0                	test   %eax,%eax
  802027:	75 d2                	jne    801ffb <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802029:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202c:	5b                   	pop    %ebx
  80202d:	5e                   	pop    %esi
  80202e:	5f                   	pop    %edi
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    

00802031 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203c:	6b d0 78             	imul   $0x78,%eax,%edx
  80203f:	83 c2 50             	add    $0x50,%edx
  802042:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802048:	39 ca                	cmp    %ecx,%edx
  80204a:	75 0d                	jne    802059 <ipc_find_env+0x28>
			return envs[i].env_id;
  80204c:	6b c0 78             	imul   $0x78,%eax,%eax
  80204f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802054:	8b 40 08             	mov    0x8(%eax),%eax
  802057:	eb 0e                	jmp    802067 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802059:	83 c0 01             	add    $0x1,%eax
  80205c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802061:	75 d9                	jne    80203c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802063:	66 b8 00 00          	mov    $0x0,%ax
}
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206f:	89 d0                	mov    %edx,%eax
  802071:	c1 e8 16             	shr    $0x16,%eax
  802074:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	f6 c1 01             	test   $0x1,%cl
  802083:	74 1d                	je     8020a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802085:	c1 ea 0c             	shr    $0xc,%edx
  802088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80208f:	f6 c2 01             	test   $0x1,%dl
  802092:	74 0e                	je     8020a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802094:	c1 ea 0c             	shr    $0xc,%edx
  802097:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80209e:	ef 
  80209f:	0f b7 c0             	movzwl %ax,%eax
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	83 ec 10             	sub    $0x10,%esp
  8020b6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020ba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020be:	8b 74 24 24          	mov    0x24(%esp),%esi
  8020c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020c6:	85 d2                	test   %edx,%edx
  8020c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	89 c8                	mov    %ecx,%eax
  8020d1:	75 35                	jne    802108 <__udivdi3+0x58>
  8020d3:	39 f1                	cmp    %esi,%ecx
  8020d5:	0f 87 bd 00 00 00    	ja     802198 <__udivdi3+0xe8>
  8020db:	85 c9                	test   %ecx,%ecx
  8020dd:	89 cd                	mov    %ecx,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f1                	div    %ecx
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 f0                	mov    %esi,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c6                	mov    %eax,%esi
  8020f4:	89 f8                	mov    %edi,%eax
  8020f6:	f7 f5                	div    %ebp
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    
  802101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802108:	3b 14 24             	cmp    (%esp),%edx
  80210b:	77 7b                	ja     802188 <__udivdi3+0xd8>
  80210d:	0f bd f2             	bsr    %edx,%esi
  802110:	83 f6 1f             	xor    $0x1f,%esi
  802113:	0f 84 97 00 00 00    	je     8021b0 <__udivdi3+0x100>
  802119:	bd 20 00 00 00       	mov    $0x20,%ebp
  80211e:	89 d7                	mov    %edx,%edi
  802120:	89 f1                	mov    %esi,%ecx
  802122:	29 f5                	sub    %esi,%ebp
  802124:	d3 e7                	shl    %cl,%edi
  802126:	89 c2                	mov    %eax,%edx
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	d3 ea                	shr    %cl,%edx
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	09 fa                	or     %edi,%edx
  802130:	8b 3c 24             	mov    (%esp),%edi
  802133:	d3 e0                	shl    %cl,%eax
  802135:	89 54 24 08          	mov    %edx,0x8(%esp)
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802143:	89 fa                	mov    %edi,%edx
  802145:	d3 ea                	shr    %cl,%edx
  802147:	89 f1                	mov    %esi,%ecx
  802149:	d3 e7                	shl    %cl,%edi
  80214b:	89 e9                	mov    %ebp,%ecx
  80214d:	d3 e8                	shr    %cl,%eax
  80214f:	09 c7                	or     %eax,%edi
  802151:	89 f8                	mov    %edi,%eax
  802153:	f7 74 24 08          	divl   0x8(%esp)
  802157:	89 d5                	mov    %edx,%ebp
  802159:	89 c7                	mov    %eax,%edi
  80215b:	f7 64 24 0c          	mull   0xc(%esp)
  80215f:	39 d5                	cmp    %edx,%ebp
  802161:	89 14 24             	mov    %edx,(%esp)
  802164:	72 11                	jb     802177 <__udivdi3+0xc7>
  802166:	8b 54 24 04          	mov    0x4(%esp),%edx
  80216a:	89 f1                	mov    %esi,%ecx
  80216c:	d3 e2                	shl    %cl,%edx
  80216e:	39 c2                	cmp    %eax,%edx
  802170:	73 5e                	jae    8021d0 <__udivdi3+0x120>
  802172:	3b 2c 24             	cmp    (%esp),%ebp
  802175:	75 59                	jne    8021d0 <__udivdi3+0x120>
  802177:	8d 47 ff             	lea    -0x1(%edi),%eax
  80217a:	31 f6                	xor    %esi,%esi
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	31 f6                	xor    %esi,%esi
  80218a:	31 c0                	xor    %eax,%eax
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	89 f2                	mov    %esi,%edx
  80219a:	31 f6                	xor    %esi,%esi
  80219c:	89 f8                	mov    %edi,%eax
  80219e:	f7 f1                	div    %ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021b4:	76 0b                	jbe    8021c1 <__udivdi3+0x111>
  8021b6:	31 c0                	xor    %eax,%eax
  8021b8:	3b 14 24             	cmp    (%esp),%edx
  8021bb:	0f 83 37 ff ff ff    	jae    8020f8 <__udivdi3+0x48>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	e9 2d ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021cb:	90                   	nop
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 f8                	mov    %edi,%eax
  8021d2:	31 f6                	xor    %esi,%esi
  8021d4:	e9 1f ff ff ff       	jmp    8020f8 <__udivdi3+0x48>
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	83 ec 20             	sub    $0x20,%esp
  8021e6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f2:	89 c6                	mov    %eax,%esi
  8021f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021f8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021fc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802200:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802204:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802208:	89 74 24 18          	mov    %esi,0x18(%esp)
  80220c:	85 c0                	test   %eax,%eax
  80220e:	89 c2                	mov    %eax,%edx
  802210:	75 1e                	jne    802230 <__umoddi3+0x50>
  802212:	39 f7                	cmp    %esi,%edi
  802214:	76 52                	jbe    802268 <__umoddi3+0x88>
  802216:	89 c8                	mov    %ecx,%eax
  802218:	89 f2                	mov    %esi,%edx
  80221a:	f7 f7                	div    %edi
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	83 c4 20             	add    $0x20,%esp
  802223:	5e                   	pop    %esi
  802224:	5f                   	pop    %edi
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
  802227:	89 f6                	mov    %esi,%esi
  802229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802230:	39 f0                	cmp    %esi,%eax
  802232:	77 5c                	ja     802290 <__umoddi3+0xb0>
  802234:	0f bd e8             	bsr    %eax,%ebp
  802237:	83 f5 1f             	xor    $0x1f,%ebp
  80223a:	75 64                	jne    8022a0 <__umoddi3+0xc0>
  80223c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802240:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802244:	0f 86 f6 00 00 00    	jbe    802340 <__umoddi3+0x160>
  80224a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80224e:	0f 82 ec 00 00 00    	jb     802340 <__umoddi3+0x160>
  802254:	8b 44 24 14          	mov    0x14(%esp),%eax
  802258:	8b 54 24 18          	mov    0x18(%esp),%edx
  80225c:	83 c4 20             	add    $0x20,%esp
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	90                   	nop
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	85 ff                	test   %edi,%edi
  80226a:	89 fd                	mov    %edi,%ebp
  80226c:	75 0b                	jne    802279 <__umoddi3+0x99>
  80226e:	b8 01 00 00 00       	mov    $0x1,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f7                	div    %edi
  802277:	89 c5                	mov    %eax,%ebp
  802279:	8b 44 24 10          	mov    0x10(%esp),%eax
  80227d:	31 d2                	xor    %edx,%edx
  80227f:	f7 f5                	div    %ebp
  802281:	89 c8                	mov    %ecx,%eax
  802283:	f7 f5                	div    %ebp
  802285:	eb 95                	jmp    80221c <__umoddi3+0x3c>
  802287:	89 f6                	mov    %esi,%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 20             	add    $0x20,%esp
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	90                   	nop
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	29 e8                	sub    %ebp,%eax
  8022a9:	d3 e2                	shl    %cl,%edx
  8022ab:	89 c7                	mov    %eax,%edi
  8022ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 c1                	mov    %eax,%ecx
  8022bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022bf:	09 d1                	or     %edx,%ecx
  8022c1:	89 fa                	mov    %edi,%edx
  8022c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022c7:	89 e9                	mov    %ebp,%ecx
  8022c9:	d3 e0                	shl    %cl,%eax
  8022cb:	89 f9                	mov    %edi,%ecx
  8022cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	d3 e8                	shr    %cl,%eax
  8022d5:	89 e9                	mov    %ebp,%ecx
  8022d7:	89 c7                	mov    %eax,%edi
  8022d9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022dd:	d3 e6                	shl    %cl,%esi
  8022df:	89 d1                	mov    %edx,%ecx
  8022e1:	89 fa                	mov    %edi,%edx
  8022e3:	d3 e8                	shr    %cl,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	09 f0                	or     %esi,%eax
  8022e9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022ed:	f7 74 24 10          	divl   0x10(%esp)
  8022f1:	d3 e6                	shl    %cl,%esi
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	f7 64 24 0c          	mull   0xc(%esp)
  8022f9:	39 d1                	cmp    %edx,%ecx
  8022fb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022ff:	89 d7                	mov    %edx,%edi
  802301:	89 c6                	mov    %eax,%esi
  802303:	72 0a                	jb     80230f <__umoddi3+0x12f>
  802305:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802309:	73 10                	jae    80231b <__umoddi3+0x13b>
  80230b:	39 d1                	cmp    %edx,%ecx
  80230d:	75 0c                	jne    80231b <__umoddi3+0x13b>
  80230f:	89 d7                	mov    %edx,%edi
  802311:	89 c6                	mov    %eax,%esi
  802313:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802317:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80231b:	89 ca                	mov    %ecx,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802323:	29 f0                	sub    %esi,%eax
  802325:	19 fa                	sbb    %edi,%edx
  802327:	d3 e8                	shr    %cl,%eax
  802329:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80232e:	89 d7                	mov    %edx,%edi
  802330:	d3 e7                	shl    %cl,%edi
  802332:	89 e9                	mov    %ebp,%ecx
  802334:	09 f8                	or     %edi,%eax
  802336:	d3 ea                	shr    %cl,%edx
  802338:	83 c4 20             	add    $0x20,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
  802340:	8b 74 24 10          	mov    0x10(%esp),%esi
  802344:	29 f9                	sub    %edi,%ecx
  802346:	19 c6                	sbb    %eax,%esi
  802348:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80234c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802350:	e9 ff fe ff ff       	jmp    802254 <__umoddi3+0x74>
