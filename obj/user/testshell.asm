
obj/user/testshell:     file format elf32-i386


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
  80002c:	e8 54 04 00 00       	call   800485 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 31 18 00 00       	call   801880 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 27 18 00 00       	call   801880 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800060:	e8 59 05 00 00       	call   8005be <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 ab 2a 80 00 	movl   $0x802aab,(%esp)
  80006c:	e8 4d 05 00 00       	call   8005be <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 0d 0e 00 00       	call   800e90 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 8c 16 00 00       	call   80171e <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 ba 2a 80 00       	push   $0x802aba
  8000a1:	e8 18 05 00 00       	call   8005be <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d8 0d 00 00       	call   800e90 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 57 16 00 00       	call   80171e <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 b5 2a 80 00       	push   $0x802ab5
  8000d6:	e8 e3 04 00 00       	call   8005be <cprintf>
	exit();
  8000db:	e8 eb 03 00 00       	call   8004cb <exit>
  8000e0:	83 c4 10             	add    $0x10,%esp
}
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 e3 14 00 00       	call   8015de <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 d7 14 00 00       	call   8015de <close>
	opencons();
  800107:	e8 1f 03 00 00       	call   80042b <opencons>
	opencons();
  80010c:	e8 1a 03 00 00       	call   80042b <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 c8 2a 80 00       	push   $0x802ac8
  80011b:	e8 89 1a 00 00       	call   801ba9 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %i", rfd);
  800129:	50                   	push   %eax
  80012a:	68 d5 2a 80 00       	push   $0x802ad5
  80012f:	6a 13                	push   $0x13
  800131:	68 eb 2a 80 00       	push   $0x802aeb
  800136:	e8 aa 03 00 00       	call   8004e5 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 9b 22 00 00       	call   8023e2 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %i", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 fc 2a 80 00       	push   $0x802afc
  800154:	6a 15                	push   $0x15
  800156:	68 eb 2a 80 00       	push   $0x802aeb
  80015b:	e8 85 03 00 00       	call   8004e5 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 64 2a 80 00       	push   $0x802a64
  80016b:	e8 4e 04 00 00       	call   8005be <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 e1 10 00 00       	call   801256 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %i", r);
  80017c:	50                   	push   %eax
  80017d:	68 59 2f 80 00       	push   $0x802f59
  800182:	6a 1a                	push   $0x1a
  800184:	68 eb 2a 80 00       	push   $0x802aeb
  800189:	e8 57 03 00 00       	call   8004e5 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 93 14 00 00       	call   801630 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 88 14 00 00       	call   801630 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 2e 14 00 00       	call   8015de <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 26 14 00 00       	call   8015de <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 05 2b 80 00       	push   $0x802b05
  8001bf:	68 d2 2a 80 00       	push   $0x802ad2
  8001c4:	68 08 2b 80 00       	push   $0x802b08
  8001c9:	e8 d6 1f 00 00       	call   8021a4 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %i", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 0c 2b 80 00       	push   $0x802b0c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 eb 2a 80 00       	push   $0x802aeb
  8001e4:	e8 fc 02 00 00       	call   8004e5 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 eb 13 00 00       	call   8015de <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 df 13 00 00       	call   8015de <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 63 23 00 00       	call   80256a <wait>
		exit();
  800207:	e8 bf 02 00 00       	call   8004cb <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 c6 13 00 00       	call   8015de <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 be 13 00 00       	call   8015de <close>

	rfd = pfds[0];
  800220:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800223:	83 c4 08             	add    $0x8,%esp
  800226:	6a 00                	push   $0x0
  800228:	68 16 2b 80 00       	push   $0x802b16
  80022d:	e8 77 19 00 00       	call   801ba9 <open>
  800232:	89 c6                	mov    %eax,%esi
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	85 c0                	test   %eax,%eax
  800239:	79 12                	jns    80024d <umain+0x162>
		panic("open testshell.key for reading: %i", kfd);
  80023b:	50                   	push   %eax
  80023c:	68 88 2a 80 00       	push   $0x802a88
  800241:	6a 2c                	push   $0x2c
  800243:	68 eb 2a 80 00       	push   $0x802aeb
  800248:	e8 98 02 00 00       	call   8004e5 <_panic>
  80024d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800254:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	57                   	push   %edi
  800265:	e8 b4 14 00 00       	call   80171e <read>
  80026a:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026c:	83 c4 0c             	add    $0xc,%esp
  80026f:	6a 01                	push   $0x1
  800271:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	56                   	push   %esi
  800276:	e8 a3 14 00 00       	call   80171e <read>
		if (n1 < 0)
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	85 db                	test   %ebx,%ebx
  800280:	79 12                	jns    800294 <umain+0x1a9>
			panic("reading testshell.out: %i", n1);
  800282:	53                   	push   %ebx
  800283:	68 24 2b 80 00       	push   $0x802b24
  800288:	6a 33                	push   $0x33
  80028a:	68 eb 2a 80 00       	push   $0x802aeb
  80028f:	e8 51 02 00 00       	call   8004e5 <_panic>
		if (n2 < 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	79 12                	jns    8002aa <umain+0x1bf>
			panic("reading testshell.key: %i", n2);
  800298:	50                   	push   %eax
  800299:	68 3e 2b 80 00       	push   $0x802b3e
  80029e:	6a 35                	push   $0x35
  8002a0:	68 eb 2a 80 00       	push   $0x802aeb
  8002a5:	e8 3b 02 00 00       	call   8004e5 <_panic>
		if (n1 == 0 && n2 == 0)
  8002aa:	89 c2                	mov    %eax,%edx
  8002ac:	09 da                	or     %ebx,%edx
  8002ae:	74 38                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b0:	83 fb 01             	cmp    $0x1,%ebx
  8002b3:	75 0e                	jne    8002c3 <umain+0x1d8>
  8002b5:	83 f8 01             	cmp    $0x1,%eax
  8002b8:	75 09                	jne    8002c3 <umain+0x1d8>
  8002ba:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002be:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c1:	74 10                	je     8002d3 <umain+0x1e8>
			wrong(rfd, kfd, nloff);
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c9:	56                   	push   %esi
  8002ca:	57                   	push   %edi
  8002cb:	e8 63 fd ff ff       	call   800033 <wrong>
  8002d0:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
  8002d3:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002d7:	75 06                	jne    8002df <umain+0x1f4>
			nloff = off+1;
  8002d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002df:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 58 2b 80 00       	push   $0x802b58
  8002f0:	e8 c9 02 00 00       	call   8005be <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   
  8002f6:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 6d 2b 80 00       	push   $0x802b6d
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2e                	jmp    80036c <devcons_write+0x47>
		m = n - tot;
  80033e:	8b 55 10             	mov    0x10(%ebp),%edx
  800341:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800343:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800348:	83 fa 7f             	cmp    $0x7f,%edx
  80034b:	77 02                	ja     80034f <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80034d:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	56                   	push   %esi
  800353:	03 45 0c             	add    0xc(%ebp),%eax
  800356:	50                   	push   %eax
  800357:	57                   	push   %edi
  800358:	e8 77 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035d:	83 c4 08             	add    $0x8,%esp
  800360:	56                   	push   %esi
  800361:	57                   	push   %edi
  800362:	e8 29 0b 00 00       	call   800e90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800367:	01 f3                	add    %esi,%ebx
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	89 d8                	mov    %ebx,%eax
  80036e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800371:	72 cb                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80038a:	75 07                	jne    800393 <devcons_read+0x18>
  80038c:	eb 28                	jmp    8003b6 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038e:	e8 9a 0b 00 00       	call   800f2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800393:	e8 16 0b 00 00       	call   800eae <sys_cgetc>
  800398:	85 c0                	test   %eax,%eax
  80039a:	74 f2                	je     80038e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039c:	85 c0                	test   %eax,%eax
  80039e:	78 16                	js     8003b6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8003a0:	83 f8 04             	cmp    $0x4,%eax
  8003a3:	74 0c                	je     8003b1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a8:	88 02                	mov    %al,(%edx)
	return 1;
  8003aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8003af:	eb 05                	jmp    8003b6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    

008003b8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c4:	6a 01                	push   $0x1
  8003c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c9:	50                   	push   %eax
  8003ca:	e8 c1 0a 00 00       	call   800e90 <sys_cputs>
  8003cf:	83 c4 10             	add    $0x10,%esp
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <getchar>:

int
getchar(void)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003da:	6a 01                	push   $0x1
  8003dc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003df:	50                   	push   %eax
  8003e0:	6a 00                	push   $0x0
  8003e2:	e8 37 13 00 00       	call   80171e <read>
	if (r < 0)
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	78 0f                	js     8003fd <getchar+0x29>
		return r;
	if (r < 1)
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	7e 06                	jle    8003f8 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f6:	eb 05                	jmp    8003fd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	ff 75 08             	pushl  0x8(%ebp)
  80040c:	e8 a4 10 00 00       	call   8014b5 <fd_lookup>
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	85 c0                	test   %eax,%eax
  800416:	78 11                	js     800429 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800418:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800421:	39 10                	cmp    %edx,(%eax)
  800423:	0f 94 c0             	sete   %al
  800426:	0f b6 c0             	movzbl %al,%eax
}
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <opencons>:

int
opencons(void)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800434:	50                   	push   %eax
  800435:	e8 2c 10 00 00       	call   801466 <fd_alloc>
  80043a:	83 c4 10             	add    $0x10,%esp
		return r;
  80043d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043f:	85 c0                	test   %eax,%eax
  800441:	78 3e                	js     800481 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	68 07 04 00 00       	push   $0x407
  80044b:	ff 75 f4             	pushl  -0xc(%ebp)
  80044e:	6a 00                	push   $0x0
  800450:	e8 f7 0a 00 00       	call   800f4c <sys_page_alloc>
  800455:	83 c4 10             	add    $0x10,%esp
		return r;
  800458:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80045a:	85 c0                	test   %eax,%eax
  80045c:	78 23                	js     800481 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800467:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	50                   	push   %eax
  800477:	e8 c3 0f 00 00       	call   80143f <fd2num>
  80047c:	89 c2                	mov    %eax,%edx
  80047e:	83 c4 10             	add    $0x10,%esp
}
  800481:	89 d0                	mov    %edx,%eax
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800490:	e8 79 0a 00 00       	call   800f0e <sys_getenvid>
  800495:	25 ff 03 00 00       	and    $0x3ff,%eax
  80049a:	6b c0 78             	imul   $0x78,%eax,%eax
  80049d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a2:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a7:	85 db                	test   %ebx,%ebx
  8004a9:	7e 07                	jle    8004b2 <libmain+0x2d>
		binaryname = argv[0];
  8004ab:	8b 06                	mov    (%esi),%eax
  8004ad:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	e8 2f fc ff ff       	call   8000eb <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8004bc:	e8 0a 00 00 00       	call   8004cb <exit>
  8004c1:	83 c4 10             	add    $0x10,%esp
#endif
}
  8004c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c7:	5b                   	pop    %ebx
  8004c8:	5e                   	pop    %esi
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d1:	e8 35 11 00 00       	call   80160b <close_all>
	sys_env_destroy(0);
  8004d6:	83 ec 0c             	sub    $0xc,%esp
  8004d9:	6a 00                	push   $0x0
  8004db:	e8 ed 09 00 00       	call   800ecd <sys_env_destroy>
  8004e0:	83 c4 10             	add    $0x10,%esp
}
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	56                   	push   %esi
  8004e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ed:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f3:	e8 16 0a 00 00       	call   800f0e <sys_getenvid>
  8004f8:	83 ec 0c             	sub    $0xc,%esp
  8004fb:	ff 75 0c             	pushl  0xc(%ebp)
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	56                   	push   %esi
  800502:	50                   	push   %eax
  800503:	68 84 2b 80 00       	push   $0x802b84
  800508:	e8 b1 00 00 00       	call   8005be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050d:	83 c4 18             	add    $0x18,%esp
  800510:	53                   	push   %ebx
  800511:	ff 75 10             	pushl  0x10(%ebp)
  800514:	e8 54 00 00 00       	call   80056d <vcprintf>
	cprintf("\n");
  800519:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  800520:	e8 99 00 00 00       	call   8005be <cprintf>
  800525:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800528:	cc                   	int3   
  800529:	eb fd                	jmp    800528 <_panic+0x43>

0080052b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	53                   	push   %ebx
  80052f:	83 ec 04             	sub    $0x4,%esp
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800535:	8b 13                	mov    (%ebx),%edx
  800537:	8d 42 01             	lea    0x1(%edx),%eax
  80053a:	89 03                	mov    %eax,(%ebx)
  80053c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800543:	3d ff 00 00 00       	cmp    $0xff,%eax
  800548:	75 1a                	jne    800564 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	68 ff 00 00 00       	push   $0xff
  800552:	8d 43 08             	lea    0x8(%ebx),%eax
  800555:	50                   	push   %eax
  800556:	e8 35 09 00 00       	call   800e90 <sys_cputs>
		b->idx = 0;
  80055b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800561:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800564:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800576:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057d:	00 00 00 
	b.cnt = 0;
  800580:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800587:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058a:	ff 75 0c             	pushl  0xc(%ebp)
  80058d:	ff 75 08             	pushl  0x8(%ebp)
  800590:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800596:	50                   	push   %eax
  800597:	68 2b 05 80 00       	push   $0x80052b
  80059c:	e8 4f 01 00 00       	call   8006f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a1:	83 c4 08             	add    $0x8,%esp
  8005a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b0:	50                   	push   %eax
  8005b1:	e8 da 08 00 00       	call   800e90 <sys_cputs>

	return b.cnt;
}
  8005b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bc:	c9                   	leave  
  8005bd:	c3                   	ret    

008005be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c7:	50                   	push   %eax
  8005c8:	ff 75 08             	pushl  0x8(%ebp)
  8005cb:	e8 9d ff ff ff       	call   80056d <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d0:	c9                   	leave  
  8005d1:	c3                   	ret    

008005d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	57                   	push   %edi
  8005d6:	56                   	push   %esi
  8005d7:	53                   	push   %ebx
  8005d8:	83 ec 1c             	sub    $0x1c,%esp
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	89 d6                	mov    %edx,%esi
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e5:	89 d1                	mov    %edx,%ecx
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005fd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800600:	72 05                	jb     800607 <printnum+0x35>
  800602:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800605:	77 3e                	ja     800645 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	ff 75 18             	pushl  0x18(%ebp)
  80060d:	83 eb 01             	sub    $0x1,%ebx
  800610:	53                   	push   %ebx
  800611:	50                   	push   %eax
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	ff 75 e4             	pushl  -0x1c(%ebp)
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff 75 dc             	pushl  -0x24(%ebp)
  80061e:	ff 75 d8             	pushl  -0x28(%ebp)
  800621:	e8 6a 21 00 00       	call   802790 <__udivdi3>
  800626:	83 c4 18             	add    $0x18,%esp
  800629:	52                   	push   %edx
  80062a:	50                   	push   %eax
  80062b:	89 f2                	mov    %esi,%edx
  80062d:	89 f8                	mov    %edi,%eax
  80062f:	e8 9e ff ff ff       	call   8005d2 <printnum>
  800634:	83 c4 20             	add    $0x20,%esp
  800637:	eb 13                	jmp    80064c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	56                   	push   %esi
  80063d:	ff 75 18             	pushl  0x18(%ebp)
  800640:	ff d7                	call   *%edi
  800642:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800645:	83 eb 01             	sub    $0x1,%ebx
  800648:	85 db                	test   %ebx,%ebx
  80064a:	7f ed                	jg     800639 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	56                   	push   %esi
  800650:	83 ec 04             	sub    $0x4,%esp
  800653:	ff 75 e4             	pushl  -0x1c(%ebp)
  800656:	ff 75 e0             	pushl  -0x20(%ebp)
  800659:	ff 75 dc             	pushl  -0x24(%ebp)
  80065c:	ff 75 d8             	pushl  -0x28(%ebp)
  80065f:	e8 5c 22 00 00       	call   8028c0 <__umoddi3>
  800664:	83 c4 14             	add    $0x14,%esp
  800667:	0f be 80 a7 2b 80 00 	movsbl 0x802ba7(%eax),%eax
  80066e:	50                   	push   %eax
  80066f:	ff d7                	call   *%edi
  800671:	83 c4 10             	add    $0x10,%esp
}
  800674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800677:	5b                   	pop    %ebx
  800678:	5e                   	pop    %esi
  800679:	5f                   	pop    %edi
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067f:	83 fa 01             	cmp    $0x1,%edx
  800682:	7e 0e                	jle    800692 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800684:	8b 10                	mov    (%eax),%edx
  800686:	8d 4a 08             	lea    0x8(%edx),%ecx
  800689:	89 08                	mov    %ecx,(%eax)
  80068b:	8b 02                	mov    (%edx),%eax
  80068d:	8b 52 04             	mov    0x4(%edx),%edx
  800690:	eb 22                	jmp    8006b4 <getuint+0x38>
	else if (lflag)
  800692:	85 d2                	test   %edx,%edx
  800694:	74 10                	je     8006a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800696:	8b 10                	mov    (%eax),%edx
  800698:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069b:	89 08                	mov    %ecx,(%eax)
  80069d:	8b 02                	mov    (%edx),%eax
  80069f:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a4:	eb 0e                	jmp    8006b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ab:	89 08                	mov    %ecx,(%eax)
  8006ad:	8b 02                	mov    (%edx),%eax
  8006af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c5:	73 0a                	jae    8006d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ca:	89 08                	mov    %ecx,(%eax)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	88 02                	mov    %al,(%edx)
}
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006dc:	50                   	push   %eax
  8006dd:	ff 75 10             	pushl  0x10(%ebp)
  8006e0:	ff 75 0c             	pushl  0xc(%ebp)
  8006e3:	ff 75 08             	pushl  0x8(%ebp)
  8006e6:	e8 05 00 00 00       	call   8006f0 <vprintfmt>
	va_end(ap);
  8006eb:	83 c4 10             	add    $0x10,%esp
}
  8006ee:	c9                   	leave  
  8006ef:	c3                   	ret    

008006f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	57                   	push   %edi
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 2c             	sub    $0x2c,%esp
  8006f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  800702:	eb 12                	jmp    800716 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800704:	85 c0                	test   %eax,%eax
  800706:	0f 84 8d 03 00 00    	je     800a99 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	50                   	push   %eax
  800711:	ff d6                	call   *%esi
  800713:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800716:	83 c7 01             	add    $0x1,%edi
  800719:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071d:	83 f8 25             	cmp    $0x25,%eax
  800720:	75 e2                	jne    800704 <vprintfmt+0x14>
  800722:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800726:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80072d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800734:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073b:	ba 00 00 00 00       	mov    $0x0,%edx
  800740:	eb 07                	jmp    800749 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800745:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8d 47 01             	lea    0x1(%edi),%eax
  80074c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074f:	0f b6 07             	movzbl (%edi),%eax
  800752:	0f b6 c8             	movzbl %al,%ecx
  800755:	83 e8 23             	sub    $0x23,%eax
  800758:	3c 55                	cmp    $0x55,%al
  80075a:	0f 87 1e 03 00 00    	ja     800a7e <vprintfmt+0x38e>
  800760:	0f b6 c0             	movzbl %al,%eax
  800763:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80076d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800771:	eb d6                	jmp    800749 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800781:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800785:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800788:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078b:	83 fa 09             	cmp    $0x9,%edx
  80078e:	77 38                	ja     8007c8 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800790:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800793:	eb e9                	jmp    80077e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 48 04             	lea    0x4(%eax),%ecx
  80079b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a6:	eb 26                	jmp    8007ce <vprintfmt+0xde>
  8007a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007ab:	89 c8                	mov    %ecx,%eax
  8007ad:	c1 f8 1f             	sar    $0x1f,%eax
  8007b0:	f7 d0                	not    %eax
  8007b2:	21 c1                	and    %eax,%ecx
  8007b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ba:	eb 8d                	jmp    800749 <vprintfmt+0x59>
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007c6:	eb 81                	jmp    800749 <vprintfmt+0x59>
  8007c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d2:	0f 89 71 ff ff ff    	jns    800749 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007e5:	e9 5f ff ff ff       	jmp    800749 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f0:	e9 54 ff ff ff       	jmp    800749 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	ff 30                	pushl  (%eax)
  800804:	ff d6                	call   *%esi
			break;
  800806:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80080c:	e9 05 ff ff ff       	jmp    800716 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	99                   	cltd   
  80081d:	31 d0                	xor    %edx,%eax
  80081f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800821:	83 f8 0f             	cmp    $0xf,%eax
  800824:	7f 0b                	jg     800831 <vprintfmt+0x141>
  800826:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  80082d:	85 d2                	test   %edx,%edx
  80082f:	75 18                	jne    800849 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800831:	50                   	push   %eax
  800832:	68 bf 2b 80 00       	push   $0x802bbf
  800837:	53                   	push   %ebx
  800838:	56                   	push   %esi
  800839:	e8 95 fe ff ff       	call   8006d3 <printfmt>
  80083e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800844:	e9 cd fe ff ff       	jmp    800716 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800849:	52                   	push   %edx
  80084a:	68 41 30 80 00       	push   $0x803041
  80084f:	53                   	push   %ebx
  800850:	56                   	push   %esi
  800851:	e8 7d fe ff ff       	call   8006d3 <printfmt>
  800856:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085c:	e9 b5 fe ff ff       	jmp    800716 <vprintfmt+0x26>
  800861:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800864:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800867:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 38                	mov    (%eax),%edi
  800875:	85 ff                	test   %edi,%edi
  800877:	75 05                	jne    80087e <vprintfmt+0x18e>
				p = "(null)";
  800879:	bf b8 2b 80 00       	mov    $0x802bb8,%edi
			if (width > 0 && padc != '-')
  80087e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800882:	0f 84 91 00 00 00    	je     800919 <vprintfmt+0x229>
  800888:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80088c:	0f 8e 95 00 00 00    	jle    800927 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	51                   	push   %ecx
  800896:	57                   	push   %edi
  800897:	e8 85 02 00 00       	call   800b21 <strnlen>
  80089c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80089f:	29 c1                	sub    %eax,%ecx
  8008a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b3:	eb 0f                	jmp    8008c4 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008be:	83 ef 01             	sub    $0x1,%edi
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	85 ff                	test   %edi,%edi
  8008c6:	7f ed                	jg     8008b5 <vprintfmt+0x1c5>
  8008c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008ce:	89 c8                	mov    %ecx,%eax
  8008d0:	c1 f8 1f             	sar    $0x1f,%eax
  8008d3:	f7 d0                	not    %eax
  8008d5:	21 c8                	and    %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x217>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x217>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x243>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x243>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x274>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f6>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f6>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x27c>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 9e fd ff ff       	jmp    800716 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d5>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x35a>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 7f fc ff ff       	call   80067c <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 70 fc ff ff       	call   80067c <getuint>
			base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 37 fc ff ff       	call   80067c <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 71 fb ff ff       	call   8005d2 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 aa fc ff ff       	jmp    800716 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 98 fc ff ff       	jmp    800716 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39e>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x39b>
  800a94:	e9 7d fc ff ff       	jmp    800716 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 b6 06 80 00       	push   $0x8006b6
  800ad5:	e8 16 fc ff ff       	call   8006f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	84 d2                	test   %dl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	38 ca                	cmp    %cl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
  800cbb:	89 d0                	mov    %edx,%eax
  800cbd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d96:	eb 07                	jmp    800d9f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d98:	38 08                	cmp    %cl,(%eax)
  800d9a:	74 07                	je     800da3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d9c:	83 c0 01             	add    $0x1,%eax
  800d9f:	39 d0                	cmp    %edx,%eax
  800da1:	72 f5                	jb     800d98 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db1:	eb 03                	jmp    800db6 <strtol+0x11>
		s++;
  800db3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db6:	0f b6 01             	movzbl (%ecx),%eax
  800db9:	3c 09                	cmp    $0x9,%al
  800dbb:	74 f6                	je     800db3 <strtol+0xe>
  800dbd:	3c 20                	cmp    $0x20,%al
  800dbf:	74 f2                	je     800db3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc1:	3c 2b                	cmp    $0x2b,%al
  800dc3:	75 0a                	jne    800dcf <strtol+0x2a>
		s++;
  800dc5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800dcd:	eb 10                	jmp    800ddf <strtol+0x3a>
  800dcf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dd4:	3c 2d                	cmp    $0x2d,%al
  800dd6:	75 07                	jne    800ddf <strtol+0x3a>
		s++, neg = 1;
  800dd8:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ddb:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ddf:	85 db                	test   %ebx,%ebx
  800de1:	0f 94 c0             	sete   %al
  800de4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dea:	75 19                	jne    800e05 <strtol+0x60>
  800dec:	80 39 30             	cmpb   $0x30,(%ecx)
  800def:	75 14                	jne    800e05 <strtol+0x60>
  800df1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df5:	0f 85 8a 00 00 00    	jne    800e85 <strtol+0xe0>
		s += 2, base = 16;
  800dfb:	83 c1 02             	add    $0x2,%ecx
  800dfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e03:	eb 16                	jmp    800e1b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e05:	84 c0                	test   %al,%al
  800e07:	74 12                	je     800e1b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800e11:	75 08                	jne    800e1b <strtol+0x76>
		s++, base = 8;
  800e13:	83 c1 01             	add    $0x1,%ecx
  800e16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e23:	0f b6 11             	movzbl (%ecx),%edx
  800e26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e29:	89 f3                	mov    %esi,%ebx
  800e2b:	80 fb 09             	cmp    $0x9,%bl
  800e2e:	77 08                	ja     800e38 <strtol+0x93>
			dig = *s - '0';
  800e30:	0f be d2             	movsbl %dl,%edx
  800e33:	83 ea 30             	sub    $0x30,%edx
  800e36:	eb 22                	jmp    800e5a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800e38:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e3b:	89 f3                	mov    %esi,%ebx
  800e3d:	80 fb 19             	cmp    $0x19,%bl
  800e40:	77 08                	ja     800e4a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800e42:	0f be d2             	movsbl %dl,%edx
  800e45:	83 ea 57             	sub    $0x57,%edx
  800e48:	eb 10                	jmp    800e5a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800e4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4d:	89 f3                	mov    %esi,%ebx
  800e4f:	80 fb 19             	cmp    $0x19,%bl
  800e52:	77 16                	ja     800e6a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e54:	0f be d2             	movsbl %dl,%edx
  800e57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5d:	7d 0f                	jge    800e6e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800e5f:	83 c1 01             	add    $0x1,%ecx
  800e62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e68:	eb b9                	jmp    800e23 <strtol+0x7e>
  800e6a:	89 c2                	mov    %eax,%edx
  800e6c:	eb 02                	jmp    800e70 <strtol+0xcb>
  800e6e:	89 c2                	mov    %eax,%edx

	if (endptr)
  800e70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e74:	74 05                	je     800e7b <strtol+0xd6>
		*endptr = (char *) s;
  800e76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e79:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	74 0c                	je     800e8b <strtol+0xe6>
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	f7 d8                	neg    %eax
  800e83:	eb 06                	jmp    800e8b <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e85:	84 c0                	test   %al,%al
  800e87:	75 8a                	jne    800e13 <strtol+0x6e>
  800e89:	eb 90                	jmp    800e1b <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	89 c7                	mov    %eax,%edi
  800ea5:	89 c6                	mov    %eax,%esi
  800ea7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_cgetc>:

int
sys_cgetc(void)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebe:	89 d1                	mov    %edx,%ecx
  800ec0:	89 d3                	mov    %edx,%ebx
  800ec2:	89 d7                	mov    %edx,%edi
  800ec4:	89 d6                	mov    %edx,%esi
  800ec6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	89 cb                	mov    %ecx,%ebx
  800ee5:	89 cf                	mov    %ecx,%edi
  800ee7:	89 ce                	mov    %ecx,%esi
  800ee9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	7e 17                	jle    800f06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	50                   	push   %eax
  800ef3:	6a 03                	push   $0x3
  800ef5:	68 df 2e 80 00       	push   $0x802edf
  800efa:	6a 23                	push   $0x23
  800efc:	68 fc 2e 80 00       	push   $0x802efc
  800f01:	e8 df f5 ff ff       	call   8004e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f14:	ba 00 00 00 00       	mov    $0x0,%edx
  800f19:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1e:	89 d1                	mov    %edx,%ecx
  800f20:	89 d3                	mov    %edx,%ebx
  800f22:	89 d7                	mov    %edx,%edi
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_yield>:

void
sys_yield(void)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 d3                	mov    %edx,%ebx
  800f41:	89 d7                	mov    %edx,%edi
  800f43:	89 d6                	mov    %edx,%esi
  800f45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	be 00 00 00 00       	mov    $0x0,%esi
  800f5a:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f68:	89 f7                	mov    %esi,%edi
  800f6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	7e 17                	jle    800f87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	50                   	push   %eax
  800f74:	6a 04                	push   $0x4
  800f76:	68 df 2e 80 00       	push   $0x802edf
  800f7b:	6a 23                	push   $0x23
  800f7d:	68 fc 2e 80 00       	push   $0x802efc
  800f82:	e8 5e f5 ff ff       	call   8004e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
  800f95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f98:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa9:	8b 75 18             	mov    0x18(%ebp),%esi
  800fac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 17                	jle    800fc9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	50                   	push   %eax
  800fb6:	6a 05                	push   $0x5
  800fb8:	68 df 2e 80 00       	push   $0x802edf
  800fbd:	6a 23                	push   $0x23
  800fbf:	68 fc 2e 80 00       	push   $0x802efc
  800fc4:	e8 1c f5 ff ff       	call   8004e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	89 df                	mov    %ebx,%edi
  800fec:	89 de                	mov    %ebx,%esi
  800fee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 17                	jle    80100b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	50                   	push   %eax
  800ff8:	6a 06                	push   $0x6
  800ffa:	68 df 2e 80 00       	push   $0x802edf
  800fff:	6a 23                	push   $0x23
  801001:	68 fc 2e 80 00       	push   $0x802efc
  801006:	e8 da f4 ff ff       	call   8004e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80100b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801021:	b8 08 00 00 00       	mov    $0x8,%eax
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	89 df                	mov    %ebx,%edi
  80102e:	89 de                	mov    %ebx,%esi
  801030:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	7e 17                	jle    80104d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	50                   	push   %eax
  80103a:	6a 08                	push   $0x8
  80103c:	68 df 2e 80 00       	push   $0x802edf
  801041:	6a 23                	push   $0x23
  801043:	68 fc 2e 80 00       	push   $0x802efc
  801048:	e8 98 f4 ff ff       	call   8004e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80104d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801063:	b8 09 00 00 00       	mov    $0x9,%eax
  801068:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	89 df                	mov    %ebx,%edi
  801070:	89 de                	mov    %ebx,%esi
  801072:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801074:	85 c0                	test   %eax,%eax
  801076:	7e 17                	jle    80108f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	50                   	push   %eax
  80107c:	6a 09                	push   $0x9
  80107e:	68 df 2e 80 00       	push   $0x802edf
  801083:	6a 23                	push   $0x23
  801085:	68 fc 2e 80 00       	push   $0x802efc
  80108a:	e8 56 f4 ff ff       	call   8004e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80108f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b0:	89 df                	mov    %ebx,%edi
  8010b2:	89 de                	mov    %ebx,%esi
  8010b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	7e 17                	jle    8010d1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	50                   	push   %eax
  8010be:	6a 0a                	push   $0xa
  8010c0:	68 df 2e 80 00       	push   $0x802edf
  8010c5:	6a 23                	push   $0x23
  8010c7:	68 fc 2e 80 00       	push   $0x802efc
  8010cc:	e8 14 f4 ff ff       	call   8004e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010df:	be 00 00 00 00       	mov    $0x0,%esi
  8010e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801105:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	89 cb                	mov    %ecx,%ebx
  801114:	89 cf                	mov    %ecx,%edi
  801116:	89 ce                	mov    %ecx,%esi
  801118:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	7e 17                	jle    801135 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 0d                	push   $0xd
  801124:	68 df 2e 80 00       	push   $0x802edf
  801129:	6a 23                	push   $0x23
  80112b:	68 fc 2e 80 00       	push   $0x802efc
  801130:	e8 b0 f3 ff ff       	call   8004e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_gettime>:

int sys_gettime(void)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	ba 00 00 00 00       	mov    $0x0,%edx
  801148:	b8 0e 00 00 00       	mov    $0xe,%eax
  80114d:	89 d1                	mov    %edx,%ecx
  80114f:	89 d3                	mov    %edx,%ebx
  801151:	89 d7                	mov    %edx,%edi
  801153:	89 d6                	mov    %edx,%esi
  801155:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	53                   	push   %ebx
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  801166:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  801168:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80116c:	74 2e                	je     80119c <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  80116e:	89 c2                	mov    %eax,%edx
  801170:	c1 ea 16             	shr    $0x16,%edx
  801173:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	74 1d                	je     80119c <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 0c             	shr    $0xc,%edx
  801184:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  80118b:	f6 c1 01             	test   $0x1,%cl
  80118e:	74 0c                	je     80119c <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  801197:	f6 c6 08             	test   $0x8,%dh
  80119a:	75 14                	jne    8011b0 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	68 0a 2f 80 00       	push   $0x802f0a
  8011a4:	6a 28                	push   $0x28
  8011a6:	68 1c 2f 80 00       	push   $0x802f1c
  8011ab:	e8 35 f3 ff ff       	call   8004e5 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  8011b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b5:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	6a 07                	push   $0x7
  8011bc:	68 00 f0 7f 00       	push   $0x7ff000
  8011c1:	6a 00                	push   $0x0
  8011c3:	e8 84 fd ff ff       	call   800f4c <sys_page_alloc>
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	79 14                	jns    8011e3 <pgfault+0x87>
		panic("sys_page_alloc");
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	68 27 2f 80 00       	push   $0x802f27
  8011d7:	6a 2c                	push   $0x2c
  8011d9:	68 1c 2f 80 00       	push   $0x802f1c
  8011de:	e8 02 f3 ff ff       	call   8004e5 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	68 00 10 00 00       	push   $0x1000
  8011eb:	53                   	push   %ebx
  8011ec:	68 00 f0 7f 00       	push   $0x7ff000
  8011f1:	e8 46 fb ff ff       	call   800d3c <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  8011f6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011fd:	53                   	push   %ebx
  8011fe:	6a 00                	push   $0x0
  801200:	68 00 f0 7f 00       	push   $0x7ff000
  801205:	6a 00                	push   $0x0
  801207:	e8 83 fd ff ff       	call   800f8f <sys_page_map>
  80120c:	83 c4 20             	add    $0x20,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	79 14                	jns    801227 <pgfault+0xcb>
		panic("sys_page_map");
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	68 36 2f 80 00       	push   $0x802f36
  80121b:	6a 2f                	push   $0x2f
  80121d:	68 1c 2f 80 00       	push   $0x802f1c
  801222:	e8 be f2 ff ff       	call   8004e5 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	68 00 f0 7f 00       	push   $0x7ff000
  80122f:	6a 00                	push   $0x0
  801231:	e8 9b fd ff ff       	call   800fd1 <sys_page_unmap>
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	79 14                	jns    801251 <pgfault+0xf5>
		panic("sys_page_unmap");
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	68 43 2f 80 00       	push   $0x802f43
  801245:	6a 31                	push   $0x31
  801247:	68 1c 2f 80 00       	push   $0x802f1c
  80124c:	e8 94 f2 ff ff       	call   8004e5 <_panic>
	return;
}
  801251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  80125f:	68 5c 11 80 00       	push   $0x80115c
  801264:	e8 5b 13 00 00       	call   8025c4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801269:	b8 07 00 00 00       	mov    $0x7,%eax
  80126e:	cd 30                	int    $0x30
  801270:	89 c7                	mov    %eax,%edi
  801272:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	75 21                	jne    80129d <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  80127c:	e8 8d fc ff ff       	call   800f0e <sys_getenvid>
  801281:	25 ff 03 00 00       	and    $0x3ff,%eax
  801286:	6b c0 78             	imul   $0x78,%eax,%eax
  801289:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80128e:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	e9 80 01 00 00       	jmp    80141d <fork+0x1c7>
	}
	if (envid < 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 12                	jns    8012b3 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  8012a1:	50                   	push   %eax
  8012a2:	68 52 2f 80 00       	push   $0x802f52
  8012a7:	6a 70                	push   $0x70
  8012a9:	68 1c 2f 80 00       	push   $0x802f1c
  8012ae:	e8 32 f2 ff ff       	call   8004e5 <_panic>
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	c1 e8 16             	shr    $0x16,%eax
  8012bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c4:	a8 01                	test   $0x1,%al
  8012c6:	0f 84 de 00 00 00    	je     8013aa <fork+0x154>
  8012cc:	89 de                	mov    %ebx,%esi
  8012ce:	c1 ee 0c             	shr    $0xc,%esi
  8012d1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012d8:	a8 01                	test   $0x1,%al
  8012da:	0f 84 ca 00 00 00    	je     8013aa <fork+0x154>
  8012e0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012e7:	a8 04                	test   $0x4,%al
  8012e9:	0f 84 bb 00 00 00    	je     8013aa <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  8012ef:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  8012f6:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  8012f9:	f6 c4 04             	test   $0x4,%ah
  8012fc:	74 34                	je     801332 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	25 07 0e 00 00       	and    $0xe07,%eax
  801306:	50                   	push   %eax
  801307:	56                   	push   %esi
  801308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80130b:	56                   	push   %esi
  80130c:	6a 00                	push   $0x0
  80130e:	e8 7c fc ff ff       	call   800f8f <sys_page_map>
  801313:	83 c4 20             	add    $0x20,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	0f 84 8c 00 00 00    	je     8013aa <fork+0x154>
        	panic("duppage share");
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	68 62 2f 80 00       	push   $0x802f62
  801326:	6a 48                	push   $0x48
  801328:	68 1c 2f 80 00       	push   $0x802f1c
  80132d:	e8 b3 f1 ff ff       	call   8004e5 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801332:	a9 02 08 00 00       	test   $0x802,%eax
  801337:	74 5d                	je     801396 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	68 05 08 00 00       	push   $0x805
  801341:	56                   	push   %esi
  801342:	ff 75 e4             	pushl  -0x1c(%ebp)
  801345:	56                   	push   %esi
  801346:	6a 00                	push   $0x0
  801348:	e8 42 fc ff ff       	call   800f8f <sys_page_map>
  80134d:	83 c4 20             	add    $0x20,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	79 14                	jns    801368 <fork+0x112>
			panic("error");
  801354:	83 ec 04             	sub    $0x4,%esp
  801357:	68 d4 2b 80 00       	push   $0x802bd4
  80135c:	6a 4b                	push   $0x4b
  80135e:	68 1c 2f 80 00       	push   $0x802f1c
  801363:	e8 7d f1 ff ff       	call   8004e5 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	68 05 08 00 00       	push   $0x805
  801370:	56                   	push   %esi
  801371:	6a 00                	push   $0x0
  801373:	56                   	push   %esi
  801374:	6a 00                	push   $0x0
  801376:	e8 14 fc ff ff       	call   800f8f <sys_page_map>
  80137b:	83 c4 20             	add    $0x20,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	79 28                	jns    8013aa <fork+0x154>
			panic("error");
  801382:	83 ec 04             	sub    $0x4,%esp
  801385:	68 d4 2b 80 00       	push   $0x802bd4
  80138a:	6a 4d                	push   $0x4d
  80138c:	68 1c 2f 80 00       	push   $0x802f1c
  801391:	e8 4f f1 ff ff       	call   8004e5 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	6a 05                	push   $0x5
  80139b:	56                   	push   %esi
  80139c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139f:	56                   	push   %esi
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 e8 fb ff ff       	call   800f8f <sys_page_map>
  8013a7:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8013aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013b0:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8013b6:	0f 85 fc fe ff ff    	jne    8012b8 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8013bc:	83 ec 04             	sub    $0x4,%esp
  8013bf:	6a 07                	push   $0x7
  8013c1:	68 00 f0 7f ee       	push   $0xee7ff000
  8013c6:	57                   	push   %edi
  8013c7:	e8 80 fb ff ff       	call   800f4c <sys_page_alloc>
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 14                	jns    8013e7 <fork+0x191>
		panic("1");
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	68 70 2f 80 00       	push   $0x802f70
  8013db:	6a 78                	push   $0x78
  8013dd:	68 1c 2f 80 00       	push   $0x802f1c
  8013e2:	e8 fe f0 ff ff       	call   8004e5 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	68 33 26 80 00       	push   $0x802633
  8013ef:	57                   	push   %edi
  8013f0:	e8 a2 fc ff ff       	call   801097 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8013f5:	83 c4 08             	add    $0x8,%esp
  8013f8:	6a 02                	push   $0x2
  8013fa:	57                   	push   %edi
  8013fb:	e8 13 fc ff ff       	call   801013 <sys_env_set_status>
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	79 14                	jns    80141b <fork+0x1c5>
		panic("sys_env_set_status");
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	68 72 2f 80 00       	push   $0x802f72
  80140f:	6a 7d                	push   $0x7d
  801411:	68 1c 2f 80 00       	push   $0x802f1c
  801416:	e8 ca f0 ff ff       	call   8004e5 <_panic>

	return envid;
  80141b:	89 f8                	mov    %edi,%eax
}
  80141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <sfork>:

// Challenge!
int
sfork(void)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80142b:	68 85 2f 80 00       	push   $0x802f85
  801430:	68 86 00 00 00       	push   $0x86
  801435:	68 1c 2f 80 00       	push   $0x802f1c
  80143a:	e8 a6 f0 ff ff       	call   8004e5 <_panic>

0080143f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	05 00 00 00 30       	add    $0x30000000,%eax
  80144a:	c1 e8 0c             	shr    $0xc,%eax
}
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
  801455:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80145a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80145f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 16             	shr    $0x16,%edx
  801476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	74 11                	je     801493 <fd_alloc+0x2d>
  801482:	89 c2                	mov    %eax,%edx
  801484:	c1 ea 0c             	shr    $0xc,%edx
  801487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	75 09                	jne    80149c <fd_alloc+0x36>
			*fd_store = fd;
  801493:	89 01                	mov    %eax,(%ecx)
			return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	eb 17                	jmp    8014b3 <fd_alloc+0x4d>
  80149c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a6:	75 c9                	jne    801471 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014bb:	83 f8 1f             	cmp    $0x1f,%eax
  8014be:	77 36                	ja     8014f6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c0:	c1 e0 0c             	shl    $0xc,%eax
  8014c3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	c1 ea 16             	shr    $0x16,%edx
  8014cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d4:	f6 c2 01             	test   $0x1,%dl
  8014d7:	74 24                	je     8014fd <fd_lookup+0x48>
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	c1 ea 0c             	shr    $0xc,%edx
  8014de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e5:	f6 c2 01             	test   $0x1,%dl
  8014e8:	74 1a                	je     801504 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ed:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f4:	eb 13                	jmp    801509 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fb:	eb 0c                	jmp    801509 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801502:	eb 05                	jmp    801509 <fd_lookup+0x54>
  801504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801514:	ba 18 30 80 00       	mov    $0x803018,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801519:	eb 13                	jmp    80152e <dev_lookup+0x23>
  80151b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80151e:	39 08                	cmp    %ecx,(%eax)
  801520:	75 0c                	jne    80152e <dev_lookup+0x23>
			*dev = devtab[i];
  801522:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801525:	89 01                	mov    %eax,(%ecx)
			return 0;
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
  80152c:	eb 2e                	jmp    80155c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152e:	8b 02                	mov    (%edx),%eax
  801530:	85 c0                	test   %eax,%eax
  801532:	75 e7                	jne    80151b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801534:	a1 04 50 80 00       	mov    0x805004,%eax
  801539:	8b 40 48             	mov    0x48(%eax),%eax
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	51                   	push   %ecx
  801540:	50                   	push   %eax
  801541:	68 9c 2f 80 00       	push   $0x802f9c
  801546:	e8 73 f0 ff ff       	call   8005be <cprintf>
	*dev = 0;
  80154b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    

0080155e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 10             	sub    $0x10,%esp
  801566:	8b 75 08             	mov    0x8(%ebp),%esi
  801569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801570:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801576:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801579:	50                   	push   %eax
  80157a:	e8 36 ff ff ff       	call   8014b5 <fd_lookup>
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 05                	js     80158b <fd_close+0x2d>
	    || fd != fd2)
  801586:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801589:	74 0b                	je     801596 <fd_close+0x38>
		return (must_exist ? r : 0);
  80158b:	80 fb 01             	cmp    $0x1,%bl
  80158e:	19 d2                	sbb    %edx,%edx
  801590:	f7 d2                	not    %edx
  801592:	21 d0                	and    %edx,%eax
  801594:	eb 41                	jmp    8015d7 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 36                	pushl  (%esi)
  80159f:	e8 67 ff ff ff       	call   80150b <dev_lookup>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 1a                	js     8015c7 <fd_close+0x69>
		if (dev->dev_close)
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 0b                	je     8015c7 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	56                   	push   %esi
  8015c0:	ff d0                	call   *%eax
  8015c2:	89 c3                	mov    %eax,%ebx
  8015c4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	56                   	push   %esi
  8015cb:	6a 00                	push   $0x0
  8015cd:	e8 ff f9 ff ff       	call   800fd1 <sys_page_unmap>
	return r;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	89 d8                	mov    %ebx,%eax
}
  8015d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 c5 fe ff ff       	call   8014b5 <fd_lookup>
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	78 10                	js     801609 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	6a 01                	push   $0x1
  8015fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801601:	e8 58 ff ff ff       	call   80155e <fd_close>
  801606:	83 c4 10             	add    $0x10,%esp
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <close_all>:

void
close_all(void)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801612:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	53                   	push   %ebx
  80161b:	e8 be ff ff ff       	call   8015de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801620:	83 c3 01             	add    $0x1,%ebx
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	83 fb 20             	cmp    $0x20,%ebx
  801629:	75 ec                	jne    801617 <close_all+0xc>
		close(i);
}
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 2c             	sub    $0x2c,%esp
  801639:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80163c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 6d fe ff ff       	call   8014b5 <fd_lookup>
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 08             	add    $0x8,%esp
  80164d:	85 d2                	test   %edx,%edx
  80164f:	0f 88 c1 00 00 00    	js     801716 <dup+0xe6>
		return r;
	close(newfdnum);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	56                   	push   %esi
  801659:	e8 80 ff ff ff       	call   8015de <close>

	newfd = INDEX2FD(newfdnum);
  80165e:	89 f3                	mov    %esi,%ebx
  801660:	c1 e3 0c             	shl    $0xc,%ebx
  801663:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801669:	83 c4 04             	add    $0x4,%esp
  80166c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166f:	e8 db fd ff ff       	call   80144f <fd2data>
  801674:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801676:	89 1c 24             	mov    %ebx,(%esp)
  801679:	e8 d1 fd ff ff       	call   80144f <fd2data>
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801684:	89 f8                	mov    %edi,%eax
  801686:	c1 e8 16             	shr    $0x16,%eax
  801689:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801690:	a8 01                	test   $0x1,%al
  801692:	74 37                	je     8016cb <dup+0x9b>
  801694:	89 f8                	mov    %edi,%eax
  801696:	c1 e8 0c             	shr    $0xc,%eax
  801699:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016a0:	f6 c2 01             	test   $0x1,%dl
  8016a3:	74 26                	je     8016cb <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ac:	83 ec 0c             	sub    $0xc,%esp
  8016af:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b8:	6a 00                	push   $0x0
  8016ba:	57                   	push   %edi
  8016bb:	6a 00                	push   $0x0
  8016bd:	e8 cd f8 ff ff       	call   800f8f <sys_page_map>
  8016c2:	89 c7                	mov    %eax,%edi
  8016c4:	83 c4 20             	add    $0x20,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 2e                	js     8016f9 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016ce:	89 d0                	mov    %edx,%eax
  8016d0:	c1 e8 0c             	shr    $0xc,%eax
  8016d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e2:	50                   	push   %eax
  8016e3:	53                   	push   %ebx
  8016e4:	6a 00                	push   $0x0
  8016e6:	52                   	push   %edx
  8016e7:	6a 00                	push   $0x0
  8016e9:	e8 a1 f8 ff ff       	call   800f8f <sys_page_map>
  8016ee:	89 c7                	mov    %eax,%edi
  8016f0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016f3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f5:	85 ff                	test   %edi,%edi
  8016f7:	79 1d                	jns    801716 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	53                   	push   %ebx
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 cd f8 ff ff       	call   800fd1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801704:	83 c4 08             	add    $0x8,%esp
  801707:	ff 75 d4             	pushl  -0x2c(%ebp)
  80170a:	6a 00                	push   $0x0
  80170c:	e8 c0 f8 ff ff       	call   800fd1 <sys_page_unmap>
	return r;
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	89 f8                	mov    %edi,%eax
}
  801716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5f                   	pop    %edi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	83 ec 14             	sub    $0x14,%esp
  801725:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801728:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	53                   	push   %ebx
  80172d:	e8 83 fd ff ff       	call   8014b5 <fd_lookup>
  801732:	83 c4 08             	add    $0x8,%esp
  801735:	89 c2                	mov    %eax,%edx
  801737:	85 c0                	test   %eax,%eax
  801739:	78 6d                	js     8017a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801745:	ff 30                	pushl  (%eax)
  801747:	e8 bf fd ff ff       	call   80150b <dev_lookup>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 4c                	js     80179f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801753:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801756:	8b 42 08             	mov    0x8(%edx),%eax
  801759:	83 e0 03             	and    $0x3,%eax
  80175c:	83 f8 01             	cmp    $0x1,%eax
  80175f:	75 21                	jne    801782 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801761:	a1 04 50 80 00       	mov    0x805004,%eax
  801766:	8b 40 48             	mov    0x48(%eax),%eax
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	53                   	push   %ebx
  80176d:	50                   	push   %eax
  80176e:	68 dd 2f 80 00       	push   $0x802fdd
  801773:	e8 46 ee ff ff       	call   8005be <cprintf>
		return -E_INVAL;
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801780:	eb 26                	jmp    8017a8 <read+0x8a>
	}
	if (!dev->dev_read)
  801782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801785:	8b 40 08             	mov    0x8(%eax),%eax
  801788:	85 c0                	test   %eax,%eax
  80178a:	74 17                	je     8017a3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	ff 75 10             	pushl  0x10(%ebp)
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	52                   	push   %edx
  801796:	ff d0                	call   *%eax
  801798:	89 c2                	mov    %eax,%edx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	eb 09                	jmp    8017a8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	eb 05                	jmp    8017a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017a8:	89 d0                	mov    %edx,%eax
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	57                   	push   %edi
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c3:	eb 21                	jmp    8017e6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	89 f0                	mov    %esi,%eax
  8017ca:	29 d8                	sub    %ebx,%eax
  8017cc:	50                   	push   %eax
  8017cd:	89 d8                	mov    %ebx,%eax
  8017cf:	03 45 0c             	add    0xc(%ebp),%eax
  8017d2:	50                   	push   %eax
  8017d3:	57                   	push   %edi
  8017d4:	e8 45 ff ff ff       	call   80171e <read>
		if (m < 0)
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 0c                	js     8017ec <readn+0x3d>
			return m;
		if (m == 0)
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	74 06                	je     8017ea <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e4:	01 c3                	add    %eax,%ebx
  8017e6:	39 f3                	cmp    %esi,%ebx
  8017e8:	72 db                	jb     8017c5 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8017ea:	89 d8                	mov    %ebx,%eax
}
  8017ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5f                   	pop    %edi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 14             	sub    $0x14,%esp
  8017fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	53                   	push   %ebx
  801803:	e8 ad fc ff ff       	call   8014b5 <fd_lookup>
  801808:	83 c4 08             	add    $0x8,%esp
  80180b:	89 c2                	mov    %eax,%edx
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 68                	js     801879 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181b:	ff 30                	pushl  (%eax)
  80181d:	e8 e9 fc ff ff       	call   80150b <dev_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 47                	js     801870 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801830:	75 21                	jne    801853 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801832:	a1 04 50 80 00       	mov    0x805004,%eax
  801837:	8b 40 48             	mov    0x48(%eax),%eax
  80183a:	83 ec 04             	sub    $0x4,%esp
  80183d:	53                   	push   %ebx
  80183e:	50                   	push   %eax
  80183f:	68 f9 2f 80 00       	push   $0x802ff9
  801844:	e8 75 ed ff ff       	call   8005be <cprintf>
		return -E_INVAL;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801851:	eb 26                	jmp    801879 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801853:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801856:	8b 52 0c             	mov    0xc(%edx),%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	74 17                	je     801874 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185d:	83 ec 04             	sub    $0x4,%esp
  801860:	ff 75 10             	pushl  0x10(%ebp)
  801863:	ff 75 0c             	pushl  0xc(%ebp)
  801866:	50                   	push   %eax
  801867:	ff d2                	call   *%edx
  801869:	89 c2                	mov    %eax,%edx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	eb 09                	jmp    801879 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801870:	89 c2                	mov    %eax,%edx
  801872:	eb 05                	jmp    801879 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801874:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801879:	89 d0                	mov    %edx,%eax
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <seek>:

int
seek(int fdnum, off_t offset)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801886:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801889:	50                   	push   %eax
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 23 fc ff ff       	call   8014b5 <fd_lookup>
  801892:	83 c4 08             	add    $0x8,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 0e                	js     8018a7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801899:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80189c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 14             	sub    $0x14,%esp
  8018b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b6:	50                   	push   %eax
  8018b7:	53                   	push   %ebx
  8018b8:	e8 f8 fb ff ff       	call   8014b5 <fd_lookup>
  8018bd:	83 c4 08             	add    $0x8,%esp
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 65                	js     80192b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d0:	ff 30                	pushl  (%eax)
  8018d2:	e8 34 fc ff ff       	call   80150b <dev_lookup>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 44                	js     801922 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e5:	75 21                	jne    801908 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e7:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ec:	8b 40 48             	mov    0x48(%eax),%eax
  8018ef:	83 ec 04             	sub    $0x4,%esp
  8018f2:	53                   	push   %ebx
  8018f3:	50                   	push   %eax
  8018f4:	68 bc 2f 80 00       	push   $0x802fbc
  8018f9:	e8 c0 ec ff ff       	call   8005be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801906:	eb 23                	jmp    80192b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801908:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190b:	8b 52 18             	mov    0x18(%edx),%edx
  80190e:	85 d2                	test   %edx,%edx
  801910:	74 14                	je     801926 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	50                   	push   %eax
  801919:	ff d2                	call   *%edx
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	eb 09                	jmp    80192b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801922:	89 c2                	mov    %eax,%edx
  801924:	eb 05                	jmp    80192b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801926:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80192b:	89 d0                	mov    %edx,%eax
  80192d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	83 ec 14             	sub    $0x14,%esp
  801939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 6d fb ff ff       	call   8014b5 <fd_lookup>
  801948:	83 c4 08             	add    $0x8,%esp
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 58                	js     8019a9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195b:	ff 30                	pushl  (%eax)
  80195d:	e8 a9 fb ff ff       	call   80150b <dev_lookup>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	78 37                	js     8019a0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801970:	74 32                	je     8019a4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801972:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801975:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80197c:	00 00 00 
	stat->st_isdir = 0;
  80197f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801986:	00 00 00 
	stat->st_dev = dev;
  801989:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	53                   	push   %ebx
  801993:	ff 75 f0             	pushl  -0x10(%ebp)
  801996:	ff 50 14             	call   *0x14(%eax)
  801999:	89 c2                	mov    %eax,%edx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	eb 09                	jmp    8019a9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	eb 05                	jmp    8019a9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a9:	89 d0                	mov    %edx,%eax
  8019ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	6a 00                	push   $0x0
  8019ba:	ff 75 08             	pushl  0x8(%ebp)
  8019bd:	e8 e7 01 00 00       	call   801ba9 <open>
  8019c2:	89 c3                	mov    %eax,%ebx
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 db                	test   %ebx,%ebx
  8019c9:	78 1b                	js     8019e6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019cb:	83 ec 08             	sub    $0x8,%esp
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	53                   	push   %ebx
  8019d2:	e8 5b ff ff ff       	call   801932 <fstat>
  8019d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d9:	89 1c 24             	mov    %ebx,(%esp)
  8019dc:	e8 fd fb ff ff       	call   8015de <close>
	return r;
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	89 f0                	mov    %esi,%eax
}
  8019e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	89 c6                	mov    %eax,%esi
  8019f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019f6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019fd:	75 12                	jne    801a11 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	6a 03                	push   $0x3
  801a04:	e8 09 0d 00 00       	call   802712 <ipc_find_env>
  801a09:	a3 00 50 80 00       	mov    %eax,0x805000
  801a0e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a11:	6a 07                	push   $0x7
  801a13:	68 00 60 80 00       	push   $0x806000
  801a18:	56                   	push   %esi
  801a19:	ff 35 00 50 80 00    	pushl  0x805000
  801a1f:	e8 9d 0c 00 00       	call   8026c1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a24:	83 c4 0c             	add    $0xc,%esp
  801a27:	6a 00                	push   $0x0
  801a29:	53                   	push   %ebx
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 2a 0c 00 00       	call   80265b <ipc_recv>
}
  801a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	8b 40 0c             	mov    0xc(%eax),%eax
  801a44:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4c:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a51:	ba 00 00 00 00       	mov    $0x0,%edx
  801a56:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5b:	e8 8d ff ff ff       	call   8019ed <fsipc>
}
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a73:	ba 00 00 00 00       	mov    $0x0,%edx
  801a78:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7d:	e8 6b ff ff ff       	call   8019ed <fsipc>
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	53                   	push   %ebx
  801a88:	83 ec 04             	sub    $0x4,%esp
  801a8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	8b 40 0c             	mov    0xc(%eax),%eax
  801a94:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a99:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9e:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa3:	e8 45 ff ff ff       	call   8019ed <fsipc>
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	85 d2                	test   %edx,%edx
  801aac:	78 2c                	js     801ada <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	68 00 60 80 00       	push   $0x806000
  801ab6:	53                   	push   %ebx
  801ab7:	e8 86 f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801abc:	a1 80 60 80 00       	mov    0x806080,%eax
  801ac1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac7:	a1 84 60 80 00       	mov    0x806084,%eax
  801acc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  801aeb:	8b 52 0c             	mov    0xc(%edx),%edx
  801aee:	89 15 00 60 80 00    	mov    %edx,0x806000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801af4:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801af9:	76 05                	jbe    801b00 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801afb:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801b00:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(req->req_buf, buf, movesize);
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	50                   	push   %eax
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	68 08 60 80 00       	push   $0x806008
  801b11:	e8 be f1 ff ff       	call   800cd4 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b20:	e8 c8 fe ff ff       	call   8019ed <fsipc>
	return write;
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b3a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	b8 03 00 00 00       	mov    $0x3,%eax
  801b4a:	e8 9e fe ff ff       	call   8019ed <fsipc>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 4b                	js     801ba0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b55:	39 c6                	cmp    %eax,%esi
  801b57:	73 16                	jae    801b6f <devfile_read+0x48>
  801b59:	68 28 30 80 00       	push   $0x803028
  801b5e:	68 2f 30 80 00       	push   $0x80302f
  801b63:	6a 7c                	push   $0x7c
  801b65:	68 44 30 80 00       	push   $0x803044
  801b6a:	e8 76 e9 ff ff       	call   8004e5 <_panic>
	assert(r <= PGSIZE);
  801b6f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b74:	7e 16                	jle    801b8c <devfile_read+0x65>
  801b76:	68 4f 30 80 00       	push   $0x80304f
  801b7b:	68 2f 30 80 00       	push   $0x80302f
  801b80:	6a 7d                	push   $0x7d
  801b82:	68 44 30 80 00       	push   $0x803044
  801b87:	e8 59 e9 ff ff       	call   8004e5 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	50                   	push   %eax
  801b90:	68 00 60 80 00       	push   $0x806000
  801b95:	ff 75 0c             	pushl  0xc(%ebp)
  801b98:	e8 37 f1 ff ff       	call   800cd4 <memmove>
	return r;
  801b9d:	83 c4 10             	add    $0x10,%esp
}
  801ba0:	89 d8                	mov    %ebx,%eax
  801ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	83 ec 20             	sub    $0x20,%esp
  801bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bb3:	53                   	push   %ebx
  801bb4:	e8 50 ef ff ff       	call   800b09 <strlen>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc1:	7f 67                	jg     801c2a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc9:	50                   	push   %eax
  801bca:	e8 97 f8 ff ff       	call   801466 <fd_alloc>
  801bcf:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 57                	js     801c2f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	53                   	push   %ebx
  801bdc:	68 00 60 80 00       	push   $0x806000
  801be1:	e8 5c ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	e8 f2 fd ff ff       	call   8019ed <fsipc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	79 14                	jns    801c18 <open+0x6f>
		fd_close(fd, 0);
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	6a 00                	push   $0x0
  801c09:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0c:	e8 4d f9 ff ff       	call   80155e <fd_close>
		return r;
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	89 da                	mov    %ebx,%edx
  801c16:	eb 17                	jmp    801c2f <open+0x86>
	}

	return fd2num(fd);
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	e8 1c f8 ff ff       	call   80143f <fd2num>
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb 05                	jmp    801c2f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c41:	b8 08 00 00 00       	mov    $0x8,%eax
  801c46:	e8 a2 fd ff ff       	call   8019ed <fsipc>
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c59:	6a 00                	push   $0x0
  801c5b:	ff 75 08             	pushl  0x8(%ebp)
  801c5e:	e8 46 ff ff ff       	call   801ba9 <open>
  801c63:	89 c1                	mov    %eax,%ecx
  801c65:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 c6 04 00 00    	js     80213c <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c76:	83 ec 04             	sub    $0x4,%esp
  801c79:	68 00 02 00 00       	push   $0x200
  801c7e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c84:	50                   	push   %eax
  801c85:	51                   	push   %ecx
  801c86:	e8 24 fb ff ff       	call   8017af <readn>
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c93:	75 0c                	jne    801ca1 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c95:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c9c:	45 4c 46 
  801c9f:	74 33                	je     801cd4 <spawn+0x87>
		close(fd);
  801ca1:	83 ec 0c             	sub    $0xc,%esp
  801ca4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801caa:	e8 2f f9 ff ff       	call   8015de <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801caf:	83 c4 0c             	add    $0xc,%esp
  801cb2:	68 7f 45 4c 46       	push   $0x464c457f
  801cb7:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cbd:	68 5b 30 80 00       	push   $0x80305b
  801cc2:	e8 f7 e8 ff ff       	call   8005be <cprintf>
		return -E_NOT_EXEC;
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801ccf:	e9 c8 04 00 00       	jmp    80219c <spawn+0x54f>
  801cd4:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd9:	cd 30                	int    $0x30
  801cdb:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ce1:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	0f 88 55 04 00 00    	js     802144 <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cef:	89 c6                	mov    %eax,%esi
  801cf1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cf7:	6b f6 78             	imul   $0x78,%esi,%esi
  801cfa:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d00:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d06:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d0d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d13:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d19:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d1e:	be 00 00 00 00       	mov    $0x0,%esi
  801d23:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d26:	eb 13                	jmp    801d3b <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	50                   	push   %eax
  801d2c:	e8 d8 ed ff ff       	call   800b09 <strlen>
  801d31:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d35:	83 c3 01             	add    $0x1,%ebx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d42:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d45:	85 c0                	test   %eax,%eax
  801d47:	75 df                	jne    801d28 <spawn+0xdb>
  801d49:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d4f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d55:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d5a:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d5c:	89 fa                	mov    %edi,%edx
  801d5e:	83 e2 fc             	and    $0xfffffffc,%edx
  801d61:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d68:	29 c2                	sub    %eax,%edx
  801d6a:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d70:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d73:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d78:	0f 86 d6 03 00 00    	jbe    802154 <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d7e:	83 ec 04             	sub    $0x4,%esp
  801d81:	6a 07                	push   $0x7
  801d83:	68 00 00 40 00       	push   $0x400000
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 bd f1 ff ff       	call   800f4c <sys_page_alloc>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	0f 88 02 04 00 00    	js     80219c <spawn+0x54f>
  801d9a:	be 00 00 00 00       	mov    $0x0,%esi
  801d9f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801da5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801da8:	eb 30                	jmp    801dda <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801daa:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  801db0:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801db6:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801db9:	83 ec 08             	sub    $0x8,%esp
  801dbc:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dbf:	57                   	push   %edi
  801dc0:	e8 7d ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dc5:	83 c4 04             	add    $0x4,%esp
  801dc8:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dcb:	e8 39 ed ff ff       	call   800b09 <strlen>
  801dd0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dd4:	83 c6 01             	add    $0x1,%esi
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801de0:	7c c8                	jl     801daa <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801de2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801de8:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801dee:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801df5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dfb:	74 19                	je     801e16 <spawn+0x1c9>
  801dfd:	68 e4 30 80 00       	push   $0x8030e4
  801e02:	68 2f 30 80 00       	push   $0x80302f
  801e07:	68 f1 00 00 00       	push   $0xf1
  801e0c:	68 75 30 80 00       	push   $0x803075
  801e11:	e8 cf e6 ff ff       	call   8004e5 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e16:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e1c:	89 f8                	mov    %edi,%eax
  801e1e:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  801e23:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e26:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e2c:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e2f:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  801e35:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	6a 07                	push   $0x7
  801e40:	68 00 d0 7f ee       	push   $0xee7fd000
  801e45:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e4b:	68 00 00 40 00       	push   $0x400000
  801e50:	6a 00                	push   $0x0
  801e52:	e8 38 f1 ff ff       	call   800f8f <sys_page_map>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	83 c4 20             	add    $0x20,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	0f 88 24 03 00 00    	js     802188 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	68 00 00 40 00       	push   $0x400000
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 5e f1 ff ff       	call   800fd1 <sys_page_unmap>
  801e73:	89 c3                	mov    %eax,%ebx
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	0f 88 08 03 00 00    	js     802188 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e80:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e86:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e8d:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e93:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e9a:	00 00 00 
  801e9d:	e9 84 01 00 00       	jmp    802026 <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  801ea2:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ea8:	83 38 01             	cmpl   $0x1,(%eax)
  801eab:	0f 85 67 01 00 00    	jne    802018 <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801eb1:	89 c1                	mov    %eax,%ecx
  801eb3:	8b 40 18             	mov    0x18(%eax),%eax
  801eb6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ebc:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ebf:	83 f8 01             	cmp    $0x1,%eax
  801ec2:	19 c0                	sbb    %eax,%eax
  801ec4:	83 e0 fe             	and    $0xfffffffe,%eax
  801ec7:	83 c0 07             	add    $0x7,%eax
  801eca:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ed0:	89 c8                	mov    %ecx,%eax
  801ed2:	8b 49 04             	mov    0x4(%ecx),%ecx
  801ed5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801edb:	8b 78 10             	mov    0x10(%eax),%edi
  801ede:	8b 48 14             	mov    0x14(%eax),%ecx
  801ee1:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801ee7:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801eea:	89 f0                	mov    %esi,%eax
  801eec:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ef1:	74 10                	je     801f03 <spawn+0x2b6>
		va -= i;
  801ef3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ef5:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801efb:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801efd:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f08:	e9 f9 00 00 00       	jmp    802006 <spawn+0x3b9>
		if (i >= filesz) {
  801f0d:	39 fb                	cmp    %edi,%ebx
  801f0f:	72 27                	jb     801f38 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f1a:	56                   	push   %esi
  801f1b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f21:	e8 26 f0 ff ff       	call   800f4c <sys_page_alloc>
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	0f 89 c9 00 00 00    	jns    801ffa <spawn+0x3ad>
  801f31:	89 c7                	mov    %eax,%edi
  801f33:	e9 2d 02 00 00       	jmp    802165 <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f38:	83 ec 04             	sub    $0x4,%esp
  801f3b:	6a 07                	push   $0x7
  801f3d:	68 00 00 40 00       	push   $0x400000
  801f42:	6a 00                	push   $0x0
  801f44:	e8 03 f0 ff ff       	call   800f4c <sys_page_alloc>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	0f 88 07 02 00 00    	js     80215b <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f54:	83 ec 08             	sub    $0x8,%esp
  801f57:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f5d:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801f63:	50                   	push   %eax
  801f64:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f6a:	e8 11 f9 ff ff       	call   801880 <seek>
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 e5 01 00 00    	js     80215f <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f7a:	83 ec 04             	sub    $0x4,%esp
  801f7d:	89 fa                	mov    %edi,%edx
  801f7f:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801f85:	89 d0                	mov    %edx,%eax
  801f87:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801f8d:	76 05                	jbe    801f94 <spawn+0x347>
  801f8f:	b8 00 10 00 00       	mov    $0x1000,%eax
  801f94:	50                   	push   %eax
  801f95:	68 00 00 40 00       	push   $0x400000
  801f9a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fa0:	e8 0a f8 ff ff       	call   8017af <readn>
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	0f 88 b3 01 00 00    	js     802163 <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fb0:	83 ec 0c             	sub    $0xc,%esp
  801fb3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fb9:	56                   	push   %esi
  801fba:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fc0:	68 00 00 40 00       	push   $0x400000
  801fc5:	6a 00                	push   $0x0
  801fc7:	e8 c3 ef ff ff       	call   800f8f <sys_page_map>
  801fcc:	83 c4 20             	add    $0x20,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	79 15                	jns    801fe8 <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  801fd3:	50                   	push   %eax
  801fd4:	68 81 30 80 00       	push   $0x803081
  801fd9:	68 23 01 00 00       	push   $0x123
  801fde:	68 75 30 80 00       	push   $0x803075
  801fe3:	e8 fd e4 ff ff       	call   8004e5 <_panic>
			sys_page_unmap(0, UTEMP);
  801fe8:	83 ec 08             	sub    $0x8,%esp
  801feb:	68 00 00 40 00       	push   $0x400000
  801ff0:	6a 00                	push   $0x0
  801ff2:	e8 da ef ff ff       	call   800fd1 <sys_page_unmap>
  801ff7:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ffa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802000:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802006:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80200c:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802012:	0f 82 f5 fe ff ff    	jb     801f0d <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802018:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80201f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802026:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80202d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802033:	0f 8c 69 fe ff ff    	jl     801ea2 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802042:	e8 97 f5 ff ff       	call   8015de <close>
  802047:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  80204a:	ba 00 00 00 00       	mov    $0x0,%edx
  80204f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802054:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  80205a:	89 d8                	mov    %ebx,%eax
  80205c:	c1 f8 0a             	sar    $0xa,%eax
  80205f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802066:	a8 01                	test   $0x1,%al
  802068:	75 10                	jne    80207a <spawn+0x42d>
  80206a:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  802070:	75 08                	jne    80207a <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  802072:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  802078:	eb 54                	jmp    8020ce <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  80207a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  802081:	a8 01                	test   $0x1,%al
  802083:	74 49                	je     8020ce <spawn+0x481>
  802085:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80208c:	f6 c4 04             	test   $0x4,%ah
  80208f:	74 3d                	je     8020ce <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  802091:	89 da                	mov    %ebx,%edx
  802093:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  802096:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8020a5:	50                   	push   %eax
  8020a6:	52                   	push   %edx
  8020a7:	56                   	push   %esi
  8020a8:	52                   	push   %edx
  8020a9:	6a 00                	push   $0x0
  8020ab:	e8 df ee ff ff       	call   800f8f <sys_page_map>
  8020b0:	83 c4 20             	add    $0x20,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	74 17                	je     8020ce <spawn+0x481>
                                panic("copy_shared_pages");
  8020b7:	83 ec 04             	sub    $0x4,%esp
  8020ba:	68 9e 30 80 00       	push   $0x80309e
  8020bf:	68 3c 01 00 00       	push   $0x13c
  8020c4:	68 75 30 80 00       	push   $0x803075
  8020c9:	e8 17 e4 ff ff       	call   8004e5 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  8020ce:	83 c3 01             	add    $0x1,%ebx
  8020d1:	89 da                	mov    %ebx,%edx
  8020d3:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  8020d9:	0f 86 7b ff ff ff    	jbe    80205a <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020df:	83 ec 08             	sub    $0x8,%esp
  8020e2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020e8:	50                   	push   %eax
  8020e9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020ef:	e8 61 ef ff ff       	call   801055 <sys_env_set_trapframe>
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	79 15                	jns    802110 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  8020fb:	50                   	push   %eax
  8020fc:	68 b0 30 80 00       	push   $0x8030b0
  802101:	68 85 00 00 00       	push   $0x85
  802106:	68 75 30 80 00       	push   $0x803075
  80210b:	e8 d5 e3 ff ff       	call   8004e5 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	6a 02                	push   $0x2
  802115:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80211b:	e8 f3 ee ff ff       	call   801013 <sys_env_set_status>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	79 25                	jns    80214c <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  802127:	50                   	push   %eax
  802128:	68 ca 30 80 00       	push   $0x8030ca
  80212d:	68 88 00 00 00       	push   $0x88
  802132:	68 75 30 80 00       	push   $0x803075
  802137:	e8 a9 e3 ff ff       	call   8004e5 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80213c:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802142:	eb 58                	jmp    80219c <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802144:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80214a:	eb 50                	jmp    80219c <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  80214c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802152:	eb 48                	jmp    80219c <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802154:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802159:	eb 41                	jmp    80219c <spawn+0x54f>
  80215b:	89 c7                	mov    %eax,%edi
  80215d:	eb 06                	jmp    802165 <spawn+0x518>
  80215f:	89 c7                	mov    %eax,%edi
  802161:	eb 02                	jmp    802165 <spawn+0x518>
  802163:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  802165:	83 ec 0c             	sub    $0xc,%esp
  802168:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80216e:	e8 5a ed ff ff       	call   800ecd <sys_env_destroy>
	close(fd);
  802173:	83 c4 04             	add    $0x4,%esp
  802176:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80217c:	e8 5d f4 ff ff       	call   8015de <close>
	return r;
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	89 f8                	mov    %edi,%eax
  802186:	eb 14                	jmp    80219c <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802188:	83 ec 08             	sub    $0x8,%esp
  80218b:	68 00 00 40 00       	push   $0x400000
  802190:	6a 00                	push   $0x0
  802192:	e8 3a ee ff ff       	call   800fd1 <sys_page_unmap>
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80219c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    

008021a4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021a9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b1:	eb 03                	jmp    8021b6 <spawnl+0x12>
		argc++;
  8021b3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b6:	83 c2 04             	add    $0x4,%edx
  8021b9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021bd:	75 f4                	jne    8021b3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021bf:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021c6:	83 e2 f0             	and    $0xfffffff0,%edx
  8021c9:	29 d4                	sub    %edx,%esp
  8021cb:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021cf:	c1 ea 02             	shr    $0x2,%edx
  8021d2:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021d9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021de:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021e5:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021ec:	00 
  8021ed:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f4:	eb 0a                	jmp    802200 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021f6:	83 c0 01             	add    $0x1,%eax
  8021f9:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021fd:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802200:	39 d0                	cmp    %edx,%eax
  802202:	75 f2                	jne    8021f6 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802204:	83 ec 08             	sub    $0x8,%esp
  802207:	56                   	push   %esi
  802208:	ff 75 08             	pushl  0x8(%ebp)
  80220b:	e8 3d fa ff ff       	call   801c4d <spawn>
}
  802210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80221f:	83 ec 0c             	sub    $0xc,%esp
  802222:	ff 75 08             	pushl  0x8(%ebp)
  802225:	e8 25 f2 ff ff       	call   80144f <fd2data>
  80222a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80222c:	83 c4 08             	add    $0x8,%esp
  80222f:	68 0a 31 80 00       	push   $0x80310a
  802234:	53                   	push   %ebx
  802235:	e8 08 e9 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80223a:	8b 56 04             	mov    0x4(%esi),%edx
  80223d:	89 d0                	mov    %edx,%eax
  80223f:	2b 06                	sub    (%esi),%eax
  802241:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802247:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80224e:	00 00 00 
	stat->st_dev = &devpipe;
  802251:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802258:	40 80 00 
	return 0;
}
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
  802260:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    

00802267 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	53                   	push   %ebx
  80226b:	83 ec 0c             	sub    $0xc,%esp
  80226e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802271:	53                   	push   %ebx
  802272:	6a 00                	push   $0x0
  802274:	e8 58 ed ff ff       	call   800fd1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802279:	89 1c 24             	mov    %ebx,(%esp)
  80227c:	e8 ce f1 ff ff       	call   80144f <fd2data>
  802281:	83 c4 08             	add    $0x8,%esp
  802284:	50                   	push   %eax
  802285:	6a 00                	push   $0x0
  802287:	e8 45 ed ff ff       	call   800fd1 <sys_page_unmap>
}
  80228c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80228f:	c9                   	leave  
  802290:	c3                   	ret    

00802291 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	57                   	push   %edi
  802295:	56                   	push   %esi
  802296:	53                   	push   %ebx
  802297:	83 ec 1c             	sub    $0x1c,%esp
  80229a:	89 c7                	mov    %eax,%edi
  80229c:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80229e:	a1 04 50 80 00       	mov    0x805004,%eax
  8022a3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	57                   	push   %edi
  8022aa:	e8 9b 04 00 00       	call   80274a <pageref>
  8022af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8022b2:	89 34 24             	mov    %esi,(%esp)
  8022b5:	e8 90 04 00 00       	call   80274a <pageref>
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022c0:	0f 94 c0             	sete   %al
  8022c3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8022c6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022cf:	39 cb                	cmp    %ecx,%ebx
  8022d1:	74 15                	je     8022e8 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8022d3:	8b 52 58             	mov    0x58(%edx),%edx
  8022d6:	50                   	push   %eax
  8022d7:	52                   	push   %edx
  8022d8:	53                   	push   %ebx
  8022d9:	68 18 31 80 00       	push   $0x803118
  8022de:	e8 db e2 ff ff       	call   8005be <cprintf>
  8022e3:	83 c4 10             	add    $0x10,%esp
  8022e6:	eb b6                	jmp    80229e <_pipeisclosed+0xd>
	}
}
  8022e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022eb:	5b                   	pop    %ebx
  8022ec:	5e                   	pop    %esi
  8022ed:	5f                   	pop    %edi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    

008022f0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	57                   	push   %edi
  8022f4:	56                   	push   %esi
  8022f5:	53                   	push   %ebx
  8022f6:	83 ec 28             	sub    $0x28,%esp
  8022f9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022fc:	56                   	push   %esi
  8022fd:	e8 4d f1 ff ff       	call   80144f <fd2data>
  802302:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	bf 00 00 00 00       	mov    $0x0,%edi
  80230c:	eb 4b                	jmp    802359 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80230e:	89 da                	mov    %ebx,%edx
  802310:	89 f0                	mov    %esi,%eax
  802312:	e8 7a ff ff ff       	call   802291 <_pipeisclosed>
  802317:	85 c0                	test   %eax,%eax
  802319:	75 48                	jne    802363 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80231b:	e8 0d ec ff ff       	call   800f2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802320:	8b 43 04             	mov    0x4(%ebx),%eax
  802323:	8b 0b                	mov    (%ebx),%ecx
  802325:	8d 51 20             	lea    0x20(%ecx),%edx
  802328:	39 d0                	cmp    %edx,%eax
  80232a:	73 e2                	jae    80230e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80232c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80232f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802333:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802336:	89 c2                	mov    %eax,%edx
  802338:	c1 fa 1f             	sar    $0x1f,%edx
  80233b:	89 d1                	mov    %edx,%ecx
  80233d:	c1 e9 1b             	shr    $0x1b,%ecx
  802340:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802343:	83 e2 1f             	and    $0x1f,%edx
  802346:	29 ca                	sub    %ecx,%edx
  802348:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80234c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802350:	83 c0 01             	add    $0x1,%eax
  802353:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802356:	83 c7 01             	add    $0x1,%edi
  802359:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80235c:	75 c2                	jne    802320 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80235e:	8b 45 10             	mov    0x10(%ebp),%eax
  802361:	eb 05                	jmp    802368 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802368:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80236b:	5b                   	pop    %ebx
  80236c:	5e                   	pop    %esi
  80236d:	5f                   	pop    %edi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	57                   	push   %edi
  802374:	56                   	push   %esi
  802375:	53                   	push   %ebx
  802376:	83 ec 18             	sub    $0x18,%esp
  802379:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80237c:	57                   	push   %edi
  80237d:	e8 cd f0 ff ff       	call   80144f <fd2data>
  802382:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802384:	83 c4 10             	add    $0x10,%esp
  802387:	bb 00 00 00 00       	mov    $0x0,%ebx
  80238c:	eb 3d                	jmp    8023cb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80238e:	85 db                	test   %ebx,%ebx
  802390:	74 04                	je     802396 <devpipe_read+0x26>
				return i;
  802392:	89 d8                	mov    %ebx,%eax
  802394:	eb 44                	jmp    8023da <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802396:	89 f2                	mov    %esi,%edx
  802398:	89 f8                	mov    %edi,%eax
  80239a:	e8 f2 fe ff ff       	call   802291 <_pipeisclosed>
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	75 32                	jne    8023d5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023a3:	e8 85 eb ff ff       	call   800f2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023a8:	8b 06                	mov    (%esi),%eax
  8023aa:	3b 46 04             	cmp    0x4(%esi),%eax
  8023ad:	74 df                	je     80238e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023af:	99                   	cltd   
  8023b0:	c1 ea 1b             	shr    $0x1b,%edx
  8023b3:	01 d0                	add    %edx,%eax
  8023b5:	83 e0 1f             	and    $0x1f,%eax
  8023b8:	29 d0                	sub    %edx,%eax
  8023ba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023c2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023c5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023c8:	83 c3 01             	add    $0x1,%ebx
  8023cb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023ce:	75 d8                	jne    8023a8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8023d3:	eb 05                	jmp    8023da <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023d5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    

008023e2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	56                   	push   %esi
  8023e6:	53                   	push   %ebx
  8023e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ed:	50                   	push   %eax
  8023ee:	e8 73 f0 ff ff       	call   801466 <fd_alloc>
  8023f3:	83 c4 10             	add    $0x10,%esp
  8023f6:	89 c2                	mov    %eax,%edx
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	0f 88 2c 01 00 00    	js     80252c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802400:	83 ec 04             	sub    $0x4,%esp
  802403:	68 07 04 00 00       	push   $0x407
  802408:	ff 75 f4             	pushl  -0xc(%ebp)
  80240b:	6a 00                	push   $0x0
  80240d:	e8 3a eb ff ff       	call   800f4c <sys_page_alloc>
  802412:	83 c4 10             	add    $0x10,%esp
  802415:	89 c2                	mov    %eax,%edx
  802417:	85 c0                	test   %eax,%eax
  802419:	0f 88 0d 01 00 00    	js     80252c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80241f:	83 ec 0c             	sub    $0xc,%esp
  802422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802425:	50                   	push   %eax
  802426:	e8 3b f0 ff ff       	call   801466 <fd_alloc>
  80242b:	89 c3                	mov    %eax,%ebx
  80242d:	83 c4 10             	add    $0x10,%esp
  802430:	85 c0                	test   %eax,%eax
  802432:	0f 88 e2 00 00 00    	js     80251a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802438:	83 ec 04             	sub    $0x4,%esp
  80243b:	68 07 04 00 00       	push   $0x407
  802440:	ff 75 f0             	pushl  -0x10(%ebp)
  802443:	6a 00                	push   $0x0
  802445:	e8 02 eb ff ff       	call   800f4c <sys_page_alloc>
  80244a:	89 c3                	mov    %eax,%ebx
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	85 c0                	test   %eax,%eax
  802451:	0f 88 c3 00 00 00    	js     80251a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802457:	83 ec 0c             	sub    $0xc,%esp
  80245a:	ff 75 f4             	pushl  -0xc(%ebp)
  80245d:	e8 ed ef ff ff       	call   80144f <fd2data>
  802462:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802464:	83 c4 0c             	add    $0xc,%esp
  802467:	68 07 04 00 00       	push   $0x407
  80246c:	50                   	push   %eax
  80246d:	6a 00                	push   $0x0
  80246f:	e8 d8 ea ff ff       	call   800f4c <sys_page_alloc>
  802474:	89 c3                	mov    %eax,%ebx
  802476:	83 c4 10             	add    $0x10,%esp
  802479:	85 c0                	test   %eax,%eax
  80247b:	0f 88 89 00 00 00    	js     80250a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802481:	83 ec 0c             	sub    $0xc,%esp
  802484:	ff 75 f0             	pushl  -0x10(%ebp)
  802487:	e8 c3 ef ff ff       	call   80144f <fd2data>
  80248c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802493:	50                   	push   %eax
  802494:	6a 00                	push   $0x0
  802496:	56                   	push   %esi
  802497:	6a 00                	push   $0x0
  802499:	e8 f1 ea ff ff       	call   800f8f <sys_page_map>
  80249e:	89 c3                	mov    %eax,%ebx
  8024a0:	83 c4 20             	add    $0x20,%esp
  8024a3:	85 c0                	test   %eax,%eax
  8024a5:	78 55                	js     8024fc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024a7:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024bc:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024d1:	83 ec 0c             	sub    $0xc,%esp
  8024d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d7:	e8 63 ef ff ff       	call   80143f <fd2num>
  8024dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024df:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024e1:	83 c4 04             	add    $0x4,%esp
  8024e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8024e7:	e8 53 ef ff ff       	call   80143f <fd2num>
  8024ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024ef:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024fa:	eb 30                	jmp    80252c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024fc:	83 ec 08             	sub    $0x8,%esp
  8024ff:	56                   	push   %esi
  802500:	6a 00                	push   $0x0
  802502:	e8 ca ea ff ff       	call   800fd1 <sys_page_unmap>
  802507:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80250a:	83 ec 08             	sub    $0x8,%esp
  80250d:	ff 75 f0             	pushl  -0x10(%ebp)
  802510:	6a 00                	push   $0x0
  802512:	e8 ba ea ff ff       	call   800fd1 <sys_page_unmap>
  802517:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80251a:	83 ec 08             	sub    $0x8,%esp
  80251d:	ff 75 f4             	pushl  -0xc(%ebp)
  802520:	6a 00                	push   $0x0
  802522:	e8 aa ea ff ff       	call   800fd1 <sys_page_unmap>
  802527:	83 c4 10             	add    $0x10,%esp
  80252a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80252c:	89 d0                	mov    %edx,%eax
  80252e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    

00802535 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802535:	55                   	push   %ebp
  802536:	89 e5                	mov    %esp,%ebp
  802538:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80253b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80253e:	50                   	push   %eax
  80253f:	ff 75 08             	pushl  0x8(%ebp)
  802542:	e8 6e ef ff ff       	call   8014b5 <fd_lookup>
  802547:	89 c2                	mov    %eax,%edx
  802549:	83 c4 10             	add    $0x10,%esp
  80254c:	85 d2                	test   %edx,%edx
  80254e:	78 18                	js     802568 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802550:	83 ec 0c             	sub    $0xc,%esp
  802553:	ff 75 f4             	pushl  -0xc(%ebp)
  802556:	e8 f4 ee ff ff       	call   80144f <fd2data>
	return _pipeisclosed(fd, p);
  80255b:	89 c2                	mov    %eax,%edx
  80255d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802560:	e8 2c fd ff ff       	call   802291 <_pipeisclosed>
  802565:	83 c4 10             	add    $0x10,%esp
}
  802568:	c9                   	leave  
  802569:	c3                   	ret    

0080256a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
  802570:	83 ec 0c             	sub    $0xc,%esp
  802573:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802576:	85 f6                	test   %esi,%esi
  802578:	75 16                	jne    802590 <wait+0x26>
  80257a:	68 49 31 80 00       	push   $0x803149
  80257f:	68 2f 30 80 00       	push   $0x80302f
  802584:	6a 09                	push   $0x9
  802586:	68 54 31 80 00       	push   $0x803154
  80258b:	e8 55 df ff ff       	call   8004e5 <_panic>
	e = &envs[ENVX(envid)];
  802590:	89 f3                	mov    %esi,%ebx
  802592:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802598:	6b db 78             	imul   $0x78,%ebx,%ebx
  80259b:	8d 7b 40             	lea    0x40(%ebx),%edi
  80259e:	83 c3 50             	add    $0x50,%ebx
  8025a1:	eb 05                	jmp    8025a8 <wait+0x3e>
		sys_yield();
  8025a3:	e8 85 e9 ff ff       	call   800f2d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025a8:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  8025ae:	39 f0                	cmp    %esi,%eax
  8025b0:	75 0a                	jne    8025bc <wait+0x52>
  8025b2:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  8025b8:	85 c0                	test   %eax,%eax
  8025ba:	75 e7                	jne    8025a3 <wait+0x39>
		sys_yield();
}
  8025bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    

008025c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8025ca:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025d1:	75 2c                	jne    8025ff <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8025d3:	83 ec 04             	sub    $0x4,%esp
  8025d6:	6a 07                	push   $0x7
  8025d8:	68 00 f0 7f ee       	push   $0xee7ff000
  8025dd:	6a 00                	push   $0x0
  8025df:	e8 68 e9 ff ff       	call   800f4c <sys_page_alloc>
  8025e4:	83 c4 10             	add    $0x10,%esp
  8025e7:	85 c0                	test   %eax,%eax
  8025e9:	79 14                	jns    8025ff <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  8025eb:	83 ec 04             	sub    $0x4,%esp
  8025ee:	68 60 31 80 00       	push   $0x803160
  8025f3:	6a 1f                	push   $0x1f
  8025f5:	68 c4 31 80 00       	push   $0x8031c4
  8025fa:	e8 e6 de ff ff       	call   8004e5 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802602:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802607:	83 ec 08             	sub    $0x8,%esp
  80260a:	68 33 26 80 00       	push   $0x802633
  80260f:	6a 00                	push   $0x0
  802611:	e8 81 ea ff ff       	call   801097 <sys_env_set_pgfault_upcall>
  802616:	83 c4 10             	add    $0x10,%esp
  802619:	85 c0                	test   %eax,%eax
  80261b:	79 14                	jns    802631 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80261d:	83 ec 04             	sub    $0x4,%esp
  802620:	68 8c 31 80 00       	push   $0x80318c
  802625:	6a 25                	push   $0x25
  802627:	68 c4 31 80 00       	push   $0x8031c4
  80262c:	e8 b4 de ff ff       	call   8004e5 <_panic>
}
  802631:	c9                   	leave  
  802632:	c3                   	ret    

00802633 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802633:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802634:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802639:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80263b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  80263e:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  802640:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  802644:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  802648:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  802649:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  80264c:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  80264e:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  802651:	83 c4 04             	add    $0x4,%esp
	popal 
  802654:	61                   	popa   
	addl $4, %esp 
  802655:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  802658:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  802659:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  80265a:	c3                   	ret    

0080265b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80265b:	55                   	push   %ebp
  80265c:	89 e5                	mov    %esp,%ebp
  80265e:	56                   	push   %esi
  80265f:	53                   	push   %ebx
  802660:	8b 75 08             	mov    0x8(%ebp),%esi
  802663:	8b 45 0c             	mov    0xc(%ebp),%eax
  802666:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  802669:	85 f6                	test   %esi,%esi
  80266b:	74 06                	je     802673 <ipc_recv+0x18>
  80266d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802673:	85 db                	test   %ebx,%ebx
  802675:	74 06                	je     80267d <ipc_recv+0x22>
  802677:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  80267d:	83 f8 01             	cmp    $0x1,%eax
  802680:	19 d2                	sbb    %edx,%edx
  802682:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  802684:	83 ec 0c             	sub    $0xc,%esp
  802687:	50                   	push   %eax
  802688:	e8 6f ea ff ff       	call   8010fc <sys_ipc_recv>
  80268d:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  80268f:	83 c4 10             	add    $0x10,%esp
  802692:	85 d2                	test   %edx,%edx
  802694:	75 24                	jne    8026ba <ipc_recv+0x5f>
	if (from_env_store)
  802696:	85 f6                	test   %esi,%esi
  802698:	74 0a                	je     8026a4 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  80269a:	a1 04 50 80 00       	mov    0x805004,%eax
  80269f:	8b 40 70             	mov    0x70(%eax),%eax
  8026a2:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8026a4:	85 db                	test   %ebx,%ebx
  8026a6:	74 0a                	je     8026b2 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  8026a8:	a1 04 50 80 00       	mov    0x805004,%eax
  8026ad:	8b 40 74             	mov    0x74(%eax),%eax
  8026b0:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8026b2:	a1 04 50 80 00       	mov    0x805004,%eax
  8026b7:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  8026ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5d                   	pop    %ebp
  8026c0:	c3                   	ret    

008026c1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026c1:	55                   	push   %ebp
  8026c2:	89 e5                	mov    %esp,%ebp
  8026c4:	57                   	push   %edi
  8026c5:	56                   	push   %esi
  8026c6:	53                   	push   %ebx
  8026c7:	83 ec 0c             	sub    $0xc,%esp
  8026ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  8026d3:	83 fb 01             	cmp    $0x1,%ebx
  8026d6:	19 c0                	sbb    %eax,%eax
  8026d8:	09 c3                	or     %eax,%ebx
  8026da:	eb 1c                	jmp    8026f8 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  8026dc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026df:	74 12                	je     8026f3 <ipc_send+0x32>
  8026e1:	50                   	push   %eax
  8026e2:	68 d2 31 80 00       	push   $0x8031d2
  8026e7:	6a 36                	push   $0x36
  8026e9:	68 e9 31 80 00       	push   $0x8031e9
  8026ee:	e8 f2 dd ff ff       	call   8004e5 <_panic>
		sys_yield();
  8026f3:	e8 35 e8 ff ff       	call   800f2d <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8026f8:	ff 75 14             	pushl  0x14(%ebp)
  8026fb:	53                   	push   %ebx
  8026fc:	56                   	push   %esi
  8026fd:	57                   	push   %edi
  8026fe:	e8 d6 e9 ff ff       	call   8010d9 <sys_ipc_try_send>
		if (ret == 0) break;
  802703:	83 c4 10             	add    $0x10,%esp
  802706:	85 c0                	test   %eax,%eax
  802708:	75 d2                	jne    8026dc <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  80270a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5f                   	pop    %edi
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    

00802712 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802712:	55                   	push   %ebp
  802713:	89 e5                	mov    %esp,%ebp
  802715:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802718:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80271d:	6b d0 78             	imul   $0x78,%eax,%edx
  802720:	83 c2 50             	add    $0x50,%edx
  802723:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802729:	39 ca                	cmp    %ecx,%edx
  80272b:	75 0d                	jne    80273a <ipc_find_env+0x28>
			return envs[i].env_id;
  80272d:	6b c0 78             	imul   $0x78,%eax,%eax
  802730:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802735:	8b 40 08             	mov    0x8(%eax),%eax
  802738:	eb 0e                	jmp    802748 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80273a:	83 c0 01             	add    $0x1,%eax
  80273d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802742:	75 d9                	jne    80271d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802744:	66 b8 00 00          	mov    $0x0,%ax
}
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    

0080274a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80274a:	55                   	push   %ebp
  80274b:	89 e5                	mov    %esp,%ebp
  80274d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802750:	89 d0                	mov    %edx,%eax
  802752:	c1 e8 16             	shr    $0x16,%eax
  802755:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80275c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802761:	f6 c1 01             	test   $0x1,%cl
  802764:	74 1d                	je     802783 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802766:	c1 ea 0c             	shr    $0xc,%edx
  802769:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802770:	f6 c2 01             	test   $0x1,%dl
  802773:	74 0e                	je     802783 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802775:	c1 ea 0c             	shr    $0xc,%edx
  802778:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80277f:	ef 
  802780:	0f b7 c0             	movzwl %ax,%eax
}
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	66 90                	xchg   %ax,%ax
  802787:	66 90                	xchg   %ax,%ax
  802789:	66 90                	xchg   %ax,%ax
  80278b:	66 90                	xchg   %ax,%ax
  80278d:	66 90                	xchg   %ax,%ax
  80278f:	90                   	nop

00802790 <__udivdi3>:
  802790:	55                   	push   %ebp
  802791:	57                   	push   %edi
  802792:	56                   	push   %esi
  802793:	83 ec 10             	sub    $0x10,%esp
  802796:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80279a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80279e:	8b 74 24 24          	mov    0x24(%esp),%esi
  8027a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8027a6:	85 d2                	test   %edx,%edx
  8027a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027ac:	89 34 24             	mov    %esi,(%esp)
  8027af:	89 c8                	mov    %ecx,%eax
  8027b1:	75 35                	jne    8027e8 <__udivdi3+0x58>
  8027b3:	39 f1                	cmp    %esi,%ecx
  8027b5:	0f 87 bd 00 00 00    	ja     802878 <__udivdi3+0xe8>
  8027bb:	85 c9                	test   %ecx,%ecx
  8027bd:	89 cd                	mov    %ecx,%ebp
  8027bf:	75 0b                	jne    8027cc <__udivdi3+0x3c>
  8027c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c6:	31 d2                	xor    %edx,%edx
  8027c8:	f7 f1                	div    %ecx
  8027ca:	89 c5                	mov    %eax,%ebp
  8027cc:	89 f0                	mov    %esi,%eax
  8027ce:	31 d2                	xor    %edx,%edx
  8027d0:	f7 f5                	div    %ebp
  8027d2:	89 c6                	mov    %eax,%esi
  8027d4:	89 f8                	mov    %edi,%eax
  8027d6:	f7 f5                	div    %ebp
  8027d8:	89 f2                	mov    %esi,%edx
  8027da:	83 c4 10             	add    $0x10,%esp
  8027dd:	5e                   	pop    %esi
  8027de:	5f                   	pop    %edi
  8027df:	5d                   	pop    %ebp
  8027e0:	c3                   	ret    
  8027e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	3b 14 24             	cmp    (%esp),%edx
  8027eb:	77 7b                	ja     802868 <__udivdi3+0xd8>
  8027ed:	0f bd f2             	bsr    %edx,%esi
  8027f0:	83 f6 1f             	xor    $0x1f,%esi
  8027f3:	0f 84 97 00 00 00    	je     802890 <__udivdi3+0x100>
  8027f9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8027fe:	89 d7                	mov    %edx,%edi
  802800:	89 f1                	mov    %esi,%ecx
  802802:	29 f5                	sub    %esi,%ebp
  802804:	d3 e7                	shl    %cl,%edi
  802806:	89 c2                	mov    %eax,%edx
  802808:	89 e9                	mov    %ebp,%ecx
  80280a:	d3 ea                	shr    %cl,%edx
  80280c:	89 f1                	mov    %esi,%ecx
  80280e:	09 fa                	or     %edi,%edx
  802810:	8b 3c 24             	mov    (%esp),%edi
  802813:	d3 e0                	shl    %cl,%eax
  802815:	89 54 24 08          	mov    %edx,0x8(%esp)
  802819:	89 e9                	mov    %ebp,%ecx
  80281b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80281f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802823:	89 fa                	mov    %edi,%edx
  802825:	d3 ea                	shr    %cl,%edx
  802827:	89 f1                	mov    %esi,%ecx
  802829:	d3 e7                	shl    %cl,%edi
  80282b:	89 e9                	mov    %ebp,%ecx
  80282d:	d3 e8                	shr    %cl,%eax
  80282f:	09 c7                	or     %eax,%edi
  802831:	89 f8                	mov    %edi,%eax
  802833:	f7 74 24 08          	divl   0x8(%esp)
  802837:	89 d5                	mov    %edx,%ebp
  802839:	89 c7                	mov    %eax,%edi
  80283b:	f7 64 24 0c          	mull   0xc(%esp)
  80283f:	39 d5                	cmp    %edx,%ebp
  802841:	89 14 24             	mov    %edx,(%esp)
  802844:	72 11                	jb     802857 <__udivdi3+0xc7>
  802846:	8b 54 24 04          	mov    0x4(%esp),%edx
  80284a:	89 f1                	mov    %esi,%ecx
  80284c:	d3 e2                	shl    %cl,%edx
  80284e:	39 c2                	cmp    %eax,%edx
  802850:	73 5e                	jae    8028b0 <__udivdi3+0x120>
  802852:	3b 2c 24             	cmp    (%esp),%ebp
  802855:	75 59                	jne    8028b0 <__udivdi3+0x120>
  802857:	8d 47 ff             	lea    -0x1(%edi),%eax
  80285a:	31 f6                	xor    %esi,%esi
  80285c:	89 f2                	mov    %esi,%edx
  80285e:	83 c4 10             	add    $0x10,%esp
  802861:	5e                   	pop    %esi
  802862:	5f                   	pop    %edi
  802863:	5d                   	pop    %ebp
  802864:	c3                   	ret    
  802865:	8d 76 00             	lea    0x0(%esi),%esi
  802868:	31 f6                	xor    %esi,%esi
  80286a:	31 c0                	xor    %eax,%eax
  80286c:	89 f2                	mov    %esi,%edx
  80286e:	83 c4 10             	add    $0x10,%esp
  802871:	5e                   	pop    %esi
  802872:	5f                   	pop    %edi
  802873:	5d                   	pop    %ebp
  802874:	c3                   	ret    
  802875:	8d 76 00             	lea    0x0(%esi),%esi
  802878:	89 f2                	mov    %esi,%edx
  80287a:	31 f6                	xor    %esi,%esi
  80287c:	89 f8                	mov    %edi,%eax
  80287e:	f7 f1                	div    %ecx
  802880:	89 f2                	mov    %esi,%edx
  802882:	83 c4 10             	add    $0x10,%esp
  802885:	5e                   	pop    %esi
  802886:	5f                   	pop    %edi
  802887:	5d                   	pop    %ebp
  802888:	c3                   	ret    
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802894:	76 0b                	jbe    8028a1 <__udivdi3+0x111>
  802896:	31 c0                	xor    %eax,%eax
  802898:	3b 14 24             	cmp    (%esp),%edx
  80289b:	0f 83 37 ff ff ff    	jae    8027d8 <__udivdi3+0x48>
  8028a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a6:	e9 2d ff ff ff       	jmp    8027d8 <__udivdi3+0x48>
  8028ab:	90                   	nop
  8028ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028b0:	89 f8                	mov    %edi,%eax
  8028b2:	31 f6                	xor    %esi,%esi
  8028b4:	e9 1f ff ff ff       	jmp    8027d8 <__udivdi3+0x48>
  8028b9:	66 90                	xchg   %ax,%ax
  8028bb:	66 90                	xchg   %ax,%ax
  8028bd:	66 90                	xchg   %ax,%ax
  8028bf:	90                   	nop

008028c0 <__umoddi3>:
  8028c0:	55                   	push   %ebp
  8028c1:	57                   	push   %edi
  8028c2:	56                   	push   %esi
  8028c3:	83 ec 20             	sub    $0x20,%esp
  8028c6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8028ca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028ce:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028d2:	89 c6                	mov    %eax,%esi
  8028d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028d8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8028dc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8028e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028e8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028ec:	85 c0                	test   %eax,%eax
  8028ee:	89 c2                	mov    %eax,%edx
  8028f0:	75 1e                	jne    802910 <__umoddi3+0x50>
  8028f2:	39 f7                	cmp    %esi,%edi
  8028f4:	76 52                	jbe    802948 <__umoddi3+0x88>
  8028f6:	89 c8                	mov    %ecx,%eax
  8028f8:	89 f2                	mov    %esi,%edx
  8028fa:	f7 f7                	div    %edi
  8028fc:	89 d0                	mov    %edx,%eax
  8028fe:	31 d2                	xor    %edx,%edx
  802900:	83 c4 20             	add    $0x20,%esp
  802903:	5e                   	pop    %esi
  802904:	5f                   	pop    %edi
  802905:	5d                   	pop    %ebp
  802906:	c3                   	ret    
  802907:	89 f6                	mov    %esi,%esi
  802909:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802910:	39 f0                	cmp    %esi,%eax
  802912:	77 5c                	ja     802970 <__umoddi3+0xb0>
  802914:	0f bd e8             	bsr    %eax,%ebp
  802917:	83 f5 1f             	xor    $0x1f,%ebp
  80291a:	75 64                	jne    802980 <__umoddi3+0xc0>
  80291c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802920:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802924:	0f 86 f6 00 00 00    	jbe    802a20 <__umoddi3+0x160>
  80292a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80292e:	0f 82 ec 00 00 00    	jb     802a20 <__umoddi3+0x160>
  802934:	8b 44 24 14          	mov    0x14(%esp),%eax
  802938:	8b 54 24 18          	mov    0x18(%esp),%edx
  80293c:	83 c4 20             	add    $0x20,%esp
  80293f:	5e                   	pop    %esi
  802940:	5f                   	pop    %edi
  802941:	5d                   	pop    %ebp
  802942:	c3                   	ret    
  802943:	90                   	nop
  802944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802948:	85 ff                	test   %edi,%edi
  80294a:	89 fd                	mov    %edi,%ebp
  80294c:	75 0b                	jne    802959 <__umoddi3+0x99>
  80294e:	b8 01 00 00 00       	mov    $0x1,%eax
  802953:	31 d2                	xor    %edx,%edx
  802955:	f7 f7                	div    %edi
  802957:	89 c5                	mov    %eax,%ebp
  802959:	8b 44 24 10          	mov    0x10(%esp),%eax
  80295d:	31 d2                	xor    %edx,%edx
  80295f:	f7 f5                	div    %ebp
  802961:	89 c8                	mov    %ecx,%eax
  802963:	f7 f5                	div    %ebp
  802965:	eb 95                	jmp    8028fc <__umoddi3+0x3c>
  802967:	89 f6                	mov    %esi,%esi
  802969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 20             	add    $0x20,%esp
  802977:	5e                   	pop    %esi
  802978:	5f                   	pop    %edi
  802979:	5d                   	pop    %ebp
  80297a:	c3                   	ret    
  80297b:	90                   	nop
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	b8 20 00 00 00       	mov    $0x20,%eax
  802985:	89 e9                	mov    %ebp,%ecx
  802987:	29 e8                	sub    %ebp,%eax
  802989:	d3 e2                	shl    %cl,%edx
  80298b:	89 c7                	mov    %eax,%edi
  80298d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802991:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802995:	89 f9                	mov    %edi,%ecx
  802997:	d3 e8                	shr    %cl,%eax
  802999:	89 c1                	mov    %eax,%ecx
  80299b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80299f:	09 d1                	or     %edx,%ecx
  8029a1:	89 fa                	mov    %edi,%edx
  8029a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8029a7:	89 e9                	mov    %ebp,%ecx
  8029a9:	d3 e0                	shl    %cl,%eax
  8029ab:	89 f9                	mov    %edi,%ecx
  8029ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029b1:	89 f0                	mov    %esi,%eax
  8029b3:	d3 e8                	shr    %cl,%eax
  8029b5:	89 e9                	mov    %ebp,%ecx
  8029b7:	89 c7                	mov    %eax,%edi
  8029b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8029bd:	d3 e6                	shl    %cl,%esi
  8029bf:	89 d1                	mov    %edx,%ecx
  8029c1:	89 fa                	mov    %edi,%edx
  8029c3:	d3 e8                	shr    %cl,%eax
  8029c5:	89 e9                	mov    %ebp,%ecx
  8029c7:	09 f0                	or     %esi,%eax
  8029c9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8029cd:	f7 74 24 10          	divl   0x10(%esp)
  8029d1:	d3 e6                	shl    %cl,%esi
  8029d3:	89 d1                	mov    %edx,%ecx
  8029d5:	f7 64 24 0c          	mull   0xc(%esp)
  8029d9:	39 d1                	cmp    %edx,%ecx
  8029db:	89 74 24 14          	mov    %esi,0x14(%esp)
  8029df:	89 d7                	mov    %edx,%edi
  8029e1:	89 c6                	mov    %eax,%esi
  8029e3:	72 0a                	jb     8029ef <__umoddi3+0x12f>
  8029e5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8029e9:	73 10                	jae    8029fb <__umoddi3+0x13b>
  8029eb:	39 d1                	cmp    %edx,%ecx
  8029ed:	75 0c                	jne    8029fb <__umoddi3+0x13b>
  8029ef:	89 d7                	mov    %edx,%edi
  8029f1:	89 c6                	mov    %eax,%esi
  8029f3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8029f7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8029fb:	89 ca                	mov    %ecx,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a03:	29 f0                	sub    %esi,%eax
  802a05:	19 fa                	sbb    %edi,%edx
  802a07:	d3 e8                	shr    %cl,%eax
  802a09:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  802a0e:	89 d7                	mov    %edx,%edi
  802a10:	d3 e7                	shl    %cl,%edi
  802a12:	89 e9                	mov    %ebp,%ecx
  802a14:	09 f8                	or     %edi,%eax
  802a16:	d3 ea                	shr    %cl,%edx
  802a18:	83 c4 20             	add    $0x20,%esp
  802a1b:	5e                   	pop    %esi
  802a1c:	5f                   	pop    %edi
  802a1d:	5d                   	pop    %ebp
  802a1e:	c3                   	ret    
  802a1f:	90                   	nop
  802a20:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a24:	29 f9                	sub    %edi,%ecx
  802a26:	19 c6                	sbb    %eax,%esi
  802a28:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802a2c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802a30:	e9 ff fe ff ff       	jmp    802934 <__umoddi3+0x74>
